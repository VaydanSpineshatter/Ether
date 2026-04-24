local D,F,_,C,_=unpack(select(2,...))
local pairs,ipairs,tinsert,sformat=pairs,ipairs,table.insert,string.format
local iK={D.iIconPath[1],D.iIconPath[2],D.iIconPath[3],D.iIconPath[5],D.iIconPath[6],D.iIconPath[7],D.iIconPath[8],D.iIconPath[9],D.iIconPath[10],D.iIconPath[12],D.iIconPath[13]}
local function OnIndicatorSelect(self,data)
    if data.index and data.value then
        for _,btn in pairs(C.IndicatorFrame.cube) do
            btn:Enable()
        end
        C.Indi=data.index
        self.text:SetText(data.value)
        F:UpdateIndicatorsPos(C.Indi,iK[C.Indi])
    end
end
function F:Indicators(index)
    local parent=C.ChildFrames[index]
    if parent.Created then return end
    parent.Created=true
    for i,opt in ipairs(D.iIconTable) do
        local btn=CreateFrame("CheckButton",nil,parent,"InterfaceOptionsCheckButtonTemplate")
        if i==1 then
            btn:SetPoint("TOPLEFT",parent,"TOPLEFT",10,-40)
        else
            btn:SetPoint("TOPLEFT",C.MainButtons[3][i-1],"BOTTOMLEFT",0,0)
        end
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
            F:IndicatorsToggleIcon(i)
            F:IndicatorToggleEvent(i)
        end)
        C.MainButtons[3][i]=btn
    end
    local indicatorList={}
    for i,v in ipairs(D.iIconTable) do
        tinsert(indicatorList,{text=v,value=v,index=i})
    end
    local dropdown=F:CreateEtherDropdown(parent,160,"Select Indicator",indicatorList,OnIndicatorSelect)
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
    local confirm=F:EtherPanelButton(preview,60,25,"Confirm","TOP",parent,"TOP",65,0)
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
function F:UpdateIndicatorsPos(n)
    if not n then
        return
    end
    local icon=iK[n]
    local data=D.DB[20][n]
    if not data then
        return
    end
    local indicator=C.IndicatorFrame
    indicator.preview.icon:SetTexture(icon)
    if n==6 then
        indicator.preview.icon:SetTexCoord(0.75,1,0.25,0.5)
    elseif n==10 then
        indicator.preview.icon:SetTexCoord(20/64,39/64,22/64,41/64)
    else
        indicator.preview.icon:SetTexCoord(0.08,0.92,0.08,0.92)
    end
    indicator.s:SetValue(data[4])
    if indicator.s.v then
        indicator.s.v:SetText(sformat("%.1f px",data[4]))
    end
    for pos,btn in pairs(indicator.cube) do
        if pos==data[1] then
            btn.bg:SetColorTexture(0.8,0.6,0,0.5)
            btn:Enable()
        else
            btn.bg:SetColorTexture(0.2,0.2,0.2,0.5)
            btn:Enable()
        end
    end
    indicator.x:SetValue(data[2])
    if indicator.x.v then
        indicator.x.v:SetText(sformat("%.0f px",data[2]))
    end
    indicator.y:SetValue(data[3])
    if indicator.y.v then
        indicator.y.v:SetText(sformat("%.0f px",data[3]))
    end
    UpdateIcon(n)
end