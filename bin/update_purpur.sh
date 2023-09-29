#!/usr/bin/env bash
#shellcheck disable=2164,2317
#shellcheck shell=bash
#shellcheck enable=require-variable-braces,require-double-brackets
set -u
SOURCE=${SOURCE:="$(dirname "${0}")/source.sh"}
NOHASHUPDATE=${NOHASHUPDATE:='false'} # If true, will download every time if there's an update or not.
INTOUPDATE=${INTOUPDATE:='true'} # If true, will download updates into the 'update' folder.
#shellcheck source-path=SCRIPTDIR
#shellcheck source=source.sh
. "${SOURCE}"
GH_TOKEN="$(cat "${MC_DIR}"/gh_token)"
CF_TOKEN="$(cat "${MC_DIR}"/curseforge_token")"
export GH_TOKEN
badfile(){
  warn "Download of ${1} failed, or file did not match hash. \nTry manually downloading or restoring file from ~/.local/share/trash/files ."
}
intoupdate(){
  [[ "${INTOUPDATE}" = 'true' ]] || return
  if [[ "$(basename "$(pwd)")" = 'update' ]]
  then
    popd
  else
    pushd_noerror "${MC_DIR}/plugins/update"
  fi
}
skipnohashupdate(){
  if [[ "${NOHASHUPDATE}" = 'false' ]]
  then
    out "Skipping ${1} because \$NOHASHUPATE = false."
    return 1
  fi
}
consturl(){
  skipnohashupdate "${1}" || return 0
  if curl -JLOf# --clobber "${2}"
  then
    out "Successfully downloaded latest version of ${1}!"
  else
    warn "Unable to download ${1}. Check your internet connection. "
  fi
}
githubeval(){
  skipnohashupdate "${1}" || return 0
  local -r REPO="${1}" NAME="${1#*/}"
  #local -r JQCOMMAND=".[].assets[] | select(startswith(\"${2%'*.jar'}\") | .browser_download_url)"
  if curl -JLOf# --clobber \
    "$(gh api --header 'Accept: application/vnd.github+json' --method GET "/repos/${REPO}/releases" -F per_page=1 |\
      jq -r '.[].assets[].browser_download_url')"
  then
    out "Successfully downloaded latest version of ${1}!"
  else
    warn "Unable to download ${NAME}. Check your internet connection. "
  fi
}
nofilefake(){
  if [[ -z "${FILE}" ]]
  then
    FILE="$(mktemp)"
    export FILE
  fi
}
geysereval(){
  local FILE \
    APIURL="https://download.geysermc.org/v2/projects/${1}/versions/latest/builds/latest" \
    NAME="${1^}"
  FILE="$(find . -maxdepth 1 -name "${2}" 2>/dev/null)"
  nofilefake
  geysercheckintegrity(){
    [[ "$(curl --silent -L "${APIURL}" | jq -r .downloads.spigot.sha256)" = \
      "$(sha256sum "${FILE}" | cut -d " " -f 1 )" ]]
  }
	if geysercheckintegrity
	then
		out "${NAME} is up to date!"
	else
		curl -#L -o "$(curl --silent -L "${APIURL}" |\
      jq -r .downloads.spigot.name)" "${APIURL}"/downloads/spigot
    FILE="$(find . -maxdepth 1 -name "${2}" 2>/dev/null)" # Redefine for geysercheckintegrity
    if geysercheckintegrity
	then
      out "Updated ${NAME}"
    else
      badfile "${NAME}"
    fi
  fi
}
mreval(){
  local FILE \
    APIURL="https://api.modrinth.com/v2/version_file/${3}/update" \
    JQCOMMAND=".files[] | select(.filename | startswith(\"${2%'*.jar'}\"))"
  FILE="$(find . -maxdepth 1 -name "${2}" 2>/dev/null)"
  mrdown(){
    curl -fLX POST --silent "${1}" -H 'Content-Type: application/json' --data-binary @- <<DATA
{
  "loaders": [
      "paper",
      "purpur"
  ],
  "game_versions": [
    "1.20.1",
    "1.20"
  ]
}
DATA
  }
  mrcheckintegrity(){
    [[ "$(mrdown "${APIURL}" | jq -r "${JQCOMMAND} | .hashes.sha1")" = \
      "$(sha1sum "${FILE}" | head -c 40)" ]]
  }
  nofilefake
  if mrcheckintegrity
  then
    out "${1} is up to date!"
  else
    trash "${FILE}"
    curl -JLOf# "$(mrdown "${APIURL}" | \
      jq -r "${JQCOMMAND} | .url")"
    FILE="$(find . -maxdepth 1 -name "${2}" 2>/dev/null)" # We need to redefine since filename has changed.
    if mrcheckintegrity
    then
      out "Updated ${1}"
    else
      badfile "${1}"
    fi
  fi
}
curseeval(){
  cursedown(){
    curl -fLX GET --silent "${1}" -H 'Content-Type: application/json' -H "x-api-key: ${CF_TOKEN}" --data-binary @- <<DATA
{
  "gameVersion": "1.19.4"
}
DATA
  }
}

