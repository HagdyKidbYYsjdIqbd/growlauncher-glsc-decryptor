local a = {}
local function C(C)
  local O = a[C]
  if O then
    return O
  end
  local U = _E[C]
  local Y = U[1]
  local L = U[2]
  local f = {}
  for a = 1, #L, 1 do
    f[a] = string["char"](((L[a] - Y) - (a - 1)) % 256)
  end
  O = table["concat"](f)
  a[C] = O
  return O
end
local function O(...)
  for a, C in ipairs({ ... }) do
    if _G[C] then
      return _G[C]
    end
  end
  return nil
end
local U = O("getLocal", "GetLocal")
local Y = O("getObjectList", "GetObjectList")
local L = O("getTiles", "GetTiles")
local f = O("getTile", "GetTile")
local n = O("getInventory", "GetInventory")
local D = O("sendPacketRaw", "SendPacketRaw")
local F = O("sendPacket", "SendPacket")
local Q = O("FindPath", "findPath")
local k = O("sendNotification", "SendNotification")
local I = O("log", "LogToConsole", "print")
local o = O("CSleep", "sleep", "Sleep")
local b = O("GetWorldName", "getCurrentWorldName", "getWorldName")
local e = require("preferences")
local W = e:new("cryys_autoplant_config")
W:load()
local function N(a)
  if o then
    o(a)
  end
end
local function d(a) end
local function Z(a)
  if k then
    pcall(k, a)
  end
end
local function P()
  if not U then
    return nil
  end
  local a, C = pcall(U)
  if a then
    return C
  end
  return nil
end
local function i()
  if not Y then
    return {}
  end
  local a, C = pcall(Y)
  if a and type(C) == "table" then
    return C
  end
  return {}
end
local function u(a)
  if type(a) ~= "table" then
    return nil, nil
  end
  if a["pos"] and (a["pos"]["x"] ~= nil and a["pos"]["y"] ~= nil) then
    return a["pos"]["x"], a["pos"]["y"]
  elseif a["posX"] ~= nil and a["posY"] ~= nil then
    return a["posX"], a["posY"]
  end
  return nil, nil
end
local function j()
  if not L then
    return {}
  end
  local a, C = pcall(L)
  if a and type(C) == "table" then
    return C
  end
  return {}
end
local function w(a, C)
  if not f then
    return nil
  end
  local O, U = pcall(f, a, C)
  if O and type(U) == "table" then
    return U
  end
  return nil
end
local function l()
  if not n then
    return {}
  end
  local a, C = pcall(n)
  if a and type(C) == "table" then
    return C
  end
  return {}
end
local function X(a, C)
  if D then
    pcall(D, a, C)
  end
end
local function G(a, C)
  if F then
    pcall(F, a, C)
  end
end
local function z(a, C)
  if not Q then
    return false
  end
  local O, U = pcall(Q, a, C, false)
  if O then
    return U
  end
  return false
end
local function h()
  if not b then
    return nil
  end
  local a, C = pcall(b)
  if a and (C and C ~= "") then
    return tostring(C)
  end
  return nil
end
local function M(a)
  if type(a) ~= "string" then
    return ""
  end
  return a:match("^%s*(.-)%s*$")
end
local function s(a, C)
  if not a or not C then
    return false
  end
  local O = (M(tostring(a))):upper()
  local U = (M(tostring(C))):upper()
  if O == "" or U == "" then
    return false
  end
  return O == U
end
local function J()
  local a = {}
  a["FARM_WORLD"] = W:get("FARM_WORLD", "")
  a["FARM_DOOR"] = W:get("FARM_DOOR", "")
  a["SEED_ID"] = W:get("SEED_ID", "")
  a["PLANT_DELAY"] = W:get("PLANT_DELAY", "200")
  a["LICENSE_KEY"] = W:get("LICENSE_KEY", "")
  a["AUTOSAVE"] = W:get("AUTOSAVE", "1")
  a["SPLICE_SEED_ID"] = W:get("SPLICE_SEED_ID", "")
  a["SPLICE_BATCH"] = W:get("SPLICE_BATCH", "10")
  a["SPLICE_RETRY"] = W:get("SPLICE_RETRY", "5")
  return a
end
local r = J()
local function g(a, C)
  local O = r[a]
  if O ~= nil and O ~= "" then
    return O
  end
  return C
end
local function E(a)
  return (a:gsub("||", "\n"))
end
local K = E(g("FARM_WORLD", ""))
local S = E(g("FARM_DOOR", ""))
function CryysSetToggle(a, C)
  if editToggle then
    pcall(editToggle, a, C)
  elseif editValue then
    pcall(editValue, a, C)
  end
end
function CryysSetValue(a, C)
  if editValue then
    pcall(editValue, a, C)
  end
end
function CryysSyncToggle()
  CryysSetToggle("plant_start_bot", false)
end
function CryysShowFillDialog(a)
  local C = table["concat"](a, " & ")
  local O = table["concat"](
    {
      "set_default_color|`o",
      "add_label_with_icon|big|`wAuto Plant``|left|6336|",
      "add_spacer|small|",
      "add_textbox|`4Belum bisa START!``|left|",
      "add_spacer|small|",
      "add_textbox|Kolom `w" .. (C .. "`` masih `4Blank``.|left|"),
      "add_textbox|Pilih " .. (C .. " dulu di menu Auto Plant, lalu nyalakan START/STOP lagi.|left|"),
      "add_quick_exit|",
      "end_dialog|plant_fill_seed|OK||",
    },
    "\n"
  )
  if growtopia and growtopia["sendDialog"] then
    if pcall(growtopia["sendDialog"], O) then
      return
    end
  end
  if sendDialog then
    pcall(
      sendDialog,
      {
        ["title"] = "Isi " .. C,
        ["alias"] = "plant_fill_seed_dialog",
        ["message"] = "Kolom " .. (C .. " masih Blank.\nPilih dulu di menu Auto Plant."),
        ["confirm"] = "OK",
      }
    )
  end
end
function CryysPlantDiscord()
  local a = "https://discord.gg/3TyheDU5Y"
  if growtopia and growtopia["sendDialog"] then
    local C = table["concat"](
      {
        "set_default_color|`o",
        "add_textbox|`wJoin Discord``|left|",
        "add_spacer|small|",
        "add_textbox|Join komunitas Auto Plant by Cryys!|left|",
        "add_spacer|small|",
        "add_url_button||`$Join Discord``|NOFLAGS|" .. (a .. "|Buka link Discord?|0|0|"),
        "add_quick_exit|",
        "end_dialog|plant_discord|Tutup||",
      },
      "\n"
    )
    if pcall(growtopia["sendDialog"], C) then
      return
    end
  end
  if sendDialog then
    pcall(
      sendDialog,
      {
        ["title"] = "Join Discord",
        ["alias"] = "plant_discord_dialog",
        ["message"] = "Join komunitas Auto Plant by Cryys:\n" .. a,
        ["confirm"] = "Join",
        ["url"] = a,
      }
    )
  end
  d("Link Discord: " .. a)
