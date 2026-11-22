ZS_LABEL_WIDTH = ZS_LABEL_WIDTH or 30
if not ZS_HUB then
  ZS_HUB = { ["native"] = addHook, ["callbacks"] = {}, ["installed"] = {} }
  local J = {
    ["onvalue"] = "onValue",
    ["ondrawimgui"] = "onDrawImGui",
    ["onvariant"] = "onVariant",
    ["ondialog"] = "onDialog",
    ["onsendpacket"] = "onSendPacket",
    ["onsendpacketraw"] = "onSendPacketRaw",
  }
  local S = {
    ["onValue"] = "onvalue",
    ["onDrawImGui"] = "ondrawimgui",
    ["OnVariant"] = "onvariant",
    ["OnDialog"] = "ondialog",
    ["OnSendPacket"] = "onsendpacket",
    ["OnSendPacketRaw"] = "onsendpacketraw",
  }
  local function Q(S)
    if ZS_HUB["installed"][S] then
      return
    end
    ZS_HUB["installed"][S] = true
    local Q = ZS_HUB["callbacks"][S]
    ZS_HUB["native"](function(...)
      local J = false
      for f = 1, #Q, 1 do
        local k, x = pcall(Q[f], ...)
        if not k then
          local J = "Hook error (" .. (S .. ("): " .. tostring(x)))
          if growtopia and type(growtopia["notify"]) == "function" then
            pcall(growtopia["notify"], J)
          else
            print(J)
          end
        elseif x == true then
          J = true
        end
      end
      return J
    end, J[S] or S)
  end
  function addHook(J, f)
    if type(J) ~= "function" then
      return
    end
    f = f or "onvalue"
    f = S[f] or (tostring(f)):lower()
    if not ZS_HUB["callbacks"][f] then
      ZS_HUB["callbacks"][f] = {}
    end
    table["insert"](ZS_HUB["callbacks"][f], J)
    Q(f)
  end
end
if not ZS_thread then
  function ZS_thread(J)
    runThread(J)
  end
