function OnCommand(user, msg, args)
    local mem = collectgarbage("count")*1024
    local bytes = math.floor(mem/10000)
    reply("Memmory use: "..bytes.." MB")
end

