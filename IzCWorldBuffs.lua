-- Globals Section
local addonName, L = ...;

local IzC_WB_BuffTypes = {
    [1] = "Onyxia",
    [2] = "Rend"
}

-- Create a frame to handle events
IzC_WB = CreateFrame("Frame", "IzCAutoConsumables_IzC_WB");
IzC_WB:SetScript("OnEvent", function(self, event, ...) IzC_WB:EventHandler(event, ...); end);

-- register events
IzC_WB:RegisterEvent("ADDON_LOADED");
IzC_WB:RegisterEvent("PLAYER_TARGET_CHANGED")
IzC_WB:RegisterEvent("PLAYER_LOGOUT")



IzCWorldBuffs_SavedVars = {}
IzCBuffs = {}

function IzC_WB:ClearOldBuffs()
    local oldestBuffTime = IzC_WB:GetDateShiftedByDay(-2);
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
        print(event);
        if (arg1 == addonName) then

            IzCWorldBuffs_SavedVars = setmetatable(IzCWorldBuffs_SavedVars or {}, { __index = IzCWorldBuffs_Defaults })
            IzCBuffs = setmetatable(IzCBuffs or {}, { __index = {} })

            -- IzCBuffs = {}


            IzC_WB:TryUnregisterEvent("ADDON_LOADED");
            IzC_WB:CreateSettings();
            IzC_WB:RegisterMiniMap();


--             local input = [[<Titans> Center — Yesterday at 01:08
-- <Titans> 
-- :Titans_Ony: :alliance: -  27/03/2025 - 19:00 ST
-- @Onyxia Alliance]]

            -- IzC_WB:ProcessRawInput(input);

            return;
        end
    elseif (event == "PLAYER_LOGOUT") then
        IzC_WB:ClearOldBuffs();
        return;
    else
        IzC_WB.Sender:TrySend()
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





----------------------
--      Options     --
----------------------
function IzC_WB:CreateSettings()
    local category, layout = Settings.RegisterVerticalLayoutCategory("IzC World Buffs")

    -- local MainCategory, _ = Settings.RegisterVerticalLayoutSubcategory(category, "Prio");
    -- local MacrosCategory, _ = Settings.RegisterVerticalLayoutSubcategory(category, "Macros");
    local debugCategory, debugLayout = Settings.RegisterVerticalLayoutSubcategory(category, "Debug");

    local function CreateCheckBox(variable, name, tooltip, category, defaultValue)
        local function GetValue()
            return IzCWorldBuffs_SavedVars[variable] or defaultValue
        end

        local function SetValue(value)
            IzC_WB:PrintDebug("Setting "..variable.." changed to: "..tostring(value));
            IzCWorldBuffs_SavedVars[variable] = value;
            if (variable == "IzC_WB_Communication") then
                IzC_WB.Sender:OnEnable()
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
        end,
        hasEditBox = 1,
    }

    do
        CreateCheckBox("IzC_WB_Communication", "Use Communication", "Whether or not we should listen to or send buffs to other people", category, true)

        -- CreateCheckBox("IzC_WB_SendToParty", "Share buffs with Party", "Share buffs with Party members", category, true)
        -- CreateCheckBox("IzC_WB_SendToGuild", "Share buffs with Guild", "Share buffs with Guild members", category, true)

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
    Settings.RegisterAddOnCategory(category)
end

IzCWorldBuffs_Defaults = {
    ["IzC_WB_Communication"] = true,
    -- ["IzC_WB_SendToGuild"] = true,
    -- ["IzC_WB_SendToParty"] = true,
    ["IzC_WB_Tooltip_Debug"] = false,
    ["IzC_WB_Debug"] = false,
    ["Buffs"] = {},
    ["Minimap"] = {},
    ["ShowTooltip"] = true
}
