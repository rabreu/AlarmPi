AlarmPi
=======

AlarmPi is an alarm script which works along with crond, mpd and tty-clock on a Raspberry Pi board  plugged in a HDTV through HDMI/CEC.

Requirements
---------------------
1. mpd
2. cec-client
3. tty-clock
4. crond

Crond
---------------------

Schedule alarmpi.sh to crontab (as root) to run it whenever you want.

i.e.:
```0 7 * * *	/path/to/alarmpi.sh```

MPD
---------------------

Create a playlist you want to be played when the job run and set the PLAYLIST variable on the alarmpi.sh file to be the same playlist you've created on MPD. Don't forget to set the audio outputs and runtime too.

HDMI/CEC
---------------------

It will make the TV to be turned on/off after the runtime period is over. Note that the there's a commented line on the alarmpi.sh file. Test this line standalone before uncommenting it. There are a lot of people relating problems with turning the TV off and keeping this line uncommented would be convenient, since cec-client will take some seconds to execute this single comment line.

tty-clock
---------------------

The cool clock which will be shown on the screen.
