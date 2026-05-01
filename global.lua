_G["BINDING_HEADER_ETHER"]="Ether"
local _,F,_,C=unpack(select(2,...))
function Ether_Config()
    if not C.ToggleUser then return end
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