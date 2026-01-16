local _, Ether     = ...

local CallbackData = {}
local pairs        = pairs

function Ether.RegisterCallback(eventName, onEventFuncName, onEventFunc)
	if not CallbackData[eventName] then
		CallbackData[eventName] = {}
	end
	CallbackData[eventName][onEventFuncName] = onEventFunc
end

function Ether.UnregisterCallback(eventName, onEventFuncName)
	if not CallbackData[eventName] then
		return
	end
	CallbackData[eventName][onEventFuncName] = nil
end

function Ether.UnregisterAllCallback(eventName)
	if not CallbackData[eventName] then
		return
	end
	CallbackData[eventName] = nil
end

function Ether.Fire(eventName, ...)
	if not CallbackData[eventName] then
		return
	end
	for _, onEventFunc in pairs(CallbackData[eventName]) do
		onEventFunc(...)
	end
end
