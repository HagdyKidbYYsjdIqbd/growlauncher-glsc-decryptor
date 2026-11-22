ZS_LABEL_WIDTH = ZS_LABEL_WIDTH or 30
if not ZS_HUB then
  ZS_HUB = { ["native"] = addHook, ["callbacks"] = {}, ["installed"] = {} }
  local z = {
    ["onvalue"] = "onValue",
    ["ondrawimgui"] = "onDrawImGui",
    ["onvariant"] = "onVariant",
    ["ondialog"] = "onDialog",
    ["onsendpacket"] = "onSendPacket",
    ["onsendpacketraw"] = "onSendPacketRaw",
  }
  local i = {
    ["onValue"] = "onvalue",
    ["onDrawImGui"] = "ondrawimgui",
    ["OnVariant"] = "onvariant",
    ["OnDialog"] = "ondialog",
    ["OnSendPacket"] = "onsendpacket",
    ["OnSendPacketRaw"] = "onsendpacketraw",
  }
  local function X(i)
    if ZS_HUB["installed"][i] then
      return
    end
    ZS_HUB["installed"][i] = true
    local X = ZS_HUB["callbacks"][i]
    ZS_HUB["native"](function(...)
      local z = false
      for o = 1, #X, 1 do
        local n, v = pcall(X[o], ...)
        if not n then
          local z = "Hook error (" .. (i .. ("): " .. tostring(v)))
          if growtopia and type(growtopia["notify"]) == "function" then
            pcall(growtopia["notify"], z)
          else
            print(z)
          end
        elseif v == true then
          z = true
        end
      end
      return z
    end, z[i] or i)
  end
  function addHook(z, o)
    if type(z) ~= "function" then
      return
    end
    o = o or "onvalue"
    o = i[o] or (tostring(o)):lower()
    if not ZS_HUB["callbacks"][o] then
      ZS_HUB["callbacks"][o] = {}
    end
    table["insert"](ZS_HUB["callbacks"][o], z)
    X(o)
  end
end
if not ZS_thread then
  function ZS_thread(z)
    runThread(z)
  end
