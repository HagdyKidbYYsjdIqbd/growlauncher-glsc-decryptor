setMinimum("6.1.2")
local I = "Premium Auto buy vend by Bangshu"
do
  local E =
    "https://script.google.com/macros/s/AKfycbxWY0ROC3V1HOTJuRPfovwsN8CfTkXrcFF6VvhlS0EQRfWleUWVHZNUSW1M2UcVesSC/exec"
  local O = "AUTOVEND"
  local b = "AUTOVEND-2.2-PAID-001"
  local k = "approval"
  local Z = "%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x"
  local function Y()
    local I, E = pcall(function()
      if type(getDiscordID) == "function" then
        return getDiscordID()
      end
      return getDiscordID
    end)
    if not I then
      return nil
    end
    if type(E) == "number" and (math["type"] and math["type"](E) == "integer") then
      E = tostring(E)
    end
    if type(E) ~= "string" or #E < 17 or #E > 20 or not E:match("^%d+$") then
      return nil
    end
    if E:match("^0+$") then
      return nil
    end
    return E
  end
  local function m(I, E)
    if not E or type(I) ~= "string" or #I > 512 then
      return false
    end
    local k, Y, m = I:match(
      '^%s*{"status":"APPROVED","approval":{"discordId":"(%d+)","product":"([A-Z]+)","version":"([%w._-]+)","receiptId":"'
        .. (Z .. '"}}%s*$')
    )
    return k == E and (Y == O and m == b)
  end
  local u, F, D = pcall(function()
    local I, E = pcall(require, "preferences")
    local O = I and (type(E) == "table" and E) or Preferences
    if type(O) ~= "table" or type(O["new"]) ~= "function" then
      return nil
    end
    local b = O:new("BangshuPremiumAutoVend")
    if b:load() == false then
      return b
    end
    return b, b:get(k, "")
  end)
  if not u then
    F = nil
  end
  if not m(D, Y()) then
    local Z, u = false, false
    local function D(I)
      pcall(editValue, "AVD_premium_status", I)
      if type(sendNotification) == "function" then
        pcall(sendNotification, I)
      elseif growtopia and type(growtopia["notify"]) == "function" then
        pcall(growtopia["notify"], I)
      end
    end
    local function K()
      if Z or u then
        return
      end
      local I = Y()
      if not I then
        D("DENIED - DISCORD ID UNAVAILABLE")
        return
      end
      if not F then
        D("DENIED - PREFERENCES UNAVAILABLE")
        return
      end
      Z = true
      D("CHECKING - BUILD 04")
      local K = pcall(runThread, function()
        local Y = E
          .. (
            "?action=verifyPaidAccess&discordId=" .. (
              I .. ("&product=" .. (O .. ("&format=growlauncher&version=" .. b)))
            )
          )
        local K, z = pcall(fetch, Y)
        if K and type(z) == "string" then
          local I = z:match("BANGSHU_PREMIUM_V1_BEGIN_([0-9a-f]+)_BANGSHU_PREMIUM_V1_END")
          if I and (#I <= 1024 and #I % 2 == 0) then
            z = I:gsub("..", function(I)
              return string["char"](tonumber(I, 16))
            end)
          end
        end
        if not K or type(z) ~= "string" then
          D("DENIED - REQUEST FAILED")
        elseif not m(z, I) then
          if z:match('^%s*{"status":"DENIED",') then
            D("DENIED - NO PREMIUM ACCESS")
          elseif z:match('^%s*{"status":"ERROR",') then
            D("DENIED - APPS SCRIPT SERVER ERROR")
          elseif z:match("^%s*<") then
            if z:find("doGet", 1, true) then
              D("DENIED - DEPLOYED APP MISSING GET HANDLER")
            else
              D("DENIED - GOOGLE RETURNED HTML")
            end
          elseif z:match("^%s*$") then
            D("DENIED - EMPTY SERVER RESPONSE")
          elseif z:match('^%s*{"status":"APPROVED",') then
            D("DENIED - APPROVAL DETAILS DO NOT MATCH")
          else
            D("DENIED - UNEXPECTED SERVER RESPONSE")
          end
        else
          local E, O = pcall(function()
            if F:set(k, z) == false then
              return false
            end
            if F:save() == false then
              return false
            end
            if F:load() == false then
              return false
            end
            return m(F:get(k, ""), I)
          end)
          u = E and O == true
          D(u and "APPROVED - RELOAD SCRIPT" or "DENIED - COULD NOT SAVE APPROVAL")
        end
        Z = false
      end)
      if not K then
        Z = false
        D("DENIED - COULD NOT START CHECK")
      end
    end
    function OnValue(I, E)
      if E == "AVD_premium_verify" then
        K()
      end
    end
    onValue = OnValue
    local z = UserInterface["new"](I, "ShoppingCart")
    z:addButton("Verify Access", "AVD_premium_verify")
    z:addInputString("Verification Status", "NOT VERIFIED", "", "", nil, "AVD_premium_status")
    if type(addCategory) == "function" then
      pcall(addCategory, I, "ShoppingCart")
    end
    addIntoModule(z:generateJSON(), I)
    if type(applyHook) == "function" then
      pcall(applyHook)
    end
    if type(setOnValue) == "function" then
      pcall(setOnValue, "AVD_premium_verify", K)
    end
    return
  end
end
local E = "AutoVendSettingsV31"
local O = "31"
local b = {
  ["itemid"] = "5706",
  ["totalbuyamount"] = "200",
  ["progressitem"] = "0",
  ["totalbought"] = "0",
  ["buyworld"] = "",
  ["dropworld"] = "",
  ["vendx"] = "0",
  ["vendy"] = "0",
  ["dropx"] = "0",
  ["dropy"] = "0",
  ["activedropx"] = "0",
  ["lockedprice"] = "",
  ["price_mode"] = "",
}
local k = {
  "itemid",
  "totalbuyamount",
  "progressitem",
  "totalbought",
  "buyworld",
  "dropworld",
  "vendx",
  "vendy",
  "dropx",
  "dropy",
  "activedropx",
  "lockedprice",
  "price_mode",
}
local Z = nil
local Y = {}
local m = false
for I, E in pairs(b) do
  Y[I] = E
end
local function u()
  local I = pcall(function()
    local I = nil
    if type(require) == "function" then
      local E, O = pcall(require, "preferences")
      if E and type(O) == "table" then
        I = O
      end
    end
    if I == nil and type(Preferences) == "table" then
      I = Preferences
    end
    if I == nil or type(I["new"]) ~= "function" then
      return
    end
    local u = I:new(E)
    if
      u == nil
      or type(u["load"]) ~= "function"
      or type(u["get"]) ~= "function"
      or type(u["set"]) ~= "function"
      or type(u["save"]) ~= "function"
    then
      return
    end
    if u:load() == false then
      return
    end
    Z = u
    if tostring(u:get("schema", "")) == O then
      for I, E in ipairs(k) do
        Y[E] = tostring(u:get(E, b[E]))
      end
      m = true
    end
  end)
  if not I then
    Z = nil
  end
end
u()
local function F(I, E, O, b)
  local k = math["floor"](tonumber(Y[I]) or E)
  return math["min"](b, math["max"](O, k))
end
local function D(I)
  return ((tostring(Y[I] or "")):upper()):gsub("%s+", "")
end
local K = UserInterface["new"](I, "ShoppingCart")
K:addLabelApp(I, "ShoppingCart")
K:addToggle("Start / Stop", false, "AVD_enable")
K:addInputString(
  "Buy Progress (view only)",
  "0 / " .. tostring(Y["totalbuyamount"]),
  "Bought / total target",
  "0 / 1000",
  nil,
  "AVD_totalbought"
)
K:addInputString(
  "Remaining to Buy (view only)",
  tostring(Y["totalbuyamount"]),
  "Items left",
  "1000",
  nil,
  "AVD_totalremaining"
)
K:addItemPicker("Pick Target Item", Y["itemid"], Y["itemid"], "AVD_itempicker")
K:addInputInt("Item ID", Y["itemid"], "ID", "5706", nil, "AVD_itemid")
K:addDisplayList("Selected Item", Y["itemid"], "AVD_selecteditem")
local z = tonumber(Y["lockedprice"])
local s = Y["price_mode"] == "WL_PER_ITEM" or (Y["price_mode"] == "" and (z ~= nil and z > 0))
K:addToggle("WL per Item", s, "AVD_priceperitem", false)
K:addInputString(
  "Item Price",
  z and tostring(math["abs"](z)) or "",
  "Enter a positive whole number",
  "7",
  nil,
  "AVD_itemprice"
)
K:addInputInt("Total Buy Amount", Y["totalbuyamount"], "items total", "1000", nil, "AVD_totalbuyamount")
local W = (K:addDialog("Buy World Settings", "Worlds are visited in the order listed", {}))["menu"]
K:addChildInputString(
  W,
  "Buy Worlds",
  Y["buyworld"],
  "Separate worlds with commas",
  "WORLD1, WORLD2|DOORID",
  nil,
  "AVD_buyworld"
)
K:addChildButton(W, "Add Current World", "AVD_setbuyworld")
K:addChildButton(W, "Clear World List", "AVD_clearbuyworlds")
local C = (K:addDialog("Drop World Settings", "Set the drop world and storage tile", {}))["menu"]
K:addChildInputString(
  C,
  "Drop World",
  Y["dropworld"],
  "WORLD|DOORID",
  "DROP WORLD or WORLD|DOORID",
  nil,
  "AVD_dropworld"
)
K:addChildButton(C, "Set Drop World = Current World", "AVD_setdropworld")
K:addChildInputInt(C, "Drop Stand Position X", Y["dropx"], "X", "0", nil, "AVD_dropx")
K:addChildInputInt(C, "Drop Stand Position Y", Y["dropy"], "Y", "0", nil, "AVD_dropy")
K:addChildButton(C, "Set Drop Position = Current Tile", "AVD_setdrop")
K:addDisplayList("Selected Vending", "0, 0", "AVD_vendpos")
K:addDisplayList(
  "Vending Price",
  z and (math["abs"](z) .. (s and " WL/item" or " items/WL")) or "NONE",
  "AVD_vendprice"
)
K:addDisplayList("Current Drop Tile", Y["activedropx"] .. (", " .. Y["dropy"]), "AVD_activedrop")
K:addDisplayList("ModFly (Session)", "OFF", "AVD_travelfly")
K:addDisplayList("Settings AutoSave", Z == nil and "UNAVAILABLE" or (m and "RESTORED" or "READY"), "AVD_autosave")
K:addDisplayList("Status", "STOPPED", "AVD_status")
K:addDisplayList("Item Inventory", "0 / 200", "AVD_inventory")
pcall(function()
  if type(addCategory) == "function" then
    addCategory(I, "ShoppingCart")
  end
end)
local B = K:generateJSON()
local w = pcall(function()
  addIntoModule(B, I)
end)
if not w then
  pcall(function()
    growtopia["notify"](I .. " menu could not be created on this Growlauncher build.")
  end)
end
local o = false
local d = false
local M = false
local S = 0
local V = F("itemid", 5706, 1, 65535)
local n = F("totalbuyamount", 200, 1, 999999)
local h = F("progressitem", 0, 0, 65535)
local i = F("totalbought", 0, 0, 999999)
local U = tostring(Y["buyworld"] or "")
local G, p = {}, 1
local X = D("dropworld")
local f = F("vendx", 0, 0, 199)
local y = F("vendy", 0, 0, 119)
local T = F("dropx", 0, 0, 199)
local L = F("dropy", 0, 0, 119)
local J = F("activedropx", T, 0, 199)
local x = 0
local v = false
local a = tonumber(Y["lockedprice"])
local r = nil
local P = false
local c = {}
local q = false
local R = ""
local function A()
  if Z == nil then
    pcall(function()
      editValue("AVD_autosave", "UNAVAILABLE")
    end)
    return false
  end
  local I = {
    ["itemid"] = tostring(V),
    ["totalbuyamount"] = tostring(n),
    ["progressitem"] = tostring(h),
    ["totalbought"] = tostring(i),
    ["buyworld"] = tostring(U),
    ["dropworld"] = tostring(X),
    ["vendx"] = tostring(f),
    ["vendy"] = tostring(y),
    ["dropx"] = tostring(T),
    ["dropy"] = tostring(L),
    ["activedropx"] = tostring(J),
    ["lockedprice"] = a and tostring(a) or "",
    ["price_mode"] = s and "WL_PER_ITEM" or "ITEMS_PER_WL",
  }
  local E = false
  for O, b in ipairs(k) do
    if Y[b] ~= I[b] then
      E = true
      break
    end
  end
  if not E and m then
    return true
  end
  local b = pcall(function()
    if Z:set("schema", O) == false then
      error("schema")
    end
    for E, O in ipairs(k) do
      if Z:set(O, I[O]) == false then
        error("setting: " .. O)
      end
    end
    if Z:save() == false then
      error("save")
    end
  end)
  if b then
    for I, E in pairs(I) do
      Y[I] = E
    end
    m = true
  end
  pcall(function()
    editValue("AVD_autosave", b and "SAVED" or "SAVE FAILED")
  end)
  return b
end
local Q = {}
local function N(I, E)
  if Q[I] then
    return
  end
  Q[I] = true
  pcall(function()
    editValue(I, tostring(E))
  end)
  Q[I] = nil
end
local function t(I, E)
  return tostring(I) .. ("," .. tostring(E))
end
local e = 200
local l = 15000
local g = 15000
local j = 4200
local H = 3000
local IM = 300
local EM = 500
local OM = 650
local bM = 1000
local kM = 900
local ZM = 1200
local YM = 12000
local mM = 5
local uM = false
local FM = 1500
local DM = 7
local KM = "STOPPED"
local zM = true
local sM = false
local WM = false
local CM = ""
local BM = 2500
local wM = false
local oM = false
local dM = 2500
local function MM(I)
  pcall(function()
    growtopia["notify"](tostring(I))
  end)
end
local function SM(I)
  I = tostring(I)
  if KM ~= I then
    KM = I
    editValue("AVD_status", I)
  end
end
local function VM(I)
  I = tostring(I or "")
  I = I:gsub("%s+", "")
  return I:upper()
end
local function nM()
  local I, E = pcall(function()
    if type(GetWorldName) == "function" then
      return GetWorldName()
    end
    if type(getCurrentWorldName) == "function" then
      return getCurrentWorldName()
    end
    return ""
  end)
  if not I then
    return ""
  end
  return VM(E)
end
local function hM()
  local I, E = pcall(function()
    return GetLocal()
  end)
  if I and E ~= nil then
    return E
  end
  I, E = pcall(function()
    return getLocal()
  end)
  if I then
    return E
  end
  return nil
end
local function iM(I)
  local E, O = pcall(function()
    if growtopia ~= nil and type(growtopia["checkInventoryCount"]) == "function" then
      return growtopia["checkInventoryCount"](I)
    end
    local E = 0
    local O = nil
    if type(GetInventory) == "function" then
      O = GetInventory()
    elseif type(getInventory) == "function" then
      O = getInventory()
    end
    if O ~= nil then
      for O, b in pairs(O) do
        if tonumber(b["id"]) == tonumber(I) then
          E = tonumber(b["amount"]) or 0
          break
        end
      end
    end
    return E
  end)
  if not E then
    return 0
  end
  return tonumber(O) or 0
end
local function UM(I)
  local E, O = pcall(function()
    if growtopia ~= nil and type(growtopia["getItemName"]) == "function" then
      return growtopia["getItemName"](I)
    end
    if type(getItemInfoByID) == "function" then
      local E = getItemInfoByID(I)
      if E ~= nil then
        return E["name"]
      end
    end
    return nil
  end)
  if E and (O ~= nil and tostring(O) ~= "") then
    return tostring(O)
  end
  return "Item " .. tostring(I)
end
local function GM()
  editValue("AVD_selecteditem", UM(V) .. (" (" .. (tostring(V) .. ")")))
end
local function pM()
  editValue("AVD_inventory", tostring(iM(V)) .. " / 200")
end
local XM = nil
local function fM()
  local I = h == V and i or 0
  local E = math["max"](1, math["floor"](tonumber(n) or 1))
  local O = math["max"](0, E - I)
  local b = math["min"](100, math["floor"]((I * 100) / E))
  local k = tostring(I) .. (" / " .. (tostring(E) .. (" (" .. (tostring(b) .. "%)"))))
  if k ~= XM then
    XM = k
    N("AVD_totalbought", k)
    N("AVD_totalremaining", tostring(O))
  end
end
local function yM()
  editValue("AVD_vendpos", tostring(f) .. (", " .. tostring(y)))
end
local TM = nil
local function LM(I)
  I = I == true
  if TM == I then
    return true
  end
  local E = editToggle or EditToggle
  if type(E) ~= "function" then
    pcall(function()
      editValue("AVD_travelfly", "UNAVAILABLE")
    end)
    return false
  end
  local O, b = pcall(E, "ModFly", I)
  if not O or b == false then
    pcall(function()
      editValue("AVD_travelfly", "ERROR")
    end)
    return false
  end
  TM = I
  pcall(function()
    editValue("AVD_travelfly", I and "ON (SESSION)" or "OFF")
  end)
  if I then
    Sleep(250)
  end
  return true
end
local function JM(I)
  M = false
  o = false
  LM(false)
  wM = false
  oM = false
  sM = false
  WM = false
  CM = ""
  pcall(function()
    EditToggle("AVD_enable", false)
  end)
  pcall(function()
    editToggle("AVD_enable", false)
  end)
  SM("STOPPED")
  if I ~= nil and I ~= "" then
    MM(I)
  end
end
local function xM(I)
  I = VM(I)
  local E, O = I:match("^([^|]+)|([^|]+)$")
  if E ~= nil then
    return E, O
  end
  if I:find("|", 1, true) then
    return "", nil
  end
  return I, nil
end
local function vM(I)
  local E, O = {}, {}
  for I in I:gmatch("[^,]+") do
    local b = VM(I)
    if b ~= "" then
      local I, k = xM(b)
      if not I:match("^[A-Z0-9]+$") or (k and not k:match("^[A-Z0-9_%-]+$")) then
        return nil
      end
      if not O[b] then
        E[#E + 1] = b
        O[b] = true
      end
    end
  end
  return E
end
local function aM(I)
  local E = xM(I)
  if E == "" or nM() ~= E then
    return false
  end
  local O = hM()
  if O == nil then
    return false
  end
  local b, k = pcall(function()
    if type(GetTiles) == "function" then
      return GetTiles()
    end
    return getTiles()
  end)
  return b and (k ~= nil and #k > 0)
end
local function rM(I, E)
  local O = 0
  while o and O < E do
    if aM(I) then
      Sleep(300)
      return o and aM(I)
    end
    Sleep(100)
    O = O + 100
  end
  return false
end
local PM = ""
local function cM(I, E)
  E = (E == "STORAGE") and "STORAGE" or "BUY"
  I = VM(I)
  local O, b = xM(I)
  if O == "" then
    SM(E .. " INVALID WORLD OR DOOR ID")
    return false
  end
  local k = b ~= nil and b ~= ""
  if not k and aM(O) then
    PM = ""
    uM = false
    return true
  end
  if k and (aM(O) and PM == I) then
    uM = false
    return true
  end
  if not aM(O) then
    SM(E .. (" WARP BASE " .. O))
    PM = ""
    local I, b = pcall(function()
      return growtopia["warpTo"](O)
    end)
    if not I or b == false then
      return false
    end
    if not rM(O, l) then
      return false
    end
    Sleep(bM)
    if not o or not aM(O) then
      return false
    end
  end
  if k then
    SM(E .. (" ENTER DOOR " .. (O .. ("|" .. b))))
    local k, Z = pcall(function()
      return SendPacket(3, "action|join_request\nname|" .. (I .. "\ninvitedWorld|0"))
    end)
    if not k or Z == false then
      return false
    end
    Sleep(1400)
    if not rM(O, l) then
      return false
    end
    Sleep(bM)
    if not o or not aM(O) then
      return false
    end
    PM = I
    SM(E .. (" DOOR REQUEST SETTLED " .. (O .. ("|" .. b))))
  else
    PM = ""
  end
  uM = true
  return true
end
local function qM()
  local I = hM()
  if I == nil then
    return nil, nil
  end
  return I["posX"] // 32, I["posY"] // 32
end
local function RM(I, E)
  local O, b = qM()
  return O == I and b == E
end
local function AM(I, E)
  if RM(I, E) then
    uM = false
    Sleep(150)
    return true
  end
  local O = uM
  uM = false
  local b = 0
  local k = 0
  local Z = 0
  while o and k < g do
    if RM(I, E) then
      Sleep(150)
      return true
    end
    if b < DM and k >= Z then
      b = b + 1
      SM("PATH " .. (tostring(b) .. ("/" .. (tostring(DM) .. (" -> " .. (tostring(I) .. ("," .. tostring(E))))))))
      pcall(function()
        FindPath(I, E)
      end)
      if O and b == 1 then
        Z = k + kM
      else
        Z = k + FM
      end
    end
    Sleep(100)
    k = k + 100
  end
  return RM(I, E)
end
local function QM(I, E)
  local O, b = pcall(function()
    if type(getTile) == "function" then
      return getTile(I, E)
    end
    return GetTile(I, E)
  end)
  if O then
    return b
  end
  return nil
end
local function NM(I, E)
  local O, b = qM()
  if O == nil or b == nil then
    return nil, "Player position is not available."
  end
  I = I or 4
  E = E or 2
  local k = {}
  for E = b - E, b + E, 1 do
    for I = O - I, O + I, 1 do
      local Z = QM(I, E)
      if Z ~= nil and (Z["fg"] == 2978 or Z["fg"] == 9268) then
        local Y = Z["extra"]
        local m = Y and tonumber(Y["vend_item"] or 0) or 0
        if m == V then
          local Z = tonumber(Y["vend_price"] or 0) or 0
          local m = math["abs"](O - I) + math["abs"](b - E)
          table["insert"](k, { ["x"] = I, ["y"] = E, ["price"] = Z, ["distance"] = m })
        end
      end
    end
  end
  if #k == 0 then
    return nil, "No nearby vending sells " .. (UM(V) .. (" (" .. (tostring(V) .. ").")))
  end
  table["sort"](k, function(I, E)
    if I["distance"] == E["distance"] then
      if I["y"] == E["y"] then
        return I["x"] < E["x"]
      end
      return I["y"] < E["y"]
    end
    return I["distance"] < E["distance"]
  end)
  return k[1], nil
end
local function tM(I)
  if type(I) ~= "string" or I == "" then
    return nil
  end
  local E, O = pcall(function()
    if type(findItemID) == "function" then
      return findItemID(I)
    end
    if growtopia ~= nil and type(growtopia["getItemID"]) == "function" then
      return growtopia["getItemID"](I)
    end
    return nil
  end)
  if E and (tonumber(O) ~= nil and tonumber(O) > 0) then
    return math["floor"](tonumber(O))
  end
  return nil
end
local function eM(I)
  if type(I) == "number" then
    return math["floor"](I)
  end
  if type(I) == "string" then
    local E = tonumber(I)
    if E ~= nil and E > 0 then
      return math["floor"](E)
    end
    local O = tM(I)
    if O ~= nil then
      return O
    end
    local b = I:match("[Ii][Tt][Ee][Mm][Ii]?[Dd]?[^%d]*(%d+)")
    if b == nil then
      b = I:match("(%d+)")
    end
    if b ~= nil then
      local I = tonumber(b)
      if I ~= nil and I > 0 then
        return math["floor"](I)
      end
    end
    return nil
  end
  if type(I) == "table" then
    local E = { I["id"], I["itemid"], I["itemID"], I["value"], I["item"], I["name"], I["itemName"], I["selected"] }
    for I, E in ipairs(E) do
      local O = eM(E)
      if O ~= nil and O > 0 then
        return O
      end
    end
  end
  return nil
end
local function lM(I)
  if I == nil or I < 1 or I > 65535 then
    return false
  end
  I = math["floor"](I)
  if I == V then
    return true
  end
  if o or M or d or (h == V and (i > 0 and iM(V) > 0)) then
    N("AVD_itemid", V)
    MM("Finish stopping and store any purchased items before changing Item ID.")
    return true
  end
  V = I
  i = 0
  h = 0
  r = nil
  c = {}
  N("AVD_itemid", V)
  GM()
  pM()
  fM()
  A()
  MM("Target Item = " .. (UM(I) .. (" (" .. (I .. ")"))))
  return true
end
local function gM(I)
  return lM(eM(I))
end
local function jM(I)
  if type(I) == "table" then
    local E = tonumber(I["x"] or I["tileX"] or I["tilex"] or I["px"])
    local O = tonumber(I["y"] or I["tileY"] or I["tiley"] or I["py"])
    if E ~= nil and O ~= nil then
      return math["floor"](E), math["floor"](O)
    end
    if type(I["pos"]) == "table" then
      E = tonumber(I["pos"]["x"] or I["pos"][1])
      O = tonumber(I["pos"]["y"] or I["pos"][2])
      if E ~= nil and O ~= nil then
        return math["floor"](E), math["floor"](O)
      end
    end
    E = tonumber(I[1])
    O = tonumber(I[2])
    if E ~= nil and O ~= nil then
      return math["floor"](E), math["floor"](O)
    end
    for I, E in pairs(I) do
      if type(E) == "table" then
        local I = tonumber(E["x"] or E["tileX"] or E["tilex"] or E["px"] or E[1])
        local O = tonumber(E["y"] or E["tileY"] or E["tiley"] or E["py"] or E[2])
        if I ~= nil and O ~= nil then
          return math["floor"](I), math["floor"](O)
        end
      elseif type(E) == "string" then
        local I, O = E:match("%(%s*(-?%d+)%s*,%s*(-?%d+)%s*%)")
        if I == nil then
          I, O = E:match("(-?%d+)%s*[,|:]%s*(-?%d+)")
        end
        if I ~= nil and O ~= nil then
          return tonumber(I), tonumber(O)
        end
      end
    end
  elseif type(I) == "string" then
    local E, O = I:match("%(%s*(-?%d+)%s*,%s*(-?%d+)%s*%)")
    if E == nil then
      E, O = I:match("(-?%d+)%s*[,|:]%s*(-?%d+)")
    end
    if E ~= nil and O ~= nil then
      return tonumber(E), tonumber(O)
    end
  end
  return nil, nil
end
local function HM()
  local I = QM(f, y)
  if I == nil then
    return nil, "Vending tile is not loaded."
  end
  if I["fg"] ~= 2978 and I["fg"] ~= 9268 then
    return nil, "Selected tile is not a vending machine."
  end
  local E = I["extra"]
  if E == nil then
    return nil, "Selected vending has no vending data."
  end
  local O = tonumber(E["vend_item"] or 0) or 0
  local b = tonumber(E["vend_price"] or 0) or 0
  if O == 0 then
    return nil, "Selected vending is empty."
  end
  if O ~= V then
    return nil, "Vending sells " .. (UM(O) .. (" (" .. (tostring(O) .. "), not selected item.")))
  end
  editValue("AVD_vendprice", tostring(b))
  return { ["x"] = f, ["y"] = y, ["price"] = b, ["itemID"] = O }, nil
end
local function IQ()
  if r ~= nil then
    return r
  end
  r = {}
  if not a or a == 0 then
    return r
  end
  local I, E = pcall(function()
    if type(GetTiles) == "function" then
      return GetTiles()
    end
    return getTiles()
  end)
  if not I or type(E) ~= "table" then
    return r
  end
  for I, E in pairs(E) do
    if E and ((tonumber(E["fg"]) == 2978 or tonumber(E["fg"]) == 9268) and E["extra"] ~= nil) then
      local I = E["extra"]
      local O = tonumber(I["vend_item"])
      local b = tonumber(I["vend_price"])
      local k, Z = tonumber(E["x"]), tonumber(E["y"])
      if O == V and (b == a and (k and Z)) then
        r[#r + 1] = { ["x"] = math["floor"](k), ["y"] = math["floor"](Z), ["itemID"] = O, ["price"] = b }
      end
    end
  end
  SM("CACHED SAME-PRICE VENDS: " .. tostring(#r))
  return r
end
local function EQ()
  local I, E = f, y
  if P then
    c[t(f, y)] = true
  else
    I, E = qM()
    I, E = I or 0, E or 0
  end
  local O = IQ()
  local b, k = nil, math["huge"]
  for O, Z in ipairs(O) do
    if not c[t(Z["x"], Z["y"])] then
      local O = math["abs"](Z["x"] - I) + math["abs"](Z["y"] - E)
      if O < k or (O == k and (b and (Z["y"] < b["y"] or (Z["y"] == b["y"] and Z["x"] < b["x"])))) then
        b, k = Z, O
      end
    end
  end
  if not b then
    SM("NO MORE SAME-PRICE VENDS")
    return false
  end
  f, y = b["x"], b["y"]
  P = true
  yM()
  editValue("AVD_vendprice", math["abs"](a) .. (s and " WL/item" or " items/WL"))
  SM("NEXT VEND " .. (tostring(f) .. ("," .. tostring(y))))
  A()
  return true
end
local function OQ()
  local I, E = qM()
  if I == f and E == y then
    return true
  end
  SM("MOVE TO VEND " .. (tostring(f) .. ("," .. tostring(y))))
  if not AM(f, y) then
    return false
  end
  I, E = qM()
  return I == f and E == y
end
local function bQ(I, E)
  local O = tonumber(I:match("embed_data|tilex|(%-?%d+)")) or E["x"]
  local b = tonumber(I:match("embed_data|tiley|(%-?%d+)")) or E["y"]
  local k = tonumber(I:match("embed_data|expectitem|(%-?%d+)"))
    or tonumber(I:match("expectitem|(%-?%d+)"))
    or E["itemID"]
  local Z = tonumber(I:match("embed_data|expectprice|(%-?%d+)"))
    or tonumber(I:match("expectprice|(%-?%d+)"))
    or E["price"]
  local Y = I:match("contains a total of%s+([%d,]+)") or I:match("contains%s+([%d,]+)")
  local m = nil
  if Y ~= nil then
    Y = (tostring(Y)):gsub(",", "")
    m = tonumber(Y)
  end
  return { ["x"] = O, ["y"] = b, ["itemID"] = k, ["price"] = Z, ["stock"] = m }
end
local function kQ(I)
  if not o then
    return nil
  end
  local E = hM()
  if E == nil then
    return nil
  end
  sM = true
  WM = false
  CM = ""
  SM("OPEN VENDING")
  local O = pcall(function()
    SendPacketRaw(false, { ["type"] = 3, ["value"] = 32, ["px"] = f, ["py"] = y, ["x"] = E["posX"], ["y"] = E["posY"] })
  end)
  if not O then
    sM = false
    return nil
  end
  local b = 0
  while o and b < BM do
    if WM then
      local E = CM
      sM = false
      WM = false
      CM = ""
      return bQ(E, I)
    end
    Sleep(50)
    b = b + 50
  end
  sM = false
  WM = false
  CM = ""
  return nil
end
local function ZQ(I)
  local E = kQ(I)
  if E ~= nil or not o then
    return E
  end
  for O = 1, mM, 1 do
    if not o then
      return nil
    end
    SM("VEND REPATH " .. (tostring(O) .. ("/" .. (tostring(mM) .. (" -> " .. (tostring(f) .. ("," .. tostring(y))))))))
    pcall(function()
      FindPath(f, y)
    end)
    local b = 0
    while o and b < ZM do
      if RM(f, y) then
        break
      end
      Sleep(100)
      b = b + 100
    end
    if not o then
      return nil
    end
    SM("RETRY VENDING")
    E = kQ(I)
    if E ~= nil then
      return E
    end
    Sleep(300)
  end
  return nil
end
local function YQ(I, E)
  SendPacket(
    2,
    "action|dialog_return\n"
      .. (
        "dialog_name|vending\n"
        .. (
          "tilex|"
          .. (
            tostring(I["x"])
            .. (
              "|\n"
              .. (
                "tiley|"
                .. (
                  tostring(I["y"])
                  .. (
                    "|\n"
                    .. (
                      "verify|1|\n"
                      .. (
                        "buycount|"
                        .. (
                          tostring(E)
                          .. (
                            "|\n"
                            .. (
                              "expectprice|"
                              .. (
                                tostring(I["price"]) .. ("|\n" .. ("expectitem|" .. (tostring(I["itemID"]) .. "|\n")))
                              )
                            )
                          )
                        )
                      )
                    )
                  )
                )
              )
            )
          )
        )
      )
  )
end
local function mQ(I)
  I = tonumber(I) or 0
  if I <= -2 then
    return math["floor"](math["abs"](I))
  end
  return 1
end
local function uQ(I, E)
  I = math["max"](0, math["floor"](tonumber(I) or 0))
  E = math["max"](1, math["floor"](tonumber(E) or 1))
  return math["floor"](I / E) * E
end
local function FQ(I, E)
  local O = math["floor"](I / E)
  if O <= 1 then
    return 0
  end
  return math["max"](1, math["floor"](O / 2)) * E
end
local function DQ(I)
  local E
  local function O()
    while o do
      local I = P and HM()
      if I and (I["price"] == a and OQ()) then
        return I
      end
      if not o or not EQ() then
        return nil
      end
      E = nil
    end
  end
  while o and (iM(V) < I and i < n) do
    ::next_buy_cycle::
    local b = O()
    if not b then
      return o and "DEPLETED" or false
    end
    local k = iM(V)
    local Z = n - i
    local Y = e - k
    local m = math["min"](I - k, Z, Y)
    local u = mQ(a)
    local F = uQ(m, u)
    if F < u then
      if k > 0 and Z >= u then
        SM("BACKPACK PRICE-UNIT FULL - STORE " .. k)
        return true
      end
      SM("UNBUYABLE FINAL PRICE REMAINDER " .. Z)
      return "UNIT_REMAINDER"
    end
    if E ~= nil then
      F = uQ(math["min"](F, E), u)
      if F < u then
        if not EQ() then
          return "DEPLETED"
        end
        E = nil
        Sleep(IM)
        goto next_buy_cycle
      end
    end
    local D = false
    local K = ZQ(b)
    if K == nil then
      JM("Vending dialog did not open. Stock cannot be checked safely.")
      return false
    end
    if tonumber(K["x"]) ~= b["x"] or tonumber(K["y"]) ~= b["y"] then
      JM("Different vending opened; cannot confirm exact price.")
      return false
    end
    if tonumber(K["itemID"]) ~= V or tonumber(K["price"]) ~= a then
      SM("VEND ITEM/PRICE CHANGED - SKIP")
    else
      local I = tonumber(K["stock"])
      if I == nil then
        JM("Vending stock was not found in the dialog.")
        return false
      end
      F = uQ(math["min"](F, I), u)
      if F < u then
        SM("VEND STOCK BELOW BUY UNIT @ " .. (f .. ("," .. y)))
      else
        SM("BUY " .. (F .. (" / STOCK " .. I)))
        if not o or not aM(G[p]) or not RM(b["x"], b["y"]) then
          return false
        end
        YQ(K, F)
        local E = 0
        while E < j do
          local I = iM(V)
          if I > k then
            break
          end
          Sleep(100)
          E = E + 100
        end
        local O = iM(V)
        if O <= k then
          Sleep(OM)
          O = iM(V)
        end
        if O > k then
          local I = O - k
          h = V
          i = i + I
          if not A() then
            pM()
            fM()
            JM("Purchase confirmed but progress could not be saved. Retry Start after storage is available.")
            return false
          end
          pM()
          fM()
          if not o then
            return false
          end
          SM("BOUGHT " .. (I .. (" / REQUESTED " .. F)))
          D = true
        else
          if not o then
            return false
          end
          SM("BUY NOT CONFIRMED @ " .. (f .. ("," .. y)))
        end
      end
    end
    if not o then
      return false
    end
    if not D then
      if not EQ() then
        SM("ALL MATCHING VENDS EXHAUSTED - STORE FIRST")
        return "DEPLETED"
      end
      E = nil
    end
    Sleep(IM)
  end
  return o and (iM(V) >= I or i >= n)
end
local function KQ(I)
  if I < 1 then
    return true
  end
  while o and G[p] do
    local E = G[p]
    if cM(E, "BUY") then
      pM()
      local E = DQ(I)
      if E ~= "DEPLETED" then
        return E
      end
    elseif o then
      MM("Could not enter " .. (E .. ". Trying the next buy world."))
    end
    if not o then
      return false
    end
    p = p + 1
    r, c, P = nil, {}, false
  end
  return o and "DEPLETED" or false
end
local function zQ(I, E)
  I = math["floor"](tonumber(I) or 0)
  if I < 1 or iM(V) < 1 then
    return true
  end
  if not cM(X, "STORAGE") or not aM(X) then
    JM("Could not enter storage world or its linked door.")
    return false
  end
  while o and iM(V) > 0 do
    if not aM(X) then
      SM("WAIT STORAGE WORLD - NO DROP")
      return false
    end
    SM("STORAGE PATH -> " .. (J .. ("," .. L)))
    if not AM(J, L) then
      SM("WAIT STORAGE POSITION " .. (J .. ("," .. L)))
      return false
    end
    if not RM(J, L) then
      SM("NOT AT DROP TILE - NO DROP")
      return false
    end
    local I = false
    for E = 1, 2, 1 do
      if not o or not aM(X) or not RM(J, L) then
        SM("DROP POSITION LOST - NO SHIFT")
        return false
      end
      local O = iM(V)
      if O < 1 then
        return true
      end
      SM("DROP " .. (E .. ("/2 @ " .. (J .. ("," .. L)))))
      wM = true
      oM = false
      local b = pcall(function()
        SendPacket(2, "action|drop\nitemID|" .. tostring(V))
      end)
      if not b then
        wM = false
        oM = false
        SM("DROP REQUEST ERROR - WAIT")
        return false
      end
      local k = 0
      while o and (aM(X) and k < dM) do
        if oM or iM(V) < O then
          break
        end
        Sleep(100)
        k = k + 100
      end
      local Z = oM
      wM = false
      oM = false
      if not o or not aM(X) then
        return false
      end
      if not RM(J, L) then
        SM("MOVEMENT DURING DROP - NO SHIFT")
        return false
      end
      if iM(V) < O then
        I = true
        break
      end
      if Z then
        local I = pcall(function()
          SendPacket(
            2,
            "action|dialog_return\n"
              .. ("dialog_name|drop_item\n" .. ("itemID|" .. (tostring(V) .. ("|\n" .. ("count|" .. tostring(O))))))
          )
        end)
        if not I then
          SM("DROP CONFIRM ERROR - WAIT")
          return false
        end
        k = 0
        while o and (aM(X) and k < H) do
          if iM(V) < O then
            break
          end
          Sleep(100)
          k = k + 100
        end
      else
        SM("DROP DIALOG NOT OPENED " .. (E .. "/2"))
      end
      if iM(V) >= O then
        Sleep(850)
      end
      pM()
      if iM(V) < O then
        I = true
        break
      end
      if not aM(X) or not RM(J, L) then
        SM("DROP POSITION CHANGED - NO SHIFT")
        return false
      end
      if E == 1 then
        SM("DROP FAILED - RETRY SAME TILE")
        Sleep(550)
      end
    end
    if I then
      x = 0
      pM()
      if iM(V) == 0 then
        SM("STORAGE DROP COMPLETE")
        return true
      end
      Sleep(250)
    else
      if J <= 0 then
        JM("Storage is full all the way to the left edge.")
        return false
      end
      J = J - 1
      x = 0
      pcall(function()
        editValue("AVD_activedrop", J .. (", " .. L))
      end)
      SM("DROP FULL / SHIFT LEFT -> " .. (J .. ("," .. L)))
      MM("Storage moved left to " .. (J .. ("," .. L)))
      A()
      Sleep(800)
      return false
    end
  end
  return iM(V) == 0
end
local function sQ()
  local I = iM(V)
  pM()
  if I < 1 then
    return true
  end
  return zQ(I, "Dropped all selected item")
end
local function WQ()
  local I = iM(V)
  pM()
  if I < 1 then
    MM("Inventory check: no existing target item.")
    return true
  end
  SM("INITIAL DROP")
  MM("Inventory check: dropping existing " .. (tostring(I) .. (" " .. (UM(V) .. " first."))))
  return zQ(I, "Initial inventory dropped")
end
local function CQ()
  Q["AVD_enable"] = true
  pcall(function()
    EditToggle("AVD_enable", false)
  end)
  pcall(function()
    editToggle("AVD_enable", false)
  end)
  Q["AVD_enable"] = nil
end
function onVariant(I, E)
  if I ~= nil and (I["v1"] == "OnDialogRequest" and type(I["v2"]) == "string") then
    local E = I["v2"]
    if o and (wM and E:find("drop_item", 1, true)) then
      oM = true
      return true
    end
    if
      o
      and (
        sM
        and (
          E:find("end_dialog|vending", 1, true) and (
            E:find("embed_data|tilex|", 1, true) or E:find("expectitem|", 1, true)
          )
        )
      )
    then
      CM = E
      WM = true
      return true
    end
  end
  return false
end
function onValue(E, O, b)
  if Q[O] then
    return
  end
  if O == "AVD_totalbought" or O == "AVD_totalremaining" then
    return
  end
  if O == "AVD_enable" then
    if b == true then
      if o or M then
        return
      end
      if d then
        CQ()
        MM("The previous run is still stopping. Try Start again shortly.")
        return
      end
      S = S + 1
      local I = S
      M = true
      runThread(function()
        if i > 0 and h ~= V then
          JM(
            "Saved progress belongs to item "
              .. (h .. ". Reselect it to resume, or edit Total Buy Amount for a new target.")
          )
          return
        end
        if not A() then
          JM("Settings storage is required to save purchase progress.")
          return
        end
        r, c, P = nil, {}, false
        p = 1
        q = false
        R = ""
        if J > T or J < 0 then
          J = T
        end
        x = 0
        pcall(function()
          editValue("AVD_activedrop", J .. (", " .. L))
        end)
        v = false
        pcall(function()
          editValue("AVD_activedrop", J .. (", " .. L))
        end)
        zM = true
        N("AVD_itemid", tostring(V))
        GM()
        pM()
        fM()
        if V <= 0 then
          JM("Choose a valid target item first.")
          return
        end
        if n < 1 then
          JM("Total Buy Amount must be at least 1.")
          return
        end
        if not a or a == 0 then
          JM("Enter the exact Item Price first.")
          return
        end
        G = vM(U)
        if not G or #G == 0 then
          JM("Enter valid Buy Worlds separated by commas.")
          return
        end
        if VM(X) == "" then
          JM("Set Drop World first.")
          return
        end
        if not LM(true) then
          JM("Could not enable ModFly at start.")
          return
        end
        if S ~= I then
          return
        end
        M = false
        o = true
        SM("STARTING")
        MM("Started. Bought " .. (i .. ("/" .. (n .. ("; remaining " .. (math["max"](0, n - i) .. "."))))))
      end)
    else
      S = S + 1
      M = false
      o = false
      LM(false)
      wM = false
      oM = false
      sM = false
      WM = false
      CM = ""
      SM("STOPPED")
      MM(I .. " stopped.")
    end
    return
  end
  if O == "AVD_itempicker" then
    if not gM(b) then
      MM("Could not read item from Item Picker.")
    end
    return
  end
  if O == "AVD_itemid" then
    if not lM(tonumber(b)) then
      N("AVD_itemid", V)
    end
    return
  end
  if O == "AVD_totalbuyamount" then
    local I = tonumber(b)
    if I == nil then
      N("AVD_totalbuyamount", n)
      return
    end
    I = math["min"](999999, math["max"](1, math["floor"](I)))
    if I ~= n then
      if o or M or d then
        MM("Stop Auto Vend and let the current action finish before editing Total Buy Amount.")
      else
        n = I
        i = 0
        h = 0
        fM()
        A()
      end
    end
    N("AVD_totalbuyamount", n)
    return
  end
  if O == "AVD_priceperitem" or O == "AVD_itemprice" then
    local I = a and math["abs"](a)
    if o or M or d then
      if O == "AVD_priceperitem" then
        Q[O] = true
        pcall(editToggle or EditToggle, O, s)
        Q[O] = nil
      else
        N(O, I or "")
      end
      return
    end
    if O == "AVD_priceperitem" then
      s = b == true
    else
      local E = (tostring(b or "")):match("^%s*(.-)%s*$")
      local k = E:match("^%d+$") and tonumber(E) or nil
      if E ~= "" and (not k or k < 1 or k > 2147483647) then
        N(O, I or "")
        MM("Enter a positive whole number for Item Price.")
        return
      end
      I = k
      N(O, I or "")
    end
    a = I and (s and I or -I)
    editValue("AVD_vendprice", I and (I .. (s and " WL/item" or " items/WL")) or "NONE")
    A()
    return
  end
  if O == "AVD_buyworld" or O == "AVD_setbuyworld" or O == "AVD_clearbuyworlds" then
    if o or M or d then
      N("AVD_buyworld", U)
      return
    end
    local I = O == "AVD_clearbuyworlds" and "" or tostring(b or "")
    if O == "AVD_setbuyworld" then
      local E = nM()
      if E == "" or E == "EXIT" or E == "EXITWORLD" then
        MM("Current world is not available.")
        return
      end
      I = U == "" and E or (U .. ("," .. E))
    end
    U = I
    if O ~= "AVD_buyworld" then
      N("AVD_buyworld", U)
    end
    A()
    return
  end
  if O == "AVD_dropworld" then
    X = VM(b)
    A()
    return
  end
  if O == "AVD_setdropworld" then
    local I = nM()
    if I == "" or I == "EXIT" then
      MM("Current world is not available.")
      return
    end
    X = I
    N("AVD_dropworld", X)
    A()
    MM("Drop World = " .. X)
    return
  end
  if O == "AVD_dropx" then
    local I = tonumber(b)
    if I ~= nil then
      T = math["floor"](I)
      J = T
      x = 0
      pcall(function()
        editValue("AVD_activedrop", J .. (", " .. L))
      end)
      A()
    end
    return
  end
  if O == "AVD_dropy" then
    local I = tonumber(b)
    if I ~= nil then
      L = math["floor"](I)
      pcall(function()
        editValue("AVD_activedrop", J .. (", " .. L))
      end)
      A()
    end
    return
  end
  if O == "AVD_setdrop" then
    local I, E = qM()
    if I == nil or E == nil then
      MM("Player position is not available.")
      return
    end
    T = I
    L = E
    J = I
    x = 0
    pcall(function()
      editValue("AVD_activedrop", J .. (", " .. L))
    end)
    N("AVD_dropx", tostring(T))
    N("AVD_dropy", tostring(L))
    A()
    MM("Drop stand position = (" .. (tostring(T) .. (", " .. (tostring(L) .. ")"))))
    return
  end
end
applyHook()
if type(setOnValue) == "function" then
  pcall(function()
    setOnValue("AVD_itempicker", function(...)
      local I = { ... }
      for E = #I, 1, -1 do
        if gM(I[E]) then
          return
        end
      end
    end)
  end)
  for I, E in ipairs({ "AVD_buyworld", "AVD_priceperitem", "AVD_itemprice", "AVD_dropworld", "AVD_dropx", "AVD_dropy" }) do
    local O = E
    pcall(setOnValue, O, function(...)
      local I = select("#", ...)
      if I > 0 then
        onValue(nil, O, select(I, ...))
      end
    end)
  end
end
runThread(function()
  SM("STOPPED")
  GM()
  pM()
  fM()
  yM()
  pcall(function()
    editValue("AVD_activedrop", J .. (", " .. L))
  end)
  if Z ~= nil and not m then
    A()
  end
  while true do
    if o then
      d = true
      pM()
      fM()
      if zM then
        if WQ() then
          zM = false
          Sleep(IM)
        else
          Sleep(350)
        end
      elseif v then
        if iM(V) == 0 then
          v = false
        elseif sQ() then
          v = (iM(V) > 0)
          Sleep(IM)
        else
          Sleep(450)
        end
      elseif q then
        if iM(V) > 0 then
          v = true
          SM("ALL VENDS DONE - STORE REMAINING ITEMS")
        else
          SM("ALL VENDS DONE - RETURN TO STORAGE")
          if cM(X, "STORAGE") and aM(X) then
            JM(R ~= "" and R or "No more purchasable same-price vends.")
          else
            SM("WAIT STORAGE BEFORE AUTOMATIC STOP")
            Sleep(700)
          end
        end
      elseif i >= n then
        if iM(V) > 0 then
          v = true
        else
          JM("Total buy target reached: " .. (tostring(i) .. ("/" .. tostring(n))))
        end
      else
        local I = n - i
        local E = math["min"](e, I)
        local O = KQ(E)
        if O == "DEPLETED" or O == "UNIT_REMAINDER" then
          q = true
          R = O == "DEPLETED" and "No reachable vend with matching item, price, and stock. Stored and stopped."
            or "Remaining target cannot be bought in whole price units. Stored and stopped."
          v = iM(V) > 0
          SM("BUYING FINISHED - STORE THEN STOP")
        elseif O == true then
          v = iM(V) > 0
          if not v then
            Sleep(250)
          end
        else
          if o and iM(V) > 0 then
            v = true
          end
          Sleep(350)
        end
      end
      d = false
    else
      Sleep(200)
    end
  end
end)
