local _, C = ...
local Data = C.Data
local unitName = UnitName('player')

---@alias IndicatorsID number
---| '"Ready Check"' # [1]
---| '"Group Roles"' # [2]
---| '"MainTank and MainAssist"' # [3]
---| '"ClassIcons"' # [4]
---| '"OfflinePlayers"' # [5]
---| '"RaidTargets"' # [6]
---| '"Resurrections"' # [7]
---| '"GroupLeader"' # [8]
---| '"MasterLooter"' # [9]
---| '"UnitIsGhost"' # [10]
---| '"UnitIsAFK"' # [11]
---| '"UnitIsDND"' # [12]
---| '"UnitThreatSituation"' # [13]
---| '"Range Check"' # [14]
---| '"Smooth Bars"' # [15]

---@alias ContentStr string
---| '"Info"'
---| '"AuraGuide"'
---| '"Hide"'
---| '"Create"'
---| '"Headers"'
---| '"Auras"'
---| '"Updates"'
---| '"Register"'
---| '"Modify"'

local Default = {
    ['VERSION'] = 0,
    ['LASTVERSION'] = 0,
    ['SHOW'] = true,
    ['LAST_TAB'] = nil,
    ['SELECTED'] = 'CONSOLE',
    ['STATUS'] = 'ALPHA',
    ['HIDE'] = {
        ['PLAYER'] = true,
        ['PLAYERSPET'] = true,
        ['TARGET'] = true,
        ['CASTBAR'] = true,
        ['PARTY'] = false,
        ['RAID'] = false,
        ['MANAGER'] = false
    },
    ['BROKER'] = {},
    ['POWER'] = {
        ['SHORT'] = {
            ['DISPLAY'] = 'Power',
            ['RAID'] = false,
            ['SINGLE'] = false
        }
    },
    ['CREATE'] = {
        ['PLAYER'] = true,
        ['PLAYERSPET'] = true,
        ['TARGET'] = true,
        ['TARGETTARGET'] = true,
        ['PARTY'] = false,
        ['RAID'] = false,
        ['RAIDPET'] = false,
        ['PLAYERBAR'] = true,
        ['TARGETBAR'] = true,
        ['PLAYERAURA'] = true,
        ['TARGETAURA'] = true
    },
    ['HEADER'] = {
        ['RAID'] = {
            ['groupby'] = 'GROUP',
            ['point'] = 'TOP',
            ['styleheight'] = '55',
            ['stylewidth'] = '55',
            ['stylescale'] = '1',
            ['showPlayer'] = false,
            ['showSolo'] = false,
            ['showParty'] = false,
            ['showRaid'] = true,
            ['columnAnchorPoint'] = 'LEFT',
            ['unitsPerColumn'] = 5,
            ['maxColumns'] = 1,
            ['columnSpacing'] = 0,
            ['sortMethod'] = 'INDEX',
            ['sortDir'] = 'ASC',
            ['HIGHLIGHT'] = false,
            ['RAIDAURA'] = false,
            ['GroupsFilter'] = {
                [1] = true,
                [2] = true,
                [3] = true,
                [4] = true,
                [5] = true,
                [6] = true,
                [7] = true,
                [8] = true
            },
            ['AuraFilter'] = {
                [10938] = true, -- POWER_WORD_FORTITUDE
                [21564] = true, -- PRAYER_OF_FORTITUDE
                [27841] = true, -- DIVINE_SPIRIT
                [27681] = true, -- PRAYER_OF_SPIRIT
                [10958] = true, -- SHADOW_PROTECTION
                [27683] = true, -- PRAYER_OF_SHADOW_PROTECTION
                [10157] = true, -- ARCANE_INTELLECT
                [23028] = true, -- ARCANE_BRILLIANCE
                [9885] = true, -- MARK_OF_THE_WILD
                [21850] = true, -- GIFT_OF_THE_WILD
                [25315] = true, -- RENEW: RANK 10
                [10901] = true, -- SHIELD: RANK 3
                [15359] = true, -- INSPIRATION: RANK 3
                [6788] = true, -- WEAKENED_SOUL
                [22009] = true, -- GREATER_HEAL_RENEW
                [6346] = true -- FEAR_WARD
            }
        },
        ['PARTY'] = {
            ['styleheight'] = '50',
            ['stylewidth'] = '120',
            ['stylescale'] = '1',
            ['showPlayer'] = true,
            ['showSolo'] = true,
            ['showParty'] = true,
            ['showRaid'] = true,
            ['point'] = 'BOTTOM',
            ['columnAnchorPoint'] = 'LEFT'
        },
        ['RAIDPET'] = {
            ['styleheight'] = '45',
            ['stylewidth'] = '45',
            ['stylescale'] = '1',
            ['showPlayer'] = true,
            ['showSolo'] = true,
            ['showParty'] = true,
            ['showRaid'] = true,
            ['useOwnerUnit'] = false,
            ['filterOnPet'] = true
        }
    },
    ['LAYOUT'] = {
        ['CURRENT'] = 'DEFAULT',
        ['DEFAULT'] = {},
        ['TANK'] = {},
        ['HEALER'] = {},
        ['DAMAGER'] = {}
    },
    ['MODULES'] = {1, 0, 1},
    ['INDICATORS'] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    ['POSITION'] = {
        ['CONSOLE'] = {'TOP', 'UIParent', 'TOP', 80, -80, 320, 200, 1.0, 1.0},
        ['SETTINGS'] = {
            'TOPLEFT', 'UIParent', 'TOPLEFT', 50, -100, 700, 560, 1.0, 1.0
        },
        ['PARTY'] = {
            'TOPLEFT', 'UIParent', 'TOPLEFT', 10, -150, 120, 220, 1.0, 1.0
        },
        ['RAID'] = {'LEFT', 'UIParent', 'LEFT', 10, -100, 550, 300, 1.0, 1.0},
        ['RAIDPET'] = {'LEFT', 'UIParent', 'LEFT', 10, 50, 400, 100, 1.0, 1.0},
        ['PLAYER'] = {
            'CENTER', 'UIParent', 'CENTER', -250, -250, 120, 50, 1.0, 1.0
        },
        ['PLAYERSPET'] = {
            'CENTER', 'UIParent', 'CENTER', -250, 100, 120, 50, 1.0, 1.0
        },
        ['PLAYERSPETTARGET'] = {
            'CENTER', 'UIParent', 'CENTER', -220, 160, 120, 50, 1.0, 1.0
        },
        ['TARGET'] = {
            'CENTER', 'UIParent', 'CENTER', 250, -250, 120, 50, 1.0, 1.0
        },
        ['TARGETTARGET'] = {
            'CENTER', 'UIParent', 'CENTER', 0, -300, 120, 50, 1.0, 1.0
        },
        ['PLAYERCASTBAR'] = {
            'CENTER', 'UIParent', 'CENTER', 0, -200, 260, 17, 1.0, 1.0
        },
        ['TARGETCASTBAR'] = {
            'CENTER', 'UIParent', 'CENTER', 330, -300, 200, 17, 1.0, 1.0
        }
    }
}
Data.Default = Default

