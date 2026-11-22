setMinimum("6.1.2")
local n =
  "https://script.google.com/macros/s/AKfycbxeBzpOUzvcRDkX-4eR8uioFbAUDsepIQc26kmxUkXt6YOjBxFdVsOE0zzvxYSprl5knA/exec"
local m = "UTDROP"
local V = "RetrieveTesseractDropLicense"
local W = "license_key"
local c = nil
local h = ""
local function Q(n)
  n = tostring(n or "")
  n = n:gsub("%s+", "")
  return n:upper()
end
local function F(n)
  n = Q(n)
  return n:match("^[A-Z]%d%d%d%d%d%d%d$") ~= nil
end
local function y()
  local n = pcall(function()
    local n = nil
    if type(require) == "function" then
      local m, V = pcall(require, "preferences")
      if m and V ~= nil then
        n = V
      end
    end
    if n == nil and type(Preferences) == "table" then
      n = Preferences
    end
    if n == nil then
      return
    end
    if type(n["new"]) == "function" then
      local m = n:new(V)
      c = m or n
    else
      c = n
    end
    if c ~= nil and type(c["load"]) == "function" then
      c:load()
    end
    if c ~= nil and type(c["get"]) == "function" then
      h = Q(c:get(W, ""))
    end
  end)
  if not n then
    c = nil
    h = ""
  end
end
local function q(n)
  if c == nil then
    return false
  end
  local m = pcall(function()
    c:set(W, Q(n))
    c:save()
  end)
  return m
end
local function u()
  if c == nil then
    return false
  end
  local n = pcall(function()
    c:set(W, "")
    c:save()
  end)
  return n
end
y()
local A = h
local C = 0
local N, r = false, false
local j = "Auto Retrieve Tesseract & Drop"
local s = 0
local l = 2000
local B = 2200
local w = {
  ["items"] = "",
  ["worlds"] = "",
  ["dropDelay"] = tostring(s),
  ["fixedDrop"] = "false",
  ["dropWorld"] = "",
  ["dropX"] = "",
  ["dropY"] = "",
}
local t, o, L = false, false, false
local J, b, O
local Y
local g = false
local K = {}
local function S(n, ...)
  if type(n) ~= "function" then
    return nil
  end
  local m, V = pcall(n, ...)
  if m then
    return V
  end
end
local function M(n, ...)
  local m, V = pcall(n, ...)
  return m and V ~= false
end
local function i(n, m)
  L = true
  S(editValue, n, tostring(m))
  L = false
end
local function z(n)
  i("UTD_status", n)
end
local function I()
  return (tostring(S(GetWorldName or getCurrentWorldName) or "")):upper()
end
local function R()
  local n = S(GetLocal or getLocal)
  if n and (tonumber(n["posX"]) and tonumber(n["posY"])) then
    return n, math["floor"](n["posX"] / 32), math["floor"](n["posY"] / 32)
  end
end
local function H()
  return t and (J == I() and R() ~= nil)
end
local function Z(n)
  local m, V = n:match("^([A-Z0-9]+)|([^|]+)$")
  if m then
    return m, V
  end
  if n:match("^[A-Z0-9]+$") then
    return n
  end
end
local function X(n)
  if I() ~= n or not R() then
    return false
  end
  local m = S(GetTiles or getTiles)
  return type(m) == "table" and next(m) ~= nil
end
local function a(n)
  for m = 1, 75, 1 do
    if not t then
      return false
    end
    if X(n) then
      Sleep(300)
      if t and X(n) then
        return true
      end
    end
    Sleep(200)
  end
  return false
end
local function E(n, m)
  local V, W = Z(n)
  if not t or not V then
    return false
  end
  if X(V) and (not W or (b == n and (not m or Y == n))) then
    J = V
    if not W then
      b, Y = nil, nil
    end
    return true
  end
  local c = SendPacket or sendPacket
  if not X(V) then
    b, Y = nil, nil
    z("WARPING TO " .. V)
    local n = growtopia and growtopia["warpTo"]
    local m
    if type(n) == "function" then
      m = M(n, V)
    else
      m = M(c, 3, "action|join_request\nname|" .. (V .. "\ninvitedWorld|0"))
    end
    if not m or not a(V) then
      return false
    end
    Sleep(1000)
    if not t or not X(V) then
      return false
    end
  end
  if W then
    b, Y = nil, nil
    z("ENTERING DOOR " .. n)
    local W, h, Q = R()
    if not M(c, 3, "action|join_request\nname|" .. (n .. "\ninvitedWorld|0")) then
      return false
    end
    if m then
      local n = false
      for m = 1, 75, 1 do
        if not t then
          return false
        end
        local W, c, F = R()
        n = n or not X(V) or c ~= h or F ~= Q
        if n and X(V) then
          break
        end
        Sleep(200)
      end
      if not n then
        return false
      end
    else
      Sleep(1400)
    end
    if not a(V) then
      return false
    end
    Sleep(1000)
    if not t or not X(V) then
      return false
    end
    b = n
    if m then
      Y = n
    end
  end
  J = V
  return true
