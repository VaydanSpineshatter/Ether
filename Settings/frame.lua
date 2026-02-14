local _, Ether = ...
local realmName = GetRealmName()
local string_format = string.format
local pairs, ipairs = pairs, ipairs

local function GetFont(_, target, tex, numb)
    target.label = target:CreateFontString(nil, "OVERLAY")
    target.label:SetFont(unpack(Ether.mediaPath.expressway), numb, "OUTLINE")
    target.label:SetText(tex)
    return target.label
end

local function CreateEtherDropdown(parent, width, text, options, position)
    local dropdown = CreateFrame("Button", nil, parent)
    dropdown:SetSize(width, 25)
    dropdown.bg = dropdown:CreateTexture(nil, "BACKGROUND")
    dropdown.bg:SetAllPoints()
    dropdown.bg:SetColorTexture(1, 1, 1, 0.1)
    dropdown.bottom = dropdown:CreateTexture(nil, "BORDER")
    dropdown.bottom:SetPoint("BOTTOMLEFT")
    dropdown.bottom:SetPoint("BOTTOMRIGHT")
    dropdown.bottom:SetHeight(1)
    dropdown.bottom:SetColorTexture(0.80, 0.40, 1.00, 1)
    if position then
        dropdown.left = dropdown:CreateTexture(nil, "BORDER")
        dropdown.left:SetPoint("TOPLEFT")
        dropdown.left:SetPoint("BOTTOMLEFT")
        dropdown.left:SetWidth(-1)
        dropdown.left:SetColorTexture(0.80, 0.40, 1.00, 1)
    else
        dropdown.right = dropdown:CreateTexture(nil, "BORDER")
        dropdown.right:SetPoint("TOPRIGHT")
        dropdown.right:SetPoint("BOTTOMRIGHT")
        dropdown.right:SetWidth(1)
        dropdown.right:SetColorTexture(0.80, 0.40, 1.00, 1)
    end
    dropdown.text = dropdown:CreateFontString(nil, "OVERLAY")
    dropdown.text:SetFont(unpack(Ether.mediaPath.expressway), 11, "OUTLINE")
    dropdown.text:SetPoint("CENTER")
    dropdown.text:SetJustifyH("CENTER")
    dropdown.text:SetJustifyV("MIDDLE")
    dropdown.text:SetText(text)
    local menu = CreateFrame("Button", nil, dropdown)
    dropdown.menu = menu
    menu:SetPoint("TOPLEFT")
    menu:SetWidth(width)
    menu.bg = menu:CreateTexture(nil, "BACKGROUND")
    menu.bg:SetAllPoints()
    menu.bg:SetColorTexture(0.2, 0.2, 0.2, 1)
    menu:SetFrameLevel(parent:GetFrameLevel() + 10)
    menu:Hide()
    menu.bottom = menu:CreateTexture(nil, "BORDER")
    menu.bottom:SetPoint("BOTTOMLEFT")
    menu.bottom:SetPoint("BOTTOMRIGHT")
    menu.bottom:SetHeight(1)
    menu.bottom:SetColorTexture(0.00, 0.80, 1.00, 1)
    if position then
        menu.left = menu:CreateTexture(nil, "BORDER")
        menu.left:SetPoint("TOPLEFT")
        menu.left:SetPoint("BOTTOMLEFT")
        menu.left:SetWidth(-1)
        menu.left:SetColorTexture(0.00, 0.80, 1.00, 1)
    else
        menu.right = menu:CreateTexture(nil, "BORDER")
        menu.right:SetPoint("TOPRIGHT")
        menu.right:SetPoint("BOTTOMRIGHT")
        menu.right:SetWidth(1)
        menu.right:SetColorTexture(0.00, 0.80, 1.00, 1)
    end
    local totalHeight = 4
    for _, data in ipairs(options) do
        local btn = CreateFrame("Button", nil, menu)
        btn:SetSize(width - 8, 20)
        btn:SetPoint("TOPLEFT", 4, -totalHeight)
        btn.text = btn:CreateFontString(nil, "OVERLAY")
        btn.text:SetFont(unpack(Ether.mediaPath.expressway), 11, "OUTLINE")
        btn.text:SetJustifyH("CENTER")
        btn.text:SetJustifyV("MIDDLE")
        btn.text:SetPoint("CENTER")
        btn.text:SetText(data.text)
        btn:SetScript("OnEnter", function()
            btn.text:SetTextColor(0.00, 0.80, 1.00, 1)
        end)
        btn:SetScript("OnLeave", function()
            btn.text:SetTextColor(1, 1, 1, 1)
        end)
        btn:SetScript("OnClick", function()
            if data.func then
                data.func()
                menu:SetShown(false)
            end
        end)
        totalHeight = totalHeight + 20
    end
    menu:SetHeight(totalHeight + 4)
    dropdown:SetScript("OnClick", function()
        menu:SetShown(true)
    end)
    menu:SetScript("OnLeave", function()
        menu:SetShown(false)
    end)
    menu:SetScript("OnShow", function()
        Ether:WrapMainSettingsColor({0.00, 0.80, 1.00, 1})
    end)
    menu:SetScript("OnHide", function()
        Ether:WrapMainSettingsColor({0.80, 0.40, 1.00, 1})
        menu:SetShown(false)
    end)
    return dropdown
end

local function SetupSliderText(slider, lowText, highText)
    slider.Low:SetFont(unpack(Ether.mediaPath.expressway), 9, "OUTLINE")
    slider.Low:SetText(lowText)
    slider.High:SetFont(unpack(Ether.mediaPath.expressway), 9, "OUTLINE")
    slider.High:SetText(highText)
    slider.Low:ClearAllPoints()
    slider.Low:SetPoint("TOPLEFT", slider, "BOTTOMLEFT", 0, -2)
    slider.High:ClearAllPoints()
    slider.High:SetPoint("TOPRIGHT", slider, "BOTTOMRIGHT", 0, -2)
end

local function SetupSliderThump(slider, size, color)
    local thumb = slider:GetThumbTexture()
    if thumb then
        thumb:SetSize(size, size)
        thumb:SetColorTexture(unpack(color))
    end
end

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
    input:SetFont(unpack(Ether.mediaPath.expressway), 11, "OUTLINE")
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

local function EtherPanelButton(parent, width, height, text, point, relto, rel, offX, offY)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(width, height)
    btn:SetPoint(point, relto, rel, offX, offY)
    btn.bg = btn:CreateTexture(nil, "BACKGROUND")
    btn.bg:SetAllPoints()
    btn.bg:SetColorTexture(0.2, 0.2, 0.2, 0.8)
    btn.text = btn:CreateFontString(nil, "OVERLAY")
    btn.text:SetFont(unpack(Ether.mediaPath.expressway), 12, "OUTLINE")
    btn.text:SetPoint("CENTER")
    btn.text:SetText(text)
    btn.hl = btn:CreateTexture(nil, "HIGHLIGHT")
    btn.hl:SetAllPoints()
    btn.hl:SetColorTexture(0.80, 0.40, 1.00, .2)
    btn:SetScript("OnEnter", function()
        btn.text:SetTextColor(0.00, 0.80, 1.00, 1)
    end)
    btn:SetScript("OnLeave", function()
        btn.text:SetTextColor(1, 1, 1, 1)
    end)
    return btn
