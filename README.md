# Burrsobot ~

## Need help?

https://t.me/+fXS45nFRKRE4OWEx


## How it works

The burrbot is a system in lua running on a openresty. Its somehwat modular, you can create a module and insert in the module folder.
This is a basic module:
```
local module = {
	--The lower the number, the more soon is loaded the module
	priority = DEFAULT_PRIORITY,
}

--runs when the load is finished
function module.load()

end

--runs when eveything is ready
function module.ready()

end

--Runs at the begin of the frame
function module.frame()

end

--Runs some times if you need to save some settings
function module.save()

end

--Run once to load the commands
function module.loadCommands()
	addCommand( {"bolo", "cake"}		, MODE_FREE,  getModulePath().."/cake.lua", 2 , "example-desc" )
end

--Runs once to load translations
function module.loadTranslation()
	g_locale[LANG_US]["example-desc"] = "Displaya cake"
	g_locale[LANG_BR]["example-desc"] = "Mostra um bolo"
end

return module
```

Some callbacks can be inserted in the module to control every aspect of the bot:
```
onEditedMessageReceive
onDocumentReceive
onLeftChatParticipant
onNewChatParticipant
onPhotoReceive
onNewChatPhoto
onNewChatTitle
onInlineQueryReceive
onCallbackQueryReceive
onSupergroupChatCreated
onGroupChatCreated
onChannelChatCreated
onMigrateToChatId
onMigrateFromChatId
onUpdateChatMember
onVideoReceive
onVoiceReceive
onContactReceive
onLocationReceive
onTextReceive
onStickerReceive
onMinute
onHour
onDay
ready
```

## Installation

First send a message to @BotFather on telegram to get a bot token.

Then you will need these dependencies:

>> Openresty (https://openresty.org/en/installation.html)

>> Redis (https://redis.io/)

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

Then clone the repository and create a media and cache dir right bellow:

```
https://github.com/mockthebear/burrsobot-telegram-lua-bot
mkdir media
mkdir cache
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

