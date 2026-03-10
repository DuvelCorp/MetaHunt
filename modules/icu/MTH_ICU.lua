local ICU_VERSION = "ICU 1.4 - Shanktank's Version";

local ICU_MAX_LINES = 10;

local ICU_CLASSES = {
    ["Warrior"] = { .25,   0,   0, .25; },
    ["Mage"]    = {  .5, .25,   0, .25; },
    ["Rogue"]   = { .75,  .5,   0, .25; },
    ["Druid"]   = {   1, .75,   0, .25; },
    ["Hunter"]  = { .25,   0, .25,  .5; },
    ["Shaman"]  = {  .5, .25, .25,  .5; },
    ["Priest"]  = { .75,  .5, .25,  .5; },
    ["Warlock"] = {   1, .75, .25,  .5; },
    ["Paladin"] = { .25,   0,  .5, .75; }
};

local ICU_DESCRIPTIONS = {
    ["ALERT"]    = "ALERT will immediately ping and add a message in the specified chat when you click the blip of a PvP-flagged player of the opposite faction on the minimap",
    ["ANNOUNCE"] = "ANNOUNCE will add a message in the specified chat when you click an entry in the popup frame",
    ["ANCHOR"]   = "ANCHOR sets the location of the frame that pops up when you click a blip on the minimap",
    ["PLAYER_COLOR_MODE"] = "PLAYER_COLOR_MODE controls how player rows are colored (CLASS, REACTION, FACTION, CUSTOM)"
};
ICU_OPTIONS = {
    ["ALERT"]    = { "AUTO", "PARTY", "RAID", "SELF", "MTH Message", "OFF"; },
    ["ANNOUNCE"] = { "AUTO", "SAY", "YELL", "PARTY", "RAID", "SELF", "MTH Message", "OFF"; },
    ["ANCHOR"]   = { "TOP", "TOPLEFT", "TOPRIGHT", "BOTTOM", "BOTTOMLEFT", "BOTTOMRIGHT", "LEFT", "RIGHT", "CUSTOM"; },
    ["POPUP_HIDE_DELAY"] = { "INSTANT", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10"; },
    ["HEALTH_TEXT_MODE"] = { "NONE", "PERCENT", "HP", "BOTH"; },
    ["PLAYER_COLOR_MODE"] = { "CLASS", "REACTION", "FACTION", "CUSTOM"; }
};

local ICU_PING_X = 0;
local ICU_PING_Y = 0;

local icu_prevtooltip = nil;
local ICU_ENABLED = false;
local ICU_HOOK_ACTIVE = false;
local ICU_Original_Minimap_OnClick = nil;
local ICU_LAST_ALERT_KEY = "";
local ICU_LAST_ALERT_AT = 0;
local ICU_POPUP_MOUSE_OUT_AT = nil;
local ICU_GetStore;
local ICU_CustomAnchor = nil;
local ICU_STORE_CACHE = nil;
local ICU_POPUP_LAST_UPDATE_AT = 0;
local ICU_POPUP_UPDATE_INTERVAL = 0.10;
local ICU_MOUSEOVER_LAST_UPDATE_AT = 0;
local ICU_MOUSEOVER_UPDATE_INTERVAL = 0.15;
local ICU_TRACE_ENABLED = false;

local ICU_CLASS_COLOR_FALLBACK = {
    WARRIOR = { 0.78, 0.61, 0.43 },
    MAGE = { 0.41, 0.80, 0.94 },
    ROGUE = { 1.00, 0.96, 0.41 },
    DRUID = { 1.00, 0.49, 0.04 },
    HUNTER = { 0.67, 0.83, 0.45 },
    SHAMAN = { 0.00, 0.44, 0.87 },
    PRIEST = { 1.00, 1.00, 1.00 },
    WARLOCK = { 0.58, 0.51, 0.79 },
    PALADIN = { 0.96, 0.55, 0.73 },
};

local ICU_DEFAULT_BG_COLORS = {
    PLAYER_HOSTILE = { 1.00, 0.20, 0.20 },
    PLAYER_NEUTRAL = { 1.00, 0.85, 0.10 },
    PLAYER_FRIENDLY = { 0.20, 0.75, 1.00 },
    NPC_HOSTILE = { 1.00, 0.20, 0.20 },
    NPC_NEUTRAL = { 1.00, 0.85, 0.10 },
    NPC_FRIENDLY = { 0.10, 0.90, 0.10 },
    UNKNOWN = { 0.70, 0.70, 0.70 },
};

--------------------------------------------------------------------------------
-- Auxiliary functions
--------------------------------------------------------------------------------

local function ICU_Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage(msg, 1, 1, 1);
end

local function ICU_PrintMTH(msg)
    if MTH and MTH.Print then
        MTH:Print(msg);
        return;
    end
    ICU_Print(msg);
end

local function ICU_Trace(msg)
    if not ICU_TRACE_ENABLED then
        return;
    end
    ICU_PrintMTH("[ICUTRACE] " .. tostring(msg));
end

local function ICU_CommandTrace(mode)
    local action = string.lower(tostring(mode or "status"));
    if action == "on" or action == "1" or action == "true" then
        ICU_TRACE_ENABLED = true;
        ICU_Trace("trace enabled");
        return;
    elseif action == "off" or action == "0" or action == "false" then
        ICU_Trace("trace disabled");
        ICU_TRACE_ENABLED = false;
        return;
    end
    ICU_PrintMTH("[ICUTRACE] status=" .. tostring(ICU_TRACE_ENABLED and true or false));
end

local function ICU_GetAlertPlayerName(unit, store)
    unit = unit or "target";
    store = store or ICU_GetStore();

    local baseName = UnitName(unit) or "";
    if baseName == "" then
        return "Unknown";
    end

    if not store["SHOW_CUSTOM_TITLES"] then
        return baseName;
    end

    local titledName = UnitPVPName(unit);
    if type(titledName) ~= "string" or titledName == "" then
        return baseName;
    end

    titledName = string.gsub(titledName, "\r\n", " ");
    titledName = string.gsub(titledName, "\n", " ");
    titledName = string.gsub(titledName, "%s+", " ");
    titledName = string.gsub(titledName, "^%s+", "");
    titledName = string.gsub(titledName, "%s+$", "");

    if titledName == "" then
        return baseName;
    end

    return titledName;
end

local function ICU_ClampColor(v)
    v = tonumber(v) or 0;
    if v < 0 then return 0 end
    if v > 1 then return 1 end
    return v;
end

local function ICU_EnsureStoreColors(store)
    if type(store["COLORS"]) ~= "table" then
        store["COLORS"] = {};
    end

    for key, def in pairs(ICU_DEFAULT_BG_COLORS) do
        local row = store["COLORS"][key];
        if type(row) ~= "table" then
            store["COLORS"][key] = { def[1], def[2], def[3] };
        else
            row[1] = ICU_ClampColor(row[1] ~= nil and row[1] or def[1]);
            row[2] = ICU_ClampColor(row[2] ~= nil and row[2] or def[2]);
            row[3] = ICU_ClampColor(row[3] ~= nil and row[3] or def[3]);
        end
    end
end

local function ICU_GetConfiguredColor(store, key)
    store = store or ICU_GetStore();
    ICU_EnsureStoreColors(store);

    local row = store["COLORS"][key];
    if type(row) == "table" then
        return row[1], row[2], row[3];
    end

    local def = ICU_DEFAULT_BG_COLORS[key] or ICU_DEFAULT_BG_COLORS.UNKNOWN;
    return def[1], def[2], def[3];
end

ICU_GetStore = function()
    if type(ICU_STORE_CACHE) == "table" then
        return ICU_STORE_CACHE;
    end

    local store = nil;

    if MTH and MTH.GetModuleCharSavedVariables then
        store = MTH:GetModuleCharSavedVariables("icu");
        if type(store) == "table" and MTH.GetModuleSavedVariables and next(store) == nil then
            local accountStore = MTH:GetModuleSavedVariables("icu");
            if type(accountStore) == "table" then
                for key, value in pairs(accountStore) do
                    if store[key] == nil then
                        store[key] = value;
                    end
                end
                ICU_Trace("store migrated account->char (empty char store)");
            end
        end
    end

    if type(store) ~= "table" then
        ICUvars = ICUvars or {};
        store = ICUvars;
    end

    if type(ICUvars) == "table" and ICUvars ~= store then
        for key, value in pairs(ICUvars) do
            if store[key] == nil then
                store[key] = value;
            end
        end
        ICU_Trace("store migrated legacy ICUvars -> module store");
    end

    if store["ALERT"] == nil then
        store["ALERT"] = "MTH Message";
    elseif store["ALERT"] == "SAY" or store["ALERT"] == "YELL" then
        store["ALERT"] = "SELF";
    end
    if store["ANNOUNCE"] == nil then
        store["ANNOUNCE"] = "MTH Message";
    end
    if store["ANCHOR"] == nil then
        store["ANCHOR"] = "BOTTOMRIGHT";
    end
    if store["POPUP_HIDE_DELAY"] == nil then
        store["POPUP_HIDE_DELAY"] = "INSTANT";
    else
        local rawDelay = tostring(store["POPUP_HIDE_DELAY"]);
        if rawDelay ~= "INSTANT" then
            local n = tonumber(rawDelay);
            if not n then
                store["POPUP_HIDE_DELAY"] = "INSTANT";
            else
                n = math.floor(n);
                if n < 1 then
                    store["POPUP_HIDE_DELAY"] = "INSTANT";
                elseif n > 10 then
                    store["POPUP_HIDE_DELAY"] = "10";
                else
                    store["POPUP_HIDE_DELAY"] = tostring(n);
                end
            end
        end
    end
    if store["mouseOver"] == nil then
        store["mouseOver"] = false;
    end
    if store["HEALTH_TEXT_MODE"] == nil then
        store["HEALTH_TEXT_MODE"] = "BOTH";
    elseif store["HEALTH_TEXT_MODE"] == "AUTO" then
        store["HEALTH_TEXT_MODE"] = "BOTH";
    end
    if store["PLAYER_COLOR_MODE"] == nil then
        store["PLAYER_COLOR_MODE"] = "CLASS";
    end
    if store["REACTION_ONLY_PVP_PLAYERS"] == nil then
        store["REACTION_ONLY_PVP_PLAYERS"] = true;
    end
    if store["SHOW_GUILD_NAME"] == nil then
        store["SHOW_GUILD_NAME"] = false;
    end
    if store["SHOW_PLAYER_CLASS"] == nil then
        store["SHOW_PLAYER_CLASS"] = true;
    end
    if store["SHOW_PLAYER_RACE"] == nil then
        store["SHOW_PLAYER_RACE"] = true;
    end
    if store["SHOW_CUSTOM_TITLES"] == nil then
        store["SHOW_CUSTOM_TITLES"] = false;
    end
    if store["EXPAND_UP"] == nil then
        store["EXPAND_UP"] = false;
    end
    if store["CUSTOM_ANCHOR_X"] ~= nil then
        store["CUSTOM_ANCHOR_X"] = math.floor((tonumber(store["CUSTOM_ANCHOR_X"]) or 0) + 0.5);
    end
    if store["CUSTOM_ANCHOR_Y"] ~= nil then
        store["CUSTOM_ANCHOR_Y"] = math.floor((tonumber(store["CUSTOM_ANCHOR_Y"]) or 0) + 0.5);
    end

    ICU_EnsureStoreColors(store);

    ICU_STORE_CACHE = store;
    ICUvars = store;
    return store;
end

local function ICU_ShouldEmitAlert(key)
    local now = 0;
    if type(GetTime) == "function" then
        now = GetTime();
    end

    local normalized = tostring(key or "");
    if normalized ~= "" and ICU_LAST_ALERT_KEY == normalized and (now - ICU_LAST_ALERT_AT) < 1.5 then
        return false;
    end

    ICU_LAST_ALERT_KEY = normalized;
    ICU_LAST_ALERT_AT = now;
    return true;
end

local function ICU_GetPopupHideDelaySeconds(store)
    store = store or ICU_GetStore();

    local raw = tostring(store["POPUP_HIDE_DELAY"] or "INSTANT");
    if raw == "INSTANT" then
        return 0;
    end

    local n = tonumber(raw);
    if not n then
        return 0;
    end

    n = math.floor(n);
    if n < 1 then
        return 0;
    end
    if n > 10 then
        return 10;
    end
    return n;
end

local function ICU_EnsureCustomAnchor(store)
    if ICU_CustomAnchor then
        return ICU_CustomAnchor;
    end

    store = store or ICU_GetStore();

    local frame = CreateFrame("Button", "MetaHuntICUAnchor", UIParent);
    frame:SetWidth(220);
    frame:SetHeight(25);
    frame:SetClampedToScreen(true);
    frame:SetMovable(true);
    frame:RegisterForDrag("LeftButton");

    local px = tonumber(store["CUSTOM_ANCHOR_X"]);
    local py = tonumber(store["CUSTOM_ANCHOR_Y"]);
    if px ~= nil and py ~= nil then
        frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", px, py);
        ICU_Trace("custom-anchor restore point=TOPLEFT->UIParent:TOPLEFT @(" .. tostring(px) .. "," .. tostring(py) .. ")");
    else
        frame:SetPoint("CENTER", UIParent, "CENTER", 0, 50);
        ICU_Trace("custom-anchor default point=CENTER->UIParent:CENTER @(0,50)");
    end

    frame:SetScript("OnDragStart", function()
        this = this or this;
        if this and this.StartMoving then
            this:StartMoving();
        end
    end);

    frame:SetScript("OnDragStop", function()
        this = this or this;
        if not this then return end

        if this.StopMovingOrSizing then
            this:StopMovingOrSizing();
        end

        local _, _, _, x, y = this:GetPoint();
        x = tonumber(x);
        y = tonumber(y);
        if not x or not y then return end

        x = math.floor(x + 0.5);
        y = math.floor(y + 0.5);
        this:ClearAllPoints();
        this:SetPoint("TOPLEFT", UIParent, "TOPLEFT", x, y);

        local storeNow = ICU_GetStore();
        storeNow["CUSTOM_ANCHOR_X"] = x;
        storeNow["CUSTOM_ANCHOR_Y"] = y;
        ICU_Trace("custom-anchor drag-stop saved x=" .. tostring(x) .. " y=" .. tostring(y));
        ICU_SetPoints();
    end);

    frame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = false,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 5, right = 5, top = 5, bottom = 5 },
    });
    frame:SetBackdropColor(0, 1, 0, 0.6);

    frame.Text = frame:CreateFontString(nil, "OVERLAY");
    frame.Text:SetFontObject(GameFontNormalSmall);
    frame.Text:ClearAllPoints();
    frame.Text:SetTextColor(1, 1, 1, 1);
    frame.Text:SetWidth(220);
    frame.Text:SetHeight(25);
    frame.Text:SetPoint("TOPLEFT", frame, "TOPLEFT");
    frame.Text:SetJustifyH("CENTER");
    frame.Text:SetJustifyV("MIDDLE");
    frame.Text:SetText("MetaHunt MCU");
    frame:Hide();

    ICU_CustomAnchor = frame;
    return frame;
