local _, Ether = ...


local anchor = CreateFrame("Frame", "EtherMaintankAnchor", UIParent, "SecureFrameTemplate")
Ether.Anchor.maintank = anchor
local header = CreateFrame("Frame", "EtherMaintankHeader", anchor, "SecureGroupHeaderTemplate")


local function MTInitial(self)
    C_Timer.After(0.1, function()
        Ether.InitialHealth(self)
        Ether.UpdateHealthAndMax(self)
        Ether.UpdateName(self)
    end)
end

local function MTAttributeChanged(self)
    self.unit = self:GetAttribute("unit")
    local guid = self.unit and UnitGUID(self.unit)
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
    if InCombatLockdown() then
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

    RegisterAttributeDriver(header, "state-visibility", "[@raid1,exists] show; hide")

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
