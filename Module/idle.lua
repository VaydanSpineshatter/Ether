local D,F,S,C=unpack(select(2,...))
C.IdleMode=UnitIsAFK("player")
local function Away(afk)
    if not afk then return end
    if C.IdleMode then return end
    C.IdleMode=true
    for index=1,12 do
        if D.DB[1][index]==1 then
            if index>=10 and index<=12 then
                F:Fire(index+30)
            elseif index>=5 and index<=7 then
                F:Fire(index+30)
            elseif index<=3 then
                F:Fire(index+30)
            end
        end
    end
    for index=1,2 do
        F:CastDisable(index)
    end
    for index=1,6 do
        if D.DB[6][index]==1 then
            F:DeactivateUnitButton(index)
        end
    end
    if D.DB[1][6]==1 then
        S.EventFrame:RegisterEvent("PLAYER_FLAGS_CHANGED")
    end
end
local function NotAway(afk)
    if afk then return end
    if not C.IdleMode then return end
    C.IdleMode=false
    for index=1,12 do
        if D.DB[1][index]==1 then
            if index>=10 and index<=12 then
                F:Fire(index)
            elseif index==7 then
                C_Timer.After(0.5,function()
                    F:Fire(index)
                end)
            elseif index>=5 and index<=6 then
                F:Fire(index)
            elseif index<=3 then
                F:Fire(index)
            end
        end
    end
    for index=1,6 do
        if D.DB[6][index]==1 then
            F:ActivateUnitButton(index)
        end
    end
    for index=1,2 do
        F:CastEnable(index)
    end
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