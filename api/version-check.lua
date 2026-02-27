MTH = MTH or {}
MTH.VersionCheck = MTH.VersionCheck or {}

local VC = MTH.VersionCheck
VC.abbrev = "MTH"
VC.channelName = "LFT"
VC.nextPublishAt = nil
VC.joinAt = nil
VC.notified = false
VC._invalidVersionWarned = false

local function VC_GetTimeNow()
	if type(time) == "function" then
		return time()
	end
	if type(GetTime) == "function" then
		return math.floor(GetTime())
	end
	return 0
end

function VC:GetLocalVersionString()
	if MTH and MTH.version and tostring(MTH.version) ~= "" then
		return tostring(MTH.version)
	end
	local getMeta = _G and _G["GetAddOnMetadata"] or nil
	if type(getMeta) == "function" then
		local v = getMeta("MetaHunt", "Version")
		if v and v ~= "" then
			return tostring(v)
		end
	end
	return "0.0.0"
end

function VC:GetLocalVersionNumber()
	local versionText = self:GetLocalVersionString()
	local _, _, major, minor, patch = string.find(tostring(versionText or ""), "^(%d+)%.(%d+)%.?(%d*)$")
	if not major then
		return nil
	end
	major = tonumber(major) or 0
	minor = tonumber(minor) or 0
	patch = tonumber(patch) or 0
	return (major * 1000000) + (minor * 1000) + patch
end

local function VC_GetChannelIdByName(channelName)
	if type(GetChannelName) ~= "function" then
		return nil
	end
	local id = nil
	local name = nil
	id, name = GetChannelName(channelName)
	id = tonumber(id)
	if id and id > 0 then
		return id
	end
	return nil
end

local function VC_IsOurChannel(name)
	return type(name) == "string" and string.lower(name) == string.lower(VC.channelName)
end

function VC:ResetPublishDelay()
	self.nextPublishAt = VC_GetTimeNow() + math.random(10, 20)
end

function VC:ShouldPublish()
	return self.nextPublishAt and VC_GetTimeNow() >= self.nextPublishAt
end

function VC:TryPublish()
	if type(SendChatMessage) ~= "function" then
		return false
	end
	local channelId = VC_GetChannelIdByName(self.channelName)
	if not channelId then
		if type(JoinChannelByName) == "function" then
			JoinChannelByName(self.channelName, "", 0, false)
		end
		return false
	end
	local localVersionNumber = self:GetLocalVersionNumber()
	if not localVersionNumber or localVersionNumber <= 0 then
		if not self._invalidVersionWarned and MTH and type(MTH.Print) == "function" then
			self._invalidVersionWarned = true
			MTH:Print("Version check disabled: invalid local version format.")
		end
		return false
	end
	local payload = self.abbrev .. ":" .. tostring(localVersionNumber) .. ":v"
	SendChatMessage(payload, "CHANNEL", nil, tostring(channelId))
	return true
end

function VC:HandleRemoteMessage(message, author, channelLabel)
	if self.notified then
		return
	end
	if not message or message == "" then
		return
	end
	if author and UnitName and author == UnitName("player") then
		return
	end
	local channelName = string.gsub(tostring(channelLabel or ""), "^%d+%.%s*", "")
	if not VC_IsOurChannel(channelName) then
		return
	end
	if string.find(message, self.abbrev .. ":", 1, true) ~= 1 then
		return
	end

	local _, _, addonTag, remoteVersion = string.find(message, "^([^:]+):([^:]+):")
	if addonTag ~= self.abbrev then
		return
	end
	local remoteNumber = tonumber(remoteVersion)
	if not remoteNumber or remoteNumber <= 0 then
		return
	end
	local localVersionNumber = self:GetLocalVersionNumber()
	if not localVersionNumber or localVersionNumber <= 0 then
		return
	end
	if remoteNumber <= localVersionNumber then
		return
	end

	self.notified = true
	self.nextPublishAt = nil
	if MTH and type(MTH.Print) == "function" then
		MTH:Print("A new version is available !")
	end

	if VC.frame then
		VC.frame:UnregisterEvent("CHAT_MSG_CHANNEL")
		VC.frame:SetScript("OnUpdate", nil)
	end
end

if not VC.frame then
	local frame = CreateFrame("Frame", "MTHVersionCheckFrame", UIParent)
	if frame then
		VC.frame = frame
		frame:RegisterEvent("PLAYER_ENTERING_WORLD")
		frame:RegisterEvent("CHAT_MSG_CHANNEL")
		frame:SetScript("OnEvent", function()
			if event == "PLAYER_ENTERING_WORLD" then
				VC.joinAt = GetTime() + 6
				VC:ResetPublishDelay()
			elseif event == "CHAT_MSG_CHANNEL" then
				VC:HandleRemoteMessage(arg1, arg2, arg4)
			end
		end)
		frame:SetScript("OnUpdate", function()
			if (this._mthTick or 1) > GetTime() then
				return
			end
			this._mthTick = GetTime() + 1

			if VC.joinAt and GetTime() >= VC.joinAt then
				if not VC_GetChannelIdByName(VC.channelName) and type(JoinChannelByName) == "function" then
					JoinChannelByName(VC.channelName, "", 0, false)
				end
				VC.joinAt = nil
			end

			if VC:ShouldPublish() then
				if VC:TryPublish() then
					VC.nextPublishAt = nil
					this:SetScript("OnUpdate", nil)
				end
			end
		end)
	end
end
