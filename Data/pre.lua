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
local GetColor={
    ["Azure blue"]={"cff3399FF"},
    ["Rust brown"]={"cff996600"},
    ["Violet"]={"cff9900FF"},
    ["Grass green"]={"cff009900"},
    ["red"]={1,0,0,"cffff0000"},
    ["green"]={0,1,b=0.00,"cff00ff00"},
    ["blue"]={0,0,b=1.00,"cff0000ff"},
    ["white"]={1,1,1,"cffffffff"},
    ["black"]={0,0,0,"cff000000"},
    ["lightGray"]={0.67,0.67,0.67,"cffaaaaaa"},
    ["darkGray"]={0.4,0.4,0.4,"cff666666"},
    ["orange"]={1,0.65,0,"cffffa500"},
    ["magenta"]={1,0,1,"cffff00ff"},
    ["cyan"]={0,1,1,"cff00ffff"},
    ["yellow"]={1,1,0,"cffffff00"},
    ["purple"]={0.5,0,0.50,"cff800080"},
    ["saddleBrown"]={0.55,0.27,0.07,"cff8b4513"},
    ["darkTur"]={0,0.81,0.82,"cff00ced1"},
    ["pink"]={1,0.41,0.71,"cffff69b4"},
    ["seaGreen"]={0.18,0.54,0.34,"cff2e8b57"},
    ["gold"]={1,0.84,0,"cffffd700"},
    ["fireRed"]={0.7,0.13,0.13,"cffb22222"},
    ["EtherPink"]={0.8,0.4,1,"cffCC66FF"},
    ["EtherBlue"]={0,0.8,1,"cE600CCFF"}
}
]]