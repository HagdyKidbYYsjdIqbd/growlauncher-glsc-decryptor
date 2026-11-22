growtopia["notify"]("`2[Fast Add Vend]`c Active!")
local function B()
  for B, S in pairs(getInventory()) do
    if S and S["id"] > 0 then
      return S["id"]
    end
  end
  return 0
end
function onVariant(S, G)
  if S["v1"] == "OnDialogRequest" and S["v2"]:find("vending") then
    local G = S["v2"]:match("tilex|(%d+)")
    local L = S["v2"]:match("tiley|(%d+)")
    if G and L then
      local S = B()
      if S == 0 then
        growtopia["notify"]("`4[Error]`c Backpack kosong!")
        return true
      end
      local l = string["format"](
        "action|dialog_return\ndialog_name|vending\ntilex|%s|\ntiley|%s|\nbuttonClicked|addstock\nitemID|%d|\ncount|100\nsetprice|1\nchk_peritem|0\nchk_perlock|1",
        G,
        L,
        S
      )
      sendPacket(2, l)
      growtopia["notify"]("`2[Success]`cAdd Stock ke Vending (" .. (G .. ("," .. (L .. ")"))))
      return true
    end
  end
end
applyHook()
