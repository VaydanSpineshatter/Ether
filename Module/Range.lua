local Ether = select(2, ...)
local Range = Ether.Range
if (not LibStub or not LibStub("SpellRange-1.0")) then return end
local SpellRange = LibStub("SpellRange-1.0")

Range.frames = {}
Range.throttle = 0.7
Range.sinceLastUpdate = 0
Range.lastNumMembers = nil

Range.UpdateFrames = {
    Update = CreateFrame("Frame")
}


local classSpells = {
    ['PRIEST'] = { 17 },
    ['MAGE'] = { 133, 116, 1467 },
    ['WARLOCK'] = { 348, 172, 686 },
    ['SHAMAN'] = { 403, 331, 8004 },
    ['PALADIN'] = { 19750 },
    ['DRUID'] = { 5185, 774 },
    ['HUNTER'] = { 75, 1978, 3044 }
}

function Range:RegisterFrame(frame)
    if not frame then return end

    self.frames[frame] = {
        unit = frame.unit,
        lastAlpha = 1,
        lastInRange = true
    }
end

function Range:UnregisterFrame(frame)
    if not frame then return end
    frame:SetAlpha(1)
    self.frames[frame] = nil
end

local function GetClassSpecificSpells()
    local _, classFilename = UnitClass("player")
    return classSpells[classFilename] or { 133 }
end

local function IsUnitInRange(unit)
    if not UnitExists(unit) then return false end

    local canAssist = UnitCanAssist("player", unit)
    local canAttack = UnitCanAttack("player", unit)
    local _, classFilnename = UnitClass("player")

    local isMelee = (classFilnename == "ROGUE" or classFilnename == "WARRIOR")

    if canAssist and not isMelee then
        local spells = GetClassSpecificSpells()
        for _, spellID in ipairs(spells) do
            local inRange = SpellRange.IsSpellInRange(spellID, unit)
            if inRange == 1 then
                return true
            elseif inRange == 0 then
                return false
            end
        end
    end

    if canAttack then
        if isMelee then
            return CheckInteractDistance(unit, 3)
        else
            local spells = GetClassSpecificSpells()
            for _, spellID in ipairs(spells) do
                local inRange = SpellRange.IsSpellInRange(spellID, unit)
                if inRange == 1 then
                    return true
                elseif inRange == 0 then
                    return false
                end
            end
        end
    end

    return UnitInRange(unit)
end

local function OnUpdate(self, elapsed)
    self.last = (self.last or 0) + elapsed
    if self.last < Range.throttle then return end
    self.last = 0
    for frame, data in pairs(Range.frames) do
        if frame then
            local inRange = IsUnitInRange(data.unit)
            local newAlpha = inRange and 1 or 0.3

            if data.lastInRange ~= inRange then
                frame:SetAlpha(newAlpha)
                data.lastAlpha = newAlpha
                data.lastInRange = inRange
            end
        end
    end
end


function Range:UpdateRoster()
    for frame in pairs(Range.frames) do
        if frame then
            self:UnregisterFrame(frame)
        end
    end
    for _, frames in pairs(Ether.Units.Data.Update.Cache) do
        if frames then
            self:RegisterFrame(frames)
        end
    end
end

function Range:ShouldUpdate()
    local current = GetNumGroupMembers()
    if current ~= lastNumMembers then
        Range.lastNumMembers = current
        Range:UpdateRoster()
    end
end

function Range:DisableRange()
    if self.UpdateFrames.Update:GetScript('OnUpdate') then
        for frame in pairs(self.frames) do
            if frame then
                self:UnregisterFrame(frame)
            end
        end
        wipe(self.frames)
        self.UpdateFrames.Update:SetScript('OnUpdate', nil)
    end
end

function Range:Initialize()
    if not self.UpdateFrames.Update:GetScript("OnUpdate") then
        self.lastNumMembers = nil
        self.UpdateFrames.Update:SetScript("OnUpdate", OnUpdate)
        self:ShouldUpdate()
    end
end
