_G["BINDING_HEADER_ETHER"]="Ether"
local D,F,_,C=unpack(select(2,...))
function Ether_Config()
    if C.DropdownMenu and C.DropdownText then
        C.DropdownMenu:Hide()
        C.DropdownText:SetAlpha(1)
    end
    if not D.DB or not D.DB["CONFIG"] or not D.DB["CONFIG"][3] then return end
    D.DB["CONFIG"][3]=F:ToggleBinary(D.DB["CONFIG"][3])
    C:ToggleUser()
end
function Ether_Info()
    if not F.AddonUsage then return end
    F:AddonUsage()
end
function Ether_Target()
    if not F.ScanGUID then return end
    F:ScanGUID()
end
local category,layout=Settings.RegisterVerticalLayoutCategory("Ether")
Settings.RegisterAddOnCategory(category)
layout:AddInitializer(CreateSettingsButtonInitializer("Info","Info",Ether_Info,"Open Info",true))
layout:AddInitializer(CreateSettingsButtonInitializer("Config","Config",Ether_Config,"Open Configuration",true))
layout:AddInitializer(CreateSettingsButtonInitializer("Target","Target",Ether_Target,"Add/Remove GUID by Target",true))