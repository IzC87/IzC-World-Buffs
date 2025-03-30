-- Globals Section
local addonName, L = ...;

IzC_WB.InputUI = {};
-- -- Input Tab Button
IzC_WB.InputUI.TabButton = CreateFrame("Button", "IzC_WB.AddonFrameTab1", IzC_WB.AddonFrame, "CharacterFrameTabButtonTemplate")
IzC_WB.InputUI.TabButton:SetPoint("BOTTOMRIGHT", 5, -19)
IzC_WB.InputUI.TabButton:SetSize(120, 25)
IzC_WB.InputUI.TabButton:SetText("Parse Input")
IzC_WB.InputUI.TabButton:SetScript("OnClick", function()
    IzC_WB.BuffsUI.Frame:Hide();
    IzC_WB.AddBuffsUI.Frame:Hide();
    IzC_WB.ExportBuffsUI.Frame:Hide();
    IzC_WB.InputUI.Frame:Show();
end)

IzC_WB.InputUI.Frame = CreateFrame("Frame", "TabPage1", IzC_WB.AddonFrame)
IzC_WB.InputUI.Frame:SetSize(500, 400)
IzC_WB.InputUI.Frame:SetPoint("CENTER")
local inputUITitle = IzC_WB.InputUI.Frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
inputUITitle:SetPoint("TOP", 0, -16)
inputUITitle:SetText("Paste your input")

-- ScrollFrame
local inputUIScrollFrame = CreateFrame("ScrollFrame", nil, IzC_WB.InputUI.Frame, "UIPanelScrollFrameTemplate")
inputUIScrollFrame:SetPoint("TOPLEFT", 16, -50)
inputUIScrollFrame:SetPoint("BOTTOMRIGHT", -30, 50)
inputUIScrollFrame:SetHeight(360)

-- EditBox inside ScrollFrame
local inputUIEditBox = CreateFrame("EditBox", nil, inputUIScrollFrame, "BackdropTemplate")
inputUIEditBox:SetBackdrop({
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
inputUIEditBox:SetBackdropColor(0, 0, 0, 0.8)
inputUIEditBox:SetMultiLine(true)
inputUIEditBox:SetFontObject(ChatFontNormal)
inputUIEditBox:SetWidth(440)
inputUIEditBox:SetAutoFocus(true)
inputUIEditBox:SetScript("OnEscapePressed", function() inputUIEditBox:ClearFocus();inputUIEditBox:SetText("");IzC_WB.AddonFrame:Hide(); end)
inputUIEditBox:SetScript("OnEnterPressed", function() inputUIEditBox:Insert("\n") end)
inputUIEditBox:SetPoint("TOPLEFT")
inputUIEditBox:SetPoint("TOPRIGHT")
inputUIEditBox:SetHeight(300)

inputUIScrollFrame:SetScrollChild(inputUIEditBox)

-- Parse Button
local inputUIParseButton = CreateFrame("Button", nil, IzC_WB.InputUI.Frame, "GameMenuButtonTemplate")
inputUIParseButton:SetPoint("BOTTOM", 0, 10)
inputUIParseButton:SetSize(120, 25)
inputUIParseButton:SetText("Parse Input")
inputUIParseButton:SetScript("OnClick", function()
    local text = inputUIEditBox:GetText()
    if text and text ~= "" then
        IzC_WB:ProcessRawInput(text);
    end
    inputUIEditBox:SetText("")
    IzC_WB.AddonFrame:Hide();
end)

IzC_WB.InputUI.Frame:Hide();
