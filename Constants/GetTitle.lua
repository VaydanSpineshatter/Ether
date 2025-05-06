local _, addonTable = ...
local M = {}

function M.GetOptionTitle(name)
    local IsEnabled = db.profile.UnitFrames.Enabled
    local IsUnlocked = not db.profile.UnitFrames.Lock

    local icon = (IsEnabled and IsUnlocked)
        and "|TInterface\\Addons\\RaidManaEV\\Textures\\Icons\\Ready.png:16|t"
        or "|TInterface\\Addons\\RaidManaEV\\Textures\\Icons\\NotReady.png:16|t"

    local color = (IsEnabled and IsUnlocked)
        and "|cff00ff00"
        or "|cffff0000"

    return string.format("%s %s%s|r", icon, color, name)
end

function M.IsFrameOptionDisabled()
    return not db.profile.UnitFrames.Enabled or db.profile.UnitFrames.Lock
end

addonTable.M = M

return M
