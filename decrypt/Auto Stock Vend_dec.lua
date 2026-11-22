local Y = {
  ["on"] = false,
  ["cancel"] = false,
  ["vendWorld"] = "",
  ["vendDoor"] = "",
  ["takeWorld"] = "",
  ["takeDoor"] = "",
  ["vendIds"] = "2978,9268",
  ["takeMax"] = 200,
  ["wrenchDelay"] = 700,
  ["idleWait"] = 60,
  ["verbose"] = false,
}
local p = 32
local v, x = pcall(require, "preferences")
local k = v and x:new("autovend_settings.json") or nil
local function j(Y, p)
  return tonumber(k and k:get(Y, tostring(p)) or p) or p
end
local function J(Y, p)
  local v = k and k:get(Y, p) or p
  return tostring(v or "")
end
Y["vendWorld"], Y["vendDoor"] = (J("vendWorld", "")):upper(), (J("vendDoor", "")):upper()
Y["takeWorld"], Y["takeDoor"] = (J("takeWorld", "")):upper(), (J("takeDoor", "")):upper()
Y["vendIds"] = J("vendIds", Y["vendIds"])
Y["takeMax"], Y["wrenchDelay"], Y["idleWait"] = j("takeMax", 200), j("wrenchDelay", 700), j("idleWait", 60)
Y["verbose"] = j("verbose", 0) == 1
Y["maxStock"] = j("maxStock", 5000)
Y["recheckMin"] = j("recheckMin", 30)
Y["black"] = {}
for p in (J("blacklist", "")):gmatch("%d+") do
  Y["black"][tonumber(p)] = true
