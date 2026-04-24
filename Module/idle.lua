local D,F,S,C,_=unpack(select(2,...))
C.IdleMode=UnitIsAFK("player")
local function Away(afk)
    if not afk then return end
    if C.IdleMode then return end
    C.IdleMode=true
    if D.DB[1][1]==1 then
        F:IconDisable()
    end
    if D.DB[1][6]==1 then
        F:IndicatorsDisable()
    end
    for index=1,6 do
        F:DeactivateUnitButton(index)
    end
    F:AuraDisable()
    for index=1,2 do
        F:CastDisable(index)
    end
    if D.DB[1][6]==1 then
        S.EventFrame:RegisterEvent("PLAYER_FLAGS_CHANGED")
    end
    F:HealthDisable()
    F:PowerDisable()
    F:RangeDisable()
    F:NameDisable()
    F:MsgDisable()
    F:MsgCLEUDisable()
end
local function NotAway(afk)
    if afk then return end
    if not C.IdleMode then return end
    C.IdleMode=false
    if D.DB[1][1]==1 then
        F:IconEnable()
    end
    if D.DB[1][6]==1 then
        F:IndicatorsEnable()
    end
    for index=1,6 do
        F:ActivateUnitButton(index)
    end
    F:HealthEnable()
    F:PowerEnable()
    F:MsgEnable()
    F:MsgCLEUEnable()
    F:NameEnable()
    for index=1,2 do
        F:CastEnable(index)
    end
    F:RangeEnable()
    C_Timer.After(0.5,function()
        F:AuraEnable()
    end)
end
function F:UserIdle(unit)
    if D.DB[1][4]~=1 then return end
    if unit~="player" then return end
    if not C.IdleMode then
        Away(UnitIsAFK(unit))
    end
    if C.IdleMode then
        NotAway(UnitIsAFK(unit))
    end
end
