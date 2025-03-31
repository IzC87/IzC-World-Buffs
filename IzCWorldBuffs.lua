-- Globals Section
local addonName, L = ...;

-- Create a frame to handle events
IzC_WB = CreateFrame("Frame", "IzCAutoConsumables_IzC_WB");
IzC_WB:SetScript("OnEvent", function(self, event, ...) IzC_WB:EventHandler(event, ...); end);

-- register events
IzC_WB:RegisterEvent("ADDON_LOADED");
IzC_WB:RegisterEvent("PLAYER_LOGOUT")
IzC_WB:RegisterEvent("PLAYER_REGEN_ENABLED");

IzCWorldBuffs_CharSettings = {}
IzCWorldBuffs_SavedVars = {}
IzCBuffs = {}
IzC_WB.OnUpdateThrottleWaiter = 5
IzC_WB.OnUpdateThrottleTime = time() + IzC_WB.OnUpdateThrottleWaiter
IzC_WB.OnUpdateIndex = 1;

function IzC_WB:ClearOldBuffs()
    local oldestBuffTime = IzC_WB:GetDateShiftedByDay(-1);
    for key,buff in pairs(IzCBuffs) do
        if buff.Time < oldestBuffTime then
            IzCBuffs[key] = nil;
        end
    end
end

function IzC_WB:PrintDebug(message)
    if IzCWorldBuffs_SavedVars.IzC_WB_Debug == true then
        DEFAULT_CHAT_FRAME:AddMessage(message);
    end
end



-----------------------
---- Event Handler ----
-----------------------
function IzC_WB:EventHandler(event, arg1, ...)
    IzC_WB:PrintDebug(event)

    if (event == "ADDON_LOADED") then
        if (arg1 == addonName) then

            IzCWorldBuffs_CharSettings = setmetatable(IzCWorldBuffs_CharSettings or {}, { __index = IzCWorldBuffs_CharSettings_Defaults })
            IzCWorldBuffs_SavedVars = setmetatable(IzCWorldBuffs_SavedVars or {}, { __index = IzCWorldBuffs_Defaults })
            IzCWorldBuffs_Minimap = setmetatable(IzCWorldBuffs_Minimap or {}, { __index = IzCWorldBuffs_Minimap_Defaults })
            IzCBuffs = setmetatable(IzCBuffs or {}, { __index = {} })

            IzC_WB:TryUnregisterEvent("ADDON_LOADED");
            IzC_WB:CreateSettings();
            IzC_WB:RegisterMiniMap();
            IzC_WB:RegisterOnUpdate();
            IzC_WB:CheckAnnouncementOn();
            return;
        end
    elseif (event == "PLAYER_LOGOUT") then
        IzC_WB:ClearOldBuffs();
        return;
    elseif (event == "PLAYER_REGEN_ENABLED") then
        IzC_WB.OnUpdateThrottleTime = time() + IzC_WB.OnUpdateThrottleWaiter
        IzC_WB:RegisterOnUpdate()
    end
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

function IzC_WB:RegisterOnUpdate()
    if not IzC_WB:GetScript("OnUpdate") then
        IzC_WB:SetScript("OnUpdate", function(self, event, ...) IzC_WB:OnUpdate(event, ...); end);
    end
end

function IzC_WB:UnRegisterOnUpdate()
    if IzC_WB:GetScript("OnUpdate") then
        IzC_WB:SetScript("OnUpdate", nil);
    end
end

----------------------
-- OnUpdate Handler --
----------------------
function IzC_WB:OnUpdate()
    if (IzC_WB.OnUpdateThrottleTime > time()) then
        return;
    end
    IzC_WB.OnUpdateThrottleTime = time() + IzC_WB.OnUpdateThrottleWaiter

    if (UnitAffectingCombat("player")) then
        IzC_WB:UnRegisterOnUpdate();
        return;
    end
    
    if IzCWorldBuffs_SavedVars.IzC_WB_SendBuffs == true and IzC_WB.OnUpdateIndex == 1 then
        IzC_WB.Sender:TrySend();
    end

    if IzC_WB.OnUpdateIndex == 2 then
        IzC_WB:PreAnnounceBuffs();
    end

    IzC_WB.OnUpdateIndex = IzC_WB.OnUpdateIndex + 1;
    if (IzC_WB.OnUpdateIndex > 2) then
        IzC_WB.OnUpdateIndex = 1;
    end
end