end
do
  local function a(a)
    return ((tostring(a or "")):match("^%s*(.-)%s*$"))
  end
  local function C(a)
    local C = {}
    for a in (((a or "") .. "\n")):gmatch("(.-)\r?\n") do
      C[#C + 1] = a
    end
    return C
  end
  local function O(O)
    local U = {}
    for C, O in ipairs(C(O)) do
      for C in ((O .. ",")):gmatch("(.-),") do
        local O = a(C)
        if O ~= "" then
          U[#U + 1] = O
        end
      end
    end
    return U
  end
  local function U(a, C)
    local U = O(a)
    local Y = O(C)
    local L = {}
    for a, C in ipairs(U) do
      if not C:find("|", 1, true) then
        local O = ""
        if #Y == 1 then
          O = Y[1]
        else
          O = Y[a] or ""
        end
        if O ~= "" then
          C = C .. ("|" .. O)
        end
      end
      L[#L + 1] = C
    end
    return table["concat"](L, "\n")
  end
  K = U(K, S)
  S = ""
  CRYYS_TAKE_MODE = "current"
end
do
  local a, C = pcall(function()
    return W:get("MODE", "plant")
  end)
  if a and (C == "plant" or C == "splice") then
    CRYYS_MODE = C
  else
    CRYYS_MODE = "plant"
  end
end
function CryysPickSeed(a, C)
  do
    local C = a
    if type(C) == "table" then
      C = C["id"] or C["itemID"] or C["item_id"] or C[1] or C["name"]
    end
    if C == nil or C == false then
      return ""
    end
    if type(C) == "number" and C <= 0 then
      return ""
    end
    if type(C) == "string" then
      local a = (C:match("^%s*(.-)%s*$")):lower()
      if a == "" or a == "blank" or a == "default" or a:match("^0+$") then
        return ""
      end
    end
  end
  if type(a) == "table" then
    a = a["id"] or a["itemID"] or a["item_id"] or a[1]
  end
  if type(a) == "string" and a:find(",") then
    return a
  end
  local O = tonumber(a)
  if not O and type(a) == "string" then
    O = tonumber(a:match("^%s*(%d+)%s*$"))
    if not O then
      local C = findItemID or FindItemID
      if C then
        local U, Y = pcall(C, a)
        if U then
          O = tonumber(Y)
        end
      end
    end
    if not O then
      O = tonumber(a:match("(%d+)"))
    end
  end
  if not O or O <= 0 then
    return C
  end
  O = math["floor"](O)
  local U = getItemInfoByID or GetItemInfoByID
  local Y = nil
  if U then
    local a, C = pcall(U, O)
    if a and type(C) == "table" then
      Y = (C["type"] == 19) or (type(C["name"]) == "string" and C["name"]:match("%sSeed$") ~= nil)
    end
  end
  if Y == nil then
    Y = (O % 2 == 1)
  end
  if not Y then
    O = O + 1
  end
  return tostring(O)
end
function CryysAddSeedPicker(a, C, O, U)
  local Y = tonumber((tostring(O or "")):match("(%d+)")) or 0
  local L = "Blank"
  if Y > 0 then
    local a = getItemInfoByID or GetItemInfoByID
    if a then
      local C, O = pcall(a, Y)
      if C and (type(O) == "table" and type(O["name"]) == "string") then
        L = O["name"]
      end
    end
  else
    Y = 0
  end
  local f = "Blank"
  local n = pcall(function()
    a:addItemPicker(C, L, f, U)
  end)
  if not n then
    a:addItemPicker(C, L, tostring(Y), U)
  end
end
local q = { ["ok"] = false, ["err"] = nil, ["detail"] = "", ["key"] = M(g("LICENSE_KEY", "")) }
q["MESSAGES"] = {
  ["no_key"] = "Enter The License Key First",
  ["invalid_key"] = "Invalid Key",
  ["expired_key"] = "Key Expired, Get The New Weekly Key",
  ["bad_params"] = "Invalid Key",
  ["try_again"] = "Server Busy, Try Again",
  ["unknown_script"] = "Script Not Registered",
  ["network"] = "Connection Failed",
  ["bad_response"] = "Server Error",
}
local function p(a)
  a = tostring(a)
  local C = {
    function()
      return sendVariant({ ["v1"] = "OnTextOverlay", ["v2"] = a })
    end,
    function()
      return SendVariant({ ["v1"] = "OnTextOverlay", ["v2"] = a })
    end,
    function()
      return SendVariantList({ [0] = "OnTextOverlay", [1] = a })
    end,
    function()
      return sendVariantList({ [0] = "OnTextOverlay", [1] = a })
    end,
  }
  for a, C in ipairs(C) do
    local O = pcall(C)
    if O then
      return true
    end
  end
  Z(a)
  return false
end
function q.saveKey(a)
  pcall(function()
    W:set("LICENSE_KEY", tostring(a or ""))
    W:save()
  end)
end
local x = "Zibhh9ws7XdmRcZK"
local function c()
  local a, C = pcall(function()
    return os["time"]()
  end)
  if not a or type(C) ~= "number" then
    return nil
  end
  local O = math["floor"]((math["floor"]((C + 25200) / 86400) + 3) / 7)
  local U = x .. (":" .. tostring(O))
  local Y = 5381
  for a = 1, #U, 1 do
    Y = (Y * 33 + U:byte(a)) % 2147483647
  end
  local L, f = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789", ""
  for a = 1, 8, 1 do
    Y = (Y * 48271) % 2147483647
    local C = Y % #L + 1
    f = f .. L:sub(C, C)
  end
  return "CRYYS-PLANT-" .. (f:sub(1, 4) .. ("-" .. f:sub(5, 8)))
end
function q.check(a)
  q["err"] = nil
  a = (M(tostring(a or q["key"] or ""))):upper()
  if a == "" then
    q["err"] = "no_key"
    return false
  end
  local C = c()
  if not C then
    q["err"] = "bad_response"
    return false
  end
  if a == C then
    return true
  end
  q["err"] = "invalid_key"
  return false
end
function q.message()
  return q["MESSAGES"][q["err"] or ""] or "Access Denied"
end
local function m()
  for a, C in ipairs({ "removeModule", "deleteModule", "clearModule", "RemoveModule" }) do
    local O = _G[C]
    if type(O) == "function" then
      pcall(O, "Cryys")
      break
    end
  end
end
local function t()
  local a = UserInterface["new"]("Auto Plant", "Park")
  a:addDivider()
  a:addToggleButton("START/STOP", false, "plant_start_bot")
  a:addDivider()
  CryysAddSeedPicker(a, "Seed to Plant", g("SEED_ID", ""), "seed_id")
  CryysAddSeedPicker(a, "Seed to Splice", g("SPLICE_SEED_ID", ""), "splice_seed_id")
  a:addDivider()
  local C = a:addDialog("Mode", "Click to open settings", {})
  a:addChildToggle(
    C["menu"],
    "Plant",
    CRYYS_MODE == "plant",
    "mode_plant",
    false,
    false,
    "Plant seed biasa di farm world."
  )
  a:addChildToggle(
    C["menu"],
    "Splice",
    CRYYS_MODE == "splice",
    "mode_splice",
    false,
    false,
    "Plant seed lalu splice dengan Seed to Splice."
  )
  local O = a:addDialog("Farm Setting", "Click to open settings", {})
  a:addChildTooltip(O["menu"], "Farm World", "Format WORLD|DOOR. Pisah pakai koma atau baris baru", "World", false)
  a:addChildInputString(O["menu"], "Farm World", K, "World", "world|door,world1|door", "World", "farm_world")
  a:addChildButton(O["menu"], "Get Current World", "farm_get_current_world")
  local U = tonumber(g("PLANT_DELAY", "200")) or 200
  if U < 100 then
    U = 100
  end
  if U > 1000 then
    U = 1000
  end
  a:addInputString("Plant Delay (ms)", tostring(U), "Minimum 100 ms.", "200", "Timer", "plant_delay")
  a:addInputString(
    "Minimum seed plant before splice",
    g("SPLICE_BATCH", "10"),
    "Max is 30!",
    "10",
    "Terminal",
    "splice_batch"
  )
  a:addInputString(
    "Max retries for each batch",
    g("SPLICE_RETRY", "5"),
    "More retries if you're lagging.",
    "5",
    "Autorenew",
    "splice_retry"
  )
  a:addDivider()
  a:addButton("Join Discord", "plant_btn_discord")
  a:addDivider()
  local Y = a:generateJSON()
  Y = Y:gsub("^%s*{", '{"description":"Auto Plant By Cryys (Free)",', 1)
  do
    local function a()
      local a, C = pcall(function()
        local a = UserInterface["new"]("tmp", "Verified")
        a:addTooltip("ZZTITLE", "ZZSUPPORT", "Info", false)
        return (a:generateJSON()):match('"([%w_]+)"%s*:%s*"ZZSUPPORT"')
      end)
      if a and C then
        return C
      end
      return "support_text"
    end
    local function C(a, C)
      local O, U = 0, C
      while U > 0 do
        local C = a:sub(U, U)
        if C == "}" then
          O = O + 1
        elseif C == "{" then
          if O == 0 then
            break
          end
          O = O - 1
        end
        U = U - 1
      end
      if U <= 0 then
        return nil
      end
      local Y, L, f = 0, false, U
      while f <= #a do
        local C = a:sub(f, f)
        if L then
          if C == "\\" then
            f = f + 1
          elseif C == '"' then
            L = false
          end
        else
          if C == '"' then
            L = true
          elseif C == "{" then
            Y = Y + 1
          elseif C == "}" then
            Y = Y - 1
            if Y == 0 then
              return U, f
            end
          end
        end
        f = f + 1
      end
      return nil
    end
    local function O(a, O, U, Y)
      local L = a:find('"' .. (O .. '"'), 1, true)
      if not L then
        return a, false
      end
      local f, n = C(a, L)
      if not f then
        return a, false
      end
      local D = a:sub(f, n)
      local F, Q, k = 0, false, 1
      local I, o
      while k <= #D do
        local a = D:sub(k, k)
        if Q then
          if a == "\\" then
            k = k + 1
          elseif a == '"' then
            Q = false
          end
        else
          if a == '"' then
            if F == 1 then
              local a = D:match('^"([^"]*)"%s*:%s*', k)
              if a == U then
                local a, C = D:find('^"[^"]*"%s*:%s*', k)
                local O = C + 1
                if D:sub(O, O) == '"' then
                  local a = O + 1
                  while a <= #D and D:sub(a, a) ~= '"' do
                    if D:sub(a, a) == "\\" then
                      a = a + 1
                    end
                    a = a + 1
                  end
                  I, o = O, a
                end
                break
              end
            end
            Q = true
          elseif a == "{" or a == "[" then
            F = F + 1
          elseif a == "}" or a == "]" then
            F = F - 1
          end
        end
        k = k + 1
      end
      local b
      if I then
        b = D:sub(1, I - 1) .. ('"' .. (Y .. ('"' .. D:sub(o + 1))))
      else
        b = '{"' .. (U .. ('":"' .. (Y .. ('",' .. D:sub(2)))))
      end
      return a:sub(1, f - 1) .. (b .. a:sub(n + 1)), true
    end
    local U = a()
    local L, f = {}, {}
    for a, C in ipairs({ U, "support_text", "description", "desc", "subtitle", "sub_text", "summary" }) do
      if not f[C] then
        f[C] = true
        L[#L + 1] = C
      end
    end
    local n = {
      { "mode_plant", "Plant seed biasa di farm world." },
      { "mode_splice", "Plant seed lalu splice dengan Seed to Splice." },
    }
    for a, C in ipairs(n) do
      local U = false
      for a, L in ipairs(L) do
        local f
        Y, f = O(Y, C[1], L, C[2])
        U = U or f
      end
    end
  end
  m()
  if addCategory then
    pcall(addCategory, "Cryys", "FileOpen")
  end
  requireModule("Cryys")
  addIntoModule(Y, "Cryys")
end
local function T()
  local a = UserInterface["new"]("Auto Plant", "Verified")
  a:addDivider()
  a:addTooltip(
    "Locked",
    "Free version. Get the weekly License Key in Discord, paste it below, then press Check Key.",
    "Info",
    false
  )
  a:addInputString(
    "License Key",
    q["key"] or "",
    "The key changes every week.",
    "CRYYS-PLANT-XXXX-XXXX",
    "Key",
    "plant_license_key"
  )
  a:addButton("Check Key", "plant_btn_recheck")
  a:addDivider()
  a:addButton("Join Discord", "plant_btn_discord")
  a:addDivider()
  local C = a:generateJSON()
  C = C:gsub("^%s*{", '{"description":"Auto Plant By Cryys (Free)",', 1)
  m()
  if addCategory then
    pcall(addCategory, "Cryys", "FileOpen")
  end
  requireModule("Cryys")
  addIntoModule(C, "Cryys")
end
q["ok"] = q["check"](q["key"])
if q["ok"] then
  t()
else
  T()
  p("`5[Cryys]  `4" .. q["message"]())
end
local B = 4000
local V = 150
local H = 4000
local R = 50
local v = 3
local y = 200
local A = 400
local aM = 5
local CM = 200
local OM = 8000
local UM = 3
local YM = 1000
local LM = 1500
local fM = 5000
local nM = 200
local DM = 2000
local FM = 150
local QM = 300
local kM = 1
local IM = 500
local oM = 0
local bM = {}
local eM = {}
local WM = nil
local NM = {
  ["farm_world"] = K,
  ["farm_door"] = S,
  ["seed_id_str"] = g("SEED_ID", ""),
  ["plant_delay"] = tonumber(g("PLANT_DELAY", "200")) or 200,
  ["autosave"] = (g("AUTOSAVE", "1") == "1"),
  ["splice_seed_str"] = g("SPLICE_SEED_ID", ""),
  ["splice_batch"] = math["min"](30, math["max"](1, tonumber(g("SPLICE_BATCH", "10")) or 10)),
  ["splice_retry"] = math["min"](5, math["max"](1, tonumber(g("SPLICE_RETRY", "5")) or 5)),
  ["seedIDList"] = {},
  ["seedIDSet"] = {},
  ["farmList"] = {},
  ["farmIndex"] = 1,
}
local function dM(a)
  local C = {}
  local O = {}
  if not a then
    return C, O
  end
  for a in string["gmatch"](a, "[^,%s]+") do
    local U = tonumber(a)
    if U then
      C[#C + 1] = U
      O[U] = true
    end
  end
  return C, O
end
local function ZM(a)
  NM["seed_id_str"] = a
  local C, O = dM(a)
  NM["seedIDList"] = C
  NM["seedIDSet"] = O
end
local function PM(a)
  local C = {}
  if not a or a == "" then
    return C
  end
  for a in ((a .. "\n")):gmatch("(.-)\r?\n") do
    C[#C + 1] = a
  end
  return C
end
function CryysParseEntries(a)
  local C = {}
  for a in (((a or "") .. "\n")):gmatch("(.-)\r?\n") do
    for a in ((a .. ",")):gmatch("(.-),") do
      local O = a:match("^%s*(.-)%s*$")
      if O ~= "" then
        local a, U = O:match("^([^|]*)|(.*)$")
        if not a then
          a = O
          U = ""
        end
        a = a:match("^%s*(.-)%s*$")
        U = U:match("^%s*(.-)%s*$")
        if a ~= "" then
          C[#C + 1] = { ["world"] = a, ["door"] = U }
        end
      end
    end
  end
  return C
end
function CryysNormList(a)
  local C = {}
  for a, O in ipairs(CryysParseEntries(a)) do
    if O["door"] ~= "" then
      C[#C + 1] = O["world"] .. ("|" .. O["door"])
    else
      C[#C + 1] = O["world"]
    end
  end
  return table["concat"](C, "\n")
end
local function iM(a)
  local C = {}
  if not a or a == "" then
    return C
  end
  for a in ((a .. "\n")):gmatch("(.-)\r?\n") do
    for a in ((a .. ",")):gmatch("(.-),") do
      local O = M(a)
      if O ~= "" then
        C[#C + 1] = O
      end
    end
  end
  return C
end
local function uM(a, C)
  return CryysParseEntries(a)
end
local function jM()
  NM["farmList"] = uM(NM["farm_world"], NM["farm_door"])
  if NM["farmIndex"] > #NM["farmList"] or NM["farmIndex"] < 1 then
    NM["farmIndex"] = 1
  end
end
local function wM()
  return NM["farmList"][NM["farmIndex"]] or { ["world"] = "", ["door"] = "" }
end
local function lM(a)
  return string["upper"](tostring(a or ""))
end
local function XM(a)
  return bM[lM(a)] == true
end
local function GM(a)
  bM[lM(a)] = true
end
local function zM(a, C)
  local O = NM["farmList"][NM["farmIndex"]]
  return lM(O and O["world"]) .. (":" .. (tostring(a) .. ("," .. tostring(C))))
end
local function hM(a, C)
  return eM[zM(a, C)] == true
end
local function MM()
  local a = #NM["farmList"]
  if a == 0 then
    return nil
  end
  for C = 1, a, 1 do
    NM["farmIndex"] = NM["farmIndex"] + 1
    if NM["farmIndex"] > a then
      NM["farmIndex"] = 1
    end
    local O = NM["farmList"][NM["farmIndex"]]
    if O and (O["world"] ~= "" and not XM(O["world"])) then
      return NM["farmIndex"]
    end
  end
  return nil
end
ZM(NM["seed_id_str"])
jM()
local sM = false
local JM = false
local rM = {}
local gM = nil
local EM = false
local KM = 0
local function SM(a)
  local C = 100
  local O = 0
  while O < a do
    if not sM then
      return false
    end
    if gM and not EM then
      if P() == nil then
        KM = KM + 1
        if KM >= 30 then
          KM = 0
          gM()
          if not sM then
            return false
          end
        end
      else
        KM = 0
      end
    end
    local U = math["min"](C, a - O)
    N(U)
    O = O + U
  end
  return sM
end
local qM = {}
local function pM(a, C)
  if qM[a] == C then
    return
  end
  qM[a] = C
  d(C)
end
local function xM(a)
  qM[a] = nil
end
local function cM()
  if not NM["autosave"] then
    return
  end
  pcall(function()
    local a = CryysNormList(NM["farm_world"] or "")
    W:set("FARM_WORLD", (a:gsub("\n", "||")))
    W:set("FARM_DOOR", "")
    W:set("SEED_ID", NM["seed_id_str"] or "")
    W:set("PLANT_DELAY", tostring(NM["plant_delay"] or 200))
    W:set("AUTOSAVE", NM["autosave"] and "1" or "0")
    W:set("MODE", CRYYS_MODE or "plant")
    W:set("SPLICE_SEED_ID", NM["splice_seed_str"] or "")
    W:set("SPLICE_BATCH", tostring(NM["splice_batch"] or 10))
    W:set("SPLICE_RETRY", tostring(NM["splice_retry"] or 5))
    W:save()
  end)
end
local function mM(a, C, O)
  if C == "plant_license_key" then
    q["key"] = M(tostring(O or ""))
    q["saveKey"](q["key"])
    return
  end
  if C == "plant_btn_recheck" then
    if q["ok"] then
      return
    end
    if q["check"](q["key"]) then
      q["ok"] = true
      q["saveKey"](q["key"])
      p("`5[Cryys]  `2Access Granted")
      t()
      if CryysShowPremium then
        pcall(CryysShowPremium)
      end
    else
      p("`5[Cryys]  `4" .. q["message"]())
    end
    return
  end
  if C == "plant_btn_discord" then
    CryysPlantDiscord()
    return
  end
  if not q["ok"] then
    return
  end
  if C == "plant_start_bot" then
    sM = O
    if sM and not q["check"](q["key"]) then
      q["ok"] = false
      sM = false
      CryysSyncToggle()
      T()
      p("`5[Cryys]  `4" .. q["message"]())
      return
    end
    if sM then
      bM = {}
      eM = {}
      WM = nil
      rM = {}
      qM = {}
      do
        local a = {}
        local C = false
        for a, O in ipairs(NM["seedIDList"]) do
          if (tonumber(O) or 0) > 0 then
            C = true
          end
        end
        if not C then
          a[#a + 1] = "Seed to Plant"
        end
        if CRYYS_MODE == "splice" then
          local C = tonumber(((tostring(NM["splice_seed_str"] or "")):match("%d+"))) or 0
          if C <= 0 then
            a[#a + 1] = "Seed to Splice"
          end
        end
        if #a > 0 then
          d("[AutoPlant] ERROR: Isi " .. (table["concat"](a, " & ") .. " dulu."))
          Z("Isi " .. (table["concat"](a, " & ") .. " dulu!"))
          sM = false
          CryysSyncToggle()
          CryysShowFillDialog(a)
          return
        end
      end
      if #NM["farmList"] == 0 then
        d("[AutoPlant] ERROR: Isi Farm World dulu.")
        Z("[AutoPlant] Isi Farm World dulu!")
        sM = false
        CryysSyncToggle()
        return
      end
      cM()
      if JM then
        d("[AutoPlant] Bot sudah jalan.")
      else
        if runThread then
          runThread(mainLoop)
        else
          d("[AutoPlant] ERROR: runThread tidak tersedia.")
          sM = false
          CryysSyncToggle()
        end
      end
    else
      d("[AutoPlant] Stopped")
    end
  elseif C == "farm_world" then
    NM["farm_world"] = O
    jM()
    cM()
  elseif C == "plant_farm_door" then
    NM["farm_door"] = O
    jM()
    cM()
  elseif C == "seed_id" then
    d("[AutoPlant] picker seed_id raw=" .. (tostring(O) .. (" (" .. (type(O) .. ")"))))
    ZM(CryysPickSeed(O, NM["seed_id_str"]))
    d("[AutoPlant] Seed dipilih: " .. tostring(NM["seed_id_str"]))
    cM()
  elseif C == "plant_delay" then
    NM["plant_delay"] = math["max"](100, tonumber(O) or 200)
    cM()
  elseif C == "autosave" then
    NM["autosave"] = O
    if NM["autosave"] then
      cM()
    end
  elseif C == "plant_btn_discord" then
    CryysPlantDiscord()
  elseif C == "farm_get_current_world" then
    local a = nil
    for C = 1, 5, 1 do
      a = h()
      if a and a ~= "" then
        break
      end
      N(200)
    end
    if a and a ~= "" then
      a = M(a)
      NM["farm_world"] = a
      NM["farmIndex"] = 1
      bM = {}
      eM = {}
      oM = 0
      rM = {}
      jM()
      CryysSetValue("farm_world", a)
      cM()
      d("[AutoPlant] Farm World diganti ke world saat ini: " .. a)
    else
      d("[AutoPlant] Get Current World gagal: nama world belum terbaca.")
    end
  elseif C == "mode_plant" then
    local a = (O == true or O == "true" or O == 1)
    if a then
      CRYYS_MODE = "plant"
      d("[AutoPlant] Mode diubah: Plant")
      CryysSetToggle("mode_splice", false)
    elseif CRYYS_MODE == "plant" then
      CryysSetToggle("mode_plant", true)
    end
    cM()
  elseif C == "mode_splice" then
    local a = (O == true or O == "true" or O == 1)
    if a then
      CRYYS_MODE = "splice"
      d("[AutoPlant] Mode diubah: Splice")
      CryysSetToggle("mode_plant", false)
    elseif CRYYS_MODE == "splice" then
      CryysSetToggle("mode_splice", true)
    end
    cM()
  elseif C == "splice_seed_id" then
    d("[AutoPlant] picker splice raw=" .. (tostring(O) .. (" (" .. (type(O) .. ")"))))
    NM["splice_seed_str"] = CryysPickSeed(O, NM["splice_seed_str"] or "")
    d("[AutoPlant] Seed to Splice dipilih: " .. tostring(NM["splice_seed_str"]))
    cM()
  elseif C == "splice_batch" then
    local a = tonumber(O) or 10
    if a < 1 then
      a = 1
    end
    if a > 30 then
      a = 30
    end
    NM["splice_batch"] = math["floor"](a)
    cM()
  elseif C == "splice_retry" then
    local a = tonumber(O) or 5
    if a < 1 then
      a = 1
    end
    if a > 5 then
      a = 5
    end
    NM["splice_retry"] = math["floor"](a)
    cM()
  elseif C == "save_config" then
    if O then
      cM()
      d("[AutoPlant] Config disimpan.")
      Z("[AutoPlant] Config Tersimpan!")
    end
  end
end
function onValue(a, C, O)
  local U, Y = pcall(mM, a, C, O)
  if not U then
    d("[AutoPlant] ERROR onValue (" .. (tostring(C) .. ("): " .. tostring(Y))))
  end
end
if addHook then
  addHook(onValue, "onValue")
end
if applyHook then
  applyHook()
end
local function tM(a)
  pcall(function()
    if type(a) ~= "table" or not WM then
      return
    end
    for a, C in pairs(a) do
      if type(C) == "string" and string["find"](string["lower"](C), "area is owned by", 1, true) then
        eM[WM] = true
        WM = nil
        return
      end
    end
  end)
  return false
end
if addHook then
  pcall(addHook, tM, "OnVariant")
  pcall(addHook, tM, "onVariant")
end
local function TM(a)
  if growtopia and growtopia["checkInventoryCount"] then
    local C, O = pcall(growtopia["checkInventoryCount"], a)
    if C and O then
      return O
    end
  end
  local C = l()
  for C, O in pairs(C) do
    if O["id"] == a then
      return O["amount"] or 0
    end
  end
  return 0
end
local function BM()
  local a = 0
  for C, O in ipairs(NM["seedIDList"]) do
    a = a + TM(O)
  end
  return a
end
local function VM()
  for a, C in ipairs(NM["seedIDList"]) do
    if TM(C) > 0 then
      return C
    end
  end
  return nil
end
local function HM(a)
  return NM["seedIDSet"][a] == true
end
local RM = O("getItemInfoByID", "GetItemInfoByID")
local vM = 19
local yM = 4
local AM = {}
local function ap(a)
  if a == nil or a == 0 then
    return false
  end
  local C = AM[a]
  if C ~= nil then
    return C
  end
  local O = false
  if NM["seedIDSet"][a] then
    O = true
  elseif RM then
    local C, U = pcall(RM, a)
    if C and type(U) == "table" then
      if U["type"] == vM then
        O = true
      elseif type(U["name"]) == "string" and U["name"]:match("%sSeed$") then
        O = true
      end
    end
  end
  AM[a] = O
  return O
end
local function Cp(a)
  if not a then
    return false
  end
  if a["readyharvest"] == true then
    return true
  end
  if type(a["extra"]) == "table" and a["extra"]["type"] == yM then
    return true
  end
  return ap(a["fg"])
end
local function Op(a)
  if not a then
    return false
  end
  if hM(a["x"], a["y"]) then
    return false
  end
  if a["fg"] ~= 0 then
    return false
  end
  local C = w(a["x"], a["y"] + 1)
  if not C then
    return false
  end
  if C["fg"] == nil or C["fg"] == 0 then
    return false
  end
  if Cp(C) then
    return false
  end
  return true
end
local function Up(a, C, O)
  if not sM then
    return false
  end
  O = O or B
  local U = P()
  if U then
    local O = math["floor"](U["posX"] / 32)
    local Y = math["floor"](U["posY"] / 32)
    if O == a and Y == C then
      return true
    end
  end
  z(a, C)
  local Y = 0
  while Y < O do
    if not sM then
      return false
    end
    local O = P()
    if not O then
      return false
    end
    local U = math["floor"](O["posX"] / 32)
    local L = math["floor"](O["posY"] / 32)
    if U == a and L == C then
      return true
    end
    if not SM(V) then
      return false
    end
    Y = Y + V
  end
  return false
end
local function Yp(a, C, O, U)
  local Y = 0
  while Y < U do
    if not sM then
      return false
    end
    local U = w(a, C)
    if U and U["fg"] == O then
      return true
    end
    if not SM(R) then
      return false
    end
    Y = Y + R
  end
  return false
end
local Lp
local function fp(a, C, O)
  if not sM then
    return false
  end
  if not Lp() then
    return false
  end
  local U = P()
  if not U then
    return false
  end
  local Y = w(a, C)
  if not Y then
    return false
  end
  if Y["fg"] ~= 0 then
    return false
  end
  if not Op(Y) then
    return false
  end
  WM = zM(a, C)
  local L = { ["x"] = U["posX"], ["y"] = U["posY"], ["px"] = a, ["py"] = C, ["type"] = 3, ["value"] = O }
  X(false, L)
  if not SM(NM["plant_delay"]) then
    return false
  end
  return true
end
local function np(a, C, O)
  if not sM then
    return false
  end
  return fp(a, C, O)
end
local function Dp(a, C)
  C = C or OM
  local O = 0
  local U = 200
  while O < C do
    if not sM then
      return false
    end
    local C = h()
    if s(C, a) and P() ~= nil then
      return true
    end
    if not SM(U) then
      return false
    end
    O = O + U
  end
  return false
end
local function Fp(a)
  a = a or fM
  local C = 0
  while C < a do
    if not sM then
      return false
    end
    if P() ~= nil then
      if not L then
        return true
      end
      local a = j()
      if next(a) ~= nil then
        return true
      end
    end
    if not SM(nM) then
      return false
    end
    C = C + nM
  end
  return false
end
local function Qp(a)
  if growtopia and growtopia["warpTo"] then
    local C = pcall(growtopia["warpTo"], a)
    if C then
      return true
    end
  end
  if F then
    G(2, "action|input\n|text|/warp " .. a)
    return true
  end
  return false
end
local function kp(a, C, O)
  if not sM then
    return false
  end
  a = M(a)
  C = M(C)
  if a == "" then
    return false
  end
  if s(h(), a) and (not O or C == "") then
    return true
  end
  local U = a
  if C ~= "" then
    U = a .. ("|" .. C)
  end
  for C = 1, UM, 1 do
    if not sM then
      return false
    end
    local O = s(h(), a)
    if not Qp(U) then
      d("[AutoPlant] Warp tidak bisa dikirim (warpTo/sendPacket tidak tersedia).")
      return false
    end
    if O then
      if not SM(LM) then
        return false
      end
    end
    if Dp(a, OM) then
      Fp(fM)
      if not sM then
        return false
      end
      if s(h(), a) then
        d("[AutoPlant] Warp confirmed: " .. a)
        if not SM(DM) then
          return false
        end
        return true
      end
    end
    d(
      "[AutoPlant] Warp belum terkonfirmasi: " .. (
          a .. (" (percobaan " .. (tostring(C) .. ("/" .. (tostring(UM) .. ")"))))
        )
    )
    if C < UM then
      if not SM(YM) then
        return false
      end
    end
  end
  d("[AutoPlant] Warp GAGAL: " .. a)
  return false
end
Lp = function()
  local a = wM()
  if not a or a["world"] == "" then
    return false
  end
  return s(h(), a["world"])
end
local function Ip(a)
  if not sM then
    return false
  end
  if a and NM["farmList"][a] then
    NM["farmIndex"] = a
  end
  local C = wM()
  if not C or C["world"] == "" then
    d("[AutoPlant] Farm tujuan tidak tersedia.")
    return false
  end
  d(
    "[AutoPlant] Returning to Farm ["
      .. (tostring(NM["farmIndex"]) .. ("/" .. (tostring(#NM["farmList"]) .. ("]: " .. C["world"]))))
  )
  if not kp(C["world"], C["door"], true) then
    d("[AutoPlant] GAGAL: Farm belum terkonfirmasi.")
    Z("[AutoPlant] Farm belum terkonfirmasi!")
    return false
  end
  local O = h()
  if not s(O, C["world"]) then
    d("[AutoPlant] GAGAL: World masih bukan Farm.")
    Z("[AutoPlant] Bukan Farm World! Planting dibatalkan.")
    return false
  end
  d("[AutoPlant] Farm confirmed: " .. tostring(O))
  return true
end
local op = 4
local function bp()
  return tonumber(((tostring(NM["splice_seed_str"] or "")):match("%d+"))) or 0
end
local function ep(a)
  if HM(a) then
    return true
  end
  if CRYYS_MODE == "splice" then
    local C = bp()
    if C > 0 and a == C then
      return true
    end
  end
  return false
end
local function Wp(a)
  if CRYYS_MODE == "splice" and (a == bp() and not HM(a)) then
    return "splice"
  end
  return "plant"
end
local function Np()
  if BM() <= 0 then
    return false
  end
  if CRYYS_MODE == "splice" and TM(bp()) <= 0 then
    return false
  end
  return true
end
local dp = 5
local function Zp()
  local a = P()
  if not a then
    return
  end
  local C = a["posX"] / 32
  local O = a["posY"] / 32
  for a, U in pairs(i()) do
    if type(U) == "table" and ep(U["itemid"]) then
      local a, Y = u(U)
      if a then
        local L = a / 32 - C
        local f = Y / 32 - O
        if L * L + f * f <= dp * dp then
          X(false, { ["type"] = 11, ["value"] = U["id"], ["x"] = a, ["y"] = Y })
        end
      end
    end
  end
end
local function Pp(a)
  local C, O = u(a)
  if not C then
    return false
  end
  local U = math["floor"](C / 32)
  local Y = math["floor"](O / 32)
  local L = a["itemid"]
  local f = TM(L)
  for a = 1, op, 1 do
    if not sM then
      return false
    end
    if not SM(FM) then
      return false
    end
    local C = Up(U, Y, B + a * 1500)
    if not sM then
      return false
    end
    Zp()
    if TM(L) > f then
      return true
    end
    if C then
      if not SM(QM) then
        return false
      end
      if TM(L) > f then
        return true
      end
      Zp()
      if not SM(FM) then
        return false
      end
      if TM(L) > f then
        return true
      end
      local C = (a % 2 == 1) and (U + 1) or (U - 1)
      if Up(C, Y, B) then
        Up(U, Y, B)
        Zp()
        if not SM(QM) then
          return false
        end
        if TM(L) > f then
          return true
        end
      end
    end
  end
  return TM(L) > f
end
local function ip(a)
  a = a or { ["plant"] = false, ["splice"] = false }
  local C = (CRYYS_MODE == "splice")
  for O = 1, aM, 1 do
    if not sM then
      return false
    end
    Zp()
    if not SM(150) then
      return false
    end
    local U = {}
    local Y = P()
    local L = Y and (Y["posX"] / 32) or 0
    local f = Y and (Y["posY"] / 32) or 0
    for a, C in pairs(i()) do
      if type(C) == "table" and ep(C["itemid"]) then
        local a, O = u(C)
        if a then
          local Y = a / 32 - L
          local n = O / 32 - f
          U[#U + 1] = { ["obj"] = C, ["kind"] = Wp(C["itemid"]), ["dist"] = Y * Y + n * n }
        end
      end
    end
    table["sort"](U, function(a, C)
      return a["dist"] < C["dist"]
    end)
    local n = { ["plant"] = false, ["splice"] = false }
    for a, C in ipairs(U) do
      n[C["kind"]] = true
    end
    for O, U in ipairs(U) do
      if not sM then
        return false
      end
      local Y
      if C then
        Y = not a[U["kind"]]
      else
        Y = BM() <= 0
      end
      if Y then
        if Pp(U["obj"]) then
          a[U["kind"]] = true
        end
      end
    end
    if C then
      if Np() and ((a["plant"] or not n["plant"]) and (a["splice"] or not n["splice"])) then
        return true
      end
    else
      if BM() > 0 then
        return true
      end
    end
    if not SM(CM) then
      return false
    end
  end
  return Np()
end
local function up()
  if not sM then
    return false
  end
  if CRYYS_MODE ~= "splice" and BM() > 0 then
    return true
  end
  return ip({ ["plant"] = false, ["splice"] = false })
end
local function jp()
  if not sM then
    return false
  end
  pM("seed_search_current", "[AutoPlant] Seed = 0. Mencari floating seed di world saat ini...")
  if up() then
    xM("seed_search_current")
    d("[AutoPlant] Seed ditemukan di world saat ini.")
    return true
  end
  xM("seed_search_current")
  pM("take_current_empty", "[AutoPlant] Tidak ada seed di world saat ini.")
  return false
end
local function wp()
  if not sM then
    return
  end
  if not Lp() then
    local a = wM()
    d("[AutoPlant] Bukan Farm World. Planting diblokir.")
    if a and a["world"] ~= "" then
      Ip()
    end
    return
  end
  if BM() == 0 then
    pM("seed_zero", "[AutoPlant] Seed = 0")
    local a = jp()
    if not a then
      return
    end
    xM("seed_zero")
    return
  end
  local a = j()
  if next(a) == nil then
    pM("tiles_empty", "[AutoPlant] Data tile belum siap. Menunggu world load...")
    return
  end
  xM("tiles_empty")
  local C = {}
  for a, O in pairs(a) do
    if type(O) == "table" and Op(O) then
      C[#C + 1] = { ["x"] = O["x"], ["y"] = O["y"] }
    end
  end
  if #C == 0 then
    oM = 0
    local a = (wM())["world"]
    GM(a)
    pM("farm_done", "[AutoPlant] Farm '" .. (a .. "' selesai. Pindah ke farm berikutnya."))
    local C = MM()
    if not C then
      d("Semua world selesai, bot berhenti")
      pcall(Z, "Semua world selesai")
      sM = false
      CryysSyncToggle()
      return
    end
    local O = wM()
    d(
      "[AutoPlant] Farm berikutnya ["
        .. (tostring(NM["farmIndex"]) .. ("/" .. (tostring(#NM["farmList"]) .. ("]: " .. O["world"]))))
    )
    if kp(O["world"], O["door"], true) then
      xM("farm_done")
      xM("mode")
    end
    return
  end
  oM = 0
  xM("farm_done")
  table["sort"](C, function(a, C)
    if a["y"] == C["y"] then
      return a["x"] < C["x"]
    end
    return a["y"] < C["y"]
  end)
  pM("mode", "[AutoPlant] Planting...")
  for a, C in ipairs(C) do
    if not sM then
      return
    end
    if not Lp() then
      d("[AutoPlant] World berubah / bukan Farm. Planting dihentikan sementara.")
      Ip()
      return
    end
    if BM() == 0 then
      pM("seed_zero", "[AutoPlant] Seed = 0")
      local a = jp()
      if not a then
        return
      end
      xM("seed_zero")
      return
    end
    local O = VM()
    if not O then
      return
    end
    local U = w(C["x"], C["y"])
    if U and Op(U) then
      if Up(C["x"], C["y"]) then
        if not Lp() then
          d("[AutoPlant] Bukan Farm setelah movement. Plant dibatalkan.")
          return
        end
        local a = w(C["x"], C["y"])
        if a and Op(a) then
          np(C["x"], C["y"], O)
        end
      end
    end
  end
end
local function lp(a, C, O)
  if not sM then
    return false
  end
  if not Lp() then
    return false
  end
  local U = P()
  if not U then
    return false
  end
  local Y = { ["x"] = U["posX"], ["y"] = U["posY"], ["px"] = a, ["py"] = C, ["type"] = 3, ["value"] = O }
  X(false, Y)
  if not SM(NM["plant_delay"]) then
    return false
  end
  return true
end
local function Xp(a, C)
  local O, U, Y = 0, 0, 0
  for L, f in ipairs(a) do
    if not sM then
      return
    end
    if not Lp() then
      d("[AutoPlant] World berubah / bukan Farm. Splice dihentikan sementara.")
      for C = L, #a, 1 do
        rM[#rM + 1] = a[C]
      end
      Ip()
      return
    end
    if TM(C) <= 0 then
      d("[AutoPlant] Seed to Splice habis di tengah batch. Sisa disimpan, ambil seed dulu.")
      for C = L, #a, 1 do
        rM[#rM + 1] = a[C]
      end
      break
    end
    local n = w(f["x"], f["y"])
    local D = 0
    while sM and (n and (n["fg"] == 0 and D < (NM["splice_retry"] or 5))) do
      D = D + 1
      if not SM(NM["plant_delay"]) then
        return
      end
      n = w(f["x"], f["y"])
    end
    if n and n["fg"] == f["seed"] then
      local a = false
      for C = 1, 3, 1 do
        if not sM then
          return
        end
        if Up(f["x"], f["y"]) then
          a = true
          break
        end
        SM(300)
      end
      if a then
        local a = 0
        while sM and a < (NM["splice_retry"] or 5) do
          a = a + 1
          lp(f["x"], f["y"], C)
          local O = w(f["x"], f["y"])
          if not O or O["fg"] ~= f["seed"] then
            break
          end
        end
        local L = w(f["x"], f["y"])
        if L and (L["fg"] ~= 0 and L["fg"] ~= f["seed"]) then
          O = O + 1
        elseif L and L["fg"] == 0 then
          U = U + 1
        else
          Y = Y + 1
        end
      else
        Y = Y + 1
        d(
          "[AutoPlant] Tidak bisa sampai tile " .. (tostring(f["x"]) .. ("," .. (tostring(f["y"]) .. " untuk splice.")))
        )
      end
    end
  end
  d(
    "[AutoPlant] Splice batch selesai. Berhasil: "
      .. (tostring(O) .. (", gagal: " .. (tostring(U) .. (", belum jelas: " .. tostring(Y)))))
  )
end
local function Gp()
  if not sM then
    return
  end
  local a = bp()
  if a <= 0 then
    pM("splice_id", "[AutoPlant] Isi Seed to Splice dulu (mode Splice).")
    sM = false
    CryysSyncToggle()
    return
  end
  xM("splice_id")
  if BM() <= 0 or TM(a) <= 0 then
    if Lp() then
      pM("seed_zero", "[AutoPlant] Seed plant atau seed splice habis. Mengambil kedua seed...")
      local a = jp()
      if a then
        xM("seed_zero")
      else
        SM(3000)
      end
      return
    end
  end
  if not Lp() then
    local a = wM()
    d("[AutoPlant] Bukan Farm World. Splice diblokir.")
    if a and a["world"] ~= "" then
      Ip()
    end
    return
  end
  xM("seed_zero")
  if #rM > 0 then
    local C = lM((wM())["world"])
    local O = {}
    for a, U in ipairs(rM) do
      if lM(U["world"]) == C then
        O[#O + 1] = U
      end
    end
    rM = {}
    if #O > 0 then
      pM("mode", "[AutoPlant] Splice: melanjutkan " .. (tostring(#O) .. " seed yang sudah tertanam..."))
      Xp(O, a)
      return
    end
  end
  local C = j()
  if next(C) == nil then
    pM("tiles_empty", "[AutoPlant] Data tile belum siap. Menunggu world load...")
    return
  end
  xM("tiles_empty")
  local O = {}
  for a, C in pairs(C) do
    if type(C) == "table" and Op(C) then
      O[#O + 1] = { ["x"] = C["x"], ["y"] = C["y"] }
    end
  end
  if #O == 0 then
    oM = 0
    local a = (wM())["world"]
    GM(a)
    pM("farm_done", "[AutoPlant] Farm '" .. (a .. "' selesai. Pindah ke farm berikutnya."))
    local C = MM()
    if not C then
      d("Semua world selesai, bot berhenti")
      pcall(Z, "Semua world selesai")
      sM = false
      CryysSyncToggle()
      return
    end
    local O = wM()
    d(
      "[AutoPlant] Farm berikutnya ["
        .. (tostring(NM["farmIndex"]) .. ("/" .. (tostring(#NM["farmList"]) .. ("]: " .. O["world"]))))
    )
    if kp(O["world"], O["door"], true) then
      xM("farm_done")
      xM("mode")
    end
    return
  end
  oM = 0
  xM("farm_done")
  table["sort"](O, function(a, C)
    if a["y"] == C["y"] then
      return a["x"] < C["x"]
    end
    return a["y"] < C["y"]
  end)
  local U = NM["splice_batch"] or 10
  local Y = {}
  for a = 1, math["min"](U, #O), 1 do
    Y[#Y + 1] = O[a]
  end
  pM("mode", "[AutoPlant] Splice: planting " .. (tostring(#Y) .. " seed..."))
  local L = {}
  local f = (wM())["world"]
  for a, C in ipairs(Y) do
    if not sM then
      return
    end
    if not Lp() then
      d("[AutoPlant] World berubah / bukan Farm. Splice dihentikan sementara.")
      Ip()
      return
    end
    local O = VM()
    if not O then
      break
    end
    local U = w(C["x"], C["y"])
    if U and Op(U) then
      if Up(C["x"], C["y"]) then
        local a = w(C["x"], C["y"])
        if a and Op(a) then
          local a = false
          for U = 1, (NM["splice_retry"] or 5), 1 do
            if not sM then
              break
            end
            a = np(C["x"], C["y"], O)
            if a then
              break
            end
          end
          if a then
            L[#L + 1] = { ["x"] = C["x"], ["y"] = C["y"], ["seed"] = O, ["world"] = f }
          end
        end
      end
    end
  end
  Xp(L, a)
end
local function zp()
  if EM then
    return sM
  end
  EM = true
  Z("[AutoPlant] Disconnect terdeteksi. Bot dijeda, menunggu reconnect...")
  local a = false
  pcall(function()
    while sM and not a do
      while sM and P() == nil do
        N(500)
      end
      if not sM then
        return
      end
      local C = 0
      local O = 0
      while sM and O < 20000 do
        N(250)
        O = O + 250
        if P() == nil then
          C = 0
        else
          C = C + 250
          local a = h()
          if C >= 1500 and (a and a ~= "") then
            break
          end
          if C >= 6000 then
            break
          end
        end
      end
      if sM and P() ~= nil then
        Z("[AutoPlant] Reconnect terdeteksi (world: " .. (tostring(h() or "?") .. "). Masuk lagi ke farm..."))
        eM = {}
        WM = nil
        oM = 0
        local C = wM()
        if not C or C["world"] == "" then
          return
        end
        for O = 1, 6, 1 do
          if not sM or P() == nil then
            break
          end
          kp(C["world"], C["door"], true)
          if sM and (P() ~= nil and Lp()) then
            a = true
            break
          end
          N(1000)
        end
        if a then
          Z("[AutoPlant] Berhasil masuk lagi ke farm. Lanjut seperti biasa.")
        end
      end
    end
  end)
  EM = false
  KM = 0
  return a and sM
end
gM = zp
function mainLoop()
  JM = true
  local a, C = pcall(function()
    d("[AutoPlant] Started")
    do
      local a = {}
      for C, O in ipairs(NM["farmList"]) do
        a[#a + 1] = O["world"]
      end
      d("[AutoPlant] Farm World: " .. table["concat"](a, ", "))
      for a, C in ipairs(NM["farmList"]) do
        local O = C["door"]
        if O == "" then
          O = "-"
        end
        d("[AutoPlant] Farm " .. (tostring(a) .. (": " .. (C["world"] .. (" -> Door: " .. O)))))
      end
    end
    d("[AutoPlant] Seed ID: " .. table["concat"](NM["seedIDList"], ","))
    do
      local a = wM()
      if a["world"] ~= "" then
        oM = 0
        if not kp(a["world"], a["door"], true) then
          d("[AutoPlant] Initial Farm World belum terkonfirmasi. Akan dicoba lagi.")
        end
      end
    end
    d("[AutoPlant] Mode: " .. tostring(CRYYS_MODE))
    while sM do
      if P() == nil then
        if not zp() then
          break
        end
      else
        pcall((CRYYS_MODE == "splice") and Gp or wp)
        if not SM(A) then
          break
        end
      end
    end
  end)
  if not a then
    d("[AutoPlant] ERROR PENTING: " .. tostring(C))
    pcall(Z, "[AutoPlant] Error, cek log!")
  end
  JM = false
  d("[AutoPlant] Stopped")
  if sM and runThread then
    d("[AutoPlant] START diminta saat thread masih menutup. Menjalankan ulang...")
    pcall(runThread, mainLoop)
  end
end
d("[AutoPlant] Script loaded. Isi Farm World & Seed ID, lalu nyalakan toggle START.")
do
  function CryysShowPremium()
    if not q["ok"] then
      return
    end
    local a = "Growid"
    local C, O = pcall(P)
    if C and (O and (O["name"] and tostring(O["name"]) ~= "")) then
      a = tostring(O["name"])
    end
    local U = "========================"
    local Y = table["concat"](
      {
        "Welcome " .. a,
        U,
        "Status: Free",
        "",
        "Thank you for using the Free Script.",
        "Open Module UI to configure your script settings.",
        U,
      },
      "\n"
    )
    d("Auto Plant By Cryys - Status: Free")
    if sendDialog then
      pcall(
        sendDialog,
        { ["title"] = "Auto Plant By Cryys", ["alias"] = "plant_premium_dialog", ["message"] = Y, ["confirm"] = "OK" }
      )
    end
  end
  if runThread then
    runThread(function()
      N(1000)
      CryysShowPremium()
    end)
  else
    CryysShowPremium()
  end
end
