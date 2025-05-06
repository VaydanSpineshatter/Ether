local _, addonTable = ...
local L, C = LOCALIZATION_L, addonTable.C

local CallbackHandler = LibStub and LibStub("CallbackHandler-1.0", true)
if CallbackHandler then
    addonTable.Modules.UnitFrames = addonTable.Modules.UnitFrames or {}
    addonTable.Modules.UnitFrames.callbacks = CallbackHandler:New(addonTable.Modules.UnitFrames)
end

addonTable.Modules.UnitFrames = addonTable.Modules.UnitFrames or {
    initialized = false,
    lastRaidState = nil,
    iconFrames = {},
    unitToFrame = {},
    unitManaCache = {}
}

local UnitFrames = addonTable.Modules.UnitFrames

local function IsValidUnit(unit)
    return unit and UnitExists(unit) and UnitIsConnected(unit) and UnitIsPlayer(unit)
end

local function GetDrinkingStatus(unit)
    local name = AuraUtil.FindAuraByName(L.DRINK_NAME, unit, "HELPFUL")
    return name
end

local throttleFrame = CreateFrame("Frame")
local updateQueue = {}
local function ProcessQueue()
    for unit, _ in pairs(updateQueue) do
        if IsValidUnit(unit) then
            UnitFrames:UpdateUnit(unit)
        end
        updateQueue[unit] = nil
    end
end
local throttleTimer = 0
throttleFrame:SetScript("OnUpdate", function(_, elapsed)
    throttleTimer = throttleTimer + elapsed
    if throttleTimer >= 0.1 then
        ProcessQueue()
        throttleTimer = 0
    end
end)


function UnitFrames:Initialize()
    if self.initialized then return end
    if db.profile.UnitFrames.Enabled == false then return false end

    if not self.customFont then
        local FONT = CreateFont("RaidmanaEVCustomFont")
        local success = pcall(function()
            FONT:SetFont(C.VENITE_RG_RBA, 12, "OUTLINE")
        end)
        if not success then
            FONT:SetFont(GameFontNormal:GetFont(), 12, "OUTLINE")
        end
        self.customFont = FONT
    end

    if not self.DrinkOverlayFrame then
        self.DrinkOverlayFrame = CreateFrame("Frame", "DrinkHealerOverlay", UIParent, "BackdropTemplate")
        local f = self.DrinkOverlayFrame

        f:SetSize(220, 400)
        f:SetFrameLevel(100)
        local pos = db.profile.UnitFrames.Position
        f:SetPoint(pos.point, pos.relativeTo, pos.relativePoint, pos.x, pos.y)
        f:SetScale(db.profile.UnitFrames.Scale)
        f:SetAlpha(db.profile.UnitFrames.Opacity)
        f:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeSize = 8,
            insets = { left = 0, right = 0, top = 0, bottom = 0 }
        })

        if db.profile.UnitFrames.Lock then f:SetBackdropColor(0.1, 0.1, 0.1, 0) else f:SetBackdropColor(0.1, 0.1, 0.1, 1) end

        f:SetMovable(true)
        f:EnableMouse(true)
        f:RegisterForDrag("LeftButton")
        f:SetScript("OnDragStart", function()
            if not db.profile.UnitFrames.Lock then f:StartMoving() end
        end)
        f:SetScript("OnDragStop", function()
            f:StopMovingOrSizing()
            if db and db.profile and db.profile.UnitFrames then
                local point, _, relPoint, x, y = f:GetPoint(1)

                db.profile.UnitFrames.Position = {
                    point = point,
                    relativeTo = "UIParent",
                    relativePoint = relPoint,
                    x = x,
                    y = y
                }
            end
        end)
    end

    self.iconFrames = self.iconFrames or {}

    for i = 1, 40 do
        if not self.iconFrames[i] then
            local frame = CreateFrame("Button", nil, self.DrinkOverlayFrame,
                "SecureActionButtonTemplate, BackdropTemplate")
            frame:SetSize(218, 22)
            frame:EnableMouse(true)
            frame:SetFrameLevel(self.DrinkOverlayFrame:GetFrameLevel() + 2)

            local hoverFrame = CreateFrame("Frame", nil, frame, "BackdropTemplate")
            hoverFrame:SetAllPoints()
            hoverFrame:SetFrameLevel(frame:GetFrameLevel() + 1)
            hoverFrame:SetBackdrop({
                edgeFile = "Interface\\Buttons\\WHITE8X8",
                edgeSize = 2,
                insets = { left = 0, right = 0, top = 0, bottom = 0 }
            })
            hoverFrame:SetBackdropBorderColor(1, 0, 0, 0.5)
            hoverFrame:Hide()

            frame:SetScript("OnEnter", function(self)
                hoverFrame:Show()

                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetFrameLevel(self:GetFrameLevel() + 10)
                if not self.unit then return end

                local name, realm = UnitName(self.unit), GetRealmName()
                local level, race = UnitLevel(self.unit), UnitRace(self.unit) or ""
                local _, class = UnitClass(self.unit)
                local color = addonTable.Store.ClassTools.GetColor(self.unit)

                GameTooltip:AddLine(format("%s-%s", name, realm), 1, 1, 1)
                GameTooltip:AddLine(format("%s %s %s", level, race, class), color.r, color.g, color.b)

                if GetGuildInfo(self.unit) then
                    GameTooltip:AddLine(
                        format("<%s> | %s",
                            GetGuildInfo(self.unit),
                            _G[UnitGroupRolesAssigned(self.unit)] or ""), 0.8, 0.8, 1)
                end
                GameTooltip:Show()
            end)

            frame:SetScript("OnLeave", function()
                hoverFrame:Hide()
                GameTooltip:Hide()
            end)

            frame:SetSize(220, 24)
            frame:SetPoint("TOPLEFT", 0, -((i - 1) * 28))
            frame:EnableMouse(true)
            frame:RegisterForClicks("AnyUp")
            frame:SetAttribute("type1", "target")

            frame.nameText = frame:CreateFontString(nil, "OVERLAY")
            frame.nameText:SetDrawLayer("OVERLAY", 1)
            frame.nameText:SetFontObject(self.customFont)
            frame.nameText:SetPoint("LEFT", 5, 0)

            frame.manaText = frame:CreateFontString(nil, "OVERLAY")
            frame.manaText:SetDrawLayer("OVERLAY", 2)
            frame.manaText:SetFontObject(self.customFont)
            frame.manaText:SetPoint("RIGHT", -30, 0)
            frame.manaText:SetTextColor(1, 1, 1)

            frame.icon = frame:CreateTexture(nil, "OVERLAY")
            frame.icon:SetDrawLayer("OVERLAY", 3)
            frame.icon:SetSize(15, 15)
            frame.icon:SetPoint("RIGHT", -5, 0)

            self.iconFrames[i] = frame
        end
        self.iconFrames[i]:Hide()
    end

    self.DrinkOverlayFrame:SetScript("OnEvent", function(_, event, unit)
        local inRaid = IsInRaid()
        if not inRaid then return end
        if event == "GROUP_ROSTER_UPDATE" or event == "PLAYER_ENTERING_WORLD" then
            self:UpdateDisplay()
        elseif IsValidUnit(unit) then
            updateQueue[unit] = true
        end
    end)

    self:RegisterEvents()
    self:UpdateDisplay()
    self.initialized = true
