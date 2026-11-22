setMinimum("6.1.2")
local e = "Premium Auto buy vend by Bangshu"
do
  local O =
    "https://script.google.com/macros/s/AKfycbxWY0ROC3V1HOTJuRPfovwsN8CfTkXrcFF6VvhlS0EQRfWleUWVHZNUSW1M2UcVesSC/exec"
  local P = "AUTOVEND"
  local A = "AUTOVEND-2.2-PAID-001"
  local S = "approval"
  local Z = "%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x"
  local function E()
    local e, O = pcall(function()
      if type(getDiscordID) == "function" then
        return getDiscordID()
      end
      return getDiscordID
    end)
    if not e then
      return nil
    end
    if type(O) == "number" and (math["type"] and math["type"](O) == "integer") then
      O = tostring(O)
    end
    if type(O) ~= "string" or #O < 17 or #O > 20 or not O:match("^%d+$") then
      return nil
    end
    if O:match("^0+$") then
      return nil
    end
    return O
  end
  local function c(e, O)
    if not O or type(e) ~= "string" or #e > 512 then
      return false
    end
    local S, E, c = e:match(
      '^%s*{"status":"APPROVED","approval":{"discordId":"(%d+)","product":"([A-Z]+)","version":"([%w._-]+)","receiptId":"'
        .. (Z .. '"}}%s*$')
    )
    return S == O and (E == P and c == A)
  end
  local u, J, y = pcall(function()
    local e, O = pcall(require, "preferences")
    local P = e and (type(O) == "table" and O) or Preferences
    if type(P) ~= "table" or type(P["new"]) ~= "function" then
      return nil
    end
    local A = P:new("BangshuPremiumAutoVend")
    if A:load() == false then
      return A
    end
    return A, A:get(S, "")
  end)
  if not u then
    J = nil
  end
  if not c(y, E()) then
    local Z, u = false, false
    local function y(e)
      pcall(editValue, "AVD_premium_status", e)
      if type(sendNotification) == "function" then
        pcall(sendNotification, e)
      elseif growtopia and type(growtopia["notify"]) == "function" then
        pcall(growtopia["notify"], e)
      end
    end
    local function p()
      if Z or u then
        return
      end
      local e = E()
      if not e then
        y("DENIED - DISCORD ID UNAVAILABLE")
        return
      end
      if not J then
        y("DENIED - PREFERENCES UNAVAILABLE")
        return
      end
      Z = true
      y("CHECKING - BUILD 04")
      local p = pcall(runThread, function()
        local E = O
          .. (
            "?action=verifyPaidAccess&discordId=" .. (
              e .. ("&product=" .. (P .. ("&format=growlauncher&version=" .. A)))
            )
          )
        local p, t = pcall(fetch, E)
        if p and type(t) == "string" then
          local e = t:match("BANGSHU_PREMIUM_V1_BEGIN_([0-9a-f]+)_BANGSHU_PREMIUM_V1_END")
          if e and (#e <= 1024 and #e % 2 == 0) then
            t = e:gsub("..", function(e)
              return string["char"](tonumber(e, 16))
            end)
          end
        end
        if not p or type(t) ~= "string" then
          y("DENIED - REQUEST FAILED")
        elseif not c(t, e) then
          if t:match('^%s*{"status":"DENIED",') then
            y("DENIED - NO PREMIUM ACCESS")
          elseif t:match('^%s*{"status":"ERROR",') then
            y("DENIED - APPS SCRIPT SERVER ERROR")
          elseif t:match("^%s*<") then
            if t:find("doGet", 1, true) then
              y("DENIED - DEPLOYED APP MISSING GET HANDLER")
            else
              y("DENIED - GOOGLE RETURNED HTML")
            end
          elseif t:match("^%s*$") then
            y("DENIED - EMPTY SERVER RESPONSE")
          elseif t:match('^%s*{"status":"APPROVED",') then
            y("DENIED - APPROVAL DETAILS DO NOT MATCH")
          else
            y("DENIED - UNEXPECTED SERVER RESPONSE")
          end
        else
          local O, P = pcall(function()
            if J:set(S, t) == false then
              return false
            end
            if J:save() == false then
              return false
            end
            if J:load() == false then
              return false
            end
            return c(J:get(S, ""), e)
          end)
          u = O and P == true
          y(u and "APPROVED - RELOAD SCRIPT" or "DENIED - COULD NOT SAVE APPROVAL")
        end
        Z = false
      end)
      if not p then
        Z = false
        y("DENIED - COULD NOT START CHECK")
      end
    end
    function OnValue(e, O)
      if O == "AVD_premium_verify" then
        p()
      end
    end
    onValue = OnValue
    local t = UserInterface["new"](e, "ShoppingCart")
    t:addButton("Verify Access", "AVD_premium_verify")
    t:addInputString("Verification Status", "NOT VERIFIED", "", "", nil, "AVD_premium_status")
    if type(addCategory) == "function" then
      pcall(addCategory, e, "ShoppingCart")
    end
    addIntoModule(t:generateJSON(), e)
    if type(applyHook) == "function" then
      pcall(applyHook)
    end
    if type(setOnValue) == "function" then
      pcall(setOnValue, "AVD_premium_verify", p)
    end
    return
  end
end
local O = "AutoVendSettingsV31"
local P = "31"
local A = {
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
}
local S = {
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
}
local Z = nil
local E = {}
local c = false
for e, O in pairs(A) do
  E[e] = O
end
local function u()
  local e = pcall(function()
    local e = nil
    if type(require) == "function" then
      local O, P = pcall(require, "preferences")
      if O and type(P) == "table" then
        e = P
      end
    end
    if e == nil and type(Preferences) == "table" then
      e = Preferences
    end
    if e == nil or type(e["new"]) ~= "function" then
      return
    end
    local u = e:new(O)
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
    if tostring(u:get("schema", "")) == P then
      for e, O in ipairs(S) do
        E[O] = tostring(u:get(O, A[O]))
      end
      c = true
    end
  end)
  if not e then
    Z = nil
  end
end
u()
local function J(e, O, P, A)
  local S = math["floor"](tonumber(E[e]) or O)
  return math["min"](A, math["max"](P, S))
end
local function y(e)
  return ((tostring(E[e] or "")):upper()):gsub("%s+", "")
end
local p = UserInterface["new"](e, "ShoppingCart")
p:addLabelApp(e, "ShoppingCart")
p:addToggle("Start / Stop", false, "AVD_enable")
p:addInputString(
  "Buy Progress (view only)",
  "0 / " .. tostring(E["totalbuyamount"]),
  "Bought / total target",
  "0 / 1000",
  nil,
  "AVD_totalbought"
)
p:addInputString(
  "Remaining to Buy (view only)",
  tostring(E["totalbuyamount"]),
  "Items left",
  "1000",
  nil,
  "AVD_totalremaining"
)
p:addItemPicker("Pick Target Item", E["itemid"], E["itemid"], "AVD_itempicker")
p:addInputInt("Item ID", E["itemid"], "ID", "5706", nil, "AVD_itemid")
p:addDisplayList("Selected Item", E["itemid"], "AVD_selecteditem")
p:addInputInt("Total Buy Amount", E["totalbuyamount"], "items total", "1000", nil, "AVD_totalbuyamount")
p:addButton("Find Vend for Selected Item", "AVD_findvend")
local t = (p:addDialog("Buy World Settings", "Set the buy world and starting vending machine", {}))["menu"]
p:addChildInputString(t, "Buy World", E["buyworld"], "WORLD|DOORID", "BUY WORLD or WORLD|DOORID", nil, "AVD_buyworld")
p:addChildButton(t, "Set Buy World = Current World", "AVD_setbuyworld")
p:addChildInputInt(t, "Vending Position X", E["vendx"], "X", "0", nil, "AVD_vendx")
p:addChildInputInt(t, "Vending Position Y", E["vendy"], "Y", "0", nil, "AVD_vendy")
p:addChildButton(t, "Set Vending = Current Tile", "AVD_setvend")
local V = (p:addDialog("Drop World Settings", "Set the drop world and storage tile", {}))["menu"]
p:addChildInputString(
  V,
  "Drop World",
  E["dropworld"],
  "WORLD|DOORID",
  "DROP WORLD or WORLD|DOORID",
  nil,
  "AVD_dropworld"
)
p:addChildButton(V, "Set Drop World = Current World", "AVD_setdropworld")
p:addChildInputInt(V, "Drop Stand Position X", E["dropx"], "X", "0", nil, "AVD_dropx")
p:addChildInputInt(V, "Drop Stand Position Y", E["dropy"], "Y", "0", nil, "AVD_dropy")
p:addChildButton(V, "Set Drop Position = Current Tile", "AVD_setdrop")
p:addDisplayList("Selected Vending", "0, 0", "AVD_vendpos")
p:addDisplayList("Vending Price", E["lockedprice"] ~= "" and E["lockedprice"] or "NONE", "AVD_vendprice")
p:addDisplayList("Current Drop Tile", E["activedropx"] .. (", " .. E["dropy"]), "AVD_activedrop")
p:addDisplayList("ModFly (Session)", "OFF", "AVD_travelfly")
p:addDisplayList("Settings AutoSave", Z == nil and "UNAVAILABLE" or (c and "RESTORED" or "READY"), "AVD_autosave")
p:addDisplayList("Status", "STOPPED", "AVD_status")
p:addDisplayList("Item Inventory", "0 / 200", "AVD_inventory")
pcall(function()
  if type(addCategory) == "function" then
    addCategory(e, "ShoppingCart")
  end
end)
local z = p:generateJSON()
local D = pcall(function()
  addIntoModule(z, e)
end)
if not D then
  pcall(function()
    growtopia["notify"](e .. " menu could not be created on this Growlauncher build.")
  end)
end
local b = false
local d = false
local m = false
local C = false
local W = 0
local j = J("itemid", 5706, 1, 65535)
local U = J("totalbuyamount", 200, 1, 999999)
local v = J("progressitem", 0, 0, 65535)
local L = J("totalbought", 0, 0, 999999)
local a = y("buyworld")
local q = y("dropworld")
local F = J("vendx", 0, 0, 199)
local B = J("vendy", 0, 0, 119)
local o = J("dropx", 0, 0, 199)
local Q = J("dropy", 0, 0, 119)
local f = J("activedropx", o, 0, 199)
local I = 0
local N = false
local H = tonumber(E["lockedprice"])
local R = nil
local r = {}
local n = false
local T = ""
local function Y()
  if Z == nil then
    pcall(function()
      editValue("AVD_autosave", "UNAVAILABLE")
    end)
    return false
  end
  local e = {
    ["itemid"] = tostring(j),
    ["totalbuyamount"] = tostring(U),
    ["progressitem"] = tostring(v),
    ["totalbought"] = tostring(L),
    ["buyworld"] = tostring(a),
    ["dropworld"] = tostring(q),
    ["vendx"] = tostring(F),
    ["vendy"] = tostring(B),
    ["dropx"] = tostring(o),
    ["dropy"] = tostring(Q),
    ["activedropx"] = tostring(f),
    ["lockedprice"] = H and tostring(H) or "",
  }
  local O = false
  for P, A in ipairs(S) do
    if E[A] ~= e[A] then
      O = true
      break
    end
  end
  if not O and c then
    return true
  end
  local A = pcall(function()
    if Z:set("schema", P) == false then
      error("schema")
    end
    for O, P in ipairs(S) do
      if Z:set(P, e[P]) == false then
        error("setting: " .. P)
      end
    end
    if Z:save() == false then
      error("save")
    end
  end)
  if A then
    for e, O in pairs(e) do
      E[e] = O
    end
    c = true
  end
  pcall(function()
    editValue("AVD_autosave", A and "SAVED" or "SAVE FAILED")
  end)
  return A
end
local x = {}
local function s(e, O)
  if x[e] then
    return
  end
  x[e] = true
  pcall(function()
    editValue(e, tostring(O))
  end)
  x[e] = nil
end
local function w(e, O)
  return tostring(e) .. ("," .. tostring(O))
end
local G = 200
local i = 15000
local k = 15000
local K = 4200
local M = 3000
local h = 300
local l = 500
local X = 650
local g = 1000
local eP = 900
local OP = 1200
local PP = 12000
local AP = 5
local SP = false
local ZP = 1500
local EP = 7
local cP = "STOPPED"
local uP = true
local JP = false
local yP = false
local pP = ""
local tP = 2500
local VP = false
local zP = false
local DP = 2500
local function bP(e)
  pcall(function()
    growtopia["notify"](tostring(e))
  end)
end
local function dP(e)
  e = tostring(e)
  if cP ~= e then
    cP = e
    editValue("AVD_status", e)
  end
end
local function mP(e)
  e = tostring(e or "")
  e = e:gsub("%s+", "")
  return e:upper()
end
local function CP()
  local e, O = pcall(function()
    if type(GetWorldName) == "function" then
      return GetWorldName()
    end
    if type(getCurrentWorldName) == "function" then
      return getCurrentWorldName()
    end
    return ""
  end)
  if not e then
    return ""
  end
  return mP(O)
end
local function WP()
  local e, O = pcall(function()
    return GetLocal()
  end)
  if e and O ~= nil then
    return O
  end
  e, O = pcall(function()
    return getLocal()
  end)
  if e then
    return O
  end
  return nil
end
local function jP(e)
  local O, P = pcall(function()
    if growtopia ~= nil and type(growtopia["checkInventoryCount"]) == "function" then
      return growtopia["checkInventoryCount"](e)
    end
    local O = 0
    local P = nil
    if type(GetInventory) == "function" then
      P = GetInventory()
    elseif type(getInventory) == "function" then
      P = getInventory()
    end
    if P ~= nil then
      for P, A in pairs(P) do
        if tonumber(A["id"]) == tonumber(e) then
          O = tonumber(A["amount"]) or 0
          break
        end
      end
    end
    return O
  end)
  if not O then
    return 0
  end
  return tonumber(P) or 0
end
local function UP(e)
  local O, P = pcall(function()
    if growtopia ~= nil and type(growtopia["getItemName"]) == "function" then
      return growtopia["getItemName"](e)
    end
    if type(getItemInfoByID) == "function" then
      local O = getItemInfoByID(e)
      if O ~= nil then
        return O["name"]
      end
    end
    return nil
  end)
  if O and (P ~= nil and tostring(P) ~= "") then
    return tostring(P)
  end
  return "Item " .. tostring(e)
end
local function vP()
  editValue("AVD_selecteditem", UP(j) .. (" (" .. (tostring(j) .. ")")))
end
local function LP()
  editValue("AVD_inventory", tostring(jP(j)) .. " / 200")
end
local aP = nil
local function qP()
  local e = v == j and L or 0
  local O = math["max"](1, math["floor"](tonumber(U) or 1))
  local P = math["max"](0, O - e)
  local A = math["min"](100, math["floor"]((e * 100) / O))
  local S = tostring(e) .. (" / " .. (tostring(O) .. (" (" .. (tostring(A) .. "%)"))))
  if S ~= aP then
    aP = S
    s("AVD_totalbought", S)
    s("AVD_totalremaining", tostring(P))
  end
end
local function FP()
  editValue("AVD_vendpos", tostring(F) .. (", " .. tostring(B)))
end
local BP = nil
local function oP(e)
  e = e == true
  if BP == e then
    return true
  end
  local O = editToggle or EditToggle
  if type(O) ~= "function" then
    pcall(function()
      editValue("AVD_travelfly", "UNAVAILABLE")
    end)
    return false
  end
  local P, A = pcall(O, "ModFly", e)
  if not P or A == false then
    pcall(function()
      editValue("AVD_travelfly", "ERROR")
    end)
    return false
  end
  BP = e
  pcall(function()
    editValue("AVD_travelfly", e and "ON (SESSION)" or "OFF")
  end)
  if e then
    Sleep(250)
  end
  return true
end
local function QP(e)
  C = false
  b = false
  oP(false)
  VP = false
  zP = false
  JP = false
  yP = false
  pP = ""
  pcall(function()
    EditToggle("AVD_enable", false)
  end)
  pcall(function()
    editToggle("AVD_enable", false)
  end)
  dP("STOPPED")
  if e ~= nil and e ~= "" then
    bP(e)
  end
end
local function fP(e)
  e = mP(e)
  local O, P = e:match("^([^|]+)|([^|]+)$")
  if O ~= nil then
    return O, P
  end
  if e:find("|", 1, true) then
    return "", nil
  end
  return e, nil
end
local function IP(e)
  local O = fP(e)
  if O == "" or CP() ~= O then
    return false
  end
  local P = WP()
  if P == nil then
    return false
  end
  local A, S = pcall(function()
    if type(GetTiles) == "function" then
      return GetTiles()
    end
    return getTiles()
  end)
  return A and (S ~= nil and #S > 0)
end
local function NP(e, O)
  local P = 0
  while b and P < O do
    if IP(e) then
      Sleep(300)
      return b and IP(e)
    end
    Sleep(100)
    P = P + 100
  end
  return false
end
local HP = ""
local function RP(e, O)
  O = (O == "STORAGE") and "STORAGE" or "BUY"
  e = mP(e)
  local P, A = fP(e)
  if P == "" then
    dP(O .. " INVALID WORLD OR DOOR ID")
    return false
  end
  local S = A ~= nil and A ~= ""
  if not S and IP(P) then
    HP = ""
    SP = false
    return true
  end
  if S and (IP(P) and HP == e) then
    SP = false
    return true
  end
  if not IP(P) then
    dP(O .. (" WARP BASE " .. P))
    HP = ""
    local e, A = pcall(function()
      return growtopia["warpTo"](P)
    end)
    if not e or A == false then
      return false
    end
    if not NP(P, i) then
      return false
    end
    Sleep(g)
    if not b or not IP(P) then
      return false
    end
  end
  if S then
    dP(O .. (" ENTER DOOR " .. (P .. ("|" .. A))))
    local S, Z = pcall(function()
      return SendPacket(3, "action|join_request\nname|" .. (e .. "\ninvitedWorld|0"))
    end)
    if not S or Z == false then
      return false
    end
    Sleep(1400)
    if not NP(P, i) then
      return false
    end
    Sleep(g)
    if not b or not IP(P) then
      return false
    end
    HP = e
    dP(O .. (" DOOR REQUEST SETTLED " .. (P .. ("|" .. A))))
  else
    HP = ""
  end
  SP = true
  return true
end
local function rP()
  local e = WP()
  if e == nil then
    return nil, nil
  end
  return e["posX"] // 32, e["posY"] // 32
end
local function nP(e, O)
  local P, A = rP()
  return P == e and A == O
end
local function TP(e, O)
  if nP(e, O) then
    SP = false
    Sleep(150)
    return true
  end
  local P = SP
  SP = false
  local A = 0
  local S = 0
  local Z = 0
  while b and S < k do
    if nP(e, O) then
      Sleep(150)
      return true
    end
    if A < EP and S >= Z then
      A = A + 1
      dP("PATH " .. (tostring(A) .. ("/" .. (tostring(EP) .. (" -> " .. (tostring(e) .. ("," .. tostring(O))))))))
      pcall(function()
        FindPath(e, O)
      end)
      if P and A == 1 then
        Z = S + eP
      else
        Z = S + ZP
      end
    end
    Sleep(100)
    S = S + 100
  end
  return nP(e, O)
end
local function YP(e, O)
  local P, A = pcall(function()
    if type(getTile) == "function" then
      return getTile(e, O)
    end
    return GetTile(e, O)
  end)
  if P then
    return A
  end
  return nil
end
local function xP(e, O)
  local P, A = rP()
  if P == nil or A == nil then
    return nil, "Player position is not available."
  end
  e = e or 4
  O = O or 2
  local S = {}
  for O = A - O, A + O, 1 do
    for e = P - e, P + e, 1 do
      local Z = YP(e, O)
      if Z ~= nil and (Z["fg"] == 2978 or Z["fg"] == 9268) then
        local E = Z["extra"]
        local c = E and tonumber(E["vend_item"] or 0) or 0
        if c == j then
          local Z = tonumber(E["vend_price"] or 0) or 0
          local c = math["abs"](P - e) + math["abs"](A - O)
          table["insert"](S, { ["x"] = e, ["y"] = O, ["price"] = Z, ["distance"] = c })
        end
      end
    end
  end
  if #S == 0 then
    return nil, "No nearby vending sells " .. (UP(j) .. (" (" .. (tostring(j) .. ").")))
  end
  table["sort"](S, function(e, O)
    if e["distance"] == O["distance"] then
      if e["y"] == O["y"] then
        return e["x"] < O["x"]
      end
      return e["y"] < O["y"]
    end
    return e["distance"] < O["distance"]
  end)
  return S[1], nil
end
local function sP(e, O, P)
  local A, S = pcall(GetTiles or getTiles)
  if not A or type(S) ~= "table" then
    return nil
  end
  local Z, E
  for A, S in pairs(S) do
    local c, u = tonumber(S["fg"]), S["extra"]
    if (c == 2978 or c == 9268) and (u and tonumber(u["vend_item"]) == e) then
      local e, A, c = tonumber(S["x"]), tonumber(S["y"]), tonumber(u["vend_price"])
      if e and (A and (c and c ~= 0)) then
        local S = math["abs"](O - e) + math["abs"](P - A)
        if not Z or S < E or (S == E and (A < Z["y"] or (A == Z["y"] and e < Z["x"]))) then
          Z, E = { ["x"] = e, ["y"] = A }, S
        end
      end
    end
  end
  return Z
end
local function wP()
  local e, O = CP(), j
  local P, A = rP()
  if P == nil or e == "" or e == "EXIT" or e == "EXITWORLD" then
    return "Enter the buy world before finding a vend."
  end
  local S = sP(O, P, A)
  if not S then
    return "No priced vend sells the selected item in this world."
  end
  dP("FINDING VEND " .. (S["x"] .. ("," .. S["y"])))
  for P, A in ipairs({ 3000, 4500 }) do
    if CP() ~= e or j ~= O then
      return "Vend search interrupted."
    end
    if not nP(S["x"], S["y"]) then
      pcall(FindPath or findPath, S["x"], S["y"])
    end
    local Z = 0
    for P = 1, A / 100, 1 do
      if CP() ~= e or j ~= O then
        return "Vend search interrupted."
      end
      Z = nP(S["x"], S["y"]) and Z + 100 or 0
      if Z >= 500 then
        local e = YP(S["x"], S["y"])
        local P, A = e and tonumber(e["fg"]), e and e["extra"]
        local Z = A and tonumber(A["vend_price"])
        if (P ~= 2978 and P ~= 9268) or not A or tonumber(A["vend_item"]) ~= O or not Z or Z == 0 then
          return "The vend changed before arrival."
        end
        local E = Z > 0 and (Z .. " WL/item") or (math["abs"](Z) .. " items/WL")
        return "Vend " .. (
            S["x"] .. ("," .. (S["y"] .. (" at " .. (E .. ". Use Set Vending = Current Tile to save it."))))
          )
      end
      Sleep(100)
    end
  end
  return "Could not reach vend " .. (S["x"] .. ("," .. (S["y"] .. ".")))
end
local function GP()
  if m then
    return
  end
  if b or C or d then
    bP("Stop buying before finding a vend.")
    return
  end
  m = true
  runThread(function()
    local e, O = pcall(wP)
    m = false
    if not e then
      O = "Could not find the vend."
    end
    dP(O)
    bP(O)
  end)
end
local function iP(e)
  if type(e) ~= "string" or e == "" then
    return nil
  end
  local O, P = pcall(function()
    if type(findItemID) == "function" then
      return findItemID(e)
    end
    if growtopia ~= nil and type(growtopia["getItemID"]) == "function" then
      return growtopia["getItemID"](e)
    end
    return nil
  end)
  if O and (tonumber(P) ~= nil and tonumber(P) > 0) then
    return math["floor"](tonumber(P))
  end
  return nil
end
local function kP(e)
  if type(e) == "number" then
    return math["floor"](e)
  end
  if type(e) == "string" then
    local O = tonumber(e)
    if O ~= nil and O > 0 then
      return math["floor"](O)
    end
    local P = iP(e)
    if P ~= nil then
      return P
    end
    local A = e:match("[Ii][Tt][Ee][Mm][Ii]?[Dd]?[^%d]*(%d+)")
    if A == nil then
      A = e:match("(%d+)")
    end
    if A ~= nil then
      local e = tonumber(A)
      if e ~= nil and e > 0 then
        return math["floor"](e)
      end
    end
    return nil
  end
  if type(e) == "table" then
    local O = { e["id"], e["itemid"], e["itemID"], e["value"], e["item"], e["name"], e["itemName"], e["selected"] }
    for e, O in ipairs(O) do
      local P = kP(O)
      if P ~= nil and P > 0 then
        return P
      end
    end
  end
  return nil
end
local function KP(e)
  if e == nil or e < 1 or e > 65535 then
    return false
  end
  e = math["floor"](e)
  if e == j then
    return true
  end
  if b or C or d or (v == j and (L > 0 and jP(j) > 0)) then
    s("AVD_itemid", j)
    bP("Finish stopping and store any purchased items before changing Item ID.")
    return true
  end
  j = e
  L = 0
  v = 0
  H = nil
  R = nil
  r = {}
  s("AVD_itemid", j)
  vP()
  LP()
  qP()
  Y()
  bP("Target Item = " .. (UP(e) .. (" (" .. (e .. ")"))))
  return true
end
local function MP(e)
  return KP(kP(e))
end
local function hP(e)
  if type(e) == "table" then
    local O = tonumber(e["x"] or e["tileX"] or e["tilex"] or e["px"])
    local P = tonumber(e["y"] or e["tileY"] or e["tiley"] or e["py"])
    if O ~= nil and P ~= nil then
      return math["floor"](O), math["floor"](P)
    end
    if type(e["pos"]) == "table" then
      O = tonumber(e["pos"]["x"] or e["pos"][1])
      P = tonumber(e["pos"]["y"] or e["pos"][2])
      if O ~= nil and P ~= nil then
        return math["floor"](O), math["floor"](P)
      end
    end
    O = tonumber(e[1])
    P = tonumber(e[2])
    if O ~= nil and P ~= nil then
      return math["floor"](O), math["floor"](P)
    end
    for e, O in pairs(e) do
      if type(O) == "table" then
        local e = tonumber(O["x"] or O["tileX"] or O["tilex"] or O["px"] or O[1])
        local P = tonumber(O["y"] or O["tileY"] or O["tiley"] or O["py"] or O[2])
        if e ~= nil and P ~= nil then
          return math["floor"](e), math["floor"](P)
        end
      elseif type(O) == "string" then
        local e, P = O:match("%(%s*(-?%d+)%s*,%s*(-?%d+)%s*%)")
        if e == nil then
          e, P = O:match("(-?%d+)%s*[,|:]%s*(-?%d+)")
        end
        if e ~= nil and P ~= nil then
          return tonumber(e), tonumber(P)
        end
      end
    end
  elseif type(e) == "string" then
    local O, P = e:match("%(%s*(-?%d+)%s*,%s*(-?%d+)%s*%)")
    if O == nil then
      O, P = e:match("(-?%d+)%s*[,|:]%s*(-?%d+)")
    end
    if O ~= nil and P ~= nil then
      return tonumber(O), tonumber(P)
    end
  end
  return nil, nil
end
local function lP()
  local e = YP(F, B)
  if e == nil then
    return nil, "Vending tile is not loaded."
  end
  if e["fg"] ~= 2978 and e["fg"] ~= 9268 then
    return nil, "Selected tile is not a vending machine."
  end
  local O = e["extra"]
  if O == nil then
    return nil, "Selected vending has no vending data."
  end
  local P = tonumber(O["vend_item"] or 0) or 0
  local A = tonumber(O["vend_price"] or 0) or 0
  if P == 0 then
    return nil, "Selected vending is empty."
  end
  if P ~= j then
    return nil, "Vending sells " .. (UP(P) .. (" (" .. (tostring(P) .. "), not selected item.")))
  end
  editValue("AVD_vendprice", tostring(A))
  return { ["x"] = F, ["y"] = B, ["price"] = A, ["itemID"] = P }, nil
end
local function XP()
  if R ~= nil then
    return R
  end
  R = {}
  if not H or H == 0 then
    return R
  end
  local e, O = pcall(function()
    if type(GetTiles) == "function" then
      return GetTiles()
    end
    return getTiles()
  end)
  if not e or type(O) ~= "table" then
    return R
  end
  for e, O in pairs(O) do
    if O and ((tonumber(O["fg"]) == 2978 or tonumber(O["fg"]) == 9268) and O["extra"] ~= nil) then
      local e = O["extra"]
      local P = tonumber(e["vend_item"])
      local A = tonumber(e["vend_price"])
      local S, Z = tonumber(O["x"]), tonumber(O["y"])
      if P == j and (A == H and (S and Z)) then
        R[#R + 1] = { ["x"] = math["floor"](S), ["y"] = math["floor"](Z), ["itemID"] = P, ["price"] = A }
      end
    end
  end
  dP("CACHED SAME-PRICE VENDS: " .. tostring(#R))
  return R
end
local function gP()
  local e, O = F, B
  r[w(F, B)] = true
  local P = XP()
  local A, S = nil, math["huge"]
  for P, Z in ipairs(P) do
    if not r[w(Z["x"], Z["y"])] then
      local P = math["abs"](Z["x"] - e) + math["abs"](Z["y"] - O)
      if P < S or (P == S and (A and (Z["y"] < A["y"] or (Z["y"] == A["y"] and Z["x"] < A["x"])))) then
        A, S = Z, P
      end
    end
  end
  if not A then
    dP("NO MORE SAME-PRICE VENDS")
    return false
  end
  F, B = A["x"], A["y"]
  s("AVD_vendx", tostring(F))
  s("AVD_vendy", tostring(B))
  FP()
  editValue("AVD_vendprice", tostring(H))
  dP("NEXT VEND " .. (tostring(F) .. ("," .. tostring(B))))
  Y()
  return true
end
local function et()
  local e, O = rP()
  if e == F and O == B then
    return true
  end
  dP("MOVE TO VEND " .. (tostring(F) .. ("," .. tostring(B))))
  if not TP(F, B) then
    return false
  end
  e, O = rP()
  return e == F and O == B
end
local function Ot(e, O)
  local P = tonumber(e:match("embed_data|tilex|(%-?%d+)")) or O["x"]
  local A = tonumber(e:match("embed_data|tiley|(%-?%d+)")) or O["y"]
  local S = tonumber(e:match("embed_data|expectitem|(%-?%d+)"))
    or tonumber(e:match("expectitem|(%-?%d+)"))
    or O["itemID"]
  local Z = tonumber(e:match("embed_data|expectprice|(%-?%d+)"))
    or tonumber(e:match("expectprice|(%-?%d+)"))
    or O["price"]
  local E = e:match("contains a total of%s+([%d,]+)") or e:match("contains%s+([%d,]+)")
  local c = nil
  if E ~= nil then
    E = (tostring(E)):gsub(",", "")
    c = tonumber(E)
  end
  return { ["x"] = P, ["y"] = A, ["itemID"] = S, ["price"] = Z, ["stock"] = c }
end
local function Pt(e)
  if not b then
    return nil
  end
  local O = WP()
  if O == nil then
    return nil
  end
  JP = true
  yP = false
  pP = ""
  dP("OPEN VENDING")
  local P = pcall(function()
    SendPacketRaw(false, { ["type"] = 3, ["value"] = 32, ["px"] = F, ["py"] = B, ["x"] = O["posX"], ["y"] = O["posY"] })
  end)
  if not P then
    JP = false
    return nil
  end
  local A = 0
  while b and A < tP do
    if yP then
      local O = pP
      JP = false
      yP = false
      pP = ""
      return Ot(O, e)
    end
    Sleep(50)
    A = A + 50
  end
  JP = false
  yP = false
  pP = ""
  return nil
end
local function At(e)
  local O = Pt(e)
  if O ~= nil or not b then
    return O
  end
  for P = 1, AP, 1 do
    if not b then
      return nil
    end
    dP("VEND REPATH " .. (tostring(P) .. ("/" .. (tostring(AP) .. (" -> " .. (tostring(F) .. ("," .. tostring(B))))))))
    pcall(function()
      FindPath(F, B)
    end)
    local A = 0
    while b and A < OP do
      if nP(F, B) then
        break
      end
      Sleep(100)
      A = A + 100
    end
    if not b then
      return nil
    end
    dP("RETRY VENDING")
    O = Pt(e)
    if O ~= nil then
      return O
    end
    Sleep(300)
  end
  return nil
end
local function St(e, O)
  SendPacket(
    2,
    "action|dialog_return\n"
      .. (
        "dialog_name|vending\n"
        .. (
          "tilex|"
          .. (
            tostring(e["x"])
            .. (
              "|\n"
              .. (
                "tiley|"
                .. (
                  tostring(e["y"])
                  .. (
                    "|\n"
                    .. (
                      "verify|1|\n"
                      .. (
                        "buycount|"
                        .. (
                          tostring(O)
                          .. (
                            "|\n"
                            .. (
                              "expectprice|"
                              .. (
                                tostring(e["price"]) .. ("|\n" .. ("expectitem|" .. (tostring(e["itemID"]) .. "|\n")))
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
local function Zt(e)
  e = tonumber(e) or 0
  if e <= -2 then
    return math["floor"](math["abs"](e))
  end
  return 1
end
local function Et(e, O)
  e = math["max"](0, math["floor"](tonumber(e) or 0))
  O = math["max"](1, math["floor"](tonumber(O) or 1))
  return math["floor"](e / O) * O
end
local function ct(e, O)
  local P = math["floor"](e / O)
  if P <= 1 then
    return 0
  end
  return math["max"](1, math["floor"](P / 2)) * O
end
local function ut(e)
  e = math["floor"](tonumber(e) or 0)
  if e < 1 then
    return true
  end
  if not RP(a, "BUY") then
    QP("Could not enter buy world.")
    return false
  end
  LP()
  dP("GO TO VENDING")
  local O = nil
  local function P()
    local e, P = lP()
    while b and (e == nil or (H and e["price"] ~= H)) do
      if not H then
        QP(P or "Choose a vending that sells the selected item.")
        return nil, false
      end
      if not gP() then
        return nil, "DEPLETED"
      end
      O = nil
      e, P = lP()
    end
    return e, nil
  end
  local A, S = P()
  if not A then
    return S or false
  end
  if not H then
    H = A["price"]
    Y()
  end
  if H == 0 then
    QP("Starting vending has no usable price. Select a stocked vend.")
    return false
  end
  if not et() then
    QP("Cannot reach selected vending (" .. (F .. ("," .. (B .. ")."))))
    return false
  end
  while b and (jP(j) < e and L < U) do
    ::next_buy_cycle::
    A, S = P()
    if not A then
      return S or false
    end
    if not et() then
      QP("Could not reach next vending (" .. (F .. ("," .. (B .. ")."))))
      return false
    end
    local Z = jP(j)
    local E = U - L
    local c = G - Z
    local u = math["min"](e - Z, E, c)
    local J = Zt(H)
    local y = Et(u, J)
    if y < J then
      if Z > 0 and E >= J then
        dP("BACKPACK PRICE-UNIT FULL - STORE " .. Z)
        return true
      end
      dP("UNBUYABLE FINAL PRICE REMAINDER " .. E)
      return "UNIT_REMAINDER"
    end
    if O ~= nil then
      y = Et(math["min"](y, O), J)
      if y < J then
        if not gP() then
          return "DEPLETED"
        end
        O = nil
        Sleep(h)
        goto next_buy_cycle
      end
    end
    local p = false
    local t = At(A)
    if t == nil then
      QP("Vending dialog did not open. Stock cannot be checked safely.")
      return false
    end
    if tonumber(t["x"]) ~= A["x"] or tonumber(t["y"]) ~= A["y"] then
      QP("Different vending opened; cannot confirm exact price.")
      return false
    end
    if tonumber(t["itemID"]) ~= j or tonumber(t["price"]) ~= H then
      dP("VEND ITEM/PRICE CHANGED - SKIP")
    else
      local e = tonumber(t["stock"])
      if e == nil then
        QP("Vending stock was not found in the dialog.")
        return false
      end
      y = Et(math["min"](y, e), J)
      if y < J then
        dP("VEND STOCK BELOW BUY UNIT @ " .. (F .. ("," .. B)))
      else
        dP("BUY " .. (y .. (" / STOCK " .. e)))
        if not b then
          return false
        end
        St(t, y)
        local O = 0
        while O < K do
          local e = jP(j)
          if e > Z then
            break
          end
          Sleep(100)
          O = O + 100
        end
        local P = jP(j)
        if P <= Z then
          Sleep(X)
          P = jP(j)
        end
        if P > Z then
          local e = P - Z
          v = j
          L = L + e
          if not Y() then
            LP()
            qP()
            QP("Purchase confirmed but progress could not be saved. Retry Start after storage is available.")
            return false
          end
          LP()
          qP()
          if not b then
            return false
          end
          dP("BOUGHT " .. (e .. (" / REQUESTED " .. y)))
          p = true
        else
          if not b then
            return false
          end
          dP("BUY NOT CONFIRMED @ " .. (F .. ("," .. B)))
        end
      end
    end
    if not b then
      return false
    end
    if not p then
      if not gP() then
        dP("ALL MATCHING VENDS EXHAUSTED - STORE FIRST")
        return "DEPLETED"
      end
      O = nil
      if not et() then
        QP("Could not reach next same-price vending.")
        return false
      end
    end
    Sleep(h)
  end
  return b and (jP(j) >= e or L >= U)
end
local function Jt(e, O)
  e = math["floor"](tonumber(e) or 0)
  if e < 1 or jP(j) < 1 then
    return true
  end
  if not RP(q, "STORAGE") or not IP(q) then
    QP("Could not enter storage world or its linked door.")
    return false
  end
  while b and jP(j) > 0 do
    if not IP(q) then
      dP("WAIT STORAGE WORLD - NO DROP")
      return false
    end
    dP("STORAGE PATH -> " .. (f .. ("," .. Q)))
    if not TP(f, Q) then
      dP("WAIT STORAGE POSITION " .. (f .. ("," .. Q)))
      return false
    end
    if not nP(f, Q) then
      dP("NOT AT DROP TILE - NO DROP")
      return false
    end
    local e = false
    for O = 1, 2, 1 do
      if not b or not IP(q) or not nP(f, Q) then
        dP("DROP POSITION LOST - NO SHIFT")
        return false
      end
      local P = jP(j)
      if P < 1 then
        return true
      end
      dP("DROP " .. (O .. ("/2 @ " .. (f .. ("," .. Q)))))
      VP = true
      zP = false
      local A = pcall(function()
        SendPacket(2, "action|drop\nitemID|" .. tostring(j))
      end)
      if not A then
        VP = false
        zP = false
        dP("DROP REQUEST ERROR - WAIT")
        return false
      end
      local S = 0
      while b and (IP(q) and S < DP) do
        if zP or jP(j) < P then
          break
        end
        Sleep(100)
        S = S + 100
      end
      local Z = zP
      VP = false
      zP = false
      if not b or not IP(q) then
        return false
      end
      if not nP(f, Q) then
        dP("MOVEMENT DURING DROP - NO SHIFT")
        return false
      end
      if jP(j) < P then
        e = true
        break
      end
      if Z then
        local e = pcall(function()
          SendPacket(
            2,
            "action|dialog_return\n"
              .. ("dialog_name|drop_item\n" .. ("itemID|" .. (tostring(j) .. ("|\n" .. ("count|" .. tostring(P))))))
          )
        end)
        if not e then
          dP("DROP CONFIRM ERROR - WAIT")
          return false
        end
        S = 0
        while b and (IP(q) and S < M) do
          if jP(j) < P then
            break
          end
          Sleep(100)
          S = S + 100
        end
      else
        dP("DROP DIALOG NOT OPENED " .. (O .. "/2"))
      end
      if jP(j) >= P then
        Sleep(850)
      end
      LP()
      if jP(j) < P then
        e = true
        break
      end
      if not IP(q) or not nP(f, Q) then
        dP("DROP POSITION CHANGED - NO SHIFT")
        return false
      end
      if O == 1 then
        dP("DROP FAILED - RETRY SAME TILE")
        Sleep(550)
      end
    end
    if e then
      I = 0
      LP()
      if jP(j) == 0 then
        dP("STORAGE DROP COMPLETE")
        return true
      end
      Sleep(250)
    else
      if f <= 0 then
        QP("Storage is full all the way to the left edge.")
        return false
      end
      f = f - 1
      I = 0
      pcall(function()
        editValue("AVD_activedrop", f .. (", " .. Q))
      end)
      dP("DROP FULL / SHIFT LEFT -> " .. (f .. ("," .. Q)))
      bP("Storage moved left to " .. (f .. ("," .. Q)))
      Y()
      Sleep(800)
      return false
    end
  end
  return jP(j) == 0
end
local function yt()
  local e = jP(j)
  LP()
  if e < 1 then
    return true
  end
  return Jt(e, "Dropped all selected item")
end
local function pt()
  local e = jP(j)
  LP()
  if e < 1 then
    bP("Inventory check: no existing target item.")
    return true
  end
  dP("INITIAL DROP")
  bP("Inventory check: dropping existing " .. (tostring(e) .. (" " .. (UP(j) .. " first."))))
  return Jt(e, "Initial inventory dropped")
end
local function tt()
  x["AVD_enable"] = true
  pcall(function()
    EditToggle("AVD_enable", false)
  end)
  pcall(function()
    editToggle("AVD_enable", false)
  end)
  x["AVD_enable"] = nil
end
function onVariant(e, O)
  if e ~= nil and (e["v1"] == "OnDialogRequest" and type(e["v2"]) == "string") then
    local O = e["v2"]
    if b and (VP and O:find("drop_item", 1, true)) then
      zP = true
      return true
    end
    if
      b
      and (
        JP
        and (
          O:find("end_dialog|vending", 1, true) and (
            O:find("embed_data|tilex|", 1, true) or O:find("expectitem|", 1, true)
          )
        )
      )
    then
      pP = O
      yP = true
      return true
    end
  end
  return false
end
function onValue(O, P, A)
  if x[P] then
    return
  end
  if P == "AVD_totalbought" or P == "AVD_totalremaining" then
    return
  end
  if P == "AVD_enable" then
    if A == true then
      if b or C then
        return
      end
      if m then
        tt()
        bP("Wait for Find Vend to finish.")
        return
      end
      if d then
        tt()
        bP("The previous run is still stopping. Try Start again shortly.")
        return
      end
      W = W + 1
      local e = W
      C = true
      runThread(function()
        if L > 0 and v ~= j then
          QP(
            "Saved progress belongs to item "
              .. (v .. ". Reselect it to resume, or edit Total Buy Amount for a new target.")
          )
          return
        end
        if not Y() then
          QP("Settings storage is required to save purchase progress.")
          return
        end
        R = nil
        r = {}
        n = false
        T = ""
        if f > o or f < 0 then
          f = o
        end
        I = 0
        pcall(function()
          editValue("AVD_activedrop", f .. (", " .. Q))
        end)
        N = false
        pcall(function()
          editValue("AVD_activedrop", f .. (", " .. Q))
        end)
        local O = nil
        local P = fP(a)
        if CP() == P then
          O = lP()
        end
        if O ~= nil then
          H = O["price"]
        end
        uP = true
        s("AVD_itemid", tostring(j))
        vP()
        LP()
        qP()
        if j <= 0 then
          QP("Choose a valid target item first.")
          return
        end
        if U < 1 then
          QP("Total Buy Amount must be at least 1.")
          return
        end
        if mP(a) == "" then
          QP("Set Buy World first.")
          return
        end
        if mP(q) == "" then
          QP("Set Drop World first.")
          return
        end
        if not oP(true) then
          QP("Could not enable ModFly at start.")
          return
        end
        if W ~= e then
          return
        end
        C = false
        b = true
        dP("STARTING")
        bP("Started. Bought " .. (L .. ("/" .. (U .. ("; remaining " .. (math["max"](0, U - L) .. "."))))))
      end)
    else
      W = W + 1
      C = false
      b = false
      oP(false)
      VP = false
      zP = false
      JP = false
      yP = false
      pP = ""
      dP("STOPPED")
      bP(e .. " stopped.")
    end
    return
  end
  if P == "AVD_itempicker" then
    if not MP(A) then
      bP("Could not read item from Item Picker.")
    end
    return
  end
  if P == "AVD_itemid" then
    if not KP(tonumber(A)) then
      s("AVD_itemid", j)
    end
    return
  end
  if P == "AVD_totalbuyamount" then
    local e = tonumber(A)
    if e == nil then
      s("AVD_totalbuyamount", U)
      return
    end
    e = math["min"](999999, math["max"](1, math["floor"](e)))
    if e ~= U then
      if b or C or d then
        bP("Stop Auto Vend and let the current action finish before editing Total Buy Amount.")
      else
        U = e
        L = 0
        v = 0
        qP()
        Y()
      end
    end
    s("AVD_totalbuyamount", U)
    return
  end
  if P == "AVD_buyworld" then
    a = mP(A)
    Y()
    return
  end
  if P == "AVD_setbuyworld" then
    local e = CP()
    if e == "" or e == "EXIT" then
      bP("Current world is not available.")
      return
    end
    a = e
    s("AVD_buyworld", a)
    Y()
    bP("Buy World = " .. a)
    return
  end
  if P == "AVD_vendx" then
    local e = tonumber(A)
    if e ~= nil then
      F = math["floor"](e)
      H = nil
      R = nil
      r = {}
      FP()
      Y()
    end
    return
  end
  if P == "AVD_vendy" then
    local e = tonumber(A)
    if e ~= nil then
      B = math["floor"](e)
      H = nil
      R = nil
      r = {}
      FP()
      Y()
    end
    return
  end
  if P == "AVD_findvend" then
    GP()
    return
  end
  if P == "AVD_setvend" then
    if m then
      bP("Wait for Find Vend to finish.")
      return
    end
    local e, O = rP()
    if e == nil or O == nil then
      bP("Player position is not available.")
      return
    end
    F = e
    B = O
    s("AVD_vendx", tostring(F))
    s("AVD_vendy", tostring(B))
    FP()
    local P = lP()
    if P ~= nil then
      editValue("AVD_vendprice", tostring(P["price"]))
      H = P["price"]
    else
      editValue("AVD_vendprice", "NONE")
    end
    Y()
    bP("Vending position = (" .. (tostring(F) .. (", " .. (tostring(B) .. ")"))))
    return
  end
  if P == "AVD_dropworld" then
    q = mP(A)
    Y()
    return
  end
  if P == "AVD_setdropworld" then
    local e = CP()
    if e == "" or e == "EXIT" then
      bP("Current world is not available.")
      return
    end
    q = e
    s("AVD_dropworld", q)
    Y()
    bP("Drop World = " .. q)
    return
  end
  if P == "AVD_dropx" then
    local e = tonumber(A)
    if e ~= nil then
      o = math["floor"](e)
      f = o
      I = 0
      pcall(function()
        editValue("AVD_activedrop", f .. (", " .. Q))
      end)
      Y()
    end
    return
  end
  if P == "AVD_dropy" then
    local e = tonumber(A)
    if e ~= nil then
      Q = math["floor"](e)
      pcall(function()
        editValue("AVD_activedrop", f .. (", " .. Q))
      end)
      Y()
    end
    return
  end
  if P == "AVD_setdrop" then
    local e, O = rP()
    if e == nil or O == nil then
      bP("Player position is not available.")
      return
    end
    o = e
    Q = O
    f = e
    I = 0
    pcall(function()
      editValue("AVD_activedrop", f .. (", " .. Q))
    end)
    s("AVD_dropx", tostring(o))
    s("AVD_dropy", tostring(Q))
    Y()
    bP("Drop stand position = (" .. (tostring(o) .. (", " .. (tostring(Q) .. ")"))))
    return
  end
end
applyHook()
if type(setOnValue) == "function" then
  pcall(function()
    setOnValue("AVD_itempicker", function(...)
      local e = { ... }
      for O = #e, 1, -1 do
        if MP(e[O]) then
          return
        end
      end
    end)
  end)
  for e, O in ipairs({ "AVD_buyworld", "AVD_vendx", "AVD_vendy", "AVD_dropworld", "AVD_dropx", "AVD_dropy" }) do
    local P = O
    pcall(setOnValue, P, function(...)
      local e = select("#", ...)
      if e > 0 then
        onValue(nil, P, select(e, ...))
      end
    end)
  end
end
runThread(function()
  dP("STOPPED")
  vP()
  LP()
  qP()
  FP()
  pcall(function()
    editValue("AVD_activedrop", f .. (", " .. Q))
  end)
  if Z ~= nil and not c then
    Y()
  end
  while true do
    if b then
      d = true
      LP()
      qP()
      if uP then
        if pt() then
          uP = false
          Sleep(h)
        else
          Sleep(350)
        end
      elseif N then
        if jP(j) == 0 then
          N = false
        elseif yt() then
          N = (jP(j) > 0)
          Sleep(h)
        else
          Sleep(450)
        end
      elseif n then
        if jP(j) > 0 then
          N = true
          dP("ALL VENDS DONE - STORE REMAINING ITEMS")
        else
          dP("ALL VENDS DONE - RETURN TO STORAGE")
          if RP(q, "STORAGE") and IP(q) then
            QP(T ~= "" and T or "No more purchasable same-price vends.")
          else
            dP("WAIT STORAGE BEFORE AUTOMATIC STOP")
            Sleep(700)
          end
        end
      elseif L >= U then
        if jP(j) > 0 then
          N = true
        else
          QP("Total buy target reached: " .. (tostring(L) .. ("/" .. tostring(U))))
        end
      else
        local e = U - L
        local O = math["min"](G, e)
        local P = ut(O)
        if P == "DEPLETED" or P == "UNIT_REMAINDER" then
          n = true
          T = P == "DEPLETED" and "No more purchasable same-price vending stock. Stored and stopped."
            or "Remaining target cannot be bought in whole price units. Stored and stopped."
          N = jP(j) > 0
          dP("BUYING FINISHED - STORE THEN STOP")
        elseif P == true then
          N = jP(j) > 0
          if not N then
            Sleep(250)
          end
        else
          if b and jP(j) > 0 then
            N = true
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
