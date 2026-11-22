ZS_LABEL_WIDTH = ZS_LABEL_WIDTH or 30
if not ZS_HUB then
  ZS_HUB = { ["native"] = addHook, ["callbacks"] = {}, ["installed"] = {} }
  local T = {
    ["onvalue"] = "onValue",
    ["ondrawimgui"] = "onDrawImGui",
    ["onvariant"] = "onVariant",
    ["ondialog"] = "onDialog",
    ["onsendpacket"] = "onSendPacket",
    ["onsendpacketraw"] = "onSendPacketRaw",
  }
  local t = {
    ["onValue"] = "onvalue",
    ["onDrawImGui"] = "ondrawimgui",
    ["OnVariant"] = "onvariant",
    ["OnDialog"] = "ondialog",
    ["OnSendPacket"] = "onsendpacket",
    ["OnSendPacketRaw"] = "onsendpacketraw",
  }
  local function A(t)
    if ZS_HUB["installed"][t] then
      return
    end
    ZS_HUB["installed"][t] = true
    local A = ZS_HUB["callbacks"][t]
    ZS_HUB["native"](function(...)
      local T = false
      for W = 1, #A, 1 do
        local l, a = pcall(A[W], ...)
        if not l then
          local T = "Hook error (" .. (t .. ("): " .. tostring(a)))
          if growtopia and type(growtopia["notify"]) == "function" then
            pcall(growtopia["notify"], T)
          else
            print(T)
          end
        elseif a == true then
          T = true
        end
      end
      return T
    end, T[t] or t)
  end
  function addHook(T, W)
    if type(T) ~= "function" then
      return
    end
    W = W or "onvalue"
    W = t[W] or (tostring(W)):lower()
    if not ZS_HUB["callbacks"][W] then
      ZS_HUB["callbacks"][W] = {}
    end
    table["insert"](ZS_HUB["callbacks"][W], T)
    A(W)
  end
end
if not ZS_thread then
  function ZS_thread(T)
    runThread(T)
  end
