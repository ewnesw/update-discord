#!/bin/bash

set -e 
set -o pipefail

if [ -z "$1" ]; then
	echo "need discord update directory"
	exit 1
fi

update_path="$1"

if [ ! -d "$update_path" ]; then
	echo "missing  ~/.discord-updates, do you want to create it ? [y/N]"
	read answer
	echo "$answer"
	if [ ! "$answer" == "y" ]; then
		echo "aborting"
		exit 1
	fi
	mkdir "$update_path"
fi

for file in "$update_path"/*; do
	echo "$file"
	if [[ $file =~ (discord\-([0-9]+\.){3}deb)$ ]]; then
		last_local_update="${BASH_REMATCH[0]}"
		echo "$last_local_update"
		break
	else
		continue
	fi
done

update_url=$(curl -Ls -w '%{url_effective}' 'https://discord.com/api/download?platform=linux&format=deb' -o /dev/null | tr -d '\0')

if [ -z "$update_url" ]; then
	echo "error during curl"
	exit 1
fi

echo "$update_url"
cd "$update_path"

if [ -z "$last_local_update" ]; then
	curl -O "$update_url"
else 
	if [[ $update_url =~ (discord\-([0-9]+\.){3}deb)$ ]]; then
		last_remote_update="${BASH_REMATCH[0]}"
		echo "$last_remote_update"
		if [ $last_local_update == $last_remote_update ]; then
			echo "discord already latest version"
			exit 0
		else
			curl -O "$update_url"
			rm $last_local_update
		fi
	else
		echo "uhoh"
		exit 1
	fi
fi

sudo apt-get install "${update_path}/${last_remote_update}"