end
if not ZS_label then
  function ZS_label(z, i, ...)
    i = tostring(i == nil and "" or i)
    local X = ZS_LABEL_WIDTH
    local function o(z)
      if utf8 and utf8["len"] then
        return utf8["len"](z) or #z
      end
      return #z
    end
    local n, v = {}, ""
    for z in i:gmatch("%S+") do
      if v == "" then
        v = z
      elseif (o(v) + 1) + o(z) <= X then
        v = v .. (" " .. z)
      else
        n[#n + 1] = v
        v = z
      end
    end
    if v ~= "" then
      n[#n + 1] = v
    end
    if #n == 0 then
      n[1] = i
    end
    for i, X in ipairs(n) do
      z:addLabel(X, ...)
    end
  end
end
if not ZS_CATEGORY_ADDED then
  ZS_CATEGORY_ADDED = true
  if type(addCategory) == "function" then
    pcall(addCategory, "ZS", "Shield")
  end
end
local z =
  { ["tag"] = "k01", ["life"] = "ZSA-SCI", ["master"] = "ZSA-PRO", ["unlocked"] = false, ["entered"] = "", ["n"] = 0 }
local function i(z)
  if growtopia and type(growtopia["notify"]) == "function" then
    pcall(growtopia["notify"], tostring(z))
  else
    print("[ZS] " .. tostring(z))
  end
end
local X = i
local o = addHook
local function n(i, X)
  if type(i) ~= "function" then
    return
  end
  return o(function(...)
    if not z["unlocked"] then
      return false
    end
    return i(...)
  end, X)
end
local function v(z)
  local i = tostring(z)
  local X, o = i:find('"menu"%s*:%s*%[')
  if not X then
    return nil
  end
  local n, v, E, h = 1, o + 1, false, false
  while v <= #i do
    local z = i:sub(v, v)
    if E then
      if h then
        h = false
      elseif z == "\\" then
        h = true
      elseif z == '"' then
        E = false
      end
    elseif z == '"' then
      E = true
    elseif z == "[" then
      n = n + 1
    elseif z == "]" then
      n = n - 1
      if n == 0 then
        return i:sub(o + 1, v - 1)
      end
    end
    v = v + 1
  end
end
local function E()
  z["n"] = z["n"] + 1
  local i = UserInterface["new"]("ZS ACCESS", "Lock")
  i:addLabelApp("* ACCESS KEY *", "Lock")
  ZS_label(i, "Enter your key. You can look around, but everything works only after unlock.")
  i:addInputString("Enter Key", "", "Enter Key", "Your key", "Key", "zskey_" .. (z["tag"] .. ("_" .. z["n"])))
  i:addButton("UNLOCK", "zsunl_" .. (z["tag"] .. ("_" .. z["n"])))
  i:addDivider()
  return i
end
local h = addIntoModule
local function T(i, X, ...)
  if type(i) == "string" and not i:find("zskey_" .. (z["tag"] .. "_"), 1, true) then
    local z, o = pcall(function()
      local z = E()
      local X = v(z:generateJSON())
      local o, n = i:find('"menu"%s*:%s*%[')
      if not (X and o) then
        return nil
      end
      local h = i:sub(n + 1)
      local T = h:match("^%s*%]") and "" or ","
      return i:sub(1, n) .. (X .. (T .. h))
    end)
    if z and o then
      i = o
    else
      pcall(function()
        h((E()):generateJSON(), X)
      end)
    end
  end
  return h(i, X, ...)
end
local function l(...)
  local X = select("#", ...)
  local o = { ... }
  local n, v = "zskey_" .. (z["tag"] .. "_"), "zsunl_" .. (z["tag"] .. "_")
  local function E(z)
    if type(z) ~= "string" then
      return nil
    end
    if z:sub(1, #n) == n then
      return "key"
    end
    if z:sub(1, #v) == v then
      return "btn"
    end
  end
  local h, T
  local function l(z, i)
    if h or i > 2 then
      return
    end
    if type(z) == "string" then
      h = E(z)
    elseif type(z) == "table" then
      for X, o in pairs(z) do
        if E(o) then
          h = E(o)
          T = z["value"] or z["text"] or z["v2"]
          return
        end
        if E(X) then
          h = E(X)
          T = o
          return
        end
        if type(o) == "table" then
          l(o, i + 1)
        end
      end
    end
  end
  for z = 1, X, 1 do
    l(o[z], 0)
    if h then
      if T == nil then
        T = o[z + 1]
      end
      break
    end
  end
  if h == "key" then
    z["entered"] = tostring(T or "")
    return true
  elseif h == "btn" then
    local X = ((z["entered"]:upper()):gsub("%s+", ""))
    if X == z["master"]:upper() then
      z["unlocked"] = true
      i("PRO key accepted. Unlocked!")
    elseif X == z["life"]:upper() then
      z["unlocked"] = true
      i("Key accepted. Unlocked!")
    else
      i("Invalid key.")
    end
    return true
  end
  return false
end
o(l, "onvalue")
local P = 75
local k = 110
local m = false
local s = false
local I = 1
local B = nil
local N = false
local R = { ["mode"] = "-", ["status"] = "Ready", ["world"] = "-", ["count"] = 0, ["drop"] = "not set" }
do
  local z = growtopia["notify"]
  pcall(function()
    growtopia["notify"] = function(i)
      R["status"] = ((tostring(i)):gsub("\n", " "))
      return z(i)
    end
  end)
end
local p = 928
local t = "Laboratory"
local K = 200
local A = 200
local d = 2
local H = 1200
local F = "Mysterious Chemical"
local x = { ["Chemical Y"] = 20, ["Chemical B"] = 10, ["Chemical P"] = 5 }
local r = {
  ["forcefield"] = {
    ["label"] = "Forcefield",
    ["result"] = "Forcefield",
    ["yield"] = 1,
    ["ingredients"] = { [F] = 1, ["Chemical G"] = 20 },
  },
  ["fuelpack"] = {
    ["label"] = "Fuelpack",
    ["result"] = "Fuel Pack",
    ["yield"] = 5,
    ["ingredients"] = { [F] = 1, ["Chemical G"] = 10, ["Chemical B"] = 2 },
  },
  ["mystery"] = { ["label"] = "Mystery Chemical", ["result"] = "Mysterious Chemical", ["yield"] = 1, ["ingredients"] = x },
}
local function j(z)
  return "Chemical " .. z
end
r["intellect"] = {
  ["label"] = "Enhanced Intellect",
  ["result"] = "Enhanced Intellect",
  ["yield"] = 1,
  ["ingredients"] = { [F] = 3, [j("B")] = 3, [j("Y")] = 3 },
}
r["shockhair"] = {
  ["label"] = "Shocking Hair",
  ["result"] = "Shocking Hair",
  ["yield"] = 1,
  ["ingredients"] = { [j("B")] = 1, [j("G")] = 30, [j("R")] = 4 },
}
r["slime"] = { ["label"] = "Slime", ["result"] = "Slime", ["yield"] = 4, ["ingredients"] = {
  [j("B")] = 4,
  [j("G")] = 15,
  [j("P")] = 2,
} }
r["steeltable"] = {
  ["label"] = "Steel Table",
  ["result"] = "Steel Table",
  ["yield"] = 5,
  ["ingredients"] = { [j("B")] = 2, [j("G")] = 5, [j("Y")] = 4 },
}
r["zegoggles"] = {
  ["label"] = "Ze Goggles",
  ["result"] = "Ze Goggles",
  ["yield"] = 1,
  ["ingredients"] = { [j("B")] = 4, [j("P")] = 3, [j("R")] = 2 },
}
r["combover"] = {
  ["label"] = "Combover",
  ["result"] = "Combover",
  ["yield"] = 1,
  ["ingredients"] = { [j("Y")] = 10, [j("R")] = 5, [j("G")] = 5 },
}
r["shockinator"] = {
  ["label"] = "Shockinator",
  ["result"] = "Shockinator",
  ["yield"] = 1,
  ["ingredients"] = { [j("G")] = 10, [j("R")] = 5, [j("P")] = 1 },
}
r["labcoat"] = {
  ["label"] = "Lab Coat",
  ["result"] = "Lab Coat",
  ["yield"] = 1,
  ["ingredients"] = { [j("R")] = 20, [j("P")] = 20, [j("Y")] = 5 },
}
r["dragontail"] = {
  ["label"] = "Dragon Tail",
  ["result"] = "Dragon Tail",
  ["yield"] = 1,
  ["ingredients"] = { [j("G")] = 6, [j("P")] = 2, [j("Y")] = 3 },
}
local w = {
  "forcefield",
  "fuelpack",
  "mystery",
  "intellect",
  "shockhair",
  "slime",
  "steeltable",
  "zegoggles",
  "combover",
  "shockinator",
  "labcoat",
  "dragontail",
}
local J = {
  ["forcefield"] = "",
  ["fuelpack"] = "",
  ["mystery"] = "",
  ["intellect"] = "",
  ["shockhair"] = "",
  ["slime"] = "",
  ["steeltable"] = "",
  ["zegoggles"] = "",
  ["combover"] = "",
  ["shockinator"] = "",
  ["labcoat"] = "",
  ["dragontail"] = "",
}
local a =
  { [F] = "M", ["Chemical Y"] = "Y", ["Chemical G"] = "G", ["Chemical B"] = "B", ["Chemical P"] = "P", ["Chemical R"] = "R" }
local e = { F, "Chemical Y", "Chemical G", "Chemical B", "Chemical P", "Chemical R" }
local function C(z)
  local i = r[z]
  local X = {}
  for z, o in ipairs(e) do
    local n = i["ingredients"][o]
    if n then
      table["insert"](X, n .. a[o])
    end
  end
  local o = (z == "mystery") and "M" or i["label"]
  return o .. (" = " .. (table["concat"](X, " + ") .. ("  ->  " .. (i["yield"] or 1))))
end
local function W(z)
  return ((tostring(z or "")):match("^%s*(.-)%s*$"))
end
local function u(z)
  local i = {}
  if type(z) ~= "string" then
    return i
  end
  for z in z:gmatch("[^,]+") do
    z = W(z)
    if z ~= "" then
      table["insert"](i, z:upper())
    end
  end
  return i
end
local function Y(z, i)
  local X = 0
  while X < i and not s do
    if (GetWorldName()):upper() == z:upper() then
      return true
    end
    Sleep(250)
    X = X + 250
  end
  return (GetWorldName()):upper() == z:upper()
end
local function b(z, i)
  local X = GetLocal()
  if not X then
    return false
  end
  return math["abs"](X["posX"] / 32 - z) <= 2 and math["abs"](X["posY"] / 32 - i) <= 2
end
local function y(z, i)
  local X = GetLocal()
  SendPacketRaw(false, { ["x"] = X["posX"], ["y"] = X["posY"], ["px"] = z, ["py"] = i, ["type"] = 3, ["value"] = 18 })
end
local function q(z)
  return growtopia["checkInventoryCount"](z) or 0
end
local function Q(z)
  table["sort"](z, function(z, i)
    if z["x"] == i["x"] then
      return z["y"] < i["y"]
    end
    return z["x"] < i["x"]
  end)
end
local g = {}
local function G(z)
  local i = {}
  for z, X in pairs(z) do
    local o = growtopia["getItemID"](z)
    if type(o) ~= "number" or o <= 0 then
      growtopia["notify"]("Unknown item: " .. z)
      return nil
    end
    i[o] = X
    g[o] = z
  end
  return i
end
local function S(z)
  local i, X = {}, false
  for z, o in pairs(z) do
    local n = q(z)
    if n < o then
      i[z] = o - n
      X = true
    end
  end
  return i, X
end
local function c(z)
  return tonumber(z["itemid"] or z["id"] or z["itemID"] or z["itemId"] or z["item"])
end
local function L(z)
  if not z then
    return nil, nil
  end
  local i = z["pos"] or z["position"]
  local X = (i and (i["x"] or i["posX"])) or z["x"] or z["posX"]
  local o = (i and (i["y"] or i["posY"])) or z["y"] or z["posY"]
  return tonumber(X), tonumber(o)
end
local O
local function Z(z)
  Sleep(80)
  local i, X = {}, {}
  for o, n in pairs(GetObjectList()) do
    if s then
      return
    end
    local v = c(n)
    local E = (not z) or (v ~= nil and z[v])
    local h, T = L(n)
    if E and (h and T) then
      local z, o = math["floor"](h / 32), math["floor"](T / 32)
      local n = z .. (":" .. o)
      if not X[n] then
        X[n] = true
        i[#i + 1] = { ["x"] = z, ["y"] = o }
      end
    end
  end
  O(i)
  for i, X in ipairs(i) do
    if s then
      return
    end
    local o = {}
    if z then
      for z in pairs(z) do
        o[z] = q(z)
      end
    end
    FindPath(X["x"], X["y"])
    for i = 1, 8, 1 do
      if s then
        return
      end
      Sleep(180)
      local X = false
      if z then
        for z in pairs(z) do
          if q(z) > (o[z] or 0) then
            X = true
            break
          end
        end
      end
      if X then
        break
      end
    end
  end
end
O = function(z)
  table["sort"](z, function(z, i)
    if z["y"] == i["y"] then
      return z["x"] < i["x"]
    end
    return z["y"] < i["y"]
  end)
end
local function U(z, i, X)
  Sleep(60)
  local o, n = {}, {}
  for v, E in pairs(GetObjectList()) do
    local h, T = L(E)
    if h and T then
      local v, l = math["floor"](h / 32), math["floor"](T / 32)
      local P = c(E)
      local k = (not X) or (P ~= nil and X[P])
      local m = v .. (":" .. l)
      if k and (math["abs"](v - z) <= 2 and (math["abs"](l - i) <= 2 and not n[m])) then
        n[m] = true
        o[#o + 1] = { ["x"] = v, ["y"] = l }
      end
    end
  end
  Q(o)
  for z, i in ipairs(o) do
    if s then
      return
    end
    FindPath(i["x"], i["y"])
    Sleep(math["max"](P, 90))
  end
end
local D
local function f(z, i, X)
  local function o()
    local z
    if type(GetObjects) == "function" then
      local i, X = pcall(GetObjects)
      if i and type(X) == "table" then
        z = X
      end
    end
    if not z and type(GetObjectList) == "function" then
      local i, X = pcall(GetObjectList)
      if i and type(X) == "table" then
        z = X
      end
    end
    return z or {}
  end
  local function n(z, i, X)
    for o, n in pairs(o()) do
      if c(n) == z then
        local z, o = L(n)
        if z and (o and (math["floor"](z / 32) == i and math["floor"](o / 32) == X)) then
          return true
        end
      end
    end
    return false
  end
  local function v(z, i)
    local X = GetLocal()
    if not X then
      return false
    end
    local o = X["posX"] or (X["pos"] and X["pos"]["x"])
    local n = X["posY"] or (X["pos"] and X["pos"]["y"])
    if not o or not n then
      return false
    end
    return math["abs"](o / 32 - z) <= 1 and math["abs"](n / 32 - i) <= 1
  end
  local E, h = {}, {}
  while true do
    if s then
      return false
    end
    if X and D(X) then
      return true
    end
    local i = {}
    for X, o in pairs(o()) do
      if s then
        return false
      end
      local n = c(o)
      if n and (z and z[n]) then
        local z, X = L(o)
        if z and X then
          i[#i + 1] = {
            ["id"] = n,
            ["x"] = math["floor"](z / 32),
            ["y"] = math["floor"](X / 32),
            ["px"] = math["floor"](z),
            ["py"] = math["floor"](X),
          }
        end
      end
    end
    table["sort"](i, function(z, i)
      if z["y"] ~= i["y"] then
        return z["y"] < i["y"]
      end
      if z["x"] ~= i["x"] then
        return z["x"] < i["x"]
      end
      return z["id"] < i["id"]
    end)
    local T = false
    for z, i in ipairs(i) do
      if s then
        return false
      end
      if X and D(X) then
        return true
      end
      local o = tostring(i["id"]) .. (":" .. (tostring(i["px"]) .. (":" .. tostring(i["py"]))))
      if not E[o] then
        h[o] = (h[o] or 0) + 1
        if h[o] >= 3 then
          E[o] = true
        end
        FindPath(i["x"], i["y"])
        Sleep(P)
        if s then
          return false
        end
        if v(i["x"], i["y"]) then
          Sleep(k)
          if not n(i["id"], i["x"], i["y"]) then
            E[o] = true
          end
        end
        T = true
        if X and D(X) then
          return true
        end
      end
    end
    if not T then
      break
    end
    Sleep(250)
  end
  return X and D(X) or false
end
local function V(z)
  local i = {
    function()
      sendPacket(2, z)
    end,
    function()
      SendPacket(2, z)
    end,
    function()
      growtopia["sendPacket"](2, z)
    end,
    function()
      growtopia["SendPacket"](2, z)
    end,
  }
  for z, i in ipairs(i) do
    if pcall(i) then
      return true
    end
  end
  return false
end
local function M(z, i)
  local X = g[z] or tostring(z)
  local o = q(z)
  if o < i then
    growtopia["notify"]("Not enough " .. (X .. (" (" .. (o .. ("/" .. (i .. ")"))))))
    return false
  end
  local n = i
  local v = 0
  while n > 0 and v < 4 do
    if s then
      return false
    end
    local i = q(z)
    if i <= 0 then
      break
    end
    local X = math["min"](n, i)
    local o = false
    pcall(function()
      V("action|dialog_return\ndialog_name|drop_item\nbuttonClicked|cancel")
    end)
    Sleep(250)
    if type(growtopia["dropItem"]) == "function" then
      pcall(function()
        growtopia["dropItem"](z)
      end)
      Sleep(450)
      pcall(function()
        V(
          "action|dialog_return\ndialog_name|drop_item\nitemID|" .. (z .. ("\ncount|" .. (X .. "\nbuttonClicked|drop")))
        )
      end)
      for X = 1, 32, 1 do
        Sleep(250)
        local v = q(z)
        if v < i then
          local z = math["min"](i - v, n)
          n = n - z
          o = true
          break
        end
      end
    end
    if not o and (n > 0 and type(growtopia["confirmDropItem"]) == "function") then
      local i = q(z)
      pcall(function()
        growtopia["confirmDropItem"](z, X)
      end)
      for X = 1, 32, 1 do
        Sleep(250)
        local v = q(z)
        if v < i then
          local z = math["min"](i - v, n)
          n = n - z
          o = true
          break
        end
      end
    end
    if o then
      v = 0
      pcall(function()
        V("action|dialog_return\ndialog_name|drop_item\nbuttonClicked|cancel")
      end)
      Sleep(1100)
    else
      v = v + 1
      pcall(function()
        V("action|dialog_return\ndialog_name|drop_item\nbuttonClicked|cancel")
      end)
      Sleep(900)
    end
  end
  if n <= 0 then
    growtopia["notify"]("Dropped " .. (X .. (" x" .. i)))
    Sleep(700)
    return true
  end
  growtopia["notify"]("Drop incomplete: " .. (X .. (" (" .. ((i - n) .. ("/" .. (i .. ")"))))))
  return false
end
local function zW()
  local z = growtopia["getItemID"](t)
  if type(z) ~= "number" or z <= 0 then
    return nil
  end
  local i, X = nil, math["huge"]
  local o = GetLocal()
  local n, v = o["posX"] / 32, o["posY"] / 32
  for o, E in pairs(GetTiles()) do
    if E["fg"] == z then
      local z = math["abs"](E["x"] - n) + math["abs"](E["y"] - v)
      if z < X then
        i, X = E, z
      end
    end
  end
  return i
end
local function iW(z)
  FindPath(z["x"], z["y"])
  Sleep(P + 300)
  local i = GetLocal()
  local X = i and (math["abs"](i["posX"] / 32 - z["x"]) < 1 and math["abs"](i["posY"] / 32 - z["y"]) < 1)
  if not X then
    FindPath(z["x"], z["y"] - 1)
    Sleep(P + 300)
  end
  Sleep(500)
end
local function XW(z, i, X)
  X = X or 1
  local o = zW()
  if not o then
    growtopia["notify"]("Laboratory not found in this world.")
    return false
  end
  local n = i and growtopia["getItemID"](i)
  if type(n) ~= "number" or n <= 0 then
    n = nil
  end
  local v = n and q(n) or 0
  local E = { { { o["x"] - 2, o["y"] }, { o["x"] - 1, o["y"] } }, { { o["x"] + 2, o["y"] }, { o["x"] + 1, o["y"] } } }
  local h = false
  for z, i in ipairs(E) do
    FindPath(i[1][1], i[1][2])
    Sleep(P + 150)
    FindPath(i[2][1], i[2][2])
    Sleep(P + 250)
    if b(o["x"], o["y"]) then
      h = true
      break
    end
  end
  if not h then
    growtopia["notify"]("Could not reach the Laboratory.")
    return false
  end
  local T = {}
  for z, i in pairs(z) do
    T[#T + 1] = { ["id"] = z, ["amount"] = i }
  end
  table["sort"](T, function(z, i)
    local X = tostring(g[z["id"]] or z["id"])
    local o = tostring(g[i["id"]] or i["id"])
    return X < o
  end)
  for z, i in ipairs(T) do
    if s then
      return false
    end
    local n, v = i["id"], i["amount"] * X
    local E = q(n)
    local h = g[n] or ("Chemical/item " .. tostring(n))
    if E < v then
      growtopia["notify"](
        "Missing recipe ingredient " .. (z .. ("/" .. (#T .. (": " .. (h .. (" (" .. (E .. ("/" .. (v .. ").")))))))))
      )
      iW(o)
      return false
    end
    growtopia["notify"]("Lab drop " .. (z .. ("/" .. (#T .. (": " .. (h .. (" x" .. v)))))))
    if not M(n, v) then
      iW(o)
      return false
    end
    local l = q(n)
    if l > E - v then
      growtopia["notify"]("Ingredient drop not fully confirmed: " .. (h .. ". Stopping before Lab punch."))
      iW(o)
      return false
    end
    Sleep(350)
  end
  Sleep(k + 300)
  for z = 1, d, 1 do
    if s then
      return false
    end
    if not GetTile(o["x"], o["y"]) or (GetTile(o["x"], o["y"]))["fg"] ~= o["fg"] then
      growtopia["notify"]("Laboratory disappeared! Stopping.")
      return false
    end
    y(o["x"], o["y"])
    Sleep(H)
  end
  Sleep(600)
  iW(o)
  if n and q(n) <= v then
    growtopia["notify"]("Combine gave no result. Stopping (check the recipe/drop).")
    return false
  end
  local l = n and (q(n) - v) or 0
  return true, l
end
local oW = UserInterface["new"]("ZS AUTO SCIENCE!", "Science")
oW:addLabelApp("* ZS AUTO SCIENCE! *", "Science")
oW:addTooltip(
  "* AUTO SCIENCE! *",
  "Choose your collect worlds and lab world, select a recipe, then start it.\n\nThe script gathers chemicals, processes them in the Laboratory and collects the result.\n\nSet a drop position to automatically drop finished items when your inventory is full. Use STOP to pause safely.",
  "Info",
  true
)
oW:addDivider()
ZS_label(oW, "1. WORLDS")
oW:addInputString("Collect", "", "Collect worlds", "", "World", "sci_world_list")
oW:addInputString("Lab", "", "Lab world", "", "World", "sci_lab_world")
oW:addDivider()
ZS_label(oW, "2. SETTINGS")
oW:addSlider("Delay", 50, 1000, 190, 10, false, "sci_delay")
oW:addButton("SET DROP POSITION", "sci_setdrop")
oW:addDivider()
ZS_label(oW, "3. SELECT ITEMS")
for z, i in ipairs(w) do
  oW:addToggle(J[i] .. (" " .. r[i]["label"]), false, "sci_select_" .. i, true)
  ZS_label(oW, C(i))
end
oW:addDivider()
oW:addToggle("> AUTO SCIENCE - START / STOP", false, "sci_run", true)
T(oW:generateJSON(), "ZS")
local function nW(z)
  local i = {}
  local function X(z, X)
    i[z] = (i[z] or 0) + X
  end
  for i, o in pairs(z["ingredients"]) do
    if i == F and z["ingredients"] ~= x then
      for z, i in pairs(x) do
        X(z, i * o)
      end
    else
      X(i, o)
    end
  end
  local o = {}
  for z, i in pairs(i) do
    local X = growtopia["getItemID"](z)
    if type(X) ~= "number" or X <= 0 then
      growtopia["notify"]("Unknown item: " .. z)
      return nil
    end
    g[X] = z
    o[X] = i
  end
  return o
end
local function vW(z)
  local i = math["huge"]
  for z, X in pairs(z) do
    i = math["min"](i, math["floor"](q(z) / X))
  end
  if i == math["huge"] then
    i = 0
  end
  return i
end
local function EW(z, i)
  for z, X in pairs(z) do
    i = math["min"](i, math["floor"](200 / X))
  end
  return i
end
D = function(z)
  local i = r[z]
  local X = G(i["ingredients"])
  if not X then
    return false
  end
  local o = i["ingredients"][F]
  if not o then
    return vW(X) >= 1
  end
  local n = growtopia["getItemID"](F)
  local v = G(x)
  local E = {}
  for z, i in pairs(X) do
    if z ~= n then
      E[z] = i
    end
  end
  if vW(E) < 1 then
    return false
  end
  return q(n) >= o or vW(v) >= 1
end
local function hW(z)
  R["world"] = z
  if (GetWorldName()):upper() == z then
    return true
  end
  growtopia["warpTo"](z)
  if not Y(z, 15000) then
    return false
  end
  Sleep(700)
  return true
end
local function TW(z, i, X)
  local o = growtopia["getItemID"](z["result"])
  if type(o) ~= "number" or o <= 0 then
    return true
  end
  if not X and q(o) < A then
    return true
  end
  if q(o) <= 0 then
    return true
  end
  g[o] = z["result"]
  if not B then
    growtopia["notify"](z["label"] .. (" reached " .. (A .. "! Press SET DROP POSITION. Stopping.")))
    return false
  end
  growtopia["notify"]("Full stack! Going to the drop position...")
  if not hW(B["world"]) then
    return false
  end
  FindPath(B["x"], B["y"])
  Sleep(P + 400)
  local n = M(o, math["min"](q(o), A))
  Sleep(600)
  if not hW(i) then
    return false
  end
  return n
end
local function lW(z, i)
  local X = r[z]
  local o = X["yield"] or 1
  local n = G(X["ingredients"])
  if not n then
    return "fail"
  end
  local v = growtopia["getItemID"](X["result"])
  if type(v) ~= "number" or v <= 0 then
    growtopia["notify"]("Unknown item: " .. X["result"])
    return "fail"
  end
  local E = X["ingredients"][F]
  local h = E and growtopia["getItemID"](F)
  local T = E and G(x)
  local l
  if E then
    l = {}
    for z, i in pairs(n) do
      if z ~= h then
        l[z] = i
      end
    end
  end
  local P = 0
  while not s do
    local z = math["floor"]((A - q(v)) / o)
    if z < 1 then
      if not TW(X, i, true) then
        return s and "stop" or "halt"
      end
      z = math["floor"]((A - q(v)) / o)
      if z < 1 then
        return "halt"
      end
    end
    local k = false
    if E then
      local z = EW(l, vW(l))
      local i = z * E - q(h)
      if i > 0 then
        local z = math["min"](i, vW(T))
        z = EW(T, z)
        z = math["min"](z, A - q(h))
        if z >= 1 then
          growtopia["notify"]("Combine: " .. (F .. (" x" .. z)))
          if not XW(T, F, z) then
            return s and "stop" or "halt"
          end
          k = true
        end
      end
    end
    if not k then
      local i = EW(n, vW(n))
      i = math["min"](i, z)
      if i < 1 then
        break
      end
      growtopia["notify"]("Combine: " .. (X["label"] .. (" x" .. (i * o))))
      local v, E = XW(n, X["result"], i)
      if not v then
        return s and "stop" or "halt"
      end
      P = P + (E or 0)
      R["count"] = R["count"] + (E or 0)
    end
    Sleep(400)
  end
  if s then
    return "stop"
  end
  return P > 0 and "done" or "nochem"
end
local function PW(z)
  local i = 0
  for z in pairs(z) do
    i = i + q(z)
  end
  return i
end
local function kW(z)
  local i = r[z]
  local X = nW(i)
  if not X then
    return "fail"
  end
  local o = u(getValue(2, "sci_world_list"))
  if #o == 0 then
    o = { (GetWorldName()):upper() }
  end
  local n = (u(getValue(2, "sci_lab_world")))[1] or (GetWorldName()):upper()
  local v = false
  local E = 0
  for i = 1, 100, 1 do
    if s then
      return "stop"
    end
    local h = false
    if D(z) then
      growtopia["notify"]("Recipe chemicals ready. Going to Laboratory...")
      if not hW(n) then
        return "fail"
      end
      local i = lW(z, n)
      if i == "stop" then
        return "stop"
      end
      if i == "halt" or i == "fail" then
        return i
      end
      if i == "done" then
        v = true
      end
    end
    for i, o in ipairs(o) do
      if s then
        return "stop"
      end
      I = i
      if not hW(o) then
        growtopia["notify"]("Could not enter: " .. o)
      else
        local i = PW(X)
        growtopia["notify"]("Scanning " .. (o .. " for required chemicals..."))
        f(X, true, z)
        if s then
          return "stop"
        end
        if PW(X) > i then
          h = true
        end
        if D(z) then
          growtopia["notify"]("Required chemicals collected. Going to Laboratory...")
          if not hW(n) then
            return "fail"
          end
          local i = lW(z, n)
          if i == "stop" then
            return "stop"
          end
          if i == "halt" or i == "fail" then
            return i
          end
          if i == "done" then
            v = true
          end
        end
      end
    end
    if h then
      E = 0
    else
      E = E + 1
      if E >= 3 then
        break
      end
      growtopia["notify"]("No new chemicals yet. Re-scanning worlds (" .. (E .. "/3)..."))
      Sleep(1400)
    end
  end
  if s then
    return "stop"
  end
  return v and "done" or "nochem"
end
local function mW(z)
  local i = getValue(1, "sci_delay")
  if type(i) == "number" and i >= 50 then
    k = i
    P = math["max"](40, i)
  end
  local X = r[z]["label"]
  growtopia["notify"](X .. " started.")
  local o = kW(z)
  if o == "done" then
    growtopia["notify"](X .. (" finished. All available chemicals processed. Total made: " .. R["count"]))
  elseif o == "nochem" then
    growtopia["notify"](X .. ": no complete recipe chemicals available in the selected worlds.")
  elseif o == "halt" then
    growtopia["notify"](X .. " stopped: Laboratory combine failed. Check the lab/drop.")
  elseif o == "fail" then
    growtopia["notify"](X .. " stopped: could not complete the laboratory cycle.")
  elseif o == "stop" then
    growtopia["notify"](X .. " stopped by user.")
  end
end
local sW = {}
local function IW()
  if m then
    growtopia["notify"]("Auto Science is already running.")
    return
  end
  local z = {}
  for i, X in ipairs(w) do
    if sW[X] then
      table["insert"](z, X)
    end
  end
  if #z == 0 then
    growtopia["notify"]("Select at least one item toggle first.")
    return
  end
  m = true
  s = false
  pcall(EditToggle, "ModFly", true)
  R["count"] = 0
  growtopia["notify"]("Auto Science started for " .. (#z .. " selected item(s)."))
  ZS_thread(function()
    for z, i in ipairs(z) do
      if s then
        break
      end
      mW(i)
    end
    m = false
    pcall(EditToggle, "ModFly", false)
    I = 1
    if s then
      growtopia["notify"]("Auto Science stopped.")
    else
      growtopia["notify"]("All selected items completed.")
    end
  end)
end
n(function(z, i, X)
  if type(i) == "string" and i:sub(1, 11) == "sci_select_" then
    local z = i:sub(12)
    if r[z] then
      sW[z] = X and true or false
      growtopia["notify"](r[z]["label"] .. (sW[z] and " selected." or " deselected."))
    end
  elseif i == "sci_run" then
    if X then
      IW()
    else
      s = true
      growtopia["notify"]("Auto Science stop requested.")
    end
  elseif i == "sci_setdrop" then
    local z = GetLocal()
    if z then
      B = { ["world"] = (GetWorldName()):upper(), ["x"] = math["floor"](z["posX"] / 32), ["y"] = math["floor"](
        z["posY"] / 32
      ) }
      R["drop"] = B["world"] .. (" (" .. (B["x"] .. (", " .. (B["y"] .. ")"))))
      growtopia["notify"]("Drop position set: " .. R["drop"])
    end
  end
end, "onValue")
growtopia["notify"]("* Welcome to Auto SCIENCE! *\nCreator: ZadStay")
if type(applyHook) == "function" then
  pcall(applyHook)
end
