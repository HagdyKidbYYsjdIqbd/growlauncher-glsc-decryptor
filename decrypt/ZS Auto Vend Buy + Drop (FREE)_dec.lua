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
  local u = {
    ["onValue"] = "onvalue",
    ["onDrawImGui"] = "ondrawimgui",
    ["OnVariant"] = "onvariant",
    ["OnDialog"] = "ondialog",
    ["OnSendPacket"] = "onsendpacket",
    ["OnSendPacketRaw"] = "onsendpacketraw",
  }
  local function P(u)
    if ZS_HUB["installed"][u] then
      return
    end
    ZS_HUB["installed"][u] = true
    local P = ZS_HUB["callbacks"][u]
    ZS_HUB["native"](function(...)
      local s = false
      for p = 1, #P, 1 do
        local E, R = pcall(P[p], ...)
        if not E then
          local s = "Hook error (" .. (u .. ("): " .. tostring(R)))
          if growtopia and type(growtopia["notify"]) == "function" then
            pcall(growtopia["notify"], s)
          else
            print(s)
          end
        elseif R == true then
          s = true
        end
      end
      return s
    end, s[u] or u)
  end
  function addHook(s, p)
    if type(s) ~= "function" then
      return
    end
    p = p or "onvalue"
    p = u[p] or (tostring(p)):lower()
    if not ZS_HUB["callbacks"][p] then
      ZS_HUB["callbacks"][p] = {}
    end
    table["insert"](ZS_HUB["callbacks"][p], s)
    P(p)
  end
end
if not ZS_thread then
  function ZS_thread(s)
    runThread(s)
  end
