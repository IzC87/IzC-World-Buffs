local LDB = LibStub ("LibDataBroker-1.1", true)
local IzC_WB_Button = LDB and LibStub ("LibDBIcon-1.0", true)

function IzC_WB:RegisterMiniMap()
    
    if LDB then
  
        local databroker = LDB:NewDataObject ("IzCWorldBuffs", {
            type = "data source",
            icon = "236396",
            text = "0",
        
            HotCornerIgnore = true,
        
            OnClick = function (self, button)
        
                if button == "LeftButton" then 
                    if IzC_WB.AddonFrame:IsShown() then
                        IzC_WB.AddonFrame:Hide();
                    else
                        IzC_WB.AddonFrame:Show()
                    end
                elseif button == "RightButton" then
                    Settings.OpenToCategory(IzC_WB.Category)
                end
            end,

            OnTooltipShow = function (tooltip)
                tooltip:AddLine("|cFFFFD700 World Buffs");
                tooltip:AddLine("------------------------------");

                local buffs = IzC_WB:SortBuffsByTime();
                local nextDay = time( { year = tonumber(date("%Y")), month = tonumber(date("%m")), day = tonumber(date("%d")) }) + 24 * 60 * 60;
                local addLine = true;

                for _,buff in ipairs(buffs) do
                    -- Don't show buffs that have passed
                    if (IzC_WB:ShowBuff(buff) == true) then
                        local dateString = date("%H:%M", buff.Time)
                        if nextDay and buff.Time > nextDay then
                            dateString = date("%A %d - %H:%M", buff.Time)
                            if addLine then
                                tooltip:AddLine("------------------------------");
                                addLine = nil;
                            end
                        end

                        local factionColor = "|cDEFF0006"
                        if buff.Alliance == true then
                            factionColor = "|c0000D6DE"
                        end
                        
                        tooltip:AddLine(factionColor..buff.Buff.." - "..buff.Faction.." - "..dateString);
                    end
                end
                
                if (IzCWorldBuffs_SavedVars.IzC_WB_Tooltip_Debug == true) then
                    tooltip:AddLine("------------------------------");

                    local minutesElapsedSinceStart = ((time() - IzC_WB.StartTime) / 60);
                    if (minutesElapsedSinceStart <= 0) then
                        minutesElapsedSinceStart = 1;
                    end

                    tooltip:AddLine("MessagesSent: "..IzC_WB.MessagesSent);
                    if (IzC_WB.MessagesSent > 0) then
                        local sentPerMinute = math.floor((IzC_WB.MessagesSent / minutesElapsedSinceStart) * 10) / 10
                        tooltip:AddLine("MessagesSent / Minute: "..tostring(sentPerMinute));
                    end

                    if (IzC_WB.MessagesReceived > 0) then
                        if (IzC_WB.MessagesSent > 0) then
                            tooltip:AddLine("------------------------------");
                        end
                        tooltip:AddLine("MessagesReceived: "..IzC_WB.MessagesReceived);
                        local receivedPerMinute = math.floor((IzC_WB.MessagesReceived / minutesElapsedSinceStart) * 10) / 10
                        tooltip:AddLine("MessagesReceived / Minute: "..tostring(receivedPerMinute));
                    end
                end
            end,
        })
        
        if (databroker and not IzC_WB_Button:IsRegistered ("IzCWorldBuffs")) then
            IzC_WB_Button:Register("IzCWorldBuffs", databroker, IzCWorldBuffs_Minimap)
        end

        IzC_WB:ShowHideMiniMap(IzCWorldBuffs_Minimap.hide);
    end
end

function IzC_WB:ShowBuff(buff)
    if (buff.Time < time() - (5 * 60)) then
        return false;
    end

    if (IzCWorldBuffs_CharSettings.IzC_WB_IgnoreRendBuff == true and buff.Buff == "RendBuff") then
        return false;
    end

    if (IzCWorldBuffs_CharSettings.IzC_WB_IgnoreOnyxia == true and buff.Buff == "Onyxia") then
        if (buff.Alliance == true and UnitFactionGroup("player") == "Horde") then
            return false;
        end
        if (buff.Alliance == false and UnitFactionGroup("player") == "Alliance") then
            return false;
        end
    end

    return true;
end

function IzC_WB:ShowHideMiniMap(shouldHide)
    IzCWorldBuffs_Minimap.hide = shouldHide;
    if shouldHide then
        IzC_WB_Button:Hide("IzCWorldBuffs");
    else
        IzC_WB_Button:Show("IzCWorldBuffs");
    end
end

function IzC_WB:ShowHideTooltip(shouldHide)
    IzCWorldBuffs_Minimap.ShowTooltip = shouldHide;
end
