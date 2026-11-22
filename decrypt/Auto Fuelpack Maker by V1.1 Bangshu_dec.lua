setMinimum("6.1.2")
local q = "auto_fuel_pack_maker_v10_settings.json"
local e = nil
local W = false
do
  local W, h = pcall(require, "preferences")
  if not W or h == nil then
    h = Preferences
  end
  if h ~= nil and type(h["new"]) == "function" then
    local W, r = pcall(function()
      return h:new(q)
    end)
    if W and r ~= nil then
      e = r
      pcall(function()
        e:load()
      end)
    end
  end
end
local function h(q, W, h, r)
  local j = W
  if e ~= nil then
    local h, r = pcall(function()
      return e:get(q, W)
    end)
    if h and tonumber(r) ~= nil then
      j = tonumber(r)
    end
  end
  j = math["floor"](j)
  if h ~= nil then
    j = math["max"](h, j)
  end
  if r ~= nil then
    j = math["min"](r, j)
  end
  return j
end
local r = h("cookX", 0)
local j = h("cookY", 0)
local V = h("storageX", 0)
local L = h("storageY", 0)
local s = h("firstPunchDelay", 500, 0, 10000)
local u = h("prePunchDelay", 700, 0, 10000)
local N = h("openPunchDelay", 350, 0, 10000)
local F = h("dropDelay", 250, 0, 10000)
local w = h("collectDelay", 500, 0, 10000)
local Z = h("pickupGap", 900, 350, 10000)
local y = h("verifyDelay", 200, 0, 10000)
local O = h("fuelStorePause", 4000, 0, 10000)
local C = h("pathPace", 900, 500, 5000)
local I = h("recipePause", 1500, 500, 10000)
local c =
  "https://script.google.com/macros/s/AKfycbxeBzpOUzvcRDkX-4eR8uioFbAUDsepIQc26kmxUkXt6YOjBxFdVsOE0zzvxYSprl5knA/exec"
local T = "AUTOFUEL"
local A = "FuelPackV34License"
local H = "license_key"
local o = nil
local d = ""
local function m(q)
  q = tostring(q or "")
  q = q:gsub("%s+", "")
  return q:upper()
end
local function b(q)
  q = m(q)
  return q:match("^[A-Z]%d%d%d%d%d%d%d$") ~= nil
end
local function J()
  local q = pcall(function()
    local q = nil
    if type(require) == "function" then
      local e, W = pcall(require, "preferences")
      if e and W ~= nil then
        q = W
      end
    end
    if q == nil and type(Preferences) == "table" then
      q = Preferences
    end
    if q == nil then
      return
    end
    if type(q["new"]) == "function" then
      local e = q:new(A)
      o = e or q
    else
      o = q
    end
    if o ~= nil and type(o["load"]) == "function" then
      o:load()
    end
    if o ~= nil and type(o["get"]) == "function" then
      d = m(o:get(H, ""))
    end
  end)
  if not q then
    o = nil
    d = ""
  end
end
local function z(q)
  if o == nil then
    return false
  end
  local e = pcall(function()
    o:set(H, m(q))
    o:save()
  end)
  return e
end
local function S()
  if o == nil then
    return false
  end
  local q = pcall(function()
    o:set(H, "")
    o:save()
  end)
  return q
end
J()
local x = UserInterface["new"]("Fuel Pack Maker", "Science")
x:addLabelApp("Fuel Pack Maker", "Science")
x:addInputString("License Key", d, "A1234567", "A1234567", nil, "FUEL_licensekey")
x:addButton("Verify License", "FUEL_verifylicense")
x:addButton("Clear Saved License", "FUEL_clearlicense")
x:addDisplayList("License Status", "NOT VERIFIED", "FUEL_licensestatus")
x:addToggle("Start / Stop", false, "FUEL_enable")
x:addInputInt("Cook Position X", tostring(r), "X", "0", nil, "FUEL_cookx")
x:addInputInt("Cook Position Y", tostring(j), "Y", "0", nil, "FUEL_cooky")
x:addButton("Set Cook Position = Current Tile", "FUEL_setcook")
x:addInputInt("Storage Position X", tostring(V), "X", "0", nil, "FUEL_storagex")
x:addInputInt("Storage Position Y", tostring(L), "Y", "0", nil, "FUEL_storagey")
x:addButton("Set Storage Position = Current Tile", "FUEL_setstorage")
x:addInputInt("After Oven Open Before Pickup (ms)", tostring(s), "ms", "0", nil, "FUEL_firstpunchdelay")
x:addInputInt("After Third Drop Before Punch (ms)", tostring(u), "ms", "0", nil, "FUEL_prepunchdelay")
x:addInputInt("After Open Punch (ms)", tostring(N), "ms", "0", nil, "FUEL_openpunchdelay")
x:addInputInt("After Drop (ms)", tostring(F), "ms", "0", nil, "FUEL_dropdelay")
x:addInputInt("Before Each Collect Attempt (ms)", tostring(Z), "ms", "900", nil, "FUEL_pickupgap")
x:addInputInt("After Fuel Pack Storage Pause (ms)", tostring(O), "ms", "4000", nil, "FUEL_storepause")
x:addInputInt("Before New Path Request (ms)", tostring(C), "ms", "900", nil, "FUEL_pathpace")
x:addInputInt("Between Cook Batches (ms)", tostring(I), "ms", "1500", nil, "FUEL_recipepause")
x:addInputInt("After Collect (ms)", tostring(w), "ms", "500", nil, "FUEL_collectdelay")
x:addInputInt("Empty Scan Gap (ms)", tostring(y), "ms", "0", nil, "FUEL_verifydelay")
x:addDisplayList("Phase", "STOPPED", "FUEL_phase")
x:addDisplayList("Status", "STOPPED", "FUEL_status")
x:addInputString("Preparation Status (view only)", "WAITING", "", "Preparation stage", nil, "FUEL_prepstatus")
x:addInputString("Drop Diagnostics (view only)", "READY", "", "Drop stage", nil, "FUEL_dropdebug")
x:addInputString("Drop Destination (view only)", "NONE", "", "COOK or STORAGE tile", nil, "FUEL_dropdest")
x:addDisplayList("Mysterious Chemical", "0", "FUEL_mcount")
x:addDisplayList("Fuel Pack", "0", "FUEL_fuelcount")
x:addDisplayList("Fast Drop", "OFF", "FUEL_fastdrop")
x:addDisplayList("Settings", e ~= nil and "AUTO SAVE ON" or "AUTO SAVE UNAVAILABLE", "FUEL_settingsstatus")
pcall(function()
  addCategory("Fuel Pack Maker", "Science")
end)
local f = pcall(function()
  addIntoModule(x:generateJSON(), "Fuel Pack Maker")
end)
if not f then
  addIntoModule(x:generateJSON())
end
local B = false
local g = ""
local G, Q = r, j
local E, M = V, L
local K, X = V, L
local P = "STOPPED"
local Y = "STOPPED"
local n = 0
local R = 0
local D = 0
local v = 0
local a = 0
local l = 0
local U, p, k = 20, 10, 5
local t, i, qO = 1, 10, 2
local eO = 200
local WO = { ["M"] = false, ["FUEL"] = false }
local hO = 2
local rO = 3200
local jO = 1200
local VO = C
local LO = I
local sO = 2500
local uO = 3000
local NO = 2
local FO = 3200
local wO = 600
local ZO = 1200
local yO = 3
local OO = 3
local CO = 350
local IO = 100
local cO = 12
local TO = 1
local AO = 1500
local HO = 50
local oO = 1200
local dO = Z
local mO = w
local bO = O
local JO = y
local zO = 2
local SO = 8
local xO = 1400
local fO = 3
local BO = 1600
local gO = 1
local GO = F
local QO = u
local EO = 500
local MO = s
local KO = N
local XO = 50
local PO = 400
local YO = 2
local nO = 3
local RO = 1200
local DO = 600
local vO = 0
local aO = 0
local lO = 2
local UO = 3000
local pO = nil
local kO = nil
local tO
local iO
local q1 = false
local e1 = false
local function W1()
  if e == nil then
    return false
  end
  local q, h = pcall(function()
    e:set("cookX", G)
    e:set("cookY", Q)
    e:set("storageX", E)
    e:set("storageY", M)
    e:set("firstPunchDelay", MO)
    e:set("prePunchDelay", QO)
    e:set("openPunchDelay", KO)
    e:set("dropDelay", GO)
    e:set("collectDelay", mO)
    e:set("pickupGap", dO)
    e:set("fuelStorePause", bO)
    e:set("pathPace", VO)
    e:set("recipePause", LO)
    e:set("verifyDelay", JO)
    e:save()
  end)
  if not q then
    if not W then
      W = true
      pcall(function()
        growtopia["notify"]("Fuel Maker settings could not be saved: " .. tostring(h))
      end)
    end
    pcall(function()
      editValue("FUEL_settingsstatus", "AUTO SAVE FAILED")
    end)
    return false
  end
  pcall(function()
    editValue("FUEL_settingsstatus", "AUTO SAVE ON")
  end)
  return true
