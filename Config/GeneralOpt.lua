local _, addonTable = ...
local L, M, C = LOCALIZATION_L, addonTable.M, addonTable.C

addonTable.Config.GeneralOpt = addonTable.Config.GeneralOpt or {}

local GeneralOpt = addonTable.Config.GeneralOpt


function GeneralOpt:GetOptions(db)
    return {
        type = "group",
        name = "|cff00ccffGeneral|r",
        order = 1,
        args = {
            header = {
                type = "header",
                order = 1,
                name = C.COLORS.TITLE .. "General Options|r"
            },
            description = {
                type = "description",
                order = 2,
                name = C.COLORS.CONFIGURE .. "Configure General Options|r",
                fontSize = "medium"
            },
            spacer = {
                type = "description",
                order = 3,
                name = " ",
            },
            ReloadAddon = {
                type = "execute",
                order = 5,
                name = "Reload Interface",
                func = function() ReloadUI() end,
            },
            spacer2 = {
                type = "description",
                order = 6,
                name = " ",
            },
            spacer3 = {
                type = "description",
                order = 7,
                name = " ",
            },
            spacer4 = {
                type = "description",
                order = 8,
                name = " ",
            },
            spacer5 = {
                type = "description",
                order = 9,
                name = " ",
            },
            spacer6 = {
                type = "description",
                order = 10,
                name = " ",
            },
            spacer7 = {
                type = "description",
                order = 11,
                name = " ",
            },
            headerDescription = {
                type = "header",
                order = 12,
                name = "|cff00ccffAbout Raid Mana - EV|r",
            }
        }
    }
end

return GeneralOpt
