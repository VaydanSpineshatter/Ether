local _, C = ...
local Store = C.Store

local pairs = pairs
local tconcat = table.concat
local tremove = table.remove
local sformat = string.format

local wipe = wipe

local __TEMP_POOL = {}

Store.TablePool = (function()
    local __TABLE_POOL = {}
    local __TABLE_COUNT = 0
    for i = 1, 80 do
        __TABLE_POOL[i] = {}
        __TABLE_COUNT = __TABLE_COUNT + 1
    end
    return {
        Get = function()
            if __TABLE_COUNT > 0 then
                local t = __TABLE_POOL[__TABLE_COUNT]
                __TABLE_POOL[__TABLE_COUNT] = nil
                __TABLE_COUNT = __TABLE_COUNT - 1
                return t
            else
                return {}
            end
        end,
        Release = function(t)
            if __TABLE_COUNT < 100 then
                for k in pairs(t) do t[k] = nil end
                __TABLE_COUNT = __TABLE_COUNT + 1
                __TABLE_POOL[__TABLE_COUNT] = t
            end
        end,
    }
end)()


function Store:CreatePool(creatorFunc)
    local pool = {
        create = creatorFunc,
        active = {},
        inactive = {},
        activeCount = 0,
    }
    setmetatable(pool, C.ObjPool)

    function pool:Acquire(...)
        if self.activeCount >= 180 then
            print('Warning - Pool: ' .. self.activeCount)
            return nil
        end

        local obj = tremove(self.inactive)
        if not obj then
            obj = self.create()
        end

        self.activeCount = self.activeCount + 1
        self.active[self.activeCount] = obj
        obj._poolIndex = self.activeCount

        if obj.Setup then
            obj:Setup(...)
        end

        return obj
    end

    function pool:Release(obj)
        if not obj or not obj._poolIndex then
            return
        end

        local index = obj._poolIndex
        if index <= 0 or index > self.activeCount then
            return
        end

        local last = self.active[self.activeCount]
        self.active[index] = last
        self.active[self.activeCount] = nil

        if last and last ~= obj then
            last._poolIndex = index
        end

        obj._poolIndex = -1
        self.activeCount = self.activeCount - 1

        if obj.Reset then
            obj:Reset()
        end

        if #self.inactive < 120 then
            self.inactive[#self.inactive + 1] = obj
        end
    end

    function pool:ReleaseAll()
        wipe(__TEMP_POOL)

        for i = 1, self.activeCount do
            __TEMP_POOL[i] = self.active[i]
        end

        for i = 1, #__TEMP_POOL do
            self:Release(__TEMP_POOL[i])
        end
    end

    function pool:GetCount()
        C.Console:Output('Pool Count: ' .. self.activeCount)
    end

    function pool:GetTableCount()
        C.Console:Output('Pool TableCount: ' .. #self.active)
    end

    return pool
end

Store.StringBuffer = (function()
    local bufferPool = {}
    local poolCount = 0
    return {
        Get = function()
            local buffer
            if poolCount > 0 then
                buffer = bufferPool[poolCount]
                bufferPool[poolCount] = nil
                poolCount = poolCount - 1
            else
                buffer = {}
            end
            return buffer
        end,
        Add = function(buffer, str)
            buffer[#buffer + 1] = str
        end,

        AddFormat = function(buffer, fmt, ...)
            buffer[#buffer + 1] = sformat(fmt, ...)
        end,

        Concat = function(buffer, sep)
            return tconcat(buffer, sep or "", 1, #buffer)
        end,
        Release = function(buffer)
            for i = #buffer, 1, -1 do
                buffer[i] = nil
            end

            if poolCount < 100 then
                poolCount = poolCount + 1
                bufferPool[poolCount] = buffer
            end
        end
    }
end)()

function Store:GetEntryMethod()
    local method = { guid = nil, unit = nil, role = role, online = online }

    function method:Reset(entry)
        if (entry) then
            entry.guid, entry.unit, entry.role, entry.online = nil, nil, nil, nil
        end
    end

    return method
end

local function CreateStringMethod()
    local method = CreateFrame('Frame', nil, UIParent)
    method:SetSize(50, 20)
    method.label = method:CreateFontString(nil, 'OVERLAY')
    method.label:SetFont(unpack(Ether.Forming.Font), 12, 'OUTLINE')
    method.label:SetPoint('CENTER')

    function method:Setup(parent, text, color, bool)
        self:SetParent(parent)
        if not bool then
            self:SetPoint('CENTER', parent, 'CENTER')
        else
            self:SetPoint('CENTER', parent, 'CENTER', 0, -50)
        end
        self.label:SetTextColor(unpack(color))
        self.label:SetText(text)
    end

    function method:Reset()
        self:Hide()
        self:ClearAllPoints()
    end

    return method
end
