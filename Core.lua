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
    slash={
        [1]={cmd="/ether",desc="Toggle Commands"},
        [2]={cmd="/ether settings",desc="Toggle settings"},
        [3]={cmd="/ether rl",desc="Reload Interface"},
        [4]={cmd="/ether Msg",desc="Ether whisper enable"},
    }
}

local EtherToggle,ShowHideSettings
do
    ---@class EtherSettings
    local EtherFrame={
        Created=false,
        SpellId=nil,
        Frames={},
        Borders={},
        Buttons={Menu={},[1]={},[2]={},[3]={},[4]={},[5]={},[6]={},[7]={},[8]={},[9]={},[10]={},[11]={},[12]={}},
        ["CONTENT"]={["CHILDREN"]={},},
        Menu={
            ["TOP"]={
                [1]={"Module","Blizzard","About"},
                [2]={"Helper"},
                [3]={"Create","Fake","Update"},
                [4]={"Settings","Custom","Effects"},
                [5]={"Position"},
                [6]={"Tooltip"},
                [7]={"Layout","Header","CastBar","Config"},
                [8]={"Edit"}
            },
            ["LEFT"]={
                [1]={"Info"},
                [2]={"Helper"},
                [3]={"Units"},
                [4]={"Aura"},
                [5]={"Indicators"},
                [6]={"Tooltip"},
                [7]={"Interface"},
                [8]={"Profile"}
            }
        }
    }
    local function ShowCategory(self,category)
        if self.Created~=true then
            return
        end
        local tabLayer
        for layer=1,8 do
            if self.Menu["TOP"][layer] then
                for _,tabName in ipairs(self.Menu["TOP"][layer]) do
                    if tabName==category then
                        tabLayer=layer
                        break
                    end
                end
            end
            if tabLayer then
                break
            end
        end
        for _,layers in pairs(self.Buttons[11]) do
            for _,topBtn in pairs(layers) do
                topBtn:Hide()
            end
        end
        if tabLayer and self.Buttons[11][tabLayer] then
            for _,topBtn in pairs(self.Buttons[11][tabLayer]) do
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
        elseif category=="Create" then
            Ether:CreateCreationSection(self)
        elseif category=="Fake" then
            Ether:CreateFakeSection(self)
        elseif category=="Update" then
            Ether:CreateUpdateSection(self)
        elseif category=="Settings" then
            Ether:CreateAuraSection(self)
        elseif category=="Effects" then
            Ether:CreateEffectsSection(self)
        elseif category=="Helper" then
            Ether:CreateHelperSection(self)
        elseif category=="Tooltip" then
            Ether:CreateTooltipSection(self)
        elseif category=="Header" then
            Ether:CreateHeaderSection(self)
        elseif category=="Layout" then
            Ether:CreateLayoutSection(self)
        elseif category=="CastBar" then
            Ether:CreateCastBarSection(self)
        elseif category=="Config" then
            Ether:CreateConfigSection(self)
        elseif category=="Edit" then
            Ether:CreateEditSection(self)
        end
        local target=self["CONTENT"]["CHILDREN"][category]
        if target then
            target:Show()
        end
    end
    local function InitializeLayer(self)
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
                    self.Buttons[11][layer]={}
                    local BtnConfig={}
                    for idx,itemName in ipairs(self.Menu["TOP"][layer]) do
                        local btn=Ether:CreateSettingsButtons(itemName,self.Frames["TOP"],layer,function(btnName)
                            ShowCategory(self,btnName)
                        end,true)
                        btn:Hide()
                        BtnConfig[idx]={
                            btn=btn,
                            name=itemName,
                            width=btn:GetWidth()
                        }
                        self.Buttons[11][layer][itemName]=btn
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
            local last=nil
            for layer=1,8 do
                if self.Menu["LEFT"][layer] then
                    for _,itemName in ipairs(self.Menu["LEFT"][layer]) do
                        local btn=Ether:CreateSettingsButtons(itemName,self.Frames["LEFT"],layer,function(_,btnLayer)
                            local firstTabName=self.Menu["TOP"][btnLayer][1]
                            Ether.DB[100][1]=firstTabName
                            for _,layers in pairs(self.Buttons[11]) do
                                for _,topBtn in pairs(layers) do
                                    topBtn:Hide()
                                end
                            end
                            if self.Buttons[11][btnLayer] then
                                for _,topBtn in pairs(self.Buttons[11][btnLayer]) do
                                    topBtn:Show()
                                end
                            end
                            if self.Menu["TOP"][btnLayer] and self.Menu["TOP"][btnLayer][1] then
                                ShowCategory(self,firstTabName)
                            end
                        end,false)

                        if last then
                            btn:SetPoint("TOPLEFT",last,"BOTTOMLEFT",0,0)
                            btn:SetPoint("TOPRIGHT",last,"BOTTOMRIGHT",0,-2)
                        else
                            btn:SetPoint("TOPLEFT",self.Frames["LEFT"],"TOPLEFT",5,0)
                            btn:SetPoint("TOPRIGHT",self.Frames["LEFT"],"TOPRIGHT",-10,0)
                        end
                        last=btn
                    end
                end
            end
            self.Frames["AURAS"]:SetParent(self["CONTENT"]["CHILDREN"]["Custom"])
            self.Frames["EDITOR"]:SetParent(self["CONTENT"]["CHILDREN"]["Custom"])
            self.Created=true
        end
    end
    function ShowHideSettings(state)
        if InCombatLockdown() then
            return
        end
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
            Ether:CleanUpButtons(EtherFrame.Frames["EDITOR"],EtherFrame.Frames["INDICATORS"])
            Ether.WrapSettingsColor({0.80,0.40,1.00,1})
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
    local function WrapSettingsColor(color)
        if type(color)~="table" then
            return
        end
        for _,borders in pairs(EtherFrame.Borders) do
            borders:SetColorTexture(unpack(color))
        end
    end
    Ether.UIPanel=EtherFrame
    Ether.WrapSettingsColor=WrapSettingsColor
    Ether.ShowHideSettings=ShowHideSettings
    Ether.EtherToggle=EtherToggle
    Ether.InitializeLayer=InitializeLayer
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
            Ether:NilCheck(Ether:GetProfile())
            Ether:ArrayMigrate(Ether:GetProfile())
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
        Ether:CreatePopupBox()
        Ether:HideBlizzard()
        Ether:SetupInfoFrame()
        local IsPrefixRegistered=C_ChatInfo.IsAddonMessagePrefixRegistered(Ether.metaData[1])
        if IsPrefixRegistered then
            if IsInGuild() then
                C_ChatInfo.SendAddonMessage(Ether.metaData[1],Ether.metaData[3],"GUILD")
            end
            Ether:EtherDebug("Prefix registered")
        end
        SLASH_ETHER1="/ether"
        SlashCmdList["ETHER"]=function(msg)
            local input,rest=msg:match("^(%S*)%s*(.-)$")
            input=string.lower(input or "")
            rest=string.lower(rest or "")
            if input=="settings" then
                if InCombatLockdown() then return end
                Ether.DB[100][3]=not Ether.DB[100][3]
                Ether.EtherToggle(Ether.DB[100][3])
            elseif input=="rl" then
                if not InCombatLockdown() then
                    ReloadUI()
                end
            elseif input=="msg" then
                Ether:EtherFrameSetClick(1,2)
            else
                for _,entry in ipairs(Ether.media.slash) do
                    Ether:EtherInfo(string.format("%s  –  %s",entry.cmd,entry.desc))
                end
            end
        end
        if LibStub and LibStub("LibSharedMedia-3.0",true) then
            if not soundsRegistered then
                soundsRegistered=true
                local LSM=LibStub("LibSharedMedia-3.0")
                LSM:Register("font","Expressway",[[Interface\AddOns\Ether\Media\Font\expressway.ttf]])
                LSM:Register("font","Venite",[[Interface\AddOns\Ether\Media\Font\venite.ttf]])
                LSM:Register("statusbar","BlankBar",[[Interface\AddOns\Ether\Media\StatusBar\BlankBar.tga]])
            end
        end
        Ether:CreateGroupHeader()
        Ether:CreatePetHeader()
        if Ether.DB[8][1]==1 then
            Ether:ChangeDirectionHeader(true)
        end
        Ether.CombatFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
        EtherToggle()
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
        Ether:ApplyFramePosition(Ether.Anchor.raid,9)
        Ether:SetupDrag(Ether.Anchor.raid,9,10)
        Ether:ApplyFramePosition(Ether.Anchor.pet,10)
        Ether:SetupDrag(Ether.Anchor.pet,10,10)
        if Ether.EtherIcon then
            Ether.EtherIcon:ClearAllPoints()
            Ether.EtherIcon:SetPoint("CENTER",Minimap,"CENTER",Ether.DB[21][13][4],Ether.DB[21][13][5])
            if Ether.DB[1][1]==1 then
                Ether:ToggleIcon(1)
            end
        end
        for _,unit in ipairs({"player","target","targettarget","pet","pettarget","focus"}) do
            Ether:CreateUnitButtons(unit)
        end
        if Ether.DB[10][1]==1 then
            Ether:CastBarEnable("player")
        end
        if Ether.DB[10][2]==1 then
            Ether:CastBarEnable("target")
        end
        if Ether.soloButtons["pet"] then
            Ether:PetCondition(Ether.soloButtons["pet"])
        end
    elseif (event=="PLAYER_ENTERING_WORLD") then
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
        for _,unit in ipairs({"player","target","pet"}) do
            Ether:SoloAuraSetup(Ether.soloButtons[unit])
        end
        Ether:RosterEnable()
        Ether.EtherToggle(Ether.DB[100][3])
    elseif (event=="PLAYER_LOGOUT") then
        ETHER_DATABASE_DX_AA["PROFILES"][Ether:GetProfileName()]=Ether:CopyTable(Ether.DB)
    end
end
local Initialize=CreateFrame("Frame")
Initialize:RegisterEvent("ADDON_LOADED")
Initialize:SetScript("OnEvent",OnInitialize)