end

function ICU_ToggleAnchor()
    local store = ICU_GetStore();
    if store["ANCHOR"] ~= "CUSTOM" then
        store["ANCHOR"] = "CUSTOM";
        ICU_SetPoints();
        ICU_Trace("toggle-anchor forced CUSTOM mode");
    end

    local anchor = ICU_EnsureCustomAnchor(store);
    if anchor:IsVisible() then
        anchor:Hide();
    else
        anchor:Show();
    end
end

local function ICU_ClampPercent(value)
    local pct = math.floor((tonumber(value) or 0) + 0.5);
    if pct < 0 then
        return 0;
    end
    if pct > 100 then
        return 100;
    end
    return pct;
end

local function ICU_GetHealthLabelAndBar(currentHealth, maxHealth, mode)
    currentHealth = tonumber(currentHealth) or 0;
    maxHealth = tonumber(maxHealth) or 0;
    mode = tostring(mode or "AUTO");

    if mode == "NONE" then
        return "", nil;
    end

    local hasMax = maxHealth > 0 and currentHealth <= maxHealth;
    local percent = nil;
    if hasMax then
        percent = ICU_ClampPercent((currentHealth / maxHealth) * 100);
    elseif currentHealth <= 100 then
        percent = ICU_ClampPercent(currentHealth);
    end

    if mode == "PERCENT" then
        if percent ~= nil then
            return "[" .. percent .. "%]", percent;
        end
        return "[" .. currentHealth .. " HP]", 100;
    elseif mode == "HP" then
        if hasMax then
            return "[" .. currentHealth .. "/" .. maxHealth .. " HP]", percent;
        end
        return "[" .. currentHealth .. " HP]", (percent or 100);
    elseif mode == "BOTH" then
        if hasMax and percent ~= nil then
            return "[" .. currentHealth .. "/" .. maxHealth .. " | " .. percent .. "%]", percent;
        elseif percent ~= nil then
            return "[" .. percent .. "% | " .. currentHealth .. " HP]", percent;
        end
        return "[" .. currentHealth .. " HP]", 100;
    end

    if hasMax and percent ~= nil then
        return "[" .. percent .. "%]", percent;
    elseif percent ~= nil then
        return "[" .. percent .. "%]", percent;
    end
    return "[" .. currentHealth .. " HP]", 100;
