#!/usr/bin/env bash
set -x
set -Bboum pipefail
source "$(dirname "${0}")"/source.sh
export TMUX=('tmux' '-S' "/tmp/tmux-$(id -u)/default")
help(){
    echo "Usage: ${0} <start|headless_start|sleepstart|stop|restart|attach|help>"
    exit "${1}"
}
eval_verb(){
    case "${1}" in
    'start'|'stop'|'attach') : ;;
    'help') help 0 ;;
    "*")    abort "\'$1\' is not a valid argument"
            help 2
            ;;
    esac
}
already_running(){
    pgrep -U "$(id -u)" java
}
has_tmux(){
	${TMUX[*]} has -t "${TMUX_SESSION}" 2>/dev/null
}
no_tmux_error(){
    abort "The tmux session is not running" && exit 1
}
pushd_noerror "${MC_DIR}"
JAR="$(find "${MC_DIR}" -maxdepth 1 -name "*.jar")"
#unset DISPLAY # Problems with X11 trying to set display
EXEC="java ${JAVAOPTS} ${JAR} ${OPTS}"
export JAR EXEC
[[ "$(whoami)" != 'minecraft' ]] && abort "Must be run as 'minecraft' user" && exit 1
case "${#}" in
0)  help 2 ;;
1)  eval_verb "${1}" ;;
2)  eval_verb "${1}"
    export MC_DIR="${2}" ;;
3)  echo 'Too many arguments' ;;
esac
case "${1}" in
'start')
    if ! has_tmux
    then
	    ${TMUX[*]} new -dn 'Trash' -s "${TMUX_SESSION}"
        #export KILLW='true'
        export KILLW='false'
    else
	   export KILLW='false'
    fi
    if already_running
    then
	   out "Server is already running."
    else
	   ${TMUX[*]} neww -dPn 'Minecraft' -c "${MC_DIR}" -t "${TMUX_SESSION}" bash -c "exec -a Minecraft_Server ${EXEC}"
	   [[ "${KILLW}" = 'true' ]] && \
            ${TMUX[*]} killw -t "${TMUX_SESSION}":'Trash'
        out "Started the Minecraft Server!"
    fi
    ;;
'stop')
    has_tmux || no_tmux_error
    if already_running
    then
        MCRCON_HOST=localhost mcrcon -w 5 "say Server is stoppping!" save-all stop
    else
        warn 'The server is not running.'
        exit 1
    fi
    out "Stopped the Minecraft Server!"
    ;;
'attach')
    has_tmux || no_tmux_error
    ${TMUX[*]} attach -t "${TMUX_SESSION}"
    ${TMUX[*]} selectw -t 'Minecraft'
    ;;
'restart')
    # For interactive restart, not spigot restart.
    exec "${0}" 'stop'
    exec "${0}" 'start'
    out "Retstarted the Server!"
    ;;
'headless_start')
    ${EXEC[*]}
    ;;
esac

