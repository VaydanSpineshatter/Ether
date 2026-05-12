local D,F,_,C=unpack(select(2,...))
local raidBtn,petBtn,soloBtn,sformat,pairs,ipairs,indexKey=D.raidBtn,D.petBtn,D.soloBtn,string.format,pairs,ipairs
local function SetDefaultValue(self,index)
    if not index then return end
    local default=D.Default[21][index]
    if not default then return end
    self.wl:SetText(default[6])
    self.w.v:SetText(sformat("%.1f px",default[6]))
    self.w:SetValue(default[6])
    self.hl:SetText(default[7])
    self.h.v:SetText(sformat("%.1f px",default[7]))
    self.h:SetValue(default[7])
    self.s.v:SetText(sformat("%.1f px",default[8]))
    self.s:SetValue(default[8])
    self.a.v:SetText(sformat("%.1f px",default[9]))
    self.a:SetValue(default[9])
    self.wl:ClearFocus()
    self.hl:ClearFocus()
end
local function callback(index)
    if D.DB[6][index]==1 then
        C.MainButtons[6][index].v:SetTextColor(0,1,0)
    elseif D.DB[6][index]==0 then
        C.MainButtons[6][index].v:SetTextColor(1,0,0)
    end
end
local function OnBarSelect(self,index,data)
    callback(index)
    for _,v in ipairs(C.MainButtons[6]) do
        if v then v:Hide() end
    end
    indexKey=index
    local panel=C.ChildFrames[6]
    panel.default:Show()
    self.v:SetText(data)
    C.MainButtons[6][index].v:SetText(data)
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
    panel.wl:ClearFocus()
    panel.hl:ClearFocus()
end
local function OnBarConsum(self,index,data)
    for _,v in ipairs(C.MainButtons[6]) do
        if v then v:Hide() end
    end
    local panel=C.ChildFrames[6]
    indexKey=index+6
    self.v:SetText(data)
    panel.consuma:SetText(D.DB["CONFIG"][indexKey])
    panel.consuma.v:SetText(data)
    panel.consuma:Show()
    panel.consuma.v:Show()
end
function F:UpdateRole(role)
    if UnitAffectingCombat("player") then return end
    C:EtherInfo("Role changed to "..role or "DAMAGER")
    UnitSetRole("player",role or "DAMAGER")
end
local function OnGroupJoined(self,_,data)
    for _,v in ipairs(C.MainButtons[6]) do
        if v then v:Hide() end
    end
    D.DB["CONFIG"][13]=data
    self.v:SetText(data)
    F:UpdateRole(data)
end
local function OnRemoved(_,index)
    F:RemoveByIndex(index)
end
local function ProcessWidthBtn(index)
    if type(index)~="number" then return end
    if index==18 then
        C.EtherIcon:SetWidth(D.DB[21][index][6])
    elseif index==17 then
        C.ToolFrame:SetWidth(D.DB[21][index][6])
    elseif index==16 then
        C.InfoFrame:SetWidth(D.DB[21][index][6])
    elseif index<=15 and index>=14 then
        D.modelBtn[index-13]:SetWidth(D.DB[21][index][6])
    elseif index<=13 and index>=12 then
        D.castBar[index-11]:SetWidth(D.DB[21][index][6])
    elseif index==10 then
        for _,btn in pairs(raidBtn) do
            if btn then
                btn:SetWidth(D.DB[21][index][6])
            end
        end
    elseif index==11 then
        for _,btn in pairs(petBtn) do
            if btn then
                btn:SetWidth(D.DB[21][index][6])
            end
        end
    elseif index<=6 then
        soloBtn[index]:SetWidth(D.DB[21][index][6])
    end
end
local function ProcessHeightBtn(index)
    if type(index)~="number" then return end
    if index==18 then
        C.EtherIcon:SetHeight(D.DB[21][index][7])
    elseif index==17 then
        C.ToolFrame:SetHeight(D.DB[21][index][7])
    elseif index==16 then
        C.InfoFrame:SetHeight(D.DB[21][index][7])
    elseif index<=15 and index>=14 then
        D.modelBtn[index-13]:SetHeight(D.DB[21][index][7])
    elseif index<=13 and index>=12 then
        D.castBar[index-11]:SetHeight(D.DB[21][index][7])
    elseif index==10 then
        for _,btn in pairs(raidBtn) do
            if btn then
                btn:SetHeight(D.DB[21][index][7])
            end
        end
    elseif index==11 then
        for _,btn in pairs(petBtn) do
            if btn then
                btn:SetHeight(D.DB[21][index][7])
            end
        end
    elseif index<=6 then
        soloBtn[index]:SetHeight(D.DB[21][index][7])
    end
