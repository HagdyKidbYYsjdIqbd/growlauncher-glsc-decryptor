local function v(v)
  if not v then
    return false
  end
  if v["v1"] == "OnDialogRequest" then
    local M = tostring(v["v2"] or "")
    logToConsole("`7[DEBUG DIALOG] `2OnDialogRequest `7Detected:")
    logToConsole("`7[DEBUG DIALOG] Panjang: `4" .. tostring(#M))
    logToConsole("`7[DEBUG DIALOG] Isi:\n`4" .. M)
  end
  return false
end
addHook(v, "OnVariant")
applyHook()
logToConsole("`2[DEBUG] DialogRequest")
