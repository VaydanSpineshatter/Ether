local _,Ether=...
--local DB = Ether.DB[1002]["Test"]


local function UpdateIndicators(number)
    if not number then
        return
    end
    local data=Ether.DB[1002][number]
    if not data then
        return
    end
    local indicator=Ether.UIPanel.Frames["INDICATORS"]
    indicator.preview.tex:ClearAllPoints()
    indicator.preview.tex:SetSize(data[4],data[4])
    indicator.preview.tex:SetPoint(data[1],indicator.preview.healthBar,data[1],data[2],data[3])
end

function Ether:UpdateIndicatorsPos(number,icon)
    if not number then
        return
    end
    local data=Ether.DB[1002][number]
    if not data then
        return
    end
    local indicator=Ether.UIPanel.Frames["INDICATORS"]

    indicator.preview.tex:SetTexture(icon)

    if number==5 then
        indicator.preview.tex:SetTexCoord(0.75,1,0.25,0.5)
    elseif number==9 then
        indicator.preview.tex:SetTexCoord(20/64,39/64,22/64,41/64)
    else
        indicator.preview.tex:SetTexCoord(0,1,0,1)
    end

    indicator.s:SetValue(data[4])
    if indicator.s.v then
        indicator.s.v:SetText(string.format("%.0f px",data[4]))
    end

    for pos,btn in pairs(indicator.cube) do
        if pos==data[1] then
            btn.bg:SetColorTexture(0.8,0.6,0,0.5)
        else
            btn.bg:SetColorTexture(0.2,0.2,0.2,0.5)
        end
    end

    indicator.x:SetValue(data[2])
    if indicator.x.v then
        indicator.x.v:SetText(string.format("%.0f",data[2]))
    end

    indicator.y:SetValue(data[3])
    if indicator.y.v then
        indicator.y.v:SetText(string.format("%.0f",data[3]))
    end

    UpdateIndicators(number)
end

local function Register()

end

local function Data()

end

local function Position()

end