local _,F=unpack(select(2,...))
local function Module(self,status)
    if self.created or type(status)~="boolean" then return end
    self.created=status
    local data={"Icon","Msg","Msg+CLEU","Idle","Range","Indicators","Aura","Info","Tooltip","Name","Health","Power"}
    F:CreateCheckButton(self,1,data,function(i,s)
        F:Fire(s and i)
        F:Fire(not s and i+30)
    end)
end
local function Blizzard(self,status)
    if self.created or type(status)~="boolean" then return end
    self.created=status
    local data={"Hide Player frame","Hide Pet frame","Hide Target frame","Hide Focus frame","Hide CastBar",
                "Hide Party","Hide Raid","Hide Raid Manager","Hide MicroMenu","Hide XP Bar","Hide BagsBar"}
    F:CreateCheckButton(self,2,data,function(i)
        F:StatusBlizzard(i)
    end)
end
local function Tooltip(self,status)
    if self.created or type(status)~="boolean" then return end
    self.created=status
    local data={"AFK","DND","PVP","Resting","Realm","Level","Class","Guild","Role","Creature","Race",
                "RaidTarget","Reaction"}
    F:CreateCheckButton(self,3,data)
end
F:RegisterCallbackByIndex(Module,1+50)
F:RegisterCallbackByIndex(Blizzard,2+50)
F:RegisterCallbackByIndex(Tooltip,3+50)