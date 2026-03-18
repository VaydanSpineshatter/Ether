---@class Ether
local _,Ether=...
local pairs,ipairs=pairs,ipairs
Ether.metaData={"EtherAddonMsg","",0}
local Anchor,Header={},{}
Ether.Header,Ether.Anchor=Anchor,Header
local soundsRegistered=false
Ether.Anchor.toolFrame=CreateFrame("Frame",nil,UIParent)

Ether.media={
    icon={"Interface\\AddOns\\Ether\\Media\\Texture\\icon.blp"},
    emblem={"Interface\\AddOns\\Ether\\Media\\Texture\\emblem.png"},
    expressway={"Interface\\AddOns\\Ether\\Media\\Font\\expressway.ttf"},
    blankBar={"Interface\\AddOns\\Ether\\Media\\StatusBar\\BlankBar.tga"},
    elvUIBar={"Interface\\AddOns\\Ether\\Media\\StatusBar\\ElvUI.tga"},
    venite={"Interface\\AddOns\\Ether\\Media\\Font\\venite.ttf"},
    etherBg={"Interface\\AddOns\\Ether\\Media\\Texture\\etherBg.tga"},
    slash={
        [1]={cmd="/ether",desc="Toggle Commands"},
        [2]={cmd="/ether settings",desc="Toggle settings"},
        [3]={cmd="/ether rl",desc="Reload Interface"},
        [4]={cmd="/ether Msg",desc="Ether whisper enable"},
    }
}

