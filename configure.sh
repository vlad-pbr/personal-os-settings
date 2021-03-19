#!/bin/bash

# Personal system configuration for Regolith

set -o errexit
USER_TTY=$(tty)

# stages and their commands
declare -A STAGES_MAIN=( \
	["1. System update"]="\
	sudo apt-get update
	sudo apt-get upgrade" \
	\
	["2. Install utils"]="\
	sudo apt-get install curl git python3-pip software-properties-common apt-transport-https gdebi-core wget
	"\
	\
	["3. VSCode"]="\
	wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
	sudo add-apt-repository \"deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main\"
	sudo apt-get install code" \
	\
	["4. Steam"]="\
	sudo add-apt-repository multiverse
	sudo apt-get update
	sudo apt-get install steam"\
	\
	["5. Discord"]="\
	wget -O /tmp/discord.deb \"https://discordapp.com/api/download?platform=linux&format=deb\"
	sudo gdebi /tmp/discord.deb
	rm -f /tmp/discord.deb"\
	\
	["6. Spotify"]="\
	curl -sS https://download.spotify.com/debian/pubkey_0D811D58.gpg | sudo apt-key add -
	sudo add-apt-repository \"deb http://repository.spotify.com stable non-free\"
	sudo apt-get install spotify-client"\
	\
	["7. Various system configurations"]="\
	echo Disabling mouse acceleration...
	gsettings set org.gnome.desktop.peripherals.mouse accel-profile 'flat'
	
	echo Git user settings...
	git config --global user.email 'vlad.pbr@gmail.com'
	git config --global user.name 'Vlad Poberezhny'" \
	\
	["8. Get kiwi"]="\
	sudo python3 -m pip install --upgrade pip
	mkdir -p $HOME/.local/bin
	curl https://raw.githubusercontent.com/vlad-pbr/kiwi/master/kiwi > $HOME/.local/bin/kiwi
	chmod +x $HOME/.local/bin/kiwi
	touch $HOME/.bash_profile
	grep -qxF 'PATH=\"\$HOME/.local/bin:\$PATH\"' $HOME/.bash_profile || echo 'PATH=\"\$HOME/.local/bin:\$PATH\"' >> $HOME/.bash_profile" \
	\
	["9. Regolith i3"]="\
	sudo add-apt-repository -y ppa:kgilmer/speed-ricer
	mkdir -p $HOME/.config/regolith/{i3,compton}"\
	\
	)

declare -A STAGES=( \
	["9. Regolith i3"]="\
        sudo add-apt-repository -y ppa:kgilmer/speed-ricer
	sudo apt-get install polybar
        mkdir -p $HOME/.config/regolith/{i3,compton}
	mkdir -p $HOME/.config/polybar
	curl https://raw.githubusercontent.com/vlad-pbr/personal-os-settings/master/regolith/i3/config > $HOME/.config/regolith/i3/config
	curl https://raw.githubusercontent.com/vlad-pbr/personal-os-settings/master/regolith/Xresources > $HOME/.config/regolith/Xresources
	curl https://raw.githubusercontent.com/vlad-pbr/personal-os-settings/master/regolith/compton/config > $HOME/.config/regolith/compton/config
	curl https://raw.githubusercontent.com/vlad-pbr/personal-os-settings/master/polybar/config > $HOME/.config/polybar/config
	curl https://raw.githubusercontent.com/vlad-pbr/personal-os-settings/master/gtk-3.0/gtk.css > $HOME/.config/gtk-3.0/gtk.css"\
        \
	)

# TODO lock binding
# TODO polybar
# TODO sleep/screen timeouts

# perform commands
printf '%s\0' "${!STAGES[@]}" | sort -z -n | tr '\0' '\n' | while read STAGE
do
	echo -e "\n=== $STAGE ==="
	bash -c "${STAGES[$STAGE]}" < $USER_TTY
done

echo -e "\nA reboot is most likely required"
