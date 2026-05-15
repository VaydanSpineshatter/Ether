local D,F,S,C=unpack(select(2,...))
local ipairs,created,event=ipairs,false,S.EventFrame
local config,content,base
do
    config=CreateFrame("Frame","EtherConfigFrame",UIParent)
    table.insert(UISpecialFrames,"EtherConfigFrame")
    C.ConfigFrame=config
    config.index=19
    config:SetFrameStrata("TOOLTIP")
    config.bg=C.ConfigFrame:CreateTexture(nil,"BACKGROUND")
    config.bg:SetAllPoints()
    config.bg:SetColorTexture(0.1,0.1,0.1)
    config:Hide()
    config:SetScript("OnHide",function()
        if C.ProfileRefresh then return end
        F:RefreshUserButtons(1)
        if C.IsMovable then return end
        D.DB["CONFIG"][3]=0
    end)
    content,base=CreateFrame("Frame",nil,config),CreateFrame("Frame",nil,config)
    base:SetPoint("TOPLEFT")
    base:SetPoint("BOTTOMLEFT")
    base:SetWidth(100)
    content:SetPoint("TOPLEFT",base,"TOPRIGHT")
    content:SetPoint("BOTTOMRIGHT")
    C.ContentFrame,C.BaseFrame,C.BorderFrames,C.ChildFrames,C.MenuButtons,C.AuraList,C.MainButtons=content,base,{},{},{},{},{}
    local i=0
    while true do
        i=i+1
        C.MainButtons[#C.MainButtons+1]={}
        if i>=7 then break end
    end
end
local function Children()
    if created then return end
    created=true
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
function C:Main()
    if created then return end
    F:InitializeSystemStatus()
    F:MainBorder(config,1,2,3,4)
    C.BorderFrames[5]=content:CreateTexture(nil,"BORDER")
    C.BorderFrames[5]:SetColorTexture(0.67,0.67,0.67)
    C.BorderFrames[5]:SetPoint("TOPLEFT",-1,1)
    C.BorderFrames[5]:SetPoint("BOTTOMLEFT",-1,-1)
    C.BorderFrames[5]:SetWidth(1)
    local unlock=F:EtherPanelButton(base,40,20,"Lock","BOTTOMLEFT",base,"BOTTOMLEFT",10,5)
    unlock:SetScript("OnClick",function()
        if C.IsMovable then
            C:ToggleUnlock(0)
        else
            C:ToggleUnlock(1)
        end
    end)
    local close=F:EtherPanelButton(base,40,20,"Close","LEFT",unlock,"RIGHT",0,0)
    close:SetScript("OnClick",function()
        if C.ProfileRefresh then return end
        config:Hide()
        D.DB["CONFIG"][3]=0
    end)
    D:ApplyFramePosition(config)
    F:SetupDrag(config)
    Children()
end
function C:ToggleUnlock(number)
    if C.ProfileRefresh then return end
    if not C.GridFrame then
        F:SetupGridFrame()
    end
    C.IsMovable=F:BinaryCondition(number)
    local i=C.IsMovable
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
function event:PLAYER_LOGIN()
    self:UnregisterEvent("PLAYER_LOGIN")
    self:RegisterEvent("PLAYER_LOGOUT")
    D.Slash[16]=D:GetProfileName()
    D.Slash[14]=C_ChatInfo.IsAddonMessagePrefixRegistered(C.EtherPrefix) and 1 or 0
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
        self:RegisterEvent("PLAYER_REGEN_ENABLED")
    else
        self:RegisterEvent("PLAYER_REGEN_DISABLED")
    end
    F:RosterEnable()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
end
function event:PLAYER_LOGOUT()
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
function event:PLAYER_ENTERING_WORLD()
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    for _,b in ipairs({D.H.pet:GetChildren()}) do
        C.UpdatePetUnit(b)
    end
    C_Timer.After(1.1,function()
        SetPerfectUIScale()
        if D.Slash[14]==1 then
            if IsInGuild() then
                C_ChatInfo.SendAddonMessage(C.EtherPrefix,D:ExportAddonMsg(),"GUILD")
            end
            D.Slash[14]=C_AddOns.GetAddOnMetadata("Ether","Version")
        else
            D.Slash[14]="|cffff0000error|r"
            F:FuncDisable("CHAT_MSG_ADDON")
            table.remove(D.msgEvent,1)
        end
    end)
end