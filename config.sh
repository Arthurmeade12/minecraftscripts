#!/usr/bin/env bash
# source.sh
# Sourced by minecraft scripts.
BOLD="$(tput bold)"
RESET="$(tput sgr0)"
WHITE="$(tput setaf 15)"
out(){
        if [[ -t 1 ]]
        then
                for ARG in "$@"; do
                        echo -e "$(tput setaf 4)${BOLD}==>${RESET} $(tput setaf 15)${ARG} ${RESET}"
                done
    else
        echo "$@"
        fi
}
warn(){
        local -r YELLOW="$(tput setaf 3)"
        if [[ -t 1 ]]
        then
                for ARG in "$@"; do
                        echo -e "${YELLOW}${BOLD}==>${RESET} ${YELLOW}WARNING: ${WHITE}${ARG} ${RESET}"
                done
    else
        echo "$@"
        fi
}
abort(){
        if [[ -t 1 ]]
        then
        local -r RED="$(tput setaf 1)"
        for ARG in "$@"
        do
            echo -e "$(tput setaf 5)${BOLD}==> ${RED}${ARG} ${RESET}"
        done
        echo "${RED}Aborting ... ${RESET}"
    else
        echo -e "$* \nAborting ..."
    fi
}
export MC_DIR=/srv/minecraft/purpur
export MC_CONFIG="${MC_DIR}"/config
export TMUX_SESSION='CENTER'
export MAXJAVA=18
export MINJAVA=17
export MINECRAFTVERSION=1.20 # Affects updating. 
export MCRCON_PASS=CfBwZG3XA
export MCRCON_PORT=30001
export OPTS="--nogui --log-strip-color -b ${MC_CONFIG}/bukkit.yml -C ${MC_CONFIG}/commands.yml -S ${MC_CONFIG}/spigot.yml --paper-dir ${MC_CONFIG}/paper/ --purpur ${MC_CONFIG}/purpur.yml  -W ${MC_DIR}/universe3 -c ${MC_CONFIG}/server.properties -d yyyy.MM.dd at HH:mm:ss -s 40  --server-name Arthurs_Server"
export AIKAR='-XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true'
export ZGC='-XX:+IgnoreUnrecognizedVMOptions -XX:+UnlockExperimentalVMOptions -XX:+UnlockDiagnosticVMOptions -XX:-OmitStackTraceInFastThrow -XX:+ShowCodeDetailsInExceptionMessages -XX:+DisableExplicitGC -XX:-UseParallelGC -XX:+PerfDisableSharedMem -XX:+UseZGC -XX:-ZUncommit -XX:ZUncommitDelay=300 -XX:ZCollectionInterval=5 -XX:ZAllocationSpikeTolerance=2.0 -XX:+AlwaysPreTouch -XX:+UseTransparentHugePages -XX:LargePageSizeInBytes=2M -XX:+UseLargePages -XX:+ParallelRefProcEnabled'
export BRUCETHEMOOSE='-XX:+UseTransparentHugePages -XX:+UseZGC -XX:AllocatePrefetchStyle=1 -XX:-ZProactive -XX:+UnlockExperimentalVMOptions -XX:+UnlockDiagnosticVMOptions -XX:+AlwaysActAsServerClassMachine -XX:+AlwaysPreTouch -XX:+DisableExplicitGC -XX:+UseNUMA -XX:NmethodSweepActivity=1 -XX:ReservedCodeCacheSize=400M -XX:NonNMethodCodeHeapSize=12M -XX:ProfiledCodeHeapSize=194M -XX:NonProfiledCodeHeapSize=194M -XX:-DontCompileHugeMethods -XX:MaxNodeLimit=240000 -XX:NodeLimitFudgeFactor=8000 -XX:+UseVectorCmov -XX:+PerfDisableSharedMem -XX:+UseFastUnorderedTimeStamps -XX:+UseCriticalJavaThreadPriority -XX:ThreadPriorityPolicy=1 -XX:AllocatePrefetchStyle=3'
export JAVAOPTS="-Xmx8192M -Xms8192M ${BRUCETHEMOOSE} --add-modules=jdk.incubator.vector -jar"
export TMUX_ARGS=""
# Done.