if ! nc -zw1 google.com 443 &>/dev/null
then
  abort "No internet connection."
  exit 3
fi
##
## Update begins
##

# Purpur is not on modrinth, uses md5sum, and has custom api. Manual section.
PURPURFILE="$(find "${MC_DIR}" -maxdepth 1 -name "purpur-*.jar")"
PURPURREMOTESUM="$(curl -L --silent https://api.purpurmc.org/v2/purpur/"${MINECRAFTVERSION}"/latest | jq -r '.md5')"
PURPUROLDSUM="$(md5sum - < "${PURPURFILE}" | tr -d '  ' | tr -d  '-')"

if [[ "${PURPURREMOTESUM}" = "${PURPUROLDSUM}" ]]
then
  out "Purpur is up to date!"
else
  trash "${PURPURFILE}"
  curl -JLO# "https://api.purpurmc.org/v2/purpur/${MINECRAFTVERSION}/latest/download"
  # Re-eval for new jar name
  PURPURFILE="$(find "${MC_DIR}" -maxdepth 1 -name "*.jar")"
  PURPUROLDSUM="$(md5sum - < "${PURPURFILE}" | tr -d '  ' | tr -d '-')"
  if [[ "${PURPUROLDSUM}" = "${PURPURREMOTESUM}" ]]
  then
    out 'Updated Purpur'
  else
    badfile "${1}"
  fi
fi
pushd_noerror "${MC_DIR}/plugins"
[[ "${INTOUPDATE}" = 'true' ]] && \
  pushd_noerror './update'
mreval 'CoreProtect' 'CoreProtect-*.jar' '7804652e9dd07410a071f7d1388ed89bd29b165c'
warn 'Skipping CraftBook!' # Only available on bukkit.org (curseforge api)
mreval 'EssentialsX' 'EssentialsX-*.jar' 'e626f9f250470bcf2feffbc3740f738f9cee50ef'
geysereval 'floodgate' 'floodgate-spigot.jar'
geysereval 'geyser' 'Geyser-Spigot.jar'
mreval 'GriefPrevention' 'GriefPrevention.jar' '6326af336598a01d008ff384379525fa0495220a'
warn 'Skipping Luckperms!'
mreval 'Pl3xMap' "Pl3xMap-${MINECRAFTVERSION}-*.jar" 'e1243130008327413a1ff4b927d13f6306d11495'
mreval 'Pl3xMap Banners' "Pl3xMap-Banners-${MINECRAFTVERSION}-*.jar" '64cdc60b377a651c97d269ff61d0bdd2dc432af9'
mreval 'Pl3xMap Mobs' "Pl3xMap-Mobs-${MINECRAFTVERSION}-*.jar" '1563fc1fb5c1fe3e027a041038cb63bd5363f379'
mreval 'Pl3xMap Signs' "Pl3xMap-Signs-${MINECRAFTVERSION}-*.jar" '3cb7ca769f6edb81a103fcac8211ac8d98cd8142'
mreval 'Pl3xMap Warps' "Pl3xMap-Warps-${MINECRAFTVERSION}-*.jar" '67e19b61d54ffa4a147280c657325a94ad7ab5ba'
mreval 'DeathSpots' "DeathSpots-${MINECRAFTVERSION}-*.jar" '0e62a02f0537525dbaad71db13b56997a781e5c6'
mreval 'Simple Voice Chat' 'voicechat-bukkit-*.jar' 'a56dd9362c75823e48f4105844c5a5bd315fd309'
githubeval 'MilkBowl/Vault' 'Vault.jar'
warn 'Skipping WorldEdit!' # bukkit.org
out 'Update complete!'
[[ "$(dirname "$(pwd)")" = 'update' ]] && \
  popd
popd
exit 0
