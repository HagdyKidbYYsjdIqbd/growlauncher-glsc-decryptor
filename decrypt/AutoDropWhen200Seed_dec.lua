local g = 370
function setOptions(g)
  EditToggle("ModFly", false)
  EditToggle("Anticollect", g)
end
function inv(g)
  for u, W in pairs(GetInventory()) do
    if W["id"] == g then
      return W["amount"]
    end
  end
  return 0
end
function cariSeedSiapDrop()
  for g, u in pairs(GetInventory()) do
    if
      u["id"] and (
        u["id"] % 2 == 1 and (u["amount"] >= 200 and (u["id"] ~= 243 and (u["id"] ~= 242 and u["id"] ~= 7188)))
      )
    then
      return u["id"], u["amount"]
    end
  end
  return nil, 0
end
function dropItem(u, W)
  SendPacket(2, "action|drop\nitemID|" .. u)
  SendPacket(
    2,
    "action|dialog_return\n" .. ("dialog_name|drop_item\n" .. ("itemID|" .. (u .. ("|\n" .. ("count|" .. W)))))
  )
  Sleep(g)
end
AddHook(function(g)
  if g["v1"] == "OnDialogRequest" and g["v2"]:find("drop_item") then
    return true
  end
  return false
end, "OnVariant")
while true do
  if GetLocal() then
    local g, u = cariSeedSiapDrop()
    if g and u >= 200 then
      LogToConsole("`5[Velno]`o Seed ID " .. (g .. (" mencapai " .. (u .. ". Auto drop..."))))
      setOptions(true)
      Sleep(100)
      dropItem(g, u)
      Sleep(500)
    else
      LogToConsole("`4[Velno]`o Belum ada seed mencapai 200. Menunggu...")
      setOptions(false)
      Sleep(3000)
    end
  end
  Sleep(100)
end
