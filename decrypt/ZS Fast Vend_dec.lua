ZS_LABEL_WIDTH = ZS_LABEL_WIDTH or 30
if not ZS_HUB then
  ZS_HUB = { ["native"] = addHook, ["callbacks"] = {}, ["installed"] = {} }
  local s = {
    ["onvalue"] = "onValue",
    ["ondrawimgui"] = "onDrawImGui",
    ["onvariant"] = "onVariant",
    ["ondialog"] = "onDialog",
    ["onsendpacket"] = "onSendPacket",
    ["onsendpacketraw"] = "onSendPacketRaw",
  }
  local I = {
    ["onValue"] = "onvalue",
    ["onDrawImGui"] = "ondrawimgui",
    ["OnVariant"] = "onvariant",
    ["OnDialog"] = "ondialog",
    ["OnSendPacket"] = "onsendpacket",
    ["OnSendPacketRaw"] = "onsendpacketraw",
  }
  local function k(I)
    if ZS_HUB["installed"][I] then
      return
    end
    ZS_HUB["installed"][I] = true
    local k = ZS_HUB["callbacks"][I]
    ZS_HUB["native"](function(...)
      local s = false
      for N = 1, #k, 1 do
        local g, h = pcall(k[N], ...)
        if not g then
          local s = "Hook error (" .. (I .. ("): " .. tostring(h)))
          if growtopia and type(growtopia["notify"]) == "function" then
            pcall(growtopia["notify"], s)
          else
            print(s)
          end
        elseif h == true then
          s = true
        end
      end
      return s
    end, s[I] or I)
  end
  function addHook(s, N)
    if type(s) ~= "function" then
      return
    end
    N = N or "onvalue"
    N = I[N] or (tostring(N)):lower()
    if not ZS_HUB["callbacks"][N] then
      ZS_HUB["callbacks"][N] = {}
    end
    table["insert"](ZS_HUB["callbacks"][N], s)
    k(N)
  end
end
if not ZS_thread then
  function ZS_thread(s)
    runThread(s)
  end
