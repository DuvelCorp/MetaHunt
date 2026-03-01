------------------------------------------------------
-- MetaHunt: AutoBuy Module
-- Standalone module shell for vendor auto-buy features.
------------------------------------------------------

local MTH_AutoBuy = {
	name = "autobuy",
	enabled = false,
	version = "1.0.5",
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

local function AB_Trace(message)
	return
end

local function AB_EnsureBridgeFrame(moduleRef)
	if MTH_AutoBuy._bridgeFrame then
		return MTH_AutoBuy._bridgeFrame
	end

	local frame = CreateFrame("Frame", "MTH_AutoBuyBridgeFrame")
	if not frame then
		AB_Log("failed to create bridge frame", "error")
		return nil
	end

	frame:RegisterEvent("MERCHANT_SHOW")
	frame:RegisterEvent("MERCHANT_UPDATE")
	frame:RegisterEvent("MERCHANT_CLOSED")
	frame:SetScript("OnEvent", function(_, eventName)
		eventName = eventName or event
		local engine = AB_Engine()
		if not engine then
			AB_Trace("bridge event=" .. tostring(eventName) .. " engine missing")
			return
		end

		if eventName == "MERCHANT_SHOW" or eventName == "MERCHANT_UPDATE" then
			AB_Trace("bridge " .. tostring(eventName) .. " -> engine")
			engine:OnMerchantEvent(eventName)
		elseif eventName == "MERCHANT_CLOSED" then
			AB_Trace("bridge MERCHANT_CLOSED -> engine")
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
			AB_Trace("bridge active=true")
		else
			MTH_AutoBuy._bridgeActive = false
			AB_Trace("bridge active=false (frame missing)")
		end
		return
	end

	if frame then
		frame:UnregisterEvent("MERCHANT_SHOW")
		frame:UnregisterEvent("MERCHANT_UPDATE")
		frame:UnregisterEvent("MERCHANT_CLOSED")
	end
	MTH_AutoBuy._bridgeActive = false
	AB_Trace("bridge active=false")
end

AB_Engine = function()
	return MTH_AutoBuyEngine
end

function MTH_AutoBuy:init()
	local engine = AB_Engine()
	if not engine then
		AB_Log("init failed: engine missing", "error")
		AB_Trace("init failed: engine missing")
		return
	end
	engine:Init()
	self.initialized = true
	AB_SetBridgeActive(self.enabled and true or false)
	AB_Trace("init done")
	if self.enabled then
		AB_Log("module initialized", "debug")
	end
end

function MTH_AutoBuy:setEnabled(enabled)
	if not self.initialized then
		self:init()
	end
	local engine = AB_Engine()
	if not engine then
		AB_Trace("setEnabled ignored: engine missing")
		return
	end
	local store = engine:EnsureDefaults()
	store.enabled = enabled and true or false
	AB_SetBridgeActive(store.enabled and true or false)
	AB_Trace("setEnabled store.enabled=" .. tostring(store.enabled))
end

function MTH_AutoBuy:onEvent(event)
	local engine = AB_Engine()
	if not engine then
		AB_Log("onEvent ignored: engine missing, event=" .. tostring(event), "debug")
		AB_Trace("engine missing, event=" .. tostring(event))
		return
	end
	if self._bridgeActive and (event == "MERCHANT_SHOW" or event == "MERCHANT_UPDATE" or event == "MERCHANT_CLOSED") then
		return
	end

	AB_Log("onEvent event=" .. tostring(event) .. " module.enabled=" .. tostring(self.enabled), "debug")

	if event == "VARIABLES_LOADED" then
		engine:Init()
		AB_SetBridgeActive(self.enabled and true or false)
		AB_Log("onEvent VARIABLES_LOADED -> engine init", "debug")
		local store = engine:EnsureDefaults()
		AB_Trace("VARIABLES_LOADED module.enabled=" .. tostring(self.enabled)
			.. " store.enabled=" .. tostring(store and store.enabled)
			.. " projectiles.enabled=" .. tostring(store and store.projectiles and store.projectiles.enabled))
		return
	end

	if not self.enabled then
		AB_Log("onEvent ignored: module disabled", "debug")
		if event == "MERCHANT_SHOW" or event == "MERCHANT_UPDATE" then
			AB_Trace(tostring(event) .. " ignored: module disabled")
		end
		return
	end

	if event == "MERCHANT_SHOW" or event == "MERCHANT_UPDATE" then
		AB_Log("onEvent merchant event forwarded: " .. tostring(event), "debug")
		AB_Trace("forwarding " .. tostring(event) .. " to engine")
		engine:OnMerchantEvent(event)
	elseif event == "MERCHANT_CLOSED" then
		AB_Trace("forwarding MERCHANT_CLOSED to engine")
		if engine.OnMerchantClosed then
			engine:OnMerchantClosed()
		end
	end
end

function MTH_AutoBuy:cleanup()
	AB_Log("module cleanup", "debug")
end

MTH:RegisterModule("autobuy", MTH_AutoBuy)
