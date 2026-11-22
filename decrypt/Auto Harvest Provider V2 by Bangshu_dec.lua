setMinimum("6.1.2")
PHUIWriteInProgress = {}
function safePHUIValue(H, L)
  if PHUIWriteInProgress[H] then
    return true
  end
  PHUIWriteInProgress[H] = true
  local G = pcall(function()
    editValue(H, L)
  end)
  PHUIWriteInProgress[H] = nil
  return G
end
local H =
  "https://script.google.com/macros/s/AKfycbxeBzpOUzvcRDkX-4eR8uioFbAUDsepIQc26kmxUkXt6YOjBxFdVsOE0zzvxYSprl5knA/exec"
local L = "PROVIDER"
local G = "ProviderHarvesterLicense"
local O = "license_key"
local M = nil
local R = ""
local function o(H)
  H = tostring(H or "")
  H = H:gsub("%s+", "")
  return H:upper()
end
local function g(H)
  H = o(H)
  return H:match("^[A-Z]%d%d%d%d%d%d%d$") ~= nil
end
local function c()
  local H = pcall(function()
    local H = nil
    if type(require) == "function" then
      local L, G = pcall(require, "preferences")
      if L and G ~= nil then
        H = G
      end
    end
    if H == nil and type(Preferences) == "table" then
      H = Preferences
    end
    if H == nil then
      return
    end
    if type(H["new"]) == "function" then
      local L = H:new(G)
      M = L or H
    else
      M = H
    end
    if M ~= nil and type(M["load"]) == "function" then
      M:load()
    end
    if M ~= nil and type(M["get"]) == "function" then
      R = o(M:get(O, ""))
    end
  end)
  if not H then
    M = nil
    R = ""
  end
end
local function y(H)
  if M == nil then
    return false
  end
  local L = pcall(function()
    M:set(O, o(H))
    M:save()
  end)
  return L
end
local function P()
  if M == nil then
    return false
  end
  local H = pcall(function()
    M:set(O, "")
    M:save()
  end)
  return H
end
c()
local v = "ProviderHarvesterPunchDelayV21"
local w = "punch_delay_ms"
local x = nil
local E = 190
local function l()
  local H = nil
  if type(require) == "function" then
    local L, G = pcall(require, "preferences")
    if L and G ~= nil then
      H = G
    end
  end
  if H == nil and type(Preferences) == "table" then
    H = Preferences
  end
  if H == nil or type(H["new"]) ~= "function" then
    return
  end
  local L, G = pcall(function()
    return H:new(v)
  end)
  if not L or G == nil then
    return
  end
  x = G
  pcall(function()
    x:load()
  end)
  local O, M = pcall(function()
    return x:get(w, 190)
  end)
  if O and tonumber(M) ~= nil then
    local H = math["floor"](tonumber(M))
    E = math["max"](0, math["min"](5000, H))
  end
end
local function q(H)
  if x == nil then
    return false
  end
  local L = pcall(function()
    local L = x:set(w, H)
    if L == false then
      error("Preferences:set failed")
    end
    local G = x:save()
    if G == false then
      error("Preferences:save failed")
    end
  end)
  return L
end
l()
local Z, W = 0, 0
local i = false
local s = 190
local N = 250
local V = true
local j = 70
local function D()
  if x == nil then
    return
  end
  local H = pcall(function()
    Z = math["floor"](tonumber(x:get("chem_drop_x", 0)) or 0)
    W = math["floor"](tonumber(x:get("chem_drop_y", 0)) or 0)
    i = x:get("chem_drop_configured", false) == true
    s = math["max"](1, math["min"](200, math["floor"](tonumber(x:get("chem_threshold", 190)) or 190)))
    N = math["max"](0, math["min"](5000, math["floor"](tonumber(x:get("chem_drop_delay", 250)) or 250)))
    j = math["max"](30, math["min"](500, math["floor"](tonumber(x:get("fast_collect_gap_ms", 70)) or 70)))
    local H = x:get("auto_collect_enabled", true)
    V = not (H == false or H == 0 or H == "false" or H == "0")
  end)
  if not H then
    Z, W = 0, 0
    i = false
    s, N = 190, 250
    j = 70
    V = true
  end
end
D()
savedHarvestWorlds = ""
savedReturnToStart = false
if x ~= nil then
  pcall(function()
    savedHarvestWorlds = tostring(x:get("harvest_world_list", "") or "")
    local H = x:get("return_to_start", false)
    savedReturnToStart = (H == true or H == "true" or H == 1 or H == "1")
  end)
end
function saveWorldSettings(H, L)
  if x == nil then
    return false
  end
  return pcall(function()
    x:set("harvest_world_list", tostring(H or ""))
    x:set("return_to_start", L == true)
    x:save()
  end)
end
local function k(H, L, G, O, M, R, o)
  if x == nil then
    return false
  end
  return pcall(function()
    x:set("chem_drop_x", H)
    x:set("chem_drop_y", L)
    x:set("chem_drop_configured", G)
    x:set("chem_threshold", O)
    x:set("chem_drop_delay", M)
    x:set("fast_collect_gap_ms", o)
    x:set("auto_collect_enabled", R == true)
    x:save()
  end)
end
PH_CONFIG_FILE = "ProviderHarvesterAllSettingsV6.json"
phConfig = nil
phPreferenceModule = nil
phConfigRestored = false
function loadPersistentProviderSettings()
  if type(require) == "function" then
    local H, L = pcall(require, "preferences")
    if H and L ~= nil then
      phPreferenceModule = L
    end
  end
  if phPreferenceModule == nil and type(Preferences) == "table" then
    phPreferenceModule = Preferences
  end
  if phPreferenceModule == nil or type(phPreferenceModule["new"]) ~= "function" then
    return
  end
  local H, L = pcall(function()
    return phPreferenceModule:new(PH_CONFIG_FILE)
  end)
  if not H or L == nil then
    return
  end
  if
    type(L["load"]) ~= "function"
    or type(L["get"]) ~= "function"
    or type(L["set"]) ~= "function"
    or type(L["save"]) ~= "function"
  then
    return
  end
  if not pcall(function()
    L:load()
  end) then
    return
  end
  phConfig = L
  local G, O = pcall(function()
    return L:get("schema", "")
  end)
  if not G or tostring(O) ~= "6" then
    return
  end
  local M = pcall(function()
    savedHarvestWorlds = tostring(L:get("worlds", savedHarvestWorlds) or "")
    local function H(H, G, O, M)
      local R = tonumber(L:get(H, G)) or G
      return math["max"](O, math["min"](M, math["floor"](R)))
    end
    local function G(H, G)
      local O = L:get(H, G and "true" or "false")
      return O == true or O == "true" or O == "1" or O == 1
    end
    savedReturnToStart = G("return_start", savedReturnToStart)
    V = G("auto_collect", V)
    E = H("punch_delay", E, 0, 5000)
    j = H("collect_delay", j, 30, 500)
    s = H("drop_threshold", s, 1, 200)
    N = H("drop_delay", N, 0, 5000)
    Z = H("drop_x", Z, 0, 999)
    W = H("drop_y", W, 0, 999)
    i = G("drop_configured", i)
    R = o(L:get("license_key", R))
  end)
  phConfigRestored = M
end
loadPersistentProviderSettings()
function saveProviderSettingsSnapshot(H)
  if phConfig == nil or phPreferenceModule == nil then
    return false
  end
  local L = pcall(function()
    phConfig:set("schema", "6")
    for H, L in pairs(H) do
      phConfig:set(H, tostring(L))
    end
    if phConfig:save() == false then
      error("Preferences save rejected")
    end
  end)
  if not L then
    return false
  end
  local G, O = pcall(function()
    local L = phPreferenceModule:new(PH_CONFIG_FILE)
    if not L then
      return false
    end
    L:load()
    if tostring(L:get("schema", "")) ~= "6" then
      return false
    end
    for H, G in pairs(H) do
      if tostring(L:get(H, "")) ~= tostring(G) then
        return false
      end
    end
    return true
  end)
  return G and O == true
