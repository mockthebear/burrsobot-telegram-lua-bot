local module = {
	cache = nil,
	last_cache=0,
}

--[ONCE] runs when the load is finished
function module.load()
	if pubsub then
		pubsub.registerExternalVariable("chat", "disabled_currency_exchnage", {type="boolean"}, true, "Disable currency exchange", "Chatting")
	
	end
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
	
end

function module.loadTranslation()


	g_locale[LANG_US]["currency-usd"] = "<b>Converting USD to BRL by brazilian central bank</b>\n\n• 1,00:%s (<i>4% spread</i>)	\n• Inclusing +R$ %s (<i>6.38% IOF</i>)\n» Converting <b>US$ %s</b> <i>(1:%s</i>) gives a total of <b>R$ %s</b>\n\n<i>This amount is the total of beeing paid if you buy something using an brazilian credit card using dollar.</i>"
	g_locale[LANG_BR]["currency-usd"] = "<b>Cotaçao banco central do dollar comercial</b>\n\n• 1,00:%s (<i>4% spread</i>)	\n• Incluindo +R$ %s (<i>6.38% IOF</i>)\n» Convertendo <b>US$ %s</b> <i>(1:%s</i>) sai a <b>R$ %s</b>\n\n<i>Esse valor é o que será pago se você fizer uma compra em moeda estrangeira com cartão de credito.</i>"


end


function module.getCoinage()
   	local f = io.popen("curl https://www.bcb.gov.br/api/servico/sitebcb/indicadorCambio")
   	local content = f:read("*a")
   	f:close()

    local jj = cjson.decode(content)
    return jj     
end

