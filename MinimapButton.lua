local LDB = LibStub ("LibDataBroker-1.1", true)
local IzC_WB_Button = LDB and LibStub ("LibDBIcon-1.0", true)

function IzC_WB:RegisterMiniMap()
    
    if LDB then
  
        local databroker = LDB:NewDataObject ("IzCWorldBuffs", {
            type = "data source",
            icon = "inv_misc_monsterscales_14",
            text = "0",
        
            HotCornerIgnore = true,
        
            OnClick = function (self, button)
        
                if button == "LeftButton" then 
                    if IzC_WB.InputFrame:IsShown() then
                        IzC_WB.InputFrame:Hide()
                    else
                        IzC_WB.InputFrame:Show()
                    end
                    -- for key,buff in pairs(IzCBuffs) do
                    --     local dateString = date("%Y-%m-%d %H:%M", buff.Time)
                    --     DEFAULT_CHAT_FRAME:AddMessage("|cFF9CD6DE"..buff.Buff.." - "..buff.Faction.." - "..dateString.."\n"..buff.RawPost.."\n");
                    -- end
                elseif button == "RightButton" then
                    Settings.OpenToCategory("IzC World Buffs")
                end
            end,

            OnTooltipShow = function (tooltip)
                tooltip:AddLine("|cFFFFD700 World Buffs");

                local buffs = IzC_WB:SortBuffsByTime();
                local nextDay = time( { year = tonumber(date("%Y")), month = tonumber(date("%m")), day = tonumber(date("%d")) }) + 24 * 60 * 60;
                local addLine = true;

                for _,buff in ipairs(buffs) do
                    -- Don't show buffs that have passed
                    if buff.Time > time() - (5 * 60) then
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
                        
                        local sendBuffCheckerString = "";
                        if (IzCWorldBuffs_SavedVars.IzC_WB_Tooltip_Debug == true) then
                            sendBuffCheckerString = " "..tostring(buff.SendBuffChecker)
                        end

                        tooltip:AddLine(factionColor..buff.Buff.." - "..buff.Faction.." - "..dateString..sendBuffCheckerString);
                    end
                end
                
                if (IzCWorldBuffs_SavedVars.IzC_WB_Tooltip_Debug == true) then
                    tooltip:AddLine("------------------------------");
                    tooltip:AddLine("SendBuffChecker: "..tostring(IzC_WB.SendBuffChecker));

                    local minutesElapsedSinceStart = ((time() - IzC_WB.StartTime) / 60);
                    if (minutesElapsedSinceStart <= 0) then
                        minutesElapsedSinceStart = 1;
                    end

                    tooltip:AddLine("MessagesSent: "..IzC_WB.MessagesSent);
                    if (IzC_WB.MessagesSent > 0) then
                        tooltip:AddLine("MessagesSent / Minute: "..tostring(IzC_WB.MessagesSent / minutesElapsedSinceStart));
                        tooltip:AddLine("------------------------------");
                    end

                    tooltip:AddLine("MessagesReceived: "..IzC_WB.MessagesReceived);
                    if (IzC_WB.MessagesReceived > 0) then
                        tooltip:AddLine("MessagesReceived / Minute: "..tostring(IzC_WB.MessagesReceived / minutesElapsedSinceStart));
                        tooltip:AddLine("------------------------------");
                    end
                end
            end,
        })
        
        if (databroker and not IzC_WB_Button:IsRegistered ("IzCWorldBuffs")) then
            IzC_WB_Button:Register ("IzCWorldBuffs", databroker, IzCWorldBuffs_SavedVars.Minimap)
        end

        IzC_WB:ShowHideMiniMap(IzCWorldBuffs_SavedVars.Minimap.hide);
    end
  end

  function IzC_WB:ShowHideMiniMap(shouldHide)
    IzCWorldBuffs_SavedVars.Minimap.hide = shouldHide;
    if shouldHide then
        IzC_WB_Button:Hide("IzCWorldBuffs");
    else
        IzC_WB_Button:Show("IzCWorldBuffs");
    end

    function IzC_WB:ShowHideTooltip(shouldHide)
        IzCWorldBuffs_SavedVars.ShowTooltip = shouldHide;
    end
end
