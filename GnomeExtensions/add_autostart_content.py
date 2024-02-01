import os
import sys

#if not args, return
if len(sys.argv) < 2:
    print("No args given")
    sys.exit()

# get args
home = sys.argv[1]
print("home: " + home)
file_path = home + "/.config/autostart/gnome-terminal.desktop"
print("filepath; " + file_path)

content_to_add = [
    "[Desktop Entry]",
    "Type=Application",
    "Exec=gnome-terminal --command " + home + "/AUTO-REDUMP/enable_gnome_extensions.sh",
    "Hidden=false",
    "NoDisplay=false",
    "X-GNOME-Autostart-enabled=true",
    "Name[en_NG]=Terminal",
    "Name=Terminal",
    "Comment[en_NG]=Start Terminal On Startup",
    "Comment=Start Terminal On Startup"
]

def append_content(file_path, content_to_append, home):
    with open(file_path, 'a') as file:
        # add a line break
        file.write("\n")
        for line in content_to_append:
            file.write(line + "\n")

append_content(file_path, content_to_add, home)