end

function UnitFrames:UpdateDisplay()
    self.unitToFrame = self.unitToFrame or {}
    self.unitManaCache = self.unitManaCache or {}


    for i, frame in ipairs(self.iconFrames) do
        frame:Hide()
        frame.unit = nil
    end

    if not IsInRaid() then return end

    local unitList = {}
    for i = 1, 40 do
        local unit = "raid" .. i
        if IsValidUnit(unit) then
            local _, class = UnitClass(unit)
            if addonTable.Store.IsManaClass(class) then
                table.insert(unitList, {
                    unit = unit,
                    name = UnitName(unit) or "",
                    class = class or ""
                })
            end
        end
    end

    table.sort(unitList, function(a, b)
        if a.class == b.class then
            return a.name:lower() < b.name:lower()
        else
            return a.class < b.class
        end
    end)

    for index, data in ipairs(unitList) do
        local frame = self.iconFrames[index]
        if frame then
            frame.unit = data.unit
            frame:SetAttribute("unit", data.unit)

            if not frame.classBG then
                frame.classBG = CreateFrame("StatusBar", nil, frame)
                frame.classBG:SetFrameLevel(frame:GetFrameLevel() - 1)
                frame.classBG:SetAllPoints()
                frame.classBG:SetStatusBarTexture(C.BAR)
                frame.classBG:SetMinMaxValues(0, 100)
                frame.classBG:SetAlpha(0.6)
            end

            local Color = addonTable.Store.ClassTools.GetColor(data.unit)
            frame.classBG:SetStatusBarColor(Color.r, Color.g, Color.b, 0.7)
            frame.classBG:SetValue(100)

            local Drinking = GetDrinkingStatus(data.unit)
            frame.icon:SetTexture(C.WATER)
            frame.icon:SetShown(Drinking ~= nil)

            frame.nameText:SetText(data.name)
            frame.nameText:SetTextColor(Color.r, Color.g, Color.b)
            frame.manaText:SetText(addonTable.Store.FormatManaText(data.unit))

            frame:Show()
            self.unitToFrame[data.unit] = frame
            self.unitManaCache[data.unit] = UnitPower(data.unit, Enum.PowerType.Mana)
        end
    end
end

function UnitFrames:UpdateUnit(unit)
    local frame = self.unitToFrame[unit]
    if not frame or not frame:IsShown() then return end

    local newManaText = addonTable.Store.FormatManaText(unit)
    if frame.manaText:GetText() ~= newManaText then
        frame.manaText:SetText(newManaText)
    end

    local oldMana = self.unitManaCache[unit]
    local newMana = UnitPower(unit, Enum.PowerType.Mana)
    self.unitManaCache[unit] = newMana

    if oldMana ~= newMana and self.callbacks then
        self.callbacks:Fire("OnManaUpdated", unit, newMana, oldMana)
    end

    local Drink = GetDrinkingStatus(unit)
    if frame.icon:IsShown() ~= (Drink ~= nil) then
        frame.icon:SetTexture(C.WATER)
        frame.icon:SetShown(Drink ~= nil)
    end
end

function UnitFrames:RegisterEvents()
    local f = self.DrinkOverlayFrame
    local events = {
        "PLAYER_ENTERING_WORLD",
        "GROUP_ROSTER_UPDATE",
        "UNIT_POWER_UPDATE",
        "UNIT_MAXPOWER",
        "UNIT_AURA"
    };

    for _, event in ipairs(events) do
        f:RegisterEvent(event)
    end
end

function UnitFrames:UnregisterEvents()
    local f = self.DrinkOverlayFrame
    f:UnregisterAllEvents()
end

function UnitFrames:Enable()
    if not self.initialized then self:Initialize() end
    if IsInRaid() then
        self:RegisterEvents()
        self:UpdateDisplay()
    else
        self:UnregisterEvents()
    end
end

function UnitFrames:Disable()
    for _, frame in ipairs(self.iconFrames) do
        frame:Hide()
        frame.unit = nil
    end
    self:UnregisterEvents()
    self.DrinkOverlayFrame:Hide()
    wipe(self.unitToFrame)
    wipe(self.unitManaCache)
    self.initialized = false
end
