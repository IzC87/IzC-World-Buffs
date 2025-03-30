-- Globals Section
local addonName, L = ...;

IzC_WB.ExportBuffsUI = {};
-- -- Buffs Tab Button
IzC_WB.ExportBuffsUI.TabButton = CreateFrame("Button", "IzC_WB.ExportonFrameTab4", IzC_WB.AddonFrame, "CharacterFrameTabButtonTemplate")
IzC_WB.ExportBuffsUI.TabButton:SetPoint("BOTTOMRIGHT", -120, -19)
IzC_WB.ExportBuffsUI.TabButton:SetSize(120, 25)
IzC_WB.ExportBuffsUI.TabButton:SetText("Export Buffs")
IzC_WB.ExportBuffsUI.TabButton:SetScript("OnClick", function()
    IzC_WB.BuffsUI.Frame:Hide();
    IzC_WB.InputUI.Frame:Hide();
    IzC_WB.AddBuffsUI.Frame:Hide();
    IzC_WB.ExportBuffsUI.Frame:Show();
end)

IzC_WB.AddonFrame:SetScript("OnShow", function()
    IzC_WB.ExportBuffsUI.EditBox:UpdateText()
end)

IzC_WB.ExportBuffsUI.Frame = CreateFrame("Frame", "TabPage4", IzC_WB.AddonFrame)
IzC_WB.ExportBuffsUI.Frame:SetSize(500, 400)
IzC_WB.ExportBuffsUI.Frame:SetPoint("CENTER")
local exportBuffsUITitle = IzC_WB.ExportBuffsUI.Frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
exportBuffsUITitle:SetPoint("TOP", 0, -16)
exportBuffsUITitle:SetText("Export Buff")

IzC_WB.ExportBuffsUI.Frame:Hide();


-- ScrollFrame
local exportUIScrollFrame = CreateFrame("ScrollFrame", nil, IzC_WB.ExportBuffsUI.Frame, "UIPanelScrollFrameTemplate")
exportUIScrollFrame:SetPoint("TOPLEFT", 16, -50)
exportUIScrollFrame:SetPoint("BOTTOMRIGHT", -30, 50)
exportUIScrollFrame:SetHeight(360)

-- EditBox inside ScrollFrame
IzC_WB.ExportBuffsUI.EditBox = CreateFrame("EditBox", nil, exportUIScrollFrame, "BackdropTemplate")
IzC_WB.ExportBuffsUI.EditBox:SetBackdrop({
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
IzC_WB.ExportBuffsUI.EditBox:SetBackdropColor(0, 0, 0, 0.8)
IzC_WB.ExportBuffsUI.EditBox:SetMultiLine(true)
IzC_WB.ExportBuffsUI.EditBox:SetFontObject(ChatFontNormal)
IzC_WB.ExportBuffsUI.EditBox:SetWidth(440)
IzC_WB.ExportBuffsUI.EditBox:SetAutoFocus(false)
IzC_WB.ExportBuffsUI.EditBox:SetScript("OnEscapePressed", function() IzC_WB.ExportBuffsUI.EditBox:ClearFocus();IzC_WB.AddonFrame:Hide(); end)
IzC_WB.ExportBuffsUI.EditBox:SetScript("OnEnterPressed", function() IzC_WB.ExportBuffsUI.EditBox:Insert("\n") end)
IzC_WB.ExportBuffsUI.EditBox:SetPoint("TOPLEFT")
IzC_WB.ExportBuffsUI.EditBox:SetPoint("TOPRIGHT")
IzC_WB.ExportBuffsUI.EditBox:SetHeight(300)

exportUIScrollFrame:SetScrollChild(IzC_WB.ExportBuffsUI.EditBox)

-- Parse Button
local exportUIParseButton = CreateFrame("Button", nil, IzC_WB.ExportBuffsUI.Frame, "GameMenuButtonTemplate")
exportUIParseButton:SetPoint("BOTTOM", 0, 10)
exportUIParseButton:SetSize(120, 25)
exportUIParseButton:SetText("Refresh")
exportUIParseButton:SetScript("OnClick", function()
    IzC_WB.ExportBuffsUI.EditBox:UpdateText()
end)


function IzC_WB.ExportBuffsUI.EditBox:UpdateText()
    IzC_WB.ExportBuffsUI.EditBox:SetText(IzC_WB.ExportBuffsUI.EditBox:GetText())
end

function IzC_WB.ExportBuffsUI.EditBox:GetText()

    local content = "";

    local buffs = IzC_WB:SortBuffsByTime();
    local nextDay = time( { year = tonumber(date("%Y")), month = tonumber(date("%m")), day = tonumber(date("%d")) }) + 24 * 60 * 60;


    for _,buff in ipairs(buffs) do
        -- Next day, dont show
        if (buff.Time > nextDay) then
            return content;
        end
        -- Don't show buffs that have passed
        if (IzC_WB:ShowBuff(buff) == true) then
            local dateString = date("%H:%M", buff.Time)
            content = content..buff.Buff.." - "..buff.Faction.." - "..dateString.."\n"
        end
    end

    return content;
end
