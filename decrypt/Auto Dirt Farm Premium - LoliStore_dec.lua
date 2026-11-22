local N = "https://lolistore-lic.ilhamwahyupurnomo79.workers.dev"
local X = "ilham214"
local v = "dfpremium"
local function j(N)
  LogToConsole("`5[LoliStore] `0" .. N)
  pcall(growtopia["notify"], (N:gsub("`.", "")))
end
local function h(N)
  return ((tostring(N)):gsub("([^%w%-%_%.%~])", function(N)
    return string["format"]("%%%02X", N:byte())
  end))
end
local a, e = pcall(getLocal)
local x = a and (e and (e["name"] and ((tostring(e["name"])):gsub("`.", "")):gsub("[^%w]", "")))
if not x or x == "" then
  j("`4Masuk ke world dulu, baru jalanin script.")
  return
end
local E = x:lower()
local function U()
  local N, X = pcall(function()
    local N = require("preferences")
    local X = N:new("lolistore_device.json")
    local v = X:get("did", "")
    if type(v) == "string" and (v:match("^%x+$") and #v >= 16) then
      return v
    end
    math["randomseed"](os["time"]() * 1000 + math["floor"]((os["clock"]() % 1) * 100000))
    local j = {}
    for N = 1, 32, 1 do
      j[N] = string["format"]("%x", math["random"](0, 15))
    end
    v = table["concat"](j)
    X:set("did", v)
    X:save()
    return v
  end)
  if N and type(X) == "string" then
    return X
  end
  return nil
end
local n = U()
if not n then
  j("`4Gagal bikin ID perangkat. Coba lagi.")
  return
end
j("Cek lisensi " .. (E .. "..."))
local B, I = fetch(N .. ("?act=get&key=" .. (h(X) .. ("&id=" .. (h(E) .. ("&s=" .. (h(v) .. ("&v=2&d=" .. n))))))))
if type(B) ~= "string" or B == "" then
  j("`4Server lisensi nggak bisa dihubungi: " .. tostring(I))
  return
end
if B:sub(1, 3) == "no|" or B:sub(1, 5) == "busy|" then
  local N = B:find("|", 1, true)
  j("`4Lisensi ditolak: " .. B:sub(N + 1, 120))
  return
end
if B:sub(1, 6) ~= "--LSOK" then
  j("`4Balasan server nggak dikenal, coba lagi nanti.")
  return
end
__LS_URL, __LS_KEY, __LS_DEV, __LS_PRODUCT = N, X, n, v
local g, p = load(B, "=LoliStore", "t")
if not g then
  j("`4Gagal muat script: " .. tostring(p))
  return
end
j("`2Lisensi OK, script dimuat.")
g()
