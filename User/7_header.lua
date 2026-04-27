local D,F,_,C=unpack(select(2,...))
local function OnHeader(self,index,data)
    local parent=C.ChildFrames[7]
    if not parent then return end
    if index<=3 then
        D.DB["CONFIG"][11]=index
        parent.sort:SetText("Sort by: "..data)
        F:Fire(1,index)
    elseif index<=5 then
        D.DB["CONFIG"][12]=index
        parent.direction:SetText("Direction: "..data)
        F:Fire(1,index)
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
    local data,config={"GROUP","CLASS","ASSIGNEDROLE","BOTTOM","TOP"},{}
    for _,v in ipairs(data) do
        config[#config+1]=v
    end
    local dropdown=F:CreateEtherDropdown(parent,130,"Select Method",config,OnHeader)
    dropdown:SetPoint("CENTER")
    local sort=parent:CreateFontString(nil,"OVERLAY")
    parent.sort=sort
    sort:SetFontObject(C.EtherFont)
    sort:SetText("Sort By: "..data[DB["CONFIG"][11]])
    sort:SetPoint("BOTTOMLEFT",dropdown,"TOPLEFT",0,10)
    local direction=parent:CreateFontString(nil,"OVERLAY")
    parent.direction=direction
    direction:SetFontObject(C.EtherFont)
    direction:SetText("Direction: "..data[DB["CONFIG"][12]])
    direction:SetPoint("BOTTOMLEFT",sort,"TOPLEFT",0,10)
    C.MainButtons[5][1]:Disable()
    C.MainButtons[5][2]:Disable()
end