end
local function h1(q)
  pcall(function()
    growtopia["notify"](tostring(q))
  end)
end
local function r1(q)
  q = tostring(q or "")
  if Y ~= q then
    Y = q
    pcall(function()
      editValue("FUEL_status", q)
    end)
  end
end
local function j1(q)
  q = tostring(q or "")
  if P ~= q then
    P = q
    pcall(function()
      editValue("FUEL_phase", q)
    end)
  end
end
local V1 = {}
local function L1(q, e)
  e = (e == true)
  if V1[q] == e then
    return
  end
  local W = editToggle or EditToggle
  if W ~= nil then
    local h = pcall(W, q, e)
    if h then
      V1[q] = e
    end
  end
end
local function s1(q)
  L1("ModFly", q == true)
end
local function u1(q)
  L1("Fast Drop", q == true)
end
local function N1(q)
  q = (tostring(q or "")):gsub("%s+", "")
  return q:upper()
end
local function F1()
  local q, e = pcall(function()
    if type(GetWorldName) == "function" then
      return GetWorldName()
    elseif type(getCurrentWorldName) == "function" then
      return getCurrentWorldName()
    end
    return ""
  end)
  if not q then
    return ""
  end
  return N1(e)
end
local function w1()
  local q = GetLocal or getLocal
  if q == nil then
    return nil
  end
  local e, W = pcall(q)
  if e then
    return W
  end
  return nil
end
local function Z1()
  local q = GetObjectList or getObjectList
  if q == nil then
    return {}
  end
  local e, W = pcall(q)
  if e and type(W) == "table" then
    return W
  end
  return {}
end
local function y1()
  local q = w1()
  if q == nil then
    return nil, nil
  end
  return q["posX"] // 32, q["posY"] // 32
end
local function O1(q, e)
  local W, h = y1()
  return W == q and h == e
end
local C1 = "WAITING"
local I1 = "READY"
local function c1(q)
  q = tostring(q or "")
  if q ~= C1 then
    C1 = q
    pcall(function()
      editValue("FUEL_prepstatus", q)
    end)
  end
end
local function T1(q)
  q = tonumber(q)
  if q == nil or q <= 0 then
    return 0
  end
  local e = GetInventory or getInventory
  if type(e) == "function" then
    local W, h = pcall(e)
    if W and type(h) == "table" then
      local e = 0
      for W, h in pairs(h) do
        if tonumber(h["id"] or h["itemid"]) == q then
          e = e + (tonumber(h["amount"] or h["count"]) or 0)
        end
      end
      return math["max"](0, e)
    end
  end
  if growtopia ~= nil and type(growtopia["checkInventoryCount"]) == "function" then
    local e, W = pcall(growtopia["checkInventoryCount"], q)
    if e and tonumber(W) ~= nil then
      return math["max"](0, tonumber(W))
    end
  end
  return 0
end
local function A1(q)
  local e, W = pcall(function()
    if growtopia ~= nil and type(growtopia["getItemName"]) == "function" then
      return growtopia["getItemName"](q)
    end
    if type(getItemInfoByID) == "function" then
      local e = getItemInfoByID(q)
      if e ~= nil then
        return e["name"]
      end
    end
    return nil
  end)
  if e and (W ~= nil and tostring(W) ~= "") then
    return tostring(W)
  end
  return "Item " .. tostring(q)
end
local function H1(q)
  local e, W = pcall(function()
    if type(findItemID) == "function" then
      return findItemID(q)
    end
    if growtopia ~= nil and type(growtopia["getItemID"]) == "function" then
      return growtopia["getItemID"](q)
    end
    return nil
  end)
  if e and (tonumber(W) ~= nil and tonumber(W) > 0) then
    return math["floor"](tonumber(W))
  end
  return 0
end
local function o1()
  n = H1("Chemical Y")
  R = H1("Chemical B")
  D = H1("Chemical P")
  v = H1("Chemical G")
  a = H1("Mysterious Chemical")
  l = H1("Fuel Pack")
  local q = {}
  if n <= 0 then
    table["insert"](q, "Chemical Y")
  end
  if R <= 0 then
    table["insert"](q, "Chemical B")
  end
  if D <= 0 then
    table["insert"](q, "Chemical P")
  end
  if v <= 0 then
    table["insert"](q, "Chemical G")
  end
  if a <= 0 then
    table["insert"](q, "Mysterious Chemical")
  end
  if l <= 0 then
    table["insert"](q, "Fuel Pack")
  end
  if #q > 0 then
    h1("Could not resolve: " .. table["concat"](q, ", "))
    return false
  end
  return true
end
local function d1()
  pcall(function()
    editValue("FUEL_mcount", tostring(T1(a)))
  end)
  pcall(function()
    editValue("FUEL_fuelcount", tostring(T1(l)))
  end)
end
local function m1(q, e)
  if not B or F1() ~= g then
    return false
  end
  if O1(q, e) then
    return true
  end
  r1("PATH COOLDOWN " .. (tostring(VO) .. "ms"))
  local W = math["max"](500, VO)
  while W > 0 do
    if not B or F1() ~= g then
      return false
    end
    local q = math["min"](W, 100)
    Sleep(q)
    W = W - q
  end
  if O1(q, e) then
    return true
  end
  local h, r = pcall(function()
    return FindPath(q, e)
  end)
  return h and r ~= false
end
local function b1(q, e)
  if not B then
    return false
  end
  if O1(q, e) then
    return true
  end
  s1(true)
  for W = 1, hO, 1 do
    if not B or F1() ~= g then
      return false
    end
    r1("PATH " .. (tostring(W) .. ("/" .. (tostring(hO) .. (" -> " .. (tostring(q) .. ("," .. tostring(e))))))))
    local h = m1(q, e)
    if not h then
      r1("PATH REJECTED - WAIT BEFORE RETRY")
    end
    local r = 0
    while B and r < rO do
      if F1() ~= g then
        return false
      end
      if O1(q, e) then
        Sleep(120)
        return true
      end
      Sleep(100)
      r = r + 100
    end
    Sleep(jO)
  end
  return O1(q, e)
end
local function J1(q, e, W)
  local h = 0
  while B and h < W do
    if not O1(q, e) then
      return false
    end
    Sleep(100)
    h = h + 100
  end
  return B and O1(q, e)
end
local function z1(q, e, W)
  if not B then
    return false
  end
  s1(true)
  if not m1(q, e) then
    return false
  end
  local h = 0
  while B and h < W do
    if F1() ~= g then
      return false
    end
    if O1(q, e) then
      return true
    end
    Sleep(100)
    h = h + 100
  end
  return O1(q, e)
end
local function S1(q, e)
  if not B then
    return false
  end
  q = math["floor"](tonumber(q) or 0)
  e = math["floor"](tonumber(e) or 0)
  if O1(q, e) then
    return true
  end
  for W = 1, NO, 1 do
    if not B or F1() ~= g then
      return false
    end
    r1(
      "MOVING TO DROP " .. (tostring(W) .. ("/" .. (tostring(NO) .. (" @ " .. (tostring(q) .. ("," .. tostring(e)))))))
    )
    if z1(q, e, FO) then
      return true
    end
    if O1(q, e) then
      return true
    end
    Sleep(ZO)
  end
  return false
