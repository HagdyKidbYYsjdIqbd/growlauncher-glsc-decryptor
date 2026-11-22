local R = "https://raspy-dawn-3465.rzkaelah.workers.dev/"
local H = "marvel_key.txt"
LD = LD or { ["run"] = 0 }
LD["run"] = LD["run"] + 1
local m = LD["run"]
__MP_LIC = __MP_LIC or { ["ok"] = false, ["key"] = nil, ["left"] = 0, ["last"] = 0, ["busy"] = false }
local T = __MP_LIC
local C = {
  ["invalid"] = "`9Invalid key.",
  ["expired"] = "`9This key has expired.",
  ["device"] = "`9This key is already used on another device. Ask the admin for a reset.",
  ["missing"] = "`9Key is empty.",
  ["server"] = "`9Server error, please try again.",
  ["net"] = "`9Could not connect to the license server.",
  ["nofunc"] = "`9Your Growlauncher cannot run this script.",
  ["nogid"] = "`9This key has no GrowID yet. Open Discord > #getkey > Set GrowID first.",
  ["growid"] = "`9This key is registered to another GrowID. Use Change GrowID in Discord.",
}
local function q(R)
  pcall(LogToConsole, "`0[ `wMARVELUS`3PROXY `0] " .. R)
  pcall(function()
    ((sendVariant or SendVariant))({ ["v1"] = "OnTextOverlay", ["v2"] = "`wMARVELUS`3PROXY `0: " .. R }, nil, -1)
  end)
