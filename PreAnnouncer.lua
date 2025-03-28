-- Globals Section
local addonName, L = ...;

IzC_WB.Announce = false;

function IzC_WB:PreAnnounceBuffs()
    if (IzC_WB.Announce == false) then
        return;
    end

    for key,buff in pairs(IzCBuffs) do
        if (IzC_WB:ShowBuff(buff) == true) then
            IzC_WB:PreAnnounceBuff(buff)
        end
    end
end

function IzC_WB:PreAnnounceBuff(buff)
    if (buff.Time < time()) then
        return false;
    end

    if (IzCWorldBuffs_SavedVars.IzC_WB_AnnounceBuff1 == true and buff.OneMinuteAnnouncement ~= true and buff.Time < time() + (1 * 60)) then
        buff.OneMinuteAnnouncement = true;
        buff.TwoinuteAnnouncement = true;
        buff.FiveMinuteAnnouncement = true;
        buff.TenMinuteAnnouncement = true;
        buff.FifteenMinuteAnnouncement = true;
        buff.TwentyMinuteAnnouncement = true;
        DEFAULT_CHAT_FRAME:AddMessage("World Buff: "..buff.Buff.." for: "..buff.Faction.." will drop in ONE minute.")
        UIErrorsFrame:AddMessage("World Buff: "..buff.Buff.." for: "..buff.Faction.." will drop in ONE minute.")
        return;
    end

    if (IzCWorldBuffs_SavedVars.IzC_WB_AnnounceBuff2 == true and buff.TwoinuteAnnouncement ~= true and buff.Time < time() + (2 * 60)) then
        buff.TwoinuteAnnouncement = true;
        buff.FiveMinuteAnnouncement = true;
        buff.TenMinuteAnnouncement = true;
        buff.FifteenMinuteAnnouncement = true;
        buff.TwentyMinuteAnnouncement = true;
        DEFAULT_CHAT_FRAME:AddMessage("World Buff: "..buff.Buff.." for: "..buff.Faction.." will drop in TWO minutes.")
        UIErrorsFrame:AddMessage("World Buff: "..buff.Buff.." for: "..buff.Faction.." will drop in TWO minutes.")
        return;
    end

    if (IzCWorldBuffs_SavedVars.IzC_WB_AnnounceBuff1 == true and buff.FiveMinuteAnnouncement ~= true and buff.Time < time() + (5 * 60)) then
        buff.FiveMinuteAnnouncement = true;
        buff.TenMinuteAnnouncement = true;
        buff.FifteenMinuteAnnouncement = true;
        buff.TwentyMinuteAnnouncement = true;
        DEFAULT_CHAT_FRAME:AddMessage("World Buff: "..buff.Buff.." for: "..buff.Faction.." will drop in FIVE minutes.")
        UIErrorsFrame:AddMessage("World Buff: "..buff.Buff.." for: "..buff.Faction.." will drop in FIVE minutes.")
        return;
    end

    if (IzCWorldBuffs_SavedVars.IzC_WB_AnnounceBuff1 == true and buff.TenMinuteAnnouncement ~= true and buff.Time < time() + (10 * 60)) then
        buff.TenMinuteAnnouncement = true;
        buff.FifteenMinuteAnnouncement = true;
        buff.TwentyMinuteAnnouncement = true;

        local minutesToBuff = math.floor(((buff.Time - time()) / 60) + 0.5);

        DEFAULT_CHAT_FRAME:AddMessage("World Buff: "..buff.Buff.." for: "..buff.Faction.." will drop in "..minutesToBuff.." minutes.")
        UIErrorsFrame:AddMessage("World Buff: "..buff.Buff.." for: "..buff.Faction.." will drop in "..minutesToBuff.." minutes.")
        return;
    end

    if (IzCWorldBuffs_SavedVars.IzC_WB_AnnounceBuff1 == true and buff.FifteenMinuteAnnouncement ~= true and buff.Time < time() + (15 * 60)) then
        buff.FifteenMinuteAnnouncement = true;
        buff.TwentyMinuteAnnouncement = true;

        local minutesToBuff = math.floor(((buff.Time - time()) / 60) + 0.5);

        DEFAULT_CHAT_FRAME:AddMessage("World Buff: "..buff.Buff.." for: "..buff.Faction.." will drop in "..minutesToBuff.." minutes.")
        UIErrorsFrame:AddMessage("World Buff: "..buff.Buff.." for: "..buff.Faction.." will drop in "..minutesToBuff.." minutes.")
        return;
    end

    if (IzCWorldBuffs_SavedVars.IzC_WB_AnnounceBuff1 == true and buff.TwentyMinuteAnnouncement ~= true and buff.Time < time() + (20 * 60)) then
        buff.TwentyMinuteAnnouncement = true;

        local minutesToBuff = math.floor(((buff.Time - time()) / 60) + 0.5);

        DEFAULT_CHAT_FRAME:AddMessage("World Buff: "..buff.Buff.." for: "..buff.Faction.." will drop in "..minutesToBuff.." minutes.")
        UIErrorsFrame:AddMessage("World Buff: "..buff.Buff.." for: "..buff.Faction.." will drop in "..minutesToBuff.." minutes.")
        return;
    end
end

function IzC_WB:CheckAnnouncementOn()
    if (IzCWorldBuffs_SavedVars.IzC_WB_AnnounceBuff1 == true) then
        IzC_WB.Announce = true;
        return;
    end
    if (IzCWorldBuffs_SavedVars.IzC_WB_AnnounceBuff2 == true) then
        IzC_WB.Announce = true;
        return;
    end
    if (IzCWorldBuffs_SavedVars.IzC_WB_AnnounceBuff5 == true) then
        IzC_WB.Announce = true;
        return;
    end
    if (IzCWorldBuffs_SavedVars.IzC_WB_AnnounceBuff10 == true) then
        IzC_WB.Announce = true;
        return;
    end
    if (IzCWorldBuffs_SavedVars.IzC_WB_AnnounceBuff15 == true) then
        IzC_WB.Announce = true;
        return;
    end
    if (IzCWorldBuffs_SavedVars.IzC_WB_AnnounceBuff20 == true) then
        IzC_WB.Announce = true;
        return;
    end

    IzC_WB.Announce = false
end
