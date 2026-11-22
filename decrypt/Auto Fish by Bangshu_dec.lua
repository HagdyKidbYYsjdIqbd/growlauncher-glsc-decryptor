local p = "Auto Fishing"
local G =
  "https://script.google.com/macros/s/AKfycbxeBzpOUzvcRDkX-4eR8uioFbAUDsepIQc26kmxUkXt6YOjBxFdVsOE0zzvxYSprl5knA/exec"
local r = "AUTOFISH"
local D
local A = ""
local P = 0
local function v(p)
  return (((tostring(p or "")):gsub("%s+", ""))):upper()
end
pcall(function()
  local p = Preferences
  if type(require) == "function" then
    local G, r = pcall(require, "preferences")
    if G and type(r) == "table" then
      p = r
    end
  end
  if type(p) ~= "table" or type(p["new"]) ~= "function" then
    return
  end
  D = p:new("AutoFishingLicense")
  D:load()
  A = v(D:get("license_key", ""))
end)
local function W(p)
  if not D then
    return false
  end
  return pcall(function()
    D:set("license_key", p)
    D:save()
  end)
end
local U = { ["AF_normal"] = "Normal", ["AF_ice"] = "Ice Crust Block", ["AF_uranium"] = "Uranium" }
local B, J = -1, "AF_normal"
local L = 2914
local h, T = false, false
local g, Q = -1, -1
local R, F = "", -1
local a
pcall(function()
  local p = Preferences
  if type(require) == "function" then
    local G, r = pcall(require, "preferences")
    if G and type(r) == "table" then
      p = r
    end
  end
  if type(p) ~= "table" or type(p["new"]) ~= "function" then
    return
  end
  a = p:new("AutoFishingSelectionsV1")
  a:load()
  local G = a:get("mode", J)
  if U[G] then
    J = G
  end
  if a:get("direction", "left") == "right" then
    B = 1
  end
  local r = math["tointeger"](tonumber(a:get("baitID", "2914")) or 0)
  if r and (r >= 1 and r <= 65535) then
    L = r
  end
  h = a:get("autoBait", "off") == "on"
  T = a:get("autoTool", "off") == "on"
  g = math["tointeger"](tonumber(a:get("fishDropX", "-1")) or -1) or -1
  Q = math["tointeger"](tonumber(a:get("fishDropY", "-1")) or -1) or -1
  R = tostring(a:get("shiftedDropWorld", ""))
  F = math["tointeger"](tonumber(a:get("shiftedDropX", "-1")) or -1) or -1
end)
if J ~= "AF_normal" then
  T = true
end
local function i()
  if not a then
    return
  end
  pcall(function()
    a:set("mode", J)
    a:set("direction", B == 1 and "right" or "left")
    a:set("autoBait", h and "on" or "off")
    a:set("autoTool", T and "on" or "off")
    a:set("baitID", tostring(L))
    a:set("fishDropX", tostring(g))
    a:set("fishDropY", tostring(Q))
    a:set("shiftedDropWorld", R)
    a:set("shiftedDropX", tostring(F))
    a:save()
  end)
end
local y = UserInterface["new"](p, "Water")
y:addLabelApp(p, "Water")
y:addInputString("License Key", A, "A1234567", "A1234567", nil, "AF_licensekey")
y:addButton("Verify License", "AF_verifylicense")
y:addButton("Clear Saved License", "AF_clearlicense")
y:addDisplayList("License Status", "NOT VERIFIED", "AF_licensestatus")
y:addToggle("Start / Stop", false, "AF_start")
y:addToggle("Auto Collect Perfect Fish", false, "AF_perfect")
local z = y:addDialog("Perfect Fish Settings", "Drop tile and protected 5x5 area", {})
y:addChildInputInt(z["menu"], "Drop X", tostring(g), "X", "-1", nil, "AF_fishdropx")
y:addChildInputInt(z["menu"], "Drop Y", tostring(Q), "Y", "-1", nil, "AF_fishdropy")
y:addChildButton(z["menu"], "Drop Position = Current Tile", "AF_setfishdrop")
local O = y:addDialog("Mode", "Choose a fishing mode", {})
y:addChildToggle(O["menu"], U["AF_normal"], J == "AF_normal", "AF_normal")
y:addChildToggle(O["menu"], U["AF_ice"], J == "AF_ice", "AF_ice")
y:addChildToggle(O["menu"], U["AF_uranium"], J == "AF_uranium", "AF_uranium")
y:addDisplayList("Selected Mode", U[J], "AF_mode_selected")
local M = y:addDialog("Direction", "Choose Left or Right", {})
y:addChildToggle(M["menu"], "Left", B == -1, "AF_direction_left")
y:addChildToggle(M["menu"], "Right", B == 1, "AF_direction_right")
y:addDisplayList("Selected Direction", B == -1 and "Left" or "Right", "AF_direction_selected")
y:addItemPicker("Select Bait", tostring(L), tostring(L), "AF_bait_picker")
local t = L == 2914 and "Wiggly Worm" or tostring(L)
pcall(function()
  local p = growtopia["getItemName"](L)
  if type(p) == "string" and p ~= "" then
    t = p
  end
end)
y:addDisplayList("Selected Bait", t, "AF_bait_selected")
y:addInputInt("Delay After Catch (ms)", "1500", "Delay", "1500", nil, "AF_delay")
y:addToggle("Auto Find Bait at 1 Remaining", h, "AF_auto_bait")
y:addToggle("Auto Hand Drill / Detonator", T, "AF_auto_tool")
y:addDisplayList("Status", "STOPPED", "AF_status")
y:addToggle("Auto Ban New World Joins", false, "AF_autoban")
if type(addCategory) == "function" then
  pcall(addCategory, p, "Water")
end
local q, b = pcall(addIntoModule, y:generateJSON(), p)
if not q or b == false then
  pcall(function()
    growtopia["notify"]("Auto Fishing menu could not be created.")
  end)
end
local k = 20
local e = 5000
local w, V, m = false, false, 0
local j, S = false, false
local d, C = nil, ""
local x, Y
local Z
local l = false
local E
local n
local function X(p, ...)
  if type(p) ~= "function" then
    return nil
  end
  local G, r = pcall(p, ...)
  if G then
    return r
  end
end
local function K(p)
  p = tostring(p or "")
  p = p:gsub("\n", "\r\n")
  p = p:gsub("([^%w%-_%.~])", function(p)
    return string["format"]("%%%02X", string["byte"](p))
  end)
  return p
end
local function u()
  local p = ""
  if type(getDiscordID) == "function" then
    local G, r = pcall(getDiscordID)
    if G and r ~= nil then
      p = tostring(r)
    end
  elseif getDiscordID ~= nil then
    p = tostring(getDiscordID)
  end
  p = ((tostring(p or "")):gsub("^%s+", "")):gsub("%s+$", "")
  if p == "" or p == "nil" or p == "0" then
    local G = GetLocal or getLocal
    if G ~= nil then
      local r, D = pcall(G)
      if r and (D ~= nil and D["name"] ~= nil) then
        p = tostring(D["name"])
        p = (p:gsub("^%s+", "")):gsub("%s+$", "")
      end
    end
  end
  if p == "nil" or p == "0" then
    return ""
  end
  return p
end
local function f(p)
  X(editValue, "AF_licensestatus", p)
