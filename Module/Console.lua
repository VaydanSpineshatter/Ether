local Ether   = select(2, ...)
local Console = Ether.Console


function Console:Initialize()
	---@class cmd
	---@field cfg table
	---@field m string
	---@field r any
	local cfg     = { m = '', r = 7 }

	local f       = CreateFrame('Frame', nil, UIParent, 'BackdropTemplate')
	Console.Frame = f

	f:SetPoint('CENTER')
	f:SetBackdrop({
		bgFile = 'Interface\\Tooltips\\UI-Tooltip-Background',
		edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 }
	})
	f:SetBackdropColor(0, 0, 0, 1)
	f:SetBackdropBorderColor(0.8, 0.4, 1, 1)
	f:SetSize(320, 200)
	f:SetFrameStrata('DIALOG')

	self.__CONSOLE = Ether.ObjMetaPos:NEW(f, 'CONSOLE')
	self.__CONSOLE:INITIAL()

	local sF = CreateFrame('ScrollFrame', nil, f, 'UIPanelScrollFrameTemplate')
	sF:SetPoint('TOPLEFT', 10, -30)
	sF:SetPoint('BOTTOMRIGHT', -30, 10)

	local cF = CreateFrame('Frame', nil, sF)
	cF:SetSize(390, 111)
	sF:SetScrollChild(cF)

	local txt = cF:CreateFontString(nil, 'OVERLAY')
	txt:SetFont(unpack(Ether.Data.Forming.Font), 12, 'OUTLINE')
	txt:SetPoint('TOPLEFT')
	txt:SetWidth(290)
	txt:SetJustifyH('LEFT')

	local top = f:CreateFontString(nil, 'OVERLAY')
	top:SetFont(unpack(Ether.Data.Forming.Font), 12, 'OUTLINE')
	top:SetPoint('TOP', 0, -10)
	top:SetText('|cE600CCFFConsole|r')
	local topR = f:CreateFontString(nil, 'OVERLAY')
	topR:SetFont(unpack(Ether.Data.Forming.Font), 12, 'OUTLINE')
	topR:SetPoint('TOPRIGHT', -10, -10)

	f:Hide()

	local Update = CreateFrame('Frame')
	local function OnUpdate(self, elapsed)
		self.last = (self.last or 0) + elapsed
		if self.last >= 1 then
			cfg.r = cfg.r - 1
			if cfg.r <= 0 then
				f:Hide()
				cfg.m = ''
				self:SetScript('OnUpdate', nil)
			else
				topR:SetText(cfg.r)
			end
			self.last = 0
		end
	end

	local function SendOuput(input)
		if (not f:IsShown()) then
			f:Show()
		end
		cfg.m = (cfg.m .. '\n' .. input)
		txt:SetText(cfg.m)

		if (Update:GetScript('OnUpdate')) then return end
		cfg.r = 7
		topR:SetText('')
		Update:SetScript('OnUpdate', OnUpdate)
	end

	function Console:Output(...)
		local t = ''
		for i = 1, select('#', ...) do
			local arg = select(i, ...)
			t = t .. tostring(arg) .. ''
		end
		SendOuput(t)
	end
end
