local D,F,_,C,L=unpack(select(2,...))
local GameTooltip=GameTooltip
local function Enter(self)
    C:ToggleBorder(1,0.84,0)
    if not C.CombatStatus then
        self.tex:SetColorTexture(0,1,0)
    end
    if self.moving then return end
    GameTooltip:SetOwner(self,"ANCHOR_LEFT")
    GameTooltip:AddLine("Ether")
    GameTooltip:AddLine(L.MINIMAP_TOOLTIP_RIGHT,1,1,1)
    GameTooltip:AddLine(L.MINIMAP_TOOLTIP_LOCALE,1,1,1)
    GameTooltip:Show()
end
local function Leave(self)
    if not C.CombatStatus then
        self.tex:SetColorTexture(0,0.8,1)
    end
    C:ToggleBorder(0.67,0.67,0.67)
    GameTooltip:Hide()
end
local function Click(_,btn)
    if btn=="RightButton" then
        C:ToggleUser()
    end
end
local frame=CreateFrame("Frame",nil,UIParent)
C.EtherIcon=frame
frame.index=18
frame:Hide()
frame.tex=frame:CreateTexture(nil,"ARTWORK")
frame.tex:SetAllPoints(frame)
frame.tex:SetColorTexture(0,0.8,1)
frame.mask=frame:CreateMaskTexture("BACKGROUND")
frame.mask:SetTexture("Interface\\AddOns\\Ether\\Media\\icon.blp","CLAMPTOBLACKADDITIVE","CLAMPTOBLACKADDITIVE")
frame.mask:SetAllPoints(frame.tex)
frame.tex:AddMaskTexture(frame.mask)
function F:IconEnable()
    if not frame:IsShown() then
        frame:SetShown(true)
        D:ApplyFramePosition(frame)
        F:SetupDrag(frame)
        frame:SetScript("OnEnter",Enter)
        frame:SetScript("OnLeave",Leave)
        frame:SetScript("OnMouseUp",Click)
    end
end
function F:IconDisable()
    if frame:IsShown() then
        frame:SetShown(false)
        F:RemoveDrag(frame)
        frame:SetScript("OnEnter",nil)
        frame:SetScript("OnLeave",nil)
        frame:SetScript("OnMouseUp",nil)
    end
end
F:RegisterCallbackByIndex(F.IconEnable,1)
F:RegisterCallbackByIndex(F.IconDisable,1+30)