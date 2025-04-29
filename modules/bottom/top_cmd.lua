function OnCommand(user, msg, args)
    if chats[user.chat.id] then 
        local gusers = g_redis:keys("user:*")

        g_redis:init_pipeline()
        for a,c in pairs(gusers) do 
            g_redis:hget(c, 'joinDate')
        end

        local onList = {}
        local res =  g_redis:commit_pipeline()
        for a,c in pairs(res) do  
            if type(c) == 'string' then
                local succ, meme = pcall(cjson.decode,c)
                if succ then 
                    if type(meme) == 'table' and meme["___"..user.chat.id] then 
                        onList[#onList+1] = gusers[a]
                    end
                else
                    g_redis:hdel(gusers[a], 'joinDate')
                    print('Inconsistency on '..gusers[a])
                end
            end
        end

        local ppl = 0
        local rank = {}
        for a,c in pairs(onList) do 
            local id = c:match("user:(%d+)")
            if id then 
                local bottomLevel = g_redis:hget(c, 'bottom_score') or 0
                bottomLevel = tonumber(bottomLevel) or 0

                ppl = ppl+1
                if bottomLevel < 0 then 
                    rank[#rank+1] = {bottomLevel, getUserById(id).first_name}

                end
            end
        end
        
        function compare(a,b)
          return a[1] < b[1]
        end

        table.sort(rank, compare)
        local ranking = ""
        for a=1, math.min(#rank, 10) do 
            ranking = ranking .. "<b>".. rank[a][2] .. "</b> - ".. (rank[a][1]*-1)..'\n'
        end


        reply.html(tr("bottom-top-top")..ranking)

    else 
        reply("For chats only")
    end
end