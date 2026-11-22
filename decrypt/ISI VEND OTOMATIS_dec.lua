local vendCount = 0

local uiJson = [[
{
  "sub_name": "Auto Isi Vend",
  "icon": "ShoppingCart",
  "menu": [
    {
      "type": "tooltip",
      "icon": "ShoppingCart",
      "text": "Auto Isi Vend",
      "support_text": "by BLACK MAMBA (blackcat5018)",
      "background": true
    },
    {
      "type": "divider"
    },
    {
      "type": "toggle",
      "alias": "isivend_enable",
      "text": "Aktifkan Script",
      "default": true
    },
    {
      "type": "divider"
    },
    {
      "type": "dialog",
      "text": "Cara Pakai & Info",
      "support_text": "Baca ini sebelum pakai!",
      "menu": [
        {
          "type": "tooltip",
          "icon": "Info",
          "text": "Cara Pakai",
          "support_text": "",
          "background": true
        },
        {
          "type": "label",
          "text": "1. Aktifkan toggle 'Aktifkan Script'"
        },
        {
          "type": "label",
          "text": "2. Jalan ke vending machine kamu"
        },
        {
          "type": "label",
          "text": "3. Punch / wrench vend seperti biasa"
        },
        {
          "type": "label",
          "text": "4. Script auto klik 'Add them to the machine'"
        },
        {
          "type": "label",
          "text": "5. Notif muncul kalau berhasil"
        },
        {
          "type": "divider"
        },
        {
          "type": "tooltip",
          "icon": "Warning",
          "text": "Perhatian",
          "support_text": "Vend yang belum pernah diisi sama sekali perlu disetup manual dulu: pilih item dan set harga. Setelah itu script bisa auto-isi.",
          "background": false
        },
        {
          "type": "divider"
        },
        {
          "type": "tooltip",
          "icon": "ContactSupport",
          "text": "Butuh bantuan?",
          "support_text": "Discord: blackcat5018",
          "background": false
        }
      ]
    },
    {
      "type": "dialog",
      "text": "Pengaturan",
      "support_text": "Opsi notifikasi",
      "menu": [
        {
          "type": "tooltip",
          "icon": "Settings",
          "text": "Pengaturan",
          "support_text": "",
          "background": true
        },
        {
          "type": "toggle",
          "alias": "isivend_notif",
          "text": "Tampilkan Notifikasi",
          "default": true
        },
        {
          "type": "toggle",
          "alias": "isivend_show_empty",
          "text": "Notif saat vend kosong",
          "default": true
        }
      ]
    },
    {
      "type": "divider"
    },
    {
      "type": "label",
      "text": "Vend diisi sesi ini: cek konsol"
    }
  ]
}
]]

addCategory("BLACK MAMBA", "ShoppingCart")
addIntoModule(uiJson, "BLACK MAMBA")

local function notif(msg)
    if getValue(0, "isivend_notif") then
        sendNotification(msg)
    end
end

addHook(function(var)
    if type(var.v1) ~= "string" or type(var.v2) ~= "string" then
        return false
    end

    if var.v1 ~= "OnDialogRequest" then return false end
    if not var.v2:find("vending")   then return false end

    if not getValue(0, "isivend_enable") then return false end

    local x = var.v2:match("embed_data|tilex|(%d+)")
    local y = var.v2:match("embed_data|tiley|(%d+)")
    if not x then x = var.v2:match("tilex|(%d+)") end
    if not y then y = var.v2:match("tiley|(%d+)") end

    local isEmpty = var.v2:find("stockItem") ~= nil
                 or var.v2:find("This machine is empty") ~= nil
    local hasStock = var.v2:find("addstock") ~= nil
    local stock   = tonumber(var.v2:match("contains a total of (%d+)")) or 0

    if isEmpty then
        if getValue(0, "isivend_show_empty") then
            notif("📦 Vend kosong! Setup manual dulu: pilih item & set harga.")
        end
        return false
    end

    if hasStock and x and y then
        sendPacket(2,
            "action|dialog_return\n" ..
            "dialog_name|vending\n" ..
            "tilex|" .. x .. "|\n" ..
            "tiley|" .. y .. "|\n" ..
            "buttonClicked|addstock\n"
        )
        vendCount = vendCount + 1
        notif("✅ Vend diisi! (" .. x .. ", " .. y .. ") [#" .. vendCount .. "]")
        LogToConsole("[Auto Isi Vend] ✅ (" .. x .. ", " .. y .. ") stock=" .. stock .. " [#" .. vendCount .. "]")
        return true
    end

    return false
end, "onVariant")

LogToConsole("[Auto Isi Vend] Siap — BLACK MAMBA > Auto Isi Vend")
sendNotification("Auto Isi Vend siap ✅")
