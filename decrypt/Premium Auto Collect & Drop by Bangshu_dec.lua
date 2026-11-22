setMinimum("6.1.2")
local B = "Premium Auto Collect by Bangshu"
do
  local d =
    "https://script.google.com/macros/s/AKfycbxWY0ROC3V1HOTJuRPfovwsN8CfTkXrcFF6VvhlS0EQRfWleUWVHZNUSW1M2UcVesSC/exec"
  local E = "AUTOCOLLECT"
  local N = "AUTOCOLLECT-6.1-PAID-001"
  local V = "approval"
  local R = "%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x"
  local function I()
    local B, d = pcall(function()
      if type(getDiscordID) == "function" then
        return getDiscordID()
      end
      return getDiscordID
    end)
    if not B then
      return nil
    end
    if type(d) == "number" and (math["type"] and math["type"](d) == "integer") then
      d = tostring(d)
    end
    if type(d) ~= "string" or #d < 17 or #d > 20 or not d:match("^%d+$") then
      return nil
    end
    if d:match("^0+$") then
      return nil
    end
    return d
  end
  local function c(B, d)
    if not d or type(B) ~= "string" or #B > 512 then
      return false
    end
    local V, I, c = B:match(
      '^%s*{"status":"APPROVED","approval":{"discordId":"(%d+)","product":"([A-Z]+)","version":"([%w._-]+)","receiptId":"'
        .. (R .. '"}}%s*$')
    )
    return V == d and (I == E and c == N)
  end
  local L, m, H = pcall(function()
    local B, d = pcall(require, "preferences")
    local E = B and (type(d) == "table" and d) or Preferences
    if type(E) ~= "table" or type(E["new"]) ~= "function" then
      return nil
    end
    local N = E:new("BangshuPremiumAutoCollect")
    if N:load() == false then
      return N
    end
    return N, N:get(V, "")
  end)
  if not L then
    m = nil
  end
  if not c(H, I()) then
    local R, L = false, false
    local function H(B)
      pcall(editValue, "ACD_premium_status", B)
      if type(sendNotification) == "function" then
        pcall(sendNotification, B)
      elseif growtopia and type(growtopia["notify"]) == "function" then
        pcall(growtopia["notify"], B)
      end
    end
    local function q()
      if R or L then
        return
      end
      local B = I()
      if not B then
        H("DENIED - DISCORD ID UNAVAILABLE")
        return
      end
      if not m then
        H("DENIED - PREFERENCES UNAVAILABLE")
        return
      end
      R = true
      H("CHECKING")
      local q = pcall(runThread, function()
        local I = d
          .. (
            "?action=verifyPaidAccess&discordId=" .. (
              B .. ("&product=" .. (E .. ("&format=growlauncher&version=" .. N)))
            )
          )
        local q, z = pcall(fetch, I)
        if q and type(z) == "string" then
          local B = z:match("BANGSHU_PREMIUM_V1_BEGIN_([0-9a-f]+)_BANGSHU_PREMIUM_V1_END")
          if B and (#B <= 1024 and #B % 2 == 0) then
            z = B:gsub("..", function(B)
              return string["char"](tonumber(B, 16))
            end)
          end
        end
        if not q or type(z) ~= "string" then
          H("DENIED - REQUEST FAILED")
        elseif not c(z, B) then
          if z:match('^%s*{"status":"DENIED",') then
            H("DENIED - NO PREMIUM ACCESS")
          elseif z:match('^%s*{"status":"ERROR",') then
            H("DENIED - APPS SCRIPT SERVER ERROR")
          elseif z:match("^%s*<") then
            if z:find("doGet", 1, true) then
              H("DENIED - DEPLOYED APP MISSING GET HANDLER")
            else
              H("DENIED - GOOGLE RETURNED HTML")
            end
          elseif z:match("^%s*$") then
            H("DENIED - EMPTY SERVER RESPONSE")
          elseif z:match('^%s*{"status":"APPROVED",') then
            H("DENIED - APPROVAL DETAILS DO NOT MATCH")
          else
            H("DENIED - UNEXPECTED SERVER RESPONSE")
          end
        else
          local d, E = pcall(function()
            if m:set(V, z) == false then
              return false
            end
            if m:save() == false then
              return false
            end
            if m:load() == false then
              return false
            end
            return c(m:get(V, ""), B)
          end)
          L = d and E == true
          H(L and "APPROVED - RELOAD SCRIPT" or "DENIED - COULD NOT SAVE APPROVAL")
        end
        R = false
      end)
      if not q then
        R = false
        H("DENIED - COULD NOT START CHECK")
      end
    end
    function OnValue(B, d)
      if d == "ACD_premium_verify" then
        q()
      end
    end
    onValue = OnValue
    local z = UserInterface["new"](B, "Inventory")
    z:addButton("Verify Access", "ACD_premium_verify")
    z:addInputString("Verification Status", "NOT VERIFIED", "", "", nil, "ACD_premium_status")
    if type(addCategory) == "function" then
      pcall(addCategory, B, "Inventory")
    end
    addIntoModule(z:generateJSON(), B)
    if type(applyHook) == "function" then
      pcall(applyHook)
    end
    if type(setOnValue) == "function" then
      pcall(setOnValue, "ACD_premium_verify", q)
    end
    return
  end
end
local d = "AutoCollectToDropAllSettingsV19.json"
ACD19_LEGACY_MW_PREF_NAME = "AutoCollectToDropMultiWorldV11"
ACD19_MW_SCHEMA = "19"
ACD19_MW_KEYS =
  { "worlds", "dropworld", "dropx", "dropy", "pickupdelay", "acktimeout", "batchmax", "items", "droptotal" }
local E = nil
ACD19_mwPreferenceModule = nil
local N = {}
ACD19_mwSettingsRestored = false
ACD19_mwSaveState = "UNAVAILABLE"
ACD19_guardedUIWrites = {}
function ACD19_safeEditValue(B, d)
  if ACD19_guardedUIWrites[B] then
    return
  end
  ACD19_guardedUIWrites[B] = true
  pcall(function()
    editValue(B, d)
  end)
  ACD19_guardedUIWrites[B] = nil
end
function ACD19_safeSetStartToggle(B)
  if ACD19_guardedUIWrites["ACD_enable"] then
    return
  end
  ACD19_guardedUIWrites["ACD_enable"] = true
  local d = editToggle or EditToggle
  if d ~= nil then
    pcall(d, "ACD_enable", B == true)
  end
  ACD19_guardedUIWrites["ACD_enable"] = nil
end
function ACD19_setAutoSaveStatus(B)
  if ACD19_mwSaveState == B then
    return
  end
  ACD19_mwSaveState = B
  ACD19_safeEditValue("ACD_autosave", B)
end
local function V(B)
  return ((tostring(B or "")):upper()):gsub("%s+", "")
end
local function R(B)
  local d, E = {}, {}
  local N = (tostring(B or "")):gsub("[;\r\n]", ",")
  for B in ((N .. ",")):gmatch("([^,]*),") do
    local N = V(B)
    if N ~= "" and (N ~= "EXIT" and not E[N]) then
      E[N] = true
      d[#d + 1] = N
      if #d >= 30 then
        break
      end
    end
  end
  return d
end
local function I(B)
  return table["concat"](B or {}, ", ")
end
local function c(B)
  local d, E = {}, {}
  local N = (tostring(B or "")):gsub("[;\r\n]", ",")
  for B in ((N .. ",")):gmatch("([^,]*),") do
    local N = tonumber(B:match("^%s*(%d+)%s*$"))
    if N ~= nil and (N > 0 and (N <= 65535 and not E[N])) then
      N = math["floor"](N)
      E[N] = true
      d[#d + 1] = N
      if #d >= 30 then
        break
      end
    end
  end
  return d
end
local function L(B)
  local d = {}
  for B, E in ipairs(B or {}) do
    d[#d + 1] = tostring(E)
  end
  return table["concat"](d, ", ")
end
function ACD19_mwNewPreferences(B)
  if ACD19_mwPreferenceModule == nil or type(ACD19_mwPreferenceModule["new"]) ~= "function" then
    return nil
  end
  local d, E = pcall(function()
    return ACD19_mwPreferenceModule:new(B)
  end)
  if not d then
    return nil
  end
  if
    E == nil
    or type(E["get"]) ~= "function"
    or type(E["set"]) ~= "function"
    or type(E["save"]) ~= "function"
    or type(E["load"]) ~= "function"
  then
    return nil
  end
  return E
end
local function m()
  if type(require) == "function" then
    local B, d = pcall(require, "preferences")
    if B and type(d) == "table" then
      ACD19_mwPreferenceModule = d
    end
  end
  if ACD19_mwPreferenceModule == nil and type(Preferences) == "table" then
    ACD19_mwPreferenceModule = Preferences
  end
  local B = ACD19_mwNewPreferences(ACD19_LEGACY_MW_PREF_NAME)
  if B ~= nil then
    pcall(function()
      B:load()
      for d, E in ipairs(ACD19_MW_KEYS) do
        N[E] = B:get(E, "")
      end
    end)
  end
  local V = ACD19_mwNewPreferences(d)
  if V == nil then
    return
  end
  local R = pcall(function()
    V:load()
  end)
  if not R then
    return
  end
  E = V
  local I, c = pcall(function()
    return V:get("schema", "")
  end)
  if I and tostring(c) == ACD19_MW_SCHEMA then
    local B = pcall(function()
      for B, d in ipairs(ACD19_MW_KEYS) do
        N[d] = V:get(d, N[d] or "")
      end
    end)
    if B then
      ACD19_mwSettingsRestored = true
    end
  end
end
local function H(B, V)
  N[B] = tostring(V)
  if E == nil then
    ACD19_setAutoSaveStatus("SAVE UNAVAILABLE")
    return false
  end
  local R = pcall(function()
    if E:set("schema", ACD19_MW_SCHEMA) == false then
      error("schema write failed")
    end
    for B, d in ipairs(ACD19_MW_KEYS) do
      if E:set(d, tostring(N[d] or "")) == false then
        error("settings write failed: " .. d)
      end
    end
    if E:save() == false then
      error("settings save failed")
    end
  end)
  if R then
    local B, E = pcall(function()
      local B = ACD19_mwNewPreferences(d)
      if B == nil then
        return false
      end
      if B:load() == false then
        return false
      end
      if tostring(B:get("schema", "")) ~= ACD19_MW_SCHEMA then
        return false
      end
      for d, E in ipairs(ACD19_MW_KEYS) do
        if tostring(B:get(E, "")) ~= tostring(N[E] or "") then
          return false
        end
      end
      return true
    end)
    R = B and E == true
  end
  ACD19_setAutoSaveStatus(R and "SAVED - REOPEN SAFE" or "SAVE FAILED")
  return R
end
local function q(B, d, E, V)
  local R = math["floor"](tonumber(N[B]) or d)
  return math["min"](V, math["max"](E, R))
end
m()
local z = I(R(N["worlds"]))
local A = L(c(N["items"]))
local O = V(N["dropworld"])
local f = q("dropx", 0, -1, 999)
local J = q("dropy", 0, -1, 999)
local i = q("pickupdelay", 0, 0, 1000)
local n = q("acktimeout", 900, 300, 10000)
local Y = q("batchmax", 2, 1, 2)
local W = q("droptotal", 0, 0, 1000000000)
local S = UserInterface["new"](B, "Inventory")
S:addLabelApp("Auto Collect V6.1 Exact Tile Mixed Pickup", "Inventory")
S:addToggle("Start / Stop", false, "ACD_enable")
S:addItemPicker("Add Collect Item", "Dirt", "2", "ACD_itempicker")
S:addInputString("Selected Items (view only)", "NONE", "Selected item IDs", "List", nil, "ACD_selecteditem")
S:addButton("Remove Last Collect Item", "ACD_removeitem")
S:addButton("Clear Collect Items", "ACD_clearitems")
S:addInputString("Total Drop Per Item (0 = until worlds empty)", tostring(W), "Items", "210", nil, "ACD_droptotal")
S:addInputString("Drop Progress Per Item (view only)", "NONE", "Dropped / goal", "Status", nil, "ACD_dropprogress")
local u = S:addDialog("Settings", "Item IDs, collection worlds, shared storage, delays", {})
S:addChildTooltip(
  u["menu"],
  "Selected Items",
  "Use Add Collect Item on the main screen, or enter comma-separated item IDs here. Items are saved; changes take effect on next Start.",
  "Inventory",
  true
)
S:addChildInputString(
  u["menu"],
  "Collect Item IDs (comma-separated)",
  A,
  "e.g. 2, 3, 4",
  "2, 3, 4",
  "Inventory",
  "ACD_itemlist"
)
S:addChildTooltip(
  u["menu"],
  "Collection Worlds",
  "List worlds in order, separated by commas. Add Current World / Remove Last World edit the list. Changes made while running apply on the next Start.",
  "Inventory",
  true
)
S:addChildInputString(
  u["menu"],
  "Collection Worlds (comma-separated)",
  z,
  "World 1, World 2, ...",
  "FARM1, FARM2",
  "Inventory",
  "ACD_worldlist"
)
S:addChildButton(u["menu"], "Add Current World", "ACD_addworld")
S:addChildButton(u["menu"], "Remove Last World", "ACD_removeworld")
S:addChildInputString(u["menu"], "Shared Storage World", O, "World", "STORAGE", "Inventory", "ACD_dropworld")
S:addChildButton(u["menu"], "Storage World = Current World", "ACD_setdropworld")
S:addChildInputInt(u["menu"], "Drop Position X (Standing Tile)", tostring(f), "X", "0", "Inventory", "ACD_dropx")
S:addChildInputInt(u["menu"], "Drop Position Y (Standing Tile)", tostring(J), "Y", "0", "Inventory", "ACD_dropy")
S:addChildButton(u["menu"], "Drop Position = Current Tile", "ACD_setdrop")
S:addChildTooltip(
  u["menu"],
  "Storage behavior",
  "0 means unlimited: collect selected items until each world is empty (3 checks). If a full backpack stack blocks more items of its type, store only that type and resume the SAME world. Otherwise batch full types together. Final partial stacks are stored when all worlds finish.",
  "Inventory",
  false
)
S:addChildTooltip(
  u["menu"],
  "Run Mode: Single Pass",
  "Visit each collection world once in order. After the final world is empty, store remaining selected items and stop automatically. Press Start again for a new round.",
  "Inventory",
  true
)
S:addChildInputInt(u["menu"], "After Pickup Delay", tostring(i), "ms", "0", "Inventory", "ACD_pickupdelay")
S:addChildInputInt(u["menu"], "Batch ACK Timeout", tostring(n), "ms", "900", "Inventory", "ACD_acktimeout")
S:addChildInputInt(u["menu"], "Max Pickup Batch (max 2)", tostring(Y), "items", "2", "Inventory", "ACD_batchmax")
S:addChildTooltip(
  u["menu"],
  "Persistent Auto Save",
  "Changes save immediately when an input is committed or a selection button is pressed. No Start is needed. Check Settings Auto Save on the main menu. Start always reopens OFF.",
  "Inventory",
  false
)
S:addDisplayList("Items Configured", tostring(#c(A)), "ACD_itemcount")
S:addDisplayList("Worlds Configured", tostring(#R(z)), "ACD_worldcount")
S:addDisplayList("Current Collection World", "NOT STARTED", "ACD_worldprogress")
S:addDisplayList("Shared Storage World", O ~= "" and O or "NOT SET", "ACD_storageprogress")
S:addDisplayList("Server Pace", "CAUTIOUS (2)", "ACD_serverpace")
S:addDisplayList("Shared Storage Trips", "0", "ACD_loops")
S:addDisplayList("Status", "STOPPED", "ACD_status")
S:addDisplayList("Selected Inventory", "NONE", "ACD_inventory")
S:addDisplayList("Dropped Objects Found", "0", "ACD_objects")
S:addDisplayList("Skipped Blocked / Unreachable", "0", "ACD_exactskipped")
S:addDisplayList(
  "Settings Auto Save",
  E == nil and "UNAVAILABLE" or (ACD19_mwSettingsRestored and "RESTORED" or "READY - SAVES ON EDIT"),
  "ACD_autosave"
)
pcall(function()
  addCategory(B, "Inventory")
end)
local Z = pcall(function()
  addIntoModule(S:generateJSON(), B)
end)
if not Z then
  addIntoModule(S:generateJSON())
end
local v = false
local X = false
local p = 0
local l = c(A)
local b, K = {}, {}
local F = 200
local t = W
local g = W
local j = {}
local G = false
local a = {}
local T = i
local U = n
local o = Y
local M = math["min"](2, Y)
local r = 0
local Q = 0
local P = ""
local D = R(z)
local y = {}
local s = 1
local h = false
local w = 0
local C = 0
local x = O
local k = f
local e = J
local Bs = 0
local ds = 0
local Es = "STOPPED"
local Ns = true
local Vs = 0
local Rs = 1
ACD_EXACT_skippedByWorld = {}
ACD_EXACT_skipCountByWorld = {}
ACD_EXACT_totalSkipped = 0
local Is = 15000
local cs = 9000
local Ls = 1300
local ms = 450
local Hs = 1100
local qs = 100
local zs = 700
local As = 6
local Os = 2200
local fs = 350
local Js = 6000
local is = 25
local ns = 1000
local Ys = 60
local Ws = 80
local Ss = 25
local us = 1
local Zs = 180
local vs = 450
local Xs = 90
local ps = 1800
local ls = 2000
local bs = 2200
local Ks = 2
local Fs = 350
local ts = 100
local gs = 250
local js = 1200
local Gs = 4
local as = 2600
local Ts = 300
local Us = 350
ACD19_DROP_SECOND_PATH_STABLE_MS = 500
ACD19_DROP_PRE_PACKET_STABLE_MS = 200
ACD19_DROP_STABLE_POLL_MS = 100
local os = false
local Ms = false
local rs = false
local Qs = false
local Ps = nil
local Ds = 0
local ys = false
ACD19_storageEntryConfirmed = false
ACD19_storageEntryConfirmedX = nil
ACD19_storageEntryConfirmedY = nil
local ss = 0
local hs = {}
local ws = 2
local function Cs(B)
  pcall(function()
    growtopia["notify"](tostring(B))
  end)
end
local function xs(B)
  B = tostring(B)
  if Es ~= B then
    Es = B
    ACD19_safeEditValue("ACD_status", B)
  end
end
local function ks()
  local B = #y
  if v and (B > 0 and s <= B) then
    pcall(function()
      ACD19_safeEditValue("ACD_worldprogress", tostring(s) .. ("/" .. (tostring(B) .. (" - " .. tostring(P)))))
    end)
  elseif B > 0 and s > B then
    pcall(function()
      ACD19_safeEditValue("ACD_worldprogress", "ALL WORLDS SCANNED")
    end)
  else
    pcall(function()
      ACD19_safeEditValue("ACD_worldprogress", "NOT STARTED")
    end)
  end
  pcall(function()
    ACD19_safeEditValue("ACD_worldcount", tostring(#D))
  end)
  pcall(function()
    ACD19_safeEditValue("ACD_storageprogress", x ~= "" and x or "NOT SET")
  end)
end
local function es()
  local B = I(D)
  pcall(function()
    ACD19_safeEditValue("ACD_worldlist", B)
  end)
  pcall(function()
    ACD19_safeEditValue("ACD_worldcount", tostring(#D))
  end)
  H("worlds", B)
end
local function B0(B, d)
  local E = editToggle or EditToggle
  if E ~= nil then
    pcall(E, B, d == true)
  end
end
local d0 = nil
local E0 = nil
local function N0(B)
  B = B == true
  if B == d0 then
    return
  end
  d0 = B
  B0("ModFly", B)
end
local function V0(B)
  B = B == true
  if B == E0 then
    return
  end
  E0 = B
  B0("Enable AutoCollect", B)
  B0("Autocollect", B)
end
local function R0(B)
  B = tostring(B or "")
  B = B:gsub("%s+", "")
  return B:upper()
end
ACD61_activeDoorRoute = ""
function ACD61_physicalWorld()
  local B, d = pcall(function()
    if type(GetWorldName) == "function" then
      return GetWorldName()
    elseif type(getCurrentWorldName) == "function" then
      return getCurrentWorldName()
    end
    return ""
  end)
  if not B then
    return ""
  end
  return R0(d)
end
local function I0()
  local B = ACD61_physicalWorld()
  if ACD61_activeDoorRoute ~= "" and B ~= "" then
    local d = ACD61_activeDoorRoute:match("^([^|]+)|")
    if d == B then
      return ACD61_activeDoorRoute
    end
  end
  return B
end
function ACD61_parseWorldRoute(B)
  B = R0(B)
  if B == "" then
    return "", nil
  end
  local d, E = B:match("^([^|]+)|([^|]+)$")
  if d then
    return d, E
  end
  if B:find("|", 1, true) then
    return "", nil
  end
  return B, nil
end
local function c0(B, d)
  B = R0(B)
  d = R0(d)
  return B ~= "" and (d ~= "" and B == d)
end
local function L0()
  return c0(P, x) and c0(I0(), x)
end
local function m0()
  return c0(I0(), x) and (L0() or rs)
end
local function H0(B, d)
  B = tonumber(B)
  d = tonumber(d)
  if B == nil or d == nil then
    return false
  end
  local E = math["min"](k, Bs) - Rs
  local N = math["max"](k, Bs) + Rs
  return B >= E and (B <= N and math["abs"](d - e) <= Rs)
end
local function q0()
  local B = GetLocal or getLocal
  if B == nil then
    return nil
  end
  local d, E = pcall(B)
  if d then
    return E
  end
  return nil
end
local function z0()
  local B = GetTiles or getTiles
  if B == nil then
    return nil
  end
  local d, E = pcall(B)
  if d and type(E) == "table" then
    return E
  end
  return nil
end
local function A0()
  local B = GetObjectList or getObjectList
  if B == nil then
    return {}
  end
  local d, E = pcall(B)
  if d and type(E) == "table" then
    return E
  end
  return {}
end
local function O0(B)
  local d, E = pcall(function()
    if growtopia ~= nil and type(growtopia["checkInventoryCount"]) == "function" then
      return growtopia["checkInventoryCount"](B)
    end
    local d = GetInventory or getInventory
    if d == nil then
      return 0
    end
    local E = d()
    for d, E in pairs(E or {}) do
      if tonumber(E["id"]) == tonumber(B) then
        return tonumber(E["amount"]) or 0
      end
    end
    return 0
  end)
  if not d then
    return 0
  end
  return tonumber(E) or 0
end
local function f0(B)
  local d, E = pcall(function()
    if growtopia ~= nil and type(growtopia["getItemName"]) == "function" then
      return growtopia["getItemName"](B)
    end
    if type(getItemInfoByID) == "function" then
      local d = getItemInfoByID(B)
      if d ~= nil then
        return d["name"]
      end
    end
    return nil
  end)
  if d and (E ~= nil and tostring(E) ~= "") then
    return tostring(E)
  end
  return "Item " .. tostring(B)
end
local function J0()
  if #b > 0 and v then
    return b
  end
  return l
end
local function i0()
  local B = 0
  for d, E in ipairs(J0()) do
    B = B + O0(E)
  end
  return B
end
local function n0(B)
  if g <= 0 then
    return nil
  end
  return math["max"](0, g - (j[B] or 0))
end
local function Y0()
  if g <= 0 or #b == 0 then
    return false
  end
  for B, d in ipairs(b) do
    if (j[d] or 0) < g then
      return false
    end
  end
  return true
end
local function W0(B)
  local d = O0(B)
  if d >= F then
    return false
  end
  local E = n0(B)
  return E == nil or d < E
end
local function S0()
  for B, d in ipairs(J0()) do
    if O0(d) >= F then
      return d
    end
  end
  return nil
end
local function u0(B)
  local d = math["max"](0, O0(B))
  local E = n0(B)
  if E == nil then
    return d
  end
  return math["min"](d, E)
end
local function Z0()
  local B = 0
  for d, E in ipairs(b) do
    B = B + u0(E)
  end
  return B
end
local function v0()
  if #b == 0 then
    return false
  end
  for B, d in ipairs(b) do
    if W0(d) then
      return false
    end
  end
  return Z0() > 0
end
local function X0()
  if g <= 0 then
    return "UNLIMITED"
  end
  local B = {}
  for d, E in ipairs(b) do
    local N = n0(E)
    if N and N > 0 then
      B[#B + 1] = tostring(E) .. (":" .. tostring(N))
    end
  end
  return #B == 0 and "ALL COMPLETE" or table["concat"](B, ", ")
end
local function p0()
  local B = (#b > 0 and v) and b or l
  local d = {}
  for B, E in ipairs(B) do
    d[#d + 1] = tostring(E) .. (": " .. (tostring(j[E] or 0) .. (" / " .. (g > 0 and tostring(g) or "unlimited"))))
  end
  pcall(function()
    ACD19_safeEditValue("ACD_dropprogress", #d > 0 and table["concat"](d, " | ") or "NONE")
  end)
end
local function l0()
  if G then
    return
  end
  G = true
  a = {}
  for B, d in ipairs(b) do
    a[d] = O0(d)
  end
end
local function b0()
  if not G then
    return
  end
  local B = false
  for d, E in ipairs(b) do
    local N = O0(E)
    local V = a[E]
    if V ~= nil and N < V then
      j[E] = (j[E] or 0) + (V - N)
      B = true
    end
    a[E] = N
  end
  if B then
    p0()
  end
end
local function K0()
  b0()
  G = false
  a = {}
  ACD19_storageEntryConfirmed = false
  ACD19_storageEntryConfirmedX, ACD19_storageEntryConfirmedY = nil, nil
end
local function F0()
  if #l == 0 then
    return "NONE"
  end
  local B = {}
  for d, E in ipairs(l) do
    B[#B + 1] = f0(E) .. (" (" .. (tostring(E) .. ")"))
  end
  return table["concat"](B, ", ")
end
local function t0()
  pcall(function()
    ACD19_safeEditValue("ACD_selecteditem", F0())
  end)
  pcall(function()
    ACD19_safeEditValue("ACD_itemcount", tostring(#l))
  end)
end
local function g0()
  local B = L(l)
  pcall(function()
    ACD19_safeEditValue("ACD_itemlist", B)
  end)
  H("items", B)
  t0()
  p0()
end
local j0 = nil
local function G0()
  local B = J0()
  local d = "NONE"
  if #B > 0 then
    local E = {}
    for B, d in ipairs(B) do
      E[#E + 1] = tostring(d) .. (":" .. tostring(O0(d)))
    end
    d = table["concat"](E, "  |  ")
  end
  if d ~= j0 then
    j0 = d
    pcall(function()
      ACD19_safeEditValue("ACD_inventory", d)
    end)
  end
end
local function a0()
  ACD19_safeEditValue("ACD_loops", tostring(Vs))
end
local function T0()
  local B = q0()
  if B == nil then
    return nil, nil
  end
  return B["posX"] // 32, B["posY"] // 32
end
local function U0(B, d)
  local E, N = T0()
  return E == B and N == d
end
local o0 = ""
local M0 = ""
local r0 = ""
local function Q0(B)
  local d = ACD61_physicalWorld()
  local E = R0(B)
  local N, V = ACD61_parseWorldRoute(E)
  if N == "" then
    return false
  end
  if d ~= M0 then
    M0 = d
    o0 = ""
    r0 = ""
    ACD61_activeDoorRoute = ""
  end
  local R = q0()
  if d ~= N or R == nil then
    return false
  end
  if V and ACD61_activeDoorRoute ~= E then
    return false
  end
  if not V and ACD61_activeDoorRoute ~= "" then
    return false
  end
  if tonumber(R["posX"]) == nil or tonumber(R["posY"]) == nil then
    return false
  end
  if o0 == N then
    return true
  end
  local I = z0()
  if I ~= nil and next(I) ~= nil then
    o0 = N
    return true
  end
  return false
end
local function P0(B)
  local d = R0(B)
  return r0 == d and Q0(d)
end
local function D0(B, d, E)
  local N = R0(B)
  if P0(N) then
    return true
  end
  local V = 0
  local R = 0
  local I, c = nil, nil
  xs("WAIT PLAYER READY " .. tostring(N))
  while v and V < d do
    if Q0(N) then
      local B = q0()
      local d = B and tonumber(B["posX"])
      local L = B and tonumber(B["posY"])
      if d ~= nil and L ~= nil then
        if I == d and c == L then
          R = R + qs
        else
          R = 0
          I, c = d, L
        end
        if R >= zs and V >= (E or 0) then
          r0 = N
          return v and P0(N)
        end
      end
    else
      R = 0
      I, c = nil, nil
    end
    Sleep(qs)
    V = V + qs
  end
  return false
end
local function y0(B, d)
  B = R0(B)
  if B == "" then
    return false
  end
  d = d or Is
  if B ~= x then
    ACD19_storageEntryConfirmed = false
    ACD19_storageEntryConfirmedX = nil
    ACD19_storageEntryConfirmedY = nil
  end
  local E, N = ACD61_parseWorldRoute(B)
  if E == "" then
    xs("INVALID WORLD OR DOOR ID")
    return false
  end
  if N then
    if P0(B) then
      N0(true)
      return true
    end
    if ACD61_physicalWorld() ~= E or ACD61_activeDoorRoute ~= "" then
      ACD61_activeDoorRoute = ""
      o0 = ""
      r0 = ""
      d0 = nil
      xs("WARP BASE " .. E)
      local B, d = pcall(function()
        return growtopia["warpTo"](E)
      end)
      if not B or d == false then
        return false
      end
    end
    if not D0(E, d, Hs) then
      return false
    end
    if not v or ACD61_physicalWorld() ~= E then
      return false
    end
    xs("ENTER DOOR " .. B)
    o0 = ""
    r0 = ""
    local N, V = pcall(function()
      return SendPacket(3, "action|join_request\nname|" .. (B .. "\ninvitedWorld|0"))
    end)
    if not N or V == false then
      return false
    end
    Sleep(1400)
    if not v or ACD61_physicalWorld() ~= E then
      return false
    end
    if not D0(E, d, Hs) then
      return false
    end
    ACD61_activeDoorRoute = B
    o0 = ""
    r0 = ""
    local R = D0(B, d, Hs)
    if R then
      N0(true)
    end
    return R
  end
  if ACD61_activeDoorRoute ~= "" then
    ACD61_activeDoorRoute = ""
    o0 = ""
    r0 = ""
    d0 = nil
    xs("RETURN BASE " .. B)
    local E, N = pcall(function()
      return growtopia["warpTo"](B)
    end)
    if not E or N == false then
      return false
    end
    local V = D0(B, d, Hs)
    if V then
      N0(true)
    end
    return V
  end
  if P0(B) then
    N0(true)
    return true
  end
  if Q0(B) then
    local E = D0(B, d, Hs)
    if E then
      N0(true)
    end
    return E
  end
  xs("WARP " .. B)
  o0 = ""
  r0 = ""
  d0 = nil
  local V = pcall(function()
    growtopia["warpTo"](B)
  end)
  if not V then
    return false
  end
  local R = D0(B, d, Hs)
  if R then
    N0(true)
  end
  return R
end
local function s0(B, d)
  if U0(B, d) then
    return true
  end
  N0(true)
  for E = 1, As, 1 do
    if not v then
      return false
    end
    xs("PATH " .. (tostring(E) .. ("/" .. (tostring(As) .. (" -> " .. (tostring(B) .. ("," .. tostring(d))))))))
    pcall(function()
      FindPath(B, d)
    end)
    local N = 0
    while v and N < Os do
      if U0(B, d) then
        Sleep(120)
        return true
      end
      Sleep(100)
      N = N + 100
    end
    Sleep(fs)
  end
  return U0(B, d)
end
local function h0(B, d)
  if not v or not P0(x) then
    return false
  end
  B = math["floor"](tonumber(B) or Bs or k)
  d = math["floor"](tonumber(d) or ds or e)
  if U0(B, d) then
    return true
  end
  N0(true)
  for E = 1, Gs, 1 do
    if not v or not P0(x) then
      return false
    end
    xs("DROP PATH " .. (tostring(E) .. ("/" .. (tostring(Gs) .. (" -> " .. (tostring(B) .. ("," .. tostring(d))))))))
    pcall(function()
      FindPath(B, d)
    end)
    local N = 0
    while v and (P0(x) and N < as) do
      if U0(B, d) then
        Sleep(Ts)
        return v and U0(B, d)
      end
      Sleep(100)
      N = N + 100
    end
    if E < Gs then
      Sleep(Us)
    end
  end
  return U0(B, d)
end
function ACD19_stableAtStorageTile(B, d, E, N)
  local V, R = 0, 0
  while v and R <= N do
    if not P0(x) then
      return false
    end
    if U0(B, d) then
      if V >= E then
        return true
      end
      V = V + ACD19_DROP_STABLE_POLL_MS
    else
      V = 0
    end
    if R >= N then
      break
    end
    Sleep(ACD19_DROP_STABLE_POLL_MS)
    R = R + ACD19_DROP_STABLE_POLL_MS
  end
  return v and (P0(x) and (U0(B, d) and V >= E))
end
function ACD19_confirmStorageDropPosition()
  if not v or not P0(x) then
    ACD19_storageEntryConfirmed = false
    return false
  end
  local B, d = Bs, ds
  if
    ACD19_storageEntryConfirmed and (
      ACD19_storageEntryConfirmedX == B and (ACD19_storageEntryConfirmedY == d and U0(B, d))
    )
  then
    return true
  end
  ACD19_storageEntryConfirmed = false
  xs("STORAGE PATH 1/2 -> " .. (tostring(B) .. ("," .. tostring(d))))
  if not h0(B, d) then
    return false
  end
  if not ACD19_stableAtStorageTile(B, d, Ts, 900) then
    xs("WAIT FIRST STORAGE ARRIVAL")
    return false
  end
  xs("STORAGE PATH 2/2 -> " .. (tostring(B) .. ("," .. tostring(d))))
  local E = pcall(function()
    FindPath(B, d)
  end)
  if not E then
    xs("WAIT SECOND STORAGE PATH")
    return false
  end
  if not ACD19_stableAtStorageTile(B, d, ACD19_DROP_SECOND_PATH_STABLE_MS, 1400) then
    xs("WAIT VERIFIED STORAGE POSITION")
    return false
  end
  ACD19_storageEntryConfirmed = true
  ACD19_storageEntryConfirmedX, ACD19_storageEntryConfirmedY = B, d
  xs("STORAGE POSITION CONFIRMED " .. (tostring(B) .. ("," .. tostring(d))))
  return true
end
local function w0(B, d)
  local E = GetTile or getTile
  if E == nil then
    return nil
  end
  local N, V = pcall(E, B, d)
  if N then
    return V
  end
  return nil
end
local function C0(B, d)
  local E = w0(B, d)
  return E ~= nil and E["collidable"] ~= true
end
function ACD_EXACT_isSkipped(B)
  local d = tostring(B or "")
  local E = ACD_EXACT_skippedByWorld[P]
  return E ~= nil and E[d] ~= nil
end
function ACD_EXACT_markSkipped(B, d)
  local E = tostring(B or "")
  if E == "" or E == "nil" or P == "" then
    return
  end
  if ACD_EXACT_skippedByWorld[P] == nil then
    ACD_EXACT_skippedByWorld[P] = {}
  end
  local N = ACD_EXACT_skippedByWorld[P]
  if N[E] ~= nil then
    return
  end
  N[E] = tostring(d or "NO PATH")
  ACD_EXACT_skipCountByWorld[P] = (ACD_EXACT_skipCountByWorld[P] or 0) + 1
  ACD_EXACT_totalSkipped = ACD_EXACT_totalSkipped + 1
  ACD19_safeEditValue("ACD_exactskipped", tostring(ACD_EXACT_totalSkipped))
  xs("SKIP " .. (tostring(d or "NO PATH") .. (" @ " .. tostring(P))))
end
local function x0(B)
  if B == nil then
    return nil, nil
  end
  local d = tonumber(B["posX"])
  local E = tonumber(B["posY"])
  if (d == nil or E == nil) and B["pos"] ~= nil then
    d = d or tonumber(B["pos"]["x"])
    E = E or tonumber(B["pos"]["y"])
  end
  return d, E
end
local function k0(B)
  B = tonumber(B)
  if B == nil then
    return false
  end
  for d, E in pairs(A0()) do
    if tonumber(E["id"]) == B then
      return true
    end
  end
  return false
end
local function e0()
  local B, d = T0()
  local E = {}
  local N = A0()
  for N, V in pairs(N) do
    if K[tonumber(V["itemid"])] == true and W0(tonumber(V["itemid"])) then
      local N, R = x0(V)
      if N ~= nil and R ~= nil then
        local I = math["floor"](N / 32)
        local c = math["floor"](R / 32)
        local L = 0
        if B ~= nil and d ~= nil then
          L = math["abs"](B - I) + math["abs"](d - c)
        end
        local m = L0() and H0(I, c)
        if not m and not ACD_EXACT_isSkipped(V["id"]) then
          table["insert"](
            E,
            {
              ["object"] = V,
              ["uid"] = tonumber(V["id"]),
              ["itemID"] = tonumber(V["itemid"]),
              ["amount"] = tonumber(V["amount"]) or 0,
              ["pixelX"] = N,
              ["pixelY"] = R,
              ["tileX"] = I,
              ["tileY"] = c,
              ["distance"] = L,
            }
          )
        end
      end
    end
  end
  if #E > 1 then
    local d = {}
    local N = {}
    for B, E in ipairs(E) do
      local V = E["tileY"]
      if d[V] == nil then
        d[V] = {}
        table["insert"](N, V)
      end
      table["insert"](d[V], E)
    end
    table["sort"](N, function(B, d)
      return B < d
    end)
    local V = true
    if B ~= nil and #N > 0 then
      local E = d[N[1]]
      local R = math["huge"]
      local I = -math["huge"]
      for B, d in ipairs(E) do
        if d["tileX"] < R then
          R = d["tileX"]
        end
        if d["tileX"] > I then
          I = d["tileX"]
        end
      end
      if math["abs"](B - I) < math["abs"](B - R) then
        V = false
      end
    end
    local R = {}
    for B, E in ipairs(N) do
      local N = d[E]
      local I
      if B % 2 == 1 then
        I = V
      else
        I = not V
      end
      table["sort"](N, function(B, d)
        if I then
          return B["tileX"] < d["tileX"]
        else
          return B["tileX"] > d["tileX"]
        end
      end)
      for B, d in ipairs(N) do
        table["insert"](R, d)
      end
    end
    E = R
  end
  ACD19_safeEditValue("ACD_objects", tostring(#E))
  return E
end
local function By()
  local B = {}
  for d, E in pairs(A0()) do
    local N = tonumber(E and E["itemid"])
    if N and (K[N] and O0(N) >= F) then
      local d, V = x0(E)
      if d ~= nil and V ~= nil then
        local R, I = math["floor"](d / 32), math["floor"](V / 32)
        if not (L0() and H0(R, I)) and not ACD_EXACT_isSkipped(E["id"]) then
          B[N] = true
        end
      end
    end
  end
  return B, next(B) ~= nil
end
local function dy(B)
  if B == nil or B["uid"] == nil then
    return false
  end
  local d = pcall(function()
    SendPacketRaw(false, { ["type"] = 11, ["value"] = B["uid"], ["x"] = B["pixelX"], ["y"] = B["pixelY"] })
  end)
  return d
end
local function Ey(B)
  local d = 0
  while v and (I0() == P and d < U) do
    if i0() > B then
      return true
    end
    Sleep(Ss)
    d = d + Ss
  end
  return v and (I0() == P and i0() > B)
end
local function Ny(B, d)
  if not v or I0() ~= P then
    return false
  end
  if U0(B, d) then
    return true
  end
  N0(true)
  local E = pcall(function()
    FindPath(B, d)
  end)
  if not E then
    return false
  end
  local N, V = 0, 0
  local R, I = T0()
  while v and N < Js do
    if I0() ~= P then
      return false
    end
    local E, c = T0()
    if E == nil or c == nil then
      return false
    end
    if U0(B, d) then
      Sleep(Ys)
      return v and (I0() == P and U0(B, d))
    end
    if E ~= R or c ~= I then
      V = 0
      R, I = E, c
    else
      V = V + is
    end
    if N >= 2000 and V >= ns then
      return U0(B, d)
    end
    Sleep(is)
    N = N + is
  end
  return false
end
local function Vy()
  local B = "CAUTIOUS"
  if M >= 3 then
    B = "FAST"
  end
  if M == 1 then
    B = "LAG SAFE"
  end
  pcall(function()
    ACD19_safeEditValue("ACD_serverpace", B .. (" (" .. (tostring(M) .. ")")))
  end)
end
local function Ry()
  M = 1
  r = 0
  Q = math["min"](Q + 1, 5)
  Vy()
end
local function Iy()
  Q = 0
  r = r + 1
  if r >= 2 and M < o then
    M = M + 1
    r = 0
  end
  Vy()
end
local function cy(B, d, E)
  if not v or I0() ~= P then
    return "WORLD"
  end
  if not W0(B["itemID"]) then
    return "FULL"
  end
  if not k0(B["uid"]) then
    return "GONE"
  end
  local N = i0()
  xs("PATH " .. (d .. ("/" .. E)))
  local V, R = B["tileX"], B["tileY"]
  if not Ny(V, R) then
    if not v or I0() ~= P then
      return "WORLD"
    end
    if i0() > N then
      return "ACK"
    end
    if not k0(B["uid"]) then
      return "GONE"
    end
    return "SKIP"
  end
  if m0() and H0(V, R) then
    return "SKIP"
  end
  local I = {}
  for B, d in pairs(A0()) do
    local E, N = tonumber(d["id"]), tonumber(d["itemid"])
    local c, L = x0(d)
    if E and (N and (c and (L and (math["floor"](c / 32) == V and math["floor"](L / 32) == R)))) then
      I[#I + 1] = { ["uid"] = E, ["itemID"] = N, ["pixelX"] = c, ["pixelY"] = L }
    end
  end
  table["sort"](I, function(B, d)
    return B["uid"] < d["uid"]
  end)
  local c = false
  local function L(B, d)
    if not v or I0() ~= P or not U0(d, R) or not k0(B["uid"]) then
      return false
    end
    local E = O0(B["itemID"])
    if E >= F or not dy(B) then
      return false
    end
    c = true
    Sleep(Xs + T)
    local N = 0
    while v and (I0() == P and U0(d, R)) do
      if O0(B["itemID"]) > E or not k0(B["uid"]) then
        return false
      end
      if N >= U then
        return true
      end
      Sleep(Ss)
      N = N + Ss
    end
    return false
  end
  local m = {}
  for B, d in ipairs(I) do
    if not v or I0() ~= P then
      return "WORLD"
    end
    if not U0(V, R) then
      return "PATH"
    end
    if L(d, V) then
      local B = d["pixelX"] - V * 32
      local E = B >= 24 and V + 1 or (B <= 8 and V - 1 or nil)
      if E and E >= 0 then
        m[#m + 1] = { ["stack"] = d, ["x"] = E }
      end
    end
  end
  for B, d in ipairs(m) do
    if not v or I0() ~= P then
      return "WORLD"
    end
    if
      k0(d["stack"]["uid"]) and (O0(d["stack"]["itemID"]) < F and (not (m0() and H0(d["x"], R)) and Ny(d["x"], R)))
    then
      L(d["stack"], d["x"])
    end
  end
  if not v or I0() ~= P then
    return "WORLD"
  end
  if i0() > N then
    return "ACK"
  end
  if c then
    return "SENT"
  end
  return "GONE"
end
local function Ly(B)
  if type(B) ~= "table" or #B == 0 then
    return false
  end
  ss = ss + 1
  xs("ADAPTIVE COLLECT")
  N0(true)
  V0(false)
  Vy()
  local d, E = {}, {}
  local N = i0()
  local V = false
  local R = false
  local function I()
    if #d == 0 then
      N = i0()
      return true
    end
    if v0() then
      d = {}
      return true
    end
    xs("WAIT BATCH ACK")
    local B = i0() > N
    if not B then
      B = Ey(N)
    end
    if B then
      R = true
      Iy()
      for B, d in ipairs(d) do
        if not k0(d["uid"]) then
          hs[tostring(d["uid"])] = nil
        end
      end
    else
      Ry()
      for B, d in ipairs(d) do
        hs[tostring(d["uid"])] = ss + ws
      end
      xs("SERVER SLOW - BACKOFF")
      local B = math["min"](vs + 250 * Q, ps)
      Sleep(B)
    end
    d = {}
    N = i0()
    return B
  end
  for N, c in ipairs(B) do
    if not v or I0() ~= P then
      break
    end
    if v0() then
      break
    end
    local L = tostring(c["uid"] or "")
    local m = c["tileX"] .. ("," .. c["tileY"])
    if L ~= "" and (not E[m] and ss >= (hs[L] or 0)) then
      if #d >= M then
        if not I() then
          break
        end
        if not v or I0() ~= P then
          break
        end
      end
      if v0() then
        break
      end
      V = true
      local H = cy(c, N, #B)
      if H ~= "GONE" then
        E[m] = true
      end
      if H == "WORLD" or H == "FULL" then
        break
      elseif H == "ACK" then
        R = true
        if #d > 0 then
          if not I() then
            break
          end
        else
          Iy()
        end
      elseif H == "SENT" then
        d[#d + 1] = c
      elseif H == "SKIP" then
        ACD_EXACT_markSkipped(c["uid"], "EXACT PATH FAILED")
      elseif H == "PATH" or H == "PACKET" then
        hs[L] = ss + ws
      end
    end
  end
  if v and (I0() == P and not v0()) then
    I()
  end
  if v and (I0() == P and (not v0() and not V)) then
    xs("WAIT DEFERRED PICKUPS")
    Sleep(300)
  end
  G0()
  return R
end
local function my(B)
  v = false
  ACD19_storageEntryConfirmed = false
  ACD19_storageEntryConfirmedX, ACD19_storageEntryConfirmedY = nil, nil
  h = false
  w = 0
  V0(false)
  N0(false)
  os = false
  Ms = false
  rs = false
  Qs = false
  Ps = nil
  Ds = 0
  ys = false
  K0()
  ACD19_safeSetStartToggle(false)
  xs("STOPPED")
  if B ~= nil and B ~= "" then
    Cs(B)
  end
end
local function Hy()
  if not v then
    return false
  end
  local B = Bs - 1
  local d = ds
  ys = true
  xs("DROP SHIFT LEFT -> " .. (tostring(B) .. ("," .. tostring(d))))
  if not h0(B, d) then
    xs("WAIT LEFT PATH " .. (tostring(B) .. ("," .. tostring(d))))
    return false
  end
  Bs = B
  ds = d
  ACD19_storageEntryConfirmed = false
  ys = false
  Cs("Storage moved left to (" .. (tostring(B) .. (", " .. (tostring(d) .. ")"))))
  return true
end
local function qy(B, d, E)
  if not v or not P0(x) then
    return false
  end
  if not ACD19_storageEntryConfirmed or not U0(Bs, ds) then
    xs("WAIT SAFE DROP POSITION")
    return false
  end
  if not ACD19_stableAtStorageTile(Bs, ds, ACD19_DROP_PRE_PACKET_STABLE_MS, 650) then
    ACD19_storageEntryConfirmed = false
    xs("DROP BLOCKED - LEFT STORAGE TILE")
    return false
  end
  if O0(B) < d then
    return true
  end
  os = true
  Ms = false
  xs("DROP REQUEST " .. tostring(B))
  local N = pcall(function()
    SendPacket(2, "action|drop\nitemID|" .. tostring(B))
  end)
  if not N then
    os = false
    Ms = false
    return false
  end
  local V = 0
  while v and (P0(x) and V < ls) do
    if Ms or O0(B) < d then
      break
    end
    Sleep(75)
    V = V + 75
  end
  local R = Ms
  os = false
  Ms = false
  if not v or not P0(x) then
    return false
  end
  if O0(B) < d then
    return true
  end
  if not R then
    return false
  end
  if not ACD19_storageEntryConfirmed or not ACD19_stableAtStorageTile(Bs, ds, ACD19_DROP_PRE_PACKET_STABLE_MS, 650) then
    ACD19_storageEntryConfirmed = false
    xs("DROP CANCELLED - POSITION CHANGED")
    return false
  end
  xs("DROP CONFIRM " .. tostring(B))
  local I = pcall(function()
    SendPacket(
      2,
      "action|dialog_return\n"
        .. ("dialog_name|drop_item\n" .. ("itemID|" .. (tostring(B) .. ("|\n" .. ("count|" .. tostring(E))))))
    )
  end)
  if not I then
    return false
  end
  V = 0
  while v and (P0(x) and V < bs) do
    if O0(B) < d then
      return true
    end
    Sleep(100)
    V = V + 100
  end
  return O0(B) < d
end
local function zy(B, d)
  while v do
    if not P0(x) then
      return false
    end
    b0()
    if u0(d) <= 0 then
      return true
    end
    if ys then
      if not Hy() then
        return false
      end
    end
    if not ACD19_confirmStorageDropPosition() then
      xs("WAIT VERIFIED STORAGE PATH")
      return false
    end
    b0()
    local B = O0(d)
    local E = u0(d)
    if E <= 0 then
      return true
    end
    local N = false
    for V = 1, Ks, 1 do
      if not v or not P0(x) then
        return false
      end
      b0()
      if O0(d) < B then
        N = true
        break
      end
      E = u0(d)
      if E <= 0 then
        return true
      end
      xs("DROP " .. (tostring(d) .. (" x" .. (tostring(E) .. (" TRY " .. (tostring(V) .. ("/" .. tostring(Ks))))))))
      if qy(d, B, E) then
        N = true
        break
      end
      if not ACD19_storageEntryConfirmed or not P0(x) or not U0(Bs, ds) then
        xs("STORAGE MOVED - RECHECK DROP TILE")
        return false
      end
      Sleep(Fs)
      b0()
      if O0(d) < B then
        N = true
        break
      end
    end
    b0()
    if N then
      local E = O0(d)
      if E < B then
        xs("DROPPED " .. (tostring(B - E) .. (" " .. f0(d))))
        G0()
      end
    else
      if not Hy() then
        return false
      end
    end
  end
  return false
end
local function Ay(B)
  local d = 0
  for E, N in ipairs(b) do
    if B == nil or B[N] then
      d = d + u0(N)
    end
  end
  return d
end
local function Oy(B, d)
  l0()
  b0()
  if Ay(d) <= 0 then
    return true
  end
  V0(false)
  if not y0(x) then
    xs("WAIT SHARED STORAGE WORLD")
    return false
  end
  rs = true
  if ys and not Hy() then
    rs = false
    return false
  end
  if not ACD19_confirmStorageDropPosition() then
    rs = false
    xs("WAIT VERIFIED STORAGE PATH")
    return false
  end
  for E, N in ipairs(b) do
    if not v then
      break
    end
    b0()
    if (d == nil or d[N]) and u0(N) > 0 then
      if not zy(B, N) then
        rs = false
        return false
      end
    end
  end
  b0()
  rs = false
  G0()
  return v and Ay(d) <= 0
end
local function fy()
  if not v or s > #y then
    h = false
    return
  end
  local B = y[s]
  P = B
  if Q0(B) then
    h = false
    w = 0
    return
  end
  h = true
  w = 0
  xs("STORED - RETURN TO " .. tostring(B))
end
local function Jy()
  if not h then
    return true
  end
  if not v then
    return false
  end
  if s > #y then
    h = false
    return true
  end
  local B = y[s]
  P = B
  w = w + 1
  xs("RETURN " .. (tostring(w) .. (" -> " .. tostring(B))))
  if y0(B, cs) and Q0(B) then
    Sleep(ms)
    if v and Q0(B) then
      h = false
      w = 0
      C = 0
      Ds = 0
      ss = 0
      hs = {}
      xs("RESUMED " .. tostring(B))
      return true
    end
  end
  xs("RETURN WARP RETRY " .. (tostring(w) .. (" -> " .. tostring(B))))
  Sleep(Ls)
  return false
end
local function iy(B)
  if type(B) ~= "string" or B == "" then
    return nil
  end
  local d, E = pcall(function()
    if type(findItemID) == "function" then
      return findItemID(B)
    end
    if growtopia ~= nil and type(growtopia["getItemID"]) == "function" then
      return growtopia["getItemID"](B)
    end
    return nil
  end)
  if d and (tonumber(E) ~= nil and tonumber(E) > 0) then
    return math["floor"](tonumber(E))
  end
  return nil
end
local function ny(B)
  if type(B) == "number" then
    return math["floor"](B)
  end
  if type(B) == "string" then
    local d = tonumber(B)
    if d ~= nil and d > 0 then
      return math["floor"](d)
    end
    local E = iy(B)
    if E ~= nil then
      return E
    end
    local N = B:match("(%d+)")
    if N ~= nil then
      local B = tonumber(N)
      if B ~= nil and B > 0 then
        return math["floor"](B)
      end
    end
    return nil
  end
  if type(B) == "table" then
    local d = { B["id"], B["itemid"], B["itemID"], B["value"], B["item"], B["name"], B["itemName"], B["selected"] }
    for B, d in ipairs(d) do
      local E = ny(d)
      if E ~= nil and E > 0 then
        return E
      end
    end
  end
  return nil
end
local function Yy(B)
  local d = ny(B)
  if d == nil or d <= 0 or d > 65535 then
    return false
  end
  if v then
    Cs("Stop before changing selected items.")
    return true
  end
  for B, E in ipairs(l) do
    if E == d then
      Cs("Already selected: " .. (f0(d) .. (" (" .. (tostring(d) .. ")"))))
      return true
    end
  end
  if #l >= 30 then
    Cs("Maximum 30 selected items.")
    return true
  end
  l[#l + 1] = d
  g0()
  G0()
  ACD19_safeEditValue("ACD_objects", "0")
  Ns = true
  Cs("Added collect item: " .. (f0(d) .. (" (" .. (tostring(d) .. ")"))))
  return true
end
function onVariant(B, d)
  if B ~= nil and (B["v1"] == "OnDialogRequest" and type(B["v2"]) == "string") then
    if v and (os and B["v2"]:find("drop_item", 1, true)) then
      Ms = true
      return true
    end
  end
  return false
end
function onGamePacket(B)
  if B ~= nil and tonumber(B["type"]) == 26 then
    o0 = ""
    M0 = ""
    r0 = ""
    ACD61_activeDoorRoute = ""
    ACD19_storageEntryConfirmed = false
    ACD19_storageEntryConfirmedX, ACD19_storageEntryConfirmedY = nil, nil
  end
  return false
end
function onSendPacketRaw(B)
  if not v or B == nil or tonumber(B["type"]) ~= 11 or not m0() then
    return false
  end
  local d = tonumber(B["value"])
  if d == nil then
    return true
  end
  local E = nil
  for B, N in pairs(A0()) do
    if tonumber(N and N["id"]) == d then
      E = N
      break
    end
  end
  if E == nil then
    return true
  end
  local N, V = x0(E)
  if N == nil or V == nil then
    return true
  end
  local R, I = math["floor"](N / 32), math["floor"](V / 32)
  if L0() and H0(R, I) then
    return true
  end
  if m0() then
    if H0(R, I) then
      return true
    end
    local B, d = T0()
    if B ~= nil and (d ~= nil and H0(B, d)) then
      return true
    end
  end
  return false
end
local function Wy()
  v = true
  N0(true)
  V0(false)
  if #l == 0 then
    my("Add at least one Collect Item first.")
    return
  end
  if #D == 0 then
    my("Add at least one Collection World in Settings first.")
    return
  end
  if x == "" then
    my("Set Drop World first.")
    return
  end
  H("repeat", false)
  H("loops", 0)
  y, b, K = {}, {}, {}
  g = t
  j = {}
  G = false
  a = {}
  for B, d in ipairs(D) do
    y[#y + 1] = d
  end
  for B, d in ipairs(l) do
    b[#b + 1] = d
    K[d] = true
  end
  s = 1
  h = false
  w = 0
  P = y[1]
  C = 0
  ks()
  Bs = k
  ds = e
  ACD19_storageEntryConfirmed = false
  ACD19_storageEntryConfirmedX, ACD19_storageEntryConfirmedY = nil, nil
  Qs = false
  Ps = nil
  Ds = 0
  ys = false
  ACD_EXACT_skippedByWorld = {}
  ACD_EXACT_skipCountByWorld = {}
  ACD_EXACT_totalSkipped = 0
  ACD19_safeEditValue("ACD_exactskipped", "0")
  ss = 0
  hs = {}
  M = math["min"](2, o)
  r = 0
  Q = 0
  Vy()
  Ns = false
  Vs = 0
  G0()
  p0()
  a0()
  xs("STARTING")
  Cs(
    "Auto Collect V6.1 started: " .. (
        g == 0 and "UNLIMITED UNTIL WORLDS EMPTY" or ("per-item drop goal " .. tostring(g))
      )
  )
end
function onValue(B, d, E)
  if ACD19_guardedUIWrites[d] then
    return
  end
  if d == "ACD_enable" then
    if E == true then
      if v or X then
        return
      end
      p = p + 1
      local B = p
      X = true
      N0(false)
      V0(false)
      runThread(function()
        if not X or p ~= B then
          return
        end
        X = false
        Wy()
      end)
    else
      p = p + 1
      X = false
      v = false
      V0(false)
      N0(false)
      os = false
      Ms = false
      rs = false
      Qs = false
      ys = false
      K0()
      xs("STOPPED")
      Cs("Auto Collect -> Drop stopped.")
    end
    return
  end
  if d == "ACD_itempicker" then
    if not Yy(E) then
      Cs("Could not read selected item.")
    end
    return
  end
  if d == "ACD_selecteditem" then
    t0()
    return
  end
  if d == "ACD_itemlist" then
    if v then
      pcall(function()
        ACD19_safeEditValue("ACD_itemlist", L(l))
      end)
      Cs("Stop before editing the item list.")
      return
    end
    l = c(E)
    g0()
    G0()
    return
  end
  if d == "ACD_removeitem" then
    if v then
      Cs("Stop before removing items.")
      return
    end
    if #l > 0 then
      local B = table["remove"](l)
      g0()
      G0()
      Cs("Removed selected item " .. tostring(B))
    end
    return
  end
  if d == "ACD_clearitems" then
    if v then
      Cs("Stop before clearing items.")
      return
    end
    l = {}
    g0()
    G0()
    Cs("Selected item list cleared.")
    return
  end
  if d == "ACD_droptotal" then
    local B = tonumber(E)
    if B == nil or B < 0 then
      pcall(function()
        ACD19_safeEditValue("ACD_droptotal", tostring(t))
      end)
      Cs("Total Drop Per Item must be 0 or a positive whole number.")
      return
    end
    B = math["max"](0, math["min"](1000000000, math["floor"](B)))
    t = B
    H("droptotal", t)
    if tostring(E) ~= tostring(B) then
      pcall(function()
        ACD19_safeEditValue("ACD_droptotal", tostring(B))
      end)
    end
    if v then
      Cs("Drop total saved. The new goal applies on next Start.")
    else
      g = t
      p0()
    end
    return
  end
  if d == "ACD_pickupdelay" then
    local B = tonumber(E)
    if B ~= nil then
      B = math["floor"](B)
      if B < 0 then
        B = 0
      end
      if B > 1000 then
        B = 1000
      end
      T = B
      ACD19_safeEditValue("ACD_pickupdelay", tostring(T))
      H("pickupdelay", T)
    end
    return
  end
  if d == "ACD_batchmax" then
    local B = math["floor"](tonumber(E) or o)
    o = math["max"](1, math["min"](2, B))
    M = math["min"](M, o)
    pcall(function()
      ACD19_safeEditValue("ACD_batchmax", tostring(o))
    end)
    Vy()
    H("batchmax", o)
    return
  end
  if d == "ACD_acktimeout" then
    local B = tonumber(E)
    if B ~= nil then
      B = math["floor"](B)
      if B < 300 then
        B = 300
      end
      if B > 10000 then
        B = 10000
      end
      U = B
      ACD19_safeEditValue("ACD_acktimeout", tostring(U))
      H("acktimeout", U)
    end
    return
  end
  if d == "ACD_worldlist" then
    D = R(E)
    es()
    ks()
    if v then
      Cs("World list saved; changes take effect on the next Start.")
    end
    return
  end
  if d == "ACD_addworld" then
    local B = I0()
    if B == "" or B == "EXIT" then
      Cs("Enter the world you want to add first.")
      return
    end
    local d = false
    for E, N in ipairs(D) do
      if N == B then
        d = true
        break
      end
    end
    if not d then
      if #D >= 30 then
        Cs("Maximum 30 collection worlds.")
        return
      end
      D[#D + 1] = B
    end
    es()
    ks()
    Cs("Collection worlds: " .. I(D))
    return
  end
  if d == "ACD_removeworld" then
    if #D > 0 then
      local B = table["remove"](D)
      es()
      ks()
      Cs("Removed collection world " .. tostring(B))
    end
    return
  end
  if d == "ACD_dropworld" then
    if v then
      pcall(function()
        ACD19_safeEditValue("ACD_dropworld", x)
      end)
      Cs("Stop the script before editing the Shared Storage World.")
      return
    end
    x = R0(E)
    H("dropworld", x)
    ks()
    return
  end
  if d == "ACD_setdropworld" then
    if v then
      Cs("Stop before editing Shared Storage World.")
      return
    end
    local B = I0()
    if B == "" or B == "EXIT" then
      Cs("Current world is not available.")
      return
    end
    x = B
    ACD19_safeEditValue("ACD_dropworld", x)
    H("dropworld", x)
    ks()
    Cs("Shared Storage World = " .. x)
    return
  end
  if d == "ACD_dropx" then
    if v then
      pcall(function()
        ACD19_safeEditValue("ACD_dropx", tostring(k))
      end)
      Cs("Stop before editing Drop X.")
      return
    end
    local B = tonumber(E)
    if B ~= nil then
      k = math["floor"](B)
      Bs = k
      H("dropx", k)
    end
    return
  end
  if d == "ACD_dropy" then
    if v then
      pcall(function()
        ACD19_safeEditValue("ACD_dropy", tostring(e))
      end)
      Cs("Stop before editing Drop Y.")
      return
    end
    local B = tonumber(E)
    if B ~= nil then
      e = math["floor"](B)
      ds = e
      H("dropy", e)
    end
    return
  end
  if d == "ACD_setdrop" then
    if v then
      Cs("Stop before setting Drop Position.")
      return
    end
    local B, d = T0()
    if B == nil or d == nil then
      Cs("Player position is not available.")
      return
    end
    k = B
    e = d
    Bs = k
    ds = e
    ACD19_safeEditValue("ACD_dropx", tostring(k))
    ACD19_safeEditValue("ACD_dropy", tostring(e))
    H("dropx", k)
    H("dropy", e)
    Cs("Drop Position = (" .. (tostring(k) .. (", " .. (tostring(e) .. ")"))))
    return
  end
end
applyHook()
if type(setOnValue) == "function" then
  pcall(function()
    setOnValue("ACD_itempicker", function(...)
      local B = { ... }
      for d = #B, 1, -1 do
        if Yy(B[d]) then
          return
        end
      end
    end)
  end)
end
runThread(function()
  N0(false)
  t0()
  G0()
  a0()
  p0()
  ks()
  Vy()
  ACD19_safeEditValue("ACD_objects", "0")
  xs("STOPPED")
  ACD19_mwSaveState = E == nil and "UNAVAILABLE" or (ACD19_mwSettingsRestored and "RESTORED" or "READY - SAVES ON EDIT")
  ACD19_safeEditValue("ACD_autosave", ACD19_mwSaveState)
  while true do
    if not v then
      Sleep(200)
    else
      if h then
        Jy()
      elseif Y0() then
        my("All selected item drop totals reached (" .. (tostring(g) .. " each)."))
      elseif Qs or v0() then
        Qs = true
        V0(false)
        if Ps then
          xs("UNLIMITED -> FREE FULL ITEM STACKS")
        else
          xs("ALL ITEMS READY -> SHARED STORAGE")
        end
        if Oy("Ready selected items dropped", Ps) then
          Qs = false
          Ps = nil
          Ds = 0
          K0()
          Vs = Vs + 1
          a0()
          if Y0() then
            my("All selected item drop totals reached (" .. (tostring(g) .. " each)."))
          else
            fy()
            Sleep(150)
          end
        else
          Sleep(400)
        end
      elseif s > #y then
        if Z0() > 0 then
          xs("FINAL STORAGE -> STOP")
          if Oy("Last eligible collected items dropped") then
            K0()
            ks()
            if g > 0 and not Y0() then
              my("All worlds scanned. Drop targets not met: " .. X0())
            else
              my("All " .. (tostring(#y) .. " collection worlds finished. Eligible items stored."))
            end
          elseif v then
            Sleep(500)
          end
        else
          K0()
          ks()
          if g > 0 and not Y0() then
            my("All worlds scanned. Drop targets not met: " .. X0())
          else
            my("All collection worlds finished. No more eligible items.")
          end
        end
      else
        P = y[s]
        if not y0(P) then
          xs("WAIT COLLECT WORLD " .. tostring(P))
          Sleep(1300)
        elseif not P0(P) then
          xs("WAIT COLLECT PLAYER READY")
          Sleep(300)
        else
          xs("SCAN " .. tostring(P))
          local B = e0()
          if #B == 0 then
            local B, d = nil, false
            if g == 0 then
              B, d = By()
            end
            if d then
              C = 0
              Ds = Ds + 1
              if Ds >= 2 then
                Ps = B
                Qs = true
                Ds = 0
                xs("UNLIMITED / FULL STACK: STORE & RESUME")
              else
                xs("VERIFY FULL STACK BACKLOG")
              end
              Sleep(400)
            else
              Ds = 0
              C = C + 1
              if C < 3 then
                xs("CONFIRM EMPTY " .. (tostring(C) .. ("/3 " .. tostring(P))))
                Sleep(400)
              else
                local B = ACD_EXACT_skipCountByWorld[P] or 0
                xs((B > 0 and ("WORLD DONE - SKIPPED " .. (tostring(B) .. " ")) or "WORLD COMPLETE ") .. tostring(P))
                C = 0
                s = s + 1
                ss = 0
                hs = {}
                if s <= #y then
                  P = y[s]
                end
                ks()
                Sleep(250)
              end
            end
          else
            C = 0
            Ds = 0
            Ly(B)
            V0(false)
            xs("RESCAN " .. tostring(P))
            Sleep(Ws)
          end
        end
      end
      Sleep(120)
    end
  end
end)