end
if not ZS_label then
  function ZS_label(T, t, ...)
    t = tostring(t == nil and "" or t)
    local A = ZS_LABEL_WIDTH
    local function W(T)
      if utf8 and utf8["len"] then
        return utf8["len"](T) or #T
      end
      return #T
    end
    local l, a = {}, ""
    for T in t:gmatch("%S+") do
      if a == "" then
        a = T
      elseif (W(a) + 1) + W(T) <= A then
        a = a .. (" " .. T)
      else
        l[#l + 1] = a
        a = T
      end
    end
    if a ~= "" then
      l[#l + 1] = a
    end
    if #l == 0 then
      l[1] = t
    end
    for t, A in ipairs(l) do
      T:addLabel(A, ...)
    end
  end
end
if not ZS_CATEGORY_ADDED then
  ZS_CATEGORY_ADDED = true
  if type(addCategory) == "function" then
    pcall(addCategory, "ZS", "Shield")
  end
end
local T = { ["tag"] = "k08", ["life"] = "ZSA-STAR", ["unlocked"] = false, ["entered"] = "", ["n"] = 0 }
local function t(T)
  if growtopia and type(growtopia["notify"]) == "function" then
    pcall(growtopia["notify"], tostring(T))
  else
    print("[ZS] " .. tostring(T))
  end
end
local A = t
local W = addHook
local function l(t, A)
  if type(t) ~= "function" then
    return
  end
  return W(function(...)
    if not T["unlocked"] then
      return false
    end
    return t(...)
  end, A)
end
local function a(T)
  local t = tostring(T)
  local A, W = t:find('"menu"%s*:%s*%[')
  if not A then
    return nil
  end
  local l, a, Z, y = 1, W + 1, false, false
  while a <= #t do
    local T = t:sub(a, a)
    if Z then
      if y then
        y = false
      elseif T == "\\" then
        y = true
      elseif T == '"' then
        Z = false
      end
    elseif T == '"' then
      Z = true
    elseif T == "[" then
      l = l + 1
    elseif T == "]" then
      l = l - 1
      if l == 0 then
        return t:sub(W + 1, a - 1)
      end
    end
    a = a + 1
  end
end
local function Z()
  T["n"] = T["n"] + 1
  local t = UserInterface["new"]("ZS ACCESS", "Lock")
  t:addLabelApp("* ACCESS KEY *", "Lock")
  ZS_label(t, "Enter your key. You can look around, but everything works only after unlock.")
  t:addInputString("Enter Key", "", "Enter Key", "Your key", "Key", "zskey_" .. (T["tag"] .. ("_" .. T["n"])))
  t:addButton("UNLOCK", "zsunl_" .. (T["tag"] .. ("_" .. T["n"])))
  t:addDivider()
  return t
end
local y = addIntoModule
local function w(t, A, ...)
  if type(t) == "string" and not t:find("zskey_" .. (T["tag"] .. "_"), 1, true) then
    local T, W = pcall(function()
      local T = Z()
      local A = a(T:generateJSON())
      local W, l = t:find('"menu"%s*:%s*%[')
      if not (A and W) then
        return nil
      end
      local y = t:sub(l + 1)
      local w = y:match("^%s*%]") and "" or ","
      return t:sub(1, l) .. (A .. (w .. y))
    end)
    if T and W then
      t = W
    else
      pcall(function()
        y((Z()):generateJSON(), A)
      end)
    end
  end
  return y(t, A, ...)
end
local function M(...)
  local A = select("#", ...)
  local W = { ... }
  local l, a = "zskey_" .. (T["tag"] .. "_"), "zsunl_" .. (T["tag"] .. "_")
  local function Z(T)
    if type(T) ~= "string" then
      return nil
    end
    if T:sub(1, #l) == l then
      return "key"
    end
    if T:sub(1, #a) == a then
      return "btn"
    end
  end
  local y, w
  local function M(T, t)
    if y or t > 2 then
      return
    end
    if type(T) == "string" then
      y = Z(T)
    elseif type(T) == "table" then
      for A, W in pairs(T) do
        if Z(W) then
          y = Z(W)
          w = T["value"] or T["text"] or T["v2"]
          return
        end
        if Z(A) then
          y = Z(A)
          w = W
          return
        end
        if type(W) == "table" then
          M(W, t + 1)
        end
      end
    end
  end
  for T = 1, A, 1 do
    M(W[T], 0)
    if y then
      if w == nil then
        w = W[T + 1]
      end
      break
    end
  end
  if y == "key" then
    T["entered"] = tostring(w or "")
    return true
  elseif y == "btn" then
    local A = ((T["entered"]:upper()):gsub("%s+", ""))
    if A == T["life"]:upper() then
      T["unlocked"] = true
      t("Key accepted. Unlocked!")
    else
      t("Invalid key.")
    end
    return true
  end
  return false
end
W(M, "onvalue")
local d = {
  ["HyperShields"] = 6518,
  ["AI Brain"] = 6520,
  ["Galactibolt"] = 6522,
  ["Space Meds"] = 6524,
  ["Teleporter Charge"] = 6526,
  ["Gigablaster"] = 6528,
  ["Quadriscanner"] = 6530,
  ["Tactical Drone"] = 6532,
  ["Stellar Documents"] = 6534,
  ["Star Supplies"] = 6536,
  ["Cyborg Diplomat"] = 6538,
  ["Growton Torpedo"] = 6540,
}
local Q = {
  { "Set a Course", { "Tactical Drone", "Stellar Documents" } },
  { "Parasite Hunt", { "Tactical Drone", "Teleporter Charge", "Quadriscanner", "Gigablaster", "Teleporter Charge" } },
  { "Warp Data", { "Tactical Drone", "Teleporter Charge", "Quadriscanner", "Teleporter Charge", "Stellar Documents" } },
  { "Rebel Attack", { "Tactical Drone", "HyperShields", "Growton Torpedo", "Growton Torpedo" } },
  { "A Challenge", { "Tactical Drone", "HyperShields", "HyperShields", "HyperShields", "HyperShields" } },
  {
    "Outpost Attack",
    { "Tactical Drone", "Growton Torpedo", "Cyborg Diplomat", "Teleporter Charge", "Stellar Documents", "Teleporter Charge" },
  },
  {
    "One Angry Ship",
    { "Tactical Drone", "Growton Torpedo", "Cyborg Diplomat", "Teleporter Charge", "Stellar Documents", "Teleporter Charge" },
  },
  { "Solar Impact", { "HyperShields", "Galactibolt", "Space Meds", "AI Brain", "Tactical Drone" } },
  { "Salvage Run", { "Tactical Drone", "Teleporter Charge", "Quadriscanner", "Teleporter Charge" } },
  { "Windy Days", { "Tactical Drone", "Teleporter Charge", "Quadriscanner", "Teleporter Charge" } },
  {
    "Who's There",
    {
      "Tactical Drone",
      "Teleporter Charge",
      "Quadriscanner",
      "AI Brain",
      "Quadriscanner",
      "Gigablaster",
      "Teleporter Charge",
    },
  },
  {
    "She's Gonna Blow",
    {
      "Tactical Drone",
      "Teleporter Charge",
      "Quadriscanner",
      "AI Brain",
      "Quadriscanner",
      "Gigablaster",
      "Teleporter Charge",
    },
  },
  {
    "Doing The Right Thing",
    { "Tactical Drone", "HyperShields", "Teleporter Charge", "Gigablaster", "Quadriscanner", "Teleporter Charge" },
  },
  {
    "Secret Stash",
    { "Tactical Drone", "HyperShields", "Teleporter Charge", "Gigablaster", "Quadriscanner", "Teleporter Charge" },
  },
  {
    "Putting Down Roots",
    { "Tactical Drone", "Teleporter Charge", "Quadriscanner", "Cyborg Diplomat", "Stellar Documents", "Star Supplies" },
  },
  { "Daydreamer", { "Tactical Drone", "Teleporter Charge", "Cyborg Diplomat", "Gigablaster" } },
  {
    "A Tasty Bite",
    { "Tactical Drone", "Cyborg Diplomat", "Galactibolt", "Quadriscanner", "AI Brain", "Galactibolt", "Growton Torpedo" },
  },
  { "Rescue", { "Tactical Drone", "Teleporter Charge", "Cyborg Diplomat", "Space Meds", "Stellar Documents" } },
  {
    "Planet Of Echoes",
    { "Tactical Drone", "Cyborg Diplomat", "Teleporter Charge", "Quadriscanner", "Gigablaster", "Teleporter Charge" },
  },
  {
    "Prevent War",
    {
      "HyperShields",
      "Tactical Drone",
      "Cyborg Diplomat",
      "Teleporter Charge",
      "Stellar Documents",
      "Galactibolt",
      "Star Supplies",
    },
  },
  { "Stuck In The Middle", { "Tactical Drone", "HyperShields", "AI Brain", "Cyborg Diplomat", "AI Brain" } },
  { "Blackout", { "Galactibolt", "Tactical Drone", "HyperShields", "Growton Torpedo", "Growton Torpedo", "Galactibolt" } },
  { "Lonely Little Droid", { "Cyborg Diplomat", "Teleporter Charge", "Star Supplies", "Quadriscanner", "Gigablaster" } },
  {
    "Doctor In The House",
    { "Tactical Drone", "Teleporter Charge", "Cyborg Diplomat", "Space Meds", "Gigablaster", "Cyborg Diplomat" },
  },
  {
    "Cleanup",
    {
      "Tactical Drone",
      "HyperShields",
      "Growton Torpedo",
      "HyperShields",
      "Stellar Documents",
      "Teleporter Charge",
      "Stellar Documents",
    },
  },
  { "Grumpy Ambassador", { "Cyborg Diplomat" } },
  { "communicators burst", { "Cyborg Diplomat" } },
  { "hacking our computer", { "AI Brain" } },
  { "popups when they hail", { "AI Brain" } },
  { "reactor's leaking radiation", { "Space Meds" } },
  { "Misfiled documents", { "Stellar Documents" } },
  { "bureaucrat", { "Stellar Documents" } },
  { "pirate ships swoops", { "Growton Torpedo" } },
  { "test fire of the Torpedoes", { "Growton Torpedo" } },
  { "Silicoid Worms", { "HyperShields" } },
  { "Shield Generator", { "HyperShields" } },
  { "Space Debris", { "HyperShields" } },
  { "Rabid space dogs", { "Gigablaster" } },
  { "Disloyal crew", { "Gigablaster" } },
  { "Space snakes attack", { "Gigablaster" } },
  { "cargo door isn't opening", { "Galactibolt" } },
  { "left engine is almost hanging", { "Galactibolt" } },
  { "lights throughout the ship", { "Galactibolt" } },
  { "plumbing isn't working", { "Galactibolt" } },
  { "oxygen leak", { "Galactibolt" } },
  { "starvation crisis", { "Star Supplies" } },
}
local N, q, X = false, false, -180000
local G, R = 200, 180000
local function v(T)
  if growtopia and type(growtopia["notify"]) == "function" then
    pcall(growtopia["notify"], T)
  elseif type(LogToConsole) == "function" then
    LogToConsole("`9[ZS Startopia] `w" .. tostring(T))
  end
end
local function H(T)
  if growtopia and type(growtopia["checkInventoryCount"]) == "function" then
    local t, A = pcall(growtopia["checkInventoryCount"], T)
    if t then
      return tonumber(A) or 0
    end
  end
  return 0
end
local function D()
  if type(GetWorldName) == "function" then
    local T, t = pcall(GetWorldName)
    if T and t then
      return tostring(t)
    end
  end
end
local function o(T)
  for t = 1, 150, 1 do
    if ((D() or "")):upper() == T:upper() then
      return true
    end
    Sleep(100)
  end
  return ((D() or "")):upper() == T:upper()
end
local function x()
  local T = type(getValue) == "function" and getValue(2, "zs_startopia_storage_world") or ""
  local t, A = {}, {}
  for T in (tostring(T or "")):gmatch("[^,;%s]+") do
    local W = T:upper()
    if not A[W] then
      A[W] = true
      t[#t + 1] = W
    end
  end
  return t
end
local function Y()
  if type(GetObjects) == "function" then
    local T, t = pcall(GetObjects)
    if T and type(t) == "table" then
      return t
    end
  end
  if type(GetObjectList) == "function" then
    local T, t = pcall(GetObjectList)
    if T and type(t) == "table" then
      return t
    end
  end
  return {}
end
local function g()
  local T = {}
  for t, A in pairs(d) do
    T[A] = true
  end
  local function t()
    local t = {}
    for A, W in pairs(Y()) do
      local l = tonumber(W and (W["itemid"] or W["itemID"] or W["item_id"] or W["id"]))
      local a = W and (W["pos"] or W["position"])
      local Z = tonumber((a and (a["x"] or a["posX"])) or (W and (W["x"] or W["posX"])))
      local y = tonumber((a and (a["y"] or a["posY"])) or (W and (W["y"] or W["posY"])))
      if l and (T[l] and (Z and (y and H(l) < G))) then
        t[#t + 1] = { ["id"] = l, ["x"] = math["floor"](Z / 32), ["y"] = math["floor"](y / 32) }
      end
    end
    return t
  end
  local A = t()
  local W = 0
  while #A == 0 and W < 2500 do
    Sleep(100)
    W = W + 100
    A = t()
  end
  if type(FindPath) ~= "function" then
    return
  end
  pcall(EditToggle, "ModFly", true)
  local l = os["time"]()
  while #A > 0 and os["time"]() - l < 30 do
    local T, W
    local l = type(GetLocal) == "function" and GetLocal() or nil
    local a = l and math["floor"]((l["posX"] or (l["pos"] and l["pos"]["x"]) or 0) / 32) or 0
    local Z = l and math["floor"]((l["posY"] or (l["pos"] and l["pos"]["y"]) or 0) / 32) or 0
    for t, l in ipairs(A) do
      if H(l["id"]) >= G then
        A[t] = false
      else
        local A = math["abs"](l["x"] - a) + math["abs"](l["y"] - Z)
        if not W or A < W then
          T, W = t, A
        end
      end
    end
    if not T then
      break
    end
    local y = A[T]
    A[T] = false
    local w = H(y["id"])
    FindPath(y["x"], y["y"])
    Sleep(120)
    local M = 0
    while M < 900 and H(y["id"]) <= w do
      Sleep(50)
      M = M + 50
    end
    A = t()
  end
  pcall(EditToggle, "ModFly", false)
end
local function h()
  if q or not N or (os["time"]() * 1000 - X) < R then
    return
  end
  local T = x()
  if #T == 0 then
    return
  end
  local t = {}
  for T, A in pairs(d) do
    if H(A) < 10 then
      t[#t + 1] = T
    end
  end
  if #t == 0 then
    return
  end
  q = true
  X = os["time"]() * 1000
  local A = D()
  if A and (A ~= "" and (A ~= "EXIT" and (growtopia and type(growtopia["warpTo"]) == "function"))) then
    for T, t in ipairs(T) do
      if not N then
        break
      end
      if ((D() or "")):upper() ~= t then
        growtopia["warpTo"](t)
        if not o(t) then
          t = nil
        end
      end
      if t then
        Sleep(150)
        g()
      end
      local A = false
      for T, t in pairs(d) do
        if H(t) < 10 then
          A = true
          break
        end
      end
      if not A then
        break
      end
    end
    if ((D() or "")):upper() ~= A:upper() then
      growtopia["warpTo"](A)
      o(A)
    end
    local t = {}
    for T, A in pairs(d) do
      if H(A) < 10 then
        t[#t + 1] = T
      end
    end
    if #t == 0 then
      v("Star Tools restocked.")
    else
      v("Restock checked. Still low: " .. table["concat"](t, ", "))
    end
  end
  q = false
end
_G["zs_startopia_set_restock"] = function(T)
  N = T and true or false
  if N then
    X = -180000
    if type(runThread) == "function" then
      runThread(function()
        while N do
          h()
          Sleep(1000)
        end
      end)
    end
    v("AUTO RESTOCK enabled.")
  else
    v("AUTO RESTOCK disabled.")
  end
end
local B, U, p = "", 1, ""
local function i(T)
  local t = string["lower"](T or "")
  for T, A in ipairs(Q) do
    if t:find(string["lower"](A[1]), 1, true) then
      return A
    end
  end
  if t:find("rebel", 1, true) or t:find("alien attack", 1, true) or t:find("pirate attack", 1, true) then
    return { "Rebel Attack", { "Tactical Drone", "HyperShields", "Growton Torpedo", "Growton Torpedo" } }
  end
  if t:find("parasite", 1, true) or t:find("bug hunt", 1, true) or t:find("spider hunt", 1, true) then
    return { "Parasite Hunt", { "Tactical Drone", "Teleporter Charge", "Quadriscanner", "Gigablaster", "Teleporter Charge" } }
  end
  if t:find("warp data", 1, true) or t:find("data detected", 1, true) then
    return { "Warp Data", {
      "Tactical Drone",
      "Teleporter Charge",
      "Quadriscanner",
      "Teleporter Charge",
      "Stellar Documents",
    } }
  end
end
local function I(T)
  if growtopia and type(growtopia["notify"]) == "function" then
    pcall(growtopia["notify"], T)
  elseif type(LogToConsole) == "function" then
    LogToConsole("`9[ZS Startopia] `w" .. T)
  end
end
local function m(T)
  if not ZS_STARTOPIA_GUIDE_ENABLED or type(T) ~= "table" then
    return false
  end
  local t = tostring(T["v1"] or T[0] or "")
  local A = tostring(T["v2"] or T[1] or "")
  if t ~= "OnDialogRequest" then
    return false
  end
  local W = string["lower"](A)
  if
    not (
      W:find("startopia", 1, true)
      or W:find("star voyage", 1, true)
      or W:find("tool6518", 1, true)
      or W:find("tool6520", 1, true)
      or W:find("tool6522", 1, true)
      or W:find("tool6524", 1, true)
      or W:find("tool6526", 1, true)
      or W:find("tool6528", 1, true)
      or W:find("tool6530", 1, true)
      or W:find("tool6532", 1, true)
      or W:find("tool6534", 1, true)
      or W:find("tool6536", 1, true)
      or W:find("tool6538", 1, true)
      or W:find("tool6540", 1, true)
    )
  then
    return false
  end
  local l = i(A)
  if not l then
    return false
  end
  local a = l[1]
  if a ~= p then
    p, U = a, 1
  elseif A:find("skill fail", 1, true) or A:find("failed", 1, true) then
  elseif A ~= B then
    U = U + 1
  end
  B = A
  local Z = l[2][U]
  if not Z then
    p, U = "", 1
    return false
  end
  local y = d[Z]
  if not y or not A:find("tool" .. y, 1, true) then
    return false
  end
  if type(SendPacket) == "function" then
    local T = pcall(SendPacket, 2, "action|dialog_return\ndialog_name|startopia\nbuttonClicked|tool" .. y)
    if T then
      if type(LogToConsole) == "function" then
        LogToConsole("`9[ZS Auto Startopia] `c" .. Z)
      end
      return true
    end
  end
  return false
end
l(m, "onvariant")
local e = UserInterface["new"]("ZS AUTO STARTOPIA", "Rocket")
e:addLabelApp("* ZS AUTO STARTOPIA *", "Rocket")
e:addTooltip(
  "AUTO STARTOPIA",
  "Turn AUTO STARTOPIA ON before starting a voyage. It recognizes supported missions and selects the matching Star Tool. Turn it OFF to stop.\n\nAUTO RESTOCK collects dropped Star Tools from your storage worlds when stock is low, then returns to your original world. Separate multiple worlds with commas.",
  "Info",
  true
)
e:addDivider()
e:addToggle("AUTO STARTOPIA", false, "zs_startopia_full_auto", false)
e:addDivider()
ZS_label(e, "STAR TOOL MULTIWORLD")
e:addToggle("AUTO RESTOCK", false, "zs_startopia_restock_toggle", false)
e:addInputString(
  "Storage world(s)",
  "",
  "Star Tool storage world(s)",
  "Separate worlds with commas.",
  "Worlds",
  "zs_startopia_storage_world"
)
w(e:generateJSON(), "ZS")
l(function(T, t, W)
  if t == "zs_startopia_full_auto" then
    ZS_STARTOPIA_GUIDE_ENABLED = W and true or false
    ZS_STARTOPIA_LAST_MATCH = ""
    if ZS_STARTOPIA_GUIDE_ENABLED then
      A(
        "Startopia AUTO GUIDE enabled. Open/start a voyage; mission dialog detection is active. Tool use remains manual until real action IDs are verified."
      )
    else
      A("Startopia AUTO GUIDE stopped.")
    end
  elseif t == "zs_startopia_restock_toggle" then
    if type(zs_startopia_set_restock) == "function" then
      zs_startopia_set_restock(W)
    end
  end
end, "onValue")
if type(applyHook) == "function" then
  pcall(applyHook)
end
