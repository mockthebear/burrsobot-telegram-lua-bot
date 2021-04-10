g_locale = {}

function reloadLocalization()
	g_locale = {}
	StartLocalization()
	loadAuxiliarLibsLocalization()
end

function getLanguageName(id)
	return g_locale.langs[id] or "LANG_??"..id
end


function StartLocalization()
	print("[Locale] Loading localization")

	g_locale.langs = {}

	local langs = {["BR"] = {id=1,name="pt-br"}, ["US"] = {id=2,name="en"} }
	local last = 0
	for lang , data in pairs(langs) do 
		last = math.max(last, data.id )

		g_locale[data.id] = {
			__langname=data.name
		}
		g_locale.langs[data.id] = data.name 
		
		_G["LANG_"..lang] = data.id
	end

	_G["LANG_LAST"] = last

	g_lang = LANG_BR
	print("[Locale] Defaul language is "..g_locale[g_lang].__langname..":"..getLanguageName(g_lang))
	print("[Locale] Loading localized stuff.")
	loadDefaultLanguage()

	
end	

function detectLanguage(msg)
	if msg.from then 
		if msg.from.language_code then 
			for i,b in pairs(g_locale.langs) do 
				if msg.from.language_code == b then 
					return i
				end
			end
		end
	end
	return LANG_BR
end

function loadLanguage(chatid)
	g_lang = getUserLang({chat={id=chatid}, from={id=chatid}})
end 

function getUserLang(msg)
	if chats[msg.chat.id] then 
		return chats[msg.chat.id].lang
	end
	return users[msg.from.id].lang
end

function tr(word, ...)
    word = word or "" 
    local ret = g_locale[g_lang][word] or word
    local arg = {...}
    if arg[1] then 
        function f(...)
            ret = ret:format(...)
        end
        local ok,err = pcall(f,...)
        if not ok and err then 
            ret = ret .. "Error translating: "..err
        end
    end
    return ret
end



function loadDefaultLanguage()



