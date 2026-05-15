-- Copyright 2026 VaydanSpineshatter
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
local _,addon=...
--[[local D,F,S,C,L=unpack(select(2,...))==Data,Func,Event,Config,Localisation]]
addon[1],addon[2],addon[3],addon[4],addon[5]={},{},{},{},{}
local D,S,C=addon[1],addon[3],addon[4]
D.A,D.H,D.DB,D.petBtn,D.raidBtn,D.customBtn,D.modelBtn,D.castBar,D.soloBtn={},{},{},{},{},{[1]={},[2]={},[3]={}},{},{},{[1]={},[2]={},[3]={},[4]={},[5]={},[6]={}}
local verStr=C_AddOns.GetAddOnMetadata("Ether","Version")
C.EtherVersion=verStr:sub(3):gsub("%.","")
C.PlayerName,C.PlayerGUID,C.EtherPrefix=UnitName("player"),UnitGUID("player"),"EtherAddonMsg"
C.EtherFont=CreateFont("EtherFont")
C.EtherFont:SetFont("Interface\\AddOns\\Ether\\Media\\venite.ttf",8,"OUTLINE")
C.Spell,C.Indi,C.ProfileRefresh=nil,nil,false
_,C.ClassName,C.ClassId=UnitClass
if type(_G["ETHER_DATABASE"])~="table" then
    _G["ETHER_DATABASE"]={}
end
if type(_G["ETHER_DATABASE"]["PROFILES"])~="table" then
    _G["ETHER_DATABASE"]["PROFILES"]={}
end
if type(_G["ETHER_DATABASE"]["CURRENT"])~="string" then
    _G["ETHER_DATABASE"]["CURRENT"]="DEFAULT"
end
if type(_G["ETHER_DATABASE"]["VERSION"])~="string" then
    _G["ETHER_DATABASE"]["VERSION"]=""
end
if type(_G["ETHER_DATABASE"]["LAST"])~="number" then
    _G["ETHER_DATABASE"]["LAST"]=0
end
local function OnEvent(self,event,...)
    self[event](self,...)
end
local event=CreateFrame("Frame")
S.EventFrame=event
function event:ADDON_LOADED()
    self:UnregisterEvent("ADDON_LOADED")
    local success,msg=pcall(function()
        if not _G["ETHER_DATABASE"]["PROFILES"]["DEFAULT"] then
            _G["ETHER_DATABASE"]["PROFILES"]["DEFAULT"]=D:CopyTable(D.Default)
            D:CurrentProfile(D:GetProfileName())
            _G["ETHER_DATABASE"]["VERSION"]=C.EtherVersion
        end
        local migrate=_G["ETHER_DATABASE"]["PROFILES"][D:GetProfileName()]["CONFIG"][13]
        if type(migrate)~="string" or migrate=="NONE" then
            for _,v in pairs(_G["ETHER_DATABASE"]["PROFILES"]) do
                v[3]=nil
                v[4]=nil
                v["CONFIG"]=D:DataMigrate(v["CONFIG"],16,0)
                v["CONFIG"][13]="DAMAGER"
            end
        end
        D:MergeToLeft(_G["ETHER_DATABASE"]["PROFILES"][D:GetProfileName()],D.Default)
    end)
    if not success then
        D:SetToDefault(success,msg)
        print(msg)
    end
    D:InitializeAddon(success)
end
event:SetScript("OnEvent",OnEvent)
event:RegisterEvent("ADDON_LOADED")