end

local function ICU_GetClassColor(classToken)
    classToken = tostring(classToken or "");
    if classToken == "" then
        return nil;
    end

    if RAID_CLASS_COLORS and RAID_CLASS_COLORS[classToken] then
        local c = RAID_CLASS_COLORS[classToken];
        return c.r or 1, c.g or 1, c.b or 1;
    end

    local fallback = ICU_CLASS_COLOR_FALLBACK[classToken];
    if fallback then
        return fallback[1], fallback[2], fallback[3];
    end

    return nil;
end

local function ICU_GetDisplayColor(unit, classToken, store)
    unit = tostring(unit or "target");
    store = store or ICU_GetStore();

    if UnitIsPlayer(unit) then
        local mode = tostring(store["PLAYER_COLOR_MODE"] or "CLASS");
        local reactionOnlyPvp = store["REACTION_ONLY_PVP_PLAYERS"] and true or false;
        local myFaction = UnitFactionGroup("player");
        local theirFaction = UnitFactionGroup(unit);
        local hostileByFaction = myFaction and theirFaction and myFaction ~= theirFaction;
        local reaction = UnitReaction(unit, "player");
        local isPvp = UnitIsPVP and UnitIsPVP(unit) and true or false;
        local hostileByPvp = hostileByFaction and isPvp;

        local function classOrFriendly()
            local cr, cg, cb = ICU_GetClassColor(classToken);
            if cr and cg and cb then
                return cr, cg, cb;
            end
            return ICU_GetConfiguredColor(store, "PLAYER_FRIENDLY");
        end

        if mode == "REACTION" then
            if reactionOnlyPvp and not isPvp then
                local r, g, b = classOrFriendly();
                return r, g, b;
            end

            if reaction and reaction <= 3 then
                local r, g, b = ICU_GetConfiguredColor(store, "PLAYER_HOSTILE");
                return r, g, b;
            elseif reaction and reaction == 4 then
                local r, g, b = ICU_GetConfiguredColor(store, "PLAYER_NEUTRAL");
                return r, g, b;
            elseif reaction and reaction >= 5 then
                local r, g, b = ICU_GetConfiguredColor(store, "PLAYER_FRIENDLY");
                return r, g, b;
            end
        elseif mode == "FACTION" then
            if hostileByPvp then
                local r, g, b = ICU_GetConfiguredColor(store, "PLAYER_HOSTILE");
                return r, g, b;
            end
            local r, g, b = ICU_GetConfiguredColor(store, "PLAYER_FRIENDLY");
            return r, g, b;
        elseif mode == "CUSTOM" then
            if hostileByPvp then
                local r, g, b = ICU_GetConfiguredColor(store, "PLAYER_HOSTILE");
                return r, g, b;
            elseif reaction and reaction == 4 then
                local r, g, b = ICU_GetConfiguredColor(store, "PLAYER_NEUTRAL");
                return r, g, b;
            end
            local r, g, b = ICU_GetConfiguredColor(store, "PLAYER_FRIENDLY");
            return r, g, b;
        end

        local r, g, b = classOrFriendly();
        return r, g, b;
    end

    local reaction = UnitReaction(unit, "player");
    if reaction and reaction <= 3 then
        return ICU_GetConfiguredColor(store, "NPC_HOSTILE");
    elseif reaction and reaction == 4 then
        return ICU_GetConfiguredColor(store, "NPC_NEUTRAL");
    elseif reaction and reaction >= 5 then
        return ICU_GetConfiguredColor(store, "NPC_FRIENDLY");
    end

    return ICU_GetConfiguredColor(store, "UNKNOWN");
