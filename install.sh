#! /usr/bin/expect -f

spawn anki -b /data
expect "*2\) Choose a version*"
send -- "2\r"
expect "Enter the version you want to install:"
send -- "${ANKI_VERSION}\r"
expect "Press enter to start Anki."
send -- "\r"
expect eof
