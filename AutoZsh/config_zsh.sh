#!/bin/bash

sudo apt install zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# Copy all the content of the ./assets to ~/. content
cp -rf ./assets/* ~/
source ~/.zshrc
printf "\e[32mSuccessfully installed ZSH\e[0m\n"

# make a count down to restart this shell
function countdown() {
    for ((i = 3; i >= 1; i--)); do
        printf "\rPress any key within $i seconds to cancel shell restarting (Ctrl+C to exit)..."
        sleep 1
        if read -t 0.1; then
            return
        fi
    done

    gnome-terminal
    kill -9 $PPID
}

countdown