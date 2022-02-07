function OnCommand(msg, text, args, targetChat, vaarg)
    if #args == 0 then 
        reply("Missing param")
        return
    end

    local textNoCommand = cutCommand(text)

    local nmin = tonumber(os.date("%M"))
    local nhour = tonumber(os.date("%H"))
    local nday = tonumber(os.date("%d"))
    local nyear = tonumber(os.date("%y"))
    local nmonth = tonumber(os.date("%m"))

    if args[2] == "at" or args[2] == "as" then 
        if args[2] == "at" then
            textNoCommand = textNoCommand:gsub("at", "", 1)
        else 
            textNoCommand = textNoCommand:gsub("as", "", 1)
        end
        local head, day,month,year = textNoCommand:match("((%d+)/(%d+)/(%d+))")

        local tail, hour, min = textNoCommand:match("((%d+):(%d+))")
        if not hour and not day then 
            reply(tr("scheduler-timer-how"))
            return
        end
        if head then
            textNoCommand = textNoCommand:gsub(head, "", 1)
        end
        if tail then
            textNoCommand = textNoCommand:gsub(tail, "", 1)
        end


        day = tonumber(day) or nday
        month = tonumber(month) or nmonth
        year = tonumber(year) or nyear
        hour = tonumber(hour) or nhour
        min = tonumber(min) or nmin


        if year < nyear or month > 12 or day > 31 or hour > 23 or min > 59 then 
            reply("hahaha. no.")
            return
        end

        local ts = os.time({day=day,month=month,year=year,hour=hour,min=min,sec=0})

        local diff = ts-os.time()
        if diff <= 0 then     
            reply.html( tr("scheduler-timer-past", scheduler.pastDate(ts, os.time()) ))
            return
        end

        reply.html( tr("scheduler-timer-set", os.date("%d/%m/%y %H:%M", ts),  scheduler.pastDate(ts, os.time()), textNoCommand:gsub("^%s*", "") ) )

        scheduler.tasks[os.time()] = {mode="at", timestamp=ts, chat=msg.chat.id, from=msg.from.id, msg=textNoCommand:htmlFix():gsub("^%s*", ""), diff=diff, message_id=msg.message_id}
        scheduler.save()
    elseif args[2] == "in" or args[2] == "em" or args[2] == "every" or args[2] == "cada" then
        local mode = "at"
        if args[2] == "in" then
            textNoCommand = textNoCommand:gsub("in", "", 1)
        elseif args[2] == "every" then
            mode = "every"
            textNoCommand = textNoCommand:gsub("every", "", 1)
        elseif args[2] == "cada" then
            mode = "every"
            textNoCommand = textNoCommand:gsub("cada", "", 1)
        else 
            textNoCommand = textNoCommand:gsub("em", "", 1)
        end



        local lookUps = {
            ['scheduler-minute']=60,
            ['scheduler-hour']=3600,
            ['scheduler-day']=3600*24,
            ['scheduler-month']=3600*24*30,
            ['scheduler-year']=3600*24*365,
        }

        local extraTs = 0

        for i,b in pairs(lookUps) do 
            local aux, count = textNoCommand:match("((%d+) "..tr(i).."s?)")
            if aux then
                if count then 
                    extraTs = extraTs + tonumber(count)*b
                end
                textNoCommand = textNoCommand:gsub(aux, "", 1)
            end
        end
        if extraTs == 0 then
            reply(tr("scheduler-timer-how"))
            return
        end
        local ts = os.time()+extraTs
        reply.html( tr("scheduler-timer-set", os.date("%d/%m/%y %H:%M", ts),  scheduler.pastDate(ts, os.time()), textNoCommand:gsub("^%s*", "") ) )

        scheduler.tasks[os.time()] = {mode=mode, timestamp=ts, chat=msg.chat.id, from=msg.from.id, msg=textNoCommand:htmlFix():gsub("^%s*", ""), diff=extraTs, message_id=msg.message_id}
        scheduler.save()
    else
        reply(tr("scheduler-timer-how"))
    end 
    
end