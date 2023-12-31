#!/usr/bin/env bash
# config.sh
# Sourced by Minecraft scripts.
MC_DIR="$(dirname "$(dirname "$(readlink -f "${0}")")")" # Evaluates to the parent dir of this script's dir.
MC_CONFIG="${MC_DIR}"/config # Folder for config.
TMUX_SESSION='CENTER' # Name of tmux session.
JAVAVERSION=17 # Which version of Java to look for.
# Currently JAVAVERSION does nothing.
MINMEMORY=4096 # See next comment
MAXMEMORY=4096 # Min and max memory to allocate to server in megabytes. Recommended to be the same.
MINECRAFTVERSION=1.20.2 # Affects updating.
MCRCON_PASS=CfBwZG3XA # Password for rcon.
MCRCON_PORT=30001 # Port for rcon.
OPTS="--nogui --log-strip-color -b ${MC_CONFIG}/bukkit.yml -C ${MC_CONFIG}/commands.yml -S ${MC_CONFIG}/spigot.yml --paper-dir ${MC_CONFIG}/paper/ --pufferfish ${MC_CONFIG}/pufferfish.yml --purpur ${MC_CONFIG}/purpur.yml --pidFile ${MC_DIR}/server.pid -W ${MC_DIR}/universe -c ${MC_CONFIG}/server.properties -d yyyy.MM.dd at HH:mm:ss -s 40 --server-name Arthurs_Server" # Opts to pass to the minecraft jar on the cli.
JAVAFLAGSCHOICE='aikar' # Can be 'brucethemoose' for Bruce's flags, 'aikar' for Aikar's flags, or zgc for standard ZGC flags.

# End of file.
