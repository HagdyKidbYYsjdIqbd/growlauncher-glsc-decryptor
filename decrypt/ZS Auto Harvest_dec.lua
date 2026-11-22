ZS_LABEL_WIDTH = ZS_LABEL_WIDTH or 30
if not ZS_HUB then
  ZS_HUB = { ["native"] = addHook, ["callbacks"] = {}, ["installed"] = {} }
  local q = {
    ["onvalue"] = "onValue",
    ["ondrawimgui"] = "onDrawImGui",
    ["onvariant"] = "onVariant",
    ["ondialog"] = "onDialog",
    ["onsendpacket"] = "onSendPacket",
    ["onsendpacketraw"] = "onSendPacketRaw",
  }
  local n = {
    ["onValue"] = "onvalue",
    ["onDrawImGui"] = "ondrawimgui",
    ["OnVariant"] = "onvariant",
    ["OnDialog"] = "ondialog",
    ["OnSendPacket"] = "onsendpacket",
    ["OnSendPacketRaw"] = "onsendpacketraw",
  }
  local function T(n)
    if ZS_HUB["installed"][n] then
      return
    end
    ZS_HUB["installed"][n] = true
    local T = ZS_HUB["callbacks"][n]
    ZS_HUB["native"](function(...)
      local q = false
      for Y = 1, #T, 1 do
        local L, S = pcall(T[Y], ...)
        if not L then
          local q = "Hook error (" .. (n .. ("): " .. tostring(S)))
          if growtopia and type(growtopia["notify"]) == "function" then
            pcall(growtopia["notify"], q)
          else
            print(q)
          end
        elseif S == true then
          q = true
        end
      end
      return q
    end, q[n] or n)
  end
  function addHook(q, Y)
    if type(q) ~= "function" then
      return
    end
    Y = Y or "onvalue"
    Y = n[Y] or (tostring(Y)):lower()
    if not ZS_HUB["callbacks"][Y] then
      ZS_HUB["callbacks"][Y] = {}
    end
    table["insert"](ZS_HUB["callbacks"][Y], q)
    T(Y)
  end
end
if not ZS_thread then
  function ZS_thread(q)
    runThread(q)
  end