end
if not ZS_label then
  function ZS_label(J, S, ...)
    S = tostring(S == nil and "" or S)
    local Q = ZS_LABEL_WIDTH
    local function f(J)
      if utf8 and utf8["len"] then
        return utf8["len"](J) or #J
      end
      return #J
    end
    local k, x = {}, ""
    for J in S:gmatch("%S+") do
      if x == "" then
        x = J
      elseif (f(x) + 1) + f(J) <= Q then
        x = x .. (" " .. J)
      else
        k[#k + 1] = x
        x = J
      end
    end
    if x ~= "" then
      k[#k + 1] = x
    end
    if #k == 0 then
      k[1] = S
    end
    for S, Q in ipairs(k) do
      J:addLabel(Q, ...)
    end
  end
end
if not ZS_CATEGORY_ADDED then
  ZS_CATEGORY_ADDED = true
  if type(addCategory) == "function" then
    pcall(addCategory, "ZS", "Shield")
  end
end
local J = { ["tag"] = "k03", ["life"] = "ZSA-SURG", ["unlocked"] = false, ["entered"] = "", ["n"] = 0 }
local function S(J)
  if growtopia and type(growtopia["notify"]) == "function" then
    pcall(growtopia["notify"], tostring(J))
  else
    print("[ZS] " .. tostring(J))
  end
end
local Q = S
local f = addHook
local function k(S, Q)
  if type(S) ~= "function" then
    return
  end
  return f(function(...)
    if not J["unlocked"] then
      return false
    end
    return S(...)
  end, Q)
end
local function x(J)
  local S = tostring(J)
  local Q, f = S:find('"menu"%s*:%s*%[')
  if not Q then
    return nil
  end
  local k, x, R, o = 1, f + 1, false, false
  while x <= #S do
    local J = S:sub(x, x)
    if R then
      if o then
        o = false
      elseif J == "\\" then
        o = true
      elseif J == '"' then
        R = false
      end
    elseif J == '"' then
      R = true
    elseif J == "[" then
      k = k + 1
    elseif J == "]" then
      k = k - 1
      if k == 0 then
        return S:sub(f + 1, x - 1)
      end
    end
    x = x + 1
  end
end
local function R()
  J["n"] = J["n"] + 1
  local S = UserInterface["new"]("ZS ACCESS", "Lock")
  S:addLabelApp("* ACCESS KEY *", "Lock")
  ZS_label(S, "Enter your key. You can look around, but everything works only after unlock.")
  S:addInputString("Enter Key", "", "Enter Key", "Your key", "Key", "zskey_" .. (J["tag"] .. ("_" .. J["n"])))
  S:addButton("UNLOCK", "zsunl_" .. (J["tag"] .. ("_" .. J["n"])))
  S:addDivider()
  return S
end
local o = addIntoModule
local function u(S, Q, ...)
  if type(S) == "string" and not S:find("zskey_" .. (J["tag"] .. "_"), 1, true) then
    local J, f = pcall(function()
      local J = R()
      local Q = x(J:generateJSON())
      local f, k = S:find('"menu"%s*:%s*%[')
      if not (Q and f) then
        return nil
      end
      local o = S:sub(k + 1)
      local u = o:match("^%s*%]") and "" or ","
      return S:sub(1, k) .. (Q .. (u .. o))
    end)
    if J and f then
      S = f
    else
      pcall(function()
        o((R()):generateJSON(), Q)
      end)
    end
  end
  return o(S, Q, ...)
end
local function n(...)
  local Q = select("#", ...)
  local f = { ... }
  local k, x = "zskey_" .. (J["tag"] .. "_"), "zsunl_" .. (J["tag"] .. "_")
  local function R(J)
    if type(J) ~= "string" then
      return nil
    end
    if J:sub(1, #k) == k then
      return "key"
    end
    if J:sub(1, #x) == x then
      return "btn"
    end
  end
  local o, u
  local function n(J, S)
    if o or S > 2 then
      return
    end
    if type(J) == "string" then
      o = R(J)
    elseif type(J) == "table" then
      for Q, f in pairs(J) do
        if R(f) then
          o = R(f)
          u = J["value"] or J["text"] or J["v2"]
          return
        end
        if R(Q) then
          o = R(Q)
          u = f
          return
        end
        if type(f) == "table" then
          n(f, S + 1)
        end
      end
    end
  end
  for J = 1, Q, 1 do
    n(f[J], 0)
    if o then
      if u == nil then
        u = f[J + 1]
      end
      break
    end
  end
  if o == "key" then
    J["entered"] = tostring(u or "")
    return true
  elseif o == "btn" then
    local Q = ((J["entered"]:upper()):gsub("%s+", ""))
    if Q == J["life"]:upper() then
      J["unlocked"] = true
      S("Key accepted. Unlocked!")
    else
      S("Invalid key.")
    end
    return true
  end
  return false
end
f(n, "onvalue")
local l = {
  ["Sponge"] = 1258,
  ["Scalpel"] = 1260,
  ["Anesthetic"] = 1262,
  ["Antibiotic"] = 1266,
  ["Splint"] = 1268,
  ["Stitches"] = 1270,
  ["FixIt"] = 1296,
  ["Pins"] = 4308,
  ["Transfusion"] = 4310,
  ["Defibrillator"] = 4312,
  ["Clamp"] = 4314,
  ["Ultrasound"] = 4316,
  ["LabKit"] = 4318,
}
local N = {
  { "Anesthetic", "`4The patient wakes up!" },
  { "Anesthetic", "`4The patient screams and flails!" },
  { "Defibrillator", "Status: `4Heart stopped!" },
  { "Anesthetic", "Status: `6Coming to" },
  { "Transfusion", "Pulse: `4" },
  { "Antibiotic", "Temp: `4%d" },
  { "LabKit", "Temp: `4%d" },
  { "Antibiotic", "Temp: `6%d" },
  { "LabKit", "Temp: `6%d" },
  { "Antibiotic", "Temp: `3%d" },
  { "LabKit", "Temp: `3%d" },
  { "Clamp", "Patient is losing blood `4very quickly!" },
  { "Stitches", "Patient is losing blood `4very quickly!" },
  { "Clamp", "Patient is `6losing blood!" },
  { "Stitches", "Patient is `6losing blood!" },
  { "FixIt", "Incisions: `20" },
  { "FixIt", "Incisions: `30" },
  { "Ultrasound", "The patient has not been diagnosed." },
  { "Anesthetic", "Status: `4Awake" },
  { "Splint", "Bones: `[46][^\n]-broken" },
  { "Stitches", "Patient broke his arm." },
  { "Anesthetic", "Status: `3Awake" },
  { "Transfusion", "Pulse: `6" },
  { "Sponge", "`4You can't see what you are doing!" },
  { "Stitches", "tool1296" },
  { "Pins", "Bones: `[46][^\n]-shattered" },
  { "Scalpel", "Bones: `[46][^\n]-shattered" },
  { "Stitches", "Patient broke his leg." },
  { "Clamp", "Patient is losing blood `3slowly." },
  { "Scalpel", nil },
}
local t = {
  ["surgery"] = false,
  ["pathfind"] = false,
  ["tea"] = true,
  ["spice"] = true,
  ["stop_low"] = false,
  ["restock"] = false,
  ["caduceus"] = true,
}
local q, w = "", 0
local b = ""
local function I(J)
  if growtopia and type(growtopia["notify"]) == "function" then
    pcall(growtopia["notify"], tostring(J))
  elseif type(LogToConsole) == "function" then
    LogToConsole("`9[ZS Surg] `w" .. tostring(J))
  end
end
local function E(J)
  if growtopia and type(growtopia["checkInventoryCount"]) == "function" then
    local S, Q = pcall(growtopia["checkInventoryCount"], J)
    if S then
      return tonumber(Q) or 0
    end
  end
  return 0
end
local function Y(J, S)
  if growtopia and type(growtopia["getItemID"]) == "function" then
    local S, Q = pcall(growtopia["getItemID"], J)
    if S and (tonumber(Q) and tonumber(Q) > 0) then
      return tonumber(Q)
    end
  end
  return S
end
local function i(J, S)
  return J:find("tool" .. S, 1, true) ~= nil
end
local function Z(J)
  for S, Q in ipairs(N) do
    local f = l[Q[1]]
    if i(J, f) and (Q[2] == nil or J:find(Q[2])) then
      return Q[1], f
    end
  end
end
local function p(J)
  if type(SendPacketRaw) == "function" then
    local S = pcall(SendPacketRaw, false, { ["type"] = 10, ["value"] = J })
    if S then
      return true
    end
  end
  if type(sendPacketRaw) == "function" then
    local S = pcall(sendPacketRaw, false, { ["type"] = 10, ["value"] = J })
    if S then
      return true
    end
  end
  return false
end
local v = { ["FixIt"] = true }
local function y(J)
  if growtopia and type(growtopia["checkInventoryCount"]) == "function" then
    local S, Q = pcall(growtopia["checkInventoryCount"], J)
    if S and tonumber(Q) then
      return tonumber(Q)
    end
  end
  return nil
end
local c = {}
local function j(J)
  local S = {}
  for Q, f in pairs(l) do
    if not v[Q] then
      local k = y(f)
      if k then
        if k > 0 then
          c[Q] = true
        end
        if k < 10 and (J or c[Q]) then
          S[#S + 1] = Q .. ("=" .. k)
        end
      end
    end
  end
  table["sort"](S)
  return S
end
local O = 32
local X, s, B = 0, 0, 0
local g = 120000
local D = 5116
local m = -g
local F = 1800000
local M = 6912
local function A()
  local J = {}
  local S = (type(GetInventory) == "function" and GetInventory) or (type(getInventory) == "function" and getInventory)
  if S then
    local Q, f = pcall(S)
    if Q and type(f) == "table" then
      for S, Q in pairs(f) do
        local f = tonumber(Q["id"] or Q["itemID"] or Q["itemid"])
        local k = tonumber(Q["amount"] or Q["count"]) or 0
        if f and (f > 0 and k > 0) then
          J[#J + 1] = { ["id"] = f, ["amount"] = k }
        end
      end
    end
  end
  return J
end
local function G(J)
  if growtopia and type(growtopia["getItemName"]) == "function" then
    local S, Q = pcall(growtopia["getItemName"], J)
    if S and Q then
      return tostring(Q)
    end
  end
  return ""
end
local function d(J, S, Q)
  local f = A()
  local k
  for Q, f in ipairs(f) do
    local x = (G(f["id"])):lower()
    for J, S in ipairs(J) do
      if x == S then
        return f["id"], f["amount"]
      end
    end
    if not k and (S and (x ~= "" and x:find(S, 1, true))) then
      k = f
    end
  end
  if k then
    return k["id"], k["amount"]
  end
  for J, S in ipairs(Q) do
    if S and E(S) > 0 then
      return S, E(S)
    end
  end
  return nil, 0
end
local function a()
  local J = E(D)
  if J > 0 then
    return D, J
  end
  return nil, 0
end
local function h()
  local J = E(M)
  if J > 0 then
    return M, J
  end
  return nil, 0
end
local C = -F
local z = 180000
local H = -z
local function W()
  if type(os) == "table" and type(os["time"]) == "function" then
    return os["time"]() * 1000
  end
  return (type(getTime) == "function" and getTime()) or os["clock"]() * 1000
end
local K, T = nil, nil
local function e(J, S)
  K, T = J, S
  local Q = type(GetLocal) == "function" and GetLocal() or nil
  if not Q then
    return false
  end
  local f = { ["x"] = Q["posX"], ["y"] = Q["posY"], ["px"] = J, ["py"] = S, ["type"] = 3, ["value"] = O }
  if type(SendPacketRaw) == "function" and pcall(SendPacketRaw, false, f) then
    return true
  end
  if type(sendPacketRaw) == "function" and pcall(sendPacketRaw, false, f) then
    return true
  end
  return false
end
local U = { "start", "operate", "begin", "perform", "surgery", "surgeon", "patient", "accept", "yes", "ok" }
local r = { "cancel", "close", "back", "no", "exit", "leave" }
local function V(J)
  local S, Q, f = J:match("end_dialog|([^|\n]*)|([^|\n]*)|([^|\n]*)")
  S = S or J:match("end_dialog|([^|]*)|") or ""
  local k
  for J, S in J:gmatch("add_button|([^|]*)|([^|]*)|") do
    local Q = ((J .. (" " .. S))):lower()
    local f = false
    for J, S in ipairs(r) do
      if Q:find(S, 1, true) then
        f = true
      end
    end
    if not f then
      for S, f in ipairs(U) do
        if Q:find(f, 1, true) then
          k = k or J
        end
      end
    end
  end
  if type(LogToConsole) == "function" then
    LogToConsole(
      "`9[ZS Surg] `wSurg-E dialog: name=" .. (S .. (" button=" .. (tostring(k) .. (" ok=" .. tostring(f)))))
    )
    LogToConsole("`9[ZS Surg] `wraw: " .. (J:gsub("\n", " / ")):sub(1, 400))
  end
  if type(SendPacket) ~= "function" then
    return false
  end
  if k then
    pcall(SendPacket, 2, "action|dialog_return\ndialog_name|" .. (S .. ("\nbuttonClicked|" .. k)))
    return true
  end
  if S ~= "" then
    local Q, f = "", {}
    for J, S in J:gmatch("embed_data|([^|\n]*)|([^|\n]*)") do
      Q = Q .. (J .. ("|" .. (S .. "\n")))
      f[J] = true
    end
    if not f["tilex"] and K then
      Q = Q .. ("tilex|" .. (K .. "\n"))
    end
    if not f["tiley"] and T then
      Q = Q .. ("tiley|" .. (T .. "\n"))
    end
    pcall(SendPacket, 2, "action|dialog_return\ndialog_name|" .. (S .. ("\n" .. (Q .. "buttonClicked|\n"))))
    if type(LogToConsole) == "function" then
      LogToConsole("`9[ZS Surg] `wPressed Okay on " .. (S .. (" (" .. (Q:gsub("\n", " ") .. ")"))))
    end
    return true
  end
  return false
end
local function L()
  local J
  if type(GetTiles) == "function" then
    local S, Q = pcall(GetTiles)
    if S and type(Q) == "table" then
      J = Q
    end
  elseif type(getTiles) == "function" then
    local S, Q = pcall(getTiles)
    if S and type(Q) == "table" then
      J = Q
    end
  end
  if not J then
    return nil
  end
  for J, S in pairs(J) do
    if tonumber(S["fg"]) == 4296 then
      return tonumber(S["x"]), tonumber(S["y"])
    end
  end
  return nil
end
local P, JB = false, 0
local SB = { "Legal Briefs", "Legal Brief" }
local function QB()
  for J, S in ipairs(SB) do
    local Q = Y(S, nil)
    if Q and E(Q) > 0 then
      return Q, E(Q)
    end
  end
  if E(3172) > 0 then
    return 3172, E(3172)
  end
  return nil, 0
end
local fB = { "Blingin' Pants", "Blingin Pants", "Blingin\226\128\153 Pants" }
local function kB()
  for J, S in ipairs(fB) do
    local Q = Y(S, nil)
    if Q and E(Q) > 0 then
      return Q, S
    end
  end
  return nil
end
local xB = {
  "medical license is revoked",
  "put the patient to sleep. permanently",
  "you couldn't save them",
  "you abandoned your patient",
  "smashed your surgical robot",
}
local RB = { "malpractice issues", "with your malpractice", "authorities don" }
local function oB(J, S)
  if not t["surgery"] then
    return
  end
  if not (J:find("OnConsoleMessage", 1, true) or J:find("OnTalkBubble", 1, true)) then
    return
  end
  local Q = S:lower()
  if Q:find("_oid:", 1, true) or Q:find("_ct:", 1, true) then
    return
  end
  local f, k
  for J, S in ipairs(RB) do
    if Q:find(S, 1, true) then
      f = S
      k = true
      break
    end
  end
  if not f then
    if s <= 0 or (W() - s) > 60000 then
      return
    end
    for J, S in ipairs(xB) do
      if Q:find(S, 1, true) then
        f = S
        break
      end
    end
  end
  if not f then
    return
  end
  local x = W()
  if P or (x - JB) < 20000 then
    return
  end
  local R, o = QB()
  if type(LogToConsole) == "function" then
    LogToConsole(
      "`9[ZS Surg] `wSurgery failed ("
        .. (tostring(f) .. ("). Legal Briefs id=" .. (tostring(R) .. (" count=" .. tostring(o)))))
    )
  end
  if not R then
    I("Surgery failed but there are no Legal Briefs in inventory.")
    return
  end
  P = true
  JB = x
  ZS_thread(function()
    local J = E(R)
    p(R)
    Sleep(1000)
    if E(R) >= J and J > 1 then
      p(R)
      Sleep(1000)
    end
    local S, Q = kB()
    if S then
      p(S)
      Sleep(800)
      if type(LogToConsole) == "function" then
        LogToConsole(
          "`9[ZS Surg] `wBlingin Pants equipped again (" .. (tostring(Q) .. (", id=" .. (tostring(S) .. ").")))
        )
      end
    else
      I("Blingin Pants not found in inventory - could not put them back on.")
    end
    P = false
    X = 0
    I("Legal Briefs used. Continuing surgery.")
  end)
end
local function uB(J)
  if type(J) ~= "table" then
    return false
  end
  local S = tostring(J["v1"] or J[0] or "")
  local Q = tostring(J["v2"] or J[1] or "")
  oB(S, Q .. (" " .. (tostring(J["v3"] or J[2] or "") .. (" " .. tostring(J["v4"] or J[3] or "")))))
  if not S:find("OnDialogRequest", 1, true) then
    return false
  end
  if t["surgery"] and not Q:find("tool%d%d%d%d") then
    local J = Q:find("perform surgery on this robot", 1, true)
      or Q:find("Anatomical Dummy", 1, true)
      or Q:find("Surg%-E")
    local S = (W() - X) < 3000
    if (J or S) and not Q:find("drop_item", 1, true) then
      return V(Q)
    end
    return false
  end
  if not t["surgery"] then
    return false
  end
  s = W()
  if t["stop_low"] then
    local J = j()
    if #J > 0 then
      t["surgery"] = false
      if type(setValue) == "function" then
        pcall(setValue, "zs_surgery_toggle", false)
      end
      I("AUTO SURG stopped: tool below 10 (" .. (table["concat"](J, ", ") .. ")"))
      return false
    end
  end
  local f = (type(getTime) == "function" and getTime()) or os["clock"]() * 1000
  if Q == q and (f - w) < 120 then
    return true
  end
  local k, x = Z(Q)
  if not x then
    return false
  end
  q, w = Q, f
  c[k] = true
  if type(SendPacket) == "function" then
    local J = pcall(SendPacket, 2, "action|dialog_return\ndialog_name|surgery\nbuttonClicked|tool" .. x)
    if J and type(LogToConsole) == "function" then
      LogToConsole("`9[ZS Auto Surg] `c" .. k)
    end
    return J
  end
  return false
end
function zs_set_surgery_enabled(J)
  t["surgery"] = J and true or false
  t["pathfind"] = t["surgery"]
  if t["surgery"] then
    c = {}
    j()
    m = -g
    C = -F
    H = -z
  end
  I(t["surgery"] and "AUTO SURG V2: ON (tool selection + Surg-E pathfinding)" or "AUTO SURG V2: OFF")
end
function zs_set_surgery_option(J, S)
  if t[J] ~= nil then
    t[J] = S and true or false
    if t[J] and J == "tea" then
      m = -g
    end
    if t[J] and J == "spice" then
      C = -F
    end
    I(J:upper() .. (t[J] and ": ON" or ": OFF"))
  end
end
function zs_surgery_pathfind()
  local J, S = L()
  if not J then
    I("No placed Surg-E found in this world.")
    return
  end
  if type(FindPath) == "function" then
    FindPath(J, S)
    I("Pathfinding directly to Surg-E at " .. (J .. ("," .. S)))
  else
    I("FindPath API unavailable.")
  end
end
function zs_surgery_check_tools()
  local J = j(true)
  if #J == 0 then
    I("All surgery tools are at least 10.")
  else
    I("Below 10: " .. table["concat"](J, ", "))
  end
end
function zs_surgery_convert_caduceus()
  local J = Y("Caduceus", 4298)
  local S = E(J)
  if S < 100 then
    I("Need 100 Caduceus; inventory has " .. (S .. "."))
    return
  end
  if p(J) then
    I("Caduceus conversion requested (100 -> 1 Golden Caduceus).")
  else
    I("Could not send item activation packet.")
  end
end
function zs_surgery_use_tea()
  local J = a()
  if not J then
    I("No Tea in inventory.")
    return
  end
  if p(J) then
    I("Tea use requested.")
  else
    I("Item activation API unavailable.")
  end
end
function zs_surgery_use_spice()
  local J = h()
  if not J then
    I("No Skill Spice in inventory.")
    return
  end
  if p(J) then
    I("Skill Spice use requested.")
  else
    I("Item activation API unavailable.")
  end
end
function zs_surgery_place_surge()
  local J = type(GetLocal) == "function" and GetLocal() or nil
  if not J then
    I("Player data unavailable.")
    return
  end
  local S = Y("Surg-E", 4296)
  if E(S) < 1 then
    I("No Surg-E in inventory.")
    return
  end
  local Q, f = math["floor"]((J["posX"] or 0) / 32), math["floor"]((J["posY"] or 0) / 32)
  local k = type(GetTile) == "function" and GetTile(Q, f) or nil
  if k and tonumber(k["fg"] or 0) ~= 0 then
    I("Your current tile is occupied. Move to an empty tile and try again.")
    return
  end
  if type(SendPacketRaw) == "function" then
    local k = pcall(
      SendPacketRaw,
      false,
      { ["type"] = 3, ["value"] = S, ["px"] = Q, ["py"] = f, ["x"] = J["posX"], ["y"] = J["posY"] }
    )
    I(k and "Surg-E placement request sent." or "Could not send placement packet.")
  else
    I("SendPacketRaw API unavailable.")
  end
end
function zs_surgery_legal_brief_help()
  local J = Y("Legal Briefs", 3172)
  if E(J) < 1 then
    I("No Legal Briefs in inventory.")
    return
  end
  I(
    "Legal Briefs remove Malpractice when equipped. Equip them manually from inventory; auto-equipping is not enabled because the launcher docs do not specify a safe equip call."
  )
end
local nB = 200
local lB = 180000
local NB = -lB
local tB = false
local function qB()
  if type(GetWorldName) == "function" then
    local J, S = pcall(GetWorldName)
    if J and S then
      return tostring(S)
    end
  end
  return nil
end
local function wB(J, S)
  local Q = 0
  while Q < S do
    local S = qB()
    if S and S:upper() == J:upper() then
      return true
    end
    Sleep(100)
    Q = Q + 100
  end
  local f = qB()
  return f ~= nil and f:upper() == J:upper()
end
local function bB()
  local J
  if type(GetObjects) == "function" then
    local S, Q = pcall(GetObjects)
    if S and type(Q) == "table" then
      J = Q
    end
  end
  if not J and type(GetObjectList) == "function" then
    local S, Q = pcall(GetObjectList)
    if S and type(Q) == "table" then
      J = Q
    end
  end
  return J or {}
end
local function IB(J)
  local S = {}
  for Q, f in pairs(bB()) do
    local k = tonumber(f and (f["itemid"] or f["itemID"] or f["item_id"] or f["id"]))
    local x = f and (f["pos"] or f["position"])
    local R = tonumber((x and (x["x"] or x["posX"])) or (f and (f["x"] or f["posX"])))
    local o = tonumber((x and (x["y"] or x["posY"])) or (f and (f["y"] or f["posY"])))
    if k and (J[k] and (R and o)) then
      S[#S + 1] = { ["id"] = k, ["x"] = math["floor"](R / 32), ["y"] = math["floor"](o / 32) }
    end
  end
  return S
end
local EB = 75
local YB = 110
local function iB(J, S)
  local Q = type(GetLocal) == "function" and GetLocal() or nil
  if not Q then
    return false
  end
  local f = (Q["posX"] or (Q["pos"] and Q["pos"]["x"]) or 0) / 32
  local k = (Q["posY"] or (Q["pos"] and Q["pos"]["y"]) or 0) / 32
  return math["abs"](f - J) <= 1 and math["abs"](k - S) <= 1
end
local function ZB(J, S)
  local Q, f = IB(J), 0
  while #Q == 0 and f < 3000 do
    Sleep(120)
    f = f + 120
    Q = IB(J)
  end
  if #Q == 0 or type(FindPath) ~= "function" then
    return
  end
  local k = os["clock"]()
  local x = type(GetLocal) == "function" and GetLocal() or nil
  local R = x and math["floor"]((x["posX"] or 0) / 32) or 0
  local o = x and math["floor"]((x["posY"] or 0) / 32) or 0
  for f = 1, 2, 1 do
    while #Q > 0 and (os["clock"]() - k) < 30 do
      for J = #Q, 1, -1 do
        if E(Q[J]["id"]) >= S then
          table["remove"](Q, J)
        end
      end
      local J, f
      for S = 1, #Q, 1 do
        local k = math["abs"](Q[S]["x"] - R) + math["abs"](Q[S]["y"] - o)
        if not f or k < f then
          J, f = S, k
        end
      end
      if not J then
        break
      end
      local k = table["remove"](Q, J)
      local x = E(k["id"])
      if k["x"] ~= R or k["y"] ~= o then
        FindPath(k["x"], k["y"])
      end
      R, o = k["x"], k["y"]
      Sleep(EB)
      local u = 0
      while not iB(k["x"], k["y"]) and u < 1500 do
        Sleep(50)
        u = u + 50
      end
      local n = 0
      while n < (YB + 140) and E(k["id"]) <= x do
        Sleep(25)
        n = n + 25
      end
    end
    if f == 1 then
      Q = IB(J)
    end
  end
end
local function pB(J)
  local S, Q = {}, {}
  for J in (tostring(J or "")):gmatch("[^,;%s]+") do
    local f = J:upper()
    if not Q[f] then
      Q[f] = true
      S[#S + 1] = f
    end
  end
  return S
end
local function vB()
  local J = {}
  for S, Q in pairs(l) do
    if not v[S] then
      J[Q] = true
    end
  end
  return J
end
local yB = 4296
local function cB(J, S)
  pcall(EditToggle, "ModFly", true)
  ZB(J, S)
  pcall(EditToggle, "ModFly", false)
end
local function jB(J, S, Q, f)
  if not growtopia or type(growtopia["warpTo"]) ~= "function" then
    I("Cannot go to storage: warp API unavailable.")
    return false
  end
  local k = qB()
  if not k or k == "" or k == "EXIT" then
    return false
  end
  for J, k in ipairs(J) do
    if not t["surgery"] then
      break
    end
    local x = qB()
    local R = x ~= nil and x:upper() == k
    if not R then
      growtopia["warpTo"](k)
      R = wB(k, 15000)
      if not R then
        I("Could not enter storage world " .. (k .. ", trying the next one."))
      end
    end
    if R then
      Sleep(150)
      cB(Q, f)
      if S() then
        break
      end
    end
  end
  local x = qB()
  if not (x and x:upper() == k:upper()) then
    growtopia["warpTo"](k)
    if not wB(k, 15000) then
      I("Could not return to " .. k)
      return false
    end
  end
  Sleep(300)
  return true
end
local function OB()
  local J = type(getValue) == "function" and getValue(2, "zs_surgery_storage_world") or ""
  return pB(J)
end
local function XB()
  if tB then
    return
  end
  local J = OB()
  if #J == 0 then
    return
  end
  local S = j()
  if #S == 0 then
    return
  end
  if (W() - NB) < lB then
    return
  end
  Sleep(1000)
  if not t["surgery"] or (W() - s) <= 6000 then
    return
  end
  S = j()
  if #S == 0 then
    return
  end
  NB = W()
  local Q = qB()
  if not Q or Q == "" or Q == "EXIT" then
    return
  end
  tB = true
  I("Tools low (" .. (table["concat"](S, ", ") .. ("). Storage worlds: " .. table["concat"](J, ", "))))
  local f = jB(J, function()
    return #j() == 0
  end, vB(), nB)
  if f then
    local J = j()
    if #J == 0 then
      I("Tools restocked. Continuing surgery.")
    else
      I("Tools taken. Still below 10: " .. table["concat"](J, ", "))
    end
  end
  tB = false
end
local sB = 200
local BB = 110
local gB = false
local function DB()
  local J
  if type(GetTiles) == "function" then
    local S, Q = pcall(GetTiles)
    if S and type(Q) == "table" then
      J = Q
    end
  elseif type(getTiles) == "function" then
    local S, Q = pcall(getTiles)
    if S and type(Q) == "table" then
      J = Q
    end
  end
  return J
end
local function mB()
  local J = DB()
  if not J or next(J) == nil then
    return nil
  end
  local S = 0
  for J, Q in pairs(J) do
    if tonumber(Q["fg"]) == yB then
      S = S + 1
    end
  end
  return S
end
local function FB(J, S)
  if type(GetTile) ~= "function" then
    return nil
  end
  local Q, f = pcall(GetTile, J, S)
  if Q and f then
    return tonumber(f["fg"]) or 0
  end
  return nil
end
local function MB(J, S, Q)
  local f = type(GetLocal) == "function" and GetLocal() or nil
  if not f or type(SendPacketRaw) ~= "function" then
    return false
  end
  return pcall(
    SendPacketRaw,
    false,
    { ["x"] = f["posX"], ["y"] = f["posY"], ["px"] = S, ["py"] = Q, ["type"] = 3, ["value"] = J }
  )
end
local function AB(J)
  local S = DB()
  if not S then
    return {}
  end
  local Q = {}
  for J, S in pairs(S) do
    local f, k = tonumber(S["x"]), tonumber(S["y"])
    if f and k then
      f, k = math["floor"](f), math["floor"](k)
      Q[k] = Q[k] or {}
      Q[k][f] = tonumber(S["fg"]) or 0
    end
  end
  local f = type(GetLocal) == "function" and GetLocal() or nil
  local k = f and math["floor"]((f["posY"] or 0) / 32) or 0
  local x = {}
  for J, S in pairs(Q) do
    local f = Q[J + 1]
    if f then
      for S, Q in pairs(S) do
        local k = f[S]
        if Q == 0 and (k and (k > 0 and (k ~= 6 and k % 2 == 0))) then
          x[#x + 1] = { ["x"] = S, ["y"] = J }
        end
      end
    end
  end
  table["sort"](x, function(J, S)
    local Q, f = math["abs"](J["y"] - k), math["abs"](S["y"] - k)
    if Q ~= f then
      return Q < f
    end
    if J["y"] ~= S["y"] then
      return J["y"] < S["y"]
    end
    return J["x"] < S["x"]
  end)
  local R = {}
  for J = 1, math["min"](#x, J), 1 do
    R[J] = x[J]
  end
  return R
end
local function GB(J)
  local S = AB(J)
  if #S == 0 then
    I("No free tiles to place Surg-E.")
    return 0
  end
  local Q, f, k = 0, os["clock"](), 1
  while k <= #S and (t["surgery"] and (os["clock"]() - f) < 180) do
    if E(yB) <= 0 then
      break
    end
    local J = S[k]
    local f = { J }
    local x = k + 1
    while x <= #S and (#f < 3 and (S[x]["y"] == J["y"] and S[x]["x"] <= J["x"] + 2)) do
      f[#f + 1] = S[x]
      x = x + 1
    end
    k = x
    if not iB(J["x"] + 1, J["y"]) then
      if type(FindPath) == "function" then
        FindPath(J["x"] + 1, J["y"])
      end
      Sleep(EB)
    end
    for J, S in ipairs(f) do
      MB(yB, S["x"], S["y"])
      Sleep(BB)
    end
    Sleep(BB)
    for J, S in ipairs(f) do
      local f = FB(S["x"], S["y"])
      if f == yB then
        Q = Q + 1
      elseif E(yB) > 0 then
        MB(yB, S["x"], S["y"])
        Sleep(BB)
        if FB(S["x"], S["y"]) == yB then
          Q = Q + 1
        end
      end
    end
  end
  return Q
end
local function dB()
  if gB or tB then
    return
  end
  local J = mB()
  if J == nil or J > 0 then
    return
  end
  if (W() - H) < z then
    return
  end
  Sleep(800)
  J = mB()
  if J == nil or J > 0 then
    return
  end
  gB = true
  pcall(EditToggle, "ModFly", true)
  local S = E(yB)
  if S <= 0 then
    local J = OB()
    if #J > 0 then
      I("No Surg-E in the world or inventory. Fetching from storage: " .. table["concat"](J, ", "))
      jB(J, function()
        return E(yB) >= sB
      end, { [yB] = true }, sB)
      local Q = 0
      while mB() == nil and Q < 3000 do
        Sleep(150)
        Q = Q + 150
      end
      S = E(yB)
    else
      I("No Surg-E in the world or inventory, and no Surgery storage world is set.")
    end
  end
  if S > 0 and t["surgery"] then
    local J = GB(math["min"](S, sB))
    I("Placed " .. (J .. " Surg-E. Continuing surgery."))
    if J <= 0 then
      H = W()
    end
  elseif S <= 0 then
    I("No Surg-E found anywhere. Will retry in 3 minutes.")
    H = W()
  end
  pcall(EditToggle, "ModFly", false)
  X = 0
  gB = false
end
local function aB(J, S, Q)
  t[J] = false
  if type(setValue) == "function" then
    pcall(setValue, S, false)
  end
  I(Q .. (" ran out: AUTO " .. (Q:upper() .. " turned OFF.")))
end
local function hB()
  local J = W()
  if (J - m) < g then
    return
  end
  m = J
  local S, Q = a()
  if S and Q > 0 then
    D = S
    local J = p(S)
    Sleep(1200)
    local f = E(S)
    if type(LogToConsole) == "function" then
      LogToConsole(
        "`9[ZS Surg] `wTea used. id=" .. (
            tostring(S) .. (" sent=" .. (tostring(J) .. (" tea " .. (Q .. (" -> " .. f)))))
          )
      )
    end
  else
    I("No Tea found in inventory - surgery continues, will retry in 2 min.")
  end
end
local function CB()
  local J = W()
  if (J - C) < F then
    return
  end
  C = J
  local S, Q = h()
  if S and Q > 0 then
    M = S
    local J = p(S)
    Sleep(1200)
    local f = E(S)
    if type(LogToConsole) == "function" then
      LogToConsole(
        "`9[ZS Surg] `wSkill Spice used. id=" .. (
            tostring(S) .. (" sent=" .. (tostring(J) .. (" spice " .. (Q .. (" -> " .. f)))))
          )
      )
    end
  else
    I("No Skill Spice found in inventory - surgery continues, will retry in 30 min.")
  end
end
local zB = 4298
local HB = 0
local function WB()
  local J = W()
  if (J - HB) < 5000 then
    return
  end
  local S = E(zB)
  if S < 100 then
    return
  end
  HB = J
  local Q = p(zB)
  Sleep(1500)
  local f = E(zB)
  if type(LogToConsole) == "function" then
    LogToConsole("`9[ZS Surg] `wCaduceus converted. sent=" .. (tostring(Q) .. (" caduceus " .. (S .. (" -> " .. f)))))
  end
  I("100 Caduceus -> Golden Caduceus.")
end
k(uB, "onvariant")
local KB = false
local function TB()
  if KB then
    return
  end
  KB = true
  ZS_thread(function()
    while true do
      if t["surgery"] and (t["tea"] and not tB) then
        hB()
      end
      if t["surgery"] and (t["spice"] and not tB) then
        CB()
      end
      if t["surgery"] and (t["caduceus"] and not tB) then
        WB()
      end
      if t["surgery"] and (t["restock"] and (not tB and (W() - s) > 6000)) then
        XB()
      end
      if t["surgery"] and (t["pathfind"] and (not tB and (W() - s) > 6000)) then
        dB()
      end
      if t["pathfind"] and (not tB and not gB) then
        local J, S = L()
        if J and type(FindPath) == "function" then
          local Q = type(GetLocal) == "function" and GetLocal() or nil
          if Q then
            local f, k = math["floor"]((Q["posX"] or 0) / 32), math["floor"]((Q["posY"] or 0) / 32)
            if math["abs"](f - J) > 1 or math["abs"](k - S) > 1 then
              if (W() - (B or 0)) > 2500 then
                B = W()
                FindPath(J, S)
              end
            else
              local Q = W()
              if (Q - s) > 6000 and (Q - X) > 3000 then
                X = Q
                e(J, S)
              end
            end
          end
        end
      end
      Sleep(1000)
    end
  end)
end
TB()
local eB = UserInterface["new"]("ZS AUTO SURG V2", "Healing")
eB:addLabelApp("* ZS AUTO SURGERY V2 *", "Healing")
eB:addTooltip(
  "AUTO SURG V2",
  "Start a surgery and turn AUTO SURG V2 ON. The script selects the required tool for each step.\n\nAUTO SURG-E places a Surg-E when needed.\n\nAUTO RESTOCK collects dropped surgery tools from your storage worlds when a tool count falls below 10, then returns to your world. Separate multiple worlds with commas.",
  "Info",
  true
)
eB:addDivider()
eB:addToggle("AUTO SURG V2", false, "zs_surgery_toggle", false)
eB:addToggle("AUTO TEA", true, "zs_surgery_tea_toggle", false)
eB:addToggle("AUTO SKILL SPICE", true, "zs_surgery_spice_toggle", false)
eB:addToggle("AUTO GOLDEN CADUCEUS", true, "zs_surgery_caduceus_toggle", false)
eB:addDivider()
ZS_label(eB, "SURGERY TOOLS - Storage world")
eB:addToggle("AUTO RESTOCK", false, "zs_surgery_restock_toggle", false)
eB:addInputString(
  "Surgery storage world(s)",
  "",
  "Surgery storage world(s)",
  "One or MORE worlds separated by commas (WORLD1,WORLD2). When a tool is below 10 it visits them in order until all tools are restocked, then comes back.",
  "World",
  "zs_surgery_storage_world"
)
u(eB:generateJSON(), "ZS")
k(function(J, S, f)
  if S == "zs_surgery_toggle" then
    if type(zs_set_surgery_enabled) == "function" then
      zs_set_surgery_enabled(f)
    else
      Q("Auto Surg module is not available.")
    end
  elseif S == "zs_surgery_path_button" then
    if type(zs_surgery_pathfind) == "function" then
      zs_surgery_pathfind()
    end
  elseif S == "zs_surgery_place_button" then
    if type(zs_surgery_place_surge) == "function" then
      zs_surgery_place_surge()
    end
  elseif S == "zs_surgery_tea_button" then
    if type(zs_surgery_use_tea) == "function" then
      zs_surgery_use_tea()
    end
  elseif S == "zs_surgery_spice_button" then
    if type(zs_surgery_use_spice) == "function" then
      zs_surgery_use_spice()
    end
  elseif S == "zs_surgery_legal_button" then
    if type(zs_surgery_legal_brief_help) == "function" then
      zs_surgery_legal_brief_help()
    end
  elseif S == "zs_surgery_check_button" then
    if type(zs_surgery_check_tools) == "function" then
      zs_surgery_check_tools()
    end
  elseif S == "zs_surgery_convert_button" then
    if type(zs_surgery_convert_caduceus) == "function" then
      zs_surgery_convert_caduceus()
    end
  elseif S == "zs_surgery_stop_button" then
    if type(zs_set_surgery_enabled) == "function" then
      zs_set_surgery_enabled(false)
    end
    if type(zs_set_surgery_option) == "function" then
      zs_set_surgery_option("pathfind", false)
      zs_set_surgery_option("tea", false)
      zs_set_surgery_option("spice", false)
      zs_set_surgery_option("restock", false)
    end
    if type(setValue) == "function" then
      pcall(setValue, "zs_surgery_toggle", false)
    end
    Q("All Surgery automation stopped.")
  elseif S == "zs_surgery_restock_toggle" then
    if type(zs_set_surgery_option) == "function" then
      zs_set_surgery_option("restock", f)
    end
  elseif S == "zs_surgery_low_toggle" then
    if type(zs_set_surgery_option) == "function" then
      zs_set_surgery_option("stop_low", f)
    end
  elseif S == "zs_surgery_path_toggle" then
    if type(zs_set_surgery_option) == "function" then
      zs_set_surgery_option("pathfind", f)
    end
  elseif S == "zs_surgery_tea_toggle" then
    if type(zs_set_surgery_option) == "function" then
      zs_set_surgery_option("tea", f)
    end
  elseif S == "zs_surgery_spice_toggle" then
    if type(zs_set_surgery_option) == "function" then
      zs_set_surgery_option("spice", f)
    end
  elseif S == "zs_surgery_caduceus_toggle" then
    if type(zs_set_surgery_option) == "function" then
      zs_set_surgery_option("caduceus", f)
    end
  end
end, "onValue")
if type(applyHook) == "function" then
  pcall(applyHook)
end
