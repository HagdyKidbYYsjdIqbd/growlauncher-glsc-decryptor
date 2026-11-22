setMinimum("6.1.2")
PHUIWriteInProgress = {}
function safePHUIValue(j, x)
  if PHUIWriteInProgress[j] then
    return true
  end
  PHUIWriteInProgress[j] = true
  local r = pcall(function()
    editValue(j, x)
  end)
  PHUIWriteInProgress[j] = nil
  return r
end
local j =
  "https://script.google.com/macros/s/AKfycbxeBzpOUzvcRDkX-4eR8uioFbAUDsepIQc26kmxUkXt6YOjBxFdVsOE0zzvxYSprl5knA/exec"
local x = "PROVIDER"
local r = "ProviderHarvesterLicense"
local A = "license_key"
local d = nil
local X = ""
local function Y(j)
  j = tostring(j or "")
  j = j:gsub("%s+", "")
  return j:upper()
end
local function n(j)
  j = Y(j)
  return j:match("^[A-Z]%d%d%d%d%d%d%d$") ~= nil
end
local function M()
  local j = pcall(function()
    local j = nil
    if type(require) == "function" then
      local x, r = pcall(require, "preferences")
      if x and r ~= nil then
        j = r
      end
    end
    if j == nil and type(Preferences) == "table" then
      j = Preferences
    end
    if j == nil then
      return
    end
    if type(j["new"]) == "function" then
      local x = j:new(r)
      d = x or j
    else
      d = j
    end
    if d ~= nil and type(d["load"]) == "function" then
      d:load()
    end
    if d ~= nil and type(d["get"]) == "function" then
      X = Y(d:get(A, ""))
    end
  end)
  if not j then
    d = nil
    X = ""
  end
end
local function K(j)
  if d == nil then
    return false
  end
  local x = pcall(function()
    d:set(A, Y(j))
    d:save()
  end)
  return x
end
local function Z()
  if d == nil then
    return false
  end
  local j = pcall(function()
    d:set(A, "")
    d:save()
  end)
  return j
end
M()
local v = "ProviderHarvesterPunchDelayV21"
local q = "punch_delay_ms"
local a = nil
local y = 180
local function W()
  local j = nil
  if type(require) == "function" then
    local x, r = pcall(require, "preferences")
    if x and r ~= nil then
      j = r
    end
  end
  if j == nil and type(Preferences) == "table" then
    j = Preferences
  end
  if j == nil or type(j["new"]) ~= "function" then
    return
  end
  local x, r = pcall(function()
    return j:new(v)
  end)
  if not x or r == nil then
    return
  end
  a = r
  pcall(function()
    a:load()
  end)
  local A, d = pcall(function()
    return a:get(q, 180)
  end)
  if A and tonumber(d) ~= nil then
    local j = math["floor"](tonumber(d))
    y = math["max"](0, math["min"](5000, j))
  end
end
local function C(j)
  if a == nil then
    return false
  end
  local x = pcall(function()
    local x = a:set(q, j)
    if x == false then
      error("Preferences:set failed")
    end
    local r = a:save()
    if r == false then
      error("Preferences:save failed")
    end
  end)
  return x
end
W()
local h, t = 0, 0
local G = false
local k = 190
local E = 250
local i = true
local T = 70
local function U()
  if a == nil then
    return
  end
  local j = pcall(function()
    h = math["floor"](tonumber(a:get("chem_drop_x", 0)) or 0)
    t = math["floor"](tonumber(a:get("chem_drop_y", 0)) or 0)
    G = a:get("chem_drop_configured", false) == true
    k = math["max"](1, math["min"](200, math["floor"](tonumber(a:get("chem_threshold", 190)) or 190)))
    E = math["max"](0, math["min"](5000, math["floor"](tonumber(a:get("chem_drop_delay", 250)) or 250)))
    T = math["max"](30, math["min"](500, math["floor"](tonumber(a:get("fast_collect_gap_ms", 70)) or 70)))
    local j = a:get("auto_collect_enabled", true)
    i = not (j == false or j == 0 or j == "false" or j == "0")
  end)
  if not j then
    h, t = 0, 0
    G = false
    k, E = 190, 250
    T = 70
    i = true
  end
end
U()
savedHarvestWorlds = ""
savedReturnToStart = false
if a ~= nil then
  pcall(function()
    savedHarvestWorlds = tostring(a:get("harvest_world_list", "") or "")
    local j = a:get("return_to_start", false)
    savedReturnToStart = (j == true or j == "true" or j == 1 or j == "1")
  end)
end
function saveWorldSettings(j, x)
  if a == nil then
    return false
  end
  return pcall(function()
    a:set("harvest_world_list", tostring(j or ""))
    a:set("return_to_start", x == true)
    a:save()
  end)
end
local function l(j, x, r, A, d, X, Y)
  if a == nil then
    return false
  end
  return pcall(function()
    a:set("chem_drop_x", j)
    a:set("chem_drop_y", x)
    a:set("chem_drop_configured", r)
    a:set("chem_threshold", A)
    a:set("chem_drop_delay", d)
    a:set("fast_collect_gap_ms", Y)
    a:set("auto_collect_enabled", X == true)
    a:save()
  end)
end
PH_CONFIG_FILE = "ProviderHarvesterAllSettingsV6.json"
phConfig = nil
phPreferenceModule = nil
phConfigRestored = false
savedProviderSelection = nil
function loadPersistentProviderSettings()
  if type(require) == "function" then
    local j, x = pcall(require, "preferences")
    if j and x ~= nil then
      phPreferenceModule = x
    end
  end
  if phPreferenceModule == nil and type(Preferences) == "table" then
    phPreferenceModule = Preferences
  end
  if phPreferenceModule == nil or type(phPreferenceModule["new"]) ~= "function" then
    return
  end
  local j, x = pcall(function()
    return phPreferenceModule:new(PH_CONFIG_FILE)
  end)
  if not j or x == nil then
    return
  end
  if
    type(x["load"]) ~= "function"
    or type(x["get"]) ~= "function"
    or type(x["set"]) ~= "function"
    or type(x["save"]) ~= "function"
  then
    return
  end
  if not pcall(function()
    x:load()
  end) then
    return
  end
  phConfig = x
  local r, A = pcall(function()
    return x:get("schema", "")
  end)
  if not r or tostring(A) ~= "6" then
    return
  end
  local d = pcall(function()
    savedHarvestWorlds = tostring(x:get("worlds", savedHarvestWorlds) or "")
    local function j(j, r, A, d)
      local X = tonumber(x:get(j, r)) or r
      return math["max"](A, math["min"](d, math["floor"](X)))
    end
    local function r(j, r)
      local A = x:get(j, r and "true" or "false")
      return A == true or A == "true" or A == "1" or A == 1
    end
    savedReturnToStart = r("return_start", savedReturnToStart)
    i = r("auto_collect", i)
    y = j("punch_delay", y, 0, 5000)
    T = j("collect_delay", T, 30, 500)
    k = j("drop_threshold", k, 1, 200)
    E = j("drop_delay", E, 0, 5000)
    h = j("drop_x", h, 0, 999)
    t = j("drop_y", t, 0, 999)
    G = r("drop_configured", G)
    local A = tostring(x:get("provider_key", "") or "")
    if A ~= "" then
      savedProviderSelection = A
    end
    X = Y(x:get("license_key", X))
  end)
  phConfigRestored = d
end
loadPersistentProviderSettings()
function saveProviderSettingsSnapshot(j)
  if phConfig == nil or phPreferenceModule == nil then
    return false
  end
  local x = pcall(function()
    phConfig:set("schema", "6")
    for j, x in pairs(j) do
      phConfig:set(j, tostring(x))
    end
    if phConfig:save() == false then
      error("Preferences save rejected")
    end
  end)
  if not x then
    return false
  end
  local r, A = pcall(function()
    local x = phPreferenceModule:new(PH_CONFIG_FILE)
    if not x then
      return false
    end
    x:load()
    if tostring(x:get("schema", "")) ~= "6" then
      return false
    end
    for j, r in pairs(j) do
      if tostring(x:get(j, "")) ~= tostring(r) then
        return false
      end
    end
    return true
  end)
  return r and A == true
