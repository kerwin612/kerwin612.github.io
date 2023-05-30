# install home-assistant mosquitto-broker and node-red on android

This is `Home Assistant`, `MQTT` broker - `Mosquitto`, `Node-RED` installation. **Requires Android 5.0 and up.** Works without root. Install `Termux` and `Termux:API` from `Play Store` or `F-droid`. Install Hacker’s keyboard. This works for me, why you have a problem with this i don’t have a clue. ￼:\)

Start Termux

## Update packages

```text
packages update
packages upgrade
packages list-installed
packages install python python-dev coreutils nano ndk-stl clang mosquitto nodejs openssh termux-api
```

## Install HA, Mosquitto, Node-RED

```text
npm i -g --unsafe-perm node-red
npm i -g --unsafe-perm pm2
pip install homeassistant
```

## Start:

```text
node-red
#Stop node-red with ctrl +c or volume down + c

mosquitto
#Stop Mosquitto with ctrl +c or volume down + c

hass
#Wait for a installation to complete then stop HA with ctrl +c or volume down + c
```

## Start at login

```text
pm2 start mosquitto -- -v -c /data/data/com.termux/files/usr/etc/mosquitto/mosquitto.conf
pm2 start node-red --node-args="--max-old-space-size=128" -- -v
pm2 start hass --interpreter=python -- --config /data/data/com.termux/files/home/.homeassistant
pm2 save

pm2 show hass
pm2 logs hass
```

## If you make mistake in pm2 configuration…

```text
pm2 stop {hass or node-red...}
pm2 delete {hass or node-red...}

nano ~/.bashrc
pm2 resurrect
```

Enjoy!

ref: [https://community.home-assistant.io/t/install-home-assistant-mosquitto-broker-and-node-red-on-android/14350](https://community.home-assistant.io/t/install-home-assistant-mosquitto-broker-and-node-red-on-android/14350)
