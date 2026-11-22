ZS_LABEL_WIDTH = ZS_LABEL_WIDTH or 30
if not ZS_HUB then
  ZS_HUB = { ["native"] = addHook, ["callbacks"] = {}, ["installed"] = {} }
  local f = {
    ["onvalue"] = "onValue",
    ["ondrawimgui"] = "onDrawImGui",
    ["onvariant"] = "onVariant",
    ["ondialog"] = "onDialog",
    ["onsendpacket"] = "onSendPacket",
    ["onsendpacketraw"] = "onSendPacketRaw",
  }
  local Y = {
    ["onValue"] = "onvalue",
    ["onDrawImGui"] = "ondrawimgui",
    ["OnVariant"] = "onvariant",
    ["OnDialog"] = "ondialog",
    ["OnSendPacket"] = "onsendpacket",
    ["OnSendPacketRaw"] = "onsendpacketraw",
  }
  local function v(Y)
    if ZS_HUB["installed"][Y] then
      return
    end
    ZS_HUB["installed"][Y] = true
    local v = ZS_HUB["callbacks"][Y]
    ZS_HUB["native"](function(...)
      local f = false
      for c = 1, #v, 1 do
        local Z, M = pcall(v[c], ...)
        if not Z then
          local f = "Hook error (" .. (Y .. ("): " .. tostring(M)))
          if growtopia and type(growtopia["notify"]) == "function" then
            pcall(growtopia["notify"], f)
          else
            print(f)
          end
        elseif M == true then
          f = true
        end
      end
      return f
    end, f[Y] or Y)
  end
  function addHook(f, c)
    if type(f) ~= "function" then
      return
    end
    c = c or "onvalue"
    c = Y[c] or (tostring(c)):lower()
    if not ZS_HUB["callbacks"][c] then
      ZS_HUB["callbacks"][c] = {}
    end
    table["insert"](ZS_HUB["callbacks"][c], f)
    v(c)
  end
end
if not ZS_thread then
  function ZS_thread(f)
    runThread(f)
  end
