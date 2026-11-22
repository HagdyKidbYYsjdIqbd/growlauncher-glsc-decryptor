local O = "https://lolistore-lic.ilhamwahyupurnomo79.workers.dev"
local D = "ilham214"
local K = "rotasi"
local function T(O)
  LogToConsole("`5[LoliStore] `0" .. O)
  pcall(growtopia["notify"], (O:gsub("`.", "")))
end
local function A(O)
  return ((tostring(O)):gsub("([^%w%-%_%.%~])", function(O)
    return string["format"]("%%%02X", O:byte())
  end))
end
local G, q = pcall(getLocal)
local p = G and (q and (q["name"] and ((tostring(q["name"])):gsub("`.", "")):gsub("[^%w]", "")))
if not p or p == "" then
  T("`4Masuk ke world dulu, baru jalanin script.")
  return
end
local B = p:lower()
local function t()
  local O, D = pcall(function()
    local O = require("preferences")
    local D = O:new("lolistore_device.json")
    local K = D:get("did", "")
    if type(K) == "string" and (K:match("^%x+$") and #K >= 16) then
      return K
    end
    math["randomseed"](os["time"]() * 1000 + math["floor"]((os["clock"]() % 1) * 100000))
    local T = {}
    for O = 1, 32, 1 do
      T[O] = string["format"]("%x", math["random"](0, 15))
    end
    K = table["concat"](T)
    D:set("did", K)
    D:save()
    return K
  end)
  if O and type(D) == "string" then
    return D
  end
  return nil
end
local W = t()
if not W then
  T("`4Gagal bikin ID perangkat. Coba lagi.")
  return
end
T("Cek lisensi " .. (B .. "..."))
local S, U = fetch(O .. ("?act=get&key=" .. (A(D) .. ("&id=" .. (A(B) .. ("&s=" .. (A(K) .. ("&v=2&d=" .. W))))))))
if type(S) ~= "string" or S == "" then
  T("`4Server lisensi nggak bisa dihubungi: " .. tostring(U))
  return
end
if S:sub(1, 3) == "no|" or S:sub(1, 5) == "busy|" then
  local O = S:find("|", 1, true)
  T("`4Lisensi ditolak: " .. S:sub(O + 1, 120))
  return
end
if S:sub(1, 6) ~= "--LSOK" then
  T("`4Balasan server nggak dikenal, coba lagi nanti.")
  return
end
__LS_URL, __LS_KEY, __LS_DEV, __LS_PRODUCT = O, D, W, K
local R, C = load(S, "=LoliStore", "t")
if not R then
  T("`4Gagal muat script: " .. tostring(C))
  return
end
T("`2Lisensi OK, script dimuat.")
R()