end
if not ZS_label then
  function ZS_label(s, I, ...)
    I = tostring(I == nil and "" or I)
    local k = ZS_LABEL_WIDTH
    local function N(s)
      if utf8 and utf8["len"] then
        return utf8["len"](s) or #s
      end
      return #s
    end
    local g, h = {}, ""
    for s in I:gmatch("%S+") do
      if h == "" then
        h = s
      elseif (N(h) + 1) + N(s) <= k then
        h = h .. (" " .. s)
      else
        g[#g + 1] = h
        h = s
      end
    end
    if h ~= "" then
      g[#g + 1] = h
    end
    if #g == 0 then
      g[1] = I
    end
    for I, k in ipairs(g) do
      s:addLabel(k, ...)
    end
  end
end
if not ZS_CATEGORY_ADDED then
  ZS_CATEGORY_ADDED = true
  if type(addCategory) == "function" then
    pcall(addCategory, "ZS", "Shield")
  end
end
local s = { ["tag"] = "k11", ["life"] = "ZSA-FVEND", ["unlocked"] = false, ["entered"] = "", ["n"] = 0 }
local function I(s)
  if growtopia and type(growtopia["notify"]) == "function" then
    pcall(growtopia["notify"], tostring(s))
  else
    print("[ZS] " .. tostring(s))
  end
end
local k = I
local N = addHook
local function g(I, k)
  if type(I) ~= "function" then
    return
  end
  return N(function(...)
    if not s["unlocked"] then
      return false
    end
    return I(...)
  end, k)
end
local function h(s)
  local I = tostring(s)
  local k, N = I:find('"menu"%s*:%s*%[')
  if not k then
    return nil
  end
  local g, h, w, H = 1, N + 1, false, false
  while h <= #I do
    local s = I:sub(h, h)
    if w then
      if H then
        H = false
      elseif s == "\\" then
        H = true
      elseif s == '"' then
        w = false
      end
    elseif s == '"' then
      w = true
    elseif s == "[" then
      g = g + 1
    elseif s == "]" then
      g = g - 1
      if g == 0 then
        return I:sub(N + 1, h - 1)
      end
    end
    h = h + 1
  end
end
local function w()
  s["n"] = s["n"] + 1
  local I = UserInterface["new"]("ZS ACCESS", "Lock")
  I:addLabelApp("* ACCESS KEY *", "Lock")
  ZS_label(I, "Enter your key. You can look around, but everything works only after unlock.")
  I:addInputString("Enter Key", "", "Enter Key", "Your key", "Key", "zskey_" .. (s["tag"] .. ("_" .. s["n"])))
  I:addButton("UNLOCK", "zsunl_" .. (s["tag"] .. ("_" .. s["n"])))
  I:addDivider()
  return I
end
local H = addIntoModule
local function r(I, k, ...)
  if type(I) == "string" and not I:find("zskey_" .. (s["tag"] .. "_"), 1, true) then
    local s, N = pcall(function()
      local s = w()
      local k = h(s:generateJSON())
      local N, g = I:find('"menu"%s*:%s*%[')
      if not (k and N) then
        return nil
      end
      local H = I:sub(g + 1)
      local r = H:match("^%s*%]") and "" or ","
      return I:sub(1, g) .. (k .. (r .. H))
    end)
    if s and N then
      I = N
    else
      pcall(function()
        H((w()):generateJSON(), k)
      end)
    end
  end
  return H(I, k, ...)
end
local function G(...)
  local k = select("#", ...)
  local N = { ... }
  local g, h = "zskey_" .. (s["tag"] .. "_"), "zsunl_" .. (s["tag"] .. "_")
  local function w(s)
    if type(s) ~= "string" then
      return nil
    end
    if s:sub(1, #g) == g then
      return "key"
    end
    if s:sub(1, #h) == h then
      return "btn"
    end
  end
  local H, r
  local function G(s, I)
    if H or I > 2 then
      return
    end
    if type(s) == "string" then
      H = w(s)
    elseif type(s) == "table" then
      for k, N in pairs(s) do
        if w(N) then
          H = w(N)
          r = s["value"] or s["text"] or s["v2"]
          return
        end
        if w(k) then
          H = w(k)
          r = N
          return
        end
        if type(N) == "table" then
          G(N, I + 1)
        end
      end
    end
  end
  for s = 1, k, 1 do
    G(N[s], 0)
    if H then
      if r == nil then
        r = N[s + 1]
      end
      break
    end
  end
  if H == "key" then
    s["entered"] = tostring(r or "")
    return true
  elseif H == "btn" then
    local k = ((s["entered"]:upper()):gsub("%s+", ""))
    if k == s["life"]:upper() then
      s["unlocked"] = true
      I("Key accepted. Unlocked!")
    else
      I("Invalid key.")
    end
    return true
  end
  return false
end
N(G, "onvalue")
local E = {
  ["mode"] = nil,
  ["running"] = false,
  ["token"] = 0,
  ["x"] = nil,
  ["y"] = nil,
  ["item"] = nil,
  ["lastDialog"] = nil,
  ["status"] = "Idle",
  ["lastAction"] = 0,
  ["lastConvert"] = 0,
}
local x = { [2978] = true, [9268] = true }
local a = 200
local function V(s)
  s = "[ZS Fast Vend] " .. tostring(s)
  if type(growtopia) == "table" and type(growtopia["notify"]) == "function" then
    pcall(growtopia["notify"], s)
  end
  if type(LogToConsole) == "function" then
    pcall(LogToConsole, "`9" .. s)
  end
end
local function F()
  local s = type(getLocal) == "function" and getLocal or (type(GetLocal) == "function" and GetLocal)
  if not s then
    return nil
  end
  local I, k = pcall(s)
  if I and type(k) == "table" then
    return k
  end
  return nil
end
local function X(s, I)
  local k = type(getTile) == "function" and getTile or (type(GetTile) == "function" and GetTile)
  if not k then
    return nil
  end
  local N, g = pcall(k, s, I)
  if N then
    return g
  end
  return nil
end
local function y()
  local s = type(GetTiles) == "function" and GetTiles or (type(getTiles) == "function" and getTiles)
  if not s then
    return {}
  end
  local I, k = pcall(s)
  if I and type(k) == "table" then
    return k
  end
  return {}
end
local function B(s)
  if not s then
    return 0
  end
  if type(growtopia) == "table" and type(growtopia["checkInventoryCount"]) == "function" then
    local I, k = pcall(growtopia["checkInventoryCount"], s)
    if I then
      return tonumber(k) or 0
    end
  end
  local I = type(getInventory) == "function" and getInventory or (type(GetInventory) == "function" and GetInventory)
  if I then
    local k, N = pcall(I)
    if k and type(N) == "table" then
      for I, k in pairs(N) do
        if tonumber(k["id"]) == tonumber(s) then
          return tonumber(k["amount"]) or 0
        end
      end
    end
  end
  return 0
end
local function i(s, I)
  return { { s - 1, I }, { s + 1, I }, { s, I - 1 }, { s, I + 1 } }
end
local function Q(s, I, k, N)
  local g, h = nil, 99999
  for s, I in ipairs(i(s, I)) do
    local w, H = I[1], I[2]
    local r = X(w, H)
    local G = tonumber(r and (r["fg"] or r["foreground"])) or 0
    if G == 0 then
      local s = math["abs"](k - w) + math["abs"](N - H)
      if s < h then
        g = { ["x"] = w, ["y"] = H }
        h = s
      end
    end
  end
  return g, h
end
local function J()
  local s = F()
  if not s then
    return nil
  end
  local I, k = math["floor"]((s["posX"] or 0) / 32), math["floor"]((s["posY"] or 0) / 32)
  local N, g = nil, 99999
  for s, h in pairs(y()) do
    local w = tonumber(h and (h["fg"] or h["foreground"])) or 0
    if x[w] then
      local s, H = tonumber(h["x"]), tonumber(h["y"])
      if s and H then
        local r, G = Q(s, H, I, k)
        if r and G < g then
          N = { ["x"] = s, ["y"] = H, ["id"] = w, ["tile"] = h, ["stand"] = r }
          g = G
        end
      end
    end
  end
  if N and g <= 12 then
    return N
  end
  return nil
end
local function K(s)
  local I = s and (s["tile"] and s["tile"]["extra"])
  return tonumber(I and (I["vend_item"] or I["item_id"])) or 0
end
local function M(s)
  local I = type(sendPacketRaw) == "function" and sendPacketRaw or (type(SendPacketRaw) == "function" and SendPacketRaw)
  if not I then
    return false
  end
  local k = pcall(I, false, s)
  return k
end
local function e(s)
  local I = F()
  if not I then
    return false
  end
  return M({ ["type"] = 3, ["value"] = 32, ["px"] = s["x"], ["py"] = s["y"], ["x"] = I["posX"], ["y"] = I["posY"] })
end
local function Z(s, I, k)
  local N = type(sendPacket) == "function" and sendPacket or (type(SendPacket) == "function" and SendPacket)
  if not N then
    return false
  end
  local g = { "action|dialog_return", "dialog_name|" .. tostring(s) }
  for s, I in pairs(I or {}) do
    g[#g + 1] = tostring(s) .. ("|" .. tostring(I))
  end
  g[#g + 1] = "buttonClicked|" .. tostring(k or "")
  return pcall(N, 2, table["concat"](g, "\n") .. "\n")
end
local function W(s)
  local I = {}
  for s, k in s:gmatch("add_button|([^|\n]*)|([^|\n]*)|") do
    I[#I + 1] = { ["id"] = s, ["label"] = k:lower() }
  end
  for s, k in s:gmatch("add_button_with_icon|([^|\n]*)|([^|\n]*)|") do
    I[#I + 1] = { ["id"] = s, ["label"] = k:lower() }
  end
  return I
end
local function n(s, I)
  local k = W(s)
  local N
  if I == "empty" then
    N = { "empty", "remove stock", "remove items", "take stock", "take item", "withdraw item", "removestock" }
  elseif I == "add" then
    N = { "add stock", "add items", "stock vend", "addstock", "restock", "add" }
  else
    N = { "withdraw earnings", "withdraw wl", "withdraw", "collect earnings", "collect wl", "collect" }
  end
  for s, I in ipairs(N) do
    for s, k in ipairs(k) do
      if (k["id"]:lower()):find(I, 1, true) or k["label"]:find(I, 1, true) then
        if not k["label"]:find("cancel", 1, true) and not k["label"]:find("close", 1, true) then
          return k["id"]
        end
      end
    end
  end
  return nil
end
local function t(s)
  return s:match("dialog_name|([^|\n]+)") or s:match("end_dialog|([^|\n]+)") or "vending"
end
local function p(s)
  local I = {}
  for s, k in s:gmatch("embed_data|([^|\n]+)|([^|\n]*)") do
    I[s] = k
  end
  for s, k in s:gmatch("([%w_]+)|([^|\n]*)") do
    if s == "tilex" or s == "tiley" or s == "itemID" or s == "count" or s == "amount" or s == "vend_item" then
      I[s] = k
    end
  end
  return I
end
local function v(s)
  local I = {}
  for s in s:gmatch("add_text_input|([^|\n]+)|") do
    I[#I + 1] = s
  end
  for s in s:gmatch("add_textbox_input|([^|\n]+)|") do
    I[#I + 1] = s
  end
  return I
end
local function U(s, I)
  if s == "add" then
    local s = K(I)
    if s <= 0 then
      return nil, s
    end
    return math["min"](a, B(s)), s
  elseif s == "empty" then
    local s = I["tile"] and I["tile"]["extra"] or {}
    local k = tonumber(s["vend_amount"] or s["amount"] or s["stock"] or s["count"]) or a
    return math["min"](a, k), K(I)
  end
  return a, 242
end
local function m(s)
  if not E["running"] or type(s) ~= "string" then
    return false
  end
  local I = s:lower()
  if
    not (
      I:find("vending", 1, true)
      or I:find("digi_vend", 1, true)
      or I:find("digivend", 1, true)
      or I:find("vend_item", 1, true)
    )
  then
    return false
  end
  local k = { ["x"] = E["x"], ["y"] = E["y"], ["tile"] = X(E["x"], E["y"]) }
  local N = t(s)
  local g = p(s)
  g["tilex"] = g["tilex"] or E["x"]
  g["tiley"] = g["tiley"] or E["y"]
  local h, w = U(E["mode"], k)
  if E["mode"] == "add" and (not h or h <= 0) then
    E["status"] = "No matching item in inventory"
    V(E["status"])
    E["running"] = false
    return true
  end
  local H = v(s)
  local r = false
  for s, I in ipairs(H) do
    local k = I:lower()
    if k:find("count", 1, true) or k:find("amount", 1, true) or k:find("quantity", 1, true) then
      g[I] = tostring(h or a)
      r = true
    end
  end
  if E["mode"] == "add" then
    g["itemID"] = tostring(w or 0)
  end
  if E["mode"] == "empty" and (w and w > 0) then
    g["itemID"] = tostring(w)
  end
  local G = n(s, E["mode"])
  if G then
    E["status"] = "Sending " .. (E["mode"] .. " request")
    Z(N, g, G)
    E["lastAction"] = os["clock"]()
    E["lastDialog"] = s
    return true
  end
  if r then
    E["status"] = "Confirming " .. E["mode"]
    Z(N, g, "")
    E["lastAction"] = os["clock"]()
    E["lastDialog"] = s
    return true
  end
  E["status"] = "Vend dialog found; action button not recognized"
  V(E["status"] .. ". Stopped safely; no unknown button was pressed.")
  E["running"] = false
  return true
end
local function c()
  if B(242) >= 100 and (os["clock"]() - E["lastConvert"]) > 5 then
    E["lastConvert"] = os["clock"]()
    local s = F()
    if s then
      M({ ["type"] = 10, ["value"] = 242, ["x"] = s["posX"], ["y"] = s["posY"] })
    end
    E["status"] = "Converting 100 WL to 1 DL"
    V(E["status"])
  end
end
local function L(s)
  E["running"] = false
  E["token"] = E["token"] + 1
  E["status"] = s or "Stopped"
  E["mode"] = nil
end
local function T(s)
  if E["running"] then
    L("Stopped")
  end
  local I = J()
  if not I then
    V("No Vending Machine or DigiVend detected nearby.")
    return
  end
  E["mode"] = s
  E["running"] = true
  E["token"] = E["token"] + 1
  local k = E["token"]
  E["x"], E["y"] = I["x"], I["y"]
  E["standX"], E["standY"] = I["stand"]["x"], I["stand"]["y"]
  E["item"] = K(I)
  E["status"] = "Moving beside machine"
  V("Detected " .. ((I["id"] == 9268 and "DigiVend" or "Vending Machine") .. (" at " .. (I["x"] .. ("," .. I["y"])))))
  ZS_thread(function()
    while E["running"] and E["token"] == k do
      local s = X(E["x"], E["y"])
      if not s or not x[tonumber(s["fg"] or s["foreground"]) or 0] then
        L("Machine disappeared")
        V(E["status"])
        break
      end
      local I = F()
      local k, N = I and math["floor"]((I["posX"] or 0) / 32), I and math["floor"]((I["posY"] or 0) / 32)
      if not k or k ~= E["standX"] or N ~= E["standY"] then
        local s = type(FindPath) == "function" and FindPath or (type(findPath) == "function" and findPath)
        if s then
          pcall(s, E["standX"], E["standY"])
        end
        Sleep(900)
      else
        E["item"] = K({ ["tile"] = s })
        if E["mode"] == "wl" then
          c()
        end
        e({ ["x"] = E["x"], ["y"] = E["y"] })
        Sleep(1800)
      end
    end
  end)
end
local P = UserInterface["new"]("ZS FAST VEND", "ShoppingCart")
P:addLabelApp("* ZS FAST VEND *", "ShoppingCart")
P:addTooltip(
  "ZS FAST VEND",
  "Finds the nearest vending machine, moves beside it and opens its menu. Each vending action has its own toggle. If an action is not recognized, it stops safely.",
  "Info",
  true
)
P:addDivider()
P:addToggle("FAST EMPTY VEND", false, "zs_fastvend_empty", true)
P:addToggle("AUTO FIND RESTOCK", false, "zs_fastvend_add", true)
P:addToggle("FAST WITHDRAW WL", false, "zs_fastvend_wl", true)
r(P:generateJSON(), "ZS")
g(function(s, I, k)
  if I == "zs_fastvend_empty" then
    if k == true or k == 1 or k == "true" then
      T("empty")
    elseif E["mode"] == "empty" then
      L("Empty OFF")
    end
  elseif I == "zs_fastvend_add" then
    if k == true or k == 1 or k == "true" then
      T("add")
    elseif E["mode"] == "add" then
      L("Add OFF")
    end
  elseif I == "zs_fastvend_wl" then
    if k == true or k == 1 or k == "true" then
      T("wl")
    elseif E["mode"] == "wl" then
      L("Withdraw OFF")
    end
  end
end, "onValue")
g(function(s)
  if not E["running"] or type(s) ~= "table" or s["v1"] ~= "OnDialogRequest" then
    return false
  end
  local I = tostring(s["v2"] or "")
  return m(I)
end, "onVariant")
if type(applyHook) == "function" then
  pcall(applyHook)
end
