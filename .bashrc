# .bashrc
# Ver 5.0 20190424 zot u1804 + vm
# echo "*** bashrc ***"

# If not running interactively, don't do anything
# If we don't bail if non-interactive, then vagrant share
# mounts following creation (vagrant halt; vagrant up)
# fail.
case $- in
    *i*) ;;
      *) return;;
esac

if [ ! -e /vagrant ]; then
  # delete the following line, and edit EXPECTED_USER
  echo "*** you need to edit EXPECTED_USER, be yourself."
fi

EXPECTED_USER=xyz

if [ "z$UID" != "z`id -u`" ]; then
    export UID=`id -u`
fi
export HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

#set noclobber

if [ -e /usr/bin/keychain ] ; then
    eval $(keychain --eval --quiet)
fi

shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

if [[ -v INSIDE_EMACS ]]; then
	export EDITOR=emacsclient
	export VISUAL=emacsclient
	export CVSPAGER=emacsclient
	export PAGER=cat
fi

if [ "x$PS1" != "x" ]; then	# we're interactive
	who=`id | sed -e "s/uid=[0-9]*(//" -e "s/).*//"`
	if	[ "x$who" == "x$EXPECTED_USER" ] ||
                [ "x$who" == "xvagrant" ]        ||
                [ "x$who" == "xpi" ]                ; then
		PS1="\h (\#): "
	else
		PS1="($who) \h (\#)# "
	fi
fi
if [ "z$EDITOR" = "z" ]; then
   export	EDITOR=vi
   export	VISUAL=vi
fi

. ~/.environment_bash

# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

if [ -f ~/.bash_functions ]; then
    . ~/.bash_functions
fi

if [ -r .bashrc.local ]; then . .bashrc.local; fi
