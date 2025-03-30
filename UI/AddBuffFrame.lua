-- Globals Section
local addonName, L = ...;

IzC_WB.AddBuffsUI = {};
-- -- Buffs Tab Button
IzC_WB.AddBuffsUI.TabButton = CreateFrame("Button", "IzC_WB.AddonFrameTab3", IzC_WB.AddonFrame, "CharacterFrameTabButtonTemplate")
IzC_WB.AddBuffsUI.TabButton:SetPoint("BOTTOMLEFT", 120, -19)
IzC_WB.AddBuffsUI.TabButton:SetSize(120, 25)
IzC_WB.AddBuffsUI.TabButton:SetText("Add Buff")
IzC_WB.AddBuffsUI.TabButton:SetScript("OnClick", function()
    IzC_WB.BuffsUI.Frame:Hide();
    IzC_WB.InputUI.Frame:Hide();
    IzC_WB.ExportBuffsUI.Frame:Hide();
    IzC_WB.AddBuffsUI.Frame:Show();
end)

IzC_WB.AddBuffsUI.Frame = CreateFrame("Frame", "TabPage3", IzC_WB.AddonFrame)
IzC_WB.AddBuffsUI.Frame:SetSize(500, 400)
IzC_WB.AddBuffsUI.Frame:SetPoint("CENTER")
local addBuffsUITitle = IzC_WB.AddBuffsUI.Frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
addBuffsUITitle:SetPoint("TOP", 0, -16)
addBuffsUITitle:SetText("Add Buff")

IzC_WB.AddBuffsUI.Frame:Hide();
