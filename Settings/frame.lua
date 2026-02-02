local _, Ether = ...

local playerName, realmName = UnitName("player"), GetRealmName()

local function GetFont(_, target, tex, numb)
    target.label = target:CreateFontString(nil, "OVERLAY")
    target.label:SetFont(unpack(Ether.mediaPath.Font), numb, "OUTLINE")
    target.label:SetText(tex)
    return target.label
end
Ether.GetFont = GetFont
function Ether.CreateModuleSection(self)
    local parent = self.Content.Children["Module"]
    local modulesValue = {
        [1] = {name = "Icon"},
        [2] = {name = "Chat Bn & Msg Whisper"},
        [3] = {name = "Tooltip"},
        [4] = {name = "Idle mode"}
    }
    local mod = CreateFrame("Frame", nil, parent)
    mod:SetSize(200, (#modulesValue * 30) + 60)
    for i, opt in ipairs(modulesValue) do
        local btn = CreateFrame("CheckButton", nil, mod, "OptionsBaseCheckButtonTemplate")

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
            elseif i == 2 then
                Ether.EnableMsgEvents()
            end
        end)
        self.Content.Buttons.Module.A[i] = btn
    end
end

function Ether.CreateInformationSection(self)
    local parent = self.Content.Children["Information"]
    local slash = GetFont(self, parent, "|cffffff00Slash Commands|r", 15)
    slash:SetPoint("TOP", 0, -20)
    local lastY = -20
    for _, entry in ipairs(Ether.SlashInfo) do
        local fs = GetFont(self, parent, string.format("%s  –  %s", entry.cmd, entry.desc), 12)
        fs:SetPoint("TOP", slash, "BOTTOM", 0, lastY)
        lastY = lastY - 18
    end
    local idle = GetFont(self, parent, "|cffffff00What happens in idle mode?|r", 15)
    idle:SetPoint("TOP", 0, -180)
    local idleInfo = GetFont(self, parent, "When the user is not at the keyboard,\nEther deregisters all events and OnUpdate functions.", 12)
    idleInfo:SetPoint("TOP", 0, -220)
end

function Ether.CreateHideSection(self)
    local parent = self.Content.Children["Hide"]
    local HideValue = {
        [1] = {name = "Blizzard Player frame"},
        [2] = {name = "Blizzard Pet frame"},
        [3] = {name = "Blizzard Target frame"},
        [4] = {name = "Blizzard Focus frame"},
        [5] = {name = "Blizzard CastBar"},
        [6] = {name = "Blizzard Party"},
        [7] = {name = "Blizzard Raid"},
        [8] = {name = "Blizzard Raid Manager"},
        [9] = {name = "Blizzard MicroMenu"},
        [10] = {name = "Blizzard MainStatusTrackingBarContainer"},
        [11] = {name = "Blizzard MainMenuBar"},
        [12] = {name = "Blizzard BagsBar"}
    }
    local hide = GetFont(self, parent, "|cffffff00Hide Blizzard Frames|r", 15)
    hide:SetPoint("TOPLEFT", 10, -10)
    local bF = CreateFrame("Frame", nil, parent)
    bF:SetSize(200, (#HideValue * 30) + 60)
    for i, opt in ipairs(HideValue) do
        local btn = CreateFrame("CheckButton", nil, bF, "InterfaceOptionsCheckButtonTemplate")
        if i == 1 then
            btn:SetPoint("TOPLEFT", hide, "BOTTOMLEFT", 0, -20)
        else
            btn:SetPoint("TOPLEFT", self.Content.Buttons.Hide.A[i - 1], "BOTTOMLEFT", 0, 0)
        end
        btn:SetSize(24, 24)
        btn.label = GetFont(self, btn, opt.name, 12)
        btn.label:SetPoint("LEFT", btn, "RIGHT", 8, 1)
        btn:SetChecked(Ether.DB[101][i] == 1)
        btn:SetScript("OnClick", function(self)
            local checked = self:GetChecked()
            Ether.DB[101][i] = checked and 1 or 0
        end)
        self.Content.Buttons.Hide.A[i] = btn
    end
end

function Ether.CreateSection(self)
    local parent = self.Content.Children["Create"]
    local CreateUnits = {
        [1] = {name = "|cffCC66FFPlayer|r", value = "PLAYER"},
        [2] = {name = "|cE600CCFFTarget|r", value = "TARGET"},
        [3] = {name = "Target of Target", value = "TARGETTARGET"},
        [4] = {name = "|cffCC66FFPlayer's Pet|r", value = "PET"},
        [5] = {name = "|cffCC66FFPlayers Pet Target|r", value = "PETTARGET"},
        [6] = {name = "|cff3399FFFocus|r", value = "FOCUS"},
    }
    local CreateAndBars = GetFont(self, parent, "|cffffff00Create/Delete Units|r", 15)
    CreateAndBars:SetPoint("TOPLEFT", 10, -10)
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
                    Ether.registerToTEvents()
                end
            elseif Ether.DB[201][index] == 0 then
                Ether:DestroyUnitButtons(unitKeys[index])
            end
        end
        btn:SetScript("OnClick", function(self)
            local checked = self:GetChecked()
            Ether.DB[201][i] = checked and 1 or 0
            unitFactory(i)
        end)
        self.Content.Buttons.Create.A[i] = btn
    end

    local CreateCustom = CreateFrame("Button", nil, parent, "GameMenuButtonTemplate")
    CreateCustom:SetPoint("TOPLEFT", self.Content.Buttons.Create.A[6], "BOTTOMLEFT", 0, -40)
    CreateCustom:GetFontString():SetFont(unpack(Ether.mediaPath.Font), 10, "OUTLINE")
    CreateCustom:SetText("Create Custom")
    CreateCustom:SetSize(100, 30)
    CreateCustom:SetScript("OnClick", function()
        Ether.CreateCustomUnit()
    end)
    local destroyCustom = CreateFrame("Button", nil, parent, "GameMenuButtonTemplate")
    destroyCustom:SetPoint("TOPLEFT", CreateCustom, "BOTTOMLEFT")
    destroyCustom:GetFontString():SetFont(unpack(Ether.mediaPath.Font), 10, "OUTLINE")
    destroyCustom:SetText("Destroy Custom")
    destroyCustom:SetSize(100, 30)
    destroyCustom:SetScript("OnClick", function()
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
        GetTblText(Ether.unitButtons["solo"], "health")
    elseif value == 2 then
        GetTblText(Ether.unitButtons["solo"], "power")
    elseif value == 3 then
        GetTblText(Ether.unitButtons["raid"], "health")
    elseif value == 4 then
        GetTblText(Ether.unitButtons["raid"], "power")
    end
end

function Ether.CreateUpdateSection(self)
    local parent = self.Content.Children["Updates"]
    local UpdateValue = {
        [1] = {text = "Health Solo"},
        [2] = {text = "Power Solo"},
        [3] = {text = "Health Header"},
        [4] = {text = "Power Header"},
    }
    local Update = GetFont(self, parent, "|cffffff00Health & Power Text:|r", 15)
    Update:SetPoint("TOPLEFT", 10, -10)
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
    local UnitUpdates = {
        [1] = {text = "Player", value = "player"},
        [2] = {text = "Target", value = "target"},
        [3] = {text = "Target of Target", value = "targettarget"},
        [4] = {text = "Pet", value = "pet"},
        [5] = {text = "Pet Target", value = "pettarget"},
        [6] = {text = "Focus", value = "focus"},
        [7] = {text = "Header", value = "raid"}
    }
    local Events = GetFont(self, parent, "|cffffff00Update|r", 15)
    Events:SetPoint("TOP", 40, -10)
    local EventsToggle = CreateFrame("Frame", nil, parent)
    EventsToggle:SetSize(200, (#UnitUpdates * 30) + 60)
    for i, opt in ipairs(UnitUpdates) do
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
end

function Ether.CreateAuraSettingsSection(self)
    local parent = self.Content.Children["Aura Settings"]
    local CreateAura = {
        [1] = {text = "Player Auras"},
        [2] = {text = "Pet Auras"},
        [3] = {text = "Target Auras"},
        [4] = {text = "Header Auras"}
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
        btn:SetChecked(Ether.DB[1001][i] == 1)
        btn:SetScript("OnClick", function(self)
            local checked = self:GetChecked()
            Ether.DB[1001][i] = checked and 1 or 0
            if i == 1 then
                if Ether.DB[1001][1] == 1 then
                    Ether:SingleAuraFullInitial(Ether.unitButtons.solo["player"])
                    ShowHideSingleAura(Ether.unitButtons.solo["player"], true)
                else
                    ShowHideSingleAura(Ether.unitButtons.solo["player"], false)
                end
            elseif i == 2 then
                if Ether.DB[1001][2] == 1 then
                    Ether:SingleAuraFullInitial(Ether.unitButtons.solo["pet"])
                    ShowHideSingleAura(Ether.unitButtons.solo["pet"], true)
                else
                    ShowHideSingleAura(Ether.unitButtons.solo["pet"], false)
                end
            elseif i == 3 then
                if Ether.DB[1001][3] == 1 then
                    Ether:SingleAuraFullInitial(Ether.unitButtons.solo["target"])
                    ShowHideSingleAura(Ether.unitButtons.solo["target"], true)
                else
                    ShowHideSingleAura(Ether.unitButtons.solo["target"], false)
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

    local templateLabel = parent:CreateFontString(nil, "OVERLAY")
    templateLabel:SetFont(unpack(Ether.mediaPath.Font), 12, "OUTLINE")
    templateLabel:SetPoint("TOPLEFT", 10, -10)
    templateLabel:SetText("Load Template:")

    local templateDropdown = CreateFrame("Button", nil, parent, "UIDropDownMenuTemplate")
    templateDropdown:SetPoint("TOPLEFT", templateLabel, "BOTTOMLEFT", -10, -10)
    UIDropDownMenu_SetWidth(templateDropdown, 140)
    UIDropDownMenu_SetText(templateDropdown, "Select Template...")

    local loadBtn = CreateFrame("Button", nil, parent)
    loadBtn:SetSize(60, 25)
    loadBtn:SetPoint("TOP", 30, -10)
    loadBtn.bg = loadBtn:CreateTexture(nil, "BACKGROUND")
    loadBtn.bg:SetAllPoints()
    loadBtn.bg:SetColorTexture(0.2, 0.2, 0.2, 0.8)
    loadBtn.text = loadBtn:CreateFontString(nil, "OVERLAY", "GameFontWhiteSmall")
    loadBtn.text:SetPoint("CENTER")
    loadBtn.text:SetText("Load")
    loadBtn:SetScript("OnClick", function(self)
        local selectedTemplate = UIDropDownMenu_GetText(templateDropdown)
        if selectedTemplate and selectedTemplate ~= "Select Template..." then
            Ether:AddTemplateAuras(selectedTemplate, true)
        end
    end)
    loadBtn:SetScript("OnEnter", function(self)
        self.bg:SetColorTexture(0.3, 0.3, 0.3, 0.9)
    end)
    loadBtn:SetScript("OnLeave", function(self)
        self.bg:SetColorTexture(0.2, 0.2, 0.2, 0.8)
    end)

    UIDropDownMenu_Initialize(templateDropdown, function()
        local info = UIDropDownMenu_CreateInfo()

        info.text = "|cffff0000Clear Auras|r"
        info.func = function()
            wipe(Ether.DB[1003])
            Ether.UpdateAuraList()
            selectedSpellId = nil
            Ether.UpdateEditor()
            Ether.DebugOutput("|cff00ccffAuras|r: Custom auras cleared")
        end
        UIDropDownMenu_AddButton(info)

        UIDropDownMenu_AddSeparator()

        for templateName, _ in pairs(Ether.AuraTemplates) do
            info.text = templateName
            info.func = function(self)
                UIDropDownMenu_SetText(templateDropdown, templateName)
            end
            UIDropDownMenu_AddButton(info)
        end
    end)

    local frame = CreateFrame("Frame", nil, parent)
    AuraList = frame
    AuraList:SetPoint("TOPLEFT", templateLabel, "BOTTOMLEFT", 0, -50)
    AuraList:SetSize(210, 320)

    local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT")
    scrollFrame:SetPoint("BOTTOMRIGHT", -25, 35)

    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(190, 1)
    scrollFrame:SetScrollChild(scrollChild)
    AuraList.scrollChild = scrollChild

    local addBtn = CreateFrame("Button", nil, frame)
    addBtn:SetSize(80, 25)
    addBtn:SetPoint("LEFT", loadBtn, "RIGHT", 10, 0)
    addBtn.bg = addBtn:CreateTexture(nil, "BACKGROUND")
    addBtn.bg:SetAllPoints()
    addBtn.bg:SetColorTexture(0.2, 0.2, 0.2, 0.8)
    addBtn.text = addBtn:CreateFontString(nil, "OVERLAY", "GameFontWhiteSmall")
    addBtn.text:SetPoint("CENTER")
    addBtn.text:SetText("New Aura")
    addBtn:SetScript("OnClick", function(self)
        Ether.AddNewAura()
    end)
    addBtn:SetScript("OnEnter", function(self)
        self.bg:SetColorTexture(0.3, 0.3, 0.3, 0.9)
    end)
    addBtn:SetScript("OnLeave", function(self)
        self.bg:SetColorTexture(0.2, 0.2, 0.2, 0.8)
    end)

    local confirm = CreateFrame("Button", nil, frame)
    confirm:SetSize(80, 25)
    confirm:SetPoint("LEFT", addBtn, "RIGHT", 10, 0)
    confirm.bg = confirm:CreateTexture(nil, "BACKGROUND")
    confirm.bg:SetAllPoints()
    confirm.bg:SetColorTexture(0.2, 0.2, 0.2, 0.8)
    confirm.text = confirm:CreateFontString(nil, "OVERLAY", "GameFontWhiteSmall")
    confirm.text:SetPoint("CENTER")
    confirm.text:SetText("Confirm")
    confirm:SetScript("OnClick", function(self)
        if selectedSpellId then
            Ether.SaveAuraPos(selectedSpellId)
        end
    end)
    confirm:SetScript("OnEnter", function(self)
        self.bg:SetColorTexture(0.3, 0.3, 0.3, 0.9)
    end)
    confirm:SetScript("OnLeave", function(self)
        self.bg:SetColorTexture(0.2, 0.2, 0.2, 0.8)
    end)

    return frame
end

function Ether:AddTemplateAuras(templateName)
    local template = Ether.AuraTemplates[templateName]
    if not template then
        return
    end

    local added = 0
    local skipped = 0

    for spellID, auraData in pairs(template) do
        if not Ether.DB[1003][spellID] then
            Ether.DB[1003][spellID] = Ether.CopyTable(auraData)
            added = added + 1
        else
            skipped = skipped + 1
        end
    end

    Ether.UpdateAuraList()

    local msg = string.format("|cff00ccffAuras|r: Template '%s' loaded. ", templateName)
    if added > 0 then
        msg = msg .. string.format("|cff00ff00+%d new auras|r", added)
    end
    if skipped > 0 then
        msg = msg .. string.format(" (%d already existed)", skipped)
    end
    Ether.DebugOutput(msg)

    selectedSpellId = nil
    Ether.UpdateEditor()
end

local Editor

local function CreateLineInput(parent, width, height)
    local input = CreateFrame("EditBox", nil, parent)
    input:SetSize(width, height)
    input:SetAutoFocus(false)

    local bg = input:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(1, 1, 1, 0.1)

    local line = input:CreateTexture(nil, "BORDER")
    line:SetPoint("BOTTOMLEFT")
    line:SetPoint("BOTTOMRIGHT")
    line:SetHeight(1)
    line:SetColorTexture(0.80, 0.40, 1.00, 1)
    input:SetFont(unpack(Ether.mediaPath.Font), 11, "OUTLINE")
    input:SetTextInsets(4, 4, 2, 2)

    input:SetScript("OnEditFocusGained", function(self)
        line:SetColorTexture(0, 0.8, 1, 1)
        line:SetHeight(1)
        bg:SetColorTexture(1, 1, 1, 0.1)
    end)
    input:SetScript("OnEditFocusLost", function(self)
        line:SetColorTexture(0.80, 0.40, 1.00, 1)
        line:SetHeight(1)
        bg:SetColorTexture(1, 1, 1, 0.1)
    end)
    input:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)

    return input
end

local colorPickerCallbacks = {
    currentSpellId = nil,
    editorFrame = nil
}

local function GenericColorChanged()
    local state = colorPickerCallbacks
    if state.currentSpellId and Ether.DB[1003][state.currentSpellId] then
        local r, g, b = ColorPickerFrame:GetColorRGB()
        local a = ColorPickerFrame:GetColorAlpha()
        local auraData = Ether.DB[1003][state.currentSpellId]

        auraData.color[1], auraData.color[2], auraData.color[3], auraData.color[4] = r, g, b, a

        if state.editorFrame then
            state.editorFrame.colorBtn.bg:SetColorTexture(r, g, b, a)
            state.editorFrame.rgbText:SetText(string.format("RGB: %d, %d, %d", r * 255, g * 255, b * 255))
            Ether.UpdatePreview()
            Ether.UpdateAuraList()
        end
    end
end

local function GenericCancel(prevValues)
    local state = colorPickerCallbacks
    if state.currentSpellId and Ether.DB[1003][state.currentSpellId] then
        local auraData = Ether.DB[1003][state.currentSpellId]

        if prevValues then
            auraData.color[1] = prevValues.r
            auraData.color[2] = prevValues.g
            auraData.color[3] = prevValues.b
            auraData.color[4] = prevValues.a
        end

        if state.editorFrame then
            local r, g, b, a = auraData.color[1], auraData.color[2], auraData.color[3], auraData.color[4]
            state.editorFrame.colorBtn.bg:SetColorTexture(r, g, b, a)
            state.editorFrame.rgbText:SetText(string.format("RGB: %d, %d, %d", r * 255, g * 255, b * 255))
            Ether.UpdatePreview()
            Ether.UpdateAuraList()
        end
    end
    colorPickerCallbacks.currentSpellId = nil
    colorPickerCallbacks.editorFrame = nil
end

local originalColor
local currentEditor
local function OnCancel(prevValues)
    if selectedSpellId and Ether.DB[1003][selectedSpellId] then
        local auraData = Ether.DB[1003][selectedSpellId]

        if prevValues then
            auraData.color[1] = prevValues.r
            auraData.color[2] = prevValues.g
            auraData.color[3] = prevValues.b
            auraData.color[4] = prevValues.a
        else
            auraData.color = {unpack(originalColor)}
        end

        local color = prevValues or {
            r = originalColor[1],
            g = originalColor[2],
            b = originalColor[3],
            a = originalColor[4]
        }
        currentEditor.colorBtn.bg:SetColorTexture(color.r, color.g, color.b, color.a)
        currentEditor.rgbText:SetText(string.format("RGB: %d, %d, %d",
                color.r * 255, color.g * 255, color.b * 255))
        Ether.UpdateAuraList()
    end
end

local function CreateEditor(parent)
    local frame = CreateFrame("Frame", nil, parent)
    Editor = frame
    frame:SetPoint("TOPRIGHT", 70, -50)
    frame:SetSize(320, 300)

    local name = frame:CreateFontString(nil, "OVERLAY", "GameFontWhiteSmall")
    frame.nameLabel = name
    name:SetPoint("TOPLEFT", 15, -5)
    name:SetText("Name")
    name:SetAlpha(.6)

    local nameInput = CreateLineInput(frame, 140, 24)
    frame.nameInput = nameInput
    nameInput:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 0, -10)
    nameInput:SetScript("OnEnterPressed", function(self)
        if selectedSpellId then
            Ether.DB[1003][selectedSpellId].name = self:GetText()
            Ether.UpdateAuraList()
        end
        self:ClearFocus()
    end)

    local spellID = frame:CreateFontString(nil, "OVERLAY", "GameFontWhiteSmall")
    frame.spellIdLabel = spellID
    spellID:SetPoint("TOPLEFT", nameInput, "BOTTOMLEFT", 0, -10)
    spellID:SetText("Spell ID")
    spellID:SetAlpha(.6)

    local spellIdInput = CreateLineInput(frame, 140, 24)
    frame.spellIdInput = spellIdInput
    spellIdInput:SetPoint("TOPLEFT", spellID, "BOTTOMLEFT", 0, -10)
    spellIdInput:SetNumeric(true)
    spellIdInput:SetScript("OnEnterPressed", function(self)
        local newId = tonumber(self:GetText())
        if selectedSpellId and newId and newId > 0 and newId ~= selectedSpellId then
            local data = Ether.DB[1003][selectedSpellId]
            Ether.DB[1003][selectedSpellId] = nil
            Ether.DB[1003][newId] = data
            selectedSpellId = newId
            Ether.UpdateAuraList()
            Ether.UpdateEditor()
        end
        self:ClearFocus()
    end)

    local sizeLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontWhiteSmall")
    frame.sizeLabel = sizeLabel
    sizeLabel:SetPoint("TOPLEFT", spellIdInput, "BOTTOMLEFT", 0, -100)
    sizeLabel:SetText("Size")

    local sizeSlider = CreateFrame("Slider", nil, frame, "OptionsSliderTemplate")
    frame.sizeSlider = sizeSlider
    sizeSlider:SetPoint("TOPLEFT", sizeLabel, "BOTTOMLEFT")
    sizeSlider:SetWidth(100)
    sizeSlider:SetMinMaxValues(4, 20)
    sizeSlider:SetValueStep(1)
    sizeSlider:SetObeyStepOnDrag(true)
    sizeSlider.Low:SetText("4")
    sizeSlider.High:SetText("20")
    sizeSlider:SetScript("OnValueChanged", function(self, value)
        if selectedSpellId then
            Ether.DB[1003][selectedSpellId].size = value
            frame.sizeValue:SetText(string.format("%.0f px", value))
            Ether.UpdatePreview()
        end
    end)
    local sizeSliderBG = sizeSlider:CreateTexture(nil, "BACKGROUND")
    sizeSliderBG:SetPoint("CENTER")
    sizeSliderBG:SetSize(100, 10)
    sizeSliderBG:SetColorTexture(0.2, 0.2, 0.2, 0.8)
    sizeSliderBG:SetDrawLayer("BACKGROUND", -1)

    local sizeValue = frame:CreateFontString(nil, "OVERLAY", "GameFontWhiteSmall")
    frame.sizeValue = sizeValue
    sizeValue:SetPoint("TOP", sizeSlider, "BOTTOM", 0, -5)
    sizeValue:SetText("6 px")

    local colorBtn = CreateFrame("Button", nil, frame)
    frame.colorBtn = colorBtn
    colorBtn:SetSize(15, 15)
    colorBtn:SetPoint("LEFT", sizeSlider, "RIGHT", 20, 0)
    frame.colorBtn.bg = colorBtn:CreateTexture(nil, "BACKGROUND")
    frame.colorBtn.bg:SetAllPoints()
    frame.colorBtn.bg:SetColorTexture(1, 1, 0, 1)
    frame.colorBtn:SetScript("OnClick", function()
        if not selectedSpellId then
            return
        end
        local data = Ether.DB[1003][selectedSpellId]
        originalColor = data.color
        currentEditor = frame
        local function OnColorChanged()
            local r, g, b = ColorPickerFrame:GetColorRGB()
            local a = ColorPickerFrame:GetColorAlpha()
            if selectedSpellId and Ether.DB[1003][selectedSpellId] then
                local auraData = Ether.DB[1003][selectedSpellId]
                auraData.color[1], auraData.color[2], auraData.color[3], auraData.color[4] = r, g, b, a
                currentEditor.colorBtn.bg:SetColorTexture(r, g, b, a)
                currentEditor.rgbText:SetText(string.format("RGB: %d, %d, %d", r * 255, g * 255, b * 255))
                Ether.UpdateAuraList()
                Ether.UpdatePreview()
            end
        end

        local swatchTexture = frame.colorBtn.bg
        ColorPickerFrame:SetupColorPickerAndShow({
            swatchFunc = OnColorChanged,
            opacityFunc = OnColorChanged,
            cancelFunc = OnCancel,
            hasOpacity = true,
            opacity = data.color[4],
            r = data.color[1],
            g = data.color[2],
            b = data.color[3],
            swatch = swatchTexture
        })
    end)

    local rgbText = frame:CreateFontString(nil, "OVERLAY")
    frame.rgbText = rgbText
    rgbText:SetFont(unpack(Ether.mediaPath.Font), 10, "OUTLINE")
    rgbText:SetPoint("LEFT", sizeSlider, "RIGHT", 40, 0)
    rgbText:SetText("RGB: 255, 255, 0")

    local preview = CreateFrame("Frame", nil, frame)
    frame.preview = preview
    preview:SetPoint("TOPLEFT", 15, -140)
    preview:SetSize(55, 55)

    local healthBar = CreateFrame("StatusBar", nil, preview)
    healthBar:SetFrameLevel(preview:GetFrameLevel() - 1)
    preview.healthBar = healthBar
    healthBar:SetPoint("BOTTOMLEFT")
    healthBar:SetSize(55, 55)
    healthBar:SetStatusBarTexture(unpack(Ether.mediaPath.statusBar))

    local pName = healthBar:CreateFontString(nil, "OVERLAY")
    pName:SetFont(unpack(Ether.mediaPath.Font), 10, "OUTLINE")
    pName:SetPoint("CENTER", healthBar, "CENTER", 0, -5)
    pName:SetText("|cffffd700ME|r")
    preview.indicator = preview:CreateTexture(nil, "OVERLAY")
    preview.indicator:SetSize(6, 6)
    preview.indicator:SetPoint("TOP", healthBar, "TOP", 0, 0)
    preview.indicator:SetColorTexture(1, 1, 0, 1)

    local positions = {
        {"TOPLEFT", "TOP", "TOPRIGHT"},
        {"LEFT", "CENTER", "RIGHT"},
        {"BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT"}
    }

    frame.posButtons = {}
    local startX, startY = 120, -120
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
            btn.text:SetFont(unpack(Ether.mediaPath.Font), 10, "OUTLINE")
            btn.text:SetPoint("CENTER")
            btn.text:SetText(pos:sub(1, 1))

            btn.position = pos
            btn:SetScript("OnClick", function(self)
                if selectedSpellId then
                    Ether.DB[1003][selectedSpellId].position = self.position
                    Ether.UpdateEditor()
                    Ether.UpdatePreview()
                end
            end)

            btn:SetScript("OnEnter", function(self)
                self.bg:SetColorTexture(0.3, 0.3, 0.3, 0.9)
            end)
            btn:SetScript("OnLeave", function(self)
                local data = selectedSpellId and Ether.DB[1003][selectedSpellId]
                if data and data.position == self.position then
                    self.bg:SetColorTexture(0.8, 0.6, 0, 0.4)
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
    offsetXSlider:SetWidth(100)
    offsetXSlider:SetMinMaxValues(-20, 20)
    offsetXSlider:SetValueStep(1)
    offsetXSlider:SetObeyStepOnDrag(true)
    offsetXSlider.Low:SetText("-20")
    offsetXSlider.High:SetText("20")
    offsetXSlider:SetScript("OnValueChanged", function(self, value)
        if selectedSpellId then
            Ether.DB[1003][selectedSpellId].offsetX = value
            frame.offsetXValue:SetText(string.format("%.0f", value))
            Ether.UpdatePreview()
        end
    end)
    local offsetXBG = offsetXSlider:CreateTexture(nil, "BACKGROUND")
    offsetXBG:SetPoint("CENTER")
    offsetXBG:SetSize(100, 10)
    offsetXBG:SetColorTexture(0.2, 0.2, 0.2, 0.8)
    offsetXBG:SetDrawLayer("BACKGROUND", -1)

    local offsetYLabel = frame:CreateFontString(nil, "OVERLAY")
    frame.offsetYLabel = offsetYLabel
    offsetYLabel:SetFont(unpack(Ether.mediaPath.Font), 10, "OUTLINE")
    offsetYLabel:SetPoint("LEFT", offsetXLabel, "RIGHT", 80, 0)
    offsetYLabel:SetText("Y Offset")

    local offsetYSlider = CreateFrame("Slider", nil, frame, "OptionsSliderTemplate")
    frame.offsetYSlider = offsetYSlider
    offsetYSlider:SetPoint("TOPLEFT", offsetYLabel, "BOTTOMLEFT")
    offsetYSlider:SetWidth(100)
    offsetYSlider:SetMinMaxValues(-20, 20)
    offsetYSlider:SetValueStep(1)
    offsetYSlider.Low:SetText("-20")
    offsetYSlider.High:SetText("20")
    offsetYSlider:SetObeyStepOnDrag(true)
    offsetYSlider:SetScript("OnValueChanged", function(self, value)
        if selectedSpellId then
            Ether.DB[1003][selectedSpellId].offsetY = value
            frame.offsetYValue:SetText(string.format("%.0f", value))
            Ether.UpdatePreview()
        end
    end)
    local offsetYBG = offsetYSlider:CreateTexture(nil, "BACKGROUND")
    offsetYBG:SetPoint("CENTER")
    offsetYBG:SetSize(100, 10)
    offsetYBG:SetColorTexture(0.2, 0.2, 0.2, 0.6)
    offsetYBG:SetDrawLayer("BACKGROUND", -1)

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

local function protoType(newId)
    local obj = {
        name = "New Aura " .. newId,
        color = {1, 1, 0, 1},
        size = 6,
        position = "TOP",
        offsetX = 0,
        offsetY = 0,
        enabled = true,
        isDebuff = false
    }
    return obj
end

function Ether.UpdateAuraList()

    for _, btn in ipairs(AuraButtons) do
        btn:Hide()
        btn:SetParent(nil)
    end

    wipe(AuraButtons)

    local yOffset = -5
    local index = 1

    for spellId, data in pairs(Ether.DB[1003]) do
        local btn = CreateFrame("Button", nil, AuraList.scrollChild)
        btn:SetSize(180, 40)
        btn:SetPoint("TOP", 0, yOffset)

        btn.bg = btn:CreateTexture(nil, "BACKGROUND")
        btn.bg:SetAllPoints()
        btn.bg:SetColorTexture(0.1, 0.1, 0.1, 0.6)

        btn:SetScript("OnEnter", function(self)
            self.bg:SetColorTexture(0.2, 0.2, 0.2, 0.7)
        end)
        btn:SetScript("OnLeave", function(self)
            if selectedSpellId == spellId then
                self.bg:SetColorTexture(0.80, 0.40, 1.00, 0.2)
            else
                self.bg:SetColorTexture(0.1, 0.1, 0.1, 0.8)
            end
        end)

        btn:SetScript("OnClick", function()
            Ether.SelectAura(spellId)
        end)

        btn.name = btn:CreateFontString(nil, "OVERLAY")
        btn.name:SetFont(unpack(Ether.mediaPath.Font), 10, "OUTLINE")
        btn.name:SetPoint("TOPLEFT", 10, -8)
        btn.name:SetText(data.name or "Unknown")

        btn.spellId = btn:CreateFontString(nil, "OVERLAY")
        btn.spellId:SetFont(unpack(Ether.mediaPath.Font), 10, "OUTLINE")
        btn.spellId:SetPoint("TOPLEFT", 10, -23)
        btn.spellId:SetText("Spell ID: " .. spellId)
        btn.spellId:SetTextColor(0, 0.8, 1)

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
                Ether.DB[1003][spellId] = nil
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
        table.insert(AuraButtons, btn)

        if selectedSpellId == spellId then
            btn.bg:SetColorTexture(0, 0.8, 1, 0.8, .3)
        end
        yOffset = yOffset - 55
        index = index + 1
    end
    AuraList.scrollChild:SetHeight(math.max(1, index * 55))
end

function Ether.UpdateEditor()
    if not selectedSpellId or not Ether.DB[1003][selectedSpellId] then
        return
    end
    local data = Ether.DB[1003][selectedSpellId]
    Editor.nameInput:SetText(data.name or "")
    Editor.nameInput:Enable()
    Editor.spellIdInput:SetText(tostring(selectedSpellId))
    Editor.colorBtn.bg:SetColorTexture(data.color[1], data.color[2], data.color[3], data.color[4])
    Editor.rgbText:SetText(string.format("RGB: %d, %d, %d",
            data.color[1] * 255, data.color[2] * 255, data.color[3] * 255))

    Editor.sizeSlider:SetValue(data.size)
    Editor.sizeValue:SetText(string.format("%.0f px", data.size))

    for pos, btn in pairs(Editor.posButtons) do
        if pos == data.position then
            btn.bg:SetColorTexture(0.8, 0.6, 0, 0.5)
            btn:Enable()
        else
            btn.bg:SetColorTexture(0.2, 0.2, 0.2, 0.5)
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

    local data = Ether.DB[1003][selectedSpellId]
    local indicator = Editor.preview.indicator

    indicator:SetSize(data.size, data.size)
    indicator:SetColorTexture(data.color[1], data.color[2], data.color[3], data.color[4])

    indicator:ClearAllPoints()

    local posMap = {
        TOPLEFT = {"TOPLEFT", data.offsetX, data.offsetY},
        TOP = {"TOP", data.offsetX, data.offsetY},
        TOPRIGHT = {"TOPRIGHT", data.offsetX, data.offsetY},
        LEFT = {"LEFT", data.offsetX, -data.offsetY},
        CENTER = {"CENTER", data.offsetX, -data.offsetY},
        RIGHT = {"RIGHT", data.offsetX, -data.offsetY},
        BOTTOMLEFT = {"BOTTOMLEFT", data.offsetX, data.offsetY},
        BOTTOM = {"BOTTOM", data.offsetX, data.offsetY},
        BOTTOMRIGHT = {"BOTTOMRIGHT", data.offsetX, data.offsetY}
    }

    local pos = posMap[data.position]
    if pos then
        indicator:SetPoint(pos[1], Editor.preview.healthBar, pos[1], pos[2], pos[3])
    end
end

function Ether.SelectAura(spellId)
    selectedSpellId = spellId
    Ether.UpdateAuraList()
    Ether.UpdateEditor()
end

function Ether:AddNewAura()
    local newId = 1
    while Ether.DB[1003][newId] do
        newId = newId + 1
    end
    Ether.DB[1003][newId] = protoType(newId)
    Ether:SelectAura(newId)
end

function Ether.CreateRegisterSection(self)
    local parent = self.Content.Children["Register"]

    local I_Register = {
        [1] = {text = "Ready check", texture = "Interface\\RaidFrame\\ReadyCheck-Ready", texture2 = "Interface\\RaidFrame\\ReadyCheck-NotReady", texture3 = "Interface\\RaidFrame\\ReadyCheck-Waiting"},
        [2] = {text = "Connection", texture = "Interface\\CharacterFrame\\Disconnect-Icon", size = 30},
        [3] = {text = "Raid target update", texture = "Interface\\TargetingFrame\\UI-RaidTargetingIcons", size = 14, coo = {0.75, 1, 0.25, 0.5}},
        [4] = {text = "Resurrection", texture = "Interface\\RaidFrame\\Raid-Icon-Rez", size = 20},
        [5] = {text = "Leader", texture = "Interface\\GroupFrame\\UI-Group-LeaderIcon"},
        [6] = {text = "Loot method", texture = "Interface\\GroupFrame\\UI-Group-MasterLooter", size = 16},
        [7] = {text = "Unit Flags |cffff0000 Red Name|r  &", texture = "Interface\\Icons\\Spell_Holy_GuardianSpirit"},
        [8] = {text = "Maintank and Mainassist", texture = "Interface\\GroupFrame\\UI-Group-MainTankIcon", texture2 = "Interface\\GroupFrame\\UI-Group-MainAssistIcon"},
        [9] = {text = "Player flags  |cE600CCFFAFK|r & |cffCC66FFDND|r"}
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
        btn.texture:SetPoint("LEFT", btn.label, "RIGHT", 8, 0)
        btn.texture:SetTexture(opt.texture)
        btn.texture2 = btn:CreateTexture(nil, "OVERLAY")
        btn.texture2:SetSize(18, 18)
        btn.texture2:SetPoint("LEFT", btn.label, "RIGHT", 35, 0)
        btn.texture2:SetTexture(opt.texture2)
        btn.texture3 = btn:CreateTexture(nil, "OVERLAY")
        btn.texture3:SetSize(18, 18)
        btn.texture3:SetPoint("LEFT", btn.label, "RIGHT", 60, 0)
        btn.texture3:SetTexture(opt.texture3)
        if opt.size then
            btn.texture:SetSize(opt.size, opt.size)
        end
        if opt.coo then
            btn.texture:SetTexCoord(unpack(opt.coo))
        end
        if opt.coo2 then
            btn.texture2:SetTexCoord(unpack(opt.coo2))
        end
        if opt.coo3 then
            btn.texture3:SetTexCoord(unpack(opt.coo3))
        end
        btn:SetChecked(DB[501][i] == 1)

        btn:SetScript("OnClick", function(self)
            local checked = self:GetChecked()
            Ether.DB[501][i] = checked and 1 or 0
            Ether:IndicatorsToggle()
            Ether:UpdateIndex(i)
        end)
        self.Content.Buttons.Indicators.A[i] = btn
    end
end

local number = nil
local iconTexture = ""
local Indicator
local coordinates = ""
local indicatorType = ""
local currentIndicator = nil
function Ether.CreatePositionSection(self)
    local parent = self.Content.Children["Position"]
    local frame = CreateFrame("Frame", nil, parent)
    Indicator = frame

    Indicator.sizeValue = nil
    Indicator.offsetXValue = nil
    Indicator.offsetYValue = nil

    local selectLabel = parent:CreateFontString(nil, "OVERLAY")
    selectLabel:SetFont(unpack(Ether.mediaPath.Font), 12, "OUTLINE")
    selectLabel:SetPoint("TOPLEFT", 10, -10)
    selectLabel:SetText("Select Indicator")

    local templateDropdown = CreateFrame("Button", nil, parent, "UIDropDownMenuTemplate")
    templateDropdown:SetPoint("TOPLEFT", selectLabel, "BOTTOMLEFT", -10, -10)
    UIDropDownMenu_SetWidth(templateDropdown, 140)
    UIDropDownMenu_SetText(templateDropdown, "...")

    local indicators = {
        [1] = {name = "ReadyCheck", icon = "Interface\\RaidFrame\\ReadyCheck-Ready", type = "texture"},
        [2] = {name = "Connection", icon = "Interface\\CharacterFrame\\Disconnect-Icon", type = "texture"},
        [3] = {name = "RaidTarget", icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcons", coordinates = {0.75, 1, 0.25, 0.5}, type = "texture"},
        [4] = {name = "Resurrection", icon = "Interface\\RaidFrame\\Raid-Icon-Rez", type = "texture"},
        [5] = {name = "GroupLeader", icon = "Interface\\GroupFrame\\UI-Group-LeaderIcon", type = "texture"},
        [6] = {name = "MasterLoo0t", icon = "Interface\\GroupFrame\\UI-Group-MasterLooter", type = "texture"},
        [7] = {name = "UnitFlags", icon = "Interface\\Icons\\Spell_Holy_GuardianSpirit", type = "texture"},
        [8] = {name = "PlayerRoles", icon = "Interface\\GroupFrame\\UI-Group-MainTankIcon", type = "texture"},
        [9] = {name = "PlayerFlags", type = "string"},
    }

    UIDropDownMenu_Initialize(templateDropdown, function()
        for id, name in ipairs(indicators) do
            local data = indicators[id]
            local info = UIDropDownMenu_CreateInfo()
            info.text = data.name
            info.func = function()
                number = id
                if data.type == "texture" then
                    indicatorType = indicators[id].type
                    iconTexture = indicators[id].icon
                    coordinates = indicators[id].coordinates
                    currentIndicator = indicators[id].name
                end
                if data.type == "string" then
                    indicatorType = indicators[id].type
                    coordinates = indicators[id].coordinates
                    currentIndicator = indicators[id].name
                end
                UIDropDownMenu_SetSelectedValue(templateDropdown, id)
                UIDropDownMenu_SetText(templateDropdown, data.name)
                Ether.UpdateIndicatorsValue()
            end
            UIDropDownMenu_AddButton(info)
        end
    end)

    local preview = CreateFrame("Frame", nil, parent)
    preview:SetPoint("TOPLEFT", selectLabel, "BOTTOMLEFT", 80, -100)
    preview:SetSize(55, 55)

    local healthBar = CreateFrame("StatusBar", nil, preview)
    Indicator.healthBar = healthBar
    healthBar:SetFrameLevel(preview:GetFrameLevel() - 1)
    healthBar:SetPoint("CENTER")
    healthBar:SetSize(55, 55)
    healthBar:SetStatusBarTexture(unpack(Ether.mediaPath.statusBar))

    local name = healthBar:CreateFontString(nil, "OVERLAY")
    name:SetFont(unpack(Ether.mediaPath.Font), 10, "OUTLINE")
    name:SetPoint("CENTER", healthBar, "CENTER", 0, -5)
    name:SetText("|cffffd700ME|r")

    local icon = healthBar:CreateTexture(nil, "OVERLAY")
    Indicator.icon = icon
    icon:SetSize(12, 12)
    icon:SetPoint("TOP", healthBar, "TOP", 0, 0)
    icon:SetTexture(iconTexture)

    local textIndicator = healthBar:CreateFontString(nil, "OVERLAY")
    textIndicator:SetFont(unpack(Ether.mediaPath.Font), 10, "OUTLINE")
    Indicator.text = textIndicator
    textIndicator:SetPoint("TOP", healthBar, "TOP", 0, 0)
    textIndicator:Hide()

    local positions = {
        {"TOPLEFT", "TOP", "TOPRIGHT"},
        {"LEFT", "CENTER", "RIGHT"},
        {"BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT"}
    }

    Indicator.posButtons = {}
    local startX, startY = 110, 0
    local btnSize = 25

    for row = 1, 3 do
        for col = 1, 3 do
            local pos = positions[row][col]
            local btn = CreateFrame("Button", nil, preview)
            btn:SetSize(btnSize, btnSize)
            btn:SetPoint("TOPLEFT", startX + (col - 1) * (btnSize + 1), startY - (row - 1) * (btnSize + 1))

            btn.bg = btn:CreateTexture(nil, "BACKGROUND")
            btn.bg:SetAllPoints()
            btn.bg:SetColorTexture(0.2, 0.2, 0.2, 0.8)

            btn.text = btn:CreateFontString(nil, "OVERLAY")
            btn.text:SetFont(unpack(Ether.mediaPath.Font), 10, "OUTLINE")
            btn.text:SetPoint("CENTER")
            btn.text:SetText(pos:sub(1, 1))

            btn.position = pos
            btn:SetScript("OnClick", function(self)
                if number then
                    Ether.DB[1002][number][2] = self.position
                    Ether.UpdateIndicatorsValue()
                end
            end)

            btn:SetScript("OnEnter", function(self)
                self.bg:SetColorTexture(0.3, 0.3, 0.3, 0.9)
            end)
            btn:SetScript("OnLeave", function(self)
                local data = number and Ether.DB[1002][number]
                if data and data[2] == self.position then
                    self.bg:SetColorTexture(0.8, 0.6, 0, 0.4)
                else
                    self.bg:SetColorTexture(0.2, 0.2, 0.2, 0.8)
                end
            end)

            Indicator.posButtons[pos] = btn
        end
    end

    local sizeLabel = parent:CreateFontString(nil, "OVERLAY")
    sizeLabel:SetFont(unpack(Ether.mediaPath.Font), 10, "OUTLINE")
    sizeLabel:SetPoint("TOPLEFT", preview, "BOTTOMLEFT", 40, -50)
    sizeLabel:SetText("Size")

    local confirm = CreateFrame("Button", nil, preview)
    confirm:SetSize(80, 25)
    confirm:SetPoint("TOPLEFT", preview, "TOPRIGHT", 160, 0)
    confirm.bg = confirm:CreateTexture(nil, "BACKGROUND")
    confirm.bg:SetAllPoints()
    confirm.bg:SetColorTexture(0.2, 0.2, 0.2, 0.8)
    confirm.text = confirm:CreateFontString(nil, "OVERLAY", "GameFontWhiteSmall")
    confirm.text:SetPoint("CENTER")
    confirm.text:SetText("Confirm")
    confirm:SetScript("OnClick", function(self)
        if currentIndicator and number then
            Ether.SaveIndicatorsPos(currentIndicator, number)
        end
    end)
    confirm:SetScript("OnEnter", function(self)
        self.bg:SetColorTexture(0.3, 0.3, 0.3, 0.9)
    end)
    confirm:SetScript("OnLeave", function(self)
        self.bg:SetColorTexture(0.2, 0.2, 0.2, 0.8)
    end)

    local sizeSlider = CreateFrame("Slider", nil, parent, "OptionsSliderTemplate")
    Indicator.sizeSlider = sizeSlider
    sizeSlider:SetPoint("TOPLEFT", sizeLabel, "BOTTOMLEFT")
    sizeSlider:SetWidth(100)
    sizeSlider:SetMinMaxValues(4, 34)
    sizeSlider:SetValueStep(1)
    sizeSlider:SetObeyStepOnDrag(true)
    sizeSlider.Low:SetText("4")
    sizeSlider.High:SetText("34")
    sizeSlider:SetScript("OnValueChanged", function(self, value)
        if number then
            Ether.DB[1002][number][1] = value
            if Indicator.sizeValue then
                Indicator.sizeValue:SetText(string.format("%.0f px", value))
            end
            Ether.UpdateIndicatorsValue()
        end
    end)
    local sizeSliderBG = sizeSlider:CreateTexture(nil, "BACKGROUND")
    sizeSliderBG:SetPoint("CENTER")
    sizeSliderBG:SetSize(100, 10)
    sizeSliderBG:SetColorTexture(0.2, 0.2, 0.2, 0.8)
    sizeSliderBG:SetDrawLayer("BACKGROUND", -1)

    local sizeValue = parent:CreateFontString(nil, "OVERLAY")
    Indicator.sizeValue = sizeValue
    sizeValue:SetFont(unpack(Ether.mediaPath.Font), 10, "OUTLINE")
    sizeValue:SetPoint("TOP", sizeSlider, "BOTTOM", 0, -5)
    sizeValue:SetText("6 px")

    local offsetXLabel = parent:CreateFontString(nil, "OVERLAY")
    offsetXLabel:SetFont(unpack(Ether.mediaPath.Font), 10, "OUTLINE")
    offsetXLabel:SetPoint("TOPLEFT", sizeLabel, "BOTTOMLEFT", 0, -50)
    offsetXLabel:SetText("X Offset")

    local offsetXSlider = CreateFrame("Slider", nil, parent, "OptionsSliderTemplate")
    Indicator.offsetXSlider = offsetXSlider
    offsetXSlider:SetPoint("TOPLEFT", offsetXLabel, "BOTTOMLEFT")
    offsetXSlider:SetWidth(100)
    offsetXSlider:SetMinMaxValues(-20, 20)
    offsetXSlider:SetValueStep(1)
    offsetXSlider:SetObeyStepOnDrag(true)
    offsetXSlider.Low:SetText("-20")
    offsetXSlider.High:SetText("20")
    offsetXSlider:SetScript("OnValueChanged", function(self, value)
        if number then
            Ether.DB[1002][number][3] = value
            if Indicator.offsetXValue then
                Indicator.offsetXValue:SetText(string.format("%.0f", value))
            end
            Ether.UpdateIndicatorsValue()
        end
    end)
    local offsetXBG = offsetXSlider:CreateTexture(nil, "BACKGROUND")
    offsetXBG:SetPoint("CENTER")
    offsetXBG:SetSize(100, 10)
    offsetXBG:SetColorTexture(0.2, 0.2, 0.2, 0.8)
    offsetXBG:SetDrawLayer("BACKGROUND", -1)

    local offsetXValue = parent:CreateFontString(nil, "OVERLAY")
    Indicator.offsetXValue = offsetXValue
    offsetXValue:SetFont(unpack(Ether.mediaPath.Font), 10, "OUTLINE")
    offsetXValue:SetPoint("TOP", offsetXSlider, "BOTTOM")
    offsetXValue:SetText("0")

    local offsetYLabel = parent:CreateFontString(nil, "OVERLAY")
    offsetYLabel:SetFont(unpack(Ether.mediaPath.Font), 10, "OUTLINE")
    offsetYLabel:SetPoint("LEFT", offsetXLabel, "RIGHT", 80, 0)
    offsetYLabel:SetText("Y Offset")

    local offsetYSlider = CreateFrame("Slider", nil, parent, "OptionsSliderTemplate")
    Indicator.offsetYSlider = offsetYSlider
    offsetYSlider:SetPoint("TOPLEFT", offsetYLabel, "BOTTOMLEFT")
    offsetYSlider:SetWidth(100)
    offsetYSlider:SetMinMaxValues(-20, 20)
    offsetYSlider:SetValueStep(1)
    offsetYSlider:SetObeyStepOnDrag(true)
    offsetYSlider.Low:SetText("-20")
    offsetYSlider.High:SetText("20")
    offsetYSlider:SetScript("OnValueChanged", function(self, value)
        if number then
            Ether.DB[1002][number][4] = value
            if Indicator.offsetYValue then
                Indicator.offsetYValue:SetText(string.format("%.0f", value))
            end
            Ether.UpdateIndicatorsValue()
        end
    end)
    local offsetYBG = offsetYSlider:CreateTexture(nil, "BACKGROUND")
    offsetYBG:SetPoint("CENTER")
    offsetYBG:SetSize(100, 10)
    offsetYBG:SetColorTexture(0.2, 0.2, 0.2, 0.6)
    offsetYBG:SetDrawLayer("BACKGROUND", -1)

    local offsetYValue = parent:CreateFontString(nil, "OVERLAY")
    Indicator.offsetYValue = offsetYValue
    offsetYValue:SetFont(unpack(Ether.mediaPath.Font), 10, "OUTLINE")
    offsetYValue:SetPoint("TOP", offsetYSlider, "BOTTOM")
    offsetYValue:SetText("0")
end

function Ether.UpdateIndicatorsValue()
    if not number then return end
    local data = Ether.DB[1002][number]
    if not data then return end

    Indicator.icon:Hide()
    Indicator.text:Hide()

    if indicatorType == "texture" then
        Indicator.icon:SetTexture(iconTexture)
        Indicator.icon:SetTexCoord(0, 1, 0, 1)
        Indicator.icon:Show()
        if coordinates then
            Indicator.icon:SetTexCoord(unpack(coordinates))
        end
    elseif indicatorType == "string" then
        Indicator.text:Show()
        Indicator.text:SetText([[|cE600CCFFAFK|r]])
    end

    Indicator.sizeSlider:SetValue(data[1])

    if Indicator.sizeValue then
        Indicator.sizeValue:SetText(string.format("%.0f px", data[1]))
    end

    for pos, btn in pairs(Indicator.posButtons) do
        if pos == data[2] then
            btn.bg:SetColorTexture(0.8, 0.6, 0, 0.5)
        else
            btn.bg:SetColorTexture(0.2, 0.2, 0.2, 0.5)
        end
    end

    Indicator.offsetXSlider:SetValue(data[3])
    if Indicator.offsetXValue then
        Indicator.offsetXValue:SetText(string.format("%.0f", data[3]))
    end

    Indicator.offsetYSlider:SetValue(data[4])
    if Indicator.offsetYValue then
        Indicator.offsetYValue:SetText(string.format("%.0f", data[4]))
    end

    Ether.UpdateIndicators()
end

function Ether.UpdateIndicators()
    if not number then return end
    local data = Ether.DB[1002][number]
    if not data then return end

    if indicatorType == "texture" then
        Indicator.icon:SetSize(data[1], data[1])
        Indicator.icon:ClearAllPoints()
        Indicator.icon:SetPoint(data[2], Indicator.healthBar, data[2], data[3], data[4])
    elseif indicatorType == "string" then
        Indicator.text:SetSize(data[1], data[1])
        Indicator.text:ClearAllPoints()
        Indicator.text:SetPoint(data[2], Indicator.healthBar, data[2], data[3], data[4])
    end
end

function Ether.CreateLayoutSection(self)
    local parent = self.Content.Children["Layout"]

    local layoutValue = {
        [1] = {text = "Create/Delete Player CastBar"},
        [2] = {text = "Create/Delete Target CastBar"},
        [3] = {text = "Smooth Bar Solo Health"},
        [4] = {text = "Smooth Bar Solo Power"},
        [5] = {text = "Smooth Bar Header"},
        [6] = {text = "Range check"},
        [7] = {text = "CastBar - Icon"},
        [8] = {text = "CastBar - Time"},
        [9] = {text = "CastBar - Name"},
        [10] = {text = "CastBar - SafeZone"},
        [11] = {text = "CastBar - IsTradeSkill"}
    }

    local layout = CreateFrame("Frame", nil, parent)
    layout:SetSize(200, (#layoutValue * 30) + 60)

    for i, opt in ipairs(layoutValue) do
        local btn = CreateFrame("CheckButton", nil, layout, "InterfaceOptionsCheckButtonTemplate")

        if i == 1 then
            btn:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, -10)
        else
            btn:SetPoint("TOPLEFT", self.Content.Buttons.Layout.A[i - 1], "BOTTOMLEFT", 0, 0)
        end
        btn:SetSize(24, 24)
        btn.label = GetFont(self, btn, opt.text, 12)
        btn.label:SetPoint("LEFT", btn, "RIGHT", 10, 0)
        btn:SetChecked(Ether.DB[801][i] == 1)
        btn:SetScript("OnClick", function(self)
            local checked = self:GetChecked()
            Ether.DB[801][i] = checked and 1 or 0
            if i == 1 then
                if Ether.DB[801][1] == 1 then
                    Ether.CastBar.Enable("player")
                else
                    Ether.CastBar.Disable("player")
                end
            elseif i == 2 then
                if Ether.DB[801][2] == 1 then
                    Ether.CastBar.Enable("target")
                else
                    Ether.CastBar.Disable("target")
                end
            elseif i == 2 then
                if Ether.DB[801][2] == 1 then
                    Ether.CastBar.Enable("target")
                else
                    Ether.CastBar.Disable("target")
                end
            elseif i == 6 then
                if Ether.DB[801][6] == 1 then
                    Ether:RangeEnable()
                else
                    Ether:RangeDisable()
                end
            end
        end)
        self.Content.Buttons.Layout.A[i] = btn
    end
end

function Ether.CreateTooltipSection(self)
    local parent = self.Content.Children["Tooltip"]

    local Tooltip = {
        [1] = {name = "AFK"},
        [2] = {name = "DND"},
        [3] = {name = "PVP Icon"},
        [4] = {name = "Resting Icon"},
        [5] = {name = "Realm"},
        [6] = {name = "Level"},
        [7] = {name = "Class"},
        [8] = {name = "Guild"},
        [9] = {name = "Role"},
        [10] = {name = "Creature Type"},
        [11] = {name = "Race", },
        [12] = {name = "Raid Target"},
        [13] = {name = "Reaction"}
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
            btn:SetPoint("TOPLEFT", self.Content.Buttons.Tooltip.A[i - 1], "BOTTOMLEFT", 0, 0)
        end

        btn:SetSize(24, 24)

        btn.label = GetFont(self, btn, opt.name, 12)
        btn.label:SetPoint("LEFT", btn, "RIGHT", 8, 1)
        btn:SetChecked(Ether.DB[301][i] == 1)

        btn:SetScript("OnClick", function(self)
            local checked = self:GetChecked()
            Ether.DB[301][i] = checked and 1 or 0
        end)

        self.Content.Buttons.Tooltip.A[i] = btn
    end
end

function Ether.CreateConfigSection(self)
    local parent = self.Content.Children["Config"]
    local DB = Ether.DB

    local FRAME_GROUPS = {
        [331] = {name = "Tooltip", frame = Ether.Anchor.tooltip},
        [332] = {name = "Player", frame = Ether.unitButtons.solo["player"]},
        [333] = {name = "Target", frame = Ether.unitButtons.solo["target"]},
        [334] = {name = "TargetTarget", frame = Ether.unitButtons.solo["targettarget"]},
        [335] = {name = "Pet", frame = Ether.unitButtons.solo["pet"]},
        [336] = {name = "Pet Target", frame = Ether.unitButtons.solo["pettarget"]},
        [337] = {name = "Focus", frame = Ether.unitButtons.solo["focus"]},
        [338] = {name = "Raid", frame = Ether.Anchor.raid},
        [339] = {name = "Debug", frame = Ether.DebugFrame},
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
        local slider = CreateFrame("Slider", nil, parent, "OptionsSliderTemplate")
        slider:SetPoint("TOPLEFT", relativeTo, "BOTTOMLEFT", 0, -10)
        slider:SetWidth(140)
        slider:SetMinMaxValues(min, max)
        slider:SetValueStep(step)
        slider:SetObeyStepOnDrag(true)
        slider.Low:Hide()
        slider.High:Hide()
        local BG = slider:CreateTexture(nil, "BACKGROUND")
        BG:SetPoint("CENTER")
        BG:SetSize(140, 10)
        BG:SetColorTexture(0.2, 0.2, 0.2, 0.8)
        BG:SetDrawLayer("BACKGROUND", -1)
        local currentFrame = DB[111].SELECTED
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
            local frame = DB[111].SELECTED
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
        local SELECTED = DB[111].SELECTED
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
                    local oldFrame = DB[111].SELECTED
                    Ether.DB[111].SELECTED = id
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
                    local currentFrame = DB[111].SELECTED
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

        for i, default in ipairs({"CENTER", 5133, "CENTER", 0, 0, 100, 100, 1, 1}) do
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
            frame:SetScale(pos[8])
            frame:SetAlpha(pos[9])
        end

        if frameGroup == DB[111].SELECTED then
            UpdateValue()
        end
    end)

    local function SetInitialValue()
        local currentFrame = DB[111].SELECTED
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
    dropdown:SetPoint("TOPLEFT", dropdownLabel, "BOTTOMLEFT", 0, -20)
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
        insets = {left = 11, right = 12, top = 12, bottom = 11}
    })
    local inputTitle = inputDialog:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    inputTitle:SetPoint("TOP", inputDialog, "TOP", 0, -15)
    local inputBox = CreateFrame("EditBox", nil, inputDialog, "InputBoxTemplate")
    inputBox:SetSize(250, 30)
    inputBox:SetPoint("TOP", inputTitle, "BOTTOM", 0, -10)
    inputBox:SetAutoFocus(false)
    local okButton = CreateFrame("Button", nil, inputDialog, "GameMenuButtonTemplate")
    okButton:SetSize(100, 25)
    okButton:SetPoint("BOTTOMLEFT", inputDialog, "BOTTOM", 0, 15)
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
        btn:GetFontString():SetFont(unpack(Ether.mediaPath.Font), 10, "OUTLINE")
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
            else
                Ether.DebugOutput("|cffcc66ffEther|r Enter name")
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

    local transfer = CreateFrame("Frame", nil, parent)
    transfer:SetPoint("TOPLEFT", parent, "TOPLEFT", 240, -10)
    transfer:SetSize(300, 200)

    local transferTitle = transfer:CreateFontString(nil, "OVERLAY")
    transferTitle:SetFont(unpack(Ether.mediaPath.Font), 13, "OUTLINE")
    transferTitle:SetPoint("TOPLEFT")
    transferTitle:SetText("Transfer")

    local exportBtn = CreateFrame("Button", nil, transfer, "GameMenuButtonTemplate")
    exportBtn:SetSize(120, 30)
    exportBtn:SetPoint("TOPLEFT", transferTitle, "BOTTOMLEFT", 0, -10)
    exportBtn:SetText("Export Profile")
    exportBtn:GetFontString():SetFont(unpack(Ether.mediaPath.Font), 10, "OUTLINE")

    exportBtn:SetScript("OnClick", function()
        local encoded = Ether.ExportProfileToClipboard()
        if encoded then
            Ether.ShowExportPopup(encoded)
        end
    end)

    local importBox
    local importBtn = CreateFrame("Button", nil, transfer, "GameMenuButtonTemplate")
    importBtn:SetSize(120, 30)
    importBtn:SetPoint("TOPLEFT", exportBtn, "BOTTOMLEFT", 0, -10)
    importBtn:SetText("Import Profile")
    importBtn:GetFontString():SetFont(unpack(Ether.mediaPath.Font), 10, "OUTLINE")

    importBtn:SetScript("OnClick", function()
        local data = importBox:GetText()
        if data and data ~= "" and data ~= "Paste export data here..." then
            local success, msg = Ether.ImportProfile(data)
            if success then
                Ether.DebugOutput("|cff00ff00" .. msg .. "|r")
                importBox:SetText("")
                parent.Refresh()
            else
                Ether.DebugOutput("|cffff0000" .. msg .. "|r")
            end
        else
            Ether.DebugOutput("|cffff0000No data to import|r")
        end
    end)

    local importLabel = transfer:CreateFontString(nil, "OVERLAY")
    importLabel:SetFont(unpack(Ether.mediaPath.Font), 11, "OUTLINE")
    importLabel:SetPoint("TOPLEFT", importBtn, "BOTTOMLEFT", 0, -20)
    importLabel:SetText("Paste to import:")

    local importBackdrop = CreateFrame("Frame", nil, transfer, "BackdropTemplate")
    importBackdrop:SetPoint("TOPLEFT", importLabel, "BOTTOMLEFT", 0, -5)
    importBackdrop:SetSize(250, 200)
    importBackdrop:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = {left = 4, right = 4, top = 4, bottom = 4}
    })
    importBackdrop:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
    importBackdrop:SetBackdropBorderColor(0.4, 0.4, 0.4)
    importBox = CreateFrame("EditBox", nil, importBackdrop)
    importBox:SetPoint("TOPLEFT", importBackdrop, "TOPLEFT", 8, -8)
    importBox:SetPoint("BOTTOMRIGHT", importBackdrop, "BOTTOMRIGHT", -8, 8)
    importBox:SetMultiLine(true)
    importBox:SetAutoFocus(false)
    importBox:SetFont(unpack(Ether.mediaPath.Font), 9, "OUTLINE")
    importBox:SetText("Paste export data here...")
    importBox:SetTextColor(0.7, 0.7, 0.7)
    importBox:SetScript("OnMouseWheel", function(self, delta)
        local current = self:GetText()
        if delta > 0 then
            self:SetCursorPosition(0)
        else
            self:SetCursorPosition(#current)
        end
    end)

    importBox:SetScript("OnEditFocusGained", function(self)
        if self:GetText() == "Paste export data here..." then
            self:SetText("")
            self:SetTextColor(1, 1, 1)
        end
        self:HighlightText()
    end)

    importBox:SetScript("OnEditFocusLost", function(self)
        if self:GetText() == "" then
            self:SetText("Paste export data here...")
            self:SetTextColor(0.7, 0.7, 0.7)
        end
    end)

    importBox:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)

    function Ether.ShowExportPopup(encoded)
        if not Ether.ExportPopup then
            Ether.CreateExportPopup()
        end

        Ether.ExportPopup.EditBox:SetText(encoded)
        Ether.ExportPopup:Show()
    end

    local frame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    frame:SetSize(400, 300)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:Hide()

    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = {left = 11, right = 12, top = 12, bottom = 11}
    })
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", frame, "TOP", 0, -15)
    title:SetText("Export Data (copied to clipboard)")
    local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -40)
    scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 40)
    frame.EditBox = CreateFrame("EditBox", nil, scrollFrame)
    frame.EditBox:SetSize(350, 200)
    frame.EditBox:SetMultiLine(true)
    frame.EditBox:SetFont(unpack(Ether.mediaPath.Font), 9, "OUTLINE")
    frame.EditBox:SetAutoFocus(false)
    frame.EditBox:SetTextInsets(5, 5, 5, 5)
    scrollFrame:SetScrollChild(frame.EditBox)
    local closeBtn = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
    closeBtn:SetSize(100, 25)
    closeBtn:SetPoint("BOTTOM", frame, "BOTTOM", 0, 15)
    closeBtn:SetText("Close")
    closeBtn:SetScript("OnClick", function()
        frame:Hide()
    end)
    Ether.ExportPopup = frame
    parent.Refresh = RefreshDropdown
    parent.RefreshConfig = function()

    end
end

function Ether.ExportCurrentProfile()
    local profileName = ETHER_DATABASE_DX_AA.currentProfile
    local profileData = ETHER_DATABASE_DX_AA.profiles[profileName]
    if not profileData then
        return nil, "Current profile not found"
    end
    local exportData = {
        version = 1.0,
        addon = "Ether",
        timestamp = time(),
        profileName = profileName,
        data = Ether.CopyTable(profileData)
    }
    local serialized = Ether.TblToString(exportData)
    local encoded = Ether.Base64Encode(serialized)
    Ether.DebugOutput("|cff00ff00Export ready:|r " .. profileName)
    Ether.DebugOutput("|cff888888Size:|r " .. #encoded .. " characters")
    return encoded
end

function Ether.ImportProfile(encodedString)
    if not encodedString or encodedString == "" then
        return false, "Empty import string"
    end

    local decoded = Ether.Base64Decode(encodedString)
    if not decoded then
        return false, "Invalid Base64 encoding"
    end

    local success, importedData = Ether.StringToTbl(decoded)
    if not success then
        return false, "Invalid data format"
    end

    if type(importedData) ~= "table" then
        return false, "Invalid data: expected table"
    end

    if importedData.addon ~= "Ether" then
        return false, "Not an Ether profile"
    end

    if not importedData.data then
        return false, "No profile data found"
    end

    local importedName = importedData.profileName or "Imported"
    local baseName = importedName
    local counter = 1

    while ETHER_DATABASE_DX_AA.profiles[importedName] do
        counter = counter + 1
        importedName = baseName .. "_" .. counter
    end

    ETHER_DATABASE_DX_AA.profiles[importedName] = Ether.CopyTable(importedData.data)

    ETHER_DATABASE_DX_AA.currentProfile = importedName
    Ether.DB = Ether.CopyTable(Ether.GetCurrentProfile())
    Ether:RefreshAllSettings()
    Ether:RefreshFramePositions()
    return true, "Successfully imported as: " .. importedName
end

function Ether.ExportProfileToClipboard()
    local encoded, err = Ether.ExportCurrentProfile()
    if not encoded then
        Ether.DebugOutput("|cffff0000Export failed:|r " .. err)
        return
    end
    local editBox = CreateFrame("EditBox", nil, UIParent)
    editBox:SetText(encoded)
    editBox:SetFocus()
    editBox:HighlightText()
    editBox:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
        self:Hide()
    end)
    editBox:SetScript("OnEditFocusLost", function(self)
        self:Hide()
    end)
    Ether.DebugOutput("|cff00ff00Profile copied to clipboard!|r")
    Ether.DebugOutput("|cff888888You can now paste it anywhere|r")

    return encoded
end

function Ether.CopyProfile(sourceName, targetName)
    if not ETHER_DATABASE_DX_AA.profiles[sourceName] then
        return false, "Source profile not found"
    end
    if ETHER_DATABASE_DX_AA.profiles[targetName] then
        return false, "Target profile already exists"
    end
    ETHER_DATABASE_DX_AA.profiles[targetName] = Ether.CopyTable(ETHER_DATABASE_DX_AA.profiles[sourceName])
    return true, "Profile copied"
end

function Ether.SwitchProfile(name)
    if not ETHER_DATABASE_DX_AA.profiles[name] then
        return false, "Profile not found"
    end

    ETHER_DATABASE_DX_AA.profiles[ETHER_DATABASE_DX_AA.currentProfile] = Ether.CopyTable(Ether.DB)

    ETHER_DATABASE_DX_AA.currentProfile = name
    Ether.DB = Ether.CopyTable(ETHER_DATABASE_DX_AA.profiles[name])

    Ether:RefreshAllSettings()
    Ether:RefreshFramePositions()

    if Ether.ConfigFrame and Ether.ConfigFrame:IsShown() then
        Ether.ConfigFrame:Hide()
        Ether.ConfigFrame:Show()
    end

    return true, "Switched to " .. name
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
    Ether:RefreshAllSettings()
    Ether:RefreshFramePositions()
    return true, "Profile deleted"
end

function Ether.GetCharacterKey()
    return playerName .. "-" .. realmName
end

function Ether.GetCurrentProfile()
    return ETHER_DATABASE_DX_AA.profiles[ETHER_DATABASE_DX_AA.currentProfile]
end

function Ether.GetProfileList()
    local list = {}
    for name in pairs(ETHER_DATABASE_DX_AA.profiles) do
        table.insert(list, name)
    end
    table.sort(list)
    return list
end

function Ether.CreateProfile(name)
    if ETHER_DATABASE_DX_AA.profiles[name] then
        return false, "Profile already exists"
    end
    ETHER_DATABASE_DX_AA.profiles[name] = Ether.CopyTable(Ether.DataDefault)
    Ether:RefreshAllSettings()
    Ether:RefreshFramePositions()
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

function Ether.ResetProfile()
    ETHER_DATABASE_DX_AA.profiles[ETHER_DATABASE_DX_AA.currentProfile] = Ether.CopyTable(Ether.DataDefault)
    Ether.DB = Ether.CopyTable(Ether.DataDefault)
    wipe(Ether.DB[1003])
    Ether.UpdateAuraList()
    selectedSpellId = nil
    Ether.UpdateEditor()
    Ether:RefreshAllSettings()
    Ether:RefreshFramePositions()
    return true, "Profile reset to default"
end

