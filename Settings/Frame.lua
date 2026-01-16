local _, Ether = ...
local tinsert = table.insert
local playerName = UnitName("player")
local string_format = string.format
local pairs, ipairs = pairs, ipairs
local math_min = math.min
local math_max = math.max

local function GetFont(_, target, tex, numb)
    target.label = target:CreateFontString(nil, "OVERLAY")
    target.label:SetFont(unpack(Ether.mediaPath.Font), numb, "OUTLINE")
    target.label:SetText(tex)
    return target.label
end

local function NotShow(tbl)
    if Ether.DB[tbl] == true then
        Ether.DB[tbl] = false
    else
        Ether.DB[tbl] = true
    end
end

local function IsInBattleground()
    local status, instanceType = IsInInstance()
    return instanceType == "pvp" or instanceType == "arena"
end

local function CreateMenuButton(parent, point, anchor, relative, setX, setY, size, callback)
    local obj = CreateFrame("Button", nil, parent, "GameMenuButtonTemplate")
    obj:SetPoint(point, anchor, relative, setX, setY)
    obj:SetSize(size, size)
    if callback then
        obj:SetScript("OnClick", callback)
    end
    return obj
end

local function InfoSection(self)
    local parent = self.Content.Children["Info"]
    local modulesValue = {
        [1] = { name = "Icon" },
        [2] = { name = "Grid" }
    }

    local mod = CreateFrame("Frame", nil, parent)
    mod:SetSize(200, (#modulesValue * 30) + 60)

    for i, opt in ipairs(modulesValue) do
        local btn = CreateFrame('CheckButton', nil, mod, 'OptionsBaseCheckButtonTemplate')

        if i == 1 then
            btn:SetPoint("TOPLEFT", parent, 20, -20)
        else
            btn:SetPoint("TOPLEFT", self.Content.Buttons.General.A[i - 1], "BOTTOMLEFT", 0, 0)
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
                if not Ether.gridFrame then
                    Ether.Setup:CreateGrid()
                end
                if Ether.DB[401][2] == 1 then
                    Ether.gridFrame:SetShown(true)
                else
                    Ether.gridFrame:SetShown(false)
                end
            end
        end)

        self.Content.Buttons.General.A[i] = btn
    end


    local Reset = GetFont(self, parent, "Reset", 13)
    Reset:SetPoint("TOPLEFT", self.Content.Buttons.General.A[2], "BOTTOMLEFT", 0, -40)


    local btnReset = CreateMenuButton(parent, "TOP", Reset, "BOTTOM", 0, -5, 24,
            function()
                StaticPopup_Show("ETHER_RESET_DATABASED")
            end)

    self.GridCheckbox = self.Content.Buttons.General.A[2]
end

StaticPopupDialogs["ETHER_RESET_DATABASED"] = {
    text = "Reset Ether database?",
    button1 = "Reset",
    button2 = "Cancel",
	OnAccept = function()
        if not InCombatLockdown() then
            Ether.DB["VERSION"] = 123456
            ReloadUI()
        end
 	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
}


local function SlashSection(self)

    local slash = GetFont(self, self.Content.Children["Slash"], "|cffffff00Slash Commands|r", 15)
    slash:SetPoint("TOP", 0, -20)

    local lastY = -20
    for _, entry in ipairs(Ether.SlashInfo) do
        local fs = GetFont(self, self.Content.Children["Slash"], string_format("%s  –  %s", entry.cmd, entry.desc), 12)
        fs:SetPoint("TOP", slash, "BOTTOM", 0, lastY)
        lastY = lastY - 18
    end
end

local function HideSection(self)
    local parent = self.Content.Children["Hide"]
    local HideValue = {
        [1] = { name = "Blizzard Player frame" },
        [2] = { name = "Blizzard Pet frame" },
        [3] = { name = "Blizzard Target frame" },
        [4] = { name = "Blizzard Focus frame" },
        [5] = { name = "Blizzard CastBar" },
        [6] = { name = "Blizzard Party" },
        [7] = { name = "Blizzard Raid" },
        [8] = { name = "Blizzard Raid Manager" }
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

local function FactorySection(self)
    local parent = self.Content.Children["Factory"]
    local CreateUnits = {
        [1] = { name = "|cffCC66FFPlayer|r", value = "PLAYER" },
        [2] = { name = "|cE600CCFFTarget|r", value = "TARGET" },
        [3] = { name = "Target of Target", value = "TARGETTARGET" },
        [4] = { name = "|cffCC66FFPlayer's Pet|r", value = "PET" },
        [5] = { name = "|cffCC66FFPlayers Pet Target|r", value = "PETTARGET" },
        [6] = { name = "|cff3399FFFocus|r", value = "FOCUS" },
        [7] = { name = "Party", value = "PARTY" },
        [8] = { name = "Raid", value = "RAID" },
        [9] = { name = "RaidPet", value = "RAIDPET" },
        [10] = { name = "MainTank", value = "MAINTANK" }
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
                if Ether.DB[201][8] == 0 then
                    Ether.Anchor.raid:SetShown(false)
                elseif Ether.DB[201][8] == 1 then
                    Ether.Anchor.raid:SetShown(true)
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

local function UpdateSection(self)

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
        [9] = { text = "Raid Pets", value = "raidpet" },
        [10] = { text = "Main Tanks", value = "maintank" }
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

        btn:SetChecked(Ether.DB[801][opt.value])

        btn:SetScript("OnClick", function(self)
            local checked = self:GetChecked()
            Ether.DB[801][opt.value] = checked
        end)
        self.Content.Buttons.Update.C[i] = btn
    end
end

local function AuraSettingsSection(self)
    local parent = self.Content.Children["Aura Settings"]

    local AurasBuff = {
        [1] = { text = "Power Word: Fortitude: Rank 6", value = 10938 },
        [2] = { text = "Prayer of Fortitude: Rank 2", value = 21564 },
        [3] = { text = "Divine Spirit: Rank 4", value = 27841 },
        [4] = { text = "Prayer of Spirit: Rank 1", value = 27681 },
        [5] = { text = "Shadow Protection: Rank 3", value = 10958 },
        [6] = { text = "Prayer of Shadow Protection: Rank 1", value = 27683 },
        [7] = { text = "Renew: Rank 10", value = 25315 },
        [8] = { text = "Power Word Shield: Rank 3", value = 10901 },
        [9] = { text = "Fear Ward", value = 6346 },
        [10] = { text = "Arcane Intellect: Rank 5", value = 10157 },
        [11] = { text = "Arcane Brilliance: Rank 1", value = 23028 },
        [12] = { text = "Mark of the Wild: Rank 7", value = 9885 },
        [13] = { text = "Gift of the Wild: Rank 2", value = 21850 },
    }

    local AurasDebuff = {
        [1] = { text = "Weakened Soul", value = 6788 }
    }

    local CreateAura = {
        [1] = { text = "Player Aura" },
        [2] = { text = "Target Aura" },
        [3] = { text = "Raid Aura" }
    }

    local CreateAuras = GetFont(self, parent, "|cffffff00Create Aura|r", 15)
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

    local buff = GetFont(self, parent, "|cffffff00Update Aura (Buff)|r", 15)
    buff:SetPoint("TOP", 40, -10)

    local auraToggle = CreateFrame("Frame", nil, parent)
    auraToggle:SetSize(200, (#AurasBuff * 30) + 60)

    for i, opt in ipairs(AurasBuff) do
        local btn = CreateFrame("CheckButton", nil, auraToggle, "InterfaceOptionsCheckButtonTemplate")
        if i == 1 then
            btn:SetPoint("TOPLEFT", buff, "BOTTOMLEFT", 0, -20)
        else
            btn:SetPoint("TOPLEFT", self.Content.Buttons.Auras.B[i - 1], "BOTTOMLEFT", 0, 0)
        end

        btn:SetSize(24, 24)

        btn.label = GetFont(self, btn, opt.text, 12)
        btn.label:SetPoint("LEFT", btn, "RIGHT", 10, 0)

        btn:SetChecked(Ether.DB[1001][1101][opt.value])

        btn:SetScript("OnClick", function(self)
            local checked = self:GetChecked()
            Ether.DB[1001][1101][opt.value] = checked
        end)
        self.Content.Buttons.Auras.B[i] = btn
    end

    local debuff = GetFont(self, parent, "|cffffff00Update Aura (Debuff)|r", 15)
    debuff:SetPoint("TOPLEFT", self.Content.Buttons.Auras.B[13], "BOTTOMLEFT", 0, -20)

    local debuffT = CreateFrame("Frame", nil, self.Content.Children['Auras'])
    debuffT:SetSize(200, (#AurasDebuff * 30) + 60)

    for i, opt in ipairs(AurasDebuff) do
        local btn = CreateFrame("CheckButton", nil, auraToggle, "InterfaceOptionsCheckButtonTemplate")

        if i == 1 then
            btn:SetPoint("TOPLEFT", debuff, "BOTTOMLEFT", 0, -20)
        else
            btn:SetPoint("TOPLEFT", self.Content.Buttons.Auras.C[i - 1], "BOTTOMLEFT", 0, 0)
        end

        btn:SetSize(24, 24)

        btn.label = GetFont(self, btn, opt.text, 12)
        btn.label:SetPoint("LEFT", btn, "RIGHT", 10, 0)

        btn:SetChecked(Ether.DB[1001][1202][opt.value])

        btn:SetScript("OnClick", function(self)
            local checked = self:GetChecked()
            Ether.DB[1001][1202][opt.value] = checked
        end)
        self.Content.Buttons.Auras.C[i] = btn
    end
end

local function AuraCustomSection(self)
    local parent = self.Content.Children["Aura Custom"]
end

local function AuraInfoSection(self)
    local parent = self.Content.Children["Aura Info"]

    local AuraInfo = {
        [1] = { Id = 10938, name = "Power Word: Fortitude: Rank 6", color = "|cffCC66FFEther Pink|r" },
        [2] = { Id = 21564, name = "Prayer of Fortitude: Rank 2", color = "|cffCC66FFEther Pink|r" },
        [3] = { Id = 27841, name = "Divine Spirit: Rank 4", color = "|cff00ffffCyan|r" },
        [4] = { Id = 27681, name = "Prayer of Spirit: Rank 1", color = "|cff00ffffCyan|r" },
        [5] = { Id = 10958, name = "Shadow Protection: Rank 3", color = "Black" },
        [6] = { Id = 27683, name = "Prayer of Shadow Protection: Rank 1", color = "Black" },
        [7] = { Id = 10157, name = "Arcane Intellect: Rank 5", color = "|cE600CCFFEther Blue|r" },
        [8] = { Id = 23028, name = "Arcane Brilliance: Rank 1", color = "|cE600CCFFEther Blue|r" },
        [9] = { Id = 9885, name = "Mark of the Wild: Rank 7", color = "|cffffa500Orange|r" },
        [10] = { Id = 21850, name = "Gift of the Wild: Rank 2", color = "|cffffa500Orange|r" },
        [11] = { Id = 25315, name = "Renew: Rank 10", color = "|cff00ff00Green|r" },
        [12] = { Id = 10901, name = "Power Word Shield: Rank 3", color = "White" },
        [13] = { Id = 6788, name = "Weakened Soul", color = "|cffff0000Red|r" },
        [14] = { Id = 6346, name = "Fear Ward", color = "|cffffd700Gold|r" },
        [15] = { Id = 0, name = "Dynamic depending on class and skills" },
        [16] = { Id = 0, name = "Magic: Border color: |cff3399FFAzure blue|r" },
        [17] = { Id = 0, name = "Disease: Border color |cff996600Rust brown|r" },
        [18] = { Id = 0, name = "Curse: Border color |cff9900FFViolet|r" },
        [19] = { Id = 0, name = "Poison: Border color |cff009900Grass green|r" }
    }

    for _, data in ipairs(AuraInfo) do
        if data.Id == 0 then
            tinsert(self.Auras.Colors, data)
        else
            tinsert(self.Auras.Spells, data)
        end
    end

    local SpellLabel = GetFont(self, parent, "|cffffff00Spells|r", 15)
    SpellLabel:SetPoint("TOP", 0, -10)

    local yOff = -10

    for _, data in ipairs(self.Auras.Spells) do
        local spellText = GetFont(self, parent, string_format("Spell: %s | ID: %d | Color: %s", data.name, data.Id, data.color or "None"), 12)
        spellText:SetPoint("TOP", SpellLabel, "BOTTOM", 20, yOff)
        yOff = yOff - 18
    end

    if #self.Auras.Colors > 0 then
        local AuraLabel = GetFont(self, parent, "|cffffff00Aura Border Colors|r", 15)
        AuraLabel:SetPoint("TOP", parent, "BOTTOM", 0, yOff - 30)
        yOff = yOff - 60
        for _, data in ipairs(self.Auras.Colors) do
            local colorText = GetFont(self, parent, data.name, 12)
            colorText:SetPoint("TOP", parent, "BOTTOM", 0, yOff)
            yOff = yOff - 18
        end
    end
end

local function RegisterSection(self)
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

local function LayoutSection(self)
    local parent = self.Content.Children["Layout"]

    local layoutValue = {
        [1] = { text = "Create/Delete Player CastBar", value = "PLAYER_BAR" },
        [2] = { text = "Create/Delete Target CastBar", value = "TARGET_BAR" },
        [3] = { text = "Show Highlight", value = "HIGHLIGHT" },
        [4] = { text = "Enable raid headers during solo/party mode", value = "LAYOUT_SOLO" },
        [5] = { text = "Layout 8 groups", value = "LAYOUT_BG" },
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

        local Refresh = GetFont(self, parent, "Refresh Header", 13)
        Refresh:SetPoint("TOPLEFT", self.Content.Buttons.Layout.B[4], "BOTTOMLEFT", 0, -40)

        local btnRefresh = CreateMenuButton(parent, "TOP", Refresh, "BOTTOM", 0, -5, 24,
                function()
                    Ether.RefreshEtherRaidHeader()
                end)

        self.Content.Buttons.Layout.B[i] = btn
    end
end

local function RangeSection(self)
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

local function TooltipSection(self)
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
            if i == 1 then
                if not self.ReloadBox then
                    self.ReloadBox = Ether.Setup:CreateBox()
                end
                local isShown = self.ReloadBox:IsShown()
                self.ReloadBox:SetText("|cffff0000Reload Interface|r")
                self.ReloadBox:SetShown(not isShown)
            end
        end)

        self.Content.Buttons.Layout.D[i] = btn
    end
end

local function ConfigSection(self)
    local parent = self.Content.Children["Config"]
    local DB = Ether.DB

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

    --- Font
    local Config = GetFont(self, parent, "|cffffff00Select frame:", 13)
    Config:SetPoint("TOPLEFT", 10, -10)

    local optionPoint = GetFont(self, parent, "Point", 13)
    optionPoint:SetPoint("TOPLEFT", Config, "BOTTOMLEFT", 30, -80)

    local optionRelative = GetFont(self, parent, "Relative point", 13)
    optionRelative:SetPoint("LEFT", optionPoint, "RIGHT", 200, 0)

    local optionX = GetFont(self, parent, "X Offset", 13)
    optionX:SetPoint("TOPLEFT", optionPoint, "BOTTOMLEFT", 30, -100)

    local optionY = GetFont(self, parent, "Y Offset", 13)
    optionY:SetPoint("LEFT", optionX, "RIGHT", 200, 0)

    local optionScale = GetFont(self, parent, "Scale", 13)
    optionScale:SetPoint("TOPLEFT", optionX, 'BOTTOMLEFT', 0, -50)

    local optionAlpha = GetFont(self, parent, "Alpha", 13)
    optionAlpha:SetPoint("LEFT", optionScale, "RIGHT", 220, 0)

    --- UIDropDownMenuTemplate

    local selectedFrame = CreateFrame("Frame", nil, parent, "UIDropDownMenuTemplate")
    selectedFrame:SetPoint("TOPLEFT", Config, "BOTTOMLEFT", 0, -10)
    UIDropDownMenu_SetWidth(selectedFrame, 100)
    UIDropDownMenu_JustifyText(selectedFrame, "CENTER")

    local selectedPoint = CreateFrame("Frame", nil, parent, "UIDropDownMenuTemplate")
    selectedPoint:SetPoint("TOPLEFT", optionPoint, "BOTTOMLEFT", 0, -10)
    UIDropDownMenu_SetWidth(selectedPoint, 80)
    UIDropDownMenu_JustifyText(selectedPoint, "CENTER")

    local selectedRelative = CreateFrame("Frame", nil, parent, "UIDropDownMenuTemplate")
    selectedRelative:SetPoint("TOPLEFT", optionRelative, "BOTTOMLEFT", 0, -10)
    UIDropDownMenu_SetWidth(selectedRelative, 80)
    UIDropDownMenu_JustifyText(selectedRelative, "CENTER")

    --- OptionsSliderTemplate

    local sliderRight = CreateFrame("Slider", nil, parent, "UISliderTemplateWithLabels, BackDropTemplate")
    sliderRight:SetBackdrop(backDrop)
    sliderRight:SetPoint("TOPLEFT", optionX, "BOTTOMLEFT", 0, -10)
    sliderRight:SetObeyStepOnDrag(true)
    sliderRight:SetSize(180, 20)
    sliderRight:SetMinMaxValues(-800, 800)
    sliderRight:SetValueStep(1)
    sliderRight:SetValue(DB[5111][DB["SELECTED"]][4])
    sliderRight:SetScript("OnValueChanged", function(slider, value)
        slider.Text:SetText(string_format("%.0f", value))
        local frame = DB["SELECTED"]
        DB[5111][frame][4] = slider:GetValue()
        Ether.Fire("FRAME_UPDATE", frame)
    end)

    local sliderLeft = CreateFrame("Slider", nil, parent, "UISliderTemplateWithLabels, BackDropTemplate")
    sliderLeft:SetBackdrop(backDrop)
    sliderLeft:SetPoint("TOPLEFT", optionY, "BOTTOMLEFT", 0, -10)
    sliderLeft:SetObeyStepOnDrag(true)
    sliderLeft:SetSize(180, 20)
    sliderLeft:SetMinMaxValues(-800, 800)
    sliderLeft:SetValueStep(1)
    sliderLeft:SetValue(DB[5111][DB["SELECTED"]][5])
    sliderLeft:SetScript("OnValueChanged", function(slider, value)
        slider.Text:SetText(string_format("%.0f", value))
        local frame = DB["SELECTED"]
        DB[5111][frame][5] = slider:GetValue()
        Ether.Fire("FRAME_UPDATE", frame)
    end)

    local sliderScale = CreateFrame("Slider", nil, parent, "UISliderTemplateWithLabels, BackDropTemplate")
    sliderScale:SetBackdrop(backDrop)
    sliderScale:SetPoint("TOPLEFT", optionScale, "BOTTOMLEFT", 0, -10)
    sliderScale:SetObeyStepOnDrag(true)
    sliderScale:SetSize(180, 20)
    sliderScale:SetMinMaxValues(0.5, 2)
    sliderScale:SetValueStep(0.1)
    sliderScale:SetValue(DB[5111][DB["SELECTED"]][8])
    sliderScale:SetScript("OnValueChanged", function(slider, value)
        slider.Text:SetText(string_format("%.0f%%", value * 100))
        local frame = DB["SELECTED"]
        DB[5111][frame][8] = slider:GetValue()
        Ether.Fire("FRAME_UPDATE", frame)
    end)

    local sliderAlpha = CreateFrame("Slider", nil, parent, "UISliderTemplateWithLabels, BackDropTemplate")
    sliderAlpha:SetBackdrop(backDrop)
    sliderAlpha:SetPoint("TOPLEFT", optionAlpha, "BOTTOMLEFT", 0, -10)
    sliderAlpha:SetObeyStepOnDrag(true)
    sliderAlpha:SetSize(180, 20)
    sliderAlpha:SetMinMaxValues(0.1, 1)
    sliderAlpha:SetValueStep(0.05)
    sliderAlpha:SetValue(DB[5111][DB["SELECTED"]][9])
    sliderAlpha:SetScript('OnValueChanged', function(slider, value)
        slider.Text:SetText(string_format("%.0f%%", value * 100))
        local frame = DB["SELECTED"]
        DB[5111][frame][9] = slider:GetValue()
        Ether.Fire("FRAME_UPDATE", frame)
    end)

    local function UpdateValue()
        local SELECTED = DB["SELECTED"]
        if not SELECTED then
            return
        end

        local pos = DB[5111][SELECTED]
        if not pos then
            return
        end
        UIDropDownMenu_SetText(selectedPoint, pos[1] or "TOP")
        UIDropDownMenu_SetText(selectedRelative, pos[3] or "TOP")
        if sliderRight:GetValue() ~= (pos[4] or 0) then
            sliderRight:SetValue(pos[4] or 0)
        end
        if sliderLeft:GetValue() ~= (pos[5] or 0) then
            sliderLeft:SetValue(pos[5] or 0)
        end
        if sliderScale:GetValue() ~= (pos[8] or 1) then
            sliderScale:SetValue(pos[8] or 1)
        end
        if sliderAlpha:GetValue() ~= (pos[9] or 1) then
            sliderAlpha:SetValue(pos[9] or 1)
        end
    end

    local frameGroups = {
        [301] = { Ether.Anchor.tooltip },
        [331] = { Ether.Anchor.player },
        [332] = { Ether.Anchor.target },
        [333] = { Ether.Anchor.targettarget },
        [334] = { Ether.Anchor.pet },
        [335] = { Ether.Anchor.pettarget },
        [336] = { Ether.Anchor.focus },
        [337] = { Ether.Anchor.party },
        [338] = { Ether.Anchor.raid },
        [339] = { Ether.Anchor.raidpet },
        [340] = { Ether.Anchor.maintank },
        [341] = { Ether.DebugFrame }

    }

    local tablePoint = {
        { name = "RIGHT", value = "RIGHT" },
        { name = "TOPRIGHT", value = "TOPRIGHT" },
        { name = "BOTTOMLEFT", value = "BOTTOMLEFT" },
        { name = "BOTTOMRIGHT", value = "BOTTOMRIGHT" },
        { name = "BOTTOM", value = "BOTTOM" },
        { name = "TOP", value = "TOP" },
        { name = "LEFT", value = "LEFT" },
        { name = "TOPLEFT", value = "TOPLEFT" },
        { name = "CENTER", value = "CENTER" }
    }

    local tableFrames = {
        [1] = { name = "Tooltip", value = 301 },
        [2] = { name = "Player", value = 331 },
        [3] = { name = "Target", value = 332 },
        [4] = { name = "TargetTarget", value = 333 },
        [5] = { name = "Pet", value = 334 },
        [6] = { name = "Pet Target", value = 335 },
        [7] = { name = "Focus", value = 336 },
        [8] = { name = "Party", value = 337 },
        [9] = { name = "Raid", value = 338 },
        [10] = { name = "Raid Pet", value = 339 },
        [11] = { name = "Main Tank", value = 340 },
        [12] = { name = "Debug", value = 341 },
    }

    --- UIDropDownMenu

    UIDropDownMenu_Initialize(selectedFrame, function()
        for _, option in ipairs(tableFrames) do
            local frameKey = option.value
            local framesList = frameGroups[frameKey]

            if framesList then
                local info = UIDropDownMenu_CreateInfo()
                info.text = option.name
                info.value = option.value
                info.func = function()
                    local frame = DB["SELECTED"]
                    Ether.DB["SELECTED"] = option.value
                    UIDropDownMenu_SetSelectedValue(selectedFrame, option.value)
                    UIDropDownMenu_SetText(selectedFrame, option.name)
                    UpdateValue()
                    Ether.Fire("FRAME_UPDATE", frame)
                end
                UIDropDownMenu_AddButton(info)
            end
        end
    end)

    UIDropDownMenu_Initialize(selectedPoint, function()
        for _, point in pairs(tablePoint) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = point.name
            info.value = point.value
            info.func = function()
                local currentFrame = DB["SELECTED"]
                if currentFrame and DB[5111] and DB[5111][currentFrame] then
                    DB[5111][currentFrame][1] = point.value
                    UIDropDownMenu_SetText(selectedPoint, point.name)
                    Ether.Fire("FRAME_UPDATE", currentFrame)
                    UpdateValue()
                end
            end
            UIDropDownMenu_AddButton(info)
        end
    end)

    UIDropDownMenu_Initialize(selectedRelative, function()
        for _, relative in pairs(tablePoint) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = relative.name
            info.value = relative.value
            info.func = function()
                local currentFrame = DB["SELECTED"]
                if currentFrame and DB[5111] and DB[5111][currentFrame] then
                    DB[5111][currentFrame][3] = relative.value
                    UIDropDownMenu_SetText(selectedPoint, relative.name)
                    Ether.Fire("FRAME_UPDATE", currentFrame)
                    UpdateValue()
                end
            end
            UIDropDownMenu_AddButton(info)
        end
    end)

    Ether.RegisterCallback("FRAME_UPDATE", "FrameGroups", function(frameGroup)
        if not frameGroup or not DB[5111][frameGroup] then
            return
        end

        local frameInfo = frameGroups[frameGroup]
        if not frameInfo then
            return
        end

        local pos = DB[5111][frameGroup]

        pos[1] = pos[1] or "CENTER"
        pos[2] = pos[2] or 5133
        pos[3] = pos[3] or "CENTER"
        pos[4] = pos[4] and math.floor(pos[4] + 0.5) or 0
        pos[5] = pos[5] and math.floor(pos[5] + 0.5) or 0
        pos[6] = pos[6] or 100
        pos[7] = pos[7] or 100
        pos[8] = pos[8] or 1
        pos[9] = pos[9] or 1

        local relTo
        if pos[2] == 5133 then
            relTo = UIParent
        else
            relTo = _G[pos[2]]
            if not relTo or not relTo.GetCenter then
                relTo = UIParent
            end
        end

        for _, frame in ipairs(frameInfo) do
            if frame and frame.SetPoint then
                frame:ClearAllPoints()
                frame:SetPoint(pos[1], relTo, pos[3], pos[4], pos[5])
                frame:SetSize(pos[6], pos[7])
                frame:SetScale(pos[8])
                frame:SetAlpha(pos[9])
            end
        end
    end)

    local function SetInitialValue()
        local currentFrame = Ether.DB["SELECTED"]
        if not currentFrame then
            UIDropDownMenu_SetText(selectedFrame, "Choose frame...")
            return
        end

        for _, option in ipairs(tableFrames) do
            if option.value == currentFrame then
                UIDropDownMenu_SetSelectedValue(selectedFrame, option.value)
                UIDropDownMenu_SetText(selectedFrame, option.name)
                UpdateValue()
                break
            end
        end
    end

    SetInitialValue()
end

local function ProfileSection(self)
    local parent = self.Content.Children["Profile"]
end

local function CreateMainSettings(self)
    if self.IsCreated then
        return
    end
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
        Ether.DB["SHOW"] = false
    end)
    tinsert(UISpecialFrames, self.Frames["Main"]:GetName())
    RegisterAttributeDriver(self.Frames["Main"], "state-visibility", "[combat]hide")

    self.X = CreateFrame("Button", nil, self.Frames["Main"], "UIPanelCloseButton")
    self.X:SetPoint("TOPRIGHT", -5, -5)
    self.X:SetSize(32, 32)
    self.X:SetScript("OnClick", function()
        Ether.DB["SHOW"] = false
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
    menuIcon:SetSize(24, 24)
    menuIcon:SetTexture("Interface\\AddOns\\Ether\\Media\\Graphic\\Icon")
    menuIcon:SetPoint("BOTTOMLEFT")

    local name = self.Frames["Bottom"]:CreateFontString(nil, "OVERLAY")
    name:SetFont(unpack(Ether.mediaPath.Font), 15, "OUTLINE")
    name:SetPoint("LEFT", menuIcon, "RIGHT", 7, 0)
    name:SetText("|cffcc66ffEther|r")

    self.IsCreated = true

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
        for _, child in pairs(self.Content.Children) do
            child:Hide()
        end
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

Ether.NotShow = NotShow
Ether.GetFont = GetFont
Ether.InfoSection = InfoSection
Ether.SlashSection = SlashSection
Ether.HideSection = HideSection
Ether.FactorySection = FactorySection
Ether.UpdateSection = UpdateSection
Ether.AuraSettingsSection = AuraSettingsSection
Ether.AuraCustomSection = AuraCustomSection
Ether.AuraInfoSection = AuraInfoSection
Ether.RegisterSection = RegisterSection
Ether.LayoutSection = LayoutSection
Ether.RangeSection = RangeSection
Ether.ProfileSection = ProfileSection
Ether.TooltipSection = TooltipSection
Ether.ConfigSection = ConfigSection
Ether.CreateMainSettings = CreateMainSettings
Ether.CreateSettingsButtons = CreateSettingsButtons
Ether.CreateSettingsScrollTab = CreateSettingsScrollTab
