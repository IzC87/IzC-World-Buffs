-- Globals Section
local addonName, L = ...;

IzC_WB.Sender = LibStub("AceAddon-3.0"):NewAddon("IzCWorldBuffs", "AceComm-3.0")
local LibSerialize = LibStub("AceSerializer-3.0")

IzC_WB.AddonMessagePrefix = "IzC_WB";

IzC_WB.MessageThrottleTime = 12;
IzC_WB.LastMessageThrottleTime = time() - IzC_WB.MessageThrottleTime;
IzC_WB.SendBuffChecker = true;

IzC_WB.MessagesSent = 0;
IzC_WB.MessagesReceived = 0;
IzC_WB.StartTime = time();

function IzC_WB.Sender:TrySend()
    if (IzC_WB.LastMessageThrottleTime > time()) then
        IzC_WB:PrintDebug("Tried to send a buff but throttle timer hasn't expired");
        return;
    end
    if (UnitAffectingCombat("player")) then
        IzC_WB:PrintDebug("Don't try to send in combat");
        return;
    end
    for key,buff in pairs(IzCBuffs) do
        if IzC_WB.Sender:ShouldSendBuff(buff) == true then
            IzC_WB:PrintDebug("Trying to send buff: "..key);
            IzC_WB.Sender:SendBuff(buff);
            return;
        end
    end

    IzC_WB:PrintDebug("No buffs to send");
    IzC_WB.SendBuffChecker = not IzC_WB.SendBuffChecker;
end

function IzC_WB.Sender:ShouldSendBuff(buff)
    if buff.Time < time() then
        -- IzC_WB:PrintDebug("Don't send too old buffs")
        return false;
    end

    if buff.SendBuffChecker == IzC_WB.SendBuffChecker then
        return true;
    end

    return false;
end

function IzC_WB.Sender:SendBuff(buff)
    if IzCWorldBuffs_SavedVars.IzC_WB_Communication ~= true then
        IzC_WB:PrintDebug("Tried to send a buff but communications is turned off.");
        return;
    end

    if (buff.Time < time()) then
        IzC_WB:PrintDebug("Tried to send a buff but it was too old");
        return;
    end
    if (IzC_WB.LastMessageThrottleTime > time()) then
        IzC_WB:PrintDebug("Tried to send a buff but throttle timer hasn't expired");
        return;
    end

    local sendTo = {  }

    if IsInGuild() then
        table.insert(sendTo, "GUILD")
    end
    if IsResting() then
        table.insert(sendTo, "YELL")
    end
    if IsInGroup(1) then
        table.insert(sendTo, "PARTY")
    end
    if IsInRaid(1) then
        table.insert(sendTo, "RAID")
    end

    IzC_WB.LastMessageThrottleTime = time() + IzC_WB.MessageThrottleTime

    if (#sendTo <= 0) then
        IzC_WB:PrintDebug("No channels found");
        return;
    end

    local target = sendTo[ math.random(#sendTo) ];

    local buffToSend = {
        Buff = buff.Buff,
        Faction = buff.Faction,
        Time = buff.Time
    };
    
    buff.SendBuffChecker = not IzC_WB.SendBuffChecker;

    IzC_WB:PrintDebug("Send buff to "..target);
    IzC_WB.Sender:Transmit(buffToSend, target)
end

function IzC_WB.Sender:Transmit(data, channel)
    local serialized = LibSerialize:Serialize(data)
    self:SendCommMessage(IzC_WB.AddonMessagePrefix, serialized, channel)
    IzC_WB.MessagesSent = IzC_WB.MessagesSent + 1;
end

function IzC_WB.Sender:OnCommReceived(prefix, payload, distribution, sender)
    if (sender == UnitName("player") or IzCWorldBuffs_SavedVars.IzC_WB_Communication ~= true) then
        return;
    end

    IzC_WB.MessagesReceived = IzC_WB.MessagesReceived + 1;

    IzC_WB.LastMessageThrottleTime = time() + IzC_WB.MessageThrottleTime;
    local success, data = LibSerialize:Deserialize(payload)
    if not success then return end

    print(prefix, payload, distribution, sender)

    IzC_WB:AddBuff(data.Buff, data.Faction, data.Time, "Imported From: "..sender)

    -- for key,buff in pairs(data) do
        -- print(key, buff)
    -- end
end




function IzC_WB.Sender:OnEnable()
    if IzCWorldBuffs_SavedVars.IzC_WB_Communication ~= true then
        return;
    end
    
    self:RegisterComm(IzC_WB.AddonMessagePrefix)
end
