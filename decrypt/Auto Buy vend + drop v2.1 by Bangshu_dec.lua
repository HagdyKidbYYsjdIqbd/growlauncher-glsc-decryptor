setMinimum("6.1.2")
local G =
  "https://script.google.com/macros/s/AKfycbxeBzpOUzvcRDkX-4eR8uioFbAUDsepIQc26kmxUkXt6YOjBxFdVsOE0zzvxYSprl5knA/exec"
local k = "AUTOVEND"
local Q = "AutoVendToDropLicense"
local l = "license_key"
local g = nil
local J = ""
local function v(G)
  G = tostring(G or "")
  G = G:gsub("%s+", "")
  return G:upper()
end
local function N(G)
  G = v(G)
  return G:match("^[A-Z]%d%d%d%d%d%d%d$") ~= nil
end
local function Y()
  local G = pcall(function()
    local G = nil
    if type(require) == "function" then
      local k, Q = pcall(require, "preferences")
      if k and Q ~= nil then
        G = Q
      end
    end
    if G == nil and type(Preferences) == "table" then
      G = Preferences
    end
    if G == nil then
      return
    end
    if type(G["new"]) == "function" then
      local k = G:new(Q)
      g = k or G
    else
      g = G
    end
    if g ~= nil and type(g["load"]) == "function" then
      g:load()
    end
    if g ~= nil and type(g["get"]) == "function" then
      J = v(g:get(l, ""))
    end
  end)
  if not G then
    g = nil
    J = ""
  end
end
local function S(G)
  if g == nil then
    return false
  end
  local k = pcall(function()
    g:set(l, v(G))
    g:save()
  end)
  return k
end
local function B()
  if g == nil then
    return false
  end
  local G = pcall(function()
    g:set(l, "")
    g:save()
  end)
  return G