end
if not ZS_label then
  function ZS_label(s, u, ...)
    u = tostring(u == nil and "" or u)
    local P = ZS_LABEL_WIDTH
    local function p(s)
      if utf8 and utf8["len"] then
        return utf8["len"](s) or #s
      end
      return #s
    end
    local E, R = {}, ""
    for s in u:gmatch("%S+") do
      if R == "" then
        R = s
      elseif (p(R) + 1) + p(s) <= P then
        R = R .. (" " .. s)
      else
        E[#E + 1] = R
        R = s
      end
    end
    if R ~= "" then
      E[#E + 1] = R
    end
    if #E == 0 then
      E[1] = u
    end
    for u, P in ipairs(E) do
      s:addLabel(P, ...)
    end
  end
end
if not ZS_CATEGORY_ADDED then
  ZS_CATEGORY_ADDED = true
  if type(addCategory) == "function" then
    pcall(addCategory, "ZS", "Shield")
  end
end
local s = { ["tag"] = "k10", ["life"] = "ZSA-AVD", ["unlocked"] = false, ["entered"] = "", ["n"] = 0 }
local function u(s)
  if growtopia and type(growtopia["notify"]) == "function" then
    pcall(growtopia["notify"], tostring(s))
  else
    print("[ZS] " .. tostring(s))
  end
end
local P = u
local p = addHook
local function E(u, P)
  if type(u) ~= "function" then
    return
  end
  return p(function(...)
    if not s["unlocked"] then
      return false
    end
    return u(...)
  end, P)
end
local function R(s)
  local u = tostring(s)
  local P, p = u:find('"menu"%s*:%s*%[')
  if not P then
    return nil
  end
  local E, R, L, l = 1, p + 1, false, false
  while R <= #u do
    local s = u:sub(R, R)
    if L then
      if l then
        l = false
      elseif s == "\\" then
        l = true
      elseif s == '"' then
        L = false
      end
    elseif s == '"' then
      L = true
    elseif s == "[" then
      E = E + 1
    elseif s == "]" then
      E = E - 1
      if E == 0 then
        return u:sub(p + 1, R - 1)
      end
    end
    R = R + 1
  end
end
local function L()
  s["n"] = s["n"] + 1
  local u = UserInterface["new"]("ZS ACCESS", "Lock")
  u:addLabelApp("* ACCESS KEY *", "Lock")
  ZS_label(u, "Enter your key. You can look around, but everything works only after unlock.")
  u:addInputString("Enter Key", "", "Enter Key", "Your key", "Key", "zskey_" .. (s["tag"] .. ("_" .. s["n"])))
  u:addButton("UNLOCK", "zsunl_" .. (s["tag"] .. ("_" .. s["n"])))
  u:addDivider()
  return u
end
local l = addIntoModule
local function U(u, P, ...)
  if type(u) == "string" and not u:find("zskey_" .. (s["tag"] .. "_"), 1, true) then
    local s, p = pcall(function()
      local s = L()
      local P = R(s:generateJSON())
      local p, E = u:find('"menu"%s*:%s*%[')
      if not (P and p) then
        return nil
      end
      local l = u:sub(E + 1)
      local U = l:match("^%s*%]") and "" or ","
      return u:sub(1, E) .. (P .. (U .. l))
    end)
    if s and p then
      u = p
    else
      pcall(function()
        l((L()):generateJSON(), P)
      end)
    end
  end
  return l(u, P, ...)
end
local function I(...)
  local P = select("#", ...)
  local p = { ... }
  local E, R = "zskey_" .. (s["tag"] .. "_"), "zsunl_" .. (s["tag"] .. "_")
  local function L(s)
    if type(s) ~= "string" then
      return nil
    end
    if s:sub(1, #E) == E then
      return "key"
    end
    if s:sub(1, #R) == R then
      return "btn"
    end
  end
  local l, U
  local function I(s, u)
    if l or u > 2 then
      return
    end
    if type(s) == "string" then
      l = L(s)
    elseif type(s) == "table" then
      for P, p in pairs(s) do
        if L(p) then
          l = L(p)
          U = s["value"] or s["text"] or s["v2"]
          return
        end
        if L(P) then
          l = L(P)
          U = p
          return
        end
        if type(p) == "table" then
          I(p, u + 1)
        end
      end
    end
  end
  for s = 1, P, 1 do
    I(p[s], 0)
    if l then
      if U == nil then
        U = p[s + 1]
      end
      break
    end
  end
  if l == "key" then
    s["entered"] = tostring(U or "")
    return true
  elseif l == "btn" then
    local P = ((s["entered"]:upper()):gsub("%s+", ""))
    if P == s["life"]:upper() then
      s["unlocked"] = true
      u("Key accepted. Unlocked!")
    else
      u("Invalid key.")
    end
    return true
  end
  return false
end
p(I, "onvalue")
local a, z = pcall(require, "json")
if not a then
  z = nil
end
local B = {
  ["list"] = {},
  ["running"] = false,
  ["token"] = 0,
  ["buyWorld"] = "",
  ["dropWorld"] = "",
  ["dropX"] = nil,
  ["dropY"] = nil,
  ["scanned"] = 0,
  ["bought"] = 0,
  ["skipped"] = 0,
  ["current"] = "-",
  ["status"] = "Stopped",
  ["waiting"] = false,
  ["dialog"] = nil,
}
local W, T = 20, 200
local function Q(s)
  if type(growtopia) == "table" and growtopia["notify"] then
    pcall(growtopia["notify"], tostring(s))
  elseif type(sendNotification) == "function" then
    pcall(sendNotification, tostring(s))
  end
  if type(log) == "function" then
    pcall(log, "[ZS Auto Vend & Drop] " .. tostring(s))
  end
end
local function K()
  if type(GetWorldName) == "function" then
    local s, u = pcall(GetWorldName)
    if s then
      return (tostring(u or "")):upper()
    end
  end
  return ""
end
local function O()
  if type(getLocal) ~= "function" then
    return nil, nil
  end
  local s, u = pcall(getLocal)
  if not s or type(u) ~= "table" or type(u["posX"]) ~= "number" or type(u["posY"]) ~= "number" then
    return nil, nil
  end
  return math["floor"](u["posX"] / 32), math["floor"](u["posY"] / 32)
end
local function f(s, u)
  if type(getTile) == "function" then
    local P, p = pcall(getTile, s, u)
    if P then
      return p
    end
  end
  return nil
end
local function M(s)
  return type(s) == "table" and (type(s["extra"]) == "table" and s["extra"]) or nil
end
local function H(s)
  if not s then
    return nil
  end
  for u, P in ipairs({ "vend_amount", "amount", "stock", "count", "item_count", "vend_count" }) do
    local p = tonumber(s[P])
    if p then
      return math["max"](0, p)
    end
  end
  return nil
end
local function J(s)
  local u = tonumber(s and s["vend_price"]) or 0
  if u < 0 then
    return math["abs"](u), u
  end
  return T, u
end
local function Z()
  local s = {
    { "Status", B["status"] },
    { "Vending List", tostring(#B["list"]) .. ("/" .. W) },
    { "Scanned", tostring(B["scanned"]) },
    { "Purchased", tostring(B["bought"]) },
    { "Skipped", tostring(B["skipped"]) },
    { "Current", B["current"] },
    { "Buy World", B["buyWorld"] ~= "" and B["buyWorld"] or "Not set" },
    { "Drop", B["dropX"] and (B["dropWorld"] .. (" (" .. (B["dropX"] .. ("," .. (B["dropY"] .. ")"))))) or "Not set" },
  }
  if type(z) == "table" and (z["encode"] and type(editValue) == "function") then
    pcall(editValue, "zs_avd_status", z:encode(s))
  end
  if type(editValue) == "function" then
    pcall(editValue, "zs_avd_list", z and (z["encode"] and z:encode((function()
      local s = {}
      for u, P in ipairs(B["list"]) do
        s[#s + 1] = { "#" .. u, string["format"]("%s (%d,%d)", P["world"], P["x"], P["y"]) }
      end
      return s
    end)())) or "[]")
  end
end
local function F(s, u)
  local P = 0
  while P < s and (B["running"] and B["token"] == u) do
    sleep(50)
    P = P + 50
  end
end
local function t(s, u)
  if type(FindPath) == "function" then
    return FindPath(s, u) ~= false
  end
  if type(findPath) == "function" then
    return findPath(s, u) ~= false
  end
  return false
end
local function V(s, u)
  local P, p = O()
  if not P then
    return false
  end
  if math["abs"](P - s) <= 2 and math["abs"](p - u) <= 2 then
    return true
  end
  for E = 1, 3, 1 do
    for R = -E, E, 1 do
      for L = -E, E, 1 do
        if math["max"](math["abs"](R), math["abs"](L)) == E and t(s + R, u + L) then
          local E = 0
          while E < 2500 and B["running"] do
            P, p = O()
            if P and (math["abs"](P - s) <= 2 and math["abs"](p - u) <= 2) then
              return true
            end
            sleep(100)
            E = E + 100
          end
        end
      end
    end
  end
  return false
end
local function X(s, u)
  if type(sendPacketRaw) ~= "function" or type(getLocal) ~= "function" then
    return false
  end
  local P, p = pcall(getLocal)
  if not P or not p then
    return false
  end
  pcall(
    sendPacketRaw,
    false,
    { ["type"] = 3, ["value"] = 32, ["px"] = s, ["py"] = u, ["x"] = p["posX"], ["y"] = p["posY"] }
  )
  return true
end
local function G(s)
  B["waiting"] = true
  B["dialog"] = nil
  local u = 0
  while u < 2200 and (B["running"] and (B["token"] == s and not B["dialog"])) do
    sleep(50)
    u = u + 50
  end
  B["waiting"] = false
  return B["dialog"]
end
local function x(s)
  if type(getInventory) ~= "function" then
    return 0
  end
  local u, P = pcall(getInventory)
  if not u or type(P) ~= "table" then
    return 0
  end
  for u, P in pairs(P) do
    if tonumber(P["id"]) == tonumber(s) then
      return tonumber(P["amount"]) or 0
    end
  end
  return 0
end
local function N()
  local s, u = B["dropX"], B["dropY"]
  if not s or not u then
    return nil, nil
  end
  local function P(s, u)
    local P = f(s, u)
    if not P then
      return false
    end
    local p, E = tonumber(P["fg"]) or 0, tonumber(P["bg"]) or 0
    return p == 0 and E == 0
  end
  if P(s, u) then
    return s, u
  end
  for p = 1, 6, 1 do
    for E = -p, p, 1 do
      for R = -p, p, 1 do
        if math["max"](math["abs"](E), math["abs"](R)) == p and P(s + E, u + R) then
          return s + E, u + R
        end
      end
    end
  end
  return nil, nil
end
local function d(s, u, P)
  local p = math["min"](tonumber(u) or 0, T)
  while p > 0 and (B["running"] and B["token"] == P) do
    local u, E = N()
    if not u then
      B["status"] = "STOPPED: no free drop tile"
      Z()
      Q("Drop area is full; stopped safely. No random dropping.")
      return false
    end
    local R, L = O()
    if R ~= u or L ~= E then
      t(u, E)
      F(500, P)
    end
    local l = math["min"](p, T)
    local U = x(s)
    if type(sendPacket) == "function" then
      sendPacket(2, "action|drop\nitemID|" .. s)
      F(350, P)
      sendPacket(2, "action|dialog_return\ndialog_name|drop_item\nitemID|" .. (s .. ("|\ncount|" .. (l .. "\n"))))
    else
      return false
    end
    local I = 0
    local a = 0
    while I < 1800 and (B["running"] and B["token"] == P) do
      F(100, P)
      I = I + 100
      a = math["max"](0, U - x(s))
      if a > 0 then
        break
      end
    end
    if a <= 0 then
      B["status"] = "STOPPED: drop not confirmed"
      Z()
      return false
    end
    p = math["max"](0, p - a)
  end
  return p == 0
end
local function D(s, u)
  table["remove"](B["list"], s)
  B["skipped"] = B["skipped"] + 1
  B["status"] = "Skipped: " .. tostring(u or "invalid vend")
  Z()
  Q("Removed from script list only: " .. tostring(u or "vend"))
end
local function q(s, u, P)
  if not B["running"] or B["token"] ~= u then
    return
  end
  B["current"] = string["format"]("%d/%d @ %d,%d", P, #B["list"], s["x"], s["y"])
  B["status"] = "Checking vending"
  B["scanned"] = B["scanned"] + 1
  Z()
  if K() ~= s["world"] then
    if type(sendPacket) == "function" then
      sendPacket(3, "action|join_request\nname|" .. (s["world"] .. "\ninvitedWorld|0"))
    else
      B["status"] = "Cannot join buy world"
      return
    end
    F(2500, u)
  end
  local p = f(s["x"], s["y"])
  local E = M(p)
  if not p or (tonumber(p["fg"]) ~= 2978 and tonumber(p["fg"]) ~= 9268) or not E then
    D(P, "vend missing")
    return
  end
  local R = tonumber(E["vend_item"])
  local L = H(E)
  local l, U = J(E)
  if not R or R <= 0 then
    D(P, "empty vend")
    return
  end
  if L and L < l then
    D(P, string["format"]("stock %d/%d", L, l))
    return
  end
  if not V(s["x"], s["y"]) then
    B["status"] = "Could not reach vending"
    Z()
    return
  end
  X(s["x"], s["y"])
  local I = G(u)
  if not I then
    B["status"] = "Vending dialog not detected"
    Z()
    Q("Could not read vending dialog; stopped this vend safely.")
    return
  end
  local a = tonumber(I:match("itemID|(%d+)") or I:match("vend_item|(%d+)")) or R
  local z = tonumber(I:match("contains%s+(%d+)") or I:match("vend_amount|(%d+)") or I:match("amount|(%d+)")) or L
  if z and z < l then
    D(P, string["format"]("stock %d/%d", z, l))
    return
  end
  local W = math["min"](T, z or T)
  if U < 0 then
    W = math["abs"](U)
  end
  local O = x(a)
  B["status"] = "Buying " .. W
  Z()
  if type(sendPacket) == "function" then
    sendPacket(
      2,
      table["concat"](
        {
          "action|dialog_return",
          "dialog_name|vending",
          "tilex|" .. s["x"],
          "tiley|" .. s["y"],
          "itemID|" .. a,
          "count|" .. W,
          "buttonClicked|buy",
          "",
        },
        "\n"
      )
    )
  else
    B["status"] = "Buy API unavailable"
    return
  end
  local t = 0
  local N = 0
  while t < 3500 and (B["running"] and B["token"] == u) do
    sleep(100)
    t = t + 100
    N = math["max"](0, x(a) - O)
    if N > 0 then
      break
    end
  end
  if N <= 0 then
    B["status"] = "Purchase not confirmed"
    Z()
    return
  end
  B["bought"] = B["bought"] + N
  B["status"] = "Purchased " .. (N .. "; dropping")
  Z()
  if B["dropWorld"] ~= "" and K() ~= B["dropWorld"] then
    sendPacket(3, "action|join_request\nname|" .. (B["dropWorld"] .. "\ninvitedWorld|0"))
    F(2500, u)
  end
  d(a, N, u)
end
local function A()
  if B["running"] then
    return
  end
  if #B["list"] == 0 then
    Q("Add at least one vending first.")
    return
  end
  if B["buyWorld"] == "" then
    B["buyWorld"] = K()
  end
  if B["dropX"] == nil then
    Q("Set Drop Position first.")
    return
  end
  B["running"] = true
  B["token"] = B["token"] + 1
  local s = B["token"]
  B["status"] = "Running"
  Z()
  runThread(function()
    local u = 1
    while B["running"] and (B["token"] == s and u <= #B["list"]) do
      local P = #B["list"]
      q(B["list"][u], s, u)
      if #B["list"] == P then
        u = u + 1
      end
      F(500, s)
    end
    if B["running"] and B["token"] == s then
      B["running"] = false
      B["status"] = "Finished"
      B["current"] = "-"
      Z()
      Q("Vending list finished.")
    end
  end)
end
local function m(s)
  B["running"] = false
  B["token"] = B["token"] + 1
  B["status"] = s or "Stopped"
  B["current"] = "-"
  Z()
end
local g = UserInterface["new"]("ZS AUTO VEND & DROP", "ShoppingCart")
g:addLabelApp("* ZS AUTO VEND & DROP *", "ShoppingCart")
g:addTooltip(
  "AUTO VEND & DROP",
  "Save your vending machines, buy world and drop position. Turn AUTO VEND & DROP ON to visit each saved machine, buy available stock and drop the items at your chosen position. If no safe drop tile is available, the run stops.",
  "Info",
  true
)
g:addDivider()
g:addButton("ADD CURRENT VEND", "zs_avd_add")
g:addButton("REMOVE LAST VEND", "zs_avd_remove")
g:addButton("CLEAR VEND LIST", "zs_avd_clear")
g:addButton("SET BUY WORLD", "zs_avd_set_world")
g:addButton("SET DROP POSITION", "zs_avd_set_drop")
g:addToggle("AUTO VEND & DROP", false, "zs_avd_run", false)
g:addDisplayList("Vend List", "[]", "zs_avd_list")
g:addDisplayList("ZS AUTO VEND & DROP - INFO", "[]", "zs_avd_status")
U(g:generateJSON(), "ZS")
Z()
E(function(s, u, P)
  if u == "zs_avd_add" then
    local s, u = O()
    local P, p, E = nil, nil, nil
    local R = K()
    if s then
      for R = 1, 3, 1 do
        for L = -R, R, 1 do
          for l = -R, R, 1 do
            if math["max"](math["abs"](L), math["abs"](l)) == R then
              local R = f(s + L, u + l)
              if R and (tonumber(R["fg"]) == 2978 or tonumber(R["fg"]) == 9268) then
                P, p, E = s + L, u + l, R
                break
              end
            end
          end
          if E then
            break
          end
        end
      end
    end
    if not P then
      Q("No vending machine found within 3 tiles.")
      return
    end
    for s, u in ipairs(B["list"]) do
      if u["world"] == R and (u["x"] == P and u["y"] == p) then
        Q("This vending is already in the list.")
        return
      end
    end
    if #B["list"] >= W then
      Q("Maximum 20 vending machines.")
      return
    end
    B["list"][#B["list"] + 1] = { ["world"] = R, ["x"] = P, ["y"] = p }
    Z()
    Q("Added vending " .. (P .. ("," .. p)))
  elseif u == "zs_avd_remove" then
    if #B["list"] > 0 then
      table["remove"](B["list"])
      Z()
    end
  elseif u == "zs_avd_clear" then
    if not B["running"] then
      B["list"] = {}
      Z()
    end
  elseif u == "zs_avd_set_world" then
    B["buyWorld"] = K()
    for s, u in ipairs(B["list"]) do
      u["world"] = B["buyWorld"]
    end
    Z()
    Q("Buy world: " .. B["buyWorld"])
  elseif u == "zs_avd_set_drop" then
    local s, u = O()
    if s then
      B["dropWorld"] = K()
      B["dropX"] = s
      B["dropY"] = u
      Z()
      Q("Drop position set: " .. (B["dropWorld"] .. (" (" .. (s .. ("," .. (u .. ")"))))))
    end
  elseif u == "zs_avd_run" then
    if P == true or P == 1 or P == "true" then
      A()
    else
      m("Stopped")
    end
  end
end, "onValue")
E(function(s)
  if not B["running"] or not B["waiting"] or type(s) ~= "table" or s["v1"] ~= "OnDialogRequest" then
    return false
  end
  local u = tostring(s["v2"] or "")
  if u:find("vending", 1, true) or u:find("vend_item", 1, true) then
    B["dialog"] = u
    return true
  end
  return false
end, "onVariant")
if type(applyHook) == "function" then
  pcall(applyHook)
end
