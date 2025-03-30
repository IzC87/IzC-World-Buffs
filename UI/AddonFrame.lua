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
    if not IzC_WB.BuffsUI.Frame:IsShown() and not IzC_WB.InputUI.Frame:IsShown() and not IzC_WB.AddBuffsUI.Frame:IsShown() and not IzC_WB.ExportBuffsUI.Frame:IsShown() then
        IzC_WB.InputUI.Frame:Show();
    end
end)

-- -- Close Button
local closeButton = CreateFrame("Button", nil, IzC_WB.AddonFrame, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", -6, -6)

IzC_WB.AddonFrame:Hide();
