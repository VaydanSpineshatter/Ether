local _, Ether = ...

local anchor = CreateFrame("Frame", "EtherMaintankAnchor", UIParent, "SecureFrameTemplate")
Ether.Anchor.maintank = anchor
local header = CreateFrame("Frame", "EtherMaintankHeader", anchor, "SecureGroupHeaderTemplate")

local U_GUID = UnitGUID
local C_After = C_Timer.After
local C_Ticker = C_Timer.NewTicker

local function FullUpdate(self)
    C_After(0.1, function()
        Ether.InitialHealth(self)
        Ether.InitialPower(self)
    end)
    Ether.UpdateHealthAndMax(self)
    Ether.UpdateName(self)
    if Ether.DB[701][1] == 1 then
        Ether.UpdateHealthText(self)
    end
    Ether.UpdatePowerAndMax(self)
    if Ether.DB[701][2] == 1 then
        Ether.UpdatePowerText(self)
    end
end

local function AttributeChanged(self)
    local guid = self.unit and U_GUID(self.unit)
    if (guid ~= self.unitGUID) then
        self.unitGUID = guid
        if (guid) then
            FullUpdate(self)
        end
    end
end

local function Show(self)
    C_After(0.05, function()
        FullUpdate(self)
    end)
end

local function Update(self, event, unit)

    if not Ether.DB[901]["targettarget"] or self.unit ~= "targettarget" then
        return
    end
    local button = Ether.unitButtons["targettarget"]

    if event == "UNIT_HEAL_PREDICTION" then
        Ether.UpdatePrediction(button)
    elseif event == "UNIT_MAXHEALTH" or event == "UNIT_HEALTH" then
        Ether.UpdateHealthAndMax(button)
        if Ether.DB[701][1] == 1 then
            Ether.UpdateHealthText(button)
        end
    elseif event == "UNIT_POWER_UPDATE" or event == "UNIT_MAXPOWER" or event == "UNIT_DISPLAYPOWER" then
        Ether.UpdatePowerAndMax(button)
        if Ether.DB[701][2] == 1 then
            Ether.UpdatePowerText(button)
        end
    end
end

function Ether:CreateUnitButtons(unit)
    if (InCombatLockdown()) then
        return
    end
    if not Ether.unitButtons[unit] then
        local button = CreateFrame("Button", "Ether_" .. unit .. "_UnitButton", Ether.Anchor[unit], "EtherUnitTemplate")
        button:SetAllPoints(Ether.Anchor[unit])
        button.unit = unit
        button:SetAttribute("unit", button.unit)
        button:RegisterForClicks("AnyUp")
        button:SetAttribute("*type1", "target")
        button:SetAttribute("*type2", "togglemenu")
        button:SetAttribute("type2", "togglemenu")
        button.Indicators = {}
        Ether.Setup.CreateTooltip(button, button.unit)
        Ether.Setup.CreateHealthBar(button, "HORIZONTAL")
        Ether.Setup.CreatePowerBar(button)
        Ether.Setup.CreatePrediction(button)
        Ether.Setup.CreateBorder(button)
        Ether.Setup.CreateNameText(button, 10, 0)
        Ether.GetClassColor(button)
        Ether.Setup.CreatePowerText(button)
        Ether.Setup.CreateHealthText(button)
        --  button.Indicators.RaidTargetIcon = button.healthBar:CreateTexture(nil, "OVERLAY")
        --  button.Indicators.RaidTargetIcon:SetPoint('BOTTOM', -2, 1)
        --  button.Indicators.RaidTargetIcon:SetSize(11, 11)
        --  button.Indicators.RaidTargetIcon:Hide()
        Mixin(button.healthBar, SmoothStatusBarMixin)
        Mixin(button.powerBar, SmoothStatusBarMixin)

        if button.unit ~= "player" then
            RegisterUnitWatch(button)
        end

        if button.unit == "targettarget" then
            button:SetScript("OnEvent", Update)
        end

        button:SetScript("OnAttributeChanged", AttributeChanged)
        button:SetScript("OnShow", Show)
        Ether.InitialHealth(button)
        Ether.InitialPower(button)

        FullUpdate(button)

        Ether.unitButtons[button.unit] = button

        return button
    end
end

function Ether:DestroyUnitButtons(unit)
    if Ether.unitButtons[unit] then
        local button = Ether.unitButtons[unit]
        button:Hide()
        button:ClearAllPoints()
        button:SetAttribute("unit", nil)
        button:RegisterForClicks()
        if unit ~= "player" then
            UnregisterUnitWatch(button)
        end
        if unit == "targettarget" then
            button:SetScript("OnEvent", nil)
        end
        button:SetScript("OnAttributeChanged", nil)
        button:SetScript("OnShow", nil)
        Ether.unitButtons[unit] = nil
    end
end

local custom = nil
local updateTicker = nil
local enabled = false

