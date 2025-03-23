-- Globals Section
local addonName, L = ...;

-- Create a frame to handle events
IzC_WB = CreateFrame("Frame", "IzCAutoConsumables_IzC_WB");
IzC_WB:SetScript("OnEvent", function(self, event, ...) IzC_WB:EventHandler(event, ...); end);

-- register events
IzC_WB:RegisterEvent("BAG_UPDATE");
IzC_WB:RegisterEvent("ADDON_LOADED");

IzCWorldBuffs_SavedVars = {}
IzCBuffs = {}

function IzC_WB:ParsePost(post)
    local result = {}

    local buffDate = nil
    local lastBuff = nil
    local lastFaction = nil

    local lines = {}
    for line in post:gmatch("[^\r\n]+") do
        table.insert(lines, line)
    end

    for i = 2, #lines do
        local line = lines[i]

        local buff = line:match("@(%w+)")
        if buff then
            lastBuff = buff
        end

        local faction = line:match("(%f[%a]Alliance%f[%A])") or line:match("(%f[%a]Horde%f[%A])")
        if faction then
            faction = faction:gsub("%s+", "")
            lastFaction = faction
        end

        local day, month, year = line:match("(%d%d)[%./%-](%d%d)[%./%-](%d%d%d%d)")
        if day and month and year then
            buffDate = { year=tonumber(year), month=tonumber(month), day=tonumber(day) }
            -- /script print(time().." - "..(time({year=2025, month=3, day=23, hour=7, min=58})))
            -- buffDate = string.format("%04d/%02d/%02d", tonumber(y), tonumber(m), tonumber(d))
        else
            -- print(post)
            -- d, m = line:match("(%d%d)[%./%-](%d%d)")
            -- if d and m then
            --     print(1)
            --     local t = time()
            --     local dateObject = date("*t", t)
            --     buffDate = string.format("%04d/%02d/%02d", tonumber(y), tonumber(m), tonumber(d.year))
            -- end
        end

        result = IzC_WB:CheckLineForTimeAndAddToTable(line, lastBuff, lastFaction, buffDate, post, result)
    end

    -- No datetime found in post.
    if not buffDate and lines[1] then
        -- On first line we need to find a timestamp but no DateTime. Because then it's an older post.
        if lines[1]:find("%d%d:%d%d") and not lines[1]:find("(%d%d)[%./%-](%d%d)[%./%-](%d%d%d%d)") then
            buffDate = date()
        end

        for i = #lines, 2, -1 do
            local line = lines[i]
            result = IzC_WB:CheckLineForTimeAndAddToTable(line, lastBuff, lastFaction, buffDate, post, result)
        end
    end

    -- If no matches, print the post for debugging
    if #result == 0 then
        print("⚠ No matches found in post:\n" .. post)
    end

    return result
end

function IzC_WB:CheckLineForTimeAndAddToTable(line, buffTag, faction, buffDate, rawPost, buffTable)
    if not buffTag then
        IzC_WB:PrintDebug("No BuffTag Found: \n"..rawPost);
        return;
    end
    if not faction then
        IzC_WB:PrintDebug("No Faction Found: \n"..rawPost);
        return;
    end
    if not buffDate then
        IzC_WB:PrintDebug("No BuffDate Found: \n"..rawPost);
        return;
    end

    for timeStr in line:gmatch("(%d%d:%d%d)") do
        if buffTag and buffDate then
            table.insert(buffTable, {
                Buff = buffTag,
                Alliance = (faction == "Alliance"),
                Date = buffDate,
                Time = timeStr,
                RawPost = rawPost
            })
        end
    end

    -- Match times like 19.40
    for timeStr in line:gmatch("(%d%d%.%d%d)") do
        if buffTag and buffDate then
            local formatted = timeStr:gsub("%.", ":")
            table.insert(buffTable, {
                Buff = buffTag,
                Alliance = (faction == "Alliance"),
                Date = buffDate,
                Time = formatted,
                RawPost = rawPost
            })
        end
    end

    for pre, timeStr in line:gmatch("([^%d/%.%-])(%d%d%d%d)%f[%D]") do
        if tonumber(timeStr) < 2400 and buffTag and buffDate then
            local formatted = timeStr:sub(1, 2) .. ":" .. timeStr:sub(3, 4)
            table.insert(buffTable, {
                Buff = buffTag,
                Alliance = (faction == "Alliance"),
                Date = buffDate,
                Time = formatted,
                RawPost = rawPost
            })
        end
    end



    
    return buffTable;
end

function IzC_WB:AddBuff(buffTable, buffTag, faction, buffDate, buffTime, rawPost)
    table.insert(buffTable, {
        Buff = buffTag,
        Alliance = (faction == "Alliance"),
        Time = time(
            {
                year = buffDate.year,
                month = buffDate.month,
                day = buffDate.day,
                hour = buffTime.hour,
                minute = buffTime.minute,
            }),
        RawPost = rawPost
    })
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

    local allBuffs = {}

    for i, post in ipairs(posts) do
        local parsed = IzC_WB:ParsePost(post)
        for _, entry in ipairs(parsed) do
            table.insert(allBuffs, entry)
        end
    end

    -- Debug print
    -- for _, b in ipairs(allBuffs) do
    --     print(("{ Buff = %s, Alliance = %s, Date = %s, Time = %s }"):format(
    --         b.Buff, tostring(b.Alliance), b.Date, b.Time
    --     ))
    -- end

    for _, b in ipairs(allBuffs) do


        table.insert(IzCBuffs, b)
    end
end

function IzC_WB:GetDateShifted(hourOffset)
    -- local t = time() + (dayOffset * 86400) -- For days
    local t = time() + (hourOffset * 3600)
    local d = date("*t", t)
    return string.format("%02d/%02d/%04d - %02d:%02d", d.day, d.month, d.year, t.hour, t.minute)