end
local t = {
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
local J = "Auto Harvest Provider V2"
local h = UserInterface["new"](J, "Agriculture")
h:addLabelApp(J, "Agriculture")
h:addInputString("License Key", R, "A1234567", "A1234567", nil, "PH_licensekey")
h:addButton("Verify License", "PH_verifylicense")
h:addButton("Clear Saved License", "PH_clearlicense")
h:addDisplayList("License Status", "NOT VERIFIED", "PH_licensestatus")
h:addToggle("Start / Stop", false, "PH_enable")
local z = h:addDialog("Settings", "Auto Collect, harvesting, multi-world and drop settings", {})
h:addChildInputString(
  z["menu"],
  "Harvest Worlds (blank = current world)",
  savedHarvestWorlds,
  "WORLD1,WORLD2 (leave empty for current)",
  "Worlds",
  "Agriculture",
  "PH_worlds"
)
h:addChildTooltip(
  z["menu"],
  "Empty Harvest Worlds",
  "When no worlds are entered, harvest ONLY the world you are standing in when you press Start. This also works if the saved value is empty or contains spaces.",
  "Agriculture",
  false
)
h:addChildButton(z["menu"], "Clear Worlds / Use Current World", "PH_clearworlds")
h:addChildButton(z["menu"], "Add Current World", "PH_addworld")
h:addChildButton(z["menu"], "Remove Last World", "PH_removeworld")
h:addChildToggle(
  z["menu"],
  "Return to Start After Each World (slower)",
  savedReturnToStart,
  "PH_returnstart",
  false,
  true
)
h:addChildToggle(z["menu"], "Auto Collect + Auto Drop", V, "PH_autocollect", false, true)
h:addChildTooltip(
  z["menu"],
  "Auto Collect OFF = immediate finish",
  "When OFF, there are NO floating-item scans, collection attempts or drops. After two valid provider scans show no ready stations, finish the current world immediately and continue to the next configured world (or stop).",
  "Agriculture",
  false
)
h:addChildTooltip(
  z["menu"],
  "Fast Batch Collection",
  "One paced pickup pass after each 5x5 harvest batch. Missed floating items are checked at the end.",
  "Agriculture",
  true
)
h:addChildInputInt(z["menu"], "Fast Collect Delay", tostring(j), "ms", "70", "Agriculture", "PH_fastcollectgap")
h:addChildInputInt(z["menu"], "Punch Delay", tostring(E), "ms", "190", "Agriculture", "PH_delay")
h:addChildTooltip(
  z["menu"],
  "Threshold-only Drop",
  "Only item types reaching the threshold are dropped. Partial stacks remain in your backpack, including at final cleanup.",
  "Agriculture",
  true
)
h:addChildInputInt(z["menu"], "Drop at Inventory Count", tostring(s), "items", "190", "Agriculture", "PH_chemthreshold")
h:addChildInputInt(z["menu"], "Item Drop Delay", tostring(N), "ms", "250", "Agriculture", "PH_chemdropdelay")
h:addChildTooltip(
  z["menu"],
  "Item Drop Position",
  "Your standing tile. Items drop one tile RIGHT; after two unconfirmed drop attempts, move LEFT and retry the same item.",
  "Agriculture",
  true
)
h:addChildInputInt(z["menu"], "Drop X (Stand Tile)", tostring(Z), "X", "0", "Agriculture", "PH_chemdropx")
h:addChildInputInt(z["menu"], "Drop Y (Stand Tile)", tostring(W), "Y", "0", "Agriculture", "PH_chemdropy")
h:addChildButton(z["menu"], "Set Drop Position = Current Tile", "PH_setchemdrop")
h:addChildTooltip(
  z["menu"],
  "Auto Save",
  "Every input and entered license key are saved to persistent settings. Start / Stop always opens OFF. Check Settings Auto Save on main page.",
  "Agriculture",
  false
)
h:addInputString("Auto Collect (view only)", V and "ON" or "OFF", "Collect", "Status", nil, "PH_autocollectdisplay")
h:addInputString(
  "Drop Position (view only)",
  i and (tostring(Z) .. (", " .. tostring(W))) or "NOT SET",
  "X, Y",
  "Drop to right",
  nil,
  "PH_chemdropdisplay"
)
h:addInputString("Item Collection Status (view only)", "IDLE", "Provider drops", "Status", nil, "PH_chemstatus")
h:addDisplayList(
  "Settings Auto Save",
  phConfig == nil and "UNAVAILABLE" or (phConfigRestored and "RESTORED" or "READY - SAVE ON CHANGE"),
  "PH_delay_save_status"
)
h:addDisplayList("World Progress", "CURRENT WORLD", "PH_worldstatus")
h:addDisplayList("Missed for Cleanup", "0", "PH_cleanupcount")
h:addDisplayList("Current Target", "NONE", "PH_target")
h:addDisplayList("Status", "STOPPED", "PH_status")
h:addInputString("Server Recovery (view only)", "NORMAL", "Recovery", "Status", nil, "PH_recovery")
pcall(function()
  addCategory(J, "Agriculture")
end)
local n = pcall(function()
  addIntoModule(h:generateJSON(), J)
end)
if not n then
  addIntoModule(h:generateJSON())
end
local a = false
local m = R
local X = false
local Y = false
local f = "NOT VERIFIED"
local U = false
local A = 0
local F = 0
local d = true
local K = true
local B = savedReturnToStart
local C = E
local I = 6
local Q, r = Z, W
local u = i
local e = s
local p = N
local b = V
local S = j
local T, Hi = Q, r
local Li = "IDLE"
local Gi, Oi = false, false
local Mi = false
local Ri = false
local oi = {}
local gi = 0
local ci = nil
local yi = {}
local Pi = {}
local vi = {}
local wi = {}
local xi = 1200
local Ei = 300
local li = 2200
local qi = 2500
local Zi = 350
local Wi = 100
local ii, si = {}, {}
function persistProviderSettings()
  local H = {
    ["worlds"] = harvestWorldText,
    ["return_start"] = tostring(B == true),
    ["auto_collect"] = tostring(b == true),
    ["punch_delay"] = C,
    ["collect_delay"] = S,
    ["drop_threshold"] = e,
    ["drop_delay"] = p,
    ["drop_x"] = Q,
    ["drop_y"] = r,
    ["drop_configured"] = tostring(u == true),
    ["license_key"] = o(m),
  }
  local L = saveProviderSettingsSnapshot(H)
  safePHUIValue(
    "PH_delay_save_status",
    L and "SAVED - REOPEN SAFE" or (phConfig == nil and "UNAVAILABLE" or "SAVE FAILED")
  )
  return L
end
local Ni = 0
local Vi = 0
local ji = false
local Di = ""
harvestWorldText = savedHarvestWorlds
worldQueue = {}
worldIndex = 0
worldTransitionPending = false
worldTransitionAttempts = 0
worldTransitionElapsed = 0
finalCleanupAttempts = 0
finalDropFailures = 0
local ki = "STOPPED"
local ti = 0
local Ji = false
local hi = false
local zi = false
local ni = 3500
local ai = 3500
local mi = 400
local Xi = 350
local Yi = 50
local fi = 250
local Ui = 1250
local Ai = 850
local Fi = 3400
local di = 3500
local Ki = 1200
local Bi = 12000
local Ci = 1500
local Ii = 10000
local Qi = 300
local ri = 0
local ui = {}
local ei = {}
local pi = nil
local bi = nil
local Si = 0
local Ti = "NORMAL"
local HK = 700
local LK = 5000
local GK = 200
local OK = 3
local MK = 450
local function RK(H)
  if growtopia ~= nil and type(growtopia["notify"]) == "function" then
    pcall(function()
      growtopia["notify"](tostring(H))
    end)
  end
end
local function oK(H)
  f = tostring(H or "")
  pcall(function()
    safePHUIValue("PH_licensestatus", f)
  end)
end
local function gK(H)
  H = tostring(H or "")
  H = H:gsub("\n", "\r\n")
  H = H:gsub("([^%w%-_%.~])", function(H)
    return string["format"]("%%%02X", string["byte"](H))
  end)
  return H
end
local function cK()
  local H = ""
  if type(getDiscordID) == "function" then
    local L, G = pcall(getDiscordID)
    if L and G ~= nil then
      H = tostring(G)
    end
  elseif getDiscordID ~= nil then
    H = tostring(getDiscordID)
  end
  H = ((tostring(H or "")):gsub("^%s+", "")):gsub("%s+$", "")
  if H == "" or H == "nil" or H == "0" then
    local L = GetLocal or getLocal
    if L ~= nil then
      local G, O = pcall(L)
      if G and (O ~= nil and O["name"] ~= nil) then
        H = tostring(O["name"])
        H = (H:gsub("^%s+", "")):gsub("%s+$", "")
      end
    end
  end
  return H
end
local function yK(G)
  if Y then
    return false
  end
  Y = true
  X = false
  local O = o(m)
  m = O
  pcall(function()
    safePHUIValue("PH_licensekey", O)
  end)
  if not g(O) then
    oK("INVALID KEY FORMAT")
    Y = false
    if not G then
      RK("License must be 1 letter + 7 numbers, for example A1234567.")
    end
    return false
  end
  local M = cK()
  if M == "" then
    oK("NO CLIENT ID")
    Y = false
    if not G then
      RK("Could not read a client ID. Enter the game first and try again.")
    end
    return false
  end
  oK("CHECKING...")
  F = F + 1
  local c = (os and type(os["time"]) == "function") and os["time"]() or math["random"](100000, 999999)
  local P = tostring(F) .. ("_" .. tostring(c))
  local v = H .. ("?key=" .. (gK(O) .. ("&id=" .. (gK(M) .. ("&product=" .. (gK(L) .. ("&nonce=" .. gK(P))))))))
  local w, x = pcall(fetch, v)
  if not w then
    oK("SERVER ERROR")
    Y = false
    if not G then
      RK("License server request failed.")
    end
    return false
  end
  x = tostring(x or "")
  x = (x:gsub("^%s+", "")):gsub("%s+$", "")
  if x:find("OK|PERMANENT", 1, true) then
    X = true
    oK("VERIFIED - PROVIDER")
    if y(O) then
      R = O
    end
    m = O
    Y = false
    if not G then
      RK("Provider license verified and saved.")
    end
    return true
  end
  if x:find("DENY|WRONG_PRODUCT", 1, true) then
    oK("WRONG PRODUCT")
  elseif x:find("DENY|DISABLED", 1, true) then
    oK("DISABLED")
  elseif x:find("DENY|BOUND_TO_OTHER_USER", 1, true) then
    oK("BOUND TO OTHER USER")
  elseif x:find("DENY|INVALID_KEY", 1, true) then
    oK("INVALID KEY")
  elseif x:find("DENY|BAD_KEY_FORMAT", 1, true) then
    oK("BAD KEY FORMAT")
  elseif x:find("DENY|NO_ID", 1, true) then
    oK("NO CLIENT ID")
  else
    oK("CHECK FAILED")
  end
  Y = false
  if not G then
    RK("License denied. Check License Status.")
  end
  return false
end
local function PK(H)
  H = tostring(H)
  if ki ~= H then
    ki = H
    safePHUIValue("PH_status", H)
  end
end
local function vK(H)
  H = tostring(H)
  if Ti ~= H then
    Ti = H
    pcall(function()
      safePHUIValue("PH_recovery", H)
    end)
  end
end
local function wK(H, L)
  local G = editToggle or EditToggle
  if G ~= nil then
    pcall(G, H, L)
  end
end
local function xK(H)
  wK("ModFly", H == true)
end
local function EK()
  local H = GetLocal or getLocal
  if H == nil then
    return nil
  end
  local L, G = pcall(H)
  if L then
    return G
  end
  return nil
end
local function lK()
  local H = GetWorldName or getCurrentWorldName
  if H == nil then
    return ""
  end
  local L, G = pcall(H)
  if L and type(G) == "string" then
    return G:upper()
  end
  return ""
end
local function qK()
  local H = GetTiles or getTiles
  if H == nil then
    return {}
  end
  local L, G = pcall(H)
  if L and type(G) == "table" then
    return G
  end
  return {}
end
local function ZK(H, L)
  local G = getTile or GetTile
  if G == nil then
    return nil
  end
  local O, M = pcall(G, H, L)
  if O then
    return M
  end
  return nil
end
local function WK()
  local H = EK()
  if H == nil then
    return nil, nil
  end
  return H["posX"] // 32, H["posY"] // 32
end
local function iK(H)
  return type(H) == "string" and (H ~= "" and H ~= "EXIT")
end
local function sK(H, L)
  if type(H) ~= "string" or type(L) ~= "string" then
    return false
  end
  return H:upper() == L:upper()
end
function parseHarvestWorlds(H)
  local L, G = {}, {}
  for H in (tostring(H or "")):gmatch("[^,%s;]+") do
    local O = H:match("^([^|]+)")
    if O and (O:match("^[%w_]+$") and #O <= 24) then
      local M = O:upper() .. H:sub(#O + 1)
      local R = O:upper()
      if not G[R] then
        G[R] = true
        L[#L + 1] = M
      end
    end
    if #L >= 30 then
      break
    end
  end
  return L
end
function worldNameFromEntry(H)
  return (((tostring(H or "")):match("^([^|]+)") or "")):upper()
end
function updateWorldDisplay()
  local H = (worldIndex > 0 and #worldQueue > 0)
      and (tostring(worldIndex) .. ("/" .. (tostring(#worldQueue) .. ("  " .. tostring(
        worldNameFromEntry(worldQueue[worldIndex])
      )))))
    or "CURRENT WORLD"
  pcall(function()
    safePHUIValue("PH_worldstatus", H)
  end)
end
local function NK()
  if Di == nil or Di == "" then
    return false
  end
  local H = EK()
  if H == nil then
    return false
  end
  local L = lK()
  if iK(L) then
    if sK(L, Di) then
      zi = true
      return true
    end
    zi = false
    return false
  end
  return zi == true
end
local function VK(H)
  local L = math["max"](0, math["floor"](tonumber(H) or 0))
  while a and L > 0 do
    if not NK() then
      return false
    end
    local H = math["min"](100, L)
    Sleep(H)
    L = L - H
  end
  return a and NK()
end
local function jK()
  return NK()
end
local function DK(H, L)
  local G = 0
  while a and G < H do
    local H = EK()
    local O = lK()
    if iK(O) and not sK(O, Di) then
      return false
    end
    local M = qK()
    if H ~= nil and (M ~= nil and next(M) ~= nil) then
      if L or sK(O, Di) or zi then
        return true
      end
    end
    Sleep(100)
    G = G + 100
  end
  return false
end
local function kK()
  local H = EK()
  if H == nil or not a then
    return false
  end
  local L = lK()
  if iK(L) and not sK(L, Di) then
    return false
  end
  local G = H["posX"] // 32
  local O = H["posY"] // 32
  xK(d)
  Sleep(250)
  for H = 1, 2, 1 do
    if not a then
      return false
    end
    pcall(function()
      FindPath(G, O)
    end)
    Sleep(GK)
  end
  local M = {
    { ["x"] = G + 1, ["y"] = O },
    { ["x"] = G - 1, ["y"] = O },
    { ["x"] = G, ["y"] = O - 1 },
    { ["x"] = G, ["y"] = O + 1 },
    { ["x"] = G + 2, ["y"] = O },
    { ["x"] = G - 2, ["y"] = O },
  }
  for H = 1, OK, 1 do
    if not a then
      return false
    end
    PK("RESUME PATH " .. (tostring(H) .. ("/" .. tostring(OK))))
    for H, L in ipairs(M) do
      local M = ZK(L["x"], L["y"])
      if M ~= nil then
        local H = false
        pcall(function()
          FindPath(L["x"], L["y"])
        end)
        local M = 0
        while a and M < 1200 do
          local R = EK()
          local o = lK()
          if iK(o) and not sK(o, Di) then
            return false
          end
          if R ~= nil then
            local M = R["posX"] // 32
            local o = R["posY"] // 32
            if M == L["x"] and o == L["y"] then
              H = true
              break
            end
            if M ~= G or o ~= O then
              H = true
              break
            end
          end
          Sleep(100)
          M = M + 100
        end
        if H then
          Sleep(GK)
          pcall(function()
            FindPath(G, O)
          end)
          Sleep(GK)
          return true
        end
      end
    end
    pcall(function()
      FindPath(G, O)
    end)
    Sleep(MK)
  end
  return false
end
local function tK(H)
  if not Ji and H ~= nil then
    RK(H)
  end
  Ji = true
  hi = false
  zi = false
  xK(false)
  PK("PAUSED - WAIT WORLD")
end
local function JK()
  if not a then
    return false
  end
  if NK() then
    if Ji or hi then
      xK(false)
      PK("RESUMING")
      Sleep(HK)
      if not a then
        return false
      end
      local H = lK()
      if iK(H) and not sK(H, Di) then
        zi = false
        return false
      end
      if not DK(LK, false) then
        PK("RESUMING")
        Sleep(100)
        return false
      end
      PK("RESUME MOVE")
      local L = kK()
      if not a then
        return false
      end
      H = lK()
      if iK(H) and not sK(H, Di) then
        zi = false
        return false
      end
      if not L then
        PK("RESUME PATH RETRY")
        Sleep(MK)
        return false
      end
      Ji = false
      hi = false
      zi = true
      RK("Provider Harvester resumed automatically.")
    end
    return true
  end
  if Ji and hi then
    xK(false)
    PK("RESUMING")
    Sleep(HK)
    if not a then
      return false
    end
    if DK(4000, true) then
      local H = lK()
      if iK(H) and not sK(H, Di) then
        zi = false
        PK("PAUSED - WAIT WORLD")
        return false
      end
      zi = true
      PK("RESUME MOVE")
      local L = kK()
      if not a then
        return false
      end
      H = lK()
      if iK(H) and not sK(H, Di) then
        zi = false
        PK("PAUSED - WAIT WORLD")
        return false
      end
      if not L then
        PK("RESUME PATH RETRY")
        Sleep(MK)
        return false
      end
      Ji = false
      hi = false
      RK("Provider Harvester resumed automatically.")
      return true
    end
  end
  if not Ji then
    RK("Provider Harvester paused - return to " .. tostring(Di))
  end
  Ji = true
  zi = false
  xK(false)
  PK("PAUSED - WAIT WORLD")
  Sleep(200)
  return false
end
local function hK() end
local function zK() end
local function nK(H)
  local L = nil
  if type(findItemID) == "function" then
    local G, O = pcall(findItemID, H["name"])
    if G then
      L = tonumber(O)
    end
  end
  if (L == nil or L <= 0) and type(getItemInfoByName) == "function" then
    local G, O = pcall(getItemInfoByName, H["name"])
    if G and O ~= nil then
      L = tonumber(O["id"])
    end
  end
  if (L == nil or L <= 0) and (growtopia ~= nil and type(growtopia["getItemID"]) == "function") then
    local G, O = pcall(function()
      return growtopia["getItemID"](H["name"])
    end)
    if G then
      L = tonumber(O)
    end
  end
  if (L == nil or L <= 0) and H["fallbackID"] ~= nil then
    L = tonumber(H["fallbackID"])
  end
  if L ~= nil and L > 0 then
    return math["floor"](L)
  end
  return nil
end
local function aK()
  ii, si = {}, {}
  for H, L in ipairs(t) do
    local G = nK(L)
    L["id"] = G
    if G ~= nil then
      ii[G] = L
    end
  end
end
local function mK(H)
  if not H or H["readyharvest"] ~= true then
    return nil
  end
  local L = tonumber(H["fg"])
  if not L or L <= 0 or si[L] then
    return nil
  end
  if ii[L] then
    return ii[L]
  end
  local G = getItemInfoByID or GetItemInfo or getItemInfo
  if type(G) ~= "function" then
    return nil
  end
  local O, M = pcall(G, L)
  local R = O and (M and tonumber(M["type"]))
  if R == 38 then
    local H = { ["id"] = L, ["key"] = tostring(L), ["name"] = M["name"] or ("Provider #" .. L) }
    ii[L] = H
    return H
  end
  if R ~= nil and R ~= false then
    si[L] = true
  end
end
local function XK()
  local H = {}
  for L, G in pairs(qK()) do
    local O = tonumber(G["fg"]) or 0
    local M = mK(G)
    if M then
      table["insert"](
        H,
        { ["x"] = tonumber(G["x"]) or 0, ["y"] = tonumber(G["y"]) or 0, ["fg"] = O, ["key"] = M["key"], ["name"] = M["name"] }
      )
    end
  end
  table["sort"](H, function(H, L)
    if H["y"] == L["y"] then
      return H["x"] < L["x"]
    end
    return H["y"] < L["y"]
  end)
  return H
end
local function YK(H)
  if H == nil or #H == 0 then
    return nil
  end
  local L = H[1]["y"]
  local G = {}
  for H, O in ipairs(H) do
    if O["y"] > L + 4 then
      break
    end
    G[O["y"]] = G[O["y"]] or {}
    G[O["y"]][O["x"]] = true
  end
  local O, M
  for H, R in ipairs(H) do
    if R["y"] > L + 2 then
      break
    end
    local o = false
    local g = 0
    for H = R["y"] - 2, R["y"] + 2, 1 do
      local O = G[H]
      if O then
        for G = R["x"] - 2, R["x"] + 2, 1 do
          if O[G] then
            g = g + 1
            if H == L then
              o = true
            end
          end
        end
      end
    end
    if o and (not O or g > M or (g == M and R["x"] < O["x"])) then
      O, M = R, g
    end
  end
  return O
end
local function fK(H, L)
  local G, O = WK()
  return G == H and O == L
end
local function UK(H, L)
  if fK(H, L) then
    return true
  end
  for G = 1, I, 1 do
    if not a then
      return false
    end
    if not NK() then
      Ji = true
      zi = false
      return false
    end
    PK("PATH " .. (tostring(G) .. ("/" .. (tostring(I) .. (" -> " .. (tostring(H) .. ("," .. tostring(L))))))))
    pcall(function()
      FindPath(H, L)
    end)
    local O = 0
    while a and O < ni do
      if not NK() then
        Ji = true
        zi = false
        return false
      end
      if fK(H, L) then
        Sleep(150)
        return true
      end
      Sleep(100)
      O = O + 100
    end
    if G < I then
      local H, L = WK()
      if H ~= nil and L ~= nil then
        pcall(function()
          FindPath(H, L)
        end)
      end
      Sleep(mi)
    end
  end
  return fK(H, L)
end
local function AK(H, L, G)
  local O = ZK(H, L)
  if O == nil then
    return nil
  end
  if tonumber(O["fg"]) ~= tonumber(G) then
    return false
  end
  return O["readyharvest"] == true
end
local function FK(H)
  Li = tostring(H)
  pcall(function()
    safePHUIValue("PH_chemstatus", Li)
  end)
end
local function dK()
  pcall(function()
    safePHUIValue("PH_chemdropdisplay", u and (tostring(Q) .. (", " .. tostring(r))) or "NOT SET")
  end)
end
local function KK()
  return persistProviderSettings()
end
local function BK()
  pcall(function()
    safePHUIValue("PH_autocollectdisplay", b and "ON" or "OFF")
  end)
end
local function CK(H)
  safePHUIValue(
    "PH_delay_save_status",
    H and "SAVED - REOPEN SAFE" or (phConfig == nil and "UNAVAILABLE" or "SAVE FAILED")
  )
end
local function IK()
  vi = {}
  wi = {}
end
local function QK(H)
  H = tonumber(H)
  if H == nil or H <= 0 or H == 112 then
    return nil
  end
  H = math["floor"](H)
  if wi[H] ~= nil then
    return wi[H]
  end
  local L = "Item #" .. tostring(H)
  local G = getItemInfo or getItemInfoByID or GetItemInfo
  if type(G) == "function" then
    local O, M = pcall(G, H)
    if O and (type(M) == "table" and (type(M["name"]) == "string" and M["name"] ~= "")) then
      L = M["name"]
    end
  end
  local O = { ["id"] = H, ["name"] = L }
  wi[H] = O
  vi[#vi + 1] = O
  return O
end
local function rK(H)
  if H == nil then
    return nil
  end
  local L = GetInventory or getInventory
  if L ~= nil then
    local G, O = pcall(L)
    if G and type(O) == "table" then
      for L, G in pairs(O) do
        if tonumber(G["id"]) == tonumber(H) then
          return tonumber(G["amount"]) or 0
        end
      end
      return 0
    end
  end
  if growtopia ~= nil and type(growtopia["checkInventoryCount"]) == "function" then
    local L, G = pcall(growtopia["checkInventoryCount"], H)
    if L then
      return tonumber(G)
    end
  end
  return nil
end
local function uK()
  for H, L in ipairs(vi) do
    local G = rK(L["id"])
    if G ~= nil and G >= e then
      return true
    end
  end
  return false
end
local function eK()
  local H = false
  for H, L in ipairs(vi) do
    local G = rK(L["id"])
    if G ~= nil and G >= e then
      oi[L["id"]] = true
    end
  end
  for L, G in pairs(oi) do
    if G then
      H = true
      break
    end
  end
  if H then
    Ri = true
  end
  return H
end
local function pK()
  for H, L in ipairs(vi) do
    local G = rK(L["id"])
    if G ~= nil and G > 0 then
      return true
    end
  end
  return false
end
local function bK(H, L)
  if not u then
    return false
  end
  return L >= r - 1 and (L <= r + 1 and (H >= math["min"](Q, T) - 1 and H <= math["max"](Q, T) + 2))
end
local function SK()
  local H = GetObjectList or getObjectList
  if H == nil then
    return {}
  end
  local L, G = pcall(H)
  if L and type(G) == "table" then
    return G
  end
  return {}
end
local function TK(H)
  local L = tonumber(H["posX"])
  local G = tonumber(H["posY"])
  if H["pos"] ~= nil then
    L = L or tonumber(H["pos"]["x"])
    G = G or tonumber(H["pos"]["y"])
  end
  return L, G
end
local function H_(H)
  for L, G in pairs(SK()) do
    if tonumber(G["id"]) == tonumber(H) then
      return true
    end
  end
  return false
end
local function L_(H)
  return tostring(H["x"]) .. (":" .. (tostring(H["y"]) .. (":" .. tostring(H["halfWidth"]))))
end
local function G_(H, L)
  if H == nil then
    return nil
  end
  local G = {
    ["x"] = math["floor"](tonumber(H["x"]) or 0),
    ["y"] = math["floor"](tonumber(H["y"]) or 0),
    ["halfWidth"] = (L == 0 and 0 or 2),
  }
  local O = L_(G)
  if not Pi[O] then
    Pi[O] = true
    yi[#yi + 1] = G
  end
  if ci == nil then
    ci = G
  end
  return G
end
local function O_(H, L, G)
  return G ~= nil
    and (
      math["abs"](H - G["x"]) <= (G["halfWidth"] == 0 and 0 or 2)
      and math["abs"](L - G["y"]) <= (G["halfWidth"] == 0 and 1 or 2)
    )
end
local function M_()
  local H = GetObjectList or getObjectList
  if H == nil then
    return {}
  end
  local L, G = pcall(H)
  if L and type(G) == "table" then
    return G
  end
  return {}
end
local function R_(H)
  local L = tonumber(H["posX"])
  local G = tonumber(H["posY"])
  if H["pos"] ~= nil then
    L = L or tonumber(H["pos"]["x"])
    G = G or tonumber(H["pos"]["y"])
  end
  return L, G
end
local function o_(H)
  for L, G in pairs(M_()) do
    if tonumber(G["id"]) == tonumber(H) then
      return true
    end
  end
  return false
end
local function g_(H, L)
  local G = {}
  local O = {}
  local M = nil
  local R = GetInventory or getInventory
  if R ~= nil then
    local H, L = pcall(R)
    if H and type(L) == "table" then
      M = {}
      for H, L in pairs(L) do
        local G = tonumber(L["id"])
        if G ~= nil then
          M[G] = tonumber(L["amount"]) or 0
        end
      end
    end
  end
  if L then
    O = yi
  elseif H ~= nil then
    O = { H }
  end
  if #O == 0 then
    return G
  end
  for H, L in pairs(M_()) do
    local R = tonumber(L["itemid"])
    local o = tonumber(L["id"])
    if R ~= nil and (R > 0 and (R ~= 112 and o ~= nil)) then
      local H, g = R_(L)
      if H ~= nil and g ~= nil then
        local L, c = math["floor"](H / 32), math["floor"](g / 32)
        if not bK(L, c) then
          local y = nil
          for H, G in ipairs(O) do
            if O_(L, c, G) then
              y = G
              break
            end
          end
          if y ~= nil then
            local O = QK(R)
            if O ~= nil then
              local O = M ~= nil and (M[R] or 0) or rK(R)
              if O ~= nil and O < 200 then
                G[#G + 1] = {
                  ["uid"] = o,
                  ["id"] = R,
                  ["x"] = H,
                  ["y"] = g,
                  ["tx"] = L,
                  ["ty"] = c,
                  ["distance"] = math["abs"](L - y["x"]) + math["abs"](c - y["y"]),
                }
              end
            end
          end
        end
      end
    end
  end
  table["sort"](G, function(H, L)
    if H["distance"] == L["distance"] then
      return H["uid"] < L["uid"]
    end
    return H["distance"] < L["distance"]
  end)
  return G
end
local function c_(H)
  local L = SendPacketRaw or sendPacketRaw
  if L == nil or H["uid"] == nil then
    return false
  end
  return pcall(function()
    L(false, { ["type"] = 11, ["value"] = H["uid"], ["x"] = H["x"], ["y"] = H["y"] })
  end)
end
local function y_(H, L, G)
  local O = 0
  while a and (NK() and O < G) do
    local G = rK(H)
    if G ~= nil and G > L then
      return true
    end
    Sleep(50)
    O = O + 50
  end
  return (rK(H) or -1) > L
end
local function P_(H, L)
  local G = L and 1100 or 2600
  local O = L and 550 or 1050
  local M = L and 50 or 75
  local R, o = WK()
  if R == nil then
    return false
  end
  if math["abs"](R - H["tx"]) <= 1 and math["abs"](o - H["ty"]) <= 1 then
    return true
  end
  local g = pcall(function()
    FindPath(H["tx"], H["ty"])
  end)
  if not g then
    return false
  end
  local c, y = 0, 0
  local P, v = R, o
  while a and (NK() and c < G) do
    R, o = WK()
    if R == nil then
      return false
    end
    if math["abs"](R - H["tx"]) <= 1 and math["abs"](o - H["ty"]) <= 1 then
      return true
    end
    if R ~= P or o ~= v then
      y = 0
      P, v = R, o
    else
      y = y + M
    end
    if y >= O then
      return false
    end
    Sleep(M)
    c = c + M
  end
  return false
end
local function v_(H)
  if not a or not NK() then
    return false
  end
  local L = rK(H["id"])
  if L == nil or L >= 200 then
    return false
  end
  if not o_(H["uid"]) then
    return true
  end
  local G, O = WK()
  if G == nil then
    return false
  end
  if math["abs"](G - H["tx"]) > 1 or math["abs"](O - H["ty"]) > 1 then
    PK("ITEM PICKUP PATH " .. (tostring(H["tx"]) .. ("," .. tostring(H["ty"]))))
    if not P_(H) then
      return false
    end
  end
  if not a or not NK() then
    return false
  end
  if (rK(H["id"]) or 0) > L then
    return true
  end
  if not o_(H["uid"]) then
    return y_(H["id"], L, 500)
  end
  for G = 1, 2, 1 do
    if not a or not NK() then
      return false
    end
    if not o_(H["uid"]) then
      return y_(H["id"], L, 450)
    end
    FK("PICKUP " .. (tostring(H["id"]) .. (" (" .. (G .. "/2)"))))
    if not c_(H) then
      return false
    end
    if y_(H["id"], L, xi) then
      gi = gi + 1
      return true
    end
    if G == 1 then
      VK(Ei)
    end
  end
  FK("PICKUP LAG - WILL RESCAN")
  return false
end
local function w_(H)
  if H == nil then
    return true
  end
  FK(H["halfWidth"] == 0 and "FAST COLLECT CLEANUP HIT" or "FAST COLLECT 5x5")
  local L = g_(H, false)
  for H, L in ipairs(L) do
    if not a or not NK() then
      return false
    end
    local G, O = WK()
    if G ~= nil and (math["abs"](G - L["tx"]) > 1 or math["abs"](O - L["ty"]) > 1) then
      P_(L, true)
    end
    G, O = WK()
    if G ~= nil and (math["abs"](G - L["tx"]) <= 1 and math["abs"](O - L["ty"]) <= 1) then
      if c_(L) then
        gi = gi + 1
        if S > 0 then
          Sleep(S)
        end
      end
    end
  end
  return a and NK()
end
local function x_(H)
  if H == nil then
    return true
  end
  FK("FINAL CHECK BATCH " .. (tostring(H["x"]) .. ("," .. tostring(H["y"]))))
  for L = 1, 4, 1 do
    if not a or not NK() then
      return false
    end
    local G = g_(H, false)
    if #G == 0 then
      return true
    else
      for L, G in ipairs(G) do
        if not a or not NK() then
          return false
        end
        if eK() then
          ci = H
          return false
        end
        if o_(G["uid"]) and not v_(G) then
          FK("FINAL PICKUP LAG - RETRY LATER")
          ci = H
          return false
        end
      end
    end
  end
  return #g_(H, false) == 0
end
local function E_(H, L, G)
  if not b then
    return true
  end
  if not a or not NK() then
    return false
  end
  if L then
    FK("FINAL LEFTOVERS CLEANUP")
    for H, L in ipairs(yi) do
      if not x_(L) then
        ci = L
        return false
      end
    end
    ci = nil
    FK("VISITED BATCHES CLEARED")
    return true
  end
  local O = H ~= nil and G_(H, G) or ci
  if O == nil then
    return true
  end
  local M = w_(O)
  if M then
    ci = nil
  end
  return M
end
local function l_(H)
  wK("Anticollect", H)
  wK("AntiCollect", H)
  if H then
    wK("Enable AutoCollect", false)
    wK("Autocollect", false)
  end
end
local function q_()
  local H = EK()
  if H == nil then
    return false
  end
  if H["isLeft"] == false or H["isLeft"] == nil then
    return true
  end
  local L, G = WK()
  if L == nil or L <= 0 then
    return false
  end
  if not UK(L - 1, G) then
    return false
  end
  if not UK(L, G) then
    return false
  end
  H = EK()
  return H ~= nil and H["isLeft"] ~= true
end
local function Z_(H, L)
  Gi, Oi = true, false
  SendPacket(2, "action|drop\nitemID|" .. tostring(H["id"]))
  local G = 0
  while a and (NK() and G < li) do
    if Oi then
      break
    end
    Sleep(50)
    G = G + 50
  end
  Gi = false
  if not a or not NK() then
    return false
  end
  if not Oi then
    return false
  end
  Oi = false
  SendPacket(
    2,
    "action|dialog_return\n"
      .. ("dialog_name|drop_item\n" .. ("itemID|" .. (tostring(H["id"]) .. ("|\n" .. ("count|" .. tostring(L))))))
  )
  local O = 0
  while a and (NK() and O < qi) do
    local G = rK(H["id"])
    if G ~= nil and G < L then
      if p > O then
        VK(p - O)
      end
      return true
    end
    Sleep(50)
    O = O + 50
  end
  return (rK(H["id"]) or L) < L
end
local function W_(H)
  if not a or not NK() then
    return false
  end
  if not eK() then
    Ri = false
    return true
  end
  Ri = true
  if not u then
    FK("SET ITEM DROP POSITION FIRST")
    return false
  end
  Mi = true
  l_(true)
  local L = true
  local G = 0
  for H, O in ipairs(vi) do
    if oi[O["id"]] then
      while a and NK() do
        local H = rK(O["id"])
        if H == nil then
          L = false
          break
        end
        if H <= 0 then
          oi[O["id"]] = nil
          break
        end
        FK("DROP " .. (O["name"] .. (" " .. tostring(H))))
        if not UK(T, Hi) or not q_() then
          L = false
          break
        end
        local M = false
        for L = 1, 2, 1 do
          if not a or not NK() then
            break
          end
          local G = rK(O["id"])
          if G ~= nil and G < H then
            M = true
            break
          end
          PK("ITEM DROP " .. (O["name"] .. (" " .. (tostring(L) .. "/2"))))
          if Z_(O, H) then
            M = true
            break
          end
          if L < 2 then
            VK(Zi)
          end
        end
        if not a or not NK() then
          L = false
          break
        end
        if not M then
          VK(200)
          local L = rK(O["id"])
          if L ~= nil and L < H then
            M = true
          end
        end
        if not M then
          if G >= Wi or T <= 1 then
            FK("ITEM DROP SPACE EXHAUSTED")
            L = false
            break
          end
          T = T - 1
          G = G + 1
          FK("DROP REJECTED -> LEFT " .. T)
          if not UK(T, Hi) then
            L = false
            break
          end
          VK(250)
        end
      end
      if not L or not a or not NK() then
        break
      end
    end
  end
  if L and (a and NK()) then
    local H, G = WK()
    if ji and (H ~= Ni or G ~= Vi) then
      PK("BACK FROM ITEM DROP")
      if not UK(Ni, Vi) then
        L = false
      end
    end
  end
  l_(false)
  Mi = false
  if L then
    local H = false
    for L, G in pairs(oi) do
      if G then
        H = true
        break
      end
    end
    Ri = H
  end
  FK(L and "ITEM DROP DONE" or "ITEM DROP RETRY LATER")
  return L
end
local function i_(H)
  return tostring(H["x"]) .. (":" .. tostring(H["y"]))
end
local function s_()
  local H = 0
  for L in pairs(ui) do
    H = H + 1
  end
  pcall(function()
    safePHUIValue("PH_cleanupcount", tostring(H))
  end)
end
local function N_()
  ui = {}
  ei = {}
  ri = 0
  pi = nil
  bi = nil
  Si = 0
  vK("NORMAL")
  s_()
end
local function V_(H)
  local L = {}
  local G = {}
  for H, O in ipairs(H) do
    local M = i_(O)
    L[M] = true
    if ui[M] == nil then
      table["insert"](G, O)
    end
  end
  local O = false
  for H in pairs(ui) do
    if not L[H] then
      ui[H] = nil
      ei[H] = nil
      O = true
    end
  end
  if O then
    s_()
  end
  if next(ui) == nil and pi == nil then
    vK("NORMAL")
  end
  return G
end
local function j_(H)
  if not a or not NK() then
    return false
  end
  safePHUIValue("PH_target", H["name"] .. (" @ " .. (tostring(H["x"]) .. (", " .. tostring(H["y"])))))
  local L = EK()
  if L == nil then
    return false
  end
  local G = sendPacketRaw or SendPacketRaw
  if G ~= nil then
    local O = pcall(function()
      G(false, { ["type"] = 3, ["value"] = 18, ["x"] = L["posX"], ["y"] = L["posY"], ["px"] = H["x"], ["py"] = H["y"] })
    end)
    if O then
      return true
    end
  end
  if growtopia ~= nil and type(growtopia["tileChange"]) == "function" then
    return pcall(function()
      growtopia["tileChange"](H["x"], H["y"], 18)
    end)
  end
  return false
end
local function D_(H, L)
  local G = 0
  local O = false
  for H, M in ipairs(H) do
    local R = tostring(M["x"]) .. (":" .. tostring(M["y"]))
    if not L[R] then
      local H = AK(M["x"], M["y"], M["fg"])
      if H == false then
        L[R] = true
        ti = ti + 1
        zK()
        O = true
      else
        G = G + 1
      end
    end
  end
  return G, O
end
local function k_(H, L)
  local G = 0
  local O = nil
  local M = false
  while a do
    if not NK() then
      Ji = true
      zi = false
      return false, M, 0
    end
    local R, o = D_(H, L)
    if o then
      M = true
      O = G
    end
    if R == 0 then
      return true, M, 0
    end
    if M and (O ~= nil and G - O >= fi) then
      return true, M, R
    end
    if G >= Ui then
      return true, M, R
    end
    Sleep(Yi)
    G = G + Yi
  end
  return false, M, 0
end
local function t_(H)
  local L, G = WK()
  if L == nil or G == nil then
    return false, false
  end
  local O = {}
  local M = {}
  for H = G - 2, G + 2, 1 do
    for L = L - 2, L + 2, 1 do
      local G = ZK(L, H)
      local M = G and tonumber(G["fg"])
      local R = mK(G)
      local o = tostring(L) .. (":" .. tostring(H))
      if R and ui[o] == nil then
        O[#O + 1] = { ["x"] = L, ["y"] = H, ["fg"] = M, ["key"] = R["key"], ["name"] = R["name"] }
      end
    end
  end
  if #O == 0 then
    PK("RESCAN ROW")
    return true, false
  end
  PK("HARVEST 5x5 BATCH " .. tostring(#O))
  local R = {}
  for M, o in ipairs(O) do
    if not a then
      return false, false
    end
    if not NK() then
      Ji = true
      zi = false
      return false, false
    end
    local g, c = WK()
    if g ~= L or c ~= G then
      break
    end
    if AK(o["x"], o["y"], o["fg"]) == true then
      if not j_(o) then
        table["insert"](R, o)
        pi = R
        bi = { ["x"] = H["x"], ["y"] = H["y"] }
        Si = 0
        vK("SEND FAILED - RETRY")
        PK("PUNCH SEND FAILED - RETRY")
        return true, false
      end
      table["insert"](R, o)
      if #R < #O then
        Sleep(C + math["random"](0, 20))
      end
    end
  end
  if #R == 0 then
    PK("RESCAN ROW")
    return true, false
  end
  PK("VERIFY 5x5 BATCH")
  local o, g, c = k_(R, M)
  if not o then
    return false, g
  end
  if not g then
    ri = ri + 1
    pi = R
    bi = { ["x"] = H["x"], ["y"] = H["y"] }
    Si = 0
    vK("LAG - SINGLE HIT RETRY")
    PK("NO BATCH ACK - LAG SAFE")
    return true, false
  end
  ri = 0
  local y, P = D_(R, M)
  if P then
    g = true
  end
  local v = false
  for H, L in ipairs(R) do
    local G = i_(L)
    if not M[G] then
      if AK(L["x"], L["y"], L["fg"]) ~= false then
        ui[G] = L
        v = true
      end
    end
  end
  if v then
    s_()
  end
  if c > 0 or v then
    PK("SKIP MISSES - CLEAN UP LATER")
  else
    PK("5x5 BATCH DONE")
  end
  return true, g
end
local function J_()
  if pi == nil then
    return true
  end
  if not a or not NK() then
    return false
  end
  local H = false
  local L = 0
  local G = {}
  local O = false
  for M, R in ipairs(pi) do
    local o = AK(R["x"], R["y"], R["fg"])
    if o == false then
      H = true
      L = L + 1
    elseif o == true then
      table["insert"](G, R)
    else
      O = true
    end
  end
  if H then
    for H, L in ipairs(G) do
      ui[i_(L)] = L
    end
    if O then
      for H, L in ipairs(pi) do
        if AK(L["x"], L["y"], L["fg"]) == nil then
          ui[i_(L)] = L
        end
      end
    end
    ti = ti + L
    zK()
    s_()
    local H = bi or pi[1]
    pi = nil
    bi = nil
    Si = 0
    ri = 0
    if b and H ~= nil then
      E_(H, false)
    end
    vK("NORMAL")
    PK("SERVER RECOVERED - RESCAN")
    return true
  end
  local M = G[1]
  if M ~= nil then
    local H, L = WK()
    if H == nil or L == nil or L ~= M["y"] or math["abs"](H - M["x"]) > 2 then
      PK("LAG RECOVERY - PATH")
      if not UK(M["x"], M["y"]) then
        M = nil
      end
    end
  end
  if M ~= nil and (a and (NK() and AK(M["x"], M["y"], M["fg"]) == true)) then
    PK("LAG RECOVERY - ONE HIT")
    j_(M)
    local H = 0
    while a and H < di do
      if not NK() then
        return false
      end
      if AK(M["x"], M["y"], M["fg"]) == false then
        break
      end
      local L = math["min"](Yi, di - H)
      Sleep(L)
      H = H + L
    end
  end
  for H, L in ipairs(pi) do
    if AK(L["x"], L["y"], L["fg"]) == false then
      return J_()
    end
  end
  Si = Si + 1
  local R = math["min"](Si - 1, 4)
  local o = math["min"](Ki * (2 ^ R), Bi)
  vK("LAG - RETRY " .. tostring(Si))
  PK("SERVER LAG - RETRY IN " .. (tostring(o) .. "ms"))
  local g = o
  while a and (g > 0 and NK()) do
    for H, L in ipairs(pi or {}) do
      if AK(L["x"], L["y"], L["fg"]) == false then
        return true
      end
    end
    local H = math["min"](250, g)
    Sleep(H)
    g = g - H
  end
  return false
end
local function h_(H)
  ei[H] = (ei[H] or 0) + 1
  local L = math["min"](ei[H] - 1, 5)
  local G = math["min"](Qi * (2 ^ L), Ii)
  vK("CLEANUP RETRY " .. tostring(ei[H]))
  PK("CLEANUP LAG - WAIT " .. (tostring(G) .. "ms"))
  VK(G)
end
local function z_(H)
  local L = i_(H)
  if not a then
    return false, false
  end
  if not NK() then
    Ji = true
    zi = false
    return false, false
  end
  if AK(H["x"], H["y"], H["fg"]) == false then
    ui[L] = nil
    ei[L] = nil
    s_()
    return true, true
  end
  PK("CLEANUP INDIVIDUAL " .. (tostring(H["x"]) .. ("," .. tostring(H["y"]))))
  if not UK(H["x"], H["y"]) then
    if not NK() then
      return false, false
    end
    h_(L)
    return true, false
  end
  if AK(H["x"], H["y"], H["fg"]) == false then
    ui[L] = nil
    ei[L] = nil
    s_()
    return true, true
  end
  if AK(H["x"], H["y"], H["fg"]) ~= true then
    h_(L)
    return true, false
  end
  if not j_(H) then
    h_(L)
    return true, false
  end
  local G = {}
  local O = 0
  while a and O <= Ci do
    if not NK() then
      Ji = true
      zi = false
      return false, false
    end
    local M, R = D_({ H }, G)
    if M == 0 then
      ui[L] = nil
      ei[L] = nil
      s_()
      return true, true
    end
    if O >= Ci then
      break
    end
    Sleep(Yi)
    O = O + Yi
  end
  h_(L)
  return true, false
end
local function n_(H)
  a = false
  worldTransitionPending = false
  l_(false)
  Mi = false
  Gi = false
  xK(false)
  PK("STOPPED")
  safePHUIValue("PH_target", "NONE")
  local L = editToggle or EditToggle
  if L ~= nil then
    pcall(L, "PH_enable", false)
  end
  if H ~= nil and H ~= "" then
    RK(H)
  end
end
function resetForWorld()
  N_()
  ci = nil
  yi = {}
  Pi = {}
  pi = nil
  bi = nil
  Si = 0
  ri = 0
  finalCleanupAttempts = 0
  finalDropFailures = 0
  oi = {}
  Ri = false
  T, Hi = Q, r
  safePHUIValue("PH_target", "NONE")
  vK("NORMAL")
  FK(b and "READY" or "AUTO COLLECT OFF")
end
function selectWorldInQueue(H)
  if H < 1 or H > #worldQueue then
    return false
  end
  worldIndex = H
  Di = worldNameFromEntry(worldQueue[H])
  worldTransitionPending = true
  worldTransitionAttempts = 0
  worldTransitionElapsed = 0
  Ji = false
  hi = false
  zi = false
  ji = false
  resetForWorld()
  xK(false)
  updateWorldDisplay()
  PK("GO TO WORLD " .. (tostring(H) .. ("/" .. (tostring(#worldQueue) .. (" " .. tostring(Di))))))
  return true
end
function requestWorldJoin(H)
  local L = false
  if type(Warp) == "function" then
    L = pcall(Warp, H)
  elseif type(JoinWorld) == "function" then
    L = pcall(JoinWorld, H)
  else
    local G = SendPacket or sendPacket
    if type(G) == "function" then
      L = pcall(G, 3, "action|join_request\nname|" .. tostring(H))
    end
  end
  return L
end
function processWorldTransition()
  if not a or not worldTransitionPending then
    return
  end
  local H = worldQueue[worldIndex]
  if H == nil then
    n_("World list unavailable.")
    return
  end
  if sK(lK(), Di) and (EK() ~= nil and next(qK()) ~= nil) then
    Sleep(250)
    if not a then
      return
    end
    if sK(lK(), Di) and next(qK()) ~= nil then
      zi = true
      worldTransitionPending = false
      Ji = false
      hi = false
      Ni, Vi = WK()
      ji = Ni ~= nil
      xK(d)
      PK("SCANNING " .. tostring(Di))
      updateWorldDisplay()
      return
    end
  end
  if worldTransitionAttempts == 0 or worldTransitionElapsed >= 8000 then
    if worldTransitionAttempts >= 3 then
      n_("Could not enter world " .. (tostring(Di) .. ". Stopped instead of skipping it."))
      return
    end
    worldTransitionAttempts = worldTransitionAttempts + 1
    worldTransitionElapsed = 0
    PK("JOIN " .. (tostring(Di) .. (" (" .. (tostring(worldTransitionAttempts) .. "/3)"))))
    if not requestWorldJoin(H) then
      n_("Growlauncher world join unavailable; " .. tostring(H))
      return
    end
  end
  Sleep(250)
  worldTransitionElapsed = worldTransitionElapsed + 250
end
function finishCurrentWorld(H)
  if not a or not NK() then
    return
  end
  local L = tostring(Di)
  if B and (ji and not fK(Ni, Vi)) then
    PK("RETURN TO START (OPTIONAL)")
    pcall(function()
      FindPath(Ni, Vi)
    end)
    local H = 0
    while a and (NK() and (not fK(Ni, Vi) and H < 1500)) do
      Sleep(100)
      H = H + 100
    end
    if not fK(Ni, Vi) then
      RK("Return path blocked in " .. (L .. "; continuing."))
    end
  end
  if not a or not NK() then
    return
  end
  if H then
    RK("Uncollected provider drops remain in " .. (L .. ". They were not deleted. Moving on after limited retries."))
  end
  if worldIndex < #worldQueue then
    RK("Provider world complete: " .. (L .. ". Next world."))
    selectWorldInQueue(worldIndex + 1)
  else
    n_("All " .. (tostring(#worldQueue) .. " provider world(s) completed."))
  end
end
local function a_()
  local H, L = WK()
  if H == nil or L == nil then
    RK("Player position is not available.")
    return
  end
  Ni = H
  Vi = L
  ji = true
  hK()
  RK("Start Position = (" .. (tostring(Ni) .. (", " .. (tostring(Vi) .. ")"))))
end
function onVariant(H, L)
  if
    a and (
      Gi and (
        H ~= nil and (
          H["v1"] == "OnDialogRequest" and (type(H["v2"]) == "string" and H["v2"]:find("drop_item", 1, true))
        )
      )
    )
  then
    Oi = true
    return true
  end
  if H ~= nil then
    if a and (H["v1"] == "OnSpawn" and type(H["v2"]) == "string") then
      local L = H["v2"]:find("type|local", 1, true) ~= nil
      if not L then
        local G = tonumber(H["v2"]:match("netID|(%d+)"))
        local O = EK()
        if G ~= nil and O ~= nil then
          L = tonumber(O["netID"]) == G
        end
      end
      if L and (Ji or not zi) then
        hi = true
        Ji = true
      end
    end
    if a and (Ji and H["v1"] == "OnSetPos") then
      hi = true
    end
  end
  return false
end
function onSendPacketRaw(H)
  if a and ((b or Mi) and (H ~= nil and (tonumber(H["type"]) == 11 and u))) then
    local L, G = tonumber(H["x"]), tonumber(H["y"])
    if L ~= nil and (G ~= nil and bK(math["floor"](L / 32), math["floor"](G / 32))) then
      return true
    end
    if Mi then
      local H, L = WK()
      if H ~= nil and bK(H, L) then
        return true
      end
    end
  end
  return false
end
function onSendPacket(H, L)
  if type(L) == "string" then
    if a then
      local H = L:find("action|quit", 1, true) ~= nil
      local G = L:find("action|join_request", 1, true) ~= nil
      if H or G then
        Ji = true
        hi = false
        zi = false
        xK(false)
        PK("PAUSED - WAIT WORLD")
      end
    end
  end
  return false
end
function onGamePacket(H)
  if H ~= nil and (tonumber(H["type"]) == 26 and a) then
    if not Ji then
      RK("Provider Harvester paused - disconnected.")
    end
    Ji = true
    hi = false
    zi = false
    xK(false)
    PK("PAUSED - WAIT WORLD")
  end
  return false
end
local function m_()
  a = true
  local H = EK()
  local L = lK()
  if H == nil or L == "" or L == "EXIT" then
    n_("Enter a world first.")
    return
  end
  aK()
  IK()
  ci = nil
  yi = {}
  Pi = {}
  if b and not u then
    n_("Set Item Drop Position in Settings before starting Auto Collect.")
    return
  end
  if b and (Q < 1 or r < 0) then
    n_("Invalid Item Drop Position; use Settings > Current Tile.")
    return
  end
  T, Hi = Q, r
  gi = 0
  Mi = false
  Ri = false
  oi = {}
  Gi, Oi = false, false
  FK(b and "READY" or "AUTO COLLECT OFF")
  worldQueue = parseHarvestWorlds(harvestWorldText)
  if #worldQueue == 0 then
    worldQueue = { L }
    PK("CURRENT WORLD ONLY: " .. tostring(L))
  end
  ti = 0
  zK()
  selectWorldInQueue(1)
  RK(
    "Provider Harvester started: "
      .. (tostring(#worldQueue) .. (" world(s), selected provider " .. (tostring(selectedInfo["name"]) .. ".")))
  )
end
local X_ = false
local function Y_(H)
  if X_ then
    return
  end
  X_ = true
  pcall(function()
    safePHUIValue("PH_worlds", tostring(H or ""))
  end)
  X_ = false
end
function onValue(H, L, G)
  if PHUIWriteInProgress[L] then
    return
  end
  if L == "PH_worlds" and X_ then
    return
  end
  if L == "PH_worlds" or L == "PH_addworld" or L == "PH_removeworld" or L == "PH_clearworlds" then
    if a or U then
      if L == "PH_worlds" and tostring(G or "") ~= harvestWorldText then
        Y_(harvestWorldText)
      end
      RK("Stop the provider script before changing harvest worlds.")
      return
    end
    local H = harvestWorldText
    if L == "PH_worlds" then
      H = tostring(G or "")
    elseif L == "PH_clearworlds" then
      H = ""
    elseif L == "PH_addworld" then
      local L = lK()
      if not iK(L) then
        RK("Enter a world first.")
        return
      end
      local G = parseHarvestWorlds(harvestWorldText)
      local O = false
      for H, G in ipairs(G) do
        if worldNameFromEntry(G) == L then
          O = true
        end
      end
      if not O then
        G[#G + 1] = L
      end
      H = table["concat"](G, ",")
    else
      local L = parseHarvestWorlds(harvestWorldText)
      if #L > 0 then
        table["remove"](L)
      end
      H = table["concat"](L, ",")
    end
    if H ~= harvestWorldText then
      harvestWorldText = H
      persistProviderSettings()
    end
    if L ~= "PH_worlds" then
      Y_(harvestWorldText)
    end
    return
  end
  if L == "PH_returnstart" then
    B = (G == true or G == 1 or G == "true" or G == "1")
    persistProviderSettings()
    return
  end
  if L == "PH_licensekey" then
    local H = o(G)
    if U and H ~= o(m) then
      A = A + 1
      U = false
      local H = editToggle or EditToggle
      if H ~= nil then
        pcall(H, "PH_enable", false)
      end
      PK("STOPPED - LICENSE CHANGED")
    end
    m = H
    X = false
    oK("NOT VERIFIED")
    persistProviderSettings()
    return
  end
  if L == "PH_verifylicense" then
    runThread(function()
      yK(false)
    end)
    return
  end
  if L == "PH_clearlicense" then
    if U then
      A = A + 1
      U = false
      local H = editToggle or EditToggle
      if H ~= nil then
        pcall(H, "PH_enable", false)
      end
      PK("STOPPED - LICENSE CLEARED")
    end
    X = false
    m = ""
    R = ""
    P()
    persistProviderSettings()
    pcall(function()
      safePHUIValue("PH_licensekey", "")
    end)
    oK("NOT VERIFIED")
    RK("Saved Provider license cleared.")
    return
  end
  if L == "PH_enable" then
    if G == true then
      if a or U then
        return
      end
      A = A + 1
      local H = A
      local L = o(m)
      U = true
      X = false
      a = false
      xK(false)
      l_(false)
      PK("CHECKING LICENSE BEFORE START")
      runThread(function()
        local G = 0
        while Y and (U and (A == H and G < 30000)) do
          Sleep(100)
          G = G + 100
        end
        if not U or A ~= H then
          return
        end
        local O = false
        if not Y then
          O = yK(true)
        else
          oK("VERIFY BUSY - RETRY START")
        end
        if not U or A ~= H then
          return
        end
        if o(m) ~= L then
          O = false
          X = false
          oK("KEY CHANGED - RETRY START")
        end
        U = false
        if not O then
          a = false
          local H = editToggle or EditToggle
          if H ~= nil then
            pcall(H, "PH_enable", false)
          end
          xK(false)
          l_(false)
          PK("LICENSE NOT VALID - NOT STARTED")
          RK("Provider license not approved by server. Start blocked (" .. (tostring(f) .. ")."))
          return
        end
        m_()
      end)
    else
      A = A + 1
      U = false
      a = false
      worldTransitionPending = false
      l_(false)
      Mi = false
      Gi = false
      xK(false)
      Ji = false
      hi = false
      zi = false
      PK("STOPPED")
      safePHUIValue("PH_target", "NONE")
      RK("Provider Harvester stopped safely.")
    end
    return
  end
  if L == "PH_autocollect" then
    local H = G == true or G == 1 or G == "true" or G == "1"
    if Mi then
      RK("Please wait for the current item drop to finish.")
      pcall(function()
        safePHUIValue("PH_autocollect", b)
      end)
      return
    end
    if H and (a and (not u or Q < 1)) then
      RK("Set a valid Drop Position before enabling Auto Collect.")
      pcall(function()
        safePHUIValue("PH_autocollect", false)
      end)
      return
    end
    b = H
    if not H then
      ci = nil
      oi = {}
      Ri = false
      FK("AUTO COLLECT OFF")
    else
      FK("AUTO COLLECT ON")
    end
    local L = KK()
    BK()
    CK(L)
    return
  end
  if L == "PH_autocollectdisplay" then
    BK()
    return
  end
  if L == "PH_recovery" then
    if tostring(G or "") ~= Ti then
      pcall(function()
        safePHUIValue("PH_recovery", Ti)
      end)
    end
    return
  end
  if L == "PH_setchemdrop" then
    if Mi then
      RK("Please wait until the current item drop finishes.")
      return
    end
    local H, L = WK()
    if H ~= nil and L ~= nil then
      Q, r = H, L
      T, Hi = H, L
      u = true
      safePHUIValue("PH_chemdropx", tostring(H))
      safePHUIValue("PH_chemdropy", tostring(L))
      dK()
      KK()
      RK("Item drop stand tile set; drop target is one tile RIGHT.")
    else
      RK("Enter a world before setting item drop position.")
    end
    return
  end
  if L == "PH_chemdropx" or L == "PH_chemdropy" then
    if Mi then
      RK("Please wait until the current item drop finishes.")
      pcall(function()
        safePHUIValue(L, tostring(L == "PH_chemdropx" and Q or r))
      end)
      return
    end
    local H = tonumber(G)
    if H ~= nil then
      H = math["floor"](H)
      if H >= 0 and H <= 999 then
        if L == "PH_chemdropx" then
          Q = H
        else
          r = H
        end
        T, Hi = Q, r
        u = true
        dK()
        KK()
      end
    else
      pcall(function()
        safePHUIValue(L, tostring(L == "PH_chemdropx" and Q or r))
      end)
    end
    return
  end
  if L == "PH_chemthreshold" then
    local H = tonumber(G)
    if H ~= nil then
      e = math["max"](1, math["min"](200, math["floor"](H)))
      safePHUIValue("PH_chemthreshold", tostring(e))
      KK()
    end
    return
  end
  if L == "PH_chemdropdelay" then
    local H = tonumber(G)
    if H ~= nil then
      p = math["max"](0, math["min"](5000, math["floor"](H)))
      safePHUIValue("PH_chemdropdelay", tostring(p))
      KK()
    end
    return
  end
  if L == "PH_chemdropdisplay" then
    local H = u and (tostring(Q) .. (", " .. tostring(r))) or "NOT SET"
    if tostring(G or "") ~= H then
      dK()
    end
    return
  end
  if L == "PH_chemstatus" then
    if tostring(G or "") ~= Li then
      pcall(function()
        safePHUIValue("PH_chemstatus", Li)
      end)
    end
    return
  end
  if L == "PH_fastcollectgap" then
    local H = tonumber(G)
    if H ~= nil then
      S = math["max"](30, math["min"](500, math["floor"](H)))
      safePHUIValue("PH_fastcollectgap", tostring(S))
      CK(KK())
    end
    return
  end
  if L == "PH_delay" then
    local H = tonumber(G)
    if H ~= nil then
      H = math["floor"](H)
      if H < 0 then
        H = 0
      end
      if H > 5000 then
        H = 5000
      end
      C = H
      safePHUIValue("PH_delay", tostring(C))
      CK(persistProviderSettings())
    end
    return
  end
end
applyHook()
aK()
runThread(function()
  xK(false)
  PK("STOPPED")
  hK()
  zK()
  s_()
  updateWorldDisplay()
  dK()
  FK(b and "IDLE" or "AUTO COLLECT OFF")
  BK()
  IK()
  if m ~= "" then
    pcall(function()
      safePHUIValue("PH_licensekey", m)
    end)
    oK("SAVED - CHECK ON START")
  else
    oK("NOT VERIFIED")
  end
  while true do
    if not a then
      Sleep(200)
    else
      if worldTransitionPending then
        processWorldTransition()
      elseif not JK() then
        Sleep(200)
      else
        xK(d)
        PK("SCANNING")
        if b and (Ri or uK()) then
          if not W_(Ri) then
            VK(650)
          end
        elseif b and ci ~= nil then
          if not E_(nil, false) then
            VK(500)
          end
        elseif pi ~= nil then
          J_()
        else
          local H = XK()
          local L = V_(H)
          if #H > 0 then
            finalCleanupAttempts = 0
            finalDropFailures = 0
          end
          if #H == 0 then
            if next(qK()) == nil then
              PK("WAIT WORLD TILES")
              VK(300)
            else
              PK("VERIFY NO READY PROVIDERS")
              VK(220)
              if a and NK() then
                local H = XK()
                if #H > 0 then
                  PK("PROVIDERS FOUND - CONTINUE")
                elseif next(qK()) == nil then
                  PK("WAIT WORLD TILES")
                else
                  if not b then
                    PK("PROVIDERS FINISHED - NO COLLECT")
                    finishCurrentWorld(false)
                  else
                    local H, L = true, {}
                    if b and #yi > 0 then
                      H = E_(nil, true)
                      L = g_(nil, true)
                    end
                    if not H or #L > 0 then
                      finalCleanupAttempts = finalCleanupAttempts + 1
                      if finalCleanupAttempts < 2 then
                        PK("FINAL PICKUP RETRY 1/2")
                        VK(250)
                      else
                        if b and (Ri or uK()) then
                          if W_(true) then
                            finishCurrentWorld(true)
                          else
                            n_("Final item drop failed in " .. (tostring(Di) .. ". Items are in backpack."))
                          end
                        else
                          finishCurrentWorld(true)
                        end
                      end
                    elseif b and (Ri or uK()) then
                      if W_(true) then
                        finishCurrentWorld(false)
                      else
                        finalDropFailures = finalDropFailures + 1
                        if finalDropFailures >= 2 then
                          n_("Final item drop unconfirmed in " .. (tostring(Di) .. ". Check backpack."))
                        else
                          PK("FINAL ITEM DROP RETRY")
                          VK(300)
                        end
                      end
                    else
                      finishCurrentWorld(false)
                    end
                  end
                end
              end
            end
          elseif #L > 0 then
            local H = YK(L)
            if H == nil then
              PK("ROW TARGET MISSING - RESCAN")
              VK(500)
            else
              safePHUIValue(
                "PH_target",
                H["name"] .. (
                    " 5x5 BATCH " .. (tostring(H["y"]) .. (" @ " .. (tostring(H["x"]) .. (", " .. tostring(H["y"])))))
                  )
              )
              if UK(H["x"], H["y"]) then
                local L, G = t_(H)
                if not L then
                  if not NK() then
                    Ji = true
                    xK(false)
                    PK("PAUSED - WAIT WORLD")
                  else
                    vK("BATCH ERROR - RETRY")
                    PK("BATCH ERROR - RETRY")
                    VK(1500)
                  end
                elseif L then
                  if b then
                    E_(H, false)
                  end
                  Sleep(G and 25 or 100)
                else
                  Sleep(100)
                end
              else
                if not NK() then
                  Ji = true
                  xK(false)
                  PK("PAUSED - WAIT WORLD")
                else
                  PK("PATH RETRY - RESCAN")
                  Sleep(700)
                end
              end
            end
          else
            local L = nil
            local G = math["huge"]
            for H, O in ipairs(H) do
              local M = i_(O)
              local R = ei[M] or 0
              if ui[M] ~= nil and R < G then
                L = O
                G = R
              end
            end
            if L == nil then
              PK("CLEANUP LIST CHANGED - RESCAN")
              VK(650)
            else
              local H, G = z_(L)
              if not H then
                if not NK() then
                  Ji = true
                  xK(false)
                  PK("PAUSED - WAIT WORLD")
                else
                  vK("CLEANUP ERROR - RETRY")
                  PK("CLEANUP ERROR - RETRY")
                  VK(1500)
                end
              elseif G then
                if b then
                  E_(L, false, 0)
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
