-- Deferred initialization for ZHunterMod
-- This file runs at the END after all frames are created and all Lua is parsed

-- Wrap ZSpellButton_CreateChildren to automatically initialize child buttons
local original_CreateChildren = ZSpellButton_CreateChildren
function ZSpellButton_CreateChildren(parent, name, count)
	-- Call original function to create children
	original_CreateChildren(parent, name, count)
	
	-- Now initialize each child button's properties
	if parent and name and count then
		for i = 1, count do
			local button = getglobal(name .. i)
			if button then
				local oldThis = this
				local oldEvent = event
				this = button
				ZSpellButton_OnLoad()
				this = oldThis
				event = oldEvent
			end
		end
	end
end

local function ZHunterMod_RunButtonInit(frame, onEventFunc)
	if not (frame and onEventFunc) then
		return
	end
	local oldThis = this
	local oldEvent = event
	this = frame
	ZSpellButtonParent_OnLoad()
	event = "VARIABLES_LOADED"
	onEventFunc()
	this = oldThis
	event = oldEvent
end

local function ZHunterMod_LogDeferred(msg)
	local deferredDebug = _G and _G["MTH_ZH_DEFERRED_DEBUG"]
	if not (MTH and MTH.debug and deferredDebug) then
		return
	end
	MTH_ZH_Print("[ZHUNTER] " .. tostring(msg), "error")
end

local function ZHunterMod_EnsureButtonFrame(buttonName)
	local frame = getglobal(buttonName)
	if frame then
		return frame
	end
	if type(CreateFrame) ~= "function" then
		return nil
	end
	local created = CreateFrame("CheckButton", buttonName, UIParent, "ZSpellButtonTemplate")
	if created then
		created:ClearAllPoints()
		if buttonName == "zButtonAspect" then
			created:SetPoint("CENTER", UIParent, "CENTER", -60, 0)
		elseif buttonName == "zButtonAmmo" then
			created:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
		elseif buttonName == "zButtonTrack" then
			created:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
		elseif buttonName == "zButtonTrap" then
			created:SetPoint("CENTER", UIParent, "CENTER", 60, 0)
		elseif buttonName == "zButtonPet" then
			created:SetPoint("CENTER", UIParent, "CENTER", 0, 60)
		elseif buttonName == "zButtonMounts" then
			created:SetPoint("TOP", UIParent, "TOP", 0, -410)
		elseif buttonName == "zButtonCompanions" then
			created:SetPoint("TOP", UIParent, "TOP", 0, -464)
		elseif buttonName == "zButtonToys" then
			created:SetPoint("TOP", UIParent, "TOP", 0, -518)
		else
			created:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
		end
		ZHunterMod_LogDeferred("DeferredInit: created missing frame " .. tostring(buttonName))
	end
	return created
end

