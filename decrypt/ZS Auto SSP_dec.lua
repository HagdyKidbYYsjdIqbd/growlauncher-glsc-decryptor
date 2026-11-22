ZS_LABEL_WIDTH = ZS_LABEL_WIDTH or 30
if not ZS_HUB then
  ZS_HUB = { ["native"] = addHook, ["callbacks"] = {}, ["installed"] = {} }
  local j = {
    ["onvalue"] = "onValue",
    ["ondrawimgui"] = "onDrawImGui",
    ["onvariant"] = "onVariant",
    ["ondialog"] = "onDialog",
    ["onsendpacket"] = "onSendPacket",
    ["onsendpacketraw"] = "onSendPacketRaw",
  }
  local G = {
    ["onValue"] = "onvalue",
    ["onDrawImGui"] = "ondrawimgui",
    ["OnVariant"] = "onvariant",
    ["OnDialog"] = "ondialog",
    ["OnSendPacket"] = "onsendpacket",
    ["OnSendPacketRaw"] = "onsendpacketraw",
  }
  local function M(G)
    if ZS_HUB["installed"][G] then
      return
    end
    ZS_HUB["installed"][G] = true
    local M = ZS_HUB["callbacks"][G]
    ZS_HUB["native"](function(...)
      local j = false
      for B = 1, #M, 1 do
        local L, k = pcall(M[B], ...)
        if not L then
          local j = "Hook error (" .. (G .. ("): " .. tostring(k)))
          if growtopia and type(growtopia["notify"]) == "function" then
            pcall(growtopia["notify"], j)
          else
            print(j)
          end
        elseif k == true then
          j = true
        end
      end
      return j
    end, j[G] or G)
  end
  function addHook(j, B)
    if type(j) ~= "function" then
      return
    end
    B = B or "onvalue"
    B = G[B] or (tostring(B)):lower()
    if not ZS_HUB["callbacks"][B] then
      ZS_HUB["callbacks"][B] = {}
    end
    table["insert"](ZS_HUB["callbacks"][B], j)
    M(B)
  end
end
if not ZS_thread then
  function ZS_thread(j)
    runThread(j)
  end
