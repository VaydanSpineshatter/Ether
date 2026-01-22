local _, Ether = ...

local anchor = CreateFrame("Frame", "EtherPartyAnchor", UIParent, "SecureFrameTemplate")
Ether.Anchor.party = anchor
local header = CreateFrame("Frame", "EtherPartyHeader", anchor, "SecureGroupHeaderTemplate")

local function Initial(self)
    C_Timer.After(0.1, function()
        Ether.InitialHealth(self)
    end)
    Ether.UpdateHealthAndMax(self)
    Ether.UpdateName(self)
    if Ether.DB[701][3] == 1 then
        Ether.UpdateHealthText(self)
    end
    if Ether.DB[701][4] == 1 then
        Ether.UpdatePowerText(self)
    end
end

local function Show(self)
    Initial(self)
end

local function OnAttributeChanged(self)
    local guid = self.unit and UnitGUID(self.unit)
    if (guid ~= self.unitGUID) then
        self.unitGUID = guid
        if (guid) then
            Initial(self)
        end
    end
end

function Ether:CreatePartyHeader()
    if InCombatLockdown() then
        return
    end
    header:SetPoint("TOPLEFT", anchor, "TOPLEFT")
    header:SetAttribute("showPlayer", false)
    header:SetAttribute("showParty", true)
    header:SetAttribute("template", "EtherUnitTemplate")
    header:SetAttribute("initialConfigFunction", [[
		RegisterUnitWatch(self)
		local header = self:GetParent()
		self:SetWidth(header:GetAttribute("ButtonWidth"))
		self:SetHeight(header:GetAttribute("ButtonHeight"))
		self:SetAttribute("*type1", "target")
		self:SetAttribute("*type2", "togglemenu")
		local unit = self:GetAttribute("unit")
	]])
    header:SetAttribute("ButtonWidth", 55)
    header:SetAttribute("ButtonHeight", 55)
    header:SetAttribute("point", "LEFT")
    header:SetAttribute("columnAnchorPoint", "RIGHT")
    header:SetAttribute("xOffset", 1)
    header:SetAttribute("yOffset", -1)
    header:SetAttribute("maxColumns", 1)
    header:SetAttribute("unitsPerColumn", 4)
    header:SetAttribute("startingIndex", -3)
    header:Show()
    header:SetAttribute("startingIndex", 1)

    RegisterAttributeDriver(header, "state-visibility", "[@raid1,exists] hide;[@party1,exists] show;[group:party] show;hide")

    for i, b in ipairs(header) do
        b.Indicators = {}
        b.raidAuras = {}
        b:SetBackdrop({bgFile = "Interface\\ChatFrame\\ChatFrameBackground"})
        b:SetBackdropColor(0, 0, 0, 1)
        local healthBar = CreateFrame("StatusBar", nil, b)
        b.healthBar = healthBar
        healthBar:SetPoint("TOPLEFT")
        healthBar:SetAllPoints(b)
        healthBar:SetOrientation("VERTICAL")
        healthBar:SetStatusBarTexture(unpack(Ether.mediaPath.StatusBar))
        healthBar:SetMinMaxValues(0, 100)
        healthBar:SetFrameLevel(b:GetFrameLevel() + 1)
        local healthDrop = b:CreateTexture(nil, "ARTWORK", nil, -7)
        b.healthDrop = healthDrop
        healthDrop:SetAllPoints(healthBar)
        healthBar:GetStatusBarTexture():SetDrawLayer("ARTWORK", -7)
        Ether.AddBlackBorder(b)
        Ether.Setup.CreatePrediction(b)
        Ether.Setup.CreateNameText(b, 10, 0)
        Ether.GetClassColor(b)
        Ether.Setup.CreatePowerText(b)
        Ether.Setup.CreateHealthText(b)
        b.unit = "party" .. i
        b:SetAttribute("unit", b.unit)
        b:SetScript("OnAttributeChanged", OnAttributeChanged)
        b:SetScript("OnShow", Show)
        b:RegisterForClicks("AnyUp")
        b:SetScript("OnEnter", Ether.OnEnter)
        b:SetScript("OnLeave", Ether.OnLeave)
        Ether.unitButtons.party[b.unit] = b
    end
end