local _,Ether=...

local frame
if not frame then
    frame=CreateFrame("Frame")
    frame:SetScript("OnEvent",function(self,event)
        if (event=="PLAYER_REGEN_DISABLED") then
            self:UnregisterEvent("PLAYER_REGEN_DISABLED")
            if Ether.DB[100][3] then
                Ether.EtherToggle(false)
            end
            self:RegisterEvent("PLAYER_REGEN_ENABLED")
        elseif (event=="PLAYER_REGEN_ENABLED") then
            self:UnregisterEvent("PLAYER_REGEN_ENABLED")
            if Ether.DB[100][3] then
                Ether.EtherToggle(true)
            end
            self:RegisterEvent("PLAYER_REGEN_DISABLED")
        end
    end)
    Ether.CombatFrame=frame
end
