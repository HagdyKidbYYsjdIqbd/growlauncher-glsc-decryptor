ZS_LABEL_WIDTH = ZS_LABEL_WIDTH or 30
if not ZS_HUB then
  ZS_HUB = { ["native"] = addHook, ["callbacks"] = {}, ["installed"] = {} }
  local l = {
    ["onvalue"] = "onValue",
    ["ondrawimgui"] = "onDrawImGui",
    ["onvariant"] = "onVariant",
    ["ondialog"] = "onDialog",
    ["onsendpacket"] = "onSendPacket",
    ["onsendpacketraw"] = "onSendPacketRaw",
  }
  local s = {
    ["onValue"] = "onvalue",
    ["onDrawImGui"] = "ondrawimgui",
    ["OnVariant"] = "onvariant",
    ["OnDialog"] = "ondialog",
    ["OnSendPacket"] = "onsendpacket",
    ["OnSendPacketRaw"] = "onsendpacketraw",
  }
  local function W(s)
    if ZS_HUB["installed"][s] then
      return
    end
    ZS_HUB["installed"][s] = true
    local W = ZS_HUB["callbacks"][s]
    ZS_HUB["native"](function(...)
      local l = false
      for K = 1, #W, 1 do
        local L, n = pcall(W[K], ...)
        if not L then
          local l = "Hook error (" .. (s .. ("): " .. tostring(n)))
          if growtopia and type(growtopia["notify"]) == "function" then
            pcall(growtopia["notify"], l)
          else
            print(l)
          end
        elseif n == true then
          l = true
        end
      end
      return l
    end, l[s] or s)
  end
  function addHook(l, K)
    if type(l) ~= "function" then
      return
    end
    K = K or "onvalue"
    K = s[K] or (tostring(K)):lower()
    if not ZS_HUB["callbacks"][K] then
      ZS_HUB["callbacks"][K] = {}
    end
    table["insert"](ZS_HUB["callbacks"][K], l)
    W(K)
  end
end
if not ZS_thread then
  function ZS_thread(l)
    runThread(l)
  end
