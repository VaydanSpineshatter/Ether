local D,F,_,C=unpack(select(2,...))
local GetInventoryItemDurability=GetInventoryItemDurability
local mfloor,sformat,tconcat=math.floor,string.format,table.concat
local UpdateAddOnMemoryUsage=UpdateAddOnMemoryUsage
local GetAddOnMemoryUsage,GetItemCount=GetAddOnMemoryUsage,GetItemCount
local GetFramerate,GetUnitSpeed=GetFramerate,GetUnitSpeed
local function ConsumaCount(str,number,status,status2)
    return sformat(str,GetItemCount(number,status,status2))
end
local dPct
local function Durability()
    local tCur,tMax=0,0
    for i=1,19 do
        local cur,max=GetInventoryItemDurability(i)
        if cur and max then
            tCur=tCur+cur
            tMax=tMax+max
        end
    end
    if tMax>0 then
        dPct=(tCur/tMax)*100
        return dPct
    end
end
function F:AddonUsage()
    if not C.EtherInfo then return end
    local data=F.GetTbl()
    UpdateAddOnMemoryUsage()
    Durability()
    local speed=GetUnitSpeed("player")
    local mem=GetAddOnMemoryUsage("Ether")
    local fps=mfloor(GetFramerate())
    data[#data+1]=ConsumaCount("Battle Elixir Count: |cffffff00%d|r",D.DB["CONFIG"][7] or "-",false,false)
    data[#data+1]=ConsumaCount("Guardian Elixir Count: |cffffff00%d|r",D.DB["CONFIG"][8] or "-",false,false)
    data[#data+1]=ConsumaCount("Food Count: |cffffff00%d|r",D.DB["CONFIG"][9] or "-",false,false)
    data[#data+1]=ConsumaCount("MainHand Charges: |cffffff00%d|r",D.DB["CONFIG"][10] or "-",false,true)
    data[#data+1]=sformat("Durability: |cffffff00%d%%|r",dPct)
    data[#data+1]=sformat("Speed: |cffffff00%d%%|r",speed/7*100)
    data[#data+1]=sformat("|cffffff00FPS: |r%s   -   |cffCC66FFMEM: |r%s Kb",fps,mfloor(mem))
    C:EtherInfo(tconcat(data,'\n'))
    F.RelTbl(data)
end

--22825
--32067
--27666
--22521
