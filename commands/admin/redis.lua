function OnCommand(msg, text, args)
	local s = g_redis[args[2]]
	reply("Query: "..args[2]:upper().." "..cjson.encode({args[3], args[4], args[5], args[6], args[7]}))
	say.big_mono(
	 	Dump(
	 			{
	 				s(g_redis, args[3], args[4], args[5], args[6], args[7])
	 			}
	 		)
	 	)
	 
end