end
if not ZS_label then
  function ZS_label(j, G, ...)
    G = tostring(G == nil and "" or G)
    local M = ZS_LABEL_WIDTH
    local function B(j)
      if utf8 and utf8["len"] then
        return utf8["len"](j) or #j
      end
      return #j
    end
    local L, k = {}, ""
    for j in G:gmatch("%S+") do
      if k == "" then
        k = j
      elseif (B(k) + 1) + B(j) <= M then
        k = k .. (" " .. j)
      else
        L[#L + 1] = k
        k = j
      end
    end
    if k ~= "" then
      L[#L + 1] = k
    end
    if #L == 0 then
      L[1] = G
    end
    for G, M in ipairs(L) do
      j:addLabel(M, ...)
    end
  end
end
if not ZS_CATEGORY_ADDED then
  ZS_CATEGORY_ADDED = true
  if type(addCategory) == "function" then
    pcall(addCategory, "ZS", "Shield")
  end
end
local j = { ["tag"] = "k15", ["life"] = "ZSA-SSP", ["unlocked"] = false, ["entered"] = "", ["n"] = 0 }
local function G(j)
  if growtopia and type(growtopia["notify"]) == "function" then
    pcall(growtopia["notify"], tostring(j))
  else
    print("[ZS] " .. tostring(j))
  end
end
local M = G
local B = addHook
local function L(G, M)
  if type(G) ~= "function" then
    return
  end
  return B(function(...)
    if not j["unlocked"] then
      return false
    end
    return G(...)
  end, M)
end
local function k(j)
  local G = tostring(j)
  local M, B = G:find('"menu"%s*:%s*%[')
  if not M then
    return nil
  end
  local L, k, t, Y = 1, B + 1, false, false
  while k <= #G do
    local j = G:sub(k, k)
    if t then
      if Y then
        Y = false
      elseif j == "\\" then
        Y = true
      elseif j == '"' then
        t = false
      end
    elseif j == '"' then
      t = true
    elseif j == "[" then
      L = L + 1
    elseif j == "]" then
      L = L - 1
      if L == 0 then
        return G:sub(B + 1, k - 1)
      end
    end
    k = k + 1
  end
end
local function t()
  j["n"] = j["n"] + 1
  local G = UserInterface["new"]("ZS ACCESS", "Lock")
  G:addLabelApp("* ACCESS KEY *", "Lock")
  ZS_label(G, "Enter your key. You can look around, but everything works only after unlock.")
  G:addInputString("Enter Key", "", "Enter Key", "Your key", "Key", "zskey_" .. (j["tag"] .. ("_" .. j["n"])))
  G:addButton("UNLOCK", "zsunl_" .. (j["tag"] .. ("_" .. j["n"])))
  G:addDivider()
  return G
end
local Y = addIntoModule
local function Z(G, M, ...)
  if type(G) == "string" and not G:find("zskey_" .. (j["tag"] .. "_"), 1, true) then
    local j, B = pcall(function()
      local j = t()
      local M = k(j:generateJSON())
      local B, L = G:find('"menu"%s*:%s*%[')
      if not (M and B) then
        return nil
      end
      local Y = G:sub(L + 1)
      local Z = Y:match("^%s*%]") and "" or ","
      return G:sub(1, L) .. (M .. (Z .. Y))
    end)
    if j and B then
      G = B
    else
      pcall(function()
        Y((t()):generateJSON(), M)
      end)
    end
  end
  return Y(G, M, ...)
end
local function S(...)
  local M = select("#", ...)
  local B = { ... }
  local L, k = "zskey_" .. (j["tag"] .. "_"), "zsunl_" .. (j["tag"] .. "_")
  local function t(j)
    if type(j) ~= "string" then
      return nil
    end
    if j:sub(1, #L) == L then
      return "key"
    end
    if j:sub(1, #k) == k then
      return "btn"
    end
  end
  local Y, Z
  local function S(j, G)
    if Y or G > 2 then
      return
    end
    if type(j) == "string" then
      Y = t(j)
    elseif type(j) == "table" then
      for M, B in pairs(j) do
        if t(B) then
          Y = t(B)
          Z = j["value"] or j["text"] or j["v2"]
          return
        end
        if t(M) then
          Y = t(M)
          Z = B
          return
        end
        if type(B) == "table" then
          S(B, G + 1)
        end
      end
    end
  end
  for j = 1, M, 1 do
    S(B[j], 0)
    if Y then
      if Z == nil then
        Z = B[j + 1]
      end
      break
    end
  end
  if Y == "key" then
    j["entered"] = tostring(Z or "")
    return true
  elseif Y == "btn" then
    local M = ((j["entered"]:upper()):gsub("%s+", ""))
    if M == j["life"]:upper() then
      j["unlocked"] = true
      G("Key accepted. Unlocked!")
    else
      G("Invalid key.")
    end
    return true
  end
  return false
end
B(S, "onvalue")
local R = 5706
local W = 350
local b = 200
local g = 3000
local h = 5
local l = 10000
local J = 3
local O = 10
local v = 90
local u = 50
local d = -1
local i = LogToConsole or logToConsole
local w = GetInventory or getInventory
local x = GetLocal or getLocal
local F = GetObjectList or getObjectList
local N = GetTiles or getTiles
local e = SendPacket or sendPacket
local E = SendPacketRaw or sendPacketRaw
local Q = SendVariant or sendVariant
local y = FindPath or findPath
local X = AddHook or L
local V = Sleep or sleep
local z = false
local P = false
local C = false
local q = false
local s = false
local T = 0
local n = 0
local f = {}
local function A(j, G)
  if i then
    i(j)
  end
end
local function a(j)
  if type(Q) ~= "function" then
    return
  end
  local G = (tostring(j)):lower()
  if G:find("could not", 1, true) or G:find("missing", 1, true) or G:find("failed", 1, true) then
    pcall(Q, { ["v1"] = "OnTextOverlay", ["v2"] = j })
  end
end
local function p()
  local j = {
    ["LogToConsole"] = i,
    ["GetInventory"] = w,
    ["GetLocal"] = x,
    ["GetObjectList"] = F,
    ["SendPacket"] = e,
    ["SendPacketRaw"] = E,
    ["FindPath"] = y,
    ["Sleep"] = V,
  }
  local G = {}
  for j, M in pairs(j) do
    if type(M) ~= "function" then
      G[#G + 1] = j
    end
  end
  if #G > 0 then
    if i then
      i("Function not found: " .. table["concat"](G, ", "))
    end
    return false
  end
  return true
end
local function r(j)
  for G, M in pairs(w() or {}) do
    if M["id"] == j then
      return tonumber(M["amount"]) or 0
    end
  end
  return 0
end
local function D(j, G)
  j, G = tonumber(j), tonumber(G)
  if not j or not G then
    return nil
  end
  local M = j > 30 and math["floor"](j / 32) or math["floor"](j)
  local B = G > 30 and math["floor"](G / 32) or math["floor"](G)
  return M, B
end
local function I()
  local j = x()
  if not j or not j["posX"] or not j["posY"] then
    return nil
  end
  return math["floor"](tonumber(j["posX"]) / 32), math["floor"](tonumber(j["posY"]) / 32)
end
local function H(j, G)
  local M, B = I()
  return M ~= nil and (M == j and B == G)
end
local function o(j)
  return j["isLeft"] == true or j["isLeft"] == 1
end
local function K(j, G)
  if type(N) ~= "function" then
    return true
  end
  local M, B = pcall(N, j, G)
  if not M or type(B) ~= "table" then
    return true
  end
  if B["collidable"] ~= nil then
    return not B["collidable"]
  end
  if B["fg"] ~= nil then
    return B["fg"] == 0
  end
  return true
end
local function U()
  local j = x()
  if not j or j["isLeft"] == nil or not j["posX"] then
    return nil
  end
  local G = math["floor"](tonumber(j["posX"]) / 32)
  return o(j) and (G - 1) or (G + 1)
end
local function m(j, G)
  for M = 1, 100, 1 do
    if not z then
      return false
    end
    if H(j, G) then
      return true
    end
    V(250)
  end
  return false
end
local function c(j, G)
  if not z then
    return false
  end
  local M = pcall(y, j, G)
  if not M then
    return false
  end
  return m(j, G)
end
local function j9(j, G)
  for M = 1, 3, 1 do
    if not z then
      return false
    end
    if not H(j, G) and not c(j, G) then
      return false
    end
    V(250)
    if H(j, G) then
      return true
    end
  end
  return false
end
local function G9()
  for j, G in pairs(w() or {}) do
    local M, B = G["id"], tonumber(G["amount"]) or 0
    if M and (M % 2 == 1 and B >= b) then
      return M, B
    end
  end
  return nil
end
local function M9()
  if not z then
    return
  end
  local j = x()
  if not j or not j["posX"] or not j["posY"] then
    return
  end
  local G = {}
  G["type"] = 3
  G["value"] = R
  G["x"] = tonumber(j["posX"])
  G["y"] = tonumber(j["posY"])
  G["px"] = math["floor"](tonumber(j["posX"]) / 32)
  G["py"] = math["floor"](tonumber(j["posY"]) / 32)
  E(false, G)
end
local function B9()
  v = v + d
  T = 0
  n = 0
end
local function L9(j, G)
  if not z then
    return false
  end
  local M = v - 1
  local B = u - 1
  local L = 9
  local k = false
  for j = 1, 10, 1 do
    if not z then
      return false
    end
    if d > 0 and M > L then
      s = true
      return false
    elseif d < 0 and M < L then
      s = true
      return false
    end
    local G = M
    if f[G] then
      B9()
      M = v - 1
    elseif not K(G, B) then
      B9()
      M = v - 1
    else
      if not j9(G, B) then
        return false
      end
      local j = U()
      if j == nil or K(j, B) then
        k = true
        break
      end
      B9()
      M = v - 1
    end
  end
  if not k then
    return false
  end
  local t = U()
  local Y = r(j)
  e(2, "action|drop\n|itemID|" .. j)
  V(200)
  e(2, "action|dialog_return\ndialog_name|drop_item\nitemID|" .. (j .. ("|\ncount|" .. G)))
  V(g)
  if r(j) >= Y then
    n = n + 1
    if n >= 2 then
      B9()
    end
    return false
  end
  n = 0
  if t then
    f[t] = true
  end
  T = T + 1
  if T >= 20 then
    B9()
  end
  return true
end
local function k9()
  if not C then
    return true
  end
  local j = 0
  while z and j < O do
    local G, M = G9()
    if not G then
      return true
    end
    if L9(G, b) then
      j = 0
    else
      if s then
        return false
      end
      j = j + 1
    end
  end
  return false
end
local function t9()
  return s and "Drop area is full" or "Repeated drop failure"
end
local function Y9(j)
  local G, M = I()
  if not G then
    return nil
  end
  local B, L = pcall(F)
  if not B or type(L) ~= "table" then
    return nil
  end
  local k, t = nil, math["huge"]
  for B, L in pairs(L) do
    if L["itemid"] and (L["itemid"] == 5706 and (L["posX"] and L["posY"])) then
      local B, Y = D(L["posX"], L["posY"])
      if B and not j[B .. ("," .. Y)] then
        local j = math["abs"](B - G) + math["abs"](Y - M)
        if j < t then
          k, t = { ["x"] = B, ["y"] = Y }, j
        end
      end
    end
  end
  return k
end
local function Z9()
  local j = {}
  for G = 1, 10, 1 do
    local M = Y9(j)
    if not M then
      break
    end
    local B = r(R)
    c(M["x"], M["y"])
    local L = 0
    while z and (r(R) <= B and L < 1500) do
      V(250)
      L = L + 250
    end
    if r(R) > B then
      return true
    end
    j[M["x"] .. ("," .. M["y"])] = true
  end
  return false
end
local function S9()
  c(v - 1, u - 1)
end
local function R9()
  if not k9() then
    return 0, t9()
  end
  local j, G, M = 0, 0, 0
  local B = { 2500, 5000, 7500, 7500 }
  while z do
    while z and r(R) > 0 do
      if C and G9() then
        if not k9() then
          return G, t9()
        end
      else
        local L = r(R)
        local k, t = 0, 0
        local Y = (j == 0) and W or B[j]
        while z and (k < 2000 and r(R) > 0) do
          if C and G9() then
            break
          end
          M9()
          t = t + 1
          V(Y)
          k = k + Y
        end
        local Z = r(R)
        if t > 0 and Z >= L then
          j = j + 1
          local L = B[j] or 7500
          A(
            "Server lag; waiting "
              .. ((L / 1000) .. ("s (failure #" .. (j .. (") - packet delay increased to " .. (Y .. "ms"))))),
            true
          )
          if j >= h then
            M = M + 1
            if M >= J then
              return G, "Stopped: consecutive cooldown limit reached"
            end
            A("10-second cooldown (all actions paused)...", true)
            j = 0
            V(l)
            A("Cooldown complete; resuming.", true)
          else
            V(L)
          end
        else
          if L > Z then
            G = G + (L - Z)
          end
          j = 0
          M = 0
        end
      end
    end
    if not k9() then
      return G, t9()
    end
    Z9()
    S9()
    V(300)
    if r(R) == 0 then
      return G, "No more SSP available in the world"
    end
    j = 0
  end
  return G, "Stopped"
end
function zs_ssp_set_drop(j)
  C = j == true
  a("AUTO DROP " .. (C and "enabled." or "disabled."))
end
function zs_ssp_start()
  if P then
    a("AUTO SSP + DROP is already running.")
    return
  end
  if not p() then
    a("AUTO SSP + DROP could not start: required API is missing.")
    return
  end
  if type(runThread) ~= "function" then
    a("AUTO SSP + DROP could not start: runThread API is missing.")
    return
  end
  z = true
  P = true
  if not q and type(X) == "function" then
    X(function(j)
      if not z or not j then
        return false
      end
      if j["v1"] == "OnDialogRequest" and (type(j["v2"]) == "string" and j["v2"]:find("drop_item")) then
        return true
      end
      if j["v1"] == "OnConsoleMessage" and type(j["v2"]) == "string" then
        return true
      end
      return false
    end, "OnVariant")
    q = true
  end
  a("AUTO SSP + DROP started.")
  runThread(function()
    local j, G = R9()
    z = false
    P = false
    local M = "Finished: " .. (tostring(G) .. (". Used: " .. tostring(j)))
    A(M, true)
    a(M)
  end)
end
function zs_ssp_stop()
  if not P then
    z = false
    a("AUTO SSP + DROP is not running.")
    return
  end
  z = false
  a("AUTO SSP + DROP stop requested.")
end
local W9 = UserInterface["new"]("ZS AUTO SSP & DROP", "Inventory")
W9:addLabelApp("* ZS AUTO SSP & DROP *", "Inventory")
W9:addTooltip(
  "AUTO SSP & DROP",
  "AUTO SSP uses your Small Seed Packs and can collect more from your configured source. AUTO DROP SEEDS drops eligible seeds when your inventory is full.",
  "Info",
  true
)
W9:addDivider()
W9:addToggle("AUTO DROP SEEDS", false, "zs_ssp_drop_toggle", true)
W9:addToggle("AUTO SSP", false, "zs_ssp_toggle", true)
Z(W9:generateJSON(), "ZS")
L(function(j, G, B)
  if G == "zs_ssp_drop_toggle" then
    if type(zs_ssp_set_drop) == "function" then
      zs_ssp_set_drop(B)
    else
      M("AUTO DROP control is not available.")
    end
  elseif G == "zs_ssp_toggle" then
    if B then
      if type(zs_ssp_start) == "function" then
        zs_ssp_start()
      else
        M("AUTO SSP + DROP module is not available.")
      end
    else
      if type(zs_ssp_stop) == "function" then
        zs_ssp_stop()
      end
    end
  end
end, "onValue")
if type(applyHook) == "function" then
  pcall(applyHook)
end
