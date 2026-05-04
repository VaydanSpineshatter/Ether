local D,F,_,C=unpack(select(2,...))
local UnitClassBase,UnitPowerType,CStr,sformat,tonumber,mfloor=UnitClassBase,UnitPowerType,"|cff%02x%02x%02x",string.format,tonumber,math.floor
local PColor={{0,'ff33a3'},{.2,'ff33da'},{.4,'c933ff'},{.6,'a333ff'},{.8,'7a33ff'},{.9,'4b33ff'},{1,'3370ff'}}
local HColor={{0,'ff0000'},{.2,'ff2a00'},{.4,'ff6a00'},{.6,'ffd000'},{.8,'adff2f'},{.9,'95ff00'},{1,'00ff00'}}
function F:GetClassColor(unit)
    if not unit then return end
    local classFilename=UnitClassBase(unit)
    local rC=RAID_CLASS_COLORS[classFilename] or RAID_CLASS_COLORS["PRIEST"]
    local r,g,b
    if rC then
        r,g,b=rC.r,rC.g,rC.b
    else
        r,g,b=0.18,0.54,0.34
    end
    return r,g,b
end
function F:GetPowerColor(unit)
    if not unit then return end
    local powerType,powerToken,rgbX,rgbY,rgbZ=UnitPowerType(unit)
    local pR=PowerBarColor[powerToken]
    local r,g,b
    if pR then
        r,g,b=pR.r,pR.g,pR.b
    elseif not rgbX then
        pR=PowerBarColor[powerType] or PowerBarColor["MANA"]
        r,g,b=pR.r,pR.g,pR.b
    else
        r,g,b=rgbX,rgbY,rgbZ
    end
    return r,g,b
end
local function RGBToHex(r,g,b,data)
    return sformat("|cff%02x%02x%02x%s|r",mfloor(r*255+0.5),mfloor(g*255+0.5),mfloor(b*255+0.5),data)
end
F.RGBToHex=RGBToHex
C.GuildIcon=CreateSimpleTextureMarkup(135026,18,18,0,0)
C.RestingIcon=CreateTextureMarkup("Interface\\CharacterFrame\\UI-StateIcon",24,24,24,24,0.0625,0.45,0.0625,0.45)
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
local function BuildGradientTable(cDef)
    local steps={}
    for i=0,100 do
        local pct=i/100
        local prev,nextC
        for idx=1,#cDef-1 do
            if pct>=cDef[idx][1] and pct<=cDef[idx+1][1] then
                prev=cDef[idx]
                nextC=cDef[idx+1]
                break
            end
        end
        if not prev then
            prev,nextC=cDef[#cDef-1],cDef[#cDef]
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
local function ColorGradient(per,...)
    if per>=1 then
        local r,g,b=select(select('#',...)-2,...)
        return r,g,b
    elseif per<=0 then
        local r,g,b=...
        return r,g,b
    end
    local num=select('#',...)/3
    local seg,rel=math.modf(per*(num-1))
    local r1,g1,b1,r2,g2,b2=select((seg*3)+1,...)
    return r1+(r2-r1)*rel,g1+(g2-g1)*rel,b1+(b2-b1)*rel
end
F.ColorGradient=ColorGradient
local ColorState={
    spell=nil,
    button=nil,
    oldR=0,
    oldG=0,
    oldB=0,
    oldA=1
}
local lastR,lastG,lastB,lastA
local function UpdateAuraColor(r,g,b)
    if r==lastR and g==lastG and b==lastB then return end
    lastR,lastG,lastB=r,g,b
    if not ColorState.spell then return end
    local data=D.DB["CUSTOM"][ColorState.spell]
    data[2],data[3],data[4]=r,g,b
    if ColorState.button then
        ColorState.button.color.bg:SetColorTexture(r,g,b)
    end
    F:UpdateAuraList()
    F:UpdatePreview(D.DB["CUSTOM"],C.ChildFrames[7],C.Spell)
end
local function UpdateAuraOpacity(a)
    if a==lastA then return end
    lastA=a
    if not ColorState.spell then return end
    local data=D.DB["CUSTOM"][ColorState.spell]
    data[5]=a
    if ColorState.button then
        ColorState.button.color.bg:SetAlpha(a)
    end
    F:UpdateAuraList()
    F:UpdatePreview(D.DB["CUSTOM"],C.ChildFrames[7],C.Spell)
end
local function OnColor()
    local r,g,b=ColorPickerFrame:GetColorRGB()
    UpdateAuraColor(r,g,b)
end
local function OnOpacity()
    local a=ColorPickerFrame:GetColorAlpha()
    UpdateAuraOpacity(a)
end
local function OnCancel(p)
    if not p then return end
    UpdateAuraColor(p.r,p.g,p.b,p.a)
end
function F:ColorSelect(parent)
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
        swatchFunc=OnColor,
        opacityFunc=OnOpacity,
        cancelFunc=OnCancel,
        hasOpacity=true,
        opacity=ColorState.oldA,
        r=ColorState.oldR,
        g=ColorState.oldG,
        b=ColorState.oldB,
        previousValues=ColorState.oldColor
    })
end
D.PowerGradient=BuildGradientTable(PColor)
D.HealGradient=BuildGradientTable(HColor)