end

local function ICU_IsEnabled()
    return ICU_ENABLED and true or false;
end

local function ICU_InstallHook()
    if ICU_HOOK_ACTIVE then
        return;
    end

    if type(Minimap_OnClick) == "function" then
        ICU_Original_Minimap_OnClick = Minimap_OnClick;
        Minimap_OnClick = ICU_Minimap_OnClick_Event;
        ICU_HOOK_ACTIVE = true;
    end
end

local function ICU_UninstallHook()
    if not ICU_HOOK_ACTIVE then
        return;
    end

    if Minimap_OnClick == ICU_Minimap_OnClick_Event and type(ICU_Original_Minimap_OnClick) == "function" then
        Minimap_OnClick = ICU_Original_Minimap_OnClick;
    end

    ICU_HOOK_ACTIVE = false;
end

function ICU_SetEnabled(enabled)
    ICU_ENABLED = enabled and true or false;
    ICU_GetStore();

    if ICU_ENABLED then
        ICU_InstallHook();
        if ICU_UpdateFrame then
            ICU_UpdateFrame:Show();
        end
        return;
    end

    ICU_UninstallHook();
    if ICU_UpdateFrame then
        ICU_UpdateFrame:Hide();
    end
    if ICU_CustomAnchor then
        ICU_CustomAnchor:Hide();
    end
    icu_prevtooltip = nil;
    ICU_Clear_Popup();
