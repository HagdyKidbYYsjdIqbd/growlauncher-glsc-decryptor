math["randomseed"](os["time"]())
local M = ""
local N = true
local F = os["clock"]()
local function w()
  local N = GetLocal()
  if not N then
    return
  end
  local F = math["random"](1, 30)
  local w = F <= 10 and "`2" or F <= 20 and "`9" or "`4"
  local d = w .. ("[ " .. (F .. "ms ]"))
  if d ~= M then
    sendVariant({ ["v1"] = "OnNameChanged", ["v2"] = d }, N["netID"])
    M = d
  end
end
function OnDrawImGui()
  if not N then
    return
  end
  local M = os["clock"]() - F
  if M >= 5 then
    N = false
    return
  end
  local w = 0.4
  local d = math["min"](M / w, 1)
  local b
  if d < 0.5 then
    b = ((4 * d) * d) * d
  else
    b = 1 - ((-2 * d + 2) ^ 3 / 2)
  end
  local G = -160 + (410 * b)
  ImGui["SetNextWindowPos"](ImVec2(118, G))
  ImGui["SetNextWindowSize"](ImVec2(1300, 180))
  ImGui["SetNextWindowBgAlpha"](0.72)
  ImGui["Begin"](
    "##VORTEX_NOTICE",
    nil,
    (
      ((ImGui["WindowFlags"]["NoTitleBar"] + ImGui["WindowFlags"]["NoResize"]) + ImGui["WindowFlags"]["NoMove"])
      + ImGui["WindowFlags"]["NoScrollbar"]
    ) + ImGui["WindowFlags"]["NoSavedSettings"]
  )
  ImGui["SetWindowFontScale"](2.1)
  ImGui["SetCursorPos"](ImVec2(110, 20))
  ImGui["TextColored"](ImVec4(1, 1, 1, 1), "Warning from")
  ImGui["SameLine"](0, 5)
  ImGui["TextColored"](ImVec4(1, 0.12, 0.12, 1), "System:")
  ImGui["SameLine"](0, 5)
  ImGui["TextColored"](ImVec4(1, 1, 1, 1), "You've been")
  ImGui["SameLine"](0, 5)
  ImGui["TextColored"](ImVec4(1, 0.12, 0.12, 1), "BANNED")
  ImGui["SameLine"](0, 5)
  ImGui["TextColored"](ImVec4(1, 1, 1, 1), "from")
  ImGui["SetCursorPos"](ImVec2(395, 78))
  ImGui["TextColored"](ImVec4(1, 1, 1, 1), "VGODS for 730 days")
  ImGui["End"]()
end
addHook(OnDrawImGui, "OnDrawImGui")
applyHook()
LogToConsole("`4[Vgod Syndicate] Started")
while true do
  pcall(w)
  Sleep(3000)
end
