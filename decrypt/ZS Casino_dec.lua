ZS_LABEL_WIDTH = ZS_LABEL_WIDTH or 30
if not ZS_HUB then
  ZS_HUB = { ["native"] = addHook, ["callbacks"] = {}, ["installed"] = {} }
  local a = {
    ["onvalue"] = "onValue",
    ["ondrawimgui"] = "onDrawImGui",
    ["onvariant"] = "onVariant",
    ["ondialog"] = "onDialog",
    ["onsendpacket"] = "onSendPacket",
    ["onsendpacketraw"] = "onSendPacketRaw",
  }
  local Z = {
    ["onValue"] = "onvalue",
    ["onDrawImGui"] = "ondrawimgui",
    ["OnVariant"] = "onvariant",
    ["OnDialog"] = "ondialog",
    ["OnSendPacket"] = "onsendpacket",
    ["OnSendPacketRaw"] = "onsendpacketraw",
  }
  local function O(Z)
    if ZS_HUB["installed"][Z] then
      return
    end
    ZS_HUB["installed"][Z] = true
    local O = ZS_HUB["callbacks"][Z]
    ZS_HUB["native"](function(...)
      local a = false
      for z = 1, #O, 1 do
        local f, e = pcall(O[z], ...)
        if not f then
          local a = "Hook error (" .. (Z .. ("): " .. tostring(e)))
          if growtopia and type(growtopia["notify"]) == "function" then
            pcall(growtopia["notify"], a)
          else
            print(a)
          end
        elseif e == true then
          a = true
        end
      end
      return a
    end, a[Z] or Z)
  end
  function addHook(a, z)
    if type(a) ~= "function" then
      return
    end
    z = z or "onvalue"
    z = Z[z] or (tostring(z)):lower()
    if not ZS_HUB["callbacks"][z] then
      ZS_HUB["callbacks"][z] = {}
    end
    table["insert"](ZS_HUB["callbacks"][z], a)
    O(z)
  end
end
if not ZS_thread then
  function ZS_thread(a)
    runThread(a)
  end
