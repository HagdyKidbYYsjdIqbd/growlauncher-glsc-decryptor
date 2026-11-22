local GIST_BASE_URL = "https://gist.githubusercontent.com/JACKO69/5b372d5601d5b7329317e1c04568b039/raw/Tomb.lua"
local _log = LogToConsole or logToConsole or log
local _sleep = sleep or Sleep or CSleep
local _getTime = getTime or os.time
local function loadLatestGist()
  -- Cache-buster ensures GitHub CDN serves your latest edit immediately
  local cache_buster = tostring(_getTime()) .. tostring(math.random(1000, 9999))
  local live_url = GIST_BASE_URL .. "?t=" .. cache_buster

  local res, err
  for attempt = 1, 3 do
    local ok, r, e = pcall(function()
      return fetch(live_url)
    end)
    if ok and r and r ~= "" and not tostring(r):find("^404:") then
      res = r
      break
    end
    err = e or "Empty response"
    if _sleep then
      _sleep(500)
    end
  end

  if not res then
    if _log then
      _log("`4[Loader]`o Failed to fetch update: " .. tostring(err))
    end
    return
  end

  local chunk, loadErr
  if _VERSION == "Lua 5.1" and type(loadstring) == "function" then
    chunk, loadErr = loadstring(res)
  else
    chunk, loadErr = load(res)
  end

  if not chunk then
    if _log then
      _log("`4[Loader]`o Syntax error in Gist: " .. tostring(loadErr))
    end
    return
  end

  local run_ok, run_err = pcall(chunk)
  if not run_ok then
    if _log then
      _log("`4[Loader]`o Runtime error: " .. tostring(run_err))
    end
  end
end
if type(runCoroutine) == "function" then
  runCoroutine(loadLatestGist)
else
  loadLatestGist()
end
