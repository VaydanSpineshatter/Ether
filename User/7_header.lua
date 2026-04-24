local D,F,_,C,_=unpack(select(2,...))

local function OnHeaderSort(_,data)
    local parent=C.ChildFrames[7]
    if not parent then return end
    if data.index<=3 then
        D.DB["CONFIG"][11]=data.index
        parent.sort:SetText("Sort by: "..data.text)
        F:Fire(1,data.index)
    elseif data.index<=5 then
        D.DB["CONFIG"][12]=data.index
        parent.direction:SetText("Direction: "..data.text)
        F:Fire(1,data.index)
    end
end

function F:Header(index)
    local parent=C.ChildFrames[index]
    if parent.Created then return end
    parent.Created=true
    local headerData={"RaidHeader","PetHeader","Health-Pct","Power-Pct"}
    local DB=D.DB
    for i,opt in ipairs(headerData) do
        local btn=CreateFrame("CheckButton",nil,parent,"InterfaceOptionsCheckButtonTemplate")
        if i==1 then
            btn:SetPoint("TOPLEFT",5,-5)
        else
            btn:SetPoint("TOPLEFT",C.MainButtons[5][i-1],"BOTTOMLEFT",0,0)
        end
        btn:SetSize(18,18)
        btn.label=btn:CreateFontString(nil,"OVERLAY")
        btn.label:SetFontObject(C.EtherFont)
        btn.label:SetText(opt)
        btn.label:SetPoint("LEFT",btn,"RIGHT",10,0)
        btn:SetChecked(DB[5][i]==1)
        btn:SetScript("OnClick",function(self)
            local checked=self:GetChecked()
            DB[5][i]=checked and 1 or 0
            F:UpdateText(i)
        end)
        C.MainButtons[5][i]=btn
    end
    local Config,Data={},{"GROUP","CLASS","ASSIGNEDROLE","BOTTOM","TOP"}
    for key,name in ipairs(Data) do
        table.insert(Config,{text=name,index=key})
    end
    local dropdown=F:CreateEtherDropdown(parent,130,"Select Method",Config,OnHeaderSort)
    dropdown:SetPoint("CENTER")
    local sort=parent:CreateFontString(nil,"OVERLAY")
    parent.sort=sort
    sort:SetFontObject(C.EtherFont)
    sort:SetText("Sort By: "..Data[DB["CONFIG"][11]])
    sort:SetPoint("BOTTOMLEFT",dropdown,"TOPLEFT",0,10)
    local direction=parent:CreateFontString(nil,"OVERLAY")
    parent.direction=direction
    direction:SetFontObject(C.EtherFont)
    direction:SetText("Direction: "..Data[DB["CONFIG"][12]])
    direction:SetPoint("BOTTOMLEFT",sort,"TOPLEFT",0,10)
end