function module.getAllCoinage()

	if not module.cache or module.last_cache < os.time() then
	   	local f = io.popen("curl https://ptax.bcb.gov.br/ptax_internet/consultarTodasAsMoedas.do?method=consultaTodasMoedas")
	   	local content = f:read("*a")
	   	f:close()

	    local tbody = content:match("<tbody>(.-)</tbody>")
	    local coins = {}
	    for memes in tbody:gmatch("<tr class=\".-\">(.-)</tr>") do 
	    	--print(memes)
	    	--<td align="right">5,4369</td>
	    	local thisdata = {}
	    	for mode in memes:gmatch("<td align=\".-\">(.-)</td>") do  
	    		thisdata[#thisdata+1] = mode
	    	end
	    	if thisdata[3] then
	    		local buy = thisdata[4]:gsub(",", ".")thisdata[5]:gsub(",", ".")
	    		local sell = thisdata[5]:gsub(",", ".")
		    	coins[thisdata[3]:lower()] = {
		    		id=thisdata[1],
		    		type=thisdata[2],
		    		name=thisdata[3],
		    		buy=tonumber(buy),
		    		sell=tonumber(sell),
		    	}
		    end

	    end
	    module.cache = coins 
	    module.last_cache = os.time() + 3600
	end
    return module.cache   
end



function module.onTextReceive(msg)
	if (msg.isChat and not chats[msg.chat.id].data.disabled_currency_exchnage) or msg.chat.type == "private" then
		if msg.targeted_to_bot then
			if  msg.text:match("([%-%d%.%,]+)[%s]*[cC][mM]") then 
				local amount = msg.text:match("([%-%d%.%,]+)[%s]*[cC][mM]")
				if not tonumber(amount) then 
		            amount = amount:gsub(",",".")
		        end
		        amount = tonumber(amount)
		        if not amount then 
		            return
		        end
		        reply_html("<b>"..amount.."</b> <i>CM</i> equals to:\n<b>"..string.format("%2.3f", amount / 2.54).."</b> <i>inches (polegadas)</i>\n<b>"..string.format("%2.3f", amount / 30.48).."</b> <i>feet (pés)</i>")
				return true
			end
			if  msg.text:match("([%-%d%.%,]+)[%s]*[iIpP][nNoO]") or msg.text:match("([%-%d%.%,]+)[%s]polegada") then 
				local amount = msg.text:match("([%d%.%,]+)[%s]*[iIpP][nNoO]")
				if not amount then 
					amount = msg.text:match("([%-%d%.%,]+)[%s]polegada")
				end
		        if not amount then 
		            return
		        end
				if not tonumber(amount) then 
		            amount = amount:gsub(",",".")
		        end
		        amount = tonumber(amount)
		        if not amount then 
		            return
		        end
		        reply_html("<b>"..amount.."</b> <i>inches (polegadas)</i> equals to:\n<b>"..string.format("%2.3f", amount * 2.54).."</b> <i>CM</i>\n<b>"..string.format("%2.3f", amount / 12).."</b> <i>feet (pés)</i>")
				return true
			end

			if  msg.text:match("([%-%d%.%,]+)[%s]*[kK][gG]") then 
				local amount = msg.text:match("([%-%d%.%,]+)[%s]*[kK][gG]")
				if not tonumber(amount) then 
		            amount = amount:gsub(",",".")
		        end
		        amount = tonumber(amount)
		        if not amount then 
		            return
		        end
		        reply_html("<b>"..amount.."</b> <i>KG</i> equals to:\n<b>"..string.format("%2.3f", amount * 2.205).."</b> <i>lbs</i>")
				return true
			end
			if  msg.text:match("([%-%d%.%,]+)[%s]*[lL][bB]") then 
				local amount = msg.text:match("([%-%d%.%,]+)[%s]*[lL][bB]")
				if not tonumber(amount) then 
		            amount = amount:gsub(",",".")
		        end
		        amount = tonumber(amount)
		        if not amount then 
		            return
		        end
		        reply_html("<b>"..amount.."</b> <i>lbs</i> equals to:\n<b>"..string.format("%2.3f", amount / 2.205).."</b> <i>KG</i>")
				return true
			end


			if msg.text:match("([%-%d%.%,]+)[%sº]*[cC]$") then
				local amount = msg.text:match("([%-%d%.%,]+)[%sº]*[cC]$")
				if not tonumber(amount) then 
		            amount = amount:gsub(",",".")
		        end
		        amount = tonumber(amount)
		        if not amount then 
		            return
		        end
		        local conv = (amount * 9/5) + 32
		        reply_html("<b>"..amount.."</b> <i>°C</i> equals to <b>"..conv.."</b> <i>°F</i>")
				return true
			end
			if msg.text:match("([%-%d%.%,]+)[%sº]*[fF]$") then
				local amount = msg.text:match("([%-%d%.%,]+)[%sº]*[fF]$")
				if not tonumber(amount) then 
		            amount = amount:gsub(",",".")
		        end
		        amount = tonumber(amount)
		        if not amount then 
		            return
		        end
		        local conv = (amount - 32) * 5/9
		        reply_html("<b>"..amount.."</b> <i>°F</i> equals to <b>"..conv.."</b> <i>°C</i>")
				return true
			end

		    if msg.text:match("([%d%.%,]+) d..?lar[es%s]*") then
		        local amount = msg.text:match("([%d%.%,]+) d..?lar[es%s]*")
		        if not tonumber(amount) then 
		            amount = amount:gsub(",",".")
		        end
		        amount = tonumber(amount)
		        if amount then 
		            local prices = module.getCoinage()
		            if not prices or not prices.conteudo then 
		            	reply("Failed to retrieve https://www.bcb.gov.br/api/servico/sitebcb/indicadorCambio")
		                return true
		            end
		            prices = prices.conteudo
		            prices[1] = prices[1] or prices[2]


		               
		            prices[1].valorVenda = tonumber(prices[1].valorVenda)
		            local conv =  prices[1].valorVenda* 1.04

		            local iof = (conv*amount) * 0.0638
		  
		            reply.html("currency-usd", string.format("%2.3f",conv):gsub("%.", ","), string.format("%2.3f", iof):gsub("%.", ","), amount, string.format("%2.3f", conv):gsub("%.", ","), string.format("%2.3f",amount*conv + iof):gsub("%.", ","))
		     
		            
		        end
		        return true
		    elseif msg.text:match("([%d%.%,]+) (...)$") then
		    	local amount, coinname = msg.text:match("([%d%.%,]+) (...)$")
		        if not tonumber(amount) then 
		            amount = amount:gsub(",",".")
		        end
		        amount = tonumber(amount)
		        if amount then 
		            coinname = coinname:lower()
			    	local allCoins = module.getAllCoinage()
			    	if not allCoins[coinname] then  
			    		local valid = ""
			    		for name, _ in pairs(allCoins) do  
			    			valid = valid .. name .. " "
			    		end
			    		
			    		reply.html("Moeda '"..coinname:upper().."' não encontrada.\nMoedas validas:\n<code>" ..valid.."</code>")
			    		return true
			    	end
			    	local coin = allCoins[coinname]

		            local conv =  coin.buy* 1.04

		            local iof = (coin.buy*amount) * 0.0638

		            reply.html("<b>Cotaçao banco central de "..coinname:upper().."</b>\n\n"..
		                "• 1,00:"..string.format("%2.3f",conv):gsub("%.", ",").." (<i>4% spread</i>)\n"..
		                "• Incluindo +R$ "..string.format("%2.3f", iof):gsub("%.", ",").." (<i>6.38% IOF</i>)\n"..
		                "» Convertendo <b>"..coinname:upper().."$ "..amount.."</b> <i>(1:"..string.format("%2.3f", conv):gsub("%.", ",").."</i>) sai a <b>R$ "..string.format("%2.3f",amount*conv + iof):gsub("%.", ",").."</b>\n\n<i>Esse valor é o que será pago se você fizer uma compra em dollar com cartão de credito.</i>")
		            
		        end
		        return true
		    end

		    if msg.text:match("cotação%s(...)") or msg.text:match("cotacao%s(...)") then
		    	local coinname = msg.text:match("cotação%s(...)")
		    	if not coinname then 
		    		coinname = msg.text:match("cotacao%s(...)")
		    	end
		    	coinname = coinname:lower()
		    	local allCoins = module.getAllCoinage()
		    	if not allCoins[coinname] then  
		    		reply("Moeda '"..coinname.."' não encontrada.")
		    		return true
		    	end
		    	local coin = allCoins[coinname]
		    	reply.html("Cotação da modea '"..coinname:upper().."'.\n<b>1.00 BRL</b> = <b>"..coin.buy.." "..coinname:upper().."</b>")
		    elseif msg.text:match("cotação") or msg.text:match("cotacao") then
		        local prices = module.getCoinage()
		        if not prices or not prices.conteudo then 
		            reply("Failed to retrieve https://www.bcb.gov.br/api/servico/sitebcb/indicadorCambio")
		            return true
		        end
		        prices = prices.conteudo
		        prices[1] = prices[1] or prices[2]
		        prices[3] = prices[3] or prices[4]


		        local conv1 =  prices[1].valorVenda* 1.04
		        local conv2 =  prices[3].valorVenda* 1.04
		        g_sayMode = "HTML"
		        reply("<b>Cotaçao banco central</b>\n\n"..
		                "• Dolar $1,00:<b>"..string.format("%2.3f",conv1):gsub("%.", ",").."</b> R$\n"..
		                "• Euro  €$1,00:<b>"..string.format("%2.3f",conv2):gsub("%.", ",").."</b> R$\n"..
		            "\n<i>Para checar quanto você vai pagar se fizer uma compre, fale:</i>\n<b>burrbot 10 euros</b>\n<b>burrbot 10 dolares</b>")
		            g_sayMode = ""

		        return true
		    end

		    if msg.text:match("([%d%.%,]+) euro") then
		        local amount = msg.text:match("([%d%.%,]+) euro*")
		        if not tonumber(amount) then 
		            amount = amount:gsub(",",".")
		        end
		        amount = tonumber(amount)
		        if amount then 
		            local prices = module.getCoinage()
		            if not prices or not prices.conteudo then 
		                reply("Failed to retrieve https://www.bcb.gov.br/api/servico/sitebcb/indicadorCambio")
		                return true
		            end
		            prices = prices.conteudo
		            prices[3] = prices[3] or prices[4]
		               
		            prices[3].valorVenda = tonumber(prices[3].valorVenda)
		            local conv =  prices[3].valorVenda* 1.04

		            local iof = (conv*amount) * 0.0638
		            g_sayMode = "HTML"
		            reply("<b>Cotaçao banco central do euro comercial</b>\n\n"..
		                "• 1,00:"..string.format("%2.3f",conv):gsub("%.", ",").." (<i>4% spread</i>)\n"..
		                "• Incluindo +R$ "..string.format("%2.3f", iof):gsub("%.", ",").." (<i>6.38% IOF</i>)\n"..
		                "» Convertendo <b>€$ "..amount.."</b> <i>(1:"..string.format("%2.3f", conv):gsub("%.", ",").."</i>) sai a <b>R$ "..string.format("%2.3f",amount*conv + iof):gsub("%.", ",").."</b>\n\n<i>Esse valor é o que será pago se você fizer uma compra em euro com cartão de credito.</i>")
		            g_sayMode = ""

		            
		        end
		        return true
		    end

		    if msg.text:match("([%d%.%,]+) reais") then
		        local amount = msg.text:match("([%d%.%,]+) reais")
		        if not tonumber(amount) then 
		            amount = amount:gsub(",",".")
		        end
		        amount = tonumber(amount)
		        if amount then 
		            local prices = module.getCoinage()
		            if not prices or not prices.conteudo then 
		                reply("Failed to retrieve https://www.bcb.gov.br/api/servico/sitebcb/indicadorCambio")
		                return true
		            end

		            prices = prices.conteudo
			        prices[1] = prices[1] or prices[2]
			        prices[3] = prices[3] or prices[4]


			        local conv1 =  prices[1].valorVenda* 1.04
			        local conv2 =  prices[3].valorVenda* 1.04

		              
		            prices[3].valorVenda = tonumber(prices[3].valorVenda)
		            local conv =  prices[3].valorVenda* 1.04


		            local amountDollar = (amount/conv1) 
		            local amountEuro = (amount/conv2) 



		            
		            local iofEuro =  (amount* 0.0638)/conv1
		            amountEuro = amountEuro - iofEuro
		            local iofDollar =  (amount* 0.0638)/conv2
		            amountDollar = amountDollar - iofDollar


		            g_sayMode = "HTML"
		            reply("<b>Cotaçao banco central de real para euro comercial e dollar comercial</b>\n\n"..
		            	"• Dolar $1,00:<b>"..string.format("%2.3f",1/conv1):gsub("%.", ",").."</b> R$\n"..
		                "• Incluindo +R$ "..string.format("%2.3f", iofDollar):gsub("%.", ",").." (<i>6.38% IOF</i>)\n"..
		                "» Convertendo <b>R$ "..amount.."</b> <i>(1:"..string.format("%2.3f", 1/conv1):gsub("%.", ",").."</i>) sai a <b>$ "..string.format("%2.3f",amountDollar):gsub("%.", ",").."</b>\n\n"..
		                "• Euro  €$1,00:<b>"..string.format("%2.3f",1/conv2):gsub("%.", ",").."</b> R$\n"..
		                "• Incluindo +R$ "..string.format("%2.3f", iofEuro):gsub("%.", ",").." (<i>6.38% IOF</i>)\n"..
		                "» Convertendo <b>R$ "..amount.."</b> <i>(1:"..string.format("%2.3f", 1/conv2):gsub("%.", ",").."</i>) sai a <b>€$ "..string.format("%2.3f",amountEuro):gsub("%.", ",").."</b>\n\n"..
		                "Esse é o valor correspondende a uma compra de euro ou dollar com cartão de crédito.")
		            g_sayMode = ""

		            
		        end
		        return true
		    end
		end
	end
	return false
end

return module