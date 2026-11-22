setMinimum("6.1.2")
local S =
  "https://script.google.com/macros/s/AKfycbxeBzpOUzvcRDkX-4eR8uioFbAUDsepIQc26kmxUkXt6YOjBxFdVsOE0zzvxYSprl5knA/exec"
local F = "AutoCollectToDropLicense"
local l = "license_key"
local y = nil
local s = ""
local function r(S)
  S = tostring(S or "")
  S = S:gsub("%s+", "")
  return S:upper()
end
local function c(S)
  S = r(S)
  return S:match("^[A-Z]%d%d%d%d%d%d%d$") ~= nil
end
local function b()
  local S = pcall(function()
    local S = nil
    if type(require) == "function" then
      local F, l = pcall(require, "preferences")
      if F and l ~= nil then
        S = l
      end
    end
    if S == nil and type(Preferences) == "table" then
      S = Preferences
    end
    if S == nil then
      return
    end
    if type(S["new"]) == "function" then
      local l = S:new(F)
      y = l or S
    else
      y = S
    end
    if y ~= nil and type(y["load"]) == "function" then
      y:load()
    end
    if y ~= nil and type(y["get"]) == "function" then
      s = r(y:get(l, ""))
    end
  end)
  if not S then
    y = nil
    s = ""
  end
end
local function U(S)
  if y == nil then
    return false
  end
  local F = pcall(function()
    y:set(l, r(S))
    y:save()
  end)
  return F
end
local function q()
  if y == nil then
    return false
  end
  local S = pcall(function()
    y:set(l, "")
    y:save()
  end)
  return S
end
b()
local k = "AutoCollectToDropAllSettingsV19.json"
ACD19_LEGACY_MW_PREF_NAME = "AutoCollectToDropMultiWorldV11"
ACD19_MW_SCHEMA = "19"
ACD19_MW_KEYS = {
  "worlds",
  "dropworld",
  "dropx",
  "dropy",
  "pickupdelay",
  "acktimeout",
  "batchmax",
  "items",
  "droptotal",
  "license_key",
}
local w = nil
ACD19_mwPreferenceModule = nil
local j = {}
ACD19_mwSettingsRestored = false
ACD19_mwSaveState = "UNAVAILABLE"
ACD19_guardedUIWrites = {}
function ACD19_safeEditValue(S, F)
  if ACD19_guardedUIWrites[S] then
    return
  end
  ACD19_guardedUIWrites[S] = true
  pcall(function()
    editValue(S, F)
  end)
  ACD19_guardedUIWrites[S] = nil
end
function ACD19_safeSetStartToggle(S)
  if ACD19_guardedUIWrites["ACD_enable"] then
    return
  end
  ACD19_guardedUIWrites["ACD_enable"] = true
  local F = editToggle or EditToggle
  if F ~= nil then
    pcall(F, "ACD_enable", S == true)
  end
  ACD19_guardedUIWrites["ACD_enable"] = nil
end
function ACD19_setAutoSaveStatus(S)
  if ACD19_mwSaveState == S then
    return
  end
  ACD19_mwSaveState = S
  ACD19_safeEditValue("ACD_autosave", S)
end
local function N(S)
  return ((tostring(S or "")):upper()):gsub("%s+", "")
