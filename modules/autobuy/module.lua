------------------------------------------------------
-- MetaHunt: AutoBuy Module
-- Standalone module shell for vendor auto-buy features.
------------------------------------------------------

local MTH_AutoBuy = {
	name = "autobuy",
	enabled = false,
	version = "1.4.0",
	events = {
		"VARIABLES_LOADED",
		"MERCHANT_SHOW",
		"MERCHANT_UPDATE",
		"MERCHANT_CLOSED",
	},
	initialized = false,
}

local function AB_Log(message, severity)
	if type(MTH_Log) == "function" then
		MTH_Log("[AutoBuy] " .. tostring(message or ""), severity)
	end
end

local AB_Engine


local function AB_EnsureBridgeFrame(moduleRef)
	if MTH_AutoBuy._bridgeFrame then
		return MTH_AutoBuy._bridgeFrame
	end

	local frame = CreateFrame("Frame", "MTH_AutoBuyBridge")
	if not frame then
		AB_Log("failed to create bridge frame", "error")
		return nil
	end

	frame:RegisterEvent("MERCHANT_SHOW")
	frame:RegisterEvent("MERCHANT_UPDATE")
	frame:RegisterEvent("MERCHANT_CLOSED")
	frame:SetScript("OnEvent", function()
		local eventName = event
		local engine = AB_Engine()
		if not engine then
			return
		end

		if eventName == "MERCHANT_SHOW" or eventName == "MERCHANT_UPDATE" then
			engine:OnMerchantEvent(eventName)
		elseif eventName == "MERCHANT_CLOSED" then
			if engine.OnMerchantClosed then
				engine:OnMerchantClosed()
			end
		end
	end)

	MTH_AutoBuy._bridgeFrame = frame
	MTH_AutoBuy._bridgeActive = true
	return frame
end

local function AB_SetBridgeActive(active)
	local frame = MTH_AutoBuy._bridgeFrame
	if active then
		if not frame then
			frame = AB_EnsureBridgeFrame(MTH_AutoBuy)
		end
		if frame then
			frame:RegisterEvent("MERCHANT_SHOW")
			frame:RegisterEvent("MERCHANT_UPDATE")
			frame:RegisterEvent("MERCHANT_CLOSED")
			MTH_AutoBuy._bridgeActive = true
		else
			MTH_AutoBuy._bridgeActive = false
		end
		return
	end

	if frame then
		frame:UnregisterEvent("MERCHANT_SHOW")
		frame:UnregisterEvent("MERCHANT_UPDATE")
		frame:UnregisterEvent("MERCHANT_CLOSED")
	end
	MTH_AutoBuy._bridgeActive = false
end

AB_Engine = function()
	return MTH_AutoBuyEngine
end

function MTH_AutoBuy:init()
	local engine = AB_Engine()
	if not engine then
		AB_Log("init failed: engine missing", "error")
		return
	end
	engine:Init()
	self.initialized = true
	AB_SetBridgeActive(self.enabled and true or false)
	if self.enabled then
	end
end

function MTH_AutoBuy:setEnabled(enabled)
	if not self.initialized then
		self:init()
	end
	local engine = AB_Engine()
	if not engine then
		return
	end
	local store = engine:EnsureDefaults()
	store.enabled = enabled and true or false
	AB_SetBridgeActive(store.enabled and true or false)
end

function MTH_AutoBuy:onEvent(event)
	local engine = AB_Engine()
	if not engine then
		return
	end
	if self._bridgeActive and (event == "MERCHANT_SHOW" or event == "MERCHANT_UPDATE" or event == "MERCHANT_CLOSED") then
		return
	end

	if event == "VARIABLES_LOADED" then
		engine:Init()
		AB_SetBridgeActive(self.enabled and true or false)
		engine:EnsureDefaults()
		return
	end

	if not self.enabled then
		if event == "MERCHANT_SHOW" or event == "MERCHANT_UPDATE" then
		end
		return
	end

	if event == "MERCHANT_SHOW" or event == "MERCHANT_UPDATE" then
		engine:OnMerchantEvent(event)
	elseif event == "MERCHANT_CLOSED" then
		if engine.OnMerchantClosed then
			engine:OnMerchantClosed()
		end
	end
end

function MTH_AutoBuy:cleanup()
end

MTH:RegisterModule("autobuy", MTH_AutoBuy)