end

local function ICU_StringifyKeys(tab)
    local str = "";

    for key, _ in pairs(tab) do
        str = str .. key .. ", ";
    end

    return string.sub(str, 1, -3);
end

local function ICU_TableHasValue(tab, val)
    for _, v in ipairs(tab) do
        if val == v then
            return true;
        end
    end

    return false;
end

--------------------------------------------------------------------------------
-- OnFoo() functions
--------------------------------------------------------------------------------

function ICU_OnLoad()
    this:RegisterEvent("VARIABLES_LOADED");

    SLASH_ICUTRACE1 = "/icutrace";
    SlashCmdList["ICUTRACE"] = function(msg)
        ICU_CommandTrace(msg);
    end

    ICU_STORE_CACHE = nil;
    if ICU_UpdateFrame then
        ICU_UpdateFrame:Hide();
    end
    ICU_Clear_Popup();
end

function ICU_OnEvent(event)
    if event == "VARIABLES_LOADED" then
        ICU_STORE_CACHE = nil;
        ICU_GetStore();
        ICU_SetPoints();
    end
end

function ICU_SetPoints()
    local store = ICU_GetStore();

    if not ICU_Popup then
        return;
    end

    ICU_Popup:ClearAllPoints();

    if store["ANCHOR"] == "CUSTOM" then
        local anchor = ICU_EnsureCustomAnchor(store);
        local px = tonumber(store["CUSTOM_ANCHOR_X"]);
        local py = tonumber(store["CUSTOM_ANCHOR_Y"]);
        if px ~= nil and py ~= nil then
            anchor:ClearAllPoints();
            anchor:SetPoint("TOPLEFT", UIParent, "TOPLEFT", px, py);
        end

        if store["EXPAND_UP"] then
            ICU_Popup:SetPoint("BOTTOMLEFT", anchor, "TOPLEFT", 0, 0);
        else
            ICU_Popup:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, 0);
        end
        return;
    end

    if ICU_CustomAnchor then
        ICU_CustomAnchor:Hide();
    end

    if store["ANCHOR"] == "BOTTOMRIGHT" then
        ICU_Popup:SetPoint("TOPRIGHT", "MinimapCluster", "BOTTOMRIGHT", 0, 0);
    elseif store["ANCHOR"] == "TOPRIGHT" then
        ICU_Popup:SetPoint("BOTTOMRIGHT", "MinimapCluster", "TOPRIGHT", 0, 0);
    elseif store["ANCHOR"] == "BOTTOM" then
        ICU_Popup:SetPoint("TOP", "MinimapCluster", "BOTTOM", 0, 0);
    elseif store["ANCHOR"] == "TOP" then
        ICU_Popup:SetPoint("BOTTOM", "MinimapCluster", "TOP", 0, 0);
    elseif store["ANCHOR"] == "BOTTOMLEFT" then
        ICU_Popup:SetPoint("TOPLEFT", "MinimapCluster", "BOTTOMLEFT", 0, 0);
    elseif store["ANCHOR"] == "TOPLEFT" then
        ICU_Popup:SetPoint("BOTTOMLEFT", "MinimapCluster", "TOPLEFT", 0, 0);
    elseif store["ANCHOR"] == "RIGHT" then
        ICU_Popup:SetPoint("RIGHT", "MinimapCluster", "LEFT", 0, 0);
    elseif store["ANCHOR"] == "LEFT" then
        ICU_Popup:SetPoint("LEFT", "MinimapCluster", "RIGHT", 0, 0);
    end
end

