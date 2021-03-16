#!/bin/bash

# Personal system configuration for Ubuntu with i3

set -o errexit
USER_TTY=$(tty)

# stages and their commands
declare -A STAGES=( \
	["1. Update the system"]="\
	sudo apt-get update
	sudo apt-get upgrade" \
	\
	["2. Install software"]="\
	sudo add-apt-repository multiverse
	sudo apt-get update
	sudo apt-get install curl git python3-pip steam" \
	\
	["3. Various system configurations"]="\
	echo Disabling mouse acceleration...
	gsettings set org.gnome.desktop.peripherals.mouse accel-profile 'flat'
	
	echo Git user settings...
	git config --global user.email 'vlad.pbr@gmail.com'
	git config --global user.name 'Vlad Poberezhny'" \
	\
	["4. Install latest Nvidia driver"]="\
	sudo ubuntu-drivers install
	sudo apt-get install libnvidia-gl-\$(ubuntu-drivers list 2> /dev/null | egrep -o '^nvidia-driver-[0-9]*' | cut -d- -f 3 | sort | tail -n1):i386" \
	\
	["5. Get kiwi"]="\
	sudo python3 -m pip install --upgrade pip
	mkdir -p $HOME/.local/bin
	curl https://raw.githubusercontent.com/vlad-pbr/kiwi/master/kiwi > $HOME/.local/bin/kiwi
	chmod +x $HOME/.local/bin/kiwi
	touch $HOME/.bash_profile
	grep -qxF 'PATH=\"\$HOME/.local/bin:\$PATH\"' $HOME/.bash_profile || echo 'PATH=\"\$HOME/.local/bin:\$PATH\"' >> $HOME/.bash_profile" \
	\
	)

# perform commands
printf '%s\0' "${!STAGES[@]}" | sort -z | tr '\0' '\n' | while read STAGE
do
	# set stage index
	STAGE_INDEX=${STAGE_INDEX:-1}

	# preform command
	echo -e "\n=== $STAGE ==="
	bash -c "${STAGES[$STAGE]}" < $USER_TTY

	# increment stage index
	STAGE_INDEX=$(( $STAGE_INDEX + 1 ))
done

echo -e "\nA reboot is most likely required"
