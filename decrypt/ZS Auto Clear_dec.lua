ZS_LABEL_WIDTH = ZS_LABEL_WIDTH or 30
if not ZS_HUB then
  ZS_HUB = { ["native"] = addHook, ["callbacks"] = {}, ["installed"] = {} }
  local T = {
    ["onvalue"] = "onValue",
    ["ondrawimgui"] = "onDrawImGui",
    ["onvariant"] = "onVariant",
    ["ondialog"] = "onDialog",
    ["onsendpacket"] = "onSendPacket",
    ["onsendpacketraw"] = "onSendPacketRaw",
  }
  local A = {
    ["onValue"] = "onvalue",
    ["onDrawImGui"] = "ondrawimgui",
    ["OnVariant"] = "onvariant",
    ["OnDialog"] = "ondialog",
    ["OnSendPacket"] = "onsendpacket",
    ["OnSendPacketRaw"] = "onsendpacketraw",
  }
  local function z(A)
    if ZS_HUB["installed"][A] then
      return
    end
    ZS_HUB["installed"][A] = true
    local z = ZS_HUB["callbacks"][A]
    ZS_HUB["native"](function(...)
      local T = false
      for F = 1, #z, 1 do
        local U, w = pcall(z[F], ...)
        if not U then
          local T = "Hook error (" .. (A .. ("): " .. tostring(w)))
          if growtopia and type(growtopia["notify"]) == "function" then
            pcall(growtopia["notify"], T)
          else
            print(T)
          end
        elseif w == true then
          T = true
        end
      end
      return T
    end, T[A] or A)
  end
  function addHook(T, F)
    if type(T) ~= "function" then
      return
    end
    F = F or "onvalue"
    F = A[F] or (tostring(F)):lower()
    if not ZS_HUB["callbacks"][F] then
      ZS_HUB["callbacks"][F] = {}
    end
    table["insert"](ZS_HUB["callbacks"][F], T)
    z(F)
  end
end
if not ZS_thread then
  function ZS_thread(T)
    runThread(T)
  end
