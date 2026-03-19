local _,Ether=...
local state=false
local function isAway(DB)
    local raidButtons=Ether.raidButtons
    if DB[6][12]==1 then
        Ether:CastBarDisable(1)
    end
    if DB[6][13]==1 then
        Ether:CastBarDisable(2)
    end
    if DB[1][5]==1 then
        Ether:RangeDisable()
    end
    if DB[1][7]==1 then
        Ether:AuraDisable()
    end
    if DB[1][1]==1 then
        Ether:ToggleIcon(false)
    end
    if Ether.DB[1][6]==1 then
        for i=1,10 do
            Ether.IndicatorToggle(i)
        end
    end
    Ether:HideIndicators()
end

local function isNotAway(DB)
    if DB[6][12]==1 then
        Ether:CastBarEnable(1)
    end
    if DB[6][13]==1 then
        Ether:CastBarEnable(2)
    end
    if DB[1][5]==1 then
        Ether:RangeEnable()
    end
    if DB[4][1]==1 then
        Ether:AuraEnable()
    end
    if DB[1][1]==1 then
        Ether:ToggleIcon(true)
    end
    if Ether.DB[1][6]==1 then
        for i=1,10 do
            Ether.IndicatorToggle(i)
        end
    end
    Ether:IndicatorsFullUpdate()
end
function Ether:isUserIdle()
    if Ether.DB[1][4]~=1 then return end
    local DB=Ether.DB
    local afk=UnitIsAFK("player")
    if afk and not state then
        state=true
        isAway(DB)
    end
    if not afk and state then
        state=false
        isNotAway(DB)
    end
end