end
if not ZS_label then
  function ZS_label(q, n, ...)
    n = tostring(n == nil and "" or n)
    local T = ZS_LABEL_WIDTH
    local function Y(q)
      if utf8 and utf8["len"] then
        return utf8["len"](q) or #q
      end
      return #q
    end
    local L, S = {}, ""
    for q in n:gmatch("%S+") do
      if S == "" then
        S = q
      elseif (Y(S) + 1) + Y(q) <= T then
        S = S .. (" " .. q)
      else
        L[#L + 1] = S
        S = q
      end
    end
    if S ~= "" then
      L[#L + 1] = S
    end
    if #L == 0 then
      L[1] = n
    end
    for n, T in ipairs(L) do
      q:addLabel(T, ...)
    end
  end
end
if not ZS_CATEGORY_ADDED then
  ZS_CATEGORY_ADDED = true
  if type(addCategory) == "function" then
    pcall(addCategory, "ZS", "Shield")
  end
end
local q = { ["tag"] = "k07", ["life"] = "ZSA-HARV", ["unlocked"] = false, ["entered"] = "", ["n"] = 0 }
local function n(q)
  if growtopia and type(growtopia["notify"]) == "function" then
    pcall(growtopia["notify"], tostring(q))
  else
    print("[ZS] " .. tostring(q))
  end
end
local T = n
local Y = addHook
local function L(n, T)
  if type(n) ~= "function" then
    return
  end
  return Y(function(...)
    if not q["unlocked"] then
      return false
    end
    return n(...)
  end, T)
end
local function S(q)
  local n = tostring(q)
  local T, Y = n:find('"menu"%s*:%s*%[')
  if not T then
    return nil
  end
  local L, S, i, J = 1, Y + 1, false, false
  while S <= #n do
    local q = n:sub(S, S)
    if i then
      if J then
        J = false
      elseif q == "\\" then
        J = true
      elseif q == '"' then
        i = false
      end
    elseif q == '"' then
      i = true
    elseif q == "[" then
      L = L + 1
    elseif q == "]" then
      L = L - 1
      if L == 0 then
        return n:sub(Y + 1, S - 1)
      end
    end
    S = S + 1
  end
end
local function i()
  q["n"] = q["n"] + 1
  local n = UserInterface["new"]("ZS ACCESS", "Lock")
  n:addLabelApp("* ACCESS KEY *", "Lock")
  ZS_label(n, "Enter your key. You can look around, but everything works only after unlock.")
  n:addInputString("Enter Key", "", "Enter Key", "Your key", "Key", "zskey_" .. (q["tag"] .. ("_" .. q["n"])))
  n:addButton("UNLOCK", "zsunl_" .. (q["tag"] .. ("_" .. q["n"])))
  n:addDivider()
  return n
end
local J = addIntoModule
local function O(n, T, ...)
  if type(n) == "string" and not n:find("zskey_" .. (q["tag"] .. "_"), 1, true) then
    local q, Y = pcall(function()
      local q = i()
      local T = S(q:generateJSON())
      local Y, L = n:find('"menu"%s*:%s*%[')
      if not (T and Y) then
        return nil
      end
      local J = n:sub(L + 1)
      local O = J:match("^%s*%]") and "" or ","
      return n:sub(1, L) .. (T .. (O .. J))
    end)
    if q and Y then
      n = Y
    else
      pcall(function()
        J((i()):generateJSON(), T)
      end)
    end
  end
  return J(n, T, ...)
end
local function c(...)
  local T = select("#", ...)
  local Y = { ... }
  local L, S = "zskey_" .. (q["tag"] .. "_"), "zsunl_" .. (q["tag"] .. "_")
  local function i(q)
    if type(q) ~= "string" then
      return nil
    end
    if q:sub(1, #L) == L then
      return "key"
    end
    if q:sub(1, #S) == S then
      return "btn"
    end
  end
  local J, O
  local function c(q, n)
    if J or n > 2 then
      return
    end
    if type(q) == "string" then
      J = i(q)
    elseif type(q) == "table" then
      for T, Y in pairs(q) do
        if i(Y) then
          J = i(Y)
          O = q["value"] or q["text"] or q["v2"]
          return
        end
        if i(T) then
          J = i(T)
          O = Y
          return
        end
        if type(Y) == "table" then
          c(Y, n + 1)
        end
      end
    end
  end
  for q = 1, T, 1 do
    c(Y[q], 0)
    if J then
      if O == nil then
        O = Y[q + 1]
      end
      break
    end
  end
  if J == "key" then
    q["entered"] = tostring(O or "")
    return true
  elseif J == "btn" then
    local T = ((q["entered"]:upper()):gsub("%s+", ""))
    if T == q["life"]:upper() then
      q["unlocked"] = true
      n("Key accepted. Unlocked!")
    else
      n("Invalid key.")
    end
    return true
  end
  return false
end
Y(c, "onvalue")
local t, h = false, false
local f = 250
local function x(q)
  if growtopia and type(growtopia["notify"]) == "function" then
    pcall(growtopia["notify"], tostring(q))
  else
    print("[ZS Auto Harvest] " .. tostring(q))
  end
end
local function G()
  if type(GetLocal) ~= "function" then
    return nil
  end
  local q, n = pcall(GetLocal)
  if q then
    return n
  end
end
local function r(q, n)
  if type(GetTile) ~= "function" then
    return nil
  end
  local T, Y = pcall(GetTile, q, n)
  if T then
    return Y
  end
end
local function X(q)
  return tonumber(q and q["fg"]) or 0
end
local function o()
  local q = G()
  if not q then
    return nil
  end
  local n = math["floor"]((tonumber(q["posX"]) or 0) / 32)
  local T = math["floor"]((tonumber(q["posY"]) or 0) / 32)
  local Y = { { n, T - 1 }, { n, T }, { n - 1, T - 1 }, { n + 1, T - 1 }, { n - 1, T }, { n + 1, T }, { n, T - 2 } }
  for q, n in ipairs(Y) do
    local T = r(n[1], n[2])
    local Y = X(T)
    if Y > 0 and Y ~= 2 then
      return Y, n[1], n[2]
    end
  end
  return nil
end
local function H(q)
  local n = {}
  if type(GetTiles) ~= "function" then
    return n
  end
  local T, Y = pcall(GetTiles)
  if not T or type(Y) ~= "table" then
    return n
  end
  for T, Y in pairs(Y) do
    local L, S = tonumber(Y["x"]), tonumber(Y["y"])
    if L and (S and X(Y) == q) then
      n[#n + 1] = { ["x"] = math["floor"](L), ["y"] = math["floor"](S) }
    end
  end
  table["sort"](n, function(q, n)
    if q["y"] == n["y"] then
      return q["x"] < n["x"]
    end
    return q["y"] < n["y"]
  end)
  local L, S = {}, 1
  while S <= #n do
    local q = n[S]
    local T = { q }
    local Y = S + 1
    while Y <= #n and (#T < 3 and (n[Y]["y"] == q["y"] and n[Y]["x"] <= q["x"] + 2)) do
      T[#T + 1] = n[Y]
      Y = Y + 1
    end
    L[#L + 1] = T
    S = Y
  end
  return L
end
local function d(q, n)
  local T = G()
  if not T then
    return false
  end
  return math["abs"]((T["posX"] or 0) / 32 - q) <= 2 and math["abs"]((T["posY"] or 0) / 32 - n) <= 2
end
local function s(q, n)
  local T = G()
  if not T or type(SendPacketRaw) ~= "function" then
    return false
  end
  local Y = pcall(
    SendPacketRaw,
    false,
    { ["x"] = T["posX"], ["y"] = T["posY"], ["px"] = q, ["py"] = n, ["type"] = 3, ["value"] = 18 }
  )
  return Y
end
local function V(q, n)
  local T = 0
  local function Y(n)
    local T = {}
    if type(GetTiles) ~= "function" then
      return T
    end
    local Y, L = pcall(GetTiles)
    if not Y or type(L) ~= "table" then
      return T
    end
    for Y, L in pairs(L) do
      local S, i = tonumber(L["x"]), tonumber(L["y"])
      if S and (i and (math["floor"](i) == n and X(L) == q)) then
        T[#T + 1] = { ["x"] = math["floor"](S), ["y"] = n }
      end
    end
    table["sort"](T, function(q, n)
      return q["x"] < n["x"]
    end)
    return T
  end
  while not h do
    local L = H(q)
    if #L == 0 then
      return T, "done"
    end
    local S, i = {}, {}
    for q, n in ipairs(L) do
      for q, n in ipairs(n) do
        if not i[n["y"]] then
          i[n["y"]] = true
          S[#S + 1] = n["y"]
        end
      end
    end
    table["sort"](S)
    local J = false
    for L, S in ipairs(S) do
      if h then
        return T, "stop"
      end
      local i = 0
      while not h do
        local L = Y(S)
        if #L == 0 then
          break
        end
        local O = L[#L]
        if type(FindPath) == "function" then
          pcall(FindPath, O["x"] + 1, O["y"])
        end
        Sleep(f)
        for Y, L in ipairs(L) do
          if h then
            return T, "stop"
          end
          if X(r(L["x"], L["y"])) == q then
            if not d(L["x"], L["y"]) then
              if type(FindPath) == "function" then
                pcall(FindPath, L["x"] + 1, L["y"])
              end
              Sleep(f)
            end
            if d(L["x"], L["y"]) then
              if not s(L["x"], L["y"]) then
                return T, "packet"
              end
              Sleep(n)
              if X(r(L["x"], L["y"])) ~= q then
                T = T + 1
                J = true
              end
            end
          end
        end
        local c = Y(S)
        if #c == 0 then
          break
        end
        local t = false
        for n, T in ipairs(L) do
          if X(r(T["x"], T["y"])) ~= q then
            t = true
            break
          end
        end
        if t then
          i = 0
        else
          i = i + 1
        end
        if i >= 3 then
          return T, "blocked"
        end
        if type(FindPath) == "function" then
          pcall(FindPath, c[1]["x"] + 1, c[1]["y"])
        end
        Sleep(f)
      end
    end
    if not J then
      return T, "blocked"
    end
    Sleep(150)
  end
  return T, "stop"
end
local function Z(q)
  local n, T = {}, {}
  q = tostring(q or "")
  for q in q:gmatch("[^,;\\n]+") do
    q = q:match("^%s*(.-)%s*$")
    if q ~= "" then
      local Y, L = q:match("^([^:|]+)[:|](%d+)$")
      if not Y then
        Y = q
      end
      Y = Y:match("^%s*(.-)%s*$")
      L = L and tostring(tonumber(L)) or nil
      local S = Y:upper() .. ("|" .. tostring(L or ""))
      if Y ~= "" and not T[S] then
        T[S] = true
        n[#n + 1] = { ["name"] = Y, ["door"] = L }
      end
    end
  end
  if #n == 0 and type(GetWorldName) == "function" then
    local q = GetWorldName()
    if q and q ~= "EXIT" then
      n[1] = { ["name"] = q }
    end
  end
  return n
end
local function a(q)
  local n = q["name"]
  local T = q["door"]
  if T then
    SendPacket(3, "action|join_request\\nname|" .. (n .. ("\\ninvitedWorld|0\\ndoorID|" .. T)))
  else
    growtopia["warpTo"](n)
  end
  local Y = 0
  while Y < 15000 and not h do
    if type(GetWorldName) == "function" and (GetWorldName()):upper() == n:upper() then
      break
    end
    Sleep(250)
    Y = Y + 250
  end
  if type(GetWorldName) ~= "function" or (GetWorldName()):upper() ~= n:upper() then
    return false
  end
  Sleep(600)
  return true
end
local function R()
  h = false
  local q, n, T = o()
  if not q or q <= 0 then
    x("Stand directly on or next to the seed you want to harvest, then turn Auto Harvest ON.")
    t = false
    return
  end
  local Y = tonumber(getValue(2, "zs_hv_delay")) or 200
  Y = math["max"](80, math["min"](1500, math["floor"](Y)))
  local L = Z(getValue(2, "zs_hv_worlds"))
  if not growtopia or type(growtopia["warpTo"]) ~= "function" then
    x("World warp API unavailable.")
    t = false
    return
  end
  x(
    "Detected seed/tree ID "
      .. (q .. (" at " .. (n .. ("," .. (T .. ". Only this exact tree type will be harvested in the listed worlds.")))))
  )
  local S = 0
  for n, T in ipairs(L) do
    if h then
      break
    end
    local L = T["name"]
    local i = type(GetWorldName) == "function" and GetWorldName() or ""
    if i:upper() ~= L:upper() or T["door"] then
      if not a(T) then
        x("Could not enter world/door: " .. (L .. (T["door"] and (":" .. T["door"]) or "")))
        t = false
        return
      end
    end
    local J, O = V(q, Y)
    S = S + J
    if O == "blocked" or O == "packet" then
      x("Harvest stopped: " .. (O .. (". Harvested " .. (S .. " tiles."))))
      t = false
      return
    end
  end
  t = false
  x("Auto Harvest finished. Harvested " .. (S .. " matching tiles."))
end
local k = UserInterface["new"]("ZS AUTO HARVEST", "Agriculture")
k:addLabelApp("* ZS AUTO HARVEST *", "Agriculture")
k:addTooltip(
  "AUTO HARVEST",
  "Stand beside the tree you want to harvest, then turn Auto Harvest ON. Add farm worlds separated by commas. Leave the list empty to use the current world.",
  "Info",
  true
)
k:addDivider()
k:addInputString(
  "Worlds / Door IDs",
  "",
  "Worlds to Harvest",
  "Example: WORLD1:5, WORLD2:12. The number after : is the door ID.",
  "World:Door ID",
  "zs_hv_worlds"
)
k:addSlider("Harvest Delay (ms)", 80, 1500, 200, 10, false, "zs_hv_delay")
k:addDivider()
k:addToggle("AUTO HARVEST", false, "zs_hv_run", true)
O(k:generateJSON(), "ZS")
L(function(q, n, T)
  if n == "zs_hv_run" then
    if T then
      if t then
        x("Auto Harvest is already running.")
        return
      end
      t = true
      h = false
      ZS_thread(R)
    else
      h = true
      x("AUTO HARVEST: OFF.")
    end
  end
end, "onValue")
if type(applyHook) == "function" then
  pcall(applyHook)
end
