local _, addonTable = ...
local L, M, C = LOCALIZATION_L, addonTable.M, addonTable.C

addonTable.Config.UnitFramesOpt = addonTable.Config.UnitFramesOpt or {}

local UnitFramesOpt = addonTable.Config.UnitFramesOpt

function UnitFramesOpt:GetOptions(db)
    return {
        type = "group",
        name = "|cff00ccffUnitFrames|r",
        order = 3,
        args = {
            header = {
                type = "header",
                order = 1,
                name = C.COLORS.TITLE .. "UnitFrames Options|r"
            },
            description = {
                type = "description",
                order = 2,
                name = C.COLORS.CONFIGURE .. "Configure UnitFrames|r",
                fontSize = "medium"
            },
            Enable = {
                type  = "toggle",
                name  = function() return M.GetOptionTitle("Enable") end,
                order = 3,
                get   = function() return db.profile.UnitFrames.Enabled end,
                set   = function(_, val)
                    db.profile.UnitFrames.Enabled = val
                    if not addonTable.Modules.UnitFrames then return end
                    if val then
                        addonTable.Modules.UnitFrames:Enable()
                        addonTable.Modules.UnitFrames.DrinkOverlayFrame:Show()
                    else
                        addonTable.Modules.UnitFrames:Disable()
                        addonTable.Modules.UnitFrames.DrinkOverlayFrame:Hide()
                    end
                end
            },
            Lock = {
                type     = "toggle",
                order    = 4,
                name     = function() return M.GetOptionTitle("Lock") end,
                get      = function() return db.profile.UnitFrames.Lock end,
                set      = function(_, value)
                    db.profile.UnitFrames.Lock = value
                    Refresh()
                end,
                disabled = function() return not db.profile.UnitFrames.Enabled end
            },
            Opacity = {
                type     = "range",
                name     = function() return M.GetOptionTitle("Opacity") end,
                order    = 5,
                min      = 0.1,
                max      = 1,
                step     = 0.05,
                get      = function() return db.profile.UnitFrames.Opacity end,
                set      = function(_, value)
                    db.profile.UnitFrames.Opacity = value
                    Refresh()
                end,
                disabled = M.IsFrameOptionDisabled,
            },
            spacer1 = {
                type = "description",
                order = 6,
                name = " ",
            },
            spacer2 = {
                type = "description",
                order = 7,
                name = " ",
            },
            Scale = {
                type     = "range",
                order    = 8,
                name     = function() return M.GetOptionTitle("Scale") end,
                width    = "full",
                desc     = "Controls the scaling of the frame",
                min      = 0.5,
                max      = 3,
                step     = 0.1,
                get      = function() return db.profile.UnitFrames.Scale end,
                set      = function(_, value)
                    db.profile.UnitFrames.Scale = value
                    Refresh()
                end,
                disabled = M.IsFrameOptionDisabled,
            },
            spacer3 = {
                type = "description",
                order = 9,
                name = " ",
            },
            spacer4 = {
                type = "description",
                order = 10,
                name = " ",
            },
            Position = {
                type = "group",
                name = function() return M.GetOptionTitle("Position") end,
                order = 11,
                inline = true,
                disabled = M.IsFrameOptionDisabled,
                args = {
                    point = {
                        type = "select",
                        name = "Frame Anchor",
                        order = 1,
                        values = {
                            TOPLEFT = "Top Left",
                            TOP = "Top",
                            CENTER = "Center",
                            BOTTOM = "Bottom",
                            BOTTOMLEFT = "Bottom Left",
                            BOTTOMRIGHT = "Bottom Right",
                            LEFT = "Left",
                            RIGHT = "Right",
                            TOPRIGHT = "Top Right"
                        },
                        get = function() return db.profile.UnitFrames.Position.point end,
                        set = function(_, value)
                            db.profile.UnitFrames.Position.point = value
                            Refresh()
                        end
                    },
                    relativePoint = {
                        type = "select",
                        name = "Parent Anchor",
                        order = 2,
                        values = {
                            TOPLEFT = "Top Left",
                            TOP = "Top",
                            CENTER = "Center",
                            BOTTOM = "Bottom",
                            BOTTOMLEFT = "Bottom Left",
                            BOTTOMRIGHT = "Bottom Right",
                            LEFT = "Left",
                            RIGHT = "Right",
                            TOPRIGHT = "Top Right"
                        },
                        get = function() return db.profile.UnitFrames.Position.relativePoint end,
                        set = function(_, value)
                            db.profile.UnitFrames.Position.relativePoint = value
                            Refresh()
                        end
                    },
                    x = {
                        type = "range",
                        name = "X Offset",
                        order = 3,
                        min = -500,
                        max = 500,
                        step = 1,
                        get = function() return db.profile.UnitFrames.Position.x end,
                        set = function(_, value)
                            db.profile.UnitFrames.Position.x = value
                            Refresh()
                        end
                    },
                    y = {
                        type = "range",
                        name = "Y Offset",
                        order = 4,
                        min = -500,
                        max = 500,
                        step = 1,
                        get = function() return db.profile.UnitFrames.Position.y end,
                        set = function(_, value)
                            db.profile.UnitFrames.Position.y = value
                            Refresh()
                        end
                    }
                }
            }
        }
    }
end

return UnitFramesOpt
