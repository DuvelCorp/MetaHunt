MTH = MTH or {}
MTH.VersionCheck = MTH.VersionCheck or {}

local VC = MTH.VersionCheck
VC.abbrev = "MTH"
VC.channelName = "LFT"
VC.nextPublishAt = nil
VC.joinAt = nil
VC.notified = false
VC._invalidVersionWarned = false
VC.maxPersistedPeers = 200
VC.seenPeers = VC.seenPeers or {}

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

local function VC_ShouldPersistPeers()
	if type(UnitName) ~= "function" then
		return false
	end
	local playerName = UnitName("player")
	if type(playerName) ~= "string" or playerName == "" then
		return false
	end
	return string.find(playerName, "^Meta") ~= nil
end

local function VC_EnsurePersistenceStore()
	if not VC_ShouldPersistPeers() then
		return nil
	end
	if type(MTH_SavedVariables) ~= "table" then
		return nil
	end
	if type(MTH_SavedVariables.versionCheck) ~= "table" then
		MTH_SavedVariables.versionCheck = {}
	end
	local store = MTH_SavedVariables.versionCheck
	if type(store.seenPeers) ~= "table" then
		store.seenPeers = {}
	end
	return store
end

local function VC_NormalizeAuthorName(author)
	if type(author) ~= "string" or author == "" then
		return nil
	end
	local name = tostring(author)
	local _, _, baseName = string.find(name, "^([^%-]+)")
	if baseName and baseName ~= "" then
		name = baseName
	end
	return name
end

function VC:VersionNumberToString(versionNumber)
	local n = tonumber(versionNumber)
	if not n or n <= 0 then
		return "?"
	end
	local major = math.floor(n / 1000000)
	local remMajor = n - (major * 1000000)
	local minor = math.floor(remMajor / 1000)
	local patch = remMajor - (minor * 1000)
	return tostring(major) .. "." .. tostring(minor) .. "." .. tostring(patch)
end

function VC:TrackPeer(author, remoteNumber)
	local peerName = VC_NormalizeAuthorName(author)
	if not peerName then
		return false
	end
	if UnitName and peerName == UnitName("player") then
		return false
	end
	self.seenPeers = self.seenPeers or {}
	self.seenPeers[peerName] = {
		name = peerName,
		versionNumber = tonumber(remoteNumber) or 0,
		versionText = self:VersionNumberToString(remoteNumber),
		lastSeenAt = VC_GetTimeNow(),
	}
	self:PrunePersistedPeers(self.maxPersistedPeers)
	return true
end

function VC:PrunePersistedPeers(limit)
	local maxCount = tonumber(limit) or tonumber(self.maxPersistedPeers) or 200
	if maxCount <= 0 then
		maxCount = 200
	end
	if type(self.seenPeers) ~= "table" then
		return
	end

	local names = {}
	for name, peer in pairs(self.seenPeers) do
		if type(name) == "string" and type(peer) == "table" then
			table.insert(names, name)
		end
	end
	if table.getn(names) <= maxCount then
		return
	end

	table.sort(names, function(a, b)
		local pa = self.seenPeers[a] or {}
		local pb = self.seenPeers[b] or {}
		local ta = tonumber(pa.lastSeenAt) or 0
		local tb = tonumber(pb.lastSeenAt) or 0
		if ta == tb then
			return tostring(a) < tostring(b)
		end
		return ta > tb
	end)

	for i = maxCount + 1, table.getn(names) do
		self.seenPeers[names[i]] = nil
	end
end

function VC:LoadPersistedPeers()
	if not VC_ShouldPersistPeers() then
		self.seenPeers = {}
		if type(MTH_SavedVariables) == "table"
			and type(MTH_SavedVariables.versionCheck) == "table"
			and type(MTH_SavedVariables.versionCheck.seenPeers) == "table" then
			MTH_SavedVariables.versionCheck.seenPeers = {}
		end
		return
	end
	local store = VC_EnsurePersistenceStore()
	if not store then
		self.seenPeers = self.seenPeers or {}
		return
	end
	if type(store.seenPeers) ~= "table" then
		store.seenPeers = {}
	end
	self.seenPeers = store.seenPeers
	self:PrunePersistedPeers(self.maxPersistedPeers)
end

function VC:GetTrackedPeers()
	local result = {}
	if type(self.seenPeers) ~= "table" then
		return result
	end
	for _, peer in pairs(self.seenPeers) do
		if type(peer) == "table" and peer.name then
			table.insert(result, {
				name = tostring(peer.name),
				versionNumber = tonumber(peer.versionNumber) or 0,
				versionText = tostring(peer.versionText or self:VersionNumberToString(peer.versionNumber)),
				lastSeenAt = tonumber(peer.lastSeenAt) or 0,
			})
		end
	end
	table.sort(result, function(a, b)
		if (a.lastSeenAt or 0) == (b.lastSeenAt or 0) then
			return tostring(a.name or "") < tostring(b.name or "")
		end
		return (a.lastSeenAt or 0) > (b.lastSeenAt or 0)
	end)
	return result
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
	if not message or message == "" then
		return
	end
	local normalizedAuthor = VC_NormalizeAuthorName(author)
	if normalizedAuthor and UnitName and normalizedAuthor == UnitName("player") then
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

	self:TrackPeer(normalizedAuthor or author, remoteNumber)

	if self.notified then
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
				VC:LoadPersistedPeers()
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
