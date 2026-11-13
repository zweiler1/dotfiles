alias ls='eza -al --color=always --group-directories-first --icons=always'
alias grep='grep --color=auto'
alias grub-update='sudo grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=arch --removable && sudo grub-mkconfig -o /boot/grub/grub.cfg'
alias restart-pipewire='systemctl restart --user pipewire wireplumber.service pipewire-pulse.service'
alias kvm-start='sudo virsh net-start default && sudo modprobe tun && sudo modprobe vhost_net'
alias mount-nfs='sudo mount -t nfs zweilerserver.ddns.net:/srv /NFS'
alias ij='env LC_ALL="de_AT.UTF-8" intellij-idea-ultimate-edition'

alias xterm='xterm -fg white -bg black'
alias clear='printf "\033[2J\033[3J\033[1;1H"'
alias celar='clear'

alias nix-clean='nix-collect-garbage -d'
alias use_dgpu="DRI_PRIME=pci-0000_03_00_0"
alias use_igpu="DRI_PRIME=pci-0000_77_00_0"

export HISTFILESIZE=10000
export HISTSIZE=$HISTFILESIZE
GPG_TTY="$(tty)"
export GPG_TTY

export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
export PATH="$HOME/env/flint/flintc/zig-out/bin:$PATH"
export PATH="$HOME/env/flint/clape:$PATH"

# $1 - 0=off, 1=on
toggleZweilerRepo() {
	case "$1" in
		0) 
			sudo sed -i 's/\[zweileros\]/#\[zweileros\]/' /etc/pacman.conf
			sudo sed -i 's/Server = https:\/\/zweilerserver.ddns.net/#Server = https:\/\/zweilerserver.ddns.net/' /etc/pacman.conf
			;;
		1) 
			sudo sed -i 's/#\[zweileros\]/\[zweileros\]/' /etc/pacman.conf
			sudo sed -i 's/#Server = https:\/\/zweilerserver.ddns.net/Server = https:\/\/zweilerserver.ddns.net/' /etc/pacman.conf
			;;
		*) 
			echo "False argument given to toggle repo function!" >&2
			;;
	esac
}

# Execute without Zweileros Repo
# $@ - The command to execute
NOZ() {
	toggleZweilerRepo 0
	"$@"
	toggleZweilerRepo 1
}

#remve-spaces from directory	= find . -type d -name "* *" -print0 -exec bash -c 'mv "$0" "${0// /_}"' {} \;
#remve-spaces from file 		= find . -type f -name "* *" -print0 -exec bash -c 'mv "$0" "${0// /_}"' {} \;

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

export COLOR_NC='\e[0m' # No Color
export COLOR_BLACK='\e[0;30m'
export COLOR_GRAY='\e[1;30m'
export COLOR_RED='\e[0;31m'
export COLOR_LIGHT_RED='\e[1;31m'
export COLOR_GREEN='\e[0;32m'
export COLOR_LIGHT_GREEN='\e[1;32m'
export COLOR_BROWN='\e[0;33m'
export COLOR_YELLOW='\e[1;33m'
export COLOR_BLUE='\e[0;34m'
export COLOR_LIGHT_BLUE='\e[1;34m'
export COLOR_PURPLE='\e[0;35m'
export COLOR_LIGHT_PURPLE='\e[1;35m'
export COLOR_CYAN='\e[0;36m'
export COLOR_LIGHT_CYAN='\e[1;36m'
export COLOR_LIGHT_GRAY='\e[0;37m'
export COLOR_WHITE='\e[1;37m'

export COLOR_GOLD='\e[38;2;225;185;100m' # Gold color, the three latter parameter are the rgb values
export COLOR_QUEEN_BLUE='\e[38;2;67;105;141m'
export COLOR_DARK_SPRING_GREEN='\e[38;2;14;103;73m'

export COLOR_USER='\e[38;2;152;175;142m'
export COLOR_PATH='\e[38;2;131;156;126m'
export COLOR_GIT='\e[38;2;115;142;115m'

export PATH=$PATH:/home/zweiler1/.local/bin
export PATH=$PATH:/home/zweiler1/.cargo/bin
export ENV_PATH="/home/zweiler1/env"

UC=$COLOR_USER					# user's color
US="$"						# user's char
[ $UID -eq "0" ] && UC=$COLOR_RED		# root's color
[ $UID -eq "0" ] && US="#"			# root's char

bash_prompt_command() {
	# How many characters of the $PWD should be kept
	local pwdmaxlen=50

	# Indicate that there has been dir truncation
	local trunc_symbol=".."

	# Store local dir
	local dir=${PWD##*/}

	# Which length to use
	pwdmaxlen=$(( ( pwdmaxlen < ${#dir} ) ? ${#dir} : pwdmaxlen ))

	if [ "$DEV_ENVIRONMENT" != "" ]; then
		US="×"
	fi
	NEW_PWD=${PWD/#$HOME/\~}

	local pwdoffset=$(( ${#NEW_PWD} - pwdmaxlen ))

	# Generate name
	if [ ${pwdoffset} -gt "0" ]; then
		NEW_PWD=${NEW_PWD:$pwdoffset:$pwdmaxlen}
		NEW_PWD=${trunc_symbol}/${NEW_PWD#*/}
	fi
	PS1="$TITLEBAR\[${UC}\]\u@\h$(get_dev_env) \[${COLOR_PATH}\]${NEW_PWD} \[${COLOR_GIT}\]$(parse_git_branch)\[${UC}\]${US}\[${COLOR_NC}\] "
}

case $TERM in
	xterm*|rxvt*)
		TITLEBAR="\[\033]0;\u:${NEW_PWD}\007\]"
		;;
	*)
		TITLEBAR=""
		;;
esac

parse_git_branch() {
	gitbranch=$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/')
	[ -n "$gitbranch" ] && gitbranch="$gitbranch "
	echo "$gitbranch"
}

get_dev_env() {
	if [ "$DEV_ENVIRONMENT" != "" ]; then
		echo ":$DEV_ENVIRONMENT"
	fi
}

PROMPT_COMMAND=bash_prompt_command

fastfetch
