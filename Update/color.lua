local D,F,_,C=unpack(select(2,...))
local sformat,tonumber,mfloor=string.format,tonumber,math.floor
local UnitClassBase,UnitPowerType,CStr=UnitClassBase,UnitPowerType,"|cff%02x%02x%02x"
local PColor={
    {0.0,'e0f7ff'},
    {0.2,'99ddff'},
    {0.4,'66bbff'},
    {0.6,'3399ff'},
    {1.0,'1a75ff'}
}
local HColor={
    {0.0,'ff0000'},
    {0.3,'ff4500'},
    {0.5,'ffa500'},
    {0.7,'ffd700'},
    {0.9,'adff2f'},
    {1.0,'00ff00'}
}
function F:GetClassColor(unit)
    if not unit then return end
    local classFilename=UnitClassBase(unit)
    local i=RAID_CLASS_COLORS[classFilename]
    local r,g,b
    if i then
        r,g,b=i.r,i.g,i.b
    else
        r,g,b=0.18,0.54,0.34
    end
    return r,g,b
end
function F:GetPowerColor(unit)
    local powerType,powerToken,rgbX,rgbY,rgbZ=UnitPowerType(unit)
    local i=PowerBarColor[powerToken]
    local r,g,b
    if i then
        r,g,b=i.r,i.g,i.b
    elseif not rgbX then
        i=PowerBarColor[powerType] or PowerBarColor["MANA"]
        r,g,b=i.r,i.g,i.b
    else
        r,g,b=rgbX,rgbY,rgbZ
    end
    return r,g,b
end
local function RGBToHex(r,g,b)
    return sformat(
            "ff%02x%02x%02x",
            mfloor(r*255+0.5),
            mfloor(g*255+0.5),
            mfloor(b*255+0.5)
    )
end
local function HexToRGB(hex)
    hex=hex:gsub('#','')
    local r=tonumber(hex:sub(1,2),16)/255
    local g=tonumber(hex:sub(3,4),16)/255
    local b=tonumber(hex:sub(5,6),16)/255
    return r,g,b
end
F.HexToRGB=HexToRGB
local function LeapColor(r1,g1,b1,r2,g2,b2,t)
    return r1+(r2-r1)*t,g1+(g2-g1)*t,b1+(b2-b1)*t
end
local function BuildGradientTable(colorDef)
    local steps={}
    for i=0,100 do
        local pct=i/100
        local prev,nextC
        for idx=1,#colorDef-1 do
            if pct>=colorDef[idx][1] and pct<=colorDef[idx+1][1] then
                prev=colorDef[idx]
                nextC=colorDef[idx+1]
                break
            end
        end
        if not prev then
            prev,nextC=colorDef[#colorDef-1],colorDef[#colorDef]
        end
        local pr,pg,pb=HexToRGB(prev[2])
        local nr,ng,nb=HexToRGB(nextC[2])
        local range=(nextC[1]-prev[1])
        local t=range>0 and (pct-prev[1])/range or 0

        local r,g,b=LeapColor(pr,pg,pb,nr,ng,nb,t)
        steps[i]=sformat(CStr,r*255,g*255,b*255)
    end
    return steps
end
local function ColorGradient(perc,...)
    if perc>=1 then
        local r,g,b=select(select('#',...)-2,...)
        return r,g,b
    elseif perc<=0 then
        local r,g,b=...
        return r,g,b
    end
    local num=select('#',...)/3
    local segment,relperc=math.modf(perc*(num-1))
    local r1,g1,b1,r2,g2,b2=select((segment*3)+1,...)
    return r1+(r2-r1)*relperc,g1+(g2-g1)*relperc,b1+(b2-b1)*relperc
end

local ColorState={
    spell=nil,
    button=nil,
    oldR=0,
    oldG=0,
    oldB=0,
    oldA=1
}

local lastR,lastG,lastB,lastA
local function UpdateAuraColor(r,g,b,a)
    if r==lastR and g==lastG and b==lastB and a==lastA then return end
    lastR,lastG,lastB,lastA=r,g,b,a
    if not ColorState.spell then return end
    local data=D.DB["CUSTOM"][ColorState.spell]
    data[2],data[3],data[4],data[5]=r,g,b,a
    if ColorState.button then
        ColorState.button.color.bg:SetColorTexture(r,g,b,a)
    end
    F:UpdateAuraList()
    F:UpdatePreview(ColorState.button)
end

local function OnColorChanged()
    local r,g,b=ColorPickerFrame:GetColorRGB()
    local a=ColorPickerFrame:GetColorAlpha()
    UpdateAuraColor(r,g,b,a)
end

local function OnCancel(p)
    if not p then return end
    UpdateAuraColor(p.r,p.g,p.b,p.a)
end

function F:ColorSelect(parent,anchor)
    if parent.color then return end
    local color=CreateFrame("Button",nil,parent)
    color:SetSize(60,15)
    color:SetPoint("TOPLEFT",anchor,"BOTTOMLEFT",0,-20)
    color.v=parent:CreateFontString(nil,"OVERLAY")
    color.v:SetFont("Interface\\AddOns\\Ether\\Media\\venite.ttf",7,"OUTLINE")
    color.v:SetPoint("TOPLEFT",anchor,"BOTTOMLEFT",0,-40)
    color.v:SetText("Color")
    color.bg=color:CreateTexture(nil,"BACKGROUND")
    color.bg:SetAllPoints()
    color.bg:SetColorTexture(1,1,0,1)
    color:SetScript("OnClick",function()
        if type(C.Spell)=="nil" then return end
        local data=D.DB["CUSTOM"][C.Spell]
        if not data then return end
        ColorState.spell=C.Spell
        ColorState.button=parent
        ColorState.oldR=data[2]
        ColorState.oldG=data[3]
        ColorState.oldB=data[4]
        ColorState.oldA=data[5]
        ColorPickerFrame:SetupColorPickerAndShow({
            swatchFunc=OnColorChanged,
            opacityFunc=OnColorChanged,
            cancelFunc=OnCancel,
            hasOpacity=true,
            opacity=ColorState.oldA,
            r=ColorState.oldR,
            g=ColorState.oldG,
            b=ColorState.oldB,
            previousValues=ColorState.oldColor
        })
    end)
    return color
end

D.PowerGradient=BuildGradientTable(PColor)
D.HealGradient=BuildGradientTable(HColor)
