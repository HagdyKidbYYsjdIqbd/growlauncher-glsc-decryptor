Delay = 180
CoorX, CoorY = 77, 23
CaveS, DirtS, DirtBe = 15, 3, 2
CORRECT_PASS = "dfbyvgod"
local m = { ["autodf"] = false }
local A = { ["autodf"] = false }
local function J(m)
  if type(log) == "function" then
    log("[Vgod Syndicate] " .. tostring(m))
  elseif type(LogToConsole) == "function" then
    LogToConsole("[Vgod Syndicate] " .. tostring(m))
  end
end
local function Z()
  local A = "set_default_color|`w\n"
    .. (
      "add_label|big|`2Vgod Syndicate!!|\n"
      .. (
        "add_spacer|small|\n"
        .. (
          "add_checkbox|autodf|`wAuto DF++ (Dirt Farm)|"
          .. (
            (m["autodf"] and "1" or "0")
            .. "|\nadd_spacer|small|\nadd_textbox|`7Centang kotak untuk memilih fitur.|\nadd_textbox|`7Tekan OK untuk memulai/memperbarui.|\nend_dialog|vortex_menu|Cancel|OK|"
          )
        )
      )
    )
  if type(sendVariant) == "function" then
    sendVariant({ ["v1"] = "OnDialogRequest", ["v2"] = A })
  end
end
local function X()
  local m =
    "set_default_color|`w\nadd_label|big|`4Vgod Syndicate | AUTHENTICATION|\nadd_spacer|small|\nadd_textbox|`2Dm discord name : `e@mrafiksy `wuntuk akses.|\nadd_spacer|small|\nadd_text_input|password|Password:||30|\nend_dialog|vortex_login|Cancel|Submit|"
  if type(sendVariant) == "function" then
    sendVariant({ ["v1"] = "OnDialogRequest", ["v2"] = m })
  end
end
function BreakLava(m, A)
  SendPacketRaw(false, { ["px"] = m, ["py"] = A, ["x"] = m * 32, ["y"] = (A - 1) * 32, ["type"] = 3, ["value"] = 18 })
  Sleep(Delay)
end
function BreakDirt(m, A)
  SendPacketRaw(false, { ["px"] = m, ["py"] = A, ["x"] = m * 32, ["y"] = (A - 2) * 32, ["type"] = 3, ["value"] = 18 })
  Sleep(Delay)
end
function inv(m)
  for A, J in pairs(GetInventory() or {}) do
    if J["id"] == m then
      return J["amount"]
    end
  end
  return 0
end
function dropSeed()
  if inv(CaveS) >= 200 then
    FindPath(CoorX, CoorY)
    Sleep(700)
    SendPacket(2, "action|drop\n|itemID|" .. CaveS)
    SendPacket(2, "action|dialog_return\ndialog_name|drop_item\nitemID|" .. (CaveS .. "|\ncount|200"))
    Sleep(800)
  end
  if inv(DirtS) >= 200 then
    FindPath(CoorX + 2, CoorY)
    Sleep(700)
    SendPacket(2, "action|drop\n|itemID|" .. DirtS)
    SendPacket(2, "action|dialog_return\ndialog_name|drop_item\nitemID|" .. (DirtS .. "|\ncount|200"))
    Sleep(800)
  end
end
local function S()
  EditToggle("Antibounce", true)
  EditToggle("ModFly", true)
  EditToggle("Fast Drop", true)
  for m, J in pairs(GetTiles() or {}) do
    if not A["autodf"] then
      break
    end
    if
      (J["y"] % 2 == 1 or J["x"] <= 1 or J["x"] >= 98)
      and (
        ((J["fg"] == 2 or (J["bg"] == 14 and J["fg"] == 0) or J["fg"] == 10 or J["fg"] == 4) and J["fg"] ~= 8)
        and not FindPath(J["x"], J["y"] - 2)
      )
    then
      repeat
        BreakDirt(J["x"], J["y"])
      until (GetTile(J["x"], J["y"]))["bg"] == 0
      dropSeed()
    end
  end
  A["autodf"] = false
  m["autodf"] = false
end
local function d(m)
  if type(runThread) == "function" then
    runThread(function()
      pcall(m)
    end)
  end
end
local function Q()
  A["autodf"] = m["autodf"]
  if A["autodf"] then
    d(function()
      while A["autodf"] do
        S()
        Sleep(500)
      end
    end)
  end
end
if type(addHook) == "function" then
  addHook(function(A, X)
    if A == 2 and type(X) == "string" then
      if X:find("dialog_name|vortex_login", 1, true) then
        if X:find("buttonClicked|Cancel", 1, true) then
          J("`4[Vgod Syndicate] `cLogin dibatalkan. Script ditutup.")
          return true
        end
        local m = X:match("password|([^%c]+)")
        if m == CORRECT_PASS then
          J("`0[`9Starting`0]`o[`2Script `cby `Vgod Syndicate!!`o]")
          J("`0[`9Starting`0]`2 Auto DF++ v1 (Logged In)")
          J("`2Vgod Syndicate!!`4 SCRIPT AKTIF")
          Z()
        else
          J("`4[Vgod Syndicate] `cPassword salah! Script otomatis ditutup.")
        end
        return true
      end
      if X:find("dialog_name|vortex_menu", 1, true) then
        if X:find("buttonClicked|Cancel", 1, true) then
          return true
        end
        m["autodf"] = X:match("autodf|(%d+)") == "1"
        Q()
        return true
      end
    end
    return false
  end, "OnSendPacket")
end
if type(applyHook) == "function" then
  applyHook()
end
J("Script Vgod Syndicate Dimuat. Silakan masukkan password.")
X()
