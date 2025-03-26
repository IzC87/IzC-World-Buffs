-- Globals Section
local addonName, L = ...;

IzC_WB.InputFrame = CreateFrame("Frame", "MyInputFrame", UIParent, "BackdropTemplate")
IzC_WB.InputFrame:SetSize(500, 400)
IzC_WB.InputFrame:SetPoint("CENTER")
IzC_WB.InputFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 8, right = 8, top = 8, bottom = 8 }
})
IzC_WB.InputFrame:SetMovable(true)
IzC_WB.InputFrame:EnableMouse(true)
IzC_WB.InputFrame:RegisterForDrag("LeftButton")
IzC_WB.InputFrame:SetScript("OnDragStart", IzC_WB.InputFrame.StartMoving)
IzC_WB.InputFrame:SetScript("OnDragStop", IzC_WB.InputFrame.StopMovingOrSizing)

-- Title
local title = IzC_WB.InputFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOP", 0, -16)
title:SetText("Paste your input")

-- ScrollFrame
local scrollFrame = CreateFrame("ScrollFrame", "MyInputScrollFrame", IzC_WB.InputFrame, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", 16, -50)
scrollFrame:SetPoint("BOTTOMRIGHT", -30, 50)
scrollFrame:SetHeight(800)

-- EditBox inside ScrollFrame
local IzC_WB_editBox = CreateFrame("EditBox", nil, scrollFrame, "BackdropTemplate")
IzC_WB_editBox:SetBackdrop({
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
IzC_WB_editBox:SetBackdropColor(0, 0, 0, 0.8)
IzC_WB_editBox:SetMultiLine(true)
IzC_WB_editBox:SetFontObject(ChatFontNormal)
IzC_WB_editBox:SetWidth(440)
IzC_WB_editBox:SetAutoFocus(true)
IzC_WB_editBox:SetScript("OnEscapePressed", function() IzC_WB_editBox:ClearFocus() end)
IzC_WB_editBox:SetScript("OnEnterPressed", function() IzC_WB_editBox:Insert("\n") end)
IzC_WB_editBox:SetPoint("TOPLEFT")
IzC_WB_editBox:SetPoint("TOPRIGHT")
IzC_WB_editBox:SetHeight(1200)

scrollFrame:SetScrollChild(IzC_WB_editBox)

-- Close Button
local closeButton = CreateFrame("Button", nil, IzC_WB.InputFrame, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", -6, -6)

-- Parse Button
local parseButton = CreateFrame("Button", nil, IzC_WB.InputFrame, "GameMenuButtonTemplate")
parseButton:SetPoint("BOTTOM", 0, 10)
parseButton:SetSize(120, 25)
parseButton:SetText("Parse Input")
parseButton:SetScript("OnClick", function()
    local text = IzC_WB_editBox:GetText()
    if text and text ~= "" then
        IzC_WB:ProcessRawInput(text);
    end
    IzC_WB_editBox:SetText("")
    IzC_WB.InputFrame:Hide();
end)

IzC_WB.InputFrame:Hide()
