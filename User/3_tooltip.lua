local D,F,_,C,_=unpack(select(2,...))
function F:Tooltip(index)
    local parent=C.ChildFrames[index]
    if parent.Created then return end
    parent.Created=true
    local DB=D.DB
    local tbl={"AFK","DND","PVP","Resting","Realm","Level","Class","Guild","Role","Creature","Race",
               "RaidTarget","Reaction"}
    for i,opt in ipairs(tbl) do
        local btn=CreateFrame("CheckButton",nil,parent,"InterfaceOptionsCheckButtonTemplate")
        if i==1 then
            btn:SetPoint("TOPLEFT",parent,"TOPLEFT",5,-5)
        else
            btn:SetPoint("TOPLEFT",C.MainButtons[4][i-1],"BOTTOMLEFT")
        end
        btn:SetSize(18,18)
        btn.label=btn:CreateFontString(nil,"OVERLAY")
        btn.label:SetFontObject(C.EtherFont)
        btn.label:SetText(opt)
        btn.label:SetPoint("LEFT",btn,"RIGHT",8,1)
        btn:SetChecked(DB[4][i]==1)
        btn:SetScript("OnClick",function(self)
            local checked=self:GetChecked()
            DB[4][i]=checked and 1 or 0
        end)
        C.MainButtons[4][i]=btn
    end
end
