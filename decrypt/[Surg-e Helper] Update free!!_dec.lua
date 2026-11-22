local res, err = fetch(
    "https://gist.githubusercontent.com/jiiselfryelf/ac67ee85786d02163a35eecfb8ed958d/raw/surghelper1.2-r0.lua"
)

if not res then
    LogToConsole(tostring(err))
    return
end

local chunk, loadErr = load(res)
if not chunk then
    LogToConsole(tostring(loadErr))
    return
end

chunk()