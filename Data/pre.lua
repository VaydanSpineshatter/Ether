local D=unpack(select(2,...))
function D:AuraTemplate(newId)
    local obj={"New Aura "..newId,1,1,0,1,"TOP",0,0,8,false}
    return obj
end
function D:IndicatorTemplate(name)
    local obj={name,1,1,0,1,"TOP",0,0,8,false}
    return obj
end
D.PredefinedIndicator={
    ["Connection"]={"UNIT_CONNECTION",0.93,0.91,0.67,1,"BOTTOMLEFT",0,0,8,true},
    ["Faction"]={"INCOMING_RESURRECT_CHANGED",0.93,0.91,0.67,1,"BOTTOMLEFT",0,0,8,true},
    ["PlayerFlags"]={"PLAYER_FLAGS_CHANGED",0.93,0.91,0.67,1,"BOTTOMLEFT",0,0,8,true},
    ["UnitFlags"]={"UNIT_FLAGS",0.93,0.91,0.67,1,"BOTTOMLEFT",0,0,8,true},
    ["Resurrection"]={"UNIT_FACTION",0.93,0.91,0.67,1,"BOTTOMLEFT",0,0,8,true},
    ["RaidTarget"]={"RAID_TARGET_UPDATE",0.93,0.91,0.67,1,"BOTTOMLEFT",0,0,8,true},
    ["Leader"]={"PARTY_LEADER_CHANGED",0.93,0.91,0.67,1,"BOTTOMLEFT",0,0,8,true},
    ["LootMaster"]={"PARTY_LOOT_METHOD_CHANGED",0.93,0.91,0.67,1,"BOTTOMLEFT",0,0,8,true},
    ["Roles"]={"PLAYER_ROLES_ASSIGNED",0.93,0.91,0.67,1,"BOTTOMLEFT",0,0,8,true},
    ["ReadyCheck"]={"READY_CHECK","READY_CHECK_CONFIRM","READY_CHECK_FINISHED",0.93,0.91,0.67,1,"BOTTOMLEFT",0,0,8,true},
}
D.PredefinedAuras={
    ["Priest-GroupBuffs"]={
        [25392]={"Prayer Fortitude 3",0.93,0.91,0.67,1,"BOTTOMLEFT",0,0,8,false},
        [32999]={"Prayer Spirit 2",0,0.7,1,1,"BOTTOMLEFT",8,0,8,false},
        [39374]={"Prayer Shadow 2",0,0,0,1,"BOTTOMRIGHT",0,0,8,false}
    },
    ["Priest-Helpful"]={
        [25218]={"Shield 12",1,0,1,1,"TOPLEFT",0,0,8,false},
        [41635]={"POM1",0,0.5,0.9,1,"RIGHT",0,0,10,false},
        [25222]={"Renew 12",0.2,1,0.2,1,"TOPRIGHT",0,0,8,false},
        [6346]={"Fear Ward",1,0.2,0.5,1,"BOTTOM",0,8,8,false},
    },
    ["Priest-Harmful"]={[6788]={"Weakened Soul",0,0.8,1,1,"TOP",0,-8,8,true}},
    ["Druid-GroupBuffs"]={[22146]={"GOTW 3",0.2,1,0.2,1,1,"BOTTOMLEFT",0,0,8,false}},
    ["Mage-Group Buffs"]={[22153]={"Int Group Rank 2",0.6,0.2,0.6,1,"BOTTOMRIGHT",0,0,8,false}},
    ["Pala-Blessing"]={
        [27143]={"Wisdom 3",0.6,0.2,0.6,1,"BOTTOMRIGHT",0,0,8,false},
        [25898]={"Kings",0.6,0.2,0.6,1,"BOTTOMRIGHT",0,8,8,false},
        [27141]={"Might 3",0.6,0.2,0.6,1,"BOTTOMRIGHT",8,16,8,false}
    },
    ["Warrior-Shout"]={[2048]={"Shout-7",0.6,0.2,0.6,1,"BOTTOMRIGHT",0,0,8,false,}},
    ["Stance-Ability"]={
        [871]={"Shield Wall",0.6,0.2,0.6,1,"BOTTOMRIGHT",0,0,8,false},
        [1719]={"Recklessness",0.6,0.2,0.6,1,"BOTTOMRIGHT",0,0,8,false}
    }
}
--[[
local GetColor              = {
	["Azure blue"]  = { str = "cff3399FF" },
	["Rust brown"]  = { str = "cff996600" },
	["Violet"]      = { str = "cff9900FF" },
	["Grass green"] = { str = "cff009900" },
	["red"]         = { r = 1.00, g = 0.00, b = 0.00, str = "cffff0000" },
	["green"]       = { r = 0.00, g = 1.00, b = 0.00, str = "cff00ff00" },
	["blue"]        = { r = 0.00, g = 0.00, b = 1.00, str = "cff0000ff" },
	["white"]       = { r = 1.00, g = 1.00, b = 1.00, str = "cffffffff" },
	["black"]       = { r = 0.00, g = 0.00, b = 0.00, str = "cff000000" },
	["lightGray"]   = { r = 0.67, g = 0.67, b = 0.67, str = "cffaaaaaa" },
	["darkGray"]    = { r = 0.40, g = 0.40, b = 0.40, str = "cff666666" },
	["orange"]      = { r = 1.00, g = 0.65, b = 0.00, str = "cffffa500" },
	["magenta"]     = { r = 1.00, g = 0.00, b = 1.00, str = "cffff00ff" },
	["cyan"]        = { r = 0.00, g = 1.00, b = 1.00, str = "cff00ffff" },
	["yellow"]      = { r = 1.00, g = 1.00, b = 0.00, str = "cffffff00" },
	["purple"]      = { r = 0.50, g = 0.00, b = 0.50, str = "cff800080" },
	["saddleBrown"] = { r = 0.55, g = 0.27, b = 0.07, str = "cff8b4513" },
	["darkTur"]     = { r = 0.00, g = 0.81, b = 0.82, str = "cff00ced1" },
	["pink"]        = { r = 1.00, g = 0.41, b = 0.71, str = "cffff69b4" },
	["seaGreen"]    = { r = 0.18, g = 0.54, b = 0.34, str = "cff2e8b57" },
	["gold"]        = { r = 1.00, g = 0.84, b = 0.00, str = "cffffd700" },
	["fireRed"]     = { r = 0.70, g = 0.13, b = 0.13, str = "cffb22222" },
	["EtherPink"]   = { r = 0.80, g = 0.40, b = 1.00, str = "cffCC66FF" },
	["EtherBlue"]   = { r = 0.00, g = 0.80, b = 1.00, str = "cE600CCFF" }
}
]]
