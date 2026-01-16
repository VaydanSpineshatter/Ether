local _, Ether = ...

local anchor = CreateFrame("Frame", "EtherRaidPetAnchor", UIParent, "SecureFrameTemplate")
Ether.Anchor.raidpet = anchor
local header = CreateFrame("Frame", "EtherRaidPetHeader", anchor, "SecureGroupPetHeaderTemplate")

local function Show(self)
    self.unit = self:GetAttribute("unit")
    self:RegisterEvent("GROUP_ROSTER_UPDATE")
    self:RegisterEvent("UNIT_PET")
    Ether.InitialHealth(self)
    Ether.UpdateHealthAndMax(self)
    Ether.UpdateName(self, true)
end

local function Hide(self)
    self:UnregisterEvent("GROUP_ROSTER_UPDATE")
    self:UnregisterEvent("UNIT_PET")
end

function Ether:CreateRaidPetHeader()

    header:SetPoint("TOPLEFT", Ether.Anchor.raidpet, "TOPLEFT")
    header:SetAttribute("template", "EtherUnitTemplate")
    header:SetAttribute("initialConfigFunction", [[
        local header = self:GetParent()
        self:SetAttribute("*type1", "target")
        self:SetAttribute("*type2", "togglemenu")
        self:SetWidth(header:GetAttribute("ButtonWidth"))
        self:SetHeight(header:GetAttribute("ButtonHeight"))
]])
    header:SetAttribute("ButtonHeight", 45)
    header:SetAttribute("ButtonWidth", 45)
    header:SetAttribute("showPlayer", true)
    header:SetAttribute("showRaid", true)
    header:SetAttribute("showParty", true)
    header:SetAttribute("point", "LEFT")
    header:SetAttribute("columnAnchorPoint", "RIGHT")
    header:SetAttribute("columnSpacing", 3)
    header:SetAttribute("xOffset", 1)
    header:SetAttribute("yOffset", -1)
    header:SetAttribute("filterOnPet", true)
    header:SetAttribute("unitsPerColumn", 10)
    header:SetAttribute("maxColumns", 1)
    header:SetAttribute("startingIndex", -9)
    header:Show()
    header:SetAttribute("startingIndex", 1)

    for i, b in ipairs(header) do
        local healthBar = CreateFrame("StatusBar", nil, b)
        b.healthBar = healthBar
        healthBar:SetPoint("TOPLEFT")
        healthBar:SetSize(45, 45)
        healthBar:SetOrientation("VERTICAL")
        healthBar:SetStatusBarTexture(unpack(Ether.mediaPath.NewBar))
        healthBar:SetMinMaxValues(0, 100)
        healthBar:SetFrameLevel(b:GetFrameLevel() + 1)
        Ether.Setup.CreateBorder(b)
        local healthDrop = b:CreateTexture(nil, "ARTWORK", nil, -7)
        b.healthDrop = healthDrop
        healthDrop:SetAllPoints(healthBar)
        healthBar:GetStatusBarTexture():SetDrawLayer("ARTWORK", -7)
        Ether.Setup.CreatePrediction(b)
        Ether.Setup.CreateNameText(b, 10, -5)
        b.healthBar:SetStatusBarColor(0.18, 0.54, 0.34)
        b.healthDrop:SetColorTexture(0.18 * 0.3, 0.54 * 0.3, 0.34 * 0.3, 0.8)
        b:RegisterForClicks("AnyUp")
        b:SetScript("OnShow", Show)
        b:SetScript("OnHide", Hide)
        b.unit = b:GetAttribute("unit")
        b:SetAttribute("unit", b.unit)
        Ether.Buttons.raidpet[i] = b.unit
    end
end

