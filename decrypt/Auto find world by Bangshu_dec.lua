setMinimum("6.1.2")
local Z = "Random World Lock Finder"
local N =
  "https://script.google.com/macros/s/AKfycbxeBzpOUzvcRDkX-4eR8uioFbAUDsepIQc26kmxUkXt6YOjBxFdVsOE0zzvxYSprl5knA/exec"
local c = "RANDOM"
local m
local e = ""
local C = 0
local function E(Z)
  return (((tostring(Z or "")):gsub("%s+", ""))):upper()
end
pcall(function()
  local Z = Preferences
  if type(require) == "function" then
    local N, c = pcall(require, "preferences")
    if N and type(c) == "table" then
      Z = c
    end
  end
  if type(Z) ~= "table" or type(Z["new"]) ~= "function" then
    return
  end
  m = Z:new("RandomWorldLockFinderLicense")
  m:load()
  e = E(m:get("license_key", ""))
end)
local function D(Z)
  if not m then
    return false
  end
  return pcall(function()
    m:set("license_key", Z)
    m:save()
  end)
end
local T, t = 242, 6
local h = 3500
local function z(Z, ...)
  if type(Z) ~= "function" then
    return nil
  end
  local N, c = pcall(Z, ...)
  if N then
    return c
  end
end
local function f(Z, ...)
  if type(Z) ~= "function" then
    return false
  end
  local N, c = pcall(Z, ...)
  return N and c ~= false
end
local function S(Z, N, c, m)
  return math["max"](c, math["min"](m, math["floor"](tonumber(Z) or N)))
end
local J
local w, g, U, P = 5, false, false, 1
pcall(function()
  local Z, N = pcall(require, "preferences")
  if not Z or type(N) ~= "table" then
    N = Preferences
  end
  if type(N) ~= "table" or type(N["new"]) ~= "function" then
    return
  end
  J = N:new("RandomWorldLockFinder")
  J:load()
  w = S(J:get("length", "5"), 5, 1, 10)
  g = J:get("numbers", "off") == "on"
  P = S(J:get("target", "1"), 1, 1, 1000000)
end)
local function R()
  if not J then
    return
  end
  pcall(function()
    J:set("length", tostring(w))
    J:set("numbers", g and "on" or "off")
    J:set("target", tostring(P))
    J:save()
  end)
end
local n = UserInterface["new"](Z, "Globe")
n:addLabelApp(Z, "Globe")
n:addInputString("License Key", e, "A1234567", "A1234567", nil, "RWF_licensekey")
n:addButton("Verify License", "RWF_verifylicense")
n:addButton("Clear Saved License", "RWF_clearlicense")
n:addDisplayList("License Status", "NOT VERIFIED", "RWF_licensestatus")
n:addToggle("Start / Stop", false, "RWF_start")
n:addSlider("World Name Length", 1, 10, w, 1, false, "RWF_length")
n:addToggle("Use Numbers", g, "RWF_numbers")
n:addToggle("Auto Lock", false, "RWF_lock")
n:addInputInt("Total World Target", tostring(P), "Worlds", "1", nil, "RWF_target")
n:addDisplayList("Worlds Locked", "0", "RWF_count")
n:addDisplayList("Status", "STOPPED", "RWF_status")
z(addCategory, Z, "Globe")
local i = n:generateJSON()
if not f(addIntoModule, i, Z) then
  f(addIntoModule, i)
end
local q, L, H
local function I(Z)
  z(editValue, "RWF_status", Z)
end
local function Q(Z)
  H = true
  z(editToggle or EditToggle, Z, false)
  H = false
end
local function s(Z)
  z(growtopia and growtopia["notify"], Z)
end
local function X(Z)
  return q == Z
end
local function o(Z, N)
  local c = Sleep or sleep
  while N > 0 and X(Z) do
    local Z = math["min"](N, 100)
    c(Z)
    N = N - Z
  end
  return X(Z)
end
local function r()
  return (tostring(z(GetWorldName or getCurrentWorldName) or "")):upper()
end
local function G()
  local Z = z(GetLocal or getLocal)
  local N, c
  if Z then
    N, c = tonumber(Z["posX"]), tonumber(Z["posY"])
  end
  if N and c then
    return Z, math["floor"](N / 32), math["floor"](c / 32)
  end
end
local function F(Z, N)
  return X(Z) and (r() == N and G() ~= nil)
end
local function B()
  local Z = z(GetInventory or getInventory)
  if type(Z) ~= "table" then
    return tonumber(z(growtopia and growtopia["checkInventoryCount"], T))
  end
  for Z, N in pairs(Z) do
    if tonumber(N["id"]) == T then
      return tonumber(N["amount"])
    end
  end
  return 0
