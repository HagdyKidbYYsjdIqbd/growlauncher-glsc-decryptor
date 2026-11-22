setMinimum("6.1.2")
local t = "Grass Factory"
local P = "pabrik_grass_vaaastore_v2"
local Q = {
  ["farmWorld"] = "",
  ["farmX"] = 0,
  ["farmY"] = 0,
  ["positionSaved"] = false,
  ["terrainID"] = 0,
  ["growSeconds"] = 68,
  ["plantDelay"] = 250,
  ["plantWindowPercent"] = 35,
  ["pnbSweepsPerPlant"] = 6,
  ["treesPerWave"] = 20,
  ["scanDelay"] = 250,
  ["punchDelay"] = 180,
  ["placeDelay"] = 200,
  ["hitsPerTile"] = 1,
  ["collectDelay"] = 160,
  ["autoCollect"] = true,
  ["autoResume"] = true,
  ["stopWhenEmpty"] = true,
  ["autoBanOnJoin"] = false,
  ["storageMode"] = "DROP",
  ["storeAt"] = 180,
  ["keepSeeds"] = 40,
  ["dropWorld"] = "",
  ["dropX"] = 0,
  ["dropY"] = 0,
  ["activeDropX"] = 0,
  ["vendorRetrySeconds"] = 20,
  ["manualLearnSeconds"] = 60,
  ["blockID"] = 0,
}
local m = {
  "farmWorld",
  "farmX",
  "farmY",
  "positionSaved",
  "terrainID",
  "growSeconds",
  "plantDelay",
  "plantWindowPercent",
  "pnbSweepsPerPlant",
  "treesPerWave",
  "scanDelay",
  "punchDelay",
  "placeDelay",
  "hitsPerTile",
  "collectDelay",
  "autoCollect",
  "autoResume",
  "stopWhenEmpty",
  "autoBanOnJoin",
  "storageMode",
  "storeAt",
  "keepSeeds",
  "dropWorld",
  "dropX",
  "dropY",
  "activeDropX",
  "vendorRetrySeconds",
  "manualLearnSeconds",
  "blockID",
}
local e = {}
for t, P in pairs(Q) do
  e[t] = P
end
local U
local W = "UNAVAILABLE"
local function K()
  local t, K = pcall(require, "preferences")
  if not t or (type(K) ~= "table" and type(K) ~= "userdata") then
    return
  end
  if type(K["new"]) ~= "function" then
    return
  end
  local a, L = pcall(function()
    return K:new(P)
  end)
  if not a then
    return
  end
  U = L or K
  if
    type(U["load"]) ~= "function"
    or type(U["get"]) ~= "function"
    or type(U["set"]) ~= "function"
    or type(U["save"]) ~= "function"
  then
    U = nil
    return
  end
  pcall(function()
    U:load()
  end)
  if tostring(U:get("factory_menu_initialized", "false")) == "true" then
    for t, P in ipairs(m) do
      local m = Q[P]
      local W = U:get("factory_" .. P, tostring(m))
      if type(m) == "boolean" then
        e[P] = (tostring(W) == "true" or tostring(W) == "1")
      elseif type(m) == "number" then
        e[P] = tonumber(W) or m
      else
        e[P] = tostring(W)
      end
    end
    if U:get("factory_storageMode", nil) == nil then
      local t = tostring(U:get("factory_storeVending", "false"))
      if t == "true" then
        e["storageMode"] = "VENDING"
      end
    end
    if U:get("factory_activeDropX", nil) == nil then
      e["activeDropX"] = tonumber(U:get("factory_dropX", 0)) or 0
    end
    if tostring(U:get("factory_delay_defaults_v5", "false")) ~= "true" then
      local t = { ["plantDelay"] = 180, ["punchDelay"] = 110, ["placeDelay"] = 120 }
      local P = { ["plantDelay"] = 250, ["punchDelay"] = 180, ["placeDelay"] = 200 }
      pcall(function()
        for t, Q in pairs(t) do
          if tonumber(e[t]) == Q then
            e[t] = P[t]
            U:set("factory_" .. t, tostring(e[t]))
          end
        end
        U:set("factory_delay_defaults_v5", "true")
        U:save()
      end)
    end
    W = "RESTORED"
  else
    W = "READY"
  end
end
K()
local function a(t, P, Q, m)
  return math["max"](P, math["min"](Q, math["floor"](tonumber(t) or m or P)))
end
local function L()
  e["terrainID"] = a(e["terrainID"], 0, 65535, 0)
  e["growSeconds"] = a(e["growSeconds"], 1, 86400, 68)
  e["plantDelay"] = a(e["plantDelay"], 20, 10000, 250)
  e["plantWindowPercent"] = a(e["plantWindowPercent"], 5, 95, 35)
  e["pnbSweepsPerPlant"] = a(e["pnbSweepsPerPlant"], 1, 100, 6)
  e["treesPerWave"] = a(e["treesPerWave"], 1, 150, 20)
  e["scanDelay"] = a(e["scanDelay"], 50, 5000, 250)
  e["punchDelay"] = a(e["punchDelay"], 20, 5000, 180)
  e["placeDelay"] = a(e["placeDelay"], 20, 5000, 200)
  e["hitsPerTile"] = a(e["hitsPerTile"], 1, 12, 1)
  e["collectDelay"] = a(e["collectDelay"], 50, 5000, 160)
  e["storeAt"] = a(e["storeAt"], 1, 200, 180)
  e["keepSeeds"] = a(e["keepSeeds"], 0, 199, 40)
  e["vendorRetrySeconds"] = a(e["vendorRetrySeconds"], 5, 600, 20)
  e["manualLearnSeconds"] = a(e["manualLearnSeconds"], 10, 180, 60)
  e["farmX"] = a(e["farmX"], 0, 199, 0)
  e["farmY"] = a(e["farmY"], 0, 119, 0)
  e["blockID"] = a(e["blockID"], 0, 65535, 0)
  e["farmWorld"] = ((tostring(e["farmWorld"] or "")):upper()):gsub("%s+", "")
  e["dropWorld"] = ((tostring(e["dropWorld"] or "")):upper()):gsub("%s+", "")
  e["dropX"] = a(e["dropX"], 0, 199, 0)
  e["dropY"] = a(e["dropY"], 0, 119, 0)
  e["activeDropX"] = a(e["activeDropX"], 0, 199, 0)
  e["storageMode"] = (tostring(e["storageMode"] or "DROP")):upper()
  if e["storageMode"] ~= "VENDING" then
    e["storageMode"] = "DROP"
  end
end
L()
if U and (tostring(U:get("factory_storageMode", ""))):upper() ~= e["storageMode"] then
  pcall(function()
    U:set("factory_storageMode", e["storageMode"])
    U:save()
  end)
end
local x = {}
local function k(t, P)
  if x[t] then
    return
  end
  x[t] = true
  pcall(function()
    editValue(t, tostring(P))
  end)
  x[t] = nil
end
local function J(t)
  pcall(function()
    if growtopia and growtopia["notify"] then
      growtopia["notify"](tostring(t))
    end
  end)
end
local function l()
  if not U then
    W = "UNAVAILABLE"
    k("GF_save", W)
    return false
  end
  local t = pcall(function()
    assert(U:set("factory_menu_initialized", "true") ~= false)
    for t, P in ipairs(m) do
      assert(U:set("factory_" .. P, tostring(e[P])) ~= false)
    end
    assert(U:save() ~= false)
  end)
  W = t and "SAVED" or "SAVE FAILED"
  k("GF_save", W)
  return t
end
local R = Sleep or sleep
local function O(t)
  if type(R) == "function" then
    R(math["floor"](t))
  end
end
local X = 0
local function Z()
  if type(getTime) == "function" then
    local t, P = pcall(getTime)
    if t and type(P) == "number" then
      return P
    end
  end
  return X
end
local function z()
  local t = GetWorldName or getCurrentWorldName
  if not t then
    return ""
  end
  local P, Q = pcall(t)
  return (P and ((tostring(Q or "")):upper()):gsub("%s+", "")) or ""
end
local function d()
  local t = GetLocal or getLocal
  if not t then
    return nil
  end
  local P, Q = pcall(t)
  if P and (Q and Q["posX"]) then
    return Q
  end
end
local function q()
  local t = d()
  if t then
    return math["floor"](t["posX"] / 32), math["floor"](t["posY"] / 32)
  end
  return nil, nil
end
local function s(t, P)
  local Q = GetTile or getTile
  if not Q then
    return nil
  end
  local m, e = pcall(Q, t, P)
  if m then
    return e
  end
end
local function j()
  local t = GetObjectList or getObjectList
  if not t then
    return {}
  end
  local P, Q = pcall(t)
  if P and type(Q) == "table" then
    return Q
  end
  return {}
end
local function S()
  local t = GetInventory or getInventory
  if not t then
    return {}
  end
  local P, Q = pcall(t)
  if P and type(Q) == "table" then
    return Q
  end
  return {}
end
local function c(t)
  if not t or t <= 0 then
    return 0
  end
  if growtopia and type(growtopia["checkInventoryCount"]) == "function" then
    local P, Q = pcall(growtopia["checkInventoryCount"], t)
    if P and tonumber(Q) then
      return tonumber(Q)
    end
  end
  for P, Q in pairs(S()) do
    if tonumber(Q["id"]) == t then
      return tonumber(Q["amount"]) or 0
    end
  end
  return 0
end
local function M(t)
  if type(findItemID) == "function" then
    local P, Q = pcall(findItemID, t)
    if P and (tonumber(Q) and tonumber(Q) > 0) then
      return math["floor"](Q)
    end
  end
  if type(getItemInfoByName) == "function" then
    local P, Q = pcall(getItemInfoByName, t)
    if P and (Q and tonumber(Q["id"])) then
      return math["floor"](Q["id"])
    end
  end
  return nil
end
local function F(t)
  if type(t) == "number" and t > 0 then
    return math["floor"](t)
  end
  if type(t) == "string" then
    local P = tonumber(t)
    if P and P > 0 then
      return math["floor"](P)
    end
    local Q = M(t)
    if Q then
      return Q
    end
  elseif type(t) == "table" then
    for P, Q in ipairs({ "id", "itemid", "itemID", "value", "item", "name" }) do
      local m = t[Q]
      if m then
        local t = F(m)
        if t then
          return t
        end
      end
    end
  end
  return nil
end
local function n(t)
  local P = ((tostring(t or "")):upper()):gsub("%s+", "")
  local Q, m = P:match("^([^|]+)|([^|]+)$")
  if Q then
    return Q, m, P
  end
  if P:find("|", 1, true) then
    return "", nil, P
  end
  return P, nil, P
end
local function G()
  local t = z()
  if t == "" or t == "EXIT" then
    return false
  end
  if not d() then
    return false
  end
  local P = GetTiles or getTiles
  if type(P) ~= "function" then
    return false
  end
  local Q, m = pcall(P)
  if not Q or type(m) ~= "table" or #m == 0 then
    return false
  end
  startupTileCount = #m
  return true
end
local w = { ["block"] = nil, ["seed"] = nil, ["vend"] = nil }
local function N()
  w["block"] = (e["blockID"] > 0 and e["blockID"]) or M("Grass")
  w["seed"] = (e["blockID"] > 0 and w["block"] + 1) or M("Grass Seed") or (w["block"] and w["block"] + 1)
  w["vend"] = M("Vending Machine") or 2978
  if not w["block"] or not w["seed"] then
    return false
  end
  k("GF_itemstatus", "Block " .. (w["block"] .. (" | Seed " .. w["seed"])))
  return true