end
local Q = {
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
  { ["key"] = "science", ["name"] = "Science Station", ["default"] = true, ["fallbackID"] = 928 },
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
local e = "Provider Harvester V6 Persistent AutoSave"
local s = UserInterface["new"](e, "Agriculture")
s:addLabelApp("Provider Harvester V6 - AutoSave", "Agriculture")
s:addInputString("License Key", X, "A1234567", "A1234567", nil, "PH_licensekey")
s:addButton("Verify License", "PH_verifylicense")
s:addButton("Clear Saved License", "PH_clearlicense")
s:addDisplayList("License Status", "NOT VERIFIED", "PH_licensestatus")
s:addToggle("Start / Stop", false, "PH_enable")
s:addButton("Provider Select", "PH_open_provider")
local R = s:addDialog("Settings", "Auto Collect, harvesting, multi-world and drop settings", {})
s:addChildInputString(
  R["menu"],
  "Harvest Worlds (blank = current world)",
  savedHarvestWorlds,
  "WORLD1,WORLD2 (leave empty for current)",
  "Worlds",
  "Agriculture",
  "PH_worlds"
)
s:addChildTooltip(
  R["menu"],
  "Empty Harvest Worlds",
  "When no worlds are entered, harvest ONLY the world you are standing in when you press Start. This also works if the saved value is empty or contains spaces.",
  "Agriculture",
  false
)
s:addChildButton(R["menu"], "Clear Worlds / Use Current World", "PH_clearworlds")
s:addChildButton(R["menu"], "Add Current World", "PH_addworld")
s:addChildButton(R["menu"], "Remove Last World", "PH_removeworld")
s:addChildToggle(
  R["menu"],
  "Return to Start After Each World (slower)",
  savedReturnToStart,
  "PH_returnstart",
  false,
  true
)
s:addChildToggle(R["menu"], "Auto Collect + Auto Drop", i, "PH_autocollect", false, true)
s:addChildTooltip(
  R["menu"],
  "Auto Collect OFF = immediate finish",
  "When OFF, there are NO floating-item scans, collection attempts or drops. After two valid provider scans show no ready stations, finish the current world immediately and continue to the next configured world (or stop).",
  "Agriculture",
  false
)
s:addChildTooltip(
  R["menu"],
  "Fast Batch Collection",
  "One paced pickup pass after each five-hit group. Missed floating items are checked at the end.",
  "Agriculture",
  true
)
s:addChildInputInt(R["menu"], "Fast Collect Delay", tostring(T), "ms", "70", "Agriculture", "PH_fastcollectgap")
s:addChildInputInt(R["menu"], "Punch Delay", tostring(y), "ms", "180", "Agriculture", "PH_delay")
s:addChildTooltip(
  R["menu"],
  "Threshold-only Drop",
  "Only item types reaching the threshold are dropped. Partial stacks remain in your backpack, including at final cleanup.",
  "Agriculture",
  true
)
s:addChildInputInt(R["menu"], "Drop at Inventory Count", tostring(k), "items", "190", "Agriculture", "PH_chemthreshold")
s:addChildInputInt(R["menu"], "Item Drop Delay", tostring(E), "ms", "250", "Agriculture", "PH_chemdropdelay")
s:addChildTooltip(
  R["menu"],
  "Item Drop Position",
  "Your standing tile. Items drop one tile RIGHT; after two unconfirmed drop attempts, move LEFT and retry the same item.",
  "Agriculture",
  true
)
s:addChildInputInt(R["menu"], "Drop X (Stand Tile)", tostring(h), "X", "0", "Agriculture", "PH_chemdropx")
s:addChildInputInt(R["menu"], "Drop Y (Stand Tile)", tostring(t), "Y", "0", "Agriculture", "PH_chemdropy")
s:addChildButton(R["menu"], "Set Drop Position = Current Tile", "PH_setchemdrop")
s:addChildTooltip(
  R["menu"],
  "Auto Save",
  "Every input, provider choice and entered license key are saved to persistent settings. Start / Stop always opens OFF. Check Settings Auto Save on main page.",
  "Agriculture",
  false
)
s:addInputString(
  "Selected Provider (view only)",
  "Science Station",
  "Selected",
  "Provider name",
  nil,
  "PH_selectedprovider"
)
s:addInputString("Auto Collect (view only)", i and "ON" or "OFF", "Collect", "Status", nil, "PH_autocollectdisplay")
s:addInputString(
  "Drop Position (view only)",
  G and (tostring(h) .. (", " .. tostring(t))) or "NOT SET",
  "X, Y",
  "Drop to right",
  nil,
  "PH_chemdropdisplay"
)
s:addInputString("Item Collection Status (view only)", "IDLE", "Provider drops", "Status", nil, "PH_chemstatus")
s:addDisplayList(
  "Settings Auto Save",
  phConfig == nil and "UNAVAILABLE" or (phConfigRestored and "RESTORED" or "READY - SAVE ON CHANGE"),
  "PH_delay_save_status"
)
s:addDisplayList("World Progress", "CURRENT WORLD", "PH_worldstatus")
s:addDisplayList("Missed for Cleanup", "0", "PH_cleanupcount")
s:addDisplayList("Current Target", "NONE", "PH_target")
s:addDisplayList("Status", "STOPPED", "PH_status")
s:addInputString("Server Recovery (view only)", "NORMAL", "Recovery", "Status", nil, "PH_recovery")
pcall(function()
  addCategory(e, "Agriculture")
end)
local g = pcall(function()
  addIntoModule(s:generateJSON(), e)
end)
if not g then
  addIntoModule(s:generateJSON())
end
local w = false
local S = X
local L = false
local m = false
local f = "NOT VERIFIED"
local J = false
local c = 0
local D = 0
local O = true
local o = true
local H = savedReturnToStart
local B = y
local F = 6
local N, z = h, t
local P = G
local I = k
local V = E
local p = i
local u = T
local b, jT = N, z
local xT = "IDLE"
local rT, AT = false, false
local dT = false
local XT = false
local YT = {}
local nT = 0
local MT = nil
local KT = {}
local ZT = {}
local vT = {}
local qT = {}
local aT = 1200
local yT = 300
local WT = 2200
local CT = 2500
local hT = 350
local tT = 100
local GT = "science"
local kT = {}
local ET = {}
local iT = 0
for j, x in ipairs(Q) do
  ET[x["key"]] = x
  if x["default"] == true then
    GT = x["key"]
  end
end
if savedProviderSelection ~= nil and ET[savedProviderSelection] ~= nil then
  GT = savedProviderSelection
end
function persistProviderSettings()
  local j = {
    ["worlds"] = harvestWorldText,
    ["return_start"] = tostring(H == true),
    ["auto_collect"] = tostring(p == true),
    ["punch_delay"] = B,
    ["collect_delay"] = u,
    ["drop_threshold"] = I,
    ["drop_delay"] = V,
    ["drop_x"] = N,
    ["drop_y"] = z,
    ["drop_configured"] = tostring(P == true),
    ["provider_key"] = GT,
    ["license_key"] = Y(S),
  }
  local x = saveProviderSettingsSnapshot(j)
  safePHUIValue(
    "PH_delay_save_status",
    x and "SAVED - REOPEN SAFE" or (phConfig == nil and "UNAVAILABLE" or "SAVE FAILED")
  )
  return x
end
local TT = 0
local UT = 0
local lT = false
local QT = ""
harvestWorldText = savedHarvestWorlds
worldQueue = {}
worldIndex = 0
worldTransitionPending = false
worldTransitionAttempts = 0
worldTransitionElapsed = 0
finalCleanupAttempts = 0
finalDropFailures = 0
local eT = "STOPPED"
local sT = 0
local RT = false
local gT = false
local wT = false
local ST = 3500
local LT = 3500
local mT = 400
local fT = 350
local JT = 50
local cT = 250
local DT = 1250
local OT = 850
local oT = 3400
local HT = 3500
local BT = 1200
local FT = 12000
local NT = 1500
local zT = 10000
local PT = 300
local IT = 0
local VT = {}
local pT = {}
local uT = nil
local bT = nil
local jM = 0
local xM = "NORMAL"
local rM = 700
local AM = 5000
local dM = 200
local XM = 3
local YM = 450
local function nM(j)
  if growtopia ~= nil and type(growtopia["notify"]) == "function" then
    pcall(function()
      growtopia["notify"](tostring(j))
    end)
  end
end
local function MM(j)
  f = tostring(j or "")
  pcall(function()
    safePHUIValue("PH_licensestatus", f)
  end)
end
local function KM(j)
  j = tostring(j or "")
  j = j:gsub("\n", "\r\n")
  j = j:gsub("([^%w%-_%.~])", function(j)
    return string["format"]("%%%02X", string["byte"](j))
  end)
  return j
end
local function ZM()
  local j = ""
  if type(getDiscordID) == "function" then
    local x, r = pcall(getDiscordID)
    if x and r ~= nil then
      j = tostring(r)
    end
  elseif getDiscordID ~= nil then
    j = tostring(getDiscordID)
  end
  j = ((tostring(j or "")):gsub("^%s+", "")):gsub("%s+$", "")
  if j == "" or j == "nil" or j == "0" then
    local x = GetLocal or getLocal
    if x ~= nil then
      local r, A = pcall(x)
      if r and (A ~= nil and A["name"] ~= nil) then
        j = tostring(A["name"])
        j = (j:gsub("^%s+", "")):gsub("%s+$", "")
      end
    end
  end
  return j
end
local function vM(r)
  if m then
    return false
  end
  m = true
  L = false
  local A = Y(S)
  S = A
  pcall(function()
    safePHUIValue("PH_licensekey", A)
  end)
  if not n(A) then
    MM("INVALID KEY FORMAT")
    m = false
    if not r then
      nM("License must be 1 letter + 7 numbers, for example A1234567.")
    end
    return false
  end
  local d = ZM()
  if d == "" then
    MM("NO CLIENT ID")
    m = false
    if not r then
      nM("Could not read a client ID. Enter the game first and try again.")
    end
    return false
  end
  MM("CHECKING...")
  D = D + 1
  local M = (os and type(os["time"]) == "function") and os["time"]() or math["random"](100000, 999999)
  local Z = tostring(D) .. ("_" .. tostring(M))
  local v = j .. ("?key=" .. (KM(A) .. ("&id=" .. (KM(d) .. ("&product=" .. (KM(x) .. ("&nonce=" .. KM(Z))))))))
  local q, a = pcall(fetch, v)
  if not q then
    MM("SERVER ERROR")
    m = false
    if not r then
      nM("License server request failed.")
    end
    return false
  end
  a = tostring(a or "")
  a = (a:gsub("^%s+", "")):gsub("%s+$", "")
  if a:find("OK|PERMANENT", 1, true) then
    L = true
    MM("VERIFIED - PROVIDER")
    if K(A) then
      X = A
    end
    S = A
    m = false
    if not r then
      nM("Provider license verified and saved.")
    end
    return true
  end
  if a:find("DENY|WRONG_PRODUCT", 1, true) then
    MM("WRONG PRODUCT")
  elseif a:find("DENY|DISABLED", 1, true) then
    MM("DISABLED")
  elseif a:find("DENY|BOUND_TO_OTHER_USER", 1, true) then
    MM("BOUND TO OTHER USER")
  elseif a:find("DENY|INVALID_KEY", 1, true) then
    MM("INVALID KEY")
  elseif a:find("DENY|BAD_KEY_FORMAT", 1, true) then
    MM("BAD KEY FORMAT")
  elseif a:find("DENY|NO_ID", 1, true) then
    MM("NO CLIENT ID")
  else
    MM("CHECK FAILED")
  end
  m = false
  if not r then
    nM("License denied. Check License Status.")
  end
  return false
end
local function qM(j)
  j = tostring(j)
  if eT ~= j then
    eT = j
    safePHUIValue("PH_status", j)
  end
end
local function aM(j)
  j = tostring(j)
  if xM ~= j then
    xM = j
    pcall(function()
      safePHUIValue("PH_recovery", j)
    end)
  end
end
local function yM(j, x)
  local r = editToggle or EditToggle
  if r ~= nil then
    pcall(r, j, x)
  end
end
local function WM(j)
  yM("ModFly", j == true)
end
local function CM()
  local j = GetLocal or getLocal
  if j == nil then
    return nil
  end
  local x, r = pcall(j)
  if x then
    return r
  end
  return nil
end
local function hM()
  local j = GetWorldName or getCurrentWorldName
  if j == nil then
    return ""
  end
  local x, r = pcall(j)
  if x and type(r) == "string" then
    return r:upper()
  end
  return ""
end
local function tM()
  local j = GetTiles or getTiles
  if j == nil then
    return {}
  end
  local x, r = pcall(j)
  if x and type(r) == "table" then
    return r
  end
  return {}
end
local function GM(j, x)
  local r = getTile or GetTile
  if r == nil then
    return nil
  end
  local A, d = pcall(r, j, x)
  if A then
    return d
  end
  return nil
end
local function kM()
  local j = CM()
  if j == nil then
    return nil, nil
  end
  return j["posX"] // 32, j["posY"] // 32
end
local function EM(j)
  return type(j) == "string" and (j ~= "" and j ~= "EXIT")
end
local function iM(j, x)
  if type(j) ~= "string" or type(x) ~= "string" then
    return false
  end
  return j:upper() == x:upper()
end
function parseHarvestWorlds(j)
  local x, r = {}, {}
  for j in (tostring(j or "")):gmatch("[^,%s;]+") do
    local A = j:match("^([^|]+)")
    if A and (A:match("^[%w_]+$") and #A <= 24) then
      local d = A:upper() .. j:sub(#A + 1)
      local X = A:upper()
      if not r[X] then
        r[X] = true
        x[#x + 1] = d
      end
    end
    if #x >= 30 then
      break
    end
  end
  return x
end
function worldNameFromEntry(j)
  return (((tostring(j or "")):match("^([^|]+)") or "")):upper()
end
function updateWorldDisplay()
  local j = (worldIndex > 0 and #worldQueue > 0)
      and (tostring(worldIndex) .. ("/" .. (tostring(#worldQueue) .. ("  " .. tostring(
        worldNameFromEntry(worldQueue[worldIndex])
      )))))
    or "CURRENT WORLD"
  pcall(function()
    safePHUIValue("PH_worldstatus", j)
  end)
end
local function TM()
  if QT == nil or QT == "" then
    return false
  end
  local j = CM()
  if j == nil then
    return false
  end
  local x = hM()
  if EM(x) then
    if iM(x, QT) then
      wT = true
      return true
    end
    wT = false
    return false
  end
  return wT == true
end
local function UM(j)
  local x = math["max"](0, math["floor"](tonumber(j) or 0))
  while w and x > 0 do
    if not TM() then
      return false
    end
    local j = math["min"](100, x)
    Sleep(j)
    x = x - j
  end
  return w and TM()
end
local function lM()
  return TM()
end
local function QM(j, x)
  local r = 0
  while w and r < j do
    local j = CM()
    local A = hM()
    if EM(A) and not iM(A, QT) then
      return false
    end
    local d = tM()
    if j ~= nil and (d ~= nil and next(d) ~= nil) then
      if x or iM(A, QT) or wT then
        return true
      end
    end
    Sleep(100)
    r = r + 100
  end
  return false
end
local function eM()
  local j = CM()
  if j == nil or not w then
    return false
  end
  local x = hM()
  if EM(x) and not iM(x, QT) then
    return false
  end
  local r = j["posX"] // 32
  local A = j["posY"] // 32
  WM(O)
  Sleep(250)
  for j = 1, 2, 1 do
    if not w then
      return false
    end
    pcall(function()
      FindPath(r, A)
    end)
    Sleep(dM)
  end
  local d = {
    { ["x"] = r + 1, ["y"] = A },
    { ["x"] = r - 1, ["y"] = A },
    { ["x"] = r, ["y"] = A - 1 },
    { ["x"] = r, ["y"] = A + 1 },
    { ["x"] = r + 2, ["y"] = A },
    { ["x"] = r - 2, ["y"] = A },
  }
  for j = 1, XM, 1 do
    if not w then
      return false
    end
    qM("RESUME PATH " .. (tostring(j) .. ("/" .. tostring(XM))))
    for j, x in ipairs(d) do
      local d = GM(x["x"], x["y"])
      if d ~= nil then
        local j = false
        pcall(function()
          FindPath(x["x"], x["y"])
        end)
        local d = 0
        while w and d < 1200 do
          local X = CM()
          local Y = hM()
          if EM(Y) and not iM(Y, QT) then
            return false
          end
          if X ~= nil then
            local d = X["posX"] // 32
            local Y = X["posY"] // 32
            if d == x["x"] and Y == x["y"] then
              j = true
              break
            end
            if d ~= r or Y ~= A then
              j = true
              break
            end
          end
          Sleep(100)
          d = d + 100
        end
        if j then
          Sleep(dM)
          pcall(function()
            FindPath(r, A)
          end)
          Sleep(dM)
          return true
        end
      end
    end
    pcall(function()
      FindPath(r, A)
    end)
    Sleep(YM)
  end
  return false
end
local function sM(j)
  if not RT and j ~= nil then
    nM(j)
  end
  RT = true
  gT = false
  wT = false
  WM(false)
  qM("PAUSED - WAIT WORLD")
end
local function RM()
  if not w then
    return false
  end
  if TM() then
    if RT or gT then
      WM(false)
      qM("RESUMING")
      Sleep(rM)
      if not w then
        return false
      end
      local j = hM()
      if EM(j) and not iM(j, QT) then
        wT = false
        return false
      end
      if not QM(AM, false) then
        qM("RESUMING")
        Sleep(100)
        return false
      end
      qM("RESUME MOVE")
      local x = eM()
      if not w then
        return false
      end
      j = hM()
      if EM(j) and not iM(j, QT) then
        wT = false
        return false
      end
      if not x then
        qM("RESUME PATH RETRY")
        Sleep(YM)
        return false
      end
      RT = false
      gT = false
      wT = true
      nM("Provider Harvester resumed automatically.")
    end
    return true
  end
  if RT and gT then
    WM(false)
    qM("RESUMING")
    Sleep(rM)
    if not w then
      return false
    end
    if QM(4000, true) then
      local j = hM()
      if EM(j) and not iM(j, QT) then
        wT = false
        qM("PAUSED - WAIT WORLD")
        return false
      end
      wT = true
      qM("RESUME MOVE")
      local x = eM()
      if not w then
        return false
      end
      j = hM()
      if EM(j) and not iM(j, QT) then
        wT = false
        qM("PAUSED - WAIT WORLD")
        return false
      end
      if not x then
        qM("RESUME PATH RETRY")
        Sleep(YM)
        return false
      end
      RT = false
      gT = false
      nM("Provider Harvester resumed automatically.")
      return true
    end
  end
  if not RT then
    nM("Provider Harvester paused - return to " .. tostring(QT))
  end
  RT = true
  wT = false
  WM(false)
  qM("PAUSED - WAIT WORLD")
  Sleep(200)
  return false
end
local function gM() end
local function wM() end
local function SM(j)
  local x = nil
  if type(findItemID) == "function" then
    local r, A = pcall(findItemID, j["name"])
    if r then
      x = tonumber(A)
    end
  end
  if (x == nil or x <= 0) and type(getItemInfoByName) == "function" then
    local r, A = pcall(getItemInfoByName, j["name"])
    if r and A ~= nil then
      x = tonumber(A["id"])
    end
  end
  if (x == nil or x <= 0) and (growtopia ~= nil and type(growtopia["getItemID"]) == "function") then
    local r, A = pcall(function()
      return growtopia["getItemID"](j["name"])
    end)
    if r then
      x = tonumber(A)
    end
  end
  if (x == nil or x <= 0) and j["fallbackID"] ~= nil then
    x = tonumber(j["fallbackID"])
  end
  if x ~= nil and x > 0 then
    return math["floor"](x)
  end
  return nil
end
local function LM()
  kT = {}
  iT = 0
  for j, x in ipairs(Q) do
    local r = SM(x)
    x["id"] = r
    if r ~= nil then
      kT[r] = x
      iT = iT + 1
    end
  end
end
local function mM(j)
  return j ~= nil and j["key"] == GT
end
local function fM()
  return ET[GT]
end
local function JM()
  local j = fM()
  local x = j ~= nil and j["name"] or "NONE"
  pcall(function()
    safePHUIValue("PH_selectedprovider", x)
  end)
end
local function cM()
  local j = fM()
  local x = j and j["name"] or "NONE"
  local r = {
    "set_default_color|`o",
    "add_label_with_icon|big|Provider Select|left|928|",
    "add_smalltext|Currently selected: " .. (x .. "|"),
    "add_smalltext|Choose one provider.|",
  }
  for j, x in ipairs(Q) do
    table["insert"](r, "add_button|PH_PICK_" .. (x["key"] .. ("|" .. (x["name"] .. "|noflags|0|0|"))))
  end
  table["insert"](r, "add_quick_exit|")
  table["insert"](r, "end_dialog|PH_provider_select|Cancel||")
  local A = table["concat"](r, "\n")
  local d = pcall(function()
    growtopia["sendDialog"](A)
  end)
  if not d then
    nM("Could not open Provider Select.")
  end
end
local function DM()
  local j = {}
  for x, r in pairs(tM()) do
    local A = tonumber(r["fg"]) or 0
    local d = kT[A]
    if d ~= nil and (mM(d) and r["readyharvest"] == true) then
      table["insert"](
        j,
        { ["x"] = tonumber(r["x"]) or 0, ["y"] = tonumber(r["y"]) or 0, ["fg"] = A, ["key"] = d["key"], ["name"] = d["name"] }
      )
    end
  end
  table["sort"](j, function(j, x)
    if j["y"] == x["y"] then
      return j["x"] < x["x"]
    end
    return j["y"] < x["y"]
  end)
  return j
end
local function OM(j)
  if j == nil or #j == 0 then
    return nil
  end
  local x = j[1]["y"]
  local r = {}
  for j, A in ipairs(j) do
    if A["y"] == x then
      table["insert"](r, A)
    else
      break
    end
  end
  if #r == 0 then
    return nil
  end
  local A = r[1]
  local d = -1
  local X = {}
  for j, x in ipairs(r) do
    X[x["x"]] = true
  end
  for j, x in ipairs(r) do
    local r = 0
    for j = -2, 2, 1 do
      if X[x["x"] + j] then
        r = r + 1
      end
    end
    if r > d or (r == d and x["x"] < A["x"]) then
      A = x
      d = r
    end
  end
  return {
    ["x"] = A["x"],
    ["y"] = A["y"],
    ["fg"] = A["fg"],
    ["key"] = A["key"],
    ["name"] = A["name"],
    ["rowCount"] = #r,
    ["coveredCount"] = d,
  }
end
local function oM(j, x)
  local r, A = kM()
  return r == j and A == x
end
local function HM(j, x)
  if oM(j, x) then
    return true
  end
  for r = 1, F, 1 do
    if not w then
      return false
    end
    if not TM() then
      RT = true
      wT = false
      return false
    end
    qM("PATH " .. (tostring(r) .. ("/" .. (tostring(F) .. (" -> " .. (tostring(j) .. ("," .. tostring(x))))))))
    pcall(function()
      FindPath(j, x)
    end)
    local A = 0
    while w and A < ST do
      if not TM() then
        RT = true
        wT = false
        return false
      end
      if oM(j, x) then
        Sleep(150)
        return true
      end
      Sleep(100)
      A = A + 100
    end
    if r < F then
      local j, x = kM()
      if j ~= nil and x ~= nil then
        pcall(function()
          FindPath(j, x)
        end)
      end
      Sleep(mT)
    end
  end
  return oM(j, x)
end
local function BM(j, x, r)
  local A = GM(j, x)
  if A == nil then
    return nil
  end
  if tonumber(A["fg"]) ~= tonumber(r) then
    return false
  end
  return A["readyharvest"] == true
end
local function FM(j)
  xT = tostring(j)
  pcall(function()
    safePHUIValue("PH_chemstatus", xT)
  end)
end
local function NM()
  pcall(function()
    safePHUIValue("PH_chemdropdisplay", P and (tostring(N) .. (", " .. tostring(z))) or "NOT SET")
  end)
end
local function zM()
  return persistProviderSettings()
end
local function PM()
  pcall(function()
    safePHUIValue("PH_autocollectdisplay", p and "ON" or "OFF")
  end)
end
local function IM(j)
  safePHUIValue(
    "PH_delay_save_status",
    j and "SAVED - REOPEN SAFE" or (phConfig == nil and "UNAVAILABLE" or "SAVE FAILED")
  )
end
local function VM()
  vT = {}
  qT = {}
end
local function pM(j)
  j = tonumber(j)
  if j == nil or j <= 0 or j == 112 then
    return nil
  end
  j = math["floor"](j)
  if qT[j] ~= nil then
    return qT[j]
  end
  local x = "Item #" .. tostring(j)
  local r = getItemInfo or getItemInfoByID or GetItemInfo
  if type(r) == "function" then
    local A, d = pcall(r, j)
    if A and (type(d) == "table" and (type(d["name"]) == "string" and d["name"] ~= "")) then
      x = d["name"]
    end
  end
  local A = { ["id"] = j, ["name"] = x }
  qT[j] = A
  vT[#vT + 1] = A
  return A
end
local function uM(j)
  if j == nil then
    return nil
  end
  local x = GetInventory or getInventory
  if x ~= nil then
    local r, A = pcall(x)
    if r and type(A) == "table" then
      for x, r in pairs(A) do
        if tonumber(r["id"]) == tonumber(j) then
          return tonumber(r["amount"]) or 0
        end
      end
      return 0
    end
  end
  if growtopia ~= nil and type(growtopia["checkInventoryCount"]) == "function" then
    local x, r = pcall(growtopia["checkInventoryCount"], j)
    if x then
      return tonumber(r)
    end
  end
  return nil
end
local function bM()
  for j, x in ipairs(vT) do
    local r = uM(x["id"])
    if r ~= nil and r >= I then
      return true
    end
  end
  return false
end
local function j4()
  local j = false
  for j, x in ipairs(vT) do
    local r = uM(x["id"])
    if r ~= nil and r >= I then
      YT[x["id"]] = true
    end
  end
  for x, r in pairs(YT) do
    if r then
      j = true
      break
    end
  end
  if j then
    XT = true
  end
  return j
end
local function x4()
  for j, x in ipairs(vT) do
    local r = uM(x["id"])
    if r ~= nil and r > 0 then
      return true
    end
  end
  return false
end
local function r4(j, x)
  if not P then
    return false
  end
  return x >= z - 1 and (x <= z + 1 and (j >= math["min"](N, b) - 1 and j <= math["max"](N, b) + 2))
end
local function A4()
  local j = GetObjectList or getObjectList
  if j == nil then
    return {}
  end
  local x, r = pcall(j)
  if x and type(r) == "table" then
    return r
  end
  return {}
end
local function d4(j)
  local x = tonumber(j["posX"])
  local r = tonumber(j["posY"])
  if j["pos"] ~= nil then
    x = x or tonumber(j["pos"]["x"])
    r = r or tonumber(j["pos"]["y"])
  end
  return x, r
end
local function X4(j)
  for x, r in pairs(A4()) do
    if tonumber(r["id"]) == tonumber(j) then
      return true
    end
  end
  return false
end
local function Y4(j)
  return tostring(j["x"]) .. (":" .. (tostring(j["y"]) .. (":" .. tostring(j["halfWidth"]))))
end
local function n4(j, x)
  if j == nil then
    return nil
  end
  local r = {
    ["x"] = math["floor"](tonumber(j["x"]) or 0),
    ["y"] = math["floor"](tonumber(j["y"]) or 0),
    ["halfWidth"] = (x == 0 and 0 or 2),
  }
  local A = Y4(r)
  if not ZT[A] then
    ZT[A] = true
    KT[#KT + 1] = r
  end
  if MT == nil then
    MT = r
  end
  return r
end
local function M4(j, x, r)
  return r ~= nil and (math["abs"](j - r["x"]) <= (r["halfWidth"] == 0 and 0 or 2) and math["abs"](x - r["y"]) <= 1)
end
local function K4()
  local j = GetObjectList or getObjectList
  if j == nil then
    return {}
  end
  local x, r = pcall(j)
  if x and type(r) == "table" then
    return r
  end
  return {}
end
local function Z4(j)
  local x = tonumber(j["posX"])
  local r = tonumber(j["posY"])
  if j["pos"] ~= nil then
    x = x or tonumber(j["pos"]["x"])
    r = r or tonumber(j["pos"]["y"])
  end
  return x, r
end
local function v4(j)
  for x, r in pairs(K4()) do
    if tonumber(r["id"]) == tonumber(j) then
      return true
    end
  end
  return false
end
local function q4(j, x)
  local r = {}
  local A = {}
  local d = nil
  local X = GetInventory or getInventory
  if X ~= nil then
    local j, x = pcall(X)
    if j and type(x) == "table" then
      d = {}
      for j, x in pairs(x) do
        local r = tonumber(x["id"])
        if r ~= nil then
          d[r] = tonumber(x["amount"]) or 0
        end
      end
    end
  end
  if x then
    A = KT
  elseif j ~= nil then
    A = { j }
  end
  if #A == 0 then
    return r
  end
  for j, x in pairs(K4()) do
    local X = tonumber(x["itemid"])
    local Y = tonumber(x["id"])
    if X ~= nil and (X > 0 and (X ~= 112 and Y ~= nil)) then
      local j, n = Z4(x)
      if j ~= nil and n ~= nil then
        local x, M = math["floor"](j / 32), math["floor"](n / 32)
        if not r4(x, M) then
          local K = nil
          for j, r in ipairs(A) do
            if M4(x, M, r) then
              K = r
              break
            end
          end
          if K ~= nil then
            local A = pM(X)
            if A ~= nil then
              local A = d ~= nil and (d[X] or 0) or uM(X)
              if A ~= nil and A < 200 then
                r[#r + 1] = {
                  ["uid"] = Y,
                  ["id"] = X,
                  ["x"] = j,
                  ["y"] = n,
                  ["tx"] = x,
                  ["ty"] = M,
                  ["distance"] = math["abs"](x - K["x"]) + math["abs"](M - K["y"]),
                }
              end
            end
          end
        end
      end
    end
  end
  table["sort"](r, function(j, x)
    if j["distance"] == x["distance"] then
      return j["uid"] < x["uid"]
    end
    return j["distance"] < x["distance"]
  end)
  return r
end
local function a4(j)
  local x = SendPacketRaw or sendPacketRaw
  if x == nil or j["uid"] == nil then
    return false
  end
  return pcall(function()
    x(false, { ["type"] = 11, ["value"] = j["uid"], ["x"] = j["x"], ["y"] = j["y"] })
  end)
end
local function y4(j, x, r)
  local A = 0
  while w and (TM() and A < r) do
    local r = uM(j)
    if r ~= nil and r > x then
      return true
    end
    Sleep(50)
    A = A + 50
  end
  return (uM(j) or -1) > x
end
local function W4(j, x)
  local r = x and 1100 or 2600
  local A = x and 550 or 1050
  local d = x and 50 or 75
  local X, Y = kM()
  if X == nil then
    return false
  end
  if math["abs"](X - j["tx"]) <= 1 and math["abs"](Y - j["ty"]) <= 1 then
    return true
  end
  local n = pcall(function()
    FindPath(j["tx"], j["ty"])
  end)
  if not n then
    return false
  end
  local M, K = 0, 0
  local Z, v = X, Y
  while w and (TM() and M < r) do
    X, Y = kM()
    if X == nil then
      return false
    end
    if math["abs"](X - j["tx"]) <= 1 and math["abs"](Y - j["ty"]) <= 1 then
      return true
    end
    if X ~= Z or Y ~= v then
      K = 0
      Z, v = X, Y
    else
      K = K + d
    end
    if K >= A then
      return false
    end
    Sleep(d)
    M = M + d
  end
  return false
end
local function C4(j)
  if not w or not TM() then
    return false
  end
  local x = uM(j["id"])
  if x == nil or x >= 200 then
    return false
  end
  if not v4(j["uid"]) then
    return true
  end
  local r, A = kM()
  if r == nil then
    return false
  end
  if math["abs"](r - j["tx"]) > 1 or math["abs"](A - j["ty"]) > 1 then
    qM("ITEM PICKUP PATH " .. (tostring(j["tx"]) .. ("," .. tostring(j["ty"]))))
    if not W4(j) then
      return false
    end
  end
  if not w or not TM() then
    return false
  end
  if (uM(j["id"]) or 0) > x then
    return true
  end
  if not v4(j["uid"]) then
    return y4(j["id"], x, 500)
  end
  for r = 1, 2, 1 do
    if not w or not TM() then
      return false
    end
    if not v4(j["uid"]) then
      return y4(j["id"], x, 450)
    end
    FM("PICKUP " .. (tostring(j["id"]) .. (" (" .. (r .. "/2)"))))
    if not a4(j) then
      return false
    end
    if y4(j["id"], x, aT) then
      nT = nT + 1
      return true
    end
    if r == 1 then
      UM(yT)
    end
  end
  FM("PICKUP LAG - WILL RESCAN")
  return false
end
local function h4(j)
  if j == nil then
    return true
  end
  FM(j["halfWidth"] == 0 and "FAST COLLECT CLEANUP HIT" or "FAST COLLECT 5-HIT")
  local x = q4(j, false)
  for j, x in ipairs(x) do
    if not w or not TM() then
      return false
    end
    local r, A = kM()
    if r ~= nil and (math["abs"](r - x["tx"]) > 1 or math["abs"](A - x["ty"]) > 1) then
      W4(x, true)
    end
    r, A = kM()
    if r ~= nil and (math["abs"](r - x["tx"]) <= 1 and math["abs"](A - x["ty"]) <= 1) then
      if a4(x) then
        nT = nT + 1
        if u > 0 then
          Sleep(u)
        end
      end
    end
  end
  return w and TM()
end
local function t4(j)
  if j == nil then
    return true
  end
  FM("FINAL CHECK BATCH " .. (tostring(j["x"]) .. ("," .. tostring(j["y"]))))
  for x = 1, 4, 1 do
    if not w or not TM() then
      return false
    end
    local r = q4(j, false)
    if #r == 0 then
      return true
    else
      for x, r in ipairs(r) do
        if not w or not TM() then
          return false
        end
        if j4() then
          MT = j
          return false
        end
        if v4(r["uid"]) and not C4(r) then
          FM("FINAL PICKUP LAG - RETRY LATER")
          MT = j
          return false
        end
      end
    end
  end
  return #q4(j, false) == 0
end
local function G4(j, x, r)
  if not p then
    return true
  end
  if not w or not TM() then
    return false
  end
  if x then
    FM("FINAL LEFTOVERS CLEANUP")
    for j, x in ipairs(KT) do
      if not t4(x) then
        MT = x
        return false
      end
    end
    MT = nil
    FM("VISITED BATCHES CLEARED")
    return true
  end
  local A = j ~= nil and n4(j, r) or MT
  if A == nil then
    return true
  end
  local d = h4(A)
  if d then
    MT = nil
  end
  return d
end
local function k4(j)
  yM("Anticollect", j)
  yM("AntiCollect", j)
  if j then
    yM("Enable AutoCollect", false)
    yM("Autocollect", false)
  end
end
local function E4()
  local j = CM()
  if j == nil then
    return false
  end
  if j["isLeft"] == false or j["isLeft"] == nil then
    return true
  end
  local x, r = kM()
  if x == nil or x <= 0 then
    return false
  end
  if not HM(x - 1, r) then
    return false
  end
  if not HM(x, r) then
    return false
  end
  j = CM()
  return j ~= nil and j["isLeft"] ~= true
end
local function i4(j, x)
  rT, AT = true, false
  SendPacket(2, "action|drop\nitemID|" .. tostring(j["id"]))
  local r = 0
  while w and (TM() and r < WT) do
    if AT then
      break
    end
    Sleep(50)
    r = r + 50
  end
  rT = false
  if not w or not TM() then
    return false
  end
  if not AT then
    return false
  end
  AT = false
  SendPacket(
    2,
    "action|dialog_return\n"
      .. ("dialog_name|drop_item\n" .. ("itemID|" .. (tostring(j["id"]) .. ("|\n" .. ("count|" .. tostring(x))))))
  )
  local A = 0
  while w and (TM() and A < CT) do
    local r = uM(j["id"])
    if r ~= nil and r < x then
      if V > A then
        UM(V - A)
      end
      return true
    end
    Sleep(50)
    A = A + 50
  end
  return (uM(j["id"]) or x) < x
end
local function T4(j)
  if not w or not TM() then
    return false
  end
  if not j4() then
    XT = false
    return true
  end
  XT = true
  if not P then
    FM("SET ITEM DROP POSITION FIRST")
    return false
  end
  dT = true
  k4(true)
  local x = true
  local r = 0
  for j, A in ipairs(vT) do
    if YT[A["id"]] then
      while w and TM() do
        local j = uM(A["id"])
        if j == nil then
          x = false
          break
        end
        if j <= 0 then
          YT[A["id"]] = nil
          break
        end
        FM("DROP " .. (A["name"] .. (" " .. tostring(j))))
        if not HM(b, jT) or not E4() then
          x = false
          break
        end
        local d = false
        for x = 1, 2, 1 do
          if not w or not TM() then
            break
          end
          local r = uM(A["id"])
          if r ~= nil and r < j then
            d = true
            break
          end
          qM("ITEM DROP " .. (A["name"] .. (" " .. (tostring(x) .. "/2"))))
          if i4(A, j) then
            d = true
            break
          end
          if x < 2 then
            UM(hT)
          end
        end
        if not w or not TM() then
          x = false
          break
        end
        if not d then
          UM(200)
          local x = uM(A["id"])
          if x ~= nil and x < j then
            d = true
          end
        end
        if not d then
          if r >= tT or b <= 1 then
            FM("ITEM DROP SPACE EXHAUSTED")
            x = false
            break
          end
          b = b - 1
          r = r + 1
          FM("DROP REJECTED -> LEFT " .. b)
          if not HM(b, jT) then
            x = false
            break
          end
          UM(250)
        end
      end
      if not x or not w or not TM() then
        break
      end
    end
  end
  if x and (w and TM()) then
    local j, r = kM()
    if lT and (j ~= TT or r ~= UT) then
      qM("BACK FROM ITEM DROP")
      if not HM(TT, UT) then
        x = false
      end
    end
  end
  k4(false)
  dT = false
  if x then
    local j = false
    for x, r in pairs(YT) do
      if r then
        j = true
        break
      end
    end
    XT = j
  end
  FM(x and "ITEM DROP DONE" or "ITEM DROP RETRY LATER")
  return x
end
local function U4(j)
  return tostring(j["x"]) .. (":" .. tostring(j["y"]))
end
local function l4()
  local j = 0
  for x in pairs(VT) do
    j = j + 1
  end
  pcall(function()
    safePHUIValue("PH_cleanupcount", tostring(j))
  end)
end
local function Q4()
  VT = {}
  pT = {}
  IT = 0
  uT = nil
  bT = nil
  jM = 0
  aM("NORMAL")
  l4()
end
local function e4(j)
  local x = {}
  local r = {}
  for j, A in ipairs(j) do
    local d = U4(A)
    x[d] = true
    if VT[d] == nil then
      table["insert"](r, A)
    end
  end
  local A = false
  for j in pairs(VT) do
    if not x[j] then
      VT[j] = nil
      pT[j] = nil
      A = true
    end
  end
  if A then
    l4()
  end
  if next(VT) == nil and uT == nil then
    aM("NORMAL")
  end
  return r
end
local function s4(j)
  if not w or not TM() then
    return false
  end
  safePHUIValue("PH_target", j["name"] .. (" @ " .. (tostring(j["x"]) .. (", " .. tostring(j["y"])))))
  local x = CM()
  if x == nil then
    return false
  end
  local r = sendPacketRaw or SendPacketRaw
  if r ~= nil then
    local A = pcall(function()
      r(false, { ["type"] = 3, ["value"] = 18, ["x"] = x["posX"], ["y"] = x["posY"], ["px"] = j["x"], ["py"] = j["y"] })
    end)
    if A then
      return true
    end
  end
  if growtopia ~= nil and type(growtopia["tileChange"]) == "function" then
    return pcall(function()
      growtopia["tileChange"](j["x"], j["y"], 18)
    end)
  end
  return false
end
local function R4(j, x)
  local r = 0
  local A = false
  for j, d in ipairs(j) do
    local X = tostring(d["x"]) .. (":" .. tostring(d["y"]))
    if not x[X] then
      local j = BM(d["x"], d["y"], d["fg"])
      if j == false then
        x[X] = true
        sT = sT + 1
        wM()
        A = true
      else
        r = r + 1
      end
    end
  end
  return r, A
end
local function g4(j, x)
  local r = 0
  local A = nil
  local d = false
  while w do
    if not TM() then
      RT = true
      wT = false
      return false, d, 0
    end
    local X, Y = R4(j, x)
    if Y then
      d = true
      A = r
    end
    if X == 0 then
      return true, d, 0
    end
    if d and (A ~= nil and r - A >= cT) then
      return true, d, X
    end
    if r >= DT then
      return true, d, X
    end
    Sleep(JT)
    r = r + JT
  end
  return false, d, 0
end
local function w4(j)
  local x, r = kM()
  if x == nil or r == nil then
    return false, false
  end
  local A = {}
  local d = {}
  local X = { -2, -1, 0, 1, 2 }
  for d, X in ipairs(X) do
    local Y, n = x + X, r
    local M = GM(Y, n)
    if M ~= nil then
      local x = tonumber(M["fg"]) or 0
      local r = kT[x]
      local d = tostring(Y) .. (":" .. tostring(n))
      if VT[d] == nil and (x == j["fg"] and (r ~= nil and (mM(r) and M["readyharvest"] == true))) then
        table["insert"](A, { ["x"] = Y, ["y"] = n, ["fg"] = x, ["key"] = r["key"], ["name"] = r["name"] })
      end
    end
  end
  if #A == 0 then
    qM("RESCAN ROW")
    return true, false
  end
  qM("FAST ROW " .. tostring(#A))
  local Y = {}
  for x, r in ipairs(A) do
    if not w then
      return false, false
    end
    if not TM() then
      RT = true
      wT = false
      return false, false
    end
    if BM(r["x"], r["y"], r["fg"]) == true then
      if not s4(r) then
        table["insert"](Y, r)
        uT = Y
        bT = { ["x"] = j["x"], ["y"] = j["y"] }
        jM = 0
        aM("SEND FAILED - RETRY")
        qM("PUNCH SEND FAILED - RETRY")
        return true, false
      end
      table["insert"](Y, r)
      if #Y < #A and B > 0 then
        Sleep(B)
      end
    end
  end
  if #Y == 0 then
    qM("RESCAN ROW")
    return true, false
  end
  qM("VERIFY FAST ROW")
  local n, M, K = g4(Y, d)
  if not n then
    return false, M
  end
  if not M then
    IT = IT + 1
    uT = Y
    bT = { ["x"] = j["x"], ["y"] = j["y"] }
    jM = 0
    aM("LAG - SINGLE HIT RETRY")
    qM("NO BATCH ACK - LAG SAFE")
    return true, false
  end
  IT = 0
  local Z, v = R4(Y, d)
  if v then
    M = true
  end
  local q = false
  for j, x in ipairs(Y) do
    local r = U4(x)
    if not d[r] then
      if BM(x["x"], x["y"], x["fg"]) ~= false then
        VT[r] = x
        q = true
      end
    end
  end
  if q then
    l4()
  end
  if K > 0 or q then
    qM("SKIP MISSES - CLEAN UP LATER")
  else
    qM("FAST ROW DONE")
  end
  return true, M
end
local function S4()
  if uT == nil then
    return true
  end
  if not w or not TM() then
    return false
  end
  local j = false
  local x = 0
  local r = {}
  local A = false
  for d, X in ipairs(uT) do
    local Y = BM(X["x"], X["y"], X["fg"])
    if Y == false then
      j = true
      x = x + 1
    elseif Y == true then
      table["insert"](r, X)
    else
      A = true
    end
  end
  if j then
    for j, x in ipairs(r) do
      VT[U4(x)] = x
    end
    if A then
      for j, x in ipairs(uT) do
        if BM(x["x"], x["y"], x["fg"]) == nil then
          VT[U4(x)] = x
        end
      end
    end
    sT = sT + x
    wM()
    l4()
    local j = bT or uT[1]
    uT = nil
    bT = nil
    jM = 0
    IT = 0
    if p and j ~= nil then
      G4(j, false)
    end
    aM("NORMAL")
    qM("SERVER RECOVERED - RESCAN")
    return true
  end
  local d = r[1]
  if d ~= nil then
    local j, x = kM()
    if j == nil or x == nil or x ~= d["y"] or math["abs"](j - d["x"]) > 2 then
      qM("LAG RECOVERY - PATH")
      if not HM(d["x"], d["y"]) then
        d = nil
      end
    end
  end
  if d ~= nil and (w and (TM() and BM(d["x"], d["y"], d["fg"]) == true)) then
    qM("LAG RECOVERY - ONE HIT")
    s4(d)
    local j = 0
    while w and j < HT do
      if not TM() then
        return false
      end
      if BM(d["x"], d["y"], d["fg"]) == false then
        break
      end
      local x = math["min"](JT, HT - j)
      Sleep(x)
      j = j + x
    end
  end
  for j, x in ipairs(uT) do
    if BM(x["x"], x["y"], x["fg"]) == false then
      return S4()
    end
  end
  jM = jM + 1
  local X = math["min"](jM - 1, 4)
  local Y = math["min"](BT * (2 ^ X), FT)
  aM("LAG - RETRY " .. tostring(jM))
  qM("SERVER LAG - RETRY IN " .. (tostring(Y) .. "ms"))
  local n = Y
  while w and (n > 0 and TM()) do
    for j, x in ipairs(uT or {}) do
      if BM(x["x"], x["y"], x["fg"]) == false then
        return true
      end
    end
    local j = math["min"](250, n)
    Sleep(j)
    n = n - j
  end
  return false
end
local function L4(j)
  pT[j] = (pT[j] or 0) + 1
  local x = math["min"](pT[j] - 1, 5)
  local r = math["min"](PT * (2 ^ x), zT)
  aM("CLEANUP RETRY " .. tostring(pT[j]))
  qM("CLEANUP LAG - WAIT " .. (tostring(r) .. "ms"))
  UM(r)
end
local function m4(j)
  local x = U4(j)
  if not w then
    return false, false
  end
  if not TM() then
    RT = true
    wT = false
    return false, false
  end
  if BM(j["x"], j["y"], j["fg"]) == false then
    VT[x] = nil
    pT[x] = nil
    l4()
    return true, true
  end
  qM("CLEANUP INDIVIDUAL " .. (tostring(j["x"]) .. ("," .. tostring(j["y"]))))
  if not HM(j["x"], j["y"]) then
    if not TM() then
      return false, false
    end
    L4(x)
    return true, false
  end
  if BM(j["x"], j["y"], j["fg"]) == false then
    VT[x] = nil
    pT[x] = nil
    l4()
    return true, true
  end
  if BM(j["x"], j["y"], j["fg"]) ~= true then
    L4(x)
    return true, false
  end
  if not s4(j) then
    L4(x)
    return true, false
  end
  local r = {}
  local A = 0
  while w and A <= NT do
    if not TM() then
      RT = true
      wT = false
      return false, false
    end
    local d, X = R4({ j }, r)
    if d == 0 then
      VT[x] = nil
      pT[x] = nil
      l4()
      return true, true
    end
    if A >= NT then
      break
    end
    Sleep(JT)
    A = A + JT
  end
  L4(x)
  return true, false
end
local function f4(j)
  w = false
  worldTransitionPending = false
  k4(false)
  dT = false
  rT = false
  WM(false)
  qM("STOPPED")
  safePHUIValue("PH_target", "NONE")
  local x = editToggle or EditToggle
  if x ~= nil then
    pcall(x, "PH_enable", false)
  end
  if j ~= nil and j ~= "" then
    nM(j)
  end
end
function resetForWorld()
  Q4()
  MT = nil
  KT = {}
  ZT = {}
  uT = nil
  bT = nil
  jM = 0
  IT = 0
  finalCleanupAttempts = 0
  finalDropFailures = 0
  YT = {}
  XT = false
  b, jT = N, z
  safePHUIValue("PH_target", "NONE")
  aM("NORMAL")
  FM(p and "READY" or "AUTO COLLECT OFF")
end
function selectWorldInQueue(j)
  if j < 1 or j > #worldQueue then
    return false
  end
  worldIndex = j
  QT = worldNameFromEntry(worldQueue[j])
  worldTransitionPending = true
  worldTransitionAttempts = 0
  worldTransitionElapsed = 0
  RT = false
  gT = false
  wT = false
  lT = false
  resetForWorld()
  WM(false)
  updateWorldDisplay()
  qM("GO TO WORLD " .. (tostring(j) .. ("/" .. (tostring(#worldQueue) .. (" " .. tostring(QT))))))
  return true
end
function requestWorldJoin(j)
  local x = false
  if type(Warp) == "function" then
    x = pcall(Warp, j)
  elseif type(JoinWorld) == "function" then
    x = pcall(JoinWorld, j)
  else
    local r = SendPacket or sendPacket
    if type(r) == "function" then
      x = pcall(r, 3, "action|join_request\nname|" .. tostring(j))
    end
  end
  return x
end
function processWorldTransition()
  if not w or not worldTransitionPending then
    return
  end
  local j = worldQueue[worldIndex]
  if j == nil then
    f4("World list unavailable.")
    return
  end
  if iM(hM(), QT) and (CM() ~= nil and next(tM()) ~= nil) then
    Sleep(250)
    if not w then
      return
    end
    if iM(hM(), QT) and next(tM()) ~= nil then
      wT = true
      worldTransitionPending = false
      RT = false
      gT = false
      TT, UT = kM()
      lT = TT ~= nil
      WM(O)
      qM("SCANNING " .. tostring(QT))
      updateWorldDisplay()
      return
    end
  end
  if worldTransitionAttempts == 0 or worldTransitionElapsed >= 8000 then
    if worldTransitionAttempts >= 3 then
      f4("Could not enter world " .. (tostring(QT) .. ". Stopped instead of skipping it."))
      return
    end
    worldTransitionAttempts = worldTransitionAttempts + 1
    worldTransitionElapsed = 0
    qM("JOIN " .. (tostring(QT) .. (" (" .. (tostring(worldTransitionAttempts) .. "/3)"))))
    if not requestWorldJoin(j) then
      f4("Growlauncher world join unavailable; " .. tostring(j))
      return
    end
  end
  Sleep(250)
  worldTransitionElapsed = worldTransitionElapsed + 250
end
function finishCurrentWorld(j)
  if not w or not TM() then
    return
  end
  local x = tostring(QT)
  if H and (lT and not oM(TT, UT)) then
    qM("RETURN TO START (OPTIONAL)")
    pcall(function()
      FindPath(TT, UT)
    end)
    local j = 0
    while w and (TM() and (not oM(TT, UT) and j < 1500)) do
      Sleep(100)
      j = j + 100
    end
    if not oM(TT, UT) then
      nM("Return path blocked in " .. (x .. "; continuing."))
    end
  end
  if not w or not TM() then
    return
  end
  if j then
    nM("Uncollected provider drops remain in " .. (x .. ". They were not deleted. Moving on after limited retries."))
  end
  if worldIndex < #worldQueue then
    nM("Provider world complete: " .. (x .. ". Next world."))
    selectWorldInQueue(worldIndex + 1)
  else
    f4("All " .. (tostring(#worldQueue) .. " provider world(s) completed."))
  end
end
local function J4()
  local j, x = kM()
  if j == nil or x == nil then
    nM("Player position is not available.")
    return
  end
  TT = j
  UT = x
  lT = true
  gM()
  nM("Start Position = (" .. (tostring(TT) .. (", " .. (tostring(UT) .. ")"))))
end
function onVariant(j, x)
  if
    w and (
      rT and (
        j ~= nil and (
          j["v1"] == "OnDialogRequest" and (type(j["v2"]) == "string" and j["v2"]:find("drop_item", 1, true))
        )
      )
    )
  then
    AT = true
    return true
  end
  if j ~= nil then
    if w and (j["v1"] == "OnSpawn" and type(j["v2"]) == "string") then
      local x = j["v2"]:find("type|local", 1, true) ~= nil
      if not x then
        local r = tonumber(j["v2"]:match("netID|(%d+)"))
        local A = CM()
        if r ~= nil and A ~= nil then
          x = tonumber(A["netID"]) == r
        end
      end
      if x and (RT or not wT) then
        gT = true
        RT = true
      end
    end
    if w and (RT and j["v1"] == "OnSetPos") then
      gT = true
    end
  end
  return false
end
function onSendPacketRaw(j)
  if w and ((p or dT) and (j ~= nil and (tonumber(j["type"]) == 11 and P))) then
    local x, r = tonumber(j["x"]), tonumber(j["y"])
    if x ~= nil and (r ~= nil and r4(math["floor"](x / 32), math["floor"](r / 32))) then
      return true
    end
    if dT then
      local j, x = kM()
      if j ~= nil and r4(j, x) then
        return true
      end
    end
  end
  return false
end
function onSendPacket(j, x)
  if type(x) == "string" then
    if x:find("action|dialog_return", 1, true) and x:find("dialog_name|PH_provider_select", 1, true) then
      local j = x:match("buttonClicked|([^\n|]+)")
      if j ~= nil and j:sub(1, 8) == "PH_PICK_" then
        local x = j:sub(9)
        local r = ET[x]
        if r ~= nil then
          if w then
            nM("Stop harvesting before changing provider.")
            return true
          end
          GT = x
          Q4()
          JM()
          persistProviderSettings()
          nM("Provider = " .. r["name"])
          if w then
            LM()
          end
        end
      end
      return true
    end
    if w then
      local j = x:find("action|quit", 1, true) ~= nil
      local r = x:find("action|join_request", 1, true) ~= nil
      if j or r then
        RT = true
        gT = false
        wT = false
        WM(false)
        qM("PAUSED - WAIT WORLD")
      end
    end
  end
  return false
end
function onGamePacket(j)
  if j ~= nil and (tonumber(j["type"]) == 26 and w) then
    if not RT then
      nM("Provider Harvester paused - disconnected.")
    end
    RT = true
    gT = false
    wT = false
    WM(false)
    qM("PAUSED - WAIT WORLD")
  end
  return false
end
local function c4()
  w = true
  local j = CM()
  local x = hM()
  if j == nil or x == "" or x == "EXIT" then
    f4("Enter a world first.")
    return
  end
  LM()
  VM()
  MT = nil
  KT = {}
  ZT = {}
  if p and not P then
    f4("Set Item Drop Position in Settings before starting Auto Collect.")
    return
  end
  if p and (N < 1 or z < 0) then
    f4("Invalid Item Drop Position; use Settings > Current Tile.")
    return
  end
  b, jT = N, z
  nT = 0
  dT = false
  XT = false
  YT = {}
  rT, AT = false, false
  FM(p and "READY" or "AUTO COLLECT OFF")
  local r = fM()
  if r == nil then
    f4("Select a provider first.")
    return
  end
  if r["id"] == nil then
    f4("Could not resolve selected provider: " .. r["name"])
    return
  end
  worldQueue = parseHarvestWorlds(harvestWorldText)
  if #worldQueue == 0 then
    worldQueue = { x }
    qM("CURRENT WORLD ONLY: " .. tostring(x))
  end
  sT = 0
  wM()
  selectWorldInQueue(1)
  nM(
    "Provider Harvester started: "
      .. (tostring(#worldQueue) .. (" world(s), selected provider " .. (tostring(r["name"]) .. ".")))
  )
end
local D4 = false
local function O4(j)
  if D4 then
    return
  end
  D4 = true
  pcall(function()
    safePHUIValue("PH_worlds", tostring(j or ""))
  end)
  D4 = false
end
function onValue(j, x, r)
  if PHUIWriteInProgress[x] then
    return
  end
  if x == "PH_worlds" and D4 then
    return
  end
  if x == "PH_worlds" or x == "PH_addworld" or x == "PH_removeworld" or x == "PH_clearworlds" then
    if w or J then
      if x == "PH_worlds" and tostring(r or "") ~= harvestWorldText then
        O4(harvestWorldText)
      end
      nM("Stop the provider script before changing harvest worlds.")
      return
    end
    local j = harvestWorldText
    if x == "PH_worlds" then
      j = tostring(r or "")
    elseif x == "PH_clearworlds" then
      j = ""
    elseif x == "PH_addworld" then
      local x = hM()
      if not EM(x) then
        nM("Enter a world first.")
        return
      end
      local r = parseHarvestWorlds(harvestWorldText)
      local A = false
      for j, r in ipairs(r) do
        if worldNameFromEntry(r) == x then
          A = true
        end
      end
      if not A then
        r[#r + 1] = x
      end
      j = table["concat"](r, ",")
    else
      local x = parseHarvestWorlds(harvestWorldText)
      if #x > 0 then
        table["remove"](x)
      end
      j = table["concat"](x, ",")
    end
    if j ~= harvestWorldText then
      harvestWorldText = j
      persistProviderSettings()
    end
    if x ~= "PH_worlds" then
      O4(harvestWorldText)
    end
    return
  end
  if x == "PH_returnstart" then
    H = (r == true or r == 1 or r == "true" or r == "1")
    persistProviderSettings()
    return
  end
  if x == "PH_licensekey" then
    local j = Y(r)
    if J and j ~= Y(S) then
      c = c + 1
      J = false
      local j = editToggle or EditToggle
      if j ~= nil then
        pcall(j, "PH_enable", false)
      end
      qM("STOPPED - LICENSE CHANGED")
    end
    S = j
    L = false
    MM("NOT VERIFIED")
    persistProviderSettings()
    return
  end
  if x == "PH_verifylicense" then
    runThread(function()
      vM(false)
    end)
    return
  end
  if x == "PH_clearlicense" then
    if J then
      c = c + 1
      J = false
      local j = editToggle or EditToggle
      if j ~= nil then
        pcall(j, "PH_enable", false)
      end
      qM("STOPPED - LICENSE CLEARED")
    end
    L = false
    S = ""
    X = ""
    Z()
    persistProviderSettings()
    pcall(function()
      safePHUIValue("PH_licensekey", "")
    end)
    MM("NOT VERIFIED")
    nM("Saved Provider license cleared.")
    return
  end
  if x == "PH_enable" then
    if r == true then
      if w or J then
        return
      end
      c = c + 1
      local j = c
      local x = Y(S)
      J = true
      L = false
      w = false
      WM(false)
      k4(false)
      qM("CHECKING LICENSE BEFORE START")
      runThread(function()
        local r = 0
        while m and (J and (c == j and r < 30000)) do
          Sleep(100)
          r = r + 100
        end
        if not J or c ~= j then
          return
        end
        local A = false
        if not m then
          A = vM(true)
        else
          MM("VERIFY BUSY - RETRY START")
        end
        if not J or c ~= j then
          return
        end
        if Y(S) ~= x then
          A = false
          L = false
          MM("KEY CHANGED - RETRY START")
        end
        J = false
        if not A then
          w = false
          local j = editToggle or EditToggle
          if j ~= nil then
            pcall(j, "PH_enable", false)
          end
          WM(false)
          k4(false)
          qM("LICENSE NOT VALID - NOT STARTED")
          nM("Provider license not approved by server. Start blocked (" .. (tostring(f) .. ")."))
          return
        end
        c4()
      end)
    else
      c = c + 1
      J = false
      w = false
      worldTransitionPending = false
      k4(false)
      dT = false
      rT = false
      WM(false)
      RT = false
      gT = false
      wT = false
      qM("STOPPED")
      safePHUIValue("PH_target", "NONE")
      nM("Provider Harvester stopped safely.")
    end
    return
  end
  if x == "PH_open_provider" then
    JM()
    cM()
    return
  end
  if x == "PH_autocollect" then
    local j = r == true or r == 1 or r == "true" or r == "1"
    if dT then
      nM("Please wait for the current item drop to finish.")
      pcall(function()
        safePHUIValue("PH_autocollect", p)
      end)
      return
    end
    if j and (w and (not P or N < 1)) then
      nM("Set a valid Drop Position before enabling Auto Collect.")
      pcall(function()
        safePHUIValue("PH_autocollect", false)
      end)
      return
    end
    p = j
    if not j then
      MT = nil
      YT = {}
      XT = false
      FM("AUTO COLLECT OFF")
    else
      FM("AUTO COLLECT ON")
    end
    local x = zM()
    PM()
    IM(x)
    return
  end
  if x == "PH_autocollectdisplay" then
    PM()
    return
  end
  if x == "PH_selectedprovider" then
    local j = fM()
    local x = j ~= nil and j["name"] or "NONE"
    if tostring(r or "") ~= x then
      pcall(function()
        safePHUIValue("PH_selectedprovider", x)
      end)
    end
    return
  end
  if x == "PH_recovery" then
    if tostring(r or "") ~= xM then
      pcall(function()
        safePHUIValue("PH_recovery", xM)
      end)
    end
    return
  end
  if x == "PH_setchemdrop" then
    if dT then
      nM("Please wait until the current item drop finishes.")
      return
    end
    local j, x = kM()
    if j ~= nil and x ~= nil then
      N, z = j, x
      b, jT = j, x
      P = true
      safePHUIValue("PH_chemdropx", tostring(j))
      safePHUIValue("PH_chemdropy", tostring(x))
      NM()
      zM()
      nM("Item drop stand tile set; drop target is one tile RIGHT.")
    else
      nM("Enter a world before setting item drop position.")
    end
    return
  end
  if x == "PH_chemdropx" or x == "PH_chemdropy" then
    if dT then
      nM("Please wait until the current item drop finishes.")
      pcall(function()
        safePHUIValue(x, tostring(x == "PH_chemdropx" and N or z))
      end)
      return
    end
    local j = tonumber(r)
    if j ~= nil then
      j = math["floor"](j)
      if j >= 0 and j <= 999 then
        if x == "PH_chemdropx" then
          N = j
        else
          z = j
        end
        b, jT = N, z
        P = true
        NM()
        zM()
      end
    else
      pcall(function()
        safePHUIValue(x, tostring(x == "PH_chemdropx" and N or z))
      end)
    end
    return
  end
  if x == "PH_chemthreshold" then
    local j = tonumber(r)
    if j ~= nil then
      I = math["max"](1, math["min"](200, math["floor"](j)))
      safePHUIValue("PH_chemthreshold", tostring(I))
      zM()
    end
    return
  end
  if x == "PH_chemdropdelay" then
    local j = tonumber(r)
    if j ~= nil then
      V = math["max"](0, math["min"](5000, math["floor"](j)))
      safePHUIValue("PH_chemdropdelay", tostring(V))
      zM()
    end
    return
  end
  if x == "PH_chemdropdisplay" then
    local j = P and (tostring(N) .. (", " .. tostring(z))) or "NOT SET"
    if tostring(r or "") ~= j then
      NM()
    end
    return
  end
  if x == "PH_chemstatus" then
    if tostring(r or "") ~= xT then
      pcall(function()
        safePHUIValue("PH_chemstatus", xT)
      end)
    end
    return
  end
  if x == "PH_fastcollectgap" then
    local j = tonumber(r)
    if j ~= nil then
      u = math["max"](30, math["min"](500, math["floor"](j)))
      safePHUIValue("PH_fastcollectgap", tostring(u))
      IM(zM())
    end
    return
  end
  if x == "PH_delay" then
    local j = tonumber(r)
    if j ~= nil then
      j = math["floor"](j)
      if j < 0 then
        j = 0
      end
      if j > 5000 then
        j = 5000
      end
      B = j
      safePHUIValue("PH_delay", tostring(B))
      IM(persistProviderSettings())
    end
    return
  end
end
applyHook()
LM()
runThread(function()
  WM(false)
  qM("STOPPED")
  gM()
  wM()
  JM()
  l4()
  updateWorldDisplay()
  NM()
  FM(p and "IDLE" or "AUTO COLLECT OFF")
  PM()
  VM()
  if S ~= "" then
    pcall(function()
      safePHUIValue("PH_licensekey", S)
    end)
    MM("SAVED - CHECK ON START")
  else
    MM("NOT VERIFIED")
  end
  while true do
    if not w then
      Sleep(200)
    else
      if worldTransitionPending then
        processWorldTransition()
      elseif not RM() then
        Sleep(200)
      else
        WM(O)
        qM("SCANNING")
        if p and (XT or bM()) then
          if not T4(XT) then
            UM(650)
          end
        elseif p and MT ~= nil then
          if not G4(nil, false) then
            UM(500)
          end
        elseif uT ~= nil then
          S4()
        else
          local j = DM()
          local x = e4(j)
          if #j > 0 then
            finalCleanupAttempts = 0
            finalDropFailures = 0
          end
          if #j == 0 then
            if next(tM()) == nil then
              qM("WAIT WORLD TILES")
              UM(300)
            else
              qM("VERIFY NO READY PROVIDERS")
              UM(220)
              if w and TM() then
                local j = DM()
                if #j > 0 then
                  qM("PROVIDERS FOUND - CONTINUE")
                elseif next(tM()) == nil then
                  qM("WAIT WORLD TILES")
                else
                  if not p then
                    qM("PROVIDERS FINISHED - NO COLLECT")
                    finishCurrentWorld(false)
                  else
                    local j, x = true, {}
                    if p and #KT > 0 then
                      j = G4(nil, true)
                      x = q4(nil, true)
                    end
                    if not j or #x > 0 then
                      finalCleanupAttempts = finalCleanupAttempts + 1
                      if finalCleanupAttempts < 2 then
                        qM("FINAL PICKUP RETRY 1/2")
                        UM(250)
                      else
                        if p and (XT or bM()) then
                          if T4(true) then
                            finishCurrentWorld(true)
                          else
                            f4("Final item drop failed in " .. (tostring(QT) .. ". Items are in backpack."))
                          end
                        else
                          finishCurrentWorld(true)
                        end
                      end
                    elseif p and (XT or bM()) then
                      if T4(true) then
                        finishCurrentWorld(false)
                      else
                        finalDropFailures = finalDropFailures + 1
                        if finalDropFailures >= 2 then
                          f4("Final item drop unconfirmed in " .. (tostring(QT) .. ". Check backpack."))
                        else
                          qM("FINAL ITEM DROP RETRY")
                          UM(300)
                        end
                      end
                    else
                      finishCurrentWorld(false)
                    end
                  end
                end
              end
            end
          elseif #x > 0 then
            local j = OM(x)
            if j == nil then
              qM("ROW TARGET MISSING - RESCAN")
              UM(500)
            else
              safePHUIValue(
                "PH_target",
                j["name"] .. (
                    " FAST ROW " .. (tostring(j["y"]) .. (" @ " .. (tostring(j["x"]) .. (", " .. tostring(j["y"])))))
                  )
              )
              if HM(j["x"], j["y"]) then
                local x, r = w4(j)
                if not x then
                  if not TM() then
                    RT = true
                    WM(false)
                    qM("PAUSED - WAIT WORLD")
                  else
                    aM("BATCH ERROR - RETRY")
                    qM("BATCH ERROR - RETRY")
                    UM(1500)
                  end
                elseif x then
                  if p then
                    G4(j, false)
                  end
                  Sleep(r and 25 or 100)
                else
                  Sleep(100)
                end
              else
                if not TM() then
                  RT = true
                  WM(false)
                  qM("PAUSED - WAIT WORLD")
                else
                  qM("PATH RETRY - RESCAN")
                  Sleep(700)
                end
              end
            end
          else
            local x = nil
            local r = math["huge"]
            for j, A in ipairs(j) do
              local d = U4(A)
              local X = pT[d] or 0
              if VT[d] ~= nil and X < r then
                x = A
                r = X
              end
            end
            if x == nil then
              qM("CLEANUP LIST CHANGED - RESCAN")
              UM(650)
            else
              local j, r = m4(x)
              if not j then
                if not TM() then
                  RT = true
                  WM(false)
                  qM("PAUSED - WAIT WORLD")
                else
                  aM("CLEANUP ERROR - RETRY")
                  qM("CLEANUP ERROR - RETRY")
                  UM(1500)
                end
              elseif r then
                if p then
                  G4(x, false, 0)
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