end
Y()
local Z = "AutoVendSettingsV31"
local i = "31"
local P = {
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
local d = {
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
local y = nil
local a = {}
local W = false
for G, k in pairs(P) do
  a[G] = k
end
local function o()
  local G = pcall(function()
    local G = nil
    if type(require) == "function" then
      local k, Q = pcall(require, "preferences")
      if k and type(Q) == "table" then
        G = Q
      end
    end
    if G == nil and type(Preferences) == "table" then
      G = Preferences
    end
    if G == nil or type(G["new"]) ~= "function" then
      return
    end
    local k = G:new(Z)
    if
      k == nil
      or type(k["load"]) ~= "function"
      or type(k["get"]) ~= "function"
      or type(k["set"]) ~= "function"
      or type(k["save"]) ~= "function"
    then
      return
    end
    if k:load() == false then
      return
    end
    y = k
    if tostring(k:get("schema", "")) == i then
      for G, Q in ipairs(d) do
        a[Q] = tostring(k:get(Q, P[Q]))
      end
      W = true
    end
  end)
  if not G then
    y = nil
  end
end
o()
local function U(G, k, Q, l)
  local g = math["floor"](tonumber(a[G]) or k)
  return math["min"](l, math["max"](Q, g))
end
local function t(G)
  return ((tostring(a[G] or "")):upper()):gsub("%s+", "")
end
local T = UserInterface["new"]("Auto Vend V2.1", "ShoppingCart")
T:addLabelApp("Auto Vend V2.1 - Total Buy Only", "ShoppingCart")
T:addInputString("License Key", J, "A1234567", "A1234567", nil, "AVD_licensekey")
T:addButton("Verify License", "AVD_verifylicense")
T:addButton("Clear Saved License", "AVD_clearlicense")
T:addDisplayList("License Status", "NOT VERIFIED", "AVD_licensestatus")
T:addToggle("Start / Stop", false, "AVD_enable")
T:addInputString(
  "Buy Progress (view only)",
  "0 / " .. tostring(a["totalbuyamount"]),
  "Bought / total target",
  "0 / 1000",
  nil,
  "AVD_totalbought"
)
T:addInputString(
  "Remaining to Buy (view only)",
  tostring(a["totalbuyamount"]),
  "Items left",
  "1000",
  nil,
  "AVD_totalremaining"
)
T:addItemPicker("Pick Target Item", a["itemid"], a["itemid"], "AVD_itempicker")
T:addInputInt("Item ID", a["itemid"], "ID", "5706", nil, "AVD_itemid")
T:addDisplayList("Selected Item", a["itemid"], "AVD_selecteditem")
T:addInputInt("Total Buy Amount", a["totalbuyamount"], "items total", "1000", nil, "AVD_totalbuyamount")
T:addInputString("Buy World", a["buyworld"], "WORLD|DOORID", "BUY WORLD or WORLD|DOORID", nil, "AVD_buyworld")
T:addButton("Set Buy World = Current World", "AVD_setbuyworld")
T:addInputInt("Vending Position X", a["vendx"], "X", "0", nil, "AVD_vendx")
T:addInputInt("Vending Position Y", a["vendy"], "Y", "0", nil, "AVD_vendy")
T:addButton("Set Vending = Current Tile", "AVD_setvend")
T:addDisplayList("Selected Vending", "0, 0", "AVD_vendpos")
T:addDisplayList("Vending Price", a["lockedprice"] ~= "" and a["lockedprice"] or "NONE", "AVD_vendprice")
T:addInputString("Drop World", a["dropworld"], "WORLD|DOORID", "DROP WORLD or WORLD|DOORID", nil, "AVD_dropworld")
T:addButton("Set Drop World = Current World", "AVD_setdropworld")
T:addInputInt("Drop Stand Position X", a["dropx"], "X", "0", nil, "AVD_dropx")
T:addInputInt("Drop Stand Position Y", a["dropy"], "Y", "0", nil, "AVD_dropy")
T:addButton("Set Drop Position = Current Tile", "AVD_setdrop")
T:addDisplayList("Current Drop Tile", a["activedropx"] .. (", " .. a["dropy"]), "AVD_activedrop")
T:addDisplayList("ModFly (Session)", "OFF", "AVD_travelfly")
T:addDisplayList("Settings AutoSave", y == nil and "UNAVAILABLE" or (W and "RESTORED" or "READY"), "AVD_autosave")
T:addDisplayList("Status", "STOPPED", "AVD_status")
T:addDisplayList("Item Inventory", "0 / 200", "AVD_inventory")
local b = "Auto Vend V2.1"
pcall(function()
  if type(addCategory) == "function" then
    addCategory(b, "ShoppingCart")
  end
end)
local w = T:generateJSON()
local u = pcall(function()
  addIntoModule(w, b)
end)
if not u then
  pcall(function()
    growtopia["notify"]("Auto Vend V2.1 menu could not be created on this Growlauncher build.")
  end)
end
local H = false
local L = false
local R = J
local q = false
local M = false
local A = false
local O = 0
local n = "NOT VERIFIED"
local r = U("itemid", 5706, 1, 65535)
local e = U("totalbuyamount", 200, 1, 999999)
local s = U("progressitem", 0, 0, 65535)
local F = U("totalbought", 0, 0, 999999)
local p = t("buyworld")
local V = t("dropworld")
local c = U("vendx", 0, 0, 199)
local D = U("vendy", 0, 0, 119)
local C = U("dropx", 0, 0, 199)
local E = U("dropy", 0, 0, 119)
local x = U("activedropx", C, 0, 199)
local I = 0
local m = false
local K = tonumber(a["lockedprice"])
local X = nil
local f = {}
local z = false
local j = ""
local function h()
  if y == nil then
    pcall(function()
      editValue("AVD_autosave", "UNAVAILABLE")
    end)
    return false
  end
  local G = {
    ["itemid"] = tostring(r),
    ["totalbuyamount"] = tostring(e),
    ["progressitem"] = tostring(s),
    ["totalbought"] = tostring(F),
    ["buyworld"] = tostring(p),
    ["dropworld"] = tostring(V),
    ["vendx"] = tostring(c),
    ["vendy"] = tostring(D),
    ["dropx"] = tostring(C),
    ["dropy"] = tostring(E),
    ["activedropx"] = tostring(x),
    ["lockedprice"] = K and tostring(K) or "",
  }
  local k = false
  for Q, l in ipairs(d) do
    if a[l] ~= G[l] then
      k = true
      break
    end
  end
  if not k and W then
    return true
  end
  local Q = pcall(function()
    if y:set("schema", i) == false then
      error("schema")
    end
    for k, Q in ipairs(d) do
      if y:set(Q, G[Q]) == false then
        error("setting: " .. Q)
      end
    end
    if y:save() == false then
      error("save")
    end
  end)
  if Q then
    for G, k in pairs(G) do
      a[G] = k
    end
    W = true
  end
  pcall(function()
    editValue("AVD_autosave", Q and "SAVED" or "SAVE FAILED")
  end)
  return Q
end
local Gq = {}
local function kq(G, k)
  if Gq[G] then
    return
  end
  Gq[G] = true
  pcall(function()
    editValue(G, tostring(k))
  end)
  Gq[G] = nil
end
local function Qq(G, k)
  return tostring(G) .. ("," .. tostring(k))
end
local lq = 200
local gq = 15000
local Jq = 15000
local vq = 4200
local Nq = 3000
local Yq = 300
local Sq = 500
local Bq = 650
local Zq = 1000
local iq = 900
local Pq = 1200
local dq = 12000
local yq = 5
local aq = false
local Wq = 1500
local oq = 7
local Uq = "STOPPED"
local tq = true
local Tq = false
local bq = false
local wq = ""
local uq = 2500
local Hq = false
local Lq = false
local Rq = 2500
local function qq(G)
  pcall(function()
    growtopia["notify"](tostring(G))
  end)
end
local function Mq(G)
  n = tostring(G or "")
  pcall(function()
    editValue("AVD_licensestatus", n)
  end)
end
local function Aq(G)
  G = tostring(G or "")
  G = G:gsub("\n", "\r\n")
  G = G:gsub("([^%w%-_%.~])", function(G)
    return string["format"]("%%%02X", string["byte"](G))
  end)
  return G
end
local function Oq()
  local G = ""
  if type(getDiscordID) == "function" then
    local k, Q = pcall(getDiscordID)
    if k and Q ~= nil then
      G = tostring(Q)
    end
  elseif getDiscordID ~= nil then
    G = tostring(getDiscordID)
  end
  G = ((tostring(G or "")):gsub("^%s+", "")):gsub("%s+$", "")
  if G == "" or G == "nil" or G == "0" then
    local k = GetLocal or getLocal
    if k ~= nil then
      local Q, l = pcall(k)
      if Q and (l ~= nil and l["name"] ~= nil) then
        G = tostring(l["name"])
        G = (G:gsub("^%s+", "")):gsub("%s+$", "")
      end
    end
  end
  return G
end
local function nq(Q)
  if M then
    return false
  end
  M = true
  q = false
  local l = v(R)
  R = l
  pcall(function()
    editValue("AVD_licensekey", l)
  end)
  if not N(l) then
    Mq("INVALID KEY FORMAT")
    M = false
    if not Q then
      qq("License must be 1 letter + 7 numbers, for example A1234567.")
    end
    return false
  end
  local g = Oq()
  if g == "" then
    Mq("NO CLIENT ID")
    M = false
    if not Q then
      qq("Could not read a client ID. Enter the game first and try again.")
    end
    return false
  end
  Mq("CHECKING...")
  local Y = G .. ("?key=" .. (Aq(l) .. ("&id=" .. (Aq(g) .. ("&product=" .. Aq(k))))))
  local B, Z, i = pcall(fetch, Y)
  if not B then
    Mq("SERVER ERROR")
    M = false
    if not Q then
      qq("License server request failed.")
    end
    return false
  end
  Z = tostring(Z or "")
  Z = (Z:gsub("^%s+", "")):gsub("%s+$", "")
  if Z:find("OK|PERMANENT", 1, true) then
    q = true
    Mq("VERIFIED - PERMANENT")
    if S(l) then
      J = l
    end
    M = false
    if not Q then
      qq("License verified and saved.")
    end
    return true
  end
  local P = Z
  local d = "LICENSE CHECK FAILED"
  if P:find("DENY|DISABLED", 1, true) then
    Mq("DISABLED")
    d = "License disabled."
  elseif P:find("DENY|WRONG_PRODUCT", 1, true) then
    Mq("WRONG PRODUCT")
    d = "This license is for another script."
  elseif P:find("DENY|BOUND_TO_OTHER_USER", 1, true) then
    Mq("BOUND TO OTHER USER")
    d = "License is bound to another user."
  elseif P:find("DENY|INVALID_KEY", 1, true) then
    Mq("INVALID KEY")
    d = "Invalid license key."
  elseif P:find("DENY|BAD_KEY_FORMAT", 1, true) then
    Mq("BAD KEY FORMAT")
    d = "License key format is invalid."
  elseif P:find("DENY|NO_ID", 1, true) then
    Mq("NO CLIENT ID")
    d = "Client ID is unavailable."
  elseif P:find("DENY|", 1, true) then
    Mq("DENIED")
    d = "License denied by server."
  elseif P == "" then
    Mq("NO RESPONSE")
    d = "License server gave no response."
  else
    Mq("CHECK FAILED")
    d = "License check failed."
  end
  M = false
  if not Q then
    qq(d)
  end
  return false
end
local function rq(G)
  G = tostring(G)
  if Uq ~= G then
    Uq = G
    editValue("AVD_status", G)
  end
end
local function eq(G)
  G = tostring(G or "")
  G = G:gsub("%s+", "")
  return G:upper()
end
local function sq()
  local G, k = pcall(function()
    if type(GetWorldName) == "function" then
      return GetWorldName()
    end
    if type(getCurrentWorldName) == "function" then
      return getCurrentWorldName()
    end
    return ""
  end)
  if not G then
    return ""
  end
  return eq(k)
end
local function Fq()
  local G, k = pcall(function()
    return GetLocal()
  end)
  if G and k ~= nil then
    return k
  end
  G, k = pcall(function()
    return getLocal()
  end)
  if G then
    return k
  end
  return nil
end
local function pq(G)
  local k, Q = pcall(function()
    if growtopia ~= nil and type(growtopia["checkInventoryCount"]) == "function" then
      return growtopia["checkInventoryCount"](G)
    end
    local k = 0
    local Q = nil
    if type(GetInventory) == "function" then
      Q = GetInventory()
    elseif type(getInventory) == "function" then
      Q = getInventory()
    end
    if Q ~= nil then
      for Q, l in pairs(Q) do
        if tonumber(l["id"]) == tonumber(G) then
          k = tonumber(l["amount"]) or 0
          break
        end
      end
    end
    return k
  end)
  if not k then
    return 0
  end
  return tonumber(Q) or 0
end
local function Vq(G)
  local k, Q = pcall(function()
    if growtopia ~= nil and type(growtopia["getItemName"]) == "function" then
      return growtopia["getItemName"](G)
    end
    if type(getItemInfoByID) == "function" then
      local k = getItemInfoByID(G)
      if k ~= nil then
        return k["name"]
      end
    end
    return nil
  end)
  if k and (Q ~= nil and tostring(Q) ~= "") then
    return tostring(Q)
  end
  return "Item " .. tostring(G)
end
local function cq()
  editValue("AVD_selecteditem", Vq(r) .. (" (" .. (tostring(r) .. ")")))
end
local function Dq()
  editValue("AVD_inventory", tostring(pq(r)) .. " / 200")
end
local Cq = nil
local function Eq()
  local G = s == r and F or 0
  local k = math["max"](1, math["floor"](tonumber(e) or 1))
  local Q = math["max"](0, k - G)
  local l = math["min"](100, math["floor"]((G * 100) / k))
  local g = tostring(G) .. (" / " .. (tostring(k) .. (" (" .. (tostring(l) .. "%)"))))
  if g ~= Cq then
    Cq = g
    kq("AVD_totalbought", g)
    kq("AVD_totalremaining", tostring(Q))
  end
end
local function xq()
  editValue("AVD_vendpos", tostring(c) .. (", " .. tostring(D)))
end
local Iq = nil
local function mq(G)
  G = G == true
  if Iq == G then
    return true
  end
  local k = editToggle or EditToggle
  if type(k) ~= "function" then
    pcall(function()
      editValue("AVD_travelfly", "UNAVAILABLE")
    end)
    return false
  end
  local Q, l = pcall(k, "ModFly", G)
  if not Q or l == false then
    pcall(function()
      editValue("AVD_travelfly", "ERROR")
    end)
    return false
  end
  Iq = G
  pcall(function()
    editValue("AVD_travelfly", G and "ON (SESSION)" or "OFF")
  end)
  if G then
    Sleep(250)
  end
  return true
end
local function Kq(G)
  A = false
  H = false
  mq(false)
  Hq = false
  Lq = false
  Tq = false
  bq = false
  wq = ""
  pcall(function()
    EditToggle("AVD_enable", false)
  end)
  pcall(function()
    editToggle("AVD_enable", false)
  end)
  rq("STOPPED")
  if G ~= nil and G ~= "" then
    qq(G)
  end
end
local function Xq(G)
  G = eq(G)
  local k, Q = G:match("^([^|]+)|([^|]+)$")
  if k ~= nil then
    return k, Q
  end
  if G:find("|", 1, true) then
    return "", nil
  end
  return G, nil
end
local function fq(G)
  local k = Xq(G)
  if k == "" or sq() ~= k then
    return false
  end
  local Q = Fq()
  if Q == nil then
    return false
  end
  local l, g = pcall(function()
    if type(GetTiles) == "function" then
      return GetTiles()
    end
    return getTiles()
  end)
  return l and (g ~= nil and #g > 0)
end
local function zq(G, k)
  local Q = 0
  while H and Q < k do
    if fq(G) then
      Sleep(300)
      return H and fq(G)
    end
    Sleep(100)
    Q = Q + 100
  end
  return false
end
local jq = ""
local function hq(G, k)
  k = (k == "STORAGE") and "STORAGE" or "BUY"
  G = eq(G)
  local Q, l = Xq(G)
  if Q == "" then
    rq(k .. " INVALID WORLD OR DOOR ID")
    return false
  end
  local g = l ~= nil and l ~= ""
  if not g and fq(Q) then
    jq = ""
    aq = false
    return true
  end
  if g and (fq(Q) and jq == G) then
    aq = false
    return true
  end
  if not fq(Q) then
    rq(k .. (" WARP BASE " .. Q))
    jq = ""
    local G, l = pcall(function()
      return growtopia["warpTo"](Q)
    end)
    if not G or l == false then
      return false
    end
    if not zq(Q, gq) then
      return false
    end
    Sleep(Zq)
    if not H or not fq(Q) then
      return false
    end
  end
  if g then
    rq(k .. (" ENTER DOOR " .. (Q .. ("|" .. l))))
    local g, J = pcall(function()
      return SendPacket(3, "action|join_request\nname|" .. (G .. "\ninvitedWorld|0"))
    end)
    if not g or J == false then
      return false
    end
    Sleep(1400)
    if not zq(Q, gq) then
      return false
    end
    Sleep(Zq)
    if not H or not fq(Q) then
      return false
    end
    jq = G
    rq(k .. (" DOOR REQUEST SETTLED " .. (Q .. ("|" .. l))))
  else
    jq = ""
  end
  aq = true
  return true
end
local function Gp()
  local G = Fq()
  if G == nil then
    return nil, nil
  end
  return G["posX"] // 32, G["posY"] // 32
end
local function kp(G, k)
  local Q, l = Gp()
  return Q == G and l == k
end
local function Qp(G, k)
  if kp(G, k) then
    aq = false
    Sleep(150)
    return true
  end
  local Q = aq
  aq = false
  local l = 0
  local g = 0
  local J = 0
  while H and g < Jq do
    if kp(G, k) then
      Sleep(150)
      return true
    end
    if l < oq and g >= J then
      l = l + 1
      rq("PATH " .. (tostring(l) .. ("/" .. (tostring(oq) .. (" -> " .. (tostring(G) .. ("," .. tostring(k))))))))
      pcall(function()
        FindPath(G, k)
      end)
      if Q and l == 1 then
        J = g + iq
      else
        J = g + Wq
      end
    end
    Sleep(100)
    g = g + 100
  end
  return kp(G, k)
end
local function lp(G, k)
  local Q, l = pcall(function()
    if type(getTile) == "function" then
      return getTile(G, k)
    end
    return GetTile(G, k)
  end)
  if Q then
    return l
  end
  return nil
end
local function gp(G, k)
  local Q, l = Gp()
  if Q == nil or l == nil then
    return nil, "Player position is not available."
  end
  G = G or 4
  k = k or 2
  local g = {}
  for k = l - k, l + k, 1 do
    for G = Q - G, Q + G, 1 do
      local J = lp(G, k)
      if J ~= nil and (J["fg"] == 2978 or J["fg"] == 9268) then
        local v = J["extra"]
        local N = v and tonumber(v["vend_item"] or 0) or 0
        if N == r then
          local J = tonumber(v["vend_price"] or 0) or 0
          local N = math["abs"](Q - G) + math["abs"](l - k)
          table["insert"](g, { ["x"] = G, ["y"] = k, ["price"] = J, ["distance"] = N })
        end
      end
    end
  end
  if #g == 0 then
    return nil, "No nearby vending sells " .. (Vq(r) .. (" (" .. (tostring(r) .. ").")))
  end
  table["sort"](g, function(G, k)
    if G["distance"] == k["distance"] then
      if G["y"] == k["y"] then
        return G["x"] < k["x"]
      end
      return G["y"] < k["y"]
    end
    return G["distance"] < k["distance"]
  end)
  return g[1], nil
end
local function Jp(G)
  if type(G) ~= "string" or G == "" then
    return nil
  end
  local k, Q = pcall(function()
    if type(findItemID) == "function" then
      return findItemID(G)
    end
    if growtopia ~= nil and type(growtopia["getItemID"]) == "function" then
      return growtopia["getItemID"](G)
    end
    return nil
  end)
  if k and (tonumber(Q) ~= nil and tonumber(Q) > 0) then
    return math["floor"](tonumber(Q))
  end
  return nil
end
local function vp(G)
  if type(G) == "number" then
    return math["floor"](G)
  end
  if type(G) == "string" then
    local k = tonumber(G)
    if k ~= nil and k > 0 then
      return math["floor"](k)
    end
    local Q = Jp(G)
    if Q ~= nil then
      return Q
    end
    local l = G:match("[Ii][Tt][Ee][Mm][Ii]?[Dd]?[^%d]*(%d+)")
    if l == nil then
      l = G:match("(%d+)")
    end
    if l ~= nil then
      local G = tonumber(l)
      if G ~= nil and G > 0 then
        return math["floor"](G)
      end
    end
    return nil
  end
  if type(G) == "table" then
    local k = { G["id"], G["itemid"], G["itemID"], G["value"], G["item"], G["name"], G["itemName"], G["selected"] }
    for G, k in ipairs(k) do
      local Q = vp(k)
      if Q ~= nil and Q > 0 then
        return Q
      end
    end
  end
  return nil
end
local function Np(G)
  if G == nil or G < 1 or G > 65535 then
    return false
  end
  G = math["floor"](G)
  if G == r then
    return true
  end
  if H or A or L or (s == r and (F > 0 and pq(r) > 0)) then
    kq("AVD_itemid", r)
    qq("Finish stopping and store any purchased items before changing Item ID.")
    return true
  end
  r = G
  F = 0
  s = 0
  K = nil
  X = nil
  f = {}
  kq("AVD_itemid", r)
  cq()
  Dq()
  Eq()
  h()
  qq("Target Item = " .. (Vq(G) .. (" (" .. (G .. ")"))))
  return true
end
local function Yp(G)
  return Np(vp(G))
end
local function Sp(G)
  if type(G) == "table" then
    local k = tonumber(G["x"] or G["tileX"] or G["tilex"] or G["px"])
    local Q = tonumber(G["y"] or G["tileY"] or G["tiley"] or G["py"])
    if k ~= nil and Q ~= nil then
      return math["floor"](k), math["floor"](Q)
    end
    if type(G["pos"]) == "table" then
      k = tonumber(G["pos"]["x"] or G["pos"][1])
      Q = tonumber(G["pos"]["y"] or G["pos"][2])
      if k ~= nil and Q ~= nil then
        return math["floor"](k), math["floor"](Q)
      end
    end
    k = tonumber(G[1])
    Q = tonumber(G[2])
    if k ~= nil and Q ~= nil then
      return math["floor"](k), math["floor"](Q)
    end
    for G, k in pairs(G) do
      if type(k) == "table" then
        local G = tonumber(k["x"] or k["tileX"] or k["tilex"] or k["px"] or k[1])
        local Q = tonumber(k["y"] or k["tileY"] or k["tiley"] or k["py"] or k[2])
        if G ~= nil and Q ~= nil then
          return math["floor"](G), math["floor"](Q)
        end
      elseif type(k) == "string" then
        local G, Q = k:match("%(%s*(-?%d+)%s*,%s*(-?%d+)%s*%)")
        if G == nil then
          G, Q = k:match("(-?%d+)%s*[,|:]%s*(-?%d+)")
        end
        if G ~= nil and Q ~= nil then
          return tonumber(G), tonumber(Q)
        end
      end
    end
  elseif type(G) == "string" then
    local k, Q = G:match("%(%s*(-?%d+)%s*,%s*(-?%d+)%s*%)")
    if k == nil then
      k, Q = G:match("(-?%d+)%s*[,|:]%s*(-?%d+)")
    end
    if k ~= nil and Q ~= nil then
      return tonumber(k), tonumber(Q)
    end
  end
  return nil, nil
end
local function Bp()
  local G = lp(c, D)
  if G == nil then
    return nil, "Vending tile is not loaded."
  end
  if G["fg"] ~= 2978 and G["fg"] ~= 9268 then
    return nil, "Selected tile is not a vending machine."
  end
  local k = G["extra"]
  if k == nil then
    return nil, "Selected vending has no vending data."
  end
  local Q = tonumber(k["vend_item"] or 0) or 0
  local l = tonumber(k["vend_price"] or 0) or 0
  if Q == 0 then
    return nil, "Selected vending is empty."
  end
  if Q ~= r then
    return nil, "Vending sells " .. (Vq(Q) .. (" (" .. (tostring(Q) .. "), not selected item.")))
  end
  editValue("AVD_vendprice", tostring(l))
  return { ["x"] = c, ["y"] = D, ["price"] = l, ["itemID"] = Q }, nil
end
local function Zp()
  if X ~= nil then
    return X
  end
  X = {}
  if not K or K == 0 then
    return X
  end
  local G, k = pcall(function()
    if type(GetTiles) == "function" then
      return GetTiles()
    end
    return getTiles()
  end)
  if not G or type(k) ~= "table" then
    return X
  end
  for G, k in pairs(k) do
    if k and ((tonumber(k["fg"]) == 2978 or tonumber(k["fg"]) == 9268) and k["extra"] ~= nil) then
      local G = k["extra"]
      local Q = tonumber(G["vend_item"])
      local l = tonumber(G["vend_price"])
      local g, J = tonumber(k["x"]), tonumber(k["y"])
      if Q == r and (l == K and (g and J)) then
        X[#X + 1] = { ["x"] = math["floor"](g), ["y"] = math["floor"](J), ["itemID"] = Q, ["price"] = l }
      end
    end
  end
  rq("CACHED SAME-PRICE VENDS: " .. tostring(#X))
  return X
end
local function ip()
  local G, k = c, D
  f[Qq(c, D)] = true
  local Q = Zp()
  local l, g = nil, math["huge"]
  for Q, J in ipairs(Q) do
    if not f[Qq(J["x"], J["y"])] then
      local Q = math["abs"](J["x"] - G) + math["abs"](J["y"] - k)
      if Q < g or (Q == g and (l and (J["y"] < l["y"] or (J["y"] == l["y"] and J["x"] < l["x"])))) then
        l, g = J, Q
      end
    end
  end
  if not l then
    rq("NO MORE SAME-PRICE VENDS")
    return false
  end
  c, D = l["x"], l["y"]
  kq("AVD_vendx", tostring(c))
  kq("AVD_vendy", tostring(D))
  xq()
  editValue("AVD_vendprice", tostring(K))
  rq("NEXT VEND " .. (tostring(c) .. ("," .. tostring(D))))
  h()
  return true
end
local function Pp()
  local G, k = Gp()
  if G == c and k == D then
    return true
  end
  rq("MOVE TO VEND " .. (tostring(c) .. ("," .. tostring(D))))
  if not Qp(c, D) then
    return false
  end
  G, k = Gp()
  return G == c and k == D
end
local function dp(G, k)
  local Q = tonumber(G:match("embed_data|tilex|(%-?%d+)")) or k["x"]
  local l = tonumber(G:match("embed_data|tiley|(%-?%d+)")) or k["y"]
  local g = tonumber(G:match("embed_data|expectitem|(%-?%d+)"))
    or tonumber(G:match("expectitem|(%-?%d+)"))
    or k["itemID"]
  local J = tonumber(G:match("embed_data|expectprice|(%-?%d+)"))
    or tonumber(G:match("expectprice|(%-?%d+)"))
    or k["price"]
  local v = G:match("contains a total of%s+([%d,]+)") or G:match("contains%s+([%d,]+)")
  local N = nil
  if v ~= nil then
    v = (tostring(v)):gsub(",", "")
    N = tonumber(v)
  end
  return { ["x"] = Q, ["y"] = l, ["itemID"] = g, ["price"] = J, ["stock"] = N }
end
local function yp(G)
  if not H then
    return nil
  end
  local k = Fq()
  if k == nil then
    return nil
  end
  Tq = true
  bq = false
  wq = ""
  rq("OPEN VENDING")
  local Q = pcall(function()
    SendPacketRaw(false, { ["type"] = 3, ["value"] = 32, ["px"] = c, ["py"] = D, ["x"] = k["posX"], ["y"] = k["posY"] })
  end)
  if not Q then
    Tq = false
    return nil
  end
  local l = 0
  while H and l < uq do
    if bq then
      local k = wq
      Tq = false
      bq = false
      wq = ""
      return dp(k, G)
    end
    Sleep(50)
    l = l + 50
  end
  Tq = false
  bq = false
  wq = ""
  return nil
end
local function ap(G)
  local k = yp(G)
  if k ~= nil or not H then
    return k
  end
  for Q = 1, yq, 1 do
    if not H then
      return nil
    end
    rq("VEND REPATH " .. (tostring(Q) .. ("/" .. (tostring(yq) .. (" -> " .. (tostring(c) .. ("," .. tostring(D))))))))
    pcall(function()
      FindPath(c, D)
    end)
    local l = 0
    while H and l < Pq do
      if kp(c, D) then
        break
      end
      Sleep(100)
      l = l + 100
    end
    if not H then
      return nil
    end
    rq("RETRY VENDING")
    k = yp(G)
    if k ~= nil then
      return k
    end
    Sleep(300)
  end
  return nil
end
local function Wp(G, k)
  SendPacket(
    2,
    "action|dialog_return\n"
      .. (
        "dialog_name|vending\n"
        .. (
          "tilex|"
          .. (
            tostring(G["x"])
            .. (
              "|\n"
              .. (
                "tiley|"
                .. (
                  tostring(G["y"])
                  .. (
                    "|\n"
                    .. (
                      "verify|1|\n"
                      .. (
                        "buycount|"
                        .. (
                          tostring(k)
                          .. (
                            "|\n"
                            .. (
                              "expectprice|"
                              .. (
                                tostring(G["price"]) .. ("|\n" .. ("expectitem|" .. (tostring(G["itemID"]) .. "|\n")))
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
local function op(G)
  G = tonumber(G) or 0
  if G <= -2 then
    return math["floor"](math["abs"](G))
  end
  return 1
end
local function Up(G, k)
  G = math["max"](0, math["floor"](tonumber(G) or 0))
  k = math["max"](1, math["floor"](tonumber(k) or 1))
  return math["floor"](G / k) * k
end
local function tp(G, k)
  local Q = math["floor"](G / k)
  if Q <= 1 then
    return 0
  end
  return math["max"](1, math["floor"](Q / 2)) * k
end
local function Tp(G)
  G = math["floor"](tonumber(G) or 0)
  if G < 1 then
    return true
  end
  if not hq(p, "BUY") then
    Kq("Could not enter buy world.")
    return false
  end
  Dq()
  rq("GO TO VENDING")
  local k = nil
  local function Q()
    local G, Q = Bp()
    while H and (G == nil or (K and G["price"] ~= K)) do
      if not K then
        Kq(Q or "Choose a vending that sells the selected item.")
        return nil, false
      end
      if not ip() then
        return nil, "DEPLETED"
      end
      k = nil
      G, Q = Bp()
    end
    return G, nil
  end
  local l, g = Q()
  if not l then
    return g or false
  end
  if not K then
    K = l["price"]
    h()
  end
  if K == 0 then
    Kq("Starting vending has no usable price. Select a stocked vend.")
    return false
  end
  if not Pp() then
    Kq("Cannot reach selected vending (" .. (c .. ("," .. (D .. ")."))))
    return false
  end
  while H and (pq(r) < G and F < e) do
    ::next_buy_cycle::
    l, g = Q()
    if not l then
      return g or false
    end
    if not Pp() then
      Kq("Could not reach next vending (" .. (c .. ("," .. (D .. ")."))))
      return false
    end
    local J = pq(r)
    local v = e - F
    local N = lq - J
    local Y = math["min"](G - J, v, N)
    local S = op(K)
    local B = Up(Y, S)
    if B < S then
      if J > 0 and v >= S then
        rq("BACKPACK PRICE-UNIT FULL - STORE " .. J)
        return true
      end
      rq("UNBUYABLE FINAL PRICE REMAINDER " .. v)
      return "UNIT_REMAINDER"
    end
    if k ~= nil then
      B = Up(math["min"](B, k), S)
      if B < S then
        if not ip() then
          return "DEPLETED"
        end
        k = nil
        Sleep(Yq)
        goto next_buy_cycle
      end
    end
    local Z = false
    local i = ap(l)
    if i == nil then
      Kq("Vending dialog did not open. Stock cannot be checked safely.")
      return false
    end
    if tonumber(i["x"]) ~= l["x"] or tonumber(i["y"]) ~= l["y"] then
      Kq("Different vending opened; cannot confirm exact price.")
      return false
    end
    if tonumber(i["itemID"]) ~= r or tonumber(i["price"]) ~= K then
      rq("VEND ITEM/PRICE CHANGED - SKIP")
    else
      local G = tonumber(i["stock"])
      if G == nil then
        Kq("Vending stock was not found in the dialog.")
        return false
      end
      B = Up(math["min"](B, G), S)
      if B < S then
        rq("VEND STOCK BELOW BUY UNIT @ " .. (c .. ("," .. D)))
      else
        rq("BUY " .. (B .. (" / STOCK " .. G)))
        if not H then
          return false
        end
        Wp(i, B)
        local k = 0
        while k < vq do
          local G = pq(r)
          if G > J then
            break
          end
          Sleep(100)
          k = k + 100
        end
        local Q = pq(r)
        if Q <= J then
          Sleep(Bq)
          Q = pq(r)
        end
        if Q > J then
          local G = Q - J
          s = r
          F = F + G
          if not h() then
            Dq()
            Eq()
            Kq("Purchase confirmed but progress could not be saved. Retry Start after storage is available.")
            return false
          end
          Dq()
          Eq()
          if not H then
            return false
          end
          rq("BOUGHT " .. (G .. (" / REQUESTED " .. B)))
          Z = true
        else
          if not H then
            return false
          end
          rq("BUY NOT CONFIRMED @ " .. (c .. ("," .. D)))
        end
      end
    end
    if not H then
      return false
    end
    if not Z then
      if not ip() then
        rq("ALL MATCHING VENDS EXHAUSTED - STORE FIRST")
        return "DEPLETED"
      end
      k = nil
      if not Pp() then
        Kq("Could not reach next same-price vending.")
        return false
      end
    end
    Sleep(Yq)
  end
  return H and (pq(r) >= G or F >= e)
end
local function bp(G, k)
  G = math["floor"](tonumber(G) or 0)
  if G < 1 or pq(r) < 1 then
    return true
  end
  if not hq(V, "STORAGE") or not fq(V) then
    Kq("Could not enter storage world or its linked door.")
    return false
  end
  while H and pq(r) > 0 do
    if not fq(V) then
      rq("WAIT STORAGE WORLD - NO DROP")
      return false
    end
    rq("STORAGE PATH -> " .. (x .. ("," .. E)))
    if not Qp(x, E) then
      rq("WAIT STORAGE POSITION " .. (x .. ("," .. E)))
      return false
    end
    if not kp(x, E) then
      rq("NOT AT DROP TILE - NO DROP")
      return false
    end
    local G = false
    for k = 1, 2, 1 do
      if not H or not fq(V) or not kp(x, E) then
        rq("DROP POSITION LOST - NO SHIFT")
        return false
      end
      local Q = pq(r)
      if Q < 1 then
        return true
      end
      rq("DROP " .. (k .. ("/2 @ " .. (x .. ("," .. E)))))
      Hq = true
      Lq = false
      local l = pcall(function()
        SendPacket(2, "action|drop\nitemID|" .. tostring(r))
      end)
      if not l then
        Hq = false
        Lq = false
        rq("DROP REQUEST ERROR - WAIT")
        return false
      end
      local g = 0
      while H and (fq(V) and g < Rq) do
        if Lq or pq(r) < Q then
          break
        end
        Sleep(100)
        g = g + 100
      end
      local J = Lq
      Hq = false
      Lq = false
      if not H or not fq(V) then
        return false
      end
      if not kp(x, E) then
        rq("MOVEMENT DURING DROP - NO SHIFT")
        return false
      end
      if pq(r) < Q then
        G = true
        break
      end
      if J then
        local G = pcall(function()
          SendPacket(
            2,
            "action|dialog_return\n"
              .. ("dialog_name|drop_item\n" .. ("itemID|" .. (tostring(r) .. ("|\n" .. ("count|" .. tostring(Q))))))
          )
        end)
        if not G then
          rq("DROP CONFIRM ERROR - WAIT")
          return false
        end
        g = 0
        while H and (fq(V) and g < Nq) do
          if pq(r) < Q then
            break
          end
          Sleep(100)
          g = g + 100
        end
      else
        rq("DROP DIALOG NOT OPENED " .. (k .. "/2"))
      end
      if pq(r) >= Q then
        Sleep(850)
      end
      Dq()
      if pq(r) < Q then
        G = true
        break
      end
      if not fq(V) or not kp(x, E) then
        rq("DROP POSITION CHANGED - NO SHIFT")
        return false
      end
      if k == 1 then
        rq("DROP FAILED - RETRY SAME TILE")
        Sleep(550)
      end
    end
    if G then
      I = 0
      Dq()
      if pq(r) == 0 then
        rq("STORAGE DROP COMPLETE")
        return true
      end
      Sleep(250)
    else
      if x <= 0 then
        Kq("Storage is full all the way to the left edge.")
        return false
      end
      x = x - 1
      I = 0
      pcall(function()
        editValue("AVD_activedrop", x .. (", " .. E))
      end)
      rq("DROP FULL / SHIFT LEFT -> " .. (x .. ("," .. E)))
      qq("Storage moved left to " .. (x .. ("," .. E)))
      h()
      Sleep(800)
      return false
    end
  end
  return pq(r) == 0
end
local function wp()
  local G = pq(r)
  Dq()
  if G < 1 then
    return true
  end
  return bp(G, "Dropped all selected item")
end
local function up()
  local G = pq(r)
  Dq()
  if G < 1 then
    qq("Inventory check: no existing target item.")
    return true
  end
  rq("INITIAL DROP")
  qq("Inventory check: dropping existing " .. (tostring(G) .. (" " .. (Vq(r) .. " first."))))
  return bp(G, "Initial inventory dropped")
end
local function Hp()
  Gq["AVD_enable"] = true
  pcall(function()
    EditToggle("AVD_enable", false)
  end)
  pcall(function()
    editToggle("AVD_enable", false)
  end)
  Gq["AVD_enable"] = nil
end
function onVariant(G, k)
  if G ~= nil and (G["v1"] == "OnDialogRequest" and type(G["v2"]) == "string") then
    local k = G["v2"]
    if H and (Hq and k:find("drop_item", 1, true)) then
      Lq = true
      return true
    end
    if
      H
      and (
        Tq
        and (
          k:find("end_dialog|vending", 1, true) and (
            k:find("embed_data|tilex|", 1, true) or k:find("expectitem|", 1, true)
          )
        )
      )
    then
      wq = k
      bq = true
      return true
    end
  end
  return false
end
function onValue(G, k, Q)
  if Gq[k] then
    return
  end
  if k == "AVD_totalbought" or k == "AVD_totalremaining" then
    return
  end
  if k == "AVD_licensekey" then
    local G = v(Q)
    if A and G ~= v(R) then
      O = O + 1
      A = false
      Hp()
      rq("STOPPED - LICENSE CHANGED")
    end
    R = G
    q = false
    Mq("NOT VERIFIED")
    return
  end
  if k == "AVD_verifylicense" then
    runThread(function()
      nq(false)
    end)
    return
  end
  if k == "AVD_clearlicense" then
    if A then
      O = O + 1
      A = false
      Hp()
    end
    q = false
    R = ""
    J = ""
    B()
    pcall(function()
      editValue("AVD_licensekey", "")
    end)
    Mq("NOT VERIFIED")
    qq("Saved license cleared.")
    return
  end
  if k == "AVD_enable" then
    if Q == true then
      if H or A then
        return
      end
      if L then
        Hp()
        qq("The previous run is still stopping. Try Start again shortly.")
        return
      end
      O = O + 1
      local G = O
      local k = v(R)
      A = true
      H = false
      rq("CHECKING LICENSE BEFORE START")
      runThread(function()
        local Q = 0
        while M and (A and (O == G and Q < 30000)) do
          Sleep(100)
          Q = Q + 100
        end
        if not A or O ~= G then
          return
        end
        local l = false
        if not M then
          l = nq(true)
        else
          Mq("VERIFY BUSY - RETRY START")
        end
        if not A or O ~= G then
          return
        end
        if v(R) ~= k then
          l = false
          q = false
          Mq("KEY CHANGED - RETRY START")
        end
        if not l then
          A = false
          H = false
          Hp()
          rq("LICENSE NOT VALID - NOT STARTED")
          qq("License was not approved by the server. Start blocked (" .. (tostring(n) .. ")."))
          return
        end
        if F > 0 and s ~= r then
          Kq(
            "Saved progress belongs to item "
              .. (s .. ". Reselect it to resume, or edit Total Buy Amount for a new target.")
          )
          return
        end
        if not h() then
          Kq("Settings storage is required to save purchase progress.")
          return
        end
        Eq()
        X = nil
        f = {}
        z = false
        j = ""
        if x > C or x < 0 then
          x = C
        end
        I = 0
        pcall(function()
          editValue("AVD_activedrop", x .. (", " .. E))
        end)
        m = false
        pcall(function()
          editValue("AVD_activedrop", x .. (", " .. E))
        end)
        local g = nil
        local J = Xq(p)
        if sq() == J then
          g = Bp()
        end
        if g ~= nil then
          K = g["price"]
        end
        tq = true
        kq("AVD_itemid", tostring(r))
        cq()
        Dq()
        if r <= 0 then
          Kq("Choose a valid target item first.")
          return
        end
        if e < 1 then
          Kq("Total Buy Amount must be at least 1.")
          return
        end
        if eq(p) == "" then
          Kq("Set Buy World first.")
          return
        end
        if eq(V) == "" then
          Kq("Set Drop World first.")
          return
        end
        if not mq(true) then
          Kq("Could not enable ModFly at start.")
          return
        end
        if O ~= G then
          return
        end
        A = false
        H = true
        rq("STARTING")
        qq("Started. Bought " .. (F .. ("/" .. (e .. ("; remaining " .. (math["max"](0, e - F) .. "."))))))
      end)
    else
      O = O + 1
      A = false
      H = false
      mq(false)
      Hq = false
      Lq = false
      Tq = false
      bq = false
      wq = ""
      rq("STOPPED")
      qq("Auto Vend V2.1 stopped.")
    end
    return
  end
  if k == "AVD_itempicker" then
    if not Yp(Q) then
      qq("Could not read item from Item Picker.")
    end
    return
  end
  if k == "AVD_itemid" then
    if not Np(tonumber(Q)) then
      kq("AVD_itemid", r)
    end
    return
  end
  if k == "AVD_totalbuyamount" then
    local G = tonumber(Q)
    if G == nil then
      kq("AVD_totalbuyamount", e)
      return
    end
    G = math["min"](999999, math["max"](1, math["floor"](G)))
    if G ~= e then
      if H or A or L then
        qq("Stop Auto Vend and let the current action finish before editing Total Buy Amount.")
      else
        e = G
        F = 0
        s = 0
        h()
        Eq()
      end
    end
    kq("AVD_totalbuyamount", e)
    return
  end
  if k == "AVD_buyworld" then
    p = eq(Q)
    h()
    return
  end
  if k == "AVD_setbuyworld" then
    local G = sq()
    if G == "" or G == "EXIT" then
      qq("Current world is not available.")
      return
    end
    p = G
    kq("AVD_buyworld", p)
    h()
    qq("Buy World = " .. p)
    return
  end
  if k == "AVD_vendx" then
    local G = tonumber(Q)
    if G ~= nil then
      c = math["floor"](G)
      K = nil
      X = nil
      f = {}
      xq()
      h()
    end
    return
  end
  if k == "AVD_vendy" then
    local G = tonumber(Q)
    if G ~= nil then
      D = math["floor"](G)
      K = nil
      X = nil
      f = {}
      xq()
      h()
    end
    return
  end
  if k == "AVD_setvend" then
    local G, k = Gp()
    if G == nil or k == nil then
      qq("Player position is not available.")
      return
    end
    c = G
    D = k
    kq("AVD_vendx", tostring(c))
    kq("AVD_vendy", tostring(D))
    xq()
    local Q = Bp()
    if Q ~= nil then
      editValue("AVD_vendprice", tostring(Q["price"]))
      K = Q["price"]
    else
      editValue("AVD_vendprice", "NONE")
    end
    h()
    qq("Vending position = (" .. (tostring(c) .. (", " .. (tostring(D) .. ")"))))
    return
  end
  if k == "AVD_dropworld" then
    V = eq(Q)
    h()
    return
  end
  if k == "AVD_setdropworld" then
    local G = sq()
    if G == "" or G == "EXIT" then
      qq("Current world is not available.")
      return
    end
    V = G
    kq("AVD_dropworld", V)
    h()
    qq("Drop World = " .. V)
    return
  end
  if k == "AVD_dropx" then
    local G = tonumber(Q)
    if G ~= nil then
      C = math["floor"](G)
      x = C
      I = 0
      pcall(function()
        editValue("AVD_activedrop", x .. (", " .. E))
      end)
      h()
    end
    return
  end
  if k == "AVD_dropy" then
    local G = tonumber(Q)
    if G ~= nil then
      E = math["floor"](G)
      pcall(function()
        editValue("AVD_activedrop", x .. (", " .. E))
      end)
      h()
    end
    return
  end
  if k == "AVD_setdrop" then
    local G, k = Gp()
    if G == nil or k == nil then
      qq("Player position is not available.")
      return
    end
    C = G
    E = k
    x = G
    I = 0
    pcall(function()
      editValue("AVD_activedrop", x .. (", " .. E))
    end)
    kq("AVD_dropx", tostring(C))
    kq("AVD_dropy", tostring(E))
    h()
    qq("Drop stand position = (" .. (tostring(C) .. (", " .. (tostring(E) .. ")"))))
    return
  end
end
applyHook()
if type(setOnValue) == "function" then
  pcall(function()
    setOnValue("AVD_itempicker", function(...)
      local G = { ... }
      for k = #G, 1, -1 do
        if Yp(G[k]) then
          return
        end
      end
    end)
  end)
end
runThread(function()
  rq("STOPPED")
  cq()
  Dq()
  Eq()
  xq()
  pcall(function()
    editValue("AVD_activedrop", x .. (", " .. E))
  end)
  if y ~= nil and not W then
    h()
  end
  if R ~= "" then
    pcall(function()
      editValue("AVD_licensekey", R)
    end)
    Mq("CHECKING SAVED KEY...")
    Sleep(300)
    nq(true)
  else
    Mq("NOT VERIFIED")
  end
  while true do
    if H then
      L = true
      Dq()
      Eq()
      if tq then
        if up() then
          tq = false
          Sleep(Yq)
        else
          Sleep(350)
        end
      elseif m then
        if pq(r) == 0 then
          m = false
        elseif wp() then
          m = (pq(r) > 0)
          Sleep(Yq)
        else
          Sleep(450)
        end
      elseif z then
        if pq(r) > 0 then
          m = true
          rq("ALL VENDS DONE - STORE REMAINING ITEMS")
        else
          rq("ALL VENDS DONE - RETURN TO STORAGE")
          if hq(V, "STORAGE") and fq(V) then
            Kq(j ~= "" and j or "No more purchasable same-price vends.")
          else
            rq("WAIT STORAGE BEFORE AUTOMATIC STOP")
            Sleep(700)
          end
        end
      elseif F >= e then
        if pq(r) > 0 then
          m = true
        else
          Kq("Total buy target reached: " .. (tostring(F) .. ("/" .. tostring(e))))
        end
      else
        local G = e - F
        local k = math["min"](lq, G)
        local Q = Tp(k)
        if Q == "DEPLETED" or Q == "UNIT_REMAINDER" then
          z = true
          j = Q == "DEPLETED" and "No more purchasable same-price vending stock. Stored and stopped."
            or "Remaining target cannot be bought in whole price units. Stored and stopped."
          m = pq(r) > 0
          rq("BUYING FINISHED - STORE THEN STOP")
        elseif Q == true then
          m = pq(r) > 0
          if not m then
            Sleep(250)
          end
        else
          if H and pq(r) > 0 then
            m = true
          end
          Sleep(350)
        end
      end
      L = false
    else
      Sleep(200)
    end
  end
end)