local nameLayouts = {
    {name = 'Default', value = 'DEFAULT'}, {name = 'Tank', value = 'TANK'},
    {name = 'Damager', value = 'DAMAGER'}, {name = 'Healer', value = 'HEALER'}
}
Data.nameLayouts = nameLayouts

local Modules = {
    [1] = {name = 'Icon'},
    [2] = {name = 'Compartment'},
    [3] = {name = 'Grid'}
}
Data.Modules = Modules

local Hide = {
    [1] = {name = 'Player frame', value = 'PLAYER'},
    [2] = {name = 'Pet frame', value = 'PLAYERSPET'},
    [3] = {name = 'Target frame', value = 'TARGET'},
    [4] = {name = 'Castbar', value = 'CASTBAR'},
    [5] = {name = 'Party', value = 'PARTY'},
    [6] = {name = 'Raid', value = 'RAID'},
    [7] = {name = 'Raid Manager', value = 'MANAGER'}
}
Data.Hide = Hide

local Units = {
    [1] = {name = '|cffCC66FFPlayer Unit|r', value = 'PLAYER'},
    [2] = {name = "|cffCC66FFPlayer's Pet Uit|r", value = 'PLAYERSPET'},
    [3] = {
        name = "|cffCC66FFPlayer's Pet  Target Unit|r",
        value = 'PLAYERSPETTARGET'
    },
    [4] = {name = '|cE600CCFFTarget Unit|r', value = 'TARGET'},
    [5] = {name = 'Target of Target Unit', value = 'TARGETTARGET'},
    [6] = {name = 'Party Header', value = 'PARTY'},
    [7] = {name = 'Raid Header', value = 'RAID'},
    [8] = {name = 'Player Cast Bar', value = 'PLAYERBAR'},
    [9] = {name = 'Target Cast Bar', value = 'TARGETBAR'}
}
Data.Units = Units