end
local c = {
  ["DISABLED"] = { "DISABLED", "License disabled." },
  ["WRONG_PRODUCT"] = { "WRONG PRODUCT", "This license is for another script." },
  ["BOUND_TO_OTHER_USER"] = { "BOUND TO OTHER USER", "License is bound to another user." },
  ["INVALID_KEY"] = { "INVALID KEY", "Invalid license key." },
  ["BAD_KEY_FORMAT"] = { "BAD KEY FORMAT", "License key format is invalid." },
  ["NO_ID"] = { "NO CLIENT ID", "Client ID is unavailable." },
}
local function s(p)
  if not p:match("^[A-Z]%d%d%d%d%d%d%d$") then
    return false, "INVALID KEY FORMAT", "License must be 1 letter + 7 numbers, for example A1234567."
  end
  local D = u()
  if D == "" then
    return false, "NO CLIENT ID", "Could not read a client ID. Enter the game first and try again."
  end
  local A = G .. ("?key=" .. (K(p) .. ("&id=" .. (K(D) .. ("&product=" .. K(r))))))
  local P, v = pcall(fetch, A)
  if not P then
    return false, "SERVER ERROR", "License server request failed."
  end
  v = (tostring(v or "")):match("^%s*(.-)%s*$")
  local W = v:match("DENY|([A-Z_]+)")
  if W then
    local p = c[W]
    if p then
      return false, p[1], p[2]
    end
    return false, "DENIED", "License denied by server."
  end
  if v:find("OK|PERMANENT", 1, true) then
    return true, "VERIFIED - PERMANENT"
  end
  if v == "" then
    return false, "NO RESPONSE", "License server gave no response."
  end
  return false, "CHECK FAILED", "License check failed."
end
local function I(p)
  if C == p then
    return
  end
  C = p
  X(editValue, "AF_status", p)
end
local function N(p)
  return (w or V) and m == p
end
local function H(p)
  S = true
  X(EditToggle or editToggle, p, false)
  S = false
end
local function o()
  if l then
    l = false
    X(editToggle or EditToggle, "ModFly", false)
  end
end
local function pd(p)
  local G = V and "AF_perfect" or "AF_start"
  local r = V
  w, V = false, false
  if r then
    X(editToggle or EditToggle, "ModFly", false)
  end
  o()
  m = m + 1
  d = nil
  Z = nil
  E = nil
  I(p)
  H(G)
end
local function Gd()
  pd("NO VALID POSITION TO FISH")
  X(growtopia and growtopia["notify"], "There is no valid position to fish.")
end
local function rd()
  return (tostring(X(GetWorldName or getCurrentWorldName) or "")):upper()
end
local function Dd()
  local p = X(GetLocal or getLocal)
  if p and (type(p["posX"]) == "number" and type(p["posY"]) == "number") then
    return p, math["floor"](p["posX"] / 32), math["floor"](p["posY"] / 32)
  end
end
local function Ad(p, G)
  return X(GetTile or getTile or (tile and tile["getTile"]), p, G)
end
local function Pd()
  return X(GetObjectList or getObjectList or (growtopia and growtopia["getWorldObjects"]))
end
local function vd(p)
  local G = X(growtopia and growtopia["checkInventoryCount"], p)
  if G ~= nil then
    return tonumber(G)
  end
  local r = X(GetInventory or getInventory)
  if not r then
    return nil
  end
  for G, r in pairs(r) do
    if tonumber(r["id"]) == p then
      return tonumber(r["amount"])
    end
  end
  return 0
end
local function Wd(p)
  local G = p["pos"]
  local r = tonumber(G and G["x"] or p["posX"])
  local D = tonumber(G and G["y"] or p["posY"])
  if r and D then
    return r, D
  end
