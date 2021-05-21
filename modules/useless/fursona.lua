function sugested(a) --Gerador de nomes

   local rare = {'k','y','x','q'}
   local cons = {'b','c','d','f','g','h','i','l','m','n','p','r','s','t','v','j'}
   local combined = {'vr', 'ck', 'tr', 'br', 'sh', 'th', 'pr', 'dr', 'fr', 'gr', 'cr', 'vr', 'nr', 'mr', 'nm', 'qu'}
   local vog = {"a",'e','i','o','u'}
   local sibalas = {}
   local sibalas3 = {}
   for i=1, #rare do 
   		if math.random(0,1000) >= 600 then
   			cons[#cons] = rare[i]
   		end
   end

   for i=1,#cons do
      for e=1,#vog do
        table.insert(sibalas,1,cons[i]..vog[e])
      end
   end

   for i=1,#combined do
      for e=1,#vog do
        table.insert(sibalas3,1,combined[i]..vog[e])
      end
   end

   local total = ""
   a = a or 1
   for i=1,a do
       local nam = ""
       for i=1,math.random(2,4) do
       		if math.random(0,1000) >= 200 then
           		nam = nam..sibalas[math.random(1,#sibalas)]
           	else 
           		nam = nam..sibalas3[math.random(1,#sibalas3)]
           	end
       end
       if math.random(0,100) <= 40 then
          nam = nam..vog[math.random(1,#vog)]
       elseif math.random(0,100) <= 40 then
          nam = nam..cons[math.random(1,#vog)]
       end
       total = total..(i == 2 and ' ' or '')..nam:sub(1,1):upper()..nam:sub(2,-1)
   end
   return total
end

local kekName = {
	[LANG_BR] = {
		"snow",
		"fox",
		"deer",
		"dark",
		"shadow",
		"nick",
		"bear",
		"sno",
		"wolf",
		"fair",
		"silver",
		"red",
		"white",
		"dog",
		"drake",
		"fire",
		"ice",
		"winter",
		"master",
		"cold",
		"steel",
		"baby",
		"gay",
		"lord",
		"super",
		"cat",
		"paw",
		"evil",
		"claw",
		"ear",
		"pointy",
		"wild",
		"frenzy",
		"crazy",
		"sad",
		"teen",
		"haunted",
		"sword",
		"drunk",
		"radioactive",
		"maple",
		"tooth",
		"maw",
		"musky",
		--[["yami",
		"napkin",
		"round",
		"feather",
		"cloud",
		"mist",
		"clingy",
		"fog",
		"foggy",]]
	},

	[LANG_US] = {
		"snow",
		"fox",
		"deer",
		"dark",
		"shadow",
		"nick",
		"bear",
		"sno",
		"wolf",
		"fair",
		"silver",
		"red",
		"white",
		"dog",
		"drake",
		"fire",
		"ice",
		"winter",
		"master",
	},
}

local species = {
	[LANG_BR] = {
	    { name = "urso"     , "um urso", "uma ursa", heavy=4},
	    {name = "lobo"      , "um lobo", "uma loba", heavy=5},
	    {name = "gato"      , "um gato", "uma gata", heavy=4},
	    {name = "red panda" , "um red panda", "uma red panda", heavy=2},
	    {name = "panda"     , "um panda", "uma panda", heavy=2},
	    {name = "pato"      , "um pato", "uma pata"},
	    {name = "cachorro"  , "um cachorro", "uma cadela", heavy=5},
	    {name = "dragão"    , "um dragão", "uma draga", heavy=5},
	    {name = "raposa"    , "uma raposa", "uma raposa", heavy=6},
	    {name = "rato"      , "um ratinho", "uma ratinha", heavy=2},
	    {name = "leão"      , "um leão", "uma leoa", heavy=2},
	    {name = "leopardo"  , "um leopardo", "uma leopardo", heavy=2},
	    {name = "guaxinim"  , "um guaxinim", "uma guaxinim", heavy=2},
	    {name = "alce"      , "um alce", "uma alce"},
	    {name = "veado"     , "um veado", "uma veado", heavy=3},
	    {name = "sergal"    , "um sergal", "uma sergal", heavy=3},
	    {name = "angel dragon",  "um angel dragon", "uma angel dragon"},
	    {name = "morcego"   ,  "um morcego", "uma morcego"},
	    {name = "dalmata"   ,  "um dalmata", "uma dalmata", heavy=2},
	    {name = "bode"      ,  "um bode", "uma cabra"},
	    {name = "passaro"   ,  "um passaro", "uma passaro"},
	    {name = "husky"   ,  "um husky", "uma husky", heavy=2},
	    {name = "urso polar"   ,  "um urso polar", "uma ursa polar", heavy=3},
	    {name = "labrador"   ,  "um labrador", "uma labradora", heavy=2},
	    {name = "lagarto"   ,  "um lagarto", "uma lagarta"},
	    {name = "tubarão"   ,  "um tubarão", "uma tubarão", heavy=2},
	    {name = "orca"   ,  "um orca", "uma orca"},
	    {name = "arara"   ,  "um arara", "uma arara"},
	    {name = "tucano"   ,  "um tucano", "uma tucano"},
	    {name = "pangolim"   ,  "um pangolim", "uma pangolim"},
	    {name = "ornitorrinco"   ,  "um ornitorrinco", "uma ornitorrinco"},
	    {name = "girafa"   ,  "um girafa", "uma girafa"},
	    {name = "doberman"   ,  "um doberman", "uma doberman", heavy=2},
	    {name = "dingo"   ,  "um dingo", "uma dingo", heavy=2},
	    {name = "canguru"   ,  "um canguru", "uma canguru"},
	    {name = "gato siames"   ,  "um gato siames", "uma gata siames"},
	    {name = "snow leopard"   ,  "um snow leopard", "uma snow leopard"},
	    {name = "lobo guará"   ,  "um lobo guará", "uma lobo guará", heavy=2},
	    {name = "canídeo generico"   ,  "um canídeo generico", "uma lobo canídeo generica", heavy=5},
	    {name = "corvo"   ,  "um corvo", "uma corvo"},

	    {name = "suricato"   ,  "um suricato", "uma suricato"},

	    {name = "hyena"   ,  "um hyena", "uma hyena"},
	    {name = "onça-pintada"   ,  "um onça-pintada", "uma onça-pintada"},
	    {name = "tigre"   ,  "um tigre", "uma tigre"},
	    {name = "pantera"   ,  "um pantera", "uma pantera"},
	    {name = "vira-lata"   ,  "um vira-lata", "uma vira-lata"},
	    {name = "guepardo"   ,  "um guepardo", "uma guepardo"},
	    {name = "urso malaio"   ,  "um urso malaio", "uma urso malaio"},
	    {name = "urso-de-oculos"   ,  "um urso-de-oculos", "uma urso-de-oculos"},
	    {name = "sun-bear"   ,  "um sun-bear", "uma sun-bear"},
	    {name = "hamster"   ,  "um hamster", "uma hamster"},
	    {name = "coelho"   ,  "um coelho", "uma coelha"},
	    {name = "capivara"   ,  "um capivara", "uma capivara"},
	    {name = "castor"   ,  "um castor", "uma castor"},
	    {name = "texugo"   ,  "um texugo", "uma texugo"},
	    {name = "esquilo"   ,  "um esquilo", "uma esquilo"},
	    {name = "opossum"   ,  "um opossum", "uma opossum"},
	    {name = "Dragão-Marinho-Folhado"   ,  "um Dragão-Marinho-Folhado", "uma Dragão-Marinho-Folhado"},

	},
	[LANG_US] = {
		{ name = "bear"     , "bear"		, "bear"},
	    {name = "wolf"      , "wolf"		, "wolf"},
	    {name = "cat"       , "cat"		, "cat"},
	    {name = "red panda" , "red panda"	, "red panda"},
	    {name = "panda"     , "panda"		, "panda"},
	    {name = "duck"      , "duck"		, "duck"},
	    {name = "dog"  		, "dog"		, "dog"},
	    {name = "dragon"    , "dragon"		, "dragon"},
	    {name = "fox"    	, "fox"		, "fox"},
	    {name = "mouse"     , "mouse"		, "mouse"},
	    {name = "lion"      , "lion"		, "lion"},
	    {name = "leopard"  	, "leopard"	, "leopard"},
	    {name = "raccoon"  	, "raccoon"	, "raccoon"},
	    {name = "deer"      , "deer"		, "deer"},
	    {name = "elk"     	, "elk"		, "elk"},
	    {name = "sergal"    , "sergal"		, "sergal"},
	    {name = "bat"   	, "bat"		, "bat"},
	    {name = "dalmatain" , "dalmatain"	, "dalmatain"},
	    {name = "ram"       , "ram"		, "ram"},
	    {name = "birb"      , "birb"		, "birb"},
	    {name = "angel dragon",  "angel dragon", "angel dragon"},
	},
}
for i,b in pairs(species[LANG_BR]) do
	if b.heavy then 
		for a=1,b.heavy do 
			species[LANG_BR][#species[LANG_BR]+1] = {name = b.name, b[1], b[2], nor=i}
		end
	end
end
local colors = {
	[LANG_BR] = {
	  "vermelha",
	  "marrom",
	  "verde",
	  "azul",
	  "cinza",
	  "branca",
	  "amarela",
	  "rosa",
	  "cinza",
	  "branco",
	  "preto",
	  "preta",
	  "marrom",
	  "escarlate",
	  {"arco-iris", true},
	  {"arco-iris", true},
	  "laranja",
	  "creme",
	  "ciano",
	  "verde marca-texto",
	  "neon",
	  "grafite",
	  "cobalto",
	  {"RGB", true},
	  "creme",
	  {"dourado", true},
	  {"prateado", true},
	  "verde claro",
	  "azul pastel",
	  "vermelho escuro",
	  {"cromado", true},
	},
	[LANG_US] = {
		"red",
	  	"brown",
	  "green",
	  "blue",
	  "gray",
	  "white",
	  "yellow",
	  "pink",
	  "dark gray",
	  "chrome",
	  "dark",
	  "black",
	  "brown",
	  "crimson",
	  "rainbow",
	  "rainbow",
	  "orange",
	  "dark green",
	  "cyan",
	  "neon",
	},
}

local quirk = {
	[LANG_BR] = {
	  "artista",  "babyfur",  "macro ",  "micro ",  "gordo",  "maluco",
	  "kinky",  "fedido",  "enfermeiro",  "bombeiro",  "cub",
	  "idoso",  "gay",  "super sexy",  "musculoso",  "musky",
	  "com 4 chifres",  "de duas cabeças",
	  "de 28 caudas",  "sabor de morango",  "hyper",  "peludo",
	  "trevoso",  "muito pistola",  "cuzão para caramba",  
	  "profissional do sequisso",  "palhaço",  "mecanico",
	  "mineiro suado",  "mago",  "guerreiro",  "arqueiro",
	  "piloto",  "que brilha",
	  "cheiroso",	  "descabelado",	  "abatido",	  "com 3 olhos",
	  "narcisista",	  "com escoliose",	  "careca",	  "com black power",
	  "zumbi",	  "de braço mecanico",	  "com medo de baratas",
	  "jardineiro",	  "cirurgião",
	  "viciado em café",	  "com medo de colheres",	  "apaixonado por guarda-chuvas",
	  "fashion",	  "que usa calças apertadas",	  "de salto alto",	  "sempre com soluço",
	  "gago",	  "de oculos",	  "de oculos de natação",	  "de fundoshi",
	  "monge",	  "vê mortos o tempo todo",	  "foda",	  "viciado em produtos da polishop",
	  "crossdresser",	  "sempre com a mão nas bola",	  "cleptomaniaco",
	  "gótico",	  "viciado em pornografia",	  "viciado em sorvete",
	  "maniaco por samambaias",	  "viciado em pole dance",	  "viciado em tatuagem",
	  "viciado em propagandas da polishop",	 
	  "viciado em tele sena",	  "fã do silvio santos",	  "fã do shrek",
	  "com heterochromia",	  "fotografo",	  "vestido de zelda",
	  "vestido de link",
	  "com boca na barriga",
	  "açogueiro", "vai aos meets sem passar desodorante",
	  "gari", "com um neckfloof enorme", "viciado em bolo", "usa bolsa de colostomia por hobbie", "de fralda",
	  "gordinho"
	},
	[LANG_US] = {
		"is artist", "is ababyfur", "is a macro ",  "is a micro ", "is fat", "is crazy",
		"is kinky", "is stinky", "is a nurse", "is a firefigther", "is a cub",
		"is old", "is gay", "is a super sexy", "is a bara", "is musky",
		"have studied in Furry High", "have with 4 horns", "is two headed",
		"have 28 tails", "taste like strawberry", "is a hyper", "is a super furry",
		"is a dark emo", "is always angry at anything", "is an asshole",
		"is a hooker", "is silly", "is a mechanic", "is a sweaty miner", "is a wizard",
		"is a sorcerer", "is an archer", "is a pilot", "is something that glows",
	},

}

local whatLikes = {
	[LANG_BR] = {
	  "mergulho",  "bolo",  "vore",  "gore",  "yiffar pra caralho",  "fazer drama",
	  "fazer drama",  "abraço",  "fazer amigos",  "usar fraldas",  "fazer coisas kinky",
	  "noticear bulges",  "dar porrada em todo mundo",  "brincar",  "uva passa",
	  "ficar no pc",  "jogar",    "minecraft",  "pornografia",  "musica",  
	  "culinaria",    "vasectomia",    "quebra cabeça",    "festa",    "carros",  
	  "aviões",    "refirgerante",    "ficar hidratado",    "suco",    "comer",  
	  "comer muito",    "inflation",    "babyfur",    "bdsm",    "conversar",  
	  "paws",    "caçar mafafagos",  "lamber patas",  "defender os mais fracos",
	  "detestar uva passa no arroz",  "chocotone",  "frutas cristalizadas",
	  "cheirar os outros no ônibus",  "coisas que brilham",    "computador",  
	  "tecnologia",  "coisas coloridas",    "bolos",  "comprar comission toda semana",
	  "chupetas",  "chicotes",  "biscoito",  "transformadores",  "internet",
	  "fazer rp",  "fazer muito rp",  "owo",  "fazer crossfit",  "pixel art",
	  "ketchup na pizza",  "purê no hotdog",  "chilli dogs",
	  "tirar selfie com efeito",  "uva passa no arroz",  "açaí",
	  "pichar paredes a meia noite",  "fazer vídeos pro YouTube",  "vender quentão na porta do metrô",
	  "biscoito de champagne", "vorear quem vê pela frente", "cafuné", "discutir biscoito x bolacha",
	  "eletronica", "programar", "fazer programa", "esportes aquaticos", "cheetos",
	  "ler HQs", 	  "netflix", 	  "miojo", 	  "banir yiff", 	  "size difference", 
	  "pintar as unhas dos pés", 	  "criticar fetiches", 	  "fazer awoo", 	  "falar que é melhor que os outros por que mora no japão", 
	  "assitir zootopia", 	  "acessar o e621", 	  "ler doujinshi", 	  "sair do fandom", 
	  "competir quem é mais miseravel", 	  "encher o saco", 	  "fazer piada ruim", 	  "assistir speedruns o dia inteiro", 
	  "musky husky", 	  "chulé", 	  "banho de lama", 
	  "perder os calçados na lama", 	  "pistolar e meter o louco", 
	  "finger ser edgy", 	  "usar maconha", 	  "suco de beterraba com açafrão", 
	  "faltar aos meets", 	  "jogar skyrim", 	  "criar evento", 
	  "fursuit sem manga", 	  "inflation", 	  "dobradiças de porta", 
	  "webnamorar", 	  "traição", 	  "funk", 
	  "rock", 	  "falar que morou em dubai", 	  "comer no giraffas", 
	  "se gabar", 
	  "FaLaR aSsIm", "fraldas", "chupetas", "p1r0k45", "ver YTP",
	  "igreja universal", 
	  "assitir felipe neto", 
	  "unicornios", "apoiar o bonoro", "abdl",
	  "poneis", 
	  "front-end", 
	  "back-end", 
	  "conversar só com sticker", 
	  "achar que toda indireta é pra ele", 
	  "polyamor", 
	  "derrubar governos", "destruir o capitalismo", "bolo", "chuva dourada",

	},
	[LANG_US] = {
	  "scuba diving", "cake", "vore", "gore", "yiff all the time", "drama",
	  "lots of drama", "hugs", "make new freinds", "fat furs", "kinky stuff",
	  "notice bulges", "puch evebody", "play", "rainsins",
	  "stay on pc all day", "play games", "minecraft", "porn", "music", "diapers", "pacifiers", "big dildos",
	  "culinary", "vasectomy", "puzzles", "parties", "cars", 
	  "planes", "soda", "stay hydrated", "juice", "eat", "say 'no u' to others",
	  "eat a lot", "inflation", "babyfurs", "bdsm", "chat", 
	  "paws", "bake cake", "lick paws", "defend the weak", "sieze the means of production", "chocolate pudding", "crystalized fruits", 
	  "snif musky huskies", "shiny things", "computers", "technology", "cakes", "buy comissions every week", "weed", 
	  "pacifiers", "whips", "transformers", "internet", "rp", "lots of rp", "ketchup on pizza",
	},
}

local sonho = {
	[LANG_BR] = {
	  "ser o maior popfur do fandom",
	  "vingar seus pais assassinados por um demônio quando ele era pequeno",
	  "ser acionista majoritário da Bad Dragon",
	  "comer cu de curioso",
	  "ganhar na Mega-Sena",
	  "pular de pára-quedas",
	  "ser o maior mestre Pokémon",
	  "provar que Digimon é melhor que Pokémon",
	  "fazer um perfeito bolo de chocolate com mortadela",
	  "ir em uma furcon",
	  "meter o loco e pistolar",
	  "aprender a voar",
	  "ir pra lua",
	  "ser popfur",
	  "fazer vore todo dia",
	  "ser um macro mas ele é um micro", 
	  "ser bara mas é magrinho",
	  "ser vorado",
	  "achar um sugar daddy",
	  "virar seu fursona",
	  "ser pisoteado",
	  "ter um armario cheio de BDs",
	  "ir no programa do silvio santos",
	  "ganhar um playstation 2 do Yudi",
	  "ganhar o master chef",
	  "conhecer o faustão",
  	},
  	[LANG_US] = {
  		"be the biggest popfur in the fandom",
	  	"avenge his parents who died by a demon during his childhoold",
	  "have a Bad Dragon",
	  "be its fursona in real life",
	  "win the lottery",

	  "be the master Pokémon",
	  "prove that Digimon is better than Pokemon",
	  "bake a chocolate cake",
	  "go in a furcon",
	  "learn to fly",
	  "be a popfur",
	  "do vore every day",
	},
}

function bernoulliNumber(chance)
  local mutations = 0
  while(math.random(0, 1000) < chance) do
      mutations = mutations +1
  end
  return mutations
end

function formatTabless(t, f) 
	
  local str = ""
  for i=1,#t do 

    str = str ..(f and f(t[i]) or t[i])..(i == #t and "" or (i == #t-1 and tr(" e ") or ", "))
  end
  return str
end



function selectSome(tab, amount)
  local found = {}
  local tt = {}
  for i=1,amount do 
    local num
    local maxN = 0
    repeat 
      num = math.random(1, #tab)
      maxN = maxN+1
      if maxN > 100 then 
      	break
      end
    until not found[num] and (type(tab[num]) == 'table' and not found[tab[num].nor or 0])
    found[num] = true
    if type(tab[num]) == 'table' and (tab[num][2] == true) then 
   
    	return {tab[num][1]}
    end

    tt[#tt+1] = tab[num]
  end
  return tt
end

function selNames(t) 
  local t2 = {}
  for i,b in pairs(t) do 
    t2[i] = b.name
  end
  return t2
end
function upperFirst(st)
	return st:sub(1,1):upper()..st:sub(2, #st)
end

function OnCommand(user, msg, args)
  local to = user.from.username
  if args[2] and args[2]:len() > 1 then 
	    args[2] = args[2]:gsub("@",""):lower()
	    if not users[args[2]] and not tonumber(args[2]) then 
	        if args[2] ~= "status" then
	            say("Who is "..args[2].."?")
	            return 
	        end
	    else 
	        to = args[2]
	        args[2] = args[3]
	        args[3] = nil
	    end
	    
    end 
  local seed = os.time()
  math.randomseed(seed)
  local tries = 0
  

  say(tr("Gerando proceduralmente um fursona")..((to ~= "") and ( tonumber(to) and tr(" usando a seed ")..to or tr(" para o @")..to) or "")..".")
  
  
  local name 
  local nc = math.min(bernoulliNumber(200) + 1,2)
  local two = selectSome(kekName[g_lang], 4)

  local useKek = math.random(0,1000) <= 600
  local kekWhere = 0
  if useKek then 
  	kekWhere = math.random(1,2)
  end

  name = (kekWhere == 1 and upperFirst(two[1]..two[2]) or sugested()) .. " " .. ((kekWhere == 2 or math.random(0, 1000) < 100) and upperFirst(two[3]..two[4]) or sugested())

  

  local str = tr("O fursona se chama ")
  local sex = math.random(0,1000) <= 500 and 1 or 2
  local elea = tr(sex == 1 and "ele" or "ela")
  local especie = math.random(1, #species[g_lang])

  str = str .. ""..name.."" .. ", "..elea..tr(" é ")

  if g_lang == LANG_US then 

	
	  local cols = ""
	  if math.random(0,1000) <= 600 then 
	  	
	    local count = bernoulliNumber(400) + 1
	    local tt = selectSome(colors[g_lang], count)

	    cols = cols..formatTabless(tt) 
	  end
	  str = str..cols
	  
	  
	 
	  local kek = false
	  if math.random(0,1000) <= 300 then 
	  		str = str .." mix of "
	  		kek = true
	    local count = bernoulliNumber(200) + 2
	    local tt = selectSome(selNames(species[g_lang]), count)
	    str = str..formatTabless(tt) 
	  else 
	    str = str .." "..species[g_lang][especie][sex]
	  end

	  --quirk
	
	  if math.random(0,1000) <= 800 then 
	    local tt = selectSome(quirk[g_lang], bernoulliNumber(80)+1)
	    if kek then
	    	str = str.. ", also "..elea.." " ..formatTabless(tt)..""
	    else
	   	 str = str.. " and is " ..formatTabless(tt)..""
	   	end
	  end


	  

  else 
	  	--Especie
	  
	  local isMix = math.random(0,1000) <= 300
	  if isMix then 
	    str = str ..tr("um misto de ")
	    local count = bernoulliNumber(200) + 2
	    local tt = selectSome(selNames(species[g_lang]), count)
	    str = str..formatTabless(tt) 
	  else 
	    str = str ..species[g_lang][especie][sex]
	  end
	
	  --quirk
	  if not isMix then
		  if math.random(0,1000) <= 800 then 
		    local tt = selectSome(quirk[g_lang], bernoulliNumber(80)+1)
		    str = str.. " " ..formatTabless(tt,   (function (word) return word:sub(#word, #word) == "o" and (word:sub(1, #word-1)..(sex == 1 and "o" or "a")) or word end)  ) ..""
		  end
	  end
	
	  --color
	  if math.random(0,1000) <= 600 then 
	    local count = bernoulliNumber(400) + 1
	    local tt = selectSome(colors[g_lang], count)
	   
	    str = str .. tr(" de cor"..(#tt > 1 and "es" or "").." ")
	    str = str..formatTabless(tt) 
	  end
  end


  
  --what likes
  local count = bernoulliNumber(600) + 1
  local tt = selectSome(whatLikes[g_lang], count)
  str = str.. ". "..(elea:sub(1,1):upper()..elea:sub(2,-1))..tr(" gosta de ")..formatTabless(tt)..""

  if math.random(0,1000) <= 200 then 
    str = str.. tr(" e o seu sonho é ")..sonho[g_lang][math.random(1, #sonho[g_lang])]
  end
  str = str .. "."
  
	deploy_sendMessage(g_chatid,str..(tonumber(to) and "" or "\n\nSeed: "..seed))
end
