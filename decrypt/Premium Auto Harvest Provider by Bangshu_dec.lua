setMinimum("6.1.2")
PHUIWriteInProgress = {}
function safePHUIValue(t, b)
  if PHUIWriteInProgress[t] then
    return true
  end
  PHUIWriteInProgress[t] = true
  local c = pcall(function()
    editValue(t, b)
  end)
  PHUIWriteInProgress[t] = nil
  return c
end
local t = "Premium Auto Harvest Provider by Bangshu"
do
  local b =
    "https://script.google.com/macros/s/AKfycbxWY0ROC3V1HOTJuRPfovwsN8CfTkXrcFF6VvhlS0EQRfWleUWVHZNUSW1M2UcVesSC/exec"
  local c = "PROVIDER"
  local N = "PROVIDER-2-PAID-001"
  local Y = "approval"
  local h = "%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x"
  local function R()
    local t, b = pcall(function()
      if type(getDiscordID) == "function" then
        return getDiscordID()
      end
      return getDiscordID
    end)
    if not t then
      return nil
    end
    if type(b) == "number" and (math["type"] and math["type"](b) == "integer") then
      b = tostring(b)
    end
    if type(b) ~= "string" or #b < 17 or #b > 20 or not b:match("^%d+$") then
      return nil
    end
    if b:match("^0+$") then
      return nil
    end
    return b
  end
  local function O(t, b)
    if not b or type(t) ~= "string" or #t > 512 then
      return false
    end
    local Y, R, O = t:match(
      '^%s*{"status":"APPROVED","approval":{"discordId":"(%d+)","product":"([A-Z]+)","version":"([%w._-]+)","receiptId":"'
        .. (h .. '"}}%s*$')
    )
    return Y == b and (R == c and O == N)
  end
  local Z, u, o = pcall(function()
    local t, b = pcall(require, "preferences")
    local c = t and (type(b) == "table" and b) or Preferences
    if type(c) ~= "table" or type(c["new"]) ~= "function" then
      return nil
    end
    local N = c:new("BangshuPremiumAutoHarvestProvider")
    if N:load() == false then
      return N
    end
    return N, N:get(Y, "")
  end)
  if not Z then
    u = nil
  end
  if not O(o, R()) then
    local h, Z = false, false
    local function o(t)
      pcall(editValue, "PH_premium_status", t)
      if type(sendNotification) == "function" then
        pcall(sendNotification, t)
      elseif growtopia and type(growtopia["notify"]) == "function" then
        pcall(growtopia["notify"], t)
      end
    end
    local function X()
      if h or Z then
        return
      end
      local t = R()
      if not t then
        o("DENIED - DISCORD ID UNAVAILABLE")
        return
      end
      if not u then
        o("DENIED - PREFERENCES UNAVAILABLE")
        return
      end
      h = true
      o("CHECKING")
      local X = pcall(runThread, function()
        local R = b
          .. (
            "?action=verifyPaidAccess&discordId=" .. (
              t .. ("&product=" .. (c .. ("&format=growlauncher&version=" .. N)))
            )
          )
        local X, r = pcall(fetch, R)
        if X and type(r) == "string" then
          local t = r:match("BANGSHU_PREMIUM_V1_BEGIN_([0-9a-f]+)_BANGSHU_PREMIUM_V1_END")
          if t and (#t <= 1024 and #t % 2 == 0) then
            r = t:gsub("..", function(t)
              return string["char"](tonumber(t, 16))
            end)
          end
        end
        if not X or type(r) ~= "string" then
          o("DENIED - REQUEST FAILED")
        elseif not O(r, t) then
          if r:match('^%s*{"status":"DENIED",') then
            local t = r:match('"reason"%s*:%s*"([A-Z_]+)"')
            if t == "INVALID_REQUEST" then
              o("DENIED - INVALID REQUEST (CHECK DEPLOYMENT)")
            elseif t == "NO_PERMANENT_ACCESS" then
              o("DENIED - CHECK PROVIDER ROW IN PAIDUSERS")
            else
              o("DENIED - NO PREMIUM ACCESS")
            end
          elseif r:match('^%s*{"status":"ERROR",') then
            o("DENIED - APPS SCRIPT SERVER ERROR")
          elseif r:match("^%s*<") then
            if r:find("doGet", 1, true) then
              o("DENIED - DEPLOYED APP MISSING GET HANDLER")
            else
              o("DENIED - GOOGLE RETURNED HTML")
            end
          elseif r:match("^%s*$") then
            o("DENIED - EMPTY SERVER RESPONSE")
          elseif r:match('^%s*{"status":"APPROVED",') then
            o("DENIED - APPROVAL DETAILS DO NOT MATCH")
          else
            o("DENIED - UNEXPECTED SERVER RESPONSE")
          end
        else
          local b, c = pcall(function()
            if u:set(Y, r) == false then
              return false
            end
            if u:save() == false then
              return false
            end
            if u:load() == false then
              return false
            end
            return O(u:get(Y, ""), t)
          end)
          Z = b and c == true
          o(Z and "APPROVED - RELOAD SCRIPT" or "DENIED - COULD NOT SAVE APPROVAL")
        end
        h = false
      end)
      if not X then
        h = false
        o("DENIED - COULD NOT START CHECK")
      end
    end
    function OnValue(t, b)
      if b == "PH_premium_verify" then
        X()
      end
    end
    onValue = OnValue
    local r = UserInterface["new"](t, "Agriculture")
    r:addButton("Verify Access", "PH_premium_verify")
    r:addInputString("Verification Status", "NOT VERIFIED", "", "", nil, "PH_premium_status")
    if type(addCategory) == "function" then
      pcall(addCategory, t, "Agriculture")
    end
    addIntoModule(r:generateJSON(), t)
    if type(applyHook) == "function" then
      pcall(applyHook)
    end
    if type(setOnValue) == "function" then
      pcall(setOnValue, "PH_premium_verify", X)
    end
    return
  end
end
local b = "ProviderHarvesterPunchDelayV21"
local c = "punch_delay_ms"
local N = nil
local Y = 250
local function h()
  local t = nil
  if type(require) == "function" then
    local b, c = pcall(require, "preferences")
    if b and c ~= nil then
      t = c
    end
  end
  if t == nil and type(Preferences) == "table" then
    t = Preferences
  end
  if t == nil or type(t["new"]) ~= "function" then
    return
  end
  local h, R = pcall(function()
    return t:new(b)
  end)
  if not h or R == nil then
    return
  end
  N = R
  pcall(function()
    N:load()
  end)
  local O, Z = pcall(function()
    return N:get(c, 190)
  end)
  if O and tonumber(Z) ~= nil then
    local t = math["floor"](tonumber(Z))
    Y = math["max"](0, math["min"](5000, t))
  end
end
local function R(t)
  if N == nil then
    return false
  end
  local b = pcall(function()
    local b = N:set(c, t)
    if b == false then
      error("Preferences:set failed")
    end
    local Y = N:save()
    if Y == false then
      error("Preferences:save failed")
    end
  end)
  return b
end
h()
local O, Z = 0, 0
local u = false
local o = 190
local X = 300
local r = true
local A = 325
local function z()
  if N == nil then
    return
  end
  local t = pcall(function()
    O = math["floor"](tonumber(N:get("chem_drop_x", 0)) or 0)
    Z = math["floor"](tonumber(N:get("chem_drop_y", 0)) or 0)
    u = N:get("chem_drop_configured", false) == true
    o = math["max"](1, math["min"](200, math["floor"](tonumber(N:get("chem_threshold", 190)) or 190)))
    X = math["max"](0, math["min"](5000, math["floor"](tonumber(N:get("chem_drop_delay", 250)) or 250)))
    A = math["max"](30, math["min"](500, math["floor"](tonumber(N:get("fast_collect_gap_ms", 70)) or 70)))
    local t = N:get("auto_collect_enabled", true)
    r = not (t == false or t == 0 or t == "false" or t == "0")
  end)
  if not t then
    O, Z = 0, 0
    u = false
    o, X = 190, 300
    A = 325
    r = true
  end
end
z()
savedHarvestWorlds = ""
savedReturnToStart = false
if N ~= nil then
  pcall(function()
    savedHarvestWorlds = tostring(N:get("harvest_world_list", "") or "")
    local t = N:get("return_to_start", false)
    savedReturnToStart = (t == true or t == "true" or t == 1 or t == "1")
  end)
end
function saveWorldSettings(t, b)
  if N == nil then
    return false
  end
  return pcall(function()
    N:set("harvest_world_list", tostring(t or ""))
    N:set("return_to_start", b == true)
    N:save()
  end)
end
local function B(t, b, c, Y, h, R, O)
  if N == nil then
    return false
  end
  return pcall(function()
    N:set("chem_drop_x", t)
    N:set("chem_drop_y", b)
    N:set("chem_drop_configured", c)
    N:set("chem_threshold", Y)
    N:set("chem_drop_delay", h)
    N:set("fast_collect_gap_ms", O)
    N:set("auto_collect_enabled", R == true)
    N:save()
  end)
end
PH_CONFIG_FILE = "ProviderHarvesterAllSettingsV6.json"
local U = ""
local g
phConfig = nil
phPreferenceModule = nil
phConfigRestored = false
function loadPersistentProviderSettings()
  if type(require) == "function" then
    local t, b = pcall(require, "preferences")
    if t and b ~= nil then
      phPreferenceModule = b
    end
  end
  if phPreferenceModule == nil and type(Preferences) == "table" then
    phPreferenceModule = Preferences
  end
  if phPreferenceModule == nil or type(phPreferenceModule["new"]) ~= "function" then
    return
  end
  local t, b = pcall(function()
    return phPreferenceModule:new(PH_CONFIG_FILE)
  end)
  if not t or b == nil then
    return
  end
  if
    type(b["load"]) ~= "function"
    or type(b["get"]) ~= "function"
    or type(b["set"]) ~= "function"
    or type(b["save"]) ~= "function"
  then
    return
  end
  if not pcall(function()
    b:load()
  end) then
    return
  end
  phConfig = b
  local c, N = pcall(function()
    return b:get("schema", "")
  end)
  if not c or tostring(N) ~= "6" then
    return
  end
  local h = pcall(function()
    savedHarvestWorlds = tostring(b:get("worlds", savedHarvestWorlds) or "")
    local function t(t, c, N, Y)
      local h = tonumber(b:get(t, c)) or c
      return math["max"](N, math["min"](Y, math["floor"](h)))
    end
    local function c(t, c)
      local N = b:get(t, c and "true" or "false")
      return N == true or N == "true" or N == "1" or N == 1
    end
    savedReturnToStart = c("return_start", savedReturnToStart)
    r = c("auto_collect", r)
    Y = t("punch_delay", Y, 0, 5000)
    A = t("collect_delay", A, 30, 500)
    o = t("drop_threshold", o, 1, 200)
    X = t("drop_delay", X, 0, 5000)
    U = tostring(b:get("drop_world", "") or "")
    O = t("drop_x", O, 0, 999)
    Z = t("drop_y", Z, 0, 999)
    u = c("drop_configured", u)
  end)
  phConfigRestored = h
end
loadPersistentProviderSettings()
function saveProviderSettingsSnapshot(t)
  if phConfig == nil or phPreferenceModule == nil then
    return false
  end
  local b = pcall(function()
    phConfig:set("schema", "6")
    for t, b in pairs(t) do
      phConfig:set(t, tostring(b))
    end
    if phConfig:save() == false then
      error("Preferences save rejected")
    end
  end)
  if not b then
    return false
  end
  local c, N = pcall(function()
    local b = phPreferenceModule:new(PH_CONFIG_FILE)
    if not b then
      return false
    end
    b:load()
    if tostring(b:get("schema", "")) ~= "6" then
      return false
    end
    for t, c in pairs(t) do
      if tostring(b:get(t, "")) ~= tostring(c) then
        return false
      end
    end
    return true
  end)
  return c and N == true
end
local j = {
  { ["key"] = "atm", ["name"] = "ATM Machine" },
  { ["key"] = "unicorn", ["name"] = "Awkward Friendly Unicorn" },
  { ["key"] = "balloon", ["name"] = "Balloon Filling Station" },
  { ["key"] = "buffalo", ["name"] = "Buffalo" },
  { ["key"] = "building", ["name"] = "Building Blocks Machine" },
  { ["key"] = "chicken", ["name"] = "Chicken" },
  { ["key"] = "coffee", ["name"] = "Coffee Maker" },
  { ["key"] = "cow", ["name"] = "Cow" },
  { ["key"] = "diamond", ["name"] = "Diamond Builders Bonanza" },
  { ["key"] = "gumball", ["name"] = "Gumball Machine" },
  { ["key"] = "icecream", ["name"] = "Ice Cream Truck" },
  { ["key"] = "science", ["name"] = "Science Station", ["fallbackID"] = 928 },
  { ["key"] = "sheep", ["name"] = "Sheep" },
  { ["key"] = "silkworm", ["name"] = "Silkworm" },
  { ["key"] = "droid", ["name"] = "Star Tool Droid", ["fallbackID"] = 6414 },
  { ["key"] = "surgical", ["name"] = "Surgical Tool Bag" },
  { ["key"] = "tackle", ["name"] = "Tackle Box" },
  { ["key"] = "tea", ["name"] = "Tea Set" },
  { ["key"] = "well", ["name"] = "Well" },
  { ["key"] = "welllove", ["name"] = "Well of Love" },
  { ["key"] = "wonder", ["name"] = "Wonder Provider" },
  { ["key"] = "cal2017", ["name"] = "Winterfest Calendar - 2017", ["group"] = "calendar" },
  { ["key"] = "cal2018", ["name"] = "Winterfest Calendar - 2018", ["group"] = "calendar" },
  { ["key"] = "cal2019", ["name"] = "Winterfest Calendar - 2019", ["group"] = "calendar" },
  { ["key"] = "cal2020", ["name"] = "Winterfest Calendar - 2020", ["group"] = "calendar" },
  { ["key"] = "cal2021", ["name"] = "Winterfest Calendar - 2021", ["group"] = "calendar" },
  { ["key"] = "cal2022", ["name"] = "Winterfest Calendar - 2022", ["group"] = "calendar" },
  { ["key"] = "cal2023", ["name"] = "Winterfest Calendar - 2023", ["group"] = "calendar" },
  { ["key"] = "cal2024", ["name"] = "Winterfest Calendar - 2024", ["group"] = "calendar" },
  { ["key"] = "cal2025", ["name"] = "Winterfest Calendar - 2025", ["group"] = "calendar" },
  { ["key"] = "benbarrage", ["name"] = "BenBarrage's Awesome Item-O-Matic", ["group"] = "creator" },
  { ["key"] = "evets", ["name"] = "evets_gt's Awesome Item-O-Matic", ["group"] = "creator" },
  { ["key"] = "keenan", ["name"] = "Keenan GT's Awesome Item-O-Matic", ["group"] = "creator" },
  { ["key"] = "linktrader", ["name"] = "LinkTrader GT's Awesome Item-O-Matic", ["group"] = "creator" },
  { ["key"] = "macproof", ["name"] = "macproof_gt's Awesome Item-O-Matic", ["group"] = "creator" },
  { ["key"] = "mrsongo", ["name"] = "MrSongo GT's Awesome Item-O-Matic", ["group"] = "creator" },
  { ["key"] = "oldgertie", ["name"] = "OldGertie's Awesome Item-O-Matic", ["group"] = "creator" },
  { ["key"] = "tery", ["name"] = "Tery's Awesome Item-O-Matic", ["group"] = "creator" },
  { ["key"] = "venomst", ["name"] = "VenomST's Awesome Item-O-Matic", ["group"] = "creator" },
}
local W = UserInterface["new"](t, "Agriculture")
W:addLabelApp(t, "Agriculture")
W:addToggle("Start / Stop", false, "PH_enable")
local i = (W:addDialog("Harvest World Settings", "Blank uses the current world", {}))["menu"]
W:addChildInputString(
  i,
  "Harvest Worlds (blank = current world)",
  savedHarvestWorlds,
  "WORLD1,WORLD2 (leave empty for current)",
  "Worlds",
  "Agriculture",
  "PH_worlds"
)
W:addChildTooltip(
  i,
  "Empty Harvest Worlds",
  "When no worlds are entered, harvest ONLY the world you are standing in when you press Start. This also works if the saved value is empty or contains spaces.",
  "Agriculture",
  false
)
W:addChildButton(i, "Clear Worlds / Use Current World", "PH_clearworlds")
W:addChildButton(i, "Add Current World", "PH_addworld")
W:addChildButton(i, "Remove Last World", "PH_removeworld")
local F = (W:addExpandableToggle("Auto Collect + Auto Drop", r, "PH_autocollect", false, true))["list_child"]
W:addChildInputString(F, "Drop World", U, "WORLD|DOORID", "Blank = harvest world", nil, "PH_dropworld")
W:addChildButton(F, "Use Current World", "PH_hereDropWorld")
W:addChildInputInt(F, "Drop X (Stand Tile)", tostring(O), "X", "0", "Agriculture", "PH_chemdropx")
W:addChildInputInt(F, "Drop Y (Stand Tile)", tostring(Z), "Y", "0", "Agriculture", "PH_chemdropy")
W:addChildButton(F, "Set Drop Position = Current Tile", "PH_setchemdrop")
local d = (W:addDialog("Drop Settings", "Inventory threshold for storage", {}))["menu"]
W:addChildInputInt(d, "Drop at Inventory Count", tostring(o), "items", "190", "Agriculture", "PH_chemthreshold")
local K = (W:addDialog("Delay Settings", "Adjust timings in milliseconds", {}))["menu"]
W:addChildInputInt(K, "Before Next Pickup Path (ms)", tostring(A), "ms", "325", "Agriculture", "PH_fastcollectgap")
W:addChildInputInt(K, "Punch Delay", tostring(Y), "ms", "250", "Agriculture", "PH_delay")
W:addChildInputInt(K, "Item Drop Delay", tostring(X), "ms", "300", "Agriculture", "PH_chemdropdelay")
W:addInputString("Auto Collect (view only)", r and "ON" or "OFF", "Collect", "Status", nil, "PH_autocollectdisplay")
W:addInputString(
  "Drop Position (view only)",
  u and (tostring(O) .. (", " .. tostring(Z))) or "NOT SET",
  "X, Y",
  "Drop to right",
  nil,
  "PH_chemdropdisplay"
)
W:addInputString("Item Collection Status (view only)", "IDLE", "Provider drops", "Status", nil, "PH_chemstatus")
W:addDisplayList(
  "Settings Auto Save",
  phConfig == nil and "UNAVAILABLE" or (phConfigRestored and "RESTORED" or "READY - SAVE ON CHANGE"),
  "PH_delay_save_status"
)
W:addDisplayList("World Progress", "CURRENT WORLD", "PH_worldstatus")
W:addDisplayList("Missed for Cleanup", "0", "PH_cleanupcount")
W:addDisplayList("Current Target", "NONE", "PH_target")
W:addDisplayList("Status", "STOPPED", "PH_status")
W:addInputString("Server Recovery (view only)", "NORMAL", "Recovery", "Status", nil, "PH_recovery")
pcall(function()
  addCategory(t, "Agriculture")
end)
local w = pcall(function()
  addIntoModule(W:generateJSON(), t)
end)
if not w then
  addIntoModule(W:generateJSON())
end
local E = false
local C = true
local H = true
local M = Y
local p = 6
local T, G = O, Z
local m = u
local S = o
local Q = X
local D = r
local q = A
local P, y = T, G
local L = "IDLE"
local I, x = false, false
local s = false
local V = false
local e = {}
local J = 0
local l = nil
local v = {}
local n = {}
local k = {}
local a = {}
local f = 1200
local tf = 300
local bf = 2200
local cf = 2500
local Nf = 350
local Yf = 100
local hf, Rf = {}, {}
function persistProviderSettings()
  local t = {
    ["worlds"] = harvestWorldText,
    ["return_start"] = "false",
    ["auto_collect"] = tostring(D == true),
    ["punch_delay"] = M,
    ["collect_delay"] = q,
    ["drop_threshold"] = S,
    ["drop_delay"] = Q,
    ["drop_world"] = U,
    ["drop_x"] = T,
    ["drop_y"] = G,
    ["drop_configured"] = tostring(m == true),
  }
  local b = saveProviderSettingsSnapshot(t)
  safePHUIValue(
    "PH_delay_save_status",
    b and "SAVED - REOPEN SAFE" or (phConfig == nil and "UNAVAILABLE" or "SAVE FAILED")
  )
  return b
end
local Of = 0
local Zf = 0
local uf = false
local of = ""
harvestWorldText = savedHarvestWorlds
worldQueue = {}
worldIndex = 0
worldTransitionPending = false
worldTransitionAttempts = 0
worldTransitionElapsed = 0
finalCleanupAttempts = 0
finalDropFailures = 0
local Xf = "STOPPED"
local rf = 0
local Af = false
local zf = false
local Bf = false
local Uf = 3500
local gf = 3500
local jf = 400
local Wf = 350
local Ff = 50
local df = 250
local Kf = 1250
local wf = 850
local Ef = 3400
local Cf = 3500
local Hf = 1200
local Mf = 12000
local pf = 1500
local Tf = 10000
local Gf = 300
local mf = 0
local Sf = {}
local Qf = {}
local Df = nil
local qf = nil
local Pf = 0
local yf = "NORMAL"
local Lf = 700
local If = 5000
local xf = 200
local sf = 3
local Vf = 450
local function ef(t)
  if growtopia ~= nil and type(growtopia["notify"]) == "function" then
    pcall(function()
      growtopia["notify"](tostring(t))
    end)
  end
end
local function Jf(t)
  t = tostring(t)
  if Xf ~= t then
    Xf = t
    safePHUIValue("PH_status", t)
  end
end
local function lf(t)
  t = tostring(t)
  if yf ~= t then
    yf = t
    pcall(function()
      safePHUIValue("PH_recovery", t)
    end)
  end
end
local function vf(t, b)
  local c = editToggle or EditToggle
  if c ~= nil then
    pcall(c, t, b)
  end
end
local function nf(t)
  vf("ModFly", t == true)
end
local function kf()
  local t = GetLocal or getLocal
  if t == nil then
    return nil
  end
  local b, c = pcall(t)
  if b then
    return c
  end
  return nil
end
local function af()
  local t = GetWorldName or getCurrentWorldName
  if t == nil then
    return ""
  end
  local b, c = pcall(t)
  if b and type(c) == "string" then
    return c:upper()
  end
  return ""
end
local function ff()
  local t = GetTiles or getTiles
  if t == nil then
    return {}
  end
  local b, c = pcall(t)
  if b and type(c) == "table" then
    return c
  end
  return {}
end
local function tB(t, b)
  if type(t) ~= "number" or t < 1 or t > 100 or t % 1 ~= 0 or type(b) ~= "number" or b < 0 or b % 1 ~= 0 then
    return false
  end
  local c = FindPath or findPath
  if type(c) ~= "function" then
    return false
  end
  return c(t, b)
end
local function bB(t, b)
  local c = getTile or GetTile
  if c == nil then
    return nil
  end
  local N, Y = pcall(c, t, b)
  if N then
    return Y
  end
  return nil
end
local function cB()
  local t = kf()
  if t == nil then
    return nil, nil
  end
  return t["posX"] // 32, t["posY"] // 32
end
local function NB(t)
  return type(t) == "string" and (t ~= "" and t ~= "EXIT")
end
local function YB(t, b)
  if type(t) ~= "string" or type(b) ~= "string" then
    return false
  end
  return t:upper() == b:upper()
end
function parseHarvestWorlds(t)
  local b, c = {}, {}
  for t in (tostring(t or "")):gmatch("[^,%s;]+") do
    local N = t:match("^([^|]+)")
    if N and (N:match("^[%w_]+$") and #N <= 24) then
      local Y = N:upper() .. t:sub(#N + 1)
      local h = Y
      if not c[h] then
        c[h] = true
        b[#b + 1] = Y
      end
    end
  end
  return b
end
function worldNameFromEntry(t)
  return (((tostring(t or "")):match("^([^|]+)") or "")):upper()
end
function updateWorldDisplay()
  local t = (worldIndex > 0 and #worldQueue > 0)
      and (tostring(worldIndex) .. ("/" .. (tostring(#worldQueue) .. ("  " .. tostring(
        worldNameFromEntry(worldQueue[worldIndex])
      )))))
    or "CURRENT WORLD"
  pcall(function()
    safePHUIValue("PH_worldstatus", t)
  end)
end
local function hB()
  if g then
    return YB(af(), g) and kf() ~= nil
  end
  if of == nil or of == "" then
    return false
  end
  local t = kf()
  if t == nil then
    return false
  end
  local b = af()
  if NB(b) then
    if YB(b, of) then
      Bf = true
      return true
    end
    Bf = false
    return false
  end
  return Bf == true
end
local function RB(t)
  local b = math["max"](0, math["floor"](tonumber(t) or 0))
  while E and b > 0 do
    if not hB() then
      return false
    end
    local t = math["min"](100, b)
    Sleep(t)
    b = b - t
  end
  return E and hB()
end
local function OB()
  return hB()
end
local function ZB(t, b)
  local c = 0
  while E and c < t do
    local t = kf()
    local N = af()
    if NB(N) and not YB(N, of) then
      return false
    end
    local Y = ff()
    if t ~= nil and (Y ~= nil and next(Y) ~= nil) then
      if b or YB(N, of) or Bf then
        return true
      end
    end
    Sleep(100)
    c = c + 100
  end
  return false
end
local function uB()
  local t = kf()
  if t == nil or not E then
    return false
  end
  local b = af()
  if NB(b) and not YB(b, of) then
    return false
  end
  local c = t["posX"] // 32
  local N = t["posY"] // 32
  nf(C)
  Sleep(250)
  for t = 1, 2, 1 do
    if not E then
      return false
    end
    pcall(function()
      FindPath(c, N)
    end)
    Sleep(xf)
  end
  local Y = {
    { ["x"] = c + 1, ["y"] = N },
    { ["x"] = c - 1, ["y"] = N },
    { ["x"] = c, ["y"] = N - 1 },
    { ["x"] = c, ["y"] = N + 1 },
    { ["x"] = c + 2, ["y"] = N },
    { ["x"] = c - 2, ["y"] = N },
  }
  for t = 1, sf, 1 do
    if not E then
      return false
    end
    Jf("RESUME PATH " .. (tostring(t) .. ("/" .. tostring(sf))))
    for t, b in ipairs(Y) do
      local Y = bB(b["x"], b["y"])
      if Y ~= nil then
        local t = false
        pcall(function()
          FindPath(b["x"], b["y"])
        end)
        local Y = 0
        while E and Y < 1200 do
          local h = kf()
          local R = af()
          if NB(R) and not YB(R, of) then
            return false
          end
          if h ~= nil then
            local Y = h["posX"] // 32
            local R = h["posY"] // 32
            if Y == b["x"] and R == b["y"] then
              t = true
              break
            end
            if Y ~= c or R ~= N then
              t = true
              break
            end
          end
          Sleep(100)
          Y = Y + 100
        end
        if t then
          Sleep(xf)
          pcall(function()
            FindPath(c, N)
          end)
          Sleep(xf)
          return true
        end
      end
    end
    pcall(function()
      FindPath(c, N)
    end)
    Sleep(Vf)
  end
  return false
end
local function oB(t)
  if not Af and t ~= nil then
    ef(t)
  end
  Af = true
  zf = false
  Bf = false
  nf(false)
  Jf("PAUSED - WAIT WORLD")
end
local function XB()
  if not E then
    return false
  end
  if hB() then
    if Af or zf then
      nf(false)
      Jf("RESUMING")
      Sleep(Lf)
      if not E then
        return false
      end
      local t = af()
      if NB(t) and not YB(t, of) then
        Bf = false
        return false
      end
      if not ZB(If, false) then
        Jf("RESUMING")
        Sleep(100)
        return false
      end
      Jf("RESUME MOVE")
      local b = uB()
      if not E then
        return false
      end
      t = af()
      if NB(t) and not YB(t, of) then
        Bf = false
        return false
      end
      if not b then
        Jf("RESUME PATH RETRY")
        Sleep(Vf)
        return false
      end
      Af = false
      zf = false
      Bf = true
      ef("Provider Harvester resumed automatically.")
    end
    return true
  end
  if Af and zf then
    nf(false)
    Jf("RESUMING")
    Sleep(Lf)
    if not E then
      return false
    end
    if ZB(4000, true) then
      local t = af()
      if NB(t) and not YB(t, of) then
        Bf = false
        Jf("PAUSED - WAIT WORLD")
        return false
      end
      Bf = true
      Jf("RESUME MOVE")
      local b = uB()
      if not E then
        return false
      end
      t = af()
      if NB(t) and not YB(t, of) then
        Bf = false
        Jf("PAUSED - WAIT WORLD")
        return false
      end
      if not b then
        Jf("RESUME PATH RETRY")
        Sleep(Vf)
        return false
      end
      Af = false
      zf = false
      ef("Provider Harvester resumed automatically.")
      return true
    end
  end
  if not Af then
    ef("Provider Harvester paused - return to " .. tostring(of))
  end
  Af = true
  Bf = false
  nf(false)
  Jf("PAUSED - WAIT WORLD")
  Sleep(200)
  return false
end
local function rB() end
local function AB() end
local function zB(t)
  local b = nil
  if type(findItemID) == "function" then
    local c, N = pcall(findItemID, t["name"])
    if c then
      b = tonumber(N)
    end
  end
  if (b == nil or b <= 0) and type(getItemInfoByName) == "function" then
    local c, N = pcall(getItemInfoByName, t["name"])
    if c and N ~= nil then
      b = tonumber(N["id"])
    end
  end
  if (b == nil or b <= 0) and (growtopia ~= nil and type(growtopia["getItemID"]) == "function") then
    local c, N = pcall(function()
      return growtopia["getItemID"](t["name"])
    end)
    if c then
      b = tonumber(N)
    end
  end
  if (b == nil or b <= 0) and t["fallbackID"] ~= nil then
    b = tonumber(t["fallbackID"])
  end
  if b ~= nil and b > 0 then
    return math["floor"](b)
  end
  return nil
end
local function BB()
  hf, Rf = {}, {}
  for t, b in ipairs(j) do
    local c = zB(b)
    b["id"] = c
    if c ~= nil then
      hf[c] = b
    end
  end
end
local function UB(t)
  if not t or t["readyharvest"] ~= true then
    return nil
  end
  local b = tonumber(t["fg"])
  if not b or b <= 0 or Rf[b] then
    return nil
  end
  if hf[b] then
    return hf[b]
  end
  local c = getItemInfoByID or GetItemInfo or getItemInfo
  if type(c) ~= "function" then
    return nil
  end
  local N, Y = pcall(c, b)
  local h = N and (Y and tonumber(Y["type"]))
  if h == 38 then
    local t = { ["id"] = b, ["key"] = tostring(b), ["name"] = Y["name"] or ("Provider #" .. b) }
    hf[b] = t
    return t
  end
  if h ~= nil and h ~= false then
    Rf[b] = true
  end
end
local function gB()
  local t = {}
  for b, c in pairs(ff()) do
    local N = tonumber(c["fg"]) or 0
    local Y = UB(c)
    if Y then
      table["insert"](
        t,
        { ["x"] = tonumber(c["x"]) or 0, ["y"] = tonumber(c["y"]) or 0, ["fg"] = N, ["key"] = Y["key"], ["name"] = Y["name"] }
      )
    end
  end
  table["sort"](t, function(t, b)
    if t["y"] == b["y"] then
      return t["x"] < b["x"]
    end
    return t["y"] < b["y"]
  end)
  return t
end
local function jB(t)
  if t == nil or #t == 0 then
    return nil
  end
  local b = t[1]["y"]
  local c = {}
  for t, N in ipairs(t) do
    if N["y"] > b + 4 then
      break
    end
    c[N["y"]] = c[N["y"]] or {}
    c[N["y"]][N["x"]] = true
  end
  local N, Y
  for t, h in ipairs(t) do
    if h["y"] > b + 2 then
      break
    end
    local R = false
    local O = 0
    for t = h["y"] - 2, h["y"] + 2, 1 do
      local N = c[t]
      if N then
        for c = h["x"] - 2, h["x"] + 2, 1 do
          if N[c] then
            O = O + 1
            if t == b then
              R = true
            end
          end
        end
      end
    end
    if R and (not N or O > Y or (O == Y and h["x"] < N["x"])) then
      N, Y = h, O
    end
  end
  return N
end
local function WB(t, b)
  local c, N = cB()
  return c == t and N == b
end
local function iB(t, b)
  if type(t) ~= "number" or t < 1 or t > 100 then
    return false
  end
  if WB(t, b) then
    return true
  end
  for c = 1, p, 1 do
    if not E then
      return false
    end
    if not hB() then
      Af = true
      Bf = false
      return false
    end
    Jf("PATH " .. (tostring(c) .. ("/" .. (tostring(p) .. (" -> " .. (tostring(t) .. ("," .. tostring(b))))))))
    pcall(function()
      tB(t, b)
    end)
    local N = 0
    while E and N < Uf do
      if not hB() then
        Af = true
        Bf = false
        return false
      end
      if WB(t, b) then
        Sleep(150)
        return true
      end
      Sleep(100)
      N = N + 100
    end
    if c < p then
      local t, b = cB()
      if t ~= nil and b ~= nil then
        pcall(function()
          tB(t, b)
        end)
      end
      Sleep(jf)
    end
  end
  return WB(t, b)
end
local function FB(t, b)
  if WB(t, b) then
    return true
  end
  for c = 1, p, 1 do
    if not E then
      return false
    end
    if not hB() then
      Af = true
      Bf = false
      return false
    end
    Jf("PATH " .. (tostring(c) .. ("/" .. (tostring(p) .. (" -> " .. (tostring(t) .. ("," .. tostring(b))))))))
    pcall(function()
      FindPath(t, b)
    end)
    local N = 0
    while E and N < Uf do
      if not hB() then
        Af = true
        Bf = false
        return false
      end
      if WB(t, b) then
        Sleep(150)
        return true
      end
      Sleep(100)
      N = N + 100
    end
    if c < p then
      local t, b = cB()
      if t ~= nil and b ~= nil then
        pcall(function()
          FindPath(t, b)
        end)
      end
      Sleep(jf)
    end
  end
  return WB(t, b)
end
local function dB(t, b, c)
  local N = bB(t, b)
  if N == nil then
    return nil
  end
  if tonumber(N["fg"]) ~= tonumber(c) then
    return false
  end
  return N["readyharvest"] == true
end
local function KB(t)
  L = tostring(t)
  pcall(function()
    safePHUIValue("PH_chemstatus", L)
  end)
end
local function wB()
  pcall(function()
    safePHUIValue("PH_chemdropdisplay", m and (tostring(T) .. (", " .. tostring(G))) or "NOT SET")
  end)
end
local function EB()
  return persistProviderSettings()
end
local function CB()
  pcall(function()
    safePHUIValue("PH_autocollectdisplay", D and "ON" or "OFF")
  end)
end
local function HB(t)
  safePHUIValue(
    "PH_delay_save_status",
    t and "SAVED - REOPEN SAFE" or (phConfig == nil and "UNAVAILABLE" or "SAVE FAILED")
  )
end
local function MB()
  k = {}
  a = {}
end
local function pB(t)
  t = tonumber(t)
  if t == nil or t <= 0 or t == 112 then
    return nil
  end
  t = math["floor"](t)
  if a[t] ~= nil then
    return a[t]
  end
  local b = "Item #" .. tostring(t)
  local c = getItemInfo or getItemInfoByID or GetItemInfo
  if type(c) == "function" then
    local N, Y = pcall(c, t)
    if N and (type(Y) == "table" and (type(Y["name"]) == "string" and Y["name"] ~= "")) then
      b = Y["name"]
    end
  end
  local N = { ["id"] = t, ["name"] = b }
  a[t] = N
  k[#k + 1] = N
  return N
end
local function TB(t)
  if t == nil then
    return nil
  end
  local b = GetInventory or getInventory
  if b ~= nil then
    local c, N = pcall(b)
    if c and type(N) == "table" then
      for b, c in pairs(N) do
        if tonumber(c["id"]) == tonumber(t) then
          return tonumber(c["amount"]) or 0
        end
      end
      return 0
    end
  end
  if growtopia ~= nil and type(growtopia["checkInventoryCount"]) == "function" then
    local b, c = pcall(growtopia["checkInventoryCount"], t)
    if b then
      return tonumber(c)
    end
  end
  return nil
end
local function GB()
  for t, b in ipairs(k) do
    local c = TB(b["id"])
    if c ~= nil and c >= S then
      return true
    end
  end
  return false
end
local function mB()
  local t = false
  for t, b in ipairs(k) do
    local c = TB(b["id"])
    if c ~= nil and c >= S then
      e[b["id"]] = true
    end
  end
  for b, c in pairs(e) do
    if c then
      t = true
      break
    end
  end
  if t then
    V = true
  end
  return t
end
local function SB()
  for t, b in ipairs(k) do
    local c = TB(b["id"])
    if c ~= nil and c > 0 then
      return true
    end
  end
  return false
end
local function QB(t, b)
  if not m then
    return false
  end
  if U ~= "" and not YB(af(), worldNameFromEntry(U)) then
    return false
  end
  return b >= G - 2 and (b <= G + 2 and (t >= math["min"](T, P) - 2 and t <= math["max"](T, P) + 2))
end
local function DB()
  local t = GetObjectList or getObjectList
  if t == nil then
    return {}
  end
  local b, c = pcall(t)
  if b and type(c) == "table" then
    return c
  end
  return {}
end
local function qB(t)
  local b = tonumber(t["posX"])
  local c = tonumber(t["posY"])
  if t["pos"] ~= nil then
    b = b or tonumber(t["pos"]["x"])
    c = c or tonumber(t["pos"]["y"])
  end
  return b, c
end
local function PB(t)
  for b, c in pairs(DB()) do
    if tonumber(c["id"]) == tonumber(t) then
      return true
    end
  end
  return false
end
local function yB(t)
  return tostring(t["x"]) .. (":" .. (tostring(t["y"]) .. (":" .. tostring(t["halfWidth"]))))
end
local function LB(t, b)
  if t == nil then
    return nil
  end
  local c = {
    ["x"] = math["floor"](tonumber(t["x"]) or 0),
    ["y"] = math["floor"](tonumber(t["y"]) or 0),
    ["halfWidth"] = (b == 0 and 0 or 2),
  }
  local N = yB(c)
  if not n[N] then
    n[N] = true
    v[#v + 1] = c
  end
  if l == nil then
    l = c
  end
  return c
end
local function IB(t, b, c)
  return c ~= nil
    and (
      math["abs"](t - c["x"]) <= (c["halfWidth"] == 0 and 0 or 2)
      and math["abs"](b - c["y"]) <= (c["halfWidth"] == 0 and 1 or 2)
    )
end
local function xB()
  local t = GetObjectList or getObjectList
  if t == nil then
    return {}
  end
  local b, c = pcall(t)
  if b and type(c) == "table" then
    return c
  end
  return {}
end
local function sB(t)
  local b = tonumber(t["posX"])
  local c = tonumber(t["posY"])
  if t["pos"] ~= nil then
    b = b or tonumber(t["pos"]["x"])
    c = c or tonumber(t["pos"]["y"])
  end
  return b, c
end
local function VB(t)
  for b, c in pairs(xB()) do
    if tonumber(c["id"]) == tonumber(t) then
      return true
    end
  end
  return false
end
local function eB(t, b)
  local c = {}
  local N = {}
  local Y = nil
  local h = GetInventory or getInventory
  if h ~= nil then
    local t, b = pcall(h)
    if t and type(b) == "table" then
      Y = {}
      for t, b in pairs(b) do
        local c = tonumber(b["id"])
        if c ~= nil then
          Y[c] = tonumber(b["amount"]) or 0
        end
      end
    end
  end
  if t then
    N = { t }
  end
  if not b and #N == 0 then
    return c
  end
  for t, h in pairs(xB()) do
    local R = tonumber(h["itemid"])
    local O = tonumber(h["id"])
    if R ~= nil and (R > 0 and (R ~= 112 and O ~= nil)) then
      local t, Z = sB(h)
      if t ~= nil and Z ~= nil then
        local h, u = math["floor"](t / 32), math["floor"](Z / 32)
        if not QB(h, u) then
          local o = nil
          for t, b in ipairs(N) do
            if IB(h, u, b) then
              o = b
              break
            end
          end
          if b or o ~= nil then
            local b = pB(R)
            if b ~= nil then
              local b = Y ~= nil and (Y[R] or 0) or TB(R)
              if b ~= nil and b < 200 then
                c[#c + 1] = {
                  ["uid"] = O,
                  ["id"] = R,
                  ["x"] = t,
                  ["y"] = Z,
                  ["tx"] = h,
                  ["ty"] = u,
                  ["distance"] = o and (math["abs"](h - o["x"]) + math["abs"](u - o["y"])) or 0,
                }
              end
            end
          end
        end
      end
    end
  end
  table["sort"](c, function(t, b)
    if t["distance"] == b["distance"] then
      return t["uid"] < b["uid"]
    end
    return t["distance"] < b["distance"]
  end)
  return c
end
local function JB(t)
  local b = SendPacketRaw or sendPacketRaw
  if b == nil or t["uid"] == nil then
    return false
  end
  local c, N = pcall(b, false, { ["type"] = 11, ["value"] = t["uid"], ["x"] = t["x"], ["y"] = t["y"] })
  return c and N ~= false
end
local function lB(t, b, c)
  local N = 0
  while E and (hB() and N < c) do
    local c = TB(t)
    if c ~= nil and c > b then
      return true
    end
    Sleep(50)
    N = N + 50
  end
  return (TB(t) or -1) > b
end
local function vB(t)
  if t <= 5 then
    return 3
  end
  if t >= 96 then
    return 98
  end
end
local function nB(t, b)
  local c = vB(t["tx"])
  if c then
    return iB(c, t["ty"])
  end
  local N = b and 1100 or 2600
  local Y = b and 550 or 1050
  local h = b and 50 or 75
  local R, O = cB()
  if R == nil then
    return false
  end
  if math["abs"](R - t["tx"]) <= 1 and math["abs"](O - t["ty"]) <= 1 then
    return true
  end
  local Z = pcall(function()
    tB(t["tx"], t["ty"])
  end)
  if not Z then
    return false
  end
  local u, o = 0, 0
  local X, r = R, O
  while E and (hB() and u < N) do
    R, O = cB()
    if R == nil then
      return false
    end
    if math["abs"](R - t["tx"]) <= 1 and math["abs"](O - t["ty"]) <= 1 then
      return true
    end
    if R ~= X or O ~= r then
      o = 0
      X, r = R, O
    else
      o = o + h
    end
    if o >= Y then
      return false
    end
    Sleep(h)
    u = u + h
  end
  return false
end
local function kB(t)
  if not E or not hB() then
    return false
  end
  local b = TB(t["id"])
  if b == nil or b >= 200 then
    return false
  end
  if not VB(t["uid"]) then
    return true
  end
  local c, N = cB()
  if c == nil then
    return false
  end
  local Y = vB(t["tx"])
  if (Y and (c ~= Y or N ~= t["ty"])) or (not Y and (math["abs"](c - t["tx"]) > 1 or math["abs"](N - t["ty"]) > 1)) then
    Jf("ITEM PICKUP PATH " .. (tostring(t["tx"]) .. ("," .. tostring(t["ty"]))))
    if not nB(t) then
      return false
    end
  end
  if not E or not hB() then
    return false
  end
  if (TB(t["id"]) or 0) > b then
    return true
  end
  if not VB(t["uid"]) then
    return lB(t["id"], b, 500)
  end
  for c = 1, 2, 1 do
    if not E or not hB() then
      return false
    end
    if not VB(t["uid"]) then
      return lB(t["id"], b, 450)
    end
    KB("PICKUP " .. (tostring(t["id"]) .. (" (" .. (c .. "/2)"))))
    if not JB(t) then
      return false
    end
    if lB(t["id"], b, f) then
      J = J + 1
      return true
    end
    if c == 1 then
      RB(tf)
    end
  end
  KB("PICKUP LAG - WILL RESCAN")
  return false
end
local function aB(t)
  if t == nil then
    return true
  end
  local b = t["halfWidth"] == 0 and 1 or 2
  local c = {}
  for b, N in ipairs(eB(t, false)) do
    local Y = vB(N["tx"]) or math["max"](6, math["min"](95, t["x"]))
    c[N["ty"]] = c[N["ty"]] or {}
    local h = c[N["ty"]]
    h[Y] = h[Y] or {}
    h[Y][#h[Y] + 1] = N
  end
  for b = t["y"] - b, t["y"] + b, 1 do
    if not E or not hB() then
      return false
    end
    local N = c[b] or {}
    for t, c in ipairs({ 3, math["max"](6, math["min"](95, t["x"])), 98 }) do
      local Y = N[c]
      if Y then
        local t, N = cB()
        if t ~= c or N ~= b then
          if q > 0 then
            Sleep(q)
          end
          if not E or not hB() then
            return false
          end
          iB(c, b)
        end
        t, N = cB()
        if t == c and N == b then
          KB("COLLECT ROW " .. tostring(b))
          for t, b in ipairs(Y) do
            if not E or not hB() then
              return false
            end
            if JB(b) then
              J = J + 1
            end
          end
        end
      end
    end
  end
  return E and hB()
end
local function fB()
  local t, b = {}, {}
  for c, N in ipairs(eB(nil, true)) do
    local Y = math["min"](98, math["floor"]((N["tx"] - 1) / 5) * 5 + 3)
    Y = math["max"](3, Y)
    local h = N["ty"] .. (":" .. Y)
    if not t[h] then
      t[h] = { ["x"] = Y, ["y"] = N["ty"], ["items"] = {} }
      b[#b + 1] = t[h]
    end
    local R = t[h]["items"]
    R[#R + 1] = N
  end
  table["sort"](b, function(t, b)
    if t["y"] == b["y"] then
      return t["x"] < b["x"]
    end
    return t["y"] < b["y"]
  end)
  for t, b in ipairs(b) do
    if not E or not hB() or mB() then
      return false
    end
    if not WB(b["x"], b["y"]) and not RB(q) then
      return false
    end
    if iB(b["x"], b["y"]) then
      KB("FINAL PICKUP ROW " .. (b["y"] .. (" @ " .. b["x"])))
      for t, c in ipairs(b["items"]) do
        if not E or not hB() or not WB(b["x"], b["y"]) then
          return false
        end
        if VB(c["uid"]) and JB(c) then
          J = J + 1
        end
      end
    end
  end
  return #eB(nil, true) == 0
end
local function ta(t, b, c)
  if not D then
    return true
  end
  if not E or not hB() then
    return false
  end
  if b then
    KB("FINAL LEFTOVERS CLEANUP")
    if not fB() then
      return false
    end
    l = nil
    KB("FLOATING ITEMS CLEARED")
    return true
  end
  local N = t ~= nil and LB(t, c) or l
  if N == nil then
    return true
  end
  local Y = aB(N)
  if Y then
    l = nil
  end
  return Y
end
local function ba(t)
  vf("Anticollect", t)
  vf("AntiCollect", t)
  if t then
    vf("Enable AutoCollect", false)
    vf("Autocollect", false)
  end
end
local function ca()
  local t = kf()
  if t == nil then
    return false
  end
  if t["isLeft"] == false or t["isLeft"] == nil then
    return true
  end
  local b, c = cB()
  if b == nil or b <= 1 then
    return false
  end
  if not iB(b - 1, c) then
    return false
  end
  if not iB(b, c) then
    return false
  end
  t = kf()
  return t ~= nil and t["isLeft"] ~= true
end
local function Na(t, b)
  for t = 1, 2, 1 do
    if not E or not hB() then
      return nil
    end
    if g or not WB(P, y) then
      pcall(tB, P, y)
    end
    if not RB(150) then
      return false
    end
  end
  if not WB(P, y) then
    Jf("DROP TILE NOT REACHED")
    return nil
  end
  I, x = true, false
  SendPacket(2, "action|drop\nitemID|" .. tostring(t["id"]))
  local c = 0
  while E and (hB() and c < bf) do
    if x then
      break
    end
    Sleep(50)
    c = c + 50
  end
  I = false
  if not E or not hB() then
    return false
  end
  if not x then
    return false
  end
  x = false
  if not WB(P, y) then
    return nil
  end
  SendPacket(
    2,
    "action|dialog_return\n"
      .. ("dialog_name|drop_item\n" .. ("itemID|" .. (tostring(t["id"]) .. ("|\n" .. ("count|" .. tostring(b))))))
  )
  local N = 0
  while E and (hB() and N < cf) do
    local c = TB(t["id"])
    if c ~= nil and c < b then
      if Q > N then
        RB(Q - N)
      end
      return true
    end
    Sleep(50)
    N = N + 50
  end
  return (TB(t["id"]) or b) < b
end
local function Ya(t)
  if not E or not hB() then
    return false
  end
  if not mB() then
    V = false
    return true
  end
  V = true
  if not m then
    KB("SET ITEM DROP POSITION FIRST")
    return false
  end
  s = true
  ba(true)
  local b = true
  local c = 0
  for t, N in ipairs(k) do
    if e[N["id"]] then
      while E and hB() do
        local t = TB(N["id"])
        if t == nil then
          b = false
          break
        end
        if t <= 0 then
          e[N["id"]] = nil
          break
        end
        KB("DROP " .. (N["name"] .. (" " .. tostring(t))))
        if not iB(P, y) or not ca() then
          b = false
          break
        end
        local Y = false
        for c = 1, 2, 1 do
          if not E or not hB() then
            break
          end
          local h = TB(N["id"])
          if h ~= nil and h < t then
            Y = true
            break
          end
          Jf("ITEM DROP " .. (N["name"] .. (" " .. (tostring(c) .. "/2"))))
          local R = Na(N, t)
          if R == nil then
            b = false
            break
          end
          if R then
            Y = true
            break
          end
          if c < 2 then
            RB(Nf)
          end
        end
        if not b or not E or not hB() then
          b = false
          break
        end
        if not Y then
          RB(200)
          local b = TB(N["id"])
          if b ~= nil and b < t then
            Y = true
          end
        end
        if not Y then
          if c >= Yf or P <= 1 then
            KB("ITEM DROP SPACE EXHAUSTED")
            b = false
            break
          end
          P = P - 1
          c = c + 1
          KB("DROP REJECTED -> LEFT " .. P)
          if not iB(P, y) then
            b = false
            break
          end
          RB(250)
        end
      end
      if not b or not E or not hB() then
        break
      end
    end
  end
  if b and (E and hB()) then
    local t, c = cB()
    if not g and (uf and (t ~= Of or c ~= Zf)) then
      Jf("BACK FROM ITEM DROP")
      if not iB(Of, Zf) then
        b = false
      end
    end
  end
  ba(false)
  s = false
  if b then
    local t = false
    for b, c in pairs(e) do
      if c then
        t = true
        break
      end
    end
    V = t
  end
  KB(b and "ITEM DROP DONE" or "ITEM DROP RETRY LATER")
  return b
end
local function ha(t)
  local b, c, N = 0
  for Y = 1, 60, 1 do
    if not E then
      return false
    end
    local h, R = cB()
    if h and (YB(af(), t) and next(ff())) then
      b = h == c and (R == N and b + 1) or 1
      if b >= 4 then
        return true
      end
    else
      b = 0
    end
    c, N = h, R
    Sleep(200)
  end
  return false
end
local function Ra(t)
  local b = worldNameFromEntry(t)
  if not E or not NB(b) then
    return false
  end
  if not YB(af(), b) then
    Jf("WARP BASE " .. b)
    local t = growtopia and growtopia["warpTo"]
    if type(t) == "function" then
      local c, N = pcall(t, b)
      if not c or N == false then
        return false
      end
    elseif not requestWorldJoin(b) then
      return false
    end
  end
  if not ha(b) then
    return false
  end
  if not t:find("|", 1, true) then
    return true
  end
  Jf("ENTER DOOR " .. t)
  local c, N = pcall(SendPacket or sendPacket, 3, "action|join_request\nname|" .. (t .. "\ninvitedWorld|0"))
  if not c or N == false then
    return false
  end
  Sleep(1400)
  return ha(b)
end
local function Oa(t)
  if U == "" then
    return Ya(t)
  end
  if not E or not hB() then
    return false
  end
  if not mB() or not m then
    return Ya(t)
  end
  local b = worldQueue[worldIndex] or of
  local c, N = cB()
  local Y = worldNameFromEntry(U)
  if YB(Y, of) and not U:find("|", 1, true) then
    return Ya(t)
  end
  s = true
  ba(true)
  Jf("JOIN DROP WORLD " .. Y)
  local h = Ra(U)
  local R = false
  if h and E then
    g = Y
    nf(C)
    R = Ya(t)
  end
  g = nil
  s = true
  ba(true)
  local O = E and Ra(b)
  if O then
    Bf, Af, zf = true, false, false
    nf(C)
    if c ~= nil then
      O = iB(c, N)
    end
  end
  s = false
  ba(false)
  if E and (not h or not O) then
    stopScript(not O and "Could not return to the harvest position." or "Could not enter the drop route.")
  end
  return h and (R and O)
end
local function Za(t)
  return tostring(t["x"]) .. (":" .. tostring(t["y"]))
end
local function ua()
  local t = 0
  for b in pairs(Sf) do
    t = t + 1
  end
  pcall(function()
    safePHUIValue("PH_cleanupcount", tostring(t))
  end)
end
local function oa()
  Sf = {}
  Qf = {}
  mf = 0
  Df = nil
  qf = nil
  Pf = 0
  lf("NORMAL")
  ua()
end
local function Xa(t)
  local b = {}
  local c = {}
  for t, N in ipairs(t) do
    local Y = Za(N)
    b[Y] = true
    if Sf[Y] == nil then
      table["insert"](c, N)
    end
  end
  local N = false
  for t in pairs(Sf) do
    if not b[t] then
      Sf[t] = nil
      Qf[t] = nil
      N = true
    end
  end
  if N then
    ua()
  end
  if next(Sf) == nil and Df == nil then
    lf("NORMAL")
  end
  return c
end
local function ra(t)
  if not E or not hB() then
    return false
  end
  safePHUIValue("PH_target", t["name"] .. (" @ " .. (tostring(t["x"]) .. (", " .. tostring(t["y"])))))
  local b = kf()
  if b == nil then
    return false
  end
  local c = sendPacketRaw or SendPacketRaw
  if c ~= nil then
    local N = pcall(function()
      c(false, { ["type"] = 3, ["value"] = 18, ["x"] = b["posX"], ["y"] = b["posY"], ["px"] = t["x"], ["py"] = t["y"] })
    end)
    if N then
      return true
    end
  end
  if growtopia ~= nil and type(growtopia["tileChange"]) == "function" then
    return pcall(function()
      growtopia["tileChange"](t["x"], t["y"], 18)
    end)
  end
  return false
end
local function Aa(t, b)
  local c = 0
  local N = false
  for t, Y in ipairs(t) do
    local h = tostring(Y["x"]) .. (":" .. tostring(Y["y"]))
    if not b[h] then
      local t = dB(Y["x"], Y["y"], Y["fg"])
      if t == false then
        b[h] = true
        rf = rf + 1
        AB()
        N = true
      else
        c = c + 1
      end
    end
  end
  return c, N
end
local function za(t, b)
  local c = 0
  local N = nil
  local Y = false
  while E do
    if not hB() then
      Af = true
      Bf = false
      return false, Y, 0
    end
    local h, R = Aa(t, b)
    if R then
      Y = true
      N = c
    end
    if h == 0 then
      return true, Y, 0
    end
    if Y and (N ~= nil and c - N >= df) then
      return true, Y, h
    end
    if c >= Kf then
      return true, Y, h
    end
    Sleep(Ff)
    c = c + Ff
  end
  return false, Y, 0
end
local function Ba(t)
  local b, c = cB()
  if b == nil or c == nil then
    return false, false
  end
  local N = {}
  local Y = {}
  for t = c - 2, c + 2, 1 do
    for b = b - 2, b + 2, 1 do
      local c = bB(b, t)
      local Y = c and tonumber(c["fg"])
      local h = UB(c)
      local R = tostring(b) .. (":" .. tostring(t))
      if h and Sf[R] == nil then
        N[#N + 1] = { ["x"] = b, ["y"] = t, ["fg"] = Y, ["key"] = h["key"], ["name"] = h["name"] }
      end
    end
  end
  if #N == 0 then
    Jf("RESCAN ROW")
    return true, false
  end
  Jf("HARVEST 5x5 BATCH " .. tostring(#N))
  local h = {}
  for Y, R in ipairs(N) do
    if not E then
      return false, false
    end
    if not hB() then
      Af = true
      Bf = false
      return false, false
    end
    local O, Z = cB()
    if O ~= b or Z ~= c then
      break
    end
    if dB(R["x"], R["y"], R["fg"]) == true then
      if not ra(R) then
        table["insert"](h, R)
        Df = h
        qf = { ["x"] = t["x"], ["y"] = t["y"] }
        Pf = 0
        lf("SEND FAILED - RETRY")
        Jf("PUNCH SEND FAILED - RETRY")
        return true, false
      end
      table["insert"](h, R)
      if #h < #N then
        Sleep(M + math["random"](0, 100))
      end
    end
  end
  if #h == 0 then
    Jf("RESCAN ROW")
    return true, false
  end
  Jf("VERIFY 5x5 BATCH")
  local R, O, Z = za(h, Y)
  if not R then
    return false, O
  end
  if not O then
    mf = mf + 1
    Df = h
    qf = { ["x"] = t["x"], ["y"] = t["y"] }
    Pf = 0
    lf("LAG - SINGLE HIT RETRY")
    Jf("NO BATCH ACK - LAG SAFE")
    return true, false
  end
  mf = 0
  local u, o = Aa(h, Y)
  if o then
    O = true
  end
  local X = false
  for t, b in ipairs(h) do
    local c = Za(b)
    if not Y[c] then
      if dB(b["x"], b["y"], b["fg"]) ~= false then
        Sf[c] = b
        X = true
      end
    end
  end
  if X then
    ua()
  end
  if Z > 0 or X then
    Jf("SKIP MISSES - CLEAN UP LATER")
  else
    Jf("5x5 BATCH DONE")
  end
  return true, O
end
local function Ua()
  if Df == nil then
    return true
  end
  if not E or not hB() then
    return false
  end
  local t = false
  local b = 0
  local c = {}
  local N = false
  for Y, h in ipairs(Df) do
    local R = dB(h["x"], h["y"], h["fg"])
    if R == false then
      t = true
      b = b + 1
    elseif R == true then
      table["insert"](c, h)
    else
      N = true
    end
  end
  if t then
    for t, b in ipairs(c) do
      Sf[Za(b)] = b
    end
    if N then
      for t, b in ipairs(Df) do
        if dB(b["x"], b["y"], b["fg"]) == nil then
          Sf[Za(b)] = b
        end
      end
    end
    rf = rf + b
    AB()
    ua()
    local t = qf or Df[1]
    Df = nil
    qf = nil
    Pf = 0
    mf = 0
    if D and t ~= nil then
      ta(t, false)
    end
    lf("NORMAL")
    Jf("SERVER RECOVERED - RESCAN")
    return true
  end
  local Y = c[1]
  if Y ~= nil then
    local t, b = cB()
    if t == nil or b == nil or b ~= Y["y"] or math["abs"](t - Y["x"]) > 2 then
      Jf("LAG RECOVERY - PATH")
      if not FB(Y["x"], Y["y"]) then
        Y = nil
      end
    end
  end
  if Y ~= nil and (E and (hB() and dB(Y["x"], Y["y"], Y["fg"]) == true)) then
    Jf("LAG RECOVERY - ONE HIT")
    ra(Y)
    local t = 0
    while E and t < Cf do
      if not hB() then
        return false
      end
      if dB(Y["x"], Y["y"], Y["fg"]) == false then
        break
      end
      local b = math["min"](Ff, Cf - t)
      Sleep(b)
      t = t + b
    end
  end
  for t, b in ipairs(Df) do
    if dB(b["x"], b["y"], b["fg"]) == false then
      return Ua()
    end
  end
  Pf = Pf + 1
  local h = math["min"](Pf - 1, 4)
  local R = math["min"](Hf * (2 ^ h), Mf)
  lf("LAG - RETRY " .. tostring(Pf))
  Jf("SERVER LAG - RETRY IN " .. (tostring(R) .. "ms"))
  local O = R
  while E and (O > 0 and hB()) do
    for t, b in ipairs(Df or {}) do
      if dB(b["x"], b["y"], b["fg"]) == false then
        return true
      end
    end
    local t = math["min"](250, O)
    Sleep(t)
    O = O - t
  end
  return false
end
local function ga(t)
  Qf[t] = (Qf[t] or 0) + 1
  local b = math["min"](Qf[t] - 1, 5)
  local c = math["min"](Gf * (2 ^ b), Tf)
  lf("CLEANUP RETRY " .. tostring(Qf[t]))
  Jf("CLEANUP LAG - WAIT " .. (tostring(c) .. "ms"))
  RB(c)
end
local function ja(t)
  local b = Za(t)
  if not E then
    return false, false
  end
  if not hB() then
    Af = true
    Bf = false
    return false, false
  end
  if dB(t["x"], t["y"], t["fg"]) == false then
    Sf[b] = nil
    Qf[b] = nil
    ua()
    return true, true
  end
  Jf("CLEANUP INDIVIDUAL " .. (tostring(t["x"]) .. ("," .. tostring(t["y"]))))
  if not FB(t["x"], t["y"]) then
    if not hB() then
      return false, false
    end
    ga(b)
    return true, false
  end
  if dB(t["x"], t["y"], t["fg"]) == false then
    Sf[b] = nil
    Qf[b] = nil
    ua()
    return true, true
  end
  if dB(t["x"], t["y"], t["fg"]) ~= true then
    ga(b)
    return true, false
  end
  if not ra(t) then
    ga(b)
    return true, false
  end
  local c = {}
  local N = 0
  while E and N <= pf do
    if not hB() then
      Af = true
      Bf = false
      return false, false
    end
    local Y, h = Aa({ t }, c)
    if Y == 0 then
      Sf[b] = nil
      Qf[b] = nil
      ua()
      return true, true
    end
    if N >= pf then
      break
    end
    Sleep(Ff)
    N = N + Ff
  end
  ga(b)
  return true, false
end
local function Wa(t)
  E = false
  worldTransitionPending = false
  ba(false)
  s = false
  I = false
  nf(false)
  Jf("STOPPED")
  safePHUIValue("PH_target", "NONE")
  local b = editToggle or EditToggle
  if b ~= nil then
    pcall(b, "PH_enable", false)
  end
  if t ~= nil and t ~= "" then
    ef(t)
  end
end
function resetForWorld()
  oa()
  l = nil
  v = {}
  n = {}
  Df = nil
  qf = nil
  Pf = 0
  mf = 0
  finalCleanupAttempts = 0
  finalDropFailures = 0
  e = {}
  V = false
  P, y = T, G
  safePHUIValue("PH_target", "NONE")
  lf("NORMAL")
  KB(D and "READY" or "AUTO COLLECT OFF")
end
function selectWorldInQueue(t)
  if t < 1 or t > #worldQueue then
    return false
  end
  worldIndex = t
  of = worldNameFromEntry(worldQueue[t])
  worldTransitionPending = true
  worldTransitionAttempts = 0
  worldTransitionElapsed = 0
  Af = false
  zf = false
  Bf = false
  uf = false
  resetForWorld()
  nf(false)
  updateWorldDisplay()
  Jf("GO TO WORLD " .. (tostring(t) .. ("/" .. (tostring(#worldQueue) .. (" " .. tostring(of))))))
  return true
end
function requestWorldJoin(t)
  local b = false
  if type(Warp) == "function" then
    b = pcall(Warp, t)
  elseif type(JoinWorld) == "function" then
    b = pcall(JoinWorld, t)
  else
    local c = SendPacket or sendPacket
    if type(c) == "function" then
      b = pcall(c, 3, "action|join_request\nname|" .. tostring(t))
    end
  end
  return b
end
function processWorldTransition()
  if not E or not worldTransitionPending then
    return
  end
  local t = worldQueue[worldIndex]
  if t == nil then
    Wa("World list unavailable.")
    return
  end
  if YB(af(), of) and (kf() ~= nil and next(ff()) ~= nil) then
    Sleep(250)
    if not E then
      return
    end
    if YB(af(), of) and next(ff()) ~= nil then
      Bf = true
      worldTransitionPending = false
      Af = false
      zf = false
      Of, Zf = cB()
      uf = Of ~= nil
      nf(C)
      Jf("SCANNING " .. tostring(of))
      updateWorldDisplay()
      return
    end
  end
  if worldTransitionAttempts == 0 or worldTransitionElapsed >= 8000 then
    if worldTransitionAttempts >= 3 then
      Wa("Could not enter world " .. (tostring(of) .. ". Stopped instead of skipping it."))
      return
    end
    worldTransitionAttempts = worldTransitionAttempts + 1
    worldTransitionElapsed = 0
    Jf("JOIN " .. (tostring(of) .. (" (" .. (tostring(worldTransitionAttempts) .. "/3)"))))
    if not requestWorldJoin(t) then
      Wa("Growlauncher world join unavailable; " .. tostring(t))
      return
    end
  end
  Sleep(250)
  worldTransitionElapsed = worldTransitionElapsed + 250
end
function finishCurrentWorld(t)
  if not E or worldTransitionPending or not hB() or not YB(af(), worldNameFromEntry(worldQueue[worldIndex])) then
    return
  end
  local b = tostring(of)
  if not E or not hB() then
    return
  end
  if t then
    ef("Uncollected provider drops remain in " .. (b .. ". They were not deleted. Moving on after limited retries."))
  end
  if worldIndex < #worldQueue then
    ef("Provider world complete: " .. (b .. ". Next world."))
    selectWorldInQueue(worldIndex + 1)
  else
    Wa("All " .. (tostring(#worldQueue) .. " provider world(s) completed."))
  end
end
local function ia()
  local t, b = cB()
  if t == nil or b == nil then
    ef("Player position is not available.")
    return
  end
  Of = t
  Zf = b
  uf = true
  rB()
  ef("Start Position = (" .. (tostring(Of) .. (", " .. (tostring(Zf) .. ")"))))
end
function onVariant(t, b)
  if
    E and (
      I and (
        t ~= nil and (
          t["v1"] == "OnDialogRequest" and (type(t["v2"]) == "string" and t["v2"]:find("drop_item", 1, true))
        )
      )
    )
  then
    x = true
    return true
  end
  if t ~= nil then
    if E and (t["v1"] == "OnSpawn" and type(t["v2"]) == "string") then
      local b = t["v2"]:find("type|local", 1, true) ~= nil
      if not b then
        local c = tonumber(t["v2"]:match("netID|(%d+)"))
        local N = kf()
        if c ~= nil and N ~= nil then
          b = tonumber(N["netID"]) == c
        end
      end
      if b and (Af or not Bf) then
        zf = true
        Af = true
      end
    end
    if E and (Af and t["v1"] == "OnSetPos") then
      zf = true
    end
  end
  return false
end
function onSendPacketRaw(t)
  if E and ((D or s) and (t ~= nil and (tonumber(t["type"]) == 11 and m))) then
    local b, c = tonumber(t["x"]), tonumber(t["y"])
    if b ~= nil and (c ~= nil and QB(math["floor"](b / 32), math["floor"](c / 32))) then
      return true
    end
    if s then
      local t, b = cB()
      if t ~= nil and QB(t, b) then
        return true
      end
    end
  end
  return false
end
function onSendPacket(t, b)
  if type(b) == "string" then
    if E then
      local t = b:find("action|quit", 1, true) ~= nil
      local c = b:find("action|join_request", 1, true) ~= nil
      if t or c then
        Af = true
        zf = false
        Bf = false
        nf(false)
        Jf("PAUSED - WAIT WORLD")
      end
    end
  end
  return false
end
function onGamePacket(t)
  if t ~= nil and (tonumber(t["type"]) == 26 and E) then
    if not Af then
      ef("Provider Harvester paused - disconnected.")
    end
    Af = true
    zf = false
    Bf = false
    nf(false)
    Jf("PAUSED - WAIT WORLD")
  end
  return false
end
local function Fa()
  E = true
  local t = kf()
  local b = af()
  if t == nil or b == "" or b == "EXIT" then
    Wa("Enter a world first.")
    return
  end
  BB()
  MB()
  l = nil
  v = {}
  n = {}
  if D and not m then
    Wa("Set Item Drop Position in Settings before starting Auto Collect.")
    return
  end
  if D and (T < 1 or T > 100 or G < 0) then
    Wa("Invalid Item Drop Position; use Settings > Current Tile.")
    return
  end
  P, y = T, G
  J = 0
  s = false
  V = false
  e = {}
  I, x = false, false
  KB(D and "READY" or "AUTO COLLECT OFF")
  worldQueue = parseHarvestWorlds(harvestWorldText)
  if #worldQueue == 0 and harvestWorldText:find("%S") then
    Wa("Invalid Harvest Worlds list. Enter WORLD or WORLD|DOORID.")
    return
  end
  if #worldQueue == 0 then
    worldQueue = { b }
    Jf("CURRENT WORLD ONLY: " .. tostring(b))
  end
  rf = 0
  AB()
  selectWorldInQueue(1)
  ef("Provider Harvester started: " .. (tostring(#worldQueue) .. " world(s)."))
end
local da = false
local function Ka(t)
  if da then
    return
  end
  da = true
  pcall(function()
    safePHUIValue("PH_worlds", tostring(t or ""))
  end)
  da = false
end
function onValue(t, b, c)
  if PHUIWriteInProgress[b] then
    return
  end
  if b == "PH_worlds" and da then
    return
  end
  if b == "PH_worlds" or b == "PH_addworld" or b == "PH_removeworld" or b == "PH_clearworlds" then
    if E then
      if b == "PH_worlds" and tostring(c or "") ~= harvestWorldText then
        Ka(harvestWorldText)
      end
      ef("Stop the provider script before changing harvest worlds.")
      return
    end
    local t = harvestWorldText
    if b == "PH_worlds" then
      t = tostring(c or "")
    elseif b == "PH_clearworlds" then
      t = ""
    elseif b == "PH_addworld" then
      local b = af()
      if not NB(b) then
        ef("Enter a world first.")
        return
      end
      local c = parseHarvestWorlds(harvestWorldText)
      local N = false
      for t, c in ipairs(c) do
        if worldNameFromEntry(c) == b then
          N = true
        end
      end
      if not N then
        c[#c + 1] = b
      end
      t = table["concat"](c, ",")
    else
      local b = parseHarvestWorlds(harvestWorldText)
      if #b > 0 then
        table["remove"](b)
      end
      t = table["concat"](b, ",")
    end
    if t ~= harvestWorldText then
      harvestWorldText = t
      persistProviderSettings()
    end
    if b ~= "PH_worlds" then
      Ka(harvestWorldText)
    end
    return
  end
  if b == "PH_enable" then
    if c == true or c == 1 or c == "true" or c == "1" then
      if E then
        return
      end
      Fa()
    else
      E = false
      worldTransitionPending = false
      ba(false)
      s = false
      I = false
      nf(false)
      Af = false
      zf = false
      Bf = false
      Jf("STOPPED")
      safePHUIValue("PH_target", "NONE")
      ef("Provider Harvester stopped safely.")
    end
    return
  end
  if b == "PH_autocollect" then
    local t = c == true or c == 1 or c == "true" or c == "1"
    if s then
      ef("Please wait for the current item drop to finish.")
      pcall(function()
        safePHUIValue("PH_autocollect", D)
      end)
      return
    end
    if t and (E and (not m or T < 1 or T > 100)) then
      ef("Set a valid Drop Position before enabling Auto Collect.")
      pcall(function()
        safePHUIValue("PH_autocollect", false)
      end)
      return
    end
    D = t
    if not t then
      l = nil
      e = {}
      V = false
      KB("AUTO COLLECT OFF")
    else
      KB("AUTO COLLECT ON")
    end
    local b = EB()
    CB()
    HB(b)
    return
  end
  if b == "PH_autocollectdisplay" then
    CB()
    return
  end
  if b == "PH_recovery" then
    if tostring(c or "") ~= yf then
      pcall(function()
        safePHUIValue("PH_recovery", yf)
      end)
    end
    return
  end
  local N = b == "PH_hereDropWorld"
  if N then
    local t = af()
    if not NB(t) or not kf() then
      ef("Enter the drop world first.")
      return
    end
    b, c = "PH_dropworld", t
  end
  if b == "PH_dropworld" then
    local t = (tostring(c or "")):match("^%s*(.-)%s*$")
    local Y, h = t:match("^([%w_]+)|([%w_-]+)$")
    Y = Y or t:match("^([%w_]+)$")
    if E or (t ~= "" and (not Y or #Y > 24 or Y:upper() == "EXIT")) then
      safePHUIValue(b, U)
      ef(E and "Stop harvesting before changing the drop world." or "Enter WORLD or WORLD|DOORID.")
      return
    end
    U = Y and (Y:upper() .. (h and "|" .. h or "")) or ""
    if N or U ~= t then
      safePHUIValue(b, U)
    end
    EB()
    return
  end
  if b == "PH_setchemdrop" then
    if s then
      ef("Please wait until the current item drop finishes.")
      return
    end
    if U ~= "" and not YB(af(), worldNameFromEntry(U)) then
      ef("Enter the configured drop world before capturing the stand tile.")
      return
    end
    local t, b = cB()
    if t ~= nil and b ~= nil then
      T, G = t, b
      P, y = t, b
      m = true
      safePHUIValue("PH_chemdropx", tostring(t))
      safePHUIValue("PH_chemdropy", tostring(b))
      wB()
      EB()
      ef("Item drop stand tile set; drop target is one tile RIGHT.")
    else
      ef("Enter a world before setting item drop position.")
    end
    return
  end
  if b == "PH_chemdropx" or b == "PH_chemdropy" then
    if s then
      ef("Please wait until the current item drop finishes.")
      pcall(function()
        safePHUIValue(b, tostring(b == "PH_chemdropx" and T or G))
      end)
      return
    end
    local t = tonumber(c)
    if t ~= nil then
      t = math["floor"](t)
      if t >= (b == "PH_chemdropx" and 1 or 0) and t <= (b == "PH_chemdropx" and 100 or 999) then
        if b == "PH_chemdropx" then
          T = t
        else
          G = t
        end
        P, y = T, G
        m = true
        wB()
        EB()
      end
    else
      pcall(function()
        safePHUIValue(b, tostring(b == "PH_chemdropx" and T or G))
      end)
    end
    return
  end
  if b == "PH_chemthreshold" then
    local t = tonumber(c)
    if t ~= nil then
      S = math["max"](1, math["min"](200, math["floor"](t)))
      safePHUIValue("PH_chemthreshold", tostring(S))
      EB()
    end
    return
  end
  if b == "PH_chemdropdelay" then
    local t = tonumber(c)
    if t ~= nil then
      Q = math["max"](0, math["min"](5000, math["floor"](t)))
      safePHUIValue("PH_chemdropdelay", tostring(Q))
      EB()
    end
    return
  end
  if b == "PH_chemdropdisplay" then
    local t = m and (tostring(T) .. (", " .. tostring(G))) or "NOT SET"
    if tostring(c or "") ~= t then
      wB()
    end
    return
  end
  if b == "PH_chemstatus" then
    if tostring(c or "") ~= L then
      pcall(function()
        safePHUIValue("PH_chemstatus", L)
      end)
    end
    return
  end
  if b == "PH_fastcollectgap" then
    local t = tonumber(c)
    if t ~= nil then
      q = math["max"](30, math["min"](500, math["floor"](t)))
      safePHUIValue("PH_fastcollectgap", tostring(q))
      HB(EB())
    end
    return
  end
  if b == "PH_delay" then
    local t = tonumber(c)
    if t ~= nil then
      t = math["floor"](t)
      if t < 0 then
        t = 0
      end
      if t > 5000 then
        t = 5000
      end
      M = t
      safePHUIValue("PH_delay", tostring(M))
      HB(persistProviderSettings())
    end
    return
  end
end
applyHook()
BB()
runThread(function()
  while true do
    if not E then
      Sleep(200)
    else
      if worldTransitionPending then
        processWorldTransition()
      elseif not XB() then
        Sleep(200)
      else
        nf(C)
        Jf("SCANNING")
        if D and (V or GB()) then
          if not Oa(V) then
            RB(650)
          end
        elseif D and l ~= nil then
          if not ta(nil, false) then
            RB(500)
          end
        elseif Df ~= nil then
          Ua()
        else
          local t = gB()
          local b = Xa(t)
          if #t > 0 then
            finalCleanupAttempts = 0
            finalDropFailures = 0
          end
          if #t == 0 then
            if next(ff()) == nil then
              Jf("WAIT WORLD TILES")
              RB(300)
            else
              Jf("VERIFY NO READY PROVIDERS")
              RB(220)
              if E and hB() then
                local t = gB()
                if #t > 0 then
                  Jf("PROVIDERS FOUND - CONTINUE")
                elseif next(ff()) == nil then
                  Jf("WAIT WORLD TILES")
                else
                  if not D then
                    Jf("PROVIDERS FINISHED - NO COLLECT")
                    finishCurrentWorld(false)
                  else
                    local t = ta(nil, true)
                    if E and hB() then
                      local b = eB(nil, true)
                      if not t or #b > 0 then
                        Jf("FLOATING ITEMS REMAIN - RETRYING")
                        RB(750)
                      else
                        for t, b in ipairs(k) do
                          if (TB(b["id"]) or 0) > 0 then
                            e[b["id"]] = true
                            V = true
                          end
                        end
                        if V then
                          if not Oa(true) then
                            RB(750)
                          end
                        else
                          finishCurrentWorld(false)
                        end
                      end
                    end
                  end
                end
              end
            end
          elseif #b > 0 then
            local t = jB(b)
            if t == nil then
              Jf("ROW TARGET MISSING - RESCAN")
              RB(500)
            else
              safePHUIValue(
                "PH_target",
                t["name"] .. (
                    " 5x5 BATCH " .. (tostring(t["y"]) .. (" @ " .. (tostring(t["x"]) .. (", " .. tostring(t["y"])))))
                  )
              )
              if FB(t["x"], t["y"]) then
                local b, c = cB()
                local N, Y = Ba(t)
                if not N then
                  if not hB() then
                    Af = true
                    nf(false)
                    Jf("PAUSED - WAIT WORLD")
                  else
                    lf("BATCH ERROR - RETRY")
                    Jf("BATCH ERROR - RETRY")
                    RB(1500)
                  end
                elseif N then
                  if D and b ~= nil then
                    ta({ ["x"] = b, ["y"] = c }, false)
                  end
                  Sleep(Y and 25 or 100)
                else
                  Sleep(100)
                end
              else
                if not hB() then
                  Af = true
                  nf(false)
                  Jf("PAUSED - WAIT WORLD")
                else
                  Jf("PATH RETRY - RESCAN")
                  Sleep(700)
                end
              end
            end
          else
            local b = nil
            local c = math["huge"]
            for t, N in ipairs(t) do
              local Y = Za(N)
              local h = Qf[Y] or 0
              if Sf[Y] ~= nil and h < c then
                b = N
                c = h
              end
            end
            if b == nil then
              Jf("CLEANUP LIST CHANGED - RESCAN")
              RB(650)
            else
              local t, c = ja(b)
              if not t then
                if not hB() then
                  Af = true
                  nf(false)
                  Jf("PAUSED - WAIT WORLD")
                else
                  lf("CLEANUP ERROR - RETRY")
                  Jf("CLEANUP ERROR - RETRY")
                  RB(1500)
                end
              elseif c then
                if D then
                  ta(b, false, 0)
                end
                Sleep(25)
              else
                Sleep(75)
              end
            end
          end
        end
      end
    end
  end
end)
if type(setOnValue) == "function" then
  for t, b in ipairs({ "PH_worlds", "PH_enable" }) do
    pcall(setOnValue, b, function(...)
      local t = select("#", ...)
      if t > 0 then
        onValue(nil, b, select(t, ...))
      end
    end)
  end
end
