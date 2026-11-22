ZS_LABEL_WIDTH = ZS_LABEL_WIDTH or 30
if not ZS_HUB then
  ZS_HUB = { ["native"] = addHook, ["callbacks"] = {}, ["installed"] = {} }
  local Q = {
    ["onvalue"] = "onValue",
    ["ondrawimgui"] = "onDrawImGui",
    ["onvariant"] = "onVariant",
    ["ondialog"] = "onDialog",
    ["onsendpacket"] = "onSendPacket",
    ["onsendpacketraw"] = "onSendPacketRaw",
  }
  local g = {
    ["onValue"] = "onvalue",
    ["onDrawImGui"] = "ondrawimgui",
    ["OnVariant"] = "onvariant",
    ["OnDialog"] = "ondialog",
    ["OnSendPacket"] = "onsendpacket",
    ["OnSendPacketRaw"] = "onsendpacketraw",
  }
  local function k(g)
    if ZS_HUB["installed"][g] then
      return
    end
    ZS_HUB["installed"][g] = true
    local k = ZS_HUB["callbacks"][g]
    ZS_HUB["native"](function(...)
      local Q = false
      for R = 1, #k, 1 do
        local Z, Y = pcall(k[R], ...)
        if not Z then
          local Q = "Hook error (" .. (g .. ("): " .. tostring(Y)))
          if growtopia and type(growtopia["notify"]) == "function" then
            pcall(growtopia["notify"], Q)
          else
            print(Q)
          end
        elseif Y == true then
          Q = true
        end
      end
      return Q
    end, Q[g] or g)
  end
  function addHook(Q, R)
    if type(Q) ~= "function" then
      return
    end
    R = R or "onvalue"
    R = g[R] or (tostring(R)):lower()
    if not ZS_HUB["callbacks"][R] then
      ZS_HUB["callbacks"][R] = {}
    end
    table["insert"](ZS_HUB["callbacks"][R], Q)
    k(R)
  end
end
if not ZS_thread then
  function ZS_thread(Q)
    runThread(Q)
  end
