setMinimum("6.1.2")
local l = "Premium Auto Collect by Bangshu"
do
  local O =
    "https://script.google.com/macros/s/AKfycbxWY0ROC3V1HOTJuRPfovwsN8CfTkXrcFF6VvhlS0EQRfWleUWVHZNUSW1M2UcVesSC/exec"
  local P = "AUTOCOLLECT"
  local N = "AUTOCOLLECT-6.1-PAID-001"
  local U = "approval"
  local w = "%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x"
  local function v()
    local l, O = pcall(function()
      if type(getDiscordID) == "function" then
        return getDiscordID()
      end
      return getDiscordID
    end)
    if not l then
      return nil
    end
    if type(O) == "number" and (math["type"] and math["type"](O) == "integer") then
      O = tostring(O)
    end
    if type(O) ~= "string" or #O < 17 or #O > 20 or not O:match("^%d+$") then
      return nil
    end
    if O:match("^0+$") then
      return nil
    end
    return O
  end
  local function E(l, O)
    if not O or type(l) ~= "string" or #l > 512 then
      return false
    end
    local U, v, E = l:match(
      '^%s*{"status":"APPROVED","approval":{"discordId":"(%d+)","product":"([A-Z]+)","version":"([%w._-]+)","receiptId":"'
        .. (w .. '"}}%s*$')
    )
    return U == O and (v == P and E == N)
  end
  local s, k, F = pcall(function()
    local l, O = pcall(require, "preferences")
    local P = l and (type(O) == "table" and O) or Preferences
    if type(P) ~= "table" or type(P["new"]) ~= "function" then
      return nil
    end
    local N = P:new("BangshuPremiumAutoCollect")
    if N:load() == false then
      return N
    end
    return N, N:get(U, "")
  end)
  if not s then
    k = nil
  end
  if not E(F, v()) then
    local w, s = false, false
    local function F(l)
      pcall(editValue, "ACD_premium_status", l)
      if type(sendNotification) == "function" then
        pcall(sendNotification, l)
      elseif growtopia and type(growtopia["notify"]) == "function" then
        pcall(growtopia["notify"], l)
      end
    end
    local function V()
      if w or s then
        return
      end
      local l = v()
      if not l then
        F("DENIED - DISCORD ID UNAVAILABLE")
        return
      end
      if not k then
        F("DENIED - PREFERENCES UNAVAILABLE")
        return
      end
      w = true
      F("CHECKING")
      local V = pcall(runThread, function()
        local v = O
          .. (
            "?action=verifyPaidAccess&discordId=" .. (
              l .. ("&product=" .. (P .. ("&format=growlauncher&version=" .. N)))
            )
          )
        local V, f = pcall(fetch, v)
        if V and type(f) == "string" then
          local l = f:match("BANGSHU_PREMIUM_V1_BEGIN_([0-9a-f]+)_BANGSHU_PREMIUM_V1_END")
          if l and (#l <= 1024 and #l % 2 == 0) then
            f = l:gsub("..", function(l)
              return string["char"](tonumber(l, 16))
            end)
          end
        end
        if not V or type(f) ~= "string" then
          F("DENIED - REQUEST FAILED")
        elseif not E(f, l) then
          if f:match('^%s*{"status":"DENIED",') then
            F("DENIED - NO PREMIUM ACCESS")
          elseif f:match('^%s*{"status":"ERROR",') then
            F("DENIED - APPS SCRIPT SERVER ERROR")
          elseif f:match("^%s*<") then
            if f:find("doGet", 1, true) then
              F("DENIED - DEPLOYED APP MISSING GET HANDLER")
            else
              F("DENIED - GOOGLE RETURNED HTML")
            end
          elseif f:match("^%s*$") then
            F("DENIED - EMPTY SERVER RESPONSE")
          elseif f:match('^%s*{"status":"APPROVED",') then
            F("DENIED - APPROVAL DETAILS DO NOT MATCH")
          else
            F("DENIED - UNEXPECTED SERVER RESPONSE")
          end
        else
          local O, P = pcall(function()
            if k:set(U, f) == false then
              return false
            end
            if k:save() == false then
              return false
            end
            if k:load() == false then
              return false
            end
            return E(k:get(U, ""), l)
          end)
          s = O and P == true
          F(s and "APPROVED - RELOAD SCRIPT" or "DENIED - COULD NOT SAVE APPROVAL")
        end
        w = false
      end)
      if not V then
        w = false
        F("DENIED - COULD NOT START CHECK")
      end
    end
    function OnValue(l, O)
      if O == "ACD_premium_verify" then
        V()
      end
    end
    onValue = OnValue
    local f = UserInterface["new"](l, "Inventory")
    f:addButton("Verify Access", "ACD_premium_verify")
    f:addInputString("Verification Status", "NOT VERIFIED", "", "", nil, "ACD_premium_status")
    if type(addCategory) == "function" then
      pcall(addCategory, l, "Inventory")
    end
    addIntoModule(f:generateJSON(), l)
    if type(applyHook) == "function" then
      pcall(applyHook)
    end
    if type(setOnValue) == "function" then
      pcall(setOnValue, "ACD_premium_verify", V)
    end
    return
  end
end
local O = "AutoCollectToDropAllSettingsV19.json"
ACD19_LEGACY_MW_PREF_NAME = "AutoCollectToDropMultiWorldV11"
ACD19_MW_SCHEMA = "19"
ACD19_MW_KEYS = {
  "fastcollect",
  "fastpickupdelay",
  "worlds",
  "dropworld",
  "dropx",
  "dropy",
  "pickupdelay",
  "acktimeout",
  "batchmax",
  "items",
  "droptotal",
}
local P = nil
ACD19_mwPreferenceModule = nil
local N = {}
ACD19_mwSettingsRestored = false
ACD19_mwSaveState = "UNAVAILABLE"
ACD19_guardedUIWrites = {}
function ACD19_safeEditValue(l, O)
  if ACD19_guardedUIWrites[l] then
    return
  end
  ACD19_guardedUIWrites[l] = true
  pcall(function()
    editValue(l, O)
  end)
  ACD19_guardedUIWrites[l] = nil
end
function ACD19_safeSetStartToggle(l)
  if ACD19_guardedUIWrites["ACD_enable"] then
    return
  end
  ACD19_guardedUIWrites["ACD_enable"] = true
  local O = editToggle or EditToggle
  if O ~= nil then
    pcall(O, "ACD_enable", l == true)
  end
  ACD19_guardedUIWrites["ACD_enable"] = nil
end
function ACD19_setAutoSaveStatus(l)
  if ACD19_mwSaveState == l then
    return
  end
  ACD19_mwSaveState = l
  ACD19_safeEditValue("ACD_autosave", l)
end
local function U(l)
  return ((tostring(l or "")):upper()):gsub("%s+", "")
end
local function w(l)
  local O, P = {}, {}
  local N = (tostring(l or "")):gsub("[;\r\n]", ",")
  for l in ((N .. ",")):gmatch("([^,]*),") do
    local N = U(l)
    if N ~= "" and (N ~= "EXIT" and not P[N]) then
      P[N] = true
      O[#O + 1] = N
      if #O >= 30 then
        break
      end
    end
  end
  return O
end
local function v(l)
  return table["concat"](l or {}, ", ")
end
local function E(l)
  local O, P = {}, {}
  local N = (tostring(l or "")):gsub("[;\r\n]", ",")
  for l in ((N .. ",")):gmatch("([^,]*),") do
    local N = tonumber(l:match("^%s*(%d+)%s*$"))
    if N ~= nil and (N > 0 and (N <= 65535 and not P[N])) then
      N = math["floor"](N)
      P[N] = true
      O[#O + 1] = N
      if #O >= 30 then
        break
      end
    end
  end
  return O
end
local function s(l)
  local O = {}
  for l, P in ipairs(l or {}) do
    O[#O + 1] = tostring(P)
  end
  return table["concat"](O, ", ")
end
function ACD19_mwNewPreferences(l)
  if ACD19_mwPreferenceModule == nil or type(ACD19_mwPreferenceModule["new"]) ~= "function" then
    return nil
  end
  local O, P = pcall(function()
    return ACD19_mwPreferenceModule:new(l)
  end)
  if not O then
    return nil
  end
  if
    P == nil
    or type(P["get"]) ~= "function"
    or type(P["set"]) ~= "function"
    or type(P["save"]) ~= "function"
    or type(P["load"]) ~= "function"
  then
    return nil
  end
  return P
end
local function k()
  if type(require) == "function" then
    local l, O = pcall(require, "preferences")
    if l and type(O) == "table" then
      ACD19_mwPreferenceModule = O
    end
  end
  if ACD19_mwPreferenceModule == nil and type(Preferences) == "table" then
    ACD19_mwPreferenceModule = Preferences
  end
  local l = ACD19_mwNewPreferences(ACD19_LEGACY_MW_PREF_NAME)
  if l ~= nil then
    pcall(function()
      l:load()
      for O, P in ipairs(ACD19_MW_KEYS) do
        N[P] = l:get(P, "")
      end
    end)
  end
  local U = ACD19_mwNewPreferences(O)
  if U == nil then
    return
  end
  local w = pcall(function()
    U:load()
  end)
  if not w then
    return
  end
  P = U
  local v, E = pcall(function()
    return U:get("schema", "")
  end)
  if v and tostring(E) == ACD19_MW_SCHEMA then
    local l = pcall(function()
      for l, O in ipairs(ACD19_MW_KEYS) do
        N[O] = U:get(O, N[O] or "")
      end
    end)
    if l then
      ACD19_mwSettingsRestored = true
    end
  end
end
local function F(l, U)
  N[l] = tostring(U)
  if P == nil then
    ACD19_setAutoSaveStatus("SAVE UNAVAILABLE")
    return false
  end
  local w = pcall(function()
    if P:set("schema", ACD19_MW_SCHEMA) == false then
      error("schema write failed")
    end
    for l, O in ipairs(ACD19_MW_KEYS) do
      if P:set(O, tostring(N[O] or "")) == false then
        error("settings write failed: " .. O)
      end
    end
    if P:save() == false then
      error("settings save failed")
    end
  end)
  if w then
    local l, P = pcall(function()
      local l = ACD19_mwNewPreferences(O)
      if l == nil then
        return false
      end
      if l:load() == false then
        return false
      end
      if tostring(l:get("schema", "")) ~= ACD19_MW_SCHEMA then
        return false
      end
      for O, P in ipairs(ACD19_MW_KEYS) do
        if tostring(l:get(P, "")) ~= tostring(N[P] or "") then
          return false
        end
      end
      return true
    end)
    w = l and P == true
  end
  ACD19_setAutoSaveStatus(w and "SAVED - REOPEN SAFE" or "SAVE FAILED")
  return w
end
local function V(l, O, P, U)
  local w = math["floor"](tonumber(N[l]) or O)
  return math["min"](U, math["max"](P, w))
end
k()
local f = v(w(N["worlds"]))
local x = s(E(N["items"]))
local C = U(N["dropworld"])
local t = V("dropx", 0, -1, 999)
local R = V("dropy", 0, -1, 999)
local n = V("fastpickupdelay", 300, 0, 1000)
local c = V("pickupdelay", 0, 0, 1000)
local M = V("acktimeout", 900, 300, 10000)
local H = V("batchmax", 2, 1, 2)
local Q = V("droptotal", 0, 0, 1000000000)
local d = UserInterface["new"](l, "Inventory")
d:addLabelApp("Auto Collect V6.1 Exact Tile Mixed Pickup", "Inventory")
d:addToggle("Start / Stop", false, "ACD_enable")
d:addToggle("Fast Collect", N["fastcollect"] == "true", "ACD_fastcollect")
d:addItemPicker("Add Collect Item", "Dirt", "2", "ACD_itempicker")
d:addInputString("Selected Items (view only)", "NONE", "Selected item IDs", "List", nil, "ACD_selecteditem")
d:addButton("Remove Last Collect Item", "ACD_removeitem")
d:addButton("Clear Collect Items", "ACD_clearitems")
d:addInputString("Total Drop Per Item (0 = until worlds empty)", tostring(Q), "Items", "210", nil, "ACD_droptotal")
d:addInputString("Drop Progress Per Item (view only)", "NONE", "Dropped / goal", "Status", nil, "ACD_dropprogress")
local D = d:addDialog("Settings", "Item IDs, collection worlds, shared storage, delays", {})
d:addChildTooltip(
  D["menu"],
  "Selected Items",
  "Use Add Collect Item on the main screen, or enter comma-separated item IDs here. Items are saved; changes take effect on next Start.",
  "Inventory",
  true
)
d:addChildInputString(
  D["menu"],
  "Collect Item IDs (comma-separated)",
  x,
  "e.g. 2, 3, 4",
  "2, 3, 4",
  "Inventory",
  "ACD_itemlist"
)
d:addChildTooltip(
  D["menu"],
  "Collection Worlds",
  "List worlds in order, separated by commas. Add Current World / Remove Last World edit the list. Changes made while running apply on the next Start.",
  "Inventory",
  true
)
d:addChildInputString(
  D["menu"],
  "Collection Worlds (comma-separated)",
  f,
  "World 1, World 2, ...",
  "FARM1, FARM2",
  "Inventory",
  "ACD_worldlist"
)
d:addChildButton(D["menu"], "Add Current World", "ACD_addworld")
d:addChildButton(D["menu"], "Remove Last World", "ACD_removeworld")
d:addChildInputString(D["menu"], "Shared Storage World", C, "World", "STORAGE", "Inventory", "ACD_dropworld")
d:addChildButton(D["menu"], "Storage World = Current World", "ACD_setdropworld")
d:addChildInputInt(D["menu"], "Drop Position X (Standing Tile)", tostring(t), "X", "0", "Inventory", "ACD_dropx")
d:addChildInputInt(D["menu"], "Drop Position Y (Standing Tile)", tostring(R), "Y", "0", "Inventory", "ACD_dropy")
d:addChildButton(D["menu"], "Drop Position = Current Tile", "ACD_setdrop")
d:addChildTooltip(
  D["menu"],
  "Storage behavior",
  "0 means unlimited: collect selected items until each world is empty (3 checks). If a full backpack stack blocks more items of its type, store only that type and resume the SAME world. Otherwise batch full types together. Final partial stacks are stored when all worlds finish.",
  "Inventory",
  false
)
d:addChildTooltip(
  D["menu"],
  "Run Mode: Single Pass",
  "Visit each collection world once in order. After the final world is empty, store remaining selected items and stop automatically. Press Start again for a new round.",
  "Inventory",
  true
)
d:addChildInputInt(D["menu"], "After Pickup Delay", tostring(c), "ms", "0", "Inventory", "ACD_pickupdelay")
d:addChildInputInt(D["menu"], "Batch ACK Timeout", tostring(M), "ms", "900", "Inventory", "ACD_acktimeout")
d:addChildInputInt(D["menu"], "Fast Pickup Delay", tostring(n), "ms", "300", "Inventory", "ACD_fastpickupdelay")
d:addChildInputInt(D["menu"], "Max Pickup Batch (max 2)", tostring(H), "items", "2", "Inventory", "ACD_batchmax")
d:addChildTooltip(
  D["menu"],
  "Persistent Auto Save",
  "Changes save immediately when an input is committed or a selection button is pressed. No Start is needed. Check Settings Auto Save on the main menu. Start always reopens OFF.",
  "Inventory",
  false
)
d:addDisplayList("Items Configured", tostring(#E(x)), "ACD_itemcount")
d:addDisplayList("Worlds Configured", tostring(#w(f)), "ACD_worldcount")
d:addDisplayList("Current Collection World", "NOT STARTED", "ACD_worldprogress")
d:addDisplayList("Shared Storage World", C ~= "" and C or "NOT SET", "ACD_storageprogress")
d:addDisplayList("Server Pace", "CAUTIOUS (2)", "ACD_serverpace")
d:addDisplayList("Shared Storage Trips", "0", "ACD_loops")
d:addDisplayList("Status", "STOPPED", "ACD_status")
d:addDisplayList("Selected Inventory", "NONE", "ACD_inventory")
d:addDisplayList("Dropped Objects Found", "0", "ACD_objects")
d:addDisplayList("Skipped Blocked / Unreachable", "0", "ACD_exactskipped")
d:addDisplayList(
  "Settings Auto Save",
  P == nil and "UNAVAILABLE" or (ACD19_mwSettingsRestored and "RESTORED" or "READY - SAVES ON EDIT"),
  "ACD_autosave"
)
pcall(function()
  addCategory(l, "Inventory")
end)
local I = pcall(function()
  addIntoModule(d:generateJSON(), l)
end)
if not I then
  addIntoModule(d:generateJSON())
end
local J = false
local T = false
local p = 0
local K = E(x)
local A, b = {}, {}
local o = 200
local r = Q
local W = Q
local B = {}
local z = false
local Y = {}
local e = c
local L = M
local j = H
local m = math["min"](2, H)
local u = 0
local G = 0
local y = ""
local g = w(f)
local Z = {}
local a = 1
local q = false
local X = 0
local h = 0
local S = C
local i = t
local lM = R
local OM = 0
local PM = 0
local NM = "STOPPED"
local UM = true
local wM = 0
local vM = 1
ACD_EXACT_skippedByWorld = {}
ACD_EXACT_skipCountByWorld = {}
ACD_EXACT_totalSkipped = 0
local EM = 15000
local sM = 9000
local kM = 1300
local FM = 450
local VM = 1100
local fM = 100
local xM = 700
local CM = 6
local tM = 2200
local RM = 350
local nM = 6000
local cM = 25
local MM = 1000
local HM = 60
local QM = 80
local dM = 25
local DM = 1
local IM = 180
local JM = 450
local TM = 90
local pM = 1800
local KM = 2000
local AM = 2200
local bM = 2
local oM = 350
local rM = 100
local WM = 250
local BM = 1200
local zM = 4
local YM = 2600
local eM = 300
local LM = 350
ACD19_DROP_SECOND_PATH_STABLE_MS = 500
ACD19_DROP_PRE_PACKET_STABLE_MS = 200
ACD19_DROP_STABLE_POLL_MS = 100
local jM = false
local mM = false
local uM = false
local GM = false
local yM = nil
local gM = 0
local ZM = false
ACD19_storageEntryConfirmed = false
ACD19_storageEntryConfirmedX = nil
ACD19_storageEntryConfirmedY = nil
local aM = 0
local qM = {}
local XM = 2
local function hM(l)
  pcall(function()
    growtopia["notify"](tostring(l))
  end)
end
local function SM(l)
  l = tostring(l)
  if NM ~= l then
    NM = l
    ACD19_safeEditValue("ACD_status", l)
  end
end
local function iM()
  local l = #Z
  if J and (l > 0 and a <= l) then
    pcall(function()
      ACD19_safeEditValue("ACD_worldprogress", tostring(a) .. ("/" .. (tostring(l) .. (" - " .. tostring(y)))))
    end)
  elseif l > 0 and a > l then
    pcall(function()
      ACD19_safeEditValue("ACD_worldprogress", "ALL WORLDS SCANNED")
    end)
  else
    pcall(function()
      ACD19_safeEditValue("ACD_worldprogress", "NOT STARTED")
    end)
  end
  pcall(function()
    ACD19_safeEditValue("ACD_worldcount", tostring(#g))
  end)
  pcall(function()
    ACD19_safeEditValue("ACD_storageprogress", S ~= "" and S or "NOT SET")
  end)
end
local function lh()
  local l = v(g)
  pcall(function()
    ACD19_safeEditValue("ACD_worldlist", l)
  end)
  pcall(function()
    ACD19_safeEditValue("ACD_worldcount", tostring(#g))
  end)
  F("worlds", l)
end
local function Oh(l, O)
  local P = editToggle or EditToggle
  if P ~= nil then
    pcall(P, l, O == true)
  end
end
local Ph = nil
local Nh = nil
local function Uh(l)
  l = l == true
  if l == Ph then
    return
  end
  Ph = l
  Oh("ModFly", l)
end
local function wh(l)
  l = l == true
  if l == Nh then
    return
  end
  Nh = l
  Oh("Enable AutoCollect", l)
  Oh("Autocollect", l)
end
local function vh(l)
  l = tostring(l or "")
  l = l:gsub("%s+", "")
  return l:upper()
end
ACD61_activeDoorRoute = ""
function ACD61_physicalWorld()
  local l, O = pcall(function()
    if type(GetWorldName) == "function" then
      return GetWorldName()
    elseif type(getCurrentWorldName) == "function" then
      return getCurrentWorldName()
    end
    return ""
  end)
  if not l then
    return ""
  end
  return vh(O)
end
local function Eh()
  local l = ACD61_physicalWorld()
  if ACD61_activeDoorRoute ~= "" and l ~= "" then
    local O = ACD61_activeDoorRoute:match("^([^|]+)|")
    if O == l then
      return ACD61_activeDoorRoute
    end
  end
  return l
end
function ACD61_parseWorldRoute(l)
  l = vh(l)
  if l == "" then
    return "", nil
  end
  local O, P = l:match("^([^|]+)|([^|]+)$")
  if O then
    return O, P
  end
  if l:find("|", 1, true) then
    return "", nil
  end
  return l, nil
end
local function sh(l, O)
  l = vh(l)
  O = vh(O)
  return l ~= "" and (O ~= "" and l == O)
end
local function kh()
  return sh(y, S) and sh(Eh(), S)
end
local function Fh()
  return sh(Eh(), S) and (kh() or uM)
end
local function Vh(l, O)
  l = tonumber(l)
  O = tonumber(O)
  if l == nil or O == nil then
    return false
  end
  local P = math["min"](i, OM) - vM
  local N = math["max"](i, OM) + vM
  return l >= P and (l <= N and math["abs"](O - lM) <= vM)
end
local function fh()
  local l = GetLocal or getLocal
  if l == nil then
    return nil
  end
  local O, P = pcall(l)
  if O then
    return P
  end
  return nil
end
local function xh()
  local l = GetTiles or getTiles
  if l == nil then
    return nil
  end
  local O, P = pcall(l)
  if O and type(P) == "table" then
    return P
  end
  return nil
end
local function Ch()
  local l = GetObjectList or getObjectList
  if l == nil then
    return {}
  end
  local O, P = pcall(l)
  if O and type(P) == "table" then
    return P
  end
  return {}
end
local function th(l)
  local O, P = pcall(function()
    if growtopia ~= nil and type(growtopia["checkInventoryCount"]) == "function" then
      return growtopia["checkInventoryCount"](l)
    end
    local O = GetInventory or getInventory
    if O == nil then
      return 0
    end
    local P = O()
    for O, P in pairs(P or {}) do
      if tonumber(P["id"]) == tonumber(l) then
        return tonumber(P["amount"]) or 0
      end
    end
    return 0
  end)
  if not O then
    return 0
  end
  return tonumber(P) or 0
end
local function Rh(l)
  local O, P = pcall(function()
    if growtopia ~= nil and type(growtopia["getItemName"]) == "function" then
      return growtopia["getItemName"](l)
    end
    if type(getItemInfoByID) == "function" then
      local O = getItemInfoByID(l)
      if O ~= nil then
        return O["name"]
      end
    end
    return nil
  end)
  if O and (P ~= nil and tostring(P) ~= "") then
    return tostring(P)
  end
  return "Item " .. tostring(l)
end
local function nh()
  if #A > 0 and J then
    return A
  end
  return K
end
local function ch()
  local l = 0
  for O, P in ipairs(nh()) do
    l = l + th(P)
  end
  return l
end
local function Mh(l)
  if W <= 0 then
    return nil
  end
  return math["max"](0, W - (B[l] or 0))
end
local function Hh()
  if W <= 0 or #A == 0 then
    return false
  end
  for l, O in ipairs(A) do
    if (B[O] or 0) < W then
      return false
    end
  end
  return true
end
local function Qh(l)
  local O = th(l)
  if O >= o then
    return false
  end
  local P = Mh(l)
  return P == nil or O < P
end
local function dh()
  for l, O in ipairs(nh()) do
    if th(O) >= o then
      return O
    end
  end
  return nil
end
local function Dh(l)
  local O = math["max"](0, th(l))
  local P = Mh(l)
  if P == nil then
    return O
  end
  return math["min"](O, P)
end
local function Ih()
  local l = 0
  for O, P in ipairs(A) do
    l = l + Dh(P)
  end
  return l
end
local function Jh()
  if #A == 0 then
    return false
  end
  for l, O in ipairs(A) do
    if Qh(O) then
      return false
    end
  end
  return Ih() > 0
end
local function Th()
  if W <= 0 then
    return "UNLIMITED"
  end
  local l = {}
  for O, P in ipairs(A) do
    local N = Mh(P)
    if N and N > 0 then
      l[#l + 1] = tostring(P) .. (":" .. tostring(N))
    end
  end
  return #l == 0 and "ALL COMPLETE" or table["concat"](l, ", ")
end
local function ph()
  local l = (#A > 0 and J) and A or K
  local O = {}
  for l, P in ipairs(l) do
    O[#O + 1] = tostring(P) .. (": " .. (tostring(B[P] or 0) .. (" / " .. (W > 0 and tostring(W) or "unlimited"))))
  end
  pcall(function()
    ACD19_safeEditValue("ACD_dropprogress", #O > 0 and table["concat"](O, " | ") or "NONE")
  end)
end
local function Kh()
  if z then
    return
  end
  z = true
  Y = {}
  for l, O in ipairs(A) do
    Y[O] = th(O)
  end
end
local function Ah()
  if not z then
    return
  end
  local l = false
  for O, P in ipairs(A) do
    local N = th(P)
    local U = Y[P]
    if U ~= nil and N < U then
      B[P] = (B[P] or 0) + (U - N)
      l = true
    end
    Y[P] = N
  end
  if l then
    ph()
  end
end
local function bh()
  Ah()
  z = false
  Y = {}
  ACD19_storageEntryConfirmed = false
  ACD19_storageEntryConfirmedX, ACD19_storageEntryConfirmedY = nil, nil
end
local function oh()
  if #K == 0 then
    return "NONE"
  end
  local l = {}
  for O, P in ipairs(K) do
    l[#l + 1] = Rh(P) .. (" (" .. (tostring(P) .. ")"))
  end
  return table["concat"](l, ", ")
end
local function rh()
  pcall(function()
    ACD19_safeEditValue("ACD_selecteditem", oh())
  end)
  pcall(function()
    ACD19_safeEditValue("ACD_itemcount", tostring(#K))
  end)
end
local function Wh()
  local l = s(K)
  pcall(function()
    ACD19_safeEditValue("ACD_itemlist", l)
  end)
  F("items", l)
  rh()
  ph()
end
local Bh = nil
local function zh()
  local l = nh()
  local O = "NONE"
  if #l > 0 then
    local P = {}
    for l, O in ipairs(l) do
      P[#P + 1] = tostring(O) .. (":" .. tostring(th(O)))
    end
    O = table["concat"](P, "  |  ")
  end
  if O ~= Bh then
    Bh = O
    pcall(function()
      ACD19_safeEditValue("ACD_inventory", O)
    end)
  end
end
local function Yh()
  ACD19_safeEditValue("ACD_loops", tostring(wM))
end
local function eh()
  local l = fh()
  if l == nil then
    return nil, nil
  end
  local O, P = tonumber(l["posX"]), tonumber(l["posY"])
  if O == nil or P == nil then
    return nil, nil
  end
  return O // 32, P // 32
end
local function Lh(l, O)
  local P, N = eh()
  return P == l and N == O
end
local jh = ""
local mh = ""
local uh = ""
local function Gh(l)
  local O = ACD61_physicalWorld()
  local P = vh(l)
  local N, U = ACD61_parseWorldRoute(P)
  if N == "" then
    return false
  end
  if O ~= mh then
    mh = O
    jh = ""
    uh = ""
    ACD61_activeDoorRoute = ""
  end
  local w = fh()
  if O ~= N or w == nil then
    return false
  end
  if U and ACD61_activeDoorRoute ~= P then
    return false
  end
  if not U and ACD61_activeDoorRoute ~= "" then
    return false
  end
  if tonumber(w["posX"]) == nil or tonumber(w["posY"]) == nil then
    return false
  end
  if jh == N then
    return true
  end
  local v = xh()
  if v ~= nil and next(v) ~= nil then
    jh = N
    return true
  end
  return false
end
local function yh(l)
  local O = vh(l)
  return uh == O and Gh(O)
end
local function gh(l, O, P)
  local N = vh(l)
  if yh(N) then
    return true
  end
  local U = 0
  local w = 0
  local v, E = nil, nil
  SM("WAIT PLAYER READY " .. tostring(N))
  while J and U < O do
    if Gh(N) then
      local l = fh()
      local O = l and tonumber(l["posX"])
      local s = l and tonumber(l["posY"])
      if O ~= nil and s ~= nil then
        if v == O and E == s then
          w = w + fM
        else
          w = 0
          v, E = O, s
        end
        if w >= xM and U >= (P or 0) then
          uh = N
          return J and yh(N)
        end
      end
    else
      w = 0
      v, E = nil, nil
    end
    Sleep(fM)
    U = U + fM
  end
  return false
end
local function Zh(l, O)
  l = vh(l)
  if l == "" then
    return false
  end
  O = O or EM
  if l ~= S then
    ACD19_storageEntryConfirmed = false
    ACD19_storageEntryConfirmedX = nil
    ACD19_storageEntryConfirmedY = nil
  end
  local P, N = ACD61_parseWorldRoute(l)
  if P == "" then
    SM("INVALID WORLD OR DOOR ID")
    return false
  end
  if N then
    if yh(l) then
      Uh(true)
      return true
    end
    if ACD61_physicalWorld() ~= P or ACD61_activeDoorRoute ~= "" then
      ACD61_activeDoorRoute = ""
      jh = ""
      uh = ""
      Ph = nil
      SM("WARP BASE " .. P)
      local l, O = pcall(function()
        return growtopia["warpTo"](P)
      end)
      if not l or O == false then
        return false
      end
    end
    if not gh(P, O, VM) then
      return false
    end
    if not J or ACD61_physicalWorld() ~= P then
      return false
    end
    SM("ENTER DOOR " .. l)
    jh = ""
    uh = ""
    local N, U = pcall(function()
      return SendPacket(3, "action|join_request\nname|" .. (l .. "\ninvitedWorld|0"))
    end)
    if not N or U == false then
      return false
    end
    Sleep(1400)
    if not J or ACD61_physicalWorld() ~= P then
      return false
    end
    if not gh(P, O, VM) then
      return false
    end
    ACD61_activeDoorRoute = l
    jh = ""
    uh = ""
    local w = gh(l, O, VM)
    if w then
      Uh(true)
    end
    return w
  end
  if ACD61_activeDoorRoute ~= "" then
    ACD61_activeDoorRoute = ""
    jh = ""
    uh = ""
    Ph = nil
    SM("RETURN BASE " .. l)
    local P, N = pcall(function()
      return growtopia["warpTo"](l)
    end)
    if not P or N == false then
      return false
    end
    local U = gh(l, O, VM)
    if U then
      Uh(true)
    end
    return U
  end
  if yh(l) then
    Uh(true)
    return true
  end
  if Gh(l) then
    local P = gh(l, O, VM)
    if P then
      Uh(true)
    end
    return P
  end
  SM("WARP " .. l)
  jh = ""
  uh = ""
  Ph = nil
  local U = pcall(function()
    growtopia["warpTo"](l)
  end)
  if not U then
    return false
  end
  local w = gh(l, O, VM)
  if w then
    Uh(true)
  end
  return w
end
local function ah(l, O)
  if Lh(l, O) then
    return true
  end
  Uh(true)
  for P = 1, CM, 1 do
    if not J then
      return false
    end
    SM("PATH " .. (tostring(P) .. ("/" .. (tostring(CM) .. (" -> " .. (tostring(l) .. ("," .. tostring(O))))))))
    pcall(function()
      FindPath(l, O)
    end)
    local N = 0
    while J and N < tM do
      if Lh(l, O) then
        Sleep(120)
        return true
      end
      Sleep(100)
      N = N + 100
    end
    Sleep(RM)
  end
  return Lh(l, O)
end
local function qh(l, O)
  if not J or not yh(S) then
    return false
  end
  l = math["floor"](tonumber(l) or OM or i)
  O = math["floor"](tonumber(O) or PM or lM)
  if Lh(l, O) then
    return true
  end
  Uh(true)
  for P = 1, zM, 1 do
    if not J or not yh(S) then
      return false
    end
    SM("DROP PATH " .. (tostring(P) .. ("/" .. (tostring(zM) .. (" -> " .. (tostring(l) .. ("," .. tostring(O))))))))
    pcall(function()
      FindPath(l, O)
    end)
    local N = 0
    while J and (yh(S) and N < YM) do
      if Lh(l, O) then
        Sleep(eM)
        return J and Lh(l, O)
      end
      Sleep(100)
      N = N + 100
    end
    if P < zM then
      Sleep(LM)
    end
  end
  return Lh(l, O)
end
function ACD19_stableAtStorageTile(l, O, P, N)
  local U, w = 0, 0
  while J and w <= N do
    if not yh(S) then
      return false
    end
    if Lh(l, O) then
      if U >= P then
        return true
      end
      U = U + ACD19_DROP_STABLE_POLL_MS
    else
      U = 0
    end
    if w >= N then
      break
    end
    Sleep(ACD19_DROP_STABLE_POLL_MS)
    w = w + ACD19_DROP_STABLE_POLL_MS
  end
  return J and (yh(S) and (Lh(l, O) and U >= P))
end
function ACD19_confirmStorageDropPosition()
  if not J or not yh(S) then
    ACD19_storageEntryConfirmed = false
    return false
  end
  local l, O = OM, PM
  if
    ACD19_storageEntryConfirmed and (
      ACD19_storageEntryConfirmedX == l and (ACD19_storageEntryConfirmedY == O and Lh(l, O))
    )
  then
    return true
  end
  ACD19_storageEntryConfirmed = false
  SM("STORAGE PATH 1/2 -> " .. (tostring(l) .. ("," .. tostring(O))))
  if not qh(l, O) then
    return false
  end
  if not ACD19_stableAtStorageTile(l, O, eM, 900) then
    SM("WAIT FIRST STORAGE ARRIVAL")
    return false
  end
  SM("STORAGE PATH 2/2 -> " .. (tostring(l) .. ("," .. tostring(O))))
  local P = pcall(function()
    FindPath(l, O)
  end)
  if not P then
    SM("WAIT SECOND STORAGE PATH")
    return false
  end
  if not ACD19_stableAtStorageTile(l, O, ACD19_DROP_SECOND_PATH_STABLE_MS, 1400) then
    SM("WAIT VERIFIED STORAGE POSITION")
    return false
  end
  ACD19_storageEntryConfirmed = true
  ACD19_storageEntryConfirmedX, ACD19_storageEntryConfirmedY = l, O
  SM("STORAGE POSITION CONFIRMED " .. (tostring(l) .. ("," .. tostring(O))))
  return true
end
local function Xh(l, O)
  local P = GetTile or getTile
  if P == nil then
    return nil
  end
  local N, U = pcall(P, l, O)
  if N then
    return U
  end
  return nil
end
local function hh(l, O)
  local P = Xh(l, O)
  return P ~= nil and P["collidable"] ~= true
end
function ACD_EXACT_isSkipped(l)
  local O = tostring(l or "")
  local P = ACD_EXACT_skippedByWorld[y]
  return P ~= nil and P[O] ~= nil
end
function ACD_EXACT_markSkipped(l, O)
  local P = tostring(l or "")
  if P == "" or P == "nil" or y == "" then
    return
  end
  if ACD_EXACT_skippedByWorld[y] == nil then
    ACD_EXACT_skippedByWorld[y] = {}
  end
  local N = ACD_EXACT_skippedByWorld[y]
  if N[P] ~= nil then
    return
  end
  N[P] = tostring(O or "NO PATH")
  ACD_EXACT_skipCountByWorld[y] = (ACD_EXACT_skipCountByWorld[y] or 0) + 1
  ACD_EXACT_totalSkipped = ACD_EXACT_totalSkipped + 1
  ACD19_safeEditValue("ACD_exactskipped", tostring(ACD_EXACT_totalSkipped))
  SM("SKIP " .. (tostring(O or "NO PATH") .. (" @ " .. tostring(y))))
end
local function Sh(l)
  if l == nil then
    return nil, nil
  end
  local O = tonumber(l["posX"])
  local P = tonumber(l["posY"])
  local N = l["pos"]
  if (O == nil or P == nil) and N ~= nil then
    O = O or tonumber(N["x"])
    P = P or tonumber(N["y"])
  end
  return O, P
end
local function ih(l)
  l = tonumber(l)
  if l == nil then
    return false
  end
  for O, P in pairs(Ch()) do
    if tonumber(P["id"]) == l then
      return true
    end
  end
  return false
end
local function lb()
  local l, O = eh()
  local P = {}
  local N = Ch()
  for N, U in pairs(N) do
    if tonumber(U["id"]) and (b[tonumber(U["itemid"])] == true and Qh(tonumber(U["itemid"]))) then
      local N, w = Sh(U)
      if N ~= nil and w ~= nil then
        local v = math["floor"](N / 32)
        local E = math["floor"](w / 32)
        local s = 0
        if l ~= nil and O ~= nil then
          s = math["abs"](l - v) + math["abs"](O - E)
        end
        local k = kh() and Vh(v, E)
        if not k and not ACD_EXACT_isSkipped(U["id"]) then
          table["insert"](
            P,
            {
              ["object"] = U,
              ["uid"] = tonumber(U["id"]),
              ["itemID"] = tonumber(U["itemid"]),
              ["amount"] = tonumber(U["amount"]) or 0,
              ["pixelX"] = N,
              ["pixelY"] = w,
              ["tileX"] = v,
              ["tileY"] = E,
              ["distance"] = s,
            }
          )
        end
      end
    end
  end
  if #P > 1 then
    local O = {}
    local N = {}
    for l, P in ipairs(P) do
      local U = P["tileY"]
      if O[U] == nil then
        O[U] = {}
        table["insert"](N, U)
      end
      table["insert"](O[U], P)
    end
    table["sort"](N, function(l, O)
      return l < O
    end)
    local U = true
    if l ~= nil and #N > 0 then
      local P = O[N[1]]
      local w = math["huge"]
      local v = -math["huge"]
      for l, O in ipairs(P) do
        if O["tileX"] < w then
          w = O["tileX"]
        end
        if O["tileX"] > v then
          v = O["tileX"]
        end
      end
      if math["abs"](l - v) < math["abs"](l - w) then
        U = false
      end
    end
    local w = {}
    for l, P in ipairs(N) do
      local N = O[P]
      local v
      if l % 2 == 1 then
        v = U
      else
        v = not U
      end
      table["sort"](N, function(l, O)
        if v then
          return l["tileX"] < O["tileX"]
        else
          return l["tileX"] > O["tileX"]
        end
      end)
      for l, O in ipairs(N) do
        table["insert"](w, O)
      end
    end
    P = w
  end
  ACD19_safeEditValue("ACD_objects", tostring(#P))
  return P
end
local function Ob()
  local l = {}
  for O, P in pairs(Ch()) do
    local N = tonumber(P and P["itemid"])
    if N and (b[N] and th(N) >= o) then
      local O, U = Sh(P)
      if O ~= nil and U ~= nil then
        local w, v = math["floor"](O / 32), math["floor"](U / 32)
        if not (kh() and Vh(w, v)) and not ACD_EXACT_isSkipped(P["id"]) then
          l[N] = true
        end
      end
    end
  end
  return l, next(l) ~= nil
end
local function Pb(l)
  if l == nil or l["uid"] == nil then
    return false
  end
  local O = pcall(function()
    SendPacketRaw(false, { ["type"] = 11, ["value"] = l["uid"], ["x"] = l["pixelX"], ["y"] = l["pixelY"] })
  end)
  return O
end
local function Nb(l)
  local O = 0
  while J and (Eh() == y and O < L) do
    if ch() > l then
      return true
    end
    Sleep(dM)
    O = O + dM
  end
  return J and (Eh() == y and ch() > l)
end
local function Ub(l, O)
  if not J or Eh() ~= y then
    return false
  end
  if Lh(l, O) then
    return true
  end
  Uh(true)
  local P = pcall(function()
    FindPath(l, O)
  end)
  if not P then
    return false
  end
  local N, U = 0, 0
  local w, v = eh()
  while J and N < nM do
    if Eh() ~= y then
      return false
    end
    local P, E = eh()
    if P == nil or E == nil then
      return false
    end
    if Lh(l, O) then
      Sleep(HM)
      return J and (Eh() == y and Lh(l, O))
    end
    if P ~= w or E ~= v then
      U = 0
      w, v = P, E
    else
      U = U + cM
    end
    if N >= 2000 and U >= MM then
      return Lh(l, O)
    end
    Sleep(cM)
    N = N + cM
  end
  return false
end
local function wb()
  local l = "CAUTIOUS"
  if m >= 3 then
    l = "FAST"
  end
  if m == 1 then
    l = "LAG SAFE"
  end
  pcall(function()
    ACD19_safeEditValue("ACD_serverpace", l .. (" (" .. (tostring(m) .. ")")))
  end)
end
local function vb()
  m = 1
  u = 0
  G = math["min"](G + 1, 5)
  wb()
end
local function Eb()
  G = 0
  u = u + 1
  if u >= 2 and m < j then
    m = m + 1
    u = 0
  end
  wb()
end
local function sb(l, O, P)
  if not J or Eh() ~= y then
    return "WORLD"
  end
  if not Qh(l["itemID"]) then
    return "FULL"
  end
  if not ih(l["uid"]) then
    return "GONE"
  end
  local N = ch()
  SM("PATH " .. (O .. ("/" .. P)))
  local U, w = l["tileX"], l["tileY"]
  if not Ub(U, w) then
    if not J or Eh() ~= y then
      return "WORLD"
    end
    if ch() > N then
      return "ACK"
    end
    if not ih(l["uid"]) then
      return "GONE"
    end
    return "SKIP"
  end
  if Fh() and Vh(U, w) then
    return "SKIP"
  end
  local v = {}
  for l, O in pairs(Ch()) do
    local P, N = tonumber(O["id"]), tonumber(O["itemid"])
    local E, s = Sh(O)
    if P and (N and (E and (s and (math["floor"](E / 32) == U and math["floor"](s / 32) == w)))) then
      v[#v + 1] = { ["uid"] = P, ["itemID"] = N, ["pixelX"] = E, ["pixelY"] = s }
    end
  end
  table["sort"](v, function(l, O)
    return l["uid"] < O["uid"]
  end)
  local E = false
  local function s(l, O)
    if not J or Eh() ~= y or not Lh(O, w) or not ih(l["uid"]) then
      return false
    end
    local P = th(l["itemID"])
    if P >= o or not Pb(l) then
      return false
    end
    E = true
    Sleep(TM + e)
    local N = 0
    while J and (Eh() == y and Lh(O, w)) do
      if th(l["itemID"]) > P or not ih(l["uid"]) then
        return false
      end
      if N >= L then
        return true
      end
      Sleep(dM)
      N = N + dM
    end
    return false
  end
  local k = {}
  for l, O in ipairs(v) do
    if not J or Eh() ~= y then
      return "WORLD"
    end
    if not Lh(U, w) then
      return "PATH"
    end
    if s(O, U) then
      local l = O["pixelX"] - U * 32
      local P = l >= 24 and U + 1 or (l <= 8 and U - 1 or nil)
      if P and P >= 0 then
        k[#k + 1] = { ["stack"] = O, ["x"] = P }
      end
    end
  end
  for l, O in ipairs(k) do
    if not J or Eh() ~= y then
      return "WORLD"
    end
    if
      ih(O["stack"]["uid"]) and (th(O["stack"]["itemID"]) < o and (not (Fh() and Vh(O["x"], w)) and Ub(O["x"], w)))
    then
      s(O["stack"], O["x"])
    end
  end
  if not J or Eh() ~= y then
    return "WORLD"
  end
  if ch() > N then
    return "ACK"
  end
  if E then
    return "SENT"
  end
  return "GONE"
end
local function kb(l)
  local O = {}
  for l, P in ipairs(l) do
    local N = math["max"](1, math["min"](99, P["tileX"]))
    if not yh(y) then
      return
    end
    if Jh() then
      return
    end
    if not O[P["uid"]] and (Qh(P["itemID"]) and (ih(P["uid"]) and (Ub(N, P["tileY"]) and yh(y)))) then
      local l, U = eh()
      if l == N and U == P["tileY"] then
        SM("FAST COLLECT ROW " .. tostring(U))
        local P = false
        for N, w in pairs(Ch()) do
          if not yh(y) then
            return
          end
          local v, E = tonumber(w["id"]), tonumber(w["itemid"])
          local s, k = Sh(w)
          if
            v
            and (
              not O[v]
              and (
                s
                and (
                  k
                  and (
                    math["floor"](k / 32) == U
                    and (
                      math["abs"](math["floor"](s / 32) - l) <= 2
                      and (not (kh() and Vh(math["floor"](s / 32), U)) and (E == 112 or (b[E] and Qh(E))))
                    )
                  )
                )
              )
            )
          then
            O[v] = true
            if Pb({ ["uid"] = v, ["pixelX"] = s, ["pixelY"] = k }) then
              P = true
            end
          end
        end
        if P and n > 0 then
          Sleep(n)
        end
      end
    end
  end
  Sleep(math["max"](100, L))
end
local function Fb(l)
  if type(l) ~= "table" or #l == 0 then
    return false
  end
  aM = aM + 1
  SM("ADAPTIVE COLLECT")
  Uh(true)
  wh(false)
  wb()
  local O, P = {}, {}
  local N = ch()
  local U = false
  local w = false
  local function v()
    if #O == 0 then
      N = ch()
      return true
    end
    if Jh() then
      O = {}
      return true
    end
    SM("WAIT BATCH ACK")
    local l = ch() > N
    if not l then
      l = Nb(N)
    end
    if l then
      w = true
      Eb()
      for l, O in ipairs(O) do
        if not ih(O["uid"]) then
          qM[tostring(O["uid"])] = nil
        end
      end
    else
      vb()
      for l, O in ipairs(O) do
        qM[tostring(O["uid"])] = aM + XM
      end
      SM("SERVER SLOW - BACKOFF")
      local l = math["min"](JM + 250 * G, pM)
      Sleep(l)
    end
    O = {}
    N = ch()
    return l
  end
  for N, E in ipairs(l) do
    if not J or Eh() ~= y then
      break
    end
    if Jh() then
      break
    end
    local s = tostring(E["uid"] or "")
    local k = E["tileX"] .. ("," .. E["tileY"])
    if s ~= "" and (not P[k] and aM >= (qM[s] or 0)) then
      if #O >= m then
        if not v() then
          break
        end
        if not J or Eh() ~= y then
          break
        end
      end
      if Jh() then
        break
      end
      U = true
      local F = sb(E, N, #l)
      if F ~= "GONE" then
        P[k] = true
      end
      if F == "WORLD" or F == "FULL" then
        break
      elseif F == "ACK" then
        w = true
        if #O > 0 then
          if not v() then
            break
          end
        else
          Eb()
        end
      elseif F == "SENT" then
        O[#O + 1] = E
      elseif F == "SKIP" then
        ACD_EXACT_markSkipped(E["uid"], "EXACT PATH FAILED")
      elseif F == "PATH" or F == "PACKET" then
        qM[s] = aM + XM
      end
    end
  end
  if J and (Eh() == y and not Jh()) then
    v()
  end
  if J and (Eh() == y and (not Jh() and not U)) then
    SM("WAIT DEFERRED PICKUPS")
    Sleep(300)
  end
  zh()
  return w
end
local function Vb(l)
  J = false
  ACD19_storageEntryConfirmed = false
  ACD19_storageEntryConfirmedX, ACD19_storageEntryConfirmedY = nil, nil
  q = false
  X = 0
  wh(false)
  Uh(false)
  jM = false
  mM = false
  uM = false
  GM = false
  yM = nil
  gM = 0
  ZM = false
  bh()
  ACD19_safeSetStartToggle(false)
  SM("STOPPED")
  if l ~= nil and l ~= "" then
    hM(l)
  end
end
local function fb()
  if not J then
    return false
  end
  local l = OM - 1
  local O = PM
  ZM = true
  SM("DROP SHIFT LEFT -> " .. (tostring(l) .. ("," .. tostring(O))))
  if not qh(l, O) then
    SM("WAIT LEFT PATH " .. (tostring(l) .. ("," .. tostring(O))))
    return false
  end
  OM = l
  PM = O
  ACD19_storageEntryConfirmed = false
  ZM = false
  hM("Storage moved left to (" .. (tostring(l) .. (", " .. (tostring(O) .. ")"))))
  return true
end
local function xb(l, O, P)
  if not J or not yh(S) then
    return false
  end
  if not ACD19_storageEntryConfirmed or not Lh(OM, PM) then
    SM("WAIT SAFE DROP POSITION")
    return false
  end
  if not ACD19_stableAtStorageTile(OM, PM, ACD19_DROP_PRE_PACKET_STABLE_MS, 650) then
    ACD19_storageEntryConfirmed = false
    SM("DROP BLOCKED - LEFT STORAGE TILE")
    return false
  end
  if th(l) < O then
    return true
  end
  jM = true
  mM = false
  SM("DROP REQUEST " .. tostring(l))
  local N = pcall(function()
    SendPacket(2, "action|drop\nitemID|" .. tostring(l))
  end)
  if not N then
    jM = false
    mM = false
    return false
  end
  local U = 0
  while J and (yh(S) and U < KM) do
    if mM or th(l) < O then
      break
    end
    Sleep(75)
    U = U + 75
  end
  local w = mM
  jM = false
  mM = false
  if not J or not yh(S) then
    return false
  end
  if th(l) < O then
    return true
  end
  if not w then
    return false
  end
  if not ACD19_storageEntryConfirmed or not ACD19_stableAtStorageTile(OM, PM, ACD19_DROP_PRE_PACKET_STABLE_MS, 650) then
    ACD19_storageEntryConfirmed = false
    SM("DROP CANCELLED - POSITION CHANGED")
    return false
  end
  SM("DROP CONFIRM " .. tostring(l))
  local v = pcall(function()
    SendPacket(
      2,
      "action|dialog_return\n"
        .. ("dialog_name|drop_item\n" .. ("itemID|" .. (tostring(l) .. ("|\n" .. ("count|" .. tostring(P))))))
    )
  end)
  if not v then
    return false
  end
  U = 0
  while J and (yh(S) and U < AM) do
    if th(l) < O then
      return true
    end
    Sleep(100)
    U = U + 100
  end
  return th(l) < O
end
local function Cb(l, O)
  while J do
    if not yh(S) then
      return false
    end
    Ah()
    if Dh(O) <= 0 then
      return true
    end
    if ZM then
      if not fb() then
        return false
      end
    end
    if not ACD19_confirmStorageDropPosition() then
      SM("WAIT VERIFIED STORAGE PATH")
      return false
    end
    Ah()
    local l = th(O)
    local P = Dh(O)
    if P <= 0 then
      return true
    end
    local N = false
    for U = 1, bM, 1 do
      if not J or not yh(S) then
        return false
      end
      Ah()
      if th(O) < l then
        N = true
        break
      end
      P = Dh(O)
      if P <= 0 then
        return true
      end
      SM("DROP " .. (tostring(O) .. (" x" .. (tostring(P) .. (" TRY " .. (tostring(U) .. ("/" .. tostring(bM))))))))
      if xb(O, l, P) then
        N = true
        break
      end
      if not ACD19_storageEntryConfirmed or not yh(S) or not Lh(OM, PM) then
        SM("STORAGE MOVED - RECHECK DROP TILE")
        return false
      end
      Sleep(oM)
      Ah()
      if th(O) < l then
        N = true
        break
      end
    end
    Ah()
    if N then
      local P = th(O)
      if P < l then
        SM("DROPPED " .. (tostring(l - P) .. (" " .. Rh(O))))
        zh()
      end
    else
      if not fb() then
        return false
      end
    end
  end
  return false
end
local function tb(l)
  local O = 0
  for P, N in ipairs(A) do
    if l == nil or l[N] then
      O = O + Dh(N)
    end
  end
  return O
end
local function Rb(l, O)
  Kh()
  Ah()
  if tb(O) <= 0 then
    return true
  end
  wh(false)
  if not Zh(S) then
    SM("WAIT SHARED STORAGE WORLD")
    return false
  end
  uM = true
  if ZM and not fb() then
    uM = false
    return false
  end
  if not ACD19_confirmStorageDropPosition() then
    uM = false
    SM("WAIT VERIFIED STORAGE PATH")
    return false
  end
  for P, N in ipairs(A) do
    if not J then
      break
    end
    Ah()
    if (O == nil or O[N]) and Dh(N) > 0 then
      if not Cb(l, N) then
        uM = false
        return false
      end
    end
  end
  Ah()
  uM = false
  zh()
  return J and tb(O) <= 0
end
local function nb()
  if not J or a > #Z then
    q = false
    return
  end
  local l = Z[a]
  y = l
  if Gh(l) then
    q = false
    X = 0
    return
  end
  q = true
  X = 0
  SM("STORED - RETURN TO " .. tostring(l))
end
local function cb()
  if not q then
    return true
  end
  if not J then
    return false
  end
  if a > #Z then
    q = false
    return true
  end
  local l = Z[a]
  y = l
  X = X + 1
  SM("RETURN " .. (tostring(X) .. (" -> " .. tostring(l))))
  if Zh(l, sM) and Gh(l) then
    Sleep(FM)
    if J and Gh(l) then
      q = false
      X = 0
      h = 0
      gM = 0
      aM = 0
      qM = {}
      SM("RESUMED " .. tostring(l))
      return true
    end
  end
  SM("RETURN WARP RETRY " .. (tostring(X) .. (" -> " .. tostring(l))))
  Sleep(kM)
  return false
end
local function Mb(l)
  if type(l) ~= "string" or l == "" then
    return nil
  end
  local O, P = pcall(function()
    if type(findItemID) == "function" then
      return findItemID(l)
    end
    if growtopia ~= nil and type(growtopia["getItemID"]) == "function" then
      return growtopia["getItemID"](l)
    end
    return nil
  end)
  if O and (tonumber(P) ~= nil and tonumber(P) > 0) then
    return math["floor"](tonumber(P))
  end
  return nil
end
local function Hb(l)
  if type(l) == "number" then
    return math["floor"](l)
  end
  if type(l) == "string" then
    local O = tonumber(l)
    if O ~= nil and O > 0 then
      return math["floor"](O)
    end
    local P = Mb(l)
    if P ~= nil then
      return P
    end
    local N = l:match("(%d+)")
    if N ~= nil then
      local l = tonumber(N)
      if l ~= nil and l > 0 then
        return math["floor"](l)
      end
    end
    return nil
  end
  if type(l) == "table" then
    local O = { l["id"], l["itemid"], l["itemID"], l["value"], l["item"], l["name"], l["itemName"], l["selected"] }
    for l, O in ipairs(O) do
      local P = Hb(O)
      if P ~= nil and P > 0 then
        return P
      end
    end
  end
  return nil
end
local function Qb(l)
  local O = Hb(l)
  if O == nil or O <= 0 or O > 65535 then
    return false
  end
  if J then
    hM("Stop before changing selected items.")
    return true
  end
  for l, P in ipairs(K) do
    if P == O then
      hM("Already selected: " .. (Rh(O) .. (" (" .. (tostring(O) .. ")"))))
      return true
    end
  end
  if #K >= 30 then
    hM("Maximum 30 selected items.")
    return true
  end
  K[#K + 1] = O
  Wh()
  zh()
  ACD19_safeEditValue("ACD_objects", "0")
  UM = true
  hM("Added collect item: " .. (Rh(O) .. (" (" .. (tostring(O) .. ")"))))
  return true
end
function onVariant(l, O)
  if l ~= nil and (l["v1"] == "OnDialogRequest" and type(l["v2"]) == "string") then
    if J and (jM and l["v2"]:find("drop_item", 1, true)) then
      mM = true
      return true
    end
  end
  return false
end
function onGamePacket(l)
  if l ~= nil and tonumber(l["type"]) == 26 then
    jh = ""
    mh = ""
    uh = ""
    ACD61_activeDoorRoute = ""
    ACD19_storageEntryConfirmed = false
    ACD19_storageEntryConfirmedX, ACD19_storageEntryConfirmedY = nil, nil
  end
  return false
end
function onSendPacketRaw(l)
  if not J or l == nil or tonumber(l["type"]) ~= 11 or not Fh() then
    return false
  end
  local O = tonumber(l["value"])
  if O == nil then
    return true
  end
  local P = nil
  for l, N in pairs(Ch()) do
    if tonumber(N and N["id"]) == O then
      P = N
      break
    end
  end
  if P == nil then
    return true
  end
  local N, U = Sh(P)
  if N == nil or U == nil then
    return true
  end
  local w, v = math["floor"](N / 32), math["floor"](U / 32)
  if kh() and Vh(w, v) then
    return true
  end
  if Fh() then
    if Vh(w, v) then
      return true
    end
    local l, O = eh()
    if l ~= nil and (O ~= nil and Vh(l, O)) then
      return true
    end
  end
  return false
end
local function db()
  J = true
  Uh(true)
  wh(false)
  if #K == 0 then
    Vb("Add at least one Collect Item first.")
    return
  end
  if #g == 0 then
    Vb("Add at least one Collection World in Settings first.")
    return
  end
  if S == "" then
    Vb("Set Drop World first.")
    return
  end
  F("repeat", false)
  F("loops", 0)
  Z, A, b = {}, {}, {}
  W = r
  B = {}
  z = false
  Y = {}
  for l, O in ipairs(g) do
    Z[#Z + 1] = O
  end
  for l, O in ipairs(K) do
    A[#A + 1] = O
    b[O] = true
  end
  if N["fastcollect"] == "true" then
    for l, O in ipairs(K) do
      local P = O + 1
      if O % 2 == 0 and (O ~= 112 and not b[P]) then
        A[#A + 1] = P
        b[P] = true
      end
    end
  end
  a = 1
  q = false
  X = 0
  y = Z[1]
  h = 0
  iM()
  OM = i
  PM = lM
  ACD19_storageEntryConfirmed = false
  ACD19_storageEntryConfirmedX, ACD19_storageEntryConfirmedY = nil, nil
  GM = false
  yM = nil
  gM = 0
  ZM = false
  ACD_EXACT_skippedByWorld = {}
  ACD_EXACT_skipCountByWorld = {}
  ACD_EXACT_totalSkipped = 0
  ACD19_safeEditValue("ACD_exactskipped", "0")
  aM = 0
  qM = {}
  m = math["min"](2, j)
  u = 0
  G = 0
  wb()
  UM = false
  wM = 0
  zh()
  ph()
  Yh()
  SM("STARTING")
  hM(
    "Auto Collect V6.1 started: " .. (
        W == 0 and "UNLIMITED UNTIL WORLDS EMPTY" or ("per-item drop goal " .. tostring(W))
      )
  )
end
function onValue(l, O, P)
  if O == "ACD_fastcollect" then
    if J then
      ACD19_safeEditValue(O, N["fastcollect"] == "true")
    else
      F("fastcollect", P == true or P == 1 or P == "true" or P == "1")
    end
    return
  end
  if ACD19_guardedUIWrites[O] then
    return
  end
  if O == "ACD_enable" then
    if P == true then
      if J or T then
        return
      end
      p = p + 1
      local l = p
      T = true
      Uh(false)
      wh(false)
      runThread(function()
        if not T or p ~= l then
          return
        end
        T = false
        db()
      end)
    else
      p = p + 1
      T = false
      J = false
      wh(false)
      Uh(false)
      jM = false
      mM = false
      uM = false
      GM = false
      ZM = false
      bh()
      SM("STOPPED")
      hM("Auto Collect -> Drop stopped.")
    end
    return
  end
  if O == "ACD_itempicker" then
    if not Qb(P) then
      hM("Could not read selected item.")
    end
    return
  end
  if O == "ACD_selecteditem" then
    rh()
    return
  end
  if O == "ACD_itemlist" then
    if J then
      pcall(function()
        ACD19_safeEditValue("ACD_itemlist", s(K))
      end)
      hM("Stop before editing the item list.")
      return
    end
    K = E(P)
    Wh()
    zh()
    return
  end
  if O == "ACD_removeitem" then
    if J then
      hM("Stop before removing items.")
      return
    end
    if #K > 0 then
      local l = table["remove"](K)
      Wh()
      zh()
      hM("Removed selected item " .. tostring(l))
    end
    return
  end
  if O == "ACD_clearitems" then
    if J then
      hM("Stop before clearing items.")
      return
    end
    K = {}
    Wh()
    zh()
    hM("Selected item list cleared.")
    return
  end
  if O == "ACD_droptotal" then
    local l = tonumber(P)
    if l == nil or l < 0 then
      pcall(function()
        ACD19_safeEditValue("ACD_droptotal", tostring(r))
      end)
      hM("Total Drop Per Item must be 0 or a positive whole number.")
      return
    end
    l = math["max"](0, math["min"](1000000000, math["floor"](l)))
    r = l
    F("droptotal", r)
    if tostring(P) ~= tostring(l) then
      pcall(function()
        ACD19_safeEditValue("ACD_droptotal", tostring(l))
      end)
    end
    if J then
      hM("Drop total saved. The new goal applies on next Start.")
    else
      W = r
      ph()
    end
    return
  end
  if O == "ACD_fastpickupdelay" then
    local l = tonumber(P)
    if l then
      n = math["max"](0, math["min"](1000, math["floor"](l)))
      F("fastpickupdelay", n)
    end
    return
  end
  if O == "ACD_pickupdelay" then
    local l = tonumber(P)
    if l ~= nil then
      l = math["floor"](l)
      if l < 0 then
        l = 0
      end
      if l > 1000 then
        l = 1000
      end
      e = l
      ACD19_safeEditValue("ACD_pickupdelay", tostring(e))
      F("pickupdelay", e)
    end
    return
  end
  if O == "ACD_batchmax" then
    local l = math["floor"](tonumber(P) or j)
    j = math["max"](1, math["min"](2, l))
    m = math["min"](m, j)
    pcall(function()
      ACD19_safeEditValue("ACD_batchmax", tostring(j))
    end)
    wb()
    F("batchmax", j)
    return
  end
  if O == "ACD_acktimeout" then
    local l = tonumber(P)
    if l ~= nil then
      l = math["floor"](l)
      if l < 300 then
        l = 300
      end
      if l > 10000 then
        l = 10000
      end
      L = l
      ACD19_safeEditValue("ACD_acktimeout", tostring(L))
      F("acktimeout", L)
    end
    return
  end
  if O == "ACD_worldlist" then
    g = w(P)
    lh()
    iM()
    if J then
      hM("World list saved; changes take effect on the next Start.")
    end
    return
  end
  if O == "ACD_addworld" then
    local l = Eh()
    if l == "" or l == "EXIT" then
      hM("Enter the world you want to add first.")
      return
    end
    local O = false
    for P, N in ipairs(g) do
      if N == l then
        O = true
        break
      end
    end
    if not O then
      if #g >= 30 then
        hM("Maximum 30 collection worlds.")
        return
      end
      g[#g + 1] = l
    end
    lh()
    iM()
    hM("Collection worlds: " .. v(g))
    return
  end
  if O == "ACD_removeworld" then
    if #g > 0 then
      local l = table["remove"](g)
      lh()
      iM()
      hM("Removed collection world " .. tostring(l))
    end
    return
  end
  if O == "ACD_dropworld" then
    if J then
      pcall(function()
        ACD19_safeEditValue("ACD_dropworld", S)
      end)
      hM("Stop the script before editing the Shared Storage World.")
      return
    end
    S = vh(P)
    F("dropworld", S)
    iM()
    return
  end
  if O == "ACD_setdropworld" then
    if J then
      hM("Stop before editing Shared Storage World.")
      return
    end
    local l = Eh()
    if l == "" or l == "EXIT" then
      hM("Current world is not available.")
      return
    end
    S = l
    ACD19_safeEditValue("ACD_dropworld", S)
    F("dropworld", S)
    iM()
    hM("Shared Storage World = " .. S)
    return
  end
  if O == "ACD_dropx" then
    if J then
      pcall(function()
        ACD19_safeEditValue("ACD_dropx", tostring(i))
      end)
      hM("Stop before editing Drop X.")
      return
    end
    local l = tonumber(P)
    if l ~= nil then
      i = math["floor"](l)
      OM = i
      F("dropx", i)
    end
    return
  end
  if O == "ACD_dropy" then
    if J then
      pcall(function()
        ACD19_safeEditValue("ACD_dropy", tostring(lM))
      end)
      hM("Stop before editing Drop Y.")
      return
    end
    local l = tonumber(P)
    if l ~= nil then
      lM = math["floor"](l)
      PM = lM
      F("dropy", lM)
    end
    return
  end
  if O == "ACD_setdrop" then
    if J then
      hM("Stop before setting Drop Position.")
      return
    end
    local l, O = eh()
    if l == nil or O == nil then
      hM("Player position is not available.")
      return
    end
    i = l
    lM = O
    OM = i
    PM = lM
    ACD19_safeEditValue("ACD_dropx", tostring(i))
    ACD19_safeEditValue("ACD_dropy", tostring(lM))
    F("dropx", i)
    F("dropy", lM)
    hM("Drop Position = (" .. (tostring(i) .. (", " .. (tostring(lM) .. ")"))))
    return
  end
end
applyHook()
if type(setOnValue) == "function" then
  pcall(function()
    setOnValue("ACD_itempicker", function(...)
      local l = { ... }
      for O = #l, 1, -1 do
        if Qb(l[O]) then
          return
        end
      end
    end)
  end)
end
runThread(function()
  Uh(false)
  rh()
  zh()
  Yh()
  ph()
  iM()
  wb()
  ACD19_safeEditValue("ACD_objects", "0")
  SM("STOPPED")
  ACD19_mwSaveState = P == nil and "UNAVAILABLE" or (ACD19_mwSettingsRestored and "RESTORED" or "READY - SAVES ON EDIT")
  ACD19_safeEditValue("ACD_autosave", ACD19_mwSaveState)
  while true do
    if not J then
      Sleep(200)
    else
      if q then
        cb()
      elseif Hh() then
        Vb("All selected item drop totals reached (" .. (tostring(W) .. " each)."))
      elseif GM or Jh() then
        GM = true
        wh(false)
        if yM then
          SM("UNLIMITED -> FREE FULL ITEM STACKS")
        else
          SM("ALL ITEMS READY -> SHARED STORAGE")
        end
        if Rb("Ready selected items dropped", yM) then
          GM = false
          yM = nil
          gM = 0
          bh()
          wM = wM + 1
          Yh()
          if Hh() then
            Vb("All selected item drop totals reached (" .. (tostring(W) .. " each)."))
          else
            nb()
            Sleep(150)
          end
        else
          Sleep(400)
        end
      elseif a > #Z then
        if Ih() > 0 then
          SM("FINAL STORAGE -> STOP")
          if Rb("Last eligible collected items dropped") then
            bh()
            iM()
            if W > 0 and not Hh() then
              Vb("All worlds scanned. Drop targets not met: " .. Th())
            else
              Vb("All " .. (tostring(#Z) .. " collection worlds finished. Eligible items stored."))
            end
          elseif J then
            Sleep(500)
          end
        else
          bh()
          iM()
          if W > 0 and not Hh() then
            Vb("All worlds scanned. Drop targets not met: " .. Th())
          else
            Vb("All collection worlds finished. No more eligible items.")
          end
        end
      else
        y = Z[a]
        if not Zh(y) then
          SM("WAIT COLLECT WORLD " .. tostring(y))
          Sleep(1300)
        elseif not yh(y) then
          SM("WAIT COLLECT PLAYER READY")
          Sleep(300)
        else
          SM("SCAN " .. tostring(y))
          local l = lb()
          if #l == 0 then
            local l, O = nil, false
            if W == 0 then
              l, O = Ob()
            end
            if O then
              h = 0
              gM = gM + 1
              if gM >= 2 then
                yM = l
                GM = true
                gM = 0
                SM("UNLIMITED / FULL STACK: STORE & RESUME")
              else
                SM("VERIFY FULL STACK BACKLOG")
              end
              Sleep(400)
            else
              gM = 0
              h = h + 1
              if h < 3 then
                SM("CONFIRM EMPTY " .. (tostring(h) .. ("/3 " .. tostring(y))))
                Sleep(400)
              else
                local l = ACD_EXACT_skipCountByWorld[y] or 0
                SM((l > 0 and ("WORLD DONE - SKIPPED " .. (tostring(l) .. " ")) or "WORLD COMPLETE ") .. tostring(y))
                h = 0
                a = a + 1
                aM = 0
                qM = {}
                if a <= #Z then
                  y = Z[a]
                end
                iM()
                Sleep(250)
              end
            end
          else
            h = 0
            gM = 0
            if N["fastcollect"] == "true" then
              kb(l)
            else
              Fb(l)
            end
            wh(false)
            SM("RESCAN " .. tostring(y))
            Sleep(QM)
          end
        end
      end
      Sleep(120)
    end
  end
end)
