
function stripChars(str)
  local tableAccents = {}
    tableAccents["À"] = "A"
    tableAccents["Á"] = "A"
    tableAccents["Â"] = "A"
    tableAccents["Ã"] = "A"
    tableAccents["Ä"] = "A"
    tableAccents["Å"] = "A"
    tableAccents["Æ"] = "AE"
    tableAccents["Ç"] = "C"
    tableAccents["È"] = "E"
    tableAccents["É"] = "E"
    tableAccents["Ê"] = "E"
    tableAccents["Ë"] = "E"
    tableAccents["Ì"] = "I"
    tableAccents["Í"] = "I"
    tableAccents["Î"] = "I"
    tableAccents["Ï"] = "I"
    tableAccents["Ð"] = "D"
    tableAccents["Ñ"] = "N"
    tableAccents["Ò"] = "O"
    tableAccents["Ó"] = "O"
    tableAccents["Ô"] = "O"
    tableAccents["Õ"] = "O"
    tableAccents["Ö"] = "O"
    tableAccents["Ø"] = "O"
    tableAccents["Ù"] = "U"
    tableAccents["Ú"] = "U"
    tableAccents["Û"] = "U"
    tableAccents["Ü"] = "U"
    tableAccents["Ý"] = "Y"
    tableAccents["Þ"] = "P"
    tableAccents["ß"] = "s"
    tableAccents["à"] = "a"
    tableAccents["á"] = "a"
    tableAccents["â"] = "a"
    tableAccents["ã"] = "a"
    tableAccents["ä"] = "a"
    tableAccents["å"] = "a"
    tableAccents["æ"] = "ae"
    tableAccents["ç"] = "c"
    tableAccents["è"] = "e"
    tableAccents["é"] = "e"
    tableAccents["ê"] = "e"
    tableAccents["ë"] = "e"
    tableAccents["ì"] = "i"
    tableAccents["í"] = "i"
    tableAccents["î"] = "i"
    tableAccents["ï"] = "i"
    tableAccents["ð"] = "eth"
    tableAccents["ñ"] = "n"
    tableAccents["ò"] = "o"
    tableAccents["ó"] = "o"
    tableAccents["ô"] = "o"
    tableAccents["õ"] = "o"
    tableAccents["ö"] = "o"
    tableAccents["ø"] = "o"
    tableAccents["ù"] = "u"
    tableAccents["ú"] = "u"
    tableAccents["û"] = "u"
    tableAccents["ü"] = "u"
    tableAccents["ý"] = "y"
    tableAccents["þ"] = "p"
    tableAccents["ÿ"] = "y"

  local normalisedString = ''

  local normalisedString = str: gsub("[%z\1-\127\194-\244][\128-\191]*", tableAccents)

  return normalisedString

end
function OnCommand(msg, text, args)
	local word = args[2]
	if not word or word == "" then 
		reply("Use assim: /defina palavra")
		return
	end

	word = word:lower()

	word =  stripChars(word)


    local dat = httpsRequest("https://www.dicio.com.br/"..word.."/")
    if not dat then 
    	reply("fail")
        return nil
    end

    --<p itemprop="description" class="significado textonovo"><span class="cl">(substantivo masculino)</span> <span><span class="tag">[Culinária]</span> Massa de farinha, geralmente com açúcar e ovos, além de outros ingredientes, geralmente de forma arredondada ou retangular, cozida ou assada.</span><br /><span><span class="tag">[Culinária]</span> Alimento salgado feito com variados ingredientes, assado ou frito: bolo de carne.</span><br /><span>Algo que pode ser moldado em forma de bola: bolo de dinheiro.</span><br /><span>Qualquer porção; monte: há um bolo de coisas sobre a mesa.</span><br /><span><span class="tag">[Popular]</span> Ação de quem não cumpre um compromisso já marcado: me deu um bolo, fiquei esperando e nada!</span><br /><span><span class="tag">[Popular]</span> Engano ou ação de enganar; logro: aquele contrato foi o maior bolo!</span><br /><span><span class="tag">[Popular]</span> Ajuntamento de pessoas; confusão: bolo de gente!</span><br /><span><span class="tag">[Popular]</span> Confusão grande, com muitas pessoas envolvidas; briga.</span><br /><span><span class="tag">[Popular]</span> Situação difícil ou repleta de conflitos; em que há falta de organização.</span><br /><span><span class="tag">[Figurado]</span> Soma de dinheiro formada mediante rateio, ou pelas apostas de parceiros de jogo: ganhou o bolo das apostas.</span><br /><span><span class="tag">[Popular]</span> Golpe de palmatória, dado como punição.</span><br /><span>Globo situado na extremidade de uma bandeira.</span><br /><span>Numa corrida de cavalos, aposta cujo ganhador é aquele que faz mais acertos ao indicar o vencedor, e placês dos páreos.</span><br /><span>Bola usada como peso em redes de pesca, geralmente feita com barro cozido.</span><br /><span class="cl">expressão</span> <span>Dar o bolo. Faltar a compromisso ou encontro marcado.</span><br /><span><span class="tag">[Biologia]</span> Bolo alimentar. Massa composta pelos alimentos após a deglutição.</span><br /><span class="etim">Etimologia (origem da palavra <i>bolo</i>). Talvez palavra derivada de bola.</span></p>

    local wut = dat:match("<p itemprop=\"description\" class=\"significado textonovo\">(.-)</p>")
    
    if not wut then 
    	reply("Palavra '"..word.."' não encontrada")
    	return 
    end
    local subs = wut:match("<span class=\"cl\">(.-)</span>") or "?"
    wut = wut:gsub("<span class=\"tag\">(.-)</span>", "%1")
    local var = wut:match("<span>Variação de <a href=\"/(.-)/")
    if wut:len() < 3 or var then 
    	
    	reply_html("Variação de <b>"..var.."</b>")
    	return
    end
    	


    local filtered = "Definiçao de <b>"..word.."</b> <i>("..subs..")</i>:\n"

    local etim = wut:match("<span class=\"etim\">(.-)</span>")

    local found = {}
    local accept = 6
	for wat in wut:gmatch("<span>(.-)</span>") do
 	
	    local txt = wat:gsub("<(.-)>", "")
	    local mmm, rabbet = txt:match("%[(.-)%] (.+)")
	    if mmm or accept >= 1 then 
	    	if not mmm then 
	    		accept = accept -1
	    		mmm = accept
	    	end
	    	if not found[mmm] then 
	    		found[mmm] = true
	    		filtered = filtered.."<code>-----------------------------</code>\n"..txt:htmlFix().."\n"
	    	end
	    end
	   
	end
	reply_html(filtered..(etim and ("\n\n<pre>"..etim.."</pre>") or ""))

end