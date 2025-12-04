local Ether = select(2, ...)
local Callback = Ether.Callback

local CALLBACK_DATA = {}
local pairs = pairs

function Callback.Register(eventName, onEventFuncName, onEventFunc)
	if not CALLBACK_DATA[eventName] then
		CALLBACK_DATA[eventName] = {}
	end
	CALLBACK_DATA[eventName][onEventFuncName] = onEventFunc
end

function Callback.Unregister(eventName, onEventFuncName)
	if not CALLBACK_DATA[eventName] then
		return
	end
	CALLBACK_DATA[eventName][onEventFuncName] = nil
end

function Callback.Fire(eventName, ...)
	if not CALLBACK_DATA[eventName] then
		return
	end
	for _, onEventFunc in pairs(CALLBACK_DATA[eventName]) do
		onEventFunc(...)
	end
end
