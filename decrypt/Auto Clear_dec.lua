local d, M, H = 250, "vgod77x9df", false
local function c(d)
  local M = log or LogToConsole
  if M then
    M("`c[`9VGOD SYNDICATE``] >> `0" .. tostring(d))
  end
end
local function a()
  if type(sendVariant) == "function" then
    sendVariant({
      ["v1"] = "OnDialogRequest",
      ["v2"] = "set_default_color|`w\nadd_label_with_icon|big|`4VGOD SYNDICATE | AUTHENTICATION|left|0|\nadd_spacer|small|\nadd_textbox|`2Dm discord name : `e@mrafiksy `wuntuk akses.|\nadd_spacer|small|\nadd_text_input|password|Password:||30|\nend_dialog|vgod_login|Cancel|Submit|",
    })
  end
end
local function n()
  local d = GetLocal()
  return d and { ["x"] = d["posX"] // 32, ["y"] = d["posY"] // 32 } or { ["x"] = 0, ["y"] = 0 }
end
local function j(d, M, H, c)
  local a = GetLocal()
  if a then
    SendPacketRaw(false, { ["type"] = d, ["value"] = M, ["px"] = H, ["py"] = c, ["x"] = a["posX"], ["y"] = a["posY"] })
  end
end
local function y()
  c("Script By VGOD SYNDICATE\n`2Starting Auto Clear World")
  for M = 0, 53, 1 do
    for c = 0, 99, 1 do
      if not H then
        return
      end
      local a = GetTile(c, M)
      if a and (not a["extra"] and ((a["bg"] ~= 0 or a["fg"] % 2 == 1) and a["fg"] ~= 8)) then
        if math["abs"]((n())["x"] - c) > 2 or math["abs"]((n())["y"] - (M - 1)) > 2 then
          FindPath(c, M - 1)
          Sleep(math["random"](55, 70))
        end
        while true do
          local H = GetTile(c, M)
          if not H or (H["fg"] == 0 and H["bg"] == 0) then
            break
          end
          j(3, 18, c, M)
          Sleep(math["random"](d, d + 50))
        end
      end
    end
    c("`9Progress Row: " .. M)
  end
  c("`2Script Finished")
  H = false
end
if type(addHook) == "function" then
  addHook(function(d, a)
    if d == 2 and (type(a) == "string" and a:find("dialog_name|vgod_login", 1, true)) then
      if a:find("buttonClicked|Cancel", 1, true) then
        c("`4[VGOD SYNDICATE] `cLogin dibatalkan.")
        return true
      end
      if a:match("password|([^%c]+)") == M then
        H = true
        c("`0[`9Starting`0]`o[`2Script `cby `VGOD SYNDICATE`o]\n`2VGOD SYNDICATE`4 SCRIPT AKTIF")
        if type(runThread) == "function" then
          runThread(function()
            pcall(y)
          end)
        else
          y()
        end
      else
        c("`4[VGOD SYNDICATE] `cPassword salah!")
      end
      return true
    end
    return false
  end, "OnSendPacket")
end
if type(applyHook) == "function" then
  applyHook()
end
c("Script VGOD SYNDICATE Dimuat. Silakan masukkan password.")
a()
