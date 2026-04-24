local _,_,_,_,L=unpack(select(2,...))
L.Localalization=setmetatable({},{
    __index=function(_,key)
        return key
    end,
})
L.Locale=_G.GetLocale()
