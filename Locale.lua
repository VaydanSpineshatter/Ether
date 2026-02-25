local _,Ether = ...
local L = {}
L = setmetatable({},{
    __index = function(_,key)
        return key
    end
})
Ether.Locale = _G.GetLocale()
Ether.L = L