setMinimum("6.1.2")
local S =
  "https://script.google.com/macros/s/AKfycbxeBzpOUzvcRDkX-4eR8uioFbAUDsepIQc26kmxUkXt6YOjBxFdVsOE0zzvxYSprl5knA/exec"
local W = "UTDROP"
local N = "RetrieveTesseractDropLicense"
local l = "license_key"
local a = nil
local h = ""
local function J(S)
  S = tostring(S or "")
  S = S:gsub("%s+", "")
  return S:upper()
end
local function r(S)
  S = J(S)
  return S:match("^[A-Z]%d%d%d%d%d%d%d$") ~= nil
end
local function A()
  local S = pcall(function()
    local S = nil
    if type(require) == "function" then
      local W, N = pcall(require, "preferences")
      if W and N ~= nil then
        S = N
      end
    end
    if S == nil and type(Preferences) == "table" then
      S = Preferences
    end
    if S == nil then
      return
    end
    if type(S["new"]) == "function" then
      local W = S:new(N)
      a = W or S
    else
      a = S
    end
    if a ~= nil and type(a["load"]) == "function" then
      a:load()
    end
    if a ~= nil and type(a["get"]) == "function" then
      h = J(a:get(l, ""))
    end
  end)
  if not S then
    a = nil
    h = ""
  end
end
local function c(S)
  if a == nil then
    return false
  end
  local W = pcall(function()
    a:set(l, J(S))
    a:save()
  end)
  return W
end
local function Y()
  if a == nil then
    return false
  end
  local S = pcall(function()
    a:set(l, "")
    a:save()
  end)
  return S
end
A()
local E = h
local Q = 0
local O, q = false, false
local d = "Auto Retrieve Tesseract & Drop"
local Z = 0
local I = 2000
local u = 2200
local w = {
  ["items"] = "",
  ["worlds"] = "",
  ["dropDelay"] = tostring(Z),
  ["fixedDrop"] = "false",
  ["dropWorld"] = "",
  ["dropX"] = "",
  ["dropY"] = "",
}
local X, g, G = false, false, false
local V, P, U
local p
local k = false
local M = {}
local function y(S, ...)
  if type(S) ~= "function" then
    return nil
  end
  local W, N = pcall(S, ...)
  if W then
    return N
  end
end
local function t(S, ...)
  local W, N = pcall(S, ...)
  return W and N ~= false
end
local function n(S, W)
  G = true
  y(editValue, S, tostring(W))
  G = false
end
local function f(S)
  n("UTD_status", S)
end
local function D()
  return (tostring(y(GetWorldName or getCurrentWorldName) or "")):upper()
end
local function C()
  local S = y(GetLocal or getLocal)
  if S and (tonumber(S["posX"]) and tonumber(S["posY"])) then
    return S, math["floor"](S["posX"] / 32), math["floor"](S["posY"] / 32)
  end
end
local function H()
  return X and (V == D() and C() ~= nil)
end
local function F(S)
  local W, N = S:match("^([A-Z0-9]+)|([^|]+)$")
  if W then
    return W, N
  end
  if S:match("^[A-Z0-9]+$") then
    return S
  end
end
local function e(S)
  if D() ~= S or not C() then
    return false
  end
  local W = y(GetTiles or getTiles)
  return type(W) == "table" and next(W) ~= nil
end
local function v(S)
  for W = 1, 75, 1 do
    if not X then
      return false
    end
    if e(S) then
      Sleep(300)
      if X and e(S) then
        return true
      end
    end
    Sleep(200)
  end
  return false
end
local function R(S, W)
  local N, l = F(S)
  if not X or not N then
    return false
  end
  if e(N) and (not l or (P == S and (not W or p == S))) then
    V = N
    if not l then
      P, p = nil, nil
    end
    return true
  end
  local a = SendPacket or sendPacket
  if not e(N) then
    P, p = nil, nil
    f("WARPING TO " .. N)
    local S = growtopia and growtopia["warpTo"]
    local W
    if type(S) == "function" then
      W = t(S, N)
    else
      W = t(a, 3, "action|join_request\nname|" .. (N .. "\ninvitedWorld|0"))
    end
    if not W or not v(N) then
      return false
    end
    Sleep(1000)
    if not X or not e(N) then
      return false
    end
  end
  if l then
    P, p = nil, nil
    f("ENTERING DOOR " .. S)
    local l, h, J = C()
    if not t(a, 3, "action|join_request\nname|" .. (S .. "\ninvitedWorld|0")) then
      return false
    end
    if W then
      local S = false
      for W = 1, 75, 1 do
        if not X then
          return false
        end
        local l, a, r = C()
        S = S or not e(N) or a ~= h or r ~= J
        if S and e(N) then
          break
        end
        Sleep(200)
      end
      if not S then
        return false
      end
    else
      Sleep(1400)
    end
    if not v(N) then
      return false
    end
    Sleep(1000)
    if not X or not e(N) then
      return false
    end
    P = S
    if W then
      p = S
    end
  end
  V = N
  return true