local Slash = {
    [1] = {cmd = '/ether', desc = 'Toggle Commands'},
    [2] = {cmd = 'rl', desc = 'Reload interface'},
    [3] = {cmd = 'grid', desc = 'Lock Frames'},
    [4] = {cmd = 'settings', desc = 'Toggle settings'},
    [5] = {cmd = 'debug', desc = 'Enable Debug'}
}
Data.Slash = Slash

local SlashL = {
    [1] = {desc = '/ether'},
    [2] = {desc = '/ether rl'},
    [3] = {desc = '/ether grid'},
    [4] = {desc = '/ether settings'},
    [5] = {desc = '/ether debug'}

}
Data.SlashL = SlashL

local Aura = {
    [1] = {
        spellId = 10938,
        name = 'Power Word: Fortitude: Rank 6',
        color = '|cffCC66FFEther Pink|r'
    },
    [2] = {
        spellId = 21564,
        name = 'Prayer of Fortitude: Rank 2',
        color = '|cffCC66FFEther Pink|r'
    },
    [3] = {
        spellId = 27841,
        name = 'Divine Spirit: Rank 4',
        color = '|cff00ffffCyan|r'
    },
    [4] = {
        spellId = 27681,
        name = 'Prayer of Spirit: Rank 1',
        color = '|cff00ffffCyan|r'
    },
    [5] = {spellId = 10958, name = 'Shadow Protection: Rank 3', color = 'Black'},
    [6] = {
        spellId = 27683,
        name = 'Prayer of Shadow Protection: Rank 1',
        color = 'Black'
    },
    [7] = {
        spellId = 10157,
        name = 'Arcane Intellect: Rank 5',
        color = '|cE600CCFFEther Blue|r'
    },
    [8] = {
        spellId = 23028,
        name = 'Arcane Brilliance: Rank 1',
        color = '|cE600CCFFEther Blue|r'
    },
    [9] = {
        spellId = 9885,
        name = 'Mark of the Wild: Rank 7',
        color = '|cffffa500Orange|r'
    },
    [10] = {
        spellId = 21850,
        name = 'Gift of the Wild: Rank 2',
        color = '|cffffa500Orange|r'
    },
    [11] = {
        spellId = 25315,
        name = 'Renew: Rank 10',
        color = '|cff00ff00Green|r'
    },
    [12] = {
        spellId = 10901,
        name = 'Power Word Shield: Rank 3',
        color = 'White'
    },
    [13] = {
        spellId = 15359,
        name = 'Inspiration: Rank 3',
        color = '|cffffff00Yellow|r'
    },
    [14] = {
        spellId = 22009,
        name = 'Greater Heal Renew: Tier 2 Priest',
        color = '|cffff00ffMagenta|r'
    },
    [15] = {spellId = 6788, name = 'Weakened Soul', color = '|cffff0000Red|r'},
    [16] = {
        spellId = 6346,
        name = 'Fear Ward',
        color = '|cff8b4513Saddle Brown|r'
    },
    [17] = {spellId = 0, name = 'Magic: Border color: |cffb22222Fire Red|r'},
    [18] = {spellId = 0, name = 'Disease: Border color |cffffd700Gold|r'},
    [19] = {spellId = 0, name = 'Curse: Border color |cE600CCFFEther Blue|r'},
    [20] = {spellId = 0, name = 'Poison: Border color |cffCC66FFEther Pink|r'}
}
Data.Aura = Aura
local OSelect = {

    [1] = {
        name = 'Console',
        value = 'CONSOLE',
        check = function() return C.Console and C.Console.Frame end
    },
    [2] = {
        name = 'Player',
        value = 'PLAYER',
        check = function() return C.Units.__PLAYER end
    },
    [3] = {
        name = 'Target',
        value = 'TARGET',
        check = function() return C.Units.__TARGET end
    },
    [4] = {
        name = 'TargetTarget',
        value = 'TARGETTARGET',
        check = function() return C.Units.__TARGETTARGET end
    },
    [5] = {
        name = "Player's Pet",
        value = 'PLAYERSPET',
        check = function() return C.Units.__PLAYERSPET end
    },
    [6] = {
        name = "Player's Pet Target",
        value = 'PLAYERSPETTARGET',
        check = function() return C.Units.__PLAYERSPETTARGET end
    },
    [7] = {
        name = 'Party',
        value = 'PARTY',
        check = function() return C.Units.PartyTemplate end
    },
    [8] = {
        name = 'Raid Header',
        value = 'RAID',
        check = function() return C.Units.SplitHeaderTemplate end
    },
    [9] = {
        name = 'Raid-Pet Header',
        value = 'RAIDPET',
        check = function() return C.Units.RaidPetTemplate end
    },
    [10] = {
        name = 'Player-Castbar',
        value = 'PLAYERCASTBAR',
        check = function() return C.Units and C.Units.PlayerCastbar end
    },
    [11] = {
        name = 'Target-Castbar',
        value = 'TARGETCASTBAR',
        check = function() return C.Units and C.Units.TargetCastbar end
    }
}
Data.OSelect = OSelect

