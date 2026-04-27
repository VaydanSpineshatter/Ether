local D,F,_,C=unpack(select(2,...))
function F:Module(index)
    local parent=C.ChildFrames[index]
    if parent.Created then return end
    parent.Created=true
    local DB=D.DB
    local modules={"Icon","Msg","Msg+CLEU","Idle","Range","Indicators","Aura","Info","Tooltip","Name","Health","Power"}
    for i,opt in ipairs(modules) do
        local btn=CreateFrame("CheckButton",nil,parent,"OptionsBaseCheckButtonTemplate")
        if i==1 then
            btn:SetPoint("TOPLEFT",parent,5,-5)
        else
            btn:SetPoint("TOPLEFT",C.MainButtons[1][i-1],"BOTTOMLEFT",0,0)
        end
        btn:SetSize(18,18)
        btn.label=btn:CreateFontString(nil,"OVERLAY")
        btn.label:SetFontObject(C.EtherFont)
        btn.label:SetText(opt)
        btn.label:SetPoint("LEFT",btn,"RIGHT",10,0)
        btn:SetChecked(DB[1][i]==1)
        btn:SetScript("OnClick",function(self)
            local checked=self:GetChecked()
            DB[1][i]=checked and 1 or 0
            if i==1 then
                if DB[1][1]==1 then
                    F:IconEnable()
                else
                    F:IconDisable()
                end
            elseif i==2 then
                F:MsgEnable()
                if DB[1][2]==1 then
                    F:MsgEnable()
                else
                    F:MsgDisable()
                end
            elseif i==3 then
                if DB[1][3]==1 then
                    F:MsgCLEUEnable()
                else
                    F:MsgCLEUDisable()
                end
            elseif i==5 then
                if DB[1][5]==1 then
                    F:RangeEnable()
                else
                    F:RangeDisable()
                end
            elseif i==6 then
                if DB[1][6]==1 then
                    F:IndicatorsEnable()
                else
                    F:IndicatorsDisable()
                end
            elseif i==7 then
                if DB[1][7]==1 then
                    F:AuraEnable()
                else
                    F:AuraDisable()
                end
            elseif i==9 then
                if DB[1][9]==1 then
                    F:NameEnable()
                else
                    F:NameDisable()
                end
            elseif i==10 then
                if DB[1][10]==1 then
                    F:HealthEnable()
                else
                    F:HealthDisable()
                end
            elseif i==11 then
                if DB[1][11]==1 then
                    F:PowerEnable()
                else
                    F:PowerDisable()
                end
            end
        end)
        C.MainButtons[1][i]=btn
    end
end