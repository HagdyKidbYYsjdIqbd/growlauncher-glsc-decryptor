local f = "SAHIL PROXY"
local R = "SAHILPROXY"
local n = "1.2-DIAGNOSTIC"
local j = "sahil"
local U = false
local C = true
local Z, m, c = 242, 1796, 7188
local p = 100
local u = 100
local M = 450
local a = 800
local i = 900
local V = LogToConsole or log
local o = sendPacket or SendPacket
local z = sendPacketRaw or SendPacketRaw
local y = sendVariant or SendVariant
local W = getInventory or GetInventory
local L = runThread or RunThread
local B = sleep or Sleep
local x = false
local v = false
local G = 0
local function q(f)
  return ((tostring(f)):gsub("`.", ""))
end
local function O(f)
  return (f:match("^%s*(.-)%s*$"))
end
local function P(R)
  V("`9[" .. (f .. ("] `0" .. R)))
  if y then
    pcall(y, { ["v1"] = "OnTextOverlay", ["v2"] = q(R) })
  end
end
local function N(f)
  if not y then
    return false
  end
  local R = pcall(y, { ["v1"] = "OnDialogRequest", ["v2"] = f })
  return R
end
local function F(f)
  if not L then
    return
  end
  local R = B or sleep
  if R then
    R(f)
  end
end
local function D(f)
  if L then
    L(function()
      pcall(f)
    end)
  else
    pcall(f)
  end
end
local function l(f)
  local R = tonumber(f)
  if R and (R >= 1 and R == math["floor"](R)) then
    return R
  end
  return nil
end
local k = { [c] = "BGL", [m] = "DL", [Z] = "WL" }
local function J()
  local f, R, n = 0, 0, 0
  for j, U in pairs(W()) do
    local C = U["amount"] or U["count"] or 0
    if U["id"] == Z then
      f = f + C
    elseif U["id"] == m then
      R = R + C
    elseif U["id"] == c then
      n = n + C
    end
  end
  return f, R, n
