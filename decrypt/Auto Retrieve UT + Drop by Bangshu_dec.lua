setMinimum("6.1.2")
local z =
  "https://script.google.com/macros/s/AKfycbxeBzpOUzvcRDkX-4eR8uioFbAUDsepIQc26kmxUkXt6YOjBxFdVsOE0zzvxYSprl5knA/exec"
local p = "UTDROP"
local d = "RetrieveTesseractDropLicense"
local x = "license_key"
local H = nil
local Y = ""
local function T(z)
  z = tostring(z or "")
  z = z:gsub("%s+", "")
  return z:upper()
end
local function y(z)
  z = T(z)
  return z:match("^[A-Z]%d%d%d%d%d%d%d$") ~= nil
end
local function W()
  local z = pcall(function()
    local z = nil
    if type(require) == "function" then
      local p, d = pcall(require, "preferences")
      if p and d ~= nil then
        z = d
      end
    end
    if z == nil and type(Preferences) == "table" then
      z = Preferences
    end
    if z == nil then
      return
    end
    if type(z["new"]) == "function" then
      local p = z:new(d)
      H = p or z
    else
      H = z
    end
    if H ~= nil and type(H["load"]) == "function" then
      H:load()
    end
    if H ~= nil and type(H["get"]) == "function" then
      Y = T(H:get(x, ""))
    end
  end)
  if not z then
    H = nil
    Y = ""
  end
end
local function D(z)
  if H == nil then
    return false
  end
  local p = pcall(function()
    H:set(x, T(z))
    H:save()
  end)
  return p
end
local function L()
  if H == nil then
    return false
  end
  local z = pcall(function()
    H:set(x, "")
    H:save()
  end)
  return z
end
W()
local V = Y
local G = 0
local M, O = false, false
local C = "Auto Retrieve Tesseract & Drop"
local N = 300
local E = {
  ["items"] = "",
  ["worlds"] = "",
  ["dropDelay"] = tostring(N),
  ["fixedDrop"] = "false",
  ["dropWorld"] = "",
  ["dropX"] = "",
  ["dropY"] = "",
}
local h, B, m = false, false, false
local k, t, X
local o = false
local e = {}
local function K(z, ...)
  if type(z) ~= "function" then
    return nil
  end
  local p, d = pcall(z, ...)
  if p then
    return d
  end
end
local function j(z, ...)
  local p, d = pcall(z, ...)
  return p and d ~= false
end
local function J(z, p)
  m = true
  K(editValue, z, tostring(p))
  m = false
end
local function a(z)
  J("UTD_status", z)
end
local function v()
  return (tostring(K(GetWorldName or getCurrentWorldName) or "")):upper()
end
local function n()
  local z = K(GetLocal or getLocal)
  if z and (tonumber(z["posX"]) and tonumber(z["posY"])) then
    return z, math["floor"](z["posX"] / 32), math["floor"](z["posY"] / 32)
  end
end
local function F()
  return h and (k == v() and n() ~= nil)
end
local function S(z)
  local p, d = z:match("^([A-Z0-9]+)|([^|]+)$")
  if p then
    return p, d
  end
  if z:match("^[A-Z0-9]+$") then
    return z
  end
end
local function b(z)
  if v() ~= z or not n() then
    return false
  end
  local p = K(GetTiles or getTiles)
  return type(p) == "table" and next(p) ~= nil
end
local function Q(z)
  for p = 1, 75, 1 do
    if not h then
      return false
    end
    if b(z) then
      Sleep(300)
      if h and b(z) then
        return true
      end
    end
    Sleep(200)
  end
  return false
end
local function i(z)
  local p, d = S(z)
  if not h or not p then
    return false
  end
  if b(p) and (not d or t == z) then
    k = p
    if not d then
      t = nil
    end
    return true
  end
  local x = SendPacket or sendPacket
  if not b(p) then
    t = nil
    a("WARPING TO " .. p)
    local z = growtopia and growtopia["warpTo"]
    local d
    if type(z) == "function" then
      d = j(z, p)
    else
      d = j(x, 3, "action|join_request\nname|" .. (p .. "\ninvitedWorld|0"))
    end
    if not d or not Q(p) then
      return false
    end
    Sleep(1000)
    if not h or not b(p) then
      return false
    end
  end
  if d then
    a("ENTERING DOOR " .. z)
    if not j(x, 3, "action|join_request\nname|" .. (z .. "\ninvitedWorld|0")) then
      return false
    end
    Sleep(1400)
    if not Q(p) then
      return false
    end
    Sleep(1000)
    if not h or not b(p) then
      return false
    end
    t = z
  end
  k = p
  return true
