function OnCommand(user, msg, args)
	msg = msg:gsub("/complete ","")
	if args[2] or ( user.reply_to_message and  user.reply_to_message.text) then 
		if (user.reply_to_message and user.reply_to_message.text) then 
			msg = user.reply_to_message.text
		end

		local response = {}
		local content = '{"context":"'..msg:gsub("\n","↵"):gsub("\"","'")..'","model_size":"gpt2/large","top_p":0.15,"temperature":2.8,"max_time":4}'


		local a,b = httpsRequest("https://transformer.huggingface.co/autocomplete/distilgpt2/small", "POST", content, {                                                                                                                                                                                                                                                                                                                                                 
			 	['Accept']= '*/*',
				['Accept-Encoding']= 'gzip, deflate, br',
				--['Accept-Language']= 'pt-BR,pt;q=0.9,en-US;q=0.8,en;q=0.7',
				['Connection']= 'keep-alive',
				['Content-Length'] = #content    ,
				['Content-Type']= 'application/json',
				--['Cookie']= '_ga=GA1.2.2117031420.1574045218; _gid=GA1.2.1835900571.1574045218; _gat=1',
				['Host']= 'transformer.huggingface.co',
				['Origin']= 'https://transformer.huggingface.co',
				['Referer']= 'https://transformer.huggingface.co/doc/distil-gpt2',
				['Sec-Fetch-Mode']= 'cors',
				['Sec-Fetch-Site']= 'same-origin',
				['User-Agent']= 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.97 Safari/537.36 t.me/Burrsobot',                                                                                                                                                           
			 })
		if a and b == 200 then 

			local tb = cjson.decode(a)
			local str = ""
			local bigger = "?"

			for i,b in pairs(tb.sentences) do 
				if #b.value > #bigger then 
					bigger = b.value
				end
			end

			str = str .. "<b>"..msg.."</b>"..tostring(bigger):gsub("↵","\n"):gsub("↵","\n")
			bot.sendMessage(g_chatid,str, "HTML",true,false, nil)
		else 
			say("deu ruim"..Dump({a,b,c,d,e,f}))
		end	
	end
end
