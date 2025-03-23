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
                    -- IzC_WB.BrowserWindow:ToggleWindow()
                elseif button == "RightButton" then
                    Settings.OpenToCategory("IzC World Buffs")
                end

            end,

            OnTooltipShow = function (tooltip)
                
                -- tooltip:AddLine (IzC_WB.L["Loon Best In Slot"]);
                -- tooltip:AddLine("|cFF9CD6DE Left Click Open Browser Window");
                -- tooltip:AddLine("|cFF9CD6DE Right Click Open Settings");
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
