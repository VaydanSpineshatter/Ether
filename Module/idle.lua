local D,F,S,C=unpack(select(2,...))
C.IdleMode=UnitIsAFK("player")
local function Away(afk)
    if not afk then return end
    if C.IdleMode then return end
    C.IdleMode=true
    F:RosterDisable()
    if D.DB[1][6]==1 then
        S.EventFrame:RegisterEvent("PLAYER_FLAGS_CHANGED")
    end
end
local function NotAway(afk)
    if afk then return end
    if not C.IdleMode then return end
    C.IdleMode=false
    F:RosterEnable()
end
function F:UserIdle(unit)
    if D.DB[1][4]~=1 then return end
    if unit~="player" then return end
    if InCombatLockdown() then return end
    if not C.IdleMode then
        Away(UnitIsAFK(unit))
    end
    if C.IdleMode then
        NotAway(UnitIsAFK(unit))
    end
end