end
local function Ud(p)
  local G, r = {}, {}
  for p, D in pairs(p) do
    local A, P = Wd(D)
    if not A then
      return nil
    end
    local v = string["format"]("%d,%d", A // 32, P // 32)
    G[v] = (G[v] or 0) + 1
    if G[v] > k then
      r[v] = true
    end
  end
  return r
end
local function Bd(p, G)
  return string["format"]("%d,%d", p, G)
end
local function Jd(p, G, r, D)
  if not p then
    return false
  end
  local A = math["tointeger"](tonumber(p["flag"] or p["flags"]) or 0) or 0
  if (A & 1024) == 0 then
    return false
  end
  local P = tonumber(p["fg"])
  if G["requiredBlock"] then
    return P == G["requiredBlock"] or (G["prepared"] and G["prepared"][Bd(r, D)] == P)
  end
  return P ~= G["iceBlock"] and P ~= G["uraniumBlock"]
end
local function Ld(p)
  return p and tonumber(p["fg"]) == 6
end
local function hd(p, G, r, D)
  local A, P = p + r["dir"], G + 1
  return not Ld(Ad(p, G)) and (not Ld(Ad(A, P)) and (not D[Bd(p, G)] and (not D[Bd(A, P)] and Jd(Ad(A, P), r, A, P))))
end
local function Td(p, G, r, D)
  if not N(r) or rd() ~= D["world"] then
    return false
  end
  local A, P, v = Dd()
  if P == p and v == G then
    return true
  end
  if type(FindPath or findPath) ~= "function" then
    return false
  end
  local W = pcall(FindPath or findPath, p, G)
  if not W then
    return false
  end
  for A = 1, 40, 1 do
    Sleep(200)
    if not N(r) or rd() ~= D["world"] then
      return false
    end
    A, P, v = Dd()
    if P == p and v == G then
      return true
    end
  end
  return false
end
local function gd(p, G, r, D, A)
  local P = {}
  local v = X(GetTiles or getTiles)
  if not v then
    return false
  end
  for G, v in pairs(v) do
    if v["x"] and (v["y"] and Jd(v, p, v["x"], v["y"])) then
      local G, W = v["x"] - p["dir"], v["y"] - 1
      local U = Ad(G, W)
      if U and (U["collidable"] ~= true and (not p["skipped"][Bd(G, W)] and hd(G, W, p, r))) then
        P[#P + 1] = { ["x"] = G, ["y"] = W, ["distance"] = math["abs"](D - G) + math["abs"](A - W) }
      end
    end
  end
  table["sort"](P, function(p, G)
    return p["distance"] < G["distance"]
  end)
  for r, D in ipairs(P) do
    if not N(G) or rd() ~= p["world"] then
      return false
    end
    if Td(D["x"], D["y"], G, p) then
      for r = 1, 6, 1 do
        if not N(G) or rd() ~= p["world"] then
          return false
        end
        local A = Pd()
        local P = A and Ud(A)
        local v, W, U = Dd()
        if W == D["x"] and (U == D["y"] and (P and hd(W, U, p, P))) then
          return true, W, U
        end
        Sleep(200)
      end
    end
    p["skipped"][Bd(D["x"], D["y"])] = true
  end
  return false
end
local function Qd(p, G, r, D, A, P, v)
  I("WAITING BEFORE " .. (v .. " PICKUP"))
  Sleep(2000)
  if not N(G) or rd() ~= p["world"] then
    return false
  end
  local W = vd(A)
  if W == nil then
    return false
  end
  if W > P then
    return true
  end
  local U = Pd()
  if not U then
    return false
  end
  local B = {}
  for p, G in pairs(U) do
    local P, v = Wd(G)
    local W = tonumber(G["id"])
    if P and (W and tonumber(G["itemid"]) == A) then
      local p, G = P // 32, v // 32
      B[#B + 1] = { ["id"] = W, ["tx"] = p, ["ty"] = G, ["distance"] = math["abs"](r - p) + math["abs"](D - G) }
    end
  end
  table["sort"](B, function(p, G)
    return p["distance"] < G["distance"]
  end)
  I("PICKING UP " .. v)
  local J = { { 0, 0 }, { -1, 0 }, { 1, 0 }, { 0, -1 }, { -1, -1 }, { 1, -1 } }
  for r, D in ipairs(B) do
    for r, P in ipairs(J) do
      if not N(G) or rd() ~= p["world"] or (vd(A) or W) > W then
        break
      end
      local v, U = D["tx"] + P[1], D["ty"] + P[2]
      local B = Ad(v, U)
      if B and B["collidable"] ~= true then
        Sleep(1500)
        if not N(G) or rd() ~= p["world"] or (vd(A) or W) > W then
          break
        end
      end
      if B and (B["collidable"] ~= true and Td(v, U, G, p)) then
        if (vd(A) or W) <= W then
          for p, G in pairs(Pd() or {}) do
            if tonumber(G["id"]) == D["id"] and tonumber(G["itemid"]) == A then
              local p, r = Wd(G)
              if p and (math["abs"](p // 32 - v) <= 1 and math["abs"](r // 32 - U) <= 1) then
                X(SendPacketRaw, false, { ["type"] = 11, ["value"] = D["id"], ["x"] = p, ["y"] = r })
              end
              break
            end
          end
          for r = 1, 10, 1 do
            Sleep(200)
            if not N(G) or rd() ~= p["world"] then
              return false
            end
            if (vd(A) or W) > W then
              break
            end
          end
        end
        break
      end
    end
    if not N(G) or rd() ~= p["world"] then
      return false
    end
    if (vd(A) or W) > W then
      break
    end
  end
  I("RETURNING TO FISHING SPOT")
  Sleep(1500)
  if not Td(r, D, G, p) then
    if N(G) and rd() == p["world"] then
      pd("COULD NOT RETURN TO FISHING SPOT")
    end
    return false
  end
  return (vd(A) or W) > W
end
local function Rd(p, G, r, D)
  local A, P = pcall(
    SendPacketRaw,
    false,
    { ["type"] = 3, ["x"] = p["posX"], ["y"] = p["posY"], ["px"] = G, ["py"] = r, ["value"] = D, ["netid"] = 0, ["state"] = 0 }
  )
  return A and P ~= false
end
addHook(function(p)
  local G = d
  if not w or not G or not p then
    return
  end
  if p["type"] == 31 and (tonumber(p["px"]) == G["x"] and tonumber(p["py"]) == G["y"]) then
    local r = tonumber(p["netid"])
    if not G["netID"] or r == G["netID"] then
      G["acknowledged"] = true
    end
  elseif p["type"] == 13 and (tonumber(p["value"]) == G["bait"] and tonumber(p["padding2"]) == 1) then
    G["baitConfirmed"] = true
  elseif p["type"] == 17 and (G["acknowledged"] and G["baitConfirmed"]) then
    local r, D = tonumber(p["x"]), tonumber(p["y"])
    if r and (D and (math["floor"](r / 32) == G["x"] and math["floor"](D / 32) == G["y"])) then
      G["bite"] = true
    end
  end
end, "onGamePacket")
local function Fd()
  x, Y = nil, nil
  H("AF_autoban")
end
local function ad(p)
  if not x or not p or p["v1"] ~= "OnSpawn" or type(p["v2"]) ~= "string" then
    return
  end
  local G = {}
  for p in p["v2"]:gmatch("[^\r\n]+") do
    local r, D = p:match("^([^|]+)|(.+)$")
    if r then
      G[r] = D
    end
  end
  if G["type"] == "local" or rd() ~= x then
    Fd()
    return
  end
  local r = Dd()
  local D = tonumber(G["netID"])
  if not r or not D or D == tonumber(r["netID"] or r["netid"]) then
    return
  end
  local A = string["char"](96) .. "."
  local P = ((G["name"] or "")):gsub(A, "")
  if not P:match("^[A-Za-z0-9_]+$") then
    return
  end
  local v = (tostring(r["name"] or "")):gsub(A, "")
  if P:lower() == v:lower() or Y[P:lower()] then
    return
  end
  Y[P:lower()] = true
  X(SendPacket or sendPacket, 2, "action|input\ntext|/ban " .. P)
end
addHook(function(p)
  ad(p)
  if Z and p then
    local G = p["v1"] == "OnTalkBubble" and p["v3"] or (p["v1"] == "OnConsoleMessage" and p["v2"])
    if type(G) == "string" then
      G = G:lower()
      if
        G:find("too many dropped", 1, true)
        or G:find("drop limit", 1, true)
        or (
          (G:find("can't drop", 1, true) or G:find("cannot drop", 1, true))
          and (G:find("any more", 1, true) or G:find("anymore", 1, true))
        )
      then
        Z["full"] = true
      end
    end
  end
  if
    Z
    and (
      p
      and (
        p["v1"] == "OnDialogRequest"
        and (
          type(p["v2"]) == "string"
          and (
            p["v2"]:find("end_dialog|drop_item|", 1, true)
            and tonumber(p["v2"]:match("embed_data|itemID|(%d+)")) == Z["id"]
          )
        )
      )
    )
  then
    Z["ready"] = true
    return true
  end
  local G = d
  if not w or not G or not p or p["v1"] ~= "OnTalkBubble" then
    return
  end
  if G["netID"] and tonumber(p["v2"]) ~= G["netID"] then
    return
  end
  if type(p["v3"]) ~= "string" then
    return
  end
  if p["v3"]:find("You can't fish here, find an emptier spot!", 1, true) then
    G["crowded"] = true
  elseif G["canDrill"] and p["v3"]:find("You need to drill the ice before you can fish!", 1, true) then
    G["needsDrill"] = true
  end
end, "onVariant")
addHook(function(p)
  if not V or not p or tonumber(p["type"]) ~= 11 then
    return false
  end
  local G = E
  if not G or tonumber(p["value"]) ~= G["uid"] then
    return true
  end
  local r, D, A = Dd()
  return not D or rd() ~= n["world"] or math["abs"](D - G["tx"]) > 1 or math["abs"](A - G["ty"]) > 1
end, "onSendPacketRaw")
local function id(p, G, r, D, A)
  local P = {
    ["x"] = D + p["dir"],
    ["y"] = A + 1,
    ["bait"] = p["bait"],
    ["canDrill"] = p["iceMode"] and p["tool"] > 0,
    ["netID"] = tonumber(r["netID"] or r["netid"]),
  }
  d = P
  if not Rd(r, P["x"], P["y"], p["bait"]) or not N(G) then
    if d == P then
      d = nil
    end
    return false
  end
  p["unresolvedCast"] = true
  I("CAST SENT - WAITING FOR CONFIRMATION")
  local v = 0
  while v < e or (P["acknowledged"] and P["baitConfirmed"]) do
    Sleep(200)
    v = v + 200
    local r, W, U = Dd()
    if not N(G) or rd() ~= p["world"] or not r or W ~= D or U ~= A then
      d = nil
      return false
    end
    if P["crowded"] then
      p["unresolvedCast"] = false
      d = nil
      return false, false, true
    end
    if P["needsDrill"] then
      p["unresolvedCast"] = false
      d = nil
      return false, true
    end
    if P["acknowledged"] and P["baitConfirmed"] then
      I("WAITING FOR BITE")
    end
    if P["bite"] then
      d = nil
      if not hd(D, A, p, {}) then
        return false
      end
      local G = Rd(r, D + p["dir"], A + 1, p["bait"])
      if G then
        p["unresolvedCast"] = false
      end
      return G
    end
  end
  d = nil
  return false
end
local function yd(p, G, r, D)
  local A = tonumber(X(getValue, 1, "AF_" .. p))
  return math["max"](r, math["min"](D, math["floor"](A or G)))
end
local function zd(p)
  if type(p) ~= "string" or p == "" then
    return nil
  end
  local G, r = pcall(function()
    if type(findItemID) == "function" then
      return findItemID(p)
    end
    if growtopia ~= nil and type(growtopia["getItemID"]) == "function" then
      return growtopia["getItemID"](p)
    end
    return nil
  end)
  if G and (tonumber(r) ~= nil and tonumber(r) > 0) then
    return math["floor"](tonumber(r))
  end
  return nil
end
local function Od(p)
  if type(p) == "number" then
    return math["floor"](p)
  end
  if type(p) == "string" then
    local G = tonumber(p)
    if G ~= nil and G > 0 then
      return math["floor"](G)
    end
    local r = zd(p)
    if r ~= nil then
      return r
    end
    local D = p:match("[Ii][Tt][Ee][Mm][Ii]?[Dd]?[^%d]*(%d+)")
    if D == nil then
      D = p:match("(%d+)")
    end
    if D ~= nil then
      local p = tonumber(D)
      if p ~= nil and p > 0 then
        return math["floor"](p)
      end
    end
    return nil
  end
  if type(p) == "table" then
    local G = { p["id"], p["itemid"], p["itemID"], p["value"], p["item"], p["name"], p["itemName"], p["selected"] }
    for p, G in pairs(G) do
      local r = Od(G)
      if r ~= nil and r > 0 then
        return r
      end
    end
  end
  return nil
end
local function Md(p)
  local G = Od(p)
  if not G or G < 1 or G > 65535 then
    return false
  end
  if L ~= G then
    L = G
    i()
  end
  local r = X(growtopia and growtopia["getItemName"], G)
  X(editValue, "AF_bait_selected", r or tostring(G))
  return true
end
local function td(p, G)
  if R == p and (F >= 0 and F <= G) then
    return F
  end
  return G
end
local function qd()
  local p = {}
  for G, r in ipairs({
    { "Goldfish", 15 },
    { "Catfish", 30 },
    { "Dogfish", 50 },
    { "Bass", 70 },
    { "Gar", 90 },
    { "Mahi Mahi", 120 },
    { "Sunfish", 160 },
    { "Stonefish", 160 },
    { "Sand Shark", 200 },
    { "Whale", 200 },
    { "Dragon Turtle", 200 },
    { "Dungeonist Crab", 100 },
    { "Dungeness Crab", 100 },
    { "Lobster", 150 },
    { "Crawdad", 50 },
    { "Alaskan King Crab", 200 },
    { "Purple Shore Crab", 100 },
    { "Hermit Crab", 200 },
    { "Maidmare Fish", 160 },
    { "Weird Manta Ray", 190 },
    { "Double-Headed Angel-Devil Fish", 60 },
    { "Cuttlefish", 120 },
    { "Alpha Great White Shark", 190 },
    { "Alpha the Great White Shark", 190 },
    { "Absolutely Real Elephant Fish", 60 },
    { "Real Elephant Fish", 60 },
    { "Ghost Fish", 200 },
    { "Skeletal Shark", 200 },
    { "Demon Angler", 200 },
    { "Swedish Fish", 180 },
    { "Gingerbread Fish", 150 },
    { "Neon Squid", 200 },
    { "Antarctic Icefish", 120 },
    { "Mr. Narwhal", 200 },
    { "Glass Piglet Squid", 50 },
    { "Rainbowfish", 150 },
    { "Totally Legit Bunnyfish", 150 },
    { "Axolotl", 150 },
    { "Pineapple Fish", 150 },
    { "Firefin", 150 },
    { "Koi Fish", 150 },
    { "Turkey Fish", 150 },
    { "Mutant Fish", 150 },
    { "Orca", 150 },
    { "Seahorse", 150 },
    { "Picasso Triggerfish", 150 },
  }) do
    local D = zd(r[1])
    if D then
      p[D] = r[2]
    end
  end
  return p
end
local bd = { 3584, 8968, 5618, 5624, 5602, 5614, 8252, 11052, 5616, 3020 }
local function kd(p, G)
  if g >= 0 and (Q >= 0 and Ad(td(p, g), Q)) then
    return true
  end
  H(G)
  I("SET STORAGE POSITION BEFORE STARTING")
  X(growtopia and growtopia["notify"], "You need to set your storage position before starting.")
  return false
end
local function ed()
  local p, G, r = Dd()
  local D = rd()
  if not G or D == "" or D == "EXIT" then
    pd("ENTER YOUR FISHING WORLD FIRST")
    return
  end
  if J == "AF_ice" and not kd(D, "AF_start") then
    return
  end
  local A = zd("Ice Crust Block")
  local P = zd("Uranium Block")
  local v
  if J == "AF_ice" then
    v = A
  end
  if J == "AF_uranium" then
    v = P
  end
  if J ~= "AF_normal" and not v then
    pd("COULD NOT FIND THE SELECTED MODE'S BLOCK ID")
    return
  end
  n = {
    ["world"] = D,
    ["dir"] = B,
    ["startDirection"] = B,
    ["requiredBlock"] = v,
    ["dropX"] = g,
    ["dropY"] = Q,
    ["activeDropX"] = td(D, g),
    ["iceBlock"] = A,
    ["uraniumBlock"] = P,
    ["bait"] = L,
    ["iceMode"] = J == "AF_ice",
    ["autoDropFish"] = J == "AF_ice" and bd or nil,
    ["delay"] = yd("delay", 1500, 0, 60000),
    ["autoBait"] = h,
    ["tool"] = T and (J ~= "AF_normal" and zd(J == "AF_ice" and "Hand Drill" or "Nuclear Detonator")) or 0,
    ["skipped"] = {},
    ["toolUsed"] = {},
    ["prepared"] = {},
  }
  m = m + 1
  w = true
end
local function wd()
  local p = rd()
  local G, r, D = Dd()
  if not r or p == "" or p == "EXIT" then
    H("AF_perfect")
    I("ENTER A WORLD BEFORE COLLECTING FISH")
    return
  end
  if not kd(p, "AF_perfect") then
    return
  end
  local A = qd()
  if next(A) == nil then
    H("AF_perfect")
    I("COULD NOT RESOLVE PERFECT FISH ITEM IDS")
    return
  end
  local P = editToggle or EditToggle
  local v, W = pcall(P, "ModFly", true)
  if not v or W == false then
    H("AF_perfect")
    I("COULD NOT ENABLE MODFLY FOR PERFECT FISH")
    return
  end
  X(P, "Enable AutoCollect", false)
  X(P, "Autocollect", false)
  n = { ["world"] = p, ["perfectWeights"] = A, ["skippedFish"] = {}, ["dropX"] = g, ["dropY"] = Q, ["activeDropX"] = td(
    p,
    g
  ) }
  m = m + 1
  V = true
end
local Vd, md
local jd = false
local function Sd(p)
  if not Vd then
    return
  end
  local G = Vd["alias"]
  Vd = nil
  H(G)
  I(p)
end
local function dd(p)
  p["key"] = A
  p["revision"] = P
  md = p
  if jd then
    return
  end
  jd = true
  runThread(function()
    while md do
      local p = md
      md = nil
      if p["revision"] == P and (not p["alias"] or Vd == p) then
        f("CHECKING...")
        local G, r, D = s(p["key"])
        if p["revision"] == P then
          f(r)
          if G then
            local G = W(p["key"])
            if p["manual"] then
              X(
                growtopia and growtopia["notify"],
                G and "License verified and saved." or "License verified. Could not save it."
              )
            end
          elseif p["manual"] or Vd == p then
            X(growtopia and growtopia["notify"], D)
          end
          if Vd == p then
            Vd = nil
            if not G then
              H(p["alias"])
              I("LICENSE NOT VALID - NOT STARTED")
            else
              I("STARTING")
              local G = p["alias"] == "AF_start" and ed or wd
              local r, D = pcall(G)
              if not r then
                pd("START FAILED: " .. tostring(D))
                if p["alias"] == "AF_perfect" then
                  H(p["alias"])
                end
              end
            end
          end
        end
      end
    end
    jd = false
  end)
end
local function Cd(p, G)
  if S then
    return
  end
  local r = p == "AF_start" and w or p == "AF_perfect" and V
  if G == false then
    if Vd and Vd["alias"] == p then
      Sd("STOPPED")
    elseif r then
      pd("STOPPED")
    end
  elseif G == true and not r then
    if Vd and Vd["alias"] == p then
      return
    end
    if w or V or j or Vd then
      H(p)
      local G = p == "AF_start" and "Auto Fishing" or "Perfect Fish Collection"
      X(growtopia and growtopia["notify"], "Turn both modes off before starting " .. (G .. "."))
    else
      Vd = { ["alias"] = p }
      I("CHECKING LICENSE BEFORE START")
      dd(Vd)
    end
  end
end
local xd = false
local function Yd(p)
  if B ~= p then
    B = p
    i()
  end
  xd = true
  local G = editToggle or EditToggle
  X(G, "AF_direction_left", B == -1)
  X(G, "AF_direction_right", B == 1)
  xd = false
  X(editValue, "AF_direction_selected", B == -1 and "Left" or "Right")
end
local Zd = false
local function ld()
  T = true
  Zd = true
  X(editToggle or EditToggle, "AF_auto_tool", true)
  Zd = false
end
local Ed = false
local function nd(p)
  if J ~= p then
    J = p
    if J ~= "AF_normal" then
      ld()
    end
    i()
  end
  Ed = true
  for p in pairs(U) do
    X(editToggle or EditToggle, p, p == J)
  end
  Ed = false
  X(editValue, "AF_mode_selected", U[J])
end
addHook(function(p, G, r)
  if G == "AF_direction_left" or G == "AF_direction_right" then
    if xd then
      return
    end
    local p = G == "AF_direction_left" and -1 or 1
    if r == true or p == B then
      Yd(p)
    end
    return
  end
  if U[G] then
    if Ed then
      return
    end
    if r == true then
      nd(G)
    elseif G == J then
      nd(J)
    end
    return
  end
  if G == "AF_start" or G == "AF_perfect" then
    Cd(G, r)
    return
  end
  if G == "AF_licensekey" then
    local p = v(r)
    if p ~= A then
      A = p
      P = P + 1
      Sd("STOPPED - LICENSE CHANGED")
      f("NOT VERIFIED")
    end
    return
  end
  if G == "AF_verifylicense" then
    if not Vd then
      dd({ ["manual"] = true })
    end
    return
  end
  if G == "AF_clearlicense" then
    A = ""
    P = P + 1
    Sd("STOPPED")
    local p = W("")
    X(editValue, "AF_licensekey", "")
    f("NOT VERIFIED")
    X(growtopia and growtopia["notify"], p and "Saved license cleared." or "Could not update saved license storage.")
    return
  end
  if G == "AF_fishdropx" or G == "AF_fishdropy" then
    local p = math["tointeger"](tonumber(r) or -1) or -1
    local D, A = g, Q
    if G == "AF_fishdropx" then
      g = p
    else
      Q = p
    end
    if g ~= D or Q ~= A then
      R, F = "", -1
    end
    i()
    return
  end
  if G == "AF_setfishdrop" then
    local p, G, r = Dd()
    if G then
      g, Q = G, r
      R, F = "", -1
      i()
      X(editValue, "AF_fishdropx", tostring(G))
      X(editValue, "AF_fishdropy", tostring(r))
    end
    return
  end
  if G == "AF_autoban" then
    if S then
      return
    end
    if r == true then
      local p = rd()
      if p == "" or p == "EXIT" or not Dd() then
        Fd()
        X(growtopia and growtopia["notify"], "Enter a world before enabling Auto Ban.")
      else
        x, Y = p, {}
      end
    else
      x, Y = nil, nil
    end
    return
  end
  if G == "AF_bait_picker" then
    Md(r)
    return
  end
  if G == "AF_auto_bait" then
    h = r == true
    i()
    return
  end
  if G == "AF_auto_tool" then
    if Zd then
      return
    end
    if J ~= "AF_normal" and r ~= true then
      ld()
      X(growtopia and growtopia["notify"], "You need a Hand Drill / Detonator to fish in the selected mode.")
      return
    end
    T = r == true
    i()
    return
  end
end, "onValue")
if type(setOnValue) == "function" then
  pcall(setOnValue, "AF_bait_picker", function(...)
    for p = select("#", ...), 1, -1 do
      if Md(select(p, ...)) then
        return
      end
    end
  end)
end
local function Xd(p, G, r, D)
  local function A(p)
    local G = math["tointeger"](tonumber(p["flag"] or p["flags"]) or 0) or 0
    return (G & 1024) ~= 0
  end
  local P = Ad(r, D)
  if not P or Ld(P) then
    return false
  end
  if not A(P) then
    return true
  end
  local v = zd("Water Bucket")
  if not v then
    return false
  end
  I("DRAINING PREVIOUS FISHING TILE")
  Sleep(200)
  local W, U, B = Dd()
  if not N(G) or rd() ~= p["world"] or not W or U + p["dir"] ~= r or B + 1 ~= D then
    return false
  end
  P = Ad(r, D)
  if not P or Ld(P) then
    return false
  end
  if not A(P) then
    return true
  end
  if not Rd(W, r, D, v) then
    return false
  end
  for v = 1, 15, 1 do
    Sleep(200)
    if not N(G) or rd() ~= p["world"] then
      return false
    end
    P = Ad(r, D)
    if P and not A(P) then
      return true
    end
  end
  return false
end
local function Kd(p, G, r, D)
  local A = p["dir"]
  local P, v = r - A, D
  local function W(p)
    return Ld(Ad(p, v)) or Ld(Ad(p, v + 1)) or Ld(Ad(p + A, v + 1))
  end
  local U = r - 2 * A
  if Ld(Ad(P, D)) then
    P = P - 2 * A
  elseif Ld(Ad(U, D)) then
    P = U - 2 * A
  elseif W(P) then
    P = U
  end
  local B = Ad(P, v)
  local J = not B or B["collidable"] == true or not Ad(P, v + 1) or not Ad(P + A, v + 1)
  if J then
    P, v, A = r, D - 2, -A
  end
  if W(P) then
    return false, "MAIN DOOR BLOCKS NEXT FISHING SPOT"
  end
  local L, h = P + A, v + 1
  if not Ad(L, h) then
    return false, "NEXT FISHING TILE IS OUT OF REACH"
  end
  local T = zd("Water Bucket")
  local g = Ad(L, h)
  local Q = math["tointeger"](tonumber(g["flag"] or g["flags"]) or 0) or 0
  if (Q & 1024) == 0 and (not T or (vd(T) or 0) < 1) then
    return false, "WATER BUCKET REQUIRED"
  end
  local R = p["iceMode"] and (g and tonumber(g["fg"]) == p["requiredBlock"])
  if p["iceMode"] and (p["tool"] > 0 and vd(p["tool"]) == 0) then
    if not Qd(p, G, r, D, p["tool"], 0, "HAND DRILL") then
      return false, "HAND DRILL PICKUP FAILED"
    end
  end
  if
    p["requiredBlock"] and ((not R and (vd(p["requiredBlock"]) or 0) < 1) or p["tool"] == 0 or (vd(p["tool"]) or 0) < 1)
  then
    return false, "FISHING BLOCK AND ENABLED TOOL REQUIRED"
  end
  local F = Ad(P, v)
  if not F or F["collidable"] == true then
    return false, "NEXT STANDING TILE IS BLOCKED"
  end
  local a = Pd()
  local i = a and Ud(a)
  if not i or i[Bd(P, v)] or i[Bd(L, h)] then
    return false, "NEXT FISHING TILE HAS TOO MANY DROPPED STACKS"
  end
  local function y(r, D, A, P)
    local v = Ad(r, D)
    if not v or Ld(v) then
      return false, "SUPPORT TILE UNAVAILABLE"
    end
    if tonumber(v["fg"]) ~= 0 then
      return true
    end
    local W = zd("Dirt") or 2
    local U = p["iceBlock"]
    local B = W
    if (vd(W) or 0) < 1 then
      local G = p["requiredBlock"] == U and 2 or 1
      if not U or (vd(U) or 0) < G then
        return false, "DIRT OR ICE CRUST BLOCK REQUIRED FOR SUPPORT"
      end
      B = U
    end
    I("PLACING SUPPORT BLOCK")
    Sleep(200)
    local J, L, h = Dd()
    if not N(G) or rd() ~= p["world"] or L ~= A or h ~= P then
      return false, "MOVED BEFORE SUPPORT PLACEMENT"
    end
    v = Ad(r, D)
    if not v or Ld(v) then
      return false, "SUPPORT TILE UNAVAILABLE"
    end
    if tonumber(v["fg"]) ~= 0 then
      return true
    end
    if not Rd(J, r, D, B) then
      return false, "SUPPORT PLACEMENT FAILED"
    end
    for A = 1, 15, 1 do
      Sleep(200)
      if not N(G) or rd() ~= p["world"] then
        return false
      end
      v = Ad(r, D)
      if v and tonumber(v["fg"]) == B then
        return true
      end
    end
    return false, "SUPPORT PLACEMENT WAS NOT CONFIRMED"
  end
  local z, O = y(P, v + 1, r, D)
  if not z then
    return false, O
  end
  I(J and "CLIMBING TO NEXT FISHING ROW" or "MOVING TO BUILD NEXT FISHING SPOT")
  if not Td(P, v, G, p) then
    return false, "CANNOT REACH NEXT STANDING TILE"
  end
  if not N(G) or rd() ~= p["world"] then
    return false
  end
  if J then
    z, O = y(P - A, v + 1, P, v)
    if not z then
      return false, O
    end
  end
  local function M(r)
    local D, A, W = Dd()
    return N(G) and (rd() == p["world"] and (A == P and (W == v and Rd(D, L, h, r))))
  end
  local function t(p)
    Sleep(200)
    return M(p)
  end
  local function q(r)
    for D = 1, 15, 1 do
      Sleep(200)
      if not N(G) or rd() ~= p["world"] then
        return nil
      end
      local A = Ad(L, h)
      if A and r(A) then
        return A
      end
    end
  end
  if W(P) then
    return false, "MAIN DOOR BLOCKS NEXT FISHING SPOT"
  end
  local b = Ad(L, h)
  local k = p["iceMode"] and (b and tonumber(b["fg"]) == p["requiredBlock"])
  if not k then
    I("CLEARING NEXT FISHING TILE")
    for p = 1, 30, 1 do
      if not b then
        return false, "NEXT TILE COULD NOT BE READ"
      end
      if Ld(b) then
        return false, "MAIN DOOR BLOCKS NEXT FISHING SPOT"
      end
      if b["fg"] == 0 and b["bg"] == 0 then
        break
      end
      if not M(18) then
        return false, "PUNCH FAILED ON NEXT TILE"
      end
      Sleep(180)
      b = Ad(L, h)
    end
    if not b or b["fg"] ~= 0 or b["bg"] ~= 0 then
      return false, "NEXT TILE COULD NOT BE CLEARED"
    end
    if p["requiredBlock"] then
      I("PLACING FISHING BLOCK")
      if not t(p["requiredBlock"]) or not q(function(G)
        return G["fg"] == p["requiredBlock"]
      end) then
        return false, "FISHING BLOCK PLACEMENT FAILED"
      end
    end
  end
  I("ADDING WATER")
  local function e(p)
    local G = math["tointeger"](tonumber(p["flag"] or p["flags"]) or 0) or 0
    return (G & 1024) ~= 0
  end
  b = Ad(L, h)
  if not b or (not e(b) and (not t(T) or not q(e))) then
    return false, "WATER PLACEMENT FAILED"
  end
  if p["requiredBlock"] then
    I("OPENING FISHING BLOCK")
    if not M(p["tool"]) then
      return false, "FISHING TOOL FAILED"
    end
  end
  p["dir"] = A
  p["originX"], p["originY"] = P, v
  local w = Bd(P, v)
  p["skipped"][w] = nil
  p["toolUsed"][w] = nil
  I("FISHING SPOT READY - RESUMING")
  Sleep(2000)
  if N(G) and (rd() == p["world"] and p["requiredBlock"]) then
    local G = Ad(L, h)
    if G then
      p["prepared"][Bd(L, h)] = tonumber(G["fg"])
    end
  end
  return true
end
local function ud(p, G, r, D, A, P, v)
  local W, U, B = Dd()
  if U ~= A or B ~= P then
    pd("MOVED FROM PERFECT FISH DROP TILE")
    return false
  end
  if vd(r) ~= D then
    pd("PERFECT FISH INVENTORY CHANGED - CHECK BAG")
    return false
  end
  local J = { ["id"] = r }
  Z = J
  local L = SendPacket or sendPacket
  local h, T = pcall(L, 2, "action|drop\nitemID|" .. r)
  if h and T ~= false then
    for D = 1, 25, 1 do
      Sleep(100)
      if not N(G) or rd() ~= p["world"] or J["ready"] or J["full"] or J["full"] or vd(r) == 0 then
        break
      end
    end
  end
  if not N(G) or rd() ~= p["world"] then
    Z = nil
    return false
  end
  local g, Q, R = Dd()
  if not J["full"] and (J["ready"] and (Q == A and (R == P and vd(r) == D))) then
    X(L, 2, "action|dialog_return\ndialog_name|drop_item\nitemID|" .. (r .. ("|\ncount|" .. D)))
    for D = 1, 30, 1 do
      Sleep(100)
      if not N(G) or rd() ~= p["world"] or vd(r) == 0 then
        break
      end
    end
  end
  if not N(G) or rd() ~= p["world"] then
    return false
  end
  Z = nil
  local F = vd(r)
  if F ~= 0 then
    local p, G, r = Dd()
    if v and (F == D and (G == A and r == P)) then
      return false, J["full"] and "full" or "retry"
    end
    pd("PERFECT FISH DROP UNCONFIRMED - CHECK BAG")
    return false
  end
  return true
end
local function fd(p, G, r)
  local D, A = p["activeDropX"], p["dropY"]
  local function P(r, D)
    Sleep(1500)
    return Td(r, D, G, p)
  end
  if #r > 0 then
    I(V and "STORING PERFECT FISH" or "STORING ICE FISH")
    if not P(D, A) then
      if N(G) and rd() == p["world"] then
        pd("CANNOT REACH PERFECT FISH DROP TILE")
      end
      return false
    end
  end
  for r, v in ipairs(r) do
    while N(G) and rd() == p["world"] do
      local r, W = ud(p, G, v["id"], v["held"], D, A, true)
      if r then
        break
      end
      if W == "retry" then
        Sleep(350)
        if not N(G) or rd() ~= p["world"] then
          return false
        end
        if vd(v["id"]) == 0 then
          break
        end
        r, W = ud(p, G, v["id"], v["held"], D, A, true)
        if r then
          break
        end
      end
      if W ~= "retry" and W ~= "full" then
        return false
      end
      local U = D - 1
      local B = U >= 0 and Ad(U, A)
      if not B or B["collidable"] == true or Ld(B) then
        pd("NO STORAGE TILE LEFT - CHECK BAG")
        return false
      end
      I("DROP TILE FULL - SHIFTING LEFT")
      if not P(U, A) then
        if N(G) and rd() == p["world"] then
          pd("CANNOT REACH NEXT DROP TILE")
        end
        return false
      end
      D = U
      p["activeDropX"] = D
      if p["dropX"] == g and p["dropY"] == Q then
        R, F = p["world"], D
        i()
      end
    end
  end
  return N(G) and rd() == p["world"]
end
local cd = 2
local function sd(p, G, r, D)
  local function A(r, D)
    Sleep(1500)
    return Td(r, D, G, p)
  end
  local P, v = p["activeDropX"], p["dropY"]
  if P < 0 or v < 0 or not Ad(P, v) then
    pd("SET PERFECT FISH DROP POSITION FIRST")
    return true
  end
  if not p["bagCleared"] then
    local W = {}
    for p in pairs(p["perfectWeights"]) do
      local G = vd(p)
      if G == nil then
        pd("CANNOT READ FISH INVENTORY")
        return true
      end
      if G > 0 then
        W[#W + 1] = { ["id"] = p, ["held"] = G }
      end
    end
    if #W > 0 then
      I("CLEARING TARGET FISH FROM BACKPACK")
      local U, B = r, D
      if U >= p["activeDropX"] - cd and (U <= p["dropX"] + cd and math["abs"](B - v) <= cd) then
        U, B = nil, nil
        local r = cd + 1
        for r, D in ipairs({ { P - r, v }, { p["dropX"] + r, v }, { P, v - r }, { P, v + r } }) do
          local P, v = D[1], D[2]
          local W = Ad(P, v)
          if W and (W["collidable"] ~= true and (not Ld(W) and A(P, v))) then
            U, B = P, v
            break
          end
          if not N(G) or rd() ~= p["world"] then
            return true
          end
        end
        if not U then
          pd("NO REACHABLE FISH STAGING TILE")
          return true
        end
      end
      for r, D in ipairs(W) do
        if not ud(p, G, D["id"], D["held"], U, B) then
          return true
        end
      end
    end
    p["bagCleared"] = true
  end
  local function W(G)
    local r, D = tonumber(G["itemid"]), tonumber(G["id"])
    local A = r and p["perfectWeights"][r]
    if not A or not D or p["skippedFish"][D] or tonumber(G["amount"]) ~= A or vd(r) ~= 0 then
      return
    end
    local P, W = Wd(G)
    if not P then
      return
    end
    local U, B = P // 32, W // 32
    if U >= p["activeDropX"] - cd and (U <= p["dropX"] + cd and math["abs"](B - v) <= cd) then
      return
    end
    return { ["id"] = r, ["uid"] = D, ["x"] = P, ["y"] = W, ["tx"] = U, ["ty"] = B }
  end
  local U = Pd()
  if type(U) ~= "table" then
    pd("CANNOT READ DROPPED FISH")
    return true
  end
  local B = {}
  for p, G in pairs(U) do
    local r = W(G)
    if r then
      B[#B + 1] = r
    end
  end
  table["sort"](B, function(p, G)
    if p["ty"] ~= G["ty"] then
      return p["ty"] < G["ty"]
    end
    if p["tx"] ~= G["tx"] then
      return p["tx"] < G["tx"]
    end
    return p["uid"] < G["uid"]
  end)
  if #B == 0 then
    return false
  end
  local function J(r)
    I("COLLECTING PERFECT FISH")
    local D = false
    local function P()
      local p, G, D = Dd()
      return G and (math["abs"](G - r["tx"]) <= 1 and math["abs"](D - r["ty"]) <= 1)
    end
    local v = Ad(r["tx"], r["ty"])
    if not v or v["collidable"] == true or Ld(v) or not A(r["tx"], r["ty"]) then
      if N(G) and rd() == p["world"] then
        if (vd(r["id"]) or 0) > 0 then
          pd("UNVERIFIED FISH PICKUP - CHECK BAG")
        else
          p["skippedFish"][r["uid"]] = true
          I("CANNOT REACH PERFECT FISH STACK")
        end
      end
      return nil
    end
    Sleep(900)
    if not N(G) or rd() ~= p["world"] then
      return nil
    end
    if P() and vd(r["id"]) == 0 then
      for p, G in pairs(Pd() or {}) do
        local A = W(G)
        if
          A and (
            A["uid"] == r["uid"] and (A["id"] == r["id"] and (A["tx"] == r["tx"] and (A["ty"] == r["ty"] and P())))
          )
        then
          E = A
          local p, G =
            pcall(SendPacketRaw, false, { ["type"] = 11, ["value"] = A["uid"], ["x"] = A["x"], ["y"] = A["y"] })
          E = nil
          D = p and G ~= false
          break
        end
      end
      for D = 1, 10, 1 do
        Sleep(200)
        if not N(G) or rd() ~= p["world"] then
          return nil
        end
        if (vd(r["id"]) or 0) > 0 then
          break
        end
      end
    end
    if not N(G) or rd() ~= p["world"] then
      return nil
    end
    local U = vd(r["id"])
    if U and (U > 0 and not D) then
      pd("UNVERIFIED FISH PICKUP - CHECK BAG")
      return nil
    end
    if not U or U == 0 then
      p["skippedFish"][r["uid"]] = true
    end
    return U
  end
  local L, h = {}, {}
  for r, D in ipairs(B) do
    if h[D["id"]] then
      break
    end
    if vd(D["id"]) == 0 then
      local r = J(D)
      if not N(G) or rd() ~= p["world"] then
        return true
      end
      if r and r > 0 then
        L[#L + 1] = { ["id"] = D["id"], ["held"] = r }
        h[D["id"]] = true
        if #L == 3 then
          break
        end
      end
    end
  end
  if not fd(p, G, L) then
    return true
  end
  return true
end
local function Id(p, G)
  if p["originX"] == nil then
    local r, D, A = Dd()
    if not D then
      return
    end
    local P = Pd()
    local v = P and Ud(P)
    if not v then
      pd("CANNOT READ DROPPED STACKS SAFELY")
      return
    end
    if hd(D, A, p, {}) then
      p["originX"], p["originY"] = D, A
    else
      I("FINDING STARTING FISHING SPOT")
      local r, P, W = gd(p, G, v, D, A)
      if not r then
        if N(G) and rd() == p["world"] then
          Gd()
        end
        return
      end
      p["originX"], p["originY"] = P, W
      I("AT STARTING SPOT - WAITING TO CAST")
      Sleep(1200)
      if not N(G) or rd() ~= p["world"] then
        return
      end
      local U, B, J = Dd()
      if B ~= P or J ~= W then
        if not Td(P, W, G, p) then
          if N(G) and rd() == p["world"] then
            pd("COULD NOT HOLD STARTING SPOT")
          end
          return
        end
        Sleep(1200)
        if not N(G) or rd() ~= p["world"] then
          return
        end
      end
    end
  end
  if p["autoDropFish"] and not p["unresolvedCast"] then
    local r = {}
    for p, G in ipairs(p["autoDropFish"]) do
      local D = vd(G)
      if D and D >= 190 then
        r[#r + 1] = { ["id"] = G, ["held"] = D }
      end
    end
    if #r > 0 then
      local D, A, P = Dd()
      if not A then
        return
      end
      if p["activeDropX"] < 0 or p["dropY"] < 0 or not Ad(p["activeDropX"], p["dropY"]) then
        pd("SET FISH DROP POSITION FIRST")
        return
      end
      local v, W = pcall(editToggle or EditToggle, "ModFly", true)
      if not v or W == false then
        pd("COULD NOT ENABLE MODFLY FOR STORAGE")
        return
      end
      l = true
      if not fd(p, G, r) then
        o()
        return
      end
      I("RETURNING TO FISHING SPOT")
      Sleep(1500)
      if not Td(A, P, G, p) and (N(G) and rd() == p["world"]) then
        pd("COULD NOT RETURN FROM FISH DROP TILE")
      end
      o()
      return
    end
  end
  local r = vd(p["bait"])
  if not r then
    pd("CANNOT READ BAIT INVENTORY")
    return
  end
  if r == 0 or (p["autoBait"] and r == 1) then
    if p["unresolvedCast"] then
      pd("LAST CAST UNRESOLVED - FINISH FISHING BEFORE REFILL")
      return
    end
    local r, D, A = Dd()
    if not p["autoBait"] then
      pd("BAIT EMPTY - AUTO FIND BAIT IS OFF")
      return
    end
    if D and (not Qd(p, G, D, A, p["bait"], 1, "BAIT") and (N(G) and rd() == p["world"])) then
      pd("BAIT EMPTY OR PICKUP FAILED")
    end
    return
  end
  local D, A, P = Dd()
  if not D then
    return
  end
  local v = Bd(A, P)
  if not hd(A, P, p, {}) then
    Gd()
    return
  end
  I("FISHING")
  local W, U, B = id(p, G, D, A, P)
  if W then
    p["toolUsed"][v] = nil
    I("WAITING AFTER CATCH")
    local r = p["delay"]
    while r > 0 and (N(G) and rd() == p["world"]) do
      local p = math["min"](r, 200)
      Sleep(p)
      r = r - p
    end
    return
  end
  if not N(G) or rd() ~= p["world"] then
    return
  end
  if B then
    p["skipped"][v] = true
    if not Xd(p, G, A + p["dir"], P + 1) then
      if N(G) and rd() == p["world"] then
        pd("COULD NOT DRAIN WATER BEFORE SHIFTING")
      end
      return
    end
    I("LOOKING FOR AN EXISTING FISHING SPOT")
    local r = Pd()
    local D = r and Ud(r)
    if D then
      if gd(p, G, D, A, P) then
        return
      end
    end
    if not N(G) or rd() ~= p["world"] then
      return
    end
    local W, U, B = Dd()
    if not U then
      return
    end
    local J, L = Kd(p, G, U, B)
    if not J and (N(G) and rd() == p["world"]) then
      pd(L)
    end
    return
  end
  local J, L, h = Dd()
  if U and (p["tool"] > 0 and (vd(p["tool"]) == 0 and (J and (L == A and h == P)))) then
    if not Qd(p, G, A, P, p["tool"], 0, "HAND DRILL") then
      if N(G) and rd() == p["world"] then
        pd("HAND DRILL PICKUP FAILED")
      end
      return
    end
    J, L, h = Dd()
  end
  if
    p["tool"] > 0
    and (
      (U or not p["toolUsed"][v]) and (J and (L == A and (h == P and (hd(A, P, p, {}) and (vd(p["tool"]) or 0) > 0))))
    )
  then
    p["toolUsed"][v] = true
    I(U and "DRILLING FISHING TILE" or "TRYING CONFIGURED FISHING TOOL")
    local r, D = A + p["dir"], P + 1
    if Rd(J, r, D, p["tool"]) then
      Sleep(2000)
      if not N(G) or rd() ~= p["world"] then
        return
      end
      local A = Ad(r, D)
      if A then
        p["prepared"][Bd(r, D)] = tonumber(A["fg"])
      end
    end
  elseif J and (L == A and (h == P and hd(A, P, p, {}))) then
    I("NO CATCH - RETRYING THIS SPOT")
    Sleep(1200)
  else
    I("CAST INTERRUPTED - CHECKING CURRENT SPOT")
  end
end
local function Nd(p, G)
  if rd() ~= p["world"] or not Dd() then
    if not p["waitingForReturn"] then
      p["waitingForReturn"] = true
      d, Z, E = nil, nil, nil
      if V then
        X(editToggle or EditToggle, "ModFly", false)
      end
    end
    I("WAITING TO RETURN TO " .. p["world"])
    return false
  end
  if not p["waitingForReturn"] then
    return true
  end
  I("BACK IN WORLD - RESTARTING SETUP")
  Sleep(1500)
  if not N(G) or rd() ~= p["world"] or not Dd() then
    return false
  end
  if V then
    local G = editToggle or EditToggle
    local r, D = pcall(G, "ModFly", true)
    if not r or D == false then
      pd("COULD NOT ENABLE MODFLY AFTER RETURN")
      return false
    end
    X(G, "Enable AutoCollect", false)
    X(G, "Autocollect", false)
    p["bagCleared"] = false
    p["skippedFish"] = {}
    p["activeDropX"] = td(p["world"], p["dropX"])
  else
    p["originX"], p["originY"] = nil, nil
    p["dir"] = p["startDirection"]
    p["skipped"], p["toolUsed"], p["prepared"] = {}, {}, {}
    p["unresolvedCast"] = false
    p["activeDropX"] = td(p["world"], p["dropX"])
  end
  p["waitingForReturn"] = false
  return true
end
if A ~= "" then
  dd({})
end
runThread(function()
  while true do
    if x and (rd() ~= x or not Dd()) then
      Fd()
    end
    if w or V then
      local p = m
      j = true
      local G, r = pcall(function()
        if not Nd(n, p) then
          return
        end
        if w then
          Id(n, p)
        else
          local G, r, D = Dd()
          if r and (not sd(n, p, r, D) and (N(p) and rd() == n["world"])) then
            pd("NO MORE ELIGIBLE PERFECT FISH")
          end
        end
      end)
      j = false
      if not G and N(p) then
        pd("FISHING ERROR: " .. tostring(r))
      end
    end
    Sleep(250)
  end
end)