end
local function U(n, m)
  return S(GetTile or getTile or (tile and tile["getTile"]), n, m)
end
local function v(n)
  local m = S(growtopia and growtopia["checkInventoryCount"], n)
  if tonumber(m) then
    return tonumber(m)
  end
  local V = S(GetInventory or getInventory)
  if type(V) ~= "table" then
    return nil
  end
  for m, V in pairs(V) do
    if tonumber(V["id"]) == n then
      return tonumber(V["amount"])
    end
  end
  return 0
end
local function p(n, m)
  for n in n:gmatch("[^\r\n]+") do
    local V = n:match("^embed_data|" .. (m .. "|([^|]+)")) or n:match("^" .. (m .. "|([^|]+)"))
    if V then
      return tonumber(V)
    end
  end
end
local function P(n)
  return ((tostring(n or "")):upper()):gsub("%s+", "")
end
local function x(n)
  local m = Z(n)
  return m and (m ~= "EXIT" and m ~= "EXITWORLD")
end
local function G(n)
  local m, V = {}, {}
  for n in (tostring(n or "")):gmatch("[^,]+") do
    n = P(n)
    if n ~= "" and not V[n] then
      m[#m + 1], V[n] = n, true
    end
  end
  return m
end
local f
pcall(function()
  local n = S(require, "preferences") or Preferences
  local m = n:new("AutoRetrieveTesseractDrop")
  m:load()
  f = m
  for n, m in pairs(w) do
    w[n] = tostring(f:get(n, m) or m)
  end
end)
local function k()
  return pcall(function()
    for n, m in pairs(w) do
      f:set(n, m)
    end
    if f:save() == false then
      error("save")
    end
  end)
end
local function d(n)
  S(growtopia and growtopia["notify"], n)
end
local function D()
  if g then
    return true
  end
  local n = S(getValue or GetValue, 0, "ModFly")
  if n == true or n == 1 or n == "true" then
    return true
  end
  g = M(editToggle or EditToggle, "ModFly", true)
  return g
end
local function e()
  if g then
    M(editToggle or EditToggle, "ModFly", false)
  end
  g = false
end
local function T()
  for n, m in ipairs({ "Enable AutoCollect", "Autocollect", "Fast Drop" }) do
    local V = S(getValue or GetValue, 0, m)
    if V == true or V == 1 or V == "true" or V == "1" then
      if not M(editToggle or EditToggle, m, false) then
        return false
      end
      K[#K + 1] = m
    end
  end
  return true
end
local function ne()
  for n, m in ipairs(K) do
    M(editToggle or EditToggle, m, true)
  end
  K = {}
end
local function me(n)
  local m = tonumber(n)
  if m and (m >= 0 and (m <= 10000 and m % 1 == 0)) then
    return m
  end
end
local Ve = w["dropWorld"]
if Ve == "" and (x(I()) and X(I())) then
  Ve = I()
end
local We = UserInterface["new"](j, "Inventory")
We:addLabelApp(j, "Inventory")
We:addInputString("License Key", h, "A1234567", "A1234567", nil, "UTD_licensekey")
We:addButton("Verify License", "UTD_verifylicense")
We:addButton("Clear Saved License", "UTD_clearlicense")
We:addDisplayList("License Status", "NOT VERIFIED", "UTD_licensestatus")
We:addToggle("Start / Stop", false, "UTD_start")
We:addItemPicker("Add Item to Retrieve", "Dirt", "2", "UTD_item")
We:addDisplayList("Selected Item IDs", w["items"], "UTD_selected")
We:addInputString("Item IDs (comma-separated)", w["items"], "2, 4, 6", "2, 4, 6", nil, "UTD_items")
local ce = (We:addDialog("Settings", "Tesseract worlds in collection order", {}))["menu"]
We:addChildInputString(
  ce,
  "Tesseract Worlds (comma-separated)",
  w["worlds"],
  "WORLD|DOORID",
  "FARM1, FARM2",
  nil,
  "UTD_worlds"
)
We:addChildButton(ce, "Add Current World", "UTD_here")
We:addChildButton(ce, "Remove Last World", "UTD_remove")
local he = (We:addDialog("Drop Settings", "Wait before each drop request and confirmation", {}))["menu"]
We:addChildInputInt(he, "Drop Delay (ms)", tostring(me(w["dropDelay"]) or s), "ms", tostring(s), nil, "UTD_dropDelay")
local Qe = (We:addExpandableToggle("Custom Drop World", w["fixedDrop"] == "true", "UTD_fixedDrop", false))["list_child"]
We:addChildInputString(Qe, "Drop World", Ve, "WORLD|DOORID", "STORAGE", nil, "UTD_dropWorld")
We:addChildButton(Qe, "Drop World = Current World", "UTD_hereDropWorld")
We:addChildInputInt(Qe, "Drop Position X", w["dropX"], "X", "", nil, "UTD_dropX")
We:addChildInputInt(Qe, "Drop Position Y", w["dropY"], "Y", "", nil, "UTD_dropY")
We:addChildButton(Qe, "Set Drop Position = Current Tile", "UTD_hereDrop")
We:addDisplayList("Active Drop Tile", "", "UTD_activeDrop")
We:addDisplayList("Status", "STOPPED", "UTD_status")
S(addCategory, j, "Inventory")
S(addIntoModule, We:generateJSON(), j)
local function Fe(n, m)
  local V, W, c = R()
  return H() and (W == n and c == m)
end
local function ye(n, m)
  if Fe(n, m) then
    return true
  end
  for V, W in ipairs({ 25, 45 }) do
    if not H() then
      return false
    end
    Sleep(450)
    if not H() then
      return false
    end
    S(FindPath or findPath, n, m)
    for V = 1, W, 1 do
      if not H() then
        return false
      end
      if Fe(n, m) then
        return true
      end
      Sleep(100)
    end
  end
  return false
end
local function qe()
  local n = I()
  return n == "" or n == "EXIT" or n == "EXITWORLD" or not R()
end
local function ue(n)
  while t do
    if E(n) then
      return true
    end
    if not t then
      return false
    end
    if not qe() then
      return false
    end
    b, Y = nil, nil
    z("WAITING FOR RECONNECT - " .. n)
    Sleep(2500)
  end
  return false
end
function onSendPacketRaw(n)
  return o and (n ~= nil and tonumber(n["type"]) == 11)
end
function onVariant(n)
  local m = O
  if not m or not H() or not n or n["v1"] ~= "OnDialogRequest" or type(n["v2"]) ~= "string" then
    return false
  end
  local V = n["v2"]
  if not V:find(m["dialog"], 1, true) then
    return false
  end
  local W, c = p(V, "tilex"), p(V, "tiley")
  if (m["x"] and (W and m["x"] ~= W)) or (m["y"] and (c and m["y"] ~= c)) then
    return false
  end
  local h = p(V, "itemID") or p(V, "itemid")
  if m["id"] and (h and m["id"] ~= h) then
    return false
  end
  m["text"] = V
  return true
end
local function Ae(n, m, V, W, c, h, Q, F)
  local y = { ["dialog"] = n, ["x"] = m, ["y"] = V, ["id"] = c }
  O = y
  if W() then
    for n = 1, (h or 45), 1 do
      if y["text"] or not H() or (F and F()) then
        break
      end
      Sleep(Q or 100)
    end
  end
  O = nil
  return y["text"]
end
local function Ce(n)
  return (((n or "")):gsub(string["char"](96) .. ".", "")):lower()
end
local function Ne(n)
  local m = S(getItemInfoByID or GetItemInfo, n)
  return m and m["name"] or S(growtopia and growtopia["getItemName"], n)
end
local function re(n, m)
  local V = p(n, "targetitem") or p(n, "itemID") or p(n, "itemid")
  if V then
    return m[V] and V
  end
  local W, c, h = Ce(n), nil, 0
  for n, m in pairs(m) do
    if #m > h and W:find(m:lower(), 1, true) then
      c, h = n, #m
    end
  end
  return c
end
local function je(n)
  local m = Ce(n)
  local V = m:match("contains a total of%s+([%d,]+)")
    or m:match("contains%s+([%d,]+)")
    or m:match("currently stored:%s*([%d,]+)")
  if V then
    return tonumber((V:gsub(",", "")))
  end
  if m:find("contains no items", 1, true) or m:find("currently empty", 1, true) then
    return 0
  end
end
local function se(n)
  local m, V = n["x"], n["y"]
  return Ae("itemsucker_block", m, V, function()
    local W = R()
    return W
      and (
        Fe(m, n["standY"])
        and M(
          SendPacketRaw or sendPacketRaw,
          false,
          { ["type"] = 3, ["value"] = 32, ["px"] = m, ["py"] = V, ["x"] = W["posX"], ["y"] = W["posY"] }
        )
      )
  end)
end
local function le(n)
  local m, V = n["x"], n["y"]
  return Ae("itemremovedfromsucker", m, V, function()
    return Fe(m, n["standY"])
      and M(
        SendPacket or sendPacket,
        2,
        "action|dialog_return\ndialog_name|itemsucker_block\ntilex|"
          .. (m .. ("|\ntiley|" .. (V .. "|\nbuttonClicked|retrieveitem\n\nchk_enablesucking|1")))
      )
  end)
end
local function Be(n, m, V, W)
  for W = 1, W, 1 do
    if not H() then
      return nil
    end
    local c = v(n)
    if c and ((V and c > m) or (not V and c < m)) then
      return c
    end
    Sleep(100)
  end
  if H() then
    return v(n)
  end
end
local function we(n, m)
  local V = S(GetTiles or getTiles)
  if type(V) ~= "table" or next(V) == nil then
    return nil, false
  end
  local W
  for V, c in pairs(V) do
    local h, Q = tonumber(c["x"]), tonumber(c["y"])
    if h and (Q and (Q >= 0 and tonumber(c["fg"]) == n)) then
      local n = h .. ("," .. Q)
      if not m[n] and (not W or h > W["x"] or (h == W["x"] and Q < W["y"])) then
        W = { ["x"] = h, ["y"] = Q, ["key"] = n }
      end
    end
  end
  return W, true
end
local function te(n)
  local m, V = n["y"] - 1, n["y"] + 1
  local W = n["standY"] or m
  local c = W == m and V or m
  if W >= 0 and ye(n["x"], W) then
    n["standY"] = W
    return true
  end
  if H() and (c >= 0 and ye(n["x"], c)) then
    n["standY"] = c
    return true
  end
  return false
end
local function oe(n, m, V)
  local W, c = n["x"], n["y"]
  if not te(n) then
    return H() and "unreachable" or "reconnect"
  end
  local h = U(W, c)
  if not h or tonumber(h["fg"]) ~= V then
    return "unreachable"
  end
  local Q = se(n)
  if not H() then
    return "reconnect"
  end
  if not Q then
    return "unreadable"
  end
  local F = re(Q, m)
  if not F then
    return "unmatched"
  end
  local y = m[F]
  local q = je(Q)
  if q == 0 then
    return "empty"
  end
  local u = v(F)
  if not u then
    return "inventory unavailable"
  end
  local A = math["min"](200 - u, q or 200)
  if A <= 0 then
    return "full"
  end
  local C = le(n)
  if not H() then
    return "reconnect"
  end
  if not C then
    return "unreadable"
  end
  local N = p(C, "targetitem") or p(C, "itemID") or p(C, "itemid")
  if N and N ~= F then
    return "unmatched"
  end
  local r = je(C)
  if r then
    A = math["min"](A, r)
  end
  if A <= 0 then
    return "empty"
  end
  if not Fe(W, n["standY"]) then
    return "unreachable"
  end
  z("RETRIEVING " .. (A .. (" " .. (y .. (" AT " .. n["key"])))))
  if
    not M(
      SendPacket or sendPacket,
      2,
      "action|dialog_return\ndialog_name|itemremovedfromsucker\ntilex|"
        .. (W .. ("|\ntiley|" .. (c .. ("|\nitemtoremove|" .. A))))
    )
  then
    return "withdrawal request failed"
  end
  local j = Be(F, u, true, 65)
  if not H() or j == nil then
    return "reconnect", F, u
  end
  if j > u then
    return "store", F, u
  end
  return "withdrawal unconfirmed"
end
local function Le()
  local n = R()
  return n and (n["isLeft"] == true or n["isLeft"] == 1)
end
local function Je()
  if not H() then
    return false
  end
  if not Le() then
    return true
  end
  z("RESPAWNING TO FACE RIGHT")
  if not M(SendPacket or sendPacket, 2, "action|respawn") then
    return false
  end
  Sleep(1200)
  for n = 1, 35, 1 do
    if not t or qe() then
      return false
    end
    if H() and not Le() then
      return true
    end
    Sleep(100)
  end
  return false
end
local function be(n, m)
  if not ye(n, m) then
    return false
  end
  if not Le() then
    return true
  end
  if not Je() or not ye(n, m) then
    return false
  end
  if not Le() then
    return true
  end
  return n > 0 and (ye(n - 1, m) and (ye(n, m) and not Le()))
end
local function Oe(n, m, V, W, c)
  local h = v(n)
  if not h or not Fe(m, V) or Le() then
    return nil
  end
  if h <= W then
    return h
  end
  local Q = Ae(
    "drop_item",
    nil,
    nil,
    function()
      return Fe(m, V) and (not Le() and M(SendPacket or sendPacket, 2, "action|drop\nitemID|" .. n))
    end,
    n,
    math["ceil"](l / 75),
    75,
    function()
      return not Fe(m, V) or (v(n) or h) < h
    end
  )
  if not Fe(m, V) then
    return nil
  end
  local F = v(n)
  if not F or F < h then
    return F
  end
  if not Q then
    return F
  end
  if c > 0 then
    Sleep(c)
  end
  if not Fe(m, V) or Le() then
    return nil
  end
  F = v(n)
  if not F or F ~= h then
    return F
  end
  if
    not M(
      SendPacket or sendPacket,
      2,
      "action|dialog_return\ndialog_name|drop_item\nitemID|" .. (n .. ("|\ncount|" .. (h - W)))
    )
  then
    return nil
  end
  return Be(n, h, false, B / 100)
end
local function Ye(n, m, V, W)
  local c = n["y"]
  local h = false
  local Q
  if n["verifyDoor"] then
    Q = E(n["world"], true)
  else
    Q = ue(n["world"])
  end
  if not Q then
    return false, "Could not enter the drop world."
  end
  while t do
    local Q = n["x"]
    if not X(J) or not U(Q, c) then
      return false, "Drop world or standing tile is unavailable."
    end
    if not be(Q, c) then
      return false, "Cannot reach the drop tile while facing right."
    end
    if not Fe(Q, c) or Le() then
      return false, "Lost the verified drop position."
    end
    local F = v(m)
    if not F then
      return false, "Could not read the backpack in storage."
    end
    if F < V then
      return false, "Backpack count fell below the amount held before withdrawal."
    end
    if F == V then
      return true
    end
    i("UTD_activeDrop", Q .. ("," .. c))
    z("DROPPING ITEM " .. (m .. (" x" .. (F - V))))
    local y = Oe(m, Q, c, V, W)
    if not y or not Fe(Q, c) then
      return false, "Drop interrupted at the storage tile. Check the backpack."
    end
    if y >= F then
      Sleep(1200)
      if not Fe(Q, c) then
        return false, "Lost the verified drop position."
      end
      y = v(m)
      if not y then
        return false, "Could not confirm the backpack count."
      end
    end
    if y < V then
      return false, "Drop exceeded the retrieved amount. Check Fast Drop."
    end
    if y == V then
      return true
    end
    if y > F then
      return false, "Backpack count increased during the drop. Check the backpack."
    end
    if y == F then
      if h or Q <= 0 then
        return false, "Drop unconfirmed and no left retry remains."
      end
      n["x"], h = Q - 1, true
      z("DROP UNCONFIRMED - SHIFTING LEFT")
    end
  end
  return false, "Stopped."
end
local function ge(n)
  local m = tonumber(S(findItemID or (growtopia and growtopia["getItemID"]), "Unstable Tesseract"))
  if not m or m < 1 then
    return "Could not resolve the Unstable Tesseract item ID."
  end
  if not T() then
    return "Could not pause launcher pickup or Fast Drop."
  end
  if not D() then
    return "Could not enable ModFly."
  end
  local V = {}
  for n, m in ipairs(n["items"]) do
    local W = Ne(m)
    if not W or W == "" then
      return "Could not resolve selected item " .. (m .. ".")
    end
    V[m] = W
  end
  local W = 0
  local c
  for h, Q in ipairs(n["worlds"]) do
    local F = {}
    local y, q, u
    local A = n["fixedStorage"]
    local C, N = {}, {}
    local r = false
    while t do
      if u then
        if not A then
          A = { ["world"] = Q, ["x"] = y["x"], ["y"] = y["standY"] }
        end
        local m, V = Ye(A, u["item"], u["before"], n["dropDelay"])
        if not m then
          return V
        end
        u = nil
      end
      if not ue(Q) then
        return "Could not enter Tesseract world " .. (Q .. ".")
      end
      if not r then
        if not Je() then
          return "Could not face right in " .. (Q .. ".")
        end
        r = true
      end
      if not c then
        c = {}
        local m = {}
        for n, V in ipairs(n["items"]) do
          local W = v(V)
          if W == nil then
            return "Could not read selected items in the backpack."
          end
          if W > 0 and not m[V] then
            c[#c + 1] = V
            m[V] = true
          end
        end
      end
      if n["fixedStorage"] then
        for n, m in ipairs(c) do
          C[m] = 0
        end
        c = {}
      end
      if q then
        Sleep(1200)
        if H() then
          local n = v(q["item"])
          if not n then
            return "Could not reconcile the backpack after reconnecting."
          end
          if n > q["before"] then
            u = q
          end
          q = nil
        end
      end
      if n["fixedStorage"] and u then
        if C[u["item"]] == nil then
          C[u["item"]] = u["before"]
        end
        u = nil
      end
      if H() and (not u and not q) then
        if not y then
          local V
          y, V = we(m, F)
          if not V then
            return "Could not scan Tesseracts in " .. (Q .. ".")
          end
          if not y then
            if not n["fixedStorage"] or next(C) == nil then
              break
            end
            z("DROPPING SELECTED ITEMS AS A BATCH")
            for m, V in ipairs(n["items"]) do
              if C[V] ~= nil then
                local m, W = Ye(A, V, C[V], n["dropDelay"])
                if not m then
                  return W
                end
                C[V] = nil
              end
            end
            C = {}
            if next(N) == nil then
              break
            end
            for n in pairs(N) do
              F[n] = nil
            end
            N = {}
          end
        end
        if y and #c > 0 then
          if not A and te(y) then
            A = { ["world"] = Q, ["x"] = y["x"], ["y"] = y["standY"] }
          end
          if A then
            for m, V in ipairs(c) do
              z("DROPPING CARRIED ITEM " .. (V .. " BEFORE RETRIEVAL"))
              local W, c = Ye(A, V, 0, n["dropDelay"])
              if not W then
                return c
              end
            end
            c = {}
          elseif H() then
            F[y["key"]] = true
            y = nil
            W = W + 1
          end
        elseif y then
          z("CHECKING TESSERACT " .. (Q .. (" " .. y["key"])))
          local c, h, A = oe(y, V, m)
          if c == "store" then
            if n["fixedStorage"] then
              if C[h] == nil then
                C[h] = A
              end
            else
              u = { ["item"] = h, ["before"] = A }
            end
          elseif c == "reconnect" then
            if h then
              q = { ["item"] = h, ["before"] = A }
            end
          elseif c == "empty" or c == "unmatched" or c == "unreachable" or c == "unreadable" or c == "full" then
            F[y["key"]] = true
            local m = n["fixedStorage"] and (c == "full" and next(C) ~= nil)
            if m then
              N[y["key"]] = true
            end
            y = nil
            if c == "unreachable" or c == "unreadable" or (c == "full" and not m) then
              W = W + 1
            end
          else
            return c .. (" at " .. (Q .. (" " .. (y["key"] .. ". Check the backpack and Tesseract."))))
          end
        end
      end
    end
    if not t then
      return "STOPPED"
    end
  end
  if c and #c > 0 then
    return "No reachable Tesseract for dropping carried items."
  end
  if W > 0 then
    return "Finished. " .. (W .. " Tesseract check(s) could not be completed.")
  end
  return "Finished all selected items and worlds."
end
local function Ke(n)
  L = true
  S(editToggle or EditToggle, "UTD_start", n)
  L = false
end
local function Se()
  local n = { ["items"] = {}, ["worlds"] = G(w["worlds"]), ["dropDelay"] = me(w["dropDelay"]) or s }
  for m, V in ipairs(G(w["items"])) do
    local W = tonumber(V)
    if not W or W < 1 or W > 65535 or W % 1 ~= 0 then
      return nil, "Enter valid item IDs."
    end
    n["items"][#n["items"] + 1] = W
  end
  if #n["items"] == 0 then
    return nil, "Add at least one item."
  end
  if #n["worlds"] == 0 then
    return nil, "Add at least one Tesseract world."
  end
  for n, m in ipairs(n["worlds"]) do
    if not x(m) then
      return nil, "Invalid world route: " .. m
    end
  end
  if w["fixedDrop"] == "true" then
    local m = P(w["dropWorld"])
    if m == "" and X(I()) then
      m = I()
    end
    local V, W = tonumber(w["dropX"]), tonumber(w["dropY"])
    if not x(m) or not V or not W or V < 0 or W < 0 or V % 1 ~= 0 or W % 1 ~= 0 then
      return nil, "Set the world and position under Custom Drop World."
    end
    n["fixedStorage"] = { ["world"] = m, ["x"] = V, ["y"] = W, ["verifyDoor"] = true }
  end
  return n
end
local function Me(n)
  if type(n) == "table" then
    n = n["id"] or n["itemID"] or n["value"] or n["name"]
  end
  local m = tonumber(n)
  if not m and type(n) == "string" then
    m = tonumber(n:match("%((%d+)%)")) or tonumber(S(findItemID or (growtopia and growtopia["getItemID"]), n))
  end
  if not m or m < 1 or m > 65535 or m % 1 ~= 0 then
    return false
  end
  local V = G(w["items"])
  for n, V in ipairs(V) do
    if tonumber(V) == m then
      return true
    end
  end
  V[#V + 1] = tostring(m)
  w["items"] = table["concat"](V, ", ")
  i("UTD_items", w["items"])
  i("UTD_selected", w["items"])
  k()
  return true
end
local function ie(n)
  local m = tostring(n or "")
  pcall(function()
    editValue("UTD_licensestatus", m)
  end)
end
local function ze(n)
  n = tostring(n or "")
  n = n:gsub("\n", "\r\n")
  n = n:gsub("([^%w%-_%.~])", function(n)
    return string["format"]("%%%02X", string["byte"](n))
  end)
  return n
end
local function Ie()
  local n = ""
  if type(getDiscordID) == "function" then
    local m, V = pcall(getDiscordID)
    if m and V ~= nil then
      n = tostring(V)
    end
  elseif getDiscordID ~= nil then
    n = tostring(getDiscordID)
  end
  n = ((tostring(n or "")):gsub("^%s+", "")):gsub("%s+$", "")
  if n == "" or n == "nil" or n == "0" then
    local m = GetLocal or getLocal
    if m ~= nil then
      local V, W = pcall(m)
      if V and (W ~= nil and W["name"] ~= nil) then
        n = tostring(W["name"])
        n = (n:gsub("^%s+", "")):gsub("%s+$", "")
      end
    end
  end
  return n
end
local function Re(V, W)
  if r then
    return false
  end
  r = true
  local c = Q(A)
  A = c
  if not F(c) then
    ie("INVALID KEY FORMAT")
    r = false
    if not V then
      d("License must be 1 letter + 7 numbers, for example A1234567.")
    end
    return false
  end
  local y = Ie()
  if y == "" then
    ie("NO CLIENT ID")
    r = false
    if not V then
      d("Could not read a client ID. Enter the game first and try again.")
    end
    return false
  end
  ie("CHECKING...")
  local u = n .. ("?key=" .. (ze(c) .. ("&id=" .. (ze(y) .. ("&product=" .. ze(m))))))
  local N, j, s = pcall(fetch, u)
  if not N then
    ie("SERVER ERROR")
    r = false
    if not V then
      d("License server request failed.")
    end
    return false
  end
  if W ~= C then
    r = false
    return false
  end
  j = tostring(j or "")
  j = (j:gsub("^%s+", "")):gsub("%s+$", "")
  if j:find("OK|PERMANENT", 1, true) then
    ie("VERIFIED - PERMANENT")
    local n = q(c)
    if n then
      h = c
    end
    r = false
    if not V then
      d(n and "License verified and saved." or "License verified. Could not save the key.")
    end
    return true
  end
  local l = j
  local B = "LICENSE CHECK FAILED"
  if l:find("DENY|DISABLED", 1, true) then
    ie("DISABLED")
    B = "License disabled."
  elseif l:find("DENY|WRONG_PRODUCT", 1, true) then
    ie("WRONG PRODUCT")
    B = "This license is for another script."
  elseif l:find("DENY|BOUND_TO_OTHER_USER", 1, true) then
    ie("BOUND TO OTHER USER")
    B = "License is bound to another user."
  elseif l:find("DENY|INVALID_KEY", 1, true) then
    ie("INVALID KEY")
    B = "Invalid license key."
  elseif l:find("DENY|BAD_KEY_FORMAT", 1, true) then
    ie("BAD KEY FORMAT")
    B = "License key format is invalid."
  elseif l:find("DENY|NO_ID", 1, true) then
    ie("NO CLIENT ID")
    B = "Client ID is unavailable."
  elseif l:find("DENY|", 1, true) then
    ie("DENIED")
    B = "License denied by server."
  elseif l == "" then
    ie("NO RESPONSE")
    B = "License server gave no response."
  else
    ie("CHECK FAILED")
    B = "License check failed."
  end
  r = false
  if not V then
    d(B)
  end
  return false
end
local function He(n, m, V)
  if L then
    return
  end
  if m == "UTD_start" then
    if V ~= true then
      t = false
      z("STOPPED")
      return
    end
    if t then
      return
    end
    if o then
      Ke(false)
      d("Wait for the previous run to stop.")
      return
    end
    local n, m = Se()
    if not n then
      Ke(false)
      d(m)
      return
    end
    t, o, J, b = true, true, nil, nil
    Y = nil
    i("UTD_activeDrop", "")
    runThread(function()
      local m, V = pcall(ge, n)
      local W = not t
      t, O = false, nil
      e()
      ne()
      o = false
      Ke(false)
      local c = W and "STOPPED" or (m and V or "Stopped: " .. tostring(V))
      z(c)
      d(c)
    end)
    return
  end
  if m == "UTD_item" then
    Me(V)
    return
  end
  local W = m and m:match("^UTD_(.+)$")
  if W == "here" or W == "remove" then
    local n = G(w["worlds"])
    if W == "here" then
      if not x(I()) or not R() then
        d("Enter a world first.")
        return
      end
      n[#n + 1] = I()
      n = G(table["concat"](n, ","))
    else
      table["remove"](n)
    end
    W, V = "worlds", table["concat"](n, ", ")
    i("UTD_worlds", V)
  end
  if W == "hereDropWorld" then
    if not x(I()) or not R() then
      d("Enter the drop world first.")
      return
    end
    W, V = "dropWorld", I()
    i("UTD_dropWorld", V)
  elseif W == "hereDrop" then
    local n, m, V = R()
    if not m then
      return
    end
    w["dropX"], w["dropY"] = tostring(m), tostring(V)
    i("UTD_dropX", m)
    i("UTD_dropY", V)
    k()
    return
  end
  if W == "dropDelay" then
    local n = me(V)
    if not n then
      i("UTD_dropDelay", me(w["dropDelay"]) or s)
      return
    end
    V = n
  end
  if W == "fixedDrop" then
    V = V == true or V == 1 or V == "true" or V == "1"
    if V and (w["dropWorld"] == "" and (x(I()) and X(I()))) then
      w["dropWorld"] = I()
      i("UTD_dropWorld", w["dropWorld"])
    end
  end
  if W and w[W] ~= nil then
    w[W] = tostring(V or "")
    if W == "items" then
      i("UTD_selected", w["items"])
    end
    k()
  end
end
local function Ze()
  C = C + 1
  if N then
    N = false
    Ke(false)
    z("STOPPED")
  end
end
function onValue(n, m, V)
  if L then
    return
  end
  if m == "UTD_licensekey" then
    local n = Q(V)
    if n ~= A then
      Ze()
      A = n
      ie("NOT VERIFIED")
    end
    return
  end
  if m == "UTD_clearlicense" then
    Ze()
    A, h = "", ""
    local n = u()
    i("UTD_licensekey", "")
    ie(n and "NOT VERIFIED" or "SAVED KEY COULD NOT BE CLEARED")
    return
  end
  if m == "UTD_verifylicense" then
    local n = C
    runThread(function()
      if n == C then
        Re(false, n)
      end
    end)
    return
  end
  if m ~= "UTD_start" then
    return He(n, m, V)
  end
  if V ~= true then
    Ze()
    return He(n, m, V)
  end
  if t or N then
    return
  end
  if o then
    return He(n, m, V)
  end
  C = C + 1
  local W = C
  N = true
  z("CHECKING LICENSE BEFORE START")
  runThread(function()
    local V = 0
    while W == C and (r and V < 30000) do
      Sleep(100)
      V = V + 100
    end
    if W ~= C then
      return
    end
    local c = Re(false, W)
    if W ~= C then
      return
    end
    N = false
    if not c then
      Ke(false)
      z("LICENSE CHECK FAILED - PRESS START TO RETRY")
      return
    end
    He(n, m, true)
  end)
end
applyHook()
if type(setOnValue) == "function" then
  for n, m in ipairs({ "UTD_items", "UTD_worlds", "UTD_dropDelay", "UTD_dropWorld", "UTD_dropX", "UTD_dropY" }) do
    local V = m
    pcall(setOnValue, V, function(...)
      local n = select("#", ...)
      if n > 0 then
        onValue(nil, V, select(n, ...))
      end
    end)
  end
  pcall(setOnValue, "UTD_item", function(...)
    for n = select("#", ...), 1, -1 do
      if Me(select(n, ...)) then
        return
      end
    end
  end)
end
