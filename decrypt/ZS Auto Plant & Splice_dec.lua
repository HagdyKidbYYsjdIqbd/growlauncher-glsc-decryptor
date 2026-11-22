ZS_LABEL_WIDTH = ZS_LABEL_WIDTH or 30
if not ZS_HUB then
  ZS_HUB = { ["native"] = addHook, ["callbacks"] = {}, ["installed"] = {} }
  local P = {
    ["onvalue"] = "onValue",
    ["ondrawimgui"] = "onDrawImGui",
    ["onvariant"] = "onVariant",
    ["ondialog"] = "onDialog",
    ["onsendpacket"] = "onSendPacket",
    ["onsendpacketraw"] = "onSendPacketRaw",
  }
  local J = {
    ["onValue"] = "onvalue",
    ["onDrawImGui"] = "ondrawimgui",
    ["OnVariant"] = "onvariant",
    ["OnDialog"] = "ondialog",
    ["OnSendPacket"] = "onsendpacket",
    ["OnSendPacketRaw"] = "onsendpacketraw",
  }
  local function v(J)
    if ZS_HUB["installed"][J] then
      return
    end
    ZS_HUB["installed"][J] = true
    local v = ZS_HUB["callbacks"][J]
    ZS_HUB["native"](function(...)
      local P = false
      for V = 1, #v, 1 do
        local t, a = pcall(v[V], ...)
        if not t then
          local P = "Hook error (" .. (J .. ("): " .. tostring(a)))
          if growtopia and type(growtopia["notify"]) == "function" then
            pcall(growtopia["notify"], P)
          else
            print(P)
          end
        elseif a == true then
          P = true
        end
      end
      return P
    end, P[J] or J)
  end
  function addHook(P, V)
    if type(P) ~= "function" then
      return
    end
    V = V or "onvalue"
    V = J[V] or (tostring(V)):lower()
    if not ZS_HUB["callbacks"][V] then
      ZS_HUB["callbacks"][V] = {}
    end
    table["insert"](ZS_HUB["callbacks"][V], P)
    v(V)
  end
end
if not ZS_thread then
  function ZS_thread(P)
    runThread(P)
  end
