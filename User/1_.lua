local _,F=unpack(select(2,...))
function F:Module(self,status)
    if self.created or type(status)~="boolean" then return end
    self.created=status
    local data={"Icon","Msg","Msg+CLEU","Idle","Range","Indicators","Aura","Info","Tooltip","Name","Health","Power"}
    F:CreateCheckButton(self,1,data,function(i,s)
        F:Fire(s and i)
        F:Fire(not s and i+30)
    end)
end