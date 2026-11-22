local res, err = fetch("https://gist.githubusercontent.com/V7Factory/82eeda997e1600dc2bc0603f0016a213/raw/V7-Factory%2520Premium%2520Proxy.lua")

if not res then
    LogToConsole(err)
return

end

local chunk, loadErr = load(res)
if not chunk then
    LogToConsole(loadErr)
    return
end

chunk()