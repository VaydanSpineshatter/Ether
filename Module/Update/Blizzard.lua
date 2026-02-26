local _,Ether=...

local hide=CreateFrame("Frame",nil,UIParent)
hide:SetAllPoints()
hide:Hide()
local function HiddenFrame(frame)
    if not frame then
        return
    end
    frame:UnregisterAllEvents()
    frame:Hide()
    frame:SetParent(hide)
end

function Ether:HideBlizzard()
    if InCombatLockdown() then
        return
    end
    if Ether.DB[101][1]==1 then
        HiddenFrame(PlayerFrame)
    end
    if Ether.DB[101][2]==1 then
        HiddenFrame(PetFrame)
    end
    if Ether.DB[101][3]==1 then
        HiddenFrame(TargetFrame)
    end
    if Ether.DB[101][4]==1 then
        HiddenFrame(FocusFrame)
    end
    if Ether.DB[101][5]==1 then
        HiddenFrame(PlayerCastingBarFrame)
    end
    if Ether.DB[101][6]==1 then
        UIParent:UnregisterEvent("GROUP_ROSTER_UPDATE")
        if CompactPartyFrame then
            CompactPartyFrame:UnregisterAllEvents()
        end

        if PartyFrame then
            PartyFrame:SetScript('OnShow',nil)
            for frame in PartyFrame.PartyMemberFramePool:EnumerateActive() do
                HiddenFrame(frame)
            end
            HiddenFrame(PartyFrame)
        else
            for i=1,4 do
                HiddenFrame(_G['PartyMemberFrame'..i])
                HiddenFrame(_G['CompactPartyMemberFrame'..i])
            end
            HiddenFrame(PartyMemberBackground)
        end
    end
    if Ether.DB[101][7]==1 then
        if CompactRaidFrameContainer then
            CompactRaidFrameContainer:UnregisterAllEvents()
            hooksecurefunc(CompactRaidFrameContainer,'Show',CompactRaidFrameContainer.Hide)
            hooksecurefunc(CompactRaidFrameContainer,'SetShown',function(frame,shown)
                if shown then
                    frame:Hide()
                end
            end)
        end
    end
    if Ether.DB[101][8]==1 then
        if CompactRaidFrameManager_SetSetting then
            CompactRaidFrameManager_SetSetting('IsShown','0')
        end
        if CompactRaidFrameManager then
            HiddenFrame(CompactRaidFrameManager)
        end
    end
    if Ether.DB[101][9]==1 then
        HiddenFrame(MicroMenu)
    end
    if Ether.DB[101][10]==1 then
        HiddenFrame(MainStatusTrackingBarContainer)
    end
    if Ether.DB[101][11]==1 then
        HiddenFrame(BagsBar)
    end
end