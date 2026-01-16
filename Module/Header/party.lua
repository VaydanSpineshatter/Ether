local _, Ether = ...

local anchor = CreateFrame("Frame", "EtherPartyAnchor", UIParent, "SecureFrameTemplate")
Ether.Anchor.party = anchor
local header = CreateFrame("Frame", "EtherPartyHeader", anchor, "SecureGroupHeaderTemplate")

local C_After = C_Timer.After
local U_GUID = UnitGUID

local function Initial(self)
    C_After(0.1, function()
        Ether.InitialHealth(self)
        Ether.InitialPower(self)
    end)
    Ether.UpdateHealthAndMax(self)
    Ether.UpdateName(self)
    if Ether.DB[701][3] == 1 then
        Ether.UpdateHealthText(self)
    end
    Ether.UpdatePowerAndMax(self)
    if Ether.DB[701][4] == 1 then
        Ether.UpdatePowerText(self)
    end
end

local function Show(self)
    Initial(self)
end

local function OnAttributeChanged(self)
    local guid = self.unit and U_GUID(self.unit)
    if (guid ~= self.unitGUID) then
        self.unitGUID = guid
        if (guid) then
            Initial(self)
        end
    end
end

function Ether:CreatePartyHeader()
    if (InCombatLockdown()) then
        return
    end
    header:SetPoint("TOPLEFT", anchor, "TOPLEFT")
    header:SetAttribute("showPlayer", true)
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
    header:SetAttribute('ButtonHeight', 50)
    header:SetAttribute('ButtonWidth', 120)
    header:SetAttribute("point", "TOP")
    header:SetAttribute("columnAnchorPoint", "BOTTOM")
    header:SetAttribute("xOffset", 1)
    header:SetAttribute("yOffset", -1)
    header:SetAttribute("maxColumns", 1)
    header:SetAttribute("unitsPerColumn", 5)
    header:SetAttribute("startingIndex", -4)
    header:Show()
    header:SetAttribute("startingIndex", 1)

    for i, b in ipairs(header) do
        Ether.Setup.CreateHealthBar(b, "HORIZONTAL")
        Ether.Setup.CreatePowerBar(b)
        Ether.Setup.CreateBorder(b)
        Ether.Setup.CreatePrediction(b)
        Ether.Setup.CreateNameText(b, 10, 0)
        Ether.GetClassColor(b)
        Ether.Setup.CreatePowerText(b)
        Ether.Setup.CreateHealthText(b)
        b.unit = "party" .. i
        if i == 1 then
            b.unit = "player"
        else
            b.unit = "party" .. (i - 1)
        end
        b:SetAttribute("unit", b.unit)
        b:SetScript("OnAttributeChanged", OnAttributeChanged)
        b:SetScript("OnShow", Show)
        b:RegisterForClicks("AnyUp")
        b:SetScript("OnEnter", Ether.OnEnter)
        b:SetScript("OnLeave", Ether.OnLeave)
        Ether.InitialHealth(b)
        Ether.InitialPower(b)
        Ether.Buttons.party[b.unit] = b
    end
end