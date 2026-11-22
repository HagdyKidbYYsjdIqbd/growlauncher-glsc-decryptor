local B = "https://lolistore-lic.ilhamwahyupurnomo79.workers.dev"
local d = "ilham214"
local n = "rotasi"
local C = 3
local function o(B)
  LogToConsole("`5[LoliStore] `0" .. B)
  pcall(growtopia["notify"], (B:gsub("`.", "")))
end
local function R(B)
  return ((tostring(B)):gsub("([^%w%-%_%.%~])", function(B)
    return string["format"]("%%%02X", B:byte())
  end))
end
local L, v = pcall(getLocal)
local a = L and (v and (v["name"] and ((tostring(v["name"])):gsub("`.", "")):gsub("[^%w]", "")))
if not a or a == "" then
  o("`4Masuk ke world dulu, baru jalanin script.")
  return
end
local y = a:lower()
local function K()
  local B, d = pcall(function()
    local B = require("preferences")
    local d = B:new("lolistore_device.json")
    local n = d:get("did", "")
    if type(n) == "string" and (n:match("^%x+$") and #n >= 16) then
      return n
    end
    math["randomseed"](os["time"]() * 1000 + math["floor"]((os["clock"]() % 1) * 100000))
    local C = {}
    for B = 1, 32, 1 do
      C[B] = string["format"]("%x", math["random"](0, 15))
    end
    n = table["concat"](C)
    d:set("did", n)
    d:save()
    return n
  end)
  if B and type(d) == "string" then
    return d
  end
  return nil
end
local s = K()
if not s then
  o("`4Gagal bikin ID perangkat. Coba lagi.")
  return
end
local q = B .. ("?act=get&key=" .. (R(d) .. ("&id=" .. (R(y) .. ("&s=" .. (R(n) .. ("&v=2&d=" .. s)))))))
local O, Z
for B = 1, C, 1 do
  o("Cek lisensi " .. (y .. ("..." .. (B > 1 and (" (coba lagi " .. (B .. ("/" .. (C .. ")")))) or ""))))
  local d, n, R = pcall(fetch, q)
  if not d then
    n, R = nil, n
  end
  O, Z = n, R
  local L = type(O) ~= "string" or O == "" or O:sub(1, 5) == "busy|" or O == "no|server lagi gangguan, coba lagi"
  if not L then
    break
  end
  if B < C then
    LogToConsole("`5[LoliStore] `4Server lisensi belum jawab (" .. (tostring(Z or O) .. "), coba lagi...`0"))
  end
end
if type(O) ~= "string" or O == "" then
  o("`4Server lisensi nggak bisa dihubungi: " .. (tostring(Z) .. ". Cek internet, terus jalanin script lagi."))
  return
end
if O:sub(1, 3) == "no|" or O:sub(1, 5) == "busy|" then
  local B = O:find("|", 1, true)
  o("`4Lisensi ditolak: " .. O:sub(B + 1, 120))
  return
end
if O:sub(1, 6) ~= "--LSOK" then
  local B = ((O:sub(1, 70)):gsub("%c", "?")):gsub("`", "'")
  o("`4DEBUG balasan: panjang=" .. (#O .. (" | awal=[" .. (B .. ("] | hex=" .. ((O:sub(1, 8)):gsub(".", function(B)
    return string["format"]("%02x", B:byte())
  end)))))))
  return
end
__LS_URL, __LS_KEY, __LS_DEV, __LS_PRODUCT = B, d, s, n
local i, b = load(O, "=LoliStore", "t")
if not i then
  o("`4Gagal muat script: " .. tostring(b))
  return
end
o("`2Lisensi OK. Mulai menjalankan script rotasi.")
local J, D = xpcall(i, function(B)
  local d = tostring(B)
  if debug and type(debug["traceback"]) == "function" then
    return debug["traceback"](d, 2)
  end
  return d
end)
if not J then
  o("`4[ROTASI DEBUG] Startup gagal. Lihat detail di console.")
  for B in (tostring(D)):gmatch("[^\r\n]+") do
    LogToConsole("[ROTASI DEBUG] " .. B)
  end
  return
end
LogToConsole("[ROTASI DEBUG] Eksekusi awal selesai.")