local EtherToggle,ToggleUnlock
do
    local CK,CM={"Module","Blizzard","About","Helper","Custom","Aura","Indicators","Tooltip","Layout","Header","Config","Profile","Info","Interface"},{}
    for i,v in ipairs(CK) do
        CM[v]=i -- "Module" -> 1
        CM[i]=v -- 1 -> "Module"
    end
    function Ether:ContentNumber(input)
        return CM[input]
    end
    ---@class EtherSettings
    local EtherFrame={
        Created=false,
        SpellId=nil,
        Frames={},
        Borders={},
        Buttons={["MENU"]={},["LIST"]={},[1]={},[2]={},[3]={},[4]={},[5]={},[6]={}},
        ["CONTENT"]={["CHILDREN"]={}},
        Menu={
            ["TOP"]={
                [1]={CK[1],CK[2],CK[3]},
                [2]={CK[4]},
                [3]={CK[5]},
                [4]={CK[6]},
                [5]={CK[7]},
                [6]={CK[8]},
                [7]={CK[9],CK[10],CK[11]},
                [8]={CK[12]}
            },
            ["LEFT"]={
                [1]={CK[13]},
                [2]={CK[4]},
                [3]={CK[5]},
                [4]={CK[6]},
                [5]={CK[7]},
                [6]={CK[8]},
                [7]={CK[14]},
                [8]={CK[12]}
            }
        }
    }
    local function ShowCategory(self,category)
        if self.Created~=true then return end
        local last
        for layer=1,8 do
            if self.Menu["TOP"][layer] then
                for _,tabName in ipairs(self.Menu["TOP"][layer]) do
                    if tabName==category then
                        last=layer
                        break
                    end
                end
            end
        end
        for _,layers in pairs(self.Buttons["MENU"]) do
            for _,topBtn in pairs(layers) do
                topBtn:Hide()
            end
        end
        if last and self.Buttons["MENU"][last] then
            for _,topBtn in pairs(self.Buttons["MENU"][last]) do
                topBtn:Show()
            end
        end
        for _,child in pairs(self["CONTENT"]["CHILDREN"]) do
            child:Hide()
        end
        if category=="Module" then
            Ether:CreateModuleSection(self)
        elseif category=="Blizzard" then
            Ether:CreateBlizzardSection(self)
        elseif category=="About" then
            Ether:CreateAboutSection(self)
        elseif category=="Custom" then
            Ether:CreateCustomSection(self)
        elseif category=="Helper" then
            Ether:CreateHelperSection(self)
        elseif category=="Tooltip" then
            Ether:CreateTooltipSection(self)
        elseif category=="Header" then
            Ether:CreateHeaderSection(self)
        elseif category=="Layout" then
            Ether:CreateLayoutSection(self)
        elseif category=="Profile" then
            Ether:CreateProfileSection(self)
        end
        local target=self["CONTENT"]["CHILDREN"][category]
        if target then
            target:Show()
        end
    end
    local function InitializeLayerLevel(self)
        if not self.Created then
            for layer=1,8 do
                if self.Menu["TOP"][layer] then
                    for _,name in ipairs(self.Menu["TOP"][layer]) do
                        self["CONTENT"]["CHILDREN"][name]=CreateFrame("Frame",nil,self.Frames["CONTENT"])
                        self["CONTENT"]["CHILDREN"][name]:SetAllPoints(self.Frames["CONTENT"])
                        self["CONTENT"]["CHILDREN"][name]:Hide()
                    end
                end
            end
            for layer=1,8 do
                if self.Menu["TOP"][layer] then
                    self.Buttons["MENU"][layer]={}
                    local BtnConfig={}
                    for idx,itemName in ipairs(self.Menu["TOP"][layer]) do
                        local btn=Ether:CreateSettingsButtons(itemName,self.Frames["TOP"],layer,function(btnName)
                            ShowCategory(self,btnName)
                            Ether.DB[100][1]=btnName
                        end,true)
                        btn:Hide()
                        BtnConfig[idx]={
                            btn=btn,
                            name=itemName,
                            width=btn:GetWidth()
                        }
                        self.Buttons["MENU"][layer][itemName]=btn
                    end
                    if #BtnConfig>0 then
                        local spacing=10
                        local totalWidth=0
                        for _,data in ipairs(BtnConfig) do
                            totalWidth=totalWidth+data.width
                        end
                        totalWidth=totalWidth+(#BtnConfig-1)*spacing
                        local startX=-totalWidth/2
                        local currentX=startX
                        for _,data in ipairs(BtnConfig) do
                            data.btn:SetPoint("CENTER",self.Frames["TOP"],"CENTER",currentX+data.width/2,5)
                            currentX=currentX+data.width+spacing
                        end
                    end
                end
            end
            local target
            target=nil
            for layer=1,8 do
                if self.Menu["LEFT"][layer] then
                    for _,itemName in ipairs(self.Menu["LEFT"][layer]) do
                        local btn=Ether:CreateSettingsButtons(itemName,self.Frames["LEFT"],layer,function(_,btnLayer)
                            local firstTabName=self.Menu["TOP"][btnLayer][1]
                            for _,layers in pairs(self.Buttons["MENU"]) do
                                for _,topBtn in pairs(layers) do
                                    topBtn:Hide()
                                end
                            end
                            if self.Buttons["MENU"][btnLayer] then
                                for _,topBtn in pairs(self.Buttons["MENU"][btnLayer]) do
                                    topBtn:Show()
                                end
                            end
                            if self.Menu["TOP"][btnLayer] and self.Menu["TOP"][btnLayer][1] then
                                ShowCategory(self,firstTabName)
                            end
                        end,false)

                        if target then
                            btn:SetPoint("TOPLEFT",target,"BOTTOMLEFT",0,0)
                            btn:SetPoint("TOPRIGHT",target,"BOTTOMRIGHT",0,-2)
                        else
                            btn:SetPoint("TOPLEFT",self.Frames["LEFT"],"TOPLEFT",5,0)
                            btn:SetPoint("TOPRIGHT",self.Frames["LEFT"],"TOPRIGHT",-10,0)
                        end
                        target=btn
                    end
                end
            end
            self.Frames["AURAS"]:SetParent(self["CONTENT"]["CHILDREN"]["Aura"])
            self.Frames["EDITOR"]:SetParent(self["CONTENT"]["CHILDREN"]["Aura"])
            self.Created=true
        end
    end
    function ToggleUnlock(state)
        if InCombatLockdown() then return end
        if not Ether.gridFrame then
            Ether:SetupGridFrame()
        end
        Ether.IsMovable=state
        Ether.gridFrame:SetShown(state)
        if Ether.toolFrame then
            Ether.toolFrame:SetShown(state)
        end
        if Ether.infoFrame then
            Ether.infoFrame:SetShown(state)
        end
        if Ether.Anchor.raid.tex then
            Ether.Anchor.raid.tex:SetShown(state)
        end
        if Ether.Anchor.pet.tex then
            Ether.Anchor.pet.tex:SetShown(state)
        end
        Ether:HideCastBar("player",state)
        Ether:HideCastBar("target",state)
        if not state then
            Ether:CleanUpButtons(EtherFrame.Frames["EDITOR"],EtherFrame.Frames["INDICATORS"],EtherFrame["CONTENT"]["CHILDREN"]["Config"])
        end
    end
    function EtherToggle(state)
        Ether:CreateMainFrame(EtherFrame)
        EtherFrame.Frames["MAIN"]:SetShown(state)
        local category=Ether.DB[100][1]
        if EtherFrame["CONTENT"]["CHILDREN"][category] then
            ShowCategory(EtherFrame,category)
        end
    end
    Ether.UIPanel=EtherFrame
    Ether.ToggleUnlock=ToggleUnlock
    Ether.EtherToggle=EtherToggle
    Ether.InitializeLayerLevel=InitializeLayerLevel
end

local function OnInitialize(self,event,...)
    if (event=="ADDON_LOADED") then
        local addon=...
        assert(addon=="Ether","Unexpected addon string: "..tostring(addon))
        assert(type(Ether.DataDefault)=="table","Ether default database missing")
        assert(type(Ether.CopyTable)=="function","Ether table func missing")
        self:UnregisterEvent("ADDON_LOADED")
        if type(_G.ETHER_DATABASE_DX_AA)~="table" then
            _G.ETHER_DATABASE_DX_AA={}
        end
        if type(ETHER_DATABASE_DX_AA["PROFILES"])~="table" then
            ETHER_DATABASE_DX_AA["PROFILES"]={}
        end
        if type(ETHER_DATABASE_DX_AA["LAST"])~="number" then
            ETHER_DATABASE_DX_AA["LAST"]=0
        end
        if type(ETHER_DATABASE_DX_AA["CURRENT"])~="string" then
            ETHER_DATABASE_DX_AA["CURRENT"]=""
        end
        local system=tonumber(C_AddOns.GetAddOnMetadata("Ether","Version"))
        Ether.metaData[2]=UnitName("player")
        Ether.metaData[3]=tonumber(system)
        Ether:VerifyDefaultData()
        local success,msg=pcall(function()
            Ether:MergeToLeft(Ether:GetProfile(),Ether.DataDefault)
        end)
        if not success then
            Ether:EtherInfo(string.format("Migration failed. Reset data to default values - %s",msg))
            Ether:ResetDataBase()
        else
            Ether:LoadAddon(self)
        end
    elseif (event=="PLAYER_LOGIN") then
        self:UnregisterEvent("PLAYER_LOGIN")
        Ether.DB=Ether:CopyTable(Ether:GetProfile())
        C_ChatInfo.RegisterAddonMessagePrefix(Ether.metaData[1])
        if Ether.CreatePopupBox then
            Ether:CreatePopupBox()
        end
        if Ether.HideBlizzard then
            Ether:HideBlizzard()
        end
        if Ether.SetupInfoFrame then
            Ether:SetupInfoFrame()
        end
        local IsPrefixRegistered=C_ChatInfo.IsAddonMessagePrefixRegistered(Ether.metaData[1])
        if IsPrefixRegistered then
            if IsInGuild() then
                C_ChatInfo.SendAddonMessage(Ether.metaData[1],Ether.metaData[3],"GUILD")
            end
            Ether:EtherDebug("Register prefix: ",Ether.metaData[1])
        end
        if Ether.SetupSlash then
            Ether:SetupSlash()
        end
        if LibStub and LibStub("LibSharedMedia-3.0",true) then
            if not soundsRegistered then
                soundsRegistered=true
                local LSM=LibStub("LibSharedMedia-3.0")
                LSM:Register("font","Venite",[[Interface\AddOns\Ether\Media\Font\venite.ttf]])
            end
        end
        Ether:CreateGroupHeader()
        Ether:CreatePetHeader()
        if Ether.DB[6][1]==1 then
            Ether:ChangeDirectionHeader(true)
        end
        Ether.CombatFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
        if Ether.DB[1][2]==1 then
            Ether:EnableMsgEvents()
        end
        Ether:CreateToolFrame()
        Ether:ToolTipInitialize()
        Ether.Anchor.raid:SetSize(32,32)
        Ether.Anchor.raid.tex=Ether.Anchor.raid:CreateTexture(nil,"BACKGROUND")
        Ether.Anchor.raid.tex:SetAllPoints()
        Ether.Anchor.raid.tex:SetColorTexture(0,1,0,.7)
        Ether.Anchor.raid.tex:Hide()
        Ether.Anchor.pet:SetSize(32,32)
        Ether.Anchor.pet.tex=Ether.Anchor.pet:CreateTexture(nil,"BACKGROUND")
        Ether.Anchor.pet.tex:SetAllPoints()
        Ether.Anchor.pet.tex:SetColorTexture(0,1,0,.7)
        Ether.Anchor.pet.tex:Hide()
        Ether:ApplyFramePosition(10)
        Ether:SetupDrag(10)
        Ether:ApplyFramePosition(11)
        Ether:SetupDrag(11)
        if Ether.EtherIcon then
            Ether.EtherIcon:ClearAllPoints()
            Ether.EtherIcon:SetPoint("CENTER",Minimap,"CENTER",Ether.DB[21][16][4],Ether.DB[21][16][5])
            if Ether.DB[1][1]==0 then
                Ether:ToggleIcon(false)
            end
        end
        for index=1,6 do
            Ether:CreateUnitButtons(index)
            if Ether.DB[6][index]==0 then
                Ether:DeactivateUnitButton(index)
            end
        end
    elseif (event=="PLAYER_ENTERING_WORLD") then
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
        if Ether.DB[6][12]==1 then
            Ether:CastBarEnable("player")
        end
        if Ether.DB[6][13]==1 then
            Ether:CastBarEnable("target")
        end
        if Ether.DB[6][4]==1 then
            Ether:PetCondition(Ether.soloButtons[4])
        end
        EtherToggle(Ether.DB[100][3])
        Ether:MergeAnalyse()
        Ether:RosterEnable()
    elseif (event=="PLAYER_LOGOUT") then
        ETHER_DATABASE_DX_AA["PROFILES"][Ether:GetProfileName()]=Ether:CopyTable(Ether.DB)
    end
end
local Initialize=CreateFrame("Frame")
Initialize:RegisterEvent("ADDON_LOADED")
Initialize:SetScript("OnEvent",OnInitialize)