end
local function x1(q)
  if q == nil then
    return nil, nil
  end
  local e = tonumber(q["posX"])
  local W = tonumber(q["posY"])
  if (e == nil or W == nil) and q["pos"] ~= nil then
    e = e or tonumber(q["pos"]["x"])
    W = W or tonumber(q["pos"]["y"])
  end
  return e, W
end
local function f1(q)
  local e, W = x1(q)
  if e == nil or W == nil then
    return nil, nil
  end
  return math["floor"](e / 32), math["floor"](W / 32)
end
local function B1(q, e)
  local W = math["min"](E, K) - 1
  local h = math["max"](E, K) + 1
  return q >= W and (q <= h and math["abs"](e - M) <= 1)
end
local function g1(q, e)
  return q >= G - 1 and (q <= G + 2 and math["abs"](e - Q) <= 1)
end
local function G1(q)
  local e = 0
  for W, h in pairs(Z1()) do
    if tonumber(h["itemid"]) == tonumber(q) then
      local q, W = f1(h)
      if q ~= nil and (W ~= nil and g1(q, W)) then
        e = e + (tonumber(h["amount"]) or 0)
      end
    end
  end
  return e
end
local function Q1(q, e)
  local W = 0
  for h, r in pairs(Z1()) do
    if tonumber(r["itemid"]) == tonumber(q) then
      local h, j = f1(r)
      if h ~= nil and j ~= nil then
        if e or q ~= a or not B1(h, j) then
          W = W + (tonumber(r["amount"]) or 0)
        end
      end
    end
  end
  return W
end
local function E1(q, e)
  return T1(q) + Q1(q, e)
end
local function M1(q)
  q = tonumber(q)
  if q == nil then
    return false
  end
  for e, W in pairs(Z1()) do
    if tonumber(W["id"]) == q then
      return true
    end
  end
  return false
end
local function K1(q, e)
  if not B or F1() ~= g then
    return false
  end
  if not O1(G, Q) and not S1(G, Q) then
    return false
  end
  local W = w1()
  if W == nil or not O1(G, Q) or F1() ~= g then
    return false
  end
  r1(q or "OPEN EZ COOK")
  local h, r = pcall(function()
    return SendPacketRaw(
      false,
      { ["type"] = 3, ["value"] = 18, ["px"] = G + 1, ["py"] = Q, ["x"] = W["posX"], ["y"] = W["posY"] }
    )
  end)
  h = h and r ~= false
  if h then
    Sleep(math["max"](0, e or KO))
  end
  return h and (B and F1() == g), h
end
local X1 = 1300
local function P1(q)
  local e = math["max"](0, math["floor"](tonumber(q) or 0))
  while e > 0 do
    if not B or F1() ~= g then
      return false
    end
    local q = math["min"](100, e)
    Sleep(q)
    e = e - q
  end
  return B and F1() == g
end
local function Y1(q, e)
  local W, h = y1()
  return W ~= nil and (h ~= nil and (math["abs"](W - q) <= 1 and math["abs"](h - e) <= 1))
end
local function n1(q, e, W)
  if not B or F1() ~= g then
    return false
  end
  if not Y1(q["tileX"], q["tileY"]) then
    return false
  end
  for h, r in pairs(Z1()) do
    if tonumber(r["id"]) == q["uid"] and tonumber(r["itemid"]) == tonumber(e) then
      local h, j = x1(r)
      if not h or not j or math["floor"](h / 32) ~= q["tileX"] or math["floor"](j / 32) ~= q["tileY"] then
        return false
      end
      if T1(e) > W then
        return true
      end
      local V, L =
        pcall(SendPacketRaw or sendPacketRaw, false, { ["type"] = 11, ["value"] = q["uid"], ["x"] = h, ["y"] = j })
      if not V or L == false then
        return false
      end
      local s = 0
      while B and (F1() == g and s < xO) do
        if T1(e) > W then
          return true
        end
        Sleep(HO)
        s = s + HO
      end
      return B and (F1() == g and T1(e) > W)
    end
  end
  return false
end
local function R1(q, e, W)
  if q == nil or not B then
    return false
  end
  W = tostring(W or A1(e))
  local h = q["tileX"] == G + 1 and q["tileY"] == Q
  local function r()
    if h and (pO ~= nil and tonumber(e) == tonumber(pO["outputID"])) then
      pO["outputCollected"] = true
    end
    Sleep(mO)
    return true
  end
  if F1() ~= g or not M1(q["uid"]) then
    return false
  end
  local j = T1(e)
  if j >= eO then
    r1("INVENTORY FULL: " .. W)
    return false
  end
  if not P1(dO) then
    return false
  end
  if T1(e) > j then
    return r()
  end
  if not M1(q["uid"]) then
    return false
  end
  s1(true)
  local V, L = q["tileX"], q["tileY"]
  r1("PICKUP EXACT " .. (W .. (" -> " .. (tostring(V) .. ("," .. tostring(L))))))
  local s = true
  if not O1(V, L) then
    s = m1(V, L)
  end
  if s and not Y1(V, L) then
    local q, W = 0, 0
    local h, s = y1()
    while B and (F1() == g and q < AO + xO) do
      if T1(e) > j then
        return r()
      end
      if Y1(V, L) then
        break
      end
      local u, N = y1()
      if u == nil or N == nil then
        break
      end
      if u ~= h or N ~= s then
        W = 0
      else
        W = W + HO
      end
      if W >= X1 then
        break
      end
      h, s = u, N
      Sleep(HO)
      q = q + HO
    end
  end
  if T1(e) > j then
    return r()
  end
  if Y1(V, L) then
    r1("AUTO COLLECT EXACT " .. W)
    if n1(q, e, j) then
      r1("COLLECTED " .. (W .. (" " .. tostring(T1(e)))))
      return r()
    end
  end
  if h and (not O1(V, L) and (T1(e) <= j and (M1(q["uid"]) and (pO ~= nil and not pO["outputCollected"])))) then
    pO["openPathConfirmed"] = false
    pO["ovenCollectPathBlocked"] = true
  end
  r1("PICKUP NOT CONFIRMED: " .. (W .. " - RESCAN"))
  if B and F1() == g then
    P1(math["max"](600, dO))
  end
  return false
end
local function D1(q, e, W)
  local h, r = y1()
  local j = {}
  for V, L in pairs(Z1()) do
    if tonumber(L["itemid"]) == tonumber(q) then
      local V, s = x1(L)
      if V ~= nil and s ~= nil then
        local u = math["floor"](V / 32)
        local N = math["floor"](s / 32)
        local F = true
        if W then
          F = (u == G + 1 and N == Q)
        elseif not e and (q == a and B1(u, N)) then
          F = false
        end
        if F and tonumber(L["id"]) ~= nil then
          local e = 0
          if h ~= nil and r ~= nil then
            e = math["abs"](h - u) + math["abs"](r - N)
          end
          table["insert"](
            j,
            {
              ["uid"] = tonumber(L["id"]),
              ["itemID"] = tonumber(q),
              ["amount"] = tonumber(L["amount"]) or 0,
              ["pixelX"] = V,
              ["pixelY"] = s,
              ["tileX"] = u,
              ["tileY"] = N,
              ["distance"] = e,
            }
          )
        end
      end
    end
  end
  table["sort"](j, function(h, r)
    if e and (tonumber(q) == tonumber(a) and not W) then
      local q = B1(h["tileX"], h["tileY"])
      local e = B1(r["tileX"], r["tileY"])
      if q ~= e then
        return q
      end
    end
    return h["distance"] < r["distance"]
  end)
  return j
end
local function v1(q, e, W, h)
  if not B then
    return false
  end
  W = tostring(W or A1(q))
  h = math["min"](eO, math["max"](1, math["floor"](tonumber(h) or eO)))
  local r = T1(q)
  if r >= h then
    r1("USE INVENTORY " .. (W .. (" " .. (tostring(r) .. (" (need " .. (tostring(h) .. ")"))))))
    return true
  end
  local j = 0
  while B and T1(q) < h do
    if F1() ~= g then
      return false
    end
    r = T1(q)
    r1("SCAN ONLY " .. (W .. (" " .. (tostring(r) .. (" (need " .. (tostring(h) .. ")"))))))
    local V = D1(q, e, false)
    if #V == 0 then
      break
    end
    local L = r
    local s = false
    for r, j in ipairs(V) do
      if not B or F1() ~= g then
        return false
      end
      if T1(q) >= h then
        break
      end
      if M1(j["uid"]) then
        local r = W
        if q == a and (e and B1(j["tileX"], j["tileY"])) then
          r = "Stored Mysterious Chemical"
        end
        local V = R1(j, q, r)
        local u = T1(q)
        if V and u > L then
          s = true
        end
        if u >= h then
          break
        end
      end
    end
    local u = T1(q)
    if u <= L and not s then
      j = j + 1
      if j >= 2 then
        break
      end
    else
      j = 0
    end
    if T1(q) >= h then
      break
    end
    Sleep(oO)
  end
  local V = T1(q)
  r1("CHECKED " .. (W .. (" " .. (tostring(V) .. (" (need " .. (tostring(h) .. ")"))))))
  return V >= h
