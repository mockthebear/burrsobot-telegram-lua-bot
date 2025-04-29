

function OnCommand(msg, text, args)
	local word = args[2]
	if not word or word == "" then 
		reply("Use assim: /defina palavra")
		return
	end

	word = word:lower()

	word =  dictionary.stripChars(word)

  local success, mode, res = dictionary.getDefinition(word) 

  if not success then 
    if mode == 0 then 
      reply("Palavra '"..word.."' não encontrada")
    else 
      reply("Internal error")
    end
  else
    reply.html(res)
  end
      	
end