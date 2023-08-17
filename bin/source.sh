#!/usr/bin/env bash
. "$(dirname "${0}")/config.sh"
BOLD="$(tput bold)"
RESET="$(tput sgr0)"
WHITE="$(tput setaf 15)"
choosejavaflags(){
    # Run in subshell so we can use local.
    case "$JAVAFLAGSCHOICE" in
    'aikar')
        JAVAFLAGS='-XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true'
        ;;
    'zgc')
        JAVAFLAGS='-XX:+IgnoreUnrecognizedVMOptions -XX:+UnlockExperimentalVMOptions -XX:+UnlockDiagnosticVMOptions -XX:-OmitStackTraceInFastThrow -XX:+ShowCodeDetailsInExceptionMessages -XX:+DisableExplicitGC -XX:-UseParallelGC -XX:+PerfDisableSharedMem -XX:+UseZGC -XX:-ZUncommit -XX:ZUncommitDelay=300 -XX:ZCollectionInterval=5 -XX:ZAllocationSpikeTolerance=2.0 -XX:+AlwaysPreTouch -XX:+UseTransparentHugePages -XX:LargePageSizeInBytes=2M -XX:+UseLargePages -XX:+ParallelRefProcEnabled'
        ;;
    'brucethemoose')
        JAVAFLAGS='-XX:+UseTransparentHugePages -XX:+UseZGC -XX:AllocatePrefetchStyle=1 -XX:-ZProactive -XX:+UnlockExperimentalVMOptions -XX:+UnlockDiagnosticVMOptions -XX:+AlwaysActAsServerClassMachine -XX:+AlwaysPreTouch -XX:+DisableExplicitGC -XX:+UseNUMA -XX:NmethodSweepActivity=1 -XX:ReservedCodeCacheSize=400M -XX:NonNMethodCodeHeapSize=12M -XX:ProfiledCodeHeapSize=194M -XX:NonProfiledCodeHeapSize=194M -XX:-DontCompileHugeMethods -XX:MaxNodeLimit=240000 -XX:NodeLimitFudgeFactor=8000 -XX:+UseVectorCmov -XX:+PerfDisableSharedMem -XX:+UseFastUnorderedTimeStamps -XX:+UseCriticalJavaThreadPriority -XX:ThreadPriorityPolicy=1 -XX:AllocatePrefetchStyle=3'
        ;;
    esac
    export JAVAFLAGS
}
out(){
    if [[ -t 1 ]]
    then
        for ARG in "${@}"; do
            echo -e "$(tput setaf 4)${BOLD}==>${RESET} $(tput setaf 15)${ARG} ${RESET}"
        done
    else
        echo "${@}"
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
        for ARG in "${@}"
        do
            echo -e "$(tput setaf 5)${BOLD}==> ${RED}${ARG} ${RESET}"
        done
        echo "${RED}Aborting ... ${RESET}"
    else
        echo -e "${*} \nAborting ..."
    fi
}
pushd_noerror(){
    [[ ! -d "${1}" ]] && \
        mkdir -p "${1}"
    pushd "${1}"
}

choosejavaflags

export JAVAOPTS="-Xmx${MINMEMORY}M -Xms${MAXMEMORY}M ${JAVAFLAGS} --add-modules=jdk.incubator.vector -jar"