end
if not ZS_label then
  function ZS_label(a, Z, ...)
    Z = tostring(Z == nil and "" or Z)
    local O = ZS_LABEL_WIDTH
    local function z(a)
      if utf8 and utf8["len"] then
        return utf8["len"](a) or #a
      end
      return #a
    end
    local f, e = {}, ""
    for a in Z:gmatch("%S+") do
      if e == "" then
        e = a
      elseif (z(e) + 1) + z(a) <= O then
        e = e .. (" " .. a)
      else
        f[#f + 1] = e
        e = a
      end
    end
    if e ~= "" then
      f[#f + 1] = e
    end
    if #f == 0 then
      f[1] = Z
    end
    for Z, O in ipairs(f) do
      a:addLabel(O, ...)
    end
  end
end
if not ZS_CATEGORY_ADDED then
  ZS_CATEGORY_ADDED = true
  if type(addCategory) == "function" then
    pcall(addCategory, "ZS", "Shield")
  end
end
local a = { ["tag"] = "k17", ["life"] = "ZSA-CASINO", ["unlocked"] = false, ["entered"] = "", ["n"] = 0 }
local function Z(a)
  if growtopia and type(growtopia["notify"]) == "function" then
    pcall(growtopia["notify"], tostring(a))
  else
    print("[ZS] " .. tostring(a))
  end
end
local O = Z
local z = addHook
local function f(Z, O)
  if type(Z) ~= "function" then
    return
  end
  return z(function(...)
    if not a["unlocked"] then
      return false
    end
    return Z(...)
  end, O)
end
local function e(a)
  local Z = tostring(a)
  local O, z = Z:find('"menu"%s*:%s*%[')
  if not O then
    return nil
  end
  local f, e, Y, r = 1, z + 1, false, false
  while e <= #Z do
    local a = Z:sub(e, e)
    if Y then
      if r then
        r = false
      elseif a == "\\" then
        r = true
      elseif a == '"' then
        Y = false
      end
    elseif a == '"' then
      Y = true
    elseif a == "[" then
      f = f + 1
    elseif a == "]" then
      f = f - 1
      if f == 0 then
        return Z:sub(z + 1, e - 1)
      end
    end
    e = e + 1
  end
end
local function Y()
  a["n"] = a["n"] + 1
  local Z = UserInterface["new"]("ZS ACCESS", "Lock")
  Z:addLabelApp("* ACCESS KEY *", "Lock")
  ZS_label(Z, "Enter your key. You can look around, but everything works only after unlock.")
  Z:addInputString("Enter Key", "", "Enter Key", "Your key", "Key", "zskey_" .. (a["tag"] .. ("_" .. a["n"])))
  Z:addButton("UNLOCK", "zsunl_" .. (a["tag"] .. ("_" .. a["n"])))
  Z:addDivider()
  return Z
end
local r = addIntoModule
local function w(Z, O, ...)
  if type(Z) == "string" and not Z:find("zskey_" .. (a["tag"] .. "_"), 1, true) then
    local a, z = pcall(function()
      local a = Y()
      local O = e(a:generateJSON())
      local z, f = Z:find('"menu"%s*:%s*%[')
      if not (O and z) then
        return nil
      end
      local r = Z:sub(f + 1)
      local w = r:match("^%s*%]") and "" or ","
      return Z:sub(1, f) .. (O .. (w .. r))
    end)
    if a and z then
      Z = z
    else
      pcall(function()
        r((Y()):generateJSON(), O)
      end)
    end
  end
  return r(Z, O, ...)
end
local function E(...)
  local O = select("#", ...)
  local z = { ... }
  local f, e = "zskey_" .. (a["tag"] .. "_"), "zsunl_" .. (a["tag"] .. "_")
  local function Y(a)
    if type(a) ~= "string" then
      return nil
    end
    if a:sub(1, #f) == f then
      return "key"
    end
    if a:sub(1, #e) == e then
      return "btn"
    end
  end
  local r, w
  local function E(a, Z)
    if r or Z > 2 then
      return
    end
    if type(a) == "string" then
      r = Y(a)
    elseif type(a) == "table" then
      for O, z in pairs(a) do
        if Y(z) then
          r = Y(z)
          w = a["value"] or a["text"] or a["v2"]
          return
        end
        if Y(O) then
          r = Y(O)
          w = z
          return
        end
        if type(z) == "table" then
          E(z, Z + 1)
        end
      end
    end
  end
  for a = 1, O, 1 do
    E(z[a], 0)
    if r then
      if w == nil then
        w = z[a + 1]
      end
      break
    end
  end
  if r == "key" then
    a["entered"] = tostring(w or "")
    return true
  elseif r == "btn" then
    local O = ((a["entered"]:upper()):gsub("%s+", ""))
    if O == a["life"]:upper() then
      a["unlocked"] = true
      Z("Key accepted. Unlocked!")
    else
      Z("Invalid key.")
    end
    return true
  end
  return false
end
z(E, "onvalue")
local function K(a, Z, O)
  a:addLabelApp("= " .. Z, "Menu_Book")
  for Z, O in ipairs(O) do
    ZS_label(a, "  " .. (O[1] .. ("   ->   " .. O[2])))
  end
end
local D = "Commands of another proxy. Not part of ZS."
local M = false
local b = "idle"
local j = nil
local B = nil
local X = 0
local C = 0
local m = "telephone"
local g = "53785"
local function s(a, Z)
  if growtopia and type(growtopia["getItemID"]) == "function" then
    local Z, O = pcall(growtopia["getItemID"], a)
    if Z and (tonumber(O) and tonumber(O) > 0) then
      return tonumber(O)
    end
  end
  return Z
end
local function n(a)
  if not a then
    return 0
  end
  if growtopia and type(growtopia["checkInventoryCount"]) == "function" then
    local Z, O = pcall(growtopia["checkInventoryCount"], a)
    if Z then
      return tonumber(O) or 0
    end
  end
  return 0
end
local function h()
  if type(GetTiles) ~= "function" or type(GetLocal) ~= "function" then
    return nil
  end
  local a = s("Telephone", nil)
  if not a or a <= 0 then
    return nil
  end
  local Z = GetLocal()
  if not Z then
    return nil
  end
  local O, z = (Z["posX"] or 0) / 32, (Z["posY"] or 0) / 32
  local f, e
  for Z, Y in pairs(GetTiles() or {}) do
    local r = tonumber(Y["fg"] or Y["foreground"])
    if r == a then
      local a, Z = tonumber(Y["x"]), tonumber(Y["y"])
      if a and Z then
        local Y, r = a - O, Z - z
        local w = Y * Y + r * r
        if not e or w < e then
          f, e = { ["x"] = math["floor"](a), ["y"] = math["floor"](Z) }, w
        end
      end
    end
  end
  return f
end
local function o(a)
  if not M then
    return
  end
  M = false
  b = "idle"
  local Z = j
  j = nil
  B = nil
  if Z and (type(runThread) == "function" and type(FindPath) == "function") then
    runThread(function()
      FindPath(Z["x"], Z["y"])
      Sleep(600)
      O("AUTO BGL: " .. (tostring(a) .. " Returned to starting position."))
    end)
  else
    O("AUTO BGL: " .. tostring(a))
  end
end
local function N()
  if M then
    O("AUTO BGL is already active.")
    return
  end
  if
    type(runThread) ~= "function"
    or type(FindPath) ~= "function"
    or type(SendPacketRaw) ~= "function"
    or type(GetLocal) ~= "function"
  then
    O("AUTO BGL: required PowerKuy movement/wrench APIs are unavailable.")
    return
  end
  local a = s("Diamond Lock", 1796)
  local Z = s("Blue Gem Lock", 7188)
  local z = n(a)
  if z < 100 then
    O("AUTO BGL: you need at least 100 Diamond Locks in inventory. Current: " .. z)
    return
  end
  local f = GetLocal()
  if not f then
    O("AUTO BGL: player position unavailable.")
    return
  end
  local e = h()
  if not e then
    O("AUTO BGL: no Telephone found in this world.")
    return
  end
  j = { ["x"] = math["floor"](f["posX"] / 32), ["y"] = math["floor"](f["posY"] / 32) }
  B = e
  X = z
  C = n(Z)
  b = "phone_dialog"
  M = true
  runThread(function()
    O("AUTO BGL: moving to nearest Telephone.")
    FindPath(e["x"], e["y"])
    Sleep(900)
    if not M then
      return
    end
    local a = GetLocal()
    if not a or math["abs"]((a["posX"] or 0) / 32 - e["x"]) > 4 or math["abs"]((a["posY"] or 0) / 32 - e["y"]) > 4 then
      o("could not reach Telephone.")
      return
    end
    local Z = { ["x"] = a["posX"], ["y"] = a["posY"], ["px"] = e["x"], ["py"] = e["y"], ["type"] = 3, ["value"] = 32 }
    local z = pcall(SendPacketRaw, false, Z)
    if not z then
      o("Telephone wrench failed.")
      return
    end
    Sleep(900)
    if M and b == "phone_dialog" then
      O("AUTO BGL: waiting for Telephone dialog.")
    end
  end)
end
local function x()
  if not M then
    return
  end
  o("stopped by user.")
end
local function V(a)
  if not M or type(a) ~= "table" or tostring(a["v1"] or "") ~= "OnDialogRequest" then
    return false
  end
  local Z = tostring(a["v2"] or "")
  local z = Z:lower()
  local f = Z:match("dialog_name|([^\r\n]+)") or "telephone"
  if b == "phone_dialog" and z:find("telephone", 1, true) then
    local a = Z:match("add_text_input|([^|\r\n]+)|%s*Phone%s*#")
      or Z:match("add_text_input|([^|\r\n]+)|")
      or "phone_number"
    m = f
    local z = "action|dialog_return\ndialog_name|" .. (f .. ("\n" .. (a .. ("|" .. (g .. "\nbuttonClicked|dial")))))
    if sendText(z) then
      b = "salesman_menu"
      O("AUTO BGL: calling Sales-Man.")
      return true
    end
    o("could not send Telephone dial command.")
    return false
  end
  if b == "salesman_menu" and z:find("sales%-man") then
    local a
    for Z in Z:gmatch("[^\r\n]+") do
      local O, z = Z:match("add_button|([^|]+)|([^|]+)")
      if O and (z and (z:lower()):find("blue gem lock", 1, true)) then
        a = O
        break
      end
    end
    if not a then
      O("AUTO BGL: could not identify the Blue Gem Lock menu button; no purchase was made.")
      o("menu button not recognized.")
      return false
    end
    local z = "action|dialog_return\ndialog_name|" .. (f .. ("\nbuttonClicked|" .. a))
    if sendText(z) then
      b = "purchase_result"
      O("AUTO BGL: selected Blue Gem Lock; checking the exchange result.")
      return true
    end
    o("could not select Blue Gem Lock.")
    return false
  end
  if b == "purchase_result" and (z:find("blue gem lock", 1, true) or z:find("diamond lock", 1, true)) then
    local a = s("Diamond Lock", 1796)
    local Z = s("Blue Gem Lock", 7188)
    local O = 0
    runThread(function()
      while M and O < 8 do
        Sleep(500)
        O = O + 1
        local z = n(a)
        local f = n(Z)
        if z <= X - 100 and f >= C + 1 then
          o("successfully exchanged 100 DL for 1 BGL.")
          return
        end
      end
      if M then
        o("exchange could not be verified; check your inventory before retrying.")
      end
    end)
    return false
  end
  return false
end
f(V, "onVariant")
local k = UserInterface["new"]("ZS CASINO", "Casino")
k:addLabelApp("* ZS CASINO *", "Casino")
k:addTooltip(
  "CASINO QUICK GUIDE",
  "Use the sections below to calculate payouts, track roulette results and convert locks.\n\nBGL: Turn ON the BGL toggle to find the nearest Telephone, call Sales-Man (53785), choose Blue Gem Lock for 100 Diamond Locks, verify the exchange and return to your starting position. Requires at least 100 DL.\n\nCOMMANDS: Enter a command in the COMMAND field, then press RUN.\nExample: dd 5 = drop 5 Diamond Locks.\n\nEach command group below explains what the command does.",
  "Info",
  true
)
k:addDivider()
k:addLabelApp("TAX / PAYOUT", "Payments")
k:addInputString("Bet amount (WL)", "100", "Bet amount in WL", "Example: 100 = 1 DL", "WL", "zs_tax_bet_wl")
k:addSlider("Tax (%)", 0, 100, 20, 1, false, "zs_tax_percent")
k:addButton("CALCULATE PAYOUT", "zs_tax_calculate")
k:addButton("DROP PAYOUT", "zs_tax_drop")
k:addDivider()
k:addLabelApp("ROULETTE TRACKER", "Casino")
k:addInputString("Roulette result", "", "Roulette result", "Number 0-36", "Result", "zs_roulette_number")
k:addButton("RECORD RESULT", "zs_roulette_record")
k:addButton("SHOW STATS", "zs_casino_stats")
k:addDivider()
k:addLabelApp("LOCK CONVERTER", "Currency_Exchange")
k:addInputString("WL amount", "0", "WL amount", "Amount in World Locks", "WL", "zs_wl_amount")
k:addButton("CONVERT", "zs_wl_calculate")
k:addDivider()
k:addLabelApp("AUTO BGL", "Currency_Exchange")
k:addToggle("BGL", false, "zs_auto_bgl_toggle", true)
k:addDivider()
k:addLabelApp("COMMAND", "Terminal")
k:addInputString("Command", "", "Command", "Example: dd 5", "Command", "zs_casino_command")
k:addButton("RUN", "zs_casino_execute")
k:addDivider()
k:addLabelApp("COMMANDS", "Menu_Book")
K(
  k,
  "Drops",
  {
    { "dd [amount]", "Drop Diamond Locks" },
    { "wd [amount]", "Drop World Locks" },
    { "bd [amount] or db [amount]", "Drop Blue Gem Locks" },
    { "drop [amount]", "Drop an amount given in WL (drop 120 = 1 DL + 20 WL)" },
    { "daw", "Drop all WL, DL and BGL" },
    { "balance", "Show the locks in your inventory" },
  }
)
K(
  k,
  "Positions",
  {
    { "setpos1 - setpos4", "Save your position as 1-4" },
    { "pos1 - pos4", "Move to position 1-4" },
    { "setposback", "Save your home position" },
    { "back", "Move to the home position" },
  }
)
K(
  k,
  "Tax and payouts",
  {
    { "settax [%]", "Set the tax, e.g. settax 5 or settax 2,5" },
    { "tax", "Calculate the payout from the bet amount" },
    { "w1 - w4", "Go to position 1-4 and drop the payout" },
    { "win1 - win4, dt1 - dt4", "Same as w1 - w4" },
  }
)
K(
  k,
  "Worlds",
  {
    { "sethost [world]", "Set the host world (no world = current world)" },
    { "setsave [world]", "Set the save world (no world = current world)" },
    { "host", "Warp to the host world" },
    { "save", "Warp to the save world" },
  }
)
k:addDivider()
k:addLabelApp("COMMAND GUIDE", "Menu_Book")
ZS_label(k, D)
k:addDivider()
K(
  k,
  "BASICS",
  {
    { "/proxy", "Show the proxy menu / dialog" },
    { "/info", "Status of all commands" },
    { "/commands", "Shortcut to all proxy commands" },
    { "/ping and /xy", "Show your ping and your x,y position" },
    { "/res and /relog", "Fast respawn and fast relog" },
    { "/warn [text]", "Show a custom warning to yourself" },
    { "/testmod", "Test what happens when a mod joins" },
    { "/cid", "Create a new account" },
    { "/fc", "Force close the proxy" },
    { "/modfly", "Mod fly on/off" },
  }
)
k:addDivider()
K(
  k,
  "MOVEMENT",
  {
    { "/findpath [x] [y]", "Teleport to x,y" },
    { "/player [name]", "Teleport to a player" },
    { "/door [id]", "Enter a door by its ID" },
    { "/rndm", "Warp to a random world" },
  }
)
k:addDivider()
K(
  k,
  "ITEMS",
  {
    { "/autocollect", "Auto collect" },
    { "/ccollect or /cc [range]", "Collect items in a custom range" },
    { "/pickup [id]", "Pick up only the given item ID" },
    { "/nopickup", "Anti pickup" },
    { "/fd", "Fast drop" },
    { "/ft", "Fast trash" },
    { "/dropall", "Drop all items" },
    { "/buywl", "Buy WL with all your gems" },
  }
)
k:addDivider()
K(
  k,
  "WORLD CONTROL",
  {
    { "/world", "World menu" },
    { "/pullall", "Pull all players" },
    { "/kickall", "Kick all players" },
    { "/banall", "Ban all players" },
    { "/tradeall", "Trade with all players" },
    { "/wm", "Wrench menu" },
    { "/wp, /wk, /wb", "Wrench pull / kick / ban" },
    { "/woff", "Turn wrench mode off" },
    { "/join", "Join menu" },
    { "/j pull, /j kick, /j ban", "Pull / kick / ban players when they join" },
    { "/j off", "Turn join mode off" },
    { "/gs or /growscan", "Growscan menu" },
    { "/gs 1", "Scan placed blocks" },
    { "/gs 2", "Scan dropped items" },
    { "/fire ban", "Auto ban trollers" },
  }
)
k:addDivider()
K(
  k,
  "MACHINES",
  {
    { "/ut", "Unstable Tesseract menu" },
    { "/ut add or /ua", "Fast UT adder" },
    { "/ut empty or /ue", "Fast UT emptier" },
    { "/ut off or /uoff", "Turn UT mode off" },
    { "/gaia", "Gaia Beacon menu" },
    { "/gaia add or /ga", "Fast Gaia adder" },
    { "/gaia empty or /ge", "Fast Gaia emptier" },
    { "/gaia off or /goff", "Turn Gaia mode off" },
    { "/donation", "Donation box menu" },
    { "/donation empty or /de", "Fast empty the donation box" },
    { "/donation add or /da", "Fast fill the donation box" },
    { "/donation off or /doff", "Turn donation mode off" },
    { "/ve", "Fast empty a vending machine" },
    { "/va", "Fast stock a vending machine" },
    { "/vb [amount]", "Fast buy from a vending machine" },
    { "/voff", "Turn vend mode off" },
  }
)
k:addDivider()
K(
  k,
  "SPAM AND FARMING",
  {
    { "/spamtext or /spamt [text]", "Set the spam text" },
    { "/spamdelay or /sd [delay]", "Set the spam delay in seconds" },
    { "//", "Start / stop spam" },
    { "/harvestid [id]", "Set the seed ID" },
    { "/harvestdelay [delay]", "Set the harvest delay in ms" },
    { "/hv", "Start / stop harvest" },
  }
)
k:addDivider()
K(
  k,
  "LOOKS",
  {
    { "/titles", "Title menu" },
    { "/doctor", "Doctor title" },
    { "/legend", "Title of Legend" },
    { "/title", "Reset the title to normal" },
    { "/visual [item name]", "Wear any item as a visual" },
    { "/visual [slot] [item name]", "Force a slot: hat shirt pants shoes face hand back hair neck ances" },
    { "/visual off", "Go back to your real clothes" },
    { "/give [item name] [count]", "Add a visual item to your inventory" },
    { "/flag [country code]", "Change your flag" },
    { "/hide", "Hide all names (use again for normal)" },
    { "/name [name]", "Change your name (use again for normal)" },
    { "/inv", "Make everyone invisible" },
    { "/blink", "Blink skin" },
    { "/hidelvl", 'Hide the "need Level 13" message' },
  }
)
w(k:generateJSON(), "ZS")
local R = ""
local P = "0"
local F = ""
local c = "100"
local i = 20
local H = { ["spins"] = 0, ["red"] = 0, ["black"] = 0, ["green"] = 0, ["history"] = {}, ["counts"] = {} }
local t = {
  [1] = true,
  [3] = true,
  [5] = true,
  [7] = true,
  [9] = true,
  [12] = true,
  [14] = true,
  [16] = true,
  [18] = true,
  [19] = true,
  [21] = true,
  [23] = true,
  [25] = true,
  [27] = true,
  [30] = true,
  [32] = true,
  [34] = true,
  [36] = true,
}
local I = {}
local L = nil
local Q = nil
local J = nil
local T = {
  ["dd"] = { ["id"] = 1796, ["label"] = "Diamond Locks" },
  ["wd"] = { ["id"] = 242, ["label"] = "World Locks" },
  ["bd"] = { ["id"] = 7188, ["label"] = "Blue Gem Locks" },
}
local function u(a)
  local Z = T[a]
  if not Z or type(growtopia["checkInventoryCount"]) ~= "function" then
    return 0
  end
  local O, z = pcall(growtopia["checkInventoryCount"], Z["id"])
  z = O and tonumber(z) or 0
  return math["floor"](z)
end
local function v(a, Z)
  local z = T[a]
  if not z then
    return false
  end
  if type(growtopia["checkInventoryCount"]) ~= "function" or type(growtopia["confirmDropItem"]) ~= "function" then
    O("Drop API unavailable: this PowerKuy build needs checkInventoryCount and confirmDropItem.")
    return false
  end
  local f = u(a)
  if f <= 0 then
    O("No " .. (z["label"] .. " in inventory."))
    return false
  end
  local e = Z and math["floor"](Z) or f
  if e <= 0 then
    O("Amount must be greater than zero.")
    return false
  end
  e = math["min"](e, f)
  local Y, r = pcall(growtopia["confirmDropItem"], z["id"], e)
  if not Y then
    O("Drop failed for " .. (z["label"] .. (": " .. tostring(r))))
    return false
  end
  O("Drop requested: " .. (e .. (" " .. (z["label"] .. "."))))
  return true
end
local function A(a)
  a = math["floor"](tonumber(a) or 0)
  if a <= 0 then
    O("Nothing to drop.")
    return false
  end
  local Z = { ["bd"] = math["floor"](a / 10000), ["dd"] = math["floor"]((a % 10000) / 100), ["wd"] = a % 100 }
  for a, z in ipairs({ "bd", "dd", "wd" }) do
    local f = Z[z]
    if f > 0 then
      local a = u(z)
      if a < f then
        O("Not enough " .. (T[z]["label"] .. (". Need " .. (f .. (", have " .. (a .. ". Nothing dropped."))))))
        return false
      end
    end
  end
  local z = true
  for a, O in ipairs({ "bd", "dd", "wd" }) do
    if Z[O] > 0 and not v(O, Z[O]) then
      z = false
    end
  end
  return z
end
local function W()
  local a = tonumber(c)
  local Z = tonumber(i) or 0
  if not a or a < 0 or a % 1 ~= 0 or Z < 0 or Z > 100 then
    O("Enter a whole-number bet in WL and tax from 0 to 100%.")
    return nil
  end
  local z = math["floor"](((a * Z) / 100) + 1e-06)
  local f = math["max"](0, a - z)
  O(string["format"]("Bet: %.0f WL | Tax: %g%% (%.0f WL) | Net payout: %.0f WL", a, Z, z, f))
  return f
end
local function p()
  local a = W()
  if not a then
    return
  end
  if a <= 0 then
    O("Net payout is 0 WL. Nothing to drop.")
    return
  end
  if A(a) then
    O(string["format"]("Net payout drop requested: %.0f WL.", a))
  end
end
local function d()
  local a, Z, z = u("wd"), u("dd"), u("bd")
  O(string["format"]("WL %d | DL %d | BGL %d | Total %.0f WL", a, Z, z, (a + Z * 100) + z * 10000))
end
local function U(a)
  local Z = GetLocal()
  if not (Z and (Z["posX"] and Z["posY"])) then
    O("Could not read your current position.")
    return
  end
  local z, f = math["floor"](Z["posX"] / 32), math["floor"](Z["posY"] / 32)
  if a == "home" then
    L = { ["x"] = z, ["y"] = f }
    O("Home position saved: " .. (z .. (", " .. f)))
  else
    I[a] = { ["x"] = z, ["y"] = f }
    O("Position " .. (a .. (" saved: " .. (z .. (", " .. f)))))
  end
end
local function q(a, Z)
  if not a then
    O(Z .. " is not set.")
    return
  end
  runThread(function()
    FindPath(a["x"], a["y"])
  end)
end
local function G(a)
  local Z = I[a]
  if not Z then
    O("Position " .. (a .. (" is not set. Use setpos" .. (a .. " first."))))
    return
  end
  local z = W()
  if not z then
    return
  end
  if z <= 0 then
    O("Net payout is 0 WL. Nothing to drop.")
    return
  end
  runThread(function()
    FindPath(Z["x"], Z["y"])
    Sleep(600)
    A(z)
  end)
end
local function l(a, Z)
  if not a then
    O(Z .. " world is not set.")
    return
  end
  growtopia["warpTo"](a)
end
local function S(a)
  local Z = (((tostring(a or "")):lower()):gsub("^%s+", "")):gsub("%s+$", "")
  Z = Z:gsub("^/+", "")
  local z, f = Z:match("^(%a+)%s*(.-)$")
  if not z then
    O("Type a command, for example: dd 5")
    return
  end
  local e = nil
  if f:match("^%d+$") then
    e = tonumber(f)
  end
  if z == "db" then
    z = "bd"
  end
  local function Y()
    if e and (e >= 1 and e <= 4) then
      return e
    end
    O("Use " .. (z .. ("1 to " .. (z .. "4."))))
    return nil
  end
  if T[z] then
    if f ~= "" and (not e or e < 1) then
      O("Amount must be a positive whole number.")
      return
    end
    v(z, e)
  elseif z == "daw" then
    if f ~= "" then
      O("daw drops everything, do not add an amount.")
      return
    end
    for a, Z in ipairs({ "wd", "dd", "bd" }) do
      v(Z, nil)
    end
  elseif z == "drop" then
    if not e or e < 1 then
      O("Use: drop [amount in WL], for example drop 120")
      return
    end
    if A(e) then
      O(string["format"]("Drop requested: %d WL.", e))
    end
  elseif z == "balance" then
    d()
  elseif z == "settax" then
    local a = tonumber((f:gsub(",", ".")))
    if not a or a < 0 or a > 100 then
      O("Use: settax [0-100], for example settax 5 or settax 2,5")
      return
    end
    i = a
    O(string["format"]("Tax set to %g%%. (The slider in the menu does not move.)", a))
  elseif z == "tax" then
    W()
  elseif z == "setpos" then
    local a = Y()
    if a then
      U(a)
    end
  elseif z == "pos" then
    local a = Y()
    if a then
      q(I[a], "Position " .. a)
    end
  elseif z == "setposback" then
    U("home")
  elseif z == "back" then
    q(L, "Home position")
  elseif z == "w" or z == "win" or z == "dt" then
    local a = Y()
    if a then
      G(a)
    end
  elseif z == "sethost" or z == "setsave" then
    local a = f ~= "" and f:upper() or (GetWorldName()):upper()
    if z == "sethost" then
      Q = a
    else
      J = a
    end
    O((z == "sethost" and "Host" or "Save") .. (" world set: " .. a))
  elseif z == "host" then
    l(Q, "Host")
  elseif z == "save" then
    l(J, "Save")
  else
    O("Unknown command: " .. (z .. ". See the command list in ZS CASINO."))
  end
end
f(function(a, Z, z)
  if Z == "zs_auto_bgl_toggle" then
    if z then
      N()
    else
      x()
    end
  elseif Z == "zs_tax_bet_wl" then
    c = tostring(z or "0")
  elseif Z == "zs_tax_percent" then
    i = tonumber(z) or 0
  elseif Z == "zs_tax_calculate" then
    W()
  elseif Z == "zs_tax_drop" then
    p()
  elseif Z == "zs_casino_command" then
    F = tostring(z or "")
  elseif Z == "zs_casino_execute" then
    S(F)
  elseif Z == "zs_roulette_number" then
    R = tostring(z or "")
  elseif Z == "zs_roulette_record" then
    local a = tonumber(R)
    if not a or a < 0 or a > 36 or a % 1 ~= 0 then
      O("Enter a roulette result from 0 to 36.")
    else
      H["spins"] = H["spins"] + 1
      H["counts"][a] = (H["counts"][a] or 0) + 1
      table["insert"](H["history"], a)
      if #H["history"] > 20 then
        table["remove"](H["history"], 1)
      end
      if a == 0 then
        H["green"] = H["green"] + 1
      elseif t[a] then
        H["red"] = H["red"] + 1
      else
        H["black"] = H["black"] + 1
      end
      O(string["format"]("Recorded %.0f. Total spins: %d.", a, H["spins"]))
    end
  elseif Z == "zs_wl_amount" then
    P = tostring(z or "0")
  elseif Z == "zs_wl_calculate" then
    local a = tonumber(P)
    if not a or a < 0 then
      O("Enter a valid non-negative WL amount.")
    else
      a = math["floor"](a)
      local Z = math["floor"](a / 10000)
      local z = a % 10000
      local f = math["floor"](z / 100)
      local e = z % 100
      O(string["format"]("%.0f WL = %d BGL, %d DL, %d WL", a, Z, f, e))
    end
  elseif Z == "zs_casino_stats" then
    O(
      string["format"](
        "Roulette: %d spins | Red: %d | Black: %d | Green: %d | Recent: %s",
        H["spins"],
        H["red"],
        H["black"],
        H["green"],
        table["concat"](H["history"], ", ")
      )
    )
  end
end, "onValue")
if type(applyHook) == "function" then
  pcall(applyHook)
end
