local D,F,S,C=unpack(select(2,...))
local ipairs,modelBtn=ipairs,D.modelBtn
C.BorderFrames,C.ChildFrames,C.MenuButtons,C.AuraList={},{},{},{}
C.MainButtons={[1]={},[2]={},[3]={},[4]={},[5]={},[6]={}}
local function MODULE_CHARGING(i)
    if i==1 then
        F:Module(i)
    elseif i==2 then
        F:Blizzard(i)
    elseif i==3 then
        F:Tooltip(i)
    elseif i==4 then
        F:Aura(i)
    elseif i==5 then
        F:Indicators(i)
    elseif i==6 then
        F:Layout(i)
    elseif i==7 then
        F:Header(i)
    elseif i==8 then
        F:Profile(i)
    end
end
local function Child()
    if C.Created then return end
    for index=1,8 do
        if not C.MenuButtons[index] then
            C.MenuButtons[index]=CreateFrame("Button",nil,C.BaseFrame)
            C.MenuButtons[index]:SetSize(90,20)
            local frame=C.ChildFrames
            frame[index]=CreateFrame("Frame",nil,C.ContentFrame)
            frame[index]:SetAllPoints(C.ContentFrame)
            C.MenuButtons[index]:SetScript("OnClick",function()
                F:MenuStringsAlpha(0)
                F:RefreshUserButtons()
                if index==4 then
                    C.ChildFrames[10]:Show()
                    C.ChildFrames[11]:Show()
                end
                D.DB["CONFIG"][1]=index
                MODULE_CHARGING(index)
                frame[index]:Show()
            end)
            if index==1 then
                C.MenuButtons[index]:SetPoint("TOP",0,-5)
            else
                C.MenuButtons[index]:SetPoint("TOP",C.MenuButtons[index-1],"BOTTOM")
            end
            C.MenuButtons[index].text=C.MenuButtons[index]:CreateFontString(nil,"OVERLAY")
            C.MenuButtons[index].text:SetFontObject(C.EtherFont)
            C.MenuButtons[index].text:SetPoint("CENTER")
            C.MenuButtons[index].text:SetText(D.MenuKey[index])
            C.MenuButtons[index]:SetScript("OnEnter",function(self)
                self.text:SetTextColor(1,0.84,0)
                C:ToggleBorder(1,0.84,0)
            end)
            C.MenuButtons[index]:SetScript("OnLeave",function(self)
                self.text:SetTextColor(1,1,1)
                C:ToggleBorder(0.67,0.67,0.67)
            end)
        end
    end
    for index=9,11 do
        if not C.ChildFrames[index] then
            C.ChildFrames[index]=CreateFrame("Frame",nil,C.ContentFrame)
            C.ChildFrames[index]:SetAllPoints(C.ContentFrame)
        end
        C.IndicatorFrame=C.ChildFrames[9]
        C.EditorFrame=C.ChildFrames[10]
        C.AuraFrame=C.ChildFrames[11]
    end
end
local function Base()
    if C.Created then return end
    C.BaseFrame:SetPoint("TOPLEFT")
    C.BaseFrame:SetPoint("BOTTOMLEFT")
    C.BaseFrame:SetWidth(100)
    C.ContentFrame:SetPoint("TOPLEFT",C.BaseFrame,"TOPRIGHT")
    C.ContentFrame:SetPoint("BOTTOMRIGHT")
    for i=1,4 do
        D.menuStrings[i]=C.ContentFrame:CreateFontString(nil,"OVERLAY")
        D.menuStrings[i]:SetFontObject(C.EtherFont)
        D.menuStrings[i]:SetText(string.format("%s - %s",D.Slash[i],D.Slash[i+4]))
        if i==1 then
            D.menuStrings[i]:SetPoint("TOP",0,-30)
        else
            D.menuStrings[i]:SetPoint("TOP",D.menuStrings[i-1],"BOTTOM",0,-5)
        end
    end
end
local function Border()
    if C.Created then return end
    C.Created=true
    F:MainBorder(C.MainFrame,1,2,3,4)
    C.BorderFrames[5]=C.ContentFrame:CreateTexture(nil,"BORDER")
    C.BorderFrames[5]:SetColorTexture(0.67,0.67,0.67)
    C.BorderFrames[5]:SetPoint("TOPLEFT",-1,1)
    C.BorderFrames[5]:SetPoint("BOTTOMLEFT",-1,-1)
    C.BorderFrames[5]:SetWidth(1)
