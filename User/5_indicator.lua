local D,F,S,C=unpack(select(2,...))
local event,pairs,ipairs,sformat,iK=S.EventFrame,pairs,ipairs,string.format,{}
local function callback(index)
    if event:IsEventRegistered(D.iEvent[index]) then
        C.MainButtons[3][index].v:SetTextColor(0,1,0)
    else
        if index==3 and D.DB[1][4]==1 then
            F:StartFlash()
        end
        C.MainButtons[3][index].v:SetTextColor(1,0,0)
    end
end
local function OnIndicatorSelect(self,index,data)
    for _,v in ipairs(C.MainButtons[3]) do
        if v then v:Hide() end
    end
    for _,btn in pairs(C.IndicatorFrame.cube) do
        btn:Enable()
    end
    C.Indi=index
    self.text:SetText(data)
    F:UpdateIndicatorsPos(C.Indi)
    C.MainButtons[3][index]:Show()
    callback(index)
end
function F:Indicators(index)
    local parent=C.ChildFrames[index]
    if parent.Created then return end
    parent.Created=true
    for i=1,13 do
        if i>11 then
            iK[#iK+1]=D.iIconPath[i]
        elseif i<=10 and i>=5 then
            iK[#iK+1]=D.iIconPath[i]
        elseif i<4 then
            iK[#iK+1]=D.iIconPath[i]
        end
    end
    for i,opt in ipairs(D.iIconTable) do
        local btn=CreateFrame("CheckButton",nil,parent,"InterfaceOptionsCheckButtonTemplate")
        btn:SetPoint("TOPLEFT",parent,"TOPLEFT",10,-40)
        btn:SetSize(18,18)
        btn.tex=btn:CreateTexture(nil,"OVERLAY")
        btn.tex:SetTexture(iK[i])
        if i==6 then
            btn.tex:SetTexCoord(0.75,1,0.25,0.5)
        elseif i==10 then
            btn.tex:SetTexCoord(20/64,39/64,22/64,41/64)
        else
            btn.tex:SetTexCoord(0,1,0,1)
        end
        btn:Hide()
        btn.tex:SetSize(18,18)
        btn.tex:SetPoint("LEFT",btn,"RIGHT",15)
        btn.v=btn:CreateFontString(nil,"OVERLAY")
        btn.v:SetFontObject(C.EtherFont)
        btn.v:SetText(opt)
        btn.v:SetPoint("LEFT",btn.tex,"RIGHT",15,0)
        btn:SetChecked(D.DB[3][i]==1)
        btn:SetScript("OnClick",function(self)
            local checked=self:GetChecked()
            D.DB[3][i]=checked and 1 or 0
            F:IndicatorToggleEvent(i)
            F:IndicatorsToggleIcon(i)
            callback(i)
            F:IndicatorsFullUpdateBtn()
        end)
        C.MainButtons[3][i]=btn
    end
    local indicatorList={}
    for _,v in ipairs(D.iIconTable) do
        indicatorList[#indicatorList+1]=v
    end
    local dropdown=F:CreateEtherDropdown(parent,140,"Select Indicator",indicatorList,OnIndicatorSelect)
    C.IndicatorFrame.dropdown=dropdown
    dropdown:SetPoint("TOPLEFT",5,-5)
    local cube,preview=F:CreatePreview(parent,"BOTTOMRIGHT")
    C.IndicatorFrame.cube=cube
    C.IndicatorFrame.preview=preview
    C.IndicatorFrame.preview.icon:SetScale(1.5)
    for _,btn in pairs(cube) do
        btn:SetScript("OnClick",function(self)
            if C.Indi then
                D.DB[20][C.Indi][1]=self.position
                for _,b in pairs(cube) do
                    b:GetScript("OnLeave")(b)
                    F:UpdateIndicatorsPos(C.Indi)
                end
            end
        end)
        btn:SetScript("OnEnter",function(self)
            self.bg:SetColorTexture(0.3,0.3,0.3,0.9)
        end)
        btn:SetScript("OnLeave",function(self)
            local data=C.Indi and D.DB[20][C.Indi]
            if data and data[1]==self.position then
                self.bg:SetColorTexture(0.8,0.6,0,0.4)
            else
                self.bg:SetColorTexture(0.2,0.2,0.2,0.8)
            end
        end)
        btn:GetScript("OnLeave")(btn)
    end
    local confirm=F:EtherPanelButton(preview,60,25,"Confirm","TOP",parent,"TOP",65,-5)
    confirm:SetScript("OnClick",function()
        if C.Indi then
            F:SavePosition(C.Indi)
        end
    end)
    local x=F:CreateSlider(parent,"X-Off","%.0f px","-18","18",1,"TOP","TOP",6,-90,
            function(self,value)
                if C.Indi then
                    D.DB[20][C.Indi][2]=value
                    self:SetValue(D.DB[20][C.Indi][2])
                    F:UpdateIndicatorsPos(C.Indi)
                    self.v:SetText(sformat("%.0f px",value))
                end
            end)
    C.IndicatorFrame.x=x
    local y=F:CreateSlider(parent,"Y-Off","%.0f px","-18","18",1,"TOP","TOP",120,-90,
            function(self,value)
                if C.Indi then
                    D.DB[20][C.Indi][3]=value
                    self:SetValue(D.DB[20][C.Indi][3])
                    F:UpdateIndicatorsPos(C.Indi)
                    self.v:SetText(sformat("%.0f px",value))
                end
            end)
    C.IndicatorFrame.y=y
    local s=F:CreateSlider(x,"Scale","6 px","4","20",1,"TOPLEFT","BOTTOMLEFT",0,-25,
            function(self,value)
                if C.Indi then
                    D.DB[20][C.Indi][4]=value
                    self:SetValue(D.DB[20][C.Indi][4])
                    F:UpdateIndicatorsPos(C.Indi)
                    self.v:SetText(sformat("%.1f px",value))
                end
            end)
    C.IndicatorFrame.s=s
end
local function UpdateIcon(n)
    if not n then
        return
    end
    local data=D.DB[20][n]
    if not data then
        return
    end
    local indicator=C.IndicatorFrame
    indicator.preview.icon:Hide()
    indicator.preview.icon:ClearAllPoints()
    indicator.preview.icon:SetSize(data[4],data[4])
    indicator.preview.icon:SetPoint(data[1],indicator.preview,data[1],data[2],data[3])
    indicator.preview.icon:Show()
end
function F:UpdateIndicatorsPos(spell)
    if not spell then return end
    local icon=iK[spell]
    local c=D.DB[20][spell]
    if not c then return end
    local indicator=C.IndicatorFrame
    indicator.preview.icon:SetTexture(icon)
    if spell==6 then
        indicator.preview.icon:SetTexCoord(0.75,1,0.25,0.5)
    elseif spell==10 then
        indicator.preview.icon:SetTexCoord(20/64,39/64,22/64,41/64)
    else
        indicator.preview.icon:SetTexCoord(0.08,0.92,0.08,0.92)
    end
    indicator.s:SetValue(c[4])
    if indicator.s.v then
        indicator.s.v:SetText(sformat("%.1f px",c[4]))
    end
    F:UpdateCube(indicator.cube,c,1)
    indicator.x:SetValue(c[2])
    if indicator.x.v then
        indicator.x.v:SetText(sformat("%.0f px",c[2]))
    end
    indicator.y:SetValue(c[3])
    if indicator.y.v then
        indicator.y.v:SetText(sformat("%.0f px",c[3]))
    end
    UpdateIcon(spell)
end