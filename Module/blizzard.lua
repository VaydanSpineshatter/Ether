local D,F,_,C,_=unpack(select(2,...))
local Hidden=CreateFrame("Frame",nil,UIParent)
Hidden:SetAllPoints()
Hidden:Hide()
local B={PlayerFrame,PetFrame,TargetFrame,FocusFrame,PlayerCastingBarFrame,PartyFrame,CompactRaidFrameContainer,
         CompactRaidFrameManager,MicroMenu,MainStatusTrackingBarContainer,BagsBar}
local data={}
C.CombatState=false
function F:StatusBlizzard(index)
    if InCombatLockdown() and C.CombatState then return end
    local DB=D.DB
    if not index or not B[index] or type(index)~="number" then return end
    if DB[2][index]==1 then
        B[index]:Hide()
        B[index]:SetParent(Hidden)
    else
        B[index]:Show()
        B[index]:SetParent(data[index])
    end
end

function F:HideBlizzard()
    if InCombatLockdown() then
        C.CombatState=true
        return
    end
    local DB=D.DB
    for index=1,11 do
        if DB[2][index]==1 then
            B[index]:Hide()
            if not data[index] then
                data[index]=B[index]:GetParent() or UIParent
            end
            F:StatusBlizzard(index)
        end
    end
end
