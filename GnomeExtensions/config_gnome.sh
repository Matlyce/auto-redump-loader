#!/bin/bash

# Vars
dependencies=(wget curl jq gnome-shell)
deps_install_apt="sudo apt install -y wget curl jq"
deps_install_dnf="sudo dnf install -y wget curl jq"
EXTENSIONS_TO_INSTALL=()

# Message colors.
error_text=$(tput setaf 1)
normal_text=$(tput sgr0)

# This function checks if binaries/commands are available in the PATH.
function CheckDependencies() {
    for name in "${dependencies[@]}"; do
        command -v "$name" >/dev/null 2>&1 || {
            echo -en "${error_text}\n[Error] Command not found: \"$name\"${normal_text}"
            exit 1
        }
    done
}

# Install dependencies based on the package manager.
function InstallDependencies() {
    if command -v apt &>/dev/null; then
        sudo apt update
        sudo apt install -y "${dependencies[@]}"
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y "${dependencies[@]}"
    else
        echo -e "${error_text}Error: Neither apt nor dnf package manager found. Please install dependencies manually.${normal_text}"
        exit 1
    fi
}

# Check if the current (active) desktop instance is GNOME.
function IsEnvGNOME() {
    [[ "$XDG_CURRENT_DESKTOP" == *"gnome"* || "$XDG_CURRENT_DESKTOP" == *"GNOME"* || "$XDG_DATA_DIRS" == *"gnome"* || "$XDG_DATA_DIRS" == *"GNOME"* ]]
}

# Parse extension links from the file.
function ParseExtensionLinks() {
    while IFS= read -r url || [ -n "$url" ]; do
        ext_id=$(echo "$url" | grep -oP '(\d+)' | head -n 1)
        [[ -n "$ext_id" ]] && EXTENSIONS_TO_INSTALL+=("$ext_id")
        printf "Found extension: %s\n" "$ext_id"
    done < "links.txt"

    printf "Number of extensions to install: %s\n" "${#EXTENSIONS_TO_INSTALL[@]}"
}

# Uninstall all currently installed extensions.
function UninstallExtensions() {
    gnome-extensions list --enabled --quiet | awk '{print $1}' | xargs -I {} gnome-extensions disable {}
    gnome-extensions list --quiet | awk '{print $1}' | xargs -I {} gnome-extensions uninstall {}
}

# Install and enable extensions.
function InstallExtensions() {
    for ext_id in "${EXTENSIONS_TO_INSTALL[@]}"; do
        echo ""
        request_url="https://extensions.gnome.org/extension-info/?pk=$ext_id&shell_version=$(gnome-shell --version | cut -d ' ' -f 3 | cut -d '.' -f 1,2)"
        printf "Url: %s\n" "$request_url"
        http_response=$(curl -s -o /dev/null -I -w "%{http_code}" "$request_url")

        if [ "$http_response" -eq 200 ]; then

            ext_info="$(curl -s "$request_url")"
            # extension_name="$(echo "$ext_info" | jq -r '.name')"
            direct_dload_url="$(echo "$ext_info" | jq -r '.download_url')"
            ext_uuid="$(echo "$ext_info" | jq -r '.uuid')"
            # ext_version="$(echo "$ext_info" | jq -r '.version')"
            # ext_homepage="$(echo "$ext_info" | jq -r '.link')"
            # ext_description="$(echo "$ext_info" | jq -r '.description')"
            download_url="https://extensions.gnome.org"$direct_dload_url

            printf "Extension to install: %s\n" "$ext_uuid"
            filename="$(basename "$download_url")"
            wget -q "$download_url"

            # Check if the extension is already installed
            echo "Installing extension $filename..."
            gnome-extensions install "$filename" -f
            # gnome-extensions enable "$ext_uuid"
            printf "\e[32m%s, Installation success\e[0m\n" "$ext_uuid"

            rm "$filename"
        else
            printf "\n${error_text}Error: No extension exists matching the ID: $ext_id and GNOME Shell version $GNOME_SHELL_VERSION (Skipping this).\n"
        fi
    done
}


# Countdown for user interaction.
function Countdown() {
    for ((i = 5; i >= 1; i--)); do
        printf "\rPress any key within $i seconds to cancel gnome restarting (Ctrl+C to exit)..."
        sleep 1
        if read -t 0.1; then
            return
        fi
    done

    sudo python3 ./add_autostart_content.py $HOME
    # ./enable_gnome_extensions.sh &
    killall -SIGQUIT gnome-shell
}

# Main execution
CheckDependencies
InstallDependencies
IsEnvGNOME || {
    echo -e "${error_text}Error: Not in a GNOME environment. Please login to a GNOME desktop to use this script.${normal_text}"
    exit 1
}

UninstallExtensions
ParseExtensionLinks
InstallExtensions

# Countdown before executing killall
Countdown
