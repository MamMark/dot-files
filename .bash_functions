# .bash_functions
# ver 5.0 20210803 zot u1804
#   add loctun for localhost tunnel (Jupyter)

# set the name of a gnome-terminal
function name () {
    echo -ne "\033]0;$1\007"
}


function e () {
    if [[ -v REM_HOST ]]; then
        emacs -name emacs-${REM_HOST}
    else
        emacs
    fi
}

function shssh () {
    ssh-add -l
    env | grep SSH
    echo "export SSH_AGENT_PID SSH_AUTH_SOCK"
    echo "gnome-session: $(pidof gnome-session)"
    echo "DBUS_SESSION: ${DBUS_SESSION_BUS_ADDRESS}"
}


# loctun - setup or kill a localhost tunnel
# $1 - hostname to tunnel to.
# $2 - 'kill' to kill said tunnel
function loctun () {
    if [ -z "$1" ] ; then
	echo "loctun needs 1 argument, desthost."
	return
    fi
    _desthost=$1
    if [ "$2" == "kill" ] ; then
        _pid=`lsof -t -i @localhost:9000 -sTCP:listen`
        if [ -z "$_pid" ] ; then
            echo "*** no local tunnel found for $_desthost"
            return
        fi
        echo "*** killing $_pid for $_desthost"
        kill $_pid
        return
    fi
    _pid=`lsof -t -i @localhost:9000 -sTCP:listen`
    if [ -n "$_pid" ] ; then
        echo "*** local tunnel for $_desthost already running, $_pid"
        return
    fi
    ssh -N -f -L localhost:9000:localhost:9000 -o ServerAliveInterval=30 pi@$1 &> /tmp/$_desthost_tun.out
    _pid=`lsof -t -i @localhost:9000 -sTCP:listen`
    if [ -z "$_pid" ] ; then
        echo "*** could not start tunnel for $_desthost"
        echo "*** see /tmp/${_desthost}_tun.out for details."
        return
    fi
    echo "*** started $_pid for $_desthost"
}


function shtos () {
    echo "MM_ROOT:       $MM_ROOT"
    echo "ROOT_DIR:      $TINYOS_ROOT_DIR"
    echo "ADDITIONAL:    $TINYOS_ROOT_DIR_ADDITIONAL"
    echo "NO_COLOR:      $TOSMAKE_NO_COLOR"
    echo ""
    echo "PACKAGING_DIR: $PACKAGING_DIR"
    echo "POST_VER:      $POST_VER"
    echo "REPO_DIR:      $REPO_DIR"
    echo -e ""
    echo -e "toolchain:"
    arm-none-eabi-gcc --version | head -1
    pushd ~/tag > /dev/null
    ls -ld t2_cur mm_cur
    popd > /dev/null
    echo
}

function tcur () {
    if [ -z "$1" ] ; then
	echo "tcur (set t2_cur) needs 1 argument."
	return
    fi
    pushd ~/mm > /dev/null
    if [ ! -d "$1" ] ; then
	echo "*** arg 1 should be a directory in ~/mm"
	echo "    $1 doesn't exist"
	return
    fi
    if [ ! -h t2_cur ] ; then
	echo "*** ~/mm/t2_cur isn't a symbolic link, something is wrong"
	return
    fi
    /bin/rm -rf t2_cur
    ln -s $1 t2_cur
    pwd
    ls -l t2_cur
    popd > /dev/null
}
