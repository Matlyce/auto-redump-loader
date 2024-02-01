#!/bin/bash

function enable_all_extensions() {
    installed_extensions=$(gnome-extensions list --quiet | awk '{print $1}')

    # Enable each installed extension
    for ext_uuid in $installed_extensions; do
        gnome-extensions enable "$ext_uuid" >/dev/null 2>&1
        echo "Enabled extension with UUID: $ext_uuid"
    done
}

enable_all_extensions
sudo python3 ./remove_autostart_content.py $HOME
printf "\e[32mSuccessfully enabled all extensions.\e[0m\n"

