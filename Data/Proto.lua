local _,Ether=...

function Ether:AuraTemplate(newId)
    local obj={"New Aura "..newId,{1,1,0,1},8,"TOP",0,0,false,false,false}
    return obj
end

Ether.PredefinedAuras={
    ["Priest-GroupBuffs"]={
        [25392]={"Prayer Fortitude 3",{0.93,0.91,0.67,1},8,"BOTTOMLEFT",0,0,false,false,false},
        [32999]={"Prayer Spirit 2",{0,0.7,1,1},8,"BOTTOMLEFT",8,0,false,false,false},
        [39374]={"Prayer Shadow 2",{0,0,0,1},8,"BOTTOMRIGHT",0,0,false,false,false}
    },
    ["Priest-Helpful"]={
        [25218]={"Shield 12",{1,0,1,1},8,"TOPLEFT",0,0,false,false,false},
        [41635]={"POM1",{0,0.5,0.9,1},10,"RIGHT",0,0,false,false,false},
        [25222]={"Renew 12",{0.2,1,0.2,1},8,"TOPRIGHT",0,0,false,false,false},
        [6346]={"Fear Ward",{1,0.2,0.5,1},8,"BOTTOM",0,8,false,false,false}
    },
    ["Priest-Harmful"]={[6788]={"Weakened Soul",{0.00,0.80,1.00,1},8,"TOP",0,-8,false,false,false}},
    ["Druid-GroupBuffs"]={[22146]={"GOTW 3",{0.2,1,0.2,1},8,"BOTTOMLEFT",0,0,false,false,false}},
    ["Mage-Group Buffs"]={[22153]={"Int Group Rank 2",{0.6,0.2,0.6,1},8,"BOTTOMRIGHT",0,0,false,false,false}},
    ["Pala-Blessing"]={
        [27143]={"Wisdom 3",{0.6,0.2,0.6,1},8,"BOTTOMRIGHT",0,0,false,false,false},
        [25898]={"Kings",{0.6,0.2,0.6,1},8,"BOTTOMRIGHT",0,8,false,false,false},
        [27141]={"Might 3",{0.6,0.2,0.6,1},8,"BOTTOMRIGHT",8,16,false,false,false}
    },
    ["Warrior-Shout"]={[2048]={"Battle Shout 7",{0.6,0.2,0.6,1},8,"BOTTOMRIGHT",0,0,false,false,false}},
    ["Stance-Ability"]={
        [871]={"Shield Wall",{0.6,0.2,0.6,1},8,"BOTTOMRIGHT",0,0,false,false,false},
        [1719]={"Recklessness",{0.6,0.2,0.6,1},8,"BOTTOMRIGHT",0,0,false,false,false}
    }
}
