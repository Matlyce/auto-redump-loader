import os
import sys

#if not args, return
if len(sys.argv) < 2:
    print("No args given")
    sys.exit()

# get args
home = sys.argv[1]
print("home: " + home)

DEBUG = False

# remove content
def remove_desktop_entry(file_path):
    content_to_remove = [
        "[Desktop Entry]",
        "Type=Application",
        "Exec=gnome-terminal --command /home/mathis/AUTO-REDUMP/enable_gnome_extensions.sh",
        "Hidden=false",
        "NoDisplay=false",
        "X-GNOME-Autostart-enabled=true",
        "Name[en_NG]=Terminal",
        "Name=Terminal",
        "Comment[en_NG]=Start Terminal On Startup",
        "Comment=Start Terminal On Startup"
    ]

    try:
        with open(file_path, 'r') as file:
            lines = file.readlines()

        with open(file_path, 'w') as file:
            index = 0
            while index < len(lines):
                if DEBUG: print ("Line: " + lines[index])
                offset = 0
                while offset < len(content_to_remove):
                    if lines[index + offset].strip() in content_to_remove[offset]:
                        if DEBUG: print ("  INNER line: " + lines[index + offset])
                        offset += 1
                    else:
                        if DEBUG: print (" NOT EQUAL: \n" + lines[index + offset] + "\n!=\n" + content_to_remove[offset])
                        break
                if offset == len(content_to_remove):
                    index += offset
                    if DEBUG: print ("REMOVED (len: " + str(offset) + ")")
                else:
                    if DEBUG: print ("ADDED")
                    file.write(lines[index])
                    index += 1

        print("Content removed successfully.")
    except FileNotFoundError:
        print(f"File not found: {file_path}")
    except Exception as e:
        print(f"An error occurred: {e}")

# retrieve home : USER_HOME=$(getent passwd $SUDO_USER | cut -d: -f6)
file_path = home + "/.config/autostart/gnome-terminal.desktop"
print("filepath; " + file_path)
remove_desktop_entry(file_path)