end
if not ZS_label then
  function ZS_label(T, A, ...)
    A = tostring(A == nil and "" or A)
    local z = ZS_LABEL_WIDTH
    local function F(T)
      if utf8 and utf8["len"] then
        return utf8["len"](T) or #T
      end
      return #T
    end
    local U, w = {}, ""
    for T in A:gmatch("%S+") do
      if w == "" then
        w = T
      elseif (F(w) + 1) + F(T) <= z then
        w = w .. (" " .. T)
      else
        U[#U + 1] = w
        w = T
      end
    end
    if w ~= "" then
      U[#U + 1] = w
    end
    if #U == 0 then
      U[1] = A
    end
    for A, z in ipairs(U) do
      T:addLabel(z, ...)
    end
  end
end
if not ZS_CATEGORY_ADDED then
  ZS_CATEGORY_ADDED = true
  if type(addCategory) == "function" then
    pcall(addCategory, "ZS", "Shield")
  end
end
local T = { ["tag"] = "k16", ["life"] = "ZSA-CLEAR", ["unlocked"] = false, ["entered"] = "", ["n"] = 0 }
local function A(T)
  if growtopia and type(growtopia["notify"]) == "function" then
    pcall(growtopia["notify"], tostring(T))
  else
    print("[ZS] " .. tostring(T))
  end
end
local z = A
local F = addHook
local function U(A, z)
  if type(A) ~= "function" then
    return
  end
  return F(function(...)
    if not T["unlocked"] then
      return false
    end
    return A(...)
  end, z)
end
local function w(T)
  local A = tostring(T)
  local z, F = A:find('"menu"%s*:%s*%[')
  if not z then
    return nil
  end
  local U, w, P, V = 1, F + 1, false, false
  while w <= #A do
    local T = A:sub(w, w)
    if P then
      if V then
        V = false
      elseif T == "\\" then
        V = true
      elseif T == '"' then
        P = false
      end
    elseif T == '"' then
      P = true
    elseif T == "[" then
      U = U + 1
    elseif T == "]" then
      U = U - 1
      if U == 0 then
        return A:sub(F + 1, w - 1)
      end
    end
    w = w + 1
  end
end
local function P()
  T["n"] = T["n"] + 1
  local A = UserInterface["new"]("ZS ACCESS", "Lock")
  A:addLabelApp("* ACCESS KEY *", "Lock")
  ZS_label(A, "Enter your key. You can look around, but everything works only after unlock.")
  A:addInputString("Enter Key", "", "Enter Key", "Your key", "Key", "zskey_" .. (T["tag"] .. ("_" .. T["n"])))
  A:addButton("UNLOCK", "zsunl_" .. (T["tag"] .. ("_" .. T["n"])))
  A:addDivider()
  return A
end
local V = addIntoModule
local function M(A, z, ...)
  if type(A) == "string" and not A:find("zskey_" .. (T["tag"] .. "_"), 1, true) then
    local T, F = pcall(function()
      local T = P()
      local z = w(T:generateJSON())
      local F, U = A:find('"menu"%s*:%s*%[')
      if not (z and F) then
        return nil
      end
      local V = A:sub(U + 1)
      local M = V:match("^%s*%]") and "" or ","
      return A:sub(1, U) .. (z .. (M .. V))
    end)
    if T and F then
      A = F
    else
      pcall(function()
        V((P()):generateJSON(), z)
      end)
    end
  end
  return V(A, z, ...)
end
local function u(...)
  local z = select("#", ...)
  local F = { ... }
  local U, w = "zskey_" .. (T["tag"] .. "_"), "zsunl_" .. (T["tag"] .. "_")
  local function P(T)
    if type(T) ~= "string" then
      return nil
    end
    if T:sub(1, #U) == U then
      return "key"
    end
    if T:sub(1, #w) == w then
      return "btn"
    end
  end
  local V, M
  local function u(T, A)
    if V or A > 2 then
      return
    end
    if type(T) == "string" then
      V = P(T)
    elseif type(T) == "table" then
      for z, F in pairs(T) do
        if P(F) then
          V = P(F)
          M = T["value"] or T["text"] or T["v2"]
          return
        end
        if P(z) then
          V = P(z)
          M = F
          return
        end
        if type(F) == "table" then
          u(F, A + 1)
        end
      end
    end
  end
  for T = 1, z, 1 do
    u(F[T], 0)
    if V then
      if M == nil then
        M = F[T + 1]
      end
      break
    end
  end
  if V == "key" then
    T["entered"] = tostring(M or "")
    return true
  elseif V == "btn" then
    local z = ((T["entered"]:upper()):gsub("%s+", ""))
    if z == T["life"]:upper() then
      T["unlocked"] = true
      A("Key accepted. Unlocked!")
    else
      A("Invalid key.")
    end
    return true
  end
  return false
end
F(u, "onvalue")
local a = ""
local r = false
local G = false
local function e(T)
  local A = {}
  T = tostring(T or "")
  T = T:gsub("[\r\n;]+", ",")
  for T in T:gmatch("[^,]+") do
    T = ((T:upper()):gsub("^%s+", "")):gsub("%s+$", "")
    T = T:gsub("[^A-Z0-9%-]", "")
    if T ~= "" then
      A[#A + 1] = T
    end
  end
  if #A == 0 then
    local T = (type(GetWorldName) == "function") and GetWorldName() or ""
    T = ((tostring(T or "")):upper()):gsub("[^A-Z0-9%-]", "")
    if T ~= "" then
      A[1] = T
    end
  end
  return A
end
local function s()
  local T = (type(GetLocal) == "function") and GetLocal() or nil
  if not T or T["posX"] == nil or T["posY"] == nil then
    return nil, nil
  end
  return math["floor"](tonumber(T["posX"]) / 32), math["floor"](tonumber(T["posY"]) / 32)
end
local function Y(T, A)
  local z = GetLocal()
  if not z or type(SendPacketRaw) ~= "function" then
    return
  end
  SendPacketRaw(
    false,
    { ["type"] = 3, ["value"] = 18, ["px"] = T, ["py"] = A, ["x"] = tonumber(z["posX"]), ["y"] = tonumber(z["posY"]) }
  )
end
local function p()
  local T = GetTile or getTile
  local A = Sleep or sleep
  if
    type(T) ~= "function"
    or type(A) ~= "function"
    or type(FindPath) ~= "function"
    or type(SendPacketRaw) ~= "function"
  then
    z("ZS Auto Clear: required game API is unavailable.")
    return false
  end
  for z = 0, 53, 1 do
    if not G then
      return false
    end
    for F = 0, 99, 1 do
      if not G then
        return false
      end
      local U, w = pcall(T, F, z)
      if
        U
        and (
          type(w) == "table"
          and (
            not w["extra"]
            and (((tonumber(w["bg"]) or 0) ~= 0 or ((tonumber(w["fg"]) or 0) % 2 == 1)) and tonumber(w["fg"]) ~= 8)
          )
        )
      then
        local U = math["max"](0, z - 1)
        local w, P = s()
        if w == nil then
          return false
        end
        if math["abs"](w - F) > 2 or math["abs"](P - U) > 2 then
          FindPath(F, U)
          A(math["random"](55, 70))
        end
        while G do
          local U, w = pcall(T, F, z)
          if not U or type(w) ~= "table" or ((tonumber(w["fg"]) or 0) == 0 and (tonumber(w["bg"]) or 0) == 0) then
            break
          end
          if w["extra"] then
            break
          end
          Y(F, z)
          A(math["random"](180, 230))
        end
      end
    end
  end
  return G
end
local function y()
  if r then
    z("ZS Auto Clear is already running.")
    return
  end
  if type(runThread) ~= "function" then
    z("ZS Auto Clear cannot start: runThread API is unavailable.")
    return
  end
  local T = e(a)
  if #T == 0 then
    z("ZS Auto Clear: enter at least one world name.")
    return
  end
  G = true
  r = true
  z("ZS Auto Clear started. Worlds: " .. table["concat"](T, ", "))
  runThread(function()
    local A = Sleep or sleep
    for F, U in ipairs(T) do
      if not G then
        break
      end
      z("ZS Auto Clear: joining " .. (U .. (" (" .. (F .. ("/" .. (#T .. ")"))))))
      if type(SendPacket) == "function" then
        SendPacket(3, "action|join_request\nname|" .. U)
      else
        z("ZS Auto Clear: SendPacket API is unavailable.")
        break
      end
      A(4000)
      if G then
        z("ZS Auto Clear: clearing " .. U)
        if not p() then
          break
        end
        z("ZS Auto Clear: finished " .. U)
        A(2000)
      end
    end
    local F = G
    G = false
    r = false
    z(F and "ZS Auto Clear: all listed worlds finished." or "ZS Auto Clear stopped.")
  end)
end
local function E()
  G = false
  z("ZS Auto Clear stop requested.")
end
local n = UserInterface["new"]("ZS AUTO CLEAR", "Build")
n:addLabelApp("* ZS AUTO CLEAR *", "Build")
n:addTooltip(
  "ZS AUTO CLEAR",
  "AUTO CLEAR processes the worlds you enter. Use only worlds you own or have permission to edit.",
  "Info",
  true
)
n:addDivider()
n:addInputString(
  "Multiworld Box",
  "",
  "Worlds to Clear",
  "Enter world names separated by commas, e.g. WORLD1, WORLD2, WORLD3",
  "Worlds",
  "zs_clear_worlds"
)
n:addToggle("ZS AUTO CLEAR", false, "zs_clear_toggle", true)
M(n:generateJSON(), "ZS")
U(function(T, A, z)
  if A == "zs_clear_worlds" then
    a = tostring(z or "")
  elseif A == "zs_clear_toggle" then
    if z then
      y()
    else
      E()
    end
  end
end, "onValue")
if type(applyHook) == "function" then
  pcall(applyHook)
end
