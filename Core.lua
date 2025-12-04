---@class EtherCore
local Ether = select(2, ...)

---@class EtherCoreInitial
local Setup = {'L', 'Locale', 'Data', 'DB', 'Units', 'Events', 'Effects', 'Forming', 'Smooth', 'Update', 'Setup', 'Indicators', 'Aura', 'Range', 'Broker', 'Castbar', 'Console', 'Grid', 'Callback', 'Store', 'Table'}

local function ConfigInitialize(tbl)
    assert(type(tbl) == 'table', 'Ether Initial Table')
    for _, initial in ipairs(tbl) do
        Ether[initial] = {}
    end
end

ConfigInitialize(Setup)

Ether.L = setmetatable({}, {
    __index = function(_, __key)
        return __key
    end
})
Ether.Locale = _G.GetLocale()

Ether.ObjMetaPos = {}
Ether.ObjMetaPos.__index = Ether.ObjMetaPos

Ether.ObjPool = {}
Ether.ObjPool.__index = Ether.ObjPool

function Ether.ObjMetaPos:NEW(parent, name)
    if type(parent) == 'nil' or type(name) == 'nil' then
        error('ObjMetaPos – ' .. (parent or name) .. ' element is nil')
        return
    end
    if type(name) ~= 'string' then
        error('ObjMetaPos – name element is not a string')
        return
    end
    local obj = {
        _parent = parent,
        _pos = Ether.DB['POSITION'][name],
        _debug = false
    }
    setmetatable(obj, Ether.ObjMetaPos)
    return obj
end

function Ether.ObjMetaPos:INITIAL()
    self._parent:ClearAllPoints()
    self._parent:SetClampedToScreen(true)
    self._parent:SetMovable(true)
    local relTo = self._pos[2]
    if type(relTo) == 'string' then
        if relTo == 'UIParent' then
            relTo = UIParent
        else
            relTo = _G[relTo] or UIParent
        end
        self._parent:SetPoint(self._pos[1], relTo, self._pos[3], self._pos[4], self._pos[5]);
        self._parent:SetSize(self._pos[6], self._pos[7])
        self._parent:SetScale(self._pos[8])
        self._parent:SetAlpha(self._pos[9])
    end
end

function Ether.ObjMetaPos:SET_DRAG()
    self._parent:EnableMouse(true)
    self._parent:RegisterForDrag('LeftButton')
    self._parent:SetScript('OnDragStart', function()
        if InCombatLockdown() then
            return
        end
        self._parent:StartMoving()
        self._parent.isMoving = true
    end)
    self._parent:SetScript('OnDragStop', function()
        if InCombatLockdown() then
            return
        end
        if not self._parent.isMoving then
            return
        end
        self._parent:StopMovingOrSizing()
        self._parent.isMoving = false
        local point, relTo, relPoint, x, y = self._parent:GetPoint(1)
        local relToName
        if relTo and relTo.GetName then
            relToName = self._parent:GetName() or 'UIParent'
        else
            relToName = 'UIParent'
        end
        self._pos[1] = point
        self._pos[2] = relToName
        self._pos[3] = relPoint
        self._pos[4] = math.floor(x * 100) / 100
        self._pos[5] = math.floor(y * 100) / 100
        local anchorRelTo = _G[relToName or UIParent]
        self._parent:SetPoint(self._pos[1], anchorRelTo, self._pos[3], self._pos[4], self._pos[5])
        if self._debug then
            Ether.Console:Output(string.format('Position: %s %s %s %s, %s', self._pos[1], self._pos[2], self._pos[3], self._pos[4], self._pos[5]))
        end
    end)
end

function Ether.ObjMetaPos:DEBUG()
    if self._parent:GetScript('OnDragStop') then
        self._debug = not self._debug
    end
end

local function GetFont(_, target, tex, numb)
    target.label = target:CreateFontString(nil, 'OVERLAY')
    target.label:SetFont(unpack(Ether.Data.Forming.Font), numb, 'OUTLINE')
    target.label:SetText(tex)
    return target.label
end

local function InfoSection(self)

    local info = GetFont(self, self.Content.Childs['Info'], '|cffffff00How do I move frames?|r', 15)
    info:SetPoint('TOP', 0, -10)

    local move = GetFont(self, self.Content.Childs['Info'], 'Interface Tab and Modify Section', 12)
    move:SetPoint('TOP', info, 'BOTTOM', 0, -20)

    local slash = GetFont(self, self.Content.Childs['Info'], '|cffffff00Slash Commands|r', 15)
    slash:SetPoint('TOP', move, 'BOTTOM',0, -20)

    local lastY = -20
    for _, entry in ipairs(Ether.Data.Slash) do
        local fs = self.Content.Childs['Info']:CreateFontString(nil, 'OVERLAY')
        fs:SetFont(unpack(Ether.Data.Forming.Font), 12, 'OUTLINE')
        fs:SetPoint('TOP', slash, 'BOTTOM',0, lastY)
        fs:SetText(string.format('%s  –  %s', entry.cmd, entry.desc))
        lastY = lastY - 18
    end
end

local function AuraGuideSection(self)

    for _, data in ipairs(Ether.Data.Aura) do
        if data.spellId == 0 then
            table.insert(self.Sections.Auras.Colors, data)
        else
            table.insert(self.Sections.Auras.Spells, data)
        end
    end

    local SpellLabel = GetFont(self, self.Content.Childs['Aura Guide'], "|cffffff00Spells|r", 15)
    SpellLabel:SetPoint('TOP', 0,- 10)

    local yOff = -10

    for _, data in ipairs(self.Sections.Auras.Spells) do
        local spellText = GetFont(self, self.Content.Childs['Aura Guide'], string.format("Spell: %s | ID: %d | Color: %s", data.name, data.spellId, data.color or 'None'), 12)
        spellText:SetPoint('TOP',SpellLabel,'BOTTOM', 20, yOff)
        yOff = yOff - 18
    end

    if #self.Sections.Auras.Colors > 0 then
        local AuraLabel = GetFont(self, self.Content.Childs['Aura Guide'], "|cffffff00Aura Border Colors|r", 15)
        AuraLabel:SetPoint('TOP', self.Content.Childs['Aura Guide'], 'BOTTOM', 0, yOff -30)
        yOff = yOff - 60
        for _, data in ipairs(self.Sections.Auras.Colors) do
            local colorText = GetFont(self, self.Content.Childs['Aura Guide'], data.name, 12)
            colorText:SetPoint('TOP', self.Content.Childs['Aura Guide'],'BOTTOM',0, yOff)
            yOff = yOff - 18
        end
    end
end