end
local b = false
local T = false
local h = "STOPPED"
local Y = ""
local C = { ["x"] = 0, ["y"] = 0 }
local g =
  { ["plants"] = 0, ["harvests"] = 0, ["punches"] = 0, ["placed"] = 0, ["picked"] = 0, ["stored"] = 0, ["cycles"] = 0 }
local E = -100000
local H = -100000
local I = -100000
local r = -100000
local v = {}
local u = ""
local f = nil
local y = false
local p = false
local V = e["activeDropX"]
local B = nil
local D = -100000
local o = ""
local A = 0
local i = 0
local tb = 240
local Pb = 500
local Qb = 15000
local mb = 0
local eb = "NOT SCANNED"
local Ub = 0
local Wb = 0
local Kb = ""
local ab = nil
local Lb = false
local xb = nil
local kb = 0
local Jb = false
local lb = 0
local Rb = 0
local Ob = "BREAK"
local Xb = false
local Zb = "Idle"
local zb = "Waiting for PnB drops"
local db = -100000
local qb = {}
local sb = "STOPPED"
local jb = 0
local Sb = 0
local cb = false
local function Mb()
  local t, P, Q = n(Y)
  return b and (t ~= "" and (z() == t and (d() ~= nil and ((P and u == Q) or (not P and u == "")))))
end
local function Fb()
  local t, P, Q = n(e["dropWorld"])
  return b and (t ~= "" and (z() == t and (d() ~= nil and ((P and u == Q) or (not P and u == "")))))
end
local nb = {}
local Gb = {}
local wb = {}
local Nb = {}
local bb = "Not attempted"
local Tb = 1
local hb = { ["waiting"] = false, ["dialog"] = nil, ["learning"] = false, ["recorded"] = {}, ["template"] = nil }
local Yb = 1
local Cb = ""
local function gb(t)
  t = tostring(t)
  if t == h then
    return
  end
  h = t
  k("GF_status", t)
