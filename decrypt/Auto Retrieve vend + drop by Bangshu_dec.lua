local f =
  "https://script.google.com/macros/s/AKfycbxeBzpOUzvcRDkX-4eR8uioFbAUDsepIQc26kmxUkXt6YOjBxFdVsOE0zzvxYSprl5knA/exec"
local v = "RETREIVE"
local V = "RetrieveVendLicense"
local W = "license_key"
local L = nil
local e = ""
local function S(f)
  f = tostring(f or "")
  f = f:gsub("%s+", "")
  return f:upper()
end
local function w(f)
  f = S(f)
  return f:match("^[A-Z]%d%d%d%d%d%d%d$") ~= nil
end
local function E()
  local f = pcall(function()
    local f = nil
    if type(require) == "function" then
      local v, V = pcall(require, "preferences")
      if v and V ~= nil then
        f = V
      end
    end
    if f == nil and type(Preferences) == "table" then
      f = Preferences
    end
    if f == nil then
      return
    end
    if type(f["new"]) == "function" then
      local v = f:new(V)
      L = v or f
    else
      L = f
    end
    if L ~= nil and type(L["load"]) == "function" then
      L:load()
    end
    if L ~= nil and type(L["get"]) == "function" then
      e = S(L:get(W, ""))
    end
  end)
  if not f then
    L = nil
    e = ""
  end
end
local function U(f)
  if L == nil then
    return false
  end
  local v = pcall(function()
    L:set(W, S(f))
    L:save()
  end)
  return v
end
local function h()
  if L == nil then
    return false
  end
  local f = pcall(function()
    L:set(W, "")
    L:save()
  end)
  return f
end
E()
local p, C, H, m = -1, -1, -1, -1
local c, J = "", ""
local F
local function u(f)
  return ((tostring(f or "")):upper()):gsub("%s+", "")
end
pcall(function()
  local f = Preferences
  if type(require) == "function" then
    local v, V = pcall(require, "preferences")
    if v and type(V) == "table" then
      f = V
    end
  end
  if type(f) ~= "table" or type(f["new"]) ~= "function" then
    return
  end
  F = f:new("RetrieveVendSettingsV1")
  F:load()
  local function v(f)
    return math["tointeger"](tonumber(F:get(f, "-1")) or -1) or -1
  end
  p, C = v("vendX"), v("vendY")
  H, m = v("dropX"), v("dropY")
  c = u(F:get("vendWorld", ""))
  J = u(F:get("dropWorld", ""))
end)
local function g()
  if not F then
    return
  end
  pcall(function()
    F:set("vendX", tostring(p))
    F:set("vendY", tostring(C))
    F:set("dropX", tostring(H))
    F:set("dropY", tostring(m))
    F:set("vendWorld", c)
    F:set("dropWorld", J)
    F:save()
  end)
end
local P = "Auto Retrieve Vend & Drop"
local t = UserInterface["new"](P, "ShoppingCart")
t:addLabelApp(P, "ShoppingCart")
t:addInputString("License Key", e, "Key", "A1234567", nil, "RVD_licensekey")
t:addButton("Verify License", "RVD_verifylicense")
t:addButton("Clear Saved License", "RVD_clearlicense")
t:addDisplayList("License Status", "NOT VERIFIED", "RVD_licensestatus")
t:addToggle("Start / Stop", false, "RVD_start")
t:addItemPicker("Pick Item", "Dirt", "2", "RVD_item")
t:addInputString("Vend World", c, "WORLD or WORLD|DOORID", "WORLD|DOORID", nil, "RVD_vendworld")
t:addButton("Vend World = Current World", "RVD_setvendworld")
t:addInputInt("Vend Position X", tostring(p), "X", "-1", nil, "RVD_vendx")
t:addInputInt("Vend Position Y", tostring(C), "Y", "-1", nil, "RVD_vendy")
t:addButton("Vend Position = Current Tile", "RVD_setvend")
t:addDisplayList("Current Position", "UNKNOWN", "RVD_current")
t:addInputString("Drop World", J, "WORLD or WORLD|DOORID", "WORLD|DOORID", nil, "RVD_dropworld")
t:addButton("Drop World = Current World", "RVD_setdropworld")
t:addInputInt("Drop Position X", tostring(H), "X", "-1", nil, "RVD_dropx")
t:addInputInt("Drop Position Y", tostring(m), "Y", "-1", nil, "RVD_dropy")
t:addButton("Drop Position = Current Tile", "RVD_setdrop")
t:addDisplayList("Active Drop Position", "NOT SET", "RVD_active")
t:addDisplayList("Status", "STOPPED", "RVD_status")
if type(addCategory) == "function" then
  pcall(addCategory, P, "ShoppingCart")