local function HideSection(self)

    local hide = GetFont(self,self.Content.Childs['Hide'],'|cffffff00Hide Blizzard Frames|r',15)
    hide:SetPoint('TOP', 0, -10)

    local bF = CreateFrame('Frame', nil, self.Content.Childs['Hide'])
    bF:SetSize(200, (#Ether.Data.Hide * 30) + 60)

    for i, opt in ipairs(Ether.Data.Hide) do
        local btn = CreateFrame('CheckButton', nil, bF, 'InterfaceOptionsCheckButtonTemplate')

        if i == 1 then
            btn:SetPoint('TOPLEFT', hide, 'BOTTOMLEFT', 0, -20)
        else
            btn:SetPoint('TOPLEFT', self.Content.Buttons.Hide[i - 1], 'BOTTOMLEFT', 0, 0)
        end

        btn:SetSize(24, 24)

        btn.label = btn:CreateFontString(nil, 'OVERLAY')
        btn.label:SetFont(unpack(Ether.Data.Forming.Font), 12, 'OUTLINE')
        btn.label:SetText(opt.name)
        btn.label:SetPoint('LEFT', btn, 'RIGHT', 8, 1)

        btn:SetChecked(Ether.DB['HIDE'][opt.value] or false)

        btn:SetScript('OnClick', function(self)
            local checked = self:GetChecked()
            Ether.DB['HIDE'][opt.value] = checked
        end)

        self.Content.Buttons.Hide[i] = btn
    end
end

local function CreateSection(self)

    local CreateAndBars = GetFont(self,self.Content.Childs['Create'],'|cffffff00Create Units and Bars|r',15)
    CreateAndBars:SetPoint('TOP', 0, -10)

    local uF = CreateFrame('Frame', nil, self.Content.Childs['Create'])
    uF:SetSize(200, (#Ether.Data.Units * 30) + 60)

    for i, opt in ipairs(Ether.Data.Units) do
        local btn = CreateFrame('CheckButton', nil, uF, 'InterfaceOptionsCheckButtonTemplate')

        if i == 1 then
            btn:SetPoint('TOPLEFT', CreateAndBars, 'TOPLEFT', 10, -20)
        else
            btn:SetPoint('TOPLEFT', self.Content.Buttons.Units.A[i - 1], 'BOTTOMLEFT', 0, 0)
        end

        btn:SetSize(24, 24)

        btn.label = btn:CreateFontString(nil, 'OVERLAY')
        btn.label:SetFont(unpack(Ether.Data.Forming.Font), 12, 'OUTLINE')
        btn.label:SetText(opt.name)
        btn.label:SetPoint('LEFT', btn, 'RIGHT', 8, 1)

        btn:SetChecked(Ether.DB['CREATE'][opt.value] or false)

        btn:SetScript('OnClick', function(self)
            local checked = self:GetChecked()
            Ether.DB['CREATE'][opt.value] = checked
        end)

        self.Content.Buttons.Units.A[i] = btn
    end

    local state = false
    self.custom = CreateFrame('Button', nil, self.Content.Childs['Create'], 'UIRadioButtonTemplate')
    self.custom:SetPoint('TOPLEFT', self.Content.Buttons.Units.A[9], 'BOTTOMLEFT', 0, -30)
    self.custom:SetSize(20, 20)
    self.custom:SetScript('OnClick', function()
        if state ~= true then
            state = true
            Ether.Callback.Fire('CREATE_FAKE_UNIT')
        end
    end)

    local customUnits = self.Content.Childs['Create']:CreateFontString(nil, 'OVERLAY')
    customUnits:SetFont(unpack(Ether.Data.Forming.Font), 13, 'OUTLINE')
    customUnits:SetPoint('LEFT', self.custom, 'RIGHT', 20, 0)
    customUnits:SetText('|' .. Ether.Data.GetColor.seaGreen.str .. 'Create fake unit|r')

    local DestroyUnit = self.Content.Childs['Create']:CreateFontString(nil, 'OVERLAY')
    DestroyUnit:SetFont(unpack(Ether.Data.Forming.Font), 13, 'OUTLINE')
    DestroyUnit:SetPoint('LEFT', customUnits, 'RIGHT', 40, 0)
    DestroyUnit:SetText('|' .. Ether.Data.GetColor.fireRed.str .. 'Destroy|r')

    self.destroyCustom = CreateFrame('Button', nil, self.Content.Childs['Create'], 'UIRadioButtonTemplate')
    self.destroyCustom:SetPoint('LEFT', DestroyUnit, 'RIGHT', 10, 0)
    self.destroyCustom:SetSize(20, 20)
    self.destroyCustom:SetScript('OnClick', function()
        if state == true then
            state = false
            Ether.Callback.Fire('DESTROY_FAKE_UNIT')
        end
    end)
end

local function HeadersSection(self)
    local Raid = self.Content.Childs['Headers']:CreateFontString(nil, 'OVERLAY')
    Raid:SetFont(unpack(Ether.Data.Forming.Font), 15, 'OUTLINE')
    Raid:SetPoint('TOPLEFT', self.Content.Childs['Headers'], 'TOPLEFT', 10, -10)
    Raid:SetText('Raid')

    local headerSettings = CreateFrame('Frame', nil, self.Content.Childs['Headers'])
    headerSettings:SetSize(200, (#Ether.Data.HeaderSettings * 30) + 60)

    for i, opt in ipairs(Ether.Data.HeaderSettings) do
        local btn = CreateFrame('CheckButton', nil, headerSettings, 'InterfaceOptionsCheckButtonTemplate')

        if i == 1 then
            btn:SetPoint('TOPLEFT', Raid, 'BOTTOMLEFT', 0, -20)
        else
            btn:SetPoint('TOPLEFT', self.Content.Buttons.Headers.A[i - 1], 'BOTTOMLEFT', 0, 0)
        end

        btn:SetSize(24, 24)

        btn.label = GetFont(self,btn,opt.text,12)
        btn.label:SetPoint('LEFT', btn, 'RIGHT', 10, 0)

        btn:SetChecked(Ether.DB['HEADER']['RAID'][opt.value])

        btn:SetScript('OnClick', function(self)
            local checked = self:GetChecked()
            Ether.DB['HEADER']['RAID'][opt.value] = checked
        end)

        self.Content.Buttons.Headers.A[i] = btn
    end

    local Groups = GetFont(self,self.Content.Childs['Headers'],'Visible Groups',15)
    Groups:SetPoint('TOPRIGHT', self.Content.Childs['Headers'], 'TOPRIGHT', -20, -10)

    local groupToggle = CreateFrame('Frame', nil, self.Content.Childs['Headers'])
    groupToggle:SetSize(200, (#Ether.Data.GroupsFilter * 30) + 60)

    for i, opt in ipairs(Ether.Data.GroupsFilter) do
        local btn = CreateFrame('CheckButton', nil, groupToggle, 'InterfaceOptionsCheckButtonTemplate')

        if i == 1 then
            btn:SetPoint('TOPLEFT', Groups, 'BOTTOMLEFT', 0, -20)
        else
            btn:SetPoint('TOPLEFT', self.Content.Buttons.Headers.B[i - 1], 'BOTTOMLEFT', 0, 0)
        end

        btn:SetSize(24, 24)

        btn.label = btn:CreateFontString(nil, 'OVERLAY')
        btn.label:SetFont(unpack(Ether.Data.Forming.Font), 12, 'OUTLINE')
        btn.label:SetText(opt.text)
        btn.label:SetPoint('LEFT', btn, 'RIGHT', 10, 0)

        btn:SetChecked(Ether.DB['HEADER']['RAID']['GroupsFilter'][opt.value])

        btn:SetScript('OnClick', function(self)
            local checked = self:GetChecked()
            Ether.DB['HEADER']['RAID']['GroupsFilter'][opt.value] = checked
        end)

        self.Content.Buttons.Headers.B[i] = btn
    end

    local Party = GetFont(self,self.Content.Childs['Headers'],'Party',15)
    Party:SetPoint('TOPLEFT', self.Content.Buttons.Headers.A[6], 'BOTTOMLEFT', 0, -30)

    local PartySettings = CreateFrame('Frame', nil, self.Content.Childs['Headers'])
    PartySettings:SetSize(200, (#Ether.Data.PartyHeaderSettings * 30) + 60)

    for i, opt in ipairs(Ether.Data.PartyHeaderSettings) do
        local btn = CreateFrame('CheckButton', nil, PartySettings, 'InterfaceOptionsCheckButtonTemplate')

        if i == 1 then
            btn:SetPoint('TOPLEFT', Party, 'BOTTOMLEFT', 0, -20)
        else
            btn:SetPoint('TOPLEFT', self.Content.Buttons.Headers.C[i - 1], 'BOTTOMLEFT', 0, 0)
        end
        btn:SetSize(24, 24)

        btn.label = btn:CreateFontString(nil, 'OVERLAY')
        btn.label:SetFont(unpack(Ether.Data.Forming.Font), 12, 'OUTLINE')
        btn.label:SetText(opt.text)
        btn.label:SetPoint('LEFT', btn, 'RIGHT', 10, 0)

        btn:SetChecked(Ether.DB['HEADER']['PARTY'][opt.value])

        btn:SetScript('OnClick', function(self)
            local checked = self:GetChecked()
            Ether.DB['HEADER']['PARTY'][opt.value] = checked
        end)

        self.Content.Buttons.Headers.C[i] = btn
    end

    local RaidPet = GetFont(self, self.Content.Childs['Headers'], 'Raid pets', 15)
    RaidPet:SetPoint('TOPLEFT', self.Content.Buttons.Headers.C[5], 'BOTTOMLEFT', 0, -30)

    local RaidPetSettings = CreateFrame('Frame', nil, self.Content.Childs['Headers'])
    RaidPetSettings:SetSize(200, (#Ether.Data.PetHeaderSettings * 30) + 60)

    for i, opt in ipairs(Ether.Data.PetHeaderSettings) do
        local btn = CreateFrame('CheckButton', nil, RaidPetSettings, 'InterfaceOptionsCheckButtonTemplate')

        if i == 1 then
            btn:SetPoint('TOPLEFT', RaidPet, 'BOTTOMLEFT', 0, -20)
        else
            btn:SetPoint('TOPLEFT', self.Content.Buttons.Headers.D[i - 1], 'BOTTOMLEFT', 0, 0)
        end
        btn:SetSize(24, 24)

        btn.label = btn:CreateFontString(nil, 'OVERLAY')
        btn.label:SetFont(unpack(Ether.Data.Forming.Font), 12, 'OUTLINE')
        btn.label:SetText(opt.text)
        btn.label:SetPoint('LEFT', btn, 'RIGHT', 10, 0)

        btn:SetChecked(Ether.DB['HEADER']['RAIDPET'][opt.value])

        btn:SetScript('OnClick', function(self)
            local checked = self:GetChecked()
            Ether.DB['HEADER']['RAIDPET'][opt.value] = checked
        end)

        self.Content.Buttons.Headers.D[i] = btn
    end
end

local function AuraSection(self)
    local Auras = GetFont(self,self.Content.Childs['Auras'],'|cffffff00Auras|r',15)
    Auras:SetPoint('TOP', 0, -10)

    local auraSpellToggle = CreateFrame('Frame', nil, self.Content.Childs['Auras'])
    auraSpellToggle:SetSize(200, (#Ether.Data.AuraFilter * 30) + 60)

    for i, opt in ipairs(Ether.Data.AuraFilter) do
        local btn = CreateFrame('CheckButton', nil, auraSpellToggle, 'InterfaceOptionsCheckButtonTemplate')

        if i == 1 then
            btn:SetPoint('TOPLEFT', Auras, 'BOTTOMLEFT', 0, -20)
        else
            btn:SetPoint('TOPLEFT', self.Content.Buttons.Auras[i - 1], 'BOTTOMLEFT', 0, 0)
        end

        btn:SetSize(24, 24)

        btn.label = btn:CreateFontString(nil, 'OVERLAY')
        btn.label:SetFont(unpack(Ether.Data.Forming.Font), 12, 'OUTLINE')
        btn.label:SetText(opt.text)
        btn.label:SetPoint('LEFT', btn, 'RIGHT', 10, 0)

        btn:SetChecked(Ether.DB['HEADER']['RAID']['AuraFilter'][opt.value])

        btn:SetScript('OnClick', function()
            local checked = self:GetChecked()
            Ether.DB['HEADER']['RAID']['AuraFilter'][opt.value] = checked
        end)

        self.Content.Buttons.Auras[i] = btn
    end

    local PlayerAura = Ether.Setup:CreateToggle(self.Content.Childs['Auras'], 'Player aura', Ether.DB['CREATE'], 'PLAYERAURA', function()
        if not Ether.DB['CREATE']['PLAYER'] then
            Ether.DB['CREATE']['PLAYERAURA'] = false
        end
    end)
    PlayerAura:SetPoint('TOPLEFT', self.Content.Buttons.Auras[16], 'BOTTOMLEFT', 0, -5)

    local   TargetAura = Ether.Setup:CreateToggle(self.Content.Childs['Auras'], 'Target aura', Ether.DB['CREATE'], 'TARGETAURA', function()
        if not Ether.DB['CREATE']['TARGET'] then
            Ether.DB['CREATE']['TARGETAURA'] = false
        end
    end)
    TargetAura:SetPoint('TOPLEFT', PlayerAura, 'BOTTOMLEFT', 0, -5)
end

local function UpdateSection(self)
    local Power = GetFont(self,self.Content.Childs['Updates'],'|cffffff00Power Updates|r',15)
    Power:SetPoint('TOP', 0, -10)

    local unitShort = Ether.Setup:CreateToggle(self.Content.Childs['Updates'], 'Single units', Ether.DB['POWER']['SHORT'], 'SINGLE', function()
        Ether.Callback.Fire('POWER_DISPLAY_CHANGED')
    end)
    unitShort:SetPoint('TOP', Power, 'BOTTOM', 0, -20)

    local raidShort = Ether.Setup:CreateToggle(self.Content.Childs['Updates'], 'Raid units', Ether.DB['POWER']['SHORT'], 'RAID', function()
        Ether.Callback.Fire('POWER_DISPLAY_CHANGED')
    end)
    raidShort:SetPoint('TOP', unitShort, 'BOTTOM', 0, -20)

    local Enum = GetFont(self, self.Content.Childs['Updates'], 'Enum:', 13)
    Enum:SetPoint('TOP', raidShort, 'BOTTOM', 0, -20)

    local frame = CreateFrame('Frame', nil, self.Content.Childs['Updates'])
    frame:SetPoint('TOP', raidShort, 'BOTTOM', 0, -20)

    local dropdown = CreateFrame('Frame', nil, frame, 'UIDropDownMenuTemplate')
    dropdown:SetPoint('TOP', Enum, 'BOTTOM', 0, -20)

    local options = {'Mana', 'Rage', 'Energy', 'Power'}

    local function GetCurrentIndex()
        local current = Ether.DB['POWER']['SHORT']['DISPLAY'] or 'Power'
        for i, option in ipairs(options) do
            if option == current then
                return i
            end
        end
        return 4
    end

    UIDropDownMenu_Initialize(dropdown, function(_, level)
        for i, option in ipairs(options) do
            local infos = UIDropDownMenu_CreateInfo()
            infos.text = option
            infos.value = i
            infos.func = function()
                UIDropDownMenu_SetSelectedID(dropdown, i)
                C.DB['POWER']['SHORT']['DISPLAY'] = option
                C.Callback.Fire('POWER_DISPLAY_CHANGED')
            end
            UIDropDownMenu_AddButton(infos, level)
        end
    end)

    UIDropDownMenu_SetWidth(dropdown, 90)
    UIDropDownMenu_SetSelectedID(dropdown, GetCurrentIndex())
    UIDropDownMenu_JustifyText(dropdown, 'CENTER')
end

local function RegisterSection(self)

    local iToggle = CreateFrame('Frame', nil, self.Content.Childs['Register'])
    iToggle:SetSize(200, (#Ether.Data.Indicators * 30) + 60)

    for i, opt in ipairs(Ether.Data.Indicators) do
        local btn = CreateFrame('CheckButton', nil, iToggle, 'InterfaceOptionsCheckButtonTemplate')

        if i == 1 then
            btn:SetPoint('TOPLEFT', self.Content.Childs['Register'], 'TOPLEFT', 10, -10)
        else
            btn:SetPoint('TOPLEFT', self.Content.Buttons.Indicators[i - 1], 'BOTTOMLEFT', 0, 0)
        end

        btn:SetSize(24, 24)

        btn.label = btn:CreateFontString(nil, 'OVERLAY')
        btn.label:SetFont(unpack(Ether.Data.Forming.Font), 12, 'OUTLINE')
        btn.label:SetText(opt.text)
        btn.label:SetPoint('LEFT', btn, 'RIGHT', 10, 0)

        btn:SetChecked(Ether.DB['INDICATORS'][i] == 1)

        btn:SetScript('OnClick', function(self)
            local checked = self:GetChecked()
            Ether.DB['INDICATORS'][i] = checked and 1 or 0
            if i == 1 then
                if Ether.Indicators.GetKey('readyKey') then
                    Ether.Indicators.DisableReady()
                else
                    Ether.Indicators.EnableReady()
                end
            elseif i == 2 then
                if Ether.Indicators.GetKey('roleKey') then
                    Ether.Indicators.DisableRole()
                else
                    Ether.Indicators.EnableRole()
                end
            elseif i == 3 then
                if Ether.Indicators.GetKey('mainTankKey') then
                    Ether.Indicators.DisableMainTank()
                else
                    Ether.Indicators.EnableMainTank()
                end
            elseif i == 4 then
                if Ether.Indicators.GetKey('classKey') then
                    Ether.Indicators.DisableClassIcon()
                else
                    Ether.Indicators.EnableClassIcon()
                end
            elseif i == 5 then
                if Ether.Indicators.GetKey('offlineKey') then
                    Ether.Indicators.DisableOffline()
                else
                    Ether.Indicators.EnableOffline()
                end
            elseif i == 6 then
                --    if Ether.Indicators.GetKey('RaidTargetKey') then
                --    Ether.Indicators.DisableRaidTarget()
                --    else
                --    Ether.Indicators.EnableRaidTarget()
                --    end
            elseif i == 7 then
                if Ether.Indicators.GetKey('resurrectionKey') then
                    Ether.Indicators.DisableResurrection()
                else
                    Ether.Indicators.EnableResurrection()
                end
            elseif i == 8 then
                if Ether.Indicators.GetKey('leaderKey') then
                    Ether.Indicators.DisableLeader()
                else
                    Ether.Indicators.EnableLeader()
                end
            elseif i == 9 then
                if Ether.Indicators.GetKey('masterlootKey') then
                    Ether.Indicators.DisableMasterLoot()
                else
                    Ether.Indicators.EnableMasterLoot()
                end
            elseif i == 10 then
                if Ether.Indicators.GetKey('ghostKey') then
                    Ether.Indicators.DisableGhost()
                else
                    Ether.Indicators.EnableGhost()
                end
            elseif i == 11 then
                if Ether.Indicators.GetKey('awayKey') then
                    Ether.Indicators.DisableAway()
                else
                    Ether.Indicators.EnableAway()
                end
            elseif i == 12 then
                if Ether.Indicators.GetKey('dndKey') then
                    Ether.Indicators.DisableDnd()
                else
                    Ether.Indicators.EnableDnd()
                end
            elseif i == 13 then
                local isShown = Settings.ReloadBox:IsShown()
                Settings.ReloadBox:SetText('Reload UI')
                Settings.ReloadBox:SetShown(not isShown)
            elseif i == 14 then
                if not Ether.Range.UpdateFrames.Update:GetScript("OnUpdate") then
                    Ether.Range:Initialize()
                else
                    Ether.Range:DisableRange()
                end
            elseif i == 15 then

            end
        end)
        self.Content.Buttons.Indicators[i] = btn
    end
end

local function ModifySection(self)
    local Modify = GetFont(self, self.Content.Childs['Modify'], 'Select frame', 13)
    Modify:SetPoint('TOPLEFT', 10, -10)

    local Layout = GetFont(self, self.Content.Childs['Modify'], 'Layout', 13)
    Layout:SetPoint('LEFT', Modify, 'RIGHT', 120, 0)

    local optionPoint = GetFont(self, self.Content.Childs['Modify'], 'Point', 13)
    optionPoint:SetPoint('TOPLEFT', Modify, 'BOTTOMLEFT', 0, -60)

    local optionRelative = GetFont(self, self.Content.Childs['Modify'], 'Relative point', 13)
    optionRelative:SetPoint('LEFT', optionPoint, 'RIGHT', 120, 0)

    local optionX = GetFont(self, self.Content.Childs['Modify'], 'X Offset', 13)
    optionX:SetPoint('TOPLEFT', optionPoint, 'BOTTOMLEFT', 0, -50)

    local optionY = GetFont(self, self.Content.Childs['Modify'], 'Y Offset', 13)
    optionY:SetPoint('LEFT', optionX, 'RIGHT', 160, 0)

    local optionScale = GetFont(self, self.Content.Childs['Modify'], 'Scale', 13)
    optionScale:SetPoint('TOPLEFT', optionX, 'BOTTOMLEFT', 0, -50)

    local optionAlpha = GetFont(self, self.Content.Childs['Modify'], 'Alpha', 13)
    optionAlpha:SetPoint('LEFT', optionScale, 'RIGHT', 180, 0)

    self.select = CreateFrame('Frame', nil, self.Content.Childs['Modify'], 'UIDropDownMenuTemplate')

    self.select:SetPoint('TOPLEFT', Modify, 'BOTTOMLEFT', 0, -10)

    self.point = CreateFrame('Frame', nil, self.Content.Childs['Modify'], 'UIDropDownMenuTemplate')
    self.point:SetPoint('TOPLEFT', optionPoint, 'BOTTOMLEFT', 0, -10)

    self.relative = CreateFrame('Frame', nil, self.Content.Childs['Modify'], 'UIDropDownMenuTemplate')
    self.relative:SetPoint('TOPLEFT', optionRelative, 'BOTTOMLEFT', 0, -10)

    self.layout = CreateFrame('Frame', nil, self.Content.Childs['Modify'], 'UIDropDownMenuTemplate')
    self.layout:SetPoint('TOPLEFT', Layout, 'BOTTOMLEFT', 0, -10)

    self.xSlide = CreateFrame('Slider', nil, self.Content.Childs['Modify'], 'UISliderTemplate')
    self.xSlide:SetPoint('TOPLEFT', optionX, 'BOTTOMLEFT', 0, -10)
    self.xSlide:SetSize(180, 20)
    self.xSlide:SetMinMaxValues(-1600, 1600)
    self.xSlide:SetValueStep(10)

    self.xText = self.xSlide:CreateFontString(nil, 'OVERLAY')
    self.xText:SetFont(unpack(Ether.Data.Forming.Font), 13, 'OUTLINE')
    self.xText:SetPoint('LEFT', self.xSlide, 'RIGHT', 10, 0)

    self.ySlide = CreateFrame('Slider', nil, self.Content.Childs['Modify'], 'UISliderTemplate')
    self.ySlide:SetPoint('TOPLEFT', optionY, 'BOTTOMLEFT', 0, -10)
    self.ySlide:SetSize(180, 20)
    self.ySlide:SetMinMaxValues(-1600, 1600)
    self.ySlide:SetValueStep(10)

    self.yText = self.ySlide:CreateFontString(nil, 'OVERLAY')
    self.yText:SetFont(unpack(Ether.Data.Forming.Font), 13, 'OUTLINE')
    self.yText:SetPoint('LEFT', self.ySlide, 'RIGHT', 10, 0)

    self.sSlide = CreateFrame('Slider', nil, self.Content.Childs['Modify'], 'UISliderTemplate')
    self.sSlide:SetPoint('TOPLEFT', optionScale, 'BOTTOMLEFT', 0, -10)
    self.sSlide:SetSize(180, 20)
    self.sSlide:SetMinMaxValues(0.5, 2.5)
    self.sSlide:SetValueStep(0.1)

    self.sText = self.sSlide:CreateFontString(nil, 'OVERLAY')
    self.sText:SetFont(unpack(Ether.Data.Forming.Font), 13, 'OUTLINE')
    self.sText:SetPoint('LEFT', self.sSlide, 'RIGHT', 10, 0)

    self.aSlide = CreateFrame('Slider', nil, self.Content.Childs['Modify'], 'UISliderTemplate')
    self.aSlide:SetPoint('TOPLEFT', optionAlpha, 'BOTTOMLEFT', 0, -10)
    self.aSlide:SetSize(180, 20)
    self.aSlide:SetMinMaxValues(0.1, 1)
    self.aSlide:SetValueStep(0.1)

    self.aText = self.aSlide:CreateFontString(nil, 'OVERLAY')
    self.aText:SetFont(unpack(Ether.Data.Forming.Font), 13, 'OUTLINE')
    self.aText:SetPoint('LEFT', self.aSlide, 'RIGHT', 10, 0)

    local function UpdateValue()
        local SELECTED = Ether.DB['SELECTED']

        UIDropDownMenu_SetText(self.point, Ether.DB['POSITION'][SELECTED][1] or 'CENTER')
        UIDropDownMenu_SetText(self.relative, Ether.DB['POSITION'][SELECTED][3] or 'CENTER')

        self.xSlide:SetValue(Ether.DB['POSITION'][SELECTED][4] or 0)
        self.ySlide:SetValue(Ether.DB['POSITION'][SELECTED][5] or 0)
        self.sSlide:SetValue(Ether.DB['POSITION'][SELECTED][8] or 1)
        self.aSlide:SetValue(Ether.DB['POSITION'][SELECTED][9] or 1)
        self.xText:SetText(Ether.DB['POSITION'][SELECTED][4] or 0)
        self.yText:SetText(Ether.DB['POSITION'][SELECTED][5] or 0)
        self.sText:SetText(Ether.DB['POSITION'][SELECTED][8] or 1)
        self.aText:SetText(Ether.DB['POSITION'][SELECTED][9] or 1)
    end

    local selectDropdown = self.select
    local CursorBtn

    UIDropDownMenu_Initialize(selectDropdown, function()
        for _, option in ipairs(Ether.Data.OSelect) do
            local infos = UIDropDownMenu_CreateInfo()
            infos.text = option.name
            infos.value = option.value
            infos.func = function(button)
                Ether.DB['SELECTED'] = button.value
                UIDropDownMenu_SetSelectedValue(selectDropdown, button.value)
                UIDropDownMenu_SetText(selectDropdown, option.name)
                UpdateValue()
                Ether.Callback.Fire('FRAME_UPDATE', frame)
                CursorBtn:SetText('|cE600CCFF' .. Ether.DB['SELECTED'] .. '|r')
            end
            UIDropDownMenu_AddButton(infos)
        end
    end)

    local function UpdateSliders()
        local frame = Ether.DB['SELECTED']
        local xValue = Ether.DB['POSITION'][frame][4] or 0
        local yValue = Ether.DB['POSITION'][frame][5] or 0
        local sValue = Ether.DB['POSITION'][frame][8] or 1
        local aValue = Ether.DB['POSITION'][frame][9] or 1

        self.xSlide:SetValue(math.floor(xValue + 0.5))
        self.ySlide:SetValue(math.floor(yValue + 0.5))
        self.sSlide:SetValue(math.floor(sValue + 0.5))
        self.aSlide:SetValue(math.floor(aValue + 0.5))
        self.xText:SetText(xValue)
        self.yText:SetText(yValue)
        self.sText:SetText(sValue)
        self.aText:SetText(aValue)
    end

    UIDropDownMenu_JustifyText(self.select, 'LEFT')

    local pointDropdown = self.point

    UIDropDownMenu_Initialize(pointDropdown, function()
        for _, point in ipairs(Ether.Data.PointRelative) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = point.name
            info.value = point.value
            info.func = function(button)
                local frame = Ether.DB['SELECTED']
                Ether.DB['POSITION'][frame][1] = button.value
                UIDropDownMenu_SetText(pointDropdown, button:GetText())
                Ether.Callback.Fire('FRAME_UPDATE', frame)
            end
            UIDropDownMenu_AddButton(info)
        end
    end)
    local relativeDropdown = self.relative

    UIDropDownMenu_Initialize(relativeDropdown, function()
        for _, pointName in ipairs(Ether.Data.PointRelative) do
            local infos = UIDropDownMenu_CreateInfo()
            infos.text = pointName.name
            infos.value = pointName.value
            infos.func = function(button)
                local frame = Ether.DB['SELECTED']
                Ether.DB['POSITION'][frame][3] = button.value
                UIDropDownMenu_SetText(relativeDropdown, button:GetText())
                Ether.Callback.Fire('FRAME_UPDATE', frame)
            end
            UIDropDownMenu_AddButton(infos)
        end
    end)

    local layoutDropdown = self.layout

    UIDropDownMenu_Initialize(layoutDropdown, function()
        for _, layout in ipairs(Ether.Data.nameLayouts) do
            local infos = UIDropDownMenu_CreateInfo()
            infos.text = layout.name
            infos.value = layout.value
            infos.func = function(button)
                Ether.DB['LAYOUT']['CURRENT'] = button.value
                UIDropDownMenu_SetText(layoutDropdown, button:GetText())
            end
            UIDropDownMenu_AddButton(infos)
        end
    end)

    self.xSlide:SetScript('OnValueChanged', function(slider, value)
        local step = 10
        local steppedValue = math.floor(value / step + 0.5) * step
        steppedValue = math.max(-1600, math.min(1600, steppedValue))
        slider:SetValue(steppedValue)
        local frame = Ether.DB['SELECTED']
        Ether.DB['POSITION'][frame][4] = steppedValue
        self.xText:SetText(steppedValue)
        Ether.Callback.Fire('FRAME_UPDATE', frame)
    end)

    self.ySlide:SetScript('OnValueChanged', function(slider, value)
        local step = 10
        local steppedValue = math.floor(value / step + 0.5) * step
        steppedValue = math.max(-1600, math.min(1600, steppedValue))
        slider:SetValue(steppedValue)
        local frame = Ether.DB['SELECTED']
        Ether.DB['POSITION'][frame][5] = steppedValue
        self.yText:SetText(steppedValue)
        Ether.Callback.Fire('FRAME_UPDATE', frame)
    end)

    self.sSlide:SetScript('OnValueChanged', function(slider, value)
        local step = 0.1
        local steppedValue = math.floor(value / step + 0.5) * step
        steppedValue = math.max(0.5, math.min(2.5, steppedValue))
        slider:SetValue(steppedValue)
        local frame = Ether.DB['SELECTED']
        Ether.DB['POSITION'][frame][8] = steppedValue
        self.sText:SetText(steppedValue)
        Ether.Callback.Fire('FRAME_UPDATE', frame)
    end)

    self.aSlide:SetScript('OnValueChanged', function(slider, value)
        local step = 0.1
        local steppedValue = math.floor(value / step + 0.5) * step
        steppedValue = math.max(0.1, math.min(1, steppedValue))
        slider:SetValue(steppedValue)
        local frame = Ether.DB['SELECTED']
        Ether.DB['POSITION'][frame][9] = steppedValue
        self.aText:SetText(steppedValue)
        Ether.Callback.Fire('FRAME_UPDATE', frame)
    end)

    CursorBtn = self.Content.Childs['Modify']:CreateFontString(nil, 'OVERLAY')
    CursorBtn:SetFont(unpack(Ether.Data.Forming.Font), 13, 'OUTLINE')
    CursorBtn:SetPoint('TOP', self.sSlide, 'BOTTOM', 0, -30)
    CursorBtn:SetText('|cE600CCFF' .. Ether.DB['SELECTED'] .. '|r')

    self.yUpper = CreateFrame('Button', nil, self.Content.Childs['Modify'], 'GameMenuButtonTemplate')
    self.yUpper:SetPoint('TOP', CursorBtn, 'BOTTOM', 0, -20)
    self.yUpper:SetSize(24, 24)
    self.yUpper:SetScript('OnClick', function()
        local frame = Ether.DB['SELECTED']
        local current = Ether.DB['POSITION'][frame][5]
        local newValue = math.min(1600, current + 10)
        Ether.DB['POSITION'][frame][5] = newValue
        UpdateValue()
    end)

    self.yLower = CreateFrame('Button', nil, self.Content.Childs['Modify'], 'GameMenuButtonTemplate')
    self.yLower:SetPoint('TOP', self.yUpper, 'BOTTOM', 0,-20)
    self.yLower:SetSize(24, 24)
    self.yLower:SetScript('OnClick', function()
        local frame = Ether.DB['SELECTED']
        local current = Ether.DB['POSITION'][frame][5]
        local newValue = math.max(-1600, current - 10)
        Ether.DB['POSITION'][frame][5] = newValue
        UpdateValue()
    end)

    self.xLeft = CreateFrame('Button', nil, self.Content.Childs['Modify'], 'GameMenuButtonTemplate')
    self.xLeft:SetPoint('TOPLEFT', self.yUpper, 'BOTTOMLEFT', -30,0)
    self.xLeft:SetSize(24, 24)
    self.xLeft:SetScript('OnClick', function()
        local frame = Ether.DB['SELECTED']
        local current = Ether.DB['POSITION'][frame][4]
        local newValue = math.max(-1600, current - 10)
        Ether.DB['POSITION'][frame][4] = newValue
        UpdateValue()
    end)

    self.xRight = CreateFrame('Button', nil, self.Content.Childs['Modify'], 'GameMenuButtonTemplate')
    self.xRight:SetPoint('TOPRIGHT', self.yUpper, 'BOTTOMRIGHT', 30,0)
    self.xRight:SetSize(24, 24)
    self.xRight:SetScript('OnClick', function()
        local frame = Ether.DB['SELECTED']
        local current = Ether.DB['POSITION'][frame][4]
        local newValue = math.min(1600, current + 10)
        Ether.DB['POSITION'][frame][4] = newValue
        UpdateValue()
    end)


        local lSText = self.Content.Childs['Modify']:CreateFontString(nil, 'OVERLAY')
        lSText:SetFont(unpack(Ether.Data.Forming.Font), 13, 'OUTLINE')
        lSText:SetPoint('TOP', self.aSlide, 'BOTTOM', 0, -30)
        lSText:SetText('|cE600CCFF' .. Ether.DB['STATUS'] .. '|r')

    self.lSwitch = CreateFrame('Button', nil, self.Content.Childs['Modify'], 'GameMenuButtonTemplate')
    self.lSwitch:SetPoint('TOP', lSText, 'BOTTOM', 0, -20)
    self.lSwitch:SetSize(24, 24)
    self.lSwitch:SetScript('OnClick', function()
        if Ether.DB['STATUS'] == 'ALPHA' then
            Ether.DB['STATUS'] = 'SCALE'
        else
            Ether.DB['STATUS'] = 'ALPHA'
        end
        lSText:SetText('|cE600CCFF' .. Ether.DB['STATUS'] .. '|r')
    end)

        self.lMinus = CreateFrame('Button', nil, self.Content.Childs['Modify'], 'GameMenuButtonTemplate')
        self.lMinus:SetPoint('TOPLEFT',  self.lSwitch, 'BOTTOMLEFT', -30, -0)
        self.lMinus:SetSize(24, 24)
        self.lMinus:SetScript('OnClick', function()
            local frame = Ether.DB['SELECTED']
            local status = Ether.DB['STATUS']
            local current = Ether.DB['POSITION'][frame][9]
            local newValue
            if status == 'ALPHA' then
                current = Ether.DB['POSITION'][frame][9]
                newValue = math.max(0.1, current - 0.1)
                Ether.DB['POSITION'][frame][9] = newValue
            else
                current = Ether['DB']['POSITION'][frame][8]
                newValue = math.max(0.5, current - 0.1)
                Ether.DB['POSITION'][frame][8] = newValue
            end
            UpdateValue()
        end)


        self.lPlus = CreateFrame('Button', nil, self.Content.Childs['Modify'], 'GameMenuButtonTemplate')
        self.lPlus:SetPoint('TOPRIGHT',  self.lSwitch, 'BOTTOMRIGHT', 30,0 )
        self.lPlus:SetSize(24, 24)
        self.lPlus:SetScript('OnClick', function()
            local frame = Ether.DB['SELECTED']
            local status = Ether.DB['STATUS']
            local current = Ether.DB['POSITION'][frame][9]
            local newValue
            if status == 'ALPHA' then
                current = Ether['DB']['POSITION'][frame][9]
                newValue = math.min(1, current + 0.1)
                Ether.DB['POSITION'][frame][9] = newValue
            else
                current = Ether.DB['POSITION'][frame][8]
                newValue = math.min(2.5, current + 0.1)
                Ether.DB['POSITION'][frame][8] = newValue
            end
            UpdateValue()
        end)

    local function SetInitialValue()
        local currentFrame = Ether.DB['SELECTED']
        if not currentFrame then
            UIDropDownMenu_SetText(selectDropdown, 'Choose frame...')
            return
        end

        for _, option in ipairs(Ether.Data.OSelect) do
            if option.value == currentFrame then
                UIDropDownMenu_SetSelectedValue(selectDropdown, option.value)
                UIDropDownMenu_SetText(selectDropdown, option.name)
                UpdateValue()
                break
            end
        end
    end

    SetInitialValue()
    UpdateSliders()

    local mod = CreateFrame('Frame', nil, self.Content.Childs['Modify'])
    mod:SetSize(200, (#Ether.Data.Modules * 30) + 60)

    for i, opt in ipairs(Ether.Data.Modules) do
        local btn = CreateFrame('CheckButton', nil, mod, 'OptionsBaseCheckButtonTemplate')

        if i == 1 then
            btn:SetPoint('TOPRIGHT', self.aSlide, 'BOTTOMRIGHT', 20, -70)
        else
            btn:SetPoint('TOPLEFT', self.Content.Buttons.Modify[i - 1], 'BOTTOMLEFT', 0, 0)
        end

        btn:SetSize(24, 24)

        GetFont(self, btn, opt.name, 12)

        btn.label:SetPoint('LEFT', btn, 'RIGHT', 10, 0)
        btn:SetChecked(Ether.DB['MODULES'][i] == 1)

        btn:SetScript('OnClick', function(self)
            local checked = self:GetChecked()
            Ether.DB['MODULES'][i] = checked and 1 or 0
            if i == 1 then
                Ether.Broker.MoveIcon()
            elseif i == 2 then
                Ether.Broker.Compartment()
            elseif i == 3 then
                Ether.Callback.Fire('TOGGLE_GRID')
            end
        end)

        self.Content.Buttons.Modify[i] = btn
    end

    self.GridCheckbox = self.Content.Buttons.Modify[3]

    local Reload = GetFont(self, self.Content.Childs['Modify'], 'Reload', 13)
    Reload:SetPoint('TOPLEFT', self.Content.Buttons.Modify[3], 'BOTTOMLEFT', 0, -30)

    local Reset = GetFont(self, self.Content.Childs['Modify'], 'Reset', 13)
    Reset:SetPoint('LEFT', Reload, 'RIGHT', 40, 0)

    self.ReloadUI = CreateFrame('CheckButton', nil, self.Content.Childs['Modify'], 'GameMenuButtonTemplate')
    self.ReloadUI:SetPoint('TOP', Reload, 'BOTTOM', 0, -5)
    self.ReloadUI:SetSize(24, 24)
    self.ReloadUI:SetScript('OnClick', function()
        local isShown = self.ReloadBox:IsShown()
        self.ReloadBox:SetText('|cffffd700Reload|r')
        self.ReloadBox:SetShown(not isShown)
    end)

    self.DataReset = CreateFrame('Button', nil, self.Content.Childs['Modify'], 'GameMenuButtonTemplate')
    self.DataReset:SetPoint('TOP', Reset, 'BOTTOM', 0, -5)
    self.DataReset:SetSize(24, 24)
    self.DataReset:SetScript('OnClick', function()
        local isShown = self.ReloadBox:IsShown()
        self.ReloadBox:SetText('|cffff0000Reset|r')
        self.ReloadBox:SetShown(not isShown)
    end)
end

local function BuildContent(self)
    -- Tab General
    InfoSection(self)
    AuraGuideSection(self)

    -- Tab Units
    HideSection(self)
    CreateSection(self)
    HeadersSection(self)
    AuraSection(self)
    UpdateSection(self)

    -- Tab Indicators
    RegisterSection(self)

    -- Tab Interface
    ModifySection(self)
end

local function CreateBorder(self)
    self.top = self:CreateTexture(nil, 'BORDER')
    self.top:SetColorTexture(1, 1, 1, 1)
    self.top:SetPoint('TOPLEFT', -2, 2)
    self.top:SetPoint('TOPRIGHT', 2, 2)
    self.top:SetHeight(1)

    self.bottom = self:CreateTexture(nil, 'BORDER')
    self.bottom:SetColorTexture(1, 1, 1, 1)
    self.bottom:SetPoint('BOTTOMLEFT', -2, -2)
    self.bottom:SetPoint('BOTTOMRIGHT', 2, -2)
    self.bottom:SetHeight(1)

    self.left = self:CreateTexture(nil, 'BORDER')
    self.left:SetColorTexture(1, 1, 1, 1)
    self.left:SetPoint('TOPLEFT', -2, 2)
    self.left:SetPoint('BOTTOMLEFT', -2, -2)
    self.left:SetWidth(1)

    self.right = self:CreateTexture(nil, 'BORDER')
    self.right:SetColorTexture(1, 1, 1, 1)
    self.right:SetPoint('TOPRIGHT', 2, 2)
    self.right:SetPoint('BOTTOMRIGHT', 2, -2)
    self.right:SetWidth(1)
end

local C_AddOns = C_AddOns
local GetMetadata = C_AddOns.GetAddOnMetadata
local unitName = UnitName('player')
local dataRegistered = false
local updatedChannel = false
Ether.version = GetMetadata('Ether', 'Version')
Ether.debug = false

---@class Ether_Settings
---@field ContentKeys string[] -- Array of content keys
---@field IsLoaded boolean -- Lazy loading check
---@field IsSuccesses boolean -- Controlled Assertion
local Construct = {
    IsSuccess = false,
    IsLoaded = false,
    Frames = {},
    MenuButtons = {},
    ScrollFrames = {},
    DropDownTemplates = {},
    Content = {
        Childs = {},
        Buttons = {
            Modify = {},
            Hide = {},
            Auras = {},
            Indicators = {},
            Units = {
                A = {},
                B = {}
            },
            Headers = {
                A = {},
                B = {},
                C = {},
                D = {}
            }
        }
    },
    ContentKeys = {
        [1] = {'Info', 'Aura Guide'},
        [2] = {'Hide', 'Create', 'Headers', 'Auras', 'Updates'},
        [3] = {'Register'},
        [4] = {'Modify'}
    },
    Menu = {
        ['LEFT'] = {
            [1] = {'General'},
            [2] = {'Units'},
            [3] = {'Indicators'},
            [4] = {'Interface'}
        },
        ['TOP'] = {
            [1] = {'Info', 'Aura Guide'},
            [2] = {'Hide', 'Create', 'Headers', 'Auras', 'Updates'},
            [3] = {'Register'},
            [4] = {'Modify'}
        }
    },
    Sections = {
        Auras = {
            Spells = {},
            Colors = {}
        }
    },
    Steps = {0, 0, 0, 0, 0}
}

local function BuildFrames()
    Construct.Frames['Main'] = CreateFrame('Frame', nil, UIParent, 'BackdropTemplate')
    Construct.Frames['Main']:SetFrameLevel(100)
    Construct.Frames['Main']:SetBackdrop({
        bgFile = 'Interface\\ChatFrame\\ChatFrameBackground',
        edgeFile = 'Interface\\DialogFrame\\UI-DialogBox-Border',
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = {
            left = 4,
            right = 4,
            top = 4,
            bottom = 4
        }
    })
    Construct.Frames['Main']:SetBackdropColor(0.1, 0.1, 0.1, .9)
    Construct.Frames['Main']:SetBackdropBorderColor(0.4, 0.4, 0.4)
    Construct.Frames['Main']:Hide()
    RegisterAttributeDriver(Construct.Frames['Main'], 'state-visibility', '[combat]hide')

    Construct.X = CreateFrame('Button', nil, Construct.Frames['Main'], 'UIPanelCloseButton')
    Construct.X:SetPoint('TOPRIGHT', -5, -5)
    Construct.X:SetSize(32, 32)
    Construct.X:SetScript('OnClick', function()
        Ether.DB['SHOW'] = false
        Construct:Toggle()
    end)

    Construct.Frames['Top'] = CreateFrame('Frame', nil, Construct.Frames['Main'])
    Construct.Frames['Top']:SetPoint('TOPLEFT', 10, -10)
    Construct.Frames['Top']:SetPoint('TOPRIGHT', -10, 0)
    Construct.Frames['Top']:SetSize(0, 40)

    Construct.Frames['Bottom'] = CreateFrame('Frame', nil, Construct.Frames['Main'])
    Construct.Frames['Bottom']:SetPoint('BOTTOMLEFT', 10, 10)
    Construct.Frames['Bottom']:SetPoint('BOTTOMRIGHT', -10, 0)
    Construct.Frames['Bottom']:SetSize(0, 30)

    Construct.Frames['Left'] = CreateFrame('Frame', nil, Construct.Frames['Main'])
    Construct.Frames['Left']:SetPoint('TOPLEFT', Construct.Frames['Top'], 'BOTTOMLEFT')
    Construct.Frames['Left']:SetPoint('BOTTOMLEFT', Construct.Frames['Bottom'], 'TOPLEFT')
    Construct.Frames['Left']:SetSize(110, 0)

    Construct.Frames['Right'] = CreateFrame('Frame', nil, Construct.Frames['Top'])
    Construct.Frames['Right']:SetPoint('TOPRIGHT', Construct.Frames['Bottom'], 'TOPRIGHT')
    Construct.Frames['Right']:SetPoint('BOTTOMRIGHT', Construct.Frames['Bottom'], 'TOPRIGHT')
    Construct.Frames['Right']:SetSize(10, 0)

    Construct.Frames['Content'] = CreateFrame('Frame', nil, Construct.Frames['Top'])
    Construct.Frames['Content']:SetPoint('TOP', Construct.Frames['Top'], 'BOTTOM')
    Construct.Frames['Content']:SetPoint('BOTTOM', Construct.Frames['Bottom'], 'TOP')
    Construct.Frames['Content']:SetPoint('LEFT', Construct.Frames['Left'], 'RIGHT')
    Construct.Frames['Content']:SetPoint('RIGHT', Construct.Frames['Right'], 'LEFT')

    CreateBorder(Construct.Frames['Content'])

    local version = Construct.Frames['Bottom']:CreateFontString(nil, 'OVERLAY')
    version:SetFont(unpack(Ether.Data.Forming.Font), 15, 'OUTLINE')
    version:SetPoint('BOTTOMRIGHT', -10, 3)
    version:SetText('Beta Build |cE600CCFF' .. Ether.version .. '|r')
    local name = Construct.Frames['Bottom']:CreateFontString(nil, 'OVERLAY')
    name:SetFont(unpack(Ether.Data.Forming.Font), 15, 'OUTLINE')
    name:SetPoint('BOTTOMLEFT', 10, 3)
    name:SetText('|cffCC66FFEther Unit Frames|r')

    Construct.__SETTINGS = Ether.ObjMetaPos:NEW(Construct.Frames['Main'], 'SETTINGS')
    Construct.__SETTINGS:INITIAL()
    Construct.__SETTINGS:SET_DRAG()
end

local function CreateMenuButton(self, name, parent, layer, onClick, isTopButton)
    local btn = CreateFrame('Button', nil, parent)
    btn:SetHeight(25)
    if isTopButton then
    else
        btn:SetWidth(parent:GetWidth() - 10)
    end
    btn.font = GetFont(self, btn, name, 15)
    btn.font:SetText(name)
    btn.font:SetAllPoints()
    btn.Highlight = btn:CreateTexture(nil, "HIGHLIGHT")
    btn.Highlight:SetAllPoints()
    btn.Highlight:SetColorTexture(1, 1, 1, .4)

    btn:SetScript("OnClick", function()
        for _, child in pairs(self.Content.Childs) do
            child:Hide()
        end
        return onClick(name, layer)
    end)

    return btn
end

local function IsSuccess(self)
    local success, msg = pcall(function()
        assert(self.Steps[1] == 1 and self.Steps[3] == 1 and self.Steps[3] == 1 and self.Steps[4] == 1, 'Steps incomplete')
    end)
    if not success then
        Ether.Console:Output('Assertion failed - ', msg)
        return false
    else
        return true
    end
end

local function ShowCategory(self, IdStr)
    if not self.IsLoaded then
        return
    end

    for _, child in pairs(self.Content.Childs) do
        if child._ScrollFrame then
            child._ScrollFrame:Hide()
        else
            child:Hide()
        end
    end

    local target = self.Content.Childs[IdStr]
    if target then
        if target._ScrollFrame then
            local scrollFrame = target._ScrollFrame

            scrollFrame:Show()

            target:Show()
            local width = scrollFrame:GetWidth()
            if width > 30 then
                target:SetWidth(width - 30)
            else
                target:SetWidth(self.Frames['Content']:GetWidth() - 30)
            end

            scrollFrame:UpdateScrollChildRect()
        else
            target:Show()
        end

        Ether.DB['LAST_TAB'] = IdStr
    end
end

local function CreateScrollTab(parent, name)

    local scrollFrame = CreateFrame('ScrollFrame', name .. 'Scroll', parent, 'UIPanelScrollFrameTemplate')
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
        self:SetVerticalScroll(math.max(0, math.min(max, cur - (delta * 20))))
    end)

    content._ScrollFrame = scrollFrame

    return content
end

local function InitializeSettings(self)
    if self.IsLoaded then
        return
    end

    for _, frames in pairs(self.Frames) do
        if frames then
            self.Steps[1] = 1
        end
    end

    for layer = 1, 4 do
        if self.ContentKeys[layer] then
            for _, name in ipairs(self.ContentKeys[layer]) do
                self.Content.Childs[name] = CreateScrollTab(self.Frames['Content'], name)
                self.Content.Childs[name].tex = self.Content.Childs[name]:CreateTexture(nil, 'BACKGROUND')
                self.Content.Childs[name].tex:SetAllPoints()
                self.Content.Childs[name].tex:SetColorTexture(0, 0, 0, 0.5)
                self.Content.Childs[name]._ScrollFrame:Hide()
            end
        end
    end

    BuildContent(self)

    if self.Content.Childs['Modify'] then
        self.Steps[2] = 1
    end

    for layer = 1, 4 do
        if self.Menu['TOP'][layer] then
            self.MenuButtons[layer] = {}
            local BtnConfig = {}
            for idx, itemName in ipairs(self.Menu['TOP'][layer]) do
                local btn = CreateMenuButton(self, itemName, self.Frames['Top'], layer, function(btnName)
                    ShowCategory(self, btnName)
                end, true)

                btn:SetWidth(self.Frames['Top']:GetWidth() / 6)

                btn:Hide()
                BtnConfig[idx] = {
                    btn = btn,
                    name = itemName,
                    width = btn:GetWidth()
                }
                self.MenuButtons[layer][itemName] = btn
            end

            if #BtnConfig > 0 then
                local spacing = 10
                local totalWidth = 0

                for _, data in ipairs(BtnConfig) do
                    totalWidth = totalWidth + data.width
                end
                totalWidth = totalWidth + (#BtnConfig - 1) * spacing

                local startX = -totalWidth / 2
                local currentX = startX

                for _, data in ipairs(BtnConfig) do
                    data.btn:SetPoint("CENTER", self.Frames['Top'], "CENTER", currentX + data.width / 2, 5)
                    currentX = currentX + data.width + spacing
                end
            end
        end
    end

    if self.Menu['TOP'][4] then
        self.Steps[3] = 1
    end

    local last = nil
    for layer = 1, 4 do
        if self.Menu['LEFT'][layer] then
            for _, itemName in ipairs(self.Menu['LEFT'][layer]) do
                local btn = CreateMenuButton(self, itemName, self.Frames['Left'], layer, function(_, btnLayer)
                    for _, layers in pairs(self.MenuButtons) do
                        for _, topBtn in pairs(layers) do
                            topBtn:Hide()
                        end
                    end

                    if self.MenuButtons[btnLayer] then
                        for _, topBtn in pairs(self.MenuButtons[btnLayer]) do
                            topBtn:Show()
                        end
                    end
                end, false)

                if last then
                    btn:SetPoint('TOPLEFT', last, 'BOTTOMLEFT', 0, 0)
                    btn:SetPoint('TOPRIGHT', last, 'BOTTOMRIGHT', 0, -2)
                else
                    btn:SetPoint('TOPLEFT', self.Frames['Left'], 'TOPLEFT', 5, 0)
                    btn:SetPoint('TOPRIGHT', self.Frames['Left'], 'TOPRIGHT', -10, 0)
                end

                last = btn
            end
        end
    end

    if self.Menu['LEFT'][4] then
        self.Steps[4] = 1
    end

    self.IsLoaded = true

    if IsSuccess(self) then
        self.IsSuccess = true
    end
end

local function FindLayer(self, category)
    for layer = 1, 4 do
        if self.ContentKeys[layer] then
            for _, name in ipairs(self.ContentKeys[layer]) do
                if name == category then
                    return layer
                end
            end
        end
    end
    return nil
end

function Construct:Toggle()
    if not self.IsLoaded then
        InitializeSettings(self)
    end
    if not self.IsSuccess then
        return
    end

    local bool = Ether.DB['SHOW']
    self.Frames['Main']:SetShown(bool)

    local category = Ether.DB['LAST_TAB'] or 'Info'
    if self.Content.Childs[category] then
        ShowCategory(self, category)
        local layer = FindLayer(self, category)
        if layer and self.MenuButtons[layer] then
            for _, topBtn in pairs(self.MenuButtons[layer]) do
                topBtn:Show()
            end
        end
    end
end

local function UpdateRosterCache()
    wipe(Ether.Units.Data.Update.Cache)
    for _, data in pairs(Ether.Units.Data.Buttons.Raid) do
        if data then
            local unitId = data:GetAttribute('unit')
            if unitId then
                Ether.Units.Data.Update.Cache[unitId] = data
            end
        end
    end
end

local function RosterInitialCache()
    wipe(Ether.Units.Data.Update.Cache)
    for groupID = 1, 8 do
        local header = Ether.Units.Data.Header.SplitHeader['Groups' .. groupID]
        if header then
            for _, child in ipairs({header:GetChildren()}) do
                if child then
                    local unitId = child:GetAttribute('unit')
                    if unitId then
                        Ether.Units.Data.Update.Cache[unitId] = child
                    end
                end
            end
        end
    end
end

-- Hidden parent
local hiddenParent = CreateFrame('Frame', nil, UIParent)
hiddenParent:SetAllPoints()
hiddenParent:Hide()
local function HiddenFrame(frame)
    if not frame then
        return
    end
    frame:UnregisterAllEvents()
    frame:Hide()
    frame:SetParent(hiddenParent)
end

local function BlizzardHidePlayer()
    if PlayerFrame and Ether.DB['HIDE']['PLAYER'] then
        PlayerFrame:UnregisterAllEvents()
        PlayerFrame:SetParent(hiddenParent)
    end
end
local function BlizzardHideTarget()
    if TargetFrame and Ether.DB['HIDE']['TARGET'] then
        TargetFrame:UnregisterAllEvents()
        TargetFrame:SetParent(hiddenParent)
    end
end
local function BlizzardHidePlayersPet()
    if PetFrame and Ether.DB['HIDE']['PLAYERSPET'] then
        PetFrame:UnregisterAllEvents()
        PetFrame:SetParent(hiddenParent)
    end
end

local function BlizzardHideCastbar()
    if CastingBarFrame and Ether.DB['HIDE']['CASTBAR'] then
        CastingBarFrame:UnregisterAllEvents()
        CastingBarFrame:SetParent(hiddenParent)
    end
end

-- Function to hide blizzard party frames
local function HideBlizzardPartyFrames()
    if Ether.DB['HIDE']['PARTY'] or Ether.DB['HIDE']['RAID'] then
        if Ether.DB['HIDE']['PARTY'] then
            UIParent:UnregisterEvent('GROUP_ROSTER_UPDATE')
            if CompactPartyFrame then
                CompactPartyFrame:UnregisterAllEvents()
            end
            if PartyFrame then
                PartyFrame:UnregisterAllEvents()
                PartyFrame:SetScript('OnShow', nil)
                for frame in PartyFrame.PartyMemberFramePool:EnumerateActive() do
                    HiddenFrame(frame)
                end
                HiddenFrame(PartyFrame)
            else
                for i = 1, 4 do
                    HiddenFrame(_G['PartyMemberFrame' .. i])
                    HiddenFrame(_G['CompactPartyMemberFrame' .. i])
                end
                HiddenFrame(PartyMemberBackground)
            end
        end
    end
end

-- Function to hide blizzard raid frames
local function HideBlizzardRaidFrames()
    if Ether.DB['HIDE']['RAID'] then
        if CompactRaidFrameContainer then
            CompactRaidFrameContainer:UnregisterAllEvents()
            hooksecurefunc(CompactRaidFrameContainer, 'Show', CompactRaidFrameContainer.Hide)
            hooksecurefunc(CompactRaidFrameContainer, 'SetShown', function(frame, shown)
                if shown then
                    frame:Hide()
                end
            end)
        end
    end
end

-- Function to hide blizzard raid frame manager
local function HideBlizzardRaidFrameManger()
    if CompactRaidFrameManager_SetSetting then
        CompactRaidFrameManager_SetSetting('IsShown', '0')
    end

    if CompactRaidFrameManager then
        CompactRaidFrameManager:UnregisterAllEvents()
        CompactRaidFrameManager:SetParent(hiddenParent)
    end
end

local function OnceGreet()
    local animation = CreateFrame('Frame', nil, UIParent)

    animation:SetSize(190, 190)
    animation:SetPoint('TOPRIGHT', 0, 0)
    animation:SetFrameStrata('DIALOG')

    animation.emblem = animation:CreateTexture(nil, 'ARTWORK')
    animation.emblem:SetAllPoints(animation)
    animation.emblem:SetTexture('Interface\\AddOns\\Ether\\Media\\Graphic\\Emblem.png')
    animation.emblem:SetVertexColor(1, 1, 1, 1)

    local animationGroup = animation:CreateAnimationGroup()

    local fadeIn = animationGroup:CreateAnimation('Alpha')
    fadeIn:SetDuration(1.5)
    fadeIn:SetFromAlpha(0)
    fadeIn:SetToAlpha(1)
    fadeIn:SetOrder(0)

    local slide = animationGroup:CreateAnimation('Translation')

    slide:SetStartDelay(0.5)
    slide:SetDuration(1.5)
    slide:SetOffset(0, 550)
    slide:SetSmoothing('IN_OUT')
    slide:SetOrder(1)

    animationGroup:SetScript('OnFinished', function()
        animation:Hide()
    end)

    animationGroup:Play()
end

local function BuildFilteredOptions()
    local filtered = {}
    for i = 1, #Ether.Data.OSelect do
        local item = Ether.Data.OSelect[i]
        if item.check and item.check() then
            table.insert(filtered, {
                name = item.name,
                value = item.value
            })
        end
    end
    Ether.Data.OSelect = filtered
    return filtered
end

local sendChannel
local function UpdateSendChannel()
    if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
        sendChannel = "INSTANCE_CHAT"
    elseif IsInRaid() then
        sendChannel = "RAID"
    else
        sendChannel = "PARTY"
    end
end

local Comm = LibStub("AceComm-3.0")
Comm:RegisterComm("ETHER_VERSION", function(prefix, message, channel, sender)
    if sender == UnitName("player") then
        return
    end

    local theirVersion = tonumber(message)
    local myVersion = tonumber(Ether.version)

    local lastCheck = Ether.DB['LASTVERSION'] or 0
    if (time() - lastCheck >= 12200) and theirVersion and myVersion and myVersion < theirVersion then
        Ether.DB['LASTVERSION'] = time()

        local msg = string.format("New version found (%d). Please visit %s to get the latest version.", theirVersion, "|cFF00CCFFhttps://www.curseforge.com/wow/addons/ether|r")

        if Ether.Console and Ether.Console.Output then
            Ether.Console:Output(msg)
        end
    end
end)

local function OnInitialize(self, event, ...)
    if (event == 'ADDON_LOADED') then
        local __STRING = ...

        assert(__STRING == 'Ether', 'Unexpected addon string: ' .. tostring(__STRING))
        assert(type(Ether.Data.Default) == 'table' and type(Ether.DB) == 'table', 'Ether data')
        assert(type(Ether.Table.MergeToLeft) == 'function' and type(Ether.Table.DeepCopy) == 'function', 'Ether table func')

        self:RegisterEvent('PLAYER_LOGIN')
        self:UnregisterEvent('ADDON_LOADED')

        if type(_G.ETHERDATABASE_DXAA) ~= 'table' then
            ETHERDATABASE_DXAA = {}
        end

        if type(ETHERDATABASE_DXAA['VERSION']) ~= 'number' then
            ETHERDATABASE_DXAA['VERSION'] = 0
        end

        local version = tonumber(Ether.version)

        assert(type(version) == 'number', 'Ether version ~= number')

        if version == ETHERDATABASE_DXAA.VERSION then
            Ether.Table:MergeToLeft(Ether.Data.Default, ETHERDATABASE_DXAA)
        else
            ETHERDATABASE_DXAA = Ether.Data.Default
            ETHERDATABASE_DXAA.VERSION = version
        end
        Ether.DB = Ether.Table:DeepCopy(Ether.Data.Default)
        assert(type(Ether.DB['HEADER']) == 'table' and type(Ether.DB['POSITION']) == 'table', 'Ether header and position')

        self:RegisterEvent('PLAYER_LOGOUT')

        if Ether.DB['HIDE']['PLAYER'] then
            BlizzardHidePlayer()
        end
        if Ether.DB['HIDE']['TARGET'] then
            BlizzardHideTarget()
        end
        if Ether.DB['HIDE']['PLAYERSPET'] then
            BlizzardHidePlayersPet()
        end
        if Ether.DB['HIDE']['CASTBAR'] then
            BlizzardHideCastbar()
        end

        if Ether.DB['HIDE']['PARTY'] then
            HideBlizzardPartyFrames()
        end
        if Ether.DB['HIDE']['RAID'] then
            HideBlizzardRaidFrames()
        end
        if Ether.DB['HIDE']['MANAGER'] then
            HideBlizzardRaidFrameManger()
        end
    elseif (event == 'PLAYER_LOGIN') then
        self:UnregisterEvent('PLAYER_LOGIN')
        BuildFrames()

        Construct.ReloadBox = Ether.Setup:CreateReloadBox()
        SLASH_ETHER1 = "/ether"
        SlashCmdList["ETHER"] = function(msg)
            local input, rest = msg:match("^(%S*)%s*(.-)$")
            input = string.lower(input or "")
            rest = string.lower(rest or "")
            if input == "settings" then
                Ether.Callback.Fire('TOGGLE_SETTINGS')
            elseif input == "rl" then
                local isShown = Ether.Settings.ReloadBox:IsShown()
                Construct.ReloadBox:SetText('Reload UI')
                Construct.ReloadBox:SetShown(not isShown)
            elseif input == "grid" then
                Ether.Callback.Fire('TOGGLE_GRID')
            elseif input == "debug" then
                Ether.Callback.Fire('DEBUG_META_POSITION')
            else
                for _, entry in ipairs(Ether.Data.SlashL) do
                    Ether.Console:Output(entry.desc)
                end
            end
        end

        if IsInGuild() then
            Comm:SendCommMessage("ETHER_VERSION", Ether.version, "GUILD", nil, "NORMAL")
        end

        if LibStub and LibStub('LibDBIcon-1.0') and Ether.Broker then
            local LDI = LibStub('LibDBIcon-1.0', true)
            LDI:Register('EtherIcon', Ether.Broker.Icon, Ether.DB['BROKER'])
            if Ether.DB['MODULES'][1] == 1 then
                LDI:Show('EtherIcon')
            else
                LDI:Hide('EtherIcon')
            end
            if Ether.DB['MODULES'][2] == 1 then
                LDI:AddButtonToCompartment('EtherIcon')
            end
            if not LibStub("LibSharedMedia-3.0") then
                return
            end
            if not dataRegistered then
              --  local LSM = LibStub("LibSharedMedia-3.0")

                dataRegistered = true
            end
        end

        if Ether.Grid and Ether.Grid.Initialize then
            Ether.Grid:Initialize()
        end

        if Ether.Console and Ether.Console.Initialize then
            Ether.Console:Initialize()
        end

        if not UnitAffectingCombat('player') then
            Ether.Units:Initialize()
            if Ether.DB['CREATE']['RAID'] then
                Ether.Units:CreateSplitHeader()
                if Ether.DB['HEADER']['RAID']['RAIDAURA'] then
                    Ether.Aura:Initialize()
                end
            end
            if Ether.DB['CREATE']['RAIDPET'] then
                Ether.Units:CreatePetHeader()
            end
            if Ether.DB['CREATE']['PARTY'] then
                Ether.Units:CreatePartyHeader()
            end

            self:RegisterEvent('GROUP_ROSTER_UPDATE')
            self:RegisterEvent('PLAYER_ENTERING_WORLD')

            RosterInitialCache()
            OnceGreet() -- Greetings Ether User
            Ether.Indicators.Enable()
        else
            self:RegisterEvent('PLAYER_REGEN_ENABLED')
            Ether.Console:Output(unitName .. ' in combat lockdown')
        end

        if Ether.DB['INDICATORS'][14] == 1 then
            Ether.Range:Initialize()
        end

        Ether.Callback.Register('UPDATE_CHECKBOX', 'GridCheckbox', function()
            if Construct and Construct.GridCheckbox then
                Construct.GridCheckbox:SetChecked(Ether.DB['GRID'])
            end
        end)

        Ether.Callback.Register('TOGGLE_SETTINGS', 'ToggleSettingsModule', function()
            if not InCombatLockdown() then
                Ether.DB['SHOW'] = not Ether.DB['SHOW']
                Construct:Toggle()
            else
                Ether.Console:Output(unitName .. ' in combat lockdown')
            end
        end)
        Ether.Callback.Fire('TOGGLE_SETTINGS')

        Ether.Callback.Register('TOGGLE_GRID', 'ToggleGridModule', function()
            if InCombatLockdown() then
                return
            end
            if Ether.Grid.frame:IsShown() then
                Ether.DB['GRID'] = false
                Ether.Callback.Fire('BG_TOGGLE')
                Ether.Callback.Fire('UPDATE_CHECKBOX')
                Ether.Grid.frame:Hide()
            else
                Ether.DB['GRID'] = true
                Ether.Callback.Fire('BG_TOGGLE')
                Ether.Callback.Fire('UPDATE_CHECKBOX')
                Ether.Grid.frame:Show()
            end
        end)

        Ether.Callback.Register('DEBUG_META_POSITION', 'DebugMetaPosi', function()
            Construct.__SETTINGS:DEBUG()
            Ether.debug = not Ether.debug
            Ether.Console:Output(Ether.debug and 'Debug On' or 'Debug Off')
        end)

        Ether.Callback.Register('LOAD_GRID', 'LoadGridModule', function()
            if InCombatLockdown() then
                return
            end
            if Ether.DB['GRID'] and Ether.Grid then
                if not Ether.Grid.frame:IsShown() then
                    Ether.Grid.frame:Show()
                    Ether.Callback.Fire('BG_TOGGLE')
                end
            end
        end)

        local fGroups = {
            PLAYER = {Ether.Units.Data.Buttons.Player},
            PLAYERSPET = {Ether.Units.Data.Buttons.PlayersPet},
            PLAYERSPETTARGET = {Ether.Units.Data.Buttons.PlayersPetTarget},
            TARGET = {Ether.Units.Data.Buttons.Target},
            TARGETTARGET = {Ether.Units.Data.Buttons.TargetTarget},
            PARTY = {Ether.Units.PartyTemplate},
            RAID = {Ether.Units.SplitHeaderTemplate},
            RAIDPET = {Ether.Units.RaidPetTemplate},
            CONSOLE = {Ether.Console.Frame},
            PLAYERCASTBAR = {Ether.Units.PlayerCastbar},
            TARGETCASTBAR = {Ether.Units.TargetCastbar}
        }

        Ether.Callback.Register('FRAME_UPDATE', 'Groups', function(frameGroup)
            local frames = fGroups[frameGroup]
            local pos = Ether.DB['POSITION'][frameGroup]
            if not frames or not pos then
                return
            end
            for _, frame in ipairs(frames) do
                if not frame then
                    return
                end
                local relTo = pos[2]
                if type(relTo) == 'string' then
                    if relTo == 'UIParent' then
                        relTo = UIParent
                    else
                        relTo = _G[relTo] or UIParent
                    end
                    frame:SetPoint(pos[1], relTo, pos[3], pos[4], pos[5])
                    frame:SetScale(pos[8])
                    frame:SetAlpha(pos[9])
                end
            end
        end)

        Ether.Callback.Register('POWER_DISPLAY_CHANGED', 'ResetLastPowerTexts', function()
            for _, frame in pairs(Ether.Units.Data.Update.Cache) do
                if frame then
                    local unit = frame:GetAttribute('unit')
                    if unit then
                        frame.Power:SetText("")
                        Ether.Update.lastPower[frame.unit] = nil
                    end
                end
            end
            for _, name in ipairs(Ether.Units.Data.Update.Cache) do
                local frame = _G[name]
                if frame and frame.Power then
                    frame.Power:SetText("")
                    Ether.Update.lastPower[frame.unit] = nil
                end
            end
        end)

        Ether.Callback.Register('CREATE_FAKE_UNIT', 'CreateFakeUnit', function()
            if UnitAffectingCombat('player') then
                Ether.Console:Output(unitName .. ' in combat lockdown')
                return
            else
                Ether.Units.CustomButtons = Ether.Units:CreateFakeUnit()
                for _, info in ipairs(Ether.Units.Data.Buttons.Fake) do
                    if info then
                        Ether.Console:Output(string.format('Fake created:\n%s\n%s', info.name, info.guid))
                        break
                    end
                end
                if Ether.Units.FakeUpdater then
                    Ether.Console:Output('Updater created')
                end
            end
        end)

        Ether.Callback.Register('DESTROY_FAKE_UNIT', 'DestroyFakeUnit', function()
            if UnitAffectingCombat('player') then
                Ether.Console:Output(unitName .. ' in combat lockdown')
                return
            else
                if Ether.Units.CustomButtons then
                    Ether.Units.CustomButtons:Hide()
                    Ether.Units.CustomButtons:UnregisterAllEvents()
                    Ether.Units.CustomButtons:RegisterForClicks()
                    Ether.Units.CustomButtons:RegisterForDrag()
                    Ether.Units.CustomButtons:SetScript('OnDragStart', nil)
                    Ether.Units.CustomButtons:SetScript('OnDragStop', nil)
                    Ether.Units.FakeUpdater = nil
                    Ether.Units.CustomButtons = nil
                    wipe(Ether.Units.Data.Buttons.Fake)
                end
            end
        end)

        if Ether.Settings and Ether.Settings.Initialize then
            Ether.Settings:Initialize()
        end

        BuildFilteredOptions()

        Ether.Callback.Fire('LOAD_GRID')
        Ether.Callback.Fire('TOGGLE_SETTINGS')
    elseif (event == 'GROUP_ROSTER_UPDATE') then
        UpdateRosterCache()
        if Ether.DB['INDICATORS'][14] == 1 then
            Ether.Range:ShouldUpdate()
        end
        if IsInGroup() and not updatedChannel then
            updatedChannel = true
            UpdateSendChannel()
            Comm:SendCommMessage("ETHER_VERSION", Ether.version, sendChannel, nil, "NORMAL")
        end
    elseif (event == 'PLAYER_ENTERING_WORLD') then
        RosterInitialCache()
    elseif (event == 'PLAYER_LOGOUT') then
        _G.ETHERDATABASE_DXAA = Ether.Table:DeepCopy(Ether.DB)
    end
end
local Initialize = CreateFrame('Frame')
Initialize:RegisterEvent('ADDON_LOADED')
Initialize:SetScript('OnEvent', OnInitialize)