local PointRelative = {
    [1] = {name = 'TOP', value = 'TOP'},
    [2] = {name = 'TOPLEFT', value = 'TOPLEFT'},
    [3] = {name = 'TOPRIGHT', value = 'TOPRIGHT'},
    [4] = {name = 'CENTER', value = 'CENTER'},
    [5] = {name = 'LEFT', value = 'LEFT'},
    [6] = {name = 'RIGHT', value = 'RIGHT'},
    [7] = {name = 'BOTTOMLEFT', value = 'BOTTOMLEFT'},
    [8] = {name = 'BOTTOMRIGHT', value = 'BOTTOMRIGHT'},
    [9] = {name = 'BOTTOM', value = 'BOTTOM'}
}
Data.PointRelative = PointRelative

local GroupsFilter = {
    {text = 'Group 1', value = 1}, {text = 'Group 2', value = 2},
    {text = 'Group 3', value = 3}, {text = 'Group 4', value = 4},
    {text = 'Group 5', value = 5}, {text = 'Group 6', value = 6},
    {text = 'Group 7', value = 7}, {text = 'Group 8', value = 8}
}
Data.GroupsFilter = GroupsFilter

local AuraFilter = {
    {text = 'Power Word: Fortitude: Rank 6', value = 10938},
    {text = 'Prayer of Fortitude: Rank 2', value = 21564},
    {text = 'Divine Spirit: Rank 4', value = 27841},
    {text = 'Prayer of Spirit: Rank 1', value = 27681},
    {text = 'Shadow Protection: Rank 3', value = 10958},
    {text = 'Prayer of Shadow Protection: Rank 1', value = 27683},
    {text = 'Arcane Intellect: Rank 5', value = 10157},
    {text = 'Arcane Brilliance: Rank 1', value = 23028},
    {text = 'Mark of the Wild: Rank 7', value = 9885},
    {text = 'Gift of the Wild: Rank 2', value = 21850},
    {text = 'Renew: Rank 10', value = 25315},
    {text = 'Power Word Shield: Rank 3', value = 10901},
    {text = 'Inspiration: Rank 3', value = 15359},
    {text = 'Weakened Soul', value = 6788},
    {text = 'Greater Heal Renew: Tier 2 Priest', value = 22009},
    {text = 'Fear Ward', value = 6346}
}
Data.AuraFilter = AuraFilter

