local D,F,_,C=unpack(select(2,...))
function F:Blizzard(index)
    local parent=C.ChildFrames[index]
    if parent.Created then return end
    parent.Created=true
    local DB=D.DB
    local blizzard={"Hide Player frame","Hide Pet frame","Hide Target frame","Hide Focus frame","Hide CastBar",
                    "Hide Party","Hide Raid","Hide Raid Manager","Hide MicroMenu","Hide XP Bar","Hide BagsBar"}
    for i,opt in ipairs(blizzard) do
        local btn=CreateFrame("CheckButton",nil,parent,"InterfaceOptionsCheckButtonTemplate")
        if i==1 then
            btn:SetPoint("TOPLEFT",5,-5)
        else
            btn:SetPoint("TOPLEFT",C.MainButtons[2][i-1],"BOTTOMLEFT",0,0)
        end
        btn:SetSize(18,18)
        btn.label=btn:CreateFontString(nil,"OVERLAY")
        btn.label:SetFontObject(C.EtherFont)
        btn.label:SetText(opt)
        btn.label:SetPoint("LEFT",btn,"RIGHT",8,1)
        btn:SetChecked(DB[2][i]==1)
        btn:SetScript("OnClick",function(self)
            local checked=self:GetChecked()
            DB[2][i]=checked and 1 or 0
            F:StatusBlizzard(i)
        end)
        C.MainButtons[2][i]=btn
    end
end