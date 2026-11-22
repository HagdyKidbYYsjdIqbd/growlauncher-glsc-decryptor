ZS_LABEL_WIDTH = ZS_LABEL_WIDTH or 30
if not ZS_HUB then
  ZS_HUB = { ["native"] = addHook, ["callbacks"] = {}, ["installed"] = {} }
  local i = {
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
  local function p(g)
    if ZS_HUB["installed"][g] then
      return
    end
    ZS_HUB["installed"][g] = true
    local p = ZS_HUB["callbacks"][g]
    ZS_HUB["native"](function(...)
      local i = false
      for w = 1, #p, 1 do
        local t, m = pcall(p[w], ...)
        if not t then
          local i = "Hook error (" .. (g .. ("): " .. tostring(m)))
          if growtopia and type(growtopia["notify"]) == "function" then
            pcall(growtopia["notify"], i)
          else
            print(i)
          end
        elseif m == true then
          i = true
        end
      end
      return i
    end, i[g] or g)
  end
  function addHook(i, w)
    if type(i) ~= "function" then
      return
    end
    w = w or "onvalue"
    w = g[w] or (tostring(w)):lower()
    if not ZS_HUB["callbacks"][w] then
      ZS_HUB["callbacks"][w] = {}
    end
    table["insert"](ZS_HUB["callbacks"][w], i)
    p(w)
  end
end
if not ZS_thread then
  function ZS_thread(i)
    runThread(i)
  end
end
if not ZS_label then
  function ZS_label(i, g, ...)
    g = tostring(g == nil and "" or g)
    local p = ZS_LABEL_WIDTH
    local function w(i)
      if utf8 and utf8["len"] then
        return utf8["len"](i) or #i
      end
      return #i
    end
    local t, m = {}, ""
    for i in g:gmatch("%S+") do
      if m == "" then
        m = i
      elseif (w(m) + 1) + w(i) <= p then
        m = m .. (" " .. i)
      else
        t[#t + 1] = m
        m = i
      end
    end
    if m ~= "" then
      t[#t + 1] = m
    end
    if #t == 0 then
      t[1] = g
    end
    for g, p in ipairs(t) do
      i:addLabel(p, ...)
    end
  end
end
if not ZS_CATEGORY_ADDED then
  ZS_CATEGORY_ADDED = true
  if type(addCategory) == "function" then
    pcall(addCategory, "ZS", "Shield")
  end
end
local i = { ["tag"] = "k04", ["life"] = "ZSA-GAUT", ["unlocked"] = false, ["entered"] = "", ["n"] = 0 }
local function g(i)
  if growtopia and type(growtopia["notify"]) == "function" then
    pcall(growtopia["notify"], tostring(i))
  else
    print("[ZS] " .. tostring(i))
  end
end
local p = g
local w = addHook
local function t(g, p)
  if type(g) ~= "function" then
    return
  end
  return w(function(...)
    if not i["unlocked"] then
      return false
    end
    return g(...)
  end, p)
end
local function m(i)
  local g = tostring(i)
  local p, w = g:find('"menu"%s*:%s*%[')
  if not p then
    return nil
  end
  local t, m, L, j = 1, w + 1, false, false
  while m <= #g do
    local i = g:sub(m, m)
    if L then
      if j then
        j = false
      elseif i == "\\" then
        j = true
      elseif i == '"' then
        L = false
      end
    elseif i == '"' then
      L = true
    elseif i == "[" then
      t = t + 1
    elseif i == "]" then
      t = t - 1
      if t == 0 then
        return g:sub(w + 1, m - 1)
      end
    end
    m = m + 1
  end
end
local function L()
  i["n"] = i["n"] + 1
  local g = UserInterface["new"]("ZS ACCESS", "Lock")
  g:addLabelApp("* ACCESS KEY *", "Lock")
  ZS_label(g, "Enter your key. You can look around, but everything works only after unlock.")
  g:addInputString("Enter Key", "", "Enter Key", "Your key", "Key", "zskey_" .. (i["tag"] .. ("_" .. i["n"])))
  g:addButton("UNLOCK", "zsunl_" .. (i["tag"] .. ("_" .. i["n"])))
  g:addDivider()
  return g
end
local j = addIntoModule
local function J(g, p, ...)
  if type(g) == "string" and not g:find("zskey_" .. (i["tag"] .. "_"), 1, true) then
    local i, w = pcall(function()
      local i = L()
      local p = m(i:generateJSON())
      local w, t = g:find('"menu"%s*:%s*%[')
      if not (p and w) then
        return nil
      end
      local j = g:sub(t + 1)
      local J = j:match("^%s*%]") and "" or ","
      return g:sub(1, t) .. (p .. (J .. j))
    end)
    if i and w then
      g = w
    else
      pcall(function()
        j((L()):generateJSON(), p)
      end)
    end
  end
  return j(g, p, ...)
end
local function d(...)
  local p = select("#", ...)
  local w = { ... }
  local t, m = "zskey_" .. (i["tag"] .. "_"), "zsunl_" .. (i["tag"] .. "_")
  local function L(i)
    if type(i) ~= "string" then
      return nil
    end
    if i:sub(1, #t) == t then
      return "key"
    end
    if i:sub(1, #m) == m then
      return "btn"
    end
  end
  local j, J
  local function d(i, g)
    if j or g > 2 then
      return
    end
    if type(i) == "string" then
      j = L(i)
    elseif type(i) == "table" then
      for p, w in pairs(i) do
        if L(w) then
          j = L(w)
          J = i["value"] or i["text"] or i["v2"]
          return
        end
        if L(p) then
          j = L(p)
          J = w
          return
        end
        if type(w) == "table" then
          d(w, g + 1)
        end
      end
    end
  end
  for i = 1, p, 1 do
    d(w[i], 0)
    if j then
      if J == nil then
        J = w[i + 1]
      end
      break
    end
  end
  if j == "key" then
    i["entered"] = tostring(J or "")
    return true
  elseif j == "btn" then
    local p = ((i["entered"]:upper()):gsub("%s+", ""))
    if p == i["life"]:upper() then
      i["unlocked"] = true
      g("Key accepted. Unlocked!")
    else
      g("Invalid key.")
    end
    return true
  end
  return false
end
w(d, "onvalue")
local n = require("json")
local r = require("preferences")
local K = r:new("zs_gaut_auto_retrieve.json")
local V = {
  ["title"] = "ZS AUTO GAUT",
  ["author"] = "ZS",
  ["category"] = "ZS",
  ["categoryIcon"] = "Shield",
  ["loadDelay"] = 6000,
  ["maxTake"] = 200,
  ["wrenchWait"] = 700,
  ["wrenchWaitFar"] = 1500,
  ["idleWait"] = 2000,
}
local C = {
  ["gaia"] = { ["id"] = 6946, ["dialog"] = "itemsucker_seed", ["name"] = "Gaia's Beacon" },
  ["ut"] = { ["id"] = 6948, ["dialog"] = "itemsucker_block", ["name"] = "Unstable Tesseract" },
}
local P = {
  ["running"] = false,
  ["token"] = 0,
  ["kind"] = K:get("kind", "gaia"),
  ["delay"] = K:get("delay", 150),
  ["dropX"] = K:get("drop_x", nil),
  ["dropY"] = K:get("drop_y", nil),
  ["dropWorld"] = K:get("drop_world", nil),
  ["waiting"] = false,
  ["info"] = nil,
  ["state"] = "Stopped",
  ["machine"] = "-",
  ["total"] = 0,
}
local function U(i)
  pcall(log, "[ZS] " .. tostring(i))
end
local function v(i)
  pcall(sendNotification, tostring(i))
  U(i)
end
local function D()
  if type(getLocal) ~= "function" then
    return nil, nil
  end
  local i, g = pcall(getLocal)
  if not i or type(g) ~= "table" or type(g["posX"]) ~= "number" or type(g["posY"]) ~= "number" then
    return nil, nil
  end
  return math["floor"](g["posX"] / 32), math["floor"](g["posY"] / 32)
end
local function N()
  local i = {
    { "State", P["state"] },
    { "Source", "Gaia + Unstable Tesseract" },
    { "Machine", P["machine"] },
    { "Drop Pos", P["dropX"] and (P["dropX"] .. (", " .. P["dropY"])) or "Not set" },
    { "Retrieved", tostring(P["total"]) },
  }
  pcall(editValue, "zs_gaut_status", n:encode(i))
end
local function z(i)
  return P["running"] and P["token"] == i
end
local function Q(i, g)
  local p = 0
  while p < i and z(g) do
    sleep(25)
    p = p + 25
  end
end
local function Z()
  sleep(math["max"](P["delay"], 100))
end
local function u(i, g)
  if type(getLocal) ~= "function" or type(sendPacketRaw) ~= "function" then
    return false
  end
  local p, w = pcall(getLocal)
  if not p or type(w) ~= "table" or type(w["posX"]) ~= "number" or type(w["posY"]) ~= "number" then
    return false
  end
  sendPacketRaw(false, { ["type"] = 3, ["value"] = 32, ["px"] = i, ["py"] = g, ["x"] = w["posX"], ["y"] = w["posY"] })
  return true
end
local function H(i, g, p, w)
  sendPacket(
    2,
    table["concat"](
      {
        "action|dialog_return",
        "dialog_name|" .. i,
        "tilex|" .. (g .. "|"),
        "tiley|" .. (p .. "|"),
        "buttonClicked|retrieveitem",
        "",
        "chk_enablesucking|1",
        "",
      },
      "\n"
    )
  )
  Z()
  sendPacket(
    2,
    table["concat"](
      {
        "action|dialog_return",
        "dialog_name|itemremovedfromsucker",
        "tilex|" .. (g .. "|"),
        "tiley|" .. (p .. "|"),
        "itemtoremove|" .. w,
        "",
      },
      "\n"
    )
  )
end
local function c(i, g)
  sendPacket(2, "action|drop\nitemID|" .. i)
  Z()
  sendPacket(2, "action|dialog_return\ndialog_name|drop_item\nitemID|" .. (i .. ("|\ncount|" .. (g .. "\n"))))
end
local function l(i)
  local g, p = pcall(getInventory)
  if not g or type(p) ~= "table" then
    return 0
  end
  for g, p in pairs(p) do
    if p["id"] == i then
      return p["amount"] or 0
    end
  end
  return 0
end
local function k(i, g, p)
  local w = 0
  while w < 1800 and z(p) do
    sleep(50)
    w = w + 50
    local p = l(i)
    if p > g then
      sleep(80)
      return l(i) - g
    end
  end
  return 0
end
local function e(i, g, p)
  local w = 0
  while w < 1500 and z(p) do
    if l(i) <= g then
      return
    end
    sleep(50)
    w = w + 50
  end
end
local function o(i, g)
  if type(FindPath) == "function" then
    local p = FindPath(i, g)
    return p ~= false
  end
  if type(findPath) == "function" then
    local p = findPath(i, g)
    return p ~= false
  end
  return false
end
local function B(i, g, p)
  if type(i) ~= "number" or type(g) ~= "number" then
    return false
  end
  local w, t = D()
  if w == i and t == g then
    return true
  end
  if not o(i, g) then
    return false
  end
  local m = 0
  while m < 4000 and z(p) do
    sleep(50)
    m = m + 50
    w, t = D()
    if w == i and t == g then
      return true
    end
  end
  return false
end
local function x(i, g)
  local p, w = D()
  if p == nil or w == nil then
    return false
  end
  return math["abs"](p - i) <= 2 and math["abs"](w - g) <= 2
end
local function E(i, g, p)
  if x(i, g) then
    return true
  end
  local w = {}
  for p = 1, 3, 1 do
    for t = -p, p, 1 do
      for m = -p, p, 1 do
        if math["max"](math["abs"](t), math["abs"](m)) == p then
          w[#w + 1] = { i + t, g + m, p }
        end
      end
    end
  end
  local t, m = D()
  table["sort"](w, function(i, g)
    local p = math["abs"](i[1] - (t or i[1])) + math["abs"](i[2] - (m or i[2]))
    local w = math["abs"](g[1] - (t or g[1])) + math["abs"](g[2] - (m or g[2]))
    if p == w then
      return i[3] < g[3]
    end
    return p < w
  end)
  local L = 0
  for w, t in ipairs(w) do
    if not z(p) then
      return false
    end
    L = L + 1
    if L > 18 then
      break
    end
    local m = o(t[1], t[2])
    if m then
      local w = 0
      while w < 1800 and z(p) do
        if x(i, g) then
          return true
        end
        sleep(100)
        w = w + 100
      end
      if x(i, g) then
        return true
      end
    end
  end
  return x(i, g)
end
local function W()
  local i, g = D()
  if i == nil or g == nil then
    return {}
  end
  local p, w = {}, 0
  local t = { [C["gaia"]["id"]] = "gaia", [C["ut"]["id"]] = "ut" }
  local m, L = pcall(getTiles)
  if m and type(L) == "table" then
    for m, L in pairs(L) do
      w = w + 1
      local j = t[tonumber(L["fg"])]
      if j then
        p[#p + 1] =
          { ["x"] = tonumber(L["x"]), ["y"] = tonumber(L["y"]), ["kind"] = j, ["d"] = math["abs"](L["x"] - i)
            + math["abs"](L["y"] - g) }
      end
    end
  end
  if w == 0 then
    for w = 0, 99, 1 do
      for m = 0, 59, 1 do
        local L, j = pcall(getTile, w, m)
        local J = L and (type(j) == "table" and t[tonumber(j["fg"])])
        if J then
          p[#p + 1] = { ["x"] = w, ["y"] = m, ["kind"] = J, ["d"] = math["abs"](w - i) + math["abs"](m - g) }
        end
      end
    end
  end
  table["sort"](p, function(i, g)
    return i["d"] < g["d"]
  end)
  return p
end
local function R(i)
  local g, p
  for w, t in pairs(C) do
    if i:find(t["dialog"], 1, true) and i:find("|" .. (t["id"] .. "|"), 1, true) then
      g, p = t, w
      break
    end
  end
  if not g then
    return nil
  end
  local w = i:match("embed_data|tilex|(%d+)")
  local t = i:match("embed_data|tiley|(%d+)")
  local m = i:match("contains (%d+)")
  local L = i:match("add_label_with_icon|small|[^|]*|left|(%d+)|")
  if w and (t and (m and L)) then
    return {
      ["dialog"] = g["dialog"],
      ["kind"] = p,
      ["x"] = tonumber(w),
      ["y"] = tonumber(t),
      ["amount"] = tonumber(m),
      ["item"] = tonumber(L),
    }
  end
  return nil
end
local function Y(i, g, p)
  P["info"] = nil
  P["waiting"] = true
  u(i["x"], i["y"])
  local w = 0
  while w < g and (not P["info"] and z(p)) do
    sleep(25)
    w = w + 25
  end
  P["waiting"] = false
  return P["info"]
end
local I = nil
local function F(i, g)
  local p = false
  local w = 0
  P["machine"] = C[i["kind"]]["name"] .. (" (" .. (i["x"] .. (", " .. (i["y"] .. ")"))))
  while z(g) do
    if not x(i["x"], i["y"]) then
      P["state"] = "Walking near " .. C[i["kind"]]["name"]
      N()
      E(i["x"], i["y"], g)
    end
    local t = Y(i, V["wrenchWaitFar"], g)
    if not t and z(g) then
      sleep(250)
      t = Y(i, V["wrenchWaitFar"] + 500, g)
    end
    if not t and z(g) then
      sleep(500)
      t = Y(i, V["wrenchWaitFar"] + 1000, g)
    end
    if not t then
      U(
        "Could not open "
          .. (
            C[i["kind"]]["name"]
            .. " dialog after pathing to the nearest reachable tile. Check walls, range, or machine ID."
          )
      )
      return p and "worked" or "skip"
    end
    if t["amount"] <= 0 then
      return p and "worked" or "empty"
    end
    local m = math["min"](t["amount"], V["maxTake"])
    local L = l(t["item"])
    H(t["dialog"], t["x"], t["y"], m)
    local j = k(t["item"], L, g)
    if j <= 0 then
      w = w + 1
      if w >= 3 then
        U("Items not entering inventory (full backpack?)")
        return p and "worked" or "skip"
      end
    else
      w = 0
      if not B(P["dropX"], P["dropY"], g) then
        U("Could not reach the drop position")
      end
      c(t["item"], j)
      e(t["item"], L, g)
      if l(t["item"]) > L then
        P["dropFails"] = (P["dropFails"] or 0) + 1
        if P["dropFails"] >= 2 then
          I = "Drop was blocked or failed - stopped."
          return p and "worked" or "skip"
        end
      else
        P["dropFails"] = 0
      end
      P["total"] = P["total"] + j
      p = true
      N()
    end
    Q(math["max"](P["delay"], 100), g)
  end
  return p and "worked" or "skip"
end
local function G(i)
  while z(i) do
    if type(GetWorldName) ~= "function" or GetWorldName() ~= P["dropWorld"] then
      P["state"] = "Stopped"
      P["running"] = false
      v("World changed - set the drop position again.")
      pcall(editToggle, "zs_gaut_run", false)
      N()
      return
    end
    local g = W()
    if #g == 0 then
      P["running"] = false
      P["state"] = "Stopped"
      v("No Gaia's Beacon or Unstable Tesseract found in this world.")
      pcall(editToggle, "zs_gaut_run", false)
      N()
      return
    end
    local p = false
    P["state"] = "Running"
    N()
    for g, w in ipairs(g) do
      if not z(i) then
        break
      end
      local t = F(w, i)
      if t == "worked" then
        p = true
      end
      if I then
        break
      end
    end
    if I then
      local i = I
      I = nil
      P["running"] = false
      P["state"] = "Stopped"
      v(i)
      pcall(editToggle, "zs_gaut_run", false)
      N()
      return
    end
    if z(i) and not p then
      P["state"] = "Idle (all empty)"
      P["machine"] = "-"
      N()
      Q(V["idleWait"], i)
    end
  end
end
local function s(i)
  if i then
    v(i)
  end
  P["running"] = false
  P["waiting"] = false
  P["token"] = P["token"] + 1
  P["state"] = "Stopped"
  P["machine"] = "-"
  pcall(editToggle, "zs_gaut_run", false)
  N()
end
local function S()
  if P["running"] then
    return
  end
  if not P["dropX"] then
    v("Set the drop position first.")
    pcall(editToggle, "zs_gaut_run", false)
    return
  end
  if type(GetWorldName) ~= "function" or GetWorldName() ~= P["dropWorld"] then
    v("Drop position belongs to another world - set it again.")
    pcall(editToggle, "zs_gaut_run", false)
    return
  end
  P["running"] = true
  P["token"] = P["token"] + 1
  P["state"] = "Running"
  local i = P["token"]
  N()
  v("Started - Gaia + Unstable Tesseract")
  runThread(function()
    G(i)
  end)
end
local function X(i, g)
  if type(i) ~= "table" then
    return false
  end
  if type(i["v1"]) ~= "string" or i["v1"] ~= "OnDialogRequest" then
    return false
  end
  if not P["running"] then
    return
  end
  local p = tostring(i["v2"] or "")
  if P["waiting"] then
    local i = R(p)
    if i then
      P["info"] = i
      return true
    end
  end
  if
    p:find("end_dialog|itemremovedfromsucker|")
    or p:find("end_dialog|drop_item|")
    or p:find(C["gaia"]["dialog"], 1, true)
    or p:find(C["ut"]["dialog"], 1, true)
  then
    return true
  end
end
t(function(i, g, p)
  if g == "zs_gaut_run" then
    if p then
      S()
    else
      if P["running"] then
        s("Stopped")
      end
    end
  elseif g == "zs_gaut_gaia" then
    if p then
      if P["kind"] ~= "gaia" then
        P["kind"] = "gaia"
        K:set("kind", P["kind"])
        K:save()
        pcall(editToggle, "zs_gaut_ut", false)
        N()
      end
    elseif P["kind"] == "gaia" then
      pcall(editToggle, "zs_gaut_gaia", true)
    end
  elseif g == "zs_gaut_ut" then
    if p then
      if P["kind"] ~= "ut" then
        P["kind"] = "ut"
        K:set("kind", P["kind"])
        K:save()
        pcall(editToggle, "zs_gaut_gaia", false)
        N()
      end
    elseif P["kind"] == "ut" then
      pcall(editToggle, "zs_gaut_ut", true)
    end
  elseif g == "zs_gaut_setdrop" then
    local i, g = D()
    P["dropX"], P["dropY"], P["dropWorld"] = i, g, GetWorldName()
    K:set("drop_x", i)
    K:set("drop_y", g)
    K:set("drop_world", P["dropWorld"])
    K:save()
    v("Drop position set: " .. (i .. (", " .. g)))
    N()
  elseif g == "zs_gaut_delay" then
    P["delay"] = math["floor"](tonumber(p) or 120)
    K:set("delay", P["delay"])
    K:save()
  end
end, "onValue")
local q = UserInterface["new"]("ZS AUTO GAUT", "Shield")
q:addLabelApp("* ZS AUTO GAUT *", "Shield")
q:addTooltip(
  "* ZS AUTO GAUT *",
  "Automatically retrieves items from Gaia's Beacon and Unstable Tesseract, then drops them at your saved position. Select a source and set the drop position before starting.",
  "Info",
  true
)
q:addDivider()
q:addToggle("ZS AUTO GAUT", false, "zs_gaut_run", true)
q:addDivider()
q:addLabel("Source")
q:addToggle("Gaia's Beacon", P["kind"] == "gaia", "zs_gaut_gaia", false)
q:addToggle("Unstable Tesseract", P["kind"] == "ut", "zs_gaut_ut", false)
q:addDivider()
q:addButton("Set Drop Position", "zs_gaut_setdrop")
q:addSlider("Packet Delay (ms)", 0, 500, P["delay"], 10, false, "zs_gaut_delay")
q:addDivider()
q:addDisplayList("Status", "Default", "zs_gaut_status")
J(q:generateJSON(), "ZS")
N()
t(X, "onVariant")
U("Loaded - Script Created By " .. V["author"])
if type(applyHook) == "function" then
  pcall(applyHook)
end