end
local function ProcessScaleBtn(index)
    if type(index)~="number" then return end
    if index==18 then
        C.EtherIcon:SetScale(D.DB[21][index][8])
    elseif index==17 then
        C.ToolFrame:SetScale(D.DB[21][index][8])
    elseif index==16 then
        C.InfoFrame:SetScale(D.DB[21][index][8])
    elseif index<=15 and index>=14 then
        D.modelBtn[index-13]:SetScale(D.DB[21][index][8])
    elseif index<=13 and index>=12 then
        D.castBar[index-11]:SetScale(D.DB[21][index][8])
    elseif index==10 then
        D.A.raid:SetScale(D.DB[21][index][8])
    elseif index==11 then
        D.A.pet:SetScale(D.DB[21][index][8])
    elseif index<=6 then
        soloBtn[index]:SetScale(D.DB[21][index][8])
    end
end
local function ProcessAlphaBtn(index)
    if type(index)~="number" then return end
    if index==18 then
        C.EtherIcon:SetAlpha(D.DB[21][index][9])
    elseif index==17 then
        C.ToolFrame:SetAlpha(D.DB[21][index][9])
    elseif index==16 then
        C.InfoFrame:SetAlpha(D.DB[21][index][9])
    elseif index<=15 and index>=14 then
        D.modelBtn[index-13]:SetAlpha(D.DB[21][index][9])
    elseif index<=13 and index>=12 then
        D.castBar[index-11]:SetAlpha(D.DB[21][index][9])
    elseif index==10 then
        D.A.raid:SetAlpha(D.DB[21][index][9])
    elseif index==11 then
        D.A.pet:SetAlpha(D.DB[21][index][9])
    elseif index<=6 then
        soloBtn[index]:SetAlpha(D.DB[21][index][9])
    end