end
local function j(Z, N)
  local c = #Z
  local m, e = c ^ N, {}
  return function()
    if m == 0 then
      return nil
    end
    local C = math["min"](m - 1, math["floor"](math["random"]() * m))
    local E = m - 1
    local D = e[C] or C
    e[C] = e[E] or E
    e[E] = nil
    m = E
    local T = {}
    for N = N, 1, -1 do
      local m = D % c + 1
      T[N] = Z:sub(m, m)
      D = math["floor"](D / c)
    end
    return table["concat"](T)
  end
end
local function u(Z, N)
  return z(GetTile or getTile or (tile and tile["getTile"]), Z, N)
end
local function x()
  local Z = z(getWorldTileMap or GetWorldTileMap)
  if Z and Z["size"] then
    local N, c = tonumber(Z["size"]["x"]), tonumber(Z["size"]["y"])
    if N and (c and (N > 0 and (c > 0 and (N % 1 == 0 and c % 1 == 0)))) then
      return N, c
    end
  end
  return 100, 60
end
local function y(Z, N)
  if not X(Z) then
    return false
  end
  if r() ~= N or not G() then
    local Z = growtopia and growtopia["warpTo"]
    local c
    if type(Z) == "function" then
      c = f(Z, N)
    else
      c = f(SendPacket or sendPacket, 3, "action|join_request\nname|" .. (N .. "\ninvitedWorld|0"))
    end
    if not c then
      return false
    end
  end
  for c = 1, 50, 1 do
    if not X(Z) then
      return false
    end
    if F(Z, N) then
      local c, m = x()
      if u(0, 0) and u(c - 1, m - 1) then
        return o(Z, 600) and F(Z, N)
      end
    end
    if not o(Z, 200) then
      return false
    end
  end
  return false
end
local function d(Z)
  return z(getItemInfoByID or GetItemInfoByID, Z)
end
local function v(Z, N)
  if N == 0 or N == t then
    return false
  end
  if N == T then
    return true
  end
  local c = Z["lockTypes"][N]
  if c ~= nil then
    return c
  end
  local m = d(N)
  if not m or not tonumber(m["type"]) then
    return nil
  end
  local e = (tostring(m["name"] or "")):lower()
  local C = tonumber(m["type"]) == Z["lockType"] or e:find("%f[%a]lock%f[%A]") ~= nil
  Z["lockTypes"][N] = C
  return C
end
local function W(Z, N)
  if not F(Z, N) then
    return "UNKNOWN"
  end
  local c = z(GetTiles or getTiles)
  if type(c) ~= "table" then
    return "UNKNOWN"
  end
  local m, e = x()
  local C, E = {}, 0
  local D, T
  for N, c in pairs(c) do
    local h, z, f = tonumber(c["x"]), tonumber(c["y"]), tonumber(c["fg"])
    if not h or not z or not f or h % 1 ~= 0 or z % 1 ~= 0 or h < 0 or h >= m or z < 0 or z >= e then
      return "UNKNOWN"
    end
    local S = z * m + h
    if C[S] then
      return "UNKNOWN"
    end
    C[S], E = true, E + 1
    if c["extra"] and tonumber(c["extra"]["type"]) == 3 then
      return "LOCKED"
    end
    local J = v(Z, f)
    if J == nil then
      return "UNKNOWN"
    end
    if J then
      return "LOCKED"
    end
    if f == t then
      if D then
        return "UNKNOWN"
      end
      D, T = h, z
    end
  end
  if E ~= m * e or not D or T < 1 or not F(Z, N) then
    return "UNKNOWN"
  end
  return "UNLOCKED", D, T
end
local function M(Z, N, c, m)
  local e, C, E = G()
  if C == c and E == m then
    return true
  end
  if not F(Z, N) or not f(FindPath or findPath, c, m) then
    return false
  end
  for e = 1, 25, 1 do
    if not o(Z, 100) or not F(Z, N) then
      return false
    end
    e, C, E = G()
    if C == c and E == m then
      return true
    end
  end
  return false