function ICU_Popup_OnUpdate()
    if not ICU_IsEnabled() then
        return;
    end

	local now = type(GetTime) == "function" and GetTime() or nil;
	if now then
		if (now - (ICU_POPUP_LAST_UPDATE_AT or 0)) < ICU_POPUP_UPDATE_INTERVAL then
			return;
		end
		ICU_POPUP_LAST_UPDATE_AT = now;
	end

    local store = ICU_GetStore();
    if MouseIsOver(MinimapCluster) or MouseIsOver(ICU_Popup) then
        if ICU_POPUP_MOUSE_OUT_AT then
            ICU_Trace("popup mouse returned -> reset mouse-out timer");
        end
        ICU_POPUP_MOUSE_OUT_AT = nil;
        return;
    end

    local delay = ICU_GetPopupHideDelaySeconds(store);
    if delay <= 0 then
        ICU_Trace("popup clear reason=delay-instant configured='" .. tostring(store["POPUP_HIDE_DELAY"])
            .. "' resolvedDelay=" .. tostring(delay));
        ICU_Clear_Popup();
        return;
    end

    if not now then
        ICU_Trace("popup clear reason=no-time-api configured='" .. tostring(store["POPUP_HIDE_DELAY"])
            .. "' resolvedDelay=" .. tostring(delay));
        ICU_Clear_Popup();
        return;
    end

    if not ICU_POPUP_MOUSE_OUT_AT then
        ICU_POPUP_MOUSE_OUT_AT = now;
        ICU_Trace("popup mouse-out start delay=" .. tostring(delay)
            .. " configured='" .. tostring(store["POPUP_HIDE_DELAY"]) .. "'");
        return;
    end

    if (now - ICU_POPUP_MOUSE_OUT_AT) >= delay then
        ICU_Trace("popup clear reason=mouse-out-timeout elapsed=" .. string.format("%.2f", (now - ICU_POPUP_MOUSE_OUT_AT))
            .. " delay=" .. tostring(delay)
            .. " configured='" .. tostring(store["POPUP_HIDE_DELAY"]) .. "'");
        ICU_Clear_Popup();
    end
end

function ICU_ButtonClick()
    if not ICU_IsEnabled() then
        return;
    end

    local store = ICU_GetStore();
    if string.len(this.ICU_DATA) ~= string.len(this:GetText()) then
        local lOriginal_ERR_UNIT_NOT_FOUND = ERR_UNIT_NOT_FOUND;
        local lOriginal_ERR_GENERIC_NO_TARGET = ERR_GENERIC_NO_TARGET;
        ERR_UNIT_NOT_FOUND = "";
        ERR_GENERIC_NO_TARGET = "";
        
        TargetByName(this.ICU_DATA);
        
        if UnitIsDead("target") then
            ClearTarget();
        end
        
        if not IsControlKeyDown() then
            if store["ANNOUNCE"] == "MTH Message" then
                ICU_PrintMTH("ICU ->  " .. this:GetText() .. ".");
            elseif store["ANNOUNCE"] == "SELF" then
                ICU_Print("ICU ->  " .. this:GetText() .. ".");
            elseif store["ANNOUNCE"] ~= "OFF" then
                if store["ANNOUNCE"] ~= "AUTO" then
                    SendChatMessage("ICU -> " .. this:GetText() .. ".", store["ANNOUNCE"]);
                else
                    if GetNumRaidMembers() > 0 then
                        SendChatMessage("ICU -> " .. this:GetText() .. ".", "RAID");
                    elseif GetNumPartyMembers() > 0 then
                        SendChatMessage("ICU -> " .. this:GetText() .. ".", "PARTY");
                    else
                        ICU_Print("ICU ->  " .. this:GetText() .. ".");
                    end
                end
            end
        else
            ICU_Print("ICU ->  " .. this:GetText() .. ".");
        end

        ERR_UNIT_NOT_FOUND = lOriginal_ERR_UNIT_NOT_FOUND;
        ERR_GENERIC_NO_TARGET = lOriginal_ERR_GENERIC_NO_TARGET;
    end
end

--------------------------------------------------------------------------------
-- OnFoo() hooked function
--------------------------------------------------------------------------------

function ICU_Minimap_OnClick_Event()
    if not ICU_IsEnabled() then
        if type(ICU_Original_Minimap_OnClick) == "function" then
            ICU_Original_Minimap_OnClick();
        end
        return;
    end

    if IsShiftKeyDown() then
        if type(ICU_Original_Minimap_OnClick) == "function" then
            ICU_Original_Minimap_OnClick();
        end
    else
        if GameTooltip:IsVisible() and GameTooltipTextLeft1 and GameTooltipTextLeft1:GetText() then
            local x, y = GetCursorPosition();
            x = x / Minimap:GetEffectiveScale();
            y = y / Minimap:GetEffectiveScale();
            
            local cx, cy = Minimap:GetCenter();
            ICU_PING_X = x + CURSOR_OFFSET_X - cx;
            ICU_PING_Y = y + CURSOR_OFFSET_Y - cy;
            
            ICU_Clear_Popup();
            ICU_Process_Tooltip(GameTooltipTextLeft1:GetText());
            
            PlaySound("UChatScrollButton");
        elseif type(ICU_Original_Minimap_OnClick) == "function" then
            ICU_Original_Minimap_OnClick();
        end
    end
end

--------------------------------------------------------------------------------
-- Internal functions
--------------------------------------------------------------------------------

