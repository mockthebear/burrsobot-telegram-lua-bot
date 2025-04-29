local module = {
	priority = DEFAULT_PRIORITY,
}

--[ONCE] runs when the load is finished
function module.load()

end

--[ONCE] runs when eveything is ready
function module.ready()

end

--Runs at the begin of the frame
function module.frame()

end

--Runs some times
function module.save()

end

function module.loadCommands()
	addCommand( {"define"}		, MODE_FREE,  getModulePath().."/define.lua", 2 , "dictionary-define" )
end

function module.loadTranslation()
	g_locale[LANG_US]["dictionary-define"] = "Definição de uma palavra"
	g_locale[LANG_BR]["dictionary-define"] = "Portuguese defition of a word"
end


function module.stripChars(str)
  local tableAccents = {}
    tableAccents["ã"] = "ã"
    tableAccents["Ã"] = "Ã"
    tableAccents["ç"] = "ç"
    tableAccents["Ç"] = "Ç"
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


function module.softStripChars(str)
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



function module.getDefinition(word) 
	word = word:lower()
	word = module.softStripChars(word)

    local dat = httpsRequest("https://www.dicio.com.br/"..word.."/")
    if not dat then 
        return nil, -1, nil
    end

    local wut = dat:match("<p class=\"significado textonovo\">(.-)</p>")    
    if not wut then 
    	return false, 0, nil
    end
    

    local subs = wut:match("<span class=\"cl\">(.-)</span>") or "?"
    wut = wut:gsub("<span class=\"tag\">(.-)</span>", "%1")
    local var = wut:match("<span>Variação de <a href=\"/(.-)/")
    if wut:len() < 3 or var then 
    	return true, 1, "Variação de <b>"..var.."</b>"
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
	return true, 0, filtered..(etim and ("\n\n<pre>"..etim.."</pre>") or "")
end


return module