local _, addonTable = ...
local L, M, C = LOCALIZATION_L, addonTable.M, addonTable.C

addonTable.Config.TrackingOpt = addonTable.Config.TrackingOpt or {}

local TrackingOpt = addonTable.Config.TrackingOpt

function TrackingOpt:GetOptions(db)
    return {
        type = "group",
        name = "|cff00ccffTracking|r",
        order = 4,
        args = {
            header = {
                type = "header",
                order = 1,
                name = C.COLORS.TITLE .. "Tracking|r"
            },
            description = {
                type = "description",
                order = 2,
                name = C.COLORS.CONFIGURE .. "Configure Tracking|r",
                fontSize = "medium"
            },
            spacer = {
                type = "description",
                order = 3,
                name = " ",
            },
            Enable = {
                type = "toggle",
                name = "Enable Potions/Runes Tracking",
                order = 4,
                get = function() return db.profile.Tracking.Enabled end,
                set = function(_, val)
                    db.profile.Tracking.Enabled = val
                    if not addonTable.Modules.Tracking then return end
                    if val then
                        addonTable.Modules.Tracking:Enable()
                    else
                        if addonTable.Modules.Tracking.Disable then
                            addonTable.Modules.Tracking:Disable()
                        end
                    end
                end
            }
        }
    }
end

return TrackingOpt
