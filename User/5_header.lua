local D,F,_,C,L=unpack(select(2,...))
local function OnHeader(_,index,data)
    local parent=C.ChildFrames[5]
    if not parent then return end
    if index<=3 then
        D.DB["CONFIG"][11]=index
        parent.sort:SetText("Sort by: "..data)
        F:Fire(22)
    elseif index<=5 then
        D.DB["CONFIG"][12]=index
        parent.direction:SetText("Direction: "..data)
        F:Fire(22)
    end
end
function F:Header(self,status)
    if self.created or type(status)~="boolean" then return end
    self.created=status
    local headerData={"RaidHeader","PetHeader",L.HEALTH_PCT,L.POWER_PCT}
    F:CreateCheckButton(self,5,headerData,function(i)
        F:UpdateText(i)
    end)
    local config={}
    for _,v in ipairs(D.header5) do
        config[#config+1]=v
    end
    local dropdown=F:CreateEtherDropdown(self,130,"Select Method",config,OnHeader)
    dropdown:SetPoint("CENTER")
    local sort=self:CreateFontString(nil,"OVERLAY")
    self.sort=sort
    sort:SetFontObject(C.EtherFont)
    sort:SetText(L.SORT_BY_H..D.header5[D.DB["CONFIG"][11]])
    sort:SetPoint("BOTTOMLEFT",dropdown,"TOPLEFT",0,10)
    local direction=self:CreateFontString(nil,"OVERLAY")
    self.direction=direction
    direction:SetFontObject(C.EtherFont)
    direction:SetText(L.DIRECTION_BY_H..D.header5[D.DB["CONFIG"][12]])
    direction:SetPoint("BOTTOMLEFT",sort,"TOPLEFT",0,10)
    C.MainButtons[5][1]:Disable()
    C.MainButtons[5][2]:Disable()
end