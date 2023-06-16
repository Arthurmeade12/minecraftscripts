#!/usr/bin/env bash
set -Bboum pipefail
source /srv/minecraft/bin/config.sh
export TMUX="tmux"
pushd "${MC_DIR}" || abort "\$MC_DIR does not exist or is not a directory."
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
sleeper_running(){
    already_running || pgrep -f "${MC_DIR}"/mcsleepingserverstarter-linux-x64
}
has_tmux(){
	tmux -S /tmp/tmux-$(id -u)/default has -t "${TMUX_SESSION}" 2>/dev/null
}
no_tmux_error(){
    abort "The tmux session is not running" && exit 1
}
JAR="$(find "${MC_DIR}" -maxdepth 1 -name "*.jar")"
#unset DISPLAY # Problems with X11 trying to set display
EXEC=("bash -c 'exec -a Minecraft_Server archlinux-java-run --max ${MAXJAVA} --min ${MINJAVA} -- ${JAVAOPTS} ${JAR} ${OPTS}'")
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
	    tmux -S /tmp/tmux-$(id -u)/default new -dDn 'Trash' -s "${TMUX_SESSION}"
        export KILLW='true'
else
	export KILLW='false'
    fi
    if already_running 
then
	out "Server is already running."
else
	tmux -S /tmp/tmux-$(id -u)/default neww -dPn 'Minecraft' -c "${MC_DIR}" -t "${TMUX_SESSION}" "${EXEC[*]}"
	[[ "${KILLW}" = 'true' ]] && tmux -S /tmp/tmux-$(id -u)/default killw -t "${TMUX_SESSION}":'Trash'
    out "Started the Minecraft Server!"    
fi
;;
'stop')
    has_tmux || no_tmux_error
    if already_running
    then
        MCRCON_HOST=localhost mcrcon -w 5 "say Server is stoppping!" save-all stop
    elif sleeper_running
    then
	    tmux -S /tmp/tmux-$(id -u)/default send -t "${TMUX_SESSION}:Minecraft" 'quit
        '
	kill -SIGCHLD "$(ps -o ppid= "$(pgrep java)")"
    else
        warn 'The server is not running.'
        exit 1
    fi
    out "Stopped the Minecraft Server!"
    ;;
'attach')
    has_tmux || no_tmux_error
    tmux -S /tmp/tmux-$(id -u)/default attach -t "${TMUX_SESSION}"
    tmux -S /tmp/tmux-$(id -u)/default selectw -t 'Minecraft'
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

