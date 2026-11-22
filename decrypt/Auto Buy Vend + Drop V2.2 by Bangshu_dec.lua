setMinimum("6.1.2")
local M =
  "https://script.google.com/macros/s/AKfycbxeBzpOUzvcRDkX-4eR8uioFbAUDsepIQc26kmxUkXt6YOjBxFdVsOE0zzvxYSprl5knA/exec"
local w = "AUTOVEND"
local d = "AutoVendToDropLicense"
local r = "license_key"
local S = nil
local T = ""
local function j(M)
  M = tostring(M or "")
  M = M:gsub("%s+", "")
  return M:upper()
end
local function m(M)
  M = j(M)
  return M:match("^[A-Z]%d%d%d%d%d%d%d$") ~= nil
end
local function C()
  local M = pcall(function()
    local M = nil
    if type(require) == "function" then
      local w, d = pcall(require, "preferences")
      if w and d ~= nil then
        M = d
      end
    end
    if M == nil and type(Preferences) == "table" then
      M = Preferences
    end
    if M == nil then
      return
    end
    if type(M["new"]) == "function" then
      local w = M:new(d)
      S = w or M
    else
      S = M
    end
    if S ~= nil and type(S["load"]) == "function" then
      S:load()
    end
    if S ~= nil and type(S["get"]) == "function" then
      T = j(S:get(r, ""))
    end
  end)
  if not M then
    S = nil
    T = ""
  end
end
local function t(M)
  if S == nil then
    return false
  end
  local w = pcall(function()
    S:set(r, j(M))
    S:save()
  end)
  return w
end
local function z()
  if S == nil then
    return false
  end
  local M = pcall(function()
    S:set(r, "")
    S:save()
  end)
  return M
