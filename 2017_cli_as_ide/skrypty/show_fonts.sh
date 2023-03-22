#!/bin/bash
for i in $(ls /usr/share/figlet | cut -d . -f 1); do
    echo $i; toilet --gay -f $i -w 200 Terminal wystarczy;
done