end
if not ZS_label then
  function ZS_label(Q, g, ...)
    g = tostring(g == nil and "" or g)
    local k = ZS_LABEL_WIDTH
    local function R(Q)
      if utf8 and utf8["len"] then
        return utf8["len"](Q) or #Q
      end
      return #Q
    end
    local Z, Y = {}, ""
    for Q in g:gmatch("%S+") do
      if Y == "" then
        Y = Q
      elseif (R(Y) + 1) + R(Q) <= k then
        Y = Y .. (" " .. Q)
      else
        Z[#Z + 1] = Y
        Y = Q
      end
    end
    if Y ~= "" then
      Z[#Z + 1] = Y
    end
    if #Z == 0 then
      Z[1] = g
    end
    for g, k in ipairs(Z) do
      Q:addLabel(k, ...)
    end
  end
end
if not ZS_CATEGORY_ADDED then
  ZS_CATEGORY_ADDED = true
  if type(addCategory) == "function" then
    pcall(addCategory, "ZS", "Shield")
  end
end
local Q = { ["tag"] = "k09", ["life"] = "ZSA-VFIND", ["unlocked"] = false, ["entered"] = "", ["n"] = 0 }
local function g(Q)
  if growtopia and type(growtopia["notify"]) == "function" then
    pcall(growtopia["notify"], tostring(Q))
  else
    print("[ZS] " .. tostring(Q))
  end
end
local k = g
local R = addHook
local function Z(g, k)
  if type(g) ~= "function" then
    return
  end
  return R(function(...)
    if not Q["unlocked"] then
      return false
    end
    return g(...)
  end, k)
end
local function Y(Q)
  local g = tostring(Q)
  local k, R = g:find('"menu"%s*:%s*%[')
  if not k then
    return nil
  end
  local Z, Y, X, T = 1, R + 1, false, false
  while Y <= #g do
    local Q = g:sub(Y, Y)
    if X then
      if T then
        T = false
      elseif Q == "\\" then
        T = true
      elseif Q == '"' then
        X = false
      end
    elseif Q == '"' then
      X = true
    elseif Q == "[" then
      Z = Z + 1
    elseif Q == "]" then
      Z = Z - 1
      if Z == 0 then
        return g:sub(R + 1, Y - 1)
      end
    end
    Y = Y + 1
  end
end
local function X()
  Q["n"] = Q["n"] + 1
  local g = UserInterface["new"]("ZS ACCESS", "Lock")
  g:addLabelApp("* ACCESS KEY *", "Lock")
  ZS_label(g, "Enter your key. You can look around, but everything works only after unlock.")
  g:addInputString("Enter Key", "", "Enter Key", "Your key", "Key", "zskey_" .. (Q["tag"] .. ("_" .. Q["n"])))
  g:addButton("UNLOCK", "zsunl_" .. (Q["tag"] .. ("_" .. Q["n"])))
  g:addDivider()
  return g
end
local T = addIntoModule
local function N(g, k, ...)
  if type(g) == "string" and not g:find("zskey_" .. (Q["tag"] .. "_"), 1, true) then
    local Q, R = pcall(function()
      local Q = X()
      local k = Y(Q:generateJSON())
      local R, Z = g:find('"menu"%s*:%s*%[')
      if not (k and R) then
        return nil
      end
      local T = g:sub(Z + 1)
      local N = T:match("^%s*%]") and "" or ","
      return g:sub(1, Z) .. (k .. (N .. T))
    end)
    if Q and R then
      g = R
    else
      pcall(function()
        T((X()):generateJSON(), k)
      end)
    end
  end
  return T(g, k, ...)
end
local function U(...)
  local k = select("#", ...)
  local R = { ... }
  local Z, Y = "zskey_" .. (Q["tag"] .. "_"), "zsunl_" .. (Q["tag"] .. "_")
  local function X(Q)
    if type(Q) ~= "string" then
      return nil
    end
    if Q:sub(1, #Z) == Z then
      return "key"
    end
    if Q:sub(1, #Y) == Y then
      return "btn"
    end
  end
  local T, N
  local function U(Q, g)
    if T or g > 2 then
      return
    end
    if type(Q) == "string" then
      T = X(Q)
    elseif type(Q) == "table" then
      for k, R in pairs(Q) do
        if X(R) then
          T = X(R)
          N = Q["value"] or Q["text"] or Q["v2"]
          return
        end
        if X(k) then
          T = X(k)
          N = R
          return
        end
        if type(R) == "table" then
          U(R, g + 1)
        end
      end
    end
  end
  for Q = 1, k, 1 do
    U(R[Q], 0)
    if T then
      if N == nil then
        N = R[Q + 1]
      end
      break
    end
  end
  if T == "key" then
    Q["entered"] = tostring(N or "")
    return true
  elseif T == "btn" then
    local k = ((Q["entered"]:upper()):gsub("%s+", ""))
    if k == Q["life"]:upper() then
      Q["unlocked"] = true
      g("Key accepted. Unlocked!")
    else
      g("Invalid key.")
    end
    return true
  end
  return false
end
R(U, "onvalue")
local function P()
  local Q = {}
  if type(GetTiles) ~= "function" then
    return Q
  end
  local g, k = pcall(GetTiles)
  if not g or type(k) ~= "table" then
    return Q
  end
  for g, k in pairs(k) do
    if k and (k["fg"] == 2978 or k["fg"] == 9268) then
      local g = k["extra"]
      local R = g and tonumber(g["vend_item"])
      if g and (tonumber(g["owner"] or 0) ~= 0 and (R and R ~= 0)) then
        local Z = type(getItemInfoByID) == "function" and getItemInfoByID(R) or nil
        local Y = Z and Z["name"] or ("Item ID " .. tostring(R))
        Q[#Q + 1] = {
          ["x"] = tonumber(k["x"]) or 0,
          ["y"] = tonumber(k["y"]) or 0,
          ["id"] = R,
          ["name"] = Y,
          ["price"] = tonumber(g["vend_price"]) or 0,
        }
      end
    end
  end
  table["sort"](Q, function(Q, g)
    if Q["name"]:lower() == g["name"]:lower() then
      if Q["y"] == g["y"] then
        return Q["x"] < g["x"]
      end
      return Q["y"] < g["y"]
    end
    return Q["name"]:lower() < g["name"]:lower()
  end)
  return Q
end
local e = {}
local M = 1
local I = ""
local q = 18
local function w(Q, g)
  if g or type(e) ~= "table" then
    e = P()
  end
  local k = {}
  local R = ((tostring(I or "")):lower()):match("^%s*(.-)%s*$")
  for Q, g in ipairs(e) do
    if R == "" or ((tostring(g["name"] or "")):lower()):find(R, 1, true) then
      k[#k + 1] = g
    end
  end
  local Z = #k
  local Y = math["max"](1, math["ceil"](Z / q))
  M = math["max"](1, math["min"](tonumber(Q) or 1, Y))
  local X = {}
  local T = (M - 1) * q + 1
  local N = math["min"]((T + q) - 1, Z)
  for Q = T, N, 1 do
    local g = k[Q]
    local R = math["abs"](g["price"])
    local Z, Y, U
    if g["price"] < 0 then
      Z, Y, U = 242, tostring(R) .. "/1", "WL"
    elseif R >= 10000 then
      Z, Y, U = 7188, (string["format"]("%.2f", R / 10000)):gsub("%.?0+$", ""), "BGL"
    elseif R >= 100 then
      Z, Y, U = 1796, (string["format"]("%.2f", R / 100)):gsub("%.?0+$", ""), "DL"
    else
      Z, Y, U = 242, tostring(R), "WL"
    end
    local P = tostring(g["name"] or "Unknown item")
    if #P > 10 then
      P = P:sub(1, 8) .. ".."
    end
    local e = string["format"]("%s %s%s", P, Y, U)
    X[#X + 1] = string["format"]("add_button_with_icon|%d-%d|%s|staticBlueFrame|%d||", g["x"], g["y"], e, g["id"])
    if ((Q - T) + 1) % 6 == 0 and Q < N then
      X[#X + 1] = "add_custom_break|"
    end
  end
  local U = {}
  if Z > 0 then
    U[#U + 1] = string["format"](
      "add_textbox|`oShowing `w%d-%d`o of `w%d`o vending machines  -  Page `w%d/%d|left|",
      T,
      N,
      Z,
      M,
      Y
    )
    if Y > 1 then
      U[#U + 1] = "add_button|zs_vend_prev|`w< PREVIOUS|noflags|"
      U[#U + 1] = "add_button|zs_vend_next|`wNEXT >|noflags|"
    end
  end
  local w = Z > 0 and table["concat"](X, "\n")
    or (
      R ~= "" and "add_textbox|`4No products match your search. Try another name.|left|"
      or "add_textbox|`4No vending items found in this world.``|"
    )
  growtopia["sendDialog"](
    table["concat"](
      {
        "set_default_color|`o",
        "add_label_with_icon|big|`wZS VEND FINDER V2|left|2978|",
        "add_text_input|zs_vend_search|Search product name:|" .. (
            ((tostring(I)):gsub("|", " ")):gsub("\n", " ") .. "|32|"
          ),
        "add_button|zs_vend_apply_search|`2SEARCH|noflags|0|0|",
        "add_button|zs_vend_clear_search|`9SHOW ALL|noflags|0|0|",
        "add_textbox|`oTap a product tile to pathfind to its vending machine.|left|",
        "add_spacer|small|",
        w,
        table["concat"](U, "\n"),
        "add_button|zs_vend_refresh|`wREFRESH LIST|noflags|",
        "add_quick_exit|",
        "end_dialog|zs_vend_results|Close||",
      },
      "\n"
    )
  )
  if Z == 0 and growtopia["notify"] then
    growtopia["notify"]("ZS Vend Finder: no vending items found.")
  end
end
local function c(Q, g)
  Q, g = tonumber(Q), tonumber(g)
  if not Q or not g then
    return
  end
  local k = type(getTile) == "function" and getTile(Q, g) or nil
  if not k or (k["fg"] ~= 2978 and k["fg"] ~= 9268) then
    if growtopia["notify"] then
      growtopia["notify"]("That vending machine is no longer there.")
    end
    return
  end
  if growtopia["notify"] then
    growtopia["notify"]("Pathfinding to vending machine at " .. (Q .. ("," .. g)))
  end
  if type(FindPath) == "function" then
    FindPath(Q, g)
  end
end
local z = UserInterface["new"]("ZS VEND FINDER V2", "Search")
z:addLabelApp("* ZS VEND FINDER V2 *", "Search")
z:addTooltip(
  "* VEND FINDER *",
  "Press the pink search button to list vending items in the current world. Search by product name to filter the list. Tap a product result to pathfind to that vending machine.",
  "Info",
  true
)
z:addDivider()
z:addButton("SHOW VENDING ITEMS", "zs_vend_find_button")
N(z:generateJSON(), "ZS")
Z(function(Q, g, k)
  if g == "zs_vend_find_button" then
    w(1, true)
  end
end, "onValue")
Z(function(Q, g)
  if type(g) ~= "string" then
    return false
  end
  if g:find("dialog_name|zs_vend_results", 1, true) then
    local Q, k = g:match("buttonClicked|(%d+)%-(%d+)")
    if Q and k then
      c(Q, k)
    elseif g:find("buttonClicked|zs_vend_prev", 1, true) then
      w(M - 1, false)
    elseif g:find("buttonClicked|zs_vend_next", 1, true) then
      w(M + 1, false)
    elseif g:find("buttonClicked|zs_vend_apply_search", 1, true) then
      I = g:match("zs_vend_search|([^\n|\r]*)") or ""
      w(1, false)
    elseif g:find("buttonClicked|zs_vend_clear_search", 1, true) then
      I = ""
      w(1, false)
    elseif g:find("buttonClicked|zs_vend_refresh", 1, true) then
      w(1, true)
    end
    return true
  end
  return false
end, "onsendpacket")
if type(applyHook) == "function" then
  pcall(applyHook)
end