local function updateCustom(self, token)
    local health, healthMax = UnitHealth(token), UnitHealthMax(token)
    if self.healthBar and healthMax > 0 then
        self.healthBar:SetMinMaxValues(0, healthMax)
        self.healthBar:SetValue(health)
    end
    local power, powerMax = UnitPower(token), UnitPowerMax(token)
    if self.powerBar and powerMax > 0 then
        self.powerBar:SetMinMaxValues(0, powerMax)
        self.powerBar:SetValue(power)
    end
end

local function updateFunc(self, token)
    if not updateTicker and not enabled then
        enabled = true
        updateTicker = C_Ticker(0.1, function()
            updateCustom(self, token)
        end)
    end
end

function Ether.stopUpdateFunc()
    if updateTicker and custom then
        updateTicker:Cancel()
        custom:RegisterForClicks()
        custom:RegisterForDrag()
        custom:Hide()
        custom:ClearAllPoints()
        custom:SetScript("OnDragStart", nil)
        custom:SetScript("OnDragStop", nil)
        custom:SetScript("OnEnter", nil)
        custom:SetScript("OnLeave", nil)
        custom = nil
        updateTicker = nil
        enabled = false
    end
end

local unitLink = "|cffffff00|Hunit:%s|h[%s]|h|r"


---https://warcraft.wiki.gg/wiki/API_UnitGUID
---https://warcraft.wiki.gg/wiki/API_UnitTokenFromGUID

local function ParseGUID(unit)
    local guid = UnitGUID(unit)
    local name = UnitName(unit)
    local token = UnitTokenFromGUID(guid)
    if guid and token then
        local link = unitLink:format(guid, name) -- clickable link
        local unit_type = strsplit("-", guid)
        if unit_type == "Creature" or unit_type == "Vehicle" then
            local _, _, server_id, instance_id, zone_uid, npc_id, spawn_uid = strsplit("-", guid)
            Ether.DebugOutput(format("%s is a creature with NPC ID %d", link, npc_id))
        elseif unit_type == "Player" then
            local _, server_id, player_id = strsplit("-", guid)
            Ether.DebugOutput(format("%s is a player with ID %s", link, player_id))
        end
        return name, token
    end
end

function Ether.CreateCustomUnit()
    if (InCombatLockdown()) then
        return
    end
    if not U_GUID("target") then
        Ether.DebugOutput("Error: Custom unit not created. Target your custom unit. Prioritize group or raid members.")
        enabled = false
        return
    end
    if not enabled and not custom then
        local success, msg = pcall(function()
            custom = CreateFrame("Button", "EtherCustomUnitButton", UIParent, "EtherUnitTemplate")
            custom:SetPoint("CENTER")
            custom:SetSize(120, 50)
            local name, unit = ParseGUID("target")
            if not name and not unit then
                return nil
            end
            custom.unit = unit
            custom:SetAttribute("unit", custom.unit)
            Ether.Setup.CreateTooltip(custom, custom.unit)
            Ether.Setup.CreateHealthBar(custom, "HORIZONTAL")
            Ether.Setup.CreatePowerBar(custom)
            Ether.Setup.CreateNameText(custom, 10)
            Ether.Setup.CreateBorder(custom)
            custom.name:SetText(name)
            Ether.Setup:CreateDrag(custom)
            custom.healthBar:SetStatusBarColor(0.18, 0.54, 0.34)
            custom.healthDrop:SetColorTexture(0.18 * 0.3, 0.54 * 0.3, 0.34 * 0.3, 0.8)
            local r, g, b = Ether.GetPowerColor(custom.unit)
            custom.powerBar:SetStatusBarColor(r, g, b)
            custom.powerDrop:SetColorTexture(r * 0.3, g * 0.3, b * 0.3, 0.4)
            custom.powerBar:SetStatusBarColor(r, g, b)
            custom:RegisterForClicks("AnyUp")
            custom:SetAttribute("*type1", "target")
            custom:SetAttribute("*type2", "togglemenu")
            custom:SetAttribute("type2", "togglemenu")

        end)
        if not success then
            Ether.DebugOutput("Custom unit creation failed - ", msg)
            Ether.stopUpdateFunc()
        else
            if not updateTicker then
                updateFunc(custom, custom.unit)
                enabled = true
            end
        end
    end
end

