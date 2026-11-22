setMinimum("6.1.2")
local i = "Auto Clave by Bangshu"
local t =
  "https://script.google.com/macros/s/AKfycbxeBzpOUzvcRDkX-4eR8uioFbAUDsepIQc26kmxUkXt6YOjBxFdVsOE0zzvxYSprl5knA/exec"
local d = "ACLAVE"
local A
local u = ""
local P = 0
local K = false
local j = false
local function q(i)
  return (((tostring(i or "")):gsub("%s+", ""))):upper()
end
pcall(function()
  local i = Preferences
  if type(require) == "function" then
    local t, d = pcall(require, "preferences")
    if t and type(d) == "table" then
      i = d
    end
  end
  if type(i) ~= "table" or type(i["new"]) ~= "function" then
    return
  end
  A = i:new("BangshuAutoClaveLegacyLicense")
  A:load()
  u = q(A:get("license_key", ""))
end)
local function H(i)
  if not A then
    return false
  end
  return pcall(function()
    if A:set("license_key", i) == false then
      error("License storage rejected key")
    end
    if A:save() == false then
      error("License storage save failed")
    end
  end)
end
local I = {
  "Surgical Sponge",
  "Surgical Splint",
  "Surgical Antiseptic",
  "Surgical Antibiotics",
  "Surgical Anesthetic",
  "Surgical Scalpel",
  "Surgical Stitches",
  "Surgical Lab Kit",
  "Surgical Clamp",
  "Surgical Pins",
  "Surgical Transfusion",
  "Surgical Ultrasound",
  "Surgical Defibrillator",
}
local F = { ["dropX"] = 33, ["dropY"] = 22, ["claveDelay"] = 450, ["dropDelay"] = 450, ["pathDelay"] = 350 }
local s = {
  { "Drop X", "dropX", 0, 99 },
  { "Drop Y", "dropY", 0, 59 },
  { "Autoclave delay (ms)", "claveDelay", 100, 10000 },
  { "Drop delay (ms)", "dropDelay", 100, 10000 },
  { "FindPath delay (ms)", "pathDelay", 100, 10000 },
}
local J, x = {}, {}
for i, t in ipairs(I) do
  x[t:lower()] = true
