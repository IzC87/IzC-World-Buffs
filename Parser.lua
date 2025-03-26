-- Globals Section
local addonName, L = ...;

function IzC_WB:ParsePost(post)
    local buffAdded = false;

    local buffDate = nil
    local lastBuff = nil
    local lastFaction = nil

    local lines = {}
    local getDate = false
    for line in post:gmatch("[^\r\n]+") do
        -- PreAdd Buff, this is to cover cases where the post is made with the @buff last.
        if (not lastBuff) then
            lastBuff = IzC_WB:GetBuff(line, nil)
        end
        -- PreAdd Faction, this is to cover cases where the post is made with the @Faction last.
        if (not lastFaction) then
            lastFaction = IzC_WB:GetFaction(line, nil)
        end
        -- PreAdd BuffDate, this is to cover cases where the post is made with the @BuffDate last.
        if (getDate == true and not buffDate) then
            buffDate = IzC_WB:GetDate(line, nil)
        end

        table.insert(lines, line)
        getDate = true;
    end

    for i = 2, #lines do
        local line = lines[i]

        lastBuff = IzC_WB:GetBuff(line, lastBuff);
        lastFaction = IzC_WB:GetFaction(line, lastFaction);
        buffDate = IzC_WB:GetDate(line, buffDate);

        local success = IzC_WB:CheckLineForTimeAndAddToTable(line, lastBuff, lastFaction, buffDate, post)
        if (buffAdded == false) then
            buffAdded = success;
        end
    end

    -- No datetime found in post.
    if not buffDate and lines[1] then
        -- On first line we need to find a timestamp but no DateTime. Because then it's an older post.
        if lines[1]:find("— %d%d?:%d%d") and not lines[1]:find("(%d%d)[%./%-](%d%d)[%./%-](%d%d%d%d)") then
            buffDate = { year=tonumber(date("%Y")), month=tonumber(date("%m")), day=tonumber(date("%d")) }
        else
            -- Pretending like a buff was added because we couldn't find a date and the post was made before today so it's likely old.
            buffAdded = true;
        end

        if (buffDate) then
            for i = #lines, 2, -1 do
                local line = lines[i]
                local success = IzC_WB:CheckLineForTimeAndAddToTable(line, lastBuff, lastFaction, buffDate, post)
                if (buffAdded == false) then
                    buffAdded = success;
                end
            end
        end
    end
    
    -- If no matches, print the post for debugging
    if buffAdded == false then
        -- IzC_WB:PrintDebug("⚠ No matches found in post:\n" .. post)
        print("-----------------");
        print("Unable to parse post:");
        print("-----------------");
        print(post);
        print(lastBuff);
        print(lastFaction);
        print(buffDate);
    end
end

function IzC_WB:GetDate(line, lastDate)
    local day, month, year = line:match("(%d%d?)[%./%-](%d%d?)[%./%-](%d%d%d%d)")
    if day and month and year then
        return { year=tonumber(year), month=tonumber(month), day=tonumber(day) }
    else
        day, month = line:match(" (%d%d?)[%./%-](%d%d?) ")
        if (day and month and (tonumber(day) >= 1 and tonumber(day) <= 31 and tonumber(month) >= 1 and tonumber(month) <= 12)) then
            return { year=tonumber(date("%Y")), month=tonumber(month), day=tonumber(day) }
        end
    end
    
    return lastDate
end

function IzC_WB:GetFaction(line, lastFaction)
    -- local faction = line:match("(%f[%a]Alliance%f[%A])") or line:match("(%f[%a]Horde%f[%A])") or line:match("(%f[%a]RendBuff%f[%A])")
    local faction = line:match("(%f[%a]Alliance%f[%A])") or line:match("(%f[%a]Horde%f[%A])") or line:match("(%f[%a]RendBuff%f[%A])")
    if faction then
        return faction;
    end
    return lastFaction;
end

function IzC_WB:GetBuff(line, lastBuff)
    local buff = line:match("@(%w+)")
    if buff then
        return buff;
    end
    return lastBuff;
end