end
local function x(S, W)
  return y(GetTile or getTile or (tile and tile["getTile"]), S, W)
end
local function B(S)
  local W = y(growtopia and growtopia["checkInventoryCount"], S)
  if tonumber(W) then
    return tonumber(W)
  end
  local N = y(GetInventory or getInventory)
  if type(N) ~= "table" then
    return nil
  end
  for W, N in pairs(N) do
    if tonumber(N["id"]) == S then
      return tonumber(N["amount"])
    end
  end
  return 0
end
local function K(S, W)
  for S in S:gmatch("[^\r\n]+") do
    local N = S:match("^embed_data|" .. (W .. "|([^|]+)")) or S:match("^" .. (W .. "|([^|]+)"))
    if N then
      return tonumber(N)
    end
  end
end
local function b(S)
  return ((tostring(S or "")):upper()):gsub("%s+", "")
end
local function L(S)
  local W = F(S)
  return W and (W ~= "EXIT" and W ~= "EXITWORLD")
end
local function T(S)
  local W, N = {}, {}
  for S in (tostring(S or "")):gmatch("[^,]+") do
    S = b(S)
    if S ~= "" and not N[S] then
      W[#W + 1], N[S] = S, true
    end
  end
  return W
end
local o
pcall(function()
  local S = y(require, "preferences") or Preferences
  local W = S:new("AutoRetrieveTesseractDrop")
  W:load()
  o = W
  for S, W in pairs(w) do
    w[S] = tostring(o:get(S, W) or W)
  end
end)
local function z()
  return pcall(function()
    for S, W in pairs(w) do
      o:set(S, W)
    end
    if o:save() == false then
      error("save")
    end
  end)
end
local function s(S)
  y(growtopia and growtopia["notify"], S)
end
local function i()
  if k then
    return true
  end
  local S = y(getValue or GetValue, 0, "ModFly")
  if S == true or S == 1 or S == "true" then
    return true
  end
  k = t(editToggle or EditToggle, "ModFly", true)
  return k
end
local function m()
  if k then
    t(editToggle or EditToggle, "ModFly", false)
  end
  k = false
end
local function j()
  for S, W in ipairs({ "Enable AutoCollect", "Autocollect", "Fast Drop" }) do
    local N = y(getValue or GetValue, 0, W)
    if N == true or N == 1 or N == "true" or N == "1" then
      if not t(editToggle or EditToggle, W, false) then
        return false
      end
      M[#M + 1] = W
    end
  end
  return true
end
local function Su()
  for S, W in ipairs(M) do
    t(editToggle or EditToggle, W, true)
  end
  M = {}
end
local function Wu(S)
  local W = tonumber(S)
  if W and (W >= 0 and (W <= 10000 and W % 1 == 0)) then
    return W
  end
end
local Nu = w["dropWorld"]
if Nu == "" and (L(D()) and e(D())) then
  Nu = D()
end
local lu = UserInterface["new"](d, "Inventory")
lu:addLabelApp(d, "Inventory")
lu:addInputString("License Key", h, "A1234567", "A1234567", nil, "UTD_licensekey")
lu:addButton("Verify License", "UTD_verifylicense")
lu:addButton("Clear Saved License", "UTD_clearlicense")
lu:addDisplayList("License Status", "NOT VERIFIED", "UTD_licensestatus")
lu:addToggle("Start / Stop", false, "UTD_start")
lu:addItemPicker("Add Item to Retrieve", "Dirt", "2", "UTD_item")
lu:addDisplayList("Selected Item IDs", w["items"], "UTD_selected")
lu:addInputString("Item IDs (comma-separated)", w["items"], "2, 4, 6", "2, 4, 6", nil, "UTD_items")
local au = (lu:addDialog("Settings", "Tesseract worlds in collection order", {}))["menu"]
lu:addChildInputString(
  au,
  "Tesseract Worlds (comma-separated)",
  w["worlds"],
  "WORLD|DOORID",
  "FARM1, FARM2",
  nil,
  "UTD_worlds"
)
lu:addChildButton(au, "Add Current World", "UTD_here")
lu:addChildButton(au, "Remove Last World", "UTD_remove")
local hu = (lu:addDialog("Drop Settings", "Wait before each drop request and confirmation", {}))["menu"]
lu:addChildInputInt(hu, "Drop Delay (ms)", tostring(Wu(w["dropDelay"]) or Z), "ms", tostring(Z), nil, "UTD_dropDelay")
local Ju = (lu:addExpandableToggle("Custom Drop World", w["fixedDrop"] == "true", "UTD_fixedDrop", false))["list_child"]
lu:addChildInputString(Ju, "Drop World", Nu, "WORLD|DOORID", "STORAGE", nil, "UTD_dropWorld")
lu:addChildButton(Ju, "Drop World = Current World", "UTD_hereDropWorld")
lu:addChildInputInt(Ju, "Drop Position X", w["dropX"], "X", "", nil, "UTD_dropX")
lu:addChildInputInt(Ju, "Drop Position Y", w["dropY"], "Y", "", nil, "UTD_dropY")
lu:addChildButton(Ju, "Set Drop Position = Current Tile", "UTD_hereDrop")
lu:addDisplayList("Active Drop Tile", "", "UTD_activeDrop")
lu:addDisplayList("Status", "STOPPED", "UTD_status")
y(addCategory, d, "Inventory")
y(addIntoModule, lu:generateJSON(), d)
local function ru(S, W)
  local N, l, a = C()
  return H() and (l == S and a == W)
end
local function Au(S, W)
  if ru(S, W) then
    return true
  end
  for N, l in ipairs({ 25, 45 }) do
    if not H() then
      return false
    end
    Sleep(450)
    if not H() then
      return false
    end
    y(FindPath or findPath, S, W)
    for N = 1, l, 1 do
      if not H() then
        return false
      end
      if ru(S, W) then
        return true
      end
      Sleep(100)
    end
  end
  return false
end
local function cu()
  local S = D()
  return S == "" or S == "EXIT" or S == "EXITWORLD" or not C()
end
local function Yu(S)
  while X do
    if R(S) then
      return true
    end
    if not X then
      return false
    end
    if not cu() then
      return false
    end
    P, p = nil, nil
    f("WAITING FOR RECONNECT - " .. S)
    Sleep(2500)
  end
  return false
end
function onSendPacketRaw(S)
  return X and (S ~= nil and tonumber(S["type"]) == 11)
end
function onVariant(S)
  local W = U
  if not W or not H() or not S or S["v1"] ~= "OnDialogRequest" or type(S["v2"]) ~= "string" then
    return false
  end
  local N = S["v2"]
  if not N:find(W["dialog"], 1, true) then
    return false
  end
  local l, a = K(N, "tilex"), K(N, "tiley")
  if (W["x"] and (l and W["x"] ~= l)) or (W["y"] and (a and W["y"] ~= a)) then
    return false
  end
  local h = K(N, "itemID") or K(N, "itemid")
  if W["id"] and (h and W["id"] ~= h) then
    return false
  end
  W["text"] = N
  return true
end
local function Eu(S, W, N, l, a, h, J, r)
  local A = { ["dialog"] = S, ["x"] = W, ["y"] = N, ["id"] = a }
  U = A
  if l() then
    for S = 1, (h or 45), 1 do
      if A["text"] or not H() or (r and r()) then
        break
      end
      Sleep(J or 100)
    end
  end
  U = nil
  return A["text"]
end
local function Qu(S)
  return (((S or "")):gsub(string["char"](96) .. ".", "")):lower()
end
local function Ou(S)
  local W = y(getItemInfoByID or GetItemInfo, S)
  return W and W["name"] or y(growtopia and growtopia["getItemName"], S)
end
local function qu(S, W)
  local N = K(S, "targetitem") or K(S, "itemID") or K(S, "itemid")
  if N then
    return W[N] and N
  end
  local l, a, h = Qu(S), nil, 0
  for S, W in pairs(W) do
    if #W > h and l:find(W:lower(), 1, true) then
      a, h = S, #W
    end
  end
  return a
end
local function du(S)
  local W = Qu(S)
  local N = W:match("contains a total of%s+([%d,]+)")
    or W:match("contains%s+([%d,]+)")
    or W:match("currently stored:%s*([%d,]+)")
  if N then
    return tonumber((N:gsub(",", "")))
  end
  if W:find("contains no items", 1, true) or W:find("currently empty", 1, true) then
    return 0
  end
end
local function Zu(S)
  local W, N = S["x"], S["y"]
  return Eu("itemsucker_block", W, N, function()
    local l = C()
    return l
      and (
        ru(W, S["standY"])
        and t(
          SendPacketRaw or sendPacketRaw,
          false,
          { ["type"] = 3, ["value"] = 32, ["px"] = W, ["py"] = N, ["x"] = l["posX"], ["y"] = l["posY"] }
        )
      )
  end)
end
local function Iu(S)
  local W, N = S["x"], S["y"]
  return Eu("itemremovedfromsucker", W, N, function()
    return ru(W, S["standY"])
      and t(
        SendPacket or sendPacket,
        2,
        "action|dialog_return\ndialog_name|itemsucker_block\ntilex|"
          .. (W .. ("|\ntiley|" .. (N .. "|\nbuttonClicked|retrieveitem\n\nchk_enablesucking|1")))
      )
  end)
end
local function uu(S, W, N, l)
  for l = 1, l, 1 do
    if not H() then
      return nil
    end
    local a = B(S)
    if a and ((N and a > W) or (not N and a < W)) then
      return a
    end
    Sleep(100)
  end
  if H() then
    return B(S)
  end
end
local function wu(S, W)
  local N = y(GetTiles or getTiles)
  if type(N) ~= "table" or next(N) == nil then
    return nil, false
  end
  local l
  for N, a in pairs(N) do
    local h, J = tonumber(a["x"]), tonumber(a["y"])
    if h and (J and (J >= 0 and tonumber(a["fg"]) == S)) then
      local S = h .. ("," .. J)
      if not W[S] and (not l or h > l["x"] or (h == l["x"] and J < l["y"])) then
        l = { ["x"] = h, ["y"] = J, ["key"] = S }
      end
    end
  end
  return l, true
end
local function Xu(S)
  local W, N = S["y"] - 1, S["y"] + 1
  local l = S["standY"] or W
  local a = l == W and N or W
  if l >= 0 and Au(S["x"], l) then
    S["standY"] = l
    return true
  end
  if H() and (a >= 0 and Au(S["x"], a)) then
    S["standY"] = a
    return true
  end
  return false
end
local function gu(S, W, N)
  local l, a = S["x"], S["y"]
  if not Xu(S) then
    return H() and "unreachable" or "reconnect"
  end
  local h = x(l, a)
  if not h or tonumber(h["fg"]) ~= N then
    return "unreachable"
  end
  local J = Zu(S)
  if not H() then
    return "reconnect"
  end
  if not J then
    return "unreadable"
  end
  local r = qu(J, W)
  if not r then
    return "unmatched"
  end
  local A = W[r]
  local c = du(J)
  if c == 0 then
    return "empty"
  end
  local Y = B(r)
  if not Y then
    return "inventory unavailable"
  end
  local E = math["min"](200 - Y, c or 200)
  if E <= 0 then
    return "full"
  end
  local Q = Iu(S)
  if not H() then
    return "reconnect"
  end
  if not Q then
    return "unreadable"
  end
  local O = K(Q, "targetitem") or K(Q, "itemID") or K(Q, "itemid")
  if O and O ~= r then
    return "unmatched"
  end
  local q = du(Q)
  if q then
    E = math["min"](E, q)
  end
  if E <= 0 then
    return "empty"
  end
  if not ru(l, S["standY"]) then
    return "unreachable"
  end
  f("RETRIEVING " .. (E .. (" " .. (A .. (" AT " .. S["key"])))))
  if
    not t(
      SendPacket or sendPacket,
      2,
      "action|dialog_return\ndialog_name|itemremovedfromsucker\ntilex|"
        .. (l .. ("|\ntiley|" .. (a .. ("|\nitemtoremove|" .. E))))
    )
  then
    return "withdrawal request failed"
  end
  local d = uu(r, Y, true, 65)
  if not H() or d == nil then
    return "reconnect", r, Y
  end
  if d > Y then
    return "store", r, Y
  end
  return "withdrawal unconfirmed"
end
local function Gu()
  local S = C()
  return S and (S["isLeft"] == true or S["isLeft"] == 1)
end
local function Vu()
  if not H() then
    return false
  end
  if not Gu() then
    return true
  end
  f("RESPAWNING TO FACE RIGHT")
  if not t(SendPacket or sendPacket, 2, "action|respawn") then
    return false
  end
  Sleep(1200)
  for S = 1, 35, 1 do
    if not X or cu() then
      return false
    end
    if H() and not Gu() then
      return true
    end
    Sleep(100)
  end
  return false
end
local function Pu(S, W)
  if not Au(S, W) then
    return false
  end
  if not Gu() then
    return true
  end
  if not Vu() or not Au(S, W) then
    return false
  end
  if not Gu() then
    return true
  end
  return S > 0 and (Au(S - 1, W) and (Au(S, W) and not Gu()))
end
local function Uu(S, W, N, l, a)
  local h = B(S)
  if not h or not ru(W, N) or Gu() then
    return nil
  end
  if h <= l then
    return h
  end
  local J = Eu(
    "drop_item",
    nil,
    nil,
    function()
      return ru(W, N) and (not Gu() and t(SendPacket or sendPacket, 2, "action|drop\nitemID|" .. S))
    end,
    S,
    math["ceil"](I / 75),
    75,
    function()
      return not ru(W, N) or (B(S) or h) < h
    end
  )
  if not ru(W, N) then
    return nil
  end
  local r = B(S)
  if not r or r < h then
    return r
  end
  if not J then
    return r
  end
  if a > 0 then
    Sleep(a)
  end
  if not ru(W, N) or Gu() then
    return nil
  end
  r = B(S)
  if not r or r ~= h then
    return r
  end
  if
    not t(
      SendPacket or sendPacket,
      2,
      "action|dialog_return\ndialog_name|drop_item\nitemID|" .. (S .. ("|\ncount|" .. (h - l)))
    )
  then
    return nil
  end
  return uu(S, h, false, u / 100)
end
local function pu(S, W, N, l)
  local a = S["y"]
  local h = false
  local J
  if S["verifyDoor"] then
    J = R(S["world"], true)
  else
    J = Yu(S["world"])
  end
  if not J then
    return false, "Could not enter the drop world."
  end
  while X do
    local J = S["x"]
    if not e(V) or not x(J, a) then
      return false, "Drop world or standing tile is unavailable."
    end
    if not Pu(J, a) then
      return false, "Cannot reach the drop tile while facing right."
    end
    if not ru(J, a) or Gu() then
      return false, "Lost the verified drop position."
    end
    local r = B(W)
    if not r then
      return false, "Could not read the backpack in storage."
    end
    if r < N then
      return false, "Backpack count fell below the amount held before withdrawal."
    end
    if r == N then
      return true
    end
    n("UTD_activeDrop", J .. ("," .. a))
    f("DROPPING ITEM " .. (W .. (" x" .. (r - N))))
    local A = Uu(W, J, a, N, l)
    if not A or not ru(J, a) then
      return false, "Drop interrupted at the storage tile. Check the backpack."
    end
    if A >= r then
      Sleep(1200)
      if not ru(J, a) then
        return false, "Lost the verified drop position."
      end
      A = B(W)
      if not A then
        return false, "Could not confirm the backpack count."
      end
    end
    if A < N then
      return false, "Drop exceeded the retrieved amount. Check Fast Drop."
    end
    if A == N then
      return true
    end
    if A > r then
      return false, "Backpack count increased during the drop. Check the backpack."
    end
    if A == r then
      if h or J <= 0 then
        return false, "Drop unconfirmed and no left retry remains."
      end
      S["x"], h = J - 1, true
      f("DROP UNCONFIRMED - SHIFTING LEFT")
    end
  end
  return false, "Stopped."
end
local function ku(S)
  local W = tonumber(y(findItemID or (growtopia and growtopia["getItemID"]), "Unstable Tesseract"))
  if not W or W < 1 then
    return "Could not resolve the Unstable Tesseract item ID."
  end
  if not j() then
    return "Could not pause launcher pickup or Fast Drop."
  end
  if not i() then
    return "Could not enable ModFly."
  end
  local N = {}
  for S, W in ipairs(S["items"]) do
    local l = Ou(W)
    if not l or l == "" then
      return "Could not resolve selected item " .. (W .. ".")
    end
    N[W] = l
  end
  local l = 0
  local a
  for h, J in ipairs(S["worlds"]) do
    local r = {}
    local A, c, Y
    local E = S["fixedStorage"]
    local Q, O = {}, {}
    local q = false
    while X do
      if Y then
        if not E then
          E = { ["world"] = J, ["x"] = A["x"], ["y"] = A["standY"] }
        end
        local W, N = pu(E, Y["item"], Y["before"], S["dropDelay"])
        if not W then
          return N
        end
        Y = nil
      end
      if not Yu(J) then
        return "Could not enter Tesseract world " .. (J .. ".")
      end
      if not q then
        if not Vu() then
          return "Could not face right in " .. (J .. ".")
        end
        q = true
      end
      if not a then
        a = {}
        local W = {}
        for S, N in ipairs(S["items"]) do
          local l = B(N)
          if l == nil then
            return "Could not read selected items in the backpack."
          end
          if l > 0 and not W[N] then
            a[#a + 1] = N
            W[N] = true
          end
        end
      end
      if S["fixedStorage"] then
        for S, W in ipairs(a) do
          Q[W] = 0
        end
        a = {}
      end
      if c then
        Sleep(1200)
        if H() then
          local S = B(c["item"])
          if not S then
            return "Could not reconcile the backpack after reconnecting."
          end
          if S > c["before"] then
            Y = c
          end
          c = nil
        end
      end
      if S["fixedStorage"] and Y then
        if Q[Y["item"]] == nil then
          Q[Y["item"]] = Y["before"]
        end
        Y = nil
      end
      if H() and (not Y and not c) then
        if not A then
          local N
          A, N = wu(W, r)
          if not N then
            return "Could not scan Tesseracts in " .. (J .. ".")
          end
          if not A then
            if not S["fixedStorage"] or next(Q) == nil then
              break
            end
            f("DROPPING SELECTED ITEMS AS A BATCH")
            for W, N in ipairs(S["items"]) do
              if Q[N] ~= nil then
                local W, l = pu(E, N, Q[N], S["dropDelay"])
                if not W then
                  return l
                end
                Q[N] = nil
              end
            end
            Q = {}
            if next(O) == nil then
              break
            end
            for S in pairs(O) do
              r[S] = nil
            end
            O = {}
          end
        end
        if A and #a > 0 then
          if not E and Xu(A) then
            E = { ["world"] = J, ["x"] = A["x"], ["y"] = A["standY"] }
          end
          if E then
            for W, N in ipairs(a) do
              f("DROPPING CARRIED ITEM " .. (N .. " BEFORE RETRIEVAL"))
              local l, a = pu(E, N, 0, S["dropDelay"])
              if not l then
                return a
              end
            end
            a = {}
          elseif H() then
            r[A["key"]] = true
            A = nil
            l = l + 1
          end
        elseif A then
          f("CHECKING TESSERACT " .. (J .. (" " .. A["key"])))
          local a, h, E = gu(A, N, W)
          if a == "store" then
            if S["fixedStorage"] then
              if Q[h] == nil then
                Q[h] = E
              end
            else
              Y = { ["item"] = h, ["before"] = E }
            end
          elseif a == "reconnect" then
            if h then
              c = { ["item"] = h, ["before"] = E }
            end
          elseif a == "empty" or a == "unmatched" or a == "unreachable" or a == "unreadable" or a == "full" then
            r[A["key"]] = true
            local W = S["fixedStorage"] and (a == "full" and next(Q) ~= nil)
            if W then
              O[A["key"]] = true
            end
            A = nil
            if a == "unreachable" or a == "unreadable" or (a == "full" and not W) then
              l = l + 1
            end
          else
            return a .. (" at " .. (J .. (" " .. (A["key"] .. ". Check the backpack and Tesseract."))))
          end
        end
      end
    end
    if not X then
      return "STOPPED"
    end
  end
  if a and #a > 0 then
    return "No reachable Tesseract for dropping carried items."
  end
  if l > 0 then
    return "Finished. " .. (l .. " Tesseract check(s) could not be completed.")
  end
  return "Finished all selected items and worlds."
end
local function Mu(S)
  G = true
  y(editToggle or EditToggle, "UTD_start", S)
  G = false
end
local function yu()
  local S = { ["items"] = {}, ["worlds"] = T(w["worlds"]), ["dropDelay"] = Wu(w["dropDelay"]) or Z }
  for W, N in ipairs(T(w["items"])) do
    local l = tonumber(N)
    if not l or l < 1 or l > 65535 or l % 1 ~= 0 then
      return nil, "Enter valid item IDs."
    end
    S["items"][#S["items"] + 1] = l
  end
  if #S["items"] == 0 then
    return nil, "Add at least one item."
  end
  if #S["worlds"] == 0 then
    return nil, "Add at least one Tesseract world."
  end
  for S, W in ipairs(S["worlds"]) do
    if not L(W) then
      return nil, "Invalid world route: " .. W
    end
  end
  if w["fixedDrop"] == "true" then
    local W = b(w["dropWorld"])
    if W == "" and e(D()) then
      W = D()
    end
    local N, l = tonumber(w["dropX"]), tonumber(w["dropY"])
    if not L(W) or not N or not l or N < 0 or l < 0 or N % 1 ~= 0 or l % 1 ~= 0 then
      return nil, "Set the world and position under Custom Drop World."
    end
    S["fixedStorage"] = { ["world"] = W, ["x"] = N, ["y"] = l, ["verifyDoor"] = true }
  end
  return S
end
local function tu(S)
  if type(S) == "table" then
    S = S["id"] or S["itemID"] or S["value"] or S["name"]
  end
  local W = tonumber(S)
  if not W and type(S) == "string" then
    W = tonumber(S:match("%((%d+)%)")) or tonumber(y(findItemID or (growtopia and growtopia["getItemID"]), S))
  end
  if not W or W < 1 or W > 65535 or W % 1 ~= 0 then
    return false
  end
  local N = T(w["items"])
  for S, N in ipairs(N) do
    if tonumber(N) == W then
      return true
    end
  end
  N[#N + 1] = tostring(W)
  w["items"] = table["concat"](N, ", ")
  n("UTD_items", w["items"])
  n("UTD_selected", w["items"])
  z()
  return true
end
local function nu(S)
  local W = tostring(S or "")
  pcall(function()
    editValue("UTD_licensestatus", W)
  end)
end
local function fu(S)
  S = tostring(S or "")
  S = S:gsub("\n", "\r\n")
  S = S:gsub("([^%w%-_%.~])", function(S)
    return string["format"]("%%%02X", string["byte"](S))
  end)
  return S
end
local function Du()
  local S = ""
  if type(getDiscordID) == "function" then
    local W, N = pcall(getDiscordID)
    if W and N ~= nil then
      S = tostring(N)
    end
  elseif getDiscordID ~= nil then
    S = tostring(getDiscordID)
  end
  S = ((tostring(S or "")):gsub("^%s+", "")):gsub("%s+$", "")
  if S == "" or S == "nil" or S == "0" then
    local W = GetLocal or getLocal
    if W ~= nil then
      local N, l = pcall(W)
      if N and (l ~= nil and l["name"] ~= nil) then
        S = tostring(l["name"])
        S = (S:gsub("^%s+", "")):gsub("%s+$", "")
      end
    end
  end
  return S
end
local function Cu(N, l)
  if q then
    return false
  end
  q = true
  local a = J(E)
  E = a
  if not r(a) then
    nu("INVALID KEY FORMAT")
    q = false
    if not N then
      s("License must be 1 letter + 7 numbers, for example A1234567.")
    end
    return false
  end
  local A = Du()
  if A == "" then
    nu("NO CLIENT ID")
    q = false
    if not N then
      s("Could not read a client ID. Enter the game first and try again.")
    end
    return false
  end
  nu("CHECKING...")
  local Y = S .. ("?key=" .. (fu(a) .. ("&id=" .. (fu(A) .. ("&product=" .. fu(W))))))
  local O, d, Z = pcall(fetch, Y)
  if not O then
    nu("SERVER ERROR")
    q = false
    if not N then
      s("License server request failed.")
    end
    return false
  end
  if l ~= Q then
    q = false
    return false
  end
  d = tostring(d or "")
  d = (d:gsub("^%s+", "")):gsub("%s+$", "")
  if d:find("OK|PERMANENT", 1, true) then
    nu("VERIFIED - PERMANENT")
    local S = c(a)
    if S then
      h = a
    end
    q = false
    if not N then
      s(S and "License verified and saved." or "License verified. Could not save the key.")
    end
    return true
  end
  local I = d
  local u = "LICENSE CHECK FAILED"
  if I:find("DENY|DISABLED", 1, true) then
    nu("DISABLED")
    u = "License disabled."
  elseif I:find("DENY|WRONG_PRODUCT", 1, true) then
    nu("WRONG PRODUCT")
    u = "This license is for another script."
  elseif I:find("DENY|BOUND_TO_OTHER_USER", 1, true) then
    nu("BOUND TO OTHER USER")
    u = "License is bound to another user."
  elseif I:find("DENY|INVALID_KEY", 1, true) then
    nu("INVALID KEY")
    u = "Invalid license key."
  elseif I:find("DENY|BAD_KEY_FORMAT", 1, true) then
    nu("BAD KEY FORMAT")
    u = "License key format is invalid."
  elseif I:find("DENY|NO_ID", 1, true) then
    nu("NO CLIENT ID")
    u = "Client ID is unavailable."
  elseif I:find("DENY|", 1, true) then
    nu("DENIED")
    u = "License denied by server."
  elseif I == "" then
    nu("NO RESPONSE")
    u = "License server gave no response."
  else
    nu("CHECK FAILED")
    u = "License check failed."
  end
  q = false
  if not N then
    s(u)
  end
  return false
end
local function Hu(S, W, N)
  if G then
    return
  end
  if W == "UTD_start" then
    if N ~= true then
      X = false
      f("STOPPED")
      return
    end
    if X then
      return
    end
    if g then
      Mu(false)
      s("Wait for the previous run to stop.")
      return
    end
    local S, W = yu()
    if not S then
      Mu(false)
      s(W)
      return
    end
    X, g, V, P = true, true, nil, nil
    p = nil
    n("UTD_activeDrop", "")
    runThread(function()
      local W, N = pcall(ku, S)
      local l = not X
      X, U = false, nil
      m()
      Su()
      g = false
      Mu(false)
      local a = l and "STOPPED" or (W and N or "Stopped: " .. tostring(N))
      f(a)
      s(a)
    end)
    return
  end
  if W == "UTD_item" then
    tu(N)
    return
  end
  local l = W and W:match("^UTD_(.+)$")
  if l == "here" or l == "remove" then
    local S = T(w["worlds"])
    if l == "here" then
      if not L(D()) or not C() then
        s("Enter a world first.")
        return
      end
      S[#S + 1] = D()
      S = T(table["concat"](S, ","))
    else
      table["remove"](S)
    end
    l, N = "worlds", table["concat"](S, ", ")
    n("UTD_worlds", N)
  end
  if l == "hereDropWorld" then
    if not L(D()) or not C() then
      s("Enter the drop world first.")
      return
    end
    l, N = "dropWorld", D()
    n("UTD_dropWorld", N)
  elseif l == "hereDrop" then
    local S, W, N = C()
    if not W then
      return
    end
    w["dropX"], w["dropY"] = tostring(W), tostring(N)
    n("UTD_dropX", W)
    n("UTD_dropY", N)
    z()
    return
  end
  if l == "dropDelay" then
    local S = Wu(N)
    if not S then
      n("UTD_dropDelay", Wu(w["dropDelay"]) or Z)
      return
    end
    N = S
  end
  if l == "fixedDrop" then
    N = N == true or N == 1 or N == "true" or N == "1"
    if N and (w["dropWorld"] == "" and (L(D()) and e(D()))) then
      w["dropWorld"] = D()
      n("UTD_dropWorld", w["dropWorld"])
    end
  end
  if l and w[l] ~= nil then
    w[l] = tostring(N or "")
    if l == "items" then
      n("UTD_selected", w["items"])
    end
    z()
  end
end
local function Fu()
  Q = Q + 1
  if O then
    O = false
    Mu(false)
    f("STOPPED")
  end
end
function onValue(S, W, N)
  if G then
    return
  end
  if W == "UTD_licensekey" then
    local S = J(N)
    if S ~= E then
      Fu()
      E = S
      nu("NOT VERIFIED")
    end
    return
  end
  if W == "UTD_clearlicense" then
    Fu()
    E, h = "", ""
    local S = Y()
    n("UTD_licensekey", "")
    nu(S and "NOT VERIFIED" or "SAVED KEY COULD NOT BE CLEARED")
    return
  end
  if W == "UTD_verifylicense" then
    local S = Q
    runThread(function()
      if S == Q then
        Cu(false, S)
      end
    end)
    return
  end
  if W ~= "UTD_start" then
    return Hu(S, W, N)
  end
  if N ~= true then
    Fu()
    return Hu(S, W, N)
  end
  if X or O then
    return
  end
  if g then
    return Hu(S, W, N)
  end
  Q = Q + 1
  local l = Q
  O = true
  f("CHECKING LICENSE BEFORE START")
  runThread(function()
    local N = 0
    while l == Q and (q and N < 30000) do
      Sleep(100)
      N = N + 100
    end
    if l ~= Q then
      return
    end
    local a = Cu(false, l)
    if l ~= Q then
      return
    end
    O = false
    if not a then
      Mu(false)
      f("LICENSE CHECK FAILED - PRESS START TO RETRY")
      return
    end
    Hu(S, W, true)
  end)
end
applyHook()
if type(setOnValue) == "function" then
  for S, W in ipairs({ "UTD_items", "UTD_worlds", "UTD_dropDelay", "UTD_dropWorld", "UTD_dropX", "UTD_dropY" }) do
    local N = W
    pcall(setOnValue, N, function(...)
      local S = select("#", ...)
      if S > 0 then
        onValue(nil, N, select(S, ...))
      end
    end)
  end
  pcall(setOnValue, "UTD_item", function(...)
    for S = select("#", ...), 1, -1 do
      if tu(select(S, ...)) then
        return
      end
    end
  end)
end
