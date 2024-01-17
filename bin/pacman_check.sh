#!/bin/sh
# Updates tmp file with number of packages available to update

pacman -Sy
pacman -Qu | wc -l > /tmp/pacman_updates.txt
