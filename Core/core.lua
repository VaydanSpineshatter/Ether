local D,F,S,C=unpack(select(2,...))
local ipairs,j,created=ipairs,0,false
C.BorderFrames,C.ChildFrames,C.MenuButtons,C.AuraList,C.MainButtons={},{},{},{},{}
while true do
    j=j+1
    C.MainButtons[#C.MainButtons+1]={}
    if j>=7 then break end
end
local function Child()
    if created then return end
    for i=1,8 do
        if not C.MenuButtons[i] then
            F:MenuButton(i,function()
                if not C.ChildFrames[i].created then
                    F:Fire(i+50,C.ChildFrames[i],true)
                end
            end)
        end
    end
end
local function Base()
    if created then return end
    C.BaseFrame:SetPoint("TOPLEFT")
    C.BaseFrame:SetPoint("BOTTOMLEFT")
    C.BaseFrame:SetWidth(100)
    C.ContentFrame:SetPoint("TOPLEFT",C.BaseFrame,"TOPRIGHT")
    C.ContentFrame:SetPoint("BOTTOMRIGHT")
    F:InitializeSystemStatus()
end
local function Border()
    if created then return end
    created=true
    F:MainBorder(C.MainFrame,1,2,3,4)
    C.BorderFrames[5]=C.ContentFrame:CreateTexture(nil,"BORDER")
    C.BorderFrames[5]:SetColorTexture(0.67,0.67,0.67)
    C.BorderFrames[5]:SetPoint("TOPLEFT",-1,1)
    C.BorderFrames[5]:SetPoint("BOTTOMLEFT",-1,-1)
    C.BorderFrames[5]:SetWidth(1)
end
function C:Main()
    if created then return end
    C.MainFrame:SetFrameStrata("TOOLTIP")
    C.MainFrame.bg=C.MainFrame:CreateTexture(nil,"BACKGROUND")
    C.MainFrame.bg:SetAllPoints()
    C.MainFrame.bg:SetColorTexture(0.1,0.1,0.1)
    C.MainFrame:Hide()
    C.MainFrame:SetScript("OnHide",function()
        if C.ProfileRefresh then return end
        F:RefreshUserButtons(1)
        if C.IsMovable then return end
        D.DB["CONFIG"][3]=0
    end)
    Base()
    Child()
    Border()
    local unlock=F:EtherPanelButton(C.BaseFrame,40,20,"Lock","BOTTOMLEFT",C.BaseFrame,"BOTTOMLEFT",10,5)
    unlock:SetScript("OnClick",function()
        if C.ProfileRefresh then return end
        if not C.GridFrame then
            F:SetupGridFrame()
        end
        if not C.GridFrame:IsShown() then
            C:ToggleUnlock(1)
        else
            C:ToggleUnlock(0)
        end
    end)
    local close=F:EtherPanelButton(C.BaseFrame,40,20,"Close","LEFT",unlock,"RIGHT",0,0)
    close:SetScript("OnClick",function()
        if C.ProfileRefresh then return end
        C.MainFrame:Hide()
        D.DB["CONFIG"][3]=0
    end)
    D:ApplyFramePosition(C.MainFrame)
    F:SetupDrag(C.MainFrame)
end
function C:ToggleUnlock(number)
    if not C.GridFrame then
        F:SetupGridFrame()
    end
    local i=F:BinaryCondition(number)
    C.IsMovable=i
    C.GridFrame:SetShown(i)
    C.InfoFrame:SetShown(i)
    C.ToolFrame:SetShown(i)
    if D.A.raid.tex then
        D.A.raid.tex:SetShown(i)
    end
    if D.A.pet.tex then
        D.A.pet.tex:SetShown(i)
    end
    if D.DB[6][12]==1 then
        F:HideCastBar(1,i)
    end
    if D.DB[6][13]==1 then
        F:HideCastBar(2,i)
    end
end
function S.EventFrame:PLAYER_LOGIN()
    self:UnregisterEvent("PLAYER_LOGIN")
    self:RegisterEvent("PLAYER_LOGOUT")
    D.Slash[20]=D:GetProfileName()
    if not C_ChatInfo.IsAddonMessagePrefixRegistered(C.EtherPrefix) then
        F:FuncDisable("CHAT_MSG_ADDON")
        table.remove(D.msgEvent,1)
    else
        D.Slash[17]="|cff00ff00true|r"
    end
    F:HideBlizzard()
    F:SetupSlash()
    F:ToolTipInitialize()
    F:CreateGroupHeader("GROUP")
    F:CreateGroupHeader("PET")
    for index=1,6 do
        F:CreateUnitButtons(index)
        if D.DB[6][index]==0 then
            F:DeactivateUnitButton(index)
        end
    end

    if D.DB[6][4]==1 then
        F:PetCondition()
    end
    for index=1,2 do
        F:CreateCastBar(index)
        F:CreateModelButton(index)
    end
    if InCombatLockdown() then
        S.EventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    else
        S.EventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    end
    F:RosterEnable()
    S.EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
end
function S.EventFrame:PLAYER_LOGOUT()
    self:UnregisterAllEvents()
    _G["ETHER_DATABASE"]["PROFILES"][D:GetProfileName()]=D:CopyTable(D.DB)
end
local function SetPerfectUIScale()
    if InCombatLockdown() then return end
    local _,screenHeight=GetPhysicalScreenSize()
    if screenHeight and screenHeight>0 then
        local perfectScale=768/screenHeight
        if tonumber(GetCVar("uiScale"))~=perfectScale then
            C_CVar.SetCVar("useUiScale","1")
            C_CVar.SetCVar("uiScale",tostring(perfectScale))
        end
    end
end
function S.EventFrame:PLAYER_ENTERING_WORLD()
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    for _,b in ipairs({D.H.pet:GetChildren()}) do
        local unit=b:GetAttribute("unit")
        if unit and UnitExists(unit) then
            b.unit=unit
            D.petBtn[b.unit]=b
            F:FullHealthUpdate(b)
            F:UpdateName(b,3)
            F:UpdateIndicatorsPetUnit(b)
        end
    end
    C_Timer.After(1.1,function()
        SetPerfectUIScale()
        if D.Slash[17]=="|cff00ff00true|r" then
           -- if IsInGuild() then
               -- C_ChatInfo.SendAddonMessage(C.EtherPrefix,D:ExportAddonMsg(),"GUILD")
         --   end
            D.Slash[16]=C_AddOns.GetAddOnMetadata("Ether","Version") or "|cffff0000Initialisation failed|r"
        end
    end)
end