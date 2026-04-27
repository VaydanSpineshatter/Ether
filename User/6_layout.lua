local D,F,_,C=unpack(select(2,...))
local raidBtn,soloBtn,sformat,pairs,ipairs,indexKey=D.raidBtn,D.soloBtn,string.format,pairs,ipairs
local function SetDefaultValue(index,wl,hl,w,h,s,a)
    if not index then return end
    local pos=D.Default[21][indexKey]
    wl:SetText(pos[6])
    hl:SetText(pos[7])
    w.v:SetText(sformat("%.1f px",pos[6]))
    w:SetValue(pos[6])
    h.v:SetText(sformat("%.1f px",pos[7]))
    h:SetValue(pos[7])
    s.v:SetText(sformat("%.1f px",pos[8]))
    s:SetValue(pos[8])
    a.v:SetText(sformat("%.1f px",pos[9]))
    a:SetValue(pos[9])
end
local function OnBarSelect(self,index,data)
    for _,v in ipairs(C.MainButtons[6]) do
        if v then v:Hide() end
    end
    indexKey=index
    local panel=C.ChildFrames[6]
    panel.default:Show()
    self.text:SetText(data)
    C.MainButtons[6][index].label:SetText(data)
    C.MainButtons[6][index]:Show()
    panel.wl:SetText(D.DB[21][index][6])
    panel.hl:SetText(D.DB[21][index][7])
    panel.w.v:SetText(sformat("%.1f px",D.DB[21][index][6]))
    panel.w:SetValue(D.DB[21][index][6])
    panel.h.v:SetText(sformat("%.1f px",D.DB[21][index][7]))
    panel.h:SetValue(D.DB[21][index][7])
    panel.s.v:SetText(sformat("%.1f px",D.DB[21][index][8]))
    panel.s:SetValue(D.DB[21][index][8])
    panel.a.v:SetText(sformat("%.1f px",D.DB[21][index][9]))
    panel.a:SetValue(D.DB[21][index][9])
end
local function OnBarConsum(self,index,data)
    local panel=C.ChildFrames[6]
    indexKey=index+6
    self.text:SetText(data)
    panel.consuma:SetText(D.DB["CONFIG"][indexKey])
    panel.consuma.v:SetText(data)
    panel.consuma:Show()
    panel.consuma.v:Show()
end
local function OnGroupJoined(self,index,data)
    D.DB["CONFIG"][13]=data
    self.text:SetText(D.DB["CONFIG"][13])
end
local function OnRemoved(self,index)
    F:RemoveByIndex(index)
    self:SetOptions(D.DB["USER"])
end
function F:ProcessUserData(index)
    if not index or type(index)~="number" then return end
    if index==18 then
        D:ApplyFramePosition(C.EtherIcon)
    elseif index==17 then
        D:ApplyFramePosition(C.ToolFrame)
    elseif index==16 then
        D:ApplyFramePosition(C.InfoFrame)
    elseif index==15 then
        D:ApplyFramePosition(D.modelBtn[2])
    elseif index==14 then
        D:ApplyFramePosition(D.modelBtn[1])
    elseif index==13 then
        D:ApplyFramePosition(D.castBar[2])
    elseif index==12 then
        D:ApplyFramePosition(D.castBar[1])
    elseif index==10 or index==11 then
        D.A.raid:SetScale(D.DB[21][indexKey][8])
        D.A.raid:SetAlpha(D.DB[21][indexKey][9])
        for _,btn in pairs(raidBtn) do
            btn:SetWidth(D.DB[21][indexKey][6])
            btn:SetHeight(D.DB[21][indexKey][7])
        end
    elseif index<7 then
        if soloBtn[index] then
            soloBtn[index]:SetWidth(D.DB[21][indexKey][6])
            soloBtn[index]:SetHeight(D.DB[21][indexKey][7])
            soloBtn[index]:SetScale(D.DB[21][indexKey][8])
            soloBtn[index]:SetAlpha(D.DB[21][indexKey][9])
        end
    end
