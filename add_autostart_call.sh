function write_gnome_terminal_desktop_file() {
    desktop_file="$HOME/.config/autostart/gnome-terminal.desktop"
    this_path="$(pwd)"

    # Check if the directory exists, create if not
    mkdir -p "$(dirname "$desktop_file")"

    # Content of the desktop file
    desktop_content="[Desktop Entry]
Type=Application
Exec=gnome-terminal --command $this_path/enable_gnome_extensions.sh
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name[en_NG]=Terminal
Name=Terminal
Comment[en_NG]=Start Terminal On Startup
Comment=Start Terminal On Startup
"

    # Check if the file already exists
    if [ -f "$desktop_file" ]; then
        # Append content to the existing file
        echo -e "\n$desktop_content" >> "$desktop_file"
        echo "Content appended to $desktop_file"
    else
        # Create a new file with the content
        echo -e "$desktop_content" > "$desktop_file"
        echo "File $desktop_file created with content"
    fi
}

write_gnome_terminal_desktop_file