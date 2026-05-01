local _,_,_,_,L=unpack(select(2,...))
if L.Locale~="enUS" and L.Locale~="enGB" then
    return
end
L.MINIMAP_TOOLTIP_LOCALE="[enUS/enGB]"
L.MINIMAP_TOOLTIP_RIGHT="Right Click: Settings"
--Tooltip
L.TT_UNKNOWN="UNKNOWN"
L.TT_AIMING_YOU="|cffff0000is aiming at you|r"
L.TT_AIMING="aims at"
--Status
L.HEALTH_PCT="Health %"
L.POWER_PCT="Power %"
--Header
L.SORT_BY_H="Sort by: "
L.DIRECTION_BY_H="Sort direction: "