end
local function O(Z, N, c, m)
  local e, C = c, m - 1
  local E = u(e, C)
  if not E or tonumber(E["fg"]) ~= 0 then
    return "BLOCKED"
  end
  local D, t, h = G()
  if not t or math["abs"](t - e) + math["abs"](h - C) ~= 1 then
    if not M(Z, N, c, m) then
      return "BLOCKED"
    end
  end
  local z, S, J = W(Z, N)
  if z ~= "UNLOCKED" or S ~= c or J ~= m then
    return "CHANGED"
  end
  local w = B()
  if not w or w < 1 then
    return "NO STOCK"
  end
  if not F(Z, N) or not U then
    return "DISABLED"
  end
  E = u(e, C)
  local g, P, R = G()
  if not E or tonumber(E["fg"]) ~= 0 or not g or math["abs"](P - e) + math["abs"](R - C) ~= 1 then
    return "BLOCKED"
  end
  if
    not f(
      SendPacketRaw or sendPacketRaw,
      false,
      { ["type"] = 3, ["value"] = T, ["px"] = e, ["py"] = C, ["x"] = g["posX"], ["y"] = g["posY"] }
    )
  then
    return "UNCONFIRMED"
  end
  for c = 1, 35, 1 do
    if not o(Z, 100) or not F(Z, N) then
      return "UNCONFIRMED"
    end
    E = u(e, C)
    local m = B()
    if E and (tonumber(E["fg"]) == T and (m and m == w - 1)) then
      local Z = E["extra"] and (tonumber(E["extra"]["owner"]) or tonumber(E["extra"]["owner_signed"]))
      local N = tonumber(g["userID"])
      if Z and (Z ~= 0 and (N and (N ~= 0 and Z ~= N))) then
        return "UNCONFIRMED"
      end
      return "PLACED"
    end
  end
  return "UNCONFIRMED"
end
local function k(Z)
  local N = d(T)
  Z["lockType"] = N and tonumber(N["type"])
  if not Z["lockType"] then
    return "Could not read World Lock item data."
  end
  local c = j(Z["chars"], Z["length"])
  local m = 0
  while X(Z) do
    if U then
      local Z = B()
      if not Z or Z < 1 then
        return "Stopped. No World Locks available."
      end
    end
    local N = c()
    if not N then
      return "All names in this search were tried. Locked " .. (m .. ".")
    end
    I("VISITING " .. N)
    if y(Z, N) then
      I("CHECKING " .. N)
      local c, e, C = W(Z, N)
      if c == "UNLOCKED" then
        if not U then
          return "Unlocked candidate found: " .. N
        end
        local c = O(Z, N, e, C)
        if c == "PLACED" then
          m = m + 1
          z(editValue, "RWF_count", tostring(m))
          if m >= Z["target"] then
            return "Target reached. Locked " .. (m .. " worlds.")
          end
          I("LOCKED " .. N)
        elseif c == "UNCONFIRMED" then
          return "Placement could not be confirmed in " .. (N .. ". Check the world and backpack.")
        elseif c == "NO STOCK" then
          return "Stopped. No World Locks available."
        elseif c == "DISABLED" and (X(Z) and F(Z, N)) then
          return "Unlocked candidate found: " .. N
        else
          I("SKIPPING " .. (N .. (" - " .. c)))
        end
      else
        I("SKIPPING " .. (N .. (" - " .. c)))
      end
    elseif X(Z) then
      I("VISIT FAILED: " .. (N .. " - TRYING ANOTHER"))
    end
    if not o(Z, h) then
      break
    end
  end
  return "STOPPED"
end
local function V(Z)
  Z = tostring(Z or "")
  Z = Z:gsub("\n", "\r\n")
  Z = Z:gsub("([^%w%-_%.~])", function(Z)
    return string["format"]("%%%02X", string["byte"](Z))
  end)
  return Z
end
local function l()
  local Z = ""
  if type(getDiscordID) == "function" then
    local N, c = pcall(getDiscordID)
    if N and c ~= nil then
      Z = tostring(c)
    end
  elseif getDiscordID ~= nil then
    Z = tostring(getDiscordID)
  end
  Z = ((tostring(Z or "")):gsub("^%s+", "")):gsub("%s+$", "")
  if Z == "" or Z == "nil" or Z == "0" then
    local N = GetLocal or getLocal
    if N ~= nil then
      local c, m = pcall(N)
      if c and (m ~= nil and m["name"] ~= nil) then
        Z = tostring(m["name"])
        Z = (Z:gsub("^%s+", "")):gsub("%s+$", "")
      end
    end
  end
  if Z == "nil" or Z == "0" then
    return ""
  end
  return Z
end
local function Y(Z)
  pcall(editValue, "RWF_licensestatus", Z)