end
Ether.EtherPanelButton = EtherPanelButton
function Ether.CreateModuleSection(self)
    local parent = self.Content.Children["Module"]

    local modulesValue = {
        [1] = {name = "Icon"},
        [2] = {name = "Chat Bn & Msg Whisper"},
        [3] = {name = "Tooltip"},
        [4] = {name = "Idle mode"},
        [5] = {name = "Range check"},
        [6] = {name = "Indicators"}
    }
    local mod = CreateFrame("Frame", nil, parent)
    mod:SetSize(200, (#modulesValue * 30) + 60)
    for i, opt in ipairs(modulesValue) do
        local btn = CreateFrame("CheckButton", nil, mod, "OptionsBaseCheckButtonTemplate")

        if i == 1 then
            btn:SetPoint("TOPLEFT", parent, 5, -5)
        else
            btn:SetPoint("TOPLEFT", self.Buttons[1][i - 1], "BOTTOMLEFT", 0, 0)
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
            elseif i == 5 then
                if Ether.DB[401][5] == 1 then
                    Ether:RangeEnable()
                else
                    Ether:RangeDisable()
                end
            elseif i == 6 then
                if Ether.DB[401][6] == 1 then
                    Ether:IndicatorsEnable()
                else
                    Ether:IndicatorsDisable()
                end
            end
        end)
        self.Buttons[1][i] = btn
    end
end

function Ether.CreateBlizzardSection(self)
    local parent = self.Content.Children["Blizzard"]
    local HideValue = {
        [1] = {name = "Player frame"},
        [2] = {name = "Pet frame"},
        [3] = {name = "Target frame"},
        [4] = {name = "Focus frame"},
        [5] = {name = "CastBar"},
        [6] = {name = "Party"},
        [7] = {name = "Raid"},
        [8] = {name = "Raid Manager"},
        [9] = {name = "MicroMenu"},
        [10] = {name = "XP Bar"},
        [11] = {name = "BagsBar"}
    }
    local bF = CreateFrame("Frame", nil, parent)
    bF:SetSize(200, (#HideValue * 30) + 60)
    for i, opt in ipairs(HideValue) do
        local btn = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
        if i == 1 then
            btn:SetPoint("TOPLEFT", 5, -5)
        else
            btn:SetPoint("TOPLEFT", self.Buttons[2][i - 1], "BOTTOMLEFT", 0, 0)
        end
        btn:SetSize(24, 24)
        btn.label = GetFont(self, btn, opt.name, 12)
        btn.label:SetPoint("LEFT", btn, "RIGHT", 8, 1)
        btn:SetChecked(Ether.DB[101][i] == 1)
        btn:SetScript("OnClick", function(self)
            local checked = self:GetChecked()
            Ether.DB[101][i] = checked and 1 or 0

        end)
        self.Buttons[2][i] = btn
    end
end

function Ether.CreateAboutSection(self)
    local parent = self.Content.Children["About"]
    local slash = GetFont(self, parent, "Slash Commands", 15)
    slash:SetPoint("TOP", 0, -20)
    local lastY = -20
    for _, entry in ipairs(Ether.SlashInfo) do
        local fs = GetFont(self, parent, string_format("%s  –  %s", entry.cmd, entry.desc), 12)
        fs:SetPoint("TOP", slash, "BOTTOM", 0, lastY)
        lastY = lastY - 18
    end
    local idle = GetFont(self, parent, "What happens in idle mode?", 15)
    idle:SetPoint("TOP", 0, -180)
    local idleInfo = GetFont(self, parent, "When the user is not at the keyboard,\nEther deregisters all events and OnUpdate functions.", 12)
    idleInfo:SetPoint("TOP", 0, -220)

    local auras = GetFont(self, parent, "How do I create my own auras?", 15)
    auras:SetPoint("TOP", idleInfo, "BOTTOM", 0, -30)
    local aurasInfo = GetFont(self, parent, "Only via SpellId. Use Aura Helper or other methods.", 12)
    aurasInfo:SetPoint("TOP", auras, "BOTTOM", 0, -10)
end

function Ether.CreateCreationSection(self)
    local parent = self.Content.Children["Create"]
    local CreateUnits = {
        [1] = {name = "|cffCC66FFPlayer|r"},
        [2] = {name = "|cE600CCFFTarget|r"},
        [3] = {name = "Target of Target"},
        [4] = {name = "|cffCC66FFPet|r"},
        [5] = {name = "|cffCC66FFPetTarget|r"},
        [6] = {name = "|cff3399FFFocus|r"},
    }

    local uF = CreateFrame('Frame', nil, parent)
    uF:SetSize(200, (#CreateUnits * 30) + 60)
    for i, opt in ipairs(CreateUnits) do
        local btn = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
        if i == 1 then
            btn:SetPoint("TOPLEFT", 5, -5)
        else
            btn:SetPoint("TOP", self.Buttons[3][i - 1], "BOTTOM", 0, 0)
        end
        btn:SetSize(24, 24)
        btn.label = GetFont(self, btn, opt.name, 12)
        btn.label:SetPoint("LEFT", btn, "RIGHT", 8, 1)
        btn:SetChecked(Ether.DB[201][i] == 1)
        btn:SetScript("OnClick", function(self)
            local checked = self:GetChecked()
            Ether.DB[201][i] = checked and 1 or 0
            if Ether.DB[201][i] == 1 then
                Ether:CreateUnitButtons(i)
            else
                Ether:DestroyUnitButtons(i)
            end
        end)
        self.Buttons[3][i] = btn
    end

    local create = EtherPanelButton(parent, 100, 25, "Create Custom", "TOPLEFT", self.Buttons[3][6], "BOTTOMLEFT", 10, -40)
    create:SetScript("OnClick", function()
        Ether.CreateCustomUnit()
    end)

    local destroy = EtherPanelButton(parent, 100, 25, "Destroy Custom", "LEFT", create, "RIGHT", 40, 0)
    destroy:SetScript("OnClick", function()
        Ether.stopUpdateFunc()
    end)
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
    local UpdateToggle = CreateFrame("Frame", nil, parent)
    UpdateToggle:SetSize(200, (#UpdateValue * 30) + 60)
    for i, opt in ipairs(UpdateValue) do
        local btn = CreateFrame("CheckButton", nil, parent, "OptionsBaseCheckButtonTemplate")
        if i == 1 then
            btn:SetPoint("TOPLEFT", 5, -5)
        else
            btn:SetPoint("TOPLEFT", self.Buttons[4][1][i - 1], "BOTTOMLEFT", 0, 0)
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
        self.Buttons[4][1][i] = btn
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
    local EventsToggle = CreateFrame("Frame", nil, parent)
    EventsToggle:SetSize(200, (#UnitUpdates * 30) + 60)
    for i, opt in ipairs(UnitUpdates) do
        local btn = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
        if i == 1 then
            btn:SetPoint("TOP", 40, -5)
        else
            btn:SetPoint("TOPLEFT", self.Buttons[4][2][i - 1], "BOTTOMLEFT", 0, 0)
        end
        btn:SetSize(24, 24)
        btn.label = GetFont(self, btn, opt.text, 12)
        btn.label:SetPoint("LEFT", btn, "RIGHT", 10, 0)
        btn:SetChecked(Ether.DB[901][opt.value])
        btn:SetScript("OnClick", function(self)
            local checked = self:GetChecked()
            Ether.DB[901][opt.value] = checked
        end)
        self.Buttons[4][2][i] = btn
    end
end

function Ether.CreateAuraSection(self)
    local parent = self.Content.Children["Settings"]
    local CreateAura = {
        [1] = {text = "Enable/Disable Auras"},
        [2] = {text = "Solo Auras"},
        [3] = {text = "Header Auras"}
    }
    local CreateAurasToggle = CreateFrame("Frame", nil, parent)
    CreateAurasToggle:SetSize(200, (#CreateAura * 30) + 60)
    for i, opt in ipairs(CreateAura) do
        local btn = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
        if i == 1 then
            btn:SetPoint("TOPLEFT", 5, -5)
        else
            btn:SetPoint("TOPLEFT", self.Buttons[5][i - 1], "BOTTOMLEFT", 0, 0)
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
                    Ether:AuraEnable()
                else
                    Ether:AuraDisable()
                end
            elseif i == 2 then
                if Ether.DB[1001][2] == 1 then
                    Ether:EnableSoloAuras()
                else
                    Ether:DisableSoloAuras()
                end
            elseif i == 3 then
                if Ether.DB[1001][3] == 1 then
                    Ether:EnableHeaderAuras()
                else
                    Ether:DisableHeaderAuras()
                end
            end
        end)
        self.Buttons[5][i] = btn
    end
end

local selectedSpellId = nil
local AuraList
local AuraButtons = {}

local Editor
local function CreateAuraList(parent)

    local auraWipe = {}
    for templateName, _ in pairs(Ether.PredefinedAuras) do
        table.insert(auraWipe, {
            text = templateName,
            func = function()
                if not Editor:IsShown() then
                    Editor:Show()
                end
                Ether:AddTemplateAuras(templateName, true)
            end
        })
    end

    local auraDropdown = CreateEtherDropdown(parent, 160, "Predefined Auras", auraWipe)
    auraDropdown:SetPoint("TOPLEFT")

    local frame = CreateFrame("Frame", nil, parent)
    AuraList = frame
    AuraList:SetPoint("TOPLEFT", auraDropdown, "BOTTOMLEFT", 0, 0)
    AuraList:SetSize(230, 400)

    local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "ScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 0, -10)
    scrollFrame:SetPoint("BOTTOMRIGHT", -25, 35)

    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(190, 1)
    scrollFrame:SetScrollChild(scrollChild)

    if scrollFrame.ScrollBar then
        scrollFrame.ScrollBar:Hide()
    end

    AuraList.scrollChild = scrollChild
    local addBtn = EtherPanelButton(frame, 60, 25, "New", "TOP", parent, "TOP", 0, -5)
    addBtn:SetScript("OnClick", function(self)
        if not Editor:IsShown() then
            Editor:Show()
        end
        Ether.AddNewAura()
    end)
    local confirm = EtherPanelButton(frame, 60, 25, "Confirm", "LEFT", addBtn, "RIGHT", 10, 0)
    confirm:SetScript("OnClick", function(self)
        if selectedSpellId then
            if Ether.DB[1003][selectedSpellId].isDebuff then
                Ether.SaveAuraPos(selectedSpellId, true)
            else
                Ether.SaveAuraPos(selectedSpellId)
            end
        end
    end)
    local clear = EtherPanelButton(frame, 60, 25, "Clear", "LEFT", confirm, "RIGHT", 10, 0)
    clear:SetScript("OnClick", function(self)
        wipe(Ether.DB[1003])
        Ether.UpdateAuraList()
        selectedSpellId = nil
        Ether.UpdateEditor()
        Ether.DebugOutput("|cff00ccffAuras|r: Custom auras cleared")
        auraDropdown.menu:Hide()
    end)

    return frame
end

function Ether:AddTemplateAuras(templateName)
    local template = Ether.PredefinedAuras[templateName]
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

    local msg = string_format("|cff00ccffAuras|r: Template '%s' loaded. ", templateName)
    if added > 0 then
        msg = msg .. string_format("|cff00ff00+%d new auras|r", added)
    end
    if skipped > 0 then
        msg = msg .. string_format(" (%d already existed)", skipped)
    end
    Ether.DebugOutput(msg)

    selectedSpellId = nil
    Ether.UpdateEditor()
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
        Ether.UpdateAuraList()
    end
end

local function UpdateIsDebuff(button, spellId)
    if not button or not spellId then return end
    local debuff = Ether.DB[1003][spellId].isDebuff
    if debuff then
        debuff = true
        button:SetColorTexture(0.80, 0.40, 1.00, 0.4)
    else
        debuff = false
        button:SetColorTexture(0.2, 0.2, 0.2, 0.8)
    end
end

local function CreateEditor(parent)
    local frame = CreateFrame("Frame", nil, parent)
    Editor = frame
    frame:SetPoint("TOPRIGHT", 70, -50)
    frame:SetSize(320, 300)

    local name = frame:CreateFontString(nil, "OVERLAY")
    frame.nameLabel = name
    name:SetFont(unpack(Ether.mediaPath.expressway), 10, "OUTLINE")
    name:SetPoint("TOP", parent, "TOP", -10, -40)
    name:SetText("Name")

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

    local spellID = frame:CreateFontString(nil, "OVERLAY")
    frame.spellIdLabel = spellID
    spellID:SetFont(unpack(Ether.mediaPath.expressway), 10, "OUTLINE")
    spellID:SetPoint("TOPLEFT", nameInput, "BOTTOMLEFT", 0, -10)
    spellID:SetText("Spell ID")

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

    local isDebuff = EtherPanelButton(frame, 80, 25, "Debuff", "LEFT", spellIdInput, "RIGHT", 10, 0)
    frame.isDebuff = isDebuff
    isDebuff:SetScript("OnClick", function(self)
        if selectedSpellId then
            Ether.DB[1003][selectedSpellId].isDebuff = not Ether.DB[1003][selectedSpellId].isDebuff
            UpdateIsDebuff(Editor.isDebuff.bg, selectedSpellId)
        end
    end)

    local sizeLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontWhiteSmall")
    frame.sizeLabel = sizeLabel
    sizeLabel:SetPoint("TOPLEFT", spellIdInput, "BOTTOMLEFT", 0, -120)
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
            frame.sizeValue:SetText(string_format("%.0f px", value))
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
    rgbText:SetFont(unpack(Ether.mediaPath.expressway), 10, "OUTLINE")
    rgbText:SetPoint("LEFT", sizeSlider, "RIGHT", 40, 0)
    rgbText:SetText("Pick Color")

    local preview = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.preview = preview
    preview:SetPoint("TOPLEFT", 15, -110)
    preview:SetSize(55, 55)
    preview:SetBackdrop({
        bgFile = Ether.DB[811]["background"],
        insets = {left = -2, right = -2, top = -2, bottom = -2}
    })
    Ether:SetupHealthBar(preview, "HORIZONTAL", 55, 55, "player")
    Ether:SetupName(preview, -5)
    preview.name:SetText(Ether:ShortenName(Ether.playerName, 3))
    local icon = preview.healthBar:CreateTexture(nil, "OVERLAY")
    frame.icon = icon
    icon:SetSize(6, 6)
    icon:SetPoint("TOP", preview.healthBar, "TOP", 0, 0)
    icon:SetColorTexture(1, 1, 0, 1)

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
            btn.text:SetFont(unpack(Ether.mediaPath.expressway), 10, "OUTLINE")
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
    offsetXLabel:SetFont(unpack(Ether.mediaPath.expressway), 10, "OUTLINE")
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
            frame.offsetXValue:SetText(string_format("%.0f", value))
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
    offsetYLabel:SetFont(unpack(Ether.mediaPath.expressway), 10, "OUTLINE")
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
            frame.offsetYValue:SetText(string_format("%.0f", value))
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
    offsetXValue:SetFont(unpack(Ether.mediaPath.expressway), 10, "OUTLINE")
    offsetXValue:SetPoint("TOP", offsetXSlider, "BOTTOM")
    offsetXValue:SetText("0")

    local offsetYValue = frame:CreateFontString(nil, "OVERLAY")
    frame.offsetYValue = offsetYValue
    offsetYValue:SetFont(unpack(Ether.mediaPath.expressway), 10, "OUTLINE")
    offsetYValue:SetPoint("TOP", offsetYSlider, "BOTTOM")
    offsetYValue:SetText("0")

    SetupSliderText(sizeSlider, "4", "20")
    SetupSliderText(offsetYSlider, "-20", "20")
    SetupSliderText(offsetXSlider, "-20", "20")
    SetupSliderThump(sizeSlider, 10, {0.8, 0.6, 0, 1})
    SetupSliderThump(offsetYSlider, 10, {0.8, 0.6, 0, 1})
    SetupSliderThump(offsetXSlider, 10, {0.8, 0.6, 0, 1})
    return frame
end

local IsCreated = false
function Ether.CreateAuraCustomSection(self)
    local parent = self.Content.Children["Custom"]
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

    local yOffset = 0
    local index = 1

    for spellId, data in pairs(Ether.DB[1003]) do
        local btn = CreateFrame("Button", nil, AuraList.scrollChild)
        btn:SetSize(200, 40)
        btn:SetPoint("TOP", 2, yOffset)

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
            if not Editor:IsShown() then
                Editor:Show()
            end
            Ether.SelectAura(spellId)
            UpdateIsDebuff(Editor.isDebuff.bg, spellId)
        end)

        btn.name = btn:CreateFontString(nil, "OVERLAY")
        btn.name:SetFont(unpack(Ether.mediaPath.expressway), 10, "OUTLINE")
        btn.name:SetPoint("TOPLEFT", 10, -8)
        btn.name:SetText(data.name or "Unknown")

        btn.spellId = btn:CreateFontString(nil, "OVERLAY")
        btn.spellId:SetFont(unpack(Ether.mediaPath.expressway), 10, "OUTLINE")
        btn.spellId:SetPoint("TOPLEFT", 10, -23)
        btn.spellId:SetText("Spell ID: " .. spellId)
        btn.spellId:SetTextColor(0, 0.8, 1)

        btn.colorBox = btn:CreateTexture(nil, "OVERLAY")
        btn.colorBox:SetSize(15, 15)
        btn.colorBox:SetPoint("RIGHT", -10, 0)
        if data.color then
            btn.colorBox:SetColorTexture(data.color[1], data.color[2], data.color[3], data.color[4])
        end

        btn.deleteBtn = CreateFrame("Button", nil, btn)
        btn.deleteBtn:SetSize(15, 15)
        btn.deleteBtn:SetPoint("RIGHT", btn.colorBox, "LEFT", 0, 0)
        btn.deleteBtn:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
        btn.deleteBtn:SetScript("OnClick", function(self)
            StaticPopup_Show("ETHER_DELETE_AURA", data.name or "this Aura", nil, spellId)
            self:GetParent():GetScript("OnLeave")(self:GetParent())
        end)
        StaticPopupDialogs["ETHER_DELETE_AURA"] = {
            text = "Delete Aura ?",
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
        yOffset = yOffset - 45
        index = index + 1
    end
    AuraList.scrollChild:SetHeight(math.max(1, index * 55))
end

function Ether.UpdateEditor()
    if not selectedSpellId or not Ether.DB[1003][selectedSpellId] then
        Editor.nameInput:SetText("")
        Editor.nameInput:Disable()
        Editor.spellIdInput:SetText("")
        Editor.spellIdInput:Disable()
        Editor.colorBtn:Disable()
        Editor.sizeSlider:Disable()
        Editor.offsetXSlider:Disable()
        Editor.offsetYSlider:Disable()
        Editor.icon:Hide()
        for _, btn in pairs(Editor.posButtons) do
            btn:Disable()
        end
        return
    end

    local data = Ether.DB[1003][selectedSpellId]
    Editor.nameInput:SetText(data.name or "")
    Editor.nameInput:Enable()
    Editor.icon:Show()
    Editor.spellIdInput:SetText(tostring(selectedSpellId))
    Editor.spellIdInput:Enable()
    Editor.colorBtn.bg:SetColorTexture(data.color[1], data.color[2], data.color[3], data.color[4])
    Editor.colorBtn:Enable()
    Editor.offsetXSlider:Enable()
    Editor.offsetXSlider:Show()
    Editor.offsetYSlider:Enable()
    Editor.offsetYSlider:Show()
    Editor.sizeSlider:SetValue(data.size)
    Editor.sizeSlider:Enable()
    Editor.sizeSlider:Show()
    Editor.sizeValue:SetText(string_format("%.0f px", data.size))
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
    Editor.offsetXValue:SetText(string_format("%.0f", data.offsetX))
    Editor.offsetYSlider:SetValue(data.offsetY)
    Editor.offsetYValue:SetText(string_format("%.0f", data.offsetY))

    Ether.UpdatePreview()
end

function Ether.UpdatePreview()
    if not selectedSpellId then
        return
    end

    local data = Ether.DB[1003][selectedSpellId]
    local indicator = Editor.icon

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
    Ether.DB[1003][newId] = Ether.AuraTemplate(newId)
    Ether:SelectAura(newId)
end

function Ether.CreateAuraHelperSection(self)
    local parent = self.Content.Children["Helper"]

    local spellIDPanel = CreateFrame("Frame", nil, parent)
    spellIDPanel:SetPoint("TOPLEFT", 10, -10)
    spellIDPanel:SetSize(250, 80)

    local title = parent:CreateFontString(nil, "OVERLAY")
    title:SetFont(unpack(Ether.mediaPath.expressway), 12, "OUTLINE")
    title:SetPoint("TOPLEFT", 10, -10)
    title:SetText("Spell Information")

    local resultText, spellIcon

    local spellNameBox = CreateLineInput(spellIDPanel, 180, 20)
    spellNameBox:SetPoint("TOPLEFT", spellIDPanel, "TOPLEFT", 10, -30)
    spellNameBox:SetAutoFocus(false)
    spellNameBox:SetScript("OnEnterPressed", function(self)
        Ether:GetSpellInfo(spellNameBox:GetText(), resultText, spellIcon)
    end)

    local spellInfo = EtherPanelButton(spellIDPanel, 80, 25, "Search", "LEFT", spellNameBox, "RIGHT", 10, 0)
    local resultFrame = CreateFrame("Frame", nil, spellIDPanel)
    resultFrame:SetPoint("TOPLEFT", spellNameBox, "BOTTOMLEFT", 0, -15)
    resultFrame:SetSize(230, 40)

    resultText = resultFrame:CreateFontString(nil, "OVERLAY")
    resultText:SetFont(unpack(Ether.mediaPath.expressway), 11, "OUTLINE")
    resultText:SetPoint("TOPLEFT", resultFrame, "BOTTOMLEFT", 0, 0)
    resultText:SetWidth(230)
    resultText:SetJustifyH("LEFT")

    spellIcon = resultFrame:CreateTexture(nil, "OVERLAY")
    spellIcon:SetPoint("TOP", resultText, "BOTTOM", 0, -40)
    spellIcon:SetSize(64, 64)
    spellIcon:Hide()

    spellInfo:SetScript("OnClick", function(self)
        Ether:GetSpellInfo(spellNameBox:GetText(), resultText, spellIcon)
    end)

    local examples = {
        "Greater Heal(Rank 4)",
        "Greater Heal",
        "18248",
        "Fishing",
        "Power Word: Shield",
        "Renew(Rank 10)",
        "25233"
    }

    local exampleText = "Example\n\n"
    for i = 1, 7 do
        exampleText = exampleText .. string_format("• %s\n", examples[i])
    end

    local example = parent:CreateFontString(nil, "OVERLAY")
    example:SetFont(unpack(Ether.mediaPath.expressway), 12, "OUTLINE")
    example:SetJustifyH("LEFT")
    example:SetPoint("TOPLEFT", spellInfo, "BOTTOMLEFT", 20, -50)
    example:SetText(exampleText)
end

function Ether:GetSpellInfo(spellName, resultText, spellIcon)
    if not resultText or not spellIcon then return end
    spellName = spellName:trim()
    if spellName == "" then
        resultText:SetText("Enter spell name")
        resultText:SetTextColor(1, 1, 1)
        spellIcon:Hide()
        return
    end
    local spellID = C_Spell.GetSpellIDForSpellIdentifier(spellName)
    if not spellID then
        local baseName = spellName:gsub("%s*%(%s*[Rr]ank%s+%d+%s*%)", ""):trim()
        if baseName ~= spellName then
            spellID = C_Spell.GetSpellIDForSpellIdentifier(baseName)
        end
    end
    if not spellID then
        resultText:SetText("Not found: " .. spellName)
        resultText:SetTextColor(1, 0, 0)
        spellIcon:Hide()
        return
    end
    local name = C_Spell.GetSpellName(spellID)
    local subtext = C_Spell.GetSpellSubtext(spellID) or ""
    local iconID = C_Spell.GetSpellTexture(spellID)
    local levelLearned = C_Spell.GetSpellLevelLearned(spellID)
    local spellRank = 0
    if subtext:match("Rank") then
        spellRank = tonumber(subtext:match("Rank%s+(%d+)")) or 0
    end
    if iconID then
        spellIcon:SetTexture(iconID)
        spellIcon:Show()
    else
        spellIcon:Hide()
    end
    local resultStr = string_format("Spell Name: %s\nSpellID: %d", name, spellID)
    if subtext ~= "" then
        resultStr = resultStr .. string_format("\n%s", subtext)
    end
    if levelLearned > 0 then
        resultStr = resultStr .. string_format("\nLearned at: Level %d", levelLearned)
    end

    resultText:SetText(resultStr)
    resultText:SetTextColor(1, 1, 1)
    Ether.DebugOutput(resultStr)

    spellIcon:SetScript("OnEnter", function()
        GameTooltip:SetOwner(spellIcon, "ANCHOR_RIGHT")
        GameTooltip:AddLine(name, 1, 1, 1)
        GameTooltip:AddLine("Spell ID: " .. spellID, 0.5, 1, 0.5)

        if subtext ~= "" then
            GameTooltip:AddLine(subtext, 1, 0.82, 0)
        end

        local level = C_Spell.GetSpellLevelLearned(spellID)
        if level > 0 then
            GameTooltip:AddLine("Learned at level " .. level, 0.7, 0.7, 1)
        end

        local desc = C_Spell.GetSpellDescription(spellID)
        if desc and desc ~= "" then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(desc:sub(1, 200), 0.8, 0.8, 0.8, true)
        end

        GameTooltip:Show()
    end)

    spellIcon:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end
local number = nil
local iconTexture = ""
local Indicator
local coordinates = ""
local indicatorType = ""
local currentIndicator = nil
function Ether.CreateIndicatorsSection(self)
    local parent = self.Content.Children["Position"]

    local I_Register = {
        [1] = {text = "Ready check", texture = "Interface\\RaidFrame\\ReadyCheck-Ready", texture2 = "Interface\\RaidFrame\\ReadyCheck-NotReady", texture3 = "Interface\\RaidFrame\\ReadyCheck-Waiting"},
        [2] = {text = "Connection", texture = "Interface\\CharacterFrame\\Disconnect-Icon", size = 30},
        [3] = {text = "Raid target update", texture = "Interface\\TargetingFrame\\UI-RaidTargetingIcons", size = 14, coo = {0.75, 1, 0.25, 0.5}},
        [4] = {text = "Resurrection", texture = "Interface\\RaidFrame\\Raid-Icon-Rez", size = 20},
        [5] = {text = "Leader", texture = "Interface\\GroupFrame\\UI-Group-LeaderIcon"},
        [6] = {text = "Loot method", texture = "Interface\\GroupFrame\\UI-Group-MasterLooter", size = 16},
        [7] = {text = "Unit Flags |cffff0000 Red Name|r  &", texture = "Interface\\Icons\\Spell_Shadow_Charm", texture2 = "Interface\\Icons\\Spell_Holy_GuardianSpirit"},
        [8] = {text = "Maintank and Mainassist", texture = "Interface\\GroupFrame\\UI-Group-MainTankIcon", texture2 = "Interface\\GroupFrame\\UI-Group-MainAssistIcon"},
        [9] = {text = "Player flags  |cE600CCFFAFK|r & |cffCC66FFDND|r"}
    }

    local DB = Ether.DB
    local iRegister = CreateFrame("Frame", nil, parent)
    iRegister:SetSize(200, (#I_Register * 30) + 60)

    for i, opt in ipairs(I_Register) do
        local btn = CreateFrame("CheckButton", nil, iRegister, "InterfaceOptionsCheckButtonTemplate")

        if i == 1 then
            btn:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, -100)
        else
            btn:SetPoint("TOPLEFT", self.Buttons[6][i - 1], "BOTTOMLEFT", 0, 0)
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
        end)
        self.Buttons[6][i] = btn
    end

    local frame = CreateFrame("Frame", nil, parent)
    Indicator = frame

    Indicator.sizeValue = nil
    Indicator.offsetXValue = nil
    Indicator.offsetYValue = nil

    local indicators = {
        ["ReadyCheck"] = {icon = "Interface\\RaidFrame\\ReadyCheck-Ready", id = 1, type = "texture"},
        ["Connection"] = {icon = "Interface\\CharacterFrame\\Disconnect-Icon", id = 2, type = "texture"},
        ["RaidTarget"] = {icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcons", id = 3, coordinates = {0.75, 1, 0.25, 0.5}, type = "texture"},
        ["Resurrection"] = {icon = "Interface\\RaidFrame\\Raid-Icon-Rez", id = 4, type = "texture"},
        ["GroupLeader"] = {icon = "Interface\\GroupFrame\\UI-Group-LeaderIcon", id = 5, type = "texture"},
        ["MasterLoot"] = {icon = "Interface\\GroupFrame\\UI-Group-MasterLooter", id = 6, type = "texture"},
        ["UnitFlags"] = {icon = "Interface\\Icons\\Spell_Holy_GuardianSpirit", id = 7, type = "texture"},
        ["PlayerRoles"] = {icon = "Interface\\GroupFrame\\UI-Group-MainTankIcon", id = 8, type = "texture"},
        ["PlayerFlags"] = {type = "string", id = 9},
    }
    local templateDropdown
    local indicatorFunc = {}
    for name in pairs(indicators) do
        table.insert(indicatorFunc, {
            text = name,
            func = function()
                Indicator.sizeSlider:Show()
                Indicator.sizeSlider:Enable()
                Indicator.offsetYSlider:Show()
                Indicator.offsetYSlider:Enable()
                Indicator.offsetXSlider:Show()
                Indicator.offsetXSlider:Enable()
                Indicator.offsetXLabel:Show()
                Indicator.sizeLabel:Show()
                Indicator.offsetYLabel:Show()
                Indicator.offsetXValue:Show()
                Indicator.offsetYValue:Show()
                Indicator.sizeValue:Show()
                Indicator.preview:Show()
                for _, btn in pairs(Indicator.posButtons) do
                    btn:Enable()
                end
                number = indicators[name].id
                if indicators[name].type == "texture" then
                    indicatorType = indicators[name].type
                    iconTexture = indicators[name].icon
                    coordinates = indicators[name].coordinates
                end
                if indicators[name].type == "string" then
                    indicatorType = indicators[name].type
                    coordinates = indicators[name].coordinates
                end
                currentIndicator = name
                templateDropdown.text:SetText(currentIndicator)
                Ether.UpdateIndicatorsValue()
            end
        })
    end

    templateDropdown = CreateEtherDropdown(parent, 160, "Select Indicator", indicatorFunc)
    Indicator.templateDropdown = templateDropdown
    templateDropdown:SetPoint("TOPLEFT")

    local preview = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    Indicator.preview = preview
    preview:SetPoint("TOP", 80, -90)
    preview:SetSize(55, 55)
    preview:SetBackdrop({
        bgFile = Ether.DB[811]["background"],
        insets = {left = -2, right = -2, top = -2, bottom = -2}
    })
    Ether:SetupHealthBar(preview, "HORIZONTAL", 55, 55, "player")
    Ether:SetupName(preview, -5)
    preview.name:SetText(Ether:ShortenName(Ether.playerName, 3))

    local icon = preview.healthBar:CreateTexture(nil, "OVERLAY")
    Indicator.icon = icon
    icon:SetSize(12, 12)
    icon:SetPoint("TOP", preview.healthBar, "TOP", 0, 0)
    icon:SetTexture(iconTexture)

    local textIndicator = preview.healthBar:CreateFontString(nil, "OVERLAY")
    textIndicator:SetFont(unpack(Ether.mediaPath.expressway), 10, "OUTLINE")
    Indicator.text = textIndicator
    textIndicator:SetPoint("TOP", preview.healthBar, "TOP", 0, 0)
    textIndicator:Hide()

    local positions = {
        {"TOPLEFT", "TOP", "TOPRIGHT"},
        {"LEFT", "CENTER", "RIGHT"},
        {"BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT"}
    }

    Indicator.posButtons = {}
    local startX, startY = 90, 0
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
            btn.text:SetFont(unpack(Ether.mediaPath.expressway), 10, "OUTLINE")
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
    Indicator.sizeLabel = sizeLabel
    sizeLabel:SetFont(unpack(Ether.mediaPath.expressway), 10, "OUTLINE")
    sizeLabel:SetPoint("TOPLEFT", preview, "BOTTOMLEFT", 0, -50)
    sizeLabel:SetText("Size")

    local confirm = EtherPanelButton(preview, 100, 25, "Confirm", "BOTTOMLEFT", preview, "TOPRIGHT", 0, 40)
    confirm:SetScript("OnClick", function(self)
        if currentIndicator and number then
            Ether.SaveIndicatorsPos(currentIndicator, number)
        end
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
                Indicator.sizeValue:SetText(string_format("%.0f px", value))
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
    sizeValue:SetFont(unpack(Ether.mediaPath.expressway), 10, "OUTLINE")
    sizeValue:SetPoint("TOP", sizeSlider, "BOTTOM", 0, -5)
    sizeValue:SetText("6 px")

    local offsetXLabel = parent:CreateFontString(nil, "OVERLAY")
    Indicator.offsetXLabel = offsetXLabel
    offsetXLabel:SetFont(unpack(Ether.mediaPath.expressway), 10, "OUTLINE")
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
                Indicator.offsetXValue:SetText(string_format("%.0f", value))
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
    offsetXValue:SetFont(unpack(Ether.mediaPath.expressway), 10, "OUTLINE")
    offsetXValue:SetPoint("TOP", offsetXSlider, "BOTTOM")
    offsetXValue:SetText("0")

    local offsetYLabel = parent:CreateFontString(nil, "OVERLAY")
    Indicator.offsetYLabel = offsetYLabel
    offsetYLabel:SetFont(unpack(Ether.mediaPath.expressway), 10, "OUTLINE")
    offsetYLabel:SetPoint("TOPLEFT", offsetXLabel, "BOTTOMLEFT", 0, -50)
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
                Indicator.offsetYValue:SetText(string_format("%.0f", value))
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
    offsetYValue:SetFont(unpack(Ether.mediaPath.expressway), 10, "OUTLINE")
    offsetYValue:SetPoint("TOP", offsetYSlider, "BOTTOM")
    offsetYValue:SetText("0")

    SetupSliderText(sizeSlider, "4", "34")
    SetupSliderText(offsetYSlider, "-20", "20")
    SetupSliderText(offsetXSlider, "-20", "20")
    SetupSliderThump(sizeSlider, 10, {0.8, 0.6, 0, 1})
    SetupSliderThump(offsetYSlider, 10, {0.8, 0.6, 0, 1})
    SetupSliderThump(offsetXSlider, 10, {0.8, 0.6, 0, 1})
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
        Indicator.sizeValue:SetText(string_format("%.0f px", data[1]))
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
        Indicator.offsetXValue:SetText(string_format("%.0f", data[3]))
    end

    Indicator.offsetYSlider:SetValue(data[4])
    if Indicator.offsetYValue then
        Indicator.offsetYValue:SetText(string_format("%.0f", data[4]))
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
        Indicator.icon:SetPoint(data[2], Indicator.preview.healthBar, data[2], data[3], data[4])
    elseif indicatorType == "string" then
        Indicator.text:SetSize(data[1], data[1])
        Indicator.text:ClearAllPoints()
        Indicator.text:SetPoint(data[2], Indicator.preview.healthBar, data[2], data[3], data[4])
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

    local mF = CreateFrame("Frame", nil, parent)
    mF:SetSize(200, (#Tooltip * 30) + 60)

    for i, opt in ipairs(Tooltip) do
        local btn = CreateFrame("CheckButton", nil, mF, "InterfaceOptionsCheckButtonTemplate")

        if i == 1 then
            btn:SetPoint("TOPLEFT", parent, "TOPLEFT", 5, -5)
        else
            btn:SetPoint("TOPLEFT", self.Buttons[7][i - 1], "BOTTOMLEFT", 0, 0)
        end

        btn:SetSize(24, 24)

        btn.label = GetFont(self, btn, opt.name, 12)
        btn.label:SetPoint("LEFT", btn, "RIGHT", 8, 1)
        btn:SetChecked(Ether.DB[301][i] == 1)

        btn:SetScript("OnClick", function(self)
            local checked = self:GetChecked()
            Ether.DB[301][i] = checked and 1 or 0
        end)
        self.Buttons[7][i] = btn
    end
end

function Ether.CreateLayoutSection(self)
    local parent = self.Content.Children["Layout"]

    local layoutValue = {
        [1] = {text = "Smooth Health Solo"},
        [2] = {text = "Smooth Power Solo"},
        [3] = {text = "Smooth Header"}
    }

    local layout = CreateFrame("Frame", nil, parent)
    layout:SetSize(200, (#layoutValue * 30) + 60)

    for i, opt in ipairs(layoutValue) do
        local btn = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")

        if i == 1 then
            btn:SetPoint("TOPLEFT", 5, -5)
        else
            btn:SetPoint("TOPLEFT", self.Buttons[8][i - 1], "BOTTOMLEFT", 0, 0)
        end
        btn:SetSize(24, 24)
        btn.label = GetFont(self, btn, opt.text, 12)
        btn.label:SetPoint("LEFT", btn, "RIGHT", 10, 0)
        btn:SetChecked(Ether.DB[801][i] == 1)
        btn:SetScript("OnClick", function(self)
            local checked = self:GetChecked()
            Ether.DB[801][i] = checked and 1 or 0
        end)
        self.Buttons[8][i] = btn
    end
end

local previewFrame
function Ether.CreateCastBarSection(self)
    local parent = self.Content.Children["CastBar"]

    local preview = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    previewFrame = preview
    preview:SetPoint("CENTER", parent, "CENTER", 0, 50)
    preview:SetSize(120, 50)
    Ether:SetupHealthBar(preview, "HORIZONTAL", 120, 40, "player")
    Ether:SetupPowerBar(preview, "player")
    preview:SetBackdrop({
        bgFile = Ether.DB[811]["background"],
        insets = {left = -2, right = -2, top = -2, bottom = -2}
    })
    Ether:SetupName(preview, 0)
    preview.name:SetText(Ether:ShortenName(Ether.playerName, 10))
    Ether:SetupCastBar(preview)
    preview.castBar.text:SetText("Fireball")
    preview.castBar.time:SetFormattedText("%.1f", 1.1)
    preview.castBar.icon:SetTexture(135812)
    preview.castBar.safeZone:SetColorTexture(1, 0, 0, 1)
    preview.castBar.safeZone:SetWidth(4)
    preview.castBar.safeZone:SetPoint(preview.castBar:GetReverseFill() and "LEFT" or "RIGHT")
    preview.castBar.safeZone:SetPoint("TOP")
    preview.castBar.safeZone:SetPoint("BOTTOM")
    preview.castBar:SetPoint("TOP", preview, "BOTTOM", 0, -30)
    preview.castBar:SetSize(240, 15)
    preview.castBar:SetMinMaxValues(0, 100)
    preview.castBar:SetValue(44)
    preview.castBar:SetStatusBarColor(0.2, 0.6, 1.0, 0.8)

    local castBarId = {
        [341] = "Player CastBar",
        [342] = "Target CastBar"
    }
    local castBarConfig = {
        [1] = "Height",
        [2] = "Width",
        [3] = "Time",
        [4] = "Text",
        [5] = "Position",
        [6] = "Icon",
        [7] = "SafeZone",
        [8] = "Size",
        [9] = "Alpha",
    }
    local barIdTbl = {}
    local barConfigTbl = {}
    local barDropdown
    local configDropdown
    for index, configName in pairs(castBarId) do
        table.insert(barIdTbl, {
            text = configName,
            func = function()
                barDropdown.text:SetText(configName)
                local pos = Ether.DB[5111][index]
                preview.castBar:SetSize(pos[6], pos[7])
                preview.castBar:SetScale(pos[8])
                preview.castBar:SetAlpha(pos[9])
                preview.castBar:Show()
            end
        })
    end
    for _, configName in ipairs(castBarConfig) do
        table.insert(barConfigTbl, {
            text = configName,
            func = function()
                configDropdown.text:SetText(configName)
            end
        })
    end
    barDropdown = CreateEtherDropdown(parent, 120, "Select CastBar", barIdTbl)
    previewFrame.text = barDropdown.text
    barDropdown:SetPoint("TOPLEFT")
    configDropdown = CreateEtherDropdown(parent, 120, "Config", barConfigTbl, true)
    previewFrame.config = configDropdown.text
    configDropdown:SetPoint("TOPRIGHT")

    local layoutValue = {
        [1] = {text = "Player CastBar"},
        [2] = {text = "Target CastBar"}
    }

    local layout = CreateFrame("Frame", nil, parent)
    layout:SetSize(200, (#layoutValue * 30) + 60)

    for i, opt in ipairs(layoutValue) do
        local btn = CreateFrame("CheckButton", nil, layout, "InterfaceOptionsCheckButtonTemplate")

        if i == 1 then
            btn:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, -300)
        else
            btn:SetPoint("TOPLEFT", self.Buttons[9][i - 1], "BOTTOMLEFT", 0, 0)
        end
        btn:SetSize(24, 24)
        btn.label = GetFont(self, btn, opt.text, 12)
        btn.label:SetPoint("LEFT", btn, "RIGHT", 10, 0)
        btn:SetChecked(Ether.DB[1201][i] == 1)
        btn:SetScript("OnClick", function(self)
            local checked = self:GetChecked()
            Ether.DB[1201][i] = checked and 1 or 0
            if i == 1 then
                if Ether.DB[1201][1] == 1 then
                    Ether:CastBarEnable("player")
                else
                    Ether:CastBarDisable("player")
                end
            elseif i == 2 then
                if Ether.DB[1201][2] == 1 then
                    Ether:CastBarEnable("target")
                else
                    Ether:CastBarDisable("target")
                end
            end
        end)
        self.Buttons[9][i] = btn
    end
end

function Ether.CreateConfigSection(self)
    local parent = self.Content.Children["Config"]
    local DB = Ether.DB

    local frameKeys = {
        [331] = "Tooltip",
        [332] = "Player",
        [333] = "Target",
        [334] = "TargetTarget",
        [335] = "Pet",
        [336] = "Pet Target",
        [337] = "Focus",
        [338] = "Raid",
        [339] = "Debug"
    }

    local frameGroup = {
        [331] = Ether.Anchor.tooltip,
        [332] = Ether.unitButtons.solo["player"],
        [333] = Ether.unitButtons.solo["target"],
        [334] = Ether.unitButtons.solo["targettarget"],
        [335] = Ether.unitButtons.solo["pet"],
        [336] = Ether.unitButtons.solo["pettarget"],
        [337] = Ether.unitButtons.solo["focus"],
        [338] = Ether.Anchor.raid,
        [339] = Ether.DebugFrame,

    }
    local sizeLabel = parent:CreateFontString(nil, "OVERLAY")
    sizeLabel:SetFont(unpack(Ether.mediaPath.expressway), 10, "OUTLINE")
    sizeLabel:SetPoint("TOPLEFT", 5, -50)
    sizeLabel:SetText("Size")

    local sizeSlider = CreateFrame("Slider", nil, parent, "OptionsSliderTemplate")
    sizeSlider:SetPoint("TOPLEFT", sizeLabel, "BOTTOMLEFT", 0, -10)
    sizeSlider:SetWidth(100)
    sizeSlider:SetMinMaxValues(0.5, 2)
    sizeSlider:SetValueStep(0.1)
    sizeSlider:SetObeyStepOnDrag(true)
    sizeSlider.Low:SetText("0.5")
    sizeSlider.High:SetText("2")

    local sizeSliderBG = sizeSlider:CreateTexture(nil, "BACKGROUND")
    sizeSliderBG:SetPoint("CENTER")
    sizeSliderBG:SetSize(100, 10)
    sizeSliderBG:SetColorTexture(0.2, 0.2, 0.2, 0.8)
    sizeSliderBG:SetDrawLayer("BACKGROUND", -1)

    local sizeValue = parent:CreateFontString(nil, "OVERLAY")
    sizeValue:SetFont(unpack(Ether.mediaPath.expressway), 10, "OUTLINE")
    sizeValue:SetPoint("TOP", sizeSlider, "BOTTOM", 0, -5)

    local alphaLabel = parent:CreateFontString(nil, "OVERLAY")
    alphaLabel:SetFont(unpack(Ether.mediaPath.expressway), 10, "OUTLINE")
    alphaLabel:SetPoint("LEFT", sizeLabel, "RIGHT", 100, 0)
    alphaLabel:SetText("Alpha")

    local alphaSlider = CreateFrame("Slider", nil, parent, "OptionsSliderTemplate")
    alphaSlider:SetPoint("TOPLEFT", alphaLabel, "BOTTOMLEFT", 0, -10)
    alphaSlider:SetWidth(100)
    alphaSlider:SetMinMaxValues(0.1, 1)
    alphaSlider:SetValueStep(0.1)
    alphaSlider:SetObeyStepOnDrag(true)
    alphaSlider.Low:SetText("0")
    alphaSlider.High:SetText("1")

    local alphaSliderBG = alphaSlider:CreateTexture(nil, "BACKGROUND")
    alphaSliderBG:SetPoint("CENTER")
    alphaSliderBG:SetSize(100, 10)
    alphaSliderBG:SetColorTexture(0.2, 0.2, 0.2, 0.8)
    alphaSliderBG:SetDrawLayer("BACKGROUND", -1)

    local alphaValue = parent:CreateFontString(nil, "OVERLAY")
    alphaValue:SetFont(unpack(Ether.mediaPath.expressway), 10, "OUTLINE")
    alphaValue:SetPoint("TOP", alphaSlider, "BOTTOM", 0, -5)

    SetupSliderText(sizeSlider, "0.5", "2.0")
    SetupSliderText(alphaSlider, "0", "1")
    SetupSliderThump(sizeSlider, 10, {0.8, 0.6, 0, 1})
    SetupSliderThump(alphaSlider, 10, {0.8, 0.6, 0, 1})

    local unlock = EtherPanelButton(parent, 100, 25, "Unlock frames", "TOPLEFT", sizeSlider, "BOTTOMLEFT", 0, -50)
    unlock:SetScript("OnClick", function()
        if InCombatLockdown() then return end
        if not Ether.gridFrame then
            Ether:SetupGridFrame()
        end
        local isShown = Ether.gridFrame:IsShown()
        Ether.IsMovable = not isShown
        if Ether.gridFrame then
            Ether.gridFrame:SetShown(not isShown)
        end
        if Ether.tooltipFrame then
            Ether.DB[401][3] = not isShown and 0 or 1
            Ether.tooltipFrame:SetShown(not isShown)
        end
        if Ether.debugFrame then
            Ether.debugFrame:SetShown(not isShown)
        end
        if Ether.Anchor.raid.tex then
            Ether.Anchor.raid.tex:SetShown(not isShown)
        end
    end)
--[[
    local snap = {}
    unlock:SetScript("OnShow", function()
        wipe(snap)
        snap = Ether.DataSnapShot(Ether.DB[401])
    end)
    unlock:SetScript("OnHide", function()
        Ether.DataRestore(Ether.DB[401], snap)
        Ether.EtherFrameChecked(1, 401)
    end)
]]
    local dropdowns = {}
    local frameOptions = {}
    local fontOptions = {}
    local barOptions = {}
    local bgOptions = {}
    local function UpdateValueLabels()
        local SELECTED = DB[111].SELECTED
        if not SELECTED or not DB[5111] or not DB[5111][SELECTED] then
            sizeValue:SetText("")
            alphaValue:SetText("")
            return
        end
        local pos = DB[5111][SELECTED]
        sizeValue:SetText(string_format("%.1f", pos[8] or 1))
        alphaValue:SetText(string_format("%.1f", pos[9] or 1))
    end

    local function UpdateSliders()
        local SELECTED = DB[111].SELECTED
        if not SELECTED or not DB[5111][SELECTED] then
            sizeSlider:Disable()
            alphaSlider:Disable()
            UpdateValueLabels()
            return
        end

        sizeSlider:Enable()
        alphaSlider:Enable()
        local pos = DB[5111][SELECTED]
        if math.abs((sizeSlider:GetValue() or 1) - (pos[8] or 1)) > 0.001 then
            sizeSlider:SetValue(pos[8] or 1)
        end
        if math.abs((alphaSlider:GetValue() or 1) - (pos[9] or 1)) > 0.001 then
            alphaSlider:SetValue(pos[9] or 1)
        end
        UpdateValueLabels()
    end

    local preview = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    preview:SetPoint("TOP", 20, -200)
    preview:SetSize(55, 55)
    Ether:SetupHealthBar(preview, "VERTICAL", 55, 55, "player")
    preview:SetFrameLevel(preview.healthBar:GetFrameLevel() + 1)
    Ether:SetupName(preview, -5)
    Ether:SetupPowerBar(preview, "player")
    preview:Hide()
    preview.healthBar:Hide()
    preview.powerBar:Hide()
    for frameID, frameData in pairs(frameKeys) do
        table.insert(frameOptions, {
            text = frameData,
            func = function()
                DB[111].SELECTED = frameID
                UpdateSliders()
                dropdowns.frame.text:SetText(frameKeys[frameID])
                if DB[111].SELECTED ~= 338 then
                    preview.name:Hide()
                    preview.name:ClearAllPoints()
                    preview.name:SetPoint("CENTER", preview.healthBar, "CENTER", 0, 3)
                    preview.name:SetText(Ether:ShortenName(Ether.playerName, 10))
                    preview.name:Show()
                    preview.healthBar:SetSize(120, 50)
                    preview:SetBackdrop({
                        bgFile = Ether.DB[811]["background"],
                        insets = {left = -2, right = -2, top = -2, bottom = -2}
                    })
                    preview:SetSize(120, 50)
                    preview.powerBar:SetSize(120, 10)
                    preview:Show()
                    preview.healthBar:Show()
                    preview.powerBar:Show()
                else
                    preview.name:Hide()
                    preview.name:ClearAllPoints()
                    preview.name:SetPoint("CENTER", preview.healthBar, "CENTER", 0, -5)
                    preview.name:SetText(Ether:ShortenName(Ether.playerName, 3))
                    preview.name:Show()
                    preview.healthBar:SetSize(55, 55)
                    preview:SetBackdrop({
                        bgFile = Ether.DB[811]["background"],
                        insets = {left = -2, right = -2, top = -2, bottom = -2}
                    })
                    preview:SetSize(55, 55)
                    preview.powerBar:SetSize(55, 10)
                    preview:Show()
                    preview.healthBar:Show()
                    preview.powerBar:Hide()
                end
            end
        })
    end

    dropdowns.frame = CreateEtherDropdown(parent, 160, "Select Frame", frameOptions)
    dropdowns.frame:SetPoint("TOPLEFT")

    sizeSlider:SetScript("OnValueChanged", function(self, value)
        local frame = DB[111].SELECTED
        if DB[5111][frame] then
            DB[5111][frame][8] = self:GetValue()
            Ether:ApplyFramePosition(frameGroup[frame], frame)
            UpdateValueLabels()
        end
    end)

    alphaSlider:SetScript("OnValueChanged", function(self, value)
        local frame = DB[111].SELECTED
        if DB[5111][frame] then
            DB[5111][frame][9] = self:GetValue()
            Ether:ApplyFramePosition(frameGroup[frame], frame)
            UpdateValueLabels()
        end
    end)

    UpdateSliders()

    if not LibStub or not LibStub("LibSharedMedia-3.0", true) then return end
    local LSM = LibStub("LibSharedMedia-3.0")
    for frameID, frameData in pairs(frameKeys) do
        table.insert(frameOptions, {
            text = frameData,
            func = function()
                DB[111].SELECTED = frameID
                UpdateSliders()
                dropdowns.frame.text:SetText(frameKeys[frameID])
                if DB[111].SELECTED ~= 338 then
                    preview.name:Hide()
                    preview.name:ClearAllPoints()
                    preview.name:SetPoint("CENTER", preview.healthBar, "CENTER", 0, 3)
                    preview.name:SetText(Ether:ShortenName(Ether.playerName, 10))
                    preview.name:Show()
                    preview.healthBar:SetSize(120, 50)
                    preview:SetBackdrop({
                        bgFile = Ether.DB[811]["background"],
                        insets = {left = -2, right = -2, top = -2, bottom = -2}
                    })
                    preview:SetSize(120, 50)
                    preview.powerBar:SetSize(120, 10)
                    preview:Show()
                    preview.healthBar:Show()
                    preview.powerBar:Show()
                else
                    preview.name:Hide()
                    preview.name:ClearAllPoints()
                    preview.name:SetPoint("CENTER", preview.healthBar, "CENTER", 0, -5)
                    preview.name:SetText(Ether:ShortenName(Ether.playerName, 3))
                    preview.name:Show()
                    preview.healthBar:SetSize(55, 55)
                    preview:SetBackdrop({
                        bgFile = Ether.DB[811]["background"],
                        insets = {left = -2, right = -2, top = -2, bottom = -2}
                    })
                    preview:SetSize(55, 55)
                    preview.powerBar:SetSize(55, 10)
                    preview:Show()
                    preview.healthBar:Show()
                    preview.powerBar:Hide()
                end
            end
        })
    end

    local mediaFonts = LSM:HashTable("font")
    for fontName, fontPath in pairs(mediaFonts) do
        table.insert(fontOptions, {
            text = fontName,
            func = function()
                dropdowns.font.text:SetText(fontName)
                DB[811].font = fontPath
                if preview.name then
                    preview.name:SetFont(fontPath, 13, "OUTLINE")
                end
                for _, button in pairs(Ether.unitButtons.raid) do
                    if button and button.name then
                        button.name:SetFont(fontPath, 13, "OUTLINE")
                    end
                end
                for _, button in pairs(Ether.unitButtons.solo) do
                    if button and button.name then
                        button.name:SetFont(fontPath, 13, "OUTLINE")
                    end
                end
            end})
    end
    dropdowns.font = CreateEtherDropdown(parent, 200, "Select Font", fontOptions, true)
    dropdowns.font:SetPoint("TOPRIGHT", 0, 0)
    local mediaBars = LSM:HashTable("statusbar")
    for barName, barPath in pairs(mediaBars) do
        table.insert(barOptions, {
            text = barName,
            func = function(self)
                dropdowns.bar.text:SetText(barName)
                DB[811].bar = barPath
                if preview.healthBar then
                    preview.healthBar:SetStatusBarTexture(barPath)
                end
                for _, button in pairs(Ether.unitButtons.raid) do
                    if button and button.healthBar then
                        button.healthBar:SetStatusBarTexture(barPath)
                    end
                end
                for _, button in pairs(Ether.unitButtons.solo) do
                    if button and button.healthBar then
                        button.healthBar:SetStatusBarTexture(barPath)
                    end
                end
            end})
    end

    dropdowns.bar = CreateEtherDropdown(parent, 200, "Select Statusbar", barOptions, true)
    dropdowns.bar:SetPoint("TOP", dropdowns.font, "BOTTOM")
    local bgMedia = LSM:HashTable("background")
    for bgName, bgPath in pairs(bgMedia) do
        table.insert(bgOptions, {
            text = bgName,
            func = function(self)
                dropdowns.bg.text:SetText(bgName)
                DB[811]["background"] = bgPath
                if preview then
                    preview:SetBackdrop({
                        bgFile = bgPath,
                        insets = {left = -2, right = -2, top = -2, bottom = -2}
                    })
                end
                if Editor.preview then
                    Editor.preview:SetBackdrop({
                        bgFile = bgPath,
                        insets = {left = -2, right = -2, top = -2, bottom = -2}
                    })
                end
                if Indicator.preview then
                    Indicator.preview:SetBackdrop({
                        bgFile = bgPath,
                        insets = {left = -2, right = -2, top = -2, bottom = -2}
                    })
                end
                if previewFrame then
                    previewFrame:SetBackdrop({
                        bgFile = bgPath,
                        insets = {left = -2, right = -2, top = -2, bottom = -2}
                    })
                end
                for _, button in pairs(Ether.unitButtons.solo) do
                    if button then
                        button:SetBackdrop({
                            bgFile = bgPath,
                            insets = {left = -2, right = -2, top = -2, bottom = -2}
                        })
                    end
                end
                for _, button in pairs(Ether.unitButtons.raid) do
                    if button then
                        if button then
                            button:SetBackdrop({
                                bgFile = bgPath,
                                insets = {left = -2, right = -2, top = -2, bottom = -2}
                            })
                        end
                    end
                end
            end})
    end
    dropdowns.bg = CreateEtherDropdown(parent, 200, "Select Background", bgOptions, true)
    dropdowns.bg:SetPoint("TOP", dropdowns.bar, "BOTTOM")
end

function Ether.CreateProfileSection(self)
    local parent = self.Content.Children["Edit"]
    local dropdown = CreateFrame("Frame", nil, parent, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -5)
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

    local createButton = EtherPanelButton(parent, 90, 25, "New", "TOPLEFT", dropdown, "BOTTOMLEFT", 5, -30)
    createButton:SetScript("OnClick", function()
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
    local copyButton = EtherPanelButton(parent, 90, 25, "Copy", "LEFT", createButton, "RIGHT", 5, 0)
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
    local renameButton = EtherPanelButton(parent, 90, 25, "Rename", "TOPLEFT", createButton, "BOTTOMLEFT", 0, -20)
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
    local deleteButton = EtherPanelButton(parent, 90, 25, "Delete", "LEFT", renameButton, "RIGHT", 5, 0)
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
    local resetButton = EtherPanelButton(parent, 90, 25, "Reset", "TOPLEFT", renameButton, "BOTTOMLEFT", 0, -80)
    resetButton:SetScript("OnClick", function()
        StaticPopupDialogs["ETHER_RESET_PROFILE"] = {
            text = "Reset profile to default settings?",
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
    transfer:SetPoint("TOP", parent, "TOP", 50, -5)
    transfer:SetSize(250, 200)
    local importBox
    local importBtn = EtherPanelButton(transfer, 90, 25, "Import", "LEFT", createButton, "RIGHT", 100, 0)
    local exportBtn = EtherPanelButton(transfer, 90, 25, "Export", "LEFT", importBtn, "RIGHT", 5, 0)
    exportBtn:SetScript("OnClick", function()
        local encoded = Ether.ExportProfileToClipboard()
        if encoded then
            Ether.ShowExportPopup(encoded)
        end
    end)
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

    local importBackdrop = CreateFrame("Frame", nil, transfer, "BackdropTemplate")
    importBackdrop:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -5, 5)
    importBackdrop:SetSize(285, 280)
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
    importBox:SetFont(unpack(Ether.mediaPath.expressway), 9, "OUTLINE")
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
    frame.EditBox:SetFont(unpack(Ether.mediaPath.expressway), 9, "OUTLINE")
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
    local charKey = Ether.GetCharacterKey()
    if charKey then
        ETHER_DATABASE_DX_AA.profiles[charKey] = Ether.CopyTable(Ether.DB)
    end
    if charKey and ETHER_DATABASE_DX_AA.profiles[charKey] then
        ETHER_DATABASE_DX_AA.currentProfile = charKey
    end
    Ether.UpdateAuraList()
    Ether.UpdateEditor()
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
        data = Ether.CopyTable(profileData),
    }
    local serialized = Ether.TblToString(exportData)
    local encoded = Ether.Base64Encode(serialized)
    Ether.DebugOutput("|cff00ff00Export ready:|r " .. profileName)
    Ether.DebugOutput("|cff888888Size:|r " .. #encoded .. " characters")
    return encoded
end

function Ether.ImportProfile(encodedString)
    if ETHER_DATABASE_DX_AA[101] < Ether.REQUIREMENT_VERSION then
        return false, "The import data is too old"
    end
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

    Ether:RefreshAllSettings()
    Ether:RefreshFramePositions()
    Ether.UpdateAuraList()
    Ether.UpdateEditor()
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
    Ether.UpdateAuraList()
    Ether.UpdateEditor()
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
    Ether.UpdateAuraList()
    Ether.UpdateEditor()
    return true, "Profile deleted"
end

function Ether.GetCharacterKey()
    return Ether.playerName .. "-" .. realmName
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
    Ether.UpdateAuraList()
    Ether.UpdateEditor()
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

function Ether.CleanUpButtons()
    Ether:WrapMainSettingsColor({0.80, 0.40, 1.00, 1})
    Indicator.icon:Hide()
    Indicator.text:Hide()
    Indicator.sizeSlider:Hide()
    Indicator.sizeSlider:Disable()
    Indicator.offsetYSlider:Hide()
    Indicator.offsetYSlider:Disable()
    Indicator.offsetXSlider:Hide()
    Indicator.offsetXSlider:Disable()
    Indicator.offsetXLabel:Hide()
    Indicator.sizeLabel:Hide()
    Indicator.offsetYLabel:Hide()
    Indicator.offsetXValue:Hide()
    Indicator.offsetYValue:Hide()
    Indicator.sizeValue:Hide()
    Indicator.preview:Hide()
    Editor:Hide()
    if previewFrame and previewFrame.castBar then
        previewFrame.castBar:Hide()
        previewFrame.text:SetText("Select CastBar")
        previewFrame.config:SetText("Config")
    end
    Indicator.templateDropdown.text:SetText("Select Indicator")
    for _, btn in pairs(Editor.posButtons) do
        btn:Disable()
    end
    for _, btn in pairs(Indicator.posButtons) do
        btn:Disable()
    end
end