end
local function Eb(t)
  if not t and (Z() - H) < 1000 then
    return
  end
  H = Z()
  k("GF_inventory", "Block " .. (c(w["block"]) .. (" | Seed " .. c(w["seed"]))))
  if w["seed"] and Mb() then
    local t, P, Q = 0, 0, nil
    for m, U in ipairs(B or {}) do
      if m > tb then
        break
      end
      local W = s(U["x"], U["y"])
      if W and tonumber(W["fg"]) == w["seed"] then
        if
          W["readyharvest"]
          or ((nb[tostring(U["x"]) .. ("," .. tostring(U["y"]))] or math["huge"]) <= Z() - e["growSeconds"] * 1000)
        then
          P = P + 1
        else
          t = t + 1
          local P = nb[tostring(U["x"]) .. ("," .. tostring(U["y"]))]
          if P then
            local t = math["max"](0, e["growSeconds"] * 1000 - (Z() - P))
            if Q == nil or t < Q then
              Q = t
            end
          end
        end
      end
    end
    k(
      "GF_trees",
      "Growing " .. (t .. (" | Ready " .. (P .. (" | Next ~" .. (Q and math["ceil"](Q / 1000) .. "s" or "unknown")))))
    )
  end
  k(
    "GF_plantpos",
    "Terrain "
      .. (
        tostring(A > 0 and A or "not detected") .. (
          " | Active beds " .. (tostring(B and #B or "not scanned") .. (" | " .. eb))
        )
      )
  )
  local P = ab and math["max"](0, math["ceil"]((e["growSeconds"] * 1000 - (Z() - ab)) / 1000)) or e["growSeconds"]
  k(
    "GF_wave",
    sb .. (
        " | Wave planted " .. (
          kb .. ("/" .. (e["treesPerWave"] .. (" | First crop ~" .. (P .. ("s | PnB sweeps " .. jb)))))
        )
      )
  )
  k("GF_stage", sb)
  k("GF_cyclecheck", Kb ~= "" and Kb or "No blocks-cleared checkpoint yet")
  k("GF_storage", e["storageMode"] .. (" | drop stand " .. (V .. ("," .. e["dropY"]))))
  k("GF_blockpickup", Zb)
  k("GF_breakdrops", zb)
  k(
    "GF_counts",
    "Planted "
      .. (
        g["plants"] .. (
          " | Harvested " .. (g["harvests"] .. (" | Punched " .. (g["punches"] .. (" | Stored " .. g["stored"]))))
        )
      )
  )
  k("GF_harvestpath", bb)
  k(
    "GF_farmpos",
    (e["farmWorld"] ~= "" and e["farmWorld"] or "CURRENT WORLD") .. (" | X=" .. (e["farmX"] .. (" Y=" .. e["farmY"])))
  )
end
local function Hb()
  x["GF_run"] = true
  pcall(function()
    if type(editToggle) == "function" then
      editToggle("GF_run", false)
    end
  end)
  pcall(function()
    if type(EditToggle) == "function" then
      EditToggle("GF_run", false)
    end
  end)
  x["GF_run"] = nil
end
local function Ib(t)
  b = false
  hb["waiting"] = false
  hb["learning"] = false
  y = false
  p = false
  f = nil
  Xb = false
  sb = "STOPPED"
  gb("STOPPED: " .. tostring(t or "Manual"))
  Hb()
  if t then
    J("Grass Factory: " .. t)
  end
end
local function rb(t, P, Q)
  if not b or f ~= nil or not e["autoCollect"] or not Mb() then
    return
  end
  local m = (t and P == "AFTER_HARVEST")
  local U = (t and (P == "FETCH" and tonumber(Q)))
  if not Xb and (not m and not U) then
    return
  end
  local W = Z()
  if not t and W - E < e["collectDelay"] then
    return
  end
  E = W
  local K, a = q()
  if not K then
    return
  end
  local L = 0
  local x = SendPacketRaw or sendPacketRaw
  if not x then
    return
  end
  for t, P in pairs(j()) do
    local e = P and P["pos"]
    if e and (tonumber(e["x"]) and tonumber(e["y"])) then
      local t, k = math["floor"](e["x"] / 32), math["floor"](e["y"] / 32)
      if math["abs"](t - K) <= 3 and math["abs"](k - a) <= 3 then
        local t = tonumber(P["id"])
        local K = tonumber(P["itemid"])
        local a = (not U or K == tonumber(Q))
        local k = (Xb and (Ob == "BREAK" and (w["seed"] and K == w["seed"])))
        local J = (w["block"] and (K == w["block"] and (Xb and (not m and (Ob == "BREAK" or c(w["block"]) >= 200)))))
        if t and (a and (not J and (not k and W - (v[t] or -100000) >= 300))) then
          pcall(x, false, { ["type"] = 11, ["value"] = t, ["x"] = e["x"], ["y"] = e["y"] })
          v[t] = W
          L = L + 1
          g["picked"] = g["picked"] + 1
          if L >= 24 then
            break
          end
        end
      end
    end
  end
  if W - H > 2500 then
    for t, P in pairs(v) do
      if W - P > 10000 then
        v[t] = nil
      end
    end
  end
end
local vb = {}
local ub = false
local fb = ""
local yb = -100000
local function pb()
  vb = {}
  ub = false
  fb = ""
  yb = -100000
end
local function Vb(t)
  local P = (tostring(t or "")):gsub("`.", "")
  P = P:match("^%s*([%w_]+)%s*$")
  if not P or #P < 2 or #P > 25 then
    return nil
  end
  return P
end
local function Bb()
  if not b or not e["autoBanOnJoin"] or not Mb() or f then
    if ub or fb ~= "" then
      pb()
    end
    return
  end
  local t = Z()
  if t - yb < 850 then
    return
  end
  yb = t
  local P, Q, m = n(Y)
  local U = Q and m or P
  if fb ~= U then
    pb()
    fb = U
    yb = t
  end
  local W = GetPlayerList or getPlayerList
  if type(W) ~= "function" then
    return
  end
  local K, a = pcall(W)
  if not K or type(a) ~= "table" then
    return
  end
  local L = d()
  if not L then
    return
  end
  local x = tonumber(L["netID"])
  local k = tonumber(L["userID"])
  local l = Vb(L["name"])
  local R = {}
  local O = {}
  for t, P in pairs(a) do
    if type(P) == "table" then
      local t = Vb(P["name"])
      local Q = tonumber(P["netID"])
      local m = tonumber(P["userID"])
      local e = (Q and (x and Q == x)) or (m and (k and m == k)) or (t and (l and t:lower() == l:lower()))
      if t and not e then
        local P = (m and (m > 0 and "u:" .. tostring(m)))
          or (Q and (Q >= 0 and "n:" .. tostring(Q)))
          or "name:" .. t:lower()
        R[P] = true
        if ub and vb[P] == nil then
          O[#O + 1] = t
        end
        vb[P] = 0
      end
    end
  end
  ub = true
  for t, P in pairs(vb) do
    if not R[t] then
      P = P + 1
      if P >= 3 then
        vb[t] = nil
      else
        vb[t] = P
      end
    end
  end
  local X = SendPacket or sendPacket
  if type(X) == "function" then
    for t = 1, math["min"](2, #O), 1 do
      local P = O[t]
      local Q = pcall(X, 2, "action|input\n|text|/ban " .. P)
      if Q then
        J("Auto Ban request: " .. P)
      end
    end
  end
end
local function Db(t)
  local P = math["max"](0, math["floor"](t or 0))
  while b and P > 0 do
    local t = math["min"](P, 50)
    O(t)
    X = X + t
    P = P - t
    Bb()
    rb(false)
  end
end
local function ob(t, P, Q)
  if not Mb() then
    return false
  end
  local m, e = q()
  if m == t and e == P then
    return true
  end
  local U = FindPath or findPath
  if not U then
    return false
  end
  for W = 1, 3, 1 do
    if not Mb() then
      return false
    end
    pcall(U, t, P)
    local K = 0
    while Mb() and K < (Q or 3500) do
      m, e = q()
      if m == t and e == P then
        return true
      end
      Db(100)
      K = K + 100
    end
  end
  return false
end
local function Ab(t, P, Q)
  if not Mb() then
    return false
  end
  local m = d()
  if not m then
    return false
  end
  local e = SendPacketRaw or sendPacketRaw
  if not e then
    return false
  end
  local U =
    pcall(e, false, { ["type"] = 3, ["value"] = Q, ["px"] = t, ["py"] = P, ["x"] = m["posX"], ["y"] = m["posY"] })
  return U
end
local function ib(t)
  local P, Q, m = n(t)
  return b and (P ~= "" and (z() == P and (d() ~= nil and ((Q and u == m) or (not Q and u == "")))))
end
local function tg(t, P)
  local Q, m, e = n(t)
  if Q == "" then
    gb(P .. " INVALID WORLD ROUTE")
    return false
  end
  if ib(e) then
    return true
  end
  if z() ~= Q or not d() or (not m and u ~= "") then
    if not growtopia or type(growtopia["warpTo"]) ~= "function" then
      return false
    end
    u = ""
    gb(P .. (" WARP " .. Q))
    local t, m = pcall(growtopia["warpTo"], Q)
    if not t or m == false then
      return false
    end
    local e = 0
    while b and e < 15000 do
      if z() == Q and d() then
        break
      end
      Db(150)
      e = e + 150
    end
    if z() ~= Q or not d() then
      return false
    end
    Db(750)
  end
  if m then
    gb(P .. (" DOOR " .. e))
    local t = SendPacket or sendPacket
    if type(t) ~= "function" then
      return false
    end
    local m, U = pcall(t, 3, "action|join_request\nname|" .. (e .. "\ninvitedWorld|0"))
    if not m or U == false then
      return false
    end
    Db(1400)
    local W = 0
    while b and W < 15000 do
      if z() == Q and d() then
        break
      end
      Db(150)
      W = W + 150
    end
    if z() ~= Q or not d() then
      return false
    end
    Db(800)
    u = e
  else
    u = ""
  end
  return ib(e)
end
local function Pg(t, P, Q, m)
  if not ib(t) then
    return false
  end
  local e = FindPath or findPath
  if type(e) ~= "function" then
    return false
  end
  local U, W = q()
  if U == P and W == Q then
    return true
  end
  for K = 1, 4, 1 do
    if not ib(t) then
      return false
    end
    pcall(e, P, Q)
    local a = 0
    while ib(t) and a < (m or 3200) do
      U, W = q()
      if U == P and W == Q then
        Db(100)
        return true
      end
      Db(100)
      a = a + 100
    end
  end
  U, W = q()
  return U == P and W == Q
end
local function Qg(t)
  local P = 0
  for Q, m in pairs(j()) do
    if tonumber(m["itemid"]) == t then
      P = P + (tonumber(m["amount"]) or 1)
    end
  end
  return P
end
local function mg(t)
  local P, Q = q()
  local m, e = nil, math["huge"]
  if not P then
    return nil
  end
  for U, W in pairs(j()) do
    if tonumber(W["itemid"]) == t and W["pos"] then
      local t, U = math["floor"]((W["pos"]["x"] or 0) / 32), math["floor"]((W["pos"]["y"] or 0) / 32)
      local K = math["abs"](P - t) + math["abs"](Q - U)
      if K < e then
        m = { ["x"] = t, ["y"] = U, ["uid"] = W["id"] }
        e = K
      end
    end
  end
  return m
end
local function eg(t)
  if not t or c(t) >= 200 or not b then
    return false
  end
  local P = mg(t)
  if not P then
    return false
  end
  local Q = c(t)
  local m, e = q()
  if math["abs"](m - P["x"]) > 2 or math["abs"](e - P["y"]) > 2 then
    if not ob(P["x"], P["y"], 2600) then
      local Q = false
      for t, m in ipairs({ { -1, 0 }, { 1, 0 }, { 0, -1 }, { 0, 1 } }) do
        local e, U = P["x"] + m[1], P["y"] + m[2]
        local W = s(e, U)
        if W and (tonumber(W["fg"]) == 0 and ob(e, U, 1600)) then
          Q = true
          break
        end
      end
      if not Q then
        gb("PICKUP PATH NOT READY: RETRY OBJECT " .. tostring(t))
        return false
      end
    end
  end
  rb(true, "FETCH", t)
  Db(250)
  if c(t) > Q then
    return true
  end
  local U = SendPacketRaw or sendPacketRaw
  if type(U) == "function" then
    for P, Q in pairs(j()) do
      local m = Q and Q["pos"]
      if tonumber(Q and Q["itemid"]) == t and (m and (tonumber(m["x"]) and tonumber(m["y"]))) then
        local t, P = q()
        local e, W = math["floor"](m["x"] / 32), math["floor"](m["y"] / 32)
        if t and (math["abs"](t - e) <= 3 and math["abs"](P - W) <= 3) then
          pcall(U, false, { ["type"] = 11, ["value"] = Q["id"], ["x"] = m["x"], ["y"] = m["y"] })
        end
      end
    end
    Db(350)
  end
  return c(t) > Q
end
local function Ug(t, P)
  return math["abs"](t - C["x"]) <= 3 and (P >= C["y"] - 3 and P <= C["y"] + 2)
end
local function Wg(t)
  if not b or not Mb() or not e["autoCollect"] or f ~= nil then
    return false
  end
  local P, Q = q()
  local m = SendPacketRaw or sendPacketRaw
  if not P or type(m) ~= "function" then
    return false
  end
  local U = Z()
  local W, K = 0, 0
  local a = t and 24 or 16
  for t, e in pairs(j()) do
    local L = e and e["pos"]
    local x = e and tonumber(e["id"])
    if x and (L and (tonumber(L["x"]) and tonumber(L["y"]))) then
      local t, k = math["floor"](L["x"] / 32), math["floor"](L["y"] / 32)
      if Ug(t, k) and (math["abs"](P - t) <= 4 and math["abs"](Q - k) <= 4) then
        K = K + 1
        local t = tonumber(e["itemid"])
        local P = (t and (t > 0 and c(t) >= 200))
        if not P and (U - (v[x] or -100000) >= 300 and W < a) then
          local t = pcall(m, false, { ["type"] = 11, ["value"] = x, ["x"] = L["x"], ["y"] = L["y"] })
          if t then
            v[x] = U
            g["picked"] = g["picked"] + 1
            W = W + 1
          end
        end
      end
    end
  end
  if W > 0 then
    zb = "PnB all-item pickup: " .. (W .. (" packets | Nearby " .. K))
  elseif K > 0 then
    zb = "PnB nearby drops: " .. (K .. " | retry/full stack")
  else
    zb = "No dropped items within expanded PnB radius"
  end
  return W > 0
end
local function Kg(t, P)
  return tostring(t) .. ("," .. tostring(P))
end
local function ag(t)
  local P = Kg(t["x"], t["y"])
  return (qb[P] or 0) <= Z()
end
local function Lg(t)
  local P = tostring(e["terrainID"]) .. ("|" .. (tostring(w["seed"] or 0) .. ("@" .. Y)))
  if not t and (B and (o == P and Z() - D < Qb)) then
    return B
  end
  if not Mb() then
    return B or {}
  end
  local Q = GetTiles or getTiles
  if type(Q) ~= "function" then
    return {}
  end
  local m, U = pcall(Q)
  if not m or type(U) ~= "table" then
    return {}
  end
  local W = {}
  local K = {}
  local a = {}
  local L, x = C["x"], C["y"]
  local k = 0
  for t, P in pairs(U) do
    k = k + 1
    if P and (tonumber(P["x"]) and tonumber(P["y"])) then
      local t, Q = math["floor"](tonumber(P["x"])), math["floor"](tonumber(P["y"]))
      W[Kg(t, Q)] = P
    end
    if k % 450 == 0 then
      O(1)
    end
  end
  local function J(t, P)
    return W[Kg(t, P)]
  end
  for t, P in pairs(U) do
    if P and (tonumber(P["x"]) and (tonumber(P["y"]) and tonumber(P["fg"]) == w["seed"])) then
      local t, Q = tonumber(P["x"]), tonumber(P["y"])
      local m = J(t, Q + 1)
      local e = m and tonumber(m["fg"]) or 0
      if e > 0 then
        K[e] = (K[e] or 0) + 1
      end
    end
  end
  local l = e["terrainID"]
  if l == 0 and i > 0 then
    l = i
  end
  if l == 0 then
    local t = 0
    for P, Q in pairs(K) do
      if Q > t then
        l, t = P, Q
      end
    end
  end
  if l == 0 then
    local t = {}
    for P, Q in pairs(U) do
      if Q and (tonumber(Q["x"]) and tonumber(Q["y"])) then
        local P, m = tonumber(Q["x"]), tonumber(Q["y"])
        local e = tonumber(Q["fg"]) or 0
        local U = J(P, m - 1)
        local W = U and tonumber(U["fg"]) or -1
        local K = math["abs"](P - L) + math["abs"]((m - 1) - x)
        if
          e > 0
          and (
            (W == 0 or W == w["seed"])
            and (
              math["abs"](P - L) <= 36 and (
                math["abs"]((m - 1) - x) <= 18 and not (math["abs"](P - L) <= 1 and m - 1 == x - 1)
              )
            )
          )
        then
          local P = t[e] or { ["count"] = 0, ["nearest"] = 9999 }
          P["count"] = P["count"] + 1
          P["nearest"] = math["min"](P["nearest"], K)
          t[e] = P
        end
      end
    end
    local P = -math["huge"]
    for t, Q in pairs(t) do
      local m = math["min"](Q["count"], 80) * 12 - Q["nearest"]
      if m > P then
        l = t
        P = m
      end
    end
  end
  A = l or 0
  if e["terrainID"] == 0 and (i == 0 and A > 0) then
    i = A
  end
  if A > 0 then
    for t, P in pairs(U) do
      if P and (tonumber(P["x"]) and tonumber(P["y"])) then
        local t, Q = math["floor"](tonumber(P["x"])), math["floor"](tonumber(P["y"]))
        if tonumber(P["fg"]) == A and Q >= 1 then
          local P = J(t, Q - 1)
          local m = P and tonumber(P["fg"]) or -1
          local e = (Q - 1 == C["y"] - 1 and math["abs"](t - C["x"]) <= 1)
          local U = (t == C["x"] and Q - 1 == C["y"])
          if not e and (m == 0 or m == w["seed"]) then
            a[#a + 1] = { ["x"] = t, ["y"] = Q - 1, ["canPlant"] = not U }
          end
        end
      end
    end
  end
  table["sort"](a, function(t, P)
    if t["y"] ~= P["y"] then
      return t["y"] < P["y"]
    end
    return t["x"] < P["x"]
  end)
  local R = #a
  for t = #a, tb + 1, -1 do
    a[t] = nil
  end
  B = a
  D = Z()
  o = P
  eb = "total=" .. (tostring(R) .. (" / tracking=" .. #a))
  return a
end
local function xg(t, P, Q)
  if not t or tonumber(t["fg"]) ~= w["seed"] then
    return false
  end
  if t["readyharvest"] == true or t["readyharvest"] == 1 then
    return true
  end
  local m = Kg(P, Q)
  if (Gb[m] or 0) > Z() then
    return false
  end
  local U = nb[m]
  return U ~= nil and Z() - U >= e["growSeconds"] * 1000
end
local function kg()
  local t, P, Q, m = 0, 0, 0, 0
  local e, U = nil, nil
  local W = nil
  for K, a in ipairs(Lg(false)) do
    local L = s(a["x"], a["y"])
    if L then
      m = m + 1
      if tonumber(L["fg"]) == w["seed"] then
        if nb[Kg(a["x"], a["y"])] == nil then
          nb[Kg(a["x"], a["y"])] = Z()
        end
        if xg(L, a["x"], a["y"]) then
          P = P + 1
          if not e and Z() >= (wb[Kg(a["x"], a["y"])] or 0) then
            e = { ["x"] = a["x"], ["y"] = a["y"] }
          end
        else
          t = t + 1
          local P = nb[Kg(a["x"], a["y"])]
          if P and (not W or P < W) then
            W = P
          end
        end
      elseif tonumber(L["fg"]) == 0 then
        Q = Q + 1
        if not U and (a["canPlant"] ~= false and ag(a)) then
          U = { ["x"] = a["x"], ["y"] = a["y"] }
        end
      end
    end
  end
  return { ["growing"] = t, ["ready"] = P, ["empty"] = Q, ["valid"] = m, ["earliestPlanted"] = W, ["chosenReady"] = e, ["chosenEmpty"] = U }
end
local function Jg(t, P)
  if not t or c(w["seed"]) <= 0 then
    return false
  end
  local Q = s(t["x"], t["y"])
  if not Q or tonumber(Q["fg"]) ~= 0 then
    return false
  end
  if not P then
    if not ob(t["x"], t["y"], 2200) then
      qb[Kg(t["x"], t["y"])] = Z() + 15000
      return false
    end
  else
    local P, Q = q()
    if not P or math["abs"](P - t["x"]) > 2 or math["abs"](Q - t["y"]) > 1 then
      return false
    end
  end
  if Ab(t["x"], t["y"], w["seed"]) then
    Db(e["plantDelay"])
    for P = 1, 4, 1 do
      local Q = s(t["x"], t["y"])
      if Q and tonumber(Q["fg"]) == w["seed"] then
        g["plants"] = g["plants"] + 1
        nb[Kg(t["x"], t["y"])] = Z()
        return true
      end
      Db(125)
    end
  end
  qb[Kg(t["x"], t["y"])] = Z() + 6000
  return false
end
local function lg(t, P)
  if not Mb() then
    return false
  end
  local Q = FindPath or findPath
  if type(Q) ~= "function" then
    bb = "NO FINDPATH API TO TREE " .. (t .. ("," .. P))
    return false
  end
  local function m()
    local Q, m = q()
    return Q and (math["abs"](Q - t) <= 2 and math["abs"](m - P) <= 2)
  end
  local e, U = q()
  if e == t and U == P then
    bb = "ON EXACT TREE TILE " .. (t .. ("," .. P))
    return true
  end
  for e = 1, 2, 1 do
    if not Mb() then
      return false
    end
    bb = "EXACT TREE FindPath " .. (t .. ("," .. (P .. (" (" .. (e .. "/2)")))))
    gb(bb)
    local U, W = pcall(Q, t, P)
    if U and W ~= false then
      local Q = 0
      while b and (Mb() and Q < 1650) do
        local m, e = q()
        if m == t and e == P then
          bb = "REACHED EXACT TREE " .. (t .. ("," .. P))
          return true
        end
        Db(100)
        Q = Q + 100
      end
    else
      bb = "EXACT TREE PATH REJECTED " .. (t .. ("," .. P))
    end
    if m() then
      bb = "TREE EXACT PATH SENT; HARVEST IN RANGE " .. (t .. ("," .. P))
      return true
    end
    if e < 2 then
      Db(180)
    end
  end
  bb = "EXACT TREE PATH NOT REACHED " .. (t .. ("," .. P))
  return false
end
local function Rg(t)
  if not t then
    return false
  end
  local P = Kg(t["x"], t["y"])
  local Q = s(t["x"], t["y"])
  if not Q or tonumber(Q["fg"]) ~= w["seed"] or not xg(Q, t["x"], t["y"]) then
    return false
  end
  if Z() < (wb[P] or 0) then
    return false
  end
  if not lg(t["x"], t["y"]) then
    Nb[P] = (Nb[P] or 0) + 1
    wb[P] = Z() + math["min"](12000, 2400 * Nb[P])
    gb("TREE EXACT PATH UNREACHABLE " .. (t["x"] .. ("," .. (t["y"] .. " - NEXT READY TREE"))))
    return false
  end
  if not Mb() then
    return false
  end
  local m, U = q()
  if not m or math["abs"](m - t["x"]) > 2 or math["abs"](U - t["y"]) > 2 then
    Nb[P] = (Nb[P] or 0) + 1
    wb[P] = Z() + 2500
    bb = "TREE OUT OF PUNCH RANGE " .. (t["x"] .. ("," .. t["y"]))
    return false
  end
  gb("HARVEST READY TREE " .. (t["x"] .. ("," .. t["y"])))
  bb = "HARVEST TREE " .. (t["x"] .. ("," .. (t["y"] .. (" FROM " .. (m .. ("," .. U))))))
  if not Ab(t["x"], t["y"], 18) then
    bb = "HARVEST PACKET FAILED " .. (t["x"] .. ("," .. t["y"]))
    wb[P] = Z() + 2500
    return false
  end
  Db(e["punchDelay"])
  for Q = 1, 4, 1 do
    local m = s(t["x"], t["y"])
    if m and tonumber(m["fg"]) ~= w["seed"] then
      g["harvests"] = g["harvests"] + 1
      nb[P] = nil
      wb[P] = nil
      Nb[P] = nil
      Gb[P] = nil
      bb = "HARVEST CONFIRMED " .. (t["x"] .. ("," .. t["y"]))
      rb(true, "AFTER_HARVEST")
      return true
    end
    Db(125)
  end
  Gb[P] = Z() + 5000
  bb = "TREE NOT YET HARVESTED " .. (t["x"] .. ("," .. (t["y"] .. "; RETRY AFTER SCAN")))
  return false
end
local function Og()
  if not w["seed"] or w["seed"] <= 0 then
    return false
  end
  local t = c(w["seed"])
  local P = math["max"](e["keepSeeds"], math["min"](e["treesPerWave"], 200))
  return t >= e["storeAt"] and t > P
end
local Xg = { -1, 1, 0 }
local function Zg()
  local t = 0
  for P, Q in ipairs(Xg) do
    local m = s(C["x"] + Q, C["y"] - 1)
    if m and tonumber(m["fg"]) == w["block"] then
      t = t + 1
    end
  end
  return t
end
local function zg(t)
  if not b or not Mb() then
    return false
  end
  local P, Q = q()
  if P ~= C["x"] or Q ~= C["y"] then
    local t = s(C["x"], C["y"])
    local P = t and tonumber(t["fg"]) == 0
    local Q = P and ob(C["x"], C["y"], 2000)
    if not Q then
      for t, P in ipairs({ -1, 1 }) do
        local m, e = C["x"] + P, C["y"]
        local U = s(m, e)
        if U and (tonumber(U["fg"]) == 0 and ob(m, e, 1700)) then
          Q = true
          gb("PNB USING NEARBY STAND; HOME TILE BLOCKED")
          break
        end
      end
    end
    if not Q then
      gb("PNB POSITION UNREACHABLE; CHECK FARM X/Y")
      return false
    end
  end
  local m = false
  for P, Q in ipairs(Xg) do
    if not Mb() or Og() then
      break
    end
    local U, W = C["x"] + Q, C["y"] - 1
    local K = s(U, W)
    if K and (tonumber(K["fg"]) == 0 and c(w["block"]) > 0) then
      if Ab(U, W, w["block"]) then
        m = true
        g["placed"] = g["placed"] + 1
        Db(e["placeDelay"])
      end
    elseif K and tonumber(K["fg"]) == w["block"] then
      for t = 1, e["hitsPerTile"], 1 do
        if not b or Og() then
          break
        end
        local P = s(U, W)
        if not P or tonumber(P["fg"]) ~= w["block"] then
          break
        end
        if Ab(U, W, 18) then
          m = true
          g["punches"] = g["punches"] + 1
        end
        Db(e["punchDelay"])
        Wg(false)
        if Og() then
          break
        end
      end
      local P = s(U, W)
      if not t and (not Og() and (P and (tonumber(P["fg"]) == 0 and c(w["block"]) > 0))) then
        if Ab(U, W, w["block"]) then
          m = true
          g["placed"] = g["placed"] + 1
          Db(e["placeDelay"])
        end
      end
    end
  end
  if m and (c(w["block"]) <= 0 and Zg() <= 0) then
    Db(math["max"](240, e["collectDelay"]))
  end
  if m then
    Wg(true)
  end
  g["cycles"] = g["cycles"] + 1
  return m
end
local function dg()
  if not U then
    return nil
  end
  local t, P = pcall(function()
    return U:get("vend_tpl", "")
  end)
  if not t or type(P) ~= "string" or P == "" then
    return nil
  end
  local Q, m = pcall(function()
    return U:get("factory_vend_tpl_seed", "")
  end)
  if Q and (tostring(m) ~= "" and tonumber(m) ~= w["seed"]) then
    return nil
  end
  if (not Q or tostring(m) == "") and e["blockID"] > 0 then
    return nil
  end
  local W = {}
  for t in ((P .. "@@")):gmatch("(.-)@@") do
    if t ~= "" then
      W[#W + 1] = t:gsub("~N~", "\n")
    end
  end
  return #W > 0 and W or nil
end
local function qg(t)
  if not U then
    return false
  end
  local P = {}
  for t, Q in ipairs(t) do
    P[#P + 1] = Q:gsub("\n", "~N~")
  end
  local Q = pcall(function()
    U:set("vend_tpl", table["concat"](P, "@@"))
    U:set("factory_vend_tpl_seed", tostring(w["seed"]))
    U:save()
  end)
  return Q
end
local function sg()
  local t = GetTiles or getTiles
  if not t then
    return {}
  end
  local P, Q = pcall(t)
  if not P or type(Q) ~= "table" then
    return {}
  end
  local m = {}
  for t, P in pairs(Q) do
    if
      P
      and (
        (tonumber(P["fg"]) == w["vend"] or tonumber(P["fg"]) == 2978 or tonumber(P["fg"]) == 9268)
        and (tonumber(P["x"]) and tonumber(P["y"]))
      )
    then
      m[#m + 1] = {
        ["x"] = tonumber(P["x"]),
        ["y"] = tonumber(P["y"]),
        ["d"] = math["abs"](tonumber(P["x"]) - C["x"]) + math["abs"](tonumber(P["y"]) - C["y"]),
      }
    end
  end
  table["sort"](m, function(t, P)
    return t["d"] < P["d"]
  end)
  return m
end
local function jg(t)
  local P, Q = q()
  if P and (math["abs"](P - t["x"]) <= 2 and math["abs"](Q - t["y"]) <= 2) then
    return true
  end
  for P, Q in ipairs({ { -1, 0 }, { 1, 0 }, { -2, 0 }, { 2, 0 }, { 0, -1 } }) do
    local m, e = t["x"] + Q[1], t["y"] + Q[2]
    local U = s(m, e)
    if U and (tonumber(U["fg"]) == 0 and ob(m, e, 2300)) then
      return true
    end
  end
  return false
end
local function Sg(t)
  if not b then
    return false
  end
  local P = d()
  if not P then
    return false
  end
  local Q = SendPacketRaw or sendPacketRaw
  if not Q then
    return false
  end
  hb["dialog"] = nil
  hb["waiting"] = true
  pcall(
    Q,
    false,
    { ["type"] = 3, ["value"] = 32, ["px"] = t["x"], ["py"] = t["y"], ["x"] = P["posX"], ["y"] = P["posY"] }
  )
  local m = 0
  while b and (hb["waiting"] and (not hb["dialog"] and m < 3500)) do
    Db(100)
    m = m + 100
  end
  hb["waiting"] = false
  return hb["dialog"] ~= nil
end
local function cg(t, P)
  hb["learning"] = true
  hb["recorded"] = {}
  J("Grass Factory: manually stock Grass Seeds into this vending once to teach the script.")
  gb("LEARNING VEND: Deposit seeds manually")
  local Q = 0
  while b and Q < e["manualLearnSeconds"] * 1000 do
    if c(w["seed"]) < P then
      break
    end
    Db(250)
    Q = Q + 250
  end
  hb["learning"] = false
  if not b or c(w["seed"]) >= P then
    return false
  end
  local m = {}
  for P, Q in ipairs(hb["recorded"]) do
    if Q:find("tilex|", 1, true) or (Q:lower()):find("vend", 1, true) then
      local P = ((Q:gsub("tilex|" .. (t["x"] .. "%f[%D]"), "tilex|{X}")):gsub(
        "tiley|" .. (t["y"] .. "%f[%D]"),
        "tiley|{Y}"
      )):gsub("|" .. (w["seed"] .. "%f[%D]"), "|{ITEM}")
      m[#m + 1] = P
    end
  end
  if #m > 0 then
    qg(m)
    hb["template"] = m
  end
  return true
end
local function Mg(t, P)
  local Q = hb["template"]
  if not Q or not Sg(t) then
    return false
  end
  local m = SendPacket or sendPacket
  if not m then
    return false
  end
  for P, Q in ipairs(Q) do
    if not b then
      return false
    end
    local e = ((Q:gsub("{X}", tostring(t["x"]))):gsub("{Y}", tostring(t["y"]))):gsub("{ITEM}", tostring(w["seed"]))
    pcall(m, 2, e)
    Db(500)
  end
  local e = 0
  while b and e < 3000 do
    if c(w["seed"]) < P then
      return true
    end
    Db(100)
    e = e + 100
  end
  return false
end
local function Fg(t)
  if e["storageMode"] ~= "VENDING" or not b or not Mb() then
    return false
  end
  local P = c(w["seed"])
  if P <= e["keepSeeds"] or (not t and P < e["storeAt"]) then
    return true
  end
  local Q = Z()
  if Q - r < e["vendorRetrySeconds"] * 1000 then
    gb("WAIT VENDING RETRY BEFORE HARVEST")
    return false
  end
  r = Q
  local m = sg()
  if #m == 0 then
    gb("NO VENDING; HARVEST WAITING FOR STORAGE")
    return false
  end
  local U = c(w["seed"])
  for t, P in ipairs(m) do
    if not b then
      return false
    end
    if jg(P) then
      local t = false
      if hb["template"] then
        t = Mg(P, U)
      else
        t = cg(P, U)
      end
      if t and c(w["seed"]) < U then
        g["stored"] = g["stored"] + (U - c(w["seed"]))
        if c(w["seed"]) < e["keepSeeds"] then
          J("Warning: vending deposit went below configured seed reserve.")
        end
        gb("VENDING SEEDS STORED BEFORE HARVEST")
        return c(w["seed"]) <= e["keepSeeds"]
      end
    end
  end
  gb("VENDING FULL/UNAVAILABLE; HARVEST WAITING")
  return false
end
local function ng()
  return math["max"](e["keepSeeds"], math["min"](e["treesPerWave"], 200))
end
local function Gg(t, P)
  if not Fb() then
    return false
  end
  local Q, m = q()
  if Q ~= V or m ~= e["dropY"] then
    return false
  end
  local U = SendPacket or sendPacket
  if type(U) ~= "function" then
    return false
  end
  y = true
  p = false
  local W, K = pcall(U, 2, "action|drop\nitemID|" .. tostring(w["seed"]))
  if not W or K == false then
    y = false
    p = false
    return false
  end
  local a = 0
  while b and (Fb() and a < 2500) do
    if p or c(w["seed"]) < t then
      break
    end
    Db(100)
    a = a + 100
  end
  local L = p
  y = false
  p = false
  if not Fb() then
    return false
  end
  Q, m = q()
  if Q ~= V or m ~= e["dropY"] then
    return false
  end
  if c(w["seed"]) < t then
    return true
  end
  if not L then
    return false
  end
  local x = math["min"](P, math["max"](0, c(w["seed"]) - ng()))
  if x <= 0 then
    return true
  end
  W, K = pcall(
    U,
    2,
    "action|dialog_return\n"
      .. ("dialog_name|drop_item\n" .. ("itemID|" .. (tostring(w["seed"]) .. ("|\n" .. ("count|" .. tostring(x))))))
  )
  if not W or K == false then
    return false
  end
  a = 0
  while b and (Fb() and a < 3200) do
    if c(w["seed"]) < t then
      return true
    end
    Db(100)
    a = a + 100
  end
  return c(w["seed"]) < t
end
local function wg()
  if not b or f ~= "DROP" then
    return false
  end
  if e["dropWorld"] == "" then
    gb("DROP WORLD NOT SET - storage paused")
    Db(800)
    return false
  end
  if not tg(e["dropWorld"], "STORAGE") then
    gb("WAITING TO ENTER STORAGE WORLD")
    Db(900)
    return false
  end
  local t = c(w["seed"])
  if t <= ng() then
    f = "RETURN"
    return true
  end
  if not Pg(e["dropWorld"], V, e["dropY"], 3200) then
    gb("WAIT DROP STAND " .. (V .. ("," .. e["dropY"])))
    Db(500)
    return false
  end
  local P, Q = q()
  if P ~= V or Q ~= e["dropY"] then
    return false
  end
  local m = false
  for t = 1, 2, 1 do
    if not Fb() then
      return false
    end
    local U = c(w["seed"])
    if U <= ng() then
      f = "RETURN"
      return true
    end
    gb("DROP SEEDS " .. ((U - ng()) .. (" TRY " .. (t .. "/2"))))
    local W = Gg(U, U - ng())
    if W or c(w["seed"]) < U then
      m = true
      local t = math["max"](0, U - c(w["seed"]))
      g["stored"] = g["stored"] + t
      break
    end
    Db(600)
    if not Fb() then
      return false
    end
    P, Q = q()
    if P ~= V or Q ~= e["dropY"] then
      return false
    end
  end
  if m then
    if c(w["seed"]) <= ng() then
      f = "RETURN"
    end
    return true
  end
  if not Fb() then
    return false
  end
  P, Q = q()
  if P ~= V or Q ~= e["dropY"] then
    return false
  end
  if V <= 0 then
    gb("STORAGE FULL TO LEFT EDGE")
    Db(1500)
    return false
  end
  V = V - 1
  e["activeDropX"] = V
  l()
  gb("DROP FULL; SHIFT LEFT " .. (V .. ("," .. e["dropY"])))
  Db(700)
  return false
end
local function Ng(t)
  if e["storageMode"] == "OFF" or not b or not Mb() then
    return
  end
  local P = c(w["seed"])
  if P < e["storeAt"] or P <= e["keepSeeds"] then
    return
  end
  if t and (t["empty"] > 0 and (P < 200 and not Lb)) then
    return
  end
  if e["storageMode"] == "VENDING" then
    Fg()
  elseif e["storageMode"] == "DROP" then
    if e["dropWorld"] == "" then
      gb("SET DROP WORLD IN STORAGE SETTINGS")
      return
    end
    f = "DROP"
    gb("SEEDS READY TO STORE " .. P)
  end
end
local function bg()
  if not b or not Mb() or not Og() then
    return false
  end
  local t = c(w["seed"])
  if e["storageMode"] == "VENDING" then
    gb("PNB PAUSED: SEEDS " .. (t .. (" / " .. (e["storeAt"] .. "; VENDING STORAGE"))))
    if not Fg(false) and Og() then
      gb("PNB WAIT: VENDING DEPOSIT UNAVAILABLE; RETRYING")
      Db(math["max"](350, e["scanDelay"]))
    end
    return true
  end
  if e["dropWorld"] == "" then
    gb("PNB PAUSED: SEEDS " .. (t .. (" / " .. (e["storeAt"] .. "; SET DROP WORLD"))))
    Db(math["max"](350, e["scanDelay"]))
    return true
  end
  f = "DROP"
  gb("PNB PAUSED: SEEDS " .. (t .. (" / " .. (e["storeAt"] .. "; STORE FIRST"))))
  return true
end
local function Tg()
  return Mb()
end
local function hg()
  if Tg() then
    return true
  end
  if not e["autoResume"] then
    Ib("Left farm world")
    return false
  end
  if Z() - I > 2200 then
    I = Z()
    gb("RECOVERING FARM WORLD " .. Y)
    tg(Y, "FARM")
  end
  Db(250)
  return Tg()
end
local function Yg(t)
  if sb ~= t then
    sb = t
    Sb = Z()
    k("GF_stage", t)
    if t == "DRAIN_BLOCKS" or t == "POST_HARVEST_BLOCKS" then
      Ob = "BREAK"
    end
  end
end
local function Cg()
  local t = 0
  if Z() >= Ub then
    t = Qg(w["block"])
  end
  return (c(w["block"]) + t) + Zg()
end
local function gg()
  D = -100000
  local t = kg()
  Kb = "BLOCKS CLEAR | READY="
    .. (
      t["ready"] .. (
        " GROWING=" .. (t["growing"] .. (" SEEDS=" .. (c(w["seed"]) .. (" FLOOR_SEEDS=" .. Qg(w["seed"])))))
      )
    )
  return t
end
local function Eg()
  if not ab then
    return true
  end
  if Lb then
    return false
  end
  local t = math["max"](1, math["floor"](((e["growSeconds"] * 1000) * e["plantWindowPercent"]) / 100))
  local P = (e["treesPerWave"] * (e["plantDelay"] + 120)) * 2
  t = math["min"](e["growSeconds"] * 900, math["max"](t, P))
  if Z() - ab >= t then
    Lb = true
    return false
  end
  return true
end
local function Hg(t, P)
  if not ab then
    ab = t or Z()
  end
  kb = kb + (P or 1)
  jb = 0
end
local function Ig(t, P)
  local Q = t and t["chosenEmpty"]
  if not Q then
    return {}
  end
  local m = {}
  for t, P in ipairs(Lg(false)) do
    if P["y"] > Q["y"] or (P["y"] == Q["y"] and P["x"] > Q["x"] + 4) then
      break
    end
    if P["y"] == Q["y"] and (P["x"] >= Q["x"] and (P["x"] <= Q["x"] + 4 and (P["canPlant"] ~= false and ag(P)))) then
      local t = s(P["x"], P["y"])
      if t and tonumber(t["fg"]) == 0 then
        m[#m + 1] = { ["x"] = P["x"], ["y"] = P["y"] }
      end
    end
  end
  while #m > (P or 5) do
    table["remove"](m)
  end
  return m
end
local function rg(t)
  if #t == 0 then
    return false
  end
  local P, Q = t[1]["x"], t[#t]["x"]
  local m, e = Q - 2, P + 2
  local U = math["floor"]((P + Q) / 2)
  local W = { U, U - 1, U + 1, m, e }
  local K = {}
  for P, Q in ipairs(W) do
    if Q >= m and (Q <= e and (Q >= 0 and (Q <= 199 and not K[Q]))) then
      K[Q] = true
      local P = s(Q, t[1]["y"])
      if P and (tonumber(P["fg"]) == 0 and ob(Q, t[1]["y"], 1600)) then
        return true
      end
    end
  end
  return false
end
local function vg(t, P, Q)
  if not t or not t["chosenEmpty"] or c(w["seed"]) <= 0 or (not Q and not Eg()) then
    return false
  end
  local m = Ig(t, P or 5)
  if #m == 0 then
    return false
  end
  gb("PLANT BATCH UP TO 5 (LEFT 2 / CENTER / RIGHT 2)")
  if not rg(m) then
    qb[Kg(m[1]["x"], m[1]["y"])] = Z() + 7000
    return false
  end
  local e = select(1, q())
  local U = {}
  for t, P in ipairs(m) do
    if P["x"] ~= e then
      U[#U + 1] = P
    end
  end
  for t, P in ipairs(m) do
    if P["x"] == e then
      U[#U + 1] = P
    end
  end
  local W = 0
  local K = nil
  for t, P in ipairs(U) do
    if not b or not Mb() or c(w["seed"]) <= 0 or (not Q and not Eg()) then
      break
    end
    local e = false
    for t, P in ipairs(m) do
      local Q = s(P["x"], P["y"])
      if Q and xg(Q, P["x"], P["y"]) then
        e = true
        break
      end
    end
    if e then
      break
    end
    if Jg(P, true) then
      W = W + 1
      local t = nb[Kg(P["x"], P["y"])] or Z()
      if not K then
        K = t
      end
      if not ab then
        ab = t
      end
    end
  end
  if W > 0 then
    Hg(K, W)
    gb("PLANTED " .. (W .. "/5 TILES IN ONE BATCH"))
    return true
  end
  return false
end
local function ug(t)
  if not b or not Mb() or not t then
    return false
  end
  local P = t["growing"] + t["ready"]
  if t["ready"] > 0 or P >= e["treesPerWave"] then
    Jb = false
    lb = 0
    return false
  end
  if not Jb then
    if c(w["seed"]) <= e["treesPerWave"] or not t["chosenEmpty"] or Z() < Rb then
      return false
    end
    Jb = true
    lb = 0
    if P == 0 then
      ab = nil
      Lb = false
      kb = 0
    end
    gb("PNB: PLANT NEXT WAVE BEFORE BREAKING")
  end
  if not t["chosenEmpty"] or c(w["seed"]) <= 0 then
    Jb = false
    return false
  end
  if Z() < Rb then
    return true
  end
  local Q = math["min"](5, e["treesPerWave"] - P, c(w["seed"]))
  if Q <= 0 then
    Jb = false
    return false
  end
  if vg(t, Q, true) then
    lb = 0
    Rb = Z() + e["plantDelay"]
    gb("PREPLANT WHILE BREAKING: " .. (tostring(P + Q) .. ("/" .. (tostring(e["treesPerWave"]) .. " TREES TARGET"))))
    return true
  end
  lb = lb + 1
  if lb >= 3 then
    Jb = false
    Rb = Z() + 10000
    lb = 0
    gb("PREPLANT PATH FAILED; RESUMING BREAKING AND RETRY LATER")
    return false
  end
  Rb = Z() + math["max"](300, e["scanDelay"])
  return true
end
local function fg()
  local t = c(w["block"])
  local P = Qg(w["block"])
  if not b or not Mb() or t >= 200 or P <= 0 then
    return false
  end
  gb("COLLECT GRASS BEFORE PNB: " .. (t .. ("/200 + FLOOR " .. P)))
  local Q = false
  local m = 0
  for t = 1, 4, 1 do
    if not b or not Mb() or Og() then
      break
    end
    local P = c(w["block"])
    if P >= 200 or Qg(w["block"]) <= 0 then
      break
    end
    local U = Wg(false)
    if U then
      Db(math["max"](100, e["collectDelay"]))
    end
    if c(w["block"]) >= 200 or Qg(w["block"]) <= 0 then
      Q = true
      break
    end
    rb(true)
    local W = eg(w["block"])
    local K = c(w["block"])
    if K > P then
      Q = true
      m = 0
      Zb = "Collected " .. (K .. ("/200 Grass; floor " .. Qg(w["block"])))
    elseif W then
      Q = true
    else
      m = m + 1
      if m >= 2 then
        break
      end
    end
  end
  local U = c(w["block"])
  local W = Qg(w["block"])
  if U >= 200 then
    Zb = "BACKPACK FULL 200/200; PROCESS GRASS"
    Wb = 0
    return true
  end
  if W == 0 then
    Zb = "GROUND CLEAR; PROCESS " .. (U .. " AVAILABLE GRASS")
    Wb = 0
    return true
  end
  if Q then
    Zb = "FILLING BACKPACK " .. (U .. ("/200; " .. (W .. " ON FLOOR")))
    Wb = 0
    return true
  end
  Wb = Wb + 1
  Zb = "GRASS PICKUP RETRY " .. (Wb .. (" | " .. (U .. "/200")))
  if Wb >= 4 then
    Wb = 0
    if U > 0 then
      Ub = Z() + 12000
      Zb = "PICKUP DEFERRED; PROCESS " .. (U .. " GRASS FIRST")
    else
      Zb = "NO GRASS PICKUP ACK YET; RETRY FLOOR COLLECTION"
    end
    return false
  end
  return false
end
local function yg()
  if e["autoCollect"] then
    if Ob == "BREAK" then
      Wg(false)
    end
    rb(false)
  end
  if Ob == "BREAK" then
    local t = c(w["block"])
    local P = Zg()
    if t <= 0 and P <= 0 then
      Wg(true)
      Ob = "COLLECT"
      Zb = "GRASS REACHED 0; COLLECT NEXT FLOOR BATCH (MAX 200)"
      gb("GRASS 0/200: START COLLECT PHASE")
      return true
    end
    gb("PNB BREAK UNTIL 0 | BAG " .. (t .. (" | PNB " .. P)))
    local Q = zg(true)
    jb = jb + 1
    if c(w["block"]) <= 0 and Zg() <= 0 then
      Wg(true)
      Ob = "COLLECT"
      Zb = "BREAK COMPLETE; COLLECT ALL AVAILABLE GRASS"
    end
    return Q
  end
  Wg(false)
  local t = c(w["block"])
  local P = Qg(w["block"])
  if t >= 200 or (P <= 0 and t > 0) or (t > 0 and Z() < Ub) then
    Ob = "BREAK"
    Zb = "COLLECT COMPLETE: " .. (t .. " GRASS; RESUME PNB")
    gb("GRASS COLLECTED " .. (t .. "/200 -> BREAK TO 0"))
    return true
  end
  if t <= 0 and P <= 0 then
    Ob = "BREAK"
    Zb = "ALL GRASS CLEARED (BACKPACK AND FLOOR EMPTY)"
    return false
  end
  if Z() < Ub then
    if t > 0 then
      Ob = "BREAK"
      return true
    end
    Zb = "WAITING TO RETRY GRASS FLOOR PICKUP"
    return false
  end
  local Q = t
  local m = fg()
  t = c(w["block"])
  P = Qg(w["block"])
  if t >= 200 or (P <= 0 and t > 0) or (t > 0 and Z() < Ub) then
    Ob = "BREAK"
    Zb = "COLLECT COMPLETE: " .. (t .. " GRASS; RESUME PNB")
    return true
  end
  gb("COLLECT GRASS UNTIL MAX | BAG " .. (t .. ("/200 | FLOOR " .. P)))
  return m or t > Q
end
local function pg()
  Xb = true
  local t, P = pcall(yg)
  Xb = false
  if not t then
    error(P)
  end
  return P
end
local function Vg()
  T = true
  local t, P = xpcall(function()
    gb("STARTUP: WAITING FOR WORLD / PLAYER / TILES")
    local t = 0
    while b and not G() do
      gb("WAITING FOR NEW WORLD TO LOAD (" .. (math["floor"](t / 1000) .. "s)"))
      Db(500)
      t = t + 500
      if t >= 30000 then
        gb("WORLD NOT READY; WAITING / RETRYING (STOP TO CANCEL)")
        t = 0
      end
    end
    if not b then
      return
    end
    gb("STARTUP: READING CROP SETTINGS")
    if not N() then
      Ib("Cannot resolve selected crop IDs")
      return
    end
    hb["template"] = dg()
    if e["farmWorld"] == "" then
      e["farmWorld"] = z()
    end
    if not e["positionSaved"] then
      local t, P = q()
      if not t then
        Ib("Set Farm Position while inside the farm world")
        return
      end
      e["farmX"], e["farmY"] = t, P
      e["positionSaved"] = true
    end
    L()
    l()
    V = e["activeDropX"]
    Y = e["farmWorld"]
    C = { ["x"] = e["farmX"], ["y"] = e["farmY"] }
    local P = n(Y)
    if P ~= z() then
      gb("SAVED FARM IS " .. (Y .. ("; CURRENT IS " .. (z() .. ". USE FARM WORLD = CURRENT WORLD TO CHANGE"))))
      Db(500)
    end
    B = nil
    D = -100000
    o = ""
    A = 0
    i = 0
    Ub = 0
    Wb = 0
    Kb = ""
    ab = nil
    Lb = false
    kb = 0
    Jb = false
    lb = 0
    Rb = 0
    Zb = "Waiting for Grass drops"
    zb = "Waiting for PnB drops"
    v = {}
    E = -100000
    Ob = "BREAK"
    Xb = false
    qb = {}
    nb = {}
    Gb = {}
    wb = {}
    Nb = {}
    bb = "Ready to find harvest trees"
    f = nil
    jb = 0
    cb = false
    local Q = 0
    local m = 0
    local U = -100000
    local W = nil
    local K = 0
    local a = false
    Yg("INITIAL_SCAN")
    gb("STARTUP: SCANNING PLANTING TERRAIN (" .. (mb .. " TILES)"))
    O(150)
    while b do
      if f == "DROP" then
        wg()
        Db(100)
      elseif f == "RETURN" then
        if tg(Y, "RETURN FARM") and ob(C["x"], C["y"], 3500) then
          f = nil
          gb("BACK AT FARM AFTER SEED STORAGE")
        else
          gb("WAIT RETURN TO FARM")
          Db(650)
        end
      elseif not Tg() then
        hg()
      else
        if not W or Z() - U >= math["max"](e["scanDelay"], Pb) then
          W = kg()
          U = Z()
        end
        local t = W
        rb(false)
        local P = (sb == "DRAIN_BLOCKS" or sb == "POST_HARVEST_BLOCKS")
        local L = false
        if P and (t["valid"] > 0 and (t["ready"] == 0 and (Cg() > 0 and (Jb or c(w["seed"]) > e["treesPerWave"])))) then
          L = ug(t)
        end
        if L then
          W = nil
          K = 0
          Eb(false)
          Db(100)
        elseif P and bg() then
          Eb(false)
          Db(100)
        elseif t["valid"] == 0 then
          gb("NO VALID PLANT BED: CHECK TERRAIN ID / SUPPORT FLOOR | " .. eb)
          W = nil
          Db(math["max"](1000, e["scanDelay"]))
        else
          local P = t["growing"] + t["ready"]
          if
            t["ready"] > 0
            and (
              sb ~= "HARVEST" and (
                sb ~= "DRAIN_BLOCKS" and (sb ~= "STORE_BEFORE_HARVEST" and sb ~= "POST_HARVEST_BLOCKS")
              )
            )
          then
            Lb = true
            Yg("DRAIN_BLOCKS")
          end
          if sb == "INITIAL_SCAN" then
            kb = math["min"](P, e["treesPerWave"])
            if P > 0 then
              ab = Z()
            end
            if t["ready"] > 0 then
              Yg("DRAIN_BLOCKS")
            elseif P < e["treesPerWave"] and (t["chosenEmpty"] and c(w["seed"]) > 0) then
              Yg("INITIAL_PLANT")
            elseif P > 0 or Cg() > 0 then
              Yg("DRAIN_BLOCKS")
            else
              Yg("INITIAL_PLANT")
            end
          elseif sb == "INITIAL_PLANT" then
            if t["ready"] > 0 then
              Lb = true
              Yg("DRAIN_BLOCKS")
            elseif kb >= e["treesPerWave"] or P >= e["treesPerWave"] or not Eg() or not t["chosenEmpty"] then
              Lb = true
              Yg("DRAIN_BLOCKS")
            elseif c(w["seed"]) > 0 and Z() >= Q then
              local m = math["min"](5, e["treesPerWave"] - kb, e["treesPerWave"] - P)
              if m <= 0 then
                Lb = true
                Yg("DRAIN_BLOCKS")
              elseif vg(t, m) then
                W = nil
                Q = Z() + e["plantDelay"]
                K = 0
              else
                K = K + 1
                if K >= 4 then
                  D = -100000
                  W = nil
                  K = 0
                  gb("PLANT BATCH BLOCKED; RESCAN NEXT TILE")
                end
                Db(e["scanDelay"])
              end
            elseif c(w["seed"]) <= 0 then
              if Qg(w["seed"]) > 0 and Z() - m > 1000 then
                m = Z()
                eg(w["seed"])
              elseif Cg() > 0 or P > 0 then
                Lb = true
                Yg("DRAIN_BLOCKS")
              else
                Yg("WAIT_FOR_SEEDS")
                gb("NO GRASS SEEDS: WAIT / SEARCH FLOOR")
                Db(math["max"](500, e["scanDelay"]))
              end
            else
              Db(80)
            end
          elseif sb == "DRAIN_BLOCKS" then
            if Cg() > 0 then
              if pg() then
                K = 0
              else
                K = K + 1
              end
              if K >= 8 then
                gb("DRAIN WAIT: BLOCKS REMAIN, RECHECKING PATH/INVENTORY")
                K = 0
                Db(600)
              end
            else
              Wg(true)
              gb("VERIFY GRASS BLOCKS CLEARED")
              Db(math["max"](220, e["scanDelay"]))
              rb(true)
              if Cg() == 0 then
                W = gg()
                gb("LAST GRASS CLEARED -> SEED STORAGE / HARVEST")
                Yg("STORE_BEFORE_HARVEST")
              end
            end
          elseif sb == "STORE_BEFORE_HARVEST" then
            if Cg() > 0 then
              Yg("DRAIN_BLOCKS")
            elseif Og() then
              if e["storageMode"] == "DROP" then
                if e["dropWorld"] == "" then
                  if not a then
                    J("Ground Drop World is not set. Storage skipped for now; set it in Ground Drop Settings.")
                    a = true
                  end
                  gb("STORAGE SKIPPED (NO DROP WORLD); CONTINUE HARVEST")
                  Yg("HARVEST")
                else
                  a = false
                  f = "DROP"
                  gb("STORE SEEDS ABOVE " .. e["keepSeeds"])
                end
              elseif e["storageMode"] == "VENDING" then
                if Fg(true) then
                  Yg("HARVEST")
                else
                  gb("VENDING DEPOSIT NOT ACKNOWLEDGED - RETRY LATER")
                  Db(math["max"](600, e["scanDelay"]))
                end
              end
            else
              Yg("HARVEST")
            end
          elseif sb == "HARVEST" then
            if t["chosenReady"] then
              gb("HARVEST ALL READY TREES (TOP LEFT FIRST)")
              if Rg(t["chosenReady"]) then
                cb = true
                xb = Z()
                K = 0
                W = nil
                Db(180)
                rb(true, "AFTER_HARVEST")
              else
                K = K + 1
                if K >= 3 then
                  gb("TREE NOT SERVER READY - RECHECKING IN 5 SECONDS")
                  K = 0
                end
                Db(math["max"](500, e["scanDelay"]))
              end
            elseif t["ready"] > 0 then
              gb("READY TREES FOUND; RETRYING HARVEST PATH")
              W = nil
              Db(math["max"](600, e["scanDelay"]))
            elseif Cg() > 0 then
              Yg("POST_HARVEST_BLOCKS")
            elseif t["growing"] > 0 then
              Yg("WAIT_GROWTH")
            else
              Yg("NEXT_PLANTING_WAVE")
            end
          elseif sb == "POST_HARVEST_BLOCKS" then
            if t["ready"] > 0 then
              Yg("HARVEST")
            elseif Cg() > 0 then
              gb("AFTER HARVEST: PICK UP / BREAK ALL GRASS")
              if pg() then
                K = 0
              else
                K = K + 1
                if K >= 5 then
                  rb(true)
                  Db(math["max"](350, e["scanDelay"]))
                  K = 0
                end
              end
            else
              Wg(true)
              Db(math["max"](180, e["scanDelay"]))
              if Cg() == 0 then
                local t = gg()
                W = t
                if t["ready"] > 0 then
                  Yg("HARVEST")
                elseif t["growing"] > 0 then
                  gb("GRASS CLEARED; WAIT NEXT TREE HARVEST")
                  Yg("WAIT_GROWTH")
                else
                  gb("GRASS CLEARED; START NEXT PLANTING WAVE")
                  Yg("NEXT_PLANTING_WAVE")
                end
              end
            end
          elseif sb == "NEXT_PLANTING_WAVE" then
            if Og() and (e["storageMode"] == "DROP" and e["dropWorld"] ~= "") then
              f = "DROP"
              gb("POST-BREAK: STORE EXCESS SEEDS; THEN REPLANT")
            elseif t["ready"] > 0 then
              Yg("HARVEST")
            elseif Cg() > 0 then
              Yg("POST_HARVEST_BLOCKS")
            elseif t["growing"] > 0 then
              Yg("WAIT_GROWTH")
            elseif c(w["seed"]) > 0 and t["chosenEmpty"] then
              ab = nil
              Lb = false
              kb = 0
              jb = 0
              qb = {}
              W = nil
              K = 0
              Yg("INITIAL_PLANT")
              gb("NEXT WAVE: PLANT UP TO " .. (e["treesPerWave"] .. " TREES"))
            elseif c(w["seed"]) > 0 and not t["chosenEmpty"] then
              qb = {}
              D = -100000
              gb("NO OPEN PLANTING TERRAIN; RESCANNING / WAITING")
              Db(math["max"](600, e["scanDelay"]))
            elseif Qg(w["seed"]) > 0 then
              gb("AFTER HARVEST: COLLECT GRASS SEEDS")
              eg(w["seed"])
              Db(math["max"](200, e["scanDelay"]))
            else
              Yg("WAIT_FOR_SEEDS")
            end
          elseif sb == "WAIT_FOR_SEEDS" then
            if Cg() > 0 then
              Yg("POST_HARVEST_BLOCKS")
            elseif t["ready"] > 0 then
              Yg("HARVEST")
            elseif t["growing"] > 0 then
              Yg("WAIT_GROWTH")
            elseif c(w["seed"]) > 0 then
              Yg("NEXT_PLANTING_WAVE")
            elseif Qg(w["seed"]) > 0 then
              gb("NO SEEDS IN BAG: PICKING UP FLOOR SEEDS")
              eg(w["seed"])
            else
              gb("WAIT SEEDS: NO TREES, BLOCKS OR FLOOR SEEDS; WILL RETRY")
              rb(true)
            end
            Db(math["max"](250, e["scanDelay"]))
          elseif sb == "WAIT_GROWTH" then
            if t["ready"] > 0 then
              Yg("DRAIN_BLOCKS")
            elseif Cg() > 0 then
              Yg("DRAIN_BLOCKS")
            elseif t["growing"] == 0 then
              Yg("NEXT_PLANTING_WAVE")
            else
              local t = math["max"](0, e["growSeconds"] * 1000 - (Z() - (ab or Z())))
              gb("WAITING FOR TREE HARVEST; NEXT CHECK ~" .. (math["ceil"](t / 1000) .. "s"))
              Db(e["scanDelay"])
            end
          else
            Yg("INITIAL_SCAN")
          end
        end
        Eb(false)
        Db(70)
      end
    end
  end, function(t)
    return tostring(t)
  end)
  T = false
  hb["waiting"] = false
  hb["learning"] = false
  if not t then
    Ib("Worker error: " .. (tostring(P)):sub(1, 180))
  end
  Eb(true)
end
function onVariant(t, P)
  if t and (t["v1"] == "OnDialogRequest" and type(t["v2"]) == "string") then
    if b and (y and t["v2"]:find("drop_item", 1, true)) then
      p = true
      return true
    end
    if hb["waiting"] and t["v2"]:find("vend", 1, true) then
      hb["dialog"] = t["v2"]
      return true
    end
  end
  return false
end
function onSendPacket(t, P)
  if hb["learning"] and (type(P) == "string" and P:find("action|dialog_return", 1, true)) then
    hb["recorded"][#hb["recorded"] + 1] = P
  end
  return false
end
local Bg = UserInterface["new"](t, "Leaf")
Bg:addLabelApp("Grass / Crop Factory", "Leaf")
Bg:addToggle("Start / Stop", false, "GF_run")
Bg:addItemPicker(
  "Block to Farm",
  tostring(e["blockID"] > 0 and e["blockID"] or M("Grass") or 0),
  "Choose crop block",
  "GF_blockpicker"
)
Bg:addItemPicker("Planting Terrain", tostring(e["terrainID"]), "Choose support terrain (0 = Auto)", "GF_terrainpicker")
Bg:addInputString(
  "Farm World (Manual)",
  e["farmWorld"],
  "WORLD|DOORID",
  "FARMWORLD or FARMWORLD|DOORID",
  nil,
  "GF_world"
)
Bg:addButton("Farm World = Current World", "GF_worldcurrent")
Bg:addDisplayList(
  "Farm Position / Coordinates",
  (e["farmWorld"] ~= "" and e["farmWorld"] or "CURRENT WORLD") .. (" | X=" .. (e["farmX"] .. (" Y=" .. e["farmY"]))),
  "GF_farmpos"
)
Bg:addInputInt("Farm Position X", tostring(e["farmX"]), "X", "0", nil, "GF_x")
Bg:addInputInt("Farm Position Y", tostring(e["farmY"]), "Y", "0", nil, "GF_y")
Bg:addButton("Farm Position = Current Tile", "GF_poscurrent")
Bg:addDisplayList("Status", "STOPPED", "GF_status")
Bg:addDisplayList("Inventory", "Block / Seed", "GF_inventory")
Bg:addDisplayList("Resolved Items", "Grass / Grass Seed", "GF_itemstatus")
Bg:addDisplayList("Planting Terrain / Row Order", "Not scanned", "GF_plantpos")
Bg:addDisplayList("Tree Harvest Path", "Not attempted", "GF_harvestpath")
Bg:addDisplayList("Factory Stage", "Not started", "GF_stage")
Bg:addDisplayList("Last Grass Clearance", "No checkpoint yet", "GF_cyclecheck")
Bg:addDisplayList("Grass Block Pickup", "Waiting for drops", "GF_blockpickup")
Bg:addDisplayList("PnB All-Item Pickup", "Waiting for PnB drops", "GF_breakdrops")
Bg:addDisplayList("Planting Wave / Tree Target", "Target " .. e["treesPerWave"], "GF_wave")
Bg:addDisplayList(
  "Storage Mode / Active Drop",
  e["storageMode"] .. (" | drop stand " .. (e["activeDropX"] .. ("," .. e["dropY"]))),
  "GF_storage"
)
Bg:addDisplayList("Production Counts", "0", "GF_counts")
Bg:addDisplayList("Growing / Ready Trees", "No trees scanned", "GF_trees")
Bg:addDisplayList("Instant AutoSave", W, "GF_save")
local Dg = Bg:addDialog("Planting & Growth", "Configurable trees per wave; up to 5 per standing position", {})
Bg:addChildInputInt(
  Dg["menu"],
  "Planting Terrain ID (0 = Auto)",
  tostring(e["terrainID"]),
  "support block ID",
  "0",
  nil,
  "GF_terrainid"
)
Bg:addChildButton(Dg["menu"], "Auto Detect Planting Terrain", "GF_autoterrain")
Bg:addChildInputInt(Dg["menu"], "Grow Time (seconds)", tostring(e["growSeconds"]), "sec", "68", nil, "GF_grow")
Bg:addChildInputInt(
  Dg["menu"],
  "Trees per Planting Wave",
  tostring(e["treesPerWave"]),
  "trees (default 20)",
  "20",
  nil,
  "GF_treesperwave"
)
Bg:addChildInputInt(Dg["menu"], "Plant Delay", tostring(e["plantDelay"]), "ms", "250", nil, "GF_plantdelay")
Bg:addChildInputInt(Dg["menu"], "Ready Harvest Scan Delay", tostring(e["scanDelay"]), "ms", "250", nil, "GF_scan")
Bg:addChildToggle(Dg["menu"], "Auto Resume When Out of Farm", e["autoResume"], "GF_resume")
local og = Bg:addDialog("Break / Place", "Break backpack Grass to 0, collect up to 200, repeat", {})
Bg:addChildInputInt(og["menu"], "Punches Per Tile", tostring(e["hitsPerTile"]), "hits", "1", nil, "GF_hits")
Bg:addChildInputInt(og["menu"], "Punch Delay", tostring(e["punchDelay"]), "ms", "180", nil, "GF_punchdelay")
Bg:addChildInputInt(og["menu"], "Place Delay", tostring(e["placeDelay"]), "ms", "200", nil, "GF_placedelay")
Bg:addChildToggle(og["menu"], "Auto Collect (Break + Collect + After Harvest)", e["autoCollect"], "GF_collect")
Bg:addChildInputInt(og["menu"], "Auto Collect Delay", tostring(e["collectDelay"]), "ms", "160", nil, "GF_collectdelay")
local Ag = Bg:addDialog("Seed Storage Mode", "Ground Drop by default; enable Vending to use vending storage", {})
Bg:addChildToggle(Ag["menu"], "Use Vending Storage", e["storageMode"] == "VENDING", "GF_usevending")
Bg:addChildInputInt(Ag["menu"], "Store When Seeds Reach", tostring(e["storeAt"]), "seeds", "180", nil, "GF_storeat")
Bg:addChildInputInt(Ag["menu"], "Keep Seeds In Backpack", tostring(e["keepSeeds"]), "seeds", "40", nil, "GF_keep")
local ig = Bg:addDialog("Vending Settings", "Same-world vending, learned once", {})
Bg:addChildInputInt(
  ig["menu"],
  "Retry Vending After",
  tostring(e["vendorRetrySeconds"]),
  "sec",
  "20",
  nil,
  "GF_vendretry"
)
Bg:addChildInputInt(
  ig["menu"],
  "Manual Learn Timeout",
  tostring(e["manualLearnSeconds"]),
  "sec",
  "60",
  nil,
  "GF_learntime"
)
Bg:addChildButton(ig["menu"], "Clear Learned Vending Template", "GF_cleartpl")
local t3 = Bg:addDialog("Ground Drop Settings", "WORLD|DOORID and shift left after 2 failed drops", {})
Bg:addChildInputString(t3["menu"], "Drop World", e["dropWorld"], "WORLD|DOORID", "STORAGE|DOOR1", nil, "GF_dropworld")
Bg:addChildButton(t3["menu"], "Set Drop World = Current World", "GF_dropworldcurrent")
Bg:addChildInputInt(t3["menu"], "Drop Position X", tostring(e["dropX"]), "X", "0", nil, "GF_dropx")
Bg:addChildInputInt(t3["menu"], "Drop Position Y", tostring(e["dropY"]), "Y", "0", nil, "GF_dropy")
Bg:addChildButton(t3["menu"], "Set Drop Position = Current Tile", "GF_dropposcurrent")
Bg:addChildButton(t3["menu"], "Reset Shifted Drop X to Original X", "GF_resetdropx")
Bg:addDivider()
Bg:addInputInt("Block ID (0 = Grass auto-detect)", tostring(e["blockID"]), "ID", "0", nil, "GF_blockid")
Bg:addDivider()
Bg:addToggle("Auto Ban Player When Joining Farm", e["autoBanOnJoin"], "GF_autobanjoin")
local P3 = Bg:generateJSON()
pcall(function()
  if type(addCategory) == "function" then
    addCategory(t, "Leaf")
  end
end)
local Q3 = pcall(function()
  addIntoModule(P3, t)
end)
if not Q3 then
  pcall(function()
    addIntoModule(P3)
  end)
end
local m3 = {
  ["GF_x"] = { "farmX", 0, 199 },
  ["GF_y"] = { "farmY", 0, 119 },
  ["GF_terrainid"] = { "terrainID", 0, 65535 },
  ["GF_grow"] = { "growSeconds", 1, 86400 },
  ["GF_plantdelay"] = { "plantDelay", 20, 10000 },
  ["GF_window"] = { "plantWindowPercent", 5, 95 },
  ["GF_sweeps"] = { "pnbSweepsPerPlant", 1, 100 },
  ["GF_treesperwave"] = { "treesPerWave", 1, 150 },
  ["GF_scan"] = { "scanDelay", 50, 5000 },
  ["GF_hits"] = { "hitsPerTile", 1, 12 },
  ["GF_punchdelay"] = { "punchDelay", 20, 5000 },
  ["GF_placedelay"] = { "placeDelay", 20, 5000 },
  ["GF_collectdelay"] = { "collectDelay", 50, 5000 },
  ["GF_storeat"] = { "storeAt", 1, 200 },
  ["GF_keep"] = { "keepSeeds", 0, 199 },
  ["GF_dropx"] = { "dropX", 0, 199 },
  ["GF_dropy"] = { "dropY", 0, 119 },
  ["GF_vendretry"] = { "vendorRetrySeconds", 5, 600 },
  ["GF_learntime"] = { "manualLearnSeconds", 10, 180 },
  ["GF_blockid"] = { "blockID", 0, 65535 },
}
local e3 = {
  ["GF_resume"] = "autoResume",
  ["GF_stopempty"] = "stopWhenEmpty",
  ["GF_collect"] = "autoCollect",
  ["GF_autobanjoin"] = "autoBanOnJoin",
}
function onValue(t, P, Q)
  if x[P] then
    return
  end
  if P == "GF_run" then
    if Q == true then
      if b or T then
        return
      end
      b = true
      pb()
      runThread(function()
        O(250)
        if b then
          Vg()
        end
      end)
    else
      b = false
      pb()
      hb["waiting"] = false
      hb["learning"] = false
      y = false
      p = false
      f = nil
      gb("STOPPED (manual)")
    end
    return
  end
  if P == "GF_autoterrain" then
    e["terrainID"] = 0
    i = 0
    B = nil
    D = -100000
    k("GF_terrainid", 0)
    l()
    Eb(true)
    J("Planting terrain set to automatic detection.")
    return
  end
  if P == "GF_terrainpicker" then
    if b then
      J("Stop farming before changing the planting terrain.")
      return
    end
    local t = F(Q)
    if t and t > 0 then
      e["terrainID"] = t
      i = 0
      B = nil
      D = -100000
      k("GF_terrainid", t)
      l()
      Eb(true)
      J("Planting only on terrain ID " .. t)
    end
    return
  end
  if P == "GF_blockpicker" then
    if b then
      J("Stop farming before changing the crop.")
      return
    end
    local t = F(Q)
    if t and t > 0 then
      e["blockID"] = t
      i = 0
      B = nil
      D = -100000
      k("GF_blockid", t)
      l()
      J("Block to Farm: " .. (t .. (" | Seed: " .. (t + 1))))
    end
    return
  end
  if P == "GF_cleartpl" then
    hb["template"] = nil
    if U then
      pcall(function()
        U:set("vend_tpl", "")
        U:set("factory_vend_tpl_seed", "")
        U:save()
      end)
    end
    J("Grass Factory: learned vending template cleared.")
    return
  end
  if P == "GF_usevending" then
    if b then
      x["GF_usevending"] = true
      pcall(function()
        if type(editToggle) == "function" then
          editToggle("GF_usevending", e["storageMode"] == "VENDING")
        elseif type(EditToggle) == "function" then
          EditToggle("GF_usevending", e["storageMode"] == "VENDING")
        end
      end)
      x["GF_usevending"] = nil
      J("Stop farming before switching storage mode.")
      return
    end
    local t = (Q == true or (tostring(Q)):lower() == "true" or tostring(Q) == "1")
    e["storageMode"] = t and "VENDING" or "DROP"
    l()
    Eb(true)
    J("Seed Storage: " .. (t and "VENDING" or "GROUND DROP"))
    return
  end
  if P == "GF_worldcurrent" then
    local t = z()
    if t ~= "" and t ~= "EXIT" then
      local P = n(e["farmWorld"])
      e["farmWorld"] = t
      k("GF_world", t)
      if P ~= t or not e["positionSaved"] then
        local t, P = q()
        if t then
          e["farmX"], e["farmY"] = t, P
          e["positionSaved"] = true
          k("GF_x", t)
          k("GF_y", P)
          J("New farm world: saved current X/Y as the farm station. You can change them manually.")
        end
      end
      B = nil
      D = -100000
      l()
      Eb(true)
    end
    return
  end
  if P == "GF_poscurrent" then
    local t, P = q()
    if t then
      e["farmX"], e["farmY"] = t, P
      e["positionSaved"] = true
      if e["farmWorld"] == "" then
        local t = z()
        if t ~= "" and t ~= "EXIT" then
          e["farmWorld"] = t
          k("GF_world", t)
        end
      end
      k("GF_x", t)
      k("GF_y", P)
      B = nil
      l()
      Eb(true)
    end
    return
  end
  if P == "GF_dropworldcurrent" then
    local t = z()
    if t ~= "" and t ~= "EXIT" then
      e["dropWorld"] = t
      k("GF_dropworld", t)
      l()
      Eb(true)
    end
    return
  end
  if P == "GF_dropposcurrent" then
    local t, P = q()
    if t then
      e["dropX"], e["dropY"] = t, P
      e["activeDropX"] = t
      V = t
      k("GF_dropx", t)
      k("GF_dropy", P)
      l()
      Eb(true)
    end
    return
  end
  if P == "GF_resetdropx" then
    e["activeDropX"] = e["dropX"]
    V = e["dropX"]
    l()
    Eb(true)
    return
  end
  if P == "GF_world" or P == "GF_dropworld" then
    if P == "GF_world" then
      e["farmWorld"] = ((tostring(Q or "")):upper()):gsub("%s+", "")
    else
      e["dropWorld"] = ((tostring(Q or "")):upper()):gsub("%s+", "")
    end
    l()
    Eb(true)
    return
  end
  if e3[P] then
    e[e3[P]] = (Q == true or tostring(Q) == "true")
    if P == "GF_autobanjoin" then
      pb()
    end
    l()
    return
  end
  local m = m3[P]
  if m then
    local t = tonumber(Q)
    if t then
      e[m[1]] = a(t, m[2], m[3], e[m[1]])
      if P == "GF_x" or P == "GF_y" then
        e["positionSaved"] = true
      end
      if P == "GF_terrainid" then
        B = nil
        D = -100000
      end
      if P == "GF_dropx" then
        e["activeDropX"] = e["dropX"]
        V = e["dropX"]
      end
      l()
      Eb(true)
    end
  end
end
applyHook()
k(
  "GF_farmpos",
  (e["farmWorld"] ~= "" and e["farmWorld"] or "CURRENT WORLD") .. (" | X=" .. (e["farmX"] .. (" Y=" .. e["farmY"])))
)
k(
  "GF_plantpos",
  "Terrain " .. (
      (e["terrainID"] > 0 and e["terrainID"] or "Auto") .. " | Top-left row order | up to 5 per planting move"
    )
)
k("GF_storage", e["storageMode"] .. (" | drop stand " .. (V .. ("," .. e["dropY"]))))