----------------------
--      Options     --
----------------------
function IzC_WB:CreateSettings()
    IzC_WB.Category, _ = Settings.RegisterVerticalLayoutCategory("IzC World Buffs")

    local announceCategory, announceLayout = Settings.RegisterVerticalLayoutSubcategory(IzC_WB.Category, "Announcements");
    local debugCategory, debugLayout = Settings.RegisterVerticalLayoutSubcategory(IzC_WB.Category, "Debug");

    local function CreatePerCharacterCheckBox(variable, name, tooltip, category, defaultValue)
        local function GetValue()
            return IzCWorldBuffs_CharSettings[variable] or defaultValue
        end

        local function SetValue(value)
            IzC_WB:PrintDebug("Setting "..variable.." changed to: "..tostring(value));
            IzCWorldBuffs_CharSettings[variable] = value;
        end

        local setting = Settings.RegisterProxySetting(category, variable, type(false), name, defaultValue, GetValue, SetValue)

        Settings.CreateCheckbox(category, setting, tooltip)
    end

    local function CreateCheckBox(variable, name, tooltip, category, defaultValue)
        local function GetValue()
            return IzCWorldBuffs_SavedVars[variable] or defaultValue
        end

        local function SetValue(value)
            IzC_WB:PrintDebug("Setting "..variable.." changed to: "..tostring(value));
            IzCWorldBuffs_SavedVars[variable] = value;
            if (variable == "IzC_WB_ReceiveBuffs") then
                IzC_WB.Sender:TryRegisterCom()
            end
            if (variable:find("^IzC_WB_AnnounceBuff")) then
                IzC_WB:CheckAnnouncementOn();
            end
        end

        local setting = Settings.RegisterProxySetting(category, variable, type(false), name, defaultValue, GetValue, SetValue)

        Settings.CreateCheckbox(category, setting, tooltip)
    end

    StaticPopupDialogs.ClearBuffs = {
        text = "Really Clear All Buffs?",
        button1 = OKAY,
        button2 = CANCEL,
        OnAccept = function(self)
            IzCBuffs = {}
        end
    }

    do
        CreateCheckBox("IzC_WB_SendBuffs", "Send Buffs To Other People", "Whether or not we should send buffs to other people", IzC_WB.Category, false)
        CreateCheckBox("IzC_WB_ReceiveBuffs", "Receive Buffs From Other People", "Whether or not we should listen to buffs from other people", IzC_WB.Category, false)

        CreatePerCharacterCheckBox("IzC_WB_IgnoreRendBuff", "Ignore Rend Buff", "Ignore Rend Buff", IzC_WB.Category, false)
        CreatePerCharacterCheckBox("IzC_WB_IgnoreOnyxia", "Ignore other faction Onyxia", "Ignore onyxia for the other faction than yours", IzC_WB.Category, false)

        CreateCheckBox("IzC_WB_AnnounceNewBuff", "Announce new buff", "Whether or not we should make an announcement when a new buff is added", announceCategory, false)
        CreateCheckBox("IzC_WB_AnnounceBuff1", "Pre-Announce buff - 1 minute", "Announce a buff that is coming in one minute", announceCategory, false)
        CreateCheckBox("IzC_WB_AnnounceBuff2", "Pre-Announce buff - 2 minutes", "Announce a buff that is coming in two minutes", announceCategory, false)
        CreateCheckBox("IzC_WB_AnnounceBuff5", "Pre-Announce buff - 5 minutes", "Announce a buff that is coming in five minutes", announceCategory, false)
        CreateCheckBox("IzC_WB_AnnounceBuff10", "Pre-Announce buff - 10 minutes", "Announce a buff that is coming in ten minutes", announceCategory, false)
        CreateCheckBox("IzC_WB_AnnounceBuff15", "Pre-Announce buff - 15 minutes", "Announce a buff that is coming in fifteen minutes", announceCategory, false)
        CreateCheckBox("IzC_WB_AnnounceBuff20", "Pre-Announce buff - 20 minutes", "Announce a buff that is coming in twenty minutes", announceCategory, false)
        
        CreateCheckBox("IzC_WB_Tooltip_Debug", "Tooltip Debug Info", "Show some debug info in buff Tooltip", debugCategory, false)
        CreateCheckBox("IzC_WB_Debug", "Debug Mode", "Print debug statements?", debugCategory, false)

        do
            local function OnButtonClick()
                StaticPopup_Show("ClearBuffs")
            end

            local initializer = CreateSettingsButtonInitializer("Clear All Buffs", "ClearBuffs", OnButtonClick, "Click button to clear all World Buffs", true);
            debugLayout:AddInitializer(initializer);
        end
    end
    Settings.RegisterAddOnCategory(IzC_WB.Category)
end

IzCWorldBuffs_Defaults = {
    ["IzC_WB_SendBuffs"] = false,
    ["IzC_WB_ReceiveBuffs"] = true,
    ["IzC_WB_Tooltip_Debug"] = false,
    ["IzC_WB_AnnounceNewBuff"] = true,
    ["IzC_WB_AnnounceBuff1"] = false,
    ["IzC_WB_AnnounceBuff2"] = false,
    ["IzC_WB_AnnounceBuff5"] = false,
    ["IzC_WB_AnnounceBuff10"] = false,
    ["IzC_WB_AnnounceBuff15"] = false,
    ["IzC_WB_AnnounceBuff20"] = false,
    ["IzC_WB_Debug"] = false,
    ["Buffs"] = {},
    ["Minimap"] = {},
    ["ShowTooltip"] = true
}

IzCWorldBuffs_Minimap_Defaults = {
}

IzCWorldBuffs_CharSettings_Defaults = {
    ["IzC_WB_IgnoreRendBuff"] = false,
    ["IzC_WB_IgnoreOnyxia"] = true
}
