local content = "pnb"
local RAW_URL = "https://hsngl-loader.hsndika.workers.dev/?key=key_hsngls12012027&s="..content

local script, err = fetch(RAW_URL)

if not script then
    LogToConsole("`c[HsnGL]`w Failed to download script.")
    return
end

local func, compileError = load(script)

if not func then
    LogToConsole("`c[HsnGL]`w Compile Error:")
    LogToConsole(compileError)
    return
end

local success, runtimeError = pcall(func)

if not success then
    LogToConsole("`c[HsnGL]`w Runtime Error:")
    LogToConsole(runtimeError)
end