function ICU_Process_Tooltip(tooltip, silent)
    if not ICU_IsEnabled() then
        return;
    end

    if type(tooltip) ~= "string" or tooltip == "" then
        return;
    end

    local pos = 0;
    local width = 0;
    local result_line, r, g, b, target, class, health, rank;
    local prev_trg = nil;
    local lOriginal_TargetFrame_OnShow_Event = TargetFrame_OnShow;
    local lOriginal_TargetFrame_OnHide_Event = TargetFrame_OnHide;
    TargetFrame_OnShow = ICU_TargetFrame_OnShow_Event;
    TargetFrame_OnHide = ICU_TargetFrame_OnHide_Event;
    local lOriginal_ERR_UNIT_NOT_FOUND = ERR_UNIT_NOT_FOUND;
    local lOriginal_ERR_GENERIC_NO_TARGET = ERR_GENERIC_NO_TARGET;
    ERR_UNIT_NOT_FOUND = "";
    ERR_GENERIC_NO_TARGET = "";
    
    prev_trg = UnitName("target");
    ClearTarget();
    
    for target in string.gfind(tooltip, "[^\n]*") do
        if string.len(target) > 0 then
            result_line, class, health, rank, r, g, b = ICU2_Process_Trg(target);
            
            if result_line ~= nil then
                pos = pos + 1;
                
                if not health then
                    health = 0;
                end
                
                local button = getglobal("ICU_PopupButton" .. pos .. "Button");
                local bar = getglobal("ICU_PopupButton" .. pos .. "ButtonBar");
                local bg = getglobal("ICU_PopupButton" .. pos .. "ButtonBGBar");
                local ranktex = getglobal("ICU_PopupButton" .. pos .. "ButtonRankIcon");
                
                SetPortraitTexture(getglobal("ICU_PopupButton" .. pos .. "ButtonPortraitIcon"), "target");
                
                if ICU_CLASSES[class] then
                    getglobal("ICU_PopupButton" .. pos .. "ButtonClassIcon"):SetTexCoord(unpack(ICU_CLASSES[class]));
                else
                    getglobal("ICU_PopupButton" .. pos .. "ButtonClassIcon"):SetTexCoord(0, .25, 0, .25);
                end
                
                getglobal("ICU_PopupButton" .. pos .. "ButtonClassIcon"):SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes");
                
                if rank and rank ~= 0 then
                    ranktex:SetTexture(format("%s%02d","Interface\\PvPRankBadges\\PvPRank", rank - 4));
                    ranktex:Show();
                else    
                    ranktex:Hide();
                end
                
                getglobal("ICU_PopupButton" .. pos):SetBackdropBorderColor(r, g, b);
                bar:SetStatusBarColor(r, g, b, 0.75);
                bar:SetValue(health);
                bg:SetStatusBarColor(r, g, b, 0.1);
                button:SetTextColor(r + 0.3, g + 0.3, b + 0.3);
                button:SetText(result_line);
                button.ICU_DATA = target;
                button:GetParent():Show();
                button:Show();
                
                local w = button:GetTextWidth();
                if w > width then
                    width = w;
                end
            end
        end
        
        if pos >= ICU_MAX_LINES then
            break
        end;
    end
    
    TargetFrame_OnShow = lOriginal_TargetFrame_OnShow_Event;
    TargetFrame_OnHide = lOriginal_TargetFrame_OnHide_Event;
    ERR_UNIT_NOT_FOUND = lOriginal_ERR_UNIT_NOT_FOUND;
    ERR_GENERIC_NO_TARGET = lOriginal_ERR_GENERIC_NO_TARGET;
    
    if pos > 0 then
        ICU_Display_Popup(pos, width + 10);
    else
        ICU_Clear_Popup();
    end
end