end
if not ZS_label then
  function ZS_label(P, J, ...)
    J = tostring(J == nil and "" or J)
    local v = ZS_LABEL_WIDTH
    local function V(P)
      if utf8 and utf8["len"] then
        return utf8["len"](P) or #P
      end
      return #P
    end
    local t, a = {}, ""
    for P in J:gmatch("%S+") do
      if a == "" then
        a = P
      elseif (V(a) + 1) + V(P) <= v then
        a = a .. (" " .. P)
      else
        t[#t + 1] = a
        a = P
      end
    end
    if a ~= "" then
      t[#t + 1] = a
    end
    if #t == 0 then
      t[1] = J
    end
    for J, v in ipairs(t) do
      P:addLabel(v, ...)
    end
  end
end
if not ZS_CATEGORY_ADDED then
  ZS_CATEGORY_ADDED = true
  if type(addCategory) == "function" then
    pcall(addCategory, "ZS", "Shield")
  end
end
local P = { ["tag"] = "k06", ["life"] = "ZSA-PLANT", ["unlocked"] = false, ["entered"] = "", ["n"] = 0 }
local function J(P)
  if growtopia and type(growtopia["notify"]) == "function" then
    pcall(growtopia["notify"], tostring(P))
  else
    print("[ZS] " .. tostring(P))
  end
end
local v = J
local V = addHook
local function t(J, v)
  if type(J) ~= "function" then
    return
  end
  return V(function(...)
    if not P["unlocked"] then
      return false
    end
    return J(...)
  end, v)
end
local function a(P)
  local J = tostring(P)
  local v, V = J:find('"menu"%s*:%s*%[')
  if not v then
    return nil
  end
  local t, a, K, C = 1, V + 1, false, false
  while a <= #J do
    local P = J:sub(a, a)
    if K then
      if C then
        C = false
      elseif P == "\\" then
        C = true
      elseif P == '"' then
        K = false
      end
    elseif P == '"' then
      K = true
    elseif P == "[" then
      t = t + 1
    elseif P == "]" then
      t = t - 1
      if t == 0 then
        return J:sub(V + 1, a - 1)
      end
    end
    a = a + 1
  end
end
local function K()
  P["n"] = P["n"] + 1
  local J = UserInterface["new"]("ZS ACCESS", "Lock")
  J:addLabelApp("* ACCESS KEY *", "Lock")
  ZS_label(J, "Enter your key. You can look around, but everything works only after unlock.")
  J:addInputString("Enter Key", "", "Enter Key", "Your key", "Key", "zskey_" .. (P["tag"] .. ("_" .. P["n"])))
  J:addButton("UNLOCK", "zsunl_" .. (P["tag"] .. ("_" .. P["n"])))
  J:addDivider()
  return J
end
local C = addIntoModule
local function M(J, v, ...)
  if type(J) == "string" and not J:find("zskey_" .. (P["tag"] .. "_"), 1, true) then
    local P, V = pcall(function()
      local P = K()
      local v = a(P:generateJSON())
      local V, t = J:find('"menu"%s*:%s*%[')
      if not (v and V) then
        return nil
      end
      local C = J:sub(t + 1)
      local M = C:match("^%s*%]") and "" or ","
      return J:sub(1, t) .. (v .. (M .. C))
    end)
    if P and V then
      J = V
    else
      pcall(function()
        C((K()):generateJSON(), v)
      end)
    end
  end
  return C(J, v, ...)
end
local function Y(...)
  local v = select("#", ...)
  local V = { ... }
  local t, a = "zskey_" .. (P["tag"] .. "_"), "zsunl_" .. (P["tag"] .. "_")
  local function K(P)
    if type(P) ~= "string" then
      return nil
    end
    if P:sub(1, #t) == t then
      return "key"
    end
    if P:sub(1, #a) == a then
      return "btn"
    end
  end
  local C, M
  local function Y(P, J)
    if C or J > 2 then
      return
    end
    if type(P) == "string" then
      C = K(P)
    elseif type(P) == "table" then
      for v, V in pairs(P) do
        if K(V) then
          C = K(V)
          M = P["value"] or P["text"] or P["v2"]
          return
        end
        if K(v) then
          C = K(v)
          M = V
          return
        end
        if type(V) == "table" then
          Y(V, J + 1)
        end
      end
    end
  end
  for P = 1, v, 1 do
    Y(V[P], 0)
    if C then
      if M == nil then
        M = V[P + 1]
      end
      break
    end
  end
  if C == "key" then
    P["entered"] = tostring(M or "")
    return true
  elseif C == "btn" then
    local v = ((P["entered"]:upper()):gsub("%s+", ""))
    if v == P["life"]:upper() then
      P["unlocked"] = true
      J("Key accepted. Unlocked!")
    else
      J("Invalid key.")
    end
    return true
  end
  return false
end
V(Y, "onvalue")
local A = false
local b = false
local Z = {}
local f = 250
local D = "zs_plant_splice_checkpoint.txt"
local F = ""
local R = ""
local function W()
  if not io or type(io["open"]) ~= "function" then
    return false
  end
  local P = io["open"](D, "w")
  if not P then
    return false
  end
  P:write("mode=", tostring(R), "\n")
  P:write("world=", tostring(F), "\n")
  for J, v in pairs(Z) do
    P:write("seed=", tostring(J), "|", tostring(v), "\n")
  end
  P:close()
  return true
end
local function d(P)
  if not io or type(io["open"]) ~= "function" then
    return false
  end
  local J = io["open"](D, "r")
  if not J then
    return false
  end
  local v, V, t = "", "", {}
  for P in J:lines() do
    local J = P:match("^mode=(.*)$")
    local a = P:match("^world=(.*)$")
    local K, C = P:match("^seed=(.-)|([%d%.%-]+)$")
    if J then
      v = J
    end
    if a then
      V = a
    end
    if K and C then
      t[K] = tonumber(C) or 0
    end
  end
  J:close()
  if v == P then
    Z = t
    F = V
    R = v
    return true
  end
  return false
end
local function N(P)
  if growtopia and type(growtopia["notify"]) == "function" then
    pcall(growtopia["notify"], tostring(P))
  else
    print("[ZS Auto Splice & Plant] " .. tostring(P))
  end
end
local function i()
  if type(os) == "table" and type(os["time"]) == "function" then
    return os["time"]()
  end
  if type(getTime) == "function" then
    return getTime()
  end
  return 0
end
local function g(P)
  local J
  pcall(function()
    J = getValue(1, P)
  end)
  if type(J) ~= "number" or J <= 0 then
    local v
    pcall(function()
      v = getValue(2, P)
    end)
    if type(v) == "table" then
      J = tonumber(v["id"] or v["itemID"] or v["itemid"] or v["value"])
    else
      J = tonumber(v)
    end
    if not J and (type(v) == "string" and v:match("%S")) then
      local P = v:match("^%s*(.-)%s*$")
      if growtopia and type(growtopia["getItemID"]) == "function" then
        local v, V = pcall(growtopia["getItemID"], P)
        if v then
          J = tonumber(V)
        end
      end
    end
  end
  if type(J) ~= "number" or J <= 0 then
    return nil
  end
  J = math["floor"](J)
  if J % 2 == 0 then
    J = J + 1
  end
  return J
end
local function k(P)
  if not growtopia or type(growtopia["checkInventoryCount"]) ~= "function" then
    return 0
  end
  local J, v = pcall(growtopia["checkInventoryCount"], P)
  if J then
    return tonumber(v) or 0
  end
  return 0
end
local function l(P, J)
  if type(GetTile) ~= "function" then
    return nil
  end
  local v, V = pcall(GetTile, P, J)
  if v then
    return V
  end
  return nil
end
local function x(P)
  return tonumber(P and P["fg"]) or 0
end
local function E()
  if type(GetLocal) ~= "function" then
    return nil
  end
  local P, J = pcall(GetLocal)
  if P then
    return J
  end
  return nil
end
local function I(P, J)
  local v = E()
  if not v or not v["posX"] or not v["posY"] then
    return false
  end
  return math["abs"](v["posX"] / 32 - P) <= 2 and math["abs"](v["posY"] / 32 - J) <= 2
end
local function w(P, J, v)
  local V = E()
  if not V or type(SendPacketRaw) ~= "function" then
    return false
  end
  local t = pcall(
    SendPacketRaw,
    false,
    { ["x"] = V["posX"], ["y"] = V["posY"], ["px"] = J, ["py"] = v, ["type"] = 3, ["value"] = P }
  )
  return t
end
local function U(P, J)
  return Z[P .. ("," .. J)] ~= nil
end
local function u(P, J)
  local v = l(P, J + 1)
  local V = x(v)
  return V > 0 and (V ~= 6 and V % 2 == 0)
end
local function j(P, J, v, V)
  if not P or not P["x"] or not P["y"] then
    return nil
  end
  local t, a = tonumber(P["x"]), tonumber(P["y"])
  if not t or not a or not u(t, a) then
    return nil
  end
  local K = l(t, a)
  if not K then
    return nil
  end
  local C = x(K)
  if C == 0 then
    return "EMPTY"
  end
  if V and U(t, a) then
    if C == J then
      return "NEEDS_SPLICE_2"
    end
    if C == v then
      return "NEEDS_SPLICE_1"
    end
  end
  return nil
end
local function p(P, J)
  local v = x(l(P, J))
  return v == 0 or v % 2 == 1
end
local function e(P)
  table["sort"](P, function(P, J)
    if P["y"] == J["y"] then
      return P["x"] < J["x"]
    end
    return P["y"] < J["y"]
  end)
  local J, v = {}, 1
  while v <= #P do
    local V = P[v]
    local t = { V }
    local a = v + 1
    while a <= #P and (P[a]["y"] == V["y"] and P[a]["x"] <= V["x"] + 2) do
      t[#t + 1] = P[a]
      a = a + 1
    end
    J[#J + 1] = t
    v = a
  end
  return J
end
local function G(P, J, v, V)
  local t = {}
  if type(GetTiles) ~= "function" then
    return t
  end
  local a, K = pcall(GetTiles)
  if not a or type(K) ~= "table" then
    return t
  end
  for a, K in pairs(K) do
    local C, M = tonumber(K and K["x"]), tonumber(K and K["y"])
    if C and M then
      local a = { ["x"] = math["floor"](C), ["y"] = math["floor"](M) }
      local K = a["x"] .. ("," .. a["y"])
      if (V[K] or 0) < 3 and j(a, P, J, v) then
        t[#t + 1] = a
      end
    end
  end
  return e(t)
end
local function o(P)
  local J = P[1]
  local v, V = J["x"] + 1, J["y"]
  if not p(v, V) then
    v = J["x"]
  end
  if type(FindPath) == "function" then
    pcall(FindPath, v, V)
  end
  Sleep(f)
end
local function m(P, J, v, V)
  local t = x(l(P["x"], P["y"]))
  if t == 0 then
    return false
  end
  if V and (U(P["x"], P["y"]) and (t == J or t == v)) then
    return false
  end
  return true
end
local function z(P, J, v, V, t, a)
  local K = j(P, J, v, V)
  if not K then
    return true
  end
  if K == "EMPTY" then
    if k(J) <= 0 then
      return false, "noseed1"
    end
    if V and k(v) <= 0 then
      return false, "noseed2"
    end
    if not w(J, P["x"], P["y"]) then
      return false, "packet"
    end
    Z[P["x"] .. ("," .. P["y"])] = i()
    W()
    Sleep(t)
    K = V and "NEEDS_SPLICE_2" or nil
  elseif K == "NEEDS_SPLICE_1" then
    if k(J) <= 0 then
      return false, "noseed1"
    end
    if not w(J, P["x"], P["y"]) then
      return false, "packet"
    end
    Sleep(t)
    K = nil
  end
  if V and K == "NEEDS_SPLICE_2" then
    if k(v) <= 0 then
      return false, "noseed2"
    end
    Sleep(a)
    if not w(v, P["x"], P["y"]) then
      return false, "packet"
    end
    W()
    Sleep(t)
  end
  return true
end
local function c(P, J)
  local v = J["x"] .. ("," .. J["y"])
  P[v] = (P[v] or 0) + 1
end
local function H(P, J, v, V, t, a, K)
  local C = {}
  for P, t in ipairs(P) do
    if not m(t, J, v, V) then
      C[#C + 1] = t
    end
  end
  local M, Y = 0, {}
  while #C > 0 and not b do
    o(P)
    Sleep(f)
    local K = {}
    for P, C in ipairs(C) do
      if b then
        return M, "stop"
      end
      if not I(C["x"], C["y"]) then
        local P, J = C["x"] + 1, C["y"]
        if not p(P, J) then
          P = C["x"] - 1
        end
        if type(FindPath) == "function" then
          pcall(FindPath, P, J)
        end
        Sleep(f * 2)
      end
      if not m(C, J, v, V) then
        local P, A = z(C, J, v, V, t, a)
        if not P then
          if A == "noseed1" or A == "noseed2" then
            return M, A
          end
          K[#K + 1] = C
        else
          Sleep(math["max"](t, 250))
          if not m(C, J, v, V) then
            K[#K + 1] = C
          elseif not Y[C["x"] .. ("," .. C["y"])] then
            Y[C["x"] .. ("," .. C["y"])] = true
            M = M + 1
          end
        end
      elseif not Y[C["x"] .. ("," .. C["y"])] then
        Y[C["x"] .. ("," .. C["y"])] = true
        M = M + 1
      end
    end
    C = K
    W()
    if #C > 0 and not b then
      Sleep(500)
    end
  end
  if b then
    return M, "stop"
  end
  return M
end
local function O()
  local P
  if type(GetObjects) == "function" then
    local J, v = pcall(GetObjects)
    if J and type(v) == "table" then
      P = v
    end
  end
  if not P and type(GetObjectList) == "function" then
    local J, v = pcall(GetObjectList)
    if J and type(v) == "table" then
      P = v
    end
  end
  return P or {}
end
local function T(P)
  return tonumber(P and (P["itemid"] or P["itemID"] or P["item_id"]))
end
local function h(P)
  if not P then
    return nil, nil
  end
  local J = P["pos"] or P["position"]
  local v = (J and (J["x"] or J["posX"])) or P["x"] or P["posX"]
  local V = (J and (J["y"] or J["posY"])) or P["y"] or P["posY"]
  return tonumber(v), tonumber(V)
end
local function n(P, J)
  local v = 0
  while v < J do
    if type(GetWorldName) == "function" and (GetWorldName()):upper() == P:upper() then
      return true
    end
    Sleep(250)
    v = v + 250
  end
  return type(GetWorldName) == "function" and (GetWorldName()):upper() == P:upper()
end
local function L(P, J)
  local v = k(P)
  if v >= J then
    return true
  end
  local V = {}
  for J, v in pairs(O()) do
    local t, a = h(v)
    if T(v) == P and (t and a) then
      V[#V + 1] = { ["x"] = math["floor"](t / 32), ["y"] = math["floor"](a / 32), ["px"] = t, ["py"] = a }
    end
  end
  table["sort"](V, function(P, J)
    if P["y"] == J["y"] then
      return P["x"] < J["x"]
    end
    return P["y"] < J["y"]
  end)
  for v, V in ipairs(V) do
    if b then
      return false
    end
    if k(P) >= J then
      break
    end
    FindPath(V["x"], V["y"])
    Sleep(f + 150)
    Sleep(250)
  end
  return k(P) > v
end
local function s(P, J, v)
  local V = getValue(2, "zs_ap_storage_world")
  V = (tostring(V or "")):match("^%s*(.-)%s*$")
  if V == "" then
    N("Seed inventory is empty. Enter a Storage World first.")
    return false, "nostorage"
  end
  if not growtopia or type(growtopia["warpTo"]) ~= "function" then
    N("Cannot restock: warp API is unavailable.")
    return false, "storagefail"
  end
  local t = GetWorldName()
  local a = E()
  local K = a and math["floor"]((a["posX"] or 0) / 32) or nil
  local C = a and math["floor"]((a["posY"] or 0) / 32) or nil
  if not t or t == "EXIT" then
    return false, "storagefail"
  end
  N("Seed stock low. Going to Storage World: " .. (V .. "..."))
  if t:upper() ~= V:upper() then
    growtopia["warpTo"](V)
    if not n(V, 15000) then
      N("Could not enter Storage World: " .. V)
      return false, "storagefail"
    end
  end
  Sleep(800)
  L(P, 200)
  if v then
    L(J, 200)
  end
  local M = k(P)
  local Y = v and k(J) or 200
  local A = M > 0 and (not v or Y > 0)
  if t:upper() ~= V:upper() then
    growtopia["warpTo"](t)
    if not n(t, 15000) then
      N("Seeds collected, but could not return to farm world: " .. t)
      return false, "returnfail"
    end
  end
  if K and C then
    FindPath(K, C)
    Sleep(f)
  end
  if A then
    N("Restock complete. Seed 1: " .. (M .. ((v and (" | Seed 2: " .. Y) or "") .. ". Continuing...")))
    return true
  end
  N("Storage World does not have enough loose seeds. Seed 1: " .. (M .. ((v and (" | Seed 2: " .. Y) or "") .. ".")))
  return false, "storageempty"
end
local function q(P, J, v, V, t)
  local a = 0
  F = type(GetWorldName) == "function" and GetWorldName() or ""
  W()
  local K = {}
  local function C()
    local P = {}
    if type(GetTiles) ~= "function" then
      return
    end
    local J, v = pcall(GetTiles)
    if not J or type(v) ~= "table" then
      return
    end
    for J, v in pairs(v) do
      local V = tonumber(v and v["y"])
      if V then
        V = math["floor"](V)
        if not P[V] then
          P[V] = true
          K[#K + 1] = V
        end
      end
    end
    table["sort"](K)
  end
  C()
  for K, C in ipairs(K) do
    if b then
      return a, "stop"
    end
    local M = 0
    while not b do
      M = M + 1
      local K = {}
      if type(GetTiles) == "function" then
        local V, t = pcall(GetTiles)
        if V and type(t) == "table" then
          for V, t in pairs(t) do
            local a, M = tonumber(t and t["x"]), tonumber(t and t["y"])
            if a and (M and math["floor"](M) == C) then
              local V = { ["x"] = math["floor"](a), ["y"] = C }
              if j(V, P, J, v) then
                K[#K + 1] = V
              end
            end
          end
        end
      end
      if #K == 0 then
        N("Row " .. (tostring(C) .. " verified: no missed planting/splicing spots."))
        break
      end
      local Y = e(K)
      local A = false
      for K, C in ipairs(Y) do
        if b then
          return a, "stop"
        end
        if k(P) <= 0 or (v and k(J) <= 0) then
          local V, t = s(P, J, v)
          if not V then
            return a, t
          end
        end
        o(C)
        local M, Y = H(C, P, J, v, V, t, {})
        W()
        a = a + (M or 0)
        if (M or 0) > 0 then
          A = true
        end
        if Y == "stop" then
          return a, "stop"
        elseif Y == "noseed1" or Y == "noseed2" then
          local K, M = s(P, J, v)
          if not K then
            return a, M
          end
          local Y, b = H(C, P, J, v, V, t, {})
          a = a + (Y or 0)
          if (Y or 0) > 0 then
            A = true
          end
          if b then
            return a, b
          end
        elseif Y then
          return a, Y
        end
      end
      Sleep(400)
      local Z = {}
      local f, D = pcall(GetTiles)
      if f and type(D) == "table" then
        for V, t in pairs(D) do
          local a, K = tonumber(t and t["x"]), tonumber(t and t["y"])
          if a and (K and math["floor"](K) == C) then
            local V = { ["x"] = math["floor"](a), ["y"] = C }
            if j(V, P, J, v) then
              Z[#Z + 1] = V
            end
          end
        end
      end
      if #Z == 0 then
        N("Row " .. (tostring(C) .. " complete and verified."))
        break
      end
      if not A then
        N("Still checking row " .. (tostring(C) .. (": retrying " .. (tostring(#Z) .. " unfinished spots."))))
        Sleep(700)
      end
    end
  end
  if b then
    return a, "stop"
  end
  return a, "done"
end
local function S(P)
  local J, v = {}, {}
  P = tostring(P or "")
  for P in P:gmatch("[^,;\n]+") do
    P = P:match("^%s*(.-)%s*$")
    if P ~= "" then
      local V = P:upper()
      if not v[V] then
        v[V] = true
        J[#J + 1] = P
      end
    end
  end
  return J
end
local function r(P, J, v, V, t)
  local a = getValue(2, "zs_ap_worlds")
  local K = S(a)
  if #K == 0 then
    local P = type(GetWorldName) == "function" and GetWorldName() or nil
    if P and P ~= "EXIT" then
      K[1] = P
    end
  end
  if #K == 0 then
    return 0, "noworld"
  end
  if not growtopia or type(growtopia["warpTo"]) ~= "function" then
    return 0, "worldwarp"
  end
  local C = 0
  for a, K in ipairs(K) do
    if b then
      return C, "stop"
    end
    local M = type(GetWorldName) == "function" and GetWorldName() or ""
    if M:upper() ~= K:upper() then
      N("Going to farm world: " .. K)
      growtopia["warpTo"](K)
      if not n(K, 15000) then
        N("Could not enter farm world: " .. K)
        return C, "worldwarp"
      end
      Sleep(700)
    end
    F = K
    R = v and "splice" or "plant"
    W()
    local Y, A = q(P, J, v, V, t)
    C = C + (Y or 0)
    if A ~= "done" then
      return C, A
    end
  end
  return C, "done"
end
local function X(P)
  local J = P and "zs_as_seed1" or "zs_ap_seed1"
  local v = "zs_as_seed2"
  local V = g(J)
  local t = P and g(v) or nil
  if not V then
    N(P and "Choose Seed 1 in ZS Auto Splice first." or "Choose a seed in Auto Plant first.")
    A = false
    return
  end
  if P and (not t or t <= 0) then
    N("Choose Seed 2 in ZS Auto Splice first.")
    A = false
    return
  end
  if P and V == t then
    N("Seed 1 and Seed 2 must be different.")
    A = false
    return
  end
  if not E() then
    N("Player data is not available.")
    A = false
    return
  end
  local a = tonumber(getValue(2, "zs_ap_delay")) or 190
  local K = tonumber(getValue(2, "zs_ap_splice_delay")) or 200
  a = math["max"](60, math["min"](1000, math["floor"](a)))
  K = math["max"](100, math["min"](1000, math["floor"](K)))
  local C = P and "splice" or "plant"
  local M = d(C)
  R = C
  b = false
  if M then
    N("Recovery data loaded. Rechecking farm worlds and unfinished seed/splice spots before continuing.")
  else
    Z = {}
    N("New run started. Progress checkpoint will be saved when Lua file access is available.")
  end
  W()
  N("Auto Splice & Plant started. Working left-to-right in groups of 3; each group is verified before moving on.")
  local Y, f = r(V, t, P, a, K)
  A = false
  if f == "done" then
    N("Finished. Planted/spliced " .. (tostring(Y) .. " tiles."))
  elseif f == "noseed1" then
    N("Stopped: Seed 1 is empty. Planted/spliced " .. (tostring(Y) .. " tiles."))
  elseif f == "noseed2" then
    N("Stopped: Seed 2 is empty. Planted " .. (tostring(Y) .. " tiles; some may still need splicing."))
  elseif f == "nostorage" or f == "storagefail" or f == "storageempty" or f == "returnfail" then
    N("Stopped: automatic seed restock failed. Completed " .. (tostring(Y) .. " tiles."))
  elseif f == "blocked" then
    N("Stopped: some tiles could not be reached. Completed " .. (tostring(Y) .. " tiles."))
  elseif f == "noworld" or f == "worldwarp" then
    N("Stopped: farm world list is empty or a world could not be entered. Completed " .. (tostring(Y) .. " tiles."))
  else
    N("Stopped. Completed " .. (tostring(Y) .. " tiles."))
  end
end
local Q = UserInterface["new"]("ZS AUTO PLANT", "Park")
Q:addLabelApp("* ZS AUTO PLANT *", "Park")
Q:addTooltip(
  "AUTO PLANT",
  "Select a seed and add your farm and storage worlds. Turn AUTO PLANT ON to plant and restock automatically.",
  "Info",
  true
)
Q:addDivider()
Q:addItemPicker("Item To Farm", "Blank", "", "zs_ap_seed1")
Q:addInputString(
  "Worlds to Plant",
  "",
  "Worlds to Plant",
  "Enter worlds separated by commas; blank = current world",
  "Worlds",
  "zs_ap_worlds"
)
Q:addInputString(
  "Storage World",
  "",
  "Storage World",
  "Enter the world where loose seeds are stored",
  "World",
  "zs_ap_storage_world"
)
Q:addSlider("Plant Delay (ms)", 60, 1000, 190, 10, false, "zs_ap_delay")
Q:addDivider()
Q:addToggle("AUTO PLANT", false, "zs_ap_run", true)
M(Q:generateJSON(), "ZS")
local B = UserInterface["new"]("ZS AUTO SPLICE", "Park")
B:addLabelApp("* ZS AUTO SPLICE *", "Park")
B:addTooltip(
  "AUTO SPLICE",
  "Choose both seeds and add your farm and storage worlds. Turn AUTO SPLICE ON to plant, splice and restock automatically.",
  "Info",
  true
)
B:addDivider()
B:addItemPicker("Item To Farm", "Blank", "", "zs_as_seed1")
B:addItemPicker("Item To Farm", "Blank", "", "zs_as_seed2")
B:addInputString(
  "Worlds to Splice",
  "",
  "Worlds to Splice",
  "Enter worlds separated by commas; blank = current world",
  "Worlds",
  "zs_ap_worlds"
)
B:addInputString(
  "Storage World",
  "",
  "Storage World",
  "Enter the world where loose seeds are stored",
  "World",
  "zs_ap_storage_world"
)
B:addSlider("Plant Delay (ms)", 60, 1000, 190, 10, false, "zs_ap_delay")
B:addSlider("Splice Delay (ms)", 100, 1000, 200, 10, false, "zs_ap_splice_delay")
B:addDivider()
B:addToggle("AUTO SPLICE", false, "zs_as_run", true)
M(B:generateJSON(), "ZS")
t(function(P, J, v)
  if J == "zs_ap_run" or J == "zs_as_run" then
    local P = J == "zs_as_run"
    if v then
      if A then
        N("A planting task is already running.")
        return
      end
      A = true
      b = false
      ZS_thread(function()
        X(P)
      end)
    else
      b = true
      N((P and "AUTO SPLICE" or "AUTO PLANT") .. ": OFF. Current position will be kept.")
    end
  end
end, "onValue")
if type(applyHook) == "function" then
  pcall(applyHook)
end