end
local function S(f)
  local R = {}
  for f, n in ipairs(f) do
    R[#R + 1] = n["amount"] .. (" " .. k[n["id"]])
  end
  return table["concat"](R, " + ")
end
local function Q(f, R)
  G = G + 1
  o(2, "action|drop\n|itemID|" .. f)
  o(2, "action|dialog_return\ndialog_name|drop_item\nitemID|" .. (f .. ("|\ncount|" .. R)))
end
local function T(f)
  local R, n = 0, 0
  for f, j in ipairs(f) do
    if j == c then
      R = R + 1
    else
      n = n + 1
    end
  end
  local j = {}
  if R > 0 then
    j[#j + 1] = R .. " BGL"
  end
  if n > 0 then
    j[#j + 1] = n .. " DL"
  end
  return table["concat"](j, " + ")
end
local function A(f, R, n)
  n = n or {}
  if v then
    P("`4Please wait, still dropping...")
    return
  end
  v = true
  local j = (R or "Dropping") .. (" " .. S(f))
  if #n > 0 then
    j = j .. (" (breaking " .. (T(n) .. " first)"))
  end
  P("`2" .. j)
  D(function()
    local R, j = pcall(function()
      for f, R in ipairs(n) do
        if not z then
          error("sendPacketRaw is not available, can't break locks")
        end
        z(false, { ["type"] = 10, ["value"] = R })
        F(a)
      end
      for R, n in ipairs(f) do
        Q(n["id"], n["amount"])
        if R < #f then
          F(M)
        end
      end
      F(i)
    end)
    if L then
      G = 0
    end
    v = false
    if not R then
      P("`4Drop stopped: " .. tostring(j))
    end
  end)
end
local function Y(f)
  local R, n, j = J()
  local U = p * u
  local C = (R + n * p) + j * U
  if C < f then
    return nil, "Don't have enough to drop " .. (f .. (" WL (you have " .. (C .. " WL worth of locks)")))
  end
  local M = {}
  local a, i, V
  for C = 1, 10, 1 do
    a = math["min"](j, math["floor"](f / U))
    V = f - a * U
    i = math["min"](n, math["floor"](V / p))
    V = V - i * p
    if V <= R then
      break
    end
    if n - i >= 1 then
      local f = math["min"](n - i, math["ceil"]((V - R) / p))
      for f = 1, f, 1 do
        M[#M + 1] = m
      end
      n = n - f
      R = R + f * p
    elseif j - a >= 1 then
      M[#M + 1] = c
      j = j - 1
      n = n + u
    else
      break
    end
  end
  if V > R then
    return nil, "Can't make the change for " .. (f .. " WL with the locks you have")
  end
  local o = {}
  if a > 0 then
    o[#o + 1] = { ["id"] = c, ["amount"] = a }
  end
  if i > 0 then
    o[#o + 1] = { ["id"] = m, ["amount"] = i }
  end
  if V > 0 then
    o[#o + 1] = { ["id"] = Z, ["amount"] = V }
  end
  return o, M
end
local function w(f, R, n)
  local j = l(R[1])
  if not j then
    P("`4Usage: " .. n)
    return
  end
  local U, C, c = J()
  local p = (f == Z and U) or (f == m and C) or c
  if p < j then
    P("`4Don't have enough " .. (k[f] .. (" to drop! You have " .. p)))
    return
  end
  A({ { ["id"] = f, ["amount"] = j } })
end
local e = {}
local I = {}
local h = {}
local function g(f)
  e[f["name"]] = f
  for R, n in ipairs(f["aliases"] or {}) do
    e[n] = f
  end
  if not f["hidden"] then
    if not h[f["group"]] then
      h[f["group"]] = {}
      I[#I + 1] = f["group"]
    end
    local R = h[f["group"]]
    R[#R + 1] = f
  end
end
local function r(R)
  local n = {
    "set_default_color|`o",
    "add_label_with_icon|big|`w" .. (f .. (" - Script Access``|left|" .. (m .. "|"))),
    "add_spacer|small|",
    "add_textbox|`oEnter the password to unlock the script.``|left|",
  }
  if R then
    n[#n + 1] = "add_textbox|`4" .. (R .. "``|left|")
  end
  n[#n + 1] = "add_text_input|password|Password:||30|"
  n[#n + 1] = "end_dialog|sahilproxy_login|Cancel|Unlock|"
  return table["concat"](n, "\n")
end
local function X()
  local j = {
    "set_default_color|`o",
    "add_label_with_icon|big|`wALL FEATURES (" .. (f .. (")``|left|" .. (m .. "|"))),
    "add_spacer|small|",
  }
  for f, R in ipairs(I) do
    j[#j + 1] = "add_label_with_icon|small|`2" .. (R .. ("``|left|" .. (Z .. "|")))
    for f, R in ipairs(h[R]) do
      j[#j + 1] = "add_textbox|`w" .. (R["usage"] .. (" `o= " .. (R["desc"] .. "``|left|")))
      for f, R in ipairs(R["examples"] or {}) do
        j[#j + 1] = "add_textbox|`9Ex: " .. (R .. "``|left|")
      end
    end
    j[#j + 1] = "add_spacer|small|"
  end
  j[#j + 1] = "add_textbox|`oMade by `2" .. (R .. (" `ov" .. (n .. "``|left|")))
  j[#j + 1] = "end_dialog|sahilproxy_list||Close|"
  return table["concat"](j, "\n")
end
local function b()
  return table["concat"](
    {
      "set_default_color|`o",
      "add_label_with_icon|big|`4WRONG PASS``|left|32|",
      "add_spacer|small|",
      "add_textbox|`oThat password is incorrect.``|left|",
      "add_spacer|small|",
      "end_dialog|sahilproxy_wrong||Try Again|",
    },
    "\n"
  )
end
local function H()
  if not N(b()) then
    P("`4WRONG PASS")
  end
end
local function K(f)
  if not N(r(f)) then
    P("`4Locked. Type `2/login <password>`4 to unlock.")
  end
end
g({
  ["name"] = "proxy",
  ["group"] = "GENERAL",
  ["usage"] = "/proxy",
  ["desc"] = "shows this feature list",
  ["run"] = function()
    if not N(X()) then
      V("`wALL FEATURES (" .. (f .. ")"))
      for f, R in ipairs(I) do
        V("`2" .. R)
        for f, R in ipairs(h[R]) do
          V("`w" .. (R["usage"] .. (" `o= " .. R["desc"])))
        end
      end
    end
  end,
})
g({
  ["name"] = "login",
  ["hidden"] = true,
  ["run"] = function(f)
    if x then
      P("`2Already unlocked. Type /proxy")
    elseif f[1] == j then
      x = true
      P("`2Unlocked! Type /proxy to see all features.")
    else
      H()
    end
  end,
})
g({
  ["name"] = "cd",
  ["group"] = "DROP COMMANDS",
  ["usage"] = "/cd (amount)",
  ["desc"] = "custom lock drop (amount in world locks, breaks a DL into WL automatically if needed)",
  ["examples"] = {
    "/cd 50 drops 50 WL",
    "/cd 250 drops 2 DL + 50 WL",
    "/cd 2500 drops 25 DL",
    "/cd 15000 drops 1 BGL + 50 DL",
  },
  ["run"] = function(f)
    local R = l(f[1])
    if not R then
      P("`4Usage: /cd (amount)   Ex: /cd 250")
      return
    end
    local n, j = Y(R)
    if not n then
      P("`4" .. j)
      return
    end
    A(n, nil, j)
  end,
})
g({
  ["name"] = "dd",
  ["group"] = "DROP COMMANDS",
  ["usage"] = "/dd (amount)",
  ["desc"] = "drops diamond locks",
  ["examples"] = { "/dd 50 drops 50 DL" },
  ["run"] = function(f)
    w(m, f, "/dd (amount)   Ex: /dd 50")
  end,
})
g({
  ["name"] = "dbgl",
  ["group"] = "DROP COMMANDS",
  ["usage"] = "/dbgl (amount)",
  ["desc"] = "drops blue gem locks",
  ["examples"] = { "/dbgl 2 drops 2 BGL" },
  ["run"] = function(f)
    w(c, f, "/dbgl (amount)   Ex: /dbgl 2")
  end,
})
g({
  ["name"] = "daw",
  ["group"] = "DROP COMMANDS",
  ["usage"] = "/daw",
  ["desc"] = "drops all your BGL, DL and WL",
  ["run"] = function()
    local f, R, n = J()
    local j = {}
    if n > 0 then
      j[#j + 1] = { ["id"] = c, ["amount"] = n }
    end
    if R > 0 then
      j[#j + 1] = { ["id"] = m, ["amount"] = R }
    end
    if f > 0 then
      j[#j + 1] = { ["id"] = Z, ["amount"] = f }
    end
    if #j == 0 then
      P("`4You don't have any locks to drop.")
      return
    end
    A(j, "Dropping all:")
  end,
})
local function E(f)
  if type(f) ~= "string" then
    return false
  end
  if U and (f:find("input", 1, true) or f:find("dialog_name", 1, true)) then
    V("`3[DEBUG] sent: " .. (f:gsub("\n", "\\n")))
  end
  if f:find("dialog_name|sahilproxy_login", 1, true) then
    local R = O(f:match("password|([^\n]*)") or "")
    if R == j then
      x = true
      P("`2Unlocked! Type /proxy to see all features.")
    elseif R ~= "" then
      H()
    end
    return true
  end
  if f:find("dialog_name|sahilproxy_wrong", 1, true) then
    K()
    return true
  end
  if f:find("dialog_name|sahilproxy_list", 1, true) then
    return true
  end
  if not f:find("action|input", 1, true) then
    return false
  end
  local R = f:match("text|([^\n]*)")
  if not R then
    return false
  end
  R = O((R:gsub("%c", "")))
  local n, C = R:match("^%.?/(%S+)%s*(.*)$")
  if not n then
    return false
  end
  local Z = e[n:lower()]
  if not Z then
    return false
  end
  if not x and Z["name"] ~= "login" then
    P("`4Locked. Enter the password to use the script.")
    K()
    return true
  end
  local m = {}
  for f in C:gmatch("%S+") do
    m[#m + 1] = f
  end
  local c, p = pcall(Z["run"], m)
  if not c then
    P("`4Error: " .. tostring(p))
  end
  return true
end
local function s(R, n)
  local j, U = pcall(E, n)
  if not j then
    V("`4[" .. (f .. ("] hook error: " .. tostring(U))))
    return false
  end
  return U == true
end
local function t(f)
  if U or C then
    for R, n in ipairs({ 0, 1, 2, "v1", "v2", "v3" }) do
      local j, Z = pcall(function()
        return f[n]
      end)
      if j and type(Z) == "string" then
        if U and Z:find("end_dialog|", 1, true) then
          V("`3[DEBUG] dialog: " .. ((Z:sub(1, 70)):gsub("\n", " ")))
          break
        end
        if C and (Z:find("add_", 1, true) and Z:find("end_dialog|", 1, true)) then
          V("`6[WRENCH DEBUG] Dialog payload follows:")
          V("`6[WRENCH DEBUG] " .. (Z:sub(1, 3500)):gsub("\n", "\\n"))
          break
        end
      end
    end
  end
  if G <= 0 then
    return false
  end
  for R, n in ipairs({ 0, 1, 2, "v1", "v2", "v3" }) do
    local j, U = pcall(function()
      return f[n]
    end)
    if j and (type(U) == "string" and U:find("end_dialog|drop_item", 1, true)) then
      G = G - 1
      return true
    end
  end
  return false
end
local function d(f, R)
  local n, j = pcall(t, f)
  if not n then
    return false
  end
  return j == true
end
if addHook then
  addHook(s, "onsendpacket")
  addHook(d, "onvariant")
elseif AddHook then
  AddHook("onsendpacket", "sahilproxy_hook", s)
  AddHook("onvariant", "sahilproxy_variant", d)
else
  V("`4[" .. (f .. "] No hook function found, commands will not work."))
end
if U then
  V("`3[DEBUG] " .. (f .. (" v" .. (n .. " loaded. Chat hook is active."))))
end
K()