end
local function r(z, p)
  return K(GetTile or getTile or (tile and tile["getTile"]), z, p)
end
local function Z(z)
  local p = K(growtopia and growtopia["checkInventoryCount"], z)
  if tonumber(p) then
    return tonumber(p)
  end
  local d = K(GetInventory or getInventory)
  if type(d) ~= "table" then
    return nil
  end
  for p, d in pairs(d) do
    if tonumber(d["id"]) == z then
      return tonumber(d["amount"])
    end
  end
  return 0
end
local function u(z, p)
  for z in z:gmatch("[^\r\n]+") do
    local d = z:match("^embed_data|" .. (p .. "|([^|]+)")) or z:match("^" .. (p .. "|([^|]+)"))
    if d then
      return tonumber(d)
    end
  end
end
local function w(z)
  return ((tostring(z or "")):upper()):gsub("%s+", "")
end
local function s(z)
  local p = S(z)
  return p and (p ~= "EXIT" and p ~= "EXITWORLD")
end
local function I(z)
  local p, d = {}, {}
  for z in (tostring(z or "")):gmatch("[^,]+") do
    z = w(z)
    if z ~= "" and not d[z] then
      p[#p + 1], d[z] = z, true
    end
  end
  return p
end
local P
pcall(function()
  local z = K(require, "preferences") or Preferences
  local p = z:new("AutoRetrieveTesseractDrop")
  if p:load() == false then
    return
  end
  P = p
  for z, p in pairs(E) do
    E[z] = tostring(P:get(z, p) or p)
  end
end)
local function c()
  return pcall(function()
    for z, p in pairs(E) do
      P:set(z, p)
    end
    if P:save() == false then
      error("save")
    end
  end)
end
local function q(z)
  K(growtopia and growtopia["notify"], z)
end
local function U()
  if o then
    return true
  end
  local z = K(getValue or GetValue, 0, "ModFly")
  if z == true or z == 1 or z == "true" then
    return true
  end
  o = j(editToggle or EditToggle, "ModFly", true)
  return o
end
local function f()
  if o then
    j(editToggle or EditToggle, "ModFly", false)
  end
  o = false
end
local function l()
  for z, p in ipairs({ "Enable AutoCollect", "Autocollect", "Fast Drop" }) do
    local d = K(getValue or GetValue, 0, p)
    if d == true or d == 1 or d == "true" or d == "1" then
      if not j(editToggle or EditToggle, p, false) then
        return false
      end
      e[#e + 1] = p
    end
  end
  return true
end
local function R()
  for z, p in ipairs(e) do
    j(editToggle or EditToggle, p, true)
  end
  e = {}
end
local function A(z)
  local p = tonumber(z)
  if p and (p >= 0 and (p <= 10000 and p % 1 == 0)) then
    return p
  end
end
local g = UserInterface["new"](C, "Inventory")
g:addLabelApp(C, "Inventory")
g:addInputString("License Key", Y, "A1234567", "A1234567", nil, "UTD_licensekey")
g:addButton("Verify License", "UTD_verifylicense")
g:addButton("Clear Saved License", "UTD_clearlicense")
g:addDisplayList("License Status", "NOT VERIFIED", "UTD_licensestatus")
g:addToggle("Start / Stop", false, "UTD_start")
g:addItemPicker("Add Item to Retrieve", "Dirt", "2", "UTD_item")
g:addDisplayList("Selected Item IDs", E["items"], "UTD_selected")
g:addInputString("Item IDs (comma-separated)", E["items"], "2, 4, 6", "2, 4, 6", nil, "UTD_items")
local zL = (g:addDialog("Settings", "Tesseract worlds in collection order", {}))["menu"]
g:addChildInputString(
  zL,
  "Tesseract Worlds (comma-separated)",
  E["worlds"],
  "WORLD|DOORID",
  "FARM1, FARM2",
  nil,
  "UTD_worlds"
)
g:addChildButton(zL, "Add Current World", "UTD_here")
g:addChildButton(zL, "Remove Last World", "UTD_remove")
local pL = (g:addDialog("Drop Settings", "Wait before each drop request and confirmation", {}))["menu"]
g:addChildInputInt(pL, "Drop Delay (ms)", tostring(A(E["dropDelay"]) or N), "ms", tostring(N), nil, "UTD_dropDelay")
g:addChildToggle(pL, "Use Fixed Drop World and Position", E["fixedDrop"] == "true", "UTD_fixedDrop")
g:addChildInputString(pL, "Drop World", E["dropWorld"], "WORLD|DOORID", "STORAGE", nil, "UTD_dropWorld")
g:addChildButton(pL, "Drop World = Current World", "UTD_hereDropWorld")
g:addChildInputInt(pL, "Drop Position X", E["dropX"], "X", "", nil, "UTD_dropX")
g:addChildInputInt(pL, "Drop Position Y", E["dropY"], "Y", "", nil, "UTD_dropY")
g:addChildButton(pL, "Set Drop Position = Current Tile", "UTD_hereDrop")
g:addDisplayList("Active Drop Tile", "", "UTD_activeDrop")
g:addDisplayList("Status", "STOPPED", "UTD_status")
K(addCategory, C, "Inventory")
K(addIntoModule, g:generateJSON(), C)
local function dL(z, p)
  local d, x, H = n()
  return F() and (x == z and H == p)
end
local function xL(z, p)
  if dL(z, p) then
    return true
  end
  for d, x in ipairs({ 25, 45 }) do
    if not F() then
      return false
    end
    Sleep(450)
    if not F() then
      return false
    end
    K(FindPath or findPath, z, p)
    for d = 1, x, 1 do
      if not F() then
        return false
      end
      if dL(z, p) then
        return true
      end
      Sleep(100)
    end
  end
  return false
end
local function HL()
  local z = v()
  return z == "" or z == "EXIT" or z == "EXITWORLD" or not n()
end
local function YL(z)
  while h do
    if i(z) then
      return true
    end
    if not h then
      return false
    end
    if not HL() then
      return false
    end
    t = nil
    a("WAITING FOR RECONNECT - " .. z)
    Sleep(2500)
  end
  return false
end
function onSendPacketRaw(z)
  return h and (z ~= nil and tonumber(z["type"]) == 11)
end
function onVariant(z)
  local p = X
  if not p or not F() or not z or z["v1"] ~= "OnDialogRequest" or type(z["v2"]) ~= "string" then
    return false
  end
  local d = z["v2"]
  if not d:find(p["dialog"], 1, true) then
    return false
  end
  local x, H = u(d, "tilex"), u(d, "tiley")
  if (p["x"] and (x and p["x"] ~= x)) or (p["y"] and (H and p["y"] ~= H)) then
    return false
  end
  local Y = u(d, "itemID") or u(d, "itemid")
  if p["id"] and (Y and p["id"] ~= Y) then
    return false
  end
  p["text"] = d
  return true
end
local function TL(z, p, d, x, H)
  local Y = { ["dialog"] = z, ["x"] = p, ["y"] = d, ["id"] = H }
  X = Y
  if x() then
    for z = 1, 45, 1 do
      if Y["text"] or not F() then
        break
      end
      Sleep(100)
    end
  end
  X = nil
  return Y["text"]
end
local function yL(z)
  return (((z or "")):gsub(string["char"](96) .. ".", "")):lower()
end
local function WL(z)
  local p = K(getItemInfoByID or GetItemInfo, z)
  return p and p["name"] or K(growtopia and growtopia["getItemName"], z)
end
local function DL(z, p)
  local d = u(z, "targetitem") or u(z, "itemID") or u(z, "itemid")
  if d then
    return p[d] and d
  end
  local x, H, Y = yL(z), nil, 0
  for z, p in pairs(p) do
    if #p > Y and x:find(p:lower(), 1, true) then
      H, Y = z, #p
    end
  end
  return H
end
local function LL(z)
  local p = yL(z)
  local d = p:match("contains a total of%s+([%d,]+)")
    or p:match("contains%s+([%d,]+)")
    or p:match("currently stored:%s*([%d,]+)")
  if d then
    return tonumber((d:gsub(",", "")))
  end
  if p:find("contains no items", 1, true) or p:find("currently empty", 1, true) then
    return 0
  end
end
local function VL(z)
  local p, d = z["x"], z["y"]
  return TL("itemsucker_block", p, d, function()
    local x = n()
    return x
      and (
        dL(p, z["standY"])
        and j(
          SendPacketRaw or sendPacketRaw,
          false,
          { ["type"] = 3, ["value"] = 32, ["px"] = p, ["py"] = d, ["x"] = x["posX"], ["y"] = x["posY"] }
        )
      )
  end)
end
local function GL(z)
  local p, d = z["x"], z["y"]
  return TL("itemremovedfromsucker", p, d, function()
    return dL(p, z["standY"])
      and j(
        SendPacket or sendPacket,
        2,
        "action|dialog_return\ndialog_name|itemsucker_block\ntilex|"
          .. (p .. ("|\ntiley|" .. (d .. "|\nbuttonClicked|retrieveitem\n\nchk_enablesucking|1")))
      )
  end)
end
local function ML(z, p, d, x)
  for x = 1, x, 1 do
    if not F() then
      return nil
    end
    local H = Z(z)
    if H and ((d and H > p) or (not d and H < p)) then
      return H
    end
    Sleep(100)
  end
  if F() then
    return Z(z)
  end
end
local function OL(z, p)
  local d = K(GetTiles or getTiles)
  if type(d) ~= "table" or next(d) == nil then
    return nil, false
  end
  local x
  for d, H in pairs(d) do
    local Y, T = tonumber(H["x"]), tonumber(H["y"])
    if Y and (T and (T >= 0 and tonumber(H["fg"]) == z)) then
      local z = Y .. ("," .. T)
      if not p[z] and (not x or Y > x["x"] or (Y == x["x"] and T < x["y"])) then
        x = { ["x"] = Y, ["y"] = T, ["key"] = z }
      end
    end
  end
  return x, true
end
local function CL(z)
  local p, d = z["y"] - 1, z["y"] + 1
  local x = z["standY"] or p
  local H = x == p and d or p
  if x >= 0 and xL(z["x"], x) then
    z["standY"] = x
    return true
  end
  if F() and (H >= 0 and xL(z["x"], H)) then
    z["standY"] = H
    return true
  end
  return false
end
local function NL(z, p, d)
  local x, H = z["x"], z["y"]
  if not CL(z) then
    return F() and "unreachable" or "reconnect"
  end
  local Y = r(x, H)
  if not Y or tonumber(Y["fg"]) ~= d then
    return "unreachable"
  end
  local T = VL(z)
  if not F() then
    return "reconnect"
  end
  if not T then
    return "unreadable"
  end
  local y = DL(T, p)
  if not y then
    return "unmatched"
  end
  local W = p[y]
  local D = LL(T)
  if D == 0 then
    return "empty"
  end
  local L = Z(y)
  if not L then
    return "inventory unavailable"
  end
  local V = math["min"](200 - L, D or 200)
  if V <= 0 then
    return "full"
  end
  local G = GL(z)
  if not F() then
    return "reconnect"
  end
  if not G then
    return "unreadable"
  end
  local M = u(G, "targetitem") or u(G, "itemID") or u(G, "itemid")
  if M and M ~= y then
    return "unmatched"
  end
  local O = LL(G)
  if O then
    V = math["min"](V, O)
  end
  if V <= 0 then
    return "empty"
  end
  if not dL(x, z["standY"]) then
    return "unreachable"
  end
  a("RETRIEVING " .. (V .. (" " .. (W .. (" AT " .. z["key"])))))
  if
    not j(
      SendPacket or sendPacket,
      2,
      "action|dialog_return\ndialog_name|itemremovedfromsucker\ntilex|"
        .. (x .. ("|\ntiley|" .. (H .. ("|\nitemtoremove|" .. V))))
    )
  then
    return "withdrawal request failed"
  end
  local C = ML(y, L, true, 65)
  if not F() or C == nil then
    return "reconnect", y, L
  end
  if C > L then
    return "store", y, L
  end
  return "withdrawal unconfirmed"
end
local function EL()
  local z = n()
  return z and (z["isLeft"] == true or z["isLeft"] == 1)
end
local function hL()
  if not F() then
    return false
  end
  if not EL() then
    return true
  end
  a("RESPAWNING TO FACE RIGHT")
  if not j(SendPacket or sendPacket, 2, "action|respawn") then
    return false
  end
  Sleep(1200)
  for z = 1, 35, 1 do
    if not h or HL() then
      return false
    end
    if F() and not EL() then
      return true
    end
    Sleep(100)
  end
  return false
end
local function BL(z, p)
  if not xL(z, p) then
    return false
  end
  if not EL() then
    return true
  end
  if not hL() or not xL(z, p) then
    return false
  end
  if not EL() then
    return true
  end
  return z > 0 and (xL(z - 1, p) and (xL(z, p) and not EL()))
end
local function mL(z, p, d, x, H)
  local Y = Z(z)
  if not Y or not dL(p, d) or EL() then
    return nil
  end
  if Y <= x then
    return Y
  end
  local T = TL("drop_item", nil, nil, function()
    return dL(p, d) and (not EL() and j(SendPacket or sendPacket, 2, "action|drop\nitemID|" .. z))
  end, z)
  if not dL(p, d) then
    return nil
  end
  local y = Z(z)
  if not y or y < Y or not T then
    return y
  end
  if H > 0 then
    Sleep(H)
  end
  if not dL(p, d) or EL() then
    return nil
  end
  y = Z(z)
  if not y or y ~= Y then
    return y
  end
  if
    not j(
      SendPacket or sendPacket,
      2,
      "action|dialog_return\ndialog_name|drop_item\nitemID|" .. (z .. ("|\ncount|" .. (Y - x)))
    )
  then
    return nil
  end
  return ML(z, Y, false, 65)
end
local function kL(z, p, d, x)
  local H = z["y"]
  local Y = false
  while h do
    if not YL(z["world"]) then
      return false, "Could not enter the drop world."
    end
    local T = z["x"]
    local y = Z(p)
    if not y then
      return false, "Could not read the backpack in storage."
    end
    if y < d then
      return false, "Backpack count fell below the amount held before withdrawal."
    end
    if y == d then
      return true
    end
    if BL(T, H) then
      if x > 0 then
        Sleep(x)
      end
      if dL(T, H) then
        J("UTD_activeDrop", T .. ("," .. H))
        a("DROPPING ITEM " .. (p .. (" x" .. (y - d))))
        local W = mL(p, T, H, d, x)
        if F() then
          if W and W < d then
            return false, "Drop exceeded the retrieved amount. Check Fast Drop."
          end
          if W == d then
            Sleep(300)
            return true
          end
          if not W or not dL(T, H) then
            return false, "Drop interrupted at the storage tile. Check the backpack."
          end
          if W >= y then
            Sleep(1200)
            if F() and (dL(T, H) and (Z(p) or y) >= y) then
              if Y or T <= 0 then
                return false, "Drop still unconfirmed after shifting left once."
              end
              z["x"], Y = T - 1, true
              J("UTD_activeDrop", z["x"] .. ("," .. H))
              a("DROP UNCONFIRMED - SHIFTING LEFT")
            end
          end
        end
      end
    elseif F() then
      return false, "Cannot reach the drop tile while facing right."
    end
  end
  return false, "Stopped."
end
local function tL(z)
  local p = tonumber(K(findItemID or (growtopia and growtopia["getItemID"]), "Unstable Tesseract"))
  if not p or p < 1 then
    return "Could not resolve the Unstable Tesseract item ID."
  end
  if not l() then
    return "Could not pause launcher pickup or Fast Drop."
  end
  if not U() then
    return "Could not enable ModFly."
  end
  local d = {}
  for z, p in ipairs(z["items"]) do
    local x = WL(p)
    if not x or x == "" then
      return "Could not resolve selected item " .. (p .. ".")
    end
    d[p] = x
  end
  local x = 0
  local H
  for Y, T in ipairs(z["worlds"]) do
    local y = {}
    local W, D, L
    local V = z["fixedStorage"]
    local G = false
    while h do
      if L then
        if not V then
          V = { ["world"] = T, ["x"] = W["x"], ["y"] = W["standY"] }
        end
        local p, d = kL(V, L["item"], L["before"], z["dropDelay"])
        if not p then
          return d
        end
        L = nil
      end
      if not YL(T) then
        return "Could not enter Tesseract world " .. (T .. ".")
      end
      if not G then
        if not hL() then
          return "Could not face right in " .. (T .. ".")
        end
        G = true
      end
      if not H then
        H = {}
        local p = {}
        for z, d in ipairs(z["items"]) do
          local x = Z(d)
          if x == nil then
            return "Could not read selected items in the backpack."
          end
          if x > 0 and not p[d] then
            H[#H + 1] = d
            p[d] = true
          end
        end
      end
      if D then
        Sleep(1200)
        if F() then
          local z = Z(D["item"])
          if not z then
            return "Could not reconcile the backpack after reconnecting."
          end
          if z > D["before"] then
            L = D
          end
          D = nil
        end
      end
      if F() and (not L and not D) then
        if not W then
          local z
          W, z = OL(p, y)
          if not z then
            return "Could not scan Tesseracts in " .. (T .. ".")
          end
          if not W then
            break
          end
        end
        if #H > 0 then
          if not V and CL(W) then
            V = { ["world"] = T, ["x"] = W["x"], ["y"] = W["standY"] }
          end
          if V then
            for p, d in ipairs(H) do
              a("DROPPING CARRIED ITEM " .. (d .. " BEFORE RETRIEVAL"))
              local x, H = kL(V, d, 0, z["dropDelay"])
              if not x then
                return H
              end
            end
            H = {}
          elseif F() then
            y[W["key"]] = true
            W = nil
            x = x + 1
          end
        else
          a("CHECKING TESSERACT " .. (T .. (" " .. W["key"])))
          local z, H, Y = NL(W, d, p)
          if z == "store" then
            L = { ["item"] = H, ["before"] = Y }
          elseif z == "reconnect" then
            if H then
              D = { ["item"] = H, ["before"] = Y }
            end
          elseif z == "empty" or z == "unmatched" or z == "unreachable" or z == "unreadable" or z == "full" then
            y[W["key"]] = true
            W = nil
            if z == "unreachable" or z == "unreadable" or z == "full" then
              x = x + 1
            end
          else
            return z .. (" at " .. (T .. (" " .. (W["key"] .. ". Check the backpack and Tesseract."))))
          end
        end
      end
    end
    if not h then
      return "STOPPED"
    end
  end
  if H and #H > 0 then
    return "No reachable Tesseract for dropping carried items."
  end
  if x > 0 then
    return "Finished. " .. (x .. " Tesseract check(s) could not be completed.")
  end
  return "Finished all selected items and worlds."
end
local function XL(z)
  m = true
  K(editToggle or EditToggle, "UTD_start", z)
  m = false
end
local function oL()
  local z = { ["items"] = {}, ["worlds"] = I(E["worlds"]), ["dropDelay"] = A(E["dropDelay"]) or N }
  for p, d in ipairs(I(E["items"])) do
    local x = tonumber(d)
    if not x or x < 1 or x > 65535 or x % 1 ~= 0 then
      return nil, "Enter valid item IDs."
    end
    z["items"][#z["items"] + 1] = x
  end
  if #z["items"] == 0 then
    return nil, "Add at least one item."
  end
  if #z["worlds"] == 0 then
    return nil, "Add at least one Tesseract world."
  end
  for z, p in ipairs(z["worlds"]) do
    if not s(p) then
      return nil, "Invalid world route: " .. p
    end
  end
  if E["fixedDrop"] == "true" then
    local p = w(E["dropWorld"])
    local d, x = tonumber(E["dropX"]), tonumber(E["dropY"])
    if not s(p) or not d or not x or d < 0 or x < 0 or d % 1 ~= 0 or x % 1 ~= 0 then
      return nil, "Set the fixed drop world and position under Drop Settings."
    end
    z["fixedStorage"] = { ["world"] = p, ["x"] = d, ["y"] = x }
  end
  return z
end
local function eL(z)
  if type(z) == "table" then
    z = z["id"] or z["itemID"] or z["value"] or z["name"]
  end
  local p = tonumber(z)
  if not p and type(z) == "string" then
    p = tonumber(z:match("%((%d+)%)")) or tonumber(K(findItemID or (growtopia and growtopia["getItemID"]), z))
  end
  if not p or p < 1 or p > 65535 or p % 1 ~= 0 then
    return false
  end
  local d = I(E["items"])
  for z, d in ipairs(d) do
    if tonumber(d) == p then
      return true
    end
  end
  d[#d + 1] = tostring(p)
  E["items"] = table["concat"](d, ", ")
  J("UTD_items", E["items"])
  J("UTD_selected", E["items"])
  c()
  return true
end
local function KL(z)
  local p = tostring(z or "")
  pcall(function()
    editValue("UTD_licensestatus", p)
  end)
end
local function jL(z)
  z = tostring(z or "")
  z = z:gsub("\n", "\r\n")
  z = z:gsub("([^%w%-_%.~])", function(z)
    return string["format"]("%%%02X", string["byte"](z))
  end)
  return z
end
local function JL()
  local z = ""
  if type(getDiscordID) == "function" then
    local p, d = pcall(getDiscordID)
    if p and d ~= nil then
      z = tostring(d)
    end
  elseif getDiscordID ~= nil then
    z = tostring(getDiscordID)
  end
  z = ((tostring(z or "")):gsub("^%s+", "")):gsub("%s+$", "")
  if z == "" or z == "nil" or z == "0" then
    local p = GetLocal or getLocal
    if p ~= nil then
      local d, x = pcall(p)
      if d and (x ~= nil and x["name"] ~= nil) then
        z = tostring(x["name"])
        z = (z:gsub("^%s+", "")):gsub("%s+$", "")
      end
    end
  end
  return z
end
local function aL(d, x)
  if O then
    return false
  end
  O = true
  local H = T(V)
  V = H
  if not y(H) then
    KL("INVALID KEY FORMAT")
    O = false
    if not d then
      q("License must be 1 letter + 7 numbers, for example A1234567.")
    end
    return false
  end
  local W = JL()
  if W == "" then
    KL("NO CLIENT ID")
    O = false
    if not d then
      q("Could not read a client ID. Enter the game first and try again.")
    end
    return false
  end
  KL("CHECKING...")
  local L = z .. ("?key=" .. (jL(H) .. ("&id=" .. (jL(W) .. ("&product=" .. jL(p))))))
  local M, C, N = pcall(fetch, L)
  if not M then
    KL("SERVER ERROR")
    O = false
    if not d then
      q("License server request failed.")
    end
    return false
  end
  if x ~= G then
    O = false
    return false
  end
  C = tostring(C or "")
  C = (C:gsub("^%s+", "")):gsub("%s+$", "")
  if C:find("OK|PERMANENT", 1, true) then
    KL("VERIFIED - PERMANENT")
    local z = D(H)
    if z then
      Y = H
    end
    O = false
    if not d then
      q(z and "License verified and saved." or "License verified. Could not save the key.")
    end
    return true
  end
  local E = C
  local h = "LICENSE CHECK FAILED"
  if E:find("DENY|DISABLED", 1, true) then
    KL("DISABLED")
    h = "License disabled."
  elseif E:find("DENY|WRONG_PRODUCT", 1, true) then
    KL("WRONG PRODUCT")
    h = "This license is for another script."
  elseif E:find("DENY|BOUND_TO_OTHER_USER", 1, true) then
    KL("BOUND TO OTHER USER")
    h = "License is bound to another user."
  elseif E:find("DENY|INVALID_KEY", 1, true) then
    KL("INVALID KEY")
    h = "Invalid license key."
  elseif E:find("DENY|BAD_KEY_FORMAT", 1, true) then
    KL("BAD KEY FORMAT")
    h = "License key format is invalid."
  elseif E:find("DENY|NO_ID", 1, true) then
    KL("NO CLIENT ID")
    h = "Client ID is unavailable."
  elseif E:find("DENY|", 1, true) then
    KL("DENIED")
    h = "License denied by server."
  elseif E == "" then
    KL("NO RESPONSE")
    h = "License server gave no response."
  else
    KL("CHECK FAILED")
    h = "License check failed."
  end
  O = false
  if not d then
    q(h)
  end
  return false
end
local function vL(z, p, d)
  if m then
    return
  end
  if p == "UTD_start" then
    if d ~= true then
      h = false
      a("STOPPED")
      return
    end
    if h then
      return
    end
    if B then
      XL(false)
      q("Wait for the previous run to stop.")
      return
    end
    local z, p = oL()
    if not z then
      XL(false)
      q(p)
      return
    end
    h, B, k, t = true, true, nil, nil
    J("UTD_activeDrop", "")
    runThread(function()
      local p, d = pcall(tL, z)
      local x = not h
      h, X = false, nil
      f()
      R()
      B = false
      XL(false)
      local H = x and "STOPPED" or (p and d or "Stopped: " .. tostring(d))
      a(H)
      q(H)
    end)
    return
  end
  if p == "UTD_item" then
    eL(d)
    return
  end
  local x = p and p:match("^UTD_(.+)$")
  if x == "here" or x == "remove" then
    local z = I(E["worlds"])
    if x == "here" then
      if not s(v()) or not n() then
        q("Enter a world first.")
        return
      end
      z[#z + 1] = v()
      z = I(table["concat"](z, ","))
    else
      table["remove"](z)
    end
    x, d = "worlds", table["concat"](z, ", ")
    J("UTD_worlds", d)
  end
  if x == "hereDropWorld" then
    if not s(v()) or not n() then
      q("Enter the drop world first.")
      return
    end
    x, d = "dropWorld", v()
    J("UTD_dropWorld", d)
  elseif x == "hereDrop" then
    local z, p, d = n()
    if not p then
      return
    end
    E["dropX"], E["dropY"] = tostring(p), tostring(d)
    J("UTD_dropX", p)
    J("UTD_dropY", d)
    c()
    return
  end
  if x == "dropDelay" then
    local z = A(d)
    if not z then
      J("UTD_dropDelay", A(E["dropDelay"]) or N)
      return
    end
    d = z
  end
  if x and E[x] ~= nil then
    E[x] = tostring(d or "")
    if x == "items" then
      J("UTD_selected", E["items"])
    end
    c()
  end
end
local function nL()
  G = G + 1
  if M then
    M = false
    XL(false)
    a("STOPPED")
  end
end
function onValue(z, p, d)
  if m then
    return
  end
  if p == "UTD_licensekey" then
    local z = T(d)
    if z ~= V then
      nL()
      V = z
      KL("NOT VERIFIED")
    end
    return
  end
  if p == "UTD_clearlicense" then
    nL()
    V, Y = "", ""
    local z = L()
    J("UTD_licensekey", "")
    KL(z and "NOT VERIFIED" or "SAVED KEY COULD NOT BE CLEARED")
    return
  end
  if p == "UTD_verifylicense" then
    local z = G
    runThread(function()
      if z == G then
        aL(false, z)
      end
    end)
    return
  end
  if p ~= "UTD_start" then
    return vL(z, p, d)
  end
  if d ~= true then
    nL()
    return vL(z, p, d)
  end
  if h or M then
    return
  end
  if B then
    return vL(z, p, d)
  end
  G = G + 1
  local x = G
  M = true
  a("CHECKING LICENSE BEFORE START")
  runThread(function()
    local d = 0
    while x == G and (O and d < 30000) do
      Sleep(100)
      d = d + 100
    end
    if x ~= G then
      return
    end
    local H = aL(false, x)
    if x ~= G then
      return
    end
    M = false
    if not H then
      XL(false)
      a("LICENSE CHECK FAILED - PRESS START TO RETRY")
      return
    end
    vL(z, p, true)
  end)
end
applyHook()
if type(setOnValue) == "function" then
  for z, p in ipairs({ "UTD_items", "UTD_worlds", "UTD_dropDelay", "UTD_dropWorld", "UTD_dropX", "UTD_dropY" }) do
    local d = p
    pcall(setOnValue, d, function(...)
      local z = select("#", ...)
      if z > 0 then
        onValue(nil, d, select(z, ...))
      end
    end)
  end
  pcall(setOnValue, "UTD_item", function(...)
    for z = select("#", ...), 1, -1 do
      if eL(select(z, ...)) then
        return
      end
    end
  end)
end
