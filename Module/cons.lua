local D,F,_,C=unpack(select(2,...))
local mfloor,sformat,tconcat,GetInventoryItemDurability,twipe,data=math.floor,string.format,table.concat,GetInventoryItemDurability,table.wipe,{}
local UpdateAddOnMemoryUsage,GetFramerate,GetUnitSpeed,GetAddOnMemoryUsage,GetItemCount,dPct=UpdateAddOnMemoryUsage,GetFramerate,GetUnitSpeed,GetAddOnMemoryUsage,GetItemCount
local function ConsumaCount(str,number,status,status2)
    return sformat(str,GetItemCount(number,status,status2))
end
local function Durability()
    local tC,tM=0,0
    for i=1,19 do
        local c,m=GetInventoryItemDurability(i)
        if c and m then
            tC=tC+c
            tM=tM+m
        end
    end
    if tM>0 then
        dPct=(tC/tM)*100
        return dPct
    end
end
function F:AddonUsage()
    if not C.EtherInfo then return end
    UpdateAddOnMemoryUsage()
    Durability()
    local mem=GetAddOnMemoryUsage("Ether")
    data[#data+1]=ConsumaCount("Battle Elixir Count: |cffffff00%d|r",D.DB["CONFIG"][7] or "-",false,false)
    data[#data+1]=ConsumaCount("Guardian Elixir Count: |cffffff00%d|r",D.DB["CONFIG"][8] or "-",false,false)
    data[#data+1]=ConsumaCount("Food Count: |cffffff00%d|r",D.DB["CONFIG"][9] or "-",false,false)
    data[#data+1]=ConsumaCount("MainHand Charges: |cffffff00%d|r",D.DB["CONFIG"][10] or "-",false,true)
    data[#data+1]=sformat("Durability: |cffffff00%d%%|r",dPct)
    data[#data+1]=sformat("Speed: |cffffff00%d%%|r",GetUnitSpeed("player")/7*100)
    data[#data+1]=sformat("|cffffff00FPS: |r%s   -   |cffCC66FFMEM: |r%s Kb",mfloor(GetFramerate()),mfloor(mem))
    C:EtherInfo(tconcat(data,'\n'))
    twipe(data)
end
--22825,32067,27666,22521