function IzC_WB:CheckLineForTimeAndAddToTable(line, buffTag, faction, buffDate, rawPost)
    local result = false;

    if not buffTag then
        IzC_WB:PrintDebug("No BuffTag Found: \n"..rawPost);
        return result;
    end
    if not faction then
        IzC_WB:PrintDebug("No Faction Found: \n"..rawPost);
        IzC_WB:PrintDebug(tostring(faction));
        return result;
    end
    if not buffDate then
        IzC_WB:PrintDebug("No BuffDate Found: \n"..rawPost);
        return result;
    end

    -- Match times like 19.40
    for timeStr in line:gmatch("(%d%d[%.:]%d%d)") do
        local s, e = line:find(timeStr, 1, true)
        local nextChar = line:sub(e + 1, e + 5)

        if nextChar == "" or not nextChar:match("^[%.:]%d%d%d%d$") then
            timeStr = timeStr:gsub("%.", ":")
            local hour, minute = strsplit(":", timeStr, 2)
            result = IzC_WB:TryAddBuff(buffTag, faction, buffDate, { hour = hour, minute = minute}, rawPost)
        end
    end
    for pre, timeStr in line:gmatch("([^%d/%.%-])(%d%d%d%d)%f[%D]") do
        if tonumber(timeStr) < 2400 then
            result = IzC_WB:TryAddBuff(buffTag, faction, buffDate, { hour = timeStr:sub(1, 2), minute = timeStr:sub(3, 4)}, rawPost)
        end
    end

    return result;
end

function IzC_WB:TryAddBuff(buffTag, faction, buffDate, buffTime, rawPost)
    if (not buffDate.year or not buffDate.month or not buffDate.day) then
        IzC_WB:PrintDebug("Date is wrong!: \n"..tostring(buffDate.year).."/"..tostring(buffDate.month).."/"..tostring(buffDate.day));
        -- print("Date is wrong!: \n"..tostring(buffDate.year).."/"..tostring(buffDate.month).."/"..tostring(buffDate.day));
        return false;
    end

    local timeStamp = time(
        {
            year = tonumber(buffDate.year),
            month = tonumber(buffDate.month),
            day = tonumber(buffDate.day),
            hour = tonumber(buffTime.hour),
            min = tonumber(buffTime.minute),
        })

    local buffAdded = IzC_WB:AddBuff(buffTag, faction, timeStamp, rawPost);

    if buffAdded then
        IzC_WB.Sender:SendBuff(buffAdded)
    end

    return true;
end

function IzC_WB:AddBuff(buffTag, faction, timeStamp, rawPost)
    if timeStamp < IzC_WB:GetDateShiftedByDay(-3) then
        IzC_WB:PrintDebug(buffTag.." too old:")
        IzC_WB:PrintDebug("rawPost")
        return nil;
    end

    local isAlliance = (faction == "Alliance")
    local factionString = "Horde";
    if isAlliance then
        factionString = "Alliance"
    end

    local buffToAdd = {
        Buff = buffTag,
        Alliance = isAlliance,
        Faction = factionString,
        Time = timeStamp,
        SendBuffChecker = true,
        RawPost = rawPost
    }

    local key = IzC_WB:GetKeyForBuff(buffToAdd);

    if (IzCBuffs[key]) then
        IzC_WB:PrintDebug("Buff already exists.\n"..key)
        return nil;
    end

    IzCBuffs[key] = buffToAdd;

    return buffToAdd;
end

function IzC_WB:SortBuffsByTime()
    local buffs = {}

    for key,buff in pairs(IzCBuffs) do
      table.insert(buffs, buff)
    end
  
    table.sort(buffs, function(a, b)
        return a.Time < b.Time
    end)
  
    return buffs
end

function IzC_WB:GetKeyForBuff(buff)
    return buff.Buff..tostring(buff.Alliance)..buff.Time
end

function IzC_WB:SplitIntoPosts(raw)
    local posts = {}
    local currentPost = {}
    
    for line in raw:gmatch("[^\r\n]+") do
        if line:match("^<.->.-%s+—%s+") then
            -- New post starts
            if #currentPost > 0 then
                table.insert(posts, table.concat(currentPost, "\n"))
                currentPost = {}
            end
        end
        table.insert(currentPost, line)
    end

    -- Add last block if it exists
    if #currentPost > 0 then
        table.insert(posts, table.concat(currentPost, "\n"))
    end

    return posts
end

function IzC_WB:ProcessRawInput(rawInput)
    if (not rawInput or rawInput == "") then
        return;
    end

    local posts = IzC_WB:SplitIntoPosts(rawInput)

    for i, post in ipairs(posts) do
        IzC_WB:ParsePost(post)
    end
end

function IzC_WB:GetDateShiftedByDay(dayOffset)
    return IzC_WB:GetDateShiftedByHour(dayOffset * 24)
end

function IzC_WB:GetDateShiftedByHour(hourOffset)
    return time() + (hourOffset * 3600)
end
