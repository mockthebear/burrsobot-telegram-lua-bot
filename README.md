# Burrsobot ~

## Installation

First send a message to @BotFather on telegram to get a bot token.

Then you will need these dependencies:

> Openresty (https://openresty.org/en/installation.html)
> Redis (https://redis.io/)

### Openresty
```
sudo apt-get install libpcre3-dev libssl-dev perl make build-essential curl
wget -qO - https://openresty.org/package/pubkey.gpg | sudo apt-key add -
sudo apt-get -y install software-properties-common
sudo add-apt-repository -y "deb http://openresty.org/package/ubuntu $(lsb_release -sc) main"
sudo apt-get update
sudo apt-get install openresty
``` 

### Redis
```
sudo apt-get install redis-server
```

## Setting up

First, set up your redis server
```
sudo service redis start
```

Then clone the repository:

```
https://github.com/mockthebear/burrsobot-telegram-lua-bot
cd burrsobot-telegram-lua-bot
```

Edit the config.lua including your telegramid and the bot token. 

## Run the bot

*Its reccomended to run the but inside a screen.*
```
resty burrbot.lua
```

## Aditional modules
Some modules of the bot like the botprotection and the text to speech need some external stuff.

> imagick
> google_speech

## Need help?

https://t.me/burrbotsupport