local GetColor = {
    ['red'] = {r = 1.00, g = 0.00, b = 0.00, str = 'cffff0000'},
    ['green'] = {r = 0.00, g = 1.00, b = 0.00, str = 'cff00ff00'},
    ['blue'] = {r = 0.00, g = 0.00, b = 1.00, str = 'cff0000ff'},
    ['white'] = {r = 1.00, g = 1.00, b = 1.00, str = 'cffffffff'},
    ['black'] = {r = 0.00, g = 0.00, b = 0.00, str = 'cff000000'},
    ['lightGray'] = {r = 0.67, g = 0.67, b = 0.67, str = 'cffaaaaaa'},
    ['darkGray'] = {r = 0.40, g = 0.40, b = 0.40, str = 'cff666666'},
    ['orange'] = {r = 1.00, g = 0.65, b = 0.00, str = 'cffffa500'},
    ['magenta'] = {r = 1.00, g = 0.00, b = 1.00, str = 'cffff00ff'},
    ['cyan'] = {r = 0.00, g = 1.00, b = 1.00, str = 'cff00ffff'},
    ['yellow'] = {r = 1.00, g = 1.00, b = 0.00, str = 'cffffff00'},
    ['purple'] = {r = 0.50, g = 0.00, b = 0.50, str = 'cff800080'},
    ['saddleBrown'] = {r = 0.55, g = 0.27, b = 0.07, str = 'cff8b4513'},
    ['darkTurq'] = {r = 0.00, g = 0.81, b = 0.82, str = 'cff00ced1'},
    ['pink'] = {r = 1.00, g = 0.41, b = 0.71, str = 'cffff69b4'},
    ['seaGreen'] = {r = 0.18, g = 0.54, b = 0.34, str = 'cff2e8b57'},
    ['gold'] = {r = 1.00, g = 0.84, b = 0.00, str = 'cffffd700'},
    ['fireRed'] = {r = 0.70, g = 0.13, b = 0.13, str = 'cffb22222'},
    ['EtherPink'] = {r = 0.80, g = 0.40, b = 1.00, str = 'cffCC66FF'},
    ['EtherBlue'] = {r = 0.00, g = 0.80, b = 1.00, str = 'cE600CCFF'}
}
Data.GetColor = GetColor

local RAID_COLORS = {
    ['HUNTER'] = {r = 0.67, g = 0.83, b = 0.45},
    ['WARLOCK'] = {r = 0.58, g = 0.51, b = 0.79},
    ['PRIEST'] = {r = 1.0, g = 1.0, b = 1.0},
    ['PALADIN'] = {r = 0.96, g = 0.55, b = 0.73},
    ['MAGE'] = {r = 0.41, g = 0.8, b = 0.94},
    ['ROGUE'] = {r = 1.0, g = 0.96, b = 0.41},
    ['DRUID'] = {r = 1.0, g = 0.49, b = 0.04},
    ['SHAMAN'] = {r = 0.0, g = 0.44, b = 0.87},
    ['WARRIOR'] = {r = 0.78, g = 0.61, b = 0.43},
    ['UNKNOWN'] = {r = 0.80, g = 0.40, b = 1.00}
}
Data.RAID_COLORS = RAID_COLORS

local FACTIONCOLORS = {
    [0] = {r = 255, g = 0, b = 0}, -- HOSTILE
    [1] = {r = 255, g = 129, b = 0}, -- UNFRIENDLY
    [2] = {r = 255, g = 255, b = 0}, -- NEUTRAL
    [3] = {r = 0, g = 255, b = 0}, -- FRIENDLY
    [4] = {r = 0, g = 0, b = 255}, -- PLAYER_SIMPLE
    [5] = {r = 96, g = 96, b = 255}, -- PLAYER_EXTENDED
    [6] = {r = 170, g = 170, b = 255}, -- PARTY
    [7] = {r = 170, g = 255, b = 170}, -- PARTY_PVP
    [8] = {r = 83, g = 201, b = 255}, -- FRIEND
    [9] = {r = 128, g = 128, b = 128}, -- DEAD
    [10] = {}, -- COMMENTATOR_TEAM_1
    [11] = {}, -- COMMENTATOR_TEAM_2
    [13] = {r = 255, g = 255, b = 139}, -- SELF
    [14] = {r = 0, g = 153, b = 0} -- BATTLEGROUND_FRIENDLY_PVP
}
Data.FACTIONCOLORS = FACTIONCOLORS

local HeaderSettings = {
    [1] = {text = 'Show Raid Header if not in any Group', value = 'showSolo'},
    [2] = {
        text = 'Show ' .. unitName .. ' in Party if not in Raid',
        value = 'showPlayer'
    },
    [3] = {text = 'Show Party if not in Raid', value = 'showParty'},
    [4] = {text = 'Show Raid Header in Raid', value = 'showRaid'},
    [5] = {text = 'Aura Module', value = 'RAIDAURA'},
    [6] = {text = 'Button Highlight', value = 'HIGHLIGHT'}
}
Data.HeaderSettings = HeaderSettings

