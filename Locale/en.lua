local Ether=select(2,...)
if Ether.Locale~="enUS" and Ether.Locale~="enGB" then
    return
end
local L=Ether.L
L.MINIMAP_TOOLTIP_LOCALE="[enUS/enGB]"
L.MINIMAP_TOOLTIP_RIGHT="Right Click: Settings"
--Tooltip
L.TT_UNKNOWN="UNKNOWN"
L.TT_AIMING_YOU="|cffff0000is aiming at you|r"
L.TT_AIMING="aims at"