end
function C:Main()
    if C.Created then return end
    local frame=C.MainFrame
    frame:SetFrameStrata("TOOLTIP")
    C.MainFrame=frame
    frame.bg=frame:CreateTexture(nil,"BACKGROUND")
    frame.bg:SetAllPoints()
    frame.bg:SetColorTexture(0.1,0.1,0.1)
    frame:Hide()
    frame:SetScript("OnHide",function()
        C:ToggleUnlock(0)
        if C.DropdownMenu then
            C.DropdownMenu:Hide()
        end
        if C.DropdownText then
            C.DropdownText:SetAlpha(1)
        end
        if C.InputText then
            C.InputText:SetText("")
        end
        C:ToggleBorder(0.67,0.67,0.67)
        for _,v in ipairs(C.ChildFrames) do
            v:Hide()
        end
        F:MenuStringsAlpha(1)
        F:CleanUpButtons(0)
        if C.ImportBox then
            C.ImportBox:ClearFocus()
            C.ImportBox:SetText("Paste import data here...")
        end
        if C.InputLine then
            C.InputLine:Hide()
        end
        if C.IsMovable then return end
        D.DB["CONFIG"][3]=0
    end)
    Base()
    Child()
    Border()
    local unlock=F:PanelButton(frame,60,20,"Lock","BOTTOMLEFT",C.BaseFrame,"BOTTOMLEFT")
    unlock:SetScript("OnClick",function()
        if not C.GridFrame then
            F:SetupGridFrame()
        end
        if not C.GridFrame:IsShown() then
            C:ToggleUnlock(1)
        else
            C:ToggleUnlock(0)
        end
    end)
    local close=F:PanelButton(frame,60,20,"Close","BOTTOMRIGHT",C.BaseFrame,"BOTTOMRIGHT")
    close:SetScript("OnClick",function()
        frame:Hide()
        D.DB["CONFIG"][3]=0
    end)
    D:ApplyFramePosition(frame)
    F:SetupDrag(frame)
end
function C:ToggleUnlock(number)
    if not C.GridFrame then
        F:SetupGridFrame()
    end
    local index=F:BinaryCondition(number)
    C.IsMovable=index
    C.GridFrame:SetShown(index)
    C.ToolFrame:SetShown(index)
    C.InfoFrame:SetShown(index)
    if D.A.raid.tex then
        D.A.raid.tex:SetShown(index)
    end
    if D.A.pet.tex then
        D.A.pet.tex:SetShown(index)
    end
    if D.DB[6][12]==1 then
        F:HideCastBar(1,index)
    end
    if D.DB[6][13]==1 then
        F:HideCastBar(2,index)
    end
    C.StatusTooltip=index
end
function S.EventFrame:PLAYER_LOGIN()
    self:UnregisterEvent("PLAYER_LOGIN")
    self:RegisterEvent("PLAYER_LOGOUT")
    if C_ChatInfo.IsAddonMessagePrefixRegistered(C.EtherPrefix) then
        if IsInGuild() then
            C_ChatInfo.SendAddonMessage(C.EtherPrefix,C.EtherVersion,"GUILD")
        end
    end
    F:HideBlizzard()
    F:SetupSlash()
    F:ToolTipInitialize()
    F:SetupHeaderBackground(D.A.raid)
    F:SetupHeaderBackground(D.A.pet)
    for index=1,6 do
        F:CreateUnitButtons(index)
        if D.DB[6][index]==0 then
            F:DeactivateUnitButton(index)
        end
    end
    if D.DB[6][4]==1 then
        F:PetCondition()
    end
    if UnitAffectingCombat("player") then
        S.EventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    else
        S.EventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    end
    F:RosterEnable()
    F:CreateGroupHeader()
    F:CreatePetHeader()
    for index=1,2 do
        D.castBar[index]=F:SetupCastBar()
        D.castBar[index].index=index+11
        D.castBar[index].unit=D:PosUnit(index)
        modelBtn[index]:SetUnit(D:PosUnit(index))
        modelBtn[index]:SetPortraitZoom(1)
        modelBtn[index]:SetCamDistanceScale(1.5)
        F:SetupButtonBackground(modelBtn[index])
        if index==1 then
            F:MainBorder(modelBtn[index],31,32,33,34)
        else
            F:MainBorder(modelBtn[index],35,36,37,38)
            modelBtn[index]:SetAttribute("unit","target")
            RegisterUnitWatch(modelBtn[index])
        end
        D:ApplyFramePosition(modelBtn[index])
        F:SetupDrag(modelBtn[index])
    end
    if D.DB[6][12]==1 then
        F:CastEnable(1)
    end
    if D.DB[6][13]==1 then
        F:CastEnable(2)
    end
    if C.InfoFrame then
        F:MainBorder(C.InfoFrame,12,13,14,15)
        D:ApplyFramePosition(C.InfoFrame)
        F:SetupDrag(C.InfoFrame)
    end
    if F:BinaryCondition(D.DB["CONFIG"][3]) then
        C:ToggleUser()
        C_Timer.After(0.1,function()
            C.MainFrame:SetShown(true)
        end)
    end
    if C.ToolFrame then
        F:MainBorder(C.ToolFrame,6,7,8,9)
        D:ApplyFramePosition(C.ToolFrame)
        F:SetupDrag(C.ToolFrame)
    end
    D:MergeAnalyse()
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
    C_Timer.After(1.5,function()
        SetPerfectUIScale()
    end)
end