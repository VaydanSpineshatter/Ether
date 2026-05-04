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
local _,Ether=...
Ether[1],Ether[2],Ether[3],Ether[4],Ether[5]={},{},{},{},{} --local D,F,S,C,L=unpack(select(2,...))
Ether[1].A,Ether[1].H,Ether[1].DB={},{},{}
Ether[1].raidBtn={}
Ether[1].petBtn={}
Ether[1].soloBtn={[1]={},[2]={},[3]={},[4]={},[5]={},[6]={}}
Ether[1].GUIDToBtn={}
Ether[1].BtnToGUID={}
Ether[1].castBar={}
Ether[1].customBtn={[1]={},[2]={},[3]={}}
Ether[1].modelBtn={}
table.insert(Ether[1].modelBtn,CreateFrame("PlayerModel",nil,UIParent))
table.insert(Ether[1].modelBtn,CreateFrame("PlayerModel",nil,UIParent))
Ether[4].MainFrame=CreateFrame("Frame","EtherUnitFrames",UIParent)
Ether[4].ContentFrame=CreateFrame("Frame",nil,Ether[4].MainFrame)
table.insert(UISpecialFrames,"EtherUnitFrames")
Ether[3].EventFrame=CreateFrame("Frame")
Ether[4].BaseFrame=CreateFrame("Frame",nil,Ether[4].MainFrame)
local verStr=C_AddOns.GetAddOnMetadata("Ether","Version")
Ether[4].EtherVersion=verStr:sub(3):gsub("%.","")
Ether[4].LastVersion=0
Ether[4].EtherPrefix="EtherAddonMsg"
Ether[4].PlayerName=UnitName("player")
Ether[4].PlayerGUID=UnitGUID("player")
Ether[4].ClassName=select(2,UnitClass("player"))
Ether[4].EtherFont=CreateFont("EtherFont")
Ether[4].EtherFont:SetFont("Interface\\AddOns\\Ether\\Media\\venite.ttf",8,"OUTLINE")
Ether[4].EtherIcon=CreateFrame("Frame",nil,UIParent)
Ether[4].ToolFrame=CreateFrame("Frame",nil,UIParent)
Ether[4].ToolFrame:SetFrameStrata("TOOLTIP")
Ether[4].ToolFrame:Hide()
Ether[4].ToolFrame.index=17
local bg=Ether[4].ToolFrame:CreateTexture(nil,"BACKGROUND")
bg:SetColorTexture(0,0,0,.5)
bg:SetAllPoints()
for i=1,6 do
    Ether[1].soloBtn[i].index=i
end
for i=1,2 do
    Ether[1].modelBtn[i].index=i+13
end
Ether[4].EtherIcon.index=18
Ether[4].MainFrame.index=19
Ether[4].CombatStatus=false
local left=Ether[3].EventFrame:CreateTexture(nil,"BACKGROUND")
local right=Ether[3].EventFrame:CreateTexture(nil,"BACKGROUND")
left:SetPoint("TOPLEFT",UIParent,"TOPLEFT")
left:SetPoint("BOTTOMLEFT",UIParent,"BOTTOMLEFT")
right:SetPoint("TOPRIGHT",UIParent,"TOPRIGHT")
right:SetPoint("BOTTOMRIGHT",UIParent,"BOTTOMRIGHT")
left:SetColorTexture(1,0,0,.4)
right:SetColorTexture(1,0,0,.4)
left:Hide()
right:Hide()
left:SetWidth(40)
right:SetWidth(40)
Ether[4].Spell,Ether[4].Indi,Ether[4].ProfileRefresh=nil,nil,false
Ether[4].FlashLeft=left
Ether[4].FlashRight=right
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
Ether[3].EventFrame.ADDON_LOADED=function(self)
    self:UnregisterEvent("ADDON_LOADED")
    local success,msg=pcall(function()
        if not _G["ETHER_DATABASE"]["PROFILES"]["DEFAULT"] then
            _G["ETHER_DATABASE"]["PROFILES"]["DEFAULT"]=Ether[1]:CopyTable(Ether[1].Default)
            Ether[1]:CurrentProfile(Ether[1]:GetProfileName())
            _G["ETHER_DATABASE"]["VERSION"]=Ether[4].EtherVersion
        end
        if type(_G["ETHER_DATABASE"]["PROFILES"][Ether[1]:GetProfileName()]["CONFIG"][13])~="string" then
            for _,v in pairs(_G["ETHER_DATABASE"]["PROFILES"]) do
                v[3]=nil
                v[4]=nil
                v["CONFIG"]=Ether[1]:DataMigrate(v["CONFIG"],16,0)
                v["CONFIG"][13]="NONE"
            end
        end
        Ether[1]:MergeToLeft(_G["ETHER_DATABASE"]["PROFILES"][Ether[1]:GetProfileName()],Ether[1].Default)
    end)
    if not success then
        Ether[1]:SetToDefault(success,msg)
        print(msg)
    end
    Ether[1]:InitializeAddon(success)
end
Ether[3].EventFrame:SetScript("OnEvent",OnEvent)
Ether[3].EventFrame:RegisterEvent("ADDON_LOADED")