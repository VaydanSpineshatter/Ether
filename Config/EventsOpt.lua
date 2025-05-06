local _, addonTable = ...
local L, M, C = LOCALIZATION_L, addonTable.M, addonTable.C

addonTable.Config.EventsOpt = addonTable.Config.EventsOpt or {}

local EventsOpt = addonTable.Config.EventsOpt

function EventsOpt:GetOptions(db)
    return {
        type = "group",
        name = "|cff00ccffEvents|r",
        order = 5,
        args = {
            header = {
                type = "header",
                order = 1,
                name = C.COLORS.TITLE .. "Events|r"
            },
            description = {
                type = "description",
                order = 2,
                name = C.COLORS.CONFIGURE .. "Configure Events|r",
                fontSize = "medium"
            },
            spacer = {
                type = "description",
                order = 3,
                name = " ",
            }

        }
    }
end

return EventsOpt