g_locale[LANG_BR] = {
	["default-chat-only"] = "Desculpe, ese comando é apenas para chats.",


	["minute"] = "minuto",
	["minutes"] = "minutos",

	["default-command-chatdmin"] = "Somente admins do chat podem usar esse comando.\n<i>Essa mensagem será apagada em 15 segundos</i>.",
	["default-command-botadmin"] = "Somente admins do bot podem usar esse comando.\n<i>Essa mensagem será apagada em 15 segundos</i>.",
	["default-command-chatonly"] = "Esse comando é exclusivo para ser usado em chats.\n<i>Essa mensagem será apagada em 15 segundos</i>.",
	["default-command-disabled"] = "Esse comando está deshabilitado nesse chat.\n<i>Essa mensagem será apagada em 15 segundos</i>.",
	["default-command-nsfw"] = "Esse comando é classificado como NSFW e não pode ser enviado nesse chat. Mude isso com '/sfw no'\n<i>Essa mensagem será apagada em 15 segundos</i>.",

	["default-command-coldown"] = "Tá no coldown. Sem spammar plz :c\nPrecisa de ajuda com algum comando? Use <code>/help (nome do comando)</code>\nEsse comando tem <b>%s</b> segundos de coldown. Espere por mais <b>%s</b> segundos para usar de novo.",
	["default-start-chat"] = "Esse comando foi feito para ser usado no private comigo. Mas se o que estiver procurando é a lista de comandos use /commands aqui ou vá para o pvt.",

}
g_locale[LANG_US] = {
	["default-command-coldown"] = "Its on coldown. No spam plz :c\nIf you need help with some commands use <code>/help (command name)</code>\nThis command has <b>%s</b> seconds of coldown. Wait for more <b>%s</b> seconds and try again.",

	["default-command-chatdmin"] = "Only chat admins can use this command.\n<i>Message will be deleted in 15 seconds</i>.",
	["default-command-botadmin"] = "Only bot admins can use this command.\n<i>Message will be deleted in 15 seconds</i>.",
	["default-command-chatonly"] = "This command can only be executed in a chat.\n<i>Message will be deleted in 15 seconds</i>.",
	["default-command-disabled"] = "This command is disable on this chat.\n<i>Message will be deleted in 15 seconds</i>.",
	["default-command-nsfw"] = "This command is classified as NSFW and cant be send here. Use '/sfw no' to enable\n<i>Message will be deleted in 15 seconds</i>.",

	["default-chat-only"] = "Sorry, this command is for chats only.",
	["default-start-chat"] = "This command was meant to be used on private with me. But if you are looking for the commands list, just use /commands here or go to pvt.",


	["Esses são seus pais: "] = "Those are your parents: ",
	["Removido mãe/pai @"] = "Removed parent @",
	["Adicionado mãe/pai @"] = "Added parent @",
	["Use esse comando assim /daddy @username, para essa pessoa virar seu daddy/mommy. Para tirar é só usar de novo no nome da pessoa."] = "Use this command like this: /daddy @someone to this person become your daddy/mommy. Use twice to remove",
	["Ei @%s, você pode sair do castigo."] = "Finally @%s, you can leave the timeout.",
	["@%s colocou @%s de castigo por 5 minutos! Mas que bebê malcriado!"] = "@%s just set @%s for a 5 minute timeout! Bad baby!",
	["Desculpe, mas castigo é só para bebês e @%s não é. Talvez usar /regression nele? :D"] = "Sorry but timeouts are only for babies, and @%s is an adult. Maybe try using first /regression on him?",
	["Você está de castigo! Não pode usar isso."] = "You are in a timeout, you cant use this!",
	["vem cuidar do seu filho."] = "come take care of your son", 
	["vem que o filho é teu"] = "come, its your child!",
	["olha seu filho aqui"] = "watch your child",
	["vem cuidar dele."] = "control your kiddo",
	["olha aqui ó."] = "come and take your kid",
	["Oi"] = "Psst",
	["Ei"] = "Excuse-me",
	["Finalmente @%s voltou a ter idade normal!"]= "Finally @%s become an adult again!",
	["Quem é %s?"] = "Who is %s?",
	["Desculpe, mas @%s ainda é um bebê. 🧷"] = "Sorry but @%s is still a baby. 🧷",
	[" Mas pera... ainda tá usando fralda?!"] = " But wait... still wearing diapers?!",
	[" O efeito passou!"] = " The effect is gone!",
	[" Nossa, a fralda ficou do tamanho adulto agora"] = "Woah, the diaper got big aswell!",
	[" É sempre engraçado ver adulto de chupeta não é?"] = "Look, he is still wearing a pacifier!",
	["Desculpa, mas bebê não usar isso. Cadê seu pai ou sua mãe?"] = "Sorry, babies cant use this kind of stuff. Where is your mommy/daddy?",
	["<i>Usando arma de regressão em</i> <b>@%s</b>"] = "<i>Using the regression ray in to</i> <b>@%s</b>",
	["Agora @%s é um bebê por 15 minutos <i>(e provavelmente está com fome e chorando).</i>"] = "@%s  is now a baby for 15 minutes <i>(and is probally hungry or crying by now).</i>",
	["Usuário %s foi desbanido e desmarcado como bot. Ele está permitido a entrar de novo."] = "User %s was unbanned and unmarked as a bot. He is allowed to join again.",
	["Desculpe, você parece que foi banido por falhar no procedimento de checar se é um bot em algum chat. Então não tem permissão para receber os links. Se acha que foi engano, fale com @mockthebear"] = "Sorry, you failed to prove you are not a bot in some chat. So you are not allowed to get any links from me. Ifyou think this was a mistake, message @mockthebear about that",
	["Use assim:\n/logger on|off  - para ligar desligar logging\n/logger get  - para enviar o arquivo de log no chat\n/logger erase - para apagar arquivo de log\n/logger pget - para enviar o arquivo via private"] = 	"Use like that:\n/logger on|off - to toggle chat logging\n/logger get - bot will send the log file\n/logger erase - bot will erase any logs.\n/logget pget - bot will send the file in the private chat",
	["Agora todas as mensagens serão salvadas."] = "Now every message is logged.",
	["Nem uma mensagem será salva mais."] = "No message will be logged now",
	["Log excluido."] = "Log deleted",
	["Enviando log"] = "Sending log",
	["Lista limpa!"] = "Ban list cleared!",
	
	
	["Bane um sticker. Use /banpack pack para banir o pack inteiro.\n/banpack msg \"nao pode\". para uma mensagem ao deletar"] = "Bans a sticker. Use /banpack pack to ban the whole pack. and /banpack msg \"Not allowed!\" to set a custom message",
	["não pode, o chat é sfw. só admins usando /sfw pra mudar"] = "Cant use this now. This chat is marked as SFW. Only admins can use /sfw to change",
	["Confirmado como não bot pelo admin!"] = "Confirmed by the dmin its not a bot!",
	["Não é um bot. Seja bem viado."] = "Not a bot! Be welcome!",
	["Desculpe você não é admin. Se você está tentando provar que não é um bot, use esse outro botão."] = "Sorry you are not an admin. If you are trying to prove you not a bot, press the OTHER button.",
	["ordens do adm"] = "orders from the admins",
	["(Admin only) Aprovar"] = "(Admin only) Approve user",
	["primeira mensagem no chat ser uma foto"] = "first message is a photo",
	["primeira mensagem no chat conter link"] = "first message contains a link",
	["primeira mensagem no chat ser um arquivo"] = "first message is a file",
	["@<user> seja bem viado :3"] = "@<user> be welcome!",
	[" não é um bot!\n\n"] = " its not a bot!\n\n",
	["Modo no direct media ligado, você tem que esperar para enviar midia."] ="No direct media mode is active. You will have to wait to send medias.",



	["entre"] = "between",

	["Com certeza"] = "Surely",
	["Nada menos que"] = "Nothing less than",
	["Nada menos nada mais que"] = "Nothing more and nothing less than",
	["Por volta de"] = "Around",
	["Acho que"] = "I think is",
	["Talvez uns"] = "Maybe around",

	["qual"] = "how much",
	["porcenta"] = "percent",
	["numero"] = "number",
	["tamanho"] = "size",
	["quanto"] = "how many",
	["quanto2"] = "how many",
	["quanto3"] = "how much",
	["Regras no pvt agora está: %s"] = "Rules to be show on privare are now %s",

	['Shippando o casal *@%s* (%s) e *@%s* (%s)!\nO nome do casal é: *%s%s*'] = 'Shipping the couple *@%s* (%s) and *@%s* (%s)!\nThe couple name now is: *%s%s*',

	["Manter esse bot custa dinheiro, e eu to tirando do meu bolso :D\nGostou do bot? Ele te fez rir? Ou te ajudou alguma vez?\nQuer ajudar ele a continuar melhorando? Doa ae <3"] = "Keeping this bot up cost money and i am doing it! Liked the bot? Did it made a laught to you or something? You can help me keep working on it and making it better!",
	["Ativada"] = "Activated",
	["Desativada"] = "Deactivated",
	["Burrbot faz muito spam, queria menos"] = "Burrbot is too spammy, i want less",
 	["Proteção contra bots em chats"] = "Protection againts spam chat bots",
 
	["não é um bot!\n\n"] = "its not a bot!\n\n",

	["Não sou um bot"] = "Im not a bot",
	["Sim, o bot tem muitas funções, as vezes algumas pessoas abusam... Mas todas as features do bot podem ser desligadas.\n*Desligar/Ligar um unico comando: /disable (comando)\n*Desligar todos os comandos: /disableall\n*Desligar quais quer interação de texto com bot, como perguntas: /nofun\n\nUsando /disableall e /nofun as unicas funções automaticas que vao rodar são as mensagens de boas vindas e as proteções contra bot. (Comandos de chat admin não podem ser desligados)\nÉ possivel usar /disableall e depois usar /enable em um comando util, como o /rules, isso vai rehabilitar o comando /rules, mas manter todos bloqueados."] = "Yeah i know, i have so many functions, sometimes peopple abuse and make spam... But every feature can be disabled in a individual chat.\n*Disable/Enable a single command: /disable (command)\n*Disable all the commands: /disableall\n*Disable any interaction with text with the bot: /nofun\n\nUsing /disableall and /nofun the only function that will remain automatic will be the welcome message and the bot protection ones. (Commands of chat admin cannot be turn of)\nIs possible to use /disableall and laters use /enable in a command.",


	["Olá %s. Antes de tudo, prove que você não é um bot. Você tem 2 minutos se não será kickado."] = "Hello %s. First you have to prove you are not a bot. You have two minutes.",
	["Obrigado, você se confirmou como não bot, e suas restrições foram removidas. Aproveite e de uma olhada nas regras :D"] = "Thanks, you are not a bot! Now take a look at the rules.",
	["Agora a bot protection está: *%s*"] = "Now the bot protection is *%s*",
	["Força a verificação de bot em um usuario."] = "Force the bot check in a user.",
	["Habilita/Deshabilita o modo de proteção de bots. Nesse modo o bot vai limitar novos usuarios suspeitos até que eles provem que não são bots."] = "Enable/Disable bot protection mode. In this mode the bot will limit any suspect new user for two minutes to check if they are bots.",

	["Adicionado aniversario do @%s para o dia %s. Notificação ocorrerá as 00:01 da manhã.\nHorario real: %s. Use /time para ver horario usado pelo bot."] = "Added birthday to @%s to the day %s. Notification will happen at 00:01 in the morning.\nTime now: %s.\nUse /time to see the timezone used by the bot.",
	["Quando um user novo entrar:\n- Se ele estiver sem username\n- Sem foto de perfil\n- Na blacklist\n-Sua primeira mensagem contem bitcoin/ethereum\nSe alguma dessas requisções se aplicar, o bot vai restringir a pessoa de postar qual quer coisa e ela terá 2 minutos para provar que não é um bot.\nQuando ele apertar o bloqueio sai e ele não é kickado.\n\nPara ligar isso, coloque o bot como admin ou com permissão de kickar e de restringir e deletar mensagens, use o comando /botprotection e pronto!\nTambém é possivel fazer com que todos os usuarios passem pela checagem de bot usando /botprotection enforce"] =  "When a new user joins the chat:\n-If he has no username\n- If no profile picture\n-if he is in a blacklist\n-If contains a bitcoin/ethereum mention\nIf any of those apply, the bot will restrict the user until it could prove its not a bot (pressing a button).\nOnce proved the restrictions will be lift and he will be free.\n\nTo do it, you will have to give permissions to the bot as: kick users, restrict users and delete others messages, then use the command /botprotection and ready!\nAlso its possible to force every new member to check if its a bot using /botprotection enforce",
	["Eu tenho proteçao anti raiders!\nPelo menos uma que interfere o minimo possivel no chat.\n\nEla funciona checando se a pessoa que acabou de entrar, está enviando mensagens em excesso, muitas midias ao mesmo tempo de uma vez ou usando palavras nazistas ou insultos.\nSe identificado como raider, o bot bane na hora e adiciona em um banco de dados o id ta pessoa.\n\nPara ligar, use /noraid e mê de permissão de kickar e restringir usuarios"]	= "I have a anti raiding protection!\nAt least, one that interfere the less possible in the chat.\n\nIt works this way: If the person who just joined is sending too much messages, lots of midia, racial slurs and stuff. It will be marked as a raider.\n\nAs a raider, it will be banned instant and added to a DB (its user id). Also notified in a channel @burrbanbot\n\nNote: This protections are only active in about 5 mins the user joins the chat. After that the user is marked as trusted.\n\nTo turn on, use /noraid and give me permission to kick and ban users.",

	["(para limpar a lista use /disableall clear)\nComandos deshabilitados nesse chat:\n"] = "(to clean the list use /disableall clear)\nDisabled commands on this chat:\n",

	["Processando foto!"] = "Processing image!",
	["Imagem muito pequena, que nem seu pinto."] = "This image is very small, like your dick.",
	["Use o comando respondendo a uma mensagem com uma foto"] = "Reply in a message with a photo.",
	["Pronto! só demorou %d segundo%s caraio."] = "There, it only took %d second%s hecc",
	["Arquivo não encontrado"] = "File not found.",
	["VSF MANO. só um voto por pessoa. por penalidade. tirei seu voto.\n***"] = "No man, only one vote per person. I removed your vote\n***",
	["Você ja votou!"] = "You already did vote.\n",
	["Responda em uma mensagem para pinar."] = "Reply a message to be vote pinned\n",
	["Isso só funciona em chats."] = "This only works in chats.",
	["Votação para fixar essa mensagem [msgid:%d].\n***"] = "Voting to pin thi message [msgid:%d] ***",
	["eu nem sou adm pra fazer isso. sorry."] = "Sorry, im not a chat admin or have permission do to it.",
	["Se o admin mandou... ta pinado!"] = "If the admin said... its pinned!",
	["Aproximadamente"] = "",
	["Por volta de"] = "Around",
	["Cerca de"] = "Something like",
	["Uns"] = "Seems to be around",
	["está em"] = "is in",
	["É você"] = "Its you",
	["É o"] = "Its ",
	["Sim."] = "Yes.",
	["Não."] = "No.",
	["O"] = "The",
	["o que eu sou"] = "what am i",
	["o que sou eu"] = "what i am",

	

	["Favor usar o formato de data (dia)/(mes)/(ano) em forma numerica. exemplo: 13/5/1985"] = "Please use format (day)/(month)/(year) like: 13/5/1985",
	["Ai mano. essa data n pode n carai."] = "No. this is a invalid date.",
	["Ai mano. esse mes só tem 30 dias carai."] = "Serious? this month only have 30 days.",
	["Ai mano. esse mes só tem 27 dias carai."] = "Seriously? This month only have 27 days.",

	
	["\t\t`(Só admin do chat)`\n"] = "\t\t`(Chat adm only)`\n",
	["\t\t`(Só em chats e só por admins)`\n"] = "\t\t`(Only in chats and by chat admin.)`\n",


	["Regras alteradas para: \n\n\"%s\"\n:D"] = "Rules set to: \n\n\"%s\"\n:D",
	["Uso: /disable gato   OU   /disable random\n\n/disable [nome do comando]"] = "Usage: /disable cat   OR   /disable random\n\n/disable [command name]",
	["Comandos deshabilitados nesse chat\n"] = "Disabled commands on this chat:\n",
	["Você nao pode dehabilitar comandos de admins."] = "You cant disable adimin commands!",
	["Novas regras:\n"] = "New rules:\n",
	["Deshabilitado"] = "Disabled",
	["Habilitado"] = "Enabled",
	["Fazer regras aparecer no private"] = "Make rules show on private",
	["Qual chat quer ver ou gerenciar regras?\n\nSe o chat não aparecer, mande alguma mensagem no chat que você quer e use de novo o comando.\nEu não mantenho registro de onde cada usuario fica, só é salvo quando ele diz algo, e depois de um tempo some."] = "Wich chat you want to manage the rules?\n\nIf the chat dont appear, send some message in the chat you want.\nI dont keep track of wich chat every user are, only when someone says something.",
			["Regras do chat no private"] = "Chat rules on private",


	["[%s] Agora o bot vai ser %s nesse chat"] = "[%s] Now the bot will be %s on this chat.",
	["barulhento"] = "loud",
	["silencioso"] = "silent",

	--/live
	["Gerando gif do gato."] = "Generating gif live now.",
	["Aproveite o gato (ou nao)"] = "Enjoy the cat (or no)",
	["Grava um timelapse do gato do mock. Basta chamar /live"] = "Records a timelapse of mock's cat. Just call /live",
	["Gerando gif... %d/%d"] = "Generating gif now... %d/%d",
	["Regras do chat"] = "Chat rules",
	["Regras do chat "] = "Chat rules ",
	["Envie o comando de novo dando reply à mensagem que contem regras."] = "Send the command again with a reply that contain the rules.",
	["Exibir regras"] = "Show rules",
	["Mudar as regras"] = "Change rules",
	["Nem uma regra setada."] = "No rules set.",
	["O que você quer em relação as regras?"]  = "What you wanna do related to rules?",
	["Ok. Seu proximo texto será as regras. Envie elas!"] = "Okay, your next text message will be the rules. Just sent it!",
	["Regras alteradas para:\n"] = "Rules set to:\n",
	["Envie o comando de novo dando reply a mensagem que contem regras."] = "Send the command again replying the messages with the rules.",

	--/cat
	["Tira uma foto de onde o gato do mock dorme. Basta chamar /gato"] = "Take a single picture from where mock's cat usually sleeps.",
	--/random
	["Numero random entre %d e %d é *%d*"] = "Random number between %d and %d is *%d*",
	["Seleciona um numero aleatorio dentre 0 a 100 ou intervalo que voce decidir.\nPode ser usado assim: /random 6  (para um numero entre 1 e 6)\nOu: /random 5 10 (para um numero entre 5 e 10)\n\nTambem da para usar /random 10x (args) para randomizar 10x"] = "Select a random number between 0 to 100 or by the number you give.\nCan be used like: /random 6 (to give a number between 1 and 6)\nAnd: /random 5 10 (to a number between 5 and 10)\n\nAlso can be used like /random 10x (args) to choose 10 random numbers 10x",
	--/fraselewd
	["Gera proceduralmente uma frase. Basta usar /fraselewd"] = "Procedurally generate a random lewd phase... Only works in portuguese... sorry.",
	--/namegen
	["Gera proceduralmente 10 nomes. Basta usar /namegen"] = "Procedurally generate 10 names. Use like this: /namegen",
	["Gerado 10 nomes:\n"] = "Generated 10 names:\n",
	--/cruzar mix
	["Comando para misturar 2 nomes.\nUse assim: /cruzar batata bolo"] = "Command to mix two names.\nCalls like: /mix potato cake",
	['*%s* casou com *%s* e nasceu: *%s%s*'] = '*%s* mixed with *%s* and became: *%s%s*',
	["Para usar o comando cruzar use assim: /cruzar nome1 nome2"] = 'To use this command, call like this: /mix potato cake',
	--/time
	["Mostra horario da maquina. Basta usar /time"] = "Show the time (clock) used by the bot. /time",
	--/resumo brief
	["Mostra um resumo do que foi dito no chat. Basta usar /resumo"] = "Shows brieflily what happened in the chat lately. Just call /brief",
	["Quem falou mais foi @%s com %d mensagens\n"] = "Who speak most was @%s with %d messages\n",
	["Quem mandou mais imagem foi @%s com %d imagens\n"] = "Who sent more images were @%s with %d images.\n",
	["Quem mandou mais stickers foi @%s com %d stickers\n"] = "Who sent more stickers where @%s with %d stickers\n",
	["Quem mandou mais gifs foi @%s com %d gifs\n"] = "Who sent more gifs where @%s with %d gifs\n",
	["Resumo do que foi dito na%s utima%s %d hora%s e %d minuto%s :\n"] = "[%s%s] A brief of what have been said in the last %d hour%s and %d minute%s:\n",
	["E a roleta sorteou (%d):"] = "The spin wheel selected(%d):",
	["faiou msg id "] = "Failed messaged id ",
	["Revivendo uma mensagem (%d):"] = "Reviving a message (%d):",
	["Essa."] = "This one.",
	[" vezes\n"] = " times\n",
	["\n\nE foram %d mensagens, %d stickers e %d imagens."] = "\n\nAnd were total of %d messages, %d stickers and %d images.",
	["\n\nE %d novas pessoas no chat.\n"] = "\n\nAlso %d new users in the chat.\n",
	["Quem mais xingou foi %s with %d palavrões.\n"] = "Also the one with most swear were %s with total of %d bad words. :C\n",
	["\nTotalizando: %2.3f mensagens por minuto nesse chat."] = "\nTotal of: %2.3f messages per minut on this chat.",
	["Esse comando só funciona em chats."] = "This command only works on chats.",

	--/addmeme
	["Adiciona um meme ao bot.\nResponda a mensagem/imagem/sticker que será adicionada comuéo meme com /addmeme"] = "Add a meme to the bot.\nReply the message/image/sticker that will be added as meme with /addmeme",
	["Essa foto é o meme a ser adicionado? S/N"] = "This photo is the meme to be add? Y/N",
	["Esse sticker é o meme a ser adicionado? S/N"] = "This sticker is the meme to be add? Y/N",
	["Isso é o meme a ser adicionado? S/N"] = "This is the meme to be add? Y/N",
	["Erro ao salvar imagem. Encerrando comando."] = "Error on saving the image. Finishing operation.",
	["Meme salvo com ID *%d*! Para ver use /meme %d"] = "Meme saved with ID *%d*! To see it use /meme %d",
	["Então não. Encerrando comando."] = "Then its a no. Finishing operation.",
	--/meme
	["Mostra um meme aleatorio ou algum especifico se você colocar o numero\nAssim: /meme (para um aleatorio)\nOu:/meme 13\nTambem funciona para exibir os memes de alguem, basta usar /meme @username"] = "Show a random meme or specified meme.\nLike this: /meme  would give you a random neme.\nLike this would give you a specific meme: /meme 13\nAnd if you want to see the memes by a user, use: /meme @username",
	["não tem memes."] = "has no memes.",
	["tem %d memes! Esses são *%s*"] = "has %d memes! Those are: *%s*",
	["Não existe meme com id %d"] = "Cant find meme with id %d.",

	--/mention
	["Mostra onde você foi mencionado."] = "Show where you have been marked in the chat in the past hours.\nThis command may be subject to the bot uptime.",
	["A menção mais recente é essa."] = "This is the mention",
	["\n*Ainda existem %d mençoes. Repita o comando para ve-las.*"] = "*There are still %d mentions, repeat the command to see them*",
	["A menção foi apagada, quem te marcou foi @%s a o texto dizia:\n`%s`\n\n"] = "The mention were deleted, who marked it was @%s and it says:\n`%s`\n\n",
	--/start
	["Sou o burrbot e sou um bot com multiplas functionalidades, dentre elas:\n-> Gerenciamento de chat e regras\n-> Comandos bobos para alegrar seu chat\n-> Catcam\n-> Conversão monetaria\n->Gerenciador de eventos e meets\n\nCada uma dessas funcionalidade pode des deshabilitada individualmente em seu chat caso queria.\n*Caso queira saber mais sobre alguma funcionalidade, selecione abaixo.*\nBot feito por @Mockthebear sugestões são bem vindas!\n\nSe quiser adicionar no seu chat, fique a vontade. Ou use /commands para ver o que você pode usar.\nSe quiser saber o que algum comando faz, use /help (nome do comando)"] = "I am burrbot, i am a bot with multiple functions... that would be:\n-> Chat management and rules management\n-> Funny commands and stuff to brithern up your chat\n-> Catcam\n->Meet manager\n\nEach of those functions can be disable one by one in your chat if needed.\n*If you want to know more about any function click below.*\n\nBot made by @Mockthebear, and suggestions are welcome!\n\nFeel free to add to your chat, no need to ask :D\nOr use /commands to see what you can use\nAnd if you need to know what a command does, use /help (command name).\nFound a command or feature in portuguese and not in english? Report to @Mockthebear please :D",
	["Oi eu sou burrbot e sou gay."] = "Hi im burrbot and im gay.",
	["Esse bot consegue diferenciar membros e admins do chat. Alguns comandos só são liberados para os admins do chat. Dentre eles alguns comandos uteis como /setrules para definir regras, /setwelcome para definir mensagem de boas vindas a novos membros... Caso queira remover um comando, basta usar o /disable, e se o bot falar de mais, batas usar /nofun...\nPrecisa mudar a lingua do bot no chat? use /lang...\nAlguem enchendo o saco ou usando de mais o bot? /ignore (username)...\nPor ai vai... Adicione o bot no chat e dê /commands como admin para ver."] = "This bot can see the difference between a member and a chat admin. Some commands can only be used by chat admins. Some of those are usefull like /setrules to define chat rues. Another good one is /setwelcome to define a message to be sent to new members... If you want to remove some command use /disable (command name), if the bot talks too much use the command /nofun\nNeed to change bot language? use /lang\nSomeone is overusing the bot? use /ignore @username and will be solved.\nIf you add me on any chat and use the command /commands as admin you will see the whole list.",
	
	["Por favor, insira um numero. assim:\n/notifyinterval 5\nEsse numero é em minutos!\nSe quiser tirar intervalo apenas coloque 0."] = "Please insert a number like this:\n/notifyinterval 5\n This number is in minutes!\nIf you want to remove the interval just set /notifyinterval 0",
	["Intervalo de notificação para você foi setado para %d minutos!"] = "Notification interval set to %s minutes!",
	["Define um intervalo entre avisos"] = "Define a notification interval",


	["Para receber ajuda favor usar o comando assim:\n/ajuda (nome do comando)\n/ajuda random\n/ajuda addmeme\n\nPara checar os comando existentes use /commands"] = "To get help use the command this way:\n/faq (command name)\n/faq random\n/faq addmeme\n\nTo check the possible commands use /commands",
	["Precisa de ajuda com algum comando? Esse serve."] = "Needs help with some command? This does this.",

	["Desculpe, nem um comando chamado %s foi encontrado.\nPara checar os comando existentes use /start"] = "Sorry the commands %s was not found.\nTo check the avaliable commands use /commands",
	["O comando *%s* possuí *%d* segundos de coldown.\n\n`%s`"] = "The command *%s* has *%d* seconds of coldown.\n\n`%s`",
	["(sem descrição)"] = "(No description)",
	["Mostra todos os comandos que você pode usar. Comandos diferentes aparecem para admins do chat."] = "Show all commands you can use. Some commands might apear if used in a chat or if you are the chat admin.",
	["Gerenciamento de chats e regras"] = "Chat and rules management",
	["Comandos bobos para alegrar"] = "Silly commands.",



	["(Só aqui)"] = "(Only here)",
	["(Comando comum)"] = "(Common command)",
	["Não xinga caralho, porra."] = "Fuck! Dont swear.",
	["Listar comandos"] = "List commands",
	["@<user> seja bem viado :3"] = "@<user> Welcome to our chat!",
	["Entãaaao esses são os comandos que você pode usar aqui:\n%s\n"] = "SOOOO, here are the commands you can use here:\n%s\n\nJust a reminder. Some of the commnds are still in portuguese.",
	--/setwelcome

	
	["Hey, a lista de comandos aqui é muito grande... Para evitar spam eu posso enviar-la no private para você... Ou simplesmente use */commands force* que eu mando aqui."] = "Hey, the command list is too big... To avoid spam i can send to you as private message... or simply type */commands force* then i send it here.",
	["Mostra stats do bot."] = "Show bot stats",


	["É UM RECORDE! Esse chat chegou a *%d* dias, *%d* horas e *%d* minutos sem uma treta/drama"] = "ITS A RECORD! This chat went *%d* days, *%d* hours and *%d* minutes without drama!",
	["Esse chat chegou a *%d* dias, *%d* horas e *%d* minutos sem uma treta. e o recorde foram *%d* dias, *%d* horas e *%d* minutos!"] = "This chat reached *%d* days, *%d* hours and *%d* minutes without drama. The record is *%d* days, *%d* hours and *%d* minutes!",
	["Este chat está a *%d* dias, *%d* horas e *%d* minutos sem uma treta."] = "This chat is *%d* days, *%d* hours and *%d* minutes without drama.",
	["Falha ao editar mensagem. É melhor usar /treta gen"] = "Failedo n editing. Better use /drama gen",
	["Esse comando é usado para ter um contador de tretas!\nUse assim:\n\n/treta gen - *Isso vai gerar um contador*, deve ser usado somente uma vez, usando mais de uma vai fazer o contador antigo parar de funcionar. *Só o admin do chat pode usar!*\n\n/treta treta - *Reseta o contador*, por que rolou uma treta!\n\n/treta show / display - *Faz o bot dar forward e reply no contador de treta*, para que você consiga achar.\n\n/treta update - *Faz atualizar o contador* na hora do comando, o comando atualiza de 30 em 30 minutos sozinho, mas esse faz na hora."] = "This command is a drama timer!\nUse like this:\n\n/drama gen - *This will generate the drama timer*, can be used only once. Using twice will make unusable the old counter. *only the admin can use*!\n/drama drama - *Resets the counter because some furry drama happened*\n/drama show/display *I will forward the counter and reply so you can see*\n/drama update - *manually update the counter*, the counter auto updates also.",
	["Gerando contador..."] = "Generating counter...",
	["Somente administradores podem usar essa função (gen)"] = "Only admins can use this feature.",
	["É TREEETAAAA. Contador resetado!"] = "Oh damn... furry drama again... Counter reseted!",
	["Sem alteração."] = "No alteration needed.",
	["Pronto"] ="Done",
	["Esse chat não tem contador de tretas ainda."] = "This chat dont have furry drama counter",

	["Confirmado como não bot pelo admin!"] = "Confirmed as not a bot by a chat admin!",


	["Desculpa ai moço. Não tem nem um sorteio rolando agora. E só admins do chat podem iniciar sorteios."] = "Sorry man, theere is a raffle running now. Only chat admins can start raffles.",
	["Definir premios e abrir inscrições."] = "Define prizes and open registration",
	["Gerar resultados"] = "Generate results",
	["Cancelar"] = "Cancel",
	["Iniciando um sorteio! O que quer fazer?"] = "Starting a raffle, what you wanna do?",
	["Você saiu do sorteio."] = "You are out of the raffle",
	["Você está inscrito!"] = "You are in the raffle",
	["Participantes: \n"] = "Participants: \n",
	["Iniciando um sorteio! O que quer fazer?"] = "Managing a raffle, what you wanna do?",
	["INICIAR"] = "Start raffle!",
	["Desculpa ai moço. o sorteio não abriu ainda!"] = "Sorry, no raffles open yet.",
	["Esse comando só funciona em chats... Mas não vou te deixar na mão. Sorteei um numero de 0 a 100, e ele é *%d*!"] = "This command only work in chats... but i will give you a /random numer between 0 and 100 and this one is *%d*!",
	["A descrição do sorteio é:\n*%s*\nConfere?"] = "Raffle description is:\n*%s*\nCheck?",
	["Cancelando!"] = "Canceled!",
	["Ok. Para iniciar o sorteio, forneça uma mensagem que será a descrição, e contendo o premio!"] = "Ok, to start a raffle, give me a message that will be the raffle description and containing the prize.",
	["Sorteio aberto por @%s! use o comando /sorteio para participar. Se usar duas vezes você tira sua inscrição."] = "Raffle open by @%s! To join use the command /raffle. if used twice remove your entry.",
	["*Atenção!* O sorteio vai ocorrer da seguinte forma:\nA cada turno, eu vou tirar um nome da lista e anunciar. Essa pessoa está fora. A utima que ficar na lista vai ganhar!"] = "*Attention*! The raffle will run like this:\nEvery turn a name will be removed from the list. This person is Out! The last one will win!",
	["Quem ainda está no sorteio: \n"] = "Who are still in the raffle: \n",
	["Ok, perfeito. O sorteio está armazenado e só será iniciado quando você @%s clicar no botão [iniciar sorteio].\nCaso a mensagem se perca, basta usar novamente /sorteio."] = "Ok perfect. The raffle is stored and will be started when you click the button [start raffle].\nIf you lost the message just send /raffle again.",

}


	
end