end
local W = {
  "getDeviceID",
  "GetDeviceID",
  "getDeviceId",
  "getHWID",
  "GetHWID",
  "getHwid",
  "getAndroidID",
  "GetAndroidID",
  "getUniqueID",
  "getUniqueId",
  "getMachineID",
  "getHardwareID",
  "getDeviceUID",
}
local r, h
local function X()
  local R = "marvel_dev.txt"
  local H = {
    "",
    "./",
    "/storage/emulated/0/",
    "/sdcard/",
    "/storage/emulated/0/Download/",
    "/storage/emulated/0/Android/data/com.rtsoft.growtopia/files/",
    "/storage/emulated/0/Android/media/",
  }
  local function m()
    for H, m in ipairs(H) do
      local T, C = pcall(function()
        local H = io["open"](m .. R, "r")
        if not H then
          return nil
        end
        local T = H:read("*l")
        H:close()
        return T
      end)
      if T and type(C) == "string" then
        C = C:gsub("%s+", "")
        if #C == 26 and C:match("^MP%x+$") then
          return C
        end
      end
    end
  end
  local function T(m)
    for H, T in ipairs(H) do
      pcall(function()
        local H = io["open"](T .. R, "w")
        if not H then
          error("x")
        end
        H:write(m)
        H:close()
      end)
    end
    if type(writeToLocal) == "function" then
      pcall(writeToLocal, R, m)
    end
  end
  local C = m()
  if C then
    T(C)
    return C
  end
  math["randomseed"](os["time"]() * 1000 + math["floor"](os["clock"]() * 100000))
  local q = { "MP" }
  for R = 1, 24, 1 do
    q[#q + 1] = string["format"]("%x", math["random"](0, 15))
  end
  C = table["concat"](q)
  T(C)
  return m()
end
local function k()
  if r then
    return r, h
  end
  for R, H in ipairs(W) do
    local m = _G[H]
    if type(m) == "function" then
      local R, H = pcall(m)
      if R and (H and tostring(H) ~= "") then
        r, h = tostring(H), "device"
        return r, h
      end
    end
  end
  local R = X()
  if R then
    r, h = R, "device"
    return r, h
  end
  local H, m = pcall(GetLocal or getLocal)
  if H and m then
    local R = m["userid"] or m["userID"]
    if R and R ~= 0 then
      r, h = "uid" .. tostring(R), "account"
      return r, h
    end
  end
end
local function P()
  for R = 1, 8, 1 do
    local H, m = pcall(GetLocal or getLocal)
    if H and (type(m) == "table" and m["name"]) then
      local R = ((tostring(m["name"])):gsub("`.", "")):gsub("%s+", "")
      if R ~= "" then
        return R
      end
    end
    local T = sleep or Sleep
    if type(T) == "function" then
      pcall(T, 1000)
    else
      break
    end
  end
end
local function o(R, H)
  if type(R) == "string" and R ~= "" then
    return R
  end
  if type(R) == "table" then
    for H, m in ipairs({ "content", "body", "data", "text", "response", "result" }) do
      local T = R[m]
      if type(T) == "function" then
        local H, m = pcall(T, R)
        T = H and m or nil
      end
      if type(T) == "string" and T ~= "" then
        return T
      end
    end
  end
  if type(H) == "string" and H ~= "" then
    return H
  end
end
local function Z(R)
  local H = {
    "makeRequest",
    "MakeRequest",
    "makerequest",
    "httpGet",
    "HttpGet",
    "httpRequest",
    "HttpRequest",
    "http_get",
    "httpget",
    "fetch",
    "getUrl",
    "GetUrl",
    "webRequest",
    "WebRequest",
    "request",
    "Request",
  }
  local m = { { R }, { { ["url"] = R, ["headers"] = {} } }, { R, "GET", {} }, { R, "GET" } }
  for R, H in ipairs(H) do
    local T = _G[H]
    if type(T) == "function" then
      for R, H in ipairs(m) do
        local m, C, q = pcall(T, table["unpack"](H))
        if m then
          local R = o(C, q)
          if R then
            return R
          end
        end
      end
    end
  end
  for R, H in ipairs({ "http", "Http", "HTTP", "requests", "Requests", "web", "Web", "net", "Net" }) do
    local T = _G[H]
    if type(T) == "table" then
      for R, H in ipairs({ "get", "Get", "request", "Request", "fetch" }) do
        if type(T[H]) == "function" then
          for R, m in ipairs(m) do
            local C, q, W = pcall(T[H], table["unpack"](m))
            if C then
              local R = o(q, W)
              if R then
                return R
              end
            end
          end
        end
      end
    end
  end
end
local function G(R)
  return ((tostring(R)):gsub("[^%w%-_%.~]", function(R)
    return string["format"]("%%%02X", R:byte())
  end))
end
local U = {
  H,
  "./" .. H,
  "/storage/emulated/0/" .. H,
  "/sdcard/" .. H,
  "/storage/emulated/0/Android/data/com.rtsoft.growtopia/files/" .. H,
  "/storage/emulated/0/Download/" .. H,
}
local I = {
  { "writeFile", "readFile" },
  { "WriteFile", "ReadFile" },
  { "writefile", "readfile" },
  { "saveFile", "loadFile" },
  { "SaveFile", "LoadFile" },
  { "saveToFile", "loadFromFile" },
  { "writeToFile", "readFromFile" },
  { "WriteToFile", "ReadFromFile" },
}
local function L(R)
  for H, m in ipairs(U) do
    pcall(function()
      local H = io["open"](m, "w")
      if not H then
        error("x")
      end
      H:write(R)
      H:close()
    end)
  end
  for m, T in ipairs(I) do
    local C = _G[T[1]]
    if type(C) == "function" then
      pcall(C, H, R)
    end
  end
end
local function t()
  for R, H in ipairs(U) do
    local m, T = pcall(function()
      local R = io["open"](H, "r")
      if not R then
        return nil
      end
      local m = R:read("*l")
      R:close()
      return m
    end)
    if m and type(T) == "string" then
      T = T:gsub("%s+", "")
      if T ~= "" then
        return T
      end
    end
  end
  for R, m in ipairs(I) do
    local T = _G[m[2]]
    if type(T) == "function" then
      local R, m = pcall(T, H)
      if R and type(m) == "string" then
        m = m:gsub("%s+", "")
        if m ~= "" then
          return m
        end
      end
    end
  end
end
local function w(H)
  local m, W = k()
  if not m then
    q("`9Device ID not available yet. Enter a world and try again.")
    return false, "net"
  end
  local r = P()
  if not r then
    q("`9GrowID not detected. Log in to Growtopia and try again.")
    return false, "net"
  end
  local h = ""
  pcall(function()
    local R = ((GetLocal or getLocal))()
    h = tostring(R["userid"] or R["userID"] or "")
  end)
  local X = Z(
    R .. (
        "?load=1&key=" .. (
          G(H) .. ("&dev=" .. (G(m) .. ("&gid=" .. (G(r) .. ("&uid=" .. (G(h) .. ("&src=" .. G(W or ""))))))))
        )
      )
  )
  if not X or X == "" then
    q(C["net"])
    return false, "net"
  end
  local o = X:match("^%-%-LEFT:(%d+)\n")
  if not o then
    local R = X:match('"msg"%s*:%s*"(%w+)"')
    q(C[R or "net"] or ("`9Rejected: " .. tostring(R)))
    return false, R or "net"
  end
  local U, I = ((load or loadstring))(X, "=marvel")
  X = nil
  if not U then
    q("`4Load error: `0" .. (tostring(I)):sub(1, 80))
    return false, "server"
  end
  T["ok"], T["key"], T["left"], T["last"], T["src"] = true, H, tonumber(o) or 0, os["time"](), W
  L(H)
  q(
    "`2License active! `9"
      .. (
        ((T["left"] >= 36500) and "`3Permanent" or (tostring(T["left"]) .. " day(s) left"))
        .. ("`9. GrowID: `3" .. (r .. "`9. Type `3/proxy"))
      )
  )
  local t, w = pcall(U)
  if not t then
    q("`4Script error: `0" .. (tostring(w)):sub(1, 80))
  end
  return true
end
local function y(R)
  R = ((tostring(R or "")):gsub("%s+", "")):upper()
  if R == "" then
    q(C["missing"])
    return
  end
  if T["busy"] then
    return
  end
  T["busy"] = true
  local H = runThread or RunThread
  H(function()
    local H, m, C = pcall(w, R)
    T["busy"] = false
    if not H then
      q("`9Error: " .. (tostring(m)):sub(1, 80))
    elseif not m and (C == "invalid" or C == "expired") then
      L("")
    end
  end)
end
local function p()
  local R = {
    "set_default_color|`o",
    "set_bg_color|8,28,70,235|",
    "set_border_color|70,170,255,255|",
    "add_label_with_icon|big|`wMarvelus`3Proxy `9License|left|1790|",
    "add_spacer|small|",
    "add_textbox|`9Enter your license key to unlock all features.|left|",
    "add_smalltext|`9Register your GrowID in Discord (#getkey) before activating.|left|",
    "add_smalltext|`9Don't have a key? Buy one here:|left|",
    "add_url_button||`whttps://linktr.ee/MarvelProxy|noflags|https://linktr.ee/MarvelProxy|Open Marvel Proxy link?|0|0|",
    "add_spacer|small|",
    "add_text_input|license_key|Key:||40|",
    "add_spacer|small|",
    "end_dialog|mp_license|Cancel|Activate|",
  }
  pcall(function()
    ((sendVariant or SendVariant))({ ["v1"] = "OnDialogRequest", ["v2"] = table["concat"](R, "\n") }, nil, -1)
  end)
end
addHook(function(R, H)
  if LD["run"] ~= m then
    return
  end
  if T["ok"] then
    return
  end
  if type(H) ~= "string" then
    return
  end
  local C = H:match("^action|input\n|text|(.*)$")
  if C then
    local R, H = C:match("^%s*(/%S+)%s*(.*)$")
    if R == "/proxy" then
      p()
      return true
    end
    if R == "/key" then
      y(H)
      return true
    end
  elseif H:find("dialog_name|mp_license", 1, true) then
    y(H:match("license_key|([^\n]*)"))
    return true
  end
end, "onSendPacket")
if R:find("GANTI_URL", 1, true) then
  q("`4Loader belum diisi URL Worker. Edit baris URL di atas file.")
elseif not (load or loadstring) then
  q(C["nofunc"])
else
  local R = runThread or RunThread
  R(function()
    local R = t()
    if R then
      q("`9Saved key found, logging in automatically...")
      y(R)
    else
      q("`9Type `3/proxy `9and enter your license key to unlock all features.")
    end
  end)
end