local PetHeaderSettings = {
    [1] = {
        text = 'Show Raid-Pet Header if not in any Group',
        value = 'showSolo'
    },
    [2] = {
        text = "Show " .. unitName .. "'s Pet in Party if not in Raid",
        value = 'showPlayer'
    },
    [3] = {text = 'Show Party if not in Raid', value = 'showParty'},
    [4] = {text = 'Show Raid-Pet Header in Raid', value = 'showRaid'},
    [5] = {text = 'Use Owner Unit', value = 'useOwnerUnit'},
    [6] = {text = 'Filter on Pet', value = 'filterOnPet'}
}
Data.PetHeaderSettings = PetHeaderSettings

local PartyHeaderSettings = {
    [1] = {text = 'Show Party Header if not in any Group', value = 'showSolo'},
    [2] = {
        text = "Show " .. unitName .. " in Party if not in Raid",
        value = 'showPlayer'
    },
    [3] = {text = 'Show Party if not in Raid', value = 'showParty'},
    [4] = {text = 'Show Party Header in Raid', value = 'showRaid'},
    [5] = {text = 'Button Highlight', value = 'HIGHLIGHT'}

}
Data.PartyHeaderSettings = PartyHeaderSettings

local Indicators = {
    [1] = {text = '1. Ready check'},
    [2] = {text = '2. Role icon'},
    [3] = {text = '3. Main tank and main assist'},
    [4] = {text = '4. Class icon'},
    [5] = {text = '5. Offline'},
    [6] = {text = '6. Raid target'},
    [7] = {text = '7. Resurrect'},
    [8] = {text = '8. Leader icon'},
    [9] = {text = '9. Master looter'},
    [10] = {text = '10. Ghost'},
    [11] = {text = '11. Unit is AFK [AFK]'},
    [12] = {text = '12. Unit is DND [DND]'},
    [13] = {text = '13. Unit Threat Situation - Fire Red Name'},
    [14] = {text = '14. Enable Range check – |cffffff00Low CPU Usage|r'},
    [15] = {
        text = '15. Enable Smooth Bar Updates – |cffff0000High CPU Usage|r'
    }
}
Data.Indicators = Indicators

local ClassCoordinate = {
    ['WARRIOR'] = {0, 0.25, 0, 0.25},
    ['MAGE'] = {0.25, 0.49609375, 0, 0.25},
    ['ROGUE'] = {0.49609375, 0.7421875, 0, 0.25},
    ['DRUID'] = {0.7421875, 0.98828125, 0, 0.25},
    ['HUNTER'] = {0, 0.25, 0.25, 0.5},
    ['SHAMAN'] = {0.25, 0.49609375, 0.25, 0.5},
    ['PRIEST'] = {0.49609375, 0.7421875, 0.25, 0.5},
    ['WARLOCK'] = {0.7421875, 0.98828125, 0.25, 0.5},
    ['PALADIN'] = {0, 0.25, 0.5, 0.75}
}
Data.ClassCoordinate = ClassCoordinate

local Layout = {
    [1] = {name = 'Tank', value = 'TANK'},
    [2] = {name = 'Healer', value = 'HEALER'},
    [3] = {name = 'Damager', value = 'DAMAGER'}
}
Data.Layout = Layout

local BackDrop = {
    bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
    edgeFile = 'Interface\\DialogFrame\\UI-DialogBox-Border',
    tile = true,
    tileSize = 32,
    edgeSize = 32,
    insets = {left = 8, right = 8, top = 8, bottom = 8}
}
Data.BackDrop = BackDrop

local Forming = {
    Icon = {'Interface\\AddOns\\Ether\\Media\\Graphic\\Icon.blp'},
    Font = {'Interface\\AddOns\\Ether\\Media\\Font\\expressway.ttf'},
    StatusBar = {'Interface\\AddOns\\Ether\\Media\\StatusBar\\UfBar.blp'},
    BlankBar = {'Interface\\AddOns\\Ether\\Media\\StatusBar\\BlankBar.tga'},
    Tex = {
        R = {'Interface\\RaidFrame\\ReadyCheck-Ready'},
        N = {'Interface\\RaidFrame\\ReadyCheck-NotReady'},
        W = {'Interface\\RaidFrame\\ReadyCheck-Waiting'}
    }
}
Data.Forming = Forming
