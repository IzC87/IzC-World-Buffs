-- Globals Section
local addonName, L = ...;

IzC_WB.BuffsUI = {};
-- -- Buffs Tab Button
IzC_WB.BuffsUI.TabButton = CreateFrame("Button", "IzC_WB.AddonFrameTab2", IzC_WB.AddonFrame, "CharacterFrameTabButtonTemplate")
IzC_WB.BuffsUI.TabButton:SetPoint("BOTTOMLEFT", 5, -19)
IzC_WB.BuffsUI.TabButton:SetSize(120, 25)
IzC_WB.BuffsUI.TabButton:SetText("Buffs")
IzC_WB.BuffsUI.TabButton:SetScript("OnClick", function()
    IzC_WB.InputUI.Frame:Hide();
    IzC_WB.AddBuffsUI.Frame:Hide();
    IzC_WB.ExportBuffsUI.Frame:Hide();
    IzC_WB.BuffsUI.Frame:Show();
end)

IzC_WB.BuffsUI.Frame = CreateFrame("Frame", "TabPage2", IzC_WB.AddonFrame)
IzC_WB.BuffsUI.Frame:SetSize(500, 400)
IzC_WB.BuffsUI.Frame:SetPoint("CENTER")
local buffsUITitle = IzC_WB.BuffsUI.Frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
buffsUITitle:SetPoint("TOP", 0, -16)
buffsUITitle:SetText("Buffs")

IzC_WB.BuffsUI.Frame:Hide();
IzC_WB.BuffsUI.Frame:SetScript("OnShow", function()
    IzC_WB.BuffsUI:BuildBuffInterface()
end)

IzC_WB.BuffsUI.Buffs = {}

function IzC_WB.BuffsUI:BuildBuffInterface()
    local buffs = IzC_WB:SortBuffsByTime();
    -- local nextDay = time( { year = tonumber(date("%Y")), month = tonumber(date("%m")), day = tonumber(date("%d")) }) + 24 * 60 * 60;

    local index = 1;
    for _,buff in ipairs(buffs) do
        if (IzC_WB:ShowBuff(buff) == true) then
            
        end
        index = index + 1;
    end
end