end
function F:Layout(index)
    local parent=C.ChildFrames[index]
    if parent.Created then return end
    parent.Created=true
    local layout={"player","target","targettarget","pet","pettarget","focus",
                  "custom1","custom2","custom3","raidButtons","petButtons","CastBar1","CastBar2","playerModel",
                  "targetModel","InfoFrame","Tooltip","EtherIcon","Battle Elixir","Guardian Elixir","Food","MainHand","TANK","HEALER","DAMAGER","NONE"}
    local object,data,role={},{},{}
    for i,v in ipairs(layout) do
        if i>22 then
            role[#role+1]=v
        elseif i>18 then
            data[#data+1]=v
        else
            object[#object+1]=v
        end
    end
    local objectDropdown=F:CreateEtherDropdown(parent,120,"Frame",object,OnBarSelect)
    local dataDropdown=F:CreateEtherDropdown(parent,120,"Consum",data,OnBarConsum)
    local roleDropdown=F:CreateEtherDropdown(parent,120,D.DB["CONFIG"][13] or "Role",role,OnGroupJoined)
    local removeDropdown=F:CreateEtherDropdown(parent,120,"Remove", D.DB["USER"],OnRemoved,true)
    objectDropdown:SetPoint("TOPLEFT",5,-5)
    dataDropdown:SetPoint("TOPRIGHT",-5,-5)
    roleDropdown:SetPoint("BOTTOMLEFT",15,35)
    removeDropdown:SetPoint("LEFT",roleDropdown,"RIGHT",10,0)
    C.RemoveDropdown = removeDropdown
    parent.roleDropdown=roleDropdown
    local wl,hl=F:LineInput(parent,100,20),F:LineInput(parent,100,20)
    parent.wl,parent.hl=wl,hl
    wl:SetPoint("TOP",parent,"TOP",0,-55)
    wl:SetScript("OnEnterPressed",function(self)
        local width=tonumber(self:GetText())
        D.DB[21][indexKey][6]=width
        F:ProcessUserData(indexKey)
        parent.w.v:SetText(tostring(self:GetText()))
        parent.w:SetValue(tostring(self:GetText()))
        self:ClearFocus()
    end)
    hl:SetPoint("LEFT",wl,"RIGHT",20,0)
    hl:SetScript("OnEnterPressed",function(self)
        local height=tonumber(self:GetText())
        D.DB[21][indexKey][7]=height
        F:ProcessUserData(indexKey)
        parent.h.v:SetText(tostring(self:GetText()))
        parent.h:SetValue(tostring(self:GetText()))
        self:ClearFocus()
    end)
    wl.v=parent:CreateFontString(nil,"OVERLAY")
    wl.v:SetFont("Interface\\AddOns\\Ether\\Media\\venite.ttf",7,"OUTLINE")
    wl.v:SetText("Width")
    wl.v:SetPoint("BOTTOMLEFT",wl,"TOPLEFT",0,5)
    hl.v=parent:CreateFontString(nil,"OVERLAY")
    hl.v:SetFont("Interface\\AddOns\\Ether\\Media\\venite.ttf",7,"OUTLINE")
    hl.v:SetText("Height")
    hl.v:SetPoint("BOTTOMLEFT",hl,"TOPLEFT",0,5)
    local s=F:CreateSlider(wl,"Scale","%.0f px","0.1","2",0.1,"TOPLEFT","BOTTOMLEFT",0,-20,
            function(self,value)
                wl:ClearFocus()
                hl:ClearFocus()
                D.DB[21][indexKey][8]=value
                self:SetValue(D.DB[21][indexKey][8])
                F:ProcessUserData(indexKey)
                self.v:SetText(sformat("%.1f px",value))
            end)
    parent.s=s
    local a=F:CreateSlider(hl,"Alpha","%.0f px","0.1","1",0.1,"TOPLEFT","BOTTOMLEFT",0,-20,
            function(self,value)
                wl:ClearFocus()
                hl:ClearFocus()
                D.DB[21][indexKey][9]=value
                self:SetValue(D.DB[21][indexKey][9])
                F:ProcessUserData(indexKey)
                self.v:SetText(sformat("%.1f px",value))
            end)
    parent.a=a
    local w=F:CreateSlider(s,"Width","%.1f px","15","800",1,"TOPLEFT","BOTTOMLEFT",0,-20,
            function(self,value)
                wl:ClearFocus()
                hl:ClearFocus()
                D.DB[21][indexKey][6]=value
                wl:SetText(D.DB[21][indexKey][6])
                self:SetValue(D.DB[21][indexKey][6])
                F:ProcessUserData(indexKey)
                self.v:SetText(sformat("%.0f px",value))
            end)
    parent.w=w
    local h=F:CreateSlider(a,"Height","%.1f px","15","800",1,"TOPLEFT","BOTTOMLEFT",0,-20,
            function(self,value)
                wl:ClearFocus()
                hl:ClearFocus()
                D.DB[21][indexKey][7]=value
                hl:SetText(D.DB[21][indexKey][7])
                self:SetValue(D.DB[21][indexKey][7])
                F:ProcessUserData(indexKey)
                self.v:SetText(sformat("%.0f px",value))
            end)
    parent.h=h
    local default=F:PanelButton(parent,60,20,"Default","TOPRIGHT",parent,"BOTTOMRIGHT",-10,30)
    default:SetScript("OnClick",function()
        SetDefaultValue(indexKey,wl,hl,w,h,s,a)
    end)
    default:Hide()
    parent.default=default
    for i,opt in ipairs(layout) do
        local btn=CreateFrame("CheckButton",nil,parent,"InterfaceOptionsCheckButtonTemplate")
        btn:Hide()
        btn:SetPoint("TOPLEFT",parent,"TOPLEFT",10,-40)
        btn:SetSize(18,18)
        btn.label=btn:CreateFontString(nil,"OVERLAY")
        btn.label:SetFontObject(C.EtherFont)
        btn.label:SetText(opt)
        btn.label:SetPoint("LEFT",btn,"RIGHT",8,1)
        btn:SetChecked(D.DB[6][i]==1)
        btn:SetScript("OnClick",function(self)
            local checked=self:GetChecked()
            D.DB[6][i]=checked and 1 or 0
            if i==12 then
                if D.DB[6][12]==1 then
                    F:CastEnable(1)
                else
                    F:CastDisable(1)
                end
            end
            if i==13 then
                if D.DB[6][13]==1 then
                    F:CastEnable(2)
                else
                    F:CastDisable(2)
                end
            end
            if i<7 then
                if D.DB[6][i]==1 then
                    F:ActivateUnitButton(i)
                else
                    F:DeactivateUnitButton(i)
                end
            end
        end)
        C.MainButtons[6][i]=btn
    end
    local print=F:EtherPanelButton(parent,50,25,"Print","TOPLEFT",parent,"BOTTOMLEFT",20,30)
    print:SetScript("OnClick",function()
        F:PrintGUID()
    end)
    local clear=F:EtherPanelButton(parent,50,25,"Clear","LEFT",print,"RIGHT",5,0)
    clear:SetScript("OnClick",function()
        if D:TableSize(D.DB["USER"])==0 then
            C:EtherInfo("No guid available to delete")
            return
        end
        F:PopupBoxSetup()
        C.PopupBox.font:SetText("Clear Ignore Data ?")
        C.PopupCallback:SetScript("OnClick",function()
            table.wipe(D.DB["USER"])
            C:EtherInfo("Ignore list is empty")
            C.PopupBox:SetShown(false)
            C.MainFrame:SetShown(true)
        end)
    end)
    local consuma=F:LineInput(parent,160,20)
    consuma:Hide()
    parent.consuma=consuma
    consuma:SetPoint("LEFT",clear,"RIGHT",40,0)
    consuma:SetNumeric(true)
    consuma:SetScript("OnEnterPressed",function(self)
        local spellId=tonumber(self:GetText())
        if spellId then
            D.DB["CONFIG"][indexKey]=spellId
        end
        self:ClearFocus()
    end)
    consuma.v=parent:CreateFontString(nil,"OVERLAY")
    consuma.v:SetFontObject(C.EtherFont)
    consuma.v:Hide()
    consuma.v:SetPoint("BOTTOMLEFT",consuma,"TOPLEFT",0,5)
end