end
if not ZS_label then
  function ZS_label(f, Y, ...)
    Y = tostring(Y == nil and "" or Y)
    local v = ZS_LABEL_WIDTH
    local function c(f)
      if utf8 and utf8["len"] then
        return utf8["len"](f) or #f
      end
      return #f
    end
    local Z, M = {}, ""
    for f in Y:gmatch("%S+") do
      if M == "" then
        M = f
      elseif (c(M) + 1) + c(f) <= v then
        M = M .. (" " .. f)
      else
        Z[#Z + 1] = M
        M = f
      end
    end
    if M ~= "" then
      Z[#Z + 1] = M
    end
    if #Z == 0 then
      Z[1] = Y
    end
    for Y, v in ipairs(Z) do
      f:addLabel(v, ...)
    end
  end
end
if not ZS_CATEGORY_ADDED then
  ZS_CATEGORY_ADDED = true
  if type(addCategory) == "function" then
    pcall(addCategory, "ZS", "Shield")
  end
end
local f = { ["tag"] = "k02", ["life"] = "ZSA-MWP", ["unlocked"] = false, ["entered"] = "", ["n"] = 0 }
local function Y(f)
  if growtopia and type(growtopia["notify"]) == "function" then
    pcall(growtopia["notify"], tostring(f))
  else
    print("[ZS] " .. tostring(f))
  end
end
local v = Y
local c = addHook
local function Z(Y, v)
  if type(Y) ~= "function" then
    return
  end
  return c(function(...)
    if not f["unlocked"] then
      return false
    end
    return Y(...)
  end, v)
end
local function M(f)
  local Y = tostring(f)
  local v, c = Y:find('"menu"%s*:%s*%[')
  if not v then
    return nil
  end
  local Z, M, n, b = 1, c + 1, false, false
  while M <= #Y do
    local f = Y:sub(M, M)
    if n then
      if b then
        b = false
      elseif f == "\\" then
        b = true
      elseif f == '"' then
        n = false
      end
    elseif f == '"' then
      n = true
    elseif f == "[" then
      Z = Z + 1
    elseif f == "]" then
      Z = Z - 1
      if Z == 0 then
        return Y:sub(c + 1, M - 1)
      end
    end
    M = M + 1
  end
end
local function n()
  f["n"] = f["n"] + 1
  local Y = UserInterface["new"]("ZS ACCESS", "Lock")
  Y:addLabelApp("* ACCESS KEY *", "Lock")
  ZS_label(Y, "Enter your key. You can look around, but everything works only after unlock.")
  Y:addInputString("Enter Key", "", "Enter Key", "Your key", "Key", "zskey_" .. (f["tag"] .. ("_" .. f["n"])))
  Y:addButton("UNLOCK", "zsunl_" .. (f["tag"] .. ("_" .. f["n"])))
  Y:addDivider()
  return Y
end
local b = addIntoModule
local function t(Y, v, ...)
  if type(Y) == "string" and not Y:find("zskey_" .. (f["tag"] .. "_"), 1, true) then
    local f, c = pcall(function()
      local f = n()
      local v = M(f:generateJSON())
      local c, Z = Y:find('"menu"%s*:%s*%[')
      if not (v and c) then
        return nil
      end
      local b = Y:sub(Z + 1)
      local t = b:match("^%s*%]") and "" or ","
      return Y:sub(1, Z) .. (v .. (t .. b))
    end)
    if f and c then
      Y = c
    else
      pcall(function()
        b((n()):generateJSON(), v)
      end)
    end
  end
  return b(Y, v, ...)
end
local function G(...)
  local v = select("#", ...)
  local c = { ... }
  local Z, M = "zskey_" .. (f["tag"] .. "_"), "zsunl_" .. (f["tag"] .. "_")
  local function n(f)
    if type(f) ~= "string" then
      return nil
    end
    if f:sub(1, #Z) == Z then
      return "key"
    end
    if f:sub(1, #M) == M then
      return "btn"
    end
  end
  local b, t
  local function G(f, Y)
    if b or Y > 2 then
      return
    end
    if type(f) == "string" then
      b = n(f)
    elseif type(f) == "table" then
      for v, c in pairs(f) do
        if n(c) then
          b = n(c)
          t = f["value"] or f["text"] or f["v2"]
          return
        end
        if n(v) then
          b = n(v)
          t = c
          return
        end
        if type(c) == "table" then
          G(c, Y + 1)
        end
      end
    end
  end
  for f = 1, v, 1 do
    G(c[f], 0)
    if b then
      if t == nil then
        t = c[f + 1]
      end
      break
    end
  end
  if b == "key" then
    f["entered"] = tostring(t or "")
    return true
  elseif b == "btn" then
    local v = ((f["entered"]:upper()):gsub("%s+", ""))
    if v == f["life"]:upper() then
      f["unlocked"] = true
      Y("Key accepted. Unlocked!")
    else
      Y("Invalid key.")
    end
    return true
  end
  return false
end
c(G, "onvalue")
local q = 250
local H = 190
local B = 1
local T = 200
local C = 4000
local e = false
local V = false
local O = false
local P = false
local y = false
local k = {
  ["worldIndex"] = 0,
  ["worldTotal"] = 0,
  ["worldName"] = "Waiting",
  ["targetIndex"] = 0,
  ["targetTotal"] = 0,
  ["worldPercent"] = 0,
  ["overallPercent"] = 0,
  ["status"] = "Ready",
}
local m = {}
local d = {}
local j = {}
local X = 1
local h = 1
local z = {
  ["science"] = 928,
  ["atm"] = 1008,
  ["tackle"] = 3044,
  ["chicken"] = 872,
  ["cow"] = 866,
  ["sheep"] = 3888,
  ["coffee"] = 1632,
  ["tea"] = 5116,
}
local U = {
  ["science"] = false,
  ["atm"] = false,
  ["tackle"] = false,
  ["chicken"] = false,
  ["cow"] = false,
  ["sheep"] = false,
  ["coffee"] = false,
  ["tea"] = false,
}
local D = { 914, 916, 918, 920, 924 }
local u =
  { ["Chemical G"] = 914, ["Chemical Y"] = 916, ["Chemical B"] = 918, ["Chemical R"] = 920, ["Chemical P"] = 924 }
local x = { "Egg", "Milk", "Wool", "Coffee", "Tea" }
local N = { ["Egg"] = 874, ["Milk"] = 868, ["Wool"] = 3890, ["Coffee"] = 1634, ["Tea"] = 5118 }
local r = { { "chicken", "Egg" }, { "cow", "Milk" }, { "sheep", "Wool" }, { "coffee", "Coffee" }, { "tea", "Tea" } }
local function g(f, Y)
  if growtopia and type(growtopia["getItemID"]) == "function" then
    local Y, v = pcall(growtopia["getItemID"], f)
    v = Y and tonumber(v) or nil
    if v and v > 0 then
      return v
    end
  end
  return tonumber(Y)
end
local function Q()
  local f, Y = {}, {}
  for v, c in ipairs(r) do
    if U[c[1]] then
      local v = c[2]
      local Z = g(v, N[v])
      if Z and (Z > 0 and not Y[Z]) then
        Y[Z] = true
        table["insert"](f, Z)
      end
    end
  end
  return f
end
local p = {
  { "Wiggly Worm", 2914 },
  { "Shiny Flashy Thing", 3012 },
  { "Salmon Eggs", 3014 },
  { "Fishing Fly", 3016 },
  { "Shrimp Lure", 3018 },
  { "Mega-Pellet Bait", 5528 },
  { "Uranium Glowing Lure", 5526 },
}
local a = { "Chemical G", "Chemical Y", "Chemical B", "Chemical R", "Chemical P" }
local R = nil
local function l()
  if not U["science"] then
    return {}
  end
  if not R then
    local f, Y = {}, {}
    for v, c in ipairs(a) do
      local Z = nil
      if growtopia and type(growtopia["getItemID"]) == "function" then
        local f, Y = pcall(growtopia["getItemID"], c)
        if f and (type(Y) == "number" and Y > 0) then
          Z = Y
        end
      end
      Z = Z or u[c]
      if type(Z) == "number" and (Z > 0 and not Y[Z]) then
        Y[Z] = true
        table["insert"](f, Z)
      end
    end
    R = f
  end
  return R
end
local function L()
  local f, Y = {}, {}
  if not U["tackle"] then
    return f
  end
  for v, c in ipairs(p) do
    local Z, M = c[1], c[2]
    local n = g(Z, M)
    if n and (n > 0 and not Y[n]) then
      Y[n] = true
      table["insert"](f, n)
    end
  end
  return f
end
local function s(f)
  if f == "science" then
    return l()
  end
  if f == "tackle" then
    return L()
  end
  if f == "other" then
    return Q()
  end
  return {}
end
local function J(f)
  if f == "science" then
    return m
  end
  if f == "tackle" then
    return d
  end
  if f == "other" then
    return j
  end
  return {}
end
local o
local I
local function A(f)
  local Y = {}
  if type(f) ~= "string" then
    return Y
  end
  for f in f:gmatch("[^,]+") do
    f = f:match("^%s*(.-)%s*$")
    if f ~= "" then
      table["insert"](Y, f:upper())
    end
  end
  return Y
end
local function E()
  local f, Y = {}, {}
  local function v(v)
    if type(v) == "number" and (v > 0 and not Y[v]) then
      Y[v] = true
      table["insert"](f, v)
    end
  end
  for f, Y in ipairs(l()) do
    v(Y)
  end
  for f, Y in ipairs(L()) do
    v(Y)
  end
  for f, Y in ipairs(Q()) do
    v(Y)
  end
  return f
end
local function i(f)
  local Y = 0
  local v = f and s(f) or E()
  for f, v in ipairs(v) do
    Y = Y + (growtopia["checkInventoryCount"](v) or 0)
  end
  return Y
end
local function W()
  for f, Y in ipairs(l()) do
    if (growtopia["checkInventoryCount"](Y) or 0) >= T then
      return true
    end
  end
  return false
end
local function F()
  for f, Y in ipairs(L()) do
    if (growtopia["checkInventoryCount"](Y) or 0) >= T then
      return true
    end
  end
  return false
end
local function K()
  for f, Y in ipairs(Q()) do
    if (growtopia["checkInventoryCount"](Y) or 0) >= T then
      return true
    end
  end
  return false
end
local function S(f, Y)
  if Y then
    return Y[f] == true
  end
  for Y, v in ipairs(E()) do
    if f == v then
      return true
    end
  end
  return false
end
local function w(f, Y)
  local v = 0
  while v < Y and not P do
    if (GetWorldName()):upper() == f:upper() then
      return true
    end
    Sleep(250)
    v = v + 250
  end
  return (GetWorldName()):upper() == f:upper()
end
local fl = UserInterface["new"]("ZS MULTIWORLD PROVIDER V2", "Agriculture")
fl:addLabelApp("* ZS MULTIWORLD PROVIDER V2 *", "Agriculture")
fl:addTooltip(
  "MULTIWORLD PROVIDER V2",
  "Add your farm worlds, storage worlds and provider settings. Turn AUTO FARM and AUTO COLLECT ON to begin. Turn AUTO FARM OFF to save your progress.",
  "Info",
  true
)
fl:addDivider()
ZS_label(fl, "1. FARM WORLDS")
fl:addInputString("Worlds to farm", "", "World list", "", "World", "world_list")
fl:addDivider()
ZS_label(fl, "2. STORAGE WORLDS & DROP POSITIONS")
ZS_label(fl, "SCIENCE STATION - Chemical storage")
fl:addInputString(
  "Science storage world",
  "",
  "Science storage world",
  "World for Science Station Chemicals",
  "World",
  "science_storage_world"
)
fl:addButton("SET SCIENCE DROP POSITION", "provider_set_science_position")
fl:addDivider()
ZS_label(fl, "TACKLE BOX - Bait storage")
fl:addInputString(
  "Tackle storage world",
  "",
  "Tackle storage world",
  "World for Tackle Box bait",
  "World",
  "tackle_storage_world"
)
fl:addButton("SET TACKLE DROP POSITION", "provider_set_tackle_position")
fl:addDivider()
ZS_label(fl, "FARM PROVIDERS - Egg, Milk, Wool, Coffee & Tea storage")
fl:addInputString(
  "Other provider storage world",
  "",
  "Other provider storage world",
  "World for Chicken, Cow, Sheep, Coffee Maker and Tea Set drops",
  "World",
  "other_storage_world"
)
fl:addButton("SET OTHER PROVIDER DROP POSITION", "provider_set_other_position")
fl:addDivider()
ZS_label(fl, "3. SELECT WHAT TO FARM")
fl:addToggle("Science Station", false, "provider_science", true)
fl:addToggle("ATM Machine", false, "provider_atm", true)
fl:addToggle("Tackle Box", false, "provider_tackle", true)
fl:addToggle("Chicken", false, "provider_chicken", true)
fl:addToggle("Cow", false, "provider_cow", true)
fl:addToggle("Sheep", false, "provider_sheep", true)
fl:addToggle("Coffee Maker", false, "provider_coffee", true)
fl:addToggle("Tea Set", false, "provider_tea", true)
fl:addDivider()
ZS_label(fl, "4. FARM CONTROLS")
fl:addToggle("> AUTO FARM", false, "provider_run", true)
fl:addToggle("AUTO COLLECT DROPS", false, "provider_collect", true)
local Yl = fl:generateJSON()
t(Yl, "ZS")
local function vl(f, Y)
  local v = GetLocal()
  SendPacketRaw(false, { ["x"] = v["posX"], ["y"] = v["posY"], ["px"] = f, ["py"] = Y, ["type"] = 3, ["value"] = 18 })
end
local function cl(f, Y)
  local v = GetLocal()
  local c = math["abs"](v["posX"] / 32 - f)
  local Z = math["abs"](v["posY"] / 32 - Y)
  return c <= 2 and Z <= 2
end
local function Zl(f, Y)
  local v = GetLocal()
  if not v then
    return false
  end
  local c = math["abs"](v["posX"] / 32 - f)
  local Z = math["abs"](v["posY"] / 32 - Y)
  return c <= 0.6 and Z <= 0.6
end
local function Ml()
  local f = "action|dialog_return\ndialog_name|drop_item\nbuttonClicked|cancel"
  if not pcall(function()
    sendPacket(2, f)
  end) then
    pcall(function()
      SendPacket(2, f)
    end)
  end
  Sleep(100)
end
local function nl(f, Y)
  local v = growtopia["checkInventoryCount"](f) or 0
  if v <= 0 or Y <= 0 then
    return true
  end
  if Y > v then
    Y = v
  end
  if type(growtopia["confirmDropItem"]) == "function" then
    pcall(function()
      growtopia["confirmDropItem"](f, Y)
    end)
    Sleep(1100)
    if (growtopia["checkInventoryCount"](f) or 0) < v then
      return true
    end
  end
  local c = pcall(function()
    growtopia["dropItem"](f)
  end)
  if not c then
    return false, "PowerKuy drop API unavailable"
  end
  Sleep(300)
  local Z = pcall(function()
    sendPacket(
      2,
      "action|dialog_return\n"
        .. ("dialog_name|drop_item\n" .. ("itemID|" .. (f .. ("\n" .. ("count|" .. (Y .. "\nbuttonClicked|drop"))))))
    )
  end)
  if not Z then
    Ml()
    return false, "Could not submit native drop dialog"
  end
  Sleep(1100)
  local M = growtopia["checkInventoryCount"](f) or 0
  if M < v then
    return true
  end
  return false, "Inventory count did not change"
end
I = function(f, Y)
  local v = s(f)
  local c = J(f)
  if i(f) <= 0 then
    return true
  end
  local Z = f == "science" and "science_storage_world"
    or (f == "tackle" and "tackle_storage_world" or "other_storage_world")
  local M = getValue(2, Z)
  if type(M) ~= "string" or M:match("^%s*$") then
    growtopia["notify"](
      (f == "science" and "Science" or (f == "tackle" and "Tackle" or "Other provider")) .. " storage world is missing."
    )
    return false
  end
  if #c == 0 then
    growtopia["notify"]("No " .. (f .. " drop positions saved. Set a position in front of its Display Box."))
    return false
  end
  local n = GetWorldName()
  local b = (M:match("^%s*(.-)%s*$")):upper()
  if n:upper() ~= b then
    growtopia["warpTo"](b)
    if not w(b, 15000) then
      growtopia["notify"]("Could not enter " .. (b .. (". " .. (f .. " items were not dropped."))))
      return false
    end
  end
  local t = 0
  for c, Z in ipairs(c) do
    if P or (Y and not O) or i(f) <= 0 then
      break
    end
    local M = Z["x"] + (Z["faceLeft"] and 1 or -1)
    FindPath(M, Z["y"])
    Sleep(350)
    FindPath(Z["x"], Z["y"])
    local n = false
    for f = 1, 60, 1 do
      Sleep(250)
      local Y = GetLocal()
      if Y and (Y["posX"] and Y["posY"]) then
        if math["floor"](Y["posX"] / 32) == Z["x"] and math["floor"](Y["posY"] / 32) == Z["y"] then
          n = true
          break
        end
      end
    end
    if n then
      for f, v in ipairs(v) do
        if P or (Y and not O) then
          break
        end
        local c = growtopia["checkInventoryCount"](v) or 0
        if c > 0 then
          local f, Y = nl(v, c)
          if f then
            local f = growtopia["checkInventoryCount"](v) or 0
            t = t + math["max"](0, c - f)
          else
            growtopia["notify"]("Drop failed for item ID " .. (v .. (": " .. tostring(Y))))
          end
        end
      end
    else
      growtopia["notify"](
        "Could not reach " .. (f .. (" drop position " .. (Z["x"] .. ("," .. (Z["y"] .. ". Trying next.")))))
      )
    end
  end
  if Y and not O then
    Ml()
  end
  local G = i(f)
  if n:upper() ~= b then
    growtopia["warpTo"](n)
    w(n, 15000)
  end
  if G == 0 then
    growtopia["notify"](
      (f == "science" and "Science Chemicals" or (f == "tackle" and "Tackle bait" or "Farm provider drops"))
        .. (" stored (" .. (t .. " items)."))
    )
    return true
  end
  growtopia["notify"]("Could not drop " .. (G .. (" " .. (f .. " items. Check box position, access and capacity."))))
  return false
end
local function bl()
  local f = nil
  if type(GetObjects) == "function" then
    local Y, v = pcall(GetObjects)
    if Y and type(v) == "table" then
      f = v
    end
  end
  if not f and type(GetObjectList) == "function" then
    local Y, v = pcall(GetObjectList)
    if Y and type(v) == "table" then
      f = v
    end
  end
  return f or {}
end
local function tl(f)
  if not f then
    return nil
  end
  return tonumber(f["itemid"] or f["itemID"] or f["id"] or f["item_id"])
end
local function Gl(f)
  if not f then
    return nil, nil
  end
  local Y = f["pos"] or f["position"]
  local v = (Y and (Y["x"] or Y["posX"])) or f["x"] or f["posX"]
  local c = (Y and (Y["y"] or Y["posY"])) or f["y"] or f["posY"]
  return tonumber(v), tonumber(c)
end
local function ql(f, Y, v)
  for c, Z in pairs(bl()) do
    if Z and tl(Z) == f then
      local f, c = Gl(Z)
      if f and (c and (math["floor"](f / 32) == Y and math["floor"](c / 32) == v)) then
        return true
      end
    end
  end
  return false
end
o = function(f, Y)
  if V then
    return false
  end
  V = true
  Sleep(300)
  local v = 0
  local c = 0
  local Z = nil
  if growtopia and type(growtopia["getItemID"]) == "function" then
    local f, Y = pcall(growtopia["getItemID"], "Display Box")
    if f and (type(Y) == "number" and Y > 0) then
      Z = Y
    end
  end
  local M = {}
  for f, Y in ipairs(E()) do
    M[Y] = true
  end
  if W() then
    growtopia["notify"]("Chemical inventory full. Storing before collecting more.")
    if not I("science", true) then
      V = false
      return false
    end
  end
  if F() then
    growtopia["notify"]("Tackle bait inventory full. Storing before collecting more.")
    if not I("tackle", true) then
      V = false
      return false
    end
  end
  if K() then
    growtopia["notify"]("Farm provider inventory full. Storing before collecting more.")
    if not I("other", true) then
      V = false
      return false
    end
  end
  local n = {}
  local b = {}
  while true do
    if not O or (f and P) then
      V = false
      return false
    end
    local Y = bl()
    local t = {}
    for f, Y in pairs(Y) do
      local v = tl(Y)
      if Y and S(v, M) then
        local f, v = Gl(Y)
        if f and v then
          table["insert"](t, Y)
        end
      end
    end
    table["sort"](t, function(f, Y)
      local v, c = Gl(f)
      local Z, M = Gl(Y)
      local n, b = math["floor"](v / 32), math["floor"](Z / 32)
      local t, G = math["floor"](c / 32), math["floor"](M / 32)
      if t ~= G then
        return t < G
      end
      if n ~= b then
        return n < b
      end
      return (tl(f) or 0) < (tl(Y) or 0)
    end)
    local G = false
    for Y, t in ipairs(t) do
      if not O or (f and P) then
        V = false
        return false
      end
      local B = tl(t)
      if t and S(B, M) then
        local Y, M = Gl(t)
        if Y and M then
          local t = math["floor"](Y / 32)
          local T = math["floor"](M / 32)
          local C = tostring(B) .. (":" .. (tostring(math["floor"](Y)) .. (":" .. tostring(math["floor"](M)))))
          local e = GetTile(t, T)
          if Z and (e and e["fg"] == Z) then
            c = c + 1
          elseif not n[C] then
            b[C] = (b[C] or 0) + 1
            if b[C] >= 3 then
              n[C] = true
            end
            FindPath(t, T)
            Sleep(q)
            if not O or (f and P) then
              V = false
              return false
            end
            if Zl(t, T) then
              Sleep(H)
              if not ql(B, t, T) then
                n[C] = true
                v = v + 1
              end
            end
            G = true
            if W() then
              growtopia["notify"](
                "One Chemical type reached 200. Storing tracked items at the saved drop positions now."
              )
              if not I("science", true) then
                V = false
                return false
              end
              n = {}
              b = {}
            end
            if F() then
              growtopia["notify"]("One Tackle bait stack reached 200. Storing bait separately.")
              if not I("tackle", true) then
                V = false
                return false
              end
              n = {}
              b = {}
            end
            if K() then
              growtopia["notify"]("A farm provider drop stack reached 200. Storing separately.")
              if not I("other", true) then
                V = false
                return false
              end
              n = {}
              b = {}
            end
          end
        end
      end
    end
    if not G then
      break
    end
    Sleep(250)
  end
  V = false
  if Y and O then
    local f = i("science") == 0 or I("science", true)
    local Y = i("tackle") == 0 or I("tackle", true)
    local v = i("other") == 0 or I("other", true)
    return f and (Y and v)
  end
  return true
end
local function Hl(f, Y, v, c, Z, M)
  local n = 0
  if Z > 0 then
    n = math["floor"]((math["max"](0, c - 1) / Z) * 100)
  elseif c > 0 then
    n = 100
  end
  local b = 0
  if Y > 0 then
    b = math["floor"](((math["max"](0, f - 1) + (n / 100)) / Y) * 100)
  end
  k["worldIndex"] = f or 0
  k["worldTotal"] = Y or 0
  k["worldName"] = tostring(v or "Unknown")
  k["targetIndex"] = math["min"](c or 0, Z or 0)
  k["targetTotal"] = Z or 0
  k["worldPercent"] = n
  k["overallPercent"] = b
  k["status"] = tostring(M or "Working")
end
Z(function(f)
  if not y then
    return
  end
  if not ImGui or type(ImVec2) ~= "function" then
    return
  end
  pcall(function()
    local f = ImGui["GetIO"]()
    local Y = f and f["DisplaySize"]
    local v = Y and Y["x"] or 800
    ImGui["SetNextWindowPos"](ImVec2(v * 0.5, 18), 1, ImVec2(0.5, 0))
    ImGui["SetNextWindowSize"](ImVec2(300, 0), 1)
    ImGui["SetNextWindowBgAlpha"](0.85)
    local c = ImGui["Begin"]("##MultiworldProviderHUD")
    if c then
      ImGui["Text"]("* MULTIWORLD PROVIDER V2 *")
      ImGui["Text"]("Creator: ZadStay")
      ImGui["Separator"]()
      ImGui["Text"](k["status"] .. ("  -  " .. k["worldName"]))
      ImGui["Text"](
        "World "
          .. (
            tostring(k["worldIndex"])
            .. (
              "/"
              .. (
                tostring(k["worldTotal"])
                .. ("   Providers " .. (tostring(k["targetIndex"]) .. ("/" .. tostring(k["targetTotal"]))))
              )
            )
          )
      )
    end
    ImGui["End"]()
  end)
end, "onDrawImGui")
local function Bl()
  local f = {}
  if U["science"] then
    f[z["science"]] = true
  end
  if U["atm"] then
    f[z["atm"]] = true
  end
  if U["tackle"] then
    f[z["tackle"]] = true
  end
  if U["chicken"] then
    f[z["chicken"]] = true
  end
  if U["cow"] then
    f[z["cow"]] = true
  end
  if U["sheep"] then
    f[z["sheep"]] = true
  end
  if U["coffee"] then
    f[z["coffee"]] = true
  end
  if U["tea"] then
    f[z["tea"]] = true
  end
  local Y = #A(getValue(2, "world_list"))
  local v, c = 0, 0
  local function Z()
    local Y, v = {}, {}
    local c = GetTiles() or {}
    for c, Z in pairs(c) do
      if Z and (Z["x"] ~= nil and Z["y"] ~= nil) then
        local c = GetTile(Z["x"], Z["y"])
        local M = c and (c["fg"] or c["foreground"]) or Z["fg"]
        if f[M] then
          local f = math["floor"](Z["y"])
          if not v[f] then
            v[f] = true
            Y[#Y + 1] = f
          end
        end
      end
    end
    table["sort"](Y)
    return Y
  end
  local function M(Y)
    local v = {}
    local c = GetTiles() or {}
    for c, Z in pairs(c) do
      if Z and (Z["x"] ~= nil and (Z["y"] ~= nil and math["floor"](Z["y"]) == Y)) then
        local c = GetTile(Z["x"], Z["y"])
        local M = c and (c["fg"] or c["foreground"]) or Z["fg"]
        if f[M] then
          v[#v + 1] = { ["x"] = math["floor"](Z["x"]), ["y"] = Y }
        end
      end
    end
    table["sort"](v, function(f, Y)
      return f["x"] < Y["x"]
    end)
    return v
  end
  while not P do
    local Y = Z()
    if #Y == 0 then
      break
    end
    local c = false
    for Y, Z in ipairs(Y) do
      if P then
        return false
      end
      local n = 0
      while not P do
        local Y = M(Z)
        if #Y == 0 then
          break
        end
        local b = Y[1]
        if not cl(b["x"], b["y"]) then
          FindPath(b["x"] + 1, b["y"])
          Sleep(q)
        end
        local t = false
        for Y, Z in ipairs(Y) do
          if P then
            return false
          end
          local M = GetTile(Z["x"], Z["y"])
          local n = M and (M["fg"] or M["foreground"])
          if M and f[n] then
            if not cl(Z["x"], Z["y"]) then
              FindPath(Z["x"] + 1, Z["y"])
              Sleep(q)
            end
            if cl(Z["x"], Z["y"]) then
              vl(Z["x"], Z["y"])
              Sleep(math["max"](100, H))
              local Y = GetTile(Z["x"], Z["y"])
              local M = Y and (Y["fg"] or Y["foreground"])
              if not Y or not f[M] then
                v = v + 1
                c = true
                t = true
                if O and not P then
                  local f = o(true, false)
                  if not f or P then
                    return false
                  end
                end
              end
            end
          end
        end
        local G = M(Z)
        if #G == 0 then
          break
        end
        if t then
          n = 0
        else
          n = n + 1
        end
        if n >= 3 then
          growtopia["notify"](
            "NO MISS paused: providers remain on row " .. (tostring(Z) .. ". The row was not skipped.")
          )
          return false
        end
        if not cl(G[1]["x"], G[1]["y"]) then
          FindPath(G[1]["x"] + 1, G[1]["y"])
          Sleep(q)
        end
      end
    end
    if not c then
      growtopia["notify"]("AUTO FIND paused: no provider was cleared. Check reachability and try again.")
      return false
    end
    Sleep(150)
  end
  if P then
    return false
  end
  h = 1
  if O then
    return o(true)
  end
  return true
end
local function Tl()
  P = false
  local f = getValue(2, "world_list")
  local Y = A(f)
  if #Y == 0 then
    e = false
    pcall(EditToggle, "ModFly", false)
    growtopia["notify"]("World List is empty.")
    return
  end
  if
    not U["science"]
    and (
      not U["atm"]
      and (
        not U["tackle"] and (
          not U["chicken"] and (not U["cow"] and (not U["sheep"] and (not U["coffee"] and not U["tea"])))
        )
      )
    )
  then
    e = false
    pcall(EditToggle, "ModFly", false)
    growtopia["notify"]("Select at least one provider.")
    return
  end
  if X > #Y then
    X = 1
    h = 1
  end
  growtopia["notify"]("Loaded " .. (#Y .. " farm worlds."))
  while X <= #Y do
    if P then
      break
    end
    local f = Y[X]
    Hl(X, #Y, f, 0, 0, "Entering world")
    if (GetWorldName()):upper() ~= f then
      growtopia["warpTo"](f)
      if not w(f, 15000) then
        growtopia["notify"]("Could not enter " .. (f .. ". Skipping."))
        X = X + 1
        h = 1
      end
    end
    if not P and (GetWorldName()):upper() == f then
      growtopia["notify"]("Farming " .. f)
      local Y = Bl()
      if not Y then
        break
      end
      Sleep(700)
      X = X + 1
      h = 1
    end
  end
  if not P and X > #Y then
    if i("science") > 0 then
      I("science", false)
    end
    if i("tackle") > 0 then
      I("tackle", false)
    end
    if i("other") > 0 then
      I("other", false)
    end
  end
  e = false
  pcall(EditToggle, "ModFly", false)
  if X > #Y then
    Hl(#Y, #Y, GetWorldName(), 1, 1, "Finished")
    growtopia["notify"]("MULTIWORLD FARMING FINISHED.")
    X = 1
    h = 1
  elseif P then
    growtopia["notify"]("Farming stopped. Position saved.")
  else
    growtopia["notify"]("Farming paused. Position saved.")
  end
  P = false
end
Z(function(f, Y, v)
  if Y == "provider_science" then
    U["science"] = v
  elseif Y == "provider_atm" then
    U["atm"] = v
  elseif Y == "provider_tackle" then
    U["tackle"] = v
  elseif Y == "provider_chicken" then
    U["chicken"] = v
  elseif Y == "provider_cow" then
    U["cow"] = v
  elseif Y == "provider_sheep" then
    U["sheep"] = v
  elseif Y == "provider_coffee" then
    U["coffee"] = v
  elseif Y == "provider_tea" then
    U["tea"] = v
  elseif
    Y == "provider_set_science_position"
    or Y == "provider_set_tackle_position"
    or Y == "provider_set_other_position"
  then
    local f = GetLocal()
    if f and (f["posX"] and f["posY"]) then
      local v = math["floor"](f["posX"] / 32)
      local c = math["floor"](f["posY"] / 32)
      local Z = Y == "provider_set_science_position" and m or (Y == "provider_set_tackle_position" and d or j)
      local M = false
      for f, Y in ipairs(Z) do
        if Y["x"] == v and Y["y"] == c then
          M = true
          break
        end
      end
      if M then
        growtopia["notify"]("Position already saved: " .. (v .. ("," .. c)))
      else
        table["insert"](Z, { ["x"] = v, ["y"] = c, ["faceLeft"] = f["isLeft"] and true or false })
        local M = Y == "provider_set_science_position" and "SCIENCE"
          or (Y == "provider_set_tackle_position" and "TACKLE" or "OTHER PROVIDER")
        growtopia["notify"](
          "Saved " .. (M .. (" position " .. (v .. ("," .. (c .. ". Face its Display Box before saving.")))))
        )
      end
    else
      growtopia["notify"]("Could not read your current position.")
    end
  elseif Y == "provider_collect" then
    O = v and true or false
    if O then
      growtopia["notify"]("AUTO COLLECT: ON. Drops will be collected left to right.")
      if not e and not V then
        P = false
        ZS_thread(function()
          o(false, true)
        end)
      end
    else
      Ml()
      growtopia["notify"]("AUTO COLLECT: OFF. Collection stopped and any open drop dialog was cancelled.")
    end
  elseif Y == "provider_run" and v then
    if e then
      return
    end
    e = true
    P = false
    pcall(EditToggle, "ModFly", true)
    y = true
    k["status"] = "Starting"
    k["worldName"] = "Preparing worlds"
    k["worldIndex"] = 0
    k["worldTotal"] = 0
    k["targetIndex"] = 0
    k["targetTotal"] = 0
    k["worldPercent"] = 0
    k["overallPercent"] = 0
    growtopia["notify"]("Multiworld Provider V2 started.")
    ZS_thread(function()
      Tl()
    end)
  elseif Y == "provider_run" and not v then
    P = true
    growtopia["notify"]("AUTO FARM: OFF. Saving current position.")
  end
end, "onValue")
growtopia["notify"]("* Welcome to Multiworld Provider V2 *\nCreator: ZadStay")
if type(applyHook) == "function" then
  pcall(applyHook)
end