end
local function y()
  local p = {}
  for Y, v in pairs(Y["black"]) do
    if v then
      p[#p + 1] = tostring(Y)
    end
  end
  table["sort"](p)
  if k then
    k:set("blacklist", table["concat"](p, ","))
    k:save()
  end
end
Y["autoStart"] = j("on", 0) == 1
local function I(Y, p)
  if k then
    k:set(Y, tostring(p))
    k:save()
  end
end
local function V(Y)
  LogToConsole("`9[`2RamStore`9] `cVend `0" .. Y)
end
local function l(p)
  if Y["verbose"] then
    V(p)
  end
end
local function w()
  if Y["cancel"] or not Y["on"] then
    error("__STOP__")
  end
end
local h = (tostring(RS_API or "https://api.ztoretopup.com")):gsub("/+$", "")
local q = (tostring(RS_DISCORD_ID or "")):gsub("%D", "")
if q == "" and getDiscordID then
  local Y, p = pcall(getDiscordID)
  if Y and p then
    q = (tostring(p)):gsub("%D", "")
  end
end
local C = { ["ok"] = false, ["pending"] = false, ["exp"] = 0, ["why"] = "" }
if q ~= "" and (tonumber(RS_EXPIRES) or 0) > os["time"]() then
  C["ok"], C["exp"] = true, tonumber(RS_EXPIRES)
end
local D = { ["ready"] = false, ["built"] = false }
local function A(Y)
  V(Y)
  pcall(function()
    growtopia["notify"]((Y:gsub("`.", "")))
  end)
end
local function B()
  if q == "" then
    C["ok"], C["why"] = false, "Login Discord dulu di Growlauncher"
    return false
  end
  C["pending"] = true
  local p
  for Y = 1, 3, 1 do
    local v, x = pcall(fetch, h .. ("/check?id=" .. (q .. "&s=AUTO_VEND")))
    if v and (type(x) == "string" and x ~= "") then
      p = x
      break
    end
    sleep(1000 * Y)
  end
  C["pending"] = false
  if not p then
    C["why"] = "Server RamStore tidak bisa dihubungi"
    return C["ok"]
  end
  local v = p:match("OK|(%d+)")
  if v then
    C["ok"], C["exp"], C["why"] = true, tonumber(v) or 0, ""
  else
    C["ok"], C["why"] = false, "Akses Auto Vend tidak aktif. Beli di Discord RamStore"
    if Y["on"] then
      Y["on"] = false
      Y["cancel"] = true
      pcall(editToggle, "Auto Vending", false)
    end
  end
  return C["ok"]
end
local function Z()
  if C["ok"] then
    return true
  end
  A("`4" .. (C["why"] ~= "" and C["why"] or "Akses Auto Vend tidak aktif. Beli di Discord RamStore"))
  return false
end
local function S()
  local Y = getLocal()
  if not Y then
    return nil
  end
  return Y["posX"] // 32, Y["posY"] // 32, Y
end
local function z(Y)
  local p, v = pcall(function()
    return growtopia["checkInventoryCount"](Y)
  end)
  if p and type(v) == "number" then
    return v
  end
  local x, k = pcall(getInventory)
  if x and type(k) == "table" then
    for p, v in pairs(k) do
      if v["id"] == Y then
        return v["amount"] or 0
      end
    end
  end
  return 0
end
local N = {}
local function O(Y)
  if N[Y] ~= nil then
    return N[Y] or ("ID " .. Y)
  end
  local p
  local v, x = pcall(function()
    return growtopia["getItemName"](Y)
  end)
  if v and (type(x) == "string" and x ~= "") then
    p = x
  end
  if not p then
    local v, x = pcall(getItemInfoByID, Y)
    if v and (type(x) == "table" and x["name"]) then
      p = tostring(x["name"])
    end
  end
  N[Y] = p or false
  return p or ("ID " .. Y)
end
local function G()
  local Y, p = pcall(GetWorldName)
  if Y and (p and p ~= "") then
    return (tostring(p)):upper()
  end
  local v, x = pcall(getWorld)
  if v and (type(x) == "table" and x["name"]) then
    return (tostring(x["name"])):upper()
  end
  return ""
end
local function W(Y, p)
  if not Y or Y == "" then
    return false
  end
  if G() == Y then
    return true
  end
  for v = 1, 3, 1 do
    l("Warp ke `9" .. Y)
    SendPacket(3, "action|join_request\nname|" .. (Y .. (((p ~= "" and ("|" .. p)) or "") .. "\ninvitedWorld|0")))
    local x = os["time"]()
    while os["time"]() - x < 20 do
      w()
      sleep(1000)
      if G() == Y and getLocal() then
        sleep(2000)
        return true
      end
    end
  end
  V("`4Gagal masuk world " .. Y)
  return false
end
local function t(Y, p)
  for v = 1, 3, 1 do
    w()
    local x, k = S()
    if x == Y and k == p then
      return true
    end
    pcall(FindPath, Y, p)
    local j = 0
    while j < 50 do
      sleep(100)
      j = j + 1
      x, k = S()
      if x == Y and k == p then
        return true
      end
    end
  end
  return false
end
local function E(Y, p)
  for v, x in ipairs({ { 0, 0 }, { -1, 0 }, { 1, 0 }, { 0, -1 } }) do
    if t(Y + x[1], p + x[2]) then
      return true
    end
  end
  return false
end
Y["want"], Y["dlg"] = false, nil
function vendVar(p)
  if Y["want"] and (p and p["v1"] == "OnDialogRequest") then
    local v = tostring(p["v2"] or "")
    local x = (v:gsub("`.", "")):lower()
    if
      x:find("vending")
      or x:find("vend machine")
      or x:find("digivend")
      or x:find("the machine contains")
      or x:find("this machine is empty")
    then
      Y["dlg"] = v
      Y["want"] = false
      return true
    end
  end
  return false
end
pcall(AddHook, vendVar, "OnVariant")
local function M(v, x)
  local k, j, J = S()
  if not J then
    return nil
  end
  Y["dlg"], Y["want"] = nil, true
  sendPacketRaw(false, { ["type"] = 3, ["value"] = p, ["x"] = J["posX"], ["y"] = J["posY"], ["px"] = v, ["py"] = x })
  local y = 0
  while Y["dlg"] == nil and y < 30 do
    sleep(100)
    y = y + 1
  end
  Y["want"] = false
  return Y["dlg"]
end
local function Q(Y)
  local p = Y:gsub("`.", "")
  local v = { ["raw"] = Y, ["clean"] = p }
  for Y in p:gmatch("[^\n]+") do
    if Y:find("contains a total of", 1, true) then
      v["stock"] = tonumber(Y:match("contains a total of (%d+)"))
      v["item"] = tonumber(Y:match("|left|(%d+)|")) or v["item"]
    end
    local p, x = Y:match("^add_button|([^|]+)|([^|]*)")
    if p and (x and (x:lower()):find("add them")) then
      v["addBtn"] = p
    end
  end
  v["dname"] = p:match("end_dialog|([^|]+)|")
  return v
end
local function f(Y, p)
  local v = ""
  for Y, p in Y["clean"]:gmatch("embed_data|([^|\n]+)|([^|\n]*)") do
    v = v .. (Y .. ("|" .. (p .. "|\n")))
  end
  for Y in Y["clean"]:gmatch("[^\n]+") do
    local p, x = Y:match("^add_text_input|([^|]+)|[^|]*|([^|]*)|")
    if p and x ~= "" then
      v = v .. (p .. ("|" .. (x .. "\n")))
    end
    local k, j = Y:match("^add_checkbox|([^|]+)|[^|]*|([01])")
    if k then
      v = v .. (k .. ("|" .. (j .. "\n")))
    end
  end
  SendPacket(
    2,
    "action|dialog_return\ndialog_name|" .. (Y["dname"] .. ("\n" .. (v .. ("buttonClicked|" .. (p .. "\n")))))
  )
end
local T = {}
local function U()
  T = {}
  for Y in (tostring(Y["vendIds"])):gmatch("%d+") do
    T[tonumber(Y)] = true
  end
end
local function n(Y)
  if not Y or Y == 0 then
    return false
  end
  if T[Y] then
    return true
  end
  local p = (O(Y)):lower()
  if p:find("vend", 1, true) then
    T[Y] = true
    return true
  end
  return false
end
local function c()
  local Y = {}
  local p, v = pcall(getTiles)
  if p and type(v) == "table" then
    for p, v in pairs(v) do
      local x, k = v["x"] or (v["pos"] and v["pos"]["x"]), v["y"] or (v["pos"] and v["pos"]["y"])
      if x and n(v["fg"]) then
        Y[#Y + 1] = { ["x"] = x, ["y"] = k }
      end
    end
  end
  table["sort"](Y, function(Y, p)
    if Y["y"] ~= p["y"] then
      return Y["y"] < p["y"]
    end
    return Y["x"] < p["x"]
  end)
  return Y
end
Y["machines"] = {}
Y["machWorld"] = ""
local function R()
  if Y["machWorld"] == "" then
    return
  end
  local p = {}
  for Y, v in pairs(Y["machines"]) do
    if v["item"] then
      p[#p + 1] = v["x"] .. (
          ":" .. (v["y"] .. (":" .. (v["item"] .. (":" .. ((v["stock"] or 0) .. (":" .. (v["t"] or 0)))))))
        )
    end
  end
  I("mach_" .. Y["machWorld"], table["concat"](p, ";"))
end
local function o(p)
  if Y["machWorld"] == p then
    return
  end
  Y["machWorld"], Y["machines"] = p, {}
  for p, v, x, k, j in (J("mach_" .. p, "")):gmatch("(%d+):(%d+):(%d+):(%d+):(%d+)") do
    Y["machines"][p .. (":" .. v)] =
      { ["x"] = tonumber(p), ["y"] = tonumber(v), ["item"] = tonumber(x), ["stock"] = tonumber(k), ["t"] = tonumber(j) }
  end
end
local function X(p, v)
  if not p or not p["item"] then
    return false
  end
  if Y["black"][p["item"]] then
    return "blacklist"
  end
  local x = os["time"]() - (p["t"] or 0) < Y["recheckMin"] * 60
  if Y["maxStock"] > 0 and ((p["stock"] or 0) >= Y["maxStock"] and x) then
    return "penuh"
  end
  if v and z(p["item"]) <= 0 then
    return "tidak ada di tas"
  end
  return false
end
local function K(p)
  if not W(Y["vendWorld"], Y["vendDoor"]) then
    error("__STOP__")
  end
  pcall(editToggle, "Anticollect", false)
  o(G())
  local v = c()
  if #v == 0 then
    V("`4Tidak ada Vending / DigiVend di " .. G())
    return 0
  end
  local x = 0
  for v, k in ipairs(v) do
    w()
    local j = k["x"] .. (":" .. k["y"])
    local J = Y["machines"][j]
    local y = X(J, p)
    if y then
      l("Lewati X" .. (k["x"] .. (" Y" .. (k["y"] .. (" (" .. (y .. ")"))))))
      goto continue
    end
    if not E(k["x"], k["y"]) then
      l("`6Mesin X" .. (k["x"] .. (" Y" .. (k["y"] .. " tidak kejangkau"))))
      goto continue
    end
    sleep(200)
    do
      local v = M(k["x"], k["y"])
      if not v then
        l("`6Mesin X" .. (k["x"] .. (" Y" .. (k["y"] .. " tidak ada dialog"))))
        goto continue
      end
      local y = Q(v)
      if y["item"] then
        Y["machines"][j] =
          { ["x"] = k["x"], ["y"] = k["y"], ["item"] = y["item"], ["stock"] = y["stock"] or 0, ["t"] = os["time"]() }
        R()
      end
      if y["item"] and Y["black"][y["item"]] then
        goto continue
      end
      if p and (y["addBtn"] and y["dname"]) then
        local p = y["item"] or (J and J["item"])
        local v = p and z(p) or 0
        sleep(300 + math["random"](0, 200))
        f(y, y["addBtn"])
        sleep(Y["wrenchDelay"])
        local I = M(k["x"], k["y"])
        local l = I and Q(I) or nil
        if l then
          Y["machines"][j]["stock"] = l["stock"] or Y["machines"][j]["stock"]
          if l["item"] then
            Y["machines"][j]["item"] = l["item"]
          end
          Y["machines"][j]["t"] = os["time"]()
          R()
        end
        local w = p and z(p) or 0
        if v > w then
          x = x + (v - w)
          V(
            "`2+"
              .. (
                (v - w)
                .. (
                  " "
                  .. (
                    (p and O(p) or "item")
                    .. (
                      "`0 -> X"
                      .. (
                        k["x"] .. (" Y" .. (k["y"] .. (l and (l["stock"] and (" \194\183 stok " .. l["stock"])) or "")))
                      )
                    )
                  )
                )
              )
          )
        end
      elseif not y["item"] then
        l("`6Mesin X" .. (k["x"] .. (" Y" .. (k["y"] .. " kosong / item tidak kebaca, lewati"))))
      end
    end
    sleep(Y["wrenchDelay"])
    ::continue::
  end
  return x
end
local function d()
  local p, v = {}, 0
  for x, k in pairs(Y["machines"]) do
    if k["item"] and (not p[k["item"]] and (not Y["black"][k["item"]] and not X(k, false))) then
      p[k["item"]] = true
      v = v + 1
    end
  end
  return p, v
end
local function b()
  local p, v = d()
  if v == 0 then
    V("`6Belum tahu item apa yang dijual (mesin kosong semua?)")
    return 0
  end
  if not W(Y["takeWorld"], Y["takeDoor"]) then
    error("__STOP__")
  end
  pcall(editToggle, "Anticollect", false)
  local x, k, j = 0, {}, 0
  while j < 120 do
    w()
    local v, J = pcall(getObjectList)
    if not v or type(J) ~= "table" then
      break
    end
    local y, I, V = S()
    local h, q
    for v, x in pairs(J) do
      local j = x["itemid"]
      local J = x["posX"] or (x["pos"] and x["pos"]["x"])
      local y = x["posY"] or (x["pos"] and x["pos"]["y"])
      if j and (p[j] and (not k[x["id"]] and (J and z(j) < Y["takeMax"]))) then
        local Y = math["abs"](J - V["posX"]) + math["abs"](y - V["posY"])
        if not q or Y < q then
          h, q = { ["o"] = x, ["x"] = J, ["y"] = y }, Y
        end
      end
    end
    if not h then
      break
    end
    local C = h["o"]["itemid"]
    local D = z(C)
    local A, B = math["floor"]((h["x"] + 8) / 32), math["floor"]((h["y"] + 8) / 32)
    if t(A, B) then
      local Y = 0
      while z(C) <= D and Y < 12 do
        sleep(100)
        Y = Y + 1
      end
      if z(C) <= D then
        sendPacketRaw(false, { ["type"] = 11, ["value"] = h["o"]["id"], ["x"] = h["x"], ["y"] = h["y"] })
        Y = 0
        while z(C) <= D and Y < 10 do
          sleep(100)
          Y = Y + 1
        end
      end
    end
    if z(C) > D then
      x = x + (z(C) - D)
      l("Ambil " .. ((z(C) - D) .. (" " .. O(C))))
    else
      k[h["o"]["id"]] = true
    end
    j = j + 1
    sleep(150)
  end
  if x > 0 then
    V("Ambil item total " .. x)
  end
  return x
end
local function F()
  local Y = d()
  for Y in pairs(Y) do
    if z(Y) > 0 then
      return true
    end
  end
  return false
end
local function m()
  U()
  if Y["vendWorld"] == "" then
    Y["vendWorld"] = G()
    I("vendWorld", Y["vendWorld"])
  end
  if Y["takeWorld"] == "" then
    V("`4Isi World Ambil Item dulu")
    error("__STOP__")
  end
  K(true)
  while true do
    w()
    local Y = b()
    if Y <= 0 and not F() then
      break
    end
    local p = K(true)
    if p <= 0 and Y <= 0 then
      break
    end
  end
end
local P = false
function vendLoop()
  runThread(function()
    while P do
      sleep(200)
    end
    if not Y["on"] then
      return
    end
    Y["cancel"], P = false, true
    local p = 0
    while Y["on"] and not Y["cancel"] do
      local v, x = pcall(m)
      if not Y["on"] or Y["cancel"] then
        break
      end
      if not v and not (tostring(x)):find("__STOP__") then
        V("`4Error: " .. tostring(x))
      end
      p = p + 1
      if p == 1 or p % 10 == 0 then
        V("`6Barang habis / selesai. Toggle tetap ON, cek lagi tiap " .. (Y["idleWait"] .. " detik"))
      end
      for p = 1, math["max"](Y["idleWait"], 10), 1 do
        if not Y["on"] or Y["cancel"] then
          break
        end
        sleep(1000)
      end
    end
    P = false
  end)
end
function scanMachines()
  if Y["vendWorld"] == "" then
    Y["vendWorld"] = G()
    I("vendWorld", Y["vendWorld"])
  end
  U()
  if not W(Y["vendWorld"], Y["vendDoor"]) then
    error("__STOP__")
  end
  o(G())
  local p = c()
  V("Cek isi " .. (#p .. " mesin..."))
  local v = 0
  for p, x in ipairs(p) do
    if E(x["x"], x["y"]) then
      sleep(200)
      local p = M(x["x"], x["y"])
      local k = p and Q(p)
      if k and k["item"] then
        Y["machines"][x["x"] .. (":" .. x["y"])] =
          { ["x"] = x["x"], ["y"] = x["y"], ["item"] = k["item"], ["stock"] = k["stock"] or 0, ["t"] = os["time"]() }
        v = v + 1
      end
      sleep(Y["wrenchDelay"])
    end
  end
  R()
  V("`2Selesai cek: " .. (v .. " mesin kebaca"))
  showPick()
end
function showPick()
  o(Y["vendWorld"])
  local p, v = {}, {}
  for Y, x in pairs(Y["machines"]) do
    if x["item"] then
      if not p[x["item"]] then
        p[x["item"]] = 0
        v[#v + 1] = x["item"]
      end
      p[x["item"]] = p[x["item"]] + (x["stock"] or 0)
    end
  end
  if #v == 0 then
    V("`6Belum ada data mesin. Tekan Cek Isi Mesin dulu")
    return
  end
  table["sort"](v, function(Y, p)
    return O(Y) < O(p)
  end)
  local x =
    "set_default_color|`o\nadd_label_with_icon|big|`wPilih Item Vending``|left|9268|\nadd_textbox|Centang = diisi otomatis. Hilangkan centang kalau tidak mau.|left|\nadd_spacer|small|\n"
  for v, k in ipairs(v) do
    x = x
      .. (
        "add_checkbox|avi_"
        .. (k .. ("|" .. (O(k) .. (" `8(stok " .. (p[k] .. (")``|" .. ((Y["black"][k] and "0" or "1") .. "|\n")))))))
      )
  end
  x = x .. "end_dialog|av_pick|Batal|Simpan|\n"
  pcall(sendVariant, { ["v1"] = "OnDialogRequest", ["v2"] = x })
end
function vendPickSend(p, v)
  local x = type(p) == "string" and p or (type(v) == "string" and v or "")
  if not x:find("dialog_name|av_pick", 1, true) then
    return false
  end
  local k, j = 0, 0
  for p, v in x:gmatch("avi_(%d+)|([01])") do
    local x = tonumber(p)
    if v == "1" then
      Y["black"][x] = nil
      k = k + 1
    else
      Y["black"][x] = true
      j = j + 1
    end
  end
  if k + j > 0 then
    y()
    V("Disimpan: `2" .. (k .. (" item diurus`0, `4" .. (j .. " dilewati"))))
  end
  return true
end
pcall(AddHook, vendPickSend, "onSendPacket")
local function r(Y)
  local p = type(Y["addDialog"]) == "function"
    and (
      type(Y["addChildInputString"]) == "function"
      and (type(Y["addChildToggle"]) == "function" and type(Y["addChildTooltip"]) == "function")
    )
  local v = {}
  function v.settings(v)
    if p then
      local p, x = pcall(Y["addDialog"], Y, v, "Klik untuk buka pengaturan", {})
      if p and (type(x) == "table" and x["menu"]) then
        return x["menu"]
      end
    end
    Y:addDivider()
    Y:addLabel(v)
  end
  function v.tog(p, v, x, k)
    if p then
      Y:addChildToggle(p, v, x, k, false)
    else
      Y:addToggle(v, x, k, false)
    end
  end
  function v.inp(p, v, x, k, j, J)
    if p then
      Y:addChildInputString(p, v, x, k, j, "Info", J)
    else
      Y:addInputString(v, x, k, j, "Info", J)
    end
  end
  function v.tip(p, v, x)
    if p then
      Y:addChildTooltip(p, v, x, "Info", false)
    else
      Y:addTooltip(v, x, "Info", false)
    end
  end
  return v
end
local function a(p)
  local v = r(p)
  p:addTooltip(
    "Information",
    "Ambil barang di World Ambil Item, warp ke World Vending, wrench mesin -> Add them to the machine, lalu wrench lagi cek stok. Harga tidak diubah // RamStore",
    "Info",
    false
  )
  local x = v["settings"]("World Setting")
  v["tip"](x, "World", "World Vending = tempat mesin jualan. World Ambil Item = tempat barang ditaruh di lantai.")
  v["inp"](x, "World Vending", Y["vendWorld"], "nama world jualan", "Nama World", "av_vendWorld")
  v["inp"](x, "Door Vending", Y["vendDoor"], "door id (boleh kosong)", "ID Door", "av_vendDoor")
  v["inp"](x, "World Ambil Item", Y["takeWorld"], "nama world barang", "Nama World", "av_takeWorld")
  v["inp"](x, "Door Ambil Item", Y["takeDoor"], "door id (boleh kosong)", "ID Door", "av_takeDoor")
  local k = v["settings"]("Vending Setting")
  v["tip"](
    k,
    "Vending",
    "Item yang diambil = item yang sudah dijual di tiap mesin (dibaca waktu wrench). Mesin kosong dilewati."
  )
  v["inp"](
    k,
    "Item ID Mesin Vending",
    Y["vendIds"],
    "pisah koma (nama ada 'Vend' otomatis ikut)",
    "2978,9268",
    "av_vendIds"
  )
  v["inp"](k, "Ambil per Item", tostring(Y["takeMax"]), "maks di tas per item", "200", "av_takeMax")
  v["inp"](k, "Delay Wrench (ms)", tostring(Y["wrenchDelay"]), "jeda antar wrench", "700", "av_wrenchDelay")
  v["inp"](k, "Cek Lagi Tiap (detik)", tostring(Y["idleWait"]), "kalau barang habis", "60", "av_idleWait")
  v["inp"](
    k,
    "Stok Penuh (Max)",
    tostring(Y["maxStock"]),
    "stok >= ini tidak di-wrench lagi (0 = off)",
    "5000",
    "av_maxStock"
  )
  v["inp"](
    k,
    "Cek Ulang Mesin Penuh (menit)",
    tostring(Y["recheckMin"]),
    "stok bisa turun karena kebeli",
    "30",
    "av_recheckMin"
  )
  p:addDivider()
  p:addToggle("Auto Vending", Y["autoStart"], "av_on", false)
  p:addToggle("Log Detail (debug)", Y["verbose"], "av_verbose", false)
  p:addDivider()
  p:addButton("Pakai World Ini Buat World Vending", "av_setVend")
  p:addButton("Pakai World Ini Buat World Ambil Item", "av_setTake")
  p:addButton("Cek Isi Mesin", "av_scan")
  p:addButton("Pilih Item (centang)", "av_pick")
end
local function e(Y)
  Y:addLabelApp("AutoVend", "Article")
  if not C["ok"] then
    Y:addTooltip(
      "Akses",
      (C["why"] ~= "" and C["why"] or "Akses Auto Vend tidak aktif") .. ". Akses pakai Discord ID (tanpa key).",
      "Info",
      false
    )
  end
end
function buildVendFeatures()
  if not C["ok"] or D["built"] then
    return
  end
  D["built"] = true
  local p = UserInterface["new"]("AutoVend Menu", "Article")
  a(p)
  addIntoModule(p:generateJSON(), "AutoVend")
  if Y["autoStart"] and not Y["on"] then
    Y["on"] = true
    V("`2Auto Vending masih ON dari sebelumnya, lanjut jalan")
    vendLoop()
  end
end
local u = OnValue
function OnValue(p, v, x)
  if (tostring(v)):sub(1, 3) ~= "av_" then
    if u then
      return u(p, v, x)
    end
    return
  end
  if not C["ok"] and (v == "av_on" and x or v == "av_scan") then
    pcall(editToggle, "Auto Vending", false)
    Z()
    return
  end
  if v == "av_on" then
    Y["on"] = x and true or false
    I("on", Y["on"] and 1 or 0)
    if not Y["on"] then
      Y["cancel"] = true
      V("`4OFF")
      return
    end
    vendLoop()
  elseif v == "av_verbose" then
    Y["verbose"] = x and true or false
    I("verbose", Y["verbose"] and 1 or 0)
  elseif v == "av_setVend" or v == "av_setTake" then
    local p = G()
    if p == "" then
      return
    end
    local x = (v == "av_setVend") and "vendWorld" or "takeWorld"
    Y[x] = p
    I(x, p)
    V((x == "vendWorld" and "World Vending" or "World Ambil Item") .. (" = `9" .. p))
  elseif v == "av_vendWorld" or v == "av_vendDoor" or v == "av_takeWorld" or v == "av_takeDoor" then
    local p = v:sub(4)
    Y[p] = ((tostring(x or "")):gsub("%s", "")):upper()
    I(p, Y[p])
  elseif v == "av_scan" then
    if P then
      V("`6Matikan Auto Vending dulu, baru Cek Isi Mesin")
      return
    end
    runThread(function()
      Y["on"], Y["cancel"] = true, false
      local p, v = pcall(scanMachines)
      Y["on"] = false
      if not p and not (tostring(v)):find("__STOP__") then
        V("`4Error: " .. tostring(v))
      end
    end)
  elseif v == "av_pick" then
    showPick()
  elseif v == "av_vendIds" then
    Y["vendIds"] = tostring(x or "")
    I("vendIds", Y["vendIds"])
  else
    local p = v:sub(4)
    local k = tonumber(((tostring(x or "")):gsub("%s", "")))
    if Y[p] ~= nil and (k and k >= 0) then
      Y[p] = math["floor"](k)
      I(p, Y[p])
    end
  end
end
runThread(function()
  sleep(3000)
  if not C["ok"] then
    B()
  end
  if C["ok"] then
    V("`2Akses aktif")
  else
    V("`4" .. (C["why"] ~= "" and C["why"] or "Akses tidak aktif"))
  end
  local p, v = pcall(function()
    local Y = UserInterface["new"]("AutoVend", "Article")
    e(Y)
    if C["ok"] then
      D["built"] = true
      a(Y)
    end
    addCategory("AutoVend", "Article")
    addIntoModule(Y:generateJSON(), "AutoVend")
  end)
  D["ready"] = true
  if not p then
    V("`4Menu gagal dibuat: " .. tostring(v))
    return
  end
  if C["ok"] and Y["autoStart"] then
    sleep(2000)
    Y["on"] = true
    V("`2Auto Vending masih ON dari sebelumnya, lanjut jalan")
    vendLoop()
  end
  local x = os["time"]()
  while true do
    sleep(5000)
    if Y["on"] and not C["ok"] then
      Y["on"] = false
      Y["cancel"] = true
    end
    if os["time"]() - x >= 1800 then
      x = os["time"]()
      B()
    end
  end
end)
applyHook()
V("siap. Buka menu AutoVend")