end
addIntoModule(t:generateJSON(), P)
local j = 2
local Y, q, b = false, false, false
local O, n, A
local M
local function N(f, ...)
  if type(f) ~= "function" then
    return nil
  end
  local v, V = pcall(f, ...)
  if v then
    return V
  end
end
local function r(f, ...)
  local v, V = pcall(f, ...)
  return v and V ~= false
end
local function s(f, v)
  b = true
  N(editValue, f, tostring(v))
  b = false
end
local function Q(f)
  s("RVD_status", f)
end
local T = {}
local function o()
  for f, v in ipairs({ "ModFly", "Antibounce" }) do
    local V = N(getValue, 0, v)
    if V ~= true and V ~= 1 then
      if not r(editToggle or EditToggle, v, true) then
        return false
      end
      T[#T + 1] = v
    end
  end
  return true
end
local function d()
  for f, v in ipairs(T) do
    r(editToggle or EditToggle, v, false)
  end
  T = {}
end
local function G(f)
  Y, A = false, nil
  d()
  b = true
  N(editToggle or EditToggle, "RVD_start", false)
  b = false
  Q(f)
  N(growtopia and growtopia["notify"], f)
end
local function i()
  return (tostring(N(GetWorldName or getCurrentWorldName) or "")):upper()
end
local function X()
  local f = N(GetLocal or getLocal)
  if f and (tonumber(f["posX"]) and tonumber(f["posY"])) then
    return f, math["floor"](f["posX"] / 32), math["floor"](f["posY"] / 32)
  end
end
local function K()
  return Y and (O == i() and X() ~= nil)
end
local function y(f)
  local v, V = f:match("^([A-Z0-9]+)|([^|]+)$")
  if v then
    return v, V
  end
  if f:match("^[A-Z0-9]+$") then
    return f
  end
end
local function D(f)
  if i() ~= f or not X() then
    return false
  end
  local v = N(GetTiles or getTiles)
  return type(v) == "table" and next(v) ~= nil
end
local function R(f)
  for v = 1, 75, 1 do
    if not Y then
      return false
    end
    if D(f) then
      Sleep(300)
      if Y and D(f) then
        return true
      end
    end
    Sleep(200)
  end
  return false
end
local function k(f)
  local v, V = y(f)
  if not Y or not v then
    return false
  end
  if D(v) and (not V or n == f) then
    O = v
    if not V then
      n = nil
    end
    return true
  end
  local W = SendPacket or sendPacket
  if not D(v) then
    n = nil
    Q("WARPING TO " .. v)
    local f = growtopia and growtopia["warpTo"]
    local V
    if type(f) == "function" then
      V = r(f, v)
    else
      V = r(W, 3, "action|join_request\nname|" .. (v .. "\ninvitedWorld|0"))
    end
    if not V or not R(v) then
      return false
    end
    Sleep(1000)
    if not Y or not D(v) then
      return false
    end
  end
  if V then
    Q("ENTERING DOOR " .. f)
    if not r(W, 3, "action|join_request\nname|" .. (f .. "\ninvitedWorld|0")) then
      return false
    end
    Sleep(1400)
    if not R(v) then
      return false
    end
    Sleep(1000)
    if not Y or not D(v) then
      return false
    end
    n = f
  end
  O = v
  return true
end
local function I(f, v)
  return N(GetTile or getTile or (tile and tile["getTile"]), f, v)
end
local function a(f)
  local v = N(growtopia and growtopia["checkInventoryCount"], f)
  if tonumber(v) then
    return tonumber(v)
  end
  local V = N(GetInventory or getInventory)
  if type(V) ~= "table" then
    return nil
  end
  for v, V in pairs(V) do
    if tonumber(V["id"]) == f then
      return tonumber(V["amount"])
    end
  end
  return 0
end
local function x()
  local f = X()
  local v = f and tonumber(f["backpackSize"] or f["backpack_slots"] or f["inventorySize"] or f["inventorySlots"])
  if not v or v < 1 then
    return false
  end
  local V = N(GetInventory or getInventory)
  if type(V) ~= "table" then
    return false
  end
  local W = 0
  for f, v in pairs(V) do
    if (tonumber(v["id"]) or 0) > 0 and (tonumber(v["amount"]) or 0) > 0 then
      W = W + 1
    end
  end
  return W >= v
end
local function z(f, v)
  if not K() then
    return false
  end
  local V, W, L = X()
  if W == f and L == v then
    return true
  end
  Sleep(500)
  if not K() or not pcall(FindPath or findPath, f, v) then
    return false
  end
  for V = 1, 50, 1 do
    Sleep(200)
    if not K() then
      return false
    end
    V, W, L = X()
    if W == f and L == v then
      return true
    end
  end
  return false
end
local function l(f)
  if not f or (tonumber(f["fg"]) ~= 2978 and tonumber(f["fg"]) ~= 9268) or not f["extra"] then
    return
  end
  return tonumber(f["extra"]["vend_item"]), tonumber(f["extra"]["vend_price"])
end
local function Z(f, v)
  for f in f:gmatch("[^\r\n]+") do
    local V = f:match("^embed_data|" .. (v .. "|([^|]+)")) or f:match("^" .. (v .. "|([^|]+)"))
    if V then
      return tonumber(V)
    end
  end
end
function onVariant(f)
  local v = A
  if not v or not K() or not f or f["v1"] ~= "OnDialogRequest" or type(f["v2"]) ~= "string" then
    return false
  end
  local V = f["v2"]
  if
    v["kind"] == "vend" and (
      V:find("end_dialog|vending", 1, true) and (Z(V, "tilex") == v["x"] and Z(V, "tiley") == v["y"])
    )
  then
    v["text"] = V
    return true
  end
  if v["kind"] == "drop" and (V:find("end_dialog|drop_item", 1, true) and Z(V, "itemID") == v["id"]) then
    v["text"] = V
    return true
  end
  return false
end
local function B(f, v)
  local V = X()
  if not K() or not V then
    return nil
  end
  local W = { ["kind"] = "vend", ["x"] = f, ["y"] = v }
  A = W
  if
    r(
      SendPacketRaw or sendPacketRaw,
      false,
      { ["type"] = 3, ["value"] = 32, ["px"] = f, ["py"] = v, ["x"] = V["posX"], ["y"] = V["posY"] }
    )
  then
    for f = 1, 25, 1 do
      if W["text"] or not K() then
        break
      end
      Sleep(100)
    end
  end
  A = nil
  return W["text"]
end
local function fD(f, v, V)
  local W = V >= 0
  return r(
    SendPacket or sendPacket,
    2,
    "action|dialog_return\ndialog_name|vending\ntilex|"
      .. (
        f
        .. (
          "|\ntiley|"
          .. (
            v
            .. (
              "|\nbuttonClicked|pullstock\n\nsetprice|"
              .. (
                math["abs"](V) .. ("\nchk_peritem|" .. ((W and "1" or "0") .. ("\nchk_perlock|" .. (W and "0" or "1"))))
              )
            )
          )
        )
      )
  )
end
local function vD(f, v, V)
  for W = 1, 35, 1 do
    Sleep(100)
    local L = a(f)
    if L and ((V and L > v) or (not V and L < v)) then
      return L
    end
    if not K() then
      break
    end
  end
end
local function VD(f, v, V, W)
  local L, e, S = X()
  local w = a(f)
  if not K() or e ~= V or S ~= W or not w or w < v then
    return nil
  end
  if w == v then
    return w
  end
  local E = { ["kind"] = "drop", ["id"] = f }
  A = E
  if not r(SendPacket or sendPacket, 2, "action|drop\nitemID|" .. f) then
    A = nil
    return nil
  end
  for f = 1, 25, 1 do
    if E["text"] or not K() then
      break
    end
    Sleep(100)
  end
  A = nil
  L, e, S = X()
  local U = a(f)
  if not K() or e ~= V or S ~= W or not U or U < v or U > w then
    return nil
  end
  if U < w or not E["text"] then
    return U
  end
  if
    not r(
      SendPacket or sendPacket,
      2,
      "action|dialog_return\ndialog_name|drop_item\nitemID|" .. (f .. ("|\ncount|" .. (w - v)))
    )
  then
    return nil
  end
  vD(f, w, false)
  L, e, S = X()
  U = a(f)
  if not K() or e ~= V or S ~= W or not U or U < v or U > w then
    return nil
  end
  return U
end
local function WD(f, v, V)
  local W = 0
  while K() do
    local L = I(f["activeX"], f["dropY"])
    if not L or L["collidable"] == true or tonumber(L["fg"]) == 6 then
      return false, "Drop position is unusable in the drop world. Check your bag."
    end
    Q("MOVING TO DROP TILE")
    if not z(f["activeX"], f["dropY"]) then
      Q("RETRYING PATH TO DROP TILE")
      if not K() or not z(f["activeX"], f["dropY"]) then
        return false, "Cannot reach drop tile after two attempts. Check your bag."
      end
    end
    s("RVD_active", f["activeX"] .. (", " .. f["dropY"]))
    local e = 0
    while K() and e < 2 do
      local V = a(f["id"])
      if not V or V < v then
        return false, "Inventory changed during drop. Check your bag."
      end
      if V == v then
        return true
      end
      Q("DROPPING RETRIEVED STOCK")
      local W = VD(f["id"], v, f["activeX"], f["dropY"])
      if not W then
        return false, "Drop could not be confirmed. Check your bag."
      end
      if W == v then
        return true
      end
      if W < v then
        return false, "Inventory changed during drop. Check your bag."
      end
      e = W < V and 0 or e + 1
      Sleep(350)
    end
    if not K() then
      break
    end
    if V and W >= V then
      return false, "Startup drop could not be confirmed after moving left once. Check your drop position."
    end
    local S = f["activeX"] - 1
    local w = S >= 0 and I(S, f["dropY"])
    if not w or w["collidable"] == true or tonumber(w["fg"]) == 6 then
      return false, "Drop tile full and no usable tile to its left. Check your bag."
    end
    Q("DROP TILE FULL - SHIFTING LEFT")
    f["activeX"] = S
    W = W + 1
  end
  return false, "Stopped before storing all retrieved stock. Check your bag."
end
local function LD(f, v, V)
  if not k(f["dropWorld"]) then
    return false, "Could not enter the drop world. Check your bag."
  end
  if not o() then
    d()
    return false, "Could not enable ModFly and Antibounce for the drop trip."
  end
  local W, L = WD(f, v, V)
  d()
  return W, L
end
local function eD(f, v, V)
  local W, L
  for e, S in pairs(f["tiles"]) do
    local w, E = tonumber(S["x"]), tonumber(S["y"])
    if w and (E and (not f["visited"][w .. ("," .. E)] and l(I(w, E)) == f["id"])) then
      local f = math["abs"](w - v) + math["abs"](E - V)
      if not W or f < L or (f == L and (E < W["y"] or (E == W["y"] and w < W["x"]))) then
        W, L = { ["x"] = w, ["y"] = E }, f
      end
    end
  end
  return W
end
local function SD(f)
  if not k(f["vendWorld"]) then
    return "Could not enter the vending route."
  end
  if l(I(f["vendX"], f["vendY"])) ~= f["id"] then
    return "Set the starting vend to a machine with the selected item."
  end
  local v = a(f["id"])
  if not v then
    return "Cannot read the selected item's inventory."
  end
  if v >= 200 or x() then
    if v == 0 then
      return "Backpack is full. Free a slot for the selected item first."
    end
    Q("STORING SELECTED ITEM BEFORE RETRIEVING")
    local V, W = LD(f, 0, 1)
    if not V then
      return W
    end
    if not k(f["vendWorld"]) then
      return "Could not return to the vending world."
    end
    if l(I(f["vendX"], f["vendY"])) ~= f["id"] then
      return "The starting vend changed during the startup drop."
    end
  end
  local V = N(GetTiles or getTiles)
  if type(V) ~= "table" then
    return "Cannot scan the vending world."
  end
  f["tiles"] = {}
  for v, V in pairs(V) do
    if l(V) == f["id"] and (tonumber(V["x"]) and tonumber(V["y"])) then
      f["tiles"][#f["tiles"] + 1] = { ["x"] = tonumber(V["x"]), ["y"] = tonumber(V["y"]) }
    end
  end
  local W = { ["x"] = f["vendX"], ["y"] = f["vendY"] }
  local L = 0
  while K() and W do
    local v, V = W["x"], W["y"]
    f["visited"][v .. ("," .. V)] = true
    local e, S = l(I(v, V))
    if e == f["id"] and S ~= nil then
      Q("MOVING TO VEND " .. (v .. (", " .. V)))
      if z(v, V) then
        while K() do
          e, S = l(I(v, V))
          if e ~= f["id"] or S == nil then
            break
          end
          local W = a(f["id"])
          if not W then
            return "Cannot read the selected item's inventory."
          end
          if W >= 200 then
            return "Backpack is full for the selected item. Make room first."
          end
          local w = B(v, V)
          if not K() then
            break
          end
          if not w or not w:find("add_button|pullstock|", 1, true) then
            L = L + 1
            break
          end
          local E, U = l(I(v, V))
          if E ~= f["id"] or U ~= S or not fD(v, V, S) then
            return "Vend changed or stock request failed. Check the machine."
          end
          Q("WAITING FOR RETRIEVED STOCK")
          if not vD(f["id"], W, true) then
            if K() then
              L = L + 1
            end
            break
          end
          local h, p = LD(f, W)
          if not h then
            return p
          end
          if not k(f["vendWorld"]) then
            return "Could not return to the vending world."
          end
          if l(I(v, V)) ~= f["id"] then
            break
          end
          if not z(v, V) then
            return "Could not return to the vending machine."
          end
        end
      else
        L = L + 1
      end
    end
    if K() then
      W = eD(f, v, V)
    end
  end
  if not K() then
    return "Stopped or left the world. Check your bag."
  end
  if L > 0 then
    return "Finished. " .. (L .. " vending machine(s) could not be retrieved.")
  end
  return "Finished. No matching vending stock remains."
end
local function wD(f)
  if type(f) == "table" then
    f = f["id"] or f["itemid"] or f["itemID"] or f["value"] or f["name"]
  end
  local v = math["tointeger"](tonumber(f) or tonumber(N(findItemID or (growtopia and growtopia["getItemID"]), f)) or 0)
  if v and (v > 0 and v <= 65535) then
    j = v
    return true
  end
  return false
end
local ED = e
local UD = false
local hD = 0
local pD = false
local function CD(f)
  N(growtopia and growtopia["notify"], f)
end
local function HD(f)
  local v = tostring(f or "")
  pcall(function()
    editValue("RVD_licensestatus", v)
  end)
end
local function mD(f)
  f = tostring(f or "")
  f = f:gsub("\n", "\r\n")
  f = f:gsub("([^%w%-_%.~])", function(f)
    return string["format"]("%%%02X", string["byte"](f))
  end)
  return f
end
local function cD()
  local f = ""
  if type(getDiscordID) == "function" then
    local v, V = pcall(getDiscordID)
    if v and V ~= nil then
      f = tostring(V)
    end
  elseif getDiscordID ~= nil then
    f = tostring(getDiscordID)
  end
  f = ((tostring(f or "")):gsub("^%s+", "")):gsub("%s+$", "")
  if f == "" or f == "nil" or f == "0" then
    local v = GetLocal or getLocal
    if v ~= nil then
      local V, W = pcall(v)
      if V and (W ~= nil and W["name"] ~= nil) then
        f = tostring(W["name"])
        f = (f:gsub("^%s+", "")):gsub("%s+$", "")
      end
    end
  end
  return f
end
local function JD(V, W)
  if UD then
    return false
  end
  UD = true
  local L = S(ED)
  ED = L
  if not w(L) then
    HD("INVALID KEY FORMAT")
    UD = false
    if not V then
      CD("License must be 1 letter + 7 numbers, for example A1234567.")
    end
    return false
  end
  local E = cD()
  if E == "" then
    HD("NO CLIENT ID")
    UD = false
    if not V then
      CD("Could not read a client ID. Enter the game first and try again.")
    end
    return false
  end
  HD("CHECKING...")
  local h = f .. ("?key=" .. (mD(L) .. ("&id=" .. (mD(E) .. ("&product=" .. mD(v))))))
  local p, C, H = pcall(fetch, h)
  if not p then
    HD("SERVER ERROR")
    UD = false
    if not V then
      CD("License server request failed.")
    end
    return false
  end
  if W ~= hD then
    UD = false
    return false
  end
  C = tostring(C or "")
  C = (C:gsub("^%s+", "")):gsub("%s+$", "")
  if C:find("OK|PERMANENT", 1, true) then
    HD("VERIFIED - PERMANENT")
    local f = U(L)
    if f then
      e = L
    end
    UD = false
    if not V then
      CD(f and "License verified and saved." or "License verified. Could not save the key.")
    end
    return true
  end
  local m = C
  local c = "LICENSE CHECK FAILED"
  if m:find("DENY|DISABLED", 1, true) then
    HD("DISABLED")
    c = "License disabled."
  elseif m:find("DENY|WRONG_PRODUCT", 1, true) then
    HD("WRONG PRODUCT")
    c = "This license is for another script."
  elseif m:find("DENY|BOUND_TO_OTHER_USER", 1, true) then
    HD("BOUND TO OTHER USER")
    c = "License is bound to another user."
  elseif m:find("DENY|INVALID_KEY", 1, true) then
    HD("INVALID KEY")
    c = "Invalid license key."
  elseif m:find("DENY|BAD_KEY_FORMAT", 1, true) then
    HD("BAD KEY FORMAT")
    c = "License key format is invalid."
  elseif m:find("DENY|NO_ID", 1, true) then
    HD("NO CLIENT ID")
    c = "Client ID is unavailable."
  elseif m:find("DENY|", 1, true) then
    HD("DENIED")
    c = "License denied by server."
  elseif m == "" then
    HD("NO RESPONSE")
    c = "License server gave no response."
  else
    HD("CHECK FAILED")
    c = "License check failed."
  end
  UD = false
  if not V then
    CD(c)
  end
  return false
end
local function FD(f, v, V)
  if b then
    return
  end
  if v == "RVD_start" then
    if V ~= true then
      if Y then
        G("STOPPED")
      end
      return
    end
    if Y then
      return
    end
    if q then
      G("Wait for the previous run to finish stopping.")
      return
    end
    local f = i()
    if f == "" or f == "EXIT" or not X() then
      G("Enter the vending world first.")
      return
    end
    local v = c ~= "" and c or f
    local W = y(v)
    if not W or W == "EXIT" then
      G("Enter a valid vending world or WORLD|DOORID.")
      return
    end
    local L = J ~= "" and J or W
    local e = y(L)
    if not e or e == "EXIT" then
      G("Enter a valid drop world or WORLD|DOORID.")
      return
    end
    if H < 0 or m < 0 or (e == f and not I(H, m)) then
      G("Set a drop position before starting.")
      return
    end
    if p < 0 or C < 0 then
      G("Set the starting vending position.")
      return
    end
    local S = {
      ["id"] = j,
      ["vendX"] = p,
      ["vendY"] = C,
      ["activeX"] = H,
      ["dropY"] = m,
      ["vendWorld"] = v,
      ["dropWorld"] = L,
      ["visited"] = {},
    }
    O, n, Y, q = f, nil, true, true
    runThread(function()
      local f, v = pcall(SD, S)
      q = false
      if Y then
        G(f and v or ("Retrieve error: " .. tostring(v)))
      end
    end)
  elseif v == "RVD_item" then
    wD(V)
  elseif v == "RVD_vendworld" then
    c = u(V)
    g()
  elseif v == "RVD_dropworld" then
    J = u(V)
    g()
  elseif v == "RVD_setvendworld" or v == "RVD_setdropworld" then
    local f = i()
    if f == "" or f == "EXIT" or not X() then
      return
    end
    if v == "RVD_setvendworld" then
      c = f
      s("RVD_vendworld", c)
    else
      J = f
      s("RVD_dropworld", J)
    end
    g()
  elseif v == "RVD_setvend" or v == "RVD_setdrop" then
    local f, V, W = X()
    if not V then
      return
    end
    if v == "RVD_setvend" then
      p, C = V, W
      if y(c) ~= i() then
        c = i()
        s("RVD_vendworld", c)
      end
      s("RVD_vendx", V)
      s("RVD_vendy", W)
    else
      H, m = V, W
      s("RVD_dropx", V)
      s("RVD_dropy", W)
      if y(J) ~= i() then
        J = i()
        s("RVD_dropworld", J)
      end
    end
    g()
  else
    local f = math["tointeger"](tonumber(V) or -1) or -1
    if v == "RVD_vendx" then
      p = f
    elseif v == "RVD_vendy" then
      C = f
    elseif v == "RVD_dropx" then
      H = f
    elseif v == "RVD_dropy" then
      m = f
    else
      return
    end
    g()
  end
end
local function uD()
  hD = hD + 1
  if pD then
    pD = false
    G("STOPPED")
  end
end
function onValue(f, v, V)
  if b then
    return
  end
  if v == "RVD_licensekey" then
    local f = S(V)
    if f ~= ED then
      uD()
      ED = f
      HD("NOT VERIFIED")
    end
    return
  end
  if v == "RVD_clearlicense" then
    uD()
    ED, e = "", ""
    local f = h()
    s("RVD_licensekey", "")
    HD(f and "NOT VERIFIED" or "SAVED KEY COULD NOT BE CLEARED")
    return
  end
  if v == "RVD_verifylicense" then
    local f = hD
    runThread(function()
      if f == hD then
        JD(false, f)
      end
    end)
    return
  end
  if v ~= "RVD_start" then
    return FD(f, v, V)
  end
  if V ~= true then
    uD()
    return FD(f, v, V)
  end
  if Y or pD then
    return
  end
  if q then
    return FD(f, v, V)
  end
  hD = hD + 1
  local W = hD
  pD = true
  Q("CHECKING LICENSE BEFORE START")
  runThread(function()
    local V = 0
    while W == hD and (UD and V < 30000) do
      Sleep(100)
      V = V + 100
    end
    if W ~= hD then
      return
    end
    local L = JD(false, W)
    if W ~= hD then
      return
    end
    pD = false
    if not L then
      G("LICENSE CHECK FAILED - PRESS START TO RETRY")
      return
    end
    FD(f, v, true)
  end)
end
applyHook()
if type(setOnValue) == "function" then
  pcall(setOnValue, "RVD_item", function(...)
    for f = select("#", ...), 1, -1 do
      if wD(select(f, ...)) then
        return
      end
    end
  end)
end
runThread(function()
  while true do
    local f, v, V = X()
    local W = v and (v .. (", " .. V)) or "UNKNOWN"
    if W ~= M then
      M = W
      s("RVD_current", W)
    end
    Sleep(500)
  end
end)
