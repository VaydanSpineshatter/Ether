local _, addonTable = ...
local L, M, C = LOCALIZATION_L, addonTable.M, addonTable.C

addonTable.Config.MinimapOpt = addonTable.Config.MinimapOpt or {}

local MinimapOpt = addonTable.Config.MinimapOpt


function MinimapOpt:GetOptions(db)
    return {
        type = "group",
        name = "|cff00ccffMinimap|r",
        order = 2,
        args = {
            header = {
                type = "header",
                order = 1,
                name = C.COLORS.TITLE .. "Minimap Options|r"
            },
            description = {
                type = "description",
                order = 2,
                name = C.COLORS.CONFIGURE .. "Configure Minimap|r",
                fontSize = "medium"
            },
            Enable = {
                type = "toggle",
                order = 4,
                name = "Enable",
                get = function() return db.profile.Minimap.Enabled end,
                set = function(_, val)
                    db.profile.Minimap.Enabled = val
                    if not addonTable.Modules.Minimap then return end
                    if val then
                        addonTable.Modules.Minimap:Enable()
                    else
                        addonTable.Modules.Minimap:Disable()
                    end
                end
            },
            Icon = {
                type = "toggle",
                order = 4,
                name = "Icon",
                get = function() end,
                set = function(_, val)
                    if not addonTable.Modules.Minimap then return end

                    addonTable.Modules.Minimap:Toggle()
                end
            },
            Reset = {
                type = "toggle",
                order = 5,
                name = "Reset to defaults",
                get = function() end,
                set = function(_, val)
                    if not addonTable.Modules.Minimap then return end

                    addonTable.Modules.Minimap:ResetToDefaults()
                end
            }
        }
    }
end

return MinimapOpt