end
local p = {
  ["DISABLED"] = { "DISABLED", "License disabled." },
  ["WRONG_PRODUCT"] = { "WRONG PRODUCT", "This license is for another script." },
  ["BOUND_TO_OTHER_USER"] = { "BOUND TO OTHER USER", "License is bound to another user." },
  ["INVALID_KEY"] = { "INVALID KEY", "Invalid license key." },
  ["BAD_KEY_FORMAT"] = { "BAD KEY FORMAT", "License key format is invalid." },
  ["NO_ID"] = { "NO CLIENT ID", "Client ID is unavailable." },
}
local function A(Z)
  if not Z:match("^[A-Z]%d%d%d%d%d%d%d$") then
    return false, "INVALID KEY FORMAT", "License must be 1 letter + 7 numbers, for example A1234567."
  end
  local m = l()
  if m == "" then
    return false, "NO CLIENT ID", "Could not read a client ID. Enter the game first and try again."
  end
  local e = N .. ("?key=" .. (V(Z) .. ("&id=" .. (V(m) .. ("&product=" .. V(c))))))
  local C, E = pcall(fetch, e)
  if not C then
    return false, "SERVER ERROR", "License server request failed."
  end
  E = (tostring(E or "")):match("^%s*(.-)%s*$")
  local D = E:match("DENY|([A-Z_]+)")
  if D then
    local Z = p[D]
    if Z then
      return false, Z[1], Z[2]
    end
    return false, "DENIED", "License denied by server."
  end
  if E:find("OK|PERMANENT", 1, true) then
    return true, "VERIFIED - PERMANENT"
  end
  if E == "" then
    return false, "NO RESPONSE", "License server gave no response."
  end
  return false, "CHECK FAILED", "License check failed."
end
local b, K
local a = false
local function Zt(Z)
  q, L = Z, true
  z(editValue, "RWF_count", "0")
  I("STARTING")
  runThread(function()
    local N, c = pcall(k, Z)
    L = false
    if not X(Z) then
      return
    end
    q = nil
    Q("RWF_start")
    if (B() or 0) < 1 and U then
      U = false
      Q("RWF_lock")
    end
    local m = N and c or "Search stopped: " .. tostring(c)
    I(m)
    s(m)
  end)
end
local function Nt(Z)
  Z["key"] = e
  Z["revision"] = C
  K = Z
  if a then
    return
  end
  a = true
  runThread(function()
    while K do
      local Z = K
      K = nil
      if Z["revision"] == C and (not Z["run"] or b == Z) then
        Y("CHECKING...")
        local N, c, m = A(Z["key"])
        if Z["revision"] == C then
          Y(c)
          if N then
            local N = D(Z["key"])
            if Z["manual"] then
              s(N and "License verified and saved." or "License verified. Could not save it.")
            end
          elseif Z["manual"] or b == Z then
            s(m)
          end
          if b == Z then
            b = nil
            if N then
              Zt(Z["run"])
            else
              Q("RWF_start")
              I("STOPPED")
            end
          end
        end
      end
    end
    a = false
  end)
end
local function ct()
  if not b then
    return
  end
  b = nil
  Q("RWF_start")
  I("STOPPED")
end
function onValue(Z, N, c)
  if H then
    return
  end
  if N == "RWF_licensekey" then
    local Z = E(c)
    if Z ~= e then
      e = Z
      C = C + 1
      ct()
      Y("NOT VERIFIED")
    end
    return
  end
  if N == "RWF_verifylicense" then
    if not b then
      Nt({ ["manual"] = true })
    end
    return
  end
  if N == "RWF_clearlicense" then
    e = ""
    C = C + 1
    ct()
    local Z = D("")
    pcall(editValue, "RWF_licensekey", "")
    Y("NOT VERIFIED")
    s(Z and "Saved license cleared." or "Could not update saved license storage.")
    return
  end
  if N == "RWF_length" then
    w = S(c, w, 1, 10)
    R()
    return
  end
  if N == "RWF_numbers" then
    g = c == true
    R()
    return
  end
  if N == "RWF_target" then
    P = S(c, P, 1, 1000000)
    R()
    return
  end
  if N == "RWF_lock" then
    if c == true and (B() or 0) < 1 then
      U = false
      Q("RWF_lock")
      s("You need at least 1 World Lock to enable Auto Lock.")
    else
      U = c == true
    end
    return
  end
  if N ~= "RWF_start" then
    return
  end
  if c ~= true then
    b, q = nil, nil
    I("STOPPED")
    return
  end
  if q or b then
    return
  end
  if L then
    Q("RWF_start")
    s("Wait for the previous search to stop.")
    return
  end
  local m = g and "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789" or "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  local T = { ["length"] = w, ["chars"] = m, ["target"] = P, ["lockTypes"] = {} }
  b = { ["run"] = T }
  I("CHECKING LICENSE BEFORE START")
  Nt(b)
end
applyHook()
if e ~= "" then
  Nt({})
end
