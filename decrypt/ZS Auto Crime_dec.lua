ZS_LABEL_WIDTH = ZS_LABEL_WIDTH or 30
if not ZS_HUB then
  ZS_HUB = { ["native"] = addHook, ["callbacks"] = {}, ["installed"] = {} }
  local u = {
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
  local function D(s)
    if ZS_HUB["installed"][s] then
      return
    end
    ZS_HUB["installed"][s] = true
    local D = ZS_HUB["callbacks"][s]
    ZS_HUB["native"](function(...)
      local u = false
      for P = 1, #D, 1 do
        local H, y = pcall(D[P], ...)
        if not H then
          local u = "Hook error (" .. (s .. ("): " .. tostring(y)))
          if growtopia and type(growtopia["notify"]) == "function" then
            pcall(growtopia["notify"], u)
          else
            print(u)
          end
        elseif y == true then
          u = true
        end
      end
      return u
    end, u[s] or s)
  end
  function addHook(u, P)
    if type(u) ~= "function" then
      return
    end
    P = P or "onvalue"
    P = s[P] or (tostring(P)):lower()
    if not ZS_HUB["callbacks"][P] then
      ZS_HUB["callbacks"][P] = {}
    end
    table["insert"](ZS_HUB["callbacks"][P], u)
    D(P)
  end
end
if not ZS_thread then
  function ZS_thread(u)
    runThread(u)
  end
end
if not ZS_label then
  function ZS_label(u, s, ...)
    s = tostring(s == nil and "" or s)
    local D = ZS_LABEL_WIDTH
    local function P(u)
      if utf8 and utf8["len"] then
        return utf8["len"](u) or #u
      end
      return #u
    end
    local H, y = {}, ""
    for u in s:gmatch("%S+") do
      if y == "" then
        y = u
      elseif (P(y) + 1) + P(u) <= D then
        y = y .. (" " .. u)
      else
        H[#H + 1] = y
        y = u
      end
    end
    if y ~= "" then
      H[#H + 1] = y
    end
    if #H == 0 then
      H[1] = s
    end
    for s, D in ipairs(H) do
      u:addLabel(D, ...)
    end
  end
end
if not ZS_CATEGORY_ADDED then
  ZS_CATEGORY_ADDED = true
  if type(addCategory) == "function" then
    pcall(addCategory, "ZS", "Shield")
  end
end
local u = { ["tag"] = "k14", ["life"] = "ZSA-CRIME", ["unlocked"] = false, ["entered"] = "", ["n"] = 0 }
local function s(u)
  if growtopia and type(growtopia["notify"]) == "function" then
    pcall(growtopia["notify"], tostring(u))
  else
    print("[ZS] " .. tostring(u))
  end
end
local D = s
local P = addHook
local function H(s, D)
  if type(s) ~= "function" then
    return
  end
  return P(function(...)
    if not u["unlocked"] then
      return false
    end
    return s(...)
  end, D)
end
local function y(u)
  local s = tostring(u)
  local D, P = s:find('"menu"%s*:%s*%[')
  if not D then
    return nil
  end
  local H, y, N, S = 1, P + 1, false, false
  while y <= #s do
    local u = s:sub(y, y)
    if N then
      if S then
        S = false
      elseif u == "\\" then
        S = true
      elseif u == '"' then
        N = false
      end
    elseif u == '"' then
      N = true
    elseif u == "[" then
      H = H + 1
    elseif u == "]" then
      H = H - 1
      if H == 0 then
        return s:sub(P + 1, y - 1)
      end
    end
    y = y + 1
  end
end
local function N()
  u["n"] = u["n"] + 1
  local s = UserInterface["new"]("ZS ACCESS", "Lock")
  s:addLabelApp("* ACCESS KEY *", "Lock")
  ZS_label(s, "Enter your key. You can look around, but everything works only after unlock.")
  s:addInputString("Enter Key", "", "Enter Key", "Your key", "Key", "zskey_" .. (u["tag"] .. ("_" .. u["n"])))
  s:addButton("UNLOCK", "zsunl_" .. (u["tag"] .. ("_" .. u["n"])))
  s:addDivider()
  return s
end
local S = addIntoModule
local function W(s, D, ...)
  if type(s) == "string" and not s:find("zskey_" .. (u["tag"] .. "_"), 1, true) then
    local u, P = pcall(function()
      local u = N()
      local D = y(u:generateJSON())
      local P, H = s:find('"menu"%s*:%s*%[')
      if not (D and P) then
        return nil
      end
      local S = s:sub(H + 1)
      local W = S:match("^%s*%]") and "" or ","
      return s:sub(1, H) .. (D .. (W .. S))
    end)
    if u and P then
      s = P
    else
      pcall(function()
        S((N()):generateJSON(), D)
      end)
    end
  end
  return S(s, D, ...)
end
local function c(...)
  local D = select("#", ...)
  local P = { ... }
  local H, y = "zskey_" .. (u["tag"] .. "_"), "zsunl_" .. (u["tag"] .. "_")
  local function N(u)
    if type(u) ~= "string" then
      return nil
    end
    if u:sub(1, #H) == H then
      return "key"
    end
    if u:sub(1, #y) == y then
      return "btn"
    end
  end
  local S, W
  local function c(u, s)
    if S or s > 2 then
      return
    end
    if type(u) == "string" then
      S = N(u)
    elseif type(u) == "table" then
      for D, P in pairs(u) do
        if N(P) then
          S = N(P)
          W = u["value"] or u["text"] or u["v2"]
          return
        end
        if N(D) then
          S = N(D)
          W = P
          return
        end
        if type(P) == "table" then
          c(P, s + 1)
        end
      end
    end
  end
  for u = 1, D, 1 do
    c(P[u], 0)
    if S then
      if W == nil then
        W = P[u + 1]
      end
      break
    end
  end
  if S == "key" then
    u["entered"] = tostring(W or "")
    return true
  elseif S == "btn" then
    local D = ((u["entered"]:upper()):gsub("%s+", ""))
    if D == u["life"]:upper() then
      u["unlocked"] = true
      s("Key accepted. Unlocked!")
    else
      s("Invalid key.")
    end
    return true
  end
  return false
end
P(c, "onvalue")
local e, X = false, false
local j = false
local J = false
local O = -180000
local M, G, A, Y, C = 300, 150, 400, 800, 1500
local a, w = 10, 200
local T = UserInterface["new"]("ZS AUTO CRIME", "Gavel")
T:addLabelApp("* ZS AUTO CRIME *", "Gavel")
T:addTooltip(
  "AUTO CRIME",
  "Turn FULL AUTO CRIME ON to start the battle automation. AUTO RESTOCK collects dropped Crime cards from your storage world when stock is low, then returns to your world. Turn the toggles OFF to stop.",
  "Info",
  true
)
T:addDivider()
T:addToggle("FULL AUTO CRIME", false, "zs_crime_run", true)
T:addDivider()
ZS_label(T, "CRIME CARDS - Storage world")
T:addToggle("AUTO RESTOCK", false, "zs_crime_restock", true)
T:addInputString(
  "Crime storage world",
  "",
  "Crime storage world",
  "World where Crime cards are dropped. When a card is below 10, it goes there, collects cards and returns.",
  "World",
  "zs_crime_storage_world"
)
W(T:generateJSON(), "ZS")
local l = {
  { ["name"] = "Crime card 2294", ["id"] = 2294 },
  { ["name"] = "Crime card 2296", ["id"] = 2296 },
  { ["name"] = "Crime card 2298", ["id"] = 2298 },
  { ["name"] = "Crime card 2300", ["id"] = 2300 },
  { ["name"] = "Crime card 2308", ["id"] = 2308 },
  { ["name"] = "Crime card 2310", ["id"] = 2310 },
  { ["name"] = "Crime card 2312", ["id"] = 2312 },
  { ["name"] = "Crime card 2314", ["id"] = 2314 },
  { ["name"] = "Crime card 2316", ["id"] = 2316 },
  { ["name"] = "Crime card 2320", ["id"] = 2320 },
  { ["name"] = "Crime card 2322", ["id"] = 2322 },
  { ["name"] = "Crime card 2324", ["id"] = 2324 },
  { ["name"] = "Crime card 2326", ["id"] = 2326 },
  { ["name"] = "Crime card 2328", ["id"] = 2328 },
  { ["name"] = "Crime card 2332", ["id"] = 2332 },
  { ["name"] = "Crime card 2334", ["id"] = 2334 },
  { ["name"] = "Crime card 2336", ["id"] = 2336 },
  { ["name"] = "Crime card 2338", ["id"] = 2338 },
}
local I = {
  ["The Firebug"] = "Fire",
  ["Jimmy Snow"] = "Ice",
  ["Big Bertha"] = "Muscle",
  ["Shockinator"] = "Lightning",
  ["Paddy O'Malice"] = "Event",
  ["Bunny Barko"] = "Event",
  ["El Peligro"] = "Event",
  ["Pine-Fresh"] = "Event",
  ["The Harvester"] = "Event",
  ["Generic Thug #17"] = "Mastermind",
  ["Professor Pummel"] = "Mastermind",
  ["Dragon Hand"] = "Mastermind",
  ["Kat 5"] = "Mastermind",
  ["Ms. Terry"] = "Supervillain",
  ["Z. Everett Koop"] = "Supervillain",
  ["Dr. Destructo"] = "Supervillain",
  ["Almighty Seth"] = "Supervillain",
  ["Devil Ham"] = "Supervillain",
  ["H.R. Geiger"] = "Special",
}
local L = {
  ["The Firebug"] = { "Frozen Mirror", "Ice Shards" },
  ["Jimmy Snow"] = { "Thunderstorm", "Shocking Fist" },
  ["Big Bertha"] = { "Overheat", "Incinerate" },
  ["Shockinator"] = { "Enrage", "Crush" },
  ["Generic Thug #17"] = { "Incinerate", "Flame On!" },
  ["Professor Pummel"] = { "Incinerate", "Flame On!" },
  ["Dragon Hand"] = { "Crush", "Regeneration" },
  ["Kat 5"] = { "Overcharge", "Shocking Fist", "Thunderstorm" },
  ["Ms. Terry"] = { "Super Speed", "counter opponent card" },
  ["Z. Everett Koop"] = { "Incinerate", "Flame On!" },
  ["Dr. Destructo"] = { "Frost Breath", "Frozen Mirror" },
  ["Almighty Seth"] = { "Crush", "Regeneration" },
  ["Devil Ham"] = { "Frost Breath", "Frozen Mirror" },
  ["Paddy O'Malice"] = { "Incinerate", "Heat Vision", "Regeneration if Liquify" },
  ["Bunny Barko"] = { "Overheat", "Incinerate" },
  ["El Peligro"] = { "Liquify", "Regeneration", "Super Strength" },
  ["Pine-Fresh"] = { "Crush", "Regeneration" },
  ["The Harvester"] = { "Frost Breath", "Frozen Mirror", "Super Speed after Incinerate" },
  ["H.R. Geiger"] = { "Overcharge", "Thunderstorm", "Megawatt Pulse", "Regeneration", "Flame On!" },
}
local function E(u)
  growtopia["notify"](tostring(u))
end
local function i()
  return math["floor"](os["clock"]() * 1000)
end
local function v(u)
  if growtopia and type(growtopia["checkInventoryCount"]) == "function" then
    local s, D = pcall(growtopia["checkInventoryCount"], u)
    if s then
      return tonumber(D) or 0
    end
  end
  return 0
end
local function F()
  local u = {}
  for s, D in ipairs(l) do
    if tonumber(D["id"]) and tonumber(D["id"]) > 0 then
      u[#u + 1] = { ["name"] = D["name"], ["id"] = tonumber(D["id"]) }
    end
  end
  return u
end
local function Q()
  local u = {}
  for s, D in ipairs(F()) do
    if v(D["id"]) < a then
      u[#u + 1] = D["name"]
    end
  end
  return u
end
local function m()
  if type(GetWorldName) == "function" then
    local u, s = pcall(GetWorldName)
    if u and s then
      return tostring(s)
    end
  end
end
local function d(u, s)
  local D = 0
  while D < s do
    local s = m()
    if s and s:upper() == u:upper() then
      return true
    end
    Sleep(250)
    D = D + 250
  end
  local P = m()
  return P ~= nil and P:upper() == u:upper()
end
local function b()
  local u = GetObjects or getObjects
  if type(u) == "function" then
    local s, D = pcall(u)
    if s and type(D) == "table" then
      return D
    end
  end
  local s = GetObjectList or getObjectList
  if type(s) == "function" then
    local u, D = pcall(s)
    if u and type(D) == "table" then
      return D
    end
  end
  return {}
end
local function q()
  local u = {}
  for s, D in ipairs(F()) do
    u[D["id"]] = true
  end
  local s = {}
  for D, P in pairs(b()) do
    local H = tonumber(P and (P["itemid"] or P["itemID"] or P["item_id"] or P["id"]))
    local y = P and (P["pos"] or P["position"])
    local N = tonumber((y and (y["x"] or y["posX"])) or (P and (P["x"] or P["posX"])))
    local S = tonumber((y and (y["y"] or y["posY"])) or (P and (P["y"] or P["posY"])))
    if H and (u[H] and (N and S)) then
      s[#s + 1] = { ["id"] = H, ["x"] = math["floor"](N / 32), ["y"] = math["floor"](S / 32) }
    end
  end
  table["sort"](s, function(u, s)
    if u["y"] == s["y"] then
      return u["x"] < s["x"]
    end
    return u["y"] < s["y"]
  end)
  if #s == 0 then
    E(
      "No Crime card drops detected in storage world. Check that cards are dropped on the ground and that the world is correct."
    )
    return 0
  end
  if type(FindPath) ~= "function" then
    E("Cannot collect Crime cards: FindPath API is unavailable.")
    return #s
  end
  for u, s in ipairs(s) do
    if v(s["id"]) < w then
      FindPath(s["x"], s["y"])
      Sleep(900)
    end
  end
  return #s
end
local function V()
  if J or not j or #l == 0 then
    return
  end
  local u = type(getValue) == "function" and getValue(2, "zs_crime_storage_world") or ""
  u = (tostring(u or "")):match("^%s*(.-)%s*$")
  if u == "" then
    return
  end
  local s = Q()
  if #s == 0 then
    return
  end
  if (i() - O) < 30000 then
    return
  end
  if not growtopia or type(growtopia["warpTo"]) ~= "function" then
    E("Cannot take materials: warp API unavailable.")
    return
  end
  local D = m()
  if not D or D == "" or D == "EXIT" then
    return
  end
  J = true
  E("Materials low (" .. (table["concat"](s, ", ") .. ("). Going to " .. (u:upper() .. "..."))))
  local P = D:upper() == u:upper()
  if not P then
    growtopia["warpTo"](u:upper())
    if not d(u, 15000) then
      E("Could not enter Crime storage world: " .. u:upper())
      J = false
      return
    end
  end
  O = i()
  Sleep(800)
  q()
  if not P then
    growtopia["warpTo"](D)
    if not d(D, 15000) then
      E("Materials taken, but could not return to " .. D)
      J = false
      return
    end
  end
  Sleep(800)
  local H = Q()
  if #H == 0 then
    E("Materials restocked. Continuing crime.")
  else
    E("Materials taken. Still below 10: " .. table["concat"](H, ", "))
  end
  J = false
end
local function h()
  if type(GetNPCList) ~= "function" then
    return nil
  end
  local u, s = pcall(GetNPCList)
  if not u or type(s) ~= "table" then
    return nil
  end
  local D = {}
  for u, s in pairs(s) do
    D[#D + 1] = { ["name"] = tostring(s["name"] or s["id"] or "?"), ["x"] = s["x"] or s["posX"], ["y"] = s["y"]
      or s["posY"] }
  end
  return D
end
local p = SendPacket or sendPacket
local t, r, f = nil, nil, nil
local x, R = nil, nil
local k = {}
local Z = 2302
local g = false
local z, B = 0, 0
local K = false
local n = 0
local o = 15000
local function U()
  return (type(getTime) == "function" and getTime()) or math["floor"](os["clock"]() * 1000)
end
local function uH()
  return
end
local function sH(u, s)
  return type(u) == "string" and u:find(s) ~= nil
end
local function DH(u)
  if type(p) ~= "function" or not x or not R then
    return false
  end
  local s = "action|dialog_return\ndialog_name|crime_edit\ntilex|"
    .. (tostring(x) .. ("|\ntiley|" .. (tostring(R) .. ("|\nstate|1||\nbuttonClicked|" .. tostring(u)))))
  local D = pcall(p, 2, s)
  return D
end
local function PH(u)
  if not e or type(u) ~= "table" then
    return false
  end
  local s, D = tostring(u["v1"] or ""), tostring(u["v2"] or "")
  if s ~= "OnDialogRequest" then
    return false
  end
  if sH(D, "Devil Ham``%'s `2Crush`` card `4melted") then
    t = "yes"
  end
  if sH(D, "Ms%. Terry") and sH(D, "Ban Hammer") then
    r = "yes"
  end
  if sH(D, "|Battle%!|") then
    K = true
    n = U()
    x = D:match("tilex|(%d+)")
    R = D:match("tiley|(%d+)")
    if e and (x and R) then
      uH()
    end
    local u, s, P, H, y
    if sH(D, "Crime in Progress") then
      u, s, P, H, y = 2298, 2308, 2320, 2324, 2332
    end
    local function N(D, N, S, W, c)
      u, s, P, H, y = D, N, S, W, c
    end
    if sH(D, "Jimmy Snow") then
      k = { y, H, P }
    elseif sH(D, "Big Bertha") then
      k = { u, H, P }
    elseif sH(D, "Shockinator") then
      k = { H, P, u }
    elseif sH(D, "The Firebug") then
      k = { s, u, y }
    elseif sH(D, "Generic Thug") or sH(D, "Kat 5") then
      k = { H, P, s }
    elseif sH(D, "Professor Pummel") then
      N(2296, 2298, 2300, 2320, 2324)
      k = { P, s, u }
    elseif sH(D, "Z%. Everett Koop") then
      N(2296, 2298, 2300, 2320, 2324)
      k = { P, u, s }
    elseif sH(D, "Dr%. Destructo") then
      N(2298, 2308, 2310, 2314, 2316)
      f = "0"
      k = { u, P, y }
    elseif sH(D, "Dragon Hand") or sH(D, "Almighty Seth") then
      N(2308, 2312, 2314, 2326, 2328)
      k = { y, H, 6969 }
    elseif sH(D, "Devil Ham") then
      N(2298, 2332, 2334, 2336, 2338)
      k = { u, H, y, P, s }
      t = "no"
      f = "1"
    elseif sH(D, "Ms%. Terry") then
      N(2294, 2316, 2322, 2328, 2338)
      k = { u, s, P, H, y }
      r = "no"
    end
    if u and (s and (P and (H and (y and (x and R))))) then
      local D = "action|dialog_return\ndialog_name|crime_edit\ntilex|"
        .. (
          x
          .. (
            "|\ntiley|"
            .. (
              R
              .. (
                "|\nstate|0||\nbuttonClicked|button_ok\n\nc"
                .. (u .. ("|1\nc" .. (s .. ("|1\nc" .. (P .. ("|1\nc" .. (H .. ("|1\nc" .. (y .. "|1\n")))))))))
              )
            )
          )
        )
      if type(p) == "function" then
        pcall(p, 2, D)
      end
    end
    return true
  end
  if not sH(D, "Fighting Crime") then
    K = false
    return false
  end
  K = true
  n = U()
  local P
  for u, s in ipairs({ "Devil Ham", "Ms%. Terry", "Dr%. Destructo" }) do
    if sH(D, s) then
      P = s
      break
    end
  end
  local H, y, N, S, W = k[1], k[2], k[3], k[4], k[5]
  local c = "passturn"
  if P == "Devil Ham" then
    if t == "no" then
      if H and sH(D, "c" .. H) then
        c = H
      end
    elseif f == "0" and (y and sH(D, "c" .. y)) then
      f = "1"
      c = y
    elseif N and sH(D, "c" .. N) then
      c = N
    elseif S and sH(D, "c" .. S) then
      c = S
    elseif W and sH(D, "c" .. W) then
      c = W
    end
  elseif P == "Ms%. Terry" then
    local u = D:match("is going to play `(%d)")
    if u == "2" then
      c = H
    elseif u == "4" then
      c = y
    elseif u == "9" then
      c = S
    elseif u == "1" then
      c = W
    elseif N and sH(D, "c" .. N) then
      c = N
    elseif W and (r == "yes" and sH(D, "c" .. W)) then
      c = W
    elseif H and sH(D, "c" .. H) then
      c = H
    elseif S and sH(D, "c" .. S) then
      c = S
    elseif W and sH(D, "c" .. W) then
      c = W
    elseif y and sH(D, "c" .. y) then
      c = y
    end
  elseif P == "Dr%. Destructo" then
    if f == "0" and (H and sH(D, "c" .. H)) then
      c = H
      f = "1"
    elseif y and sH(D, "c" .. y) then
      c = y
    elseif N and sH(D, "c" .. N) then
      c = N
    end
  else
    if H and sH(D, "c" .. H) then
      c = H
    elseif y and sH(D, "c" .. y) then
      c = y
    elseif N and sH(D, "c" .. N) then
      c = N
    end
  end
  DH("c" .. tostring(c))
  return true
end
if type(H) == "function" then
  H(PH, "onvariant")
end
local function HH()
  return false
end
local function yH(u)
  return false
end
local NH = false
local function SH()
  if NH then
    return
  end
  NH = true
  ZS_thread(function()
    while j do
      if not J then
        V()
      end
      Sleep(1000)
    end
    NH = false
  end)
end
local function WH()
  E("Auto Crime started. Battle dialog handler enabled.")
  while not X do
    V()
    Sleep(Y)
  end
  e = false
  E("Auto Crime stopped.")
end
H(function(u, s, D)
  if s == "zs_crime_run" then
    if D and not e then
      e, X = true, false
      K = false
      n = 0
      ZS_thread(WH)
    elseif not D then
      X = true
      x, R = nil, nil
      K = false
      n = 0
    end
  elseif s == "zs_crime_restock" then
    j = D and true or false
    if j then
      O = -180000
      SH()
      E("Crime AUTO RESTOCK enabled. Checking card counts independently.")
    else
      E("Crime AUTO RESTOCK disabled.")
    end
  end
end, "onValue")
if type(applyHook) == "function" then
  pcall(applyHook)
end