end
local z
local Z = "UNAVAILABLE"
local function l()
  local i = {}
  for t, d in ipairs(s) do
    i[#i + 1] = tostring(F[d[2]])
  end
  for t, d in ipairs(I) do
    i[#i + 1] = J[d] and "1" or "0"
  end
  return table["concat"](i, ",")
end
pcall(function()
  local i, t = pcall(require, "preferences")
  local d = i and (type(t) == "table" and t) or Preferences
  if type(d) ~= "table" or type(d["new"]) ~= "function" then
    return
  end
  local A = d:new("BangshuAutoClaveSettings.json")
  if
    not A
    or type(A["load"]) ~= "function"
    or type(A["get"]) ~= "function"
    or type(A["set"]) ~= "function"
    or type(A["save"]) ~= "function"
  then
    return
  end
  local u = A:load()
  z, Z = A, "READY"
  if u == false then
    return
  end
  local P = A:get("settings_v1", "")
  if type(P) ~= "string" or P == "" then
    return
  end
  local K = {}
  for i in P:gmatch("[^,]+") do
    K[#K + 1] = i
  end
  if #K ~= #s + #I or table["concat"](K, ",") ~= P then
    return
  end
  for i, t in ipairs(s) do
    local d = K[i]:match("^%d+$") and tonumber(K[i])
    if not d or d < t[3] or d > t[4] then
      return
    end
  end
  for i = 1, #I, 1 do
    local t = K[#s + i]
    if t ~= "0" and t ~= "1" then
      return
    end
  end
  for i, t in ipairs(s) do
    F[t[2]] = tonumber(K[i])
  end
  for i, t in ipairs(I) do
    J[t] = K[#s + i] == "1"
  end
  Z = "RESTORED"
end)
local function V()
  if not z then
    return
  end
  local i, t = pcall(function()
    if z:set("settings_v1", l()) == false then
      return false
    end
    return z:save() ~= false
  end)
  Z = i and (t and "SAVED") or "SAVE FAILED"
  pcall(editValue, "ACL_autosave", Z)
end
local h, E, b = false, false, false
local N, D, L
local v, o
local T, c = false, nil
local G = SendPacket or sendPacket
local y = SendPacketRaw or sendPacketRaw
local p = GetLocal or getLocal
local Q = GetInventory or getInventory
local Y = GetTiles or getTiles
local g = GetWorldName or getCurrentWorldName
local e = EditToggle or editToggle
local function n(i)
  pcall(editValue, "ACL_status", i)
end
local function a()
  if not h then
    return false
  end
  if g() ~= N or p() == nil then
    T = true
    return false
  end
  return not T
end
local function R()
  local i = 0
  local t = 0
  local d = 0
  while h and i <= 60000 do
    if g() == N and p() ~= nil then
      if t >= 1000 then
        if e("ModFly", true) == false or e("Enable AutoCollect", false) == false then
          return false, "STOPPED - could not restore movement and pickup settings"
        end
        T = false
        n("Reconnected to " .. N)
        return true
      end
      t = t + 250
    else
      t = 0
      if i >= d then
        n("Reconnecting to " .. N)
        pcall(G, 3, "action|join_request\nname|" .. (N .. "\ninvitedWorld|0"))
        d = i + 5000
      end
    end
    Sleep(250)
    i = i + 250
  end
  if not h then
    return false, "STOPPED"
  end
  return false, "STOPPED - reconnect timed out"
end
local function B()
  local i = Q()
  if type(i) ~= "table" then
    error("Inventory unavailable")
  end
  local t = {}
  for i, d in pairs(i) do
    local A = tonumber(d["id"] or d["itemID"])
    if A and A > 0 then
      local i = getItemInfoByID(A)
      local u = i and i["name"]
      if type(u) == "string" and x[u:lower()] then
        t[u:lower()] = { ["id"] = A, ["amount"] = tonumber(d["amount"]) or 0 }
      end
    end
  end
  return t
end
local function W(i)
  local t = Q()
  if type(t) ~= "table" then
    return nil
  end
  for t, d in pairs(t) do
    if tonumber(d["id"] or d["itemID"]) == i then
      return tonumber(d["amount"])
    end
  end
  return 0
end
local function M()
  local i = p()
  if not i then
    return nil
  end
  return math["floor"](i["posX"] / 32), math["floor"](i["posY"] / 32)
end
local function S()
  local i, t = M()
  local d = Y()
  if not i or type(d) ~= "table" then
    return nil
  end
  local A = {}
  local u, P, K
  for d, j in pairs(d) do
    local q = tonumber(j["fg"])
    if q and (q > 0 and A[q] == nil) then
      local i = getItemInfoByID(q)
      A[q] = i ~= nil and (type(i["name"]) == "string" and i["name"]:lower() == "autoclave")
    end
    local H, I = tonumber(j["x"]), tonumber(j["y"])
    if q and (A[q] and (H and (I and I > 0))) then
      local d = (H - i) ^ 2 + (I - t) ^ 2
      if not K or d < K or (d == K and (I < P or (I == P and H < u))) then
        u, P, K = H, I, d
      end
    end
  end
  return u, P
end
local function k(i, t)
  local d, A = M()
  return d == i and A == t
end
local X = 0
local function r(i, t)
  local d = t and math["min"](1500, math["floor"](X / 2)) or 0
  Sleep((i + d) + math["random"](0, 100))
end
local function O(i)
  local t = math["min"](12000, math["max"](i, X * 2 + 1500))
  return math["ceil"](t / 100) * 100
end
local function f(i)
  X = math["max"](i, math["floor"](X * 0.9))
end
local function w(i, t)
  for d = 0, t, 100 do
    if not a() then
      return false
    end
    if i() then
      return true, d
    end
    if d < t then
      Sleep(100)
    end
  end
  return false
end
local function U(i, t)
  local d = O(t)
  local A, u = w(i, d)
  if A then
    f(u)
  elseif a() then
    f(d)
  end
  return A
end
local function C(i, t, d)
  if not a() then
    return false
  end
  if k(i, t) then
    return true
  end
  FindPath(i, t)
  r(d, false)
  return w(function()
    return k(i, t)
  end, O(4500))
end
function OnVariant(i)
  if not i or i["v1"] ~= "OnDialogRequest" or not a() then
    return false
  end
  local t = i["v2"]
  if type(t) ~= "string" then
    return false
  end
  if v and t:find("end_dialog|autoclave|", 1, true) then
    local i = tonumber(t:match("embed_data|tilex|(%d+)"))
    local d = tonumber(t:match("embed_data|tiley|(%d+)"))
    if (i == nil or i == v["x"]) and (d == nil or d == v["y"]) then
      o = true
      return true
    end
  end
  if not D or not t:find("end_dialog|drop_item|", 1, true) then
    return false
  end
  local d = tonumber(t:match("embed_data|itemID|(%d+)"))
  if d ~= D then
    return false
  end
  L = true
  return true
end
onVariant = OnVariant
local function m(i, t)
  if not a() or not k(i, t) then
    return false
  end
  local d = p()
  if not d then
    return false
  end
  v, o = { ["x"] = i, ["y"] = t }, false
  y(false, { ["type"] = 3, ["value"] = 32, ["px"] = i, ["py"] = t, ["x"] = d["posX"], ["y"] = d["posY"] })
  local A = U(function()
    return o
  end, 4000)
  v, o = nil, false
  return A and (a() and k(i, t))
end
local function i7(i, t, d, A)
  if not C(t, d, A["pathDelay"]) then
    return "PATH"
  end
  local u = W(i["id"])
  if u ~= 200 then
    return "RESCAN"
  end
  D, L = i["id"], false
  G(2, "action|drop\nitemID|" .. i["id"])
  local P = U(function()
    return L
  end, 4000)
  D, L = nil, false
  if not a() or not k(t, d) then
    return "STOP"
  end
  if not P then
    return "REJECTED"
  end
  c = { ["id"] = i["id"], ["maxAmount"] = u - 1, ["label"] = "drop" }
  G(2, "action|dialog_return\ndialog_name|drop_item\nitemID|" .. (i["id"] .. ("|\ncount|" .. u)))
  r(A["dropDelay"], true)
  if U(function()
    local t = W(i["id"])
    return t ~= nil and t < u
  end, 5000) then
    c = nil
    return "OK"
  end
  if not a() then
    return "STOP"
  end
  c = nil
  return "UNCONFIRMED"
end
local t7 = GetObjectList or getObjectList
local d7
function OnSendPacketRaw(i)
  if E and (i and tonumber(i["type"]) == 11) then
    return d7 == nil or tonumber(i["value"]) ~= d7
  end
  return false
end
onSendPacketRaw = OnSendPacketRaw
local function A7(i, t)
  return i .. ("," .. t)
end
local function u7()
  local i = t7()
  if type(i) ~= "table" then
    error("World objects unavailable")
  end
  return i
end
local function P7(i)
  for t, d in pairs(u7()) do
    if tonumber(d["id"]) == i then
      return true
    end
  end
  return false
end
local function K7(i, t)
  local d, A, u = {}, {}, {}
  local P = {}
  for u, K in pairs(u7()) do
    local j = tonumber(K["itemid"] or K["itemID"])
    if j and P[j] == nil then
      local t = getItemInfoByID(j)
      P[j] = t and (type(t["name"]) == "string" and t["name"]:lower() == i) or false
    end
    if j and P[j] then
      local i = tonumber(K["posX"] or (K["pos"] and K["pos"]["x"]))
      local u = tonumber(K["posY"] or (K["pos"] and K["pos"]["y"]))
      local P = tonumber(K["id"])
      if i and (u and P) then
        local K, q = math["floor"](i / 32), math["floor"](u / 32)
        if not t[A7(K, q)] then
          if not d[q] then
            d[q] = {}
            A[#A + 1] = q
          end
          local t = d[q]
          t[#t + 1] = { ["uid"] = P, ["id"] = j, ["ox"] = i, ["oy"] = u, ["x"] = K, ["y"] = q }
        end
      end
    end
  end
  table["sort"](A)
  local K = M()
  local j = true
  if K and A[1] then
    local i, t = math["huge"], -math["huge"]
    for d, A in ipairs(d[A[1]]) do
      i, t = math["min"](i, A["x"]), math["max"](t, A["x"])
    end
    j = math["abs"](K - i) <= math["abs"](K - t)
  end
  for i, t in ipairs(A) do
    local A = d[t]
    table["sort"](A, function(i, t)
      if i["x"] == t["x"] then
        return i["uid"] < t["uid"]
      end
      if j then
        return i["x"] < t["x"]
      end
      return i["x"] > t["x"]
    end)
    for i, t in ipairs(A) do
      u[#u + 1] = t
    end
    j = not j
  end
  return u
end
local function j7(i, t)
  if not a() then
    return false
  end
  local d, A = M()
  if d ~= t or A ~= i["y"] then
    return false
  end
  if math["abs"](i["x"] - d) > 1 or math["abs"](i["y"] - A) > 1 then
    return false
  end
  local u = false
  for t, d in pairs(u7()) do
    if tonumber(d["id"]) == i["uid"] then
      local t = tonumber(d["posX"] or (d["pos"] and d["pos"]["x"]))
      local A = tonumber(d["posY"] or (d["pos"] and d["pos"]["y"]))
      if
        tonumber(d["itemid"] or d["itemID"]) ~= i["id"]
        or not t
        or not A
        or math["floor"](t / 32) ~= i["x"]
        or math["floor"](A / 32) ~= i["y"]
      then
        return false
      end
      i["ox"], i["oy"] = t, A
      u = true
      break
    end
  end
  if not u then
    return true
  end
  local P = W(i["id"])
  if P == nil or P >= 200 then
    return false
  end
  d7 = i["uid"]
  local K, j = pcall(y, false, { ["type"] = 11, ["value"] = i["uid"], ["x"] = i["ox"], ["y"] = i["oy"] })
  d7 = nil
  if not K or j == false then
    return false
  end
  r(90, false)
  local q = O(3500)
  for d = 0, q, 25 do
    if not a() or not k(t, i["y"]) then
      return false
    end
    if (W(i["id"]) or 0) > P or not P7(i["uid"]) then
      f(d)
      return true
    end
    if d < q then
      Sleep(25)
    end
  end
  f(q)
  return false
end
local function q7(i, t, d)
  local A = K7(i:lower(), d)
  if #A == 0 then
    return "EMPTY"
  end
  n("Collecting " .. i)
  for i, A in ipairs(A) do
    if not a() then
      return "STOP"
    end
    if C(A["x"], A["y"], t["pathDelay"]) then
      if j7(A, A["x"]) then
        return "PROGRESS"
      end
      local i = A["ox"] - A["x"] * 32
      local u = i >= 24 and A["x"] + 1 or (i <= 8 and A["x"] - 1 or nil)
      if
        u and (
          u >= 0 and (
            u <= 99 and (not d[A7(u, A["y"])] and (P7(A["uid"]) and (C(u, A["y"], t["pathDelay"]) and j7(A, u))))
          )
        )
      then
        return "PROGRESS"
      end
    end
  end
  return "BLOCKED"
end
local function H7(i, t)
  local d, A = i["dropX"], i["claveX"]
  local u = { [A7(d, i["dropY"])] = true, [A7(A, i["claveY"] - 1)] = true }
  local P, K = 1, 0
  local function j()
    local j = B()
    local q = I[P]
    if not q then
      for i, d in ipairs(I) do
        local A = j[d:lower()]
        if not t[d] and (A and A["amount"] >= 20) then
          P, q = i, d
          break
        end
      end
      if not q then
        return "DONE - OFF tools exhausted or below 20"
      end
    end
    local H = j[q:lower()]
    if t[q] then
      P = P + 1
    elseif not H or H["amount"] < 20 then
      local t = q7(q, i, u)
      if t == "STOP" then
        return "STOPPED"
      end
      if t == "BLOCKED" then
        return "STOPPED - cannot collect " .. q
      end
      if t == "EMPTY" then
        K = K + 1
        if K >= 3 then
          P, K = P + 1, 0
        end
      else
        K = 0
      end
    else
      K = 0
      local P, F
      for i, t in ipairs(I) do
        local d = j[t:lower()]
        if d and (d["id"] ~= H["id"] and d["amount"] >= 200) then
          P, F = d, t
          break
        end
      end
      if P then
        local K = t[F]
        local j = K and d or A
        local q = K and i["dropY"] or i["claveY"] - 1
        if K and (j == i["claveX"] and q == i["claveY"] - 1) then
          return "STOPPED - set a separate drop tile for saved tools"
        end
        u[A7(j, q)] = true
        n("Storing " .. F)
        local H = i7(P, j, q, i)
        if H == "REJECTED" or H == "UNCONFIRMED" then
          if j == 0 then
            return "STOPPED - no storage tile left"
          end
          j = j - 1
          if K then
            d = j
          else
            A = j
          end
          n("Storage rejected - shifting left to X " .. j)
        elseif H == "PATH" then
          return "STOPPED - cannot reach storage tile"
        elseif H == "STOP" then
          return "STOPPED"
        end
      else
        if not C(i["claveX"], i["claveY"], i["pathDelay"]) then
          return "STOPPED - cannot reach the exact autoclave tile"
        end
        local t = W(H["id"])
        if t and t >= 20 then
          if not a() or not k(i["claveX"], i["claveY"]) then
            return "STOPPED"
          end
          n("Opening autoclave")
          if not m(i["claveX"], i["claveY"]) then
            return "STOPPED - autoclave dialog did not open"
          end
          n("Autoclaving " .. q)
          local d = "action|dialog_return\ndialog_name|autoclave\ntilex|"
            .. (i["claveX"] .. ("|\ntiley|" .. (i["claveY"] .. "|\n")))
          G(2, d .. ("buttonClicked|tool" .. H["id"]))
          r(i["claveDelay"], true)
          if not a() or not k(i["claveX"], i["claveY"]) then
            return "STOPPED"
          end
          c = { ["id"] = H["id"], ["maxAmount"] = t - 20, ["label"] = "exchange" }
          G(2, d .. ("itemID|" .. (H["id"] .. "|\nbuttonClicked|verify")))
          r(i["claveDelay"], true)
          if
            not U(function()
              local i = W(H["id"])
              return i ~= nil and i <= t - 20
            end, 5000)
          then
            return "STOPPED - autoclave exchange was not confirmed"
          end
          c = nil
        end
      end
    end
  end
  while h do
    if not a() then
      local i, t = R()
      if not i then
        return t
      end
      K = 0
      if c then
        local i = c
        local t = U(function()
          local t = W(i["id"])
          return t ~= nil and t <= i["maxAmount"]
        end, 5000)
        if t then
          c = nil
        elseif a() then
          return "STOPPED - interrupted " .. (i["label"] .. " could not be confirmed")
        end
      end
    end
    if a() then
      local i, t = pcall(j)
      if a() then
        if not i then
          error(t)
        end
        if t then
          return t
        end
      end
    end
    Sleep(100)
  end
  return "STOPPED"
end
local function I7(i)
  i = tostring(i or "")
  i = i:gsub("\n", "\r\n")
  i = i:gsub("([^%w%-_%.~])", function(i)
    return string["format"]("%%%02X", string["byte"](i))
  end)
  return i
end
local function F7()
  local i = ""
  if type(getDiscordID) == "function" then
    local t, d = pcall(getDiscordID)
    if t and d ~= nil then
      i = tostring(d)
    end
  elseif getDiscordID ~= nil then
    i = tostring(getDiscordID)
  end
  i = ((tostring(i or "")):gsub("^%s+", "")):gsub("%s+$", "")
  if i == "" or i == "nil" or i == "0" then
    local t = GetLocal or getLocal
    if t ~= nil then
      local d, A = pcall(t)
      if d and (A ~= nil and A["name"] ~= nil) then
        i = tostring(A["name"])
        i = (i:gsub("^%s+", "")):gsub("%s+$", "")
      end
    end
  end
  if i == "nil" or i == "0" then
    return ""
  end
  return i
end
local function s7(i)
  pcall(editValue, "ACL_licensestatus", i)
end
local J7 = {
  ["DISABLED"] = { "DISABLED", "License disabled." },
  ["WRONG_PRODUCT"] = { "WRONG PRODUCT", "This license is for another script." },
  ["BOUND_TO_OTHER_USER"] = { "BOUND TO OTHER USER", "License is bound to another user." },
  ["INVALID_KEY"] = { "INVALID KEY", "Invalid license key." },
  ["BAD_KEY_FORMAT"] = { "BAD KEY FORMAT", "License key format is invalid." },
  ["NO_ID"] = { "NO CLIENT ID", "Client ID is unavailable." },
}
local function x7(i)
  if not i:match("^[A-Z]%d%d%d%d%d%d%d$") then
    return false, "INVALID KEY FORMAT", "License must be 1 letter + 7 numbers, for example A1234567."
  end
  local A = F7()
  if A == "" then
    return false, "NO CLIENT ID", "Could not read a client ID. Enter the game first and try again."
  end
  local u = t .. ("?key=" .. (I7(i) .. ("&id=" .. (I7(A) .. ("&product=" .. I7(d))))))
  local P, K = pcall(fetch, u)
  if not P then
    return false, "SERVER ERROR", "License server request failed."
  end
  K = (tostring(K or "")):match("^%s*(.-)%s*$")
  local j = K:match("DENY|([A-Z_]+)")
  if j then
    local i = J7[j]
    if i then
      return false, i[1], i[2]
    end
    return false, "DENIED", "License denied by server."
  end
  if K:find("OK|PERMANENT", 1, true) then
    return true, "VERIFIED - PERMANENT"
  end
  if K == "" then
    return false, "NO RESPONSE", "License server gave no response."
  end
  return false, "CHECK FAILED", "License check failed."
end
local function z7()
  if E or K then
    return
  end
  local i, t = u, P
  K = true
  s7("CHECKING")
  local d = pcall(runThread, function()
    local d, A, u = pcall(x7, i)
    K = false
    if t ~= P then
      return
    end
    s7(d and u or "SERVER ERROR")
    if d and (A and not H(i)) then
      s7("VERIFIED - COULD NOT SAVE KEY")
    end
  end)
  if not d then
    K = false
    s7("COULD NOT START LICENSE CHECK")
  end
end
function OnValue(i, t, d)
  if t == "ACL_licensekey" then
    if j then
      return
    end
    local i = q(d)
    if i ~= u then
      u = i
      P = P + 1
      s7("NOT VERIFIED")
    end
    return
  end
  if t == "ACL_verifylicense" then
    z7()
    return
  end
  if t == "ACL_clearlicense" then
    u = ""
    P = P + 1
    local i = H("")
    j = true
    pcall(editValue, "ACL_licensekey", "")
    j = false
    s7(i and "NOT VERIFIED" or "COULD NOT CLEAR SAVED KEY")
    return
  end
  if t == "ACL_start" then
    if b then
      return
    end
    if d ~= true then
      h = false
      return
    end
    if h then
      return
    end
    if E or K then
      b = true
      pcall(e, "ACL_start", false)
      b = false
      return
    end
    local i, t = {}, {}
    for t, d in pairs(F) do
      i[t] = d
    end
    for i, d in pairs(J) do
      t[i] = d
    end
    local A, j = u, P
    N = g()
    T, c = false, nil
    X = 0
    h, E = true, true
    runThread(function()
      local d, u = false, false
      local K, q = false, false
      local I, F = pcall(function()
        if type(N) ~= "string" or not N:match("^[A-Za-z0-9]+$") or N:upper() == "EXIT" or not a() then
          return "STOPPED - enter the autoclave world first"
        end
        s7("CHECKING")
        local I, F = x7(A)
        if j ~= P then
          return "STOPPED - license key changed"
        end
        if not a() then
          s7("NOT VERIFIED")
          return "STOPPED"
        end
        s7(F)
        if not I then
          return "STOPPED - " .. F
        end
        if not H(A) then
          s7("VERIFIED - COULD NOT SAVE KEY")
        end
        i["claveX"], i["claveY"] = S()
        if i["claveX"] == nil then
          return "STOPPED - no autoclave found in this world"
        end
        n("Autoclave selected at " .. (i["claveX"] .. (", " .. i["claveY"])))
        local s, J = pcall(getValue, 0, "ModFly")
        u = s and J == true
        if not u then
          if e("ModFly", true) == false then
            return "STOPPED - ModFly unavailable"
          end
          d = true
        end
        local x, z = pcall(getValue, 0, "Enable AutoCollect")
        K = x and z == true
        if e("Enable AutoCollect", false) == false then
          return "STOPPED - cannot disable general AutoCollect"
        end
        q = true
        return H7(i, t)
      end)
      h, D, L = false, nil, false
      v, o = nil, false
      T, c = false, nil
      d7 = nil
      if q and K then
        pcall(e, "Enable AutoCollect", true)
      end
      if d then
        pcall(e, "ModFly", u)
      end
      b = true
      pcall(e, "ACL_start", false)
      b, E = false, false
      n(I and F or ("STOPPED - " .. tostring(F)))
    end)
    return
  end
  if t == "ACL_set_drop" then
    local i, t = M()
    if not i then
      n("Enter the world before setting the drop tile")
      return
    end
    F["dropX"], F["dropY"] = i, t
    V()
    pcall(editValue, "ACL_dropX", tostring(i))
    pcall(editValue, "ACL_dropY", tostring(t))
    n("Drop tile set to " .. (i .. (", " .. t)))
    return
  end
  for i, A in ipairs(I) do
    if t == "ACL_tool_" .. i then
      local i = d == true
      if (J[A] == true) ~= i then
        J[A] = i
        V()
      end
      return
    end
  end
  for i, A in ipairs(s) do
    if t == "ACL_" .. A[2] then
      local i = tonumber(d)
      if i then
        local t = math["max"](A[3], math["min"](A[4], math["floor"](i)))
        if t ~= F[A[2]] then
          F[A[2]] = t
          V()
        end
      end
      return
    end
  end
end
onValue = OnValue
local Z7 = UserInterface["new"](i, "Inventory")
Z7:addToggle("Start / Stop", false, "ACL_start")
Z7:addInputString("Status (view only)", "STOPPED", "Status", "STOPPED", nil, "ACL_status")
Z7:addInputString("License Key", u, "A1234567", "A1234567", nil, "ACL_licensekey")
Z7:addButton("Verify License", "ACL_verifylicense")
Z7:addButton("Clear Saved License", "ACL_clearlicense")
Z7:addInputString(
  "License Status (view only)",
  "NOT VERIFIED",
  "License Status",
  "NOT VERIFIED",
  nil,
  "ACL_licensestatus"
)
Z7:addDisplayList("Settings AutoSave", Z, "ACL_autosave")
local l7 = Z7:addDialog("Surgical Tool Settings", "Choose which tools to save", {})
Z7:addChildTooltip(
  l7["menu"],
  "Toggle ON to keep the tool",
  "Tools left OFF can be used in autoclave exchanges.",
  "Inventory",
  true
)
for i, t in ipairs(I) do
  Z7:addChildToggle(l7["menu"], t, J[t] == true, "ACL_tool_" .. i)
end
local V7 = Z7:addDialog("Position Settings", "Set the saved-tool drop tile", {})
Z7:addChildButton(V7["menu"], "Drop Position = Current Tile", "ACL_set_drop")
local h7 = Z7:addDialog("Delay Settings", "Set action delays in milliseconds", {})
for i, t in ipairs(s) do
  local d = i <= 2 and V7 or h7
  local A = tostring(F[t[2]])
  Z7:addChildInputInt(d["menu"], t[1], A, t[1], A, nil, "ACL_" .. t[2])
end
pcall(addCategory, i, "Inventory")
addIntoModule(Z7:generateJSON(), i)
if type(applyHook) == "function" then
  applyHook()
end