end
local function Layout(self,status)
    if self.created or type(status)~="boolean" then return end
    self.created=status
    local layout={"player","target","targettarget","pet","pettarget","focus",
                  "custom1","custom2","custom3","raidButtons","petButtons","CastBar1","CastBar2","playerModel",
                  "targetModel","InfoFrame","Tooltip","EtherIcon","Battle Elixir","Guardian Elixir","Food","MainHand","TANK","HEALER","DAMAGER"}
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
    local objectDropdown=F:CreateEtherDropdown(self,120,"Frame",object,OnBarSelect)
    local dataDropdown=F:CreateEtherDropdown(self,120,"Consum",data,OnBarConsum)
    local roleDropdown=F:CreateEtherDropdown(self,120,D.DB["CONFIG"][13] or "DAMAGER",role,OnGroupJoined)
    local removeDropdown=F:CreateEtherDropdown(self,120,"Remove",D.DB["USER"],OnRemoved,true)
    C.RemoveDropdown=removeDropdown
    self.roleDropdown=roleDropdown
    local wl,hl=F:LineInput(self,100,20),F:LineInput(self,100,20)
    self.wl,self.hl=wl,hl
    wl:SetPoint("TOP",self,"TOP",0,-55)
    wl:SetScript("OnEnterPressed",function()
        local i=indexKey
        local width=tonumber(wl:GetText())
        D.DB[21][i][6]=width
        C.ChildFrames[6].w.v:SetText(tostring(wl:GetText()))
        C.ChildFrames[6].w:SetValue(tostring(wl:GetText()))
        ProcessWidthBtn(i)
        wl:ClearFocus()

    end)
    hl:SetPoint("LEFT",wl,"RIGHT",20,0)
    hl:SetScript("OnEnterPressed",function()
        local i=indexKey
        local height=tonumber(hl:GetText())
        D.DB[21][i][7]=height
        C.ChildFrames[6].h.v:SetText(tostring(hl:GetText()))
        C.ChildFrames[6].h:SetValue(tostring(hl:GetText()))
        ProcessHeightBtn(i)
        hl:ClearFocus()
    end)
    wl.v=self:CreateFontString(nil,"OVERLAY")
    wl.v:SetFont("Interface\\AddOns\\Ether\\Media\\venite.ttf",7,"OUTLINE")
    wl.v:SetText("Width")
    wl.v:SetPoint("BOTTOMLEFT",wl,"TOPLEFT",0,5)
    hl.v=self:CreateFontString(nil,"OVERLAY")
    hl.v:SetFont("Interface\\AddOns\\Ether\\Media\\venite.ttf",7,"OUTLINE")
    hl.v:SetText("Height")
    hl.v:SetPoint("BOTTOMLEFT",hl,"TOPLEFT",0,5)
    local s=F:CreateSlider(wl,"Scale","%.0f px","0.1","2",0.1,"TOPLEFT","BOTTOMLEFT",0,-20,
            function(_,value)
                local i=indexKey
                D.DB[21][i][8]=value
                C.ChildFrames[6].s:SetValue(value)
                C.ChildFrames[6].s.v:SetText(sformat("%.1f px",value))
                ProcessScaleBtn(i)
            end)
    self.s=s
    local a=F:CreateSlider(hl,"Alpha","%.0f px","0.1","1",0.1,"TOPLEFT","BOTTOMLEFT",0,-20,
            function(_,value)
                local i=indexKey
                D.DB[21][i][9]=value
                C.ChildFrames[6].a:SetValue(value)
                C.ChildFrames[6].a.v:SetText(sformat("%.1f px",value))
                ProcessAlphaBtn(i)
            end)
    self.a=a
    local w=F:CreateSlider(s,"Width","%.1f px","15","800",1,"TOPLEFT","BOTTOMLEFT",0,-20,
            function(_,value)
                local i=indexKey
                D.DB[21][i][6]=value
                wl:SetText(value)
                C.ChildFrames[6].w.v:SetText(sformat("%.0f px",value))
                C.ChildFrames[6].w:SetValue(value)
                ProcessWidthBtn(i)
            end)
    self.w=w
    local h=F:CreateSlider(a,"Height","%.1f px","15","800",1,"TOPLEFT","BOTTOMLEFT",0,-20,
            function(_,value)
                local i=indexKey
                D.DB[21][i][7]=value
                hl:SetText(value)
                C.ChildFrames[6].h.v:SetText(sformat("%.0f px",value))
                C.ChildFrames[6].h:SetValue(value)
                ProcessHeightBtn(i)
            end)
    self.h=h
    local default=F:EtherPanelButton(self,60,20,"Default","TOPRIGHT",self,"TOPRIGHT",0,-5)
    default:SetScript("OnClick",function()
        if indexKey then
            SetDefaultValue(self,indexKey,wl,hl,w,h,s,a)
        end
    end)
    default:Hide()
    self.default=default
    F:CreateCheckButton(self,6,layout,function(i,cb)
        callback(i)
        if i<=6 then
            F:ActivateUnitButton(cb and i)
            F:DeactivateUnitButton(not cb and i)
        end
        if i>=12 and i<=13 then
            F:CastEnable(cb and (i-11))
            F:CastDisable(not cb and (i-11))
        end
    end,true,"TOPLEFT",self,"TOPLEFT",10,-40)
    local consuma=F:LineInput(self,160,20)
    consuma:Hide()
    self.consuma=consuma
    consuma:SetNumeric(true)
    consuma:SetScript("OnEnterPressed",function()
        local spellId=tonumber(consuma:GetText())
        if spellId then
            D.DB["CONFIG"][indexKey]=spellId
        end
        consuma:ClearFocus()
    end)
    consuma.v=self:CreateFontString(nil,"OVERLAY")
    consuma.v:SetFontObject(C.EtherFont)
    consuma.v:Hide()
    objectDropdown:SetPoint("TOPLEFT",5,-5)
    roleDropdown:SetPoint("BOTTOMLEFT",5,5)
    removeDropdown:SetPoint("LEFT",roleDropdown,"RIGHT",10,0)
    dataDropdown:SetPoint("LEFT",removeDropdown,"RIGHT",10,0)
    consuma:SetPoint("BOTTOMLEFT",roleDropdown,"TOPLEFT",0,5)
    consuma.v:SetPoint("BOTTOMLEFT",consuma,"TOPLEFT",0,5)
    local print=F:EtherPanelButton(self,30,25,"Print","LEFT",consuma.v,"RIGHT",5,0)
    print:SetScript("OnClick",function()
        F:PrintGUID()
    end)
    local clear=F:EtherPanelButton(self,30,25,"Wipe","LEFT",print,"RIGHT",10,0,1,0,0)
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
    local repair=F:EtherPanelButton(self,50,25,"Repair","LEFT",clear,"RIGHT",20,0)
    self.repair=repair
    repair:SetScript("OnClick",function()
        D.DB["CONFIG"][17]=F:ToggleBinary(D.DB["CONFIG"][17])
        F.UpdateStatus(repair,17)
    end)
    local guild=F:EtherPanelButton(self,50,25,"Guild","LEFT",repair,"RIGHT",5,0)
    self.guild=guild
    guild:SetScript("OnClick",function()
        D.DB["CONFIG"][18]=F:ToggleBinary(D.DB["CONFIG"][18])
        F.UpdateStatus(guild,18)
    end)
    C.MainButtons[6][10]:Disable()
    C.MainButtons[6][11]:Disable()
    F.UpdateStatus(repair,17)
    F.UpdateStatus(guild,18)
end
F:RegisterCallbackByIndex(Layout,6+50)