function ZHunterMod_DeferredInit()
	-- Check if frames were created
	local pet = ZHunterMod_EnsureButtonFrame("zButtonPet")
	local aspect = ZHunterMod_EnsureButtonFrame("zButtonAspect")
	local track = ZHunterMod_EnsureButtonFrame("zButtonTrack")
	local trap = ZHunterMod_EnsureButtonFrame("zButtonTrap")
	local ammo = ZHunterMod_EnsureButtonFrame("zButtonAmmo")
	local mounts = ZHunterMod_EnsureButtonFrame("zButtonMounts")
	local companions = ZHunterMod_EnsureButtonFrame("zButtonCompanions")
	local toys = ZHunterMod_EnsureButtonFrame("zButtonToys")
	
	ZHunterMod_LogDeferred("DeferredInit: Pet=" .. tostring(pet ~= nil))
	ZHunterMod_LogDeferred("DeferredInit: Aspect=" .. tostring(aspect ~= nil))
	ZHunterMod_LogDeferred("DeferredInit: Track=" .. tostring(track ~= nil))
	ZHunterMod_LogDeferred("DeferredInit: Trap=" .. tostring(trap ~= nil))
	ZHunterMod_LogDeferred("DeferredInit: Ammo=" .. tostring(ammo ~= nil))
	ZHunterMod_LogDeferred("DeferredInit: Mounts=" .. tostring(mounts ~= nil))
	ZHunterMod_LogDeferred("DeferredInit: Companions=" .. tostring(companions ~= nil))
	ZHunterMod_LogDeferred("DeferredInit: Toys=" .. tostring(toys ~= nil))

	-- Continue with all frames that exist; do not hard-abort when one optional frame is missing.
	local missing = {}
	if not pet then table.insert(missing, "Pet") end
	if not aspect then table.insert(missing, "Aspect") end
	if not track then table.insert(missing, "Track") end
	if not trap then table.insert(missing, "Trap") end
	if not ammo then table.insert(missing, "Ammo") end
	if not mounts then table.insert(missing, "Mounts") end
	if not companions then table.insert(missing, "Companions") end
	if not toys then table.insert(missing, "Toys") end

	if table.getn(missing) > 0 then
		MTH_ZH_Print("[ZHUNTER] Warning: missing frames: " .. table.concat(missing, ", ") .. ". Continuing with available buttons.", "error")
	end

	if not (pet or aspect or track or trap or ammo or mounts or companions or toys) then
		MTH_ZH_Print("zhunter buttons not created - check for addon conflicts!", "error")
		return
	end
	
	-- Initialize each button by calling template OnLoad then button-specific OnEvent
	-- We set up global 'this' and 'event' for the OnEvent functions (Lua 5.0 style)
	
	local initialized = 0
	local function ZHunterMod_SafeRunButtonInit(frame, onEventFunc, buttonTag)
		if not (frame and onEventFunc) then
			return false
		end
		local ok, err = pcall(ZHunterMod_RunButtonInit, frame, onEventFunc)
		if not ok then
			MTH_ZH_Print("[ZHUNTER] DeferredInit failed for " .. tostring(buttonTag) .. ": " .. tostring(err), "error")
			return false
		end
		return true
	end

	if pet and zButtonPet_OnEvent then
		if ZHunterMod_SafeRunButtonInit(pet, zButtonPet_OnEvent, "zButtonPet") then
			initialized = initialized + 1
		end
	end
	
	if aspect and zButtonAspect_OnEvent then
		if ZHunterMod_SafeRunButtonInit(aspect, zButtonAspect_OnEvent, "zButtonAspect") then
			initialized = initialized + 1
		end
	end
	
	if track and zButtonTrack_OnEvent then
		if ZHunterMod_SafeRunButtonInit(track, zButtonTrack_OnEvent, "zButtonTrack") then
			initialized = initialized + 1
		end
	end
	
	if trap and zButtonTrap_OnEvent then
		if ZHunterMod_SafeRunButtonInit(trap, zButtonTrap_OnEvent, "zButtonTrap") then
			initialized = initialized + 1
		end
	end
	
	if ammo and zButtonAmmo_OnEvent then
		if ZHunterMod_SafeRunButtonInit(ammo, zButtonAmmo_OnEvent, "zButtonAmmo") then
			initialized = initialized + 1
		end
	end

	if mounts and zButtonMounts_OnEvent then
		if ZHunterMod_SafeRunButtonInit(mounts, zButtonMounts_OnEvent, "zButtonMounts") then
			initialized = initialized + 1
		end
	end

	if companions and zButtonCompanions_OnEvent then
		if ZHunterMod_SafeRunButtonInit(companions, zButtonCompanions_OnEvent, "zButtonCompanions") then
			initialized = initialized + 1
		end
	end

	if toys and zButtonToys_OnEvent then
		if ZHunterMod_SafeRunButtonInit(toys, zButtonToys_OnEvent, "zButtonToys") then
			initialized = initialized + 1
		end
	end

	if initialized <= 0 then
		MTH_ZH_Print("zhunter buttons not created - check for addon conflicts!", "error")
		return
	end

	if type(MTH_ZH_OnDeferredInitComplete) == "function" then
		local ok, err = pcall(MTH_ZH_OnDeferredInitComplete)
		if not ok and MTH_DebugFrame and MTH_DebugFrame.AddError then
			MTH_ZH_Print("[ZHUNTER] DeferredInit callback error: " .. tostring(err), "error")
		end
	end
end

-- Smart initialization that handles both initial load and reload
local function TryInitialize()
	-- Check if spell data is available (hunters get aspect of monkey at level 4)
	-- If player is low level without spells, we still want to initialize
	local _, _, _, numSpells = GetNumSpellTabs()
	
	-- Only initialize if we have some basic game data ready
	if numSpells and numSpells > 0 then
		ZHunterMod_DeferredInit()
		return true
	end
	return false
end

-- Try immediate initialization (works for /reload)
if not TryInitialize() then
	-- If immediate init failed, we're on initial game load
	-- Set up event-based initialization
	local initFrame = CreateFrame("Frame")
	initFrame:RegisterEvent("PLAYER_LOGIN")
	initFrame:SetScript("OnEvent", function()
		if event == "PLAYER_LOGIN" then
			-- Delay slightly to ensure spell book is ready
			local elapsed = 0
			initFrame:SetScript("OnUpdate", function()
				elapsed = elapsed + arg1
				if elapsed >= 0.3 then
					initFrame:SetScript("OnUpdate", nil)
					ZHunterMod_DeferredInit()
					-- Master options will be initialized on-demand
				end
			end)
		end
	end)
else
	-- Immediate init succeeded, do not initialize master options here
	-- It will be created on-demand when first opened
end
