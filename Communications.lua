-- Globals Section
local addonName, L = ...;

IzC_WB.Sender = LibStub("AceAddon-3.0"):NewAddon("IzCWorldBuffs", "AceComm-3.0")
local LibSerialize = LibStub("AceSerializer-3.0")

IzC_WB.AddonMessagePrefix = "IzC_WB";

IzC_WB.MessageThrottleTime = 8;
IzC_WB.LastMessageThrottleTime = time() - IzC_WB.MessageThrottleTime;
IzC_WB.SendBuffChecker = true;

IzC_WB.MessagesSent = 0;
IzC_WB.MessagesReceived = 0;
IzC_WB.StartTime = time();
IzC_WB.ReceiveRegistered = false;
IzC_WB.SendRegistered = false;

function IzC_WB.Sender:TrySend()
    if (IzC_WB.LastMessageThrottleTime > time()) then
        IzC_WB:PrintDebug("Tried to send a buff but throttle timer hasn't expired");
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
        return false;
    end

    if buff.SendBuffChecker == IzC_WB.SendBuffChecker then
        return true;
    end

    return false;
end

function IzC_WB.Sender:SendBuff(buff)
    if IzCWorldBuffs_SavedVars.IzC_WB_SendBuffs ~= true then
        IzC_WB:PrintDebug("Tried to send a buff but sending is turned off.");
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

    IzC_WB.LastMessageThrottleTime = time() + (IzC_WB.MessageThrottleTime * 2) 

    if (#sendTo <= 0) then
        IzC_WB:PrintDebug("No channels found");
        return;
    end

    local target = sendTo[ math.random(#sendTo) ];

    local buffToSend = {
        B = buff.Buff,
        T = buff.Time
    };
    if (buff.Alliance == true) then
        buffToSend.A = 1
    else
        buffToSend.A = 0
    end
    
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
    if (sender == UnitName("player") or IzCWorldBuffs_SavedVars.IzC_WB_ReceiveBuffs ~= true) then
        return;
    end

    IzC_WB.MessagesReceived = IzC_WB.MessagesReceived + 1;

    IzC_WB.LastMessageThrottleTime = time() + IzC_WB.MessageThrottleTime;
    local success, data = LibSerialize:Deserialize(payload)
    if not success then return end

    IzC_WB:PrintDebug(prefix.." - "..payload.." - "..distribution.." - "..sender)

    if (data.T == nil or data.A == nil or data.B == nil) then
        IzC_WB:PrintDebug(sender.." is using an old version. Disregarding msg")
        return;
    end

    local isAlliance = false;
    if (data.A == 1) then
        isAlliance = true;
    end

    IzC_WB:AddBuff(data.B, isAlliance, data.T, sender)
end

function IzC_WB.Sender:OnEnable()
    IzC_WB.Sender:TryRegisterCom()
end

function IzC_WB.Sender:TryRegisterCom()
    if IzCWorldBuffs_SavedVars.IzC_WB_ReceiveBuffs == true and IzC_WB.ReceiveRegistered == false then
        self:RegisterComm(IzC_WB.AddonMessagePrefix)
        IzC_WB.ReceiveRegistered = true;
    end
end
