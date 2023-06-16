#!/bin/bash
[[ "$(whoami)" != 'minecraft' ]] && echo 'You are not "minecraft". Aborting ...' && exit 1
. /srv/minecraft/bin/config.sh
grep -i universe <<< ${OPTS}
WORLDS=('creative2' 'creative2_nether' 'survivalx' 'march')
pushd "${MC_DIR}"/universe
for WORLD in ${WORLDS[*]}
do
    tar -czpkf ../backup/"${WORLD}"/"$(date +%Y-%m-%d_%H)".tar.gz ./"${WORLD}" &
    disown $!
    echo "Started backup of ${WORLD}!"
    # -p, preserve permissions, -k, do not overwrite an existing file, new one every hour with $TIME
    #rm "$(ls -t1 | head -n 10)" # always remove oldest copy, aka always have 10 copies
done
popd
exit 0