end
local function O(S)
  local F, l = {}, {}
  local y = (tostring(S or "")):gsub("[;\r\n]", ",")
  for S in ((y .. ",")):gmatch("([^,]*),") do
    local y = N(S)
    if y ~= "" and (y ~= "EXIT" and not l[y]) then
      l[y] = true
      F[#F + 1] = y
      if #F >= 30 then
        break
      end
    end
  end
  return F
end
local function I(S)
  return table["concat"](S or {}, ", ")
end
local function a(S)
  local F, l = {}, {}
  local y = (tostring(S or "")):gsub("[;\r\n]", ",")
  for S in ((y .. ",")):gmatch("([^,]*),") do
    local y = tonumber(S:match("^%s*(%d+)%s*$"))
    if y ~= nil and (y > 0 and (y <= 65535 and not l[y])) then
      y = math["floor"](y)
      l[y] = true
      F[#F + 1] = y
      if #F >= 30 then
        break
      end
    end
  end
  return F
end
local function B(S)
  local F = {}
  for S, l in ipairs(S or {}) do
    F[#F + 1] = tostring(l)
  end
  return table["concat"](F, ", ")
end
function ACD19_mwNewPreferences(S)
  if ACD19_mwPreferenceModule == nil or type(ACD19_mwPreferenceModule["new"]) ~= "function" then
    return nil
  end
  local F, l = pcall(function()
    return ACD19_mwPreferenceModule:new(S)
  end)
  if not F then
    return nil
  end
  if
    l == nil
    or type(l["get"]) ~= "function"
    or type(l["set"]) ~= "function"
    or type(l["save"]) ~= "function"
    or type(l["load"]) ~= "function"
  then
    return nil
  end
  return l
end
local function h()
  if type(require) == "function" then
    local S, F = pcall(require, "preferences")
    if S and type(F) == "table" then
      ACD19_mwPreferenceModule = F
    end
  end
  if ACD19_mwPreferenceModule == nil and type(Preferences) == "table" then
    ACD19_mwPreferenceModule = Preferences
  end
  local S = ACD19_mwNewPreferences(ACD19_LEGACY_MW_PREF_NAME)
  if S ~= nil then
    pcall(function()
      S:load()
      for F, l in ipairs(ACD19_MW_KEYS) do
        if l ~= "license_key" then
          j[l] = S:get(l, "")
        end
      end
    end)
  end
  j["license_key"] = s or ""
  local F = ACD19_mwNewPreferences(k)
  if F == nil then
    return
  end
  local l = pcall(function()
    F:load()
  end)
  if not l then
    return
  end
  w = F
  local y, c = pcall(function()
    return F:get("schema", "")
  end)
  if y and tostring(c) == ACD19_MW_SCHEMA then
    local S = pcall(function()
      for S, l in ipairs(ACD19_MW_KEYS) do
        j[l] = F:get(l, j[l] or "")
      end
    end)
    if S then
      ACD19_mwSettingsRestored = true
      s = r(j["license_key"])
    end
  end
end
local function E(S, F)
  j[S] = tostring(F)
  if w == nil then
    ACD19_setAutoSaveStatus("SAVE UNAVAILABLE")
    return false
  end
  local l = pcall(function()
    if w:set("schema", ACD19_MW_SCHEMA) == false then
      error("schema write failed")
    end
    for S, F in ipairs(ACD19_MW_KEYS) do
      if w:set(F, tostring(j[F] or "")) == false then
        error("settings write failed: " .. F)
      end
    end
    if w:save() == false then
      error("settings save failed")
    end
  end)
  if l then
    local S, F = pcall(function()
      local S = ACD19_mwNewPreferences(k)
      if S == nil then
        return false
      end
      if S:load() == false then
        return false
      end
      if tostring(S:get("schema", "")) ~= ACD19_MW_SCHEMA then
        return false
      end
      for F, l in ipairs(ACD19_MW_KEYS) do
        if tostring(S:get(l, "")) ~= tostring(j[l] or "") then
          return false
        end
      end
      return true
    end)
    l = S and F == true
  end
  ACD19_setAutoSaveStatus(l and "SAVED - REOPEN SAFE" or "SAVE FAILED")
  return l
end
local function L(S, F, l, y)
  local s = math["floor"](tonumber(j[S]) or F)
  return math["min"](y, math["max"](l, s))
end
h()
local m = I(O(j["worlds"]))
local i = B(a(j["items"]))
local H = N(j["dropworld"])
local K = L("dropx", 0, -1, 999)
local X = L("dropy", 0, -1, 999)
local x = L("pickupdelay", 0, 0, 1000)
local n = L("acktimeout", 900, 300, 10000)
local J = L("batchmax", 2, 1, 2)
local z = L("droptotal", 0, 0, 1000000000)
local g = "Auto Collect V6.1 Exact Tile Mixed Pickup"
local P = UserInterface["new"](g, "Inventory")
P:addLabelApp("Auto Collect V6.1 Exact Tile Mixed Pickup", "Inventory")
P:addInputString("License Key", s, "A1234567", "A1234567", nil, "ACD_licensekey")
P:addButton("Verify License", "ACD_verifylicense")
P:addButton("Clear Saved License", "ACD_clearlicense")
P:addDisplayList("License Status", "NOT VERIFIED", "ACD_licensestatus")
P:addToggle("Start / Stop", false, "ACD_enable")
P:addItemPicker("Add Collect Item", "Dirt", "2", "ACD_itempicker")
P:addInputString("Selected Items (view only)", "NONE", "Selected item IDs", "List", nil, "ACD_selecteditem")
P:addButton("Remove Last Collect Item", "ACD_removeitem")
P:addButton("Clear Collect Items", "ACD_clearitems")
P:addInputString("Total Drop Per Item (0 = until worlds empty)", tostring(z), "Items", "210", nil, "ACD_droptotal")
P:addInputString("Drop Progress Per Item (view only)", "NONE", "Dropped / goal", "Status", nil, "ACD_dropprogress")
local G = P:addDialog("Settings", "Item IDs, collection worlds, shared storage, delays", {})
P:addChildTooltip(
  G["menu"],
  "Selected Items",
  "Use Add Collect Item on the main screen, or enter comma-separated item IDs here. Items are saved; changes take effect on next Start.",
  "Inventory",
  true
)
P:addChildInputString(
  G["menu"],
  "Collect Item IDs (comma-separated)",
  i,
  "e.g. 2, 3, 4",
  "2, 3, 4",
  "Inventory",
  "ACD_itemlist"
)
P:addChildTooltip(
  G["menu"],
  "Collection Worlds",
  "List worlds in order, separated by commas. Add Current World / Remove Last World edit the list. Changes made while running apply on the next Start.",
  "Inventory",
  true
)
P:addChildInputString(
  G["menu"],
  "Collection Worlds (comma-separated)",
  m,
  "World 1, World 2, ...",
  "FARM1, FARM2",
  "Inventory",
  "ACD_worldlist"
)
P:addChildButton(G["menu"], "Add Current World", "ACD_addworld")
P:addChildButton(G["menu"], "Remove Last World", "ACD_removeworld")
P:addChildInputString(G["menu"], "Shared Storage World", H, "World", "STORAGE", "Inventory", "ACD_dropworld")
P:addChildButton(G["menu"], "Storage World = Current World", "ACD_setdropworld")
P:addChildInputInt(G["menu"], "Drop Position X (Standing Tile)", tostring(K), "X", "0", "Inventory", "ACD_dropx")
P:addChildInputInt(G["menu"], "Drop Position Y (Standing Tile)", tostring(X), "Y", "0", "Inventory", "ACD_dropy")
P:addChildButton(G["menu"], "Drop Position = Current Tile", "ACD_setdrop")
P:addChildTooltip(
  G["menu"],
  "Storage behavior",
  "0 means unlimited: collect selected items until each world is empty (3 checks). If a full backpack stack blocks more items of its type, store only that type and resume the SAME world. Otherwise batch full types together. Final partial stacks are stored when all worlds finish.",
  "Inventory",
  false
)
P:addChildTooltip(
  G["menu"],
  "Run Mode: Single Pass",
  "Visit each collection world once in order. After the final world is empty, store remaining selected items and stop automatically. Press Start again for a new round.",
  "Inventory",
  true
)
P:addChildInputInt(G["menu"], "After Pickup Delay", tostring(x), "ms", "0", "Inventory", "ACD_pickupdelay")
P:addChildInputInt(G["menu"], "Batch ACK Timeout", tostring(n), "ms", "900", "Inventory", "ACD_acktimeout")
P:addChildInputInt(G["menu"], "Max Pickup Batch (max 2)", tostring(J), "items", "2", "Inventory", "ACD_batchmax")
P:addChildTooltip(
  G["menu"],
  "Persistent Auto Save",
  "Changes save immediately when an input is committed or a selection button is pressed. No Start is needed. Check Settings Auto Save on the main menu. Start always reopens OFF.",
  "Inventory",
  false
)
P:addDisplayList("Items Configured", tostring(#a(i)), "ACD_itemcount")
P:addDisplayList("Worlds Configured", tostring(#O(m)), "ACD_worldcount")
P:addDisplayList("Current Collection World", "NOT STARTED", "ACD_worldprogress")
P:addDisplayList("Shared Storage World", H ~= "" and H or "NOT SET", "ACD_storageprogress")
P:addDisplayList("Server Pace", "CAUTIOUS (2)", "ACD_serverpace")
P:addDisplayList("Shared Storage Trips", "0", "ACD_loops")
P:addDisplayList("Status", "STOPPED", "ACD_status")
P:addDisplayList("Selected Inventory", "NONE", "ACD_inventory")
P:addDisplayList("Dropped Objects Found", "0", "ACD_objects")
P:addDisplayList("Skipped Blocked / Unreachable", "0", "ACD_exactskipped")
P:addDisplayList(
  "Settings Auto Save",
  w == nil and "UNAVAILABLE" or (ACD19_mwSettingsRestored and "RESTORED" or "READY - SAVES ON EDIT"),
  "ACD_autosave"
)
pcall(function()
  addCategory(g, "Inventory")
end)
local u = pcall(function()
  addIntoModule(P:generateJSON(), g)
end)
if not u then
  addIntoModule(P:generateJSON())
end
local C = false
local D = s
local f = false
local R = false
local Y = "NOT VERIFIED"
local V = false
local t = 0
local W = 0
local Q = a(i)
local T, A = {}, {}
local e = 200
local o = z
local p = z
local v = {}
local M = false
local Z = {}
local d = x
local SS = n
local FS = J
local lS = math["min"](2, J)
local yS = 0
local sS = 0
local rS = ""
local cS = O(m)
local bS = {}
local US = 1
local qS = false
local kS = 0
local wS = 0
local jS = H
local NS = K
local OS = X
local IS = 0
local aS = 0
local BS = "STOPPED"
local hS = true
local ES = 0
local LS = 1
ACD_EXACT_skippedByWorld = {}
ACD_EXACT_skipCountByWorld = {}
ACD_EXACT_totalSkipped = 0
local mS = 15000
local iS = 9000
local HS = 1300
local KS = 450
local XS = 1100
local xS = 100
local nS = 700
local JS = 6
local zS = 2200
local gS = 350
local PS = 6000
local GS = 25
local uS = 1000
local CS = 60
local DS = 80
local fS = 25
local RS = 1
local YS = 180
local VS = 450
local tS = 90
local WS = 1800
local QS = 2000
local TS = 2200
local AS = 2
local eS = 350
local oS = 100
local pS = 250
local vS = 1200
local MS = 4
local ZS = 2600
local dS = 300
local S0 = 350
ACD19_DROP_SECOND_PATH_STABLE_MS = 500
ACD19_DROP_PRE_PACKET_STABLE_MS = 200
ACD19_DROP_STABLE_POLL_MS = 100
local F0 = false
local l0 = false
local y0 = false
local s0 = false
local r0 = nil
local c0 = 0
local b0 = false
ACD19_storageEntryConfirmed = false
ACD19_storageEntryConfirmedX = nil
ACD19_storageEntryConfirmedY = nil
local U0 = 0
local q0 = {}
local k0 = 2
local function w0(S)
  pcall(function()
    growtopia["notify"](tostring(S))
  end)
end
local function j0(S)
  Y = tostring(S or "")
  pcall(function()
    ACD19_safeEditValue("ACD_licensestatus", Y)
  end)
end
local function N0(S)
  S = tostring(S or "")
  S = S:gsub("\n", "\r\n")
  S = S:gsub("([^%w%-_%.~])", function(S)
    return string["format"]("%%%02X", string["byte"](S))
  end)
  return S
end
local function O0()
  local S = ""
  if type(getDiscordID) == "function" then
    local F, l = pcall(getDiscordID)
    if F and l ~= nil then
      S = tostring(l)
    end
  elseif getDiscordID ~= nil then
    S = tostring(getDiscordID)
  end
  S = ((tostring(S or "")):gsub("^%s+", "")):gsub("%s+$", "")
  if S == "" or S == "nil" or S == "0" then
    local F = GetLocal or getLocal
    if F ~= nil then
      local l, y = pcall(F)
      if l and (y ~= nil and y["name"] ~= nil) then
        S = tostring(y["name"])
        S = (S:gsub("^%s+", "")):gsub("%s+$", "")
      end
    end
  end
  return S
end
local function I0(F)
  if R then
    return false
  end
  R = true
  f = false
  local l = r(D)
  D = l
  pcall(function()
    ACD19_safeEditValue("ACD_licensekey", l)
  end)
  if not c(l) then
    j0("INVALID KEY FORMAT")
    R = false
    if not F then
      w0("License must be 1 letter + 7 numbers, for example A1234567.")
    end
    return false
  end
  local y = O0()
  if y == "" then
    j0("NO CLIENT ID")
    R = false
    if not F then
      w0("Could not read a client ID. Connect Growlauncher/Discord or enter the game first.")
    end
    return false
  end
  j0("CHECKING...")
  W = W + 1
  local b = tostring(W)
    .. ("_" .. tostring((os and type(os["time"]) == "function") and os["time"]() or math["random"](100000, 999999)))
  local q = S .. ("?key=" .. (N0(l) .. ("&id=" .. (N0(y) .. ("&nonce=" .. N0(b))))))
  local k, w, j = pcall(fetch, q)
  if not k then
    j0("SERVER ERROR")
    R = false
    if not F then
      w0("License server request failed.")
    end
    return false
  end
  w = tostring(w or "")
  w = (w:gsub("^%s+", "")):gsub("%s+$", "")
  if w:find("OK|PERMANENT", 1, true) then
    f = true
    j0("VERIFIED - PERMANENT")
    if U(l) then
      s = l
    end
    R = false
    if not F then
      w0("License verified and saved.")
    end
    return true
  end
  local N = w
  if N == "" then
    local S = tostring(j or "")
    if S ~= "" and S ~= "nil" then
      N = S
    else
      N = "NO RESPONSE - UPDATE GOOGLE APPS SCRIPT TO HTMLSERVICE"
    end
  end
  if N:find("DENY|DISABLED", 1, true) then
    j0("DISABLED")
  elseif N:find("DENY|BOUND_TO_OTHER_USER", 1, true) then
    j0("BOUND TO OTHER USER")
  elseif N:find("DENY|INVALID_KEY", 1, true) then
    j0("INVALID KEY")
  elseif N:find("DENY|BAD_KEY_FORMAT", 1, true) then
    j0("BAD KEY FORMAT")
  elseif N:find("DENY|NO_ID", 1, true) then
    j0("NO CLIENT ID")
  else
    j0("CHECK FAILED")
  end
  R = false
  if not F then
    w0("License denied: " .. N)
  end
  return false
end
local function a0(S)
  S = tostring(S)
  if BS ~= S then
    BS = S
    ACD19_safeEditValue("ACD_status", S)
  end
end
local function B0()
  local S = #bS
  if C and (S > 0 and US <= S) then
    pcall(function()
      ACD19_safeEditValue("ACD_worldprogress", tostring(US) .. ("/" .. (tostring(S) .. (" - " .. tostring(rS)))))
    end)
  elseif S > 0 and US > S then
    pcall(function()
      ACD19_safeEditValue("ACD_worldprogress", "ALL WORLDS SCANNED")
    end)
  else
    pcall(function()
      ACD19_safeEditValue("ACD_worldprogress", "NOT STARTED")
    end)
  end
  pcall(function()
    ACD19_safeEditValue("ACD_worldcount", tostring(#cS))
  end)
  pcall(function()
    ACD19_safeEditValue("ACD_storageprogress", jS ~= "" and jS or "NOT SET")
  end)
end
local function h0()
  local S = I(cS)
  pcall(function()
    ACD19_safeEditValue("ACD_worldlist", S)
  end)
  pcall(function()
    ACD19_safeEditValue("ACD_worldcount", tostring(#cS))
  end)
  E("worlds", S)
end
local function E0(S, F)
  local l = editToggle or EditToggle
  if l ~= nil then
    pcall(l, S, F == true)
  end
end
local L0 = nil
local m0 = nil
local function i0(S)
  S = S == true
  if S == L0 then
    return
  end
  L0 = S
  E0("ModFly", S)
end
local function H0(S)
  S = S == true
  if S == m0 then
    return
  end
  m0 = S
  E0("Enable AutoCollect", S)
  E0("Autocollect", S)
end
local function K0(S)
  S = tostring(S or "")
  S = S:gsub("%s+", "")
  return S:upper()
end
ACD61_activeDoorRoute = ""
function ACD61_physicalWorld()
  local S, F = pcall(function()
    if type(GetWorldName) == "function" then
      return GetWorldName()
    elseif type(getCurrentWorldName) == "function" then
      return getCurrentWorldName()
    end
    return ""
  end)
  if not S then
    return ""
  end
  return K0(F)
end
local function X0()
  local S = ACD61_physicalWorld()
  if ACD61_activeDoorRoute ~= "" and S ~= "" then
    local F = ACD61_activeDoorRoute:match("^([^|]+)|")
    if F == S then
      return ACD61_activeDoorRoute
    end
  end
  return S
end
function ACD61_parseWorldRoute(S)
  S = K0(S)
  if S == "" then
    return "", nil
  end
  local F, l = S:match("^([^|]+)|([^|]+)$")
  if F then
    return F, l
  end
  if S:find("|", 1, true) then
    return "", nil
  end
  return S, nil
end
local function x0(S, F)
  S = K0(S)
  F = K0(F)
  return S ~= "" and (F ~= "" and S == F)
end
local function n0()
  return x0(rS, jS) and x0(X0(), jS)
end
local function J0()
  return x0(X0(), jS) and (n0() or y0)
end
local function z0(S, F)
  S = tonumber(S)
  F = tonumber(F)
  if S == nil or F == nil then
    return false
  end
  local l = math["min"](NS, IS) - LS
  local y = math["max"](NS, IS) + LS
  return S >= l and (S <= y and math["abs"](F - OS) <= LS)
end
local function g0()
  local S = GetLocal or getLocal
  if S == nil then
    return nil
  end
  local F, l = pcall(S)
  if F then
    return l
  end
  return nil
end
local function P0()
  local S = GetTiles or getTiles
  if S == nil then
    return nil
  end
  local F, l = pcall(S)
  if F and type(l) == "table" then
    return l
  end
  return nil
end
local function G0()
  local S = GetObjectList or getObjectList
  if S == nil then
    return {}
  end
  local F, l = pcall(S)
  if F and type(l) == "table" then
    return l
  end
  return {}
end
local function u0(S)
  local F, l = pcall(function()
    if growtopia ~= nil and type(growtopia["checkInventoryCount"]) == "function" then
      return growtopia["checkInventoryCount"](S)
    end
    local F = GetInventory or getInventory
    if F == nil then
      return 0
    end
    local l = F()
    for F, l in pairs(l or {}) do
      if tonumber(l["id"]) == tonumber(S) then
        return tonumber(l["amount"]) or 0
      end
    end
    return 0
  end)
  if not F then
    return 0
  end
  return tonumber(l) or 0
end
local function C0(S)
  local F, l = pcall(function()
    if growtopia ~= nil and type(growtopia["getItemName"]) == "function" then
      return growtopia["getItemName"](S)
    end
    if type(getItemInfoByID) == "function" then
      local F = getItemInfoByID(S)
      if F ~= nil then
        return F["name"]
      end
    end
    return nil
  end)
  if F and (l ~= nil and tostring(l) ~= "") then
    return tostring(l)
  end
  return "Item " .. tostring(S)
end
local function D0()
  if #T > 0 and C then
    return T
  end
  return Q
end
local function f0()
  local S = 0
  for F, l in ipairs(D0()) do
    S = S + u0(l)
  end
  return S
end
local function R0(S)
  if p <= 0 then
    return nil
  end
  return math["max"](0, p - (v[S] or 0))
end
local function Y0()
  if p <= 0 or #T == 0 then
    return false
  end
  for S, F in ipairs(T) do
    if (v[F] or 0) < p then
      return false
    end
  end
  return true
end
local function V0(S)
  local F = u0(S)
  if F >= e then
    return false
  end
  local l = R0(S)
  return l == nil or F < l
end
local function t0()
  for S, F in ipairs(D0()) do
    if u0(F) >= e then
      return F
    end
  end
  return nil
end
local function W0(S)
  local F = math["max"](0, u0(S))
  local l = R0(S)
  if l == nil then
    return F
  end
  return math["min"](F, l)
end
local function Q0()
  local S = 0
  for F, l in ipairs(T) do
    S = S + W0(l)
  end
  return S
end
local function T0()
  if #T == 0 then
    return false
  end
  for S, F in ipairs(T) do
    if V0(F) then
      return false
    end
  end
  return Q0() > 0
end
local function A0()
  if p <= 0 then
    return "UNLIMITED"
  end
  local S = {}
  for F, l in ipairs(T) do
    local y = R0(l)
    if y and y > 0 then
      S[#S + 1] = tostring(l) .. (":" .. tostring(y))
    end
  end
  return #S == 0 and "ALL COMPLETE" or table["concat"](S, ", ")
end
local function e0()
  local S = (#T > 0 and C) and T or Q
  local F = {}
  for S, l in ipairs(S) do
    F[#F + 1] = tostring(l) .. (": " .. (tostring(v[l] or 0) .. (" / " .. (p > 0 and tostring(p) or "unlimited"))))
  end
  pcall(function()
    ACD19_safeEditValue("ACD_dropprogress", #F > 0 and table["concat"](F, " | ") or "NONE")
  end)
end
local function o0()
  if M then
    return
  end
  M = true
  Z = {}
  for S, F in ipairs(T) do
    Z[F] = u0(F)
  end
end
local function p0()
  if not M then
    return
  end
  local S = false
  for F, l in ipairs(T) do
    local y = u0(l)
    local s = Z[l]
    if s ~= nil and y < s then
      v[l] = (v[l] or 0) + (s - y)
      S = true
    end
    Z[l] = y
  end
  if S then
    e0()
  end
end
local function v0()
  p0()
  M = false
  Z = {}
  ACD19_storageEntryConfirmed = false
  ACD19_storageEntryConfirmedX, ACD19_storageEntryConfirmedY = nil, nil
end
local function M0()
  if #Q == 0 then
    return "NONE"
  end
  local S = {}
  for F, l in ipairs(Q) do
    S[#S + 1] = C0(l) .. (" (" .. (tostring(l) .. ")"))
  end
  return table["concat"](S, ", ")
end
local function Z0()
  pcall(function()
    ACD19_safeEditValue("ACD_selecteditem", M0())
  end)
  pcall(function()
    ACD19_safeEditValue("ACD_itemcount", tostring(#Q))
  end)
end
local function d0()
  local S = B(Q)
  pcall(function()
    ACD19_safeEditValue("ACD_itemlist", S)
  end)
  E("items", S)
  Z0()
  e0()
end
local ST = nil
local function FT()
  local S = D0()
  local F = "NONE"
  if #S > 0 then
    local l = {}
    for S, F in ipairs(S) do
      l[#l + 1] = tostring(F) .. (":" .. tostring(u0(F)))
    end
    F = table["concat"](l, "  |  ")
  end
  if F ~= ST then
    ST = F
    pcall(function()
      ACD19_safeEditValue("ACD_inventory", F)
    end)
  end
end
local function lT()
  ACD19_safeEditValue("ACD_loops", tostring(ES))
end
local function yT()
  local S = g0()
  if S == nil then
    return nil, nil
  end
  return S["posX"] // 32, S["posY"] // 32
end
local function sT(S, F)
  local l, y = yT()
  return l == S and y == F
end
local rT = ""
local cT = ""
local bT = ""
local function UT(S)
  local F = ACD61_physicalWorld()
  local l = K0(S)
  local y, s = ACD61_parseWorldRoute(l)
  if y == "" then
    return false
  end
  if F ~= cT then
    cT = F
    rT = ""
    bT = ""
    ACD61_activeDoorRoute = ""
  end
  local r = g0()
  if F ~= y or r == nil then
    return false
  end
  if s and ACD61_activeDoorRoute ~= l then
    return false
  end
  if not s and ACD61_activeDoorRoute ~= "" then
    return false
  end
  if tonumber(r["posX"]) == nil or tonumber(r["posY"]) == nil then
    return false
  end
  if rT == y then
    return true
  end
  local c = P0()
  if c ~= nil and next(c) ~= nil then
    rT = y
    return true
  end
  return false
end
local function qT(S)
  local F = K0(S)
  return bT == F and UT(F)
end
local function kT(S, F, l)
  local y = K0(S)
  if qT(y) then
    return true
  end
  local s = 0
  local r = 0
  local c, b = nil, nil
  a0("WAIT PLAYER READY " .. tostring(y))
  while C and s < F do
    if UT(y) then
      local S = g0()
      local F = S and tonumber(S["posX"])
      local U = S and tonumber(S["posY"])
      if F ~= nil and U ~= nil then
        if c == F and b == U then
          r = r + xS
        else
          r = 0
          c, b = F, U
        end
        if r >= nS and s >= (l or 0) then
          bT = y
          return C and qT(y)
        end
      end
    else
      r = 0
      c, b = nil, nil
    end
    Sleep(xS)
    s = s + xS
  end
  return false
end
local function wT(S, F)
  S = K0(S)
  if S == "" then
    return false
  end
  F = F or mS
  if S ~= jS then
    ACD19_storageEntryConfirmed = false
    ACD19_storageEntryConfirmedX = nil
    ACD19_storageEntryConfirmedY = nil
  end
  local l, y = ACD61_parseWorldRoute(S)
  if l == "" then
    a0("INVALID WORLD OR DOOR ID")
    return false
  end
  if y then
    if qT(S) then
      i0(true)
      return true
    end
    if ACD61_physicalWorld() ~= l or ACD61_activeDoorRoute ~= "" then
      ACD61_activeDoorRoute = ""
      rT = ""
      bT = ""
      L0 = nil
      a0("WARP BASE " .. l)
      local S, F = pcall(function()
        return growtopia["warpTo"](l)
      end)
      if not S or F == false then
        return false
      end
    end
    if not kT(l, F, XS) then
      return false
    end
    if not C or ACD61_physicalWorld() ~= l then
      return false
    end
    a0("ENTER DOOR " .. S)
    rT = ""
    bT = ""
    local y, s = pcall(function()
      return SendPacket(3, "action|join_request\nname|" .. (S .. "\ninvitedWorld|0"))
    end)
    if not y or s == false then
      return false
    end
    Sleep(1400)
    if not C or ACD61_physicalWorld() ~= l then
      return false
    end
    if not kT(l, F, XS) then
      return false
    end
    ACD61_activeDoorRoute = S
    rT = ""
    bT = ""
    local r = kT(S, F, XS)
    if r then
      i0(true)
    end
    return r
  end
  if ACD61_activeDoorRoute ~= "" then
    ACD61_activeDoorRoute = ""
    rT = ""
    bT = ""
    L0 = nil
    a0("RETURN BASE " .. S)
    local l, y = pcall(function()
      return growtopia["warpTo"](S)
    end)
    if not l or y == false then
      return false
    end
    local s = kT(S, F, XS)
    if s then
      i0(true)
    end
    return s
  end
  if qT(S) then
    i0(true)
    return true
  end
  if UT(S) then
    local l = kT(S, F, XS)
    if l then
      i0(true)
    end
    return l
  end
  a0("WARP " .. S)
  rT = ""
  bT = ""
  L0 = nil
  local s = pcall(function()
    growtopia["warpTo"](S)
  end)
  if not s then
    return false
  end
  local r = kT(S, F, XS)
  if r then
    i0(true)
  end
  return r
end
local function jT(S, F)
  if sT(S, F) then
    return true
  end
  i0(true)
  for l = 1, JS, 1 do
    if not C then
      return false
    end
    a0("PATH " .. (tostring(l) .. ("/" .. (tostring(JS) .. (" -> " .. (tostring(S) .. ("," .. tostring(F))))))))
    pcall(function()
      FindPath(S, F)
    end)
    local y = 0
    while C and y < zS do
      if sT(S, F) then
        Sleep(120)
        return true
      end
      Sleep(100)
      y = y + 100
    end
    Sleep(gS)
  end
  return sT(S, F)
end
local function NT(S, F)
  if not C or not qT(jS) then
    return false
  end
  S = math["floor"](tonumber(S) or IS or NS)
  F = math["floor"](tonumber(F) or aS or OS)
  if sT(S, F) then
    return true
  end
  i0(true)
  for l = 1, MS, 1 do
    if not C or not qT(jS) then
      return false
    end
    a0("DROP PATH " .. (tostring(l) .. ("/" .. (tostring(MS) .. (" -> " .. (tostring(S) .. ("," .. tostring(F))))))))
    pcall(function()
      FindPath(S, F)
    end)
    local y = 0
    while C and (qT(jS) and y < ZS) do
      if sT(S, F) then
        Sleep(dS)
        return C and sT(S, F)
      end
      Sleep(100)
      y = y + 100
    end
    if l < MS then
      Sleep(S0)
    end
  end
  return sT(S, F)
end
function ACD19_stableAtStorageTile(S, F, l, y)
  local s, r = 0, 0
  while C and r <= y do
    if not qT(jS) then
      return false
    end
    if sT(S, F) then
      if s >= l then
        return true
      end
      s = s + ACD19_DROP_STABLE_POLL_MS
    else
      s = 0
    end
    if r >= y then
      break
    end
    Sleep(ACD19_DROP_STABLE_POLL_MS)
    r = r + ACD19_DROP_STABLE_POLL_MS
  end
  return C and (qT(jS) and (sT(S, F) and s >= l))
end
function ACD19_confirmStorageDropPosition()
  if not C or not qT(jS) then
    ACD19_storageEntryConfirmed = false
    return false
  end
  local S, F = IS, aS
  if
    ACD19_storageEntryConfirmed and (
      ACD19_storageEntryConfirmedX == S and (ACD19_storageEntryConfirmedY == F and sT(S, F))
    )
  then
    return true
  end
  ACD19_storageEntryConfirmed = false
  a0("STORAGE PATH 1/2 -> " .. (tostring(S) .. ("," .. tostring(F))))
  if not NT(S, F) then
    return false
  end
  if not ACD19_stableAtStorageTile(S, F, dS, 900) then
    a0("WAIT FIRST STORAGE ARRIVAL")
    return false
  end
  a0("STORAGE PATH 2/2 -> " .. (tostring(S) .. ("," .. tostring(F))))
  local l = pcall(function()
    FindPath(S, F)
  end)
  if not l then
    a0("WAIT SECOND STORAGE PATH")
    return false
  end
  if not ACD19_stableAtStorageTile(S, F, ACD19_DROP_SECOND_PATH_STABLE_MS, 1400) then
    a0("WAIT VERIFIED STORAGE POSITION")
    return false
  end
  ACD19_storageEntryConfirmed = true
  ACD19_storageEntryConfirmedX, ACD19_storageEntryConfirmedY = S, F
  a0("STORAGE POSITION CONFIRMED " .. (tostring(S) .. ("," .. tostring(F))))
  return true
end
local function OT(S, F)
  local l = GetTile or getTile
  if l == nil then
    return nil
  end
  local y, s = pcall(l, S, F)
  if y then
    return s
  end
  return nil
end
local function IT(S, F)
  local l = OT(S, F)
  return l ~= nil and l["collidable"] ~= true
end
function ACD_EXACT_isSkipped(S)
  local F = tostring(S or "")
  local l = ACD_EXACT_skippedByWorld[rS]
  return l ~= nil and l[F] ~= nil
end
function ACD_EXACT_markSkipped(S, F)
  local l = tostring(S or "")
  if l == "" or l == "nil" or rS == "" then
    return
  end
  if ACD_EXACT_skippedByWorld[rS] == nil then
    ACD_EXACT_skippedByWorld[rS] = {}
  end
  local y = ACD_EXACT_skippedByWorld[rS]
  if y[l] ~= nil then
    return
  end
  y[l] = tostring(F or "NO PATH")
  ACD_EXACT_skipCountByWorld[rS] = (ACD_EXACT_skipCountByWorld[rS] or 0) + 1
  ACD_EXACT_totalSkipped = ACD_EXACT_totalSkipped + 1
  ACD19_safeEditValue("ACD_exactskipped", tostring(ACD_EXACT_totalSkipped))
  a0("SKIP " .. (tostring(F or "NO PATH") .. (" @ " .. tostring(rS))))
end
local function aT(S)
  if S == nil then
    return nil, nil
  end
  local F = tonumber(S["posX"])
  local l = tonumber(S["posY"])
  if (F == nil or l == nil) and S["pos"] ~= nil then
    F = F or tonumber(S["pos"]["x"])
    l = l or tonumber(S["pos"]["y"])
  end
  return F, l
end
local function BT(S)
  S = tonumber(S)
  if S == nil then
    return false
  end
  for F, l in pairs(G0()) do
    if tonumber(l["id"]) == S then
      return true
    end
  end
  return false
end
local function hT()
  local S, F = yT()
  local l = {}
  local y = G0()
  for y, s in pairs(y) do
    if A[tonumber(s["itemid"])] == true and V0(tonumber(s["itemid"])) then
      local y, r = aT(s)
      if y ~= nil and r ~= nil then
        local c = math["floor"](y / 32)
        local b = math["floor"](r / 32)
        local U = 0
        if S ~= nil and F ~= nil then
          U = math["abs"](S - c) + math["abs"](F - b)
        end
        local q = n0() and z0(c, b)
        if not q and not ACD_EXACT_isSkipped(s["id"]) then
          table["insert"](
            l,
            {
              ["object"] = s,
              ["uid"] = tonumber(s["id"]),
              ["itemID"] = tonumber(s["itemid"]),
              ["amount"] = tonumber(s["amount"]) or 0,
              ["pixelX"] = y,
              ["pixelY"] = r,
              ["tileX"] = c,
              ["tileY"] = b,
              ["distance"] = U,
            }
          )
        end
      end
    end
  end
  if #l > 1 then
    local F = {}
    local y = {}
    for S, l in ipairs(l) do
      local s = l["tileY"]
      if F[s] == nil then
        F[s] = {}
        table["insert"](y, s)
      end
      table["insert"](F[s], l)
    end
    table["sort"](y, function(S, F)
      return S < F
    end)
    local s = true
    if S ~= nil and #y > 0 then
      local l = F[y[1]]
      local r = math["huge"]
      local c = -math["huge"]
      for S, F in ipairs(l) do
        if F["tileX"] < r then
          r = F["tileX"]
        end
        if F["tileX"] > c then
          c = F["tileX"]
        end
      end
      if math["abs"](S - c) < math["abs"](S - r) then
        s = false
      end
    end
    local r = {}
    for S, l in ipairs(y) do
      local y = F[l]
      local c
      if S % 2 == 1 then
        c = s
      else
        c = not s
      end
      table["sort"](y, function(S, F)
        if c then
          return S["tileX"] < F["tileX"]
        else
          return S["tileX"] > F["tileX"]
        end
      end)
      for S, F in ipairs(y) do
        table["insert"](r, F)
      end
    end
    l = r
  end
  ACD19_safeEditValue("ACD_objects", tostring(#l))
  return l
end
local function ET()
  local S = {}
  for F, l in pairs(G0()) do
    local y = tonumber(l and l["itemid"])
    if y and (A[y] and u0(y) >= e) then
      local F, s = aT(l)
      if F ~= nil and s ~= nil then
        local r, c = math["floor"](F / 32), math["floor"](s / 32)
        if not (n0() and z0(r, c)) and not ACD_EXACT_isSkipped(l["id"]) then
          S[y] = true
        end
      end
    end
  end
  return S, next(S) ~= nil
end
local function LT(S)
  if S == nil or S["uid"] == nil then
    return false
  end
  local F = pcall(function()
    SendPacketRaw(false, { ["type"] = 11, ["value"] = S["uid"], ["x"] = S["pixelX"], ["y"] = S["pixelY"] })
  end)
  return F
end
local function mT(S)
  local F = 0
  while C and (X0() == rS and F < SS) do
    if f0() > S then
      return true
    end
    Sleep(fS)
    F = F + fS
  end
  return C and (X0() == rS and f0() > S)
end
local function iT(S, F)
  if not C or X0() ~= rS then
    return false
  end
  if sT(S, F) then
    return true
  end
  i0(true)
  local l = pcall(function()
    FindPath(S, F)
  end)
  if not l then
    return false
  end
  local y, s = 0, 0
  local r, c = yT()
  while C and y < PS do
    if X0() ~= rS then
      return false
    end
    local l, b = yT()
    if l == nil or b == nil then
      return false
    end
    if sT(S, F) then
      Sleep(CS)
      return C and (X0() == rS and sT(S, F))
    end
    if l ~= r or b ~= c then
      s = 0
      r, c = l, b
    else
      s = s + GS
    end
    if y >= 2000 and s >= uS then
      return sT(S, F)
    end
    Sleep(GS)
    y = y + GS
  end
  return false
end
local function HT()
  local S = "CAUTIOUS"
  if lS >= 3 then
    S = "FAST"
  end
  if lS == 1 then
    S = "LAG SAFE"
  end
  pcall(function()
    ACD19_safeEditValue("ACD_serverpace", S .. (" (" .. (tostring(lS) .. ")")))
  end)
end
local function KT()
  lS = 1
  yS = 0
  sS = math["min"](sS + 1, 5)
  HT()
end
local function XT()
  sS = 0
  yS = yS + 1
  if yS >= 2 and lS < FS then
    lS = lS + 1
    yS = 0
  end
  HT()
end
local function xT(S, F, l)
  if not C or X0() ~= rS then
    return "WORLD"
  end
  if not V0(S["itemID"]) then
    return "FULL"
  end
  if not BT(S["uid"]) then
    return "GONE"
  end
  local y = f0()
  a0("PATH " .. (F .. ("/" .. l)))
  local s, r = S["tileX"], S["tileY"]
  if not iT(s, r) then
    if not C or X0() ~= rS then
      return "WORLD"
    end
    if f0() > y then
      return "ACK"
    end
    if not BT(S["uid"]) then
      return "GONE"
    end
    return "SKIP"
  end
  if J0() and z0(s, r) then
    return "SKIP"
  end
  local c = {}
  for S, F in pairs(G0()) do
    local l, y = tonumber(F["id"]), tonumber(F["itemid"])
    local b, U = aT(F)
    if l and (y and (b and (U and (math["floor"](b / 32) == s and math["floor"](U / 32) == r)))) then
      c[#c + 1] = { ["uid"] = l, ["itemID"] = y, ["pixelX"] = b, ["pixelY"] = U }
    end
  end
  table["sort"](c, function(S, F)
    return S["uid"] < F["uid"]
  end)
  local b = false
  local function U(S, F)
    if not C or X0() ~= rS or not sT(F, r) or not BT(S["uid"]) then
      return false
    end
    local l = u0(S["itemID"])
    if l >= e or not LT(S) then
      return false
    end
    b = true
    Sleep(tS + d)
    local y = 0
    while C and (X0() == rS and sT(F, r)) do
      if u0(S["itemID"]) > l or not BT(S["uid"]) then
        return false
      end
      if y >= SS then
        return true
      end
      Sleep(fS)
      y = y + fS
    end
    return false
  end
  local q = {}
  for S, F in ipairs(c) do
    if not C or X0() ~= rS then
      return "WORLD"
    end
    if not sT(s, r) then
      return "PATH"
    end
    if U(F, s) then
      local S = F["pixelX"] - s * 32
      local l = S >= 24 and s + 1 or (S <= 8 and s - 1 or nil)
      if l and l >= 0 then
        q[#q + 1] = { ["stack"] = F, ["x"] = l }
      end
    end
  end
  for S, F in ipairs(q) do
    if not C or X0() ~= rS then
      return "WORLD"
    end
    if
      BT(F["stack"]["uid"]) and (u0(F["stack"]["itemID"]) < e and (not (J0() and z0(F["x"], r)) and iT(F["x"], r)))
    then
      U(F["stack"], F["x"])
    end
  end
  if not C or X0() ~= rS then
    return "WORLD"
  end
  if f0() > y then
    return "ACK"
  end
  if b then
    return "SENT"
  end
  return "GONE"
end
local function nT(S)
  if type(S) ~= "table" or #S == 0 then
    return false
  end
  U0 = U0 + 1
  a0("ADAPTIVE COLLECT")
  i0(true)
  H0(false)
  HT()
  local F, l = {}, {}
  local y = f0()
  local s = false
  local r = false
  local function c()
    if #F == 0 then
      y = f0()
      return true
    end
    if T0() then
      F = {}
      return true
    end
    a0("WAIT BATCH ACK")
    local S = f0() > y
    if not S then
      S = mT(y)
    end
    if S then
      r = true
      XT()
      for S, F in ipairs(F) do
        if not BT(F["uid"]) then
          q0[tostring(F["uid"])] = nil
        end
      end
    else
      KT()
      for S, F in ipairs(F) do
        q0[tostring(F["uid"])] = U0 + k0
      end
      a0("SERVER SLOW - BACKOFF")
      local S = math["min"](VS + 250 * sS, WS)
      Sleep(S)
    end
    F = {}
    y = f0()
    return S
  end
  for y, b in ipairs(S) do
    if not C or X0() ~= rS then
      break
    end
    if T0() then
      break
    end
    local U = tostring(b["uid"] or "")
    local q = b["tileX"] .. ("," .. b["tileY"])
    if U ~= "" and (not l[q] and U0 >= (q0[U] or 0)) then
      if #F >= lS then
        if not c() then
          break
        end
        if not C or X0() ~= rS then
          break
        end
      end
      if T0() then
        break
      end
      s = true
      local k = xT(b, y, #S)
      if k ~= "GONE" then
        l[q] = true
      end
      if k == "WORLD" or k == "FULL" then
        break
      elseif k == "ACK" then
        r = true
        if #F > 0 then
          if not c() then
            break
          end
        else
          XT()
        end
      elseif k == "SENT" then
        F[#F + 1] = b
      elseif k == "SKIP" then
        ACD_EXACT_markSkipped(b["uid"], "EXACT PATH FAILED")
      elseif k == "PATH" or k == "PACKET" then
        q0[U] = U0 + k0
      end
    end
  end
  if C and (X0() == rS and not T0()) then
    c()
  end
  if C and (X0() == rS and (not T0() and not s)) then
    a0("WAIT DEFERRED PICKUPS")
    Sleep(300)
  end
  FT()
  return r
end
local function JT(S)
  C = false
  ACD19_storageEntryConfirmed = false
  ACD19_storageEntryConfirmedX, ACD19_storageEntryConfirmedY = nil, nil
  qS = false
  kS = 0
  H0(false)
  i0(false)
  F0 = false
  l0 = false
  y0 = false
  s0 = false
  r0 = nil
  c0 = 0
  b0 = false
  v0()
  ACD19_safeSetStartToggle(false)
  a0("STOPPED")
  if S ~= nil and S ~= "" then
    w0(S)
  end
end
local function zT()
  if not C then
    return false
  end
  local S = IS - 1
  local F = aS
  b0 = true
  a0("DROP SHIFT LEFT -> " .. (tostring(S) .. ("," .. tostring(F))))
  if not NT(S, F) then
    a0("WAIT LEFT PATH " .. (tostring(S) .. ("," .. tostring(F))))
    return false
  end
  IS = S
  aS = F
  ACD19_storageEntryConfirmed = false
  b0 = false
  w0("Storage moved left to (" .. (tostring(S) .. (", " .. (tostring(F) .. ")"))))
  return true
end
local function gT(S, F, l)
  if not C or not qT(jS) then
    return false
  end
  if not ACD19_storageEntryConfirmed or not sT(IS, aS) then
    a0("WAIT SAFE DROP POSITION")
    return false
  end
  if not ACD19_stableAtStorageTile(IS, aS, ACD19_DROP_PRE_PACKET_STABLE_MS, 650) then
    ACD19_storageEntryConfirmed = false
    a0("DROP BLOCKED - LEFT STORAGE TILE")
    return false
  end
  if u0(S) < F then
    return true
  end
  F0 = true
  l0 = false
  a0("DROP REQUEST " .. tostring(S))
  local y = pcall(function()
    SendPacket(2, "action|drop\nitemID|" .. tostring(S))
  end)
  if not y then
    F0 = false
    l0 = false
    return false
  end
  local s = 0
  while C and (qT(jS) and s < QS) do
    if l0 or u0(S) < F then
      break
    end
    Sleep(75)
    s = s + 75
  end
  local r = l0
  F0 = false
  l0 = false
  if not C or not qT(jS) then
    return false
  end
  if u0(S) < F then
    return true
  end
  if not r then
    return false
  end
  if not ACD19_storageEntryConfirmed or not ACD19_stableAtStorageTile(IS, aS, ACD19_DROP_PRE_PACKET_STABLE_MS, 650) then
    ACD19_storageEntryConfirmed = false
    a0("DROP CANCELLED - POSITION CHANGED")
    return false
  end
  a0("DROP CONFIRM " .. tostring(S))
  local c = pcall(function()
    SendPacket(
      2,
      "action|dialog_return\n"
        .. ("dialog_name|drop_item\n" .. ("itemID|" .. (tostring(S) .. ("|\n" .. ("count|" .. tostring(l))))))
    )
  end)
  if not c then
    return false
  end
  s = 0
  while C and (qT(jS) and s < TS) do
    if u0(S) < F then
      return true
    end
    Sleep(100)
    s = s + 100
  end
  return u0(S) < F
end
local function PT(S, F)
  while C do
    if not qT(jS) then
      return false
    end
    p0()
    if W0(F) <= 0 then
      return true
    end
    if b0 then
      if not zT() then
        return false
      end
    end
    if not ACD19_confirmStorageDropPosition() then
      a0("WAIT VERIFIED STORAGE PATH")
      return false
    end
    p0()
    local S = u0(F)
    local l = W0(F)
    if l <= 0 then
      return true
    end
    local y = false
    for s = 1, AS, 1 do
      if not C or not qT(jS) then
        return false
      end
      p0()
      if u0(F) < S then
        y = true
        break
      end
      l = W0(F)
      if l <= 0 then
        return true
      end
      a0("DROP " .. (tostring(F) .. (" x" .. (tostring(l) .. (" TRY " .. (tostring(s) .. ("/" .. tostring(AS))))))))
      if gT(F, S, l) then
        y = true
        break
      end
      if not ACD19_storageEntryConfirmed or not qT(jS) or not sT(IS, aS) then
        a0("STORAGE MOVED - RECHECK DROP TILE")
        return false
      end
      Sleep(eS)
      p0()
      if u0(F) < S then
        y = true
        break
      end
    end
    p0()
    if y then
      local l = u0(F)
      if l < S then
        a0("DROPPED " .. (tostring(S - l) .. (" " .. C0(F))))
        FT()
      end
    else
      if not zT() then
        return false
      end
    end
  end
  return false
end
local function GT(S)
  local F = 0
  for l, y in ipairs(T) do
    if S == nil or S[y] then
      F = F + W0(y)
    end
  end
  return F
end
local function uT(S, F)
  o0()
  p0()
  if GT(F) <= 0 then
    return true
  end
  H0(false)
  if not wT(jS) then
    a0("WAIT SHARED STORAGE WORLD")
    return false
  end
  y0 = true
  if b0 and not zT() then
    y0 = false
    return false
  end
  if not ACD19_confirmStorageDropPosition() then
    y0 = false
    a0("WAIT VERIFIED STORAGE PATH")
    return false
  end
  for l, y in ipairs(T) do
    if not C then
      break
    end
    p0()
    if (F == nil or F[y]) and W0(y) > 0 then
      if not PT(S, y) then
        y0 = false
        return false
      end
    end
  end
  p0()
  y0 = false
  FT()
  return C and GT(F) <= 0
end
local function CT()
  if not C or US > #bS then
    qS = false
    return
  end
  local S = bS[US]
  rS = S
  if UT(S) then
    qS = false
    kS = 0
    return
  end
  qS = true
  kS = 0
  a0("STORED - RETURN TO " .. tostring(S))
end
local function DT()
  if not qS then
    return true
  end
  if not C then
    return false
  end
  if US > #bS then
    qS = false
    return true
  end
  local S = bS[US]
  rS = S
  kS = kS + 1
  a0("RETURN " .. (tostring(kS) .. (" -> " .. tostring(S))))
  if wT(S, iS) and UT(S) then
    Sleep(KS)
    if C and UT(S) then
      qS = false
      kS = 0
      wS = 0
      c0 = 0
      U0 = 0
      q0 = {}
      a0("RESUMED " .. tostring(S))
      return true
    end
  end
  a0("RETURN WARP RETRY " .. (tostring(kS) .. (" -> " .. tostring(S))))
  Sleep(HS)
  return false
end
local function fT(S)
  if type(S) ~= "string" or S == "" then
    return nil
  end
  local F, l = pcall(function()
    if type(findItemID) == "function" then
      return findItemID(S)
    end
    if growtopia ~= nil and type(growtopia["getItemID"]) == "function" then
      return growtopia["getItemID"](S)
    end
    return nil
  end)
  if F and (tonumber(l) ~= nil and tonumber(l) > 0) then
    return math["floor"](tonumber(l))
  end
  return nil
end
local function RT(S)
  if type(S) == "number" then
    return math["floor"](S)
  end
  if type(S) == "string" then
    local F = tonumber(S)
    if F ~= nil and F > 0 then
      return math["floor"](F)
    end
    local l = fT(S)
    if l ~= nil then
      return l
    end
    local y = S:match("(%d+)")
    if y ~= nil then
      local S = tonumber(y)
      if S ~= nil and S > 0 then
        return math["floor"](S)
      end
    end
    return nil
  end
  if type(S) == "table" then
    local F = { S["id"], S["itemid"], S["itemID"], S["value"], S["item"], S["name"], S["itemName"], S["selected"] }
    for S, F in ipairs(F) do
      local l = RT(F)
      if l ~= nil and l > 0 then
        return l
      end
    end
  end
  return nil
end
local function YT(S)
  local F = RT(S)
  if F == nil or F <= 0 or F > 65535 then
    return false
  end
  if C then
    w0("Stop before changing selected items.")
    return true
  end
  for S, l in ipairs(Q) do
    if l == F then
      w0("Already selected: " .. (C0(F) .. (" (" .. (tostring(F) .. ")"))))
      return true
    end
  end
  if #Q >= 30 then
    w0("Maximum 30 selected items.")
    return true
  end
  Q[#Q + 1] = F
  d0()
  FT()
  ACD19_safeEditValue("ACD_objects", "0")
  hS = true
  w0("Added collect item: " .. (C0(F) .. (" (" .. (tostring(F) .. ")"))))
  return true
end
function onVariant(S, F)
  if S ~= nil and (S["v1"] == "OnDialogRequest" and type(S["v2"]) == "string") then
    if C and (F0 and S["v2"]:find("drop_item", 1, true)) then
      l0 = true
      return true
    end
  end
  return false
end
function onGamePacket(S)
  if S ~= nil and tonumber(S["type"]) == 26 then
    rT = ""
    cT = ""
    bT = ""
    ACD61_activeDoorRoute = ""
    ACD19_storageEntryConfirmed = false
    ACD19_storageEntryConfirmedX, ACD19_storageEntryConfirmedY = nil, nil
  end
  return false
end
function onSendPacketRaw(S)
  if not C or S == nil or tonumber(S["type"]) ~= 11 or not J0() then
    return false
  end
  local F = tonumber(S["value"])
  if F == nil then
    return true
  end
  local l = nil
  for S, y in pairs(G0()) do
    if tonumber(y and y["id"]) == F then
      l = y
      break
    end
  end
  if l == nil then
    return true
  end
  local y, s = aT(l)
  if y == nil or s == nil then
    return true
  end
  local r, c = math["floor"](y / 32), math["floor"](s / 32)
  if n0() and z0(r, c) then
    return true
  end
  if J0() then
    if z0(r, c) then
      return true
    end
    local S, F = yT()
    if S ~= nil and (F ~= nil and z0(S, F)) then
      return true
    end
  end
  return false
end
local function VT()
  C = true
  i0(true)
  H0(false)
  if #Q == 0 then
    JT("Add at least one Collect Item first.")
    return
  end
  if #cS == 0 then
    JT("Add at least one Collection World in Settings first.")
    return
  end
  if jS == "" then
    JT("Set Drop World first.")
    return
  end
  E("repeat", false)
  E("loops", 0)
  bS, T, A = {}, {}, {}
  p = o
  v = {}
  M = false
  Z = {}
  for S, F in ipairs(cS) do
    bS[#bS + 1] = F
  end
  for S, F in ipairs(Q) do
    T[#T + 1] = F
    A[F] = true
  end
  US = 1
  qS = false
  kS = 0
  rS = bS[1]
  wS = 0
  B0()
  IS = NS
  aS = OS
  ACD19_storageEntryConfirmed = false
  ACD19_storageEntryConfirmedX, ACD19_storageEntryConfirmedY = nil, nil
  s0 = false
  r0 = nil
  c0 = 0
  b0 = false
  ACD_EXACT_skippedByWorld = {}
  ACD_EXACT_skipCountByWorld = {}
  ACD_EXACT_totalSkipped = 0
  ACD19_safeEditValue("ACD_exactskipped", "0")
  U0 = 0
  q0 = {}
  lS = math["min"](2, FS)
  yS = 0
  sS = 0
  HT()
  hS = false
  ES = 0
  FT()
  e0()
  lT()
  a0("STARTING")
  w0(
    "Auto Collect V6.1 started: " .. (
        p == 0 and "UNLIMITED UNTIL WORLDS EMPTY" or ("per-item drop goal " .. tostring(p))
      )
  )
end
function onValue(S, F, l)
  if ACD19_guardedUIWrites[F] then
    return
  end
  if F == "ACD_licensekey" then
    local S = r(l)
    if V and S ~= r(D) then
      t = t + 1
      V = false
      ACD19_safeSetStartToggle(false)
      a0("STOPPED - LICENSE CHANGED")
    end
    D = S
    f = false
    E("license_key", S)
    j0("NOT VERIFIED")
    return
  end
  if F == "ACD_verifylicense" then
    runThread(function()
      I0(false)
    end)
    return
  end
  if F == "ACD_clearlicense" then
    if V then
      t = t + 1
      V = false
      ACD19_safeSetStartToggle(false)
      a0("STOPPED - LICENSE CLEARED")
    end
    f = false
    D = ""
    s = ""
    q()
    E("license_key", "")
    pcall(function()
      ACD19_safeEditValue("ACD_licensekey", "")
    end)
    j0("NOT VERIFIED")
    w0("Saved license cleared.")
    return
  end
  if F == "ACD_enable" then
    if l == true then
      if C or V then
        return
      end
      t = t + 1
      local S = t
      local F = r(D)
      V = true
      f = false
      C = false
      i0(false)
      H0(false)
      a0("CHECKING LICENSE BEFORE START")
      runThread(function()
        local l = 0
        while R and (V and (t == S and l < 30000)) do
          Sleep(100)
          l = l + 100
        end
        if not V or t ~= S then
          return
        end
        local y = false
        if not R then
          y = I0(true)
        else
          j0("VERIFY BUSY - RETRY START")
        end
        if not V or t ~= S then
          return
        end
        if r(D) ~= F then
          y = false
          f = false
          j0("KEY CHANGED - RETRY START")
        end
        V = false
        if not y then
          C = false
          ACD19_safeSetStartToggle(false)
          H0(false)
          i0(false)
          a0("LICENSE NOT VALID - NOT STARTED")
          w0("License was not approved by the server. Start blocked (" .. (tostring(Y) .. ")."))
          return
        end
        VT()
      end)
    else
      t = t + 1
      V = false
      C = false
      H0(false)
      i0(false)
      F0 = false
      l0 = false
      y0 = false
      s0 = false
      b0 = false
      v0()
      a0("STOPPED")
      w0("Auto Collect -> Drop stopped.")
    end
    return
  end
  if F == "ACD_itempicker" then
    if not YT(l) then
      w0("Could not read selected item.")
    end
    return
  end
  if F == "ACD_selecteditem" then
    Z0()
    return
  end
  if F == "ACD_itemlist" then
    if C then
      pcall(function()
        ACD19_safeEditValue("ACD_itemlist", B(Q))
      end)
      w0("Stop before editing the item list.")
      return
    end
    Q = a(l)
    d0()
    FT()
    return
  end
  if F == "ACD_removeitem" then
    if C then
      w0("Stop before removing items.")
      return
    end
    if #Q > 0 then
      local S = table["remove"](Q)
      d0()
      FT()
      w0("Removed selected item " .. tostring(S))
    end
    return
  end
  if F == "ACD_clearitems" then
    if C then
      w0("Stop before clearing items.")
      return
    end
    Q = {}
    d0()
    FT()
    w0("Selected item list cleared.")
    return
  end
  if F == "ACD_droptotal" then
    local S = tonumber(l)
    if S == nil or S < 0 then
      pcall(function()
        ACD19_safeEditValue("ACD_droptotal", tostring(o))
      end)
      w0("Total Drop Per Item must be 0 or a positive whole number.")
      return
    end
    S = math["max"](0, math["min"](1000000000, math["floor"](S)))
    o = S
    E("droptotal", o)
    if tostring(l) ~= tostring(S) then
      pcall(function()
        ACD19_safeEditValue("ACD_droptotal", tostring(S))
      end)
    end
    if C then
      w0("Drop total saved. The new goal applies on next Start.")
    else
      p = o
      e0()
    end
    return
  end
  if F == "ACD_pickupdelay" then
    local S = tonumber(l)
    if S ~= nil then
      S = math["floor"](S)
      if S < 0 then
        S = 0
      end
      if S > 1000 then
        S = 1000
      end
      d = S
      ACD19_safeEditValue("ACD_pickupdelay", tostring(d))
      E("pickupdelay", d)
    end
    return
  end
  if F == "ACD_batchmax" then
    local S = math["floor"](tonumber(l) or FS)
    FS = math["max"](1, math["min"](2, S))
    lS = math["min"](lS, FS)
    pcall(function()
      ACD19_safeEditValue("ACD_batchmax", tostring(FS))
    end)
    HT()
    E("batchmax", FS)
    return
  end
  if F == "ACD_acktimeout" then
    local S = tonumber(l)
    if S ~= nil then
      S = math["floor"](S)
      if S < 300 then
        S = 300
      end
      if S > 10000 then
        S = 10000
      end
      SS = S
      ACD19_safeEditValue("ACD_acktimeout", tostring(SS))
      E("acktimeout", SS)
    end
    return
  end
  if F == "ACD_worldlist" then
    cS = O(l)
    h0()
    B0()
    if C then
      w0("World list saved; changes take effect on the next Start.")
    end
    return
  end
  if F == "ACD_addworld" then
    local S = X0()
    if S == "" or S == "EXIT" then
      w0("Enter the world you want to add first.")
      return
    end
    local F = false
    for l, y in ipairs(cS) do
      if y == S then
        F = true
        break
      end
    end
    if not F then
      if #cS >= 30 then
        w0("Maximum 30 collection worlds.")
        return
      end
      cS[#cS + 1] = S
    end
    h0()
    B0()
    w0("Collection worlds: " .. I(cS))
    return
  end
  if F == "ACD_removeworld" then
    if #cS > 0 then
      local S = table["remove"](cS)
      h0()
      B0()
      w0("Removed collection world " .. tostring(S))
    end
    return
  end
  if F == "ACD_dropworld" then
    if C then
      pcall(function()
        ACD19_safeEditValue("ACD_dropworld", jS)
      end)
      w0("Stop the script before editing the Shared Storage World.")
      return
    end
    jS = K0(l)
    E("dropworld", jS)
    B0()
    return
  end
  if F == "ACD_setdropworld" then
    if C then
      w0("Stop before editing Shared Storage World.")
      return
    end
    local S = X0()
    if S == "" or S == "EXIT" then
      w0("Current world is not available.")
      return
    end
    jS = S
    ACD19_safeEditValue("ACD_dropworld", jS)
    E("dropworld", jS)
    B0()
    w0("Shared Storage World = " .. jS)
    return
  end
  if F == "ACD_dropx" then
    if C then
      pcall(function()
        ACD19_safeEditValue("ACD_dropx", tostring(NS))
      end)
      w0("Stop before editing Drop X.")
      return
    end
    local S = tonumber(l)
    if S ~= nil then
      NS = math["floor"](S)
      IS = NS
      E("dropx", NS)
    end
    return
  end
  if F == "ACD_dropy" then
    if C then
      pcall(function()
        ACD19_safeEditValue("ACD_dropy", tostring(OS))
      end)
      w0("Stop before editing Drop Y.")
      return
    end
    local S = tonumber(l)
    if S ~= nil then
      OS = math["floor"](S)
      aS = OS
      E("dropy", OS)
    end
    return
  end
  if F == "ACD_setdrop" then
    if C then
      w0("Stop before setting Drop Position.")
      return
    end
    local S, F = yT()
    if S == nil or F == nil then
      w0("Player position is not available.")
      return
    end
    NS = S
    OS = F
    IS = NS
    aS = OS
    ACD19_safeEditValue("ACD_dropx", tostring(NS))
    ACD19_safeEditValue("ACD_dropy", tostring(OS))
    E("dropx", NS)
    E("dropy", OS)
    w0("Drop Position = (" .. (tostring(NS) .. (", " .. (tostring(OS) .. ")"))))
    return
  end
end
applyHook()
if type(setOnValue) == "function" then
  pcall(function()
    setOnValue("ACD_itempicker", function(...)
      local S = { ... }
      for F = #S, 1, -1 do
        if YT(S[F]) then
          return
        end
      end
    end)
  end)
end
runThread(function()
  i0(false)
  Z0()
  FT()
  lT()
  e0()
  B0()
  HT()
  ACD19_safeEditValue("ACD_objects", "0")
  a0("STOPPED")
  ACD19_mwSaveState = w == nil and "UNAVAILABLE" or (ACD19_mwSettingsRestored and "RESTORED" or "READY - SAVES ON EDIT")
  ACD19_safeEditValue("ACD_autosave", ACD19_mwSaveState)
  if D ~= "" then
    pcall(function()
      ACD19_safeEditValue("ACD_licensekey", D)
    end)
    j0("SAVED - CHECK ON START")
  else
    j0("NOT VERIFIED")
  end
  while true do
    if not C then
      Sleep(200)
    else
      if qS then
        DT()
      elseif Y0() then
        JT("All selected item drop totals reached (" .. (tostring(p) .. " each)."))
      elseif s0 or T0() then
        s0 = true
        H0(false)
        if r0 then
          a0("UNLIMITED -> FREE FULL ITEM STACKS")
        else
          a0("ALL ITEMS READY -> SHARED STORAGE")
        end
        if uT("Ready selected items dropped", r0) then
          s0 = false
          r0 = nil
          c0 = 0
          v0()
          ES = ES + 1
          lT()
          if Y0() then
            JT("All selected item drop totals reached (" .. (tostring(p) .. " each)."))
          else
            CT()
            Sleep(150)
          end
        else
          Sleep(400)
        end
      elseif US > #bS then
        if Q0() > 0 then
          a0("FINAL STORAGE -> STOP")
          if uT("Last eligible collected items dropped") then
            v0()
            B0()
            if p > 0 and not Y0() then
              JT("All worlds scanned. Drop targets not met: " .. A0())
            else
              JT("All " .. (tostring(#bS) .. " collection worlds finished. Eligible items stored."))
            end
          elseif C then
            Sleep(500)
          end
        else
          v0()
          B0()
          if p > 0 and not Y0() then
            JT("All worlds scanned. Drop targets not met: " .. A0())
          else
            JT("All collection worlds finished. No more eligible items.")
          end
        end
      else
        rS = bS[US]
        if not wT(rS) then
          a0("WAIT COLLECT WORLD " .. tostring(rS))
          Sleep(1300)
        elseif not qT(rS) then
          a0("WAIT COLLECT PLAYER READY")
          Sleep(300)
        else
          a0("SCAN " .. tostring(rS))
          local S = hT()
          if #S == 0 then
            local S, F = nil, false
            if p == 0 then
              S, F = ET()
            end
            if F then
              wS = 0
              c0 = c0 + 1
              if c0 >= 2 then
                r0 = S
                s0 = true
                c0 = 0
                a0("UNLIMITED / FULL STACK: STORE & RESUME")
              else
                a0("VERIFY FULL STACK BACKLOG")
              end
              Sleep(400)
            else
              c0 = 0
              wS = wS + 1
              if wS < 3 then
                a0("CONFIRM EMPTY " .. (tostring(wS) .. ("/3 " .. tostring(rS))))
                Sleep(400)
              else
                local S = ACD_EXACT_skipCountByWorld[rS] or 0
                a0((S > 0 and ("WORLD DONE - SKIPPED " .. (tostring(S) .. " ")) or "WORLD COMPLETE ") .. tostring(rS))
                wS = 0
                US = US + 1
                U0 = 0
                q0 = {}
                if US <= #bS then
                  rS = bS[US]
                end
                B0()
                Sleep(250)
              end
            end
          else
            wS = 0
            c0 = 0
            nT(S)
            H0(false)
            a0("RESCAN " .. tostring(rS))
            Sleep(DS)
          end
        end
      end
      Sleep(120)
    end
  end
end)
