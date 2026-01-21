local _, Ether = ...
local tinsert, tsort, tconcat = table.insert, table.sort, table.concat
local playerName, realmName = UnitName("player"), GetRealmName()
local pairs, ipairs = pairs, ipairs
local math_min, math_max = math.min, math.max

local backDrop = {
    bgFile = "Interface\\Buttons\\UI-SliderBar-Background",
    edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
    tile = true,
    tileSize = 8,
    edgeSize = 8,
    insets = {
        left = 3,
        right = 3,
        top = 6,
        bottom = 6
    }
}

local function GetFont(_, target, tex, numb)
    target.label = target:CreateFontString(nil, "OVERLAY")
    target.label:SetFont(unpack(Ether.mediaPath.Font), numb, "OUTLINE")
    target.label:SetText(tex)
    return target.label
end

local function IsInBattleground()
    local _, instanceType = IsInInstance()
    return instanceType == "pvp" or instanceType == "arena"
end

function Ether.CreateModuleSection(self)

    local parent = self.Content.Children["Module"]
    local modulesValue = {
        [1] = { name = "Icon" }
    }

    local mod = CreateFrame("Frame", nil, parent)
    mod:SetSize(200, (#modulesValue * 30) + 60)

    for i, opt in ipairs(modulesValue) do
        local btn = CreateFrame('CheckButton', nil, mod, 'OptionsBaseCheckButtonTemplate')

        if i == 1 then
            btn:SetPoint("TOPLEFT", parent, 20, -20)
        else
            btn:SetPoint("TOPLEFT", self.Content.Buttons.Module.A[i - 1], "BOTTOMLEFT", 0, 0)
        end

        btn:SetSize(24, 24)

        GetFont(self, btn, opt.name, 12)

        btn.label:SetPoint("LEFT", btn, "RIGHT", 10, 0)
        btn:SetChecked(Ether.DB[401][i] == 1)

        btn:SetScript("OnClick", function(self)
            local checked = self:GetChecked()
            Ether.DB[401][i] = checked and 1 or 0
            if i == 1 then
                local LDI = LibStub("LibDBIcon-1.0")
                if Ether.DB[401][1] == 1 then
                    LDI:Show("EtherIcon")
                    ETHER_ICON.hide = false
                else
                    LDI:Hide("EtherIcon")
                    ETHER_ICON.hide = true
                end
            end
        end)

        self.Content.Buttons.Module.A[i] = btn
    end

end

function Ether.CreateSlashSection(self)

    local slash = GetFont(self, self.Content.Children["Slash"], "|cffffff00Slash Commands|r", 15)
    slash:SetPoint("TOP", 0, -20)

    local lastY = -20
    for _, entry in ipairs(Ether.SlashInfo) do
        local fs = GetFont(self, self.Content.Children["Slash"], string.format("%s  –  %s", entry.cmd, entry.desc), 12)
        fs:SetPoint("TOP", slash, "BOTTOM", 0, lastY)
        lastY = lastY - 18
    end
end

function Ether.CreateHideSection(self)
    local parent = self.Content.Children["Hide"]
    local HideValue = {
        [1] = { name = "Blizzard Player frame" },
        [2] = { name = "Blizzard Pet frame" },
        [3] = { name = "Blizzard Target frame" },
        [4] = { name = "Blizzard Focus frame" },
        [5] = { name = "Blizzard CastBar" },
        [6] = { name = "Blizzard Party" },
        [7] = { name = "Blizzard Raid" },
        [8] = { name = "Blizzard Raid Manager" },
        [9] = { name = "Blizzard MicroMenu" },
        [10] = { name = "Blizzard MainStatusTrackingBarContainer" },
        [11] = { name = "Blizzard MainMenuBar" },
        [12] = { name = "Blizzard BagsBar" }
    }

    local hide = GetFont(self, parent, "|cffffff00Hide Blizzard Frames|r", 15)
    hide:SetPoint("TOP", 0, -10)

    local bF = CreateFrame("Frame", nil, parent)
    bF:SetSize(200, (#HideValue * 30) + 60)

    for i, opt in ipairs(HideValue) do
        local btn = CreateFrame("CheckButton", nil, bF, "InterfaceOptionsCheckButtonTemplate")

        if i == 1 then
            btn:SetPoint("TOPLEFT", hide, "BOTTOMLEFT", 0, -20)
        else
            btn:SetPoint("TOPLEFT", self.Content.Buttons.Hide[i - 1], "BOTTOMLEFT", 0, 0)
        end

        btn:SetSize(24, 24)

        btn.label = GetFont(self, btn, opt.name, 12)
        btn.label:SetPoint("LEFT", btn, "RIGHT", 8, 1)

        btn:SetChecked(Ether.DB[101][i] == 1)

        btn:SetScript("OnClick", function(self)
            local checked = self:GetChecked()
            Ether.DB[101][i] = checked and 1 or 0
        end)

        self.Content.Buttons.Hide[i] = btn
    end
end

function Ether.CreateSection(self)
    local parent = self.Content.Children["Create"]
    local CreateUnits = {
        [1] = { name = "|cffCC66FFPlayer|r", value = "PLAYER" },
        [2] = { name = "|cE600CCFFTarget|r", value = "TARGET" },
        [3] = { name = "Target of Target", value = "TARGETTARGET" },
        [4] = { name = "|cffCC66FFPlayer's Pet|r", value = "PET" },
        [5] = { name = "|cffCC66FFPlayers Pet Target|r", value = "PETTARGET" },
        [6] = { name = "|cff3399FFFocus|r", value = "FOCUS" },
        [7] = { name = "Party", value = "PARTY" },
        [8] = { name = "Raid", value = "RAID" },
        [9] = { name = "MainTank", value = "MAINTANK" }
    }

    local CreateAndBars = GetFont(self, parent, "|cffffff00Create/Delete Units|r", 15)
    CreateAndBars:SetPoint("TOP", 0, -10)

    local uF = CreateFrame('Frame', nil, parent)
    uF:SetSize(200, (#CreateUnits * 30) + 60)

    for i, opt in ipairs(CreateUnits) do
        local btn = CreateFrame("CheckButton", nil, uF, "InterfaceOptionsCheckButtonTemplate")

        if i == 1 then
            btn:SetPoint("TOPLEFT", CreateAndBars, "BOTTOMLEFT", 0, -20)
        else
            btn:SetPoint("TOP", self.Content.Buttons.Create.A[i - 1], "BOTTOM", 0, 0)
        end

        btn:SetSize(24, 24)

        btn.label = GetFont(self, btn, opt.name, 12)
        btn.label:SetPoint("LEFT", btn, "RIGHT", 8, 1)

        btn:SetChecked(Ether.DB[201][i] == 1)

        local unitKeys = {
            [1] = "player",
            [2] = "target",
            [3] = "targettarget",
            [4] = "pet",
            [5] = "pettarget",
            [6] = "focus"
        }

        local function unitFactory(index)
            if index > 6 then
                return
            end
            if Ether.DB[201][index] == 1 then
                Ether:CreateUnitButtons(unitKeys[index])
                if index == 3 then
                    Ether.targetOfTargetEvents()
                end
            elseif Ether.DB[201][index] == 0 then
                Ether:DestroyUnitButtons(unitKeys[index])
            end
        end

        btn:SetScript("OnClick", function(self)
            local checked = self:GetChecked()
            Ether.DB[201][i] = checked and 1 or 0
            unitFactory(i)
            if i == 7 then
                if not Ether.Buttons.party["player"] then
                    Ether:CreatePartyHeader()
                end
                if Ether.DB[201][7] == 1 then
                    Ether.Anchor.party:SetShown(true)
                else
                    Ether.Anchor.party:SetShown(false)
                end
            elseif i == 8 then
                Ether:CreateRaidHeader()
                if Ether.DB[201][8] == 1 then
                    Ether.Anchor.raid:SetShown(true)
                else
                    Ether.Anchor.raid:SetShown(false)
                end
            elseif i == 10 then
                if IsInBattleground() then
                    return
                end
                if not Ether.Buttons.maintank["raid1"] then
                    Ether:CreateMainTankHeader()
                end
                if Ether.DB[201][10] == 1 then
                    Ether.Anchor.maintank:SetShown(true)
                else
                    Ether.Anchor.maintank:SetShown(false)
                end
            end
        end)

        self.Content.Buttons.Create.A[i] = btn
    end

    local customUnits = GetFont(self, parent, "|cff00ff00Create Custom|r", 13)
    customUnits:SetPoint("TOPLEFT", self.Content.Buttons.Create.A[9], "BOTTOMLEFT", 0, -40)

    self.custom = CreateFrame("Button", nil, parent, "UIRadioButtonTemplate")
    self.custom:SetPoint("TOP", customUnits, "BOTTOM", 0, -20)
    self.custom:SetSize(20, 20)
    self.custom:SetScript("OnClick", function()
        if not UnitAffectingCombat("player") then
            Ether.CreateCustomUnit()
        end
    end)

    local DestroyUnit = GetFont(self, parent, "|cffff0000Destroy Custom|r", 13)
    DestroyUnit:SetPoint("LEFT", customUnits, "RIGHT", 40, 0)

    self.destroyCustom = CreateFrame("Button", nil, parent, "UIRadioButtonTemplate")
    self.destroyCustom:SetPoint("TOP", DestroyUnit, "BOTTOM", 0, -20)
    self.destroyCustom:SetSize(20, 20)
    self.destroyCustom:SetScript("OnClick", function()
        Ether.stopUpdateFunc()
    end)

end

local function ShowHideSingleAura(frame, bool)
    if not frame or not frame.Aura then
        return
    end
    for i = 1, 16 do
        if frame.Aura.Buffs and frame.Aura.Buffs[i] then
            frame.Aura.Buffs[i]:SetShown(bool)
        end
        if frame.Aura.Debuffs and frame.Aura.Debuffs[i] then
            frame.Aura.Debuffs[i]:SetShown(bool)
        end
    end

    if bool ~= true then
        wipe(frame.Aura.Buffs)
        wipe(frame.Aura.Debuffs)
        wipe(frame.Aura.LastBuffs)
        wipe(frame.Aura.LastDebuffs)
    end
end

local function GetTblText(buttons, tbl)
    for _, btn in pairs(buttons) do
        if btn[tbl] then
            btn[tbl]:SetText("")
        end
    end
end

local function resetHealthPowerText(value)
    if value == 1 then
        GetTblText(Ether["unitButtons"], "health")
    elseif value == 2 then
        GetTblText(Ether["unitButtons"], "power")
    elseif value == 3 then
        GetTblText(Ether.Buttons["party"], "health")
    elseif value == 4 then
        GetTblText(Ether.Buttons["party"], "power")
    elseif value == 5 then
        GetTblText(Ether.Buttons["raid"], "health")
    elseif value == 6 then
        GetTblText(Ether.Buttons["raid"], "power")
    end
end

function Ether.CreateUpdateSection(self)

    local parent = self.Content.Children["Updates"]

    local UpdateValue = {
        [1] = { text = "Health Solo" },
        [2] = { text = "Power Solo" },
        [3] = { text = "Health Party" },
        [4] = { text = "Power Party" },
        [5] = { text = "Raid Health" },
        [6] = { text = "Raid Power" }
    }
    local Update = GetFont(self, parent, "|cffffff00Health & Power Text:|r", 15)
    Update:SetPoint("TOPLEFT", 30, -10)

    local UpdateToggle = CreateFrame("Frame", nil, parent)
    UpdateToggle:SetSize(200, (#UpdateValue * 30) + 60)

    for i, opt in ipairs(UpdateValue) do
        local btn = CreateFrame("CheckButton", nil, UpdateToggle, "InterfaceOptionsCheckButtonTemplate")

        if i == 1 then
            btn:SetPoint("TOPLEFT", Update, "BOTTOMLEFT", 0, -20)
        else
            btn:SetPoint("TOPLEFT", self.Content.Buttons.Update.A[i - 1], "BOTTOMLEFT", 0, 0)
        end

        btn:SetSize(24, 24)

        btn.label = GetFont(self, btn, opt.text, 12)
        btn.label:SetPoint("LEFT", btn, "RIGHT", 10, 0)

        btn:SetChecked(Ether.DB[701][i] == 1)

        btn:SetScript("OnClick", function(self)
            local checked = self:GetChecked()
            Ether.DB[701][i] = checked and 1 or 0
            resetHealthPowerText(i)
        end)

        self.Content.Buttons.Update.A[i] = btn
    end

    local UnitEvents = {
        [1] = { text = "Player", value = "player" },
        [2] = { text = "Target", value = "target" },
        [3] = { text = "Target of Target", value = "targettarget" },
        [4] = { text = "Pet", value = "pet" },
        [5] = { text = "Pet Target", value = "pettarget" },
        [6] = { text = "Focus", value = "focus" },
        [7] = { text = "Party", value = "party" },
        [8] = { text = "Raid", value = "raid" },
        [9] = { text = "Main Tanks", value = "maintank" }
    }

    local Events = GetFont(self, parent, "|cffffff00Unit Events|r", 15)
    Events:SetPoint("TOP", 40, -10)

    local EventsToggle = CreateFrame("Frame", nil, parent)
    EventsToggle:SetSize(200, (#UnitEvents * 30) + 60)

    for i, opt in ipairs(UnitEvents) do
        local btn = CreateFrame("CheckButton", nil, EventsToggle, "InterfaceOptionsCheckButtonTemplate")

        if i == 1 then
            btn:SetPoint("TOPLEFT", Events, "BOTTOMLEFT", 0, -20)
        else
            btn:SetPoint("TOPLEFT", self.Content.Buttons.Update.B[i - 1], "BOTTOMLEFT", 0, 0)
        end

        btn:SetSize(24, 24)

        btn.label = GetFont(self, btn, opt.text, 12)
        btn.label:SetPoint("LEFT", btn, "RIGHT", 10, 0)

        btn:SetChecked(Ether.DB[901][opt.value])

        btn:SetScript("OnClick", function(self)
            local checked = self:GetChecked()
            Ether.DB[901][opt.value] = checked
        end)

        self.Content.Buttons.Update.B[i] = btn
    end

    local smoothValue = {
        [1] = { text = "Smooth healthBar on Single Units", value = "SMOOTH_HEALTH_SINGLE" },
        [2] = { text = "Smooth powerBar on Single Units", value = "SMOOTH_POWER_SINGLE" },
        [3] = { text = "Smooth healthBar on Raid Units", value = "SMOOTH_HEALTH_RAID" },
    }

    local Style = GetFont(self, parent, "|cffffff00Smooth Bars|r", 15)
    Style:SetPoint("TOPLEFT", self.Content.Buttons.Update.A[6], "BOTTOMLEFT", 0, -72)

    local cpu = GetFont(self, parent, "|cffb22222High CPU usage|r", 15)
    cpu:SetPoint("TOPLEFT", Style, "BOTTOMLEFT", 0, -10)

    local StyleToggle = CreateFrame("Frame", nil, parent)
    StyleToggle:SetSize(200, (#smoothValue * 30) + 60)

    for i, opt in ipairs(smoothValue) do
        local btn = CreateFrame("CheckButton", nil, StyleToggle, "InterfaceOptionsCheckButtonTemplate")

        if i == 1 then
            btn:SetPoint("TOPLEFT", cpu, "BOTTOMLEFT", 0, -20)
        else
            btn:SetPoint("TOPLEFT", self.Content.Buttons.Update.C[i - 1], "BOTTOMLEFT", 0, 0)
        end

        btn:SetSize(24, 24)

        btn.label = GetFont(self, btn, opt.text, 12)
        btn.label:SetPoint("LEFT", btn, "RIGHT", 10, 0)

        btn:SetChecked(Ether.DB[2001][opt.value])

        btn:SetScript("OnClick", function(self)
            local checked = self:GetChecked()
            Ether.DB[2001][opt.value] = checked
        end)
        self.Content.Buttons.Update.C[i] = btn
    end
end

function Ether.CreateAuraSettingsSection(self)
    local parent = self.Content.Children["Aura Settings"]

    local AurasPredefined = {
        [1] = { text = "Weakened Soul - Debuff", value = 6788 }
    }

    local CreateAura = {
        [1] = { text = "Player Aura" },
        [2] = { text = "Target Aura" },
        [3] = { text = "Raid Aura" }
    }

    local CreateAuras = GetFont(self, parent, "|cffffff00Update Auras|r", 15)
    CreateAuras:SetPoint("TOPLEFT", 30, -10)

    local CreateAurasToggle = CreateFrame("Frame", nil, parent)
    CreateAurasToggle:SetSize(200, (#CreateAura * 30) + 60)

    for i, opt in ipairs(CreateAura) do
        local btn = CreateFrame("CheckButton", nil, CreateAurasToggle, "InterfaceOptionsCheckButtonTemplate")

        if i == 1 then
            btn:SetPoint("TOPLEFT", CreateAuras, "BOTTOMLEFT", 0, -20)
        else
            btn:SetPoint("TOPLEFT", self.Content.Buttons.Auras.A[i - 1], "BOTTOMLEFT", 0, 0)
        end

        btn:SetSize(24, 24)

        btn.label = GetFont(self, btn, opt.text, 12)
        btn.label:SetPoint("LEFT", btn, "RIGHT", 10, 0)

        btn:SetChecked(Ether.DB[1001][1002][i] == 1)
        btn:SetScript("OnClick", function(self)
            local checked = self:GetChecked()
            Ether.DB[1001][1002][i] = checked and 1 or 0
            if i == 1 then
                if Ether.DB[1001][1002][1] == 1 then
                    Ether.Aura.SingleAuraFullInitial(Ether.unitButtons["player"])
                    ShowHideSingleAura(Ether.unitButtons["player"], true)
                else
                    ShowHideSingleAura(Ether.unitButtons["player"], false)
                end
            elseif i == 2 then
                if Ether.DB[1001][1002][2] == 1 then
                    Ether.Aura.SingleAuraFullInitial(Ether.unitButtons["target"])
                    ShowHideSingleAura(Ether.unitButtons["target"], true)
                else
                    ShowHideSingleAura(Ether.unitButtons["target"], false)
                end
            end
        end)

        self.Content.Buttons.Auras.A[i] = btn
    end
end

local selectedSpellId = nil

local AuraList
local AuraButtons = {}

local function CreateAuraList(parent)
    local frame = CreateFrame("Frame", nil, parent)
    AuraList = frame
    AuraList:SetPoint("TOPLEFT")
    AuraList:SetSize(210, 390)

    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0, 0, 0, 0.4)

    local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT")
    scrollFrame:SetPoint("BOTTOMRIGHT", -25, 45)

    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(190, 1)
    scrollFrame:SetScrollChild(scrollChild)
    AuraList.scrollChild = scrollChild

    local addBtn = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
    addBtn:SetSize(100, 30)
    addBtn:SetPoint("BOTTOM", 0, 5)
    addBtn:SetText("New Aura")
    addBtn:SetNormalFontObject("GameFontWhiteSmall")
    addBtn:SetScript("OnClick", function()
        Ether.AddNewAura()
    end)

    return frame
end

local Editor

local function CreateEditor(parent)
    local frame = CreateFrame("Frame", nil, parent)
    Editor = frame
    frame:SetPoint("TOPLEFT", AuraList, "TOPRIGHT")
    frame:SetSize(380, 390)

    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0, 0, 0, 0.4)

    local name = frame:CreateFontString(nil, "OVERLAY")
    frame.nameLabel = name
    name:SetFont(unpack(Ether.mediaPath.Font), 10, "OUTLINE")
    name:SetPoint("TOPLEFT", 15, -5)
    name:SetText("Name")

    local nameInput = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    frame.nameInput = nameInput
    nameInput:SetSize(140, 30)
    nameInput:SetPoint("TOPLEFT", name, "BOTTOMLEFT")
    nameInput:SetAutoFocus(false)
    nameInput:SetScript("OnEnterPressed", function(self)
        if selectedSpellId then
            Ether.DB[1001][1003][selectedSpellId].name = self:GetText()
            Ether.UpdateAuraList()
        end
        self:ClearFocus()
    end)

    local spellID = frame:CreateFontString(nil, "OVERLAY")
    frame.spellIdLabel = spellID
    spellID:SetFont(unpack(Ether.mediaPath.Font), 10, "OUTLINE")
    spellID:SetPoint("TOPLEFT", nameInput, "BOTTOMLEFT")
    spellID:SetText("Spell ID")

    local spellIdInput = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    frame.spellIdInput = spellIdInput
    spellIdInput:SetSize(140, 30)
    spellIdInput:SetPoint("TOPLEFT", spellID, "BOTTOMLEFT")
    spellIdInput:SetAutoFocus(false)
    spellIdInput:SetNumeric(true)
    spellIdInput:SetScript("OnEnterPressed", function(self)
        local newId = tonumber(self:GetText())
        if selectedSpellId and newId and newId > 0 and newId ~= selectedSpellId then
            local data = Ether.DB[1001][1003][selectedSpellId]
            Ether.DB[1001][1003][selectedSpellId] = nil
            Ether.DB[1001][1003][newId] = data
            selectedSpellId = newId
            Ether.UpdateAuraList()
            Ether.UpdateEditor()
        end
        self:ClearFocus()
    end)

    local color = frame:CreateFontString(nil, "OVERLAY")
    frame.colorLabel = color
    color:SetFont(unpack(Ether.mediaPath.Font), 10, "OUTLINE")
    color:SetPoint("TOPLEFT", spellIdInput, "BOTTOMLEFT")
    color:SetText("Color")

    local colorBtn = CreateFrame("Button", nil, frame)
    frame.colorBtn = colorBtn
    colorBtn:SetSize(25, 25)
    colorBtn:SetPoint("TOPLEFT", color, "BOTTOMLEFT", 0, -10)
    frame.colorBtn.bg = colorBtn:CreateTexture(nil, "BACKGROUND")
    frame.colorBtn.bg:SetAllPoints()
    frame.colorBtn.bg:SetColorTexture(1, 1, 0, 1)
    frame.colorBtn:SetScript("OnClick", function()
        if selectedSpellId then
            local data = Ether.DB[1001][1003][selectedSpellId]
            ColorPickerFrame:SetColorRGB(data.color[1], data.color[2], data.color[3])
            ColorPickerFrame.previousValues = { data.color[1], data.color[2], data.color[3], data.color[4] }
            ColorPickerFrame.swatchFunc = function()
                local r, g, b = ColorPickerFrame:GetColorRGB()
                data.color[1] = r
                data.color[2] = g
                data.color[3] = b
                frame.colorBtn.bg:SetColorTexture(r, g, b, data.color[4])
                Ether.UpdateAuraList()
            end
            ColorPickerFrame.opacityFunc = function()
                local a = OpacitySliderFrame:GetValue()
                data.color[4] = a
                frame.colorBtn.bg:SetColorTexture(data.color[1], data.color[2], data.color[3], a)
                Ether.UpdateAuraList()
            end
            ColorPickerFrame.cancelFunc = function()
                local prev = ColorPickerFrame.previousValues
                data.color[1] = prev[1]
                data.color[2] = prev[2]
                data.color[3] = prev[3]
                data.color[4] = prev[4]
                frame.colorBtn.bg:SetColorTexture(prev[1], prev[2], prev[3], prev[4])
                Ether.UpdateAuraList()
            end
            ColorPickerFrame.hasOpacity = true
            ColorPickerFrame.opacity = data.color[4]
            ColorPickerFrame:Show()
        end
    end)

    local rgbText = frame:CreateFontString(nil, "OVERLAY")
    frame.rgbText = rgbText
    rgbText:SetFont(unpack(Ether.mediaPath.Font), 10, "OUTLINE")
    rgbText:SetPoint("LEFT", color, "RIGHT", 10, 0)
    rgbText:SetText("RGB: 255, 255, 0")

    local sizeLabel = frame:CreateFontString(nil, "OVERLAY")
    frame.sizeLabel = sizeLabel
    sizeLabel:SetFont(unpack(Ether.mediaPath.Font), 10, "OUTLINE")
    sizeLabel:SetPoint("TOPLEFT", colorBtn, "BOTTOMLEFT", 0, -60)
    sizeLabel:SetText("Size")

    local sizeSlider = CreateFrame("Slider", nil, frame, "OptionsSliderTemplate")
    frame.sizeSlider = sizeSlider
    sizeSlider:SetPoint("TOPLEFT", sizeLabel, "BOTTOMLEFT")
    sizeSlider:SetWidth(140)
    sizeSlider:SetMinMaxValues(4, 20)
    sizeSlider:SetValueStep(1)
    sizeSlider:SetObeyStepOnDrag(true)
    sizeSlider.Low:SetText("4")
    sizeSlider.High:SetText("20")
    sizeSlider:SetScript("OnValueChanged", function(self, value)
        if selectedSpellId then
            Ether.DB[1001][1003][selectedSpellId].size = value
            frame.sizeValue:SetText(string.format("%.0f px", value))
            Ether.UpdatePreview()
        end
    end)

    local sizeValue = frame:CreateFontString(nil, "OVERLAY")
    frame.sizeValue = sizeValue
    sizeValue:SetFont(unpack(Ether.mediaPath.Font), 10, "OUTLINE")
    sizeValue:SetPoint("TOP", sizeSlider, "BOTTOM", 0, -5)
    sizeValue:SetText("6 px")

    local positions = {
        { "TOPLEFT", "TOP", "TOPRIGHT" },
        { "LEFT", "CENTER", "RIGHT" },
        { "BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT" }
    }

    frame.posButtons = {}
    local startX, startY = 180, -100
    local btnSize = 25

    for row = 1, 3 do
        for col = 1, 3 do
            local pos = positions[row][col]
            local btn = CreateFrame("Button", nil, frame)
            btn:SetSize(btnSize, btnSize)
            btn:SetPoint("TOPLEFT", startX + (col - 1) * (btnSize + 1), startY - (row - 1) * (btnSize + 1))

            btn.bg = btn:CreateTexture(nil, "BACKGROUND")
            btn.bg:SetAllPoints()
            btn.bg:SetColorTexture(0.2, 0.2, 0.2, 0.8)

            btn.text = btn:CreateFontString(nil, "OVERLAY")
            btn.text:SetFontObject("GameFontNormalSmall")
            btn.text:SetPoint("CENTER")
            btn.text:SetText(pos:sub(1, 1))

            btn.position = pos
            btn:SetScript("OnClick", function(self)
                if selectedSpellId then
                    Ether.DB[1001][1003][selectedSpellId].position = self.position
                    Ether.UpdateEditor()
                    Ether.UpdatePreview()
                end
            end)

            btn:SetScript("OnEnter", function(self)
                self.bg:SetColorTexture(0.3, 0.3, 0.3, 0.9)
            end)
            btn:SetScript("OnLeave", function(self)
                local data = selectedSpellId and Ether.DB[1001][1003][selectedSpellId]
                if data and data.position == self.position then
                    self.bg:SetColorTexture(0.8, 0.6, 0, 0.8)
                else
                    self.bg:SetColorTexture(0.2, 0.2, 0.2, 0.8)
                end
            end)

            frame.posButtons[pos] = btn
        end
    end

    local offsetXLabel = frame:CreateFontString(nil, "OVERLAY")
    frame.offsetXLabel = offsetXLabel
    offsetXLabel:SetFont(unpack(Ether.mediaPath.Font), 10, "OUTLINE")
    offsetXLabel:SetPoint("TOPLEFT", sizeLabel, "BOTTOMLEFT", 0, -50)
    offsetXLabel:SetText("X Offset")

    local offsetXSlider = CreateFrame("Slider", nil, frame, "OptionsSliderTemplate")
    frame.offsetXSlider = offsetXSlider
    offsetXSlider:SetPoint("TOPLEFT", offsetXLabel, "BOTTOMLEFT")
    offsetXSlider:SetWidth(140)
    offsetXSlider:SetMinMaxValues(-20, 20)
    offsetXSlider:SetValueStep(1)
    offsetXSlider:SetObeyStepOnDrag(true)
    offsetXSlider:SetScript("OnValueChanged", function(self, value)
        if selectedSpellId then
            Ether.DB[1001][1003][selectedSpellId].offsetX = value
            frame.offsetXValue:SetText(string.format("%.0f", value))
            Ether.UpdatePreview()
        end
    end)

    local offsetYLabel = frame:CreateFontString(nil, "OVERLAY")
    frame.offsetYLabel = offsetYLabel
    offsetYLabel:SetFont(unpack(Ether.mediaPath.Font), 10, "OUTLINE")
    offsetYLabel:SetPoint("TOPLEFT", offsetXLabel, "BOTTOMLEFT", 0, -50)
    offsetYLabel:SetText("Y Offset")

    local offsetYSlider = CreateFrame("Slider", nil, frame, "OptionsSliderTemplate")
    frame.offsetYSlider = offsetYSlider
    offsetYSlider:SetPoint("TOPLEFT", offsetYLabel, "BOTTOMLEFT")
    offsetYSlider:SetWidth(140)
    offsetYSlider:SetMinMaxValues(-20, 20)
    offsetYSlider:SetValueStep(1)
    offsetYSlider:SetObeyStepOnDrag(true)
    offsetYSlider:SetScript("OnValueChanged", function(self, value)
        if selectedSpellId then
            Ether.DB[1001][1003][selectedSpellId].offsetY = value
            frame.offsetYValue:SetText(string.format("%.0f", value))
            Ether.UpdatePreview()
        end
    end)

    local offsetXValue = frame:CreateFontString(nil, "OVERLAY")
    frame.offsetXValue = offsetXValue
    offsetXValue:SetFont(unpack(Ether.mediaPath.Font), 10, "OUTLINE")
    offsetXValue:SetPoint("TOP", offsetXSlider, "BOTTOM")
    offsetXValue:SetText("0")

    local offsetYValue = frame:CreateFontString(nil, "OVERLAY")
    frame.offsetYValue = offsetYValue
    offsetYValue:SetFont(unpack(Ether.mediaPath.Font), 10, "OUTLINE")
    offsetYValue:SetPoint("TOP", offsetYSlider, "BOTTOM")
    offsetYValue:SetText("0")

    local preview = CreateFrame("Frame", nil, frame)
    frame.preview = preview
    preview:SetPoint("TOPLEFT", colorBtn, "TOPRIGHT", 40, 0)
    preview:SetSize(55, 55)

    local healthBar = CreateFrame("StatusBar", nil, preview)
    healthBar:SetFrameLevel(preview:GetFrameLevel() - 1)
    preview.healthBar = healthBar
    healthBar:SetPoint("BOTTOMLEFT")
    healthBar:SetSize(55, 55)
    healthBar:SetStatusBarTexture(unpack(Ether.mediaPath.StatusBar))

    preview.indicator = preview:CreateTexture(nil, "OVERLAY")
    preview.indicator:SetSize(6, 6)
    preview.indicator:SetPoint("TOP", healthBar, "TOP", 0, 0)
    preview.indicator:SetColorTexture(1, 1, 0, 1)

    return frame
end

local IsCreated = false
function Ether.CreateAuraCustomSection(self)
    local parent = self.Content.Children["Aura Custom"]
    if not IsCreated then
        IsCreated = true
        CreateAuraList(parent)
        CreateEditor(parent)
        Ether.UpdateAuraList()
        Ether.UpdateEditor()
    end
end

function Ether.UpdateAuraList()

    for _, btn in ipairs(AuraButtons) do
        btn:Hide()
        btn:SetParent(nil)
    end

    wipe(AuraButtons)

    local yOffset = -5
    local index = 1

    for spellId, data in pairs(Ether.DB[1001][1003]) do
        local btn = CreateFrame("Button", nil, AuraList.scrollChild)
        btn:SetSize(180, 40)
        btn:SetPoint("TOP", 0, yOffset)

        btn.bg = btn:CreateTexture(nil, "BACKGROUND")
        btn.bg:SetAllPoints()
        btn.bg:SetColorTexture(0.1, 0.1, 0.1, 0.8)

        btn:SetScript("OnEnter", function(self)
            self.bg:SetColorTexture(0.2, 0.2, 0.2, 0.9)
        end)
        btn:SetScript("OnLeave", function(self)
            if selectedSpellId == spellId then
                self.bg:SetColorTexture(0.3, 0.3, 0, 0.8)
            else
                self.bg:SetColorTexture(0.1, 0.1, 0.1, 0.8)
            end
        end)

        btn:SetScript("OnClick", function()
            Ether.SelectAura(spellId)
        end)

        btn.name = btn:CreateFontString(nil, "OVERLAY")
        btn.name:SetFontObject("GameFontNormal")
        btn.name:SetPoint("TOPLEFT", 10, -8)
        btn.name:SetText(data.name or "Unknown")

        btn.spellId = btn:CreateFontString(nil, "OVERLAY")
        btn.spellId:SetFontObject("GameFontNormalSmall")
        btn.spellId:SetPoint("TOPLEFT", 10, -23)
        btn.spellId:SetText("Spell ID: " .. spellId)
        btn.spellId:SetTextColor(0.7, 0.7, 0.7)

        btn.colorBox = btn:CreateTexture(nil, "OVERLAY")
        btn.colorBox:SetSize(16, 16)
        btn.colorBox:SetPoint("RIGHT", -10, 0)
        if data.color then
            btn.colorBox:SetColorTexture(data.color[1], data.color[2], data.color[3], data.color[4])
        end

        btn.deleteBtn = CreateFrame("Button", nil, btn)
        btn.deleteBtn:SetSize(20, 20)
        btn.deleteBtn:SetPoint("TOPRIGHT", -10, -5)
        btn.deleteBtn:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
        btn.deleteBtn:SetScript("OnClick", function(self)
            StaticPopup_Show("ETHER_DELETE_AURA", data.name or "this Aura", nil, spellId)
            self:GetParent():GetScript("OnLeave")(self:GetParent())
        end)
        StaticPopupDialogs["ETHER_DELETE_AURA"] = {
            text = "Destroy Aura ?",
            button1 = "Yes",
            button2 = "No",
            OnAccept = function(self, spellId)
                Ether.DB[1001][1003][spellId] = nil
                if selectedSpellId == spellId then
                    selectedSpellId = nil
                end
                Ether.UpdateAuraList()
                Ether.UpdateEditor()
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
        }
        btn.spellId = spellId
        tinsert(AuraButtons, btn)

        if selectedSpellId == spellId then
            btn.bg:SetColorTexture(0.3, 0.3, 0, 0.8)
        end
        yOffset = yOffset - 55
        index = index + 1
    end
    AuraList.scrollChild:SetHeight(math_max(1, index * 55))
end

function Ether.UpdateEditor()
    if not selectedSpellId or not Ether.DB[1001][1003][selectedSpellId] then
        Editor.nameInput:SetText("")
        Editor.nameInput:Disable()
        Editor.spellIdInput:SetText("")
        Editor.spellIdInput:Disable()
        Editor.colorBtn:Disable()
        Editor.sizeSlider:Disable()
        Editor.offsetXSlider:Disable()
        Editor.offsetYSlider:Disable()
        for _, btn in pairs(Editor.posButtons) do
            btn:Disable()
        end
        return
    end

    local data = Ether.DB[1001][1003][selectedSpellId]

    Editor.nameInput:SetText(data.name or "")
    Editor.nameInput:Enable()
    Editor.spellIdInput:SetText(tostring(selectedSpellId))
    Editor.spellIdInput:Enable()
    Editor.colorBtn:Enable()
    Editor.sizeSlider:Enable()
    Editor.offsetXSlider:Enable()
    Editor.offsetYSlider:Enable()

    Editor.colorBtn.bg:SetColorTexture(data.color[1], data.color[2], data.color[3], data.color[4])
    Editor.rgbText:SetText(string.format("RGB: %d, %d, %d",
            data.color[1] * 255, data.color[2] * 255, data.color[3] * 255))

    Editor.sizeSlider:SetValue(data.size)
    Editor.sizeValue:SetText(string.format("%.0f px", data.size))

    for pos, btn in pairs(Editor.posButtons) do
        if pos == data.position then
            btn.bg:SetColorTexture(0.8, 0.6, 0, 0.8)
            btn:Enable()
        else
            btn.bg:SetColorTexture(0.2, 0.2, 0.2, 0.8)
            btn:Enable()
        end
    end

    Editor.offsetXSlider:SetValue(data.offsetX)
    Editor.offsetXValue:SetText(string.format("%.0f", data.offsetX))
    Editor.offsetYSlider:SetValue(data.offsetY)
    Editor.offsetYValue:SetText(string.format("%.0f", data.offsetY))

    Ether.UpdatePreview()
end

function Ether.UpdatePreview()
    if not selectedSpellId then
        return
    end

    local data = Ether.DB[1001][1003][selectedSpellId]
    local indicator = Editor.preview.indicator

    indicator:SetSize(data.size, data.size)
    indicator:SetColorTexture(data.color[1], data.color[2], data.color[3], data.color[4])

    indicator:ClearAllPoints()

    local posMap = {
        TOPLEFT = { "TOPLEFT", data.offsetX, -data.offsetY },
        TOP = { "TOP", data.offsetX, -data.offsetY },
        TOPRIGHT = { "TOPRIGHT", data.offsetX, -data.offsetY },
        LEFT = { "LEFT", data.offsetX, -data.offsetY },
        CENTER = { "CENTER", data.offsetX, -data.offsetY },
        RIGHT = { "RIGHT", data.offsetX, -data.offsetY },
        BOTTOMLEFT = { "BOTTOMLEFT", data.offsetX, -data.offsetY },
        BOTTOM = { "BOTTOM", data.offsetX, -data.offsetY },
        BOTTOMRIGHT = { "BOTTOMRIGHT", data.offsetX, -data.offsetY }
    }

    local pos = posMap[data.position]
    if pos then
        indicator:SetPoint(pos[1], Editor.preview.healthBar, pos[1], pos[2], pos[3])
    end
end

function Ether.AddNewAura()
    local newId = 1
    while Ether.DB[1001][1003][newId] do
        newId = newId + 1
    end

    Ether.DB[1001][1003][newId] = {
        name = "New Aura " .. newId,
        color = { 1, 1, 0, 1 },
        size = 6,
        position = "TOP",
        offsetX = 0,
        offsetY = 0,
        enabled = true
    }

    Ether.SelectAura(newId)
end

function Ether.SelectAura(spellId)
    selectedSpellId = spellId
    Ether.UpdateAuraList()
    Ether.UpdateEditor()
end

function Ether.CreateRegisterSection(self)
    local parent = self.Content.Children["Register"]

    local I_Register = {
        [1] = { text = "Ready check, confirm and finished", texture = "Interface\\RaidFrame\\ReadyCheck-Ready" },
        [2] = { text = "Unit connection", texture = "Interface\\CharacterFrame\\Disconnect-Icon", size = 30 },
        [3] = { text = "Raid target update", texture = "Interface\\TargetingFrame\\UI-RaidTargetingIcons", size = 14, cor = { 0.75, 1, 0.25, 0.5 } },
        [4] = { text = "Incoming Resurrect changed", texture = "Interface\\RaidFrame\\Raid-Icon-Rez" },
        [5] = { text = "Party leader changed", texture = "Interface\\GroupFrame\\UI-Group-LeaderIcon" },
        [6] = { text = "Party loot method changed", texture = "Interface\\GroupFrame\\UI-Group-MasterLooter", size = 16 },
        [7] = { text = "|cffffa500Unit Flags|r" },
        [8] = { text = "|cffCC66FFPlayer roles assigned|r" },
        [9] = { text = "|cE600CCFFPlayer flags|r" }
    }

    local I_Enable = {
        [1] = { text = "|cffffa500Status|r - Charmed - |cffff0000 Red Name|r", texture = "136129", size = 16 },
        [2] = { text = "|cffffa500Status|r - Dead", texture = "Interface\\Icons\\Spell_Holy_SenseUndead", size = 16 },
        [3] = { text = "|cffffa500Status|r - Ghost", texture = "Interface\\Icons\\Spell_Holy_GuardianSpirit", size = 16 },
        [4] = { text = "|cffCC66FFStatus|r - Group Role", texture = "Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES", cor = { 0, 19 / 64, 22 / 64, 41 / 64 } },
        [5] = { text = "|cffCC66FFStatus|r - Maintank or mainassist", texture = "Interface\\GroupFrame\\UI-Group-MainTankIcon" },
        [6] = { text = "|cE600CCFFStatus|r - |cffff0000AFK|r" },
        [7] = { text = "|cE600CCFFStatus|r - |cffCC66FFDND|r" }
    }

    local DB = Ether.DB
    local iRegister = CreateFrame("Frame", nil, parent)
    iRegister:SetSize(200, (#I_Register * 30) + 60)

    for i, opt in ipairs(I_Register) do
        local btn = CreateFrame("CheckButton", nil, iRegister, "InterfaceOptionsCheckButtonTemplate")

        if i == 1 then
            btn:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, -10)
        else
            btn:SetPoint("TOPLEFT", self.Content.Buttons.Indicators.A[i - 1], "BOTTOMLEFT", 0, 0)
        end

        btn:SetSize(24, 24)

        btn.label = GetFont(self, btn, opt.text, 12)
        btn.label:SetPoint("LEFT", btn, "RIGHT", 10, 0)
        btn.texture = btn:CreateTexture(nil, "OVERLAY")
        btn.texture:SetSize(18, 18)
        btn.texture:SetPoint("LEFT", btn.label, "RIGHT", 10, 0)
        btn.texture:SetTexture(opt.texture)
        if opt.size then
            btn.texture:SetSize(opt.size, opt.size)
        end
        if opt.cor then
            btn.texture:SetTexCoord(unpack(opt.cor))
        end
        btn:SetChecked(DB[501][i] == 1)

        btn:SetScript("OnClick", function(self)
            local checked = self:GetChecked()
            Ether.DB[501][i] = checked and 1 or 0
            Ether.Indicators.GetIndicatorRegisterStatus(i)
            Ether.Indicators:Toggle()
            Ether.Indicators:UpdateIndicators()
        end)
        self.Content.Buttons.Indicators.A[i] = btn
    end

    local iEnable = CreateFrame("Frame", nil, parent)
    iEnable:SetSize(200, (#I_Enable * 30) + 60)

    for i, opt in ipairs(I_Enable) do
        local btn = CreateFrame("CheckButton", nil, iEnable, "InterfaceOptionsCheckButtonTemplate")

        if i == 1 then
            btn:SetPoint("TOPLEFT", self.Content.Buttons.Indicators.A[9], "BOTTOMLEFT", 80, -20)
        else
            btn:SetPoint("TOPLEFT", self.Content.Buttons.Indicators.B[i - 1], "BOTTOMLEFT", 0, 0)
        end

        btn:SetSize(24, 24)

        btn.label = GetFont(self, btn, opt.text, 12)
        btn.label:SetPoint("LEFT", btn, 'RIGHT', 10, 0)
        btn.texture = btn:CreateTexture(nil, "OVERLAY")
        btn.texture:SetSize(18, 18)
        btn.texture:SetPoint("LEFT", btn.label, "RIGHT", 10, 0)
        btn.texture:SetTexture(opt.texture or tonumber(opt.texture))

        if opt.size then
            btn.texture:SetSize(opt.size, opt.size)
        end
        if opt.cor then
            btn.texture:SetTexCoord(unpack(opt.cor))
        end

        btn:SetChecked(Ether.DB[601][i] == 1)

        btn:SetScript("OnClick", function(self)
            local checked = self:GetChecked()
            Ether.DB[601][i] = checked and 1 or 0
            Ether.Indicators.GetIndicatorEnabledStatus(i)
        end)

        self.Content.Buttons.Indicators.B[i] = btn
    end
end

function Ether.CreateLayoutSection(self)
    local parent = self.Content.Children["Layout"]

    local layoutValue = {
        [1] = { text = "Create/Delete Player CastBar", value = "PLAYER_BAR" },
        [2] = { text = "Create/Delete Target CastBar", value = "TARGET_BAR" },
    }

    local layout = CreateFrame("Frame", nil, parent)
    layout:SetSize(200, (#layoutValue * 30) + 60)

    for i, opt in ipairs(layoutValue) do
        local btn = CreateFrame("CheckButton", nil, layout, "InterfaceOptionsCheckButtonTemplate")

        if i == 1 then
            btn:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, -10)
        else
            btn:SetPoint("TOPLEFT", self.Content.Buttons.Layout.B[i - 1], "BOTTOMLEFT", 0, 0)
        end

        btn:SetSize(24, 24)

        btn.label = GetFont(self, btn, opt.text, 12)
        btn.label:SetPoint("LEFT", btn, "RIGHT", 10, 0)

        btn:SetChecked(Ether.DB[2001][opt.value])

        btn:SetScript("OnClick", function(self)
            local checked = self:GetChecked()
            Ether.DB[2001][opt.value] = checked
            if opt.value == "PLAYER_BAR" then
                Ether.CastBar.StatusCastBar("PLAYER_BAR", "player")
            elseif opt.value == "TARGET_BAR" then
                Ether.CastBar.StatusCastBar("TARGET_BAR", "target")
            end
        end)

        self.Content.Buttons.Layout.B[i] = btn
    end
end

function Ether.CreateRangeSection(self)
    local parent = self.Content.Children["Range"]

    local rangeValue = {
        [1] = { name = "Enable Range" }
    }

    local layout = CreateFrame("Frame", nil, parent)
    layout:SetSize(200, (#rangeValue * 30) + 60)

    for i, opt in ipairs(rangeValue) do
        local btn = CreateFrame("CheckButton", nil, layout, "InterfaceOptionsCheckButtonTemplate")

        if i == 1 then
            btn:SetPoint("TOP", parent, "TOPLEFT", 20, -10)
        else
            btn:SetPoint("TOPLEFT", self.Content.Buttons.Layout.C[i - 1], "BOTTOMLEFT", 0, 0)
        end

        btn:SetSize(24, 24)

        btn.label = GetFont(self, btn, opt.name, 12)
        btn.label:SetPoint("LEFT", btn, "RIGHT", 10, 0)

        btn:SetChecked(Ether.DB[801][i] == 1)

        btn:SetScript("OnClick", function(self)
            local checked = self:GetChecked()
            Ether.DB[801][i] = checked and 1 or 0
            if i == 1 then
                if Ether.DB[801][1] == 1 then
                    Ether.Range:Enable()
                else
                    Ether.Range:Disable()
                end
            end
        end)
        self.Content.Buttons.Layout.C[i] = btn
    end
end

function Ether.CreateTooltipSection(self)
    local parent = self.Content.Children["Tooltip"]

    local Tooltip = {
        [1] = { name = "Enabled" },
        [2] = { name = "AFK" },
        [3] = { name = "DND" },
        [4] = { name = "PVP Icon" },
        [5] = { name = "Resting Icon" },
        [6] = { name = "Realm" },
        [7] = { name = "Only different realms" },
        [8] = { name = "Level" },
        [9] = { name = "Class" },
        [10] = { name = "Guild" },
        [11] = { name = "Role" },
        [12] = { name = "Creature Type" },
        [13] = { name = "Race", },
        [14] = { name = "Raid Target" },
        [15] = { name = "Reaction" }
    }

    local tTip = GetFont(self, parent, "|cffffd700Tooltip Options:|r", 15)
    tTip:SetPoint("TOPLEFT", 20, -20)

    local mF = CreateFrame("Frame", nil, parent)
    mF:SetSize(200, (#Tooltip * 30) + 60)

    for i, opt in ipairs(Tooltip) do
        local btn = CreateFrame("CheckButton", nil, mF, "InterfaceOptionsCheckButtonTemplate")

        if i == 1 then
            btn:SetPoint("TOPLEFT", tTip, "BOTTOMLEFT", 0, -20)
        else
            btn:SetPoint("TOPLEFT", self.Content.Buttons.Layout.D[i - 1], "BOTTOMLEFT", 0, 0)
        end

        btn:SetSize(24, 24)

        btn.label = GetFont(self, btn, opt.name, 12)
        btn.label:SetPoint("LEFT", btn, "RIGHT", 8, 1)
        btn:SetChecked(Ether.DB[301][i] == 1)

        btn:SetScript("OnClick", function(self)
            local checked = self:GetChecked()
            Ether.DB[301][i] = checked and 1 or 0
        end)

        self.Content.Buttons.Layout.D[i] = btn
    end
end

function Ether.CreateConfigSection(self)
    local parent = self.Content.Children["Config"]
    local DB = Ether.DB

    local FRAME_GROUPS = {
        [331] = { name = "Tooltip", frame = Ether.Anchor.tooltip },
        [332] = { name = "Player", frame = Ether.Anchor.player },
        [333] = { name = "Target", frame = Ether.Anchor.target },
        [334] = { name = "TargetTarget", frame = Ether.Anchor.targettarget },
        [335] = { name = "Pet", frame = Ether.Anchor.pet },
        [336] = { name = "Pet Target", frame = Ether.Anchor.pettarget },
        [337] = { name = "Focus", frame = Ether.Anchor.focus },
        [338] = { name = "Party", frame = Ether.Anchor.party },
        [339] = { name = "Raid", frame = Ether.Anchor.raid },
        [340] = { name = "Main Tank", frame = Ether.Anchor.maintank },
        [341] = { name = "Debug", frame = Ether.DebugFrame },
    }

    local ANCHOR_POINTS = {
        "RIGHT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT",
        "BOTTOM", "TOP", "LEFT", "TOPLEFT", "CENTER"
    }

    local labels = {}
    local function CreateLabel(text, point, relativeTo, relativePoint, x, y)
        local label = GetFont(self, parent, text, 13)
        label:SetPoint(point, relativeTo, relativePoint, x, y)
        labels[text] = label
        return label
    end

    CreateLabel("Select frame:", "TOPLEFT", parent, "TOPLEFT", 10, -10)
    CreateLabel("Point", "TOPLEFT", labels["Select frame:"], "BOTTOMLEFT", 30, -80)
    CreateLabel("Relative", "LEFT", labels["Point"], "RIGHT", 200, 0)
    CreateLabel("Slide X", "TOPLEFT", labels["Point"], "BOTTOMLEFT", 30, -100)
    CreateLabel("Slide Y", "LEFT", labels["Slide X"], "RIGHT", 200, 0)
    CreateLabel("Scale", "TOPLEFT", labels["Slide X"], "BOTTOMLEFT", 0, -80)
    CreateLabel("Alpha", "LEFT", labels["Scale"], "RIGHT", 220, 0)
    local dropdowns = {}
    local function CreateDropdown(name, relativeTo, width)
        local dropdown = CreateFrame("Frame", nil, parent, "UIDropDownMenuTemplate")
        dropdown:SetPoint("TOPLEFT", relativeTo, "BOTTOMLEFT", 0, -10)
        UIDropDownMenu_SetWidth(dropdown, width)
        UIDropDownMenu_JustifyText(dropdown, "CENTER")
        dropdowns[name] = dropdown
        return dropdown
    end
    dropdowns.frame = CreateDropdown("frame", labels["Select frame:"], 100)
    dropdowns.point = CreateDropdown("point", labels["Point"], 80)
    dropdowns.relative = CreateDropdown("relative", labels["Relative"], 80)
    local sliders = {}
    local function CreateSlider(name, relativeTo, min, max, step, formatFunc)
        local slider = CreateFrame("Slider", nil, parent, "UISliderTemplateWithLabels, BackDropTemplate")
        slider:SetBackdrop(backDrop)
        slider:SetPoint("TOPLEFT", relativeTo, "BOTTOMLEFT", 0, -10)
        slider:SetObeyStepOnDrag(true)
        slider:SetSize(120, 20)
        slider:SetMinMaxValues(min, max)
        slider:SetValueStep(step)
        local currentFrame = DB[001].SELECTED
        local defaultValue = 0
        if currentFrame and DB[5111] and DB[5111][currentFrame] then
            if name == "x" then
                defaultValue = DB[5111][currentFrame][4] or 0
            elseif name == "y" then
                defaultValue = DB[5111][currentFrame][5] or 0
            elseif name == "scale" then
                defaultValue = DB[5111][currentFrame][8] or 1
            elseif name == "alpha" then
                defaultValue = DB[5111][currentFrame][9] or 1
            end
        end
        slider:SetValue(defaultValue)
        slider:SetScript("OnValueChanged", function(self, value)
            self.Text:SetText(formatFunc(value))
            local frame = DB[001].SELECTED
            if frame and DB[5111] and DB[5111][frame] then
                local index = name == "x" and 4 or name == "y" and 5 or name == "scale" and 8 or name == "alpha" and 9
                DB[5111][frame][index] = self:GetValue()
                Ether.Fire("FRAME_UPDATE", frame)
            end
        end)
        sliders[name] = slider
        return slider
    end
    sliders.x = CreateSlider("x", labels["Slide X"], -800, 800, 1,
            function(v)
                return string.format("%.0f", v)
            end)
    sliders.y = CreateSlider("y", labels["Slide Y"], -800, 800, 1,
            function(v)
                return string.format("%.0f", v)
            end)
    sliders.scale = CreateSlider("scale", sliders.x, 0.5, 2, 0.1,
            function(v)
                return string.format("%.0f%%", v * 100)
            end)
    sliders.alpha = CreateSlider("alpha", sliders.y, 0.1, 1, 0.1,
            function(v)
                return string.format("%.0f%%", v * 100)
            end)

    local function UpdateValue()
        local SELECTED = DB[001].SELECTED
        if not SELECTED or not DB[5111] or not DB[5111][SELECTED] then
            return
        end
        local pos = DB[5111][SELECTED]
        UIDropDownMenu_SetText(dropdowns.point, pos[1] or "TOP")
        UIDropDownMenu_SetText(dropdowns.relative, pos[3] or "TOP")
        if sliders.x:GetValue() ~= (pos[4] or 0) then
            sliders.x:SetValue(pos[4] or 0)
        end
        if sliders.y:GetValue() ~= (pos[5] or 0) then
            sliders.y:SetValue(pos[5] or 0)
        end
        if sliders.scale:GetValue() ~= (pos[8] or 1) then
            sliders.scale:SetValue(pos[8] or 1)
        end
        if sliders.alpha:GetValue() ~= (pos[9] or 1) then
            sliders.alpha:SetValue(pos[9] or 1)
        end
    end
    local function CreateFrameDropdown()
        UIDropDownMenu_Initialize(dropdowns.frame, function()
            for id, data in pairs(FRAME_GROUPS) do
                local info = UIDropDownMenu_CreateInfo()
                info.text = data.name
                info.value = id
                info.func = function()
                    local oldFrame = DB[001].SELECTED
                    Ether.DB[001].SELECTED = id
                    UIDropDownMenu_SetSelectedValue(dropdowns.frame, id)
                    UIDropDownMenu_SetText(dropdowns.frame, data.name)
                    UpdateValue()
                    Ether.Fire("FRAME_UPDATE", oldFrame)
                end
                UIDropDownMenu_AddButton(info)
            end
        end)
    end
    local function CreatePointDropdown(dropdown, pointIndex)
        UIDropDownMenu_Initialize(dropdown, function()
            for _, point in ipairs(ANCHOR_POINTS) do
                local info = UIDropDownMenu_CreateInfo()
                info.text = point
                info.value = point
                info.func = function()
                    local currentFrame = DB[001].SELECTED
                    if currentFrame and DB[5111] and DB[5111][currentFrame] then
                        DB[5111][currentFrame][pointIndex] = point
                        UIDropDownMenu_SetText(dropdown, point)
                        Ether.Fire("FRAME_UPDATE", currentFrame)
                        UpdateValue()
                    end
                end
                UIDropDownMenu_AddButton(info)
            end
        end)
    end
    CreateFrameDropdown()
    CreatePointDropdown(dropdowns.point, 1)
    CreatePointDropdown(dropdowns.relative, 3)

    Ether.RegisterCallback("FRAME_UPDATE", "FrameGroups", function(frameGroup)
        if not frameGroup or not DB[5111] or not DB[5111][frameGroup] or not FRAME_GROUPS[frameGroup] then
            return
        end

        local frameData = FRAME_GROUPS[frameGroup]
        local pos = DB[5111][frameGroup]

        for i, default in ipairs({ "CENTER", 5133, "CENTER", 0, 0, 100, 100, 1, 1 }) do
            pos[i] = pos[i] or default
        end
        pos[4] = pos[4] and math.floor(pos[4] + 0.5) or 0
        pos[5] = pos[5] and math.floor(pos[5] + 0.5) or 0

        local relTo
        if pos[2] == 5133 then
            relTo = UIParent
        else
            relTo = FRAME_GROUPS[pos[2]] and FRAME_GROUPS[pos[2]].frame or UIParent
            if not relTo or not relTo.GetCenter then
                relTo = UIParent
            end
        end
        local frame = frameData.frame
        if frame and frame.SetPoint then
            frame:ClearAllPoints()
            frame:SetPoint(pos[1], relTo, pos[3], pos[4], pos[5])
            frame:SetSize(pos[6], pos[7])
            frame:SetScale(pos[8])
            frame:SetAlpha(pos[9])
        end

        if frameGroup == DB[001].SELECTED then
            UpdateValue()
        end
    end)

    local function SetInitialValue()
        local currentFrame = DB[001].SELECTED
        if currentFrame and FRAME_GROUPS[currentFrame] then
            UIDropDownMenu_SetSelectedValue(dropdowns.frame, currentFrame)
            UIDropDownMenu_SetText(dropdowns.frame, FRAME_GROUPS[currentFrame].name)
            UpdateValue()
        else
            UIDropDownMenu_SetText(dropdowns.frame, "Choose frame...")
        end
    end
    SetInitialValue()
end

function Ether.CreateProfileSection(self)
    local parent = self.Content.Children["Profile"]
    local dropdownLabel = parent:CreateFontString(nil, "OVERLAY")
    dropdownLabel:SetFont(unpack(Ether.mediaPath.Font), 13, "OUTLINE")
    dropdownLabel:SetPoint("TOPLEFT", 10, -10)
    dropdownLabel:SetText("Current profile:")
    local dropdown = CreateFrame("Frame", nil, parent, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", dropdownLabel, "BOTTOMLEFT", 10, -20)
    UIDropDownMenu_SetWidth(dropdown, 130)
    local inputDialog = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    inputDialog:SetSize(300, 120)
    inputDialog:SetPoint("CENTER")
    inputDialog:SetFrameStrata("DIALOG")
    inputDialog:Hide()
    inputDialog:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    local inputTitle = inputDialog:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    inputTitle:SetPoint("TOP", inputDialog, "TOP", 0, -15)
    local inputBox = CreateFrame("EditBox", nil, inputDialog, "InputBoxTemplate")
    inputBox:SetSize(250, 30)
    inputBox:SetPoint("TOP", inputTitle, "BOTTOM", 0, -10)
    inputBox:SetAutoFocus(false)
    local okButton = CreateFrame("Button", nil, inputDialog, "GameMenuButtonTemplate")
    okButton:SetSize(100, 25)
    okButton:SetPoint("BOTTOMLEFT", inputDialog, "BOTTOM", 5, 15)
    okButton:SetText("OK")
    local cancelButton = CreateFrame("Button", nil, inputDialog, "GameMenuButtonTemplate")
    cancelButton:SetSize(100, 25)
    cancelButton:SetPoint("BOTTOMRIGHT", inputDialog, "BOTTOM", -5, 15)
    cancelButton:SetText("Cancel")
    cancelButton:SetScript("OnClick", function()
        inputDialog:Hide()
    end)
    local function RefreshDropdown()
        UIDropDownMenu_Initialize(dropdown, function(self, level)
            local info = UIDropDownMenu_CreateInfo()
            for _, profileName in ipairs(Ether.GetProfileList()) do
                info.text = profileName
                info.value = profileName
                info.func = function(self)
                    local success, msg = Ether.SwitchProfile(self.value)
                    if success then
                        UIDropDownMenu_SetSelectedValue(dropdown, self.value)
                        UIDropDownMenu_SetText(dropdown, self.value)
                        Ether.DebugOutput("|cffcc66ffEther|r " .. msg)

                        if parent.RefreshConfig then
                            parent.RefreshConfig()
                        end
                    else
                        Ether.DebugOutput("|cffcc66ffEther|r " .. msg)
                    end
                end
                info.checked = (profileName == ETHER_DATABASE_DX_AA.currentProfile)
                UIDropDownMenu_AddButton(info, level)
            end
        end)
        UIDropDownMenu_SetSelectedValue(dropdown, ETHER_DATABASE_DX_AA.currentProfile)
        UIDropDownMenu_SetText(dropdown, ETHER_DATABASE_DX_AA.currentProfile)
    end
    RefreshDropdown()
    local buttonY = -80
    local function CreateButton(text, w, h, xOffset, yOffset)
        local btn = CreateFrame("Button", nil, parent, "GameMenuButtonTemplate")
        btn:SetSize(w, h)
        btn:SetPoint("TOP", dropdown, "BOTTOM", xOffset, yOffset)
        btn:SetText(text)
        local fontString = btn:GetFontString()
        if fontString then
            fontString:SetFont(unpack(Ether.mediaPath.Font), 10, "OUTLINE")
        end
        return btn
    end
    local newButton = CreateButton("Create new profile", 140, 30, 0, buttonY)
    newButton:SetScript("OnClick", function()
        inputTitle:SetText("Create new profile")
        inputBox:SetText("")
        inputDialog:Show()
        inputBox:SetFocus()
        okButton:SetScript("OnClick", function()
            local name = inputBox:GetText()
            if name and name ~= "" then
                local success, msg = Ether.CreateProfile(name)
                if success then
                    RefreshDropdown()
                    Ether.DebugOutput("|cffcc66ffEther|r " .. msg)
                else
                    Ether.DebugOutput("|cffcc66ffEther|r " .. msg)
                end
            end
            inputDialog:Hide()
        end)
    end)
    local copyButton = CreateButton("Copy profile", 140, 30, 0, buttonY - 40)
    copyButton:SetScript("OnClick", function()
        inputTitle:SetText("Copy profile")
        inputBox:SetText(ETHER_DATABASE_DX_AA.currentProfile .. " - Copy")
        inputDialog:Show()
        inputBox:SetFocus()
        okButton:SetScript("OnClick", function()
            local name = inputBox:GetText()
            if name and name ~= "" then

                local success, msg = Ether.CopyProfile(ETHER_DATABASE_DX_AA.currentProfile, name)
                if success then
                    RefreshDropdown()
                    Ether.DebugOutput("|cffcc66ffEther|r " .. msg)
                else
                    Ether.DebugOutput("|cffcc66ffEther|r " .. msg)
                end
            end
            inputDialog:Hide()
        end)
    end)
    local renameButton = CreateButton("Rename profile", 140, 30, 0, buttonY - 80)
    renameButton:SetScript("OnClick", function()
        inputTitle:SetText("Rename profile")
        inputBox:SetText(ETHER_DATABASE_DX_AA.currentProfile)
        inputDialog:Show()
        inputBox:SetFocus()
        okButton:SetScript("OnClick", function()
            local newName = inputBox:GetText()
            if newName and newName ~= "" then
                local success, msg = Ether.RenameProfile(ETHER_DATABASE_DX_AA.currentProfile, newName)
                if success then
                    RefreshDropdown()
                    Ether.DebugOutput("|cffcc66ffEther|r " .. msg)
                else
                    Ether.DebugOutput("|cffcc66ffEther|r " .. msg)
                end
            end
            inputDialog:Hide()
        end)
    end)
    local deleteButton = CreateButton("Delete profile", 140, 30, 0, buttonY - 120)
    deleteButton:SetScript("OnClick", function()
        local profileToDelete = ETHER_DATABASE_DX_AA.currentProfile
        local profiles = Ether.GetProfileList()
        if #profiles <= 1 then
            Ether.DebugOutput("|cffcc66ffEther|r Cannot delete the only profile")
            return
        end
        StaticPopupDialogs["ETHER_DELETE_PROFILE"] = {
            text = "Are you sure you want to delete your profile '" .. profileToDelete .. "'?",
            button1 = "Yes",
            button2 = "No",
            OnAccept = function()
                local success, msg = Ether.DeleteProfile(profileToDelete)
                if success then
                    RefreshDropdown()
                    Ether.DebugOutput("|cffcc66ffEther|r " .. msg)
                    if parent.RefreshConfig then
                        parent.RefreshConfig()
                    end
                else
                    Ether.DebugOutput("|cffcc66ffEther|r " .. msg)
                end
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
        }
        StaticPopup_Show("ETHER_DELETE_PROFILE")
    end)

    local resetButton = CreateButton("Reset to default", 140, 30, 0, buttonY - 160)
    resetButton:SetScript("OnClick", function()
        StaticPopupDialogs["ETHER_RESET_PROFILE"] = {
            text = "Reset profile to default settings?\nThis cannot be undone!",
            button1 = "Yes",
            button2 = "No",
            OnAccept = function()
                local success, msg = Ether.ResetProfile()
                if success then
                    Ether.DebugOutput("|cffcc66ffEther|r " .. msg)
                    RefreshDropdown()
                    if parent.RefreshConfig then
                        parent.RefreshConfig()
                    end
                else
                    Ether.DebugOutput("|cffcc66ffEther|r " .. msg)
                end
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
        }
        StaticPopup_Show("ETHER_RESET_PROFILE")
    end)
    parent.Refresh = RefreshDropdown
    parent.RefreshConfig = function()
        Ether.DebugOutput("|cffcc66ffEther|r UI refreshed for new profile")
    end
end

local function CreateMainSettings(self)
    if not self.IsCreated then
        self.Frames["Main"] = CreateFrame("Frame", "EtherUnitFrameAddon", UIParent, "BackdropTemplate")
        self.Frames["Main"]:SetFrameLevel(100)
        self.Frames["Main"]:SetBackdrop({
            bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        self.Frames["Main"]:SetBackdropColor(0.1, 0.1, 0.1, .9)
        self.Frames["Main"]:SetBackdropBorderColor(0, 0.8, 1, .7)
        self.Frames["Main"]:Hide()
        self.Frames["Main"]:SetScript("OnHide", function()
            Ether.DB[001].SHOW = false
        end)
        tinsert(UISpecialFrames, self.Frames["Main"]:GetName())
        RegisterAttributeDriver(self.Frames["Main"], "state-visibility", "[combat]hide")
        local btnX = CreateFrame("Button", nil, self.Frames["Main"], "GameMenuButtonTemplate")
        btnX:SetPoint("TOPRIGHT", -10, -10)
        btnX:GetFontString():SetFont(unpack(Ether.mediaPath.Font), 10, "OUTLINE")
        btnX:SetText("X")
        btnX:SetSize(28, 28)
        btnX:SetScript("OnClick", function()
            self.Frames["Main"]:Hide()
        end)

        self.Frames["Top"] = CreateFrame("Frame", nil, self.Frames["Main"])
        self.Frames["Top"]:SetPoint("TOPLEFT", 10, -10)
        self.Frames["Top"]:SetPoint("TOPRIGHT", -10, 0)
        self.Frames["Top"]:SetSize(0, 40)
        self.Frames["Bottom"] = CreateFrame('Frame', nil, self.Frames["Main"])
        self.Frames["Bottom"]:SetPoint("BOTTOMLEFT", 10, 10)
        self.Frames["Bottom"]:SetPoint("BOTTOMRIGHT", -10, 0)
        self.Frames["Bottom"]:SetSize(0, 30)
        self.Frames["Left"] = CreateFrame('Frame', nil, self.Frames["Main"])
        self.Frames["Left"]:SetPoint("TOPLEFT", self.Frames["Top"], 'BOTTOMLEFT')
        self.Frames["Left"]:SetPoint("BOTTOMLEFT", self.Frames["Bottom"], "TOPLEFT")
        self.Frames["Left"]:SetSize(110, 0)
        self.Frames["Right"] = CreateFrame("Frame", nil, self.Frames["Top"])
        self.Frames["Right"]:SetPoint("TOPRIGHT", self.Frames["Bottom"], "TOPRIGHT")
        self.Frames["Right"]:SetPoint("BOTTOMRIGHT", self.Frames["Bottom"], "TOPRIGHT")
        self.Frames["Right"]:SetSize(10, 0)
        self.Frames["Content"] = CreateFrame("Frame", nil, self.Frames["Top"])
        self.Frames["Content"]:SetPoint("TOP", self.Frames["Top"], 'BOTTOM')
        self.Frames["Content"]:SetPoint("BOTTOM", self.Frames["Bottom"], "TOP")
        self.Frames["Content"]:SetPoint("LEFT", self.Frames["Left"], "RIGHT")
        self.Frames["Content"]:SetPoint("RIGHT", self.Frames["Right"], "LEFT")
        local top = self.Frames["Content"]:CreateTexture(nil, 'BORDER')
        top:SetColorTexture(1, 1, 1, 1)
        top:SetPoint("TOPLEFT", -2, 2)
        top:SetPoint("TOPRIGHT", 2, 2)
        top:SetHeight(1)
        local bottom = self.Frames["Content"]:CreateTexture(nil, 'BORDER')
        bottom:SetColorTexture(1, 1, 1, 1)
        bottom:SetPoint("BOTTOMLEFT", -2, -2)
        bottom:SetPoint("BOTTOMRIGHT", 2, -2)
        bottom:SetHeight(1)
        local left = self.Frames["Content"]:CreateTexture(nil, "BORDER")
        left:SetColorTexture(1, 1, 1, 1)
        left:SetPoint("TOPLEFT", -2, 2)
        left:SetPoint("BOTTOMLEFT", -2, -2)
        left:SetWidth(1)
        local right = self.Frames["Content"]:CreateTexture(nil, "BORDER")
        right:SetColorTexture(1, 1, 1, 1)
        right:SetPoint("TOPRIGHT", 2, 2)
        right:SetPoint("BOTTOMRIGHT", 2, -2)
        right:SetWidth(1)
        local version = self.Frames["Bottom"]:CreateFontString(nil, "OVERLAY")
        version:SetFont(unpack(Ether.mediaPath.Font), 15, "OUTLINE")
        version:SetPoint("BOTTOMRIGHT", -10, 3)
        version:SetText("Beta Build |cE600CCFF" .. Ether.version .. "|r")
        local menuIcon = self.Frames["Bottom"]:CreateTexture(nil, "ARTWORK")
        menuIcon:SetSize(32, 32)
        menuIcon:SetTexture(unpack(Ether.mediaPath.Icon))
        menuIcon:SetPoint("BOTTOMLEFT", 0, 5)
        local name = self.Frames["Bottom"]:CreateFontString(nil, "OVERLAY")
        name:SetFont(unpack(Ether.mediaPath.Font), 20, "OUTLINE")
        name:SetPoint("BOTTOMLEFT", menuIcon, "BOTTOMRIGHT", 7, 0)
        name:SetText("|cffcc66ffEther|r")
        self.IsCreated = true
    end
end

local function CreateSettingsButtons(self, name, parent, layer, onClick, isTopButton)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetHeight(25)
    if isTopButton then
    else
        btn:SetWidth(parent:GetWidth() - 10)
    end
    btn.font = Ether.GetFont(self, btn, name, 15)
    btn.font:SetText(name)
    btn.font:SetAllPoints()
    btn.Highlight = btn:CreateTexture(nil, "HIGHLIGHT")
    btn.Highlight:SetAllPoints()
    btn.Highlight:SetColorTexture(1, 1, 1, .4)
    btn:SetScript("OnClick", function()
        return onClick(name, layer)
    end)
    return btn
end

local function CreateSettingsScrollTab(parent, name)
    local scrollFrame = CreateFrame("ScrollFrame", name .. "Scroll", parent, "UIPanelScrollFrameTemplate")
    scrollFrame:SetAllPoints(parent)
    if scrollFrame.ScrollBar then
        scrollFrame.ScrollBar:ClearAllPoints()
        scrollFrame.ScrollBar:SetPoint("TOPRIGHT", -5, -20)
        scrollFrame.ScrollBar:SetPoint("BOTTOMRIGHT", -5, 20)
    end
    local content = CreateFrame('Frame', name, scrollFrame)
    content:SetSize(scrollFrame:GetWidth() - 30, 1)
    scrollFrame:SetScrollChild(content)
    scrollFrame:EnableMouseWheel(true)
    scrollFrame:SetScript("OnMouseWheel", function(self, delta)
        local cur, max = self:GetVerticalScroll(), self:GetVerticalScrollRange()
        self:SetVerticalScroll(math_max(0, math_min(max, cur - (delta * 20))))
    end)
    content._ScrollFrame = scrollFrame
    return content
end

Ether.GetFont = GetFont
Ether.CreateMainSettings = CreateMainSettings
Ether.CreateSettingsButtons = CreateSettingsButtons
Ether.CreateSettingsScrollTab = CreateSettingsScrollTab

function Ether.CopyProfile(sourceName, targetName)
    if not ETHER_DATABASE_DX_AA.profiles[sourceName] then
        return false, "Source profile not found"
    end
    if ETHER_DATABASE_DX_AA.profiles[targetName] then
        return false, "Target profile already exists"
    end
    ETHER_DATABASE_DX_AA.profiles[targetName] = Ether.DeepCopy(ETHER_DATABASE_DX_AA.profiles[sourceName])
    return true, "Profile copied"
end

function Ether.SwitchProfile(name)
    if not ETHER_DATABASE_DX_AA.profiles[name] then
        return false, "Profile not found"
    end
    ETHER_DATABASE_DX_AA.profiles[ETHER_DATABASE_DX_AA.currentProfile] = Ether.DeepCopy(Ether.DB)
    ETHER_DATABASE_DX_AA.currentProfile = name
    Ether.DB = Ether.DeepCopy(ETHER_DATABASE_DX_AA.profiles[name])
    return true, "Profile changed to " .. name
end

function Ether.DeleteProfile(name)
    if not ETHER_DATABASE_DX_AA.profiles[name] then
        return false, "Profile not found"
    end
    local profileCount = 0
    for _ in pairs(ETHER_DATABASE_DX_AA.profiles) do
        profileCount = profileCount + 1
    end
    if profileCount <= 1 then
        return false, "Cannot delete the only profile"
    end
    if name == ETHER_DATABASE_DX_AA.currentProfile then
        local otherProfile
        for profileName in pairs(ETHER_DATABASE_DX_AA.profiles) do
            if profileName ~= name then
                otherProfile = profileName
                break
            end
        end
        if not otherProfile then
            return false, "No other profile available"
        end
        local success, msg = Ether.SwitchProfile(otherProfile)
        if not success then
            return false, "Failed to switch profile: " .. msg
        end
    end

    ETHER_DATABASE_DX_AA.profiles[name] = nil
    return true, "Profile deleted"
end

function Ether.GetCharacterKey()
    return playerName .. " - " .. realmName
end

function Ether.GetCurrentProfile()
    return ETHER_DATABASE_DX_AA.profiles[ETHER_DATABASE_DX_AA.currentProfile]
end

function Ether.GetProfileList()
    local list = {}
    for name in pairs(ETHER_DATABASE_DX_AA.profiles) do
        tinsert(list, name)
    end
    tsort(list)
    return list
end

function Ether.CreateProfile(name)
    if ETHER_DATABASE_DX_AA.profiles[name] then
        return false, "Profile already exists"
    end
    ETHER_DATABASE_DX_AA.profiles[name] = Ether.DeepCopy(Ether.DataDefault)
    return true, "Profile created"
end

function Ether.RenameProfile(oldName, newName)
    if not ETHER_DATABASE_DX_AA.profiles[oldName] then
        return false, "Profile not found"
    end
    if ETHER_DATABASE_DX_AA.profiles[newName] then
        return false, "Name already taken"
    end
    ETHER_DATABASE_DX_AA.profiles[newName] = ETHER_DATABASE_DX_AA.profiles[oldName]
    ETHER_DATABASE_DX_AA.profiles[oldName] = nil
    if ETHER_DATABASE_DX_AA.currentProfile == oldName then
        ETHER_DATABASE_DX_AA.currentProfile = newName
    end
    return true, "Profile renamed"
end
--[[
function Ether.RefreshAllPositions()
    for frameId, frameData in pairs(FRAME_GROUPS or {}) do
        if frameData.frame and frameData.frame.SetPoint then
            Ether.Fire("FRAME_UPDATE", frameId)
        end
    end
    Ether.DebugOutput("|cffcc66ffEther|r All positions refreshed")
end
]]
function Ether.ResetProfile()
    ETHER_DATABASE_DX_AA.profiles[ETHER_DATABASE_DX_AA.currentProfile] = Ether.DeepCopy(Ether.DataDefault)
    Ether.DB = Ether.DeepCopy(ETHER_DATABASE_DX_AA.profiles[ETHER_DATABASE_DX_AA.currentProfile])
    ReloadUI()
    return true, "Profile reset to default"
end
function Ether.CompressString(str)
    return str:gsub("(.)%1%1%1+", function(c)
        return c .. "#" .. (#str:match(c .. "+")) .. "#"
    end)
end

function Ether.DecompressString(str)
    return str:gsub("(.)#(%d+)#", function(c, count)
        return c:rep(tonumber(count))
    end)
end

function Ether.Validate(data)
    return type(data) == "table"
end

