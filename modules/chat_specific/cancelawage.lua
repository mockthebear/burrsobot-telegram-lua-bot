local cancela = {}

if not g_cancela then
	g_cancela = {}
	--[[for i=1, (#cancela*5) do
		local a = math.random(1, #cancela) 
		local b = math.random(1, #cancela) 
		local aux = cancela[a]
		cancela[a] = cancela[b]
		cancela[b] = aux
	end
	for i=1, (#cancela) do
		g_cancela[i] = cancela[i]
	end ]]

	g_cancela.cnt = 1
	
end

function OnCommand(user, msg, args)
	if user.from.username == "wagesn" then 
		return reply("ai mano, auto cancelamento n vale n viu?")
	end
	if not users[user.from.username]["cancela_wage"] or users[user.from.username].cancelaDay ~= (tonumber(os.date("%d"))-1) then
		users[user.from.username]["cancela_wage"] = g_cancela.cnt * os.time()
		g_cancela.cnt = g_cancela.cnt +1
		users[user.from.username].cancelaDay = tonumber(os.date("%d"))-1
	end

	--math.randomseed(users[user.from.username]["cancela_wage"]*4)

	local reason = {
		'foi grosso com',
		'olhou feio pra',
		'olhou atravessado para',
		'não dividiu chiclete com',
		'tava lá de boas sem ligar para',
		'falou mal do',
		'não deu atenção para',
		'discordou de',
		'fez uma dança interpretativa sobre o',
		'discordou no facebook do',
		'bloqueou',
		'xingou',
		'tirou do grupo',
		'robou o lanche do',
		'encheu a cara com',
		'atropelou',
	}

	local action = {
		"o filme da liga da justiça",
		"meu fursona",
		"meus fursonas",
		"meu papagaio",
		"meu marido",
		"meu pinto",
		"meu pau de óculos",
		"meus advogados",
		"meu evento",
		"meu jogo preferido",

	}
	local res = reason[math.random(1, #reason)]
	local ac = action[math.random(1, #action)]


	if res:sub(#res-2, #res) == 'do' and ac:sub(1,1) == 'o' then 
		res = res:sub(1, #res-2)
	end

	if math.random(0, 1000) <= 500 then 
		res = res:gsub(" com", ""):gsub(" para", ""):gsub(" do$", ""):gsub(" o", ""):gsub(" sobre o", "") .." e "..reason[math.random(1, #reason)]
		if math.random(0, 1000) <= 300 then 
			res = res:gsub(" com", ""):gsub(" para", ""):gsub(" do$", ""):gsub(" o", ""):gsub(" sobre o", "") .." e "..reason[math.random(1, #reason)]
		end
	end

	reply_html(selectUsername(user, true).." vai cancelar o Wagesn por que ele <b>"..res.." "..ac.."</b>.")

end