end
if not ZS_label then
  function ZS_label(l, s, ...)
    s = tostring(s == nil and "" or s)
    local W = ZS_LABEL_WIDTH
    local function K(l)
      if utf8 and utf8["len"] then
        return utf8["len"](l) or #l
      end
      return #l
    end
    local L, n = {}, ""
    for l in s:gmatch("%S+") do
      if n == "" then
        n = l
      elseif (K(n) + 1) + K(l) <= W then
        n = n .. (" " .. l)
      else
        L[#L + 1] = n
        n = l
      end
    end
    if n ~= "" then
      L[#L + 1] = n
    end
    if #L == 0 then
      L[1] = s
    end
    for s, W in ipairs(L) do
      l:addLabel(W, ...)
    end
  end
end
if not ZS_CATEGORY_ADDED then
  ZS_CATEGORY_ADDED = true
  if type(addCategory) == "function" then
    pcall(addCategory, "ZS", "Shield")
  end
end
local l = { ["tag"] = "k05", ["life"] = "ZSA-WTW", ["unlocked"] = false, ["entered"] = "", ["n"] = 0 }
local function s(l)
  if growtopia and type(growtopia["notify"]) == "function" then
    pcall(growtopia["notify"], tostring(l))
  else
    print("[ZS] " .. tostring(l))
  end
end
local W = s
local K = addHook
local function L(s, W)
  if type(s) ~= "function" then
    return
  end
  return K(function(...)
    if not l["unlocked"] then
      return false
    end
    return s(...)
  end, W)
end
local function n(l)
  local s = tostring(l)
  local W, K = s:find('"menu"%s*:%s*%[')
  if not W then
    return nil
  end
  local L, n, b, x = 1, K + 1, false, false
  while n <= #s do
    local l = s:sub(n, n)
    if b then
      if x then
        x = false
      elseif l == "\\" then
        x = true
      elseif l == '"' then
        b = false
      end
    elseif l == '"' then
      b = true
    elseif l == "[" then
      L = L + 1
    elseif l == "]" then
      L = L - 1
      if L == 0 then
        return s:sub(K + 1, n - 1)
      end
    end
    n = n + 1
  end
end
local function b()
  l["n"] = l["n"] + 1
  local s = UserInterface["new"]("ZS ACCESS", "Lock")
  s:addLabelApp("* ACCESS KEY *", "Lock")
  ZS_label(s, "Enter your key. You can look around, but everything works only after unlock.")
  s:addInputString("Enter Key", "", "Enter Key", "Your key", "Key", "zskey_" .. (l["tag"] .. ("_" .. l["n"])))
  s:addButton("UNLOCK", "zsunl_" .. (l["tag"] .. ("_" .. l["n"])))
  s:addDivider()
  return s
end
local x = addIntoModule
local function Z(s, W, ...)
  if type(s) == "string" and not s:find("zskey_" .. (l["tag"] .. "_"), 1, true) then
    local l, K = pcall(function()
      local l = b()
      local W = n(l:generateJSON())
      local K, L = s:find('"menu"%s*:%s*%[')
      if not (W and K) then
        return nil
      end
      local x = s:sub(L + 1)
      local Z = x:match("^%s*%]") and "" or ","
      return s:sub(1, L) .. (W .. (Z .. x))
    end)
    if l and K then
      s = K
    else
      pcall(function()
        x((b()):generateJSON(), W)
      end)
    end
  end
  return x(s, W, ...)
end
local function m(...)
  local W = select("#", ...)
  local K = { ... }
  local L, n = "zskey_" .. (l["tag"] .. "_"), "zsunl_" .. (l["tag"] .. "_")
  local function b(l)
    if type(l) ~= "string" then
      return nil
    end
    if l:sub(1, #L) == L then
      return "key"
    end
    if l:sub(1, #n) == n then
      return "btn"
    end
  end
  local x, Z
  local function m(l, s)
    if x or s > 2 then
      return
    end
    if type(l) == "string" then
      x = b(l)
    elseif type(l) == "table" then
      for W, K in pairs(l) do
        if b(K) then
          x = b(K)
          Z = l["value"] or l["text"] or l["v2"]
          return
        end
        if b(W) then
          x = b(W)
          Z = K
          return
        end
        if type(K) == "table" then
          m(K, s + 1)
        end
      end
    end
  end
  for l = 1, W, 1 do
    m(K[l], 0)
    if x then
      if Z == nil then
        Z = K[l + 1]
      end
      break
    end
  end
  if x == "key" then
    l["entered"] = tostring(Z or "")
    return true
  elseif x == "btn" then
    local W = ((l["entered"]:upper()):gsub("%s+", ""))
    if W == l["life"]:upper() then
      l["unlocked"] = true
      s("Key accepted. Unlocked!")
    else
      s("Invalid key.")
    end
    return true
  end
  return false
end
K(m, "onvalue")
local S, z = false, false
local E = nil
local function i(l)
  if growtopia and type(growtopia["notify"]) == "function" then
    pcall(growtopia["notify"], tostring(l))
  end
end
local function U(l)
  if type(getValue) ~= "function" then
    return nil
  end
  local s, W
  pcall(function()
    s = getValue(1, l)
  end)
  pcall(function()
    W = getValue(2, l)
  end)
  return W ~= nil and W or s
end
local function q(l)
  if type(l) == "number" then
    return math["floor"](l)
  end
  if type(l) == "string" then
    local s = tonumber(l:match("%d+"))
    if s then
      return math["floor"](s)
    end
  elseif type(l) == "table" then
    return tonumber(l["id"] or l["itemID"] or l["itemid"] or l["value"] or l[1])
  end
  return nil
end
local function o(l)
  local s, W = {}, {}
  for l in (tostring(l or "")):gmatch("[^,;]+") do
    l = l:match("^%s*(.-)%s*$")
    local K = l:upper()
    if l ~= "" and not W[K] then
      W[K] = true
      s[#s + 1] = K
    end
  end
  return s
end
local function Y()
  local l, s = pcall(GetWorldName)
  return l and tostring(s or "") or ""
end
local function A(l, s)
  local W = 0
  while W < s and not z do
    if (Y()):upper() == l:upper() then
      return true
    end
    Sleep(100)
    W = W + 100
  end
  return (Y()):upper() == l:upper()
end
local function N(l)
  local s, W = pcall(growtopia["checkInventoryCount"], l)
  return s and (tonumber(W) or 0) or 0
end
local function a()
  local l, s = pcall(GetObjects)
  if l and type(s) == "table" then
    return s
  end
  l, s = pcall(GetObjectList)
  return l and (type(s) == "table" and s) or {}
end
local function B(l)
  local s = {}
  for W, K in pairs(a()) do
    local L = tonumber(K and (K["itemid"] or K["itemID"] or K["item_id"] or K["id"]))
    local n = K and (K["pos"] or K["position"])
    local b = tonumber((n and (n["x"] or n["posX"])) or (K and (K["x"] or K["posX"])))
    local x = tonumber((n and (n["y"] or n["posY"])) or (K and (K["y"] or K["posY"])))
    if L == l and (b and x) then
      s[#s + 1] = { ["x"] = math["floor"](b / 32), ["y"] = math["floor"](x / 32) }
    end
  end
  return s
end
local function v(l, s)
  local W = GetLocal and GetLocal() or nil
  if not W then
    return false
  end
  local K = (W["posX"] or 0) / 32
  local L = (W["posY"] or 0) / 32
  return math["abs"](K - l) <= 1 and math["abs"](L - s) <= 1
end
local function M(l)
  if type(FindPath) ~= "function" then
    return 0
  end
  local s = N(l)
  local W = B(l)
  local K = 0
  while #W == 0 and (K < 2500 and not z) do
    Sleep(125)
    K = K + 125
    W = B(l)
  end
  for s, W in ipairs(W) do
    if z then
      break
    end
    local K = N(l)
    FindPath(W["x"], W["y"])
    Sleep(180)
    local L = 0
    while not v(W["x"], W["y"]) and (L < 1500 and not z) do
      Sleep(50)
      L = L + 50
    end
    L = 0
    while N(l) <= K and (L < 700 and not z) do
      Sleep(50)
      L = L + 50
    end
  end
  return math["max"](0, N(l) - s)
end
local function R(l, s, W, K)
  if s <= 0 then
    return true
  end
  if type(FindPath) ~= "function" then
    return false
  end
  FindPath(W, K)
  Sleep(250)
  local L = GetLocal and GetLocal() or nil
  if not L then
    return false
  end
  local n = N(l)
  local b = pcall(function()
    growtopia["dropItem"](l)
  end)
  if not b then
    return false
  end
  Sleep(250)
  local x = pcall(function()
    SendPacket(
      2,
      "action|dialog_return\ndialog_name|drop_item\nitemID|" .. (l .. ("\ncount|" .. (s .. "\nbuttonClicked|drop")))
    )
  end)
  if not x then
    return false
  end
  Sleep(700)
  return N(l) < n
end
local function f()
  local l = q(U("zs_wtw_item"))
  local s = o(U("zs_wtw_worlds"))
  local W = (tostring(U("zs_wtw_destination") or "")):match("^%s*(.-)%s*$")
  local K = math["max"](1, tonumber(U("zs_wtw_limit")) or 200)
  local L = math["max"](250, tonumber(U("zs_wtw_delay")) or 2000)
  if not l or l <= 0 then
    i("WTW: choose one item in Item Box first.")
    return
  end
  if #s == 0 then
    i("WTW: enter the source worlds in Multiworld Box.")
    return
  end
  if W == "" then
    i("WTW: enter the destination world.")
    return
  end
  if not E or E["world"] ~= W:upper() then
    i("WTW: set the destination tile while standing in the destination world.")
    return
  end
  local n = Y()
  if n == "" then
    i("WTW: current world unavailable.")
    return
  end
  S, z = true, false
  local b = 0
  i("ZS AUTO WTW started. Item ID: " .. l)
  for s, W in ipairs(s) do
    if z or N(l) >= K then
      break
    end
    if (Y()):upper() ~= W then
      pcall(growtopia["warpTo"], W)
      if not A(W, 15000) then
        i("WTW: could not enter " .. (W .. "; skipped."))
      end
    end
    if (Y()):upper() == W then
      Sleep(L)
      b = b + M(l)
      i("WTW: " .. (W .. (" checked; inventory " .. (N(l) .. "."))))
    end
  end
  if not z and N(l) > 0 then
    pcall(growtopia["warpTo"], W:upper())
    if A(W, 15000) then
      Sleep(L)
      local s = N(l)
      if s > K then
        s = K
      end
      local n = R(l, s, E["x"], E["y"])
      i(n and ("WTW: dropped " .. (s .. (" item(s) in " .. (W .. ".")))) or "WTW: drop could not be confirmed.")
    else
      i("WTW: destination world could not be entered.")
    end
  end
  if n ~= "" and (Y()):upper() ~= n:upper() then
    pcall(growtopia["warpTo"], n)
    A(n, 15000)
  end
  S = false
  i("ZS AUTO WTW finished. Collected during this run: " .. (b .. "."))
end
L(function(l, s, W)
  if s == "zs_wtw_run" then
    if W and not S then
      if type(runThread) == "function" then
        runThread(f)
      else
        f()
      end
    elseif not W then
      z = true
    end
  elseif s == "zs_wtw_setpos" then
    local l = GetLocal and GetLocal() or nil
    local s = (tostring(U("zs_wtw_destination") or "")):match("^%s*(.-)%s*$")
    if l and (s ~= "" and (Y()):upper() == s:upper()) then
      E = { ["world"] = s:upper(), ["x"] = math["floor"]((l["posX"] or 0) / 32), ["y"] = math["floor"](
        (l["posY"] or 0) / 32
      ) }
      i("WTW drop position saved: " .. (E["world"] .. (" (" .. (E["x"] .. (", " .. (E["y"] .. ")"))))))
    else
      i("Warp to the Destination World, stand on the drop tile, then press Set Position.")
    end
  end
end, "onValue")
local r = UserInterface["new"]("ZS AUTO WTW", "Agriculture")
r:addLabelApp("* ZS AUTO WTW *", "Agriculture")
r:addTooltip(
  "* ZS AUTO WTW *",
  "Select exactly one item in Item Box. Enter only the worlds to search in Multiworld Box, then enter the destination world. Stand on the destination tile and press Set Position. WTW collects only the selected item and drops it at the saved destination.",
  "Info",
  true
)
r:addDivider()
r:addItemPicker("Item Box", "Blank", "", "zs_wtw_item")
r:addInputString(
  "Multiworld Box",
  "",
  "Source worlds",
  "Enter source worlds separated by commas",
  "Worlds",
  "zs_wtw_worlds"
)
r:addInputString(
  "Destination World",
  "",
  "Destination world",
  "World where the selected item should be dropped",
  "World",
  "zs_wtw_destination"
)
r:addButton("SET POSITION", "zs_wtw_setpos")
r:addSlider("Maximum item amount", 1, 200, 200, 1, false, "zs_wtw_limit")
r:addSlider("World delay (ms)", 250, 5000, 2000, 250, false, "zs_wtw_delay")
r:addToggle("ZS AUTO WTW", false, "zs_wtw_run", true)
Z(r:generateJSON(), "ZS")
if type(applyHook) == "function" then
  pcall(applyHook)
end