function Ether:PetCondition(button)
    if (InCombatLockdown()) then
        return
    end
    local _, classFileName = UnitClass("player")
    if classFileName ~= "HUNTER" then
        return
    end
    if (not button.healthBar) then
        return
    end
    local condition = CreateFrame("Frame", "nil", button)

    condition:SetSize(16, 16)
    condition:SetPoint("BOTTOMRIGHT", button.healthBar, "BOTTOMRIGHT", 0, 0)

    condition.happy = condition:CreateTexture(nil, "OVERLAY")
    condition.happy:SetTexture("Interface\\PetPaperDollFrame\\UI-PetHappiness")
    condition.happy:SetAllPoints(condition)

    condition.happy:SetScript("OnEnter", function()
        if not UnitExists("pet") then
            return
        end
        local happiness, damagePercentage, loyaltyRate = GetPetHappiness()
        local petType = UnitCreatureFamily("pet")
        GameTooltip:SetOwner(condition, "ANCHOR_RIGHT")
        GameTooltip:SetText("Condition:")
        GameTooltip:AddLine("Family: " .. petType)
        GameTooltip:AddLine("Happiness: " .. ({ "Unhappy", "Content", "Happy" })[happiness])
        GameTooltip:AddLine("Loyalty: " .. (loyaltyRate or "N/A"))
        GameTooltip:AddLine("Pet is doing " .. damagePercentage .. "% damage")
        GameTooltip:Show()
    end)
    condition.happy:SetScript("OnLeave", GameTooltip_Hide)

    local PET_CORDS = {
        [1] = { 0.375, 0.5625, 0, 0.359375 },
        [2] = { 0.1875, 0.375, 0, 0.359375 },
        [3] = { 0, 0.1875, 0, 0.359375 },
    }

    local function PetStatus()
        local happiness = GetPetHappiness()
        if (happiness) then
            condition.happy:SetTexCoord(unpack(PET_CORDS[happiness]))
        end
    end

    local function OnPetEvent(_, event, unit)
        if event == "UNIT_POWER_UPDATE" and unit == "pet" then
            local happiness = UnitPower("pet", Enum.PowerType.Happiness)
            if happiness then
                PetStatus()
            end

        elseif (event == "UNIT_PET") then
            Ether.UpdateName(button)
        end
    end
    local petEvent = CreateFrame('Frame')
    PetStatus()
    petEvent:RegisterUnitEvent("UNIT_POWER_UPDATE", "pet")
    petEvent:RegisterUnitEvent("UNIT_PET", "player")
    petEvent:SetScript("OnEvent", OnPetEvent)
end

local function MTInitial(self)
    C_After(0.1, function()
        Ether.InitialHealth(self)
        Ether.UpdateHealthAndMax(self)
        Ether.UpdateName(self)
    end)
end

local function MTAttributeChanged(self)
    self.unit = self:GetAttribute("unit")
    local guid = self.unit and U_GUID(self.unit)
    if (guid ~= self.unitGUID) then
        self.unitGUID = guid
        if (guid) then
            MTInitial(self)
        end
    end
end
local function MTShow(self)
    self.unit = self:GetAttribute("unit")
    MTInitial(self)
end

function Ether:CreateMainTankHeader()
    if (InCombatLockdown()) then
        return
    end
    header:SetPoint("TOPLEFT", anchor, "TOPLEFT")
    header:SetAttribute("template", "EtherUnitTemplate")
    header:SetAttribute("point", "LEFT")
    header:SetAttribute("columnAnchorPoint", "LEFT")
    header:SetAttribute("roleFilter", "MAINTANK")
    header:SetAttribute("showRaid", true)
    header:SetAttribute("strictFiltering", true)
    header:SetAttribute("ButtonHeight", 35)
    header:SetAttribute("ButtonWidth", 95)
    header:SetAttribute("xOffset", 1)
    header:SetAttribute("yOffset", -1)
    header:SetAttribute("columnSpacing", 2)
    header:SetAttribute("initialConfigFunction", [[
    RegisterUnitWatch(self)
   local header = self:GetParent()
   self:SetWidth(header:GetAttribute("ButtonWidth"))
   self:SetHeight(header:GetAttribute("ButtonHeight"))
   self:SetAttribute("*type1", "target")
   self:SetAttribute("*type2", "togglemenu")

   	local unit = self:GetAttribute("unit")
]])

    header:SetAttribute("unitsPerColumn", 4)
    header:SetAttribute("maxColumns", 1)
    header:SetAttribute("startingIndex", -3)
    header:Show()
    header:SetAttribute("startingIndex", 1)

    for i, b in ipairs(header) do
        local unit = "raid" .. i
        b.unit = unit
        b:SetAttribute("unit", b.unit)
        local healthBar = CreateFrame("StatusBar", nil, b)
        b.healthBar = healthBar
        healthBar:SetPoint("TOPLEFT")
        healthBar:SetSize(95, 35)
        healthBar:SetOrientation("HORIZONTAL")
        healthBar:SetStatusBarTexture(unpack(Ether.mediaPath.NewBar))
        healthBar:SetMinMaxValues(0, 100)
        healthBar:SetFrameLevel(b:GetFrameLevel() + 1)
        local healthDrop = b:CreateTexture(nil, "ARTWORK", nil, -7)
        b.healthDrop = healthDrop
        healthDrop:SetAllPoints(healthBar)
        healthBar:GetStatusBarTexture():SetDrawLayer("ARTWORK", -7)
        Ether.Setup.CreatePrediction(b)
        Ether.Setup.CreateBorder(b)
        Ether.Setup.CreateNameText(b, 10, 0)
        Ether.GetClassColor(b)
        b:SetAttribute("unit", b.unit)
        b:RegisterForClicks("AnyUp")
        b:SetScript("OnShow", MTShow)
        b:HookScript("OnAttributeChanged", MTAttributeChanged)
        b:SetScript("OnEnter", Ether.OnEnter)
        b:SetScript("OnLeave", Ether.OnLeave)
        Ether.Buttons.maintank[b.unit] = b
    end
end