function ICU2_Process_Trg(trg)
    local store = ICU_GetStore();

    for name in string.gfind(trg, "|c%x%x%x%x%x%x%x%x([^|]+)|r") do
        trg = name;
    end
    
    local result_strn = nil;
    local health, rank;
    
    TargetByName(trg);
    
    if UnitExists("target") and UnitName("target") then
        local _, classToken = UnitClass("target");
        result_strn = trg .. " " .. UnitLevel( "target" );
        
        if UnitIsPlayer("target") then
            myFaction, _ = UnitFactionGroup("player");
            theirFaction, _ = UnitFactionGroup("target");
            local isPvp = UnitIsPVP and UnitIsPVP("target") and true or false;

            if myFaction ~= theirFaction and isPvp and not UnitOnTaxi("target") then
                local enemyName = UnitName("target") or "";
                if ICU_ShouldEmitAlert(enemyName) then
                    Minimap:PingLocation(ICU_PING_X, ICU_PING_Y);
                end

                local alertName = ICU_GetAlertPlayerName("target", store);
                message = "ICU -> " .. alertName .. " " .. UnitLevel("target") .. " " .. UnitRace("target") .. " " .. UnitClass("target");

                local shouldSendAlertMessage = ICU_ShouldEmitAlert(enemyName .. "-msg");
                if shouldSendAlertMessage and store["ALERT"] == "AUTO" then
                    if GetNumRaidMembers() > 0 then
                        SendChatMessage(message, "RAID");
                    elseif GetNumPartyMembers() > 0 then
                        SendChatMessage(message, "PARTY");
                    else
                        ICU_Print(message);
                    end
                elseif shouldSendAlertMessage and store["ALERT"] == "MTH Message" then
                    ICU_PrintMTH(message);
                elseif shouldSendAlertMessage and store["ALERT"] == "SELF" then
                    ICU_Print(message);
                elseif shouldSendAlertMessage and store["ALERT"] ~= "OFF" and not ((store["ALERT"] == "PARTY" and GetNumPartyMembers() == 0) or (store["ALERT"] == "RAID" and GetNumRaidMembers() == 0)) then
                    SendChatMessage(message, store["ALERT"]);
                end
            end

            local playerRace = UnitRace("target") or "";
            local playerClass = UnitClass("target") or "";
            local playerMeta = {};
            if store["SHOW_PLAYER_RACE"] and playerRace ~= "" then
                table.insert(playerMeta, playerRace);
            end
            if store["SHOW_PLAYER_CLASS"] and playerClass ~= "" then
                table.insert(playerMeta, playerClass);
            end
            if table.getn(playerMeta) > 0 then
                result_strn = result_strn .. " " .. table.concat(playerMeta, " ");
            end
            rank = UnitPVPRank("target");
            local guildname, _, _ = GetGuildInfo("target");
            
            if store["SHOW_GUILD_NAME"] and guildname ~= nil and guildname ~= "" then
                result_strn = result_strn .. " <" .. guildname .. ">";
            end
            
            local currentHealth = tonumber(UnitHealth("target")) or 0;
            local maxHealth = tonumber(UnitHealthMax("target")) or 0;
            local healthMode = store["HEALTH_TEXT_MODE"] or "AUTO";

            if UnitInParty("target") or UnitInRaid("target") then
                result_strn = result_strn .. " [" .. currentHealth .. "/" .. maxHealth .. "]";
                if maxHealth > 0 then
                    health = currentHealth / maxHealth * 100;
                else
                    health = 0;
                end
            else
                local healthLabel, barValue = ICU_GetHealthLabelAndBar(currentHealth, maxHealth, healthMode);
                if healthLabel and healthLabel ~= "" then
                    result_strn = result_strn .. " " .. healthLabel;
                end
                health = barValue;
            end
        else
            result_strn = "NPC:- " .. result_strn;
            local currentHealth = tonumber(UnitHealth("target")) or 0;
            local maxHealth = tonumber(UnitHealthMax("target")) or 0;
            local healthMode = store["HEALTH_TEXT_MODE"] or "AUTO";
            local healthLabel, barValue = ICU_GetHealthLabelAndBar(currentHealth, maxHealth, healthMode);
            if healthLabel and healthLabel ~= "" then
                result_strn = result_strn .. " " .. healthLabel;
            end
            health = barValue;
        end
        
        local r, g, b = ICU_GetDisplayColor("target", classToken, store);
        
        return result_strn, UnitClass("target"), health, rank, r, g, b;     
    end
    
    return result_strn;
end

function ICU_TargetFrame_OnShow_Event()
    -- Do nothing
end

function ICU_TargetFrame_OnHide_Event()
    CloseDropDownMenus();
end

function ICU_Display_Popup(numTrgs, width)
    if not ICU_IsEnabled() then
        return;
    end

    for i = 1, 10 do 
        getglobal("ICU_PopupButton" .. i):SetWidth(width + 40 + 9);
        getglobal("ICU_PopupButton" .. i .. "Button"):SetWidth(width + 40);
        getglobal("ICU_PopupButton" .. i .. "ButtonBar"):SetWidth(width);
        getglobal("ICU_PopupButton" .. i .. "ButtonBGBar"):SetWidth(width);
    end
    
    ICU_Popup:SetWidth(width + 40 + UNITPOPUP_BORDER_WIDTH);
    ICU_Popup:SetHeight(numTrgs * ICU_PopupButton1:GetHeight() + 12);
    ICU_POPUP_MOUSE_OUT_AT = nil;
    ICU_Popup:Show();
end

function ICU_Clear_Popup()
    if not ICU_Popup then
        return;
    end

    for i = 1, 10 do
        getglobal("ICU_PopupButton" .. i .. "Button"):SetText("");
        getglobal("ICU_PopupButton" .. i).ICU_DATA = "";
        getglobal("ICU_PopupButton" .. i):Hide();
    end

    ICU_POPUP_MOUSE_OUT_AT = nil;
    ICU_Popup:Hide();
end

function ICU_MouseOverUpdate()
    if not ICU_IsEnabled() then
        return;
    end

	local now = type(GetTime) == "function" and GetTime() or nil;
	if now then
		if (now - (ICU_MOUSEOVER_LAST_UPDATE_AT or 0)) < ICU_MOUSEOVER_UPDATE_INTERVAL then
			return;
		end
		ICU_MOUSEOVER_LAST_UPDATE_AT = now;
	end

    local store = ICU_GetStore();
	if not GetMouseFocus then
        return;
    end

	local focus = GetMouseFocus();
	if not focus then
        return;
    end

    if store["mouseOver"] and IsControlKeyDown() and MouseIsOver(MinimapCluster) and focus.GetName and focus:GetName() == "Minimap" then
        if GameTooltip and GameTooltip.IsVisible and GameTooltip:IsVisible() and GameTooltipTextLeft1 and GameTooltipTextLeft1.GetText then
			local tooltipText = GameTooltipTextLeft1:GetText();
            if tooltipText ~= icu_prevtooltip then
                ICU_Clear_Popup();
                icu_prevtooltip = tooltipText;
                ICU_Minimap_OnClick_Event();
            end 
        end
    end
end