end
C()
local O = "AutoVendSettingsV31"
local X = "31"
local Y = {
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
local R = {
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
local h = nil
local p = {}
local x = false
for M, w in pairs(Y) do
  p[M] = w
end
local function c()
  local M = pcall(function()
    local M = nil
    if type(require) == "function" then
      local w, d = pcall(require, "preferences")
      if w and type(d) == "table" then
        M = d
      end
    end
    if M == nil and type(Preferences) == "table" then
      M = Preferences
    end
    if M == nil or type(M["new"]) ~= "function" then
      return
    end
    local w = M:new(O)
    if
      w == nil
      or type(w["load"]) ~= "function"
      or type(w["get"]) ~= "function"
      or type(w["set"]) ~= "function"
      or type(w["save"]) ~= "function"
    then
      return
    end
    if w:load() == false then
      return
    end
    h = w
    if tostring(w:get("schema", "")) == X then
      for M, d in ipairs(R) do
        p[d] = tostring(w:get(d, Y[d]))
      end
      x = true
    end
  end)
  if not M then
    h = nil
  end
end
c()
local function P(M, w, d, r)
  local S = math["floor"](tonumber(p[M]) or w)
  return math["min"](r, math["max"](d, S))
end
local function L(M)
  return ((tostring(p[M] or "")):upper()):gsub("%s+", "")
end
local B = "Auto buy vend v2.2 by Bangshu"
local A = UserInterface["new"](B, "ShoppingCart")
A:addLabelApp(B, "ShoppingCart")
A:addInputString("License Key", T, "A1234567", "A1234567", nil, "AVD_licensekey")
A:addButton("Verify License", "AVD_verifylicense")
A:addButton("Clear Saved License", "AVD_clearlicense")
A:addDisplayList("License Status", "NOT VERIFIED", "AVD_licensestatus")
A:addToggle("Start / Stop", false, "AVD_enable")
A:addInputString(
  "Buy Progress (view only)",
  "0 / " .. tostring(p["totalbuyamount"]),
  "Bought / total target",
  "0 / 1000",
  nil,
  "AVD_totalbought"
)
A:addInputString(
  "Remaining to Buy (view only)",
  tostring(p["totalbuyamount"]),
  "Items left",
  "1000",
  nil,
  "AVD_totalremaining"
)
A:addItemPicker("Pick Target Item", p["itemid"], p["itemid"], "AVD_itempicker")
A:addInputInt("Item ID", p["itemid"], "ID", "5706", nil, "AVD_itemid")
A:addDisplayList("Selected Item", p["itemid"], "AVD_selecteditem")
A:addInputInt("Total Buy Amount", p["totalbuyamount"], "items total", "1000", nil, "AVD_totalbuyamount")
A:addButton("Find Vend for Selected Item", "AVD_findvend")
local G = (A:addDialog("Buy World Settings", "Set the buy world and starting vending machine", {}))["menu"]
A:addChildInputString(G, "Buy World", p["buyworld"], "WORLD|DOORID", "BUY WORLD or WORLD|DOORID", nil, "AVD_buyworld")
A:addChildButton(G, "Set Buy World = Current World", "AVD_setbuyworld")
A:addChildInputInt(G, "Vending Position X", p["vendx"], "X", "0", nil, "AVD_vendx")
A:addChildInputInt(G, "Vending Position Y", p["vendy"], "Y", "0", nil, "AVD_vendy")
A:addChildButton(G, "Set Vending = Current Tile", "AVD_setvend")
local J = (A:addDialog("Drop World Settings", "Set the drop world and storage tile", {}))["menu"]
A:addChildInputString(
  J,
  "Drop World",
  p["dropworld"],
  "WORLD|DOORID",
  "DROP WORLD or WORLD|DOORID",
  nil,
  "AVD_dropworld"
)
A:addChildButton(J, "Set Drop World = Current World", "AVD_setdropworld")
A:addChildInputInt(J, "Drop Stand Position X", p["dropx"], "X", "0", nil, "AVD_dropx")
A:addChildInputInt(J, "Drop Stand Position Y", p["dropy"], "Y", "0", nil, "AVD_dropy")
A:addChildButton(J, "Set Drop Position = Current Tile", "AVD_setdrop")
A:addDisplayList("Selected Vending", "0, 0", "AVD_vendpos")
A:addDisplayList("Vending Price", p["lockedprice"] ~= "" and p["lockedprice"] or "NONE", "AVD_vendprice")
A:addDisplayList("Current Drop Tile", p["activedropx"] .. (", " .. p["dropy"]), "AVD_activedrop")
A:addDisplayList("ModFly (Session)", "OFF", "AVD_travelfly")
A:addDisplayList("Settings AutoSave", h == nil and "UNAVAILABLE" or (x and "RESTORED" or "READY"), "AVD_autosave")
A:addDisplayList("Status", "STOPPED", "AVD_status")
A:addDisplayList("Item Inventory", "0 / 200", "AVD_inventory")
pcall(function()
  if type(addCategory) == "function" then
    addCategory(B, "ShoppingCart")
  end
end)
local I = A:generateJSON()
local s = pcall(function()
  addIntoModule(I, B)
end)
if not s then
  pcall(function()
    growtopia["notify"](B .. " menu could not be created on this Growlauncher build.")
  end)
end
local N = false
local i = false
local b = false
local f = T
local e = false
local g = false
local V = false
local y = 0
local u = "NOT VERIFIED"
local D = P("itemid", 5706, 1, 65535)
local W = P("totalbuyamount", 200, 1, 999999)
local q = P("progressitem", 0, 0, 65535)
local Z = P("totalbought", 0, 0, 999999)
local U = L("buyworld")
local H = L("dropworld")
local k = P("vendx", 0, 0, 199)
local n = P("vendy", 0, 0, 119)
local F = P("dropx", 0, 0, 199)
local a = P("dropy", 0, 0, 119)
local Q = P("activedropx", F, 0, 199)
local v = 0
local E = false
local o = tonumber(p["lockedprice"])
local K = nil
local l = {}
local MI = false
local wI = ""
local function dI()
  if h == nil then
    pcall(function()
      editValue("AVD_autosave", "UNAVAILABLE")
    end)
    return false
  end
  local M = {
    ["itemid"] = tostring(D),
    ["totalbuyamount"] = tostring(W),
    ["progressitem"] = tostring(q),
    ["totalbought"] = tostring(Z),
    ["buyworld"] = tostring(U),
    ["dropworld"] = tostring(H),
    ["vendx"] = tostring(k),
    ["vendy"] = tostring(n),
    ["dropx"] = tostring(F),
    ["dropy"] = tostring(a),
    ["activedropx"] = tostring(Q),
    ["lockedprice"] = o and tostring(o) or "",
  }
  local w = false
  for d, r in ipairs(R) do
    if p[r] ~= M[r] then
      w = true
      break
    end
  end
  if not w and x then
    return true
  end
  local d = pcall(function()
    if h:set("schema", X) == false then
      error("schema")
    end
    for w, d in ipairs(R) do
      if h:set(d, M[d]) == false then
        error("setting: " .. d)
      end
    end
    if h:save() == false then
      error("save")
    end
  end)
  if d then
    for M, w in pairs(M) do
      p[M] = w
    end
    x = true
  end
  pcall(function()
    editValue("AVD_autosave", d and "SAVED" or "SAVE FAILED")
  end)
  return d
end
local rI = {}
local function SI(M, w)
  if rI[M] then
    return
  end
  rI[M] = true
  pcall(function()
    editValue(M, tostring(w))
  end)
  rI[M] = nil
end
local function TI(M, w)
  return tostring(M) .. ("," .. tostring(w))
end
local jI = 200
local mI = 15000
local CI = 15000
local tI = 4200
local zI = 3000
local OI = 300
local XI = 500
local YI = 650
local RI = 1000
local hI = 900
local pI = 1200
local xI = 12000
local cI = 5
local PI = false
local LI = 1500
local BI = 7
local AI = "STOPPED"
local GI = true
local JI = false
local II = false
local sI = ""
local NI = 2500
local iI = false
local bI = false
local fI = 2500
local function eI(M)
  pcall(function()
    growtopia["notify"](tostring(M))
  end)
end
local function gI(M)
  u = tostring(M or "")
  pcall(function()
    editValue("AVD_licensestatus", u)
  end)
end
local function VI(M)
  M = tostring(M or "")
  M = M:gsub("\n", "\r\n")
  M = M:gsub("([^%w%-_%.~])", function(M)
    return string["format"]("%%%02X", string["byte"](M))
  end)
  return M
end
local function yI()
  local M = ""
  if type(getDiscordID) == "function" then
    local w, d = pcall(getDiscordID)
    if w and d ~= nil then
      M = tostring(d)
    end
  elseif getDiscordID ~= nil then
    M = tostring(getDiscordID)
  end
  M = ((tostring(M or "")):gsub("^%s+", "")):gsub("%s+$", "")
  if M == "" or M == "nil" or M == "0" then
    local w = GetLocal or getLocal
    if w ~= nil then
      local d, r = pcall(w)
      if d and (r ~= nil and r["name"] ~= nil) then
        M = tostring(r["name"])
        M = (M:gsub("^%s+", "")):gsub("%s+$", "")
      end
    end
  end
  return M
end
local function uI(d)
  if g then
    return false
  end
  g = true
  e = false
  local r = j(f)
  f = r
  pcall(function()
    editValue("AVD_licensekey", r)
  end)
  if not m(r) then
    gI("INVALID KEY FORMAT")
    g = false
    if not d then
      eI("License must be 1 letter + 7 numbers, for example A1234567.")
    end
    return false
  end
  local S = yI()
  if S == "" then
    gI("NO CLIENT ID")
    g = false
    if not d then
      eI("Could not read a client ID. Enter the game first and try again.")
    end
    return false
  end
  gI("CHECKING...")
  local C = M .. ("?key=" .. (VI(r) .. ("&id=" .. (VI(S) .. ("&product=" .. VI(w))))))
  local z, O, X = pcall(fetch, C)
  if not z then
    gI("SERVER ERROR")
    g = false
    if not d then
      eI("License server request failed.")
    end
    return false
  end
  O = tostring(O or "")
  O = (O:gsub("^%s+", "")):gsub("%s+$", "")
  if O:find("OK|PERMANENT", 1, true) then
    e = true
    gI("VERIFIED - PERMANENT")
    if t(r) then
      T = r
    end
    g = false
    if not d then
      eI("License verified and saved.")
    end
    return true
  end
  local Y = O
  local R = "LICENSE CHECK FAILED"
  if Y:find("DENY|DISABLED", 1, true) then
    gI("DISABLED")
    R = "License disabled."
  elseif Y:find("DENY|WRONG_PRODUCT", 1, true) then
    gI("WRONG PRODUCT")
    R = "This license is for another script."
  elseif Y:find("DENY|BOUND_TO_OTHER_USER", 1, true) then
    gI("BOUND TO OTHER USER")
    R = "License is bound to another user."
  elseif Y:find("DENY|INVALID_KEY", 1, true) then
    gI("INVALID KEY")
    R = "Invalid license key."
  elseif Y:find("DENY|BAD_KEY_FORMAT", 1, true) then
    gI("BAD KEY FORMAT")
    R = "License key format is invalid."
  elseif Y:find("DENY|NO_ID", 1, true) then
    gI("NO CLIENT ID")
    R = "Client ID is unavailable."
  elseif Y:find("DENY|", 1, true) then
    gI("DENIED")
    R = "License denied by server."
  elseif Y == "" then
    gI("NO RESPONSE")
    R = "License server gave no response."
  else
    gI("CHECK FAILED")
    R = "License check failed."
  end
  g = false
  if not d then
    eI(R)
  end
  return false
end
local function DI(M)
  M = tostring(M)
  if AI ~= M then
    AI = M
    editValue("AVD_status", M)
  end
end
local function WI(M)
  M = tostring(M or "")
  M = M:gsub("%s+", "")
  return M:upper()
end
local function qI()
  local M, w = pcall(function()
    if type(GetWorldName) == "function" then
      return GetWorldName()
    end
    if type(getCurrentWorldName) == "function" then
      return getCurrentWorldName()
    end
    return ""
  end)
  if not M then
    return ""
  end
  return WI(w)
end
local function ZI()
  local M, w = pcall(function()
    return GetLocal()
  end)
  if M and w ~= nil then
    return w
  end
  M, w = pcall(function()
    return getLocal()
  end)
  if M then
    return w
  end
  return nil
end
local function UI(M)
  local w, d = pcall(function()
    if growtopia ~= nil and type(growtopia["checkInventoryCount"]) == "function" then
      return growtopia["checkInventoryCount"](M)
    end
    local w = 0
    local d = nil
    if type(GetInventory) == "function" then
      d = GetInventory()
    elseif type(getInventory) == "function" then
      d = getInventory()
    end
    if d ~= nil then
      for d, r in pairs(d) do
        if tonumber(r["id"]) == tonumber(M) then
          w = tonumber(r["amount"]) or 0
          break
        end
      end
    end
    return w
  end)
  if not w then
    return 0
  end
  return tonumber(d) or 0
end
local function HI(M)
  local w, d = pcall(function()
    if growtopia ~= nil and type(growtopia["getItemName"]) == "function" then
      return growtopia["getItemName"](M)
    end
    if type(getItemInfoByID) == "function" then
      local w = getItemInfoByID(M)
      if w ~= nil then
        return w["name"]
      end
    end
    return nil
  end)
  if w and (d ~= nil and tostring(d) ~= "") then
    return tostring(d)
  end
  return "Item " .. tostring(M)
end
local function kI()
  editValue("AVD_selecteditem", HI(D) .. (" (" .. (tostring(D) .. ")")))
end
local function nI()
  editValue("AVD_inventory", tostring(UI(D)) .. " / 200")
end
local FI = nil
local function aI()
  local M = q == D and Z or 0
  local w = math["max"](1, math["floor"](tonumber(W) or 1))
  local d = math["max"](0, w - M)
  local r = math["min"](100, math["floor"]((M * 100) / w))
  local S = tostring(M) .. (" / " .. (tostring(w) .. (" (" .. (tostring(r) .. "%)"))))
  if S ~= FI then
    FI = S
    SI("AVD_totalbought", S)
    SI("AVD_totalremaining", tostring(d))
  end
end
local function QI()
  editValue("AVD_vendpos", tostring(k) .. (", " .. tostring(n)))
end
local vI = nil
local function EI(M)
  M = M == true
  if vI == M then
    return true
  end
  local w = editToggle or EditToggle
  if type(w) ~= "function" then
    pcall(function()
      editValue("AVD_travelfly", "UNAVAILABLE")
    end)
    return false
  end
  local d, r = pcall(w, "ModFly", M)
  if not d or r == false then
    pcall(function()
      editValue("AVD_travelfly", "ERROR")
    end)
    return false
  end
  vI = M
  pcall(function()
    editValue("AVD_travelfly", M and "ON (SESSION)" or "OFF")
  end)
  if M then
    Sleep(250)
  end
  return true
end
local function oI(M)
  V = false
  N = false
  EI(false)
  iI = false
  bI = false
  JI = false
  II = false
  sI = ""
  pcall(function()
    EditToggle("AVD_enable", false)
  end)
  pcall(function()
    editToggle("AVD_enable", false)
  end)
  DI("STOPPED")
  if M ~= nil and M ~= "" then
    eI(M)
  end
end
local function KI(M)
  M = WI(M)
  local w, d = M:match("^([^|]+)|([^|]+)$")
  if w ~= nil then
    return w, d
  end
  if M:find("|", 1, true) then
    return "", nil
  end
  return M, nil
end
local function lI(M)
  local w = KI(M)
  if w == "" or qI() ~= w then
    return false
  end
  local d = ZI()
  if d == nil then
    return false
  end
  local r, S = pcall(function()
    if type(GetTiles) == "function" then
      return GetTiles()
    end
    return getTiles()
  end)
  return r and (S ~= nil and #S > 0)
end
local function Mc(M, w)
  local d = 0
  while N and d < w do
    if lI(M) then
      Sleep(300)
      return N and lI(M)
    end
    Sleep(100)
    d = d + 100
  end
  return false
end
local wc = ""
local function dc(M, w)
  w = (w == "STORAGE") and "STORAGE" or "BUY"
  M = WI(M)
  local d, r = KI(M)
  if d == "" then
    DI(w .. " INVALID WORLD OR DOOR ID")
    return false
  end
  local S = r ~= nil and r ~= ""
  if not S and lI(d) then
    wc = ""
    PI = false
    return true
  end
  if S and (lI(d) and wc == M) then
    PI = false
    return true
  end
  if not lI(d) then
    DI(w .. (" WARP BASE " .. d))
    wc = ""
    local M, r = pcall(function()
      return growtopia["warpTo"](d)
    end)
    if not M or r == false then
      return false
    end
    if not Mc(d, mI) then
      return false
    end
    Sleep(RI)
    if not N or not lI(d) then
      return false
    end
  end
  if S then
    DI(w .. (" ENTER DOOR " .. (d .. ("|" .. r))))
    local S, T = pcall(function()
      return SendPacket(3, "action|join_request\nname|" .. (M .. "\ninvitedWorld|0"))
    end)
    if not S or T == false then
      return false
    end
    Sleep(1400)
    if not Mc(d, mI) then
      return false
    end
    Sleep(RI)
    if not N or not lI(d) then
      return false
    end
    wc = M
    DI(w .. (" DOOR REQUEST SETTLED " .. (d .. ("|" .. r))))
  else
    wc = ""
  end
  PI = true
  return true
end
local function rc()
  local M = ZI()
  if M == nil then
    return nil, nil
  end
  return M["posX"] // 32, M["posY"] // 32
end
local function Sc(M, w)
  local d, r = rc()
  return d == M and r == w
end
local function Tc(M, w)
  if Sc(M, w) then
    PI = false
    Sleep(150)
    return true
  end
  local d = PI
  PI = false
  local r = 0
  local S = 0
  local T = 0
  while N and S < CI do
    if Sc(M, w) then
      Sleep(150)
      return true
    end
    if r < BI and S >= T then
      r = r + 1
      DI("PATH " .. (tostring(r) .. ("/" .. (tostring(BI) .. (" -> " .. (tostring(M) .. ("," .. tostring(w))))))))
      pcall(function()
        FindPath(M, w)
      end)
      if d and r == 1 then
        T = S + hI
      else
        T = S + LI
      end
    end
    Sleep(100)
    S = S + 100
  end
  return Sc(M, w)
end
local function jc(M, w)
  local d, r = pcall(function()
    if type(getTile) == "function" then
      return getTile(M, w)
    end
    return GetTile(M, w)
  end)
  if d then
    return r
  end
  return nil
end
local function mc(M, w)
  local d, r = rc()
  if d == nil or r == nil then
    return nil, "Player position is not available."
  end
  M = M or 4
  w = w or 2
  local S = {}
  for w = r - w, r + w, 1 do
    for M = d - M, d + M, 1 do
      local T = jc(M, w)
      if T ~= nil and (T["fg"] == 2978 or T["fg"] == 9268) then
        local j = T["extra"]
        local m = j and tonumber(j["vend_item"] or 0) or 0
        if m == D then
          local T = tonumber(j["vend_price"] or 0) or 0
          local m = math["abs"](d - M) + math["abs"](r - w)
          table["insert"](S, { ["x"] = M, ["y"] = w, ["price"] = T, ["distance"] = m })
        end
      end
    end
  end
  if #S == 0 then
    return nil, "No nearby vending sells " .. (HI(D) .. (" (" .. (tostring(D) .. ").")))
  end
  table["sort"](S, function(M, w)
    if M["distance"] == w["distance"] then
      if M["y"] == w["y"] then
        return M["x"] < w["x"]
      end
      return M["y"] < w["y"]
    end
    return M["distance"] < w["distance"]
  end)
  return S[1], nil
end
local function Cc(M, w, d)
  local r, S = pcall(GetTiles or getTiles)
  if not r or type(S) ~= "table" then
    return nil
  end
  local T, j
  for r, S in pairs(S) do
    local m, C = tonumber(S["fg"]), S["extra"]
    if (m == 2978 or m == 9268) and (C and tonumber(C["vend_item"]) == M) then
      local M, r, m = tonumber(S["x"]), tonumber(S["y"]), tonumber(C["vend_price"])
      if M and (r and (m and m ~= 0)) then
        local S = math["abs"](w - M) + math["abs"](d - r)
        if not T or S < j or (S == j and (r < T["y"] or (r == T["y"] and M < T["x"]))) then
          T, j = { ["x"] = M, ["y"] = r }, S
        end
      end
    end
  end
  return T
end
local function tc()
  local M, w = qI(), D
  local d, r = rc()
  if d == nil or M == "" or M == "EXIT" or M == "EXITWORLD" then
    return "Enter the buy world before finding a vend."
  end
  local S = Cc(w, d, r)
  if not S then
    return "No priced vend sells the selected item in this world."
  end
  DI("FINDING VEND " .. (S["x"] .. ("," .. S["y"])))
  for d, r in ipairs({ 3000, 4500 }) do
    if qI() ~= M or D ~= w then
      return "Vend search interrupted."
    end
    if not Sc(S["x"], S["y"]) then
      pcall(FindPath or findPath, S["x"], S["y"])
    end
    local T = 0
    for d = 1, r / 100, 1 do
      if qI() ~= M or D ~= w then
        return "Vend search interrupted."
      end
      T = Sc(S["x"], S["y"]) and T + 100 or 0
      if T >= 500 then
        local M = jc(S["x"], S["y"])
        local d, r = M and tonumber(M["fg"]), M and M["extra"]
        local T = r and tonumber(r["vend_price"])
        if (d ~= 2978 and d ~= 9268) or not r or tonumber(r["vend_item"]) ~= w or not T or T == 0 then
          return "The vend changed before arrival."
        end
        local j = T > 0 and (T .. " WL/item") or (math["abs"](T) .. " items/WL")
        return "Vend " .. (
            S["x"] .. ("," .. (S["y"] .. (" at " .. (j .. ". Use Set Vending = Current Tile to save it."))))
          )
      end
      Sleep(100)
    end
  end
  return "Could not reach vend " .. (S["x"] .. ("," .. (S["y"] .. ".")))
end
local function zc()
  if b then
    return
  end
  if N or V or i then
    eI("Stop buying before finding a vend.")
    return
  end
  b = true
  runThread(function()
    local M, w = pcall(tc)
    b = false
    if not M then
      w = "Could not find the vend."
    end
    DI(w)
    eI(w)
  end)
end
local function Oc(M)
  if type(M) ~= "string" or M == "" then
    return nil
  end
  local w, d = pcall(function()
    if type(findItemID) == "function" then
      return findItemID(M)
    end
    if growtopia ~= nil and type(growtopia["getItemID"]) == "function" then
      return growtopia["getItemID"](M)
    end
    return nil
  end)
  if w and (tonumber(d) ~= nil and tonumber(d) > 0) then
    return math["floor"](tonumber(d))
  end
  return nil
end
local function Xc(M)
  if type(M) == "number" then
    return math["floor"](M)
  end
  if type(M) == "string" then
    local w = tonumber(M)
    if w ~= nil and w > 0 then
      return math["floor"](w)
    end
    local d = Oc(M)
    if d ~= nil then
      return d
    end
    local r = M:match("[Ii][Tt][Ee][Mm][Ii]?[Dd]?[^%d]*(%d+)")
    if r == nil then
      r = M:match("(%d+)")
    end
    if r ~= nil then
      local M = tonumber(r)
      if M ~= nil and M > 0 then
        return math["floor"](M)
      end
    end
    return nil
  end
  if type(M) == "table" then
    local w = { M["id"], M["itemid"], M["itemID"], M["value"], M["item"], M["name"], M["itemName"], M["selected"] }
    for M, w in ipairs(w) do
      local d = Xc(w)
      if d ~= nil and d > 0 then
        return d
      end
    end
  end
  return nil
end
local function Yc(M)
  if M == nil or M < 1 or M > 65535 then
    return false
  end
  M = math["floor"](M)
  if M == D then
    return true
  end
  if N or V or i or (q == D and (Z > 0 and UI(D) > 0)) then
    SI("AVD_itemid", D)
    eI("Finish stopping and store any purchased items before changing Item ID.")
    return true
  end
  D = M
  Z = 0
  q = 0
  o = nil
  K = nil
  l = {}
  SI("AVD_itemid", D)
  kI()
  nI()
  aI()
  dI()
  eI("Target Item = " .. (HI(M) .. (" (" .. (M .. ")"))))
  return true
end
local function Rc(M)
  return Yc(Xc(M))
end
local function hc(M)
  if type(M) == "table" then
    local w = tonumber(M["x"] or M["tileX"] or M["tilex"] or M["px"])
    local d = tonumber(M["y"] or M["tileY"] or M["tiley"] or M["py"])
    if w ~= nil and d ~= nil then
      return math["floor"](w), math["floor"](d)
    end
    if type(M["pos"]) == "table" then
      w = tonumber(M["pos"]["x"] or M["pos"][1])
      d = tonumber(M["pos"]["y"] or M["pos"][2])
      if w ~= nil and d ~= nil then
        return math["floor"](w), math["floor"](d)
      end
    end
    w = tonumber(M[1])
    d = tonumber(M[2])
    if w ~= nil and d ~= nil then
      return math["floor"](w), math["floor"](d)
    end
    for M, w in pairs(M) do
      if type(w) == "table" then
        local M = tonumber(w["x"] or w["tileX"] or w["tilex"] or w["px"] or w[1])
        local d = tonumber(w["y"] or w["tileY"] or w["tiley"] or w["py"] or w[2])
        if M ~= nil and d ~= nil then
          return math["floor"](M), math["floor"](d)
        end
      elseif type(w) == "string" then
        local M, d = w:match("%(%s*(-?%d+)%s*,%s*(-?%d+)%s*%)")
        if M == nil then
          M, d = w:match("(-?%d+)%s*[,|:]%s*(-?%d+)")
        end
        if M ~= nil and d ~= nil then
          return tonumber(M), tonumber(d)
        end
      end
    end
  elseif type(M) == "string" then
    local w, d = M:match("%(%s*(-?%d+)%s*,%s*(-?%d+)%s*%)")
    if w == nil then
      w, d = M:match("(-?%d+)%s*[,|:]%s*(-?%d+)")
    end
    if w ~= nil and d ~= nil then
      return tonumber(w), tonumber(d)
    end
  end
  return nil, nil
end
local function pc()
  local M = jc(k, n)
  if M == nil then
    return nil, "Vending tile is not loaded."
  end
  if M["fg"] ~= 2978 and M["fg"] ~= 9268 then
    return nil, "Selected tile is not a vending machine."
  end
  local w = M["extra"]
  if w == nil then
    return nil, "Selected vending has no vending data."
  end
  local d = tonumber(w["vend_item"] or 0) or 0
  local r = tonumber(w["vend_price"] or 0) or 0
  if d == 0 then
    return nil, "Selected vending is empty."
  end
  if d ~= D then
    return nil, "Vending sells " .. (HI(d) .. (" (" .. (tostring(d) .. "), not selected item.")))
  end
  editValue("AVD_vendprice", tostring(r))
  return { ["x"] = k, ["y"] = n, ["price"] = r, ["itemID"] = d }, nil
end
local function xc()
  if K ~= nil then
    return K
  end
  K = {}
  if not o or o == 0 then
    return K
  end
  local M, w = pcall(function()
    if type(GetTiles) == "function" then
      return GetTiles()
    end
    return getTiles()
  end)
  if not M or type(w) ~= "table" then
    return K
  end
  for M, w in pairs(w) do
    if w and ((tonumber(w["fg"]) == 2978 or tonumber(w["fg"]) == 9268) and w["extra"] ~= nil) then
      local M = w["extra"]
      local d = tonumber(M["vend_item"])
      local r = tonumber(M["vend_price"])
      local S, T = tonumber(w["x"]), tonumber(w["y"])
      if d == D and (r == o and (S and T)) then
        K[#K + 1] = { ["x"] = math["floor"](S), ["y"] = math["floor"](T), ["itemID"] = d, ["price"] = r }
      end
    end
  end
  DI("CACHED SAME-PRICE VENDS: " .. tostring(#K))
  return K
end
local function cc()
  local M, w = k, n
  l[TI(k, n)] = true
  local d = xc()
  local r, S = nil, math["huge"]
  for d, T in ipairs(d) do
    if not l[TI(T["x"], T["y"])] then
      local d = math["abs"](T["x"] - M) + math["abs"](T["y"] - w)
      if d < S or (d == S and (r and (T["y"] < r["y"] or (T["y"] == r["y"] and T["x"] < r["x"])))) then
        r, S = T, d
      end
    end
  end
  if not r then
    DI("NO MORE SAME-PRICE VENDS")
    return false
  end
  k, n = r["x"], r["y"]
  SI("AVD_vendx", tostring(k))
  SI("AVD_vendy", tostring(n))
  QI()
  editValue("AVD_vendprice", tostring(o))
  DI("NEXT VEND " .. (tostring(k) .. ("," .. tostring(n))))
  dI()
  return true
end
local function Pc()
  local M, w = rc()
  if M == k and w == n then
    return true
  end
  DI("MOVE TO VEND " .. (tostring(k) .. ("," .. tostring(n))))
  if not Tc(k, n) then
    return false
  end
  M, w = rc()
  return M == k and w == n
end
local function Lc(M, w)
  local d = tonumber(M:match("embed_data|tilex|(%-?%d+)")) or w["x"]
  local r = tonumber(M:match("embed_data|tiley|(%-?%d+)")) or w["y"]
  local S = tonumber(M:match("embed_data|expectitem|(%-?%d+)"))
    or tonumber(M:match("expectitem|(%-?%d+)"))
    or w["itemID"]
  local T = tonumber(M:match("embed_data|expectprice|(%-?%d+)"))
    or tonumber(M:match("expectprice|(%-?%d+)"))
    or w["price"]
  local j = M:match("contains a total of%s+([%d,]+)") or M:match("contains%s+([%d,]+)")
  local m = nil
  if j ~= nil then
    j = (tostring(j)):gsub(",", "")
    m = tonumber(j)
  end
  return { ["x"] = d, ["y"] = r, ["itemID"] = S, ["price"] = T, ["stock"] = m }
end
local function Bc(M)
  if not N then
    return nil
  end
  local w = ZI()
  if w == nil then
    return nil
  end
  JI = true
  II = false
  sI = ""
  DI("OPEN VENDING")
  local d = pcall(function()
    SendPacketRaw(false, { ["type"] = 3, ["value"] = 32, ["px"] = k, ["py"] = n, ["x"] = w["posX"], ["y"] = w["posY"] })
  end)
  if not d then
    JI = false
    return nil
  end
  local r = 0
  while N and r < NI do
    if II then
      local w = sI
      JI = false
      II = false
      sI = ""
      return Lc(w, M)
    end
    Sleep(50)
    r = r + 50
  end
  JI = false
  II = false
  sI = ""
  return nil
end
local function Ac(M)
  local w = Bc(M)
  if w ~= nil or not N then
    return w
  end
  for d = 1, cI, 1 do
    if not N then
      return nil
    end
    DI("VEND REPATH " .. (tostring(d) .. ("/" .. (tostring(cI) .. (" -> " .. (tostring(k) .. ("," .. tostring(n))))))))
    pcall(function()
      FindPath(k, n)
    end)
    local r = 0
    while N and r < pI do
      if Sc(k, n) then
        break
      end
      Sleep(100)
      r = r + 100
    end
    if not N then
      return nil
    end
    DI("RETRY VENDING")
    w = Bc(M)
    if w ~= nil then
      return w
    end
    Sleep(300)
  end
  return nil
end
local function Gc(M, w)
  SendPacket(
    2,
    "action|dialog_return\n"
      .. (
        "dialog_name|vending\n"
        .. (
          "tilex|"
          .. (
            tostring(M["x"])
            .. (
              "|\n"
              .. (
                "tiley|"
                .. (
                  tostring(M["y"])
                  .. (
                    "|\n"
                    .. (
                      "verify|1|\n"
                      .. (
                        "buycount|"
                        .. (
                          tostring(w)
                          .. (
                            "|\n"
                            .. (
                              "expectprice|"
                              .. (
                                tostring(M["price"]) .. ("|\n" .. ("expectitem|" .. (tostring(M["itemID"]) .. "|\n")))
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
local function Jc(M)
  M = tonumber(M) or 0
  if M <= -2 then
    return math["floor"](math["abs"](M))
  end
  return 1
end
local function Ic(M, w)
  M = math["max"](0, math["floor"](tonumber(M) or 0))
  w = math["max"](1, math["floor"](tonumber(w) or 1))
  return math["floor"](M / w) * w
end
local function sc(M, w)
  local d = math["floor"](M / w)
  if d <= 1 then
    return 0
  end
  return math["max"](1, math["floor"](d / 2)) * w
end
local function Nc(M)
  M = math["floor"](tonumber(M) or 0)
  if M < 1 then
    return true
  end
  if not dc(U, "BUY") then
    oI("Could not enter buy world.")
    return false
  end
  nI()
  DI("GO TO VENDING")
  local w = nil
  local function d()
    local M, d = pc()
    while N and (M == nil or (o and M["price"] ~= o)) do
      if not o then
        oI(d or "Choose a vending that sells the selected item.")
        return nil, false
      end
      if not cc() then
        return nil, "DEPLETED"
      end
      w = nil
      M, d = pc()
    end
    return M, nil
  end
  local r, S = d()
  if not r then
    return S or false
  end
  if not o then
    o = r["price"]
    dI()
  end
  if o == 0 then
    oI("Starting vending has no usable price. Select a stocked vend.")
    return false
  end
  if not Pc() then
    oI("Cannot reach selected vending (" .. (k .. ("," .. (n .. ")."))))
    return false
  end
  while N and (UI(D) < M and Z < W) do
    ::next_buy_cycle::
    r, S = d()
    if not r then
      return S or false
    end
    if not Pc() then
      oI("Could not reach next vending (" .. (k .. ("," .. (n .. ")."))))
      return false
    end
    local T = UI(D)
    local j = W - Z
    local m = jI - T
    local C = math["min"](M - T, j, m)
    local t = Jc(o)
    local z = Ic(C, t)
    if z < t then
      if T > 0 and j >= t then
        DI("BACKPACK PRICE-UNIT FULL - STORE " .. T)
        return true
      end
      DI("UNBUYABLE FINAL PRICE REMAINDER " .. j)
      return "UNIT_REMAINDER"
    end
    if w ~= nil then
      z = Ic(math["min"](z, w), t)
      if z < t then
        if not cc() then
          return "DEPLETED"
        end
        w = nil
        Sleep(OI)
        goto next_buy_cycle
      end
    end
    local O = false
    local X = Ac(r)
    if X == nil then
      oI("Vending dialog did not open. Stock cannot be checked safely.")
      return false
    end
    if tonumber(X["x"]) ~= r["x"] or tonumber(X["y"]) ~= r["y"] then
      oI("Different vending opened; cannot confirm exact price.")
      return false
    end
    if tonumber(X["itemID"]) ~= D or tonumber(X["price"]) ~= o then
      DI("VEND ITEM/PRICE CHANGED - SKIP")
    else
      local M = tonumber(X["stock"])
      if M == nil then
        oI("Vending stock was not found in the dialog.")
        return false
      end
      z = Ic(math["min"](z, M), t)
      if z < t then
        DI("VEND STOCK BELOW BUY UNIT @ " .. (k .. ("," .. n)))
      else
        DI("BUY " .. (z .. (" / STOCK " .. M)))
        if not N then
          return false
        end
        Gc(X, z)
        local w = 0
        while w < tI do
          local M = UI(D)
          if M > T then
            break
          end
          Sleep(100)
          w = w + 100
        end
        local d = UI(D)
        if d <= T then
          Sleep(YI)
          d = UI(D)
        end
        if d > T then
          local M = d - T
          q = D
          Z = Z + M
          if not dI() then
            nI()
            aI()
            oI("Purchase confirmed but progress could not be saved. Retry Start after storage is available.")
            return false
          end
          nI()
          aI()
          if not N then
            return false
          end
          DI("BOUGHT " .. (M .. (" / REQUESTED " .. z)))
          O = true
        else
          if not N then
            return false
          end
          DI("BUY NOT CONFIRMED @ " .. (k .. ("," .. n)))
        end
      end
    end
    if not N then
      return false
    end
    if not O then
      if not cc() then
        DI("ALL MATCHING VENDS EXHAUSTED - STORE FIRST")
        return "DEPLETED"
      end
      w = nil
      if not Pc() then
        oI("Could not reach next same-price vending.")
        return false
      end
    end
    Sleep(OI)
  end
  return N and (UI(D) >= M or Z >= W)
end
local function ic(M, w)
  M = math["floor"](tonumber(M) or 0)
  if M < 1 or UI(D) < 1 then
    return true
  end
  if not dc(H, "STORAGE") or not lI(H) then
    oI("Could not enter storage world or its linked door.")
    return false
  end
  while N and UI(D) > 0 do
    if not lI(H) then
      DI("WAIT STORAGE WORLD - NO DROP")
      return false
    end
    DI("STORAGE PATH -> " .. (Q .. ("," .. a)))
    if not Tc(Q, a) then
      DI("WAIT STORAGE POSITION " .. (Q .. ("," .. a)))
      return false
    end
    if not Sc(Q, a) then
      DI("NOT AT DROP TILE - NO DROP")
      return false
    end
    local M = false
    for w = 1, 2, 1 do
      if not N or not lI(H) or not Sc(Q, a) then
        DI("DROP POSITION LOST - NO SHIFT")
        return false
      end
      local d = UI(D)
      if d < 1 then
        return true
      end
      DI("DROP " .. (w .. ("/2 @ " .. (Q .. ("," .. a)))))
      iI = true
      bI = false
      local r = pcall(function()
        SendPacket(2, "action|drop\nitemID|" .. tostring(D))
      end)
      if not r then
        iI = false
        bI = false
        DI("DROP REQUEST ERROR - WAIT")
        return false
      end
      local S = 0
      while N and (lI(H) and S < fI) do
        if bI or UI(D) < d then
          break
        end
        Sleep(100)
        S = S + 100
      end
      local T = bI
      iI = false
      bI = false
      if not N or not lI(H) then
        return false
      end
      if not Sc(Q, a) then
        DI("MOVEMENT DURING DROP - NO SHIFT")
        return false
      end
      if UI(D) < d then
        M = true
        break
      end
      if T then
        local M = pcall(function()
          SendPacket(
            2,
            "action|dialog_return\n"
              .. ("dialog_name|drop_item\n" .. ("itemID|" .. (tostring(D) .. ("|\n" .. ("count|" .. tostring(d))))))
          )
        end)
        if not M then
          DI("DROP CONFIRM ERROR - WAIT")
          return false
        end
        S = 0
        while N and (lI(H) and S < zI) do
          if UI(D) < d then
            break
          end
          Sleep(100)
          S = S + 100
        end
      else
        DI("DROP DIALOG NOT OPENED " .. (w .. "/2"))
      end
      if UI(D) >= d then
        Sleep(850)
      end
      nI()
      if UI(D) < d then
        M = true
        break
      end
      if not lI(H) or not Sc(Q, a) then
        DI("DROP POSITION CHANGED - NO SHIFT")
        return false
      end
      if w == 1 then
        DI("DROP FAILED - RETRY SAME TILE")
        Sleep(550)
      end
    end
    if M then
      v = 0
      nI()
      if UI(D) == 0 then
        DI("STORAGE DROP COMPLETE")
        return true
      end
      Sleep(250)
    else
      if Q <= 0 then
        oI("Storage is full all the way to the left edge.")
        return false
      end
      Q = Q - 1
      v = 0
      pcall(function()
        editValue("AVD_activedrop", Q .. (", " .. a))
      end)
      DI("DROP FULL / SHIFT LEFT -> " .. (Q .. ("," .. a)))
      eI("Storage moved left to " .. (Q .. ("," .. a)))
      dI()
      Sleep(800)
      return false
    end
  end
  return UI(D) == 0
end
local function bc()
  local M = UI(D)
  nI()
  if M < 1 then
    return true
  end
  return ic(M, "Dropped all selected item")
end
local function fc()
  local M = UI(D)
  nI()
  if M < 1 then
    eI("Inventory check: no existing target item.")
    return true
  end
  DI("INITIAL DROP")
  eI("Inventory check: dropping existing " .. (tostring(M) .. (" " .. (HI(D) .. " first."))))
  return ic(M, "Initial inventory dropped")
end
local function ec()
  rI["AVD_enable"] = true
  pcall(function()
    EditToggle("AVD_enable", false)
  end)
  pcall(function()
    editToggle("AVD_enable", false)
  end)
  rI["AVD_enable"] = nil
end
function onVariant(M, w)
  if M ~= nil and (M["v1"] == "OnDialogRequest" and type(M["v2"]) == "string") then
    local w = M["v2"]
    if N and (iI and w:find("drop_item", 1, true)) then
      bI = true
      return true
    end
    if
      N
      and (
        JI
        and (
          w:find("end_dialog|vending", 1, true) and (
            w:find("embed_data|tilex|", 1, true) or w:find("expectitem|", 1, true)
          )
        )
      )
    then
      sI = w
      II = true
      return true
    end
  end
  return false
end
function onValue(M, w, d)
  if rI[w] then
    return
  end
  if w == "AVD_totalbought" or w == "AVD_totalremaining" then
    return
  end
  if w == "AVD_licensekey" then
    local M = j(d)
    if V and M ~= j(f) then
      y = y + 1
      V = false
      ec()
      DI("STOPPED - LICENSE CHANGED")
    end
    f = M
    e = false
    gI("NOT VERIFIED")
    return
  end
  if w == "AVD_verifylicense" then
    runThread(function()
      uI(false)
    end)
    return
  end
  if w == "AVD_clearlicense" then
    if V then
      y = y + 1
      V = false
      ec()
    end
    e = false
    f = ""
    T = ""
    z()
    pcall(function()
      editValue("AVD_licensekey", "")
    end)
    gI("NOT VERIFIED")
    eI("Saved license cleared.")
    return
  end
  if w == "AVD_enable" then
    if d == true then
      if N or V then
        return
      end
      if b then
        ec()
        eI("Wait for Find Vend to finish.")
        return
      end
      if i then
        ec()
        eI("The previous run is still stopping. Try Start again shortly.")
        return
      end
      y = y + 1
      local M = y
      local w = j(f)
      V = true
      N = false
      DI("CHECKING LICENSE BEFORE START")
      runThread(function()
        local d = 0
        while g and (V and (y == M and d < 30000)) do
          Sleep(100)
          d = d + 100
        end
        if not V or y ~= M then
          return
        end
        local r = false
        if not g then
          r = uI(true)
        else
          gI("VERIFY BUSY - RETRY START")
        end
        if not V or y ~= M then
          return
        end
        if j(f) ~= w then
          r = false
          e = false
          gI("KEY CHANGED - RETRY START")
        end
        if not r then
          V = false
          N = false
          ec()
          DI("LICENSE NOT VALID - NOT STARTED")
          eI("License was not approved by the server. Start blocked (" .. (tostring(u) .. ")."))
          return
        end
        if Z > 0 and q ~= D then
          oI(
            "Saved progress belongs to item "
              .. (q .. ". Reselect it to resume, or edit Total Buy Amount for a new target.")
          )
          return
        end
        if not dI() then
          oI("Settings storage is required to save purchase progress.")
          return
        end
        K = nil
        l = {}
        MI = false
        wI = ""
        if Q > F or Q < 0 then
          Q = F
        end
        v = 0
        pcall(function()
          editValue("AVD_activedrop", Q .. (", " .. a))
        end)
        E = false
        pcall(function()
          editValue("AVD_activedrop", Q .. (", " .. a))
        end)
        local S = nil
        local T = KI(U)
        if qI() == T then
          S = pc()
        end
        if S ~= nil then
          o = S["price"]
        end
        GI = true
        SI("AVD_itemid", tostring(D))
        kI()
        nI()
        aI()
        if D <= 0 then
          oI("Choose a valid target item first.")
          return
        end
        if W < 1 then
          oI("Total Buy Amount must be at least 1.")
          return
        end
        if WI(U) == "" then
          oI("Set Buy World first.")
          return
        end
        if WI(H) == "" then
          oI("Set Drop World first.")
          return
        end
        if not EI(true) then
          oI("Could not enable ModFly at start.")
          return
        end
        if y ~= M then
          return
        end
        V = false
        N = true
        DI("STARTING")
        eI("Started. Bought " .. (Z .. ("/" .. (W .. ("; remaining " .. (math["max"](0, W - Z) .. "."))))))
      end)
    else
      y = y + 1
      V = false
      N = false
      EI(false)
      iI = false
      bI = false
      JI = false
      II = false
      sI = ""
      DI("STOPPED")
      eI("Auto Vend V2.1 stopped.")
    end
    return
  end
  if w == "AVD_itempicker" then
    if not Rc(d) then
      eI("Could not read item from Item Picker.")
    end
    return
  end
  if w == "AVD_itemid" then
    if not Yc(tonumber(d)) then
      SI("AVD_itemid", D)
    end
    return
  end
  if w == "AVD_totalbuyamount" then
    local M = tonumber(d)
    if M == nil then
      SI("AVD_totalbuyamount", W)
      return
    end
    M = math["min"](999999, math["max"](1, math["floor"](M)))
    if M ~= W then
      if N or V or i then
        eI("Stop Auto Vend and let the current action finish before editing Total Buy Amount.")
      else
        W = M
        Z = 0
        q = 0
        aI()
        dI()
      end
    end
    SI("AVD_totalbuyamount", W)
    return
  end
  if w == "AVD_buyworld" then
    U = WI(d)
    dI()
    return
  end
  if w == "AVD_setbuyworld" then
    local M = qI()
    if M == "" or M == "EXIT" then
      eI("Current world is not available.")
      return
    end
    U = M
    SI("AVD_buyworld", U)
    dI()
    eI("Buy World = " .. U)
    return
  end
  if w == "AVD_vendx" then
    local M = tonumber(d)
    if M ~= nil then
      k = math["floor"](M)
      o = nil
      K = nil
      l = {}
      QI()
      dI()
    end
    return
  end
  if w == "AVD_vendy" then
    local M = tonumber(d)
    if M ~= nil then
      n = math["floor"](M)
      o = nil
      K = nil
      l = {}
      QI()
      dI()
    end
    return
  end
  if w == "AVD_findvend" then
    zc()
    return
  end
  if w == "AVD_setvend" then
    if b then
      eI("Wait for Find Vend to finish.")
      return
    end
    local M, w = rc()
    if M == nil or w == nil then
      eI("Player position is not available.")
      return
    end
    k = M
    n = w
    SI("AVD_vendx", tostring(k))
    SI("AVD_vendy", tostring(n))
    QI()
    local d = pc()
    if d ~= nil then
      editValue("AVD_vendprice", tostring(d["price"]))
      o = d["price"]
    else
      editValue("AVD_vendprice", "NONE")
    end
    dI()
    eI("Vending position = (" .. (tostring(k) .. (", " .. (tostring(n) .. ")"))))
    return
  end
  if w == "AVD_dropworld" then
    H = WI(d)
    dI()
    return
  end
  if w == "AVD_setdropworld" then
    local M = qI()
    if M == "" or M == "EXIT" then
      eI("Current world is not available.")
      return
    end
    H = M
    SI("AVD_dropworld", H)
    dI()
    eI("Drop World = " .. H)
    return
  end
  if w == "AVD_dropx" then
    local M = tonumber(d)
    if M ~= nil then
      F = math["floor"](M)
      Q = F
      v = 0
      pcall(function()
        editValue("AVD_activedrop", Q .. (", " .. a))
      end)
      dI()
    end
    return
  end
  if w == "AVD_dropy" then
    local M = tonumber(d)
    if M ~= nil then
      a = math["floor"](M)
      pcall(function()
        editValue("AVD_activedrop", Q .. (", " .. a))
      end)
      dI()
    end
    return
  end
  if w == "AVD_setdrop" then
    local M, w = rc()
    if M == nil or w == nil then
      eI("Player position is not available.")
      return
    end
    F = M
    a = w
    Q = M
    v = 0
    pcall(function()
      editValue("AVD_activedrop", Q .. (", " .. a))
    end)
    SI("AVD_dropx", tostring(F))
    SI("AVD_dropy", tostring(a))
    dI()
    eI("Drop stand position = (" .. (tostring(F) .. (", " .. (tostring(a) .. ")"))))
    return
  end
end
applyHook()
if type(setOnValue) == "function" then
  pcall(function()
    setOnValue("AVD_itempicker", function(...)
      local M = { ... }
      for w = #M, 1, -1 do
        if Rc(M[w]) then
          return
        end
      end
    end)
  end)
  for M, w in ipairs({ "AVD_buyworld", "AVD_vendx", "AVD_vendy", "AVD_dropworld", "AVD_dropx", "AVD_dropy" }) do
    local d = w
    pcall(setOnValue, d, function(...)
      local M = select("#", ...)
      if M > 0 then
        onValue(nil, d, select(M, ...))
      end
    end)
  end
end
runThread(function()
  DI("STOPPED")
  kI()
  nI()
  aI()
  QI()
  pcall(function()
    editValue("AVD_activedrop", Q .. (", " .. a))
  end)
  if h ~= nil and not x then
    dI()
  end
  if f ~= "" then
    pcall(function()
      editValue("AVD_licensekey", f)
    end)
    gI("CHECKING SAVED KEY...")
    Sleep(300)
    uI(true)
  else
    gI("NOT VERIFIED")
  end
  while true do
    if N then
      i = true
      nI()
      aI()
      if GI then
        if fc() then
          GI = false
          Sleep(OI)
        else
          Sleep(350)
        end
      elseif E then
        if UI(D) == 0 then
          E = false
        elseif bc() then
          E = (UI(D) > 0)
          Sleep(OI)
        else
          Sleep(450)
        end
      elseif MI then
        if UI(D) > 0 then
          E = true
          DI("ALL VENDS DONE - STORE REMAINING ITEMS")
        else
          DI("ALL VENDS DONE - RETURN TO STORAGE")
          if dc(H, "STORAGE") and lI(H) then
            oI(wI ~= "" and wI or "No more purchasable same-price vends.")
          else
            DI("WAIT STORAGE BEFORE AUTOMATIC STOP")
            Sleep(700)
          end
        end
      elseif Z >= W then
        if UI(D) > 0 then
          E = true
        else
          oI("Total buy target reached: " .. (tostring(Z) .. ("/" .. tostring(W))))
        end
      else
        local M = W - Z
        local w = math["min"](jI, M)
        local d = Nc(w)
        if d == "DEPLETED" or d == "UNIT_REMAINDER" then
          MI = true
          wI = d == "DEPLETED" and "No more purchasable same-price vending stock. Stored and stopped."
            or "Remaining target cannot be bought in whole price units. Stored and stopped."
          E = UI(D) > 0
          DI("BUYING FINISHED - STORE THEN STOP")
        elseif d == true then
          E = UI(D) > 0
          if not E then
            Sleep(250)
          end
        else
          if N and UI(D) > 0 then
            E = true
          end
          Sleep(350)
        end
      end
      i = false
    else
      Sleep(200)
    end
  end
end)
