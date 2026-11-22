local g = "auto_clave_enabled"
local Z = {
  { 1270, "Stitches", "ac_stitches" },
  { 1260, "Scalpel", "ac_scalpel" },
  { 1266, "Antibiotic", "ac_antibiotic" },
  { 1262, "Anesthetic", "ac_anesthetic" },
  { 1264, "Antiseptic", "ac_antiseptic" },
  { 1258, "Sponge", "ac_sponge" },
  { 4318, "Lab Kit", "ac_labkit" },
  { 4308, "Pins", "ac_pins" },
  { 1268, "Spirit", "ac_spirit" },
  { 4314, "Clamp", "ac_clamp" },
  { 4312, "Defibrillator", "ac_defibrillator" },
  { 4316, "Ultrasound", "ac_ultrasound" },
  { 4310, "Transfusion", "ac_transfusion" },
}
local v =
  '{\n    "sub_name": "Auto Clave",\n    "icon": "MedicalServices",\n    "menu": [\n        {\n            "type": "label",\n            "text": "=== AUTO CLAVE ==="\n        },\n        {\n            "type": "toggle",\n            "text": "Enable Auto Clave",\n            "alias": "auto_clave_enabled",\n            "default": false\n        },\n        {\n            "type": "divider"\n        },\n        {\n            "type": "label",\n            "text": "=== TOOL SETTINGS ==="\n        },\n        {\n            "type": "toggle",\n            "text": "Stitches",\n            "alias": "ac_stitches",\n            "default": true\n        },\n        {\n            "type": "toggle",\n            "text": "Scalpel",\n            "alias": "ac_scalpel",\n            "default": true\n        },\n        {\n            "type": "toggle",\n            "text": "Antibiotic",\n            "alias": "ac_antibiotic",\n            "default": true\n        },\n        {\n            "type": "toggle",\n            "text": "Anesthetic",\n            "alias": "ac_anesthetic",\n            "default": true\n        },\n        {\n            "type": "toggle",\n            "text": "Antiseptic",\n            "alias": "ac_antiseptic",\n            "default": true\n        },\n        {\n            "type": "toggle",\n            "text": "Sponge",\n            "alias": "ac_sponge",\n            "default": true\n        },\n        {\n            "type": "toggle",\n            "text": "Lab Kit",\n            "alias": "ac_labkit",\n            "default": true\n        },\n        {\n            "type": "toggle",\n            "text": "Pins",\n            "alias": "ac_pins",\n            "default": true\n        },\n        {\n            "type": "toggle",\n            "text": "Spirit",\n            "alias": "ac_spirit",\n            "default": true\n        },\n        {\n            "type": "toggle",\n            "text": "Clamp",\n            "alias": "ac_clamp",\n            "default": true\n        },\n        {\n            "type": "toggle",\n            "text": "Defibrillator",\n            "alias": "ac_defibrillator",\n            "default": true\n        },\n        {\n            "type": "toggle",\n            "text": "Ultrasound",\n            "alias": "ac_ultrasound",\n            "default": true\n        },\n        {\n            "type": "toggle",\n            "text": "Transfusion",\n            "alias": "ac_transfusion",\n            "default": true\n        }\n    ]\n}\n'
addIntoModule(v)
local d = 0
local K, D = 0, 0
local N = ""
local function i(g)
  for Z, v in pairs(getInventory()) do
    if v["id"] == g then
      return v["amount"]
    end
  end
  return 0
end
local function x()
  local g = 0
  local v = 0
  for Z, d in ipairs(Z) do
    local K = d[1]
    local D = d[3]
    local N = getValue(0, D)
    if N then
      local Z = i(K)
      if Z > v then
        v = Z
        g = K
      end
    end
  end
  return g
end
local function p(Z)
  if not Z or Z["v1"] ~= "OnDialogRequest" then
    return
  end
  if not getValue(0, g) then
    return
  end
  local v = tostring(Z["v2"] or "")
  if v:find("With this device", 1, true) and v:find("Autoclave", 1, true) then
    N = "autoclave"
    d = x()
    if d == 0 then
      LogToConsole("`4[Auto Clave] Tidak ada tool aktif yang tersedia.")
      return true
    end
    K = v:match("|tilex|(%d+)") or "0"
    D = v:match("|tiley|(%d+)") or "0"
    sendPacket(
      2,
      "action|dialog_return\n"
        .. (
          "dialog_name|"
          .. (
            N
            .. (
              "\n"
              .. (
                "tilex|" .. (
                  K .. (
                    "|\n" .. (
                      "tiley|" .. (D .. ("|\n" .. ("itemID|" .. (d .. ("|\n" .. ("buttonClicked|tool" .. d))))))
                    )
                  )
                )
              )
            )
          )
        )
    )
    return true
  elseif v:find("Are you sure you want", 1, true) then
    if N ~= "autoclave" or d == 0 then
      return
    end
    sendPacket(
      2,
      "action|dialog_return\n"
        .. (
          "dialog_name|"
          .. (
            N .. (
              "\n" .. (
                "tilex|" .. (
                  K .. ("|\n" .. ("tiley|" .. (D .. ("|\n" .. ("itemID|" .. (d .. "|\nbuttonClicked|verify"))))))
                )
              )
            )
          )
        )
    )
    return true
  end
end
addHook(p, "onVariant")
