local D,F,_,C=unpack(select(2,...))
local eColor="|cffcc66ffEther|r "
local function OnProfileChange(self,_,data)
    if data==D:GetProfileName() then return end
    D:SwitchProfile(data)
    self.v:SetText(data)
    D.menuStrings[8]:SetText(string.format("%s %s","Profile ",data))
    for _,v in ipairs(C.ChildFrames) do
        v:Hide()
    end
end
local function CreateImportBox(parent)
    if C.TransferBox then return end
    local frame=CreateFrame("Frame",nil,parent,"BackdropTemplate")
    frame:SetPoint("TOPRIGHT")
    frame:SetSize(220,parent:GetHeight())
    frame:SetBackdrop({
        bgFile="Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
        tile=true,
        tileSize=16,
        edgeSize=16,
        insets={left=4,right=4,top=4,bottom=4}
    })
    frame:SetBackdropColor(0.1,0.1,0.1,0.8)
    frame:SetBackdropBorderColor(0.4,0.4,0.4)
    local box=CreateFrame("EditBox",nil,frame)
    C.TransferBox=box
    box:SetPoint("TOPLEFT",frame,"TOPLEFT",8,-8)
    box:SetPoint("BOTTOMRIGHT",frame,"BOTTOMRIGHT",-8,8)
    box:SetMultiLine(true)
    box:SetAutoFocus(false)
    box:SetClipsChildren(true)
    box:SetFontObject(C.EtherFont)
    box:SetText("Paste import data here...")
    box:SetTextColor(0.7,0.7,0.7)
    box:SetScript("OnMouseWheel",function(self,delta)
        local current=self:GetText()
        if delta>0 then
            self:SetCursorPosition(0)
        else
            self:SetCursorPosition(#current)
        end
    end)
    box:SetScript("OnEditFocusGained",function(self)
        if self:GetText()=="Paste export data here..." then
            self:SetText("")
            self:SetTextColor(1,1,1)
        end
        self:HighlightText()
    end)
    box:SetScript("OnEditFocusLost",function(self)
        if self:GetText()=="" then
            self:SetText("Paste import data here...")
            self:SetTextColor(0.7,0.7,0.7)
        end
    end)
    box:SetScript("OnEscapePressed",function(self)
        self:ClearFocus()
    end)
    return box
end
local function Profile(self,status)
    if self.created or type(status)~="boolean" then return end
    self.created=status
    if not C.ChildFrames[6].created then
        F:Fire(6+50,C.ChildFrames[6],true)
    end
    local dropdown=F:CreateEtherDropdown(self,130,"Select Profile",D:GetProfileList(),OnProfileChange)
    C.ProfileDropdown=dropdown
    dropdown:SetPoint("TOPLEFT",5,-5)
    dropdown.v:SetText(D:GetProfileName())
    local input=F:LineInput(self,180,20)
    C.InputLine=input
    input:SetPoint("BOTTOMLEFT",25,15)
    input:Hide()
    input:SetScript("OnEnterPressed",function()
        local newName=input:GetText()
        if newName and newName~="" and newName~="Enter name and press enter" then
            local success,msg=D:RenameProfile(D:GetProfileName(),newName)
            if success then
                C:EtherInfo(eColor,msg)
                input:Hide()
                input:ClearFocus()
                input:SetText("")
            else
                C:EtherInfo(eColor,msg)
            end
        end
        input:ClearFocus()
    end)
    local transfer=CreateImportBox(self)
    local create=F:EtherPanelButton(self,60,25,"New","TOPLEFT",dropdown,"BOTTOMLEFT",5,-13,0,1,0)
    local copy=F:EtherPanelButton(self,60,25,"Copy","LEFT",create,"RIGHT")
    local reset=F:EtherPanelButton(self,60,25,"Reset","LEFT",copy,"RIGHT",0,0,1,0,0)
    local rename=F:EtherPanelButton(self,60,25,"Rename","TOPLEFT",create,"BOTTOMLEFT",0,-13)
    local delete=F:EtherPanelButton(self,60,25,"Delete","LEFT",rename,"RIGHT",0,0,1,0,0)
    local export=F:EtherPanelButton(self,60,25,"Export","TOPLEFT",rename,"BOTTOMLEFT",0,-13)
    local import=F:EtherPanelButton(self,60,25,"Import","LEFT",export,"RIGHT")
    create:SetScript("OnClick",function()
        input:Show()
        input:SetText("Enter name and press enter")
        if input:GetScript("OnEnterPressed") then
            input:SetScript("OnEnterPressed",nil)
        end
        input:SetScript("OnEnterPressed",function()
            local name=input:GetText()
            if name and name~="" and name~="Enter name and press enter" then
                local success,msg=D:CreateProfile(name)
                if success then
                    C:EtherInfo(eColor..msg)
                    dropdown:SetOptions(D:GetProfileList())
                    dropdown.v:SetText(D:GetProfileName())
                    input:Hide()
                    input:ClearFocus()
                    input:SetText("")
                    input:SetScript("OnEnterPressed",nil)
                else
                    C:EtherInfo(eColor..msg)
                end
            end
            input:ClearFocus()
        end)
    end)
    delete:SetScript("OnClick",function()
        local profileToDelete=D:GetProfileName()
        F:PopupBoxSetup()
        C.PopupBox.font:SetText("Delete profile |cffcc66ff"..profileToDelete.."|r ?")
        C.PopupCallback:SetScript("OnClick",function()
            local success,msg=D:DeleteProfile(profileToDelete)
            if success then
                C:EtherInfo(eColor..msg)
                C.PopupBox:SetShown(false)
                C.MainFrame:SetShown(true)
                C.PopupBox.font:SetText()
                D.ProfileRefresh()
            else
                C:EtherInfo(eColor..msg)
                C.PopupBox:SetShown(false)
                C.MainFrame:SetShown(true)
            end
        end)
    end)
    copy:SetScript("OnClick",function()
        local name=D:GetProfileName()
        if name and name~="" then
            local success,msg=D:CopyProfile(name)
            if success then
                dropdown:SetOptions(D:GetProfileList())
                dropdown.v:SetText(name)
                C:EtherInfo(eColor..msg)
            else
                C:EtherInfo(eColor..msg)
            end
        end
    end)
    rename:SetScript("OnClick",function()
        input:Show()
        input:SetText("Enter name and press enter")
        if input:GetScript("OnEnterPressed") then
            input:SetScript("OnEnterPressed",nil)
        end
        input:SetScript("OnEnterPressed",function()
            local newName=input:GetText()
            if newName and newName~="" and newName~="Enter name and press enter" then
                local success,msg=D:RenameProfile(D:GetProfileName(),newName)
                if success then
                    dropdown:SetOptions(D:GetProfileList())
                    dropdown.v:SetText(D:GetProfileName())
                    C:EtherInfo(eColor.."name changed to "..D:GetProfileName())
                    input:Hide()
                    input:ClearFocus()
                    input:SetText("")
                    input:SetScript("OnEnterPressed",nil)
                else
                    C:EtherInfo(eColor..msg)
                end
            end
            input:ClearFocus()
        end)
    end)
    reset:SetScript("OnClick",function()
        F:PopupBoxSetup()
        local profileToRest=D:GetProfileName()
        C.PopupBox.font:SetText("Reset profile |cffcc66ff"..profileToRest.."|r ?")
        C.PopupCallback:SetScript("OnClick",function()
            local success,msg=D:ResetProfile()
            if success then
                C:EtherInfo("|cffcc66ffEther|r "..msg)
                C.PopupBox:SetShown(false)
                C.MainFrame:SetShown(true)
            else
                C:EtherInfo(eColor..msg)
                C.PopupBox:SetShown(false)
                C.MainFrame:SetShown(true)
            end
        end)
    end)
    export:SetScript("OnClick",function()
        local encoded,err=D:ExportProfile()
        if encoded then
            transfer:SetText(encoded)
        else
            C:EtherInfo("|cffff0000Export failed:|r "..err)
        end
    end)
    import:SetScript("OnClick",function()
        if not transfer then return end
        local info=transfer:GetText()
        if not info or info=="" or info=="Paste import data here..." then return end
        local success,msg=D:ImportProfile(info)
        if success then
            dropdown:SetOptions(D:GetProfileList())
            dropdown.v:SetText(D:GetProfileName())
            C:EtherInfo(eColor..msg)
            transfer:SetText("Paste import data here...")
        else
            C:EtherInfo("|cffff0000No data to import|r")
        end
    end)
end
F:RegisterCallbackByIndex(Profile,8+50)