end
local function a1(q)
  local e
  if q == "M" then
    e = { { n, U, "Y" }, { R, p, "B" }, { D, k, "P" } }
  else
    e = { { a, t, "M" }, { v, i, "G" }, { R, qO, "B" } }
  end
  local W = {}
  local h = true
  for q, e in ipairs(e) do
    local r = T1(e[1])
    W[#W + 1] = e[3] .. (tostring(r) .. ("/" .. tostring(e[2])))
    if r < e[2] then
      h = false
    end
  end
  local r = "BAG " .. (q .. (": " .. table["concat"](W, " ")))
  c1((h and "READY " or "MISSING ") .. r)
  return h
end
local function l1(q, e, W, h)
  local r = T1(q)
  if r >= e then
    r1("BAG READY " .. (h .. (" x" .. (tostring(r) .. (" (need " .. (tostring(e) .. ")"))))))
    return true
  end
  r1("COLLECT MISSING " .. (h .. (" " .. (tostring(r) .. ("/" .. tostring(e))))))
  c1("NEED " .. (h .. (" " .. (tostring(r) .. ("/" .. tostring(e))))))
  local j = v1(q, W, h, e)
  local V = T1(q)
  if not j or V < e then
    r1("WAIT " .. (h .. (" " .. (tostring(V) .. ("/" .. tostring(e))))))
    return false
  end
  return true
end
local function U1()
  if T1(a) < eO then
    return true
  end
  if not B or F1() ~= g then
    return false
  end
  if tO == nil then
    return false
  end
  r1("OVEN M FULL - STORE 200 M FIRST")
  local q = tO(a, "Mysterious Chemical")
  local e = T1(a)
  if not q or e >= eO then
    r1("WAIT M STORAGE BEFORE OVEN PICKUP")
    return false
  end
  r1("M STORED - RETURN TO OVEN FOR M PICKUP")
  return true
end
local function p1(q, e)
  if not B then
    return false
  end
  e = tostring(e or A1(q))
  local W = 0
  while B do
    local h = D1(q, true, true)
    if #h == 0 then
      return true
    end
    if q == a and not U1() then
      return false
    end
    if q == l and T1(l) >= eO then
      if tO == nil then
        return false
      end
      r1("OVEN FUEL FULL - STORE FIRST")
      if not tO(l, "Fuel Pack") or T1(l) >= eO then
        return false
      end
    end
    local r = T1(q)
    local j = false
    r1("EZ COOK GET " .. e)
    for W, h in ipairs(h) do
      if not B then
        return false
      end
      if M1(h["uid"]) then
        local W = T1(q)
        local r = R1(h, q, e)
        local V = T1(q)
        if r and V > W then
          j = true
        end
      end
    end
    local V = T1(q)
    local L = D1(q, true, true)
    if #L == 0 then
      return true
    end
    if V <= r and not j then
      W = W + 1
      if W >= 3 then
        h1("Could not confirm collecting " .. (e .. " from EZ Cook."))
        return false
      end
    else
      W = 0
    end
    Sleep(oO)
  end
  return false
end
local k1
local function t1()
  r1("TAKE M FIRST")
  if not p1(a, "Mysterious Chemical") then
    return false
  end
  r1("TAKE EXTRA Y")
  if not p1(n, "Chemical Y") then
    return false
  end
  r1("TAKE EXTRA B")
  if not p1(R, "Chemical B") then
    return false
  end
  r1("TAKE EXTRA P")
  if not p1(D, "Chemical P") then
    return false
  end
  if not k1() then
    return false
  end
  d1()
  return true
end
local function i1()
  r1("TAKE FUEL FIRST")
  if not p1(l, "Fuel Pack") then
    return false
  end
  r1("TAKE EXTRA M")
  if not p1(a, "Mysterious Chemical") then
    return false
  end
  r1("TAKE EXTRA G")
  if not p1(v, "Chemical G") then
    return false
  end
  r1("TAKE EXTRA B")
  if not p1(R, "Chemical B") then
    return false
  end
  if not k1() then
    return false
  end
  d1()
  return true
end
local function qT()
  local q = { [n] = true, [R] = true, [D] = true, [v] = true, [a] = true, [l] = true }
  local e = {}
  for W, h in pairs(Z1()) do
    local r = tonumber(h["itemid"])
    local j, V = f1(h)
    if r and (q[r] and (j == G + 1 and V == Q)) then
      local q, W = x1(h)
      if q and W then
        table["insert"](
          e,
          { ["uid"] = tonumber(h["id"]), ["itemID"] = r, ["pixelX"] = q, ["pixelY"] = W, ["tileX"] = j, ["tileY"] = V }
        )
      end
    end
  end
  return e
end
k1 = function()
  if not B or F1() ~= g then
    return false
  end
  local q = 0
  local e = 0
  local W = false
  r1("EZ COOK EMPTY GUARD (X+1)")
  while B and (F1() == g and e < SO) do
    local h = qT()
    if #h == 0 then
      q = q + 1
      r1("EZ COOK EMPTY CHECK " .. (tostring(q) .. ("/" .. tostring(zO))))
      if q >= zO then
        W = true
        break
      end
    else
      q = 0
      e = e + 1
      r1("EZ COOK COLLECT " .. (tostring(#h) .. " OBJECT(S)"))
      for q, e in ipairs(h) do
        if not B or F1() ~= g then
          break
        end
        if M1(e["uid"]) then
          if T1(e["itemID"]) >= eO then
            if e["itemID"] == a then
              if not U1() then
                break
              end
            elseif e["itemID"] == l and tO ~= nil then
              r1("OVEN FUEL FULL - STORE FIRST")
              if not tO(l, "Fuel Pack") or T1(l) >= eO then
                break
              end
            else
              r1("EZ COOK BLOCKED: INVENTORY FULL")
              break
            end
          end
          local q = R1(e, e["itemID"], A1(e["itemID"]))
          if not q then
            break
          end
        end
      end
    end
    Sleep(JO)
  end
  if not B or F1() ~= g then
    return false
  end
  if not S1(G, Q) then
    r1("CANNOT RETURN TO COOK DROP TILE")
    return false
  end
  if not W then
    r1("EZ COOK NOT EMPTY - NEXT COOK BLOCKED")
    return false
  end
  r1("EZ COOK EMPTY VERIFIED")
  return true
end
local function eT(q, e, W)
  if not B or F1() ~= g then
    return false
  end
  if pO ~= nil or kO == nil then
    return false
  end
  if kO["blocked"] then
    return false
  end
  Sleep(CO)
  if T1(q) < W then
    r1("LATE DROP ACK: " .. tostring(e))
    return true
  end
  local h = kO["reopenAttempts"] or 0
  if h >= TO then
    kO["blocked"] = true
    r1("COOK DROP STILL REJECTED - MANUAL CHECK")
    h1("Cook ingredient still rejected after one recovery punch. Check the oven before restarting.")
    return false
  end
  r1("COOK DROP REJECTED - TAP OVEN " .. tostring(h + 1))
  local r = K1("OPEN OVEN TO RETRY DROP", KO)
  if not r then
    return false
  end
  kO["reopenAttempts"] = h + 1
  Sleep(MO)
  if not B or F1() ~= g then
    return false
  end
  r1("RETRY SAME INGREDIENT: " .. tostring(e))
  return true
end
local WT = 50
local hT = 250
local rT = 950
local jT = 50
local function VT(q)
  q = tostring(q or "")
  if q ~= I1 then
    I1 = q
    pcall(function()
      editValue("FUEL_dropdebug", q)
    end)
  end
end
local function LT(q, e)
  if not B or F1() ~= g then
    return false
  end
  local W = sendPacket or SendPacket
  if type(W) ~= "function" then
    VT("ERROR: sendPacket unavailable")
    r1("DROP PACKET API UNAVAILABLE")
    return false
  end
  if e <= 0 then
    VT("ERROR: no items to drop")
    return false
  end
  local h = T1(q)
  q1 = true
  e1 = false
  VT("SILENT DROP REQUEST item " .. (tostring(q) .. (" x" .. tostring(e))))
  local r, j = pcall(W, 2, "action|drop\nitemID|" .. tostring(q))
  if not r or j == false then
    q1 = false
    VT("ERROR: silent drop request failed")
    return false
  end
  local V = 0
  while B and (F1() == g and V < rT) do
    if T1(q) < h then
      VT("FAST DROP ACK x" .. tostring(e))
      return true
    end
    if e1 and V >= hT then
      break
    end
    Sleep(WT)
    V = V + WT
  end
  if not B or F1() ~= g then
    return false
  end
  if T1(q) < h then
    VT("FAST DROP ACK x" .. tostring(e))
    return true
  end
  VT("SILENT CONFIRM item " .. (tostring(q) .. (" x" .. tostring(e))))
  local L, s = pcall(
    W,
    2,
    "action|dialog_return\n"
      .. ("dialog_name|drop_item\n" .. ("itemID|" .. (tostring(q) .. ("|\n" .. ("count|" .. (tostring(e) .. "\n"))))))
  )
  if not L or s == false then
    VT("ERROR: silent confirmation failed")
    return false
  end
  VT("SILENT DROP SENT x" .. (tostring(e) .. " / waiting ACK"))
  return true
end
local function sT(q, e, W, h, r)
  local j = r and "STORAGE" or "COOK"
  local V = math["floor"](tonumber(W) or 0)
  local L = math["floor"](tonumber(h) or 0)
  local s = 0
  local u = 0
  local N = tostring(e or A1(q))
  while B and F1() == g do
    local W = T1(q)
    if W <= 0 then
      return true, V, L
    end
    pcall(function()
      editValue("FUEL_dropdest", j .. (" @ " .. (tostring(V) .. ("," .. tostring(L)))))
    end)
    if not O1(V, L) then
      if not S1(V, L) then
        r1("WAIT DROP POSITION " .. (tostring(V) .. ("," .. tostring(L))))
        return false, V, L
      end
    end
    if not O1(V, L) then
      return false, V, L
    end
    local h = math["min"](eO, W)
    r1(j .. (" DROP " .. (N .. (" x" .. tostring(h)))))
    VT(j .. (" @" .. (tostring(V) .. ("," .. (tostring(L) .. (" DROP " .. (N .. (" x" .. tostring(h)))))))))
    local F = LT(q, h)
    if not B or F1() ~= g then
      return false, V, L
    end
    local w = T1(q) < W
    local Z = 0
    if F then
      while not w and (B and (F1() == g and Z < uO)) do
        Sleep(jT)
        Z = Z + jT
        w = T1(q) < W
      end
    end
    if not B or F1() ~= g then
      return false, V, L
    end
    q1 = false
    e1 = false
    if w or T1(q) < W then
      s = 0
      local e = T1(q)
      r1("DROPPED " .. (N .. (" (" .. (tostring(W - e) .. ")"))))
      VT("SUCCESS " .. (N .. (" / inventory " .. (tostring(W) .. (" -> " .. tostring(e))))))
      if e <= 0 then
        return true, V, L
      end
      if GO > 0 then
        Sleep(GO)
      end
    else
      s = s + 1
      r1("DROP NO ACK " .. (tostring(s) .. ("/2 " .. N)))
      VT("NO INVENTORY CHANGE " .. (N .. (" / retry " .. tostring(s))))
      Sleep(CO)
      if T1(q) < W then
        s = 0
      elseif s >= 2 then
        s = 0
        if r then
          u = u + 1
          if u > IO then
            r1("STORAGE FULL - TOO MANY SHIFTS")
            return false, V, L
          end
          V = V - 1
          r1("FULL TILE - SHIFT LEFT " .. tostring(V))
          if not S1(V, L) then
            return false, V, L
          end
        else
          if not eT(q, e, W) then
            return false, V, L
          end
        end
      end
    end
  end
  return false, V, L
end
local function uT(q, e)
  local W = sT(q, e, G, Q, false)
  return W == true
end
tO = function(q, e)
  local W, h, r = sT(q, e, K, X, true)
  if h ~= nil and r ~= nil then
    K = h
    X = r
  end
  return W == true
end
local function NT(q)
  if kO ~= nil and kO["kind"] ~= q then
    r1("UNFINISHED RECIPE DROP - OTHER PHASE BLOCKED")
    return false
  end
  if kO == nil then
    if q == "FUEL" then
      if not iO() then
        return false
      end
    end
    if not a1(q) then
      VT("BLOCKED: INGREDIENT MISSING FROM BACKPACK")
      return false
    end
    VT("CHECK OVEN TILE ONCE")
    if #qT() > 0 then
      c1("OVEN HAS ITEMS - COLLECT BEFORE DROPPING")
      if not k1() then
        VT("BLOCKED: OVEN ITEMS NOT CLEARED")
        return false
      end
      if not a1(q) then
        VT("BLOCKED: BAG CHANGED AFTER OVEN CLEANUP")
        return false
      end
    else
      c1("OVEN EMPTY - READY TO DROP " .. q)
    end
    VT("MOVE TO COOK " .. (tostring(G) .. ("," .. tostring(Q))))
    if not b1(G, Q) then
      VT("WAIT: cannot reach COOK " .. (tostring(G) .. ("," .. tostring(Q))))
      return false
    end
    Sleep(200)
    if not B or F1() ~= g then
      return false
    end
    if q == "FUEL" then
      if T1(a) < t then
        r1("M PICKUP NOT CONFIRMED - NO FUEL DROP")
        return false
      end
      if T1(l) ~= 0 then
        r1("FUEL STILL IN INVENTORY - NO FUEL DROP")
        return false
      end
    end
    c1("BEGIN FULL-STACK DROP " .. q)
    kO = { ["kind"] = q, ["index"] = 1, ["reopenAttempts"] = 0, ["blocked"] = false }
  end
  if kO["blocked"] then
    r1("RECIPE DROP BLOCKED - MANUAL OVEN CHECK")
    return false
  end
  local e
  if q == "M" then
    e = { { n, "Chemical Y" }, { R, "Chemical B" }, { D, "Chemical P" } }
  else
    e = { { a, "Mysterious Chemical" }, { v, "Chemical G" }, { R, "Chemical B" } }
  end
  while B and (F1() == g and (kO ~= nil and kO["index"] <= #e)) do
    local W = e[kO["index"]]
    r1("RECIPE " .. (q .. (" DROP " .. (tostring(kO["index"]) .. ("/" .. tostring(#e))))))
    local h = T1(W[1])
    if h <= 0 then
      VT("WAIT: inventory empty for " .. W[2])
      return false
    end
    VT("INGREDIENT " .. (tostring(kO["index"]) .. ("/3 " .. (W[2] .. (" x" .. tostring(math["min"](h, eO)))))))
    c1("DROP " .. (q .. (" " .. (W[2] .. (" x" .. tostring(math["min"](h, eO)))))))
    if not uT(W[1], W[2]) then
      return false
    end
    kO["index"] = kO["index"] + 1
    kO["reopenAttempts"] = 0
    if kO["index"] <= #e then
      Sleep(math["max"](700, GO))
    end
  end
  if not B or F1() ~= g then
    return false
  end
  kO = nil
  c1("ALL THREE INGREDIENTS DROPPED " .. q)
  return true
end
local function FT()
  return NT("M")
end
local function wT()
  return NT("FUEL")
end
local function ZT(q, e)
  if not B or F1() ~= g then
    return false
  end
  if T1(q) > (e or 0) then
    if pO ~= nil then
      pO["outputCollected"] = true
    end
    return true
  end
  if O1(G + 1, Q) then
    return true
  end
  r1("CHECK OVEN PATH")
  local W = m1(G + 1, Q)
  if not W then
    return false
  end
  local h = 0
  while B and (F1() == g and h < 1000) do
    if T1(q) > (e or 0) then
      if pO ~= nil then
        pO["outputCollected"] = true
      end
      return true
    end
    if O1(G + 1, Q) then
      return true
    end
    Sleep(XO)
    h = h + XO
  end
  return false
end
local function yT()
  if pO == nil or not B or F1() ~= g then
    return false
  end
  local q = pO
  if not q["firstSent"] or not q["openSent"] or q["outputCollected"] then
    return false
  end
  if T1(q["outputID"]) > (q["beforeInventory"] or 0) then
    q["outputCollected"] = true
    return false
  end
  if O1(G + 1, Q) then
    q["openPathConfirmed"] = true
    return false
  end
  local e = q["openRecoveryPunches"] or 0
  if e >= nO then
    if not q["openRetryExhaustedNotice"] then
      q["openRetryExhaustedNotice"] = true
      h1("Oven path still blocked after opening retries. Pausing this recipe for manual inspection; no recook.")
    end
    r1("OVEN PATH BLOCKED - RECOVERY LIMIT")
    Sleep(RO)
    return false
  end
  r1("OPEN MISSED - RECOVER OVEN " .. tostring(e + 1))
  local W, h = K1("RETRY SECOND PUNCH - OPEN EZ COOK", KO)
  if h then
    q["openRecoveryPunches"] = e + 1
    q["pathFailures"] = 0
    q["ovenCollectPathBlocked"] = false
    q["openPathConfirmed"] = false
    Sleep(RO)
  end
  return W
end
local function OT(q, e)
  if pO == nil or pO["outputID"] ~= q then
    return false
  end
  if not B or F1() ~= g then
    return false
  end
  if not pO["firstSent"] then
    if not pO["prePunchWaited"] then
      r1("WAIT AFTER THIRD DROP BEFORE COOK")
      Sleep(QO)
      if not B or F1() ~= g then
        return false
      end
      pO["prePunchWaited"] = true
    end
    pO["beforeInventory"] = T1(q)
    local e, W = K1("FIRST PUNCH - COOK", EO)
    if W then
      pO["firstSent"] = true
    end
    if not e then
      r1("COOK SENT - WAIT TO OPEN; NO RECOOK")
      return false
    end
  end
  if not pO["openSent"] then
    local q, e = K1("SECOND PUNCH - OPEN EZ COOK", KO)
    if e then
      pO["openSent"] = true
    end
    if not q then
      r1("OPEN SENT - WAIT FOR OVEN PATH")
      return false
    end
  end
  return pO["firstSent"] == true and pO["openSent"] == true
end
local function CT()
  if pO == nil then
    return true
  end
  local q = pO["outputID"]
  if not OT(q, pO["label"]) then
    return false
  end
  if not pO["pickupDelayApplied"] then
    r1("WAIT AFTER SECOND PUNCH BEFORE PICKUP")
    Sleep(MO)
    if not B or F1() ~= g then
      return false
    end
    pO["pickupDelayApplied"] = true
  end
  if not pO["openPathConfirmed"] then
    if not ZT(q, pO["beforeInventory"]) then
      pO["pathFailures"] = (pO["pathFailures"] or 0) + 1
      r1("OVEN PATH BLOCKED - VERIFY " .. tostring(pO["pathFailures"]))
      if pO["pathFailures"] >= YO then
        yT()
      else
        Sleep(PO)
      end
      return false
    end
    pO["pathFailures"] = 0
    pO["ovenCollectPathBlocked"] = false
    pO["openPathConfirmed"] = true
  end
  local e
  if q == a then
    e = t1()
  else
    e = i1()
  end
  if not e or not pO["outputCollected"] then
    if pO["ovenCollectPathBlocked"] and not pO["outputCollected"] then
      pO["openPathConfirmed"] = false
      r1("OVEN PICKUP PATH BLOCKED - RECHECK OVEN")
    else
      r1("EZ COOK PICKUP PENDING - WAIT FOR INVENTORY")
    end
    return false
  end
  pO = nil
  d1()
  r1("COOK DONE - REST " .. (tostring(LO) .. "ms"))
  if LO > 0 then
    if not P1(LO) then
      return false
    end
  end
  return true
end
local function IT(q)
  local e, W = {}, {}
  for q, h in ipairs(q) do
    e[h[1]] = h[3]
    W[h[1]] = 0
  end
  for q, h in pairs(Z1()) do
    local r = tonumber(h["itemid"])
    if r ~= nil and e[r] ~= nil then
      local q, j = f1(h)
      if q ~= nil and (j ~= nil and (e[r] or r ~= a or not B1(q, j))) then
        W[r] = W[r] + math["max"](1, tonumber(h["amount"]) or 1)
      end
    end
  end
  return W
end
local function cT(q, e, W)
  if q >= eO then
    return eO
  end
  if q + math["max"](0, e or 0) >= eO then
    return eO
  end
  return W
end
local function TT(q)
  local e = q == "M" and { { n, U, false, "Chemical Y" }, { R, p, false, "Chemical B" }, { D, k, false, "Chemical P" } }
    or { { a, t, true, "Mysterious Chemical" }, { v, i, false, "Chemical G" }, { R, qO, false, "Chemical B" } }
  local W = false
  for q, e in ipairs(e) do
    if T1(e[1]) < e[2] then
      W = true
      break
    end
  end
  if not W and WO[q] then
    return a1(q)
  end
  local h = {}
  for q, e in ipairs(e) do
    h[#h + 1] = e
  end
  if q == "M" and not WO["M"] then
    h[#h + 1] = { v, 0, false, "Chemical G (fuel reserve)", true }
  end
  local r = IT(h)
  for e, W in ipairs(h) do
    if not B or F1() ~= g then
      return false
    end
    local h, j, V, L = W[1], W[2], W[3], W[4]
    local s = W[5] == true
    local u = T1(h)
    local N = r[h] or 0
    local F = cT(u, N, j)
    if s and F < eO then
      F = u
    end
    if F > u then
      c1(
        "BATCH " .. (
            q .. (" " .. (L .. (" " .. (tostring(u) .. ("/" .. (tostring(F) .. (" | ground " .. tostring(N))))))))
          )
      )
      r1("BATCH GET " .. (L .. (" -> " .. tostring(F))))
      v1(h, V, L, F)
    end
    local w = T1(h)
    if not s and w < j then
      c1("WAIT " .. (L .. (" " .. (tostring(w) .. ("/" .. tostring(j))))))
      return false
    end
  end
  WO[q] = true
  return a1(q)
end
local function AT(q, e)
  local W = T1(q)
  if W < 1 then
    return true
  end
  local h = tO(q, e)
  if not h then
    return false
  end
  if tonumber(q) == tonumber(l) and T1(l) == 0 then
    local q = bO
    r1("FUEL STORED - WAIT " .. (tostring(q) .. "ms"))
    c1("FUEL STORAGE COMPLETE - PAUSE BEFORE NEXT INGREDIENT")
    if q > 0 and not P1(q) then
      return false
    end
    if not B or F1() ~= g then
      return false
    end
    r1("FUEL STORAGE SETTLED - CHECK INGREDIENTS")
  end
  return true
end
iO = function()
  if not B or F1() ~= g then
    return false
  end
  local q = T1(l)
  if q == 0 then
    return true
  end
  r1("STORE " .. (tostring(q) .. " FUEL BEFORE NEXT COOK"))
  if not AT(l, "Fuel Pack") then
    r1("FUEL STORAGE FAILED - NO NEW RECIPE")
    return false
  end
  local e = 0
  while B and (F1() == g and e <= uO) do
    if T1(l) == 0 then
      d1()
      r1("FUEL INV 0 - READY FOR RECIPE")
      return true
    end
    Sleep(100)
    e = e + 100
  end
  r1("FUEL NOT ZERO - NO NEW RECIPE")
  return false
end
local function HT()
  if T1(a) >= eO then
    r1("STORE M CHEM")
    return AT(a, "Mysterious Chemical")
  end
  return true
end
local function oT()
  if T1(l) >= eO then
    r1("STORE FUEL")
    return AT(l, "Fuel Pack")
  end
  return true
end
local function dT(q, e, W)
  local h = T1(q)
  if h >= e then
    return true
  end
  return h + Q1(q, W) >= e
end
local function mT()
  return dT(n, U, false) and (dT(R, p, false) and dT(D, k, false))
end
local function bT()
  return dT(a, t, true) and (dT(v, i, false) and dT(R, qO, false))
end
local function JT()
  if not B or F1() ~= g then
    return nil, nil
  end
  local q = GetObjectList or getObjectList
  if type(q) ~= "function" then
    return nil, nil
  end
  local e, W = pcall(q)
  if not e or type(W) ~= "table" then
    return nil, nil
  end
  local h = 0
  for q, e in pairs(W) do
    if e and tonumber(e["itemid"]) == tonumber(a) then
      h = h + math["max"](1, tonumber(e["amount"]) or 1)
    end
  end
  return T1(a), h
end
local function zT(q)
  B = false
  u1(false)
  pcall(function()
    editValue("FUEL_fastdrop", "OFF")
  end)
  s1(false)
  q1 = false
  e1 = false
  local e = editToggle or EditToggle
  if e ~= nil then
    pcall(e, "FUEL_enable", false)
  end
  j1("STOPPED")
  r1("STOPPED")
  d1()
  if q ~= nil and q ~= "" then
    h1(q)
  end
end
function onVariant(q, e)
  if q ~= nil and (q["v1"] == "OnDialogRequest" and type(q["v2"]) == "string") then
    if B and q["v2"]:find("drop_item", 1, true) then
      if q1 then
        e1 = true
      end
      return true
    end
  end
  return false
end
local ST = d
local xT = false
local fT = 0
local BT = false
local gT = false
local GT = false
local function QT(q)
  local e = tostring(q or "")
  pcall(function()
    editValue("FUEL_licensestatus", e)
  end)
end
local function ET(q)
  q = tostring(q or "")
  q = q:gsub("\n", "\r\n")
  q = q:gsub("([^%w%-_%.~])", function(q)
    return string["format"]("%%%02X", string["byte"](q))
  end)
  return q
end
local function MT()
  local q = ""
  if type(getDiscordID) == "function" then
    local e, W = pcall(getDiscordID)
    if e and W ~= nil then
      q = tostring(W)
    end
  elseif getDiscordID ~= nil then
    q = tostring(getDiscordID)
  end
  q = ((tostring(q or "")):gsub("^%s+", "")):gsub("%s+$", "")
  if q == "" or q == "nil" or q == "0" then
    local e = GetLocal or getLocal
    if e ~= nil then
      local W, h = pcall(e)
      if W and (h ~= nil and h["name"] ~= nil) then
        q = tostring(h["name"])
        q = (q:gsub("^%s+", "")):gsub("%s+$", "")
      end
    end
  end
  return q
end
local function KT(q, e)
  if xT then
    return false
  end
  xT = true
  local W = m(ST)
  ST = W
  if not b(W) then
    QT("INVALID KEY FORMAT")
    xT = false
    if not q then
      h1("License must be 1 letter + 7 numbers, for example A1234567.")
    end
    return false
  end
  local h = MT()
  if h == "" then
    QT("NO CLIENT ID")
    xT = false
    if not q then
      h1("Could not read a client ID. Enter the game first and try again.")
    end
    return false
  end
  QT("CHECKING...")
  local r = c .. ("?key=" .. (ET(W) .. ("&id=" .. (ET(h) .. ("&product=" .. ET(T))))))
  local j, V, L = pcall(fetch, r)
  if not j then
    QT("SERVER ERROR")
    xT = false
    if not q then
      h1("License server request failed.")
    end
    return false
  end
  if e ~= fT then
    xT = false
    return false
  end
  V = tostring(V or "")
  V = (V:gsub("^%s+", "")):gsub("%s+$", "")
  if V:find("OK|PERMANENT", 1, true) then
    QT("VERIFIED - PERMANENT")
    local e = z(W)
    if e then
      d = W
    end
    xT = false
    if not q then
      h1(e and "License verified and saved." or "License verified. Could not save the key.")
    end
    return true
  end
  local s = V
  local u = "LICENSE CHECK FAILED"
  if s:find("DENY|DISABLED", 1, true) then
    QT("DISABLED")
    u = "License disabled."
  elseif s:find("DENY|WRONG_PRODUCT", 1, true) then
    QT("WRONG PRODUCT")
    u = "This license is for another script."
  elseif s:find("DENY|BOUND_TO_OTHER_USER", 1, true) then
    QT("BOUND TO OTHER USER")
    u = "License is bound to another user."
  elseif s:find("DENY|INVALID_KEY", 1, true) then
    QT("INVALID KEY")
    u = "Invalid license key."
  elseif s:find("DENY|BAD_KEY_FORMAT", 1, true) then
    QT("BAD KEY FORMAT")
    u = "License key format is invalid."
  elseif s:find("DENY|NO_ID", 1, true) then
    QT("NO CLIENT ID")
    u = "Client ID is unavailable."
  elseif s:find("DENY|", 1, true) then
    QT("DENIED")
    u = "License denied by server."
  elseif s == "" then
    QT("NO RESPONSE")
    u = "License server gave no response."
  else
    QT("CHECK FAILED")
    u = "License check failed."
  end
  xT = false
  if not q then
    h1(u)
  end
  return false
end
local function XT(q, e, W)
  if e == "FUEL_prepstatus" then
    if tostring(W or "") ~= C1 then
      pcall(function()
        editValue("FUEL_prepstatus", C1)
      end)
    end
    return
  end
  if e == "FUEL_dropdebug" then
    if tostring(W or "") ~= I1 then
      pcall(function()
        editValue("FUEL_dropdebug", I1)
      end)
    end
    return
  end
  if e == "FUEL_enable" then
    B = (W == true)
    if B then
      if F1() == "" or F1() == "EXIT" then
        zT("Enter your Science Station world first.")
        return
      end
      if G == 0 and Q == 0 then
        zT("Set Cook Position first.")
        return
      end
      if E == 0 and M == 0 then
        zT("Set Storage Position first.")
        return
      end
      if not o1() then
        zT("Could not resolve one or more recipe item IDs.")
        return
      end
      g = F1()
      pO = nil
      vO = 0
      aO = 0
      kO = nil
      WO["M"] = false
      WO["FUEL"] = false
      K = E
      X = M
      s1(true)
      L1("Enable AutoCollect", false)
      L1("Autocollect", false)
      u1(true)
      editValue("FUEL_fastdrop", "ON - SILENT")
      j1("M CHEM")
      r1("STARTING - WAIT FOR WORLD / PLAYER")
      d1()
      h1("Fuel Pack V34: batch 200 ingredients when available; exact-tile pickup and M verification.")
    else
      u1(false)
      editValue("FUEL_fastdrop", "OFF")
      s1(false)
      q1 = false
      e1 = false
      j1("STOPPED")
      r1("STOPPED")
      h1("Fuel Pack Maker stopped.")
    end
    return
  end
  local h = {
    ["FUEL_firstpunchdelay"] = function(q)
      MO = q
    end,
    ["FUEL_prepunchdelay"] = function(q)
      QO = q
    end,
    ["FUEL_openpunchdelay"] = function(q)
      KO = q
    end,
    ["FUEL_dropdelay"] = function(q)
      GO = q
    end,
    ["FUEL_collectdelay"] = function(q)
      mO = q
    end,
    ["FUEL_pickupgap"] = function(q)
      dO = math["max"](350, q)
    end,
    ["FUEL_storepause"] = function(q)
      bO = math["min"](10000, q)
    end,
    ["FUEL_pathpace"] = function(q)
      VO = math["max"](500, q)
    end,
    ["FUEL_recipepause"] = function(q)
      LO = math["max"](500, q)
    end,
    ["FUEL_verifydelay"] = function(q)
      JO = q
    end,
  }
  if h[e] then
    local q = tonumber(W)
    if q ~= nil then
      q = math["max"](0, math["min"](10000, math["floor"](q)))
      h[e](q)
      if e == "FUEL_pickupgap" then
        pcall(function()
          editValue("FUEL_pickupgap", tostring(dO))
        end)
      elseif e == "FUEL_pathpace" then
        pcall(function()
          editValue("FUEL_pathpace", tostring(VO))
        end)
      elseif e == "FUEL_recipepause" then
        pcall(function()
          editValue("FUEL_recipepause", tostring(LO))
        end)
      end
      W1()
    end
    return
  end
  if e == "FUEL_cookx" then
    local q = tonumber(W)
    if q ~= nil then
      G = math["floor"](q)
      W1()
    end
    return
  end
  if e == "FUEL_cooky" then
    local q = tonumber(W)
    if q ~= nil then
      Q = math["floor"](q)
      W1()
    end
    return
  end
  if e == "FUEL_storagex" then
    local q = tonumber(W)
    if q ~= nil then
      E = math["floor"](q)
      K = E
      W1()
    end
    return
  end
  if e == "FUEL_storagey" then
    local q = tonumber(W)
    if q ~= nil then
      M = math["floor"](q)
      X = M
      W1()
    end
    return
  end
  if e == "FUEL_setcook" then
    local q, e = y1()
    if q == nil or e == nil then
      h1("Player position unavailable.")
      return
    end
    G, Q = q, e
    W1()
    editValue("FUEL_cookx", tostring(G))
    editValue("FUEL_cooky", tostring(Q))
    h1(
      "Cook Position = ("
        .. (
          tostring(G) .. (
            ", " .. (tostring(Q) .. ("), EZ Cook at (" .. (tostring(G + 1) .. (", " .. (tostring(Q) .. ").")))))
          )
        )
    )
    return
  end
  if e == "FUEL_setstorage" then
    local q, e = y1()
    if q == nil or e == nil then
      h1("Player position unavailable.")
      return
    end
    E, M = q, e
    K, X = E, M
    W1()
    editValue("FUEL_storagex", tostring(E))
    editValue("FUEL_storagey", tostring(M))
    h1("Storage Position = (" .. (tostring(E) .. (", " .. (tostring(M) .. ")."))))
    return
  end
end
local function PT()
  fT = fT + 1
  if BT then
    BT = false
    GT = true
    pcall(editToggle or EditToggle, "FUEL_enable", false)
    GT = false
    r1("STOPPED")
  end
end
function onValue(q, e, W)
  if e == "FUEL_licensekey" then
    if gT then
      return
    end
    local q = m(W)
    if q ~= ST then
      PT()
      ST = q
      QT("NOT VERIFIED")
    end
    return
  end
  if e == "FUEL_clearlicense" then
    PT()
    ST, d = "", ""
    local q = S()
    gT = true
    pcall(editValue, "FUEL_licensekey", "")
    gT = false
    QT(q and "NOT VERIFIED" or "SAVED KEY COULD NOT BE CLEARED")
    return
  end
  if e == "FUEL_verifylicense" then
    local q = fT
    runThread(function()
      if q == fT then
        KT(false, q)
      end
    end)
    return
  end
  if e ~= "FUEL_enable" then
    return XT(q, e, W)
  end
  if GT then
    return
  end
  if W ~= true then
    PT()
    return XT(q, e, W)
  end
  if B or BT then
    return
  end
  fT = fT + 1
  local h = fT
  BT = true
  r1("CHECKING LICENSE BEFORE START")
  runThread(function()
    local W = 0
    while h == fT and (xT and W < 30000) do
      Sleep(100)
      W = W + 100
    end
    if h ~= fT then
      return
    end
    local r = KT(false, h)
    if h ~= fT then
      return
    end
    if not r then
      PT()
      r1("LICENSE CHECK FAILED - PRESS START TO RETRY")
      return
    end
    BT = false
    XT(q, e, true)
  end)
end
applyHook()
runThread(function()
  u1(false)
  s1(false)
  j1("STOPPED")
  r1("STOPPED")
  d1()
  while true do
    if not B then
      Sleep(200)
    elseif F1() ~= g then
      r1("WAIT ORIGINAL WORLD")
      s1(false)
      while B and F1() ~= g do
        Sleep(500)
      end
      if B then
        Sleep(600)
        s1(true)
        u1(true)
        pcall(function()
          editValue("FUEL_fastdrop", "ON - SILENT")
        end)
      end
    else
      d1()
      if kO ~= nil then
        if kO["blocked"] then
          r1("COOK DROP BLOCKED - MANUAL CHECK")
          Sleep(500)
        else
          local q = kO["kind"]
          local e = false
          if q == "M" then
            e = FT()
          else
            e = wT()
          end
          if e then
            local e = q == "M" and a or l
            pO = {
              ["outputID"] = e,
              ["label"] = q == "M" and "Mysterious Chemical" or "Fuel Pack",
              ["firstSent"] = false,
              ["openSent"] = false,
              ["openPathConfirmed"] = false,
              ["warned"] = false,
            }
            CT()
          end
          Sleep(400)
        end
      elseif pO ~= nil then
        if CT() then
          Sleep(DO)
        else
          Sleep(500)
        end
      elseif P == "M CHEM" then
        if not HT() then
          r1("WAIT M STORAGE")
          Sleep(1200)
        elseif TT("M") then
          vO = 0
          if FT() then
            pO = {
              ["outputID"] = a,
              ["label"] = "Mysterious Chemical",
              ["firstSent"] = false,
              ["openSent"] = false,
              ["openPathConfirmed"] = false,
              ["warned"] = false,
            }
            if CT() then
              HT()
            end
          else
            r1("M DROP WAIT / VERIFY INVENTORY")
            Sleep(1200)
          end
        else
          vO = vO + 1
          r1("M MISSING - WAIT " .. (tostring(UO) .. "ms"))
          if vO >= lO then
            vO = 0
            j1("FUEL")
            r1("NEXT RECIPE - FUEL")
          end
          Sleep(UO)
        end
      elseif P == "FUEL" then
        if not iO() then
          r1("WAIT FUEL STORAGE")
          Sleep(1200)
        elseif TT("FUEL") then
          aO = 0
          if wT() then
            pO = {
              ["outputID"] = l,
              ["label"] = "Fuel Pack",
              ["firstSent"] = false,
              ["openSent"] = false,
              ["openPathConfirmed"] = false,
              ["warned"] = false,
            }
            if CT() then
              oT()
            end
          else
            r1("FUEL DROP WAIT / VERIFY INVENTORY")
            Sleep(1200)
          end
        else
          aO = aO + 1
          r1("FUEL MISSING - WAIT " .. (tostring(UO) .. "ms"))
          Sleep(UO)
          if aO >= lO then
            aO = 0
            if mT() then
              j1("M CHEM")
              r1("M SUPPLY FOUND - RESUME M")
            elseif bT() then
              r1("FUEL MATERIALS IN WORLD - RETRY PICKUP")
            else
              local q, e = JT()
              if q == nil then
                r1("WAIT WORLD M SCAN - NOT FINISHED")
                c1("OBJECT LIST UNAVAILABLE - RETRY")
              elseif q > 0 or e > 0 then
                local W = E1(v, false)
                local h = E1(R, false)
                r1("M REMAINS: BAG " .. (tostring(q) .. (" WORLD " .. tostring(e))))
                c1(
                  "M STILL AVAILABLE: BAG "
                    .. (
                      tostring(q)
                      .. (
                        " WORLD "
                        .. (
                          tostring(e)
                          .. (
                            " | WAIT G "
                            .. (
                              tostring(W) .. ("/" .. (tostring(i) .. (" B " .. (tostring(h) .. ("/" .. tostring(qO))))))
                            )
                          )
                        )
                      )
                    )
                )
              else
                r1("VERIFY NO M - SECOND WORLD SCAN")
                if P1(800) then
                  local q, e = JT()
                  if q == nil then
                    r1("M SCAN UNAVAILABLE - RETRY")
                  elseif q > 0 or e > 0 then
                    r1("LATE M FOUND - RETRY FUEL")
                  elseif mT() or bT() then
                    r1("LATE RECIPE SUPPLY - RETRY")
                  elseif T1(l) > 0 and not AT(l, "Fuel Pack") then
                    r1("WAIT FINAL FUEL STORAGE")
                  else
                    zT("Finished. No M Chemical or complete recipe remains.")
                  end
                end
              end
            end
          end
        end
      else
        j1("M CHEM")
      end
      Sleep(350)
    end
  end
end)
