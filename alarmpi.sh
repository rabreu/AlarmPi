#!/bin/bash
#
# The MIT License (MIT)
#
# Copyright (c) 2014 Renata Abreu
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

TERM=xterm
export TERM

PLAYLIST='alarmpi'				# Set your playlist for waking up
ENABLE_OUTPUTS=(2)                              # Enable output by index # i.e. ENABLE_OUTPUTS=(2 3). Run '$ mpc outputs' to check it out.
TIME=90						# Alarm runtime period (in minutes)
REPEAT=on					# Set repeat (on/off)
TTYCLOCK_FLAGS='-S -c -t -C 1 -d 3'		# Set tty-clock flags for customizing

# Prepare the screen for tty-clock
echo "on 0" | cec-client -s > /dev/null
echo -ne '\033[9;0]' > /dev/tty1
setterm -blank 0 -powerdown 0 > /dev/tty1

# Take a snapshot of the current outputs and repeat status
SNAPSHOT_OUTPUTS=$(mpc outputs | awk '{ print $2 " " $(NF) }')
SNAPSHOT_REPEAT=$(mpc | awk 'END { print $4 }')

# Prepare the current queue for loading the alarmpi playlist and a previous restoration
mpc save tmp > /dev/null
mpc clear > /dev/null
mpc load $PLAYLIST > /dev/null

# Enable and disable the selected outputs defined at ENABLE_OUTPUTS and DISABLE_OUTPUTS variables
N_OUTPUTS=`mpc outputs | awk 'END { print $2 }'`
for (( output = 1 ;  output <= $N_OUTPUTS ; output = $output+1 ))
do
	mpc disable $output > /dev/null
done

for output in ${ENABLE_OUTPUTS[@]}
do
        mpc enable $output  > /dev/null
done

# Enable repeat
mpc repeat $REPEAT > /dev/null

# Core
mpc play > /dev/null
tty-clock $TTYCLOCK_FLAGS > /dev/tty1 &
sleep $[$TIME*60]
TTY_CLOCK_PID=$(pidof tty-clock)
kill -9 $TTY_CLOCK_PID > /dev/null
mpc stop > /dev/null
clear > /dev/tty1
# echo "standby 0" | cec-client -s > /dev/null  # Turns off the TV. See if this line works isolatedly before to uncomment.

# Restore the previous audio outputs, queue and repeat status like it has never been touched
arr=($(echo $SNAPSHOT_OUTPUTS | tr " " "\n"))
for (( i = 0 ; i < ${#arr[@]} ; i=$i+2 ))
do
        mpc ${arr[$i+1]%?} ${arr[$i]} > /dev/null
done

case "$SNAPSHOT_REPEAT" in
on)	mpc repeat on > /dev/null
	;;
off)	mpc repeat off > /dev/null
	;;
esac

mpc clear > /dev/null
mpc load tmp > /dev/null
mpc rm tmp > /dev/null
