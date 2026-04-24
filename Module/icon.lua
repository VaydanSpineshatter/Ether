local D,F,_,C,L=unpack(select(2,...))
local function Enter(self)
    C:ToggleBorder(1,0.84,0)
    if self.moving then return end
    GameTooltip:SetOwner(self,"ANCHOR_LEFT")
    GameTooltip:AddLine("Ether")
    GameTooltip:AddLine(L.MINIMAP_TOOLTIP_RIGHT,1,1,1)
    GameTooltip:AddLine(L.MINIMAP_TOOLTIP_LOCALE,1,1,1)
    GameTooltip:Show()
end
local function Leave()
    C:ToggleBorder(0.67,0.67,0.67)
    GameTooltip:Hide()
end
local function Click(_,btn)
    if btn=="RightButton" then
        if C.DropdownMenu then
            C.DropdownMenu:Hide()
        end
        if C.DropdownText then
            C.DropdownText:SetAlpha(1)
        end
        D.DB["CONFIG"][3]=F:ToggleBinary(D.DB["CONFIG"][3])
        C:ToggleUser()
    end
end
C.EtherIcon:Hide()
C.EtherIcon.tex=C.EtherIcon:CreateTexture(nil,"ARTWORK")
C.EtherIcon.tex:SetAllPoints(C.EtherIcon)
C.EtherIcon.tex:SetColorTexture(0,0.8,1)
C.EtherIcon.mask=C.EtherIcon:CreateMaskTexture("BACKGROUND")
C.EtherIcon.mask:SetTexture("Interface\\AddOns\\Ether\\Media\\icon.blp","CLAMPTOBLACKADDITIVE","CLAMPTOBLACKADDITIVE")
C.EtherIcon.mask:SetAllPoints(C.EtherIcon.tex)
C.EtherIcon.tex:AddMaskTexture(C.EtherIcon.mask)
C.EtherIcon.hl=C.EtherIcon:CreateTexture(nil,"HIGHLIGHT")
C.EtherIcon.hl:SetColorTexture(1,0.84,0,.4)
C.EtherIcon.hl:SetPoint("TOPLEFT",4,-4)
C.EtherIcon.hl:SetPoint("BOTTOMRIGHT",-4,4)

function F:IconEnable()
    if not C.EtherIcon then return end
    if not C.EtherIcon:IsShown() then
        C.EtherIcon:SetShown(true)
        D:ApplyFramePosition(C.EtherIcon)
        F:SetupDrag(C.EtherIcon)
        C.EtherIcon:SetScript("OnEnter",Enter)
        C.EtherIcon:SetScript("OnLeave",Leave)
        C.EtherIcon:SetScript("OnMouseUp",Click)
    end
end
function F:IconDisable()
    if not C.EtherIcon then return end
    if C.EtherIcon:IsShown() then
        C.EtherIcon:SetShown(false)
        F:RemoveDrag(C.EtherIcon)
        C.EtherIcon:SetScript("OnEnter",nil)
        C.EtherIcon:SetScript("OnLeave",nil)
        C.EtherIcon:SetScript("OnMouseUp",nil)
    end
end