end

function IzC_WB:PrintDebug(message)
    if IzCWorldBuffs_SavedVars.IzC_IWB_Debug == true then
        DEFAULT_CHAT_FRAME:AddMessage(message);
    end
end




-----------------------
---- Event Handler ----
-----------------------
function IzC_WB:EventHandler(event, arg1, ...)

    if (event == "ADDON_LOADED") then
        if (arg1 == addonName) then

            IzCWorldBuffs_SavedVars = setmetatable(IzCWorldBuffs_SavedVars or {}, { __index = IzCWorldBuffs_Defaults })
            IzCBuffs = setmetatable(IzCBuffs or {}, { __index = {} })



            IzCBuffs = {}



            IzC_WB:TryUnregisterEvent("ADDON_LOADED");
            IzC_WB:CreateSettings();
            IzC_WB:RegisterMiniMap();

local input = [[<Watch Threat> Movie — 20/03/2025 15:59
<Watch Threat>
@Onyxia Horde - 20/3 ~19.40
<RoT> Crux — 20/03/2025 16:05
<Reign of  Terror>
@Onyxia Alliance  at ~18:30
<Requiem> Grime — 20/03/2025 17:40
<Requiem>
@Onyxia Horde - 21/03/2025, 19:00ST
<BALAST> Flubberfett — 20/03/2025 19:41
@Onyxia Alliance Going to swap our 22:00 ST buff today to 22:35 to be safe for layers - SHOULD be a guaranteed drop - If it doesn't drop don’t wisper me because I don't care if you don't have ony buff for your deadmines 
<DSLFS>Eddíemeduza — 20/03/2025 21:11
<Den som lever får se>
@Onyxia Alliance 21/03/2025 - 18:00 ST
<Unmedicated> Grompy — Yesterday at 00:14
<Unmedicated>
21/03/2025
@Onyxia Horde 22:30
<Prepared>Lake — Yesterday at 16:04
<Prepared>
@Onyxia Alliance   22/03/2025 - 12:00 ST
<Watch Threat> Movie — Yesterday at 21:58
<Watch Threat>
@Onyxia Horde - 22/03/2025~21.00
<HADES> Trazou — Yesterday at 22:52
<HADES> @Onyxia Horde 
22/03/2025
00:00 
14:00

23/03/2025
14:00
23:30
<God of War> Kratós — 06:54
<God of War>
@Onyxia Alliance - 23.03.2025 - 17:30 ST
<Victory> Cowfather — 08:28
23/03/2025 - SUNDAY

<Victory> will pop @RendBuff - 1400
<Victory> will pop @Onyxia Horde - 1400
<Victory> will pop @RendBuff - 1701
<Victory> will pop @RendBuff - 2002
<Victory> will pop @Onyxia Horde - 2002
]]


    IzC_WB:ProcessRawInput(input)

            return;
        end
    end

    IzC_WB:PrintDebug(event)
end

function IzC_WB:TryRegisterEvent(event)
    IzC_WB:PrintDebug("Trying to Register Event: "..event)
    if IzC_WB:IsEventRegistered(event) then
        return
    end

    IzC_WB:PrintDebug("Register Event: "..event)
    IzC_WB:RegisterEvent(event);
end

function IzC_WB:TryUnregisterEvent(event)
    IzC_WB:PrintDebug("Trying to Unregister Event: "..event)
    if IzC_WB:IsEventRegistered(event) then
        IzC_WB:PrintDebug("Unregister Event: "..event)
        IzC_WB:UnregisterEvent(event);
    end
end











----------------------
--      Options     --
----------------------
function IzC_WB:CreateSettings()
    local category, layout = Settings.RegisterVerticalLayoutCategory("IzC World Buffs")

    -- local MainCategory, _ = Settings.RegisterVerticalLayoutSubcategory(category, "Prio");
    -- local MacrosCategory, _ = Settings.RegisterVerticalLayoutSubcategory(category, "Macros");
    local debugCategory, _ = Settings.RegisterVerticalLayoutSubcategory(category, "Debug");

    local function CreateCheckBox(variable, name, tooltip, category, defaultValue)
        local function GetValue()
            return IzCWorldBuffs_SavedVars[variable] or defaultValue
        end

        local function SetValue(value)
            IzC_WB:PrintDebug("Setting "..variable.." changed to: "..tostring(value));
            IzCWorldBuffs_SavedVars[variable] = value;
            IzC_WB:UpdateMacros();
        end

        local setting = Settings.RegisterProxySetting(category, variable, type(false), name, defaultValue, GetValue, SetValue)

        Settings.CreateCheckbox(category, setting, tooltip)
    end

    StaticPopupDialogs.RawInput = {
        text = "Copy paste from Discord",
        button1 = OKAY,
        button2 = CANCEL,
        OnAccept = function(self)
            local input = self.editBox:GetText()
            IzC_WB:ProcessRawInput(input)
        end,
        hasEditBox = 1,
    }

    do
        do
            local function OnButtonClick()
                StaticPopup_Show("RawInput")
            end

            local initializer = CreateSettingsButtonInitializer("Raw Input", "Add", OnButtonClick, "Click button to add input for World Buffs", true);
            layout:AddInitializer(initializer);
        end

        CreateCheckBox("IzC_IWB_Debug", "Debug Mode", "Print debug statements?", debugCategory, false)
    end

    Settings.RegisterAddOnCategory(category)
end

IzCWorldBuffs_Defaults = {
    ["IzC_IWB_Debug"] = false,
    ["Buffs"] = {},
    ["Minimap"] = {},
    ["ShowTooltip"] = true
}
