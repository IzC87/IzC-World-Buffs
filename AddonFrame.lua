-- Globals Section
local addonName, L = ...;

IzC_WB.AddonFrame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
IzC_WB.AddonFrame:SetSize(500, 400)
IzC_WB.AddonFrame:SetPoint("CENTER")
IzC_WB.AddonFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 8, right = 8, top = 8, bottom = 8 }
})
IzC_WB.AddonFrame:SetMovable(true)
IzC_WB.AddonFrame:EnableMouse(true)
IzC_WB.AddonFrame:RegisterForDrag("LeftButton")
IzC_WB.AddonFrame:SetScript("OnDragStart", IzC_WB.AddonFrame.StartMoving)
IzC_WB.AddonFrame:SetScript("OnDragStop", IzC_WB.AddonFrame.StopMovingOrSizing)
IzC_WB.AddonFrame:SetScript("OnShow", function()
    if not IzC_WB.BuffsUI.Frame:IsShown() and not IzC_WB.InputUI.Frame:IsShown() then
        IzC_WB.InputUI.Frame:Show();
    end
end)

-- -- Close Button
local closeButton = CreateFrame("Button", nil, IzC_WB.AddonFrame, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", -6, -6)

IzC_WB.AddonFrame:Hide();







IzC_WB.BuffsUI = {};
-- -- Buffs Tab Button
IzC_WB.BuffsUI.TabButton = CreateFrame("Button", "IzC_WB.AddonFrameTab2", IzC_WB.AddonFrame, "CharacterFrameTabButtonTemplate")
IzC_WB.BuffsUI.TabButton:SetPoint("BOTTOMLEFT", 120, -19)
IzC_WB.BuffsUI.TabButton:SetSize(120, 25)
IzC_WB.BuffsUI.TabButton:SetText("Buffs")
IzC_WB.BuffsUI.TabButton:SetScript("OnClick", function()
    -- PanelTemplates_SetTab(IzC_WB.AddonFrame, 2);
    IzC_WB.BuffsUI.Frame:Show();
    IzC_WB.InputUI.Frame:Hide();
end)

IzC_WB.BuffsUI.Frame = CreateFrame("Frame", "TabPage2", IzC_WB.AddonFrame)
IzC_WB.BuffsUI.Frame:SetSize(500, 400)
IzC_WB.BuffsUI.Frame:SetPoint("CENTER")
local buffsUITitle = IzC_WB.BuffsUI.Frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
buffsUITitle:SetPoint("TOP", 0, -16)
buffsUITitle:SetText("Buffs")

IzC_WB.BuffsUI.Frame:Hide();
