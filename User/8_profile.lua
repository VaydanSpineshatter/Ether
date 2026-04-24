local D,F,_,C,_=unpack(select(2,...))
local ipairs=ipairs
local eColor="|cffcc66ffEther|r "

local function OnProfileChange(self,data)
    if data.text==D:GetProfileName() then return end
    D:SwitchProfile(data.text)
    self.text:SetText(data.text)
end

local function GetUpdatedProfileList(parts)
    local data=F.GetTbl()
    for key,name in ipairs(D:GetProfileList(data)) do
        parts[#parts+1]={text=name,index=key}
    end
    F.RelTbl(data)
    return parts
end

function F:Profile(index)
    local parent=C.ChildFrames[index]
    if parent.Created then return end
    parent.Created=true
    local profile={}
    local data=F.GetTbl()
    for key,name in ipairs(D:GetProfileList(data)) do
        profile[#profile+1]={text=name,index=key}
    end
    F.RelTbl(data)
    local dropdown=F:CreateEtherDropdown(parent,130,"Select Profile",profile,OnProfileChange)
    dropdown:SetPoint("TOPLEFT",5,-5)
    dropdown.text:SetText(D:GetProfileName())
    local transfer=CreateFrame("Frame",nil,parent,"BackdropTemplate")
    transfer:SetPoint("TOPRIGHT")
    transfer:SetSize(220,parent:GetHeight())
    transfer:SetBackdrop({
        bgFile="Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
        tile=true,
        tileSize=16,
        edgeSize=16,
        insets={left=4,right=4,top=4,bottom=4}
    })
    transfer:SetBackdropColor(0.1,0.1,0.1,0.8)
    transfer:SetBackdropBorderColor(0.4,0.4,0.4)
    local input=F:LineInput(parent,180,20)
    C.InputLine=input
    input:SetPoint("BOTTOMLEFT",25,15)
    input:Hide()
    input:SetScript("OnEnterPressed",function(self)
        local newName=input:GetText()
        if newName and newName~="" and newName~="Enter name and press enter" then
            local success,msg=D:RenameProfile(D:GetProfileName(),newName)
            if success then
                local parts=F:GetTbl()
                local freshData=GetUpdatedProfileList(parts)
                dropdown:SetOptions(freshData)
                dropdown.text:SetText(D:GetProfileName())
                C:EtherInfo(eColor,msg)
                self:Hide()
                self:ClearFocus()
                self:SetText("")
                F.RelTbl(parts)
            else
                C:EtherInfo(eColor,msg)
            end
        end
        self:ClearFocus()
    end)
    local create=F:EtherPanelButton(parent,60,25,"New","TOPLEFT",dropdown,"BOTTOMLEFT",5,-13)
    local copy=F:EtherPanelButton(parent,60,25,"Copy","LEFT",create,"RIGHT")
    local reset=F:EtherPanelButton(parent,60,25,"Reset","LEFT",copy,"RIGHT")
    local rename=F:EtherPanelButton(parent,60,25,"Rename","TOPLEFT",create,"BOTTOMLEFT",0,-13)
    local delete=F:EtherPanelButton(parent,60,25,"Delete","LEFT",rename,"RIGHT")
    local export=F:EtherPanelButton(parent,60,25,"Export","TOPLEFT",rename,"BOTTOMLEFT",0,-13)
    local import=F:EtherPanelButton(transfer,60,25,"Import","LEFT",export,"RIGHT")
    create:SetScript("OnClick",function()
        input:Show()
        input:SetText("Enter name and press enter")
        if input:GetScript("OnEnterPressed") then
            input:SetScript("OnEnterPressed",nil)
        end
        input:SetScript("OnEnterPressed",function(self)
            local name=input:GetText()
            if name and name~="" and name~="Enter name and press enter" then
                local success,msg=D:CreateProfile(name)
                if success then
                    local parts=F:GetTbl()
                    local freshData=GetUpdatedProfileList(parts)
                    dropdown:SetOptions(freshData)
                    dropdown.text:SetText(name)
                    C:EtherInfo(eColor,msg)
                    self:Hide()
                    self:ClearFocus()
                    self:SetText("")
                    self:SetScript("OnEnterPressed",nil)
                    D:SwitchProfile(name)
                    F.RelTbl(parts)
                else
                    C:EtherInfo(eColor,msg)
                end
            end
            self:ClearFocus()
        end)
    end)
    copy:SetScript("OnClick",function()
        local name=D:GetProfileName().." - Copy"
        if name and name~="" then
            local success,msg=D:CopyProfile(D:GetProfileName(),name)
            if success then
                local parts=F:GetTbl()
                local freshData=GetUpdatedProfileList(parts)
                dropdown:SetOptions(freshData)
                dropdown.text:SetText(name)
                C:EtherInfo(eColor,msg)
                D:SwitchProfile(name)
                F.RelTbl(parts)
            else
                C:EtherInfo(eColor,msg)
            end
        end
    end)
    rename:SetScript("OnClick",function()
        input:Show()
        input:SetText("Enter name and press enter")
        if input:GetScript("OnEnterPressed") then
            input:SetScript("OnEnterPressed",nil)
        end
        input:SetScript("OnEnterPressed",function(self)
            local newName=input:GetText()
            if newName and newName~="" and newName~="Enter name and press enter" then
                local success,msg=D:RenameProfile(D:GetProfileName(),newName)
                if success then
                    local parts=F:GetTbl()
                    local freshData=GetUpdatedProfileList(parts)
                    dropdown:SetOptions(freshData)
                    dropdown.text:SetText(D:GetProfileName())
                    C:EtherInfo(eColor,msg)
                    self:Hide()
                    self:ClearFocus()
                    self:SetText("")
                    self:SetScript("OnEnterPressed",nil)
                    D:SwitchProfile(newName)
                    F.RelTbl(parts)
                else
                    C:EtherInfo(eColor,msg)
                end
            end
            self:ClearFocus()
        end)
    end)
    delete:SetScript("OnClick",function()
        local profileToDelete=D:GetProfileName()
        if D:TableSize(_G["ETHER_DATABASE"]["PROFILES"])<=1 then
            C:EtherInfo("|cffcc66ffEther|r Cannot delete the last profile")
            return
        end
        if D:GetProfileName()=="DEFAULT" then
            C:EtherInfo("|cffcc66ffEther|r Cannot delete Default profile")
            return
        end
        F:PopupBoxSetup()
        C.PopupBox.font:SetText("Delete profile |cffcc66ff"..profileToDelete.."|r ?")
        C.PopupCallback:SetScript("OnClick",function()
            local success,msg=D:DeleteProfile(profileToDelete)
            if success then
                local parts=F:GetTbl()
                local freshData=GetUpdatedProfileList(parts)
                dropdown:SetOptions(freshData)
                dropdown.text:SetText(D:GetProfileName())
                C:EtherInfo(eColor..msg)
                C.PopupBox:SetShown(false)
                C.MainFrame:SetShown(true)
                C.PopupBox.font:SetText()
                F.RelTbl(parts)
            else
                C:EtherInfo(eColor..msg)
                C.PopupBox:SetShown(false)
                C.MainFrame:SetShown(true)
            end
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
                local parts=F:GetTbl()
                local freshData=GetUpdatedProfileList(parts)
                dropdown:SetOptions(freshData)
                dropdown.text:SetText(D:GetProfileName())
                C.PopupBox:SetShown(false)
                C.MainFrame:SetShown(true)
                F.RelTbl(parts)
            else
                C:EtherInfo(eColor..msg)
                C.PopupBox:SetShown(false)
                C.MainFrame:SetShown(true)
            end
        end)
    end)
    local importBox=F:CreateImportBox(transfer)
    export:SetScript("OnClick",function()
        local encoded=D:ExportProfileToClipboard()
        if encoded then
            importBox:SetText(encoded)
        end
    end)
    import:SetScript("OnClick",function()
        if not importBox then return end
        local info=importBox:GetText()
        if not info or info=="" or info=="Paste import data here..." then return end
        local success,msg=D:ImportProfile(info)
        if success then
            local parts=F:GetTbl()
            local freshData=GetUpdatedProfileList(parts)
            dropdown:SetOptions(freshData)
            dropdown.text:SetText(D:GetProfileName())
            C:EtherInfo(eColor,msg)
            D:SwitchProfile(D:GetProfileName())
            C.ImportBox:SetText("Paste import data here...")
            F.RelTbl(parts)
        else
            C:EtherInfo("|cffff0000No data to import|r")
        end
    end)
end
function F:CreateImportBox(backdrop)
    if C.ImportBox then return end
    local importBox=CreateFrame("EditBox",nil,backdrop)
    C.ImportBox=importBox
    importBox:SetPoint("TOPLEFT",backdrop,"TOPLEFT",8,-8)
    importBox:SetPoint("BOTTOMRIGHT",backdrop,"BOTTOMRIGHT",-8,8)
    importBox:SetMultiLine(true)
    importBox:SetAutoFocus(false)
    importBox:SetClipsChildren(true)
    importBox:SetFontObject(C.EtherFont)
    importBox:SetText("Paste import data here...")
    importBox:SetTextColor(0.7,0.7,0.7)
    importBox:SetScript("OnMouseWheel",function(self,delta)
        local current=self:GetText()
        if delta>0 then
            self:SetCursorPosition(0)
        else
            self:SetCursorPosition(#current)
        end
    end)
    importBox:SetScript("OnEditFocusGained",function(self)
        if self:GetText()=="Paste export data here..." then
            self:SetText("")
            self:SetTextColor(1,1,1)
        end
        self:HighlightText()
    end)
    importBox:SetScript("OnEditFocusLost",function(self)
        if self:GetText()=="" then
            self:SetText("Paste import data here...")
            self:SetTextColor(0.7,0.7,0.7)
        end
    end)
    importBox:SetScript("OnEscapePressed",function(self)
        self:ClearFocus()
    end)
    return importBox
end