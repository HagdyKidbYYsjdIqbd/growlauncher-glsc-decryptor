ZS_LABEL_WIDTH = ZS_LABEL_WIDTH or 30
if not ZS_HUB then
  ZS_HUB = { ["native"] = addHook, ["callbacks"] = {}, ["installed"] = {} }
  local k = {
    ["onvalue"] = "onValue",
    ["ondrawimgui"] = "onDrawImGui",
    ["onvariant"] = "onVariant",
    ["ondialog"] = "onDialog",
    ["onsendpacket"] = "onSendPacket",
    ["onsendpacketraw"] = "onSendPacketRaw",
  }
  local S = {
    ["onValue"] = "onvalue",
    ["onDrawImGui"] = "ondrawimgui",
    ["OnVariant"] = "onvariant",
    ["OnDialog"] = "ondialog",
    ["OnSendPacket"] = "onsendpacket",
    ["OnSendPacketRaw"] = "onsendpacketraw",
  }
  local function X(S)
    if ZS_HUB["installed"][S] then
      return
    end
    ZS_HUB["installed"][S] = true
    local X = ZS_HUB["callbacks"][S]
    ZS_HUB["native"](function(...)
      local k = false
      for I = 1, #X, 1 do
        local D, W = pcall(X[I], ...)
        if not D then
          local k = "Hook error (" .. (S .. ("): " .. tostring(W)))
          if growtopia and type(growtopia["notify"]) == "function" then
            pcall(growtopia["notify"], k)
          else
            print(k)
          end
        elseif W == true then
          k = true
        end
      end
      return k
    end, k[S] or S)
  end
  function addHook(k, I)
    if type(k) ~= "function" then
      return
    end
    I = I or "onvalue"
    I = S[I] or (tostring(I)):lower()
    if not ZS_HUB["callbacks"][I] then
      ZS_HUB["callbacks"][I] = {}
    end
    table["insert"](ZS_HUB["callbacks"][I], k)
    X(I)
  end
end
if not ZS_thread then
  function ZS_thread(k)
    runThread(k)
  end
end
if not ZS_label then
  function ZS_label(k, S, ...)
    S = tostring(S == nil and "" or S)
    local X = ZS_LABEL_WIDTH
    local function I(k)
      if utf8 and utf8["len"] then
        return utf8["len"](k) or #k
      end
      return #k
    end
    local D, W = {}, ""
    for k in S:gmatch("%S+") do
      if W == "" then
        W = k
      elseif (I(W) + 1) + I(k) <= X then
        W = W .. (" " .. k)
      else
        D[#D + 1] = W
        W = k
      end
    end
    if W ~= "" then
      D[#D + 1] = W
    end
    if #D == 0 then
      D[1] = S
    end
    for S, X in ipairs(D) do
      k:addLabel(X, ...)
    end
  end
end
if not ZS_CATEGORY_ADDED then
  ZS_CATEGORY_ADDED = true
  if type(addCategory) == "function" then
    pcall(addCategory, "ZS", "Shield")
  end
end
local k = { ["tag"] = "k12", ["life"] = "ZSA-COOK", ["unlocked"] = false, ["entered"] = "", ["n"] = 0 }
local function S(k)
  if growtopia and type(growtopia["notify"]) == "function" then
    pcall(growtopia["notify"], tostring(k))
  else
    print("[ZS] " .. tostring(k))
  end
end
local X = S
local I = addHook
local function D(S, X)
  if type(S) ~= "function" then
    return
  end
  return I(function(...)
    if not k["unlocked"] then
      return false
    end
    return S(...)
  end, X)
end
local function W(k)
  local S = tostring(k)
  local X, I = S:find('"menu"%s*:%s*%[')
  if not X then
    return nil
  end
  local D, W, m, i = 1, I + 1, false, false
  while W <= #S do
    local k = S:sub(W, W)
    if m then
      if i then
        i = false
      elseif k == "\\" then
        i = true
      elseif k == '"' then
        m = false
      end
    elseif k == '"' then
      m = true
    elseif k == "[" then
      D = D + 1
    elseif k == "]" then
      D = D - 1
      if D == 0 then
        return S:sub(I + 1, W - 1)
      end
    end
    W = W + 1
  end
end
local function m()
  k["n"] = k["n"] + 1
  local S = UserInterface["new"]("ZS ACCESS", "Lock")
  S:addLabelApp("* ACCESS KEY *", "Lock")
  ZS_label(S, "Enter your key. You can look around, but everything works only after unlock.")
  S:addInputString("Enter Key", "", "Enter Key", "Your key", "Key", "zskey_" .. (k["tag"] .. ("_" .. k["n"])))
  S:addButton("UNLOCK", "zsunl_" .. (k["tag"] .. ("_" .. k["n"])))
  S:addDivider()
  return S
end
local i = addIntoModule
local function B(S, X, ...)
  if type(S) == "string" and not S:find("zskey_" .. (k["tag"] .. "_"), 1, true) then
    local k, I = pcall(function()
      local k = m()
      local X = W(k:generateJSON())
      local I, D = S:find('"menu"%s*:%s*%[')
      if not (X and I) then
        return nil
      end
      local i = S:sub(D + 1)
      local B = i:match("^%s*%]") and "" or ","
      return S:sub(1, D) .. (X .. (B .. i))
    end)
    if k and I then
      S = I
    else
      pcall(function()
        i((m()):generateJSON(), X)
      end)
    end
  end
  return i(S, X, ...)
end
local function O(...)
  local X = select("#", ...)
  local I = { ... }
  local D, W = "zskey_" .. (k["tag"] .. "_"), "zsunl_" .. (k["tag"] .. "_")
  local function m(k)
    if type(k) ~= "string" then
      return nil
    end
    if k:sub(1, #D) == D then
      return "key"
    end
    if k:sub(1, #W) == W then
      return "btn"
    end
  end
  local i, B
  local function O(k, S)
    if i or S > 2 then
      return
    end
    if type(k) == "string" then
      i = m(k)
    elseif type(k) == "table" then
      for X, I in pairs(k) do
        if m(I) then
          i = m(I)
          B = k["value"] or k["text"] or k["v2"]
          return
        end
        if m(X) then
          i = m(X)
          B = I
          return
        end
        if type(I) == "table" then
          O(I, S + 1)
        end
      end
    end
  end
  for k = 1, X, 1 do
    O(I[k], 0)
    if i then
      if B == nil then
        B = I[k + 1]
      end
      break
    end
  end
  if i == "key" then
    k["entered"] = tostring(B or "")
    return true
  elseif i == "btn" then
    local X = ((k["entered"]:upper()):gsub("%s+", ""))
    if X == k["life"]:upper() then
      k["unlocked"] = true
      S("Key accepted. Unlocked!")
    else
      S("Invalid key.")
    end
    return true
  end
  return false
end
I(O, "onvalue")
local p = {
  [4596] = {
    { ["cook"] = 4562, ["cooking_on"] = "low", ["delay"] = 800 },
    { ["sleep"] = 400 },
    { ["cook"] = 874, ["delay"] = 800 },
    { ["sleep"] = 26700 },
    { ["cook"] = 868, ["delay"] = 800 },
    { ["sleep"] = 13300 },
    { ["cook"] = 196, ["delay"] = 800 },
    { ["sleep"] = 20000 },
    { ["cook"] = 18, ["delay"] = 800 },
  },
  [4604] = {
    { ["cook"] = 3472, ["cooking_on"] = "low", ["delay"] = 800 },
    { ["sleep"] = 33700 },
    { ["cook"] = 4602, ["delay"] = 800 },
    { ["sleep"] = 400 },
    { ["cook"] = 4588, ["delay"] = 800 },
    { ["sleep"] = 36300 },
    { ["cook"] = 962, ["delay"] = 800 },
    { ["sleep"] = 30000 },
    { ["cook"] = 18, ["delay"] = 800 },
  },
  [7056] = {
    { ["cook"] = 4562, ["cooking_on"] = "low", ["delay"] = 800 },
    { ["sleep"] = 400 },
    { ["cook"] = 3472, ["delay"] = 800 },
    { ["sleep"] = 27000 },
    { ["cook"] = 7054, ["delay"] = 800 },
    { ["sleep"] = 23000 },
    { ["cook"] = 4610, ["delay"] = 800 },
    { ["sleep"] = 40000 },
    { ["cook"] = 4766, ["delay"] = 800 },
    { ["sleep"] = 10000 },
    { ["cook"] = 18, ["delay"] = 800 },
  },
  [5452] = {
    { ["cook"] = 5416, ["cooking_on"] = "low", ["delay"] = 800 },
    { ["sleep"] = 400 },
    { ["cook"] = 3836, ["delay"] = 800 },
    { ["sleep"] = 20400 },
    { ["cook"] = 874, ["delay"] = 800 },
    { ["sleep"] = 10000 },
    { ["cook"] = 4610, ["delay"] = 800 },
    { ["sleep"] = 33000 },
    { ["cook"] = 5376, ["delay"] = 800 },
    { ["sleep"] = 17400 },
    { ["cook"] = 18, ["delay"] = 500 },
  },
  [6912] = {
    { ["cook"] = 7014, ["cooking_on"] = "low", ["delay"] = 800 },
    { ["sleep"] = 16000 },
    { ["cook"] = 3472, ["delay"] = 800 },
    { ["sleep"] = 34000 },
    { ["cook"] = 4602, ["delay"] = 800 },
    { ["sleep"] = 33000 },
    { ["cook"] = 868, ["delay"] = 800 },
    { ["sleep"] = 3000 },
    { ["cook"] = 962, ["delay"] = 800 },
    { ["sleep"] = 30000 },
    { ["cook"] = 18, ["delay"] = 800 },
  },
  [4600] = {
    { ["cook"] = 540, ["cooking_on"] = "medium", ["delay"] = 1500 },
    { ["sleep"] = 500 },
    { ["cook"] = 4562, ["delay"] = 1500 },
    { ["sleep"] = 500 },
    { ["cook"] = 3428, ["delay"] = 1500 },
    { ["sleep"] = 43500 },
    { ["cook"] = 3468, ["delay"] = 1500 },
    { ["sleep"] = 16000 },
    { ["cook"] = 18, ["delay"] = 1500 },
  },
  [10218] = {
    { ["cook"] = 5630, ["cooking_on"] = "low", ["delay"] = 800 },
    { ["sleep"] = 47000 },
    { ["cook"] = 5636, ["delay"] = 800 },
    { ["sleep"] = 30000 },
    { ["cook"] = 1238, ["delay"] = 800 },
    { ["sleep"] = 23000 },
    { ["cook"] = 5256, ["delay"] = 800 },
    { ["sleep"] = 6800 },
    { ["cook"] = 18, ["delay"] = 800 },
  },
  [1474] = {
    { ["cook"] = 956, ["cooking_on"] = "low", ["delay"] = 1500 },
    { ["sleep"] = 500 },
    { ["cook"] = 874, ["delay"] = 1500 },
    { ["sleep"] = 10000 },
    { ["cook"] = 4586, ["delay"] = 1500 },
    { ["sleep"] = 16000 },
    { ["cook"] = 868, ["delay"] = 1500 },
    { ["sleep"] = 34000 },
    { ["cook"] = 18, ["delay"] = 1500 },
  },
  [6914] = {
    { ["cook"] = 822, ["cooking_on"] = "low", ["delay"] = 800 },
    { ["cook"] = 5882, ["delay"] = 800 },
    { ["sleep"] = 35500 },
    { ["cook"] = 4666, ["delay"] = 800 },
    { ["cook"] = 7058, ["delay"] = 800 },
    { ["sleep"] = 400 },
    { ["cook"] = 18, ["delay"] = 800 },
  },
  [3240] = {
    { ["cook"] = 822, ["cooking_on"] = "low", ["delay"] = 800 },
    { ["cook"] = 4610, ["delay"] = 800 },
    { ["cook"] = 3836, ["delay"] = 800 },
    { ["sleep"] = 13600 },
    { ["cook"] = 868, ["delay"] = 800 },
    { ["sleep"] = 23200 },
    { ["cook"] = 4624, ["delay"] = 800 },
    { ["sleep"] = 6800 },
    { ["cook"] = 18, ["delay"] = 800 },
  },
}
function inv(k)
  for S, X in pairs(GetInventory()) do
    if X["id"] == k then
      return X["amount"]
    end
  end
  return 0
end
function addTooltipID(k, S, X)
  local I = S["menu"]
  if not I then
    return
  end
  for S, X in pairs(X) do
    local D = getItemInfoByID(S)
    if D then
      k:addChildTooltip(I, D["name"], D["id"], "Cookie", false)
    end
  end
end
local u =
  '{\n  "sub_name": "ZS AUTO COOK V1",\n  "description": "ZS Auto Cook V1",\n  "menu": [\n    {"text":"* ZS AUTO COOK V1 *","type":"labelapp","icon":"Fastfood","description":"ZadStay Auto Cook"},\n    {"background":true,"text":"* AUTO COOK INFO *","icon":"TipsAndUpdates","support_text":"Turn ON one food toggle to start cooking that item. Turn it OFF to stop. Select the oven count and cooking device below.","type":"tooltip"},\n    {"type":"label","text":"COOKING SETTINGS"},\n    {"alias":"useoven","default":true,"text":"Use Oven","description":"Cook using standard ovens","type":"toggle"},\n    {"alias":"replicator","default":false,"text":"Use Replicator","description":"Cook using replicators","type":"toggle"},\n    {"type":"label","text":"SELECT FOOD"},\n    {"alias":"cook_4596","default":false,"text":"Berry Crepes","type":"toggle"},\n    {"alias":"cook_4604","default":false,"text":"Arroz Con Pollo","type":"toggle"},\n    {"alias":"cook_7056","default":false,"text":"Coconut Tart","type":"toggle"},\n    {"alias":"cook_5452","default":false,"text":"Gingerbread Cookie","type":"toggle"},\n    {"alias":"cook_6912","default":false,"text":"Skill Spice","type":"toggle"},\n    {"alias":"cook_4600","default":false,"text":"Beer-Battered Fish and Chips","type":"toggle"},\n    {"alias":"cook_10218","default":false,"text":"Trawlerman\'s Friend","type":"toggle"},\n    {"alias":"cook_1474","default":false,"text":"Eggs Benedict","type":"toggle"},\n    {"alias":"cook_6914","default":false,"text":"Gemonade","type":"toggle"},\n    {"alias":"cook_3240","default":false,"text":"Hot Chocolate","type":"toggle"},\n    {"type":"label","text":"ADDITIONAL SETTINGS"},\n    {"use_dot":true,"max":25,"text":"Number of Ovens","alias":"ovenvalue","step":1,"default":1,"type":"slider","min":1},\n    {"use_dot":true,"max":3000,"text":"Extra Delay (ms)","alias":"extrasleep","step":30,"default":-1000,"type":"slider","min":-3000},\n    {"alias":"recipes","text":"Show Selected Food Ingredients","type":"button"}\n  ],\n  "icon":"Fastfood"\n}\n'
B(u, "ZS")
local o = 4596
local J = false
local Y = true
local E = 0
local a = 0
local l = p[o][1]["cooking_on"]
local f = getValue(1, "ovenvalue") or 6
local N = getValue(1, "extrasleep")
function inv(k)
  for S, X in pairs(GetInventory()) do
    if X["id"] == k then
      return X["amount"]
    end
  end
  return 0
end
function spr(k, S, X, I)
  SendPacketRaw(
    false,
    { ["type"] = k, ["value"] = S, ["px"] = X, ["py"] = I, ["x"] = (GetLocal())["posX"], ["y"] = (GetLocal())["posY"] }
  )
end
local function d()
  return { ["x"] = (GetLocal())["posX"] // 32, ["y"] = (GetLocal())["posY"] // 32 }
end
local function t(k, S)
  local X = GetTile(k, S)
  if not X then
    return false
  end
  local I = X["fg"]
  return (getValue(0, "useoven") and I == 4618) or (getValue(0, "replicator") and I == 6412)
end
function check_item(k)
  k = k or false
  local S = p[o]
  if not S then
    return false
  end
  local X = tonumber(getValue(1, "ovenvalue")) or 1
  local I = {}
  local D = {}
  for k, S in ipairs(S) do
    if S["cook"] and S["cook"] ~= 18 then
      local k = type(S["cook"]) == "table" and S["cook"] or { S["cook"] }
      for k, S in ipairs(k) do
        if not I[S] then
          I[S] = 0
          D[#D + 1] = S
        end
        I[S] = I[S] + 1
      end
    end
  end
  local W, m = {}, false
  for k, S in ipairs(D) do
    local D = I[S]
    local i = D * X
    local B = inv(S)
    local O = getItemInfoByID(S)
    local p = O and O["name"] or ("Item ID " .. S)
    local u = B < i and "`4" or "`2"
    if B < i then
      m = true
    end
    W[#W + 1] = "add_label_with_icon|small|`w"
      .. (p .. ("`o - " .. (D .. (" per food, " .. (u .. (B .. ("`w/" .. (i .. (" needed``|left|" .. (S .. "|"))))))))))
  end
  if k or m then
    local k = getItemInfoByID(o)
    local S = k and k["name"] or ("Food ID " .. o)
    growtopia["sendDialog"](
      table["concat"](
        {
          "set_default_color|`w",
          "add_custom_button|ZadStay|state:disabled;icon:" .. (o .. ";|"),
          "add_textbox|" .. (S .. " - Cooking Ingredients|"),
          "add_smalltext|ZadStay Auto Cook|",
          "add_custom_break|",
          "reset_placement_x|",
          "add_spacer|small|",
          "add_textbox|Required ingredients for " .. (X .. " oven(s):|"),
          table["concat"](W, "\n"),
          "add_spacer|small|",
          "add_smalltext|Counts are calculated for one complete batch in each selected oven.``|",
          o == 4596 and "add_smalltext|Optional spice: 2 Sugar (anytime).|" or "",
          o == 4604 and "add_smalltext|Optional spice: Salt and 2 Pepper (anytime).|" or "",
          o == 5452 and "add_smalltext|Optional spice: 2 Sugar (anytime).|" or "",
          o == 6912 and "add_smalltext|Optional spice: Salt, Sugar and Pepper (anytime).|" or "",
          o == 4600 and "add_smalltext|Optional spice: Salt and Pepper (anytime).|" or "",
          o == 1474 and "add_smalltext|Optional spice: Salt (anytime).|" or "",
          o == 6914 and "add_smalltext|Optional spice: 3 Sugar (anytime).|" or "",
          o == 3240 and "add_smalltext|Optional spice: 3 Sugar (anytime).|" or "",
          "add_quick_exit|",
          "end_dialog|zs_autocook_ingredients|Close||",
          "add_custom_margin|x:300;y:0|\nadd_custom_button|DUMMY_PADDING_X;textLabel:``;state:disabled;middle_colour:0;border_colour:0;|",
        },
        "\n"
      )
    )
  end
  return m
end
function SendPackets(k, S, X, I)
  if I == "medium" then
    I = "med"
  end
  SendPacket(
    2,
    "action|dialog_return\n"
      .. (
        "dialog_name|oven\n"
        .. (
          "tilex|"
          .. (
            k
            .. (
              "|\n"
              .. (
                "tiley|" .. (
                  S .. (
                    "|\n" .. ("cookthis|" .. (X .. ("|\n" .. ("buttonClicked|" .. (tostring(I or "low") .. "\n\n")))))
                  )
                )
              )
            )
          )
        )
      )
  )
end
function processStep(k, S)
  local X = getValue(1, "ovenvalue") or 1
  local I = k["cook"]
  local function D()
    local S = X
    for X = -2, 2, 1 do
      for D = -2, 2, 1 do
        if not J then
          return
        end
        local W = (d())["x"] + D
        local m = (d())["y"] + X
        if t(W, m) and S > 0 then
          S = S - 1
          spr(3, I, W, m)
          SendPackets(W, m, I, l)
          CSleep(k["delay"] or 500)
        end
        CSleep(1)
      end
    end
  end
  if I == 18 then
    D()
  else
    runCoroutine(function()
      D()
    end)
  end
end
function letmecook()
  while true do
    if not J then
      CSleep(500)
    else
      E = 0
      a = 0
      if check_item() then
        J = false
        CSleep(500)
      end
      local k = p[o]
      if k and J then
        for S, X in ipairs(k) do
          if not J then
            break
          end
          a = S
          processStep(X, S)
          if X["sleep"] then
            local I = X["sleep"]
            local D = k[S + 1]
            if S == #k or (D and D["cook"] == 18) then
              I = I + (N or 0)
            end
            local W = 0
            while W < I do
              if not J then
                break
              end
              local k = math["min"](1000, I - W)
              CSleep(k)
              W = W + k
            end
          end
        end
      end
      if J then
        J = false
        E = 0
        a = 0
        editValue("cook_" .. tostring(o), false)
        growtopia["notify"]("Auto Cook batch complete: " .. tostring(o))
      end
    end
  end
end
runCoroutine(letmecook)
runCoroutine(function()
  while true do
    if J then
      E = E + 1
    end
    CSleep(1000)
  end
end)
D(function(k, S, X)
  if S == "recipes" then
    check_item(true)
  elseif S == "extrasleep" then
    N = tonumber(X) or getValue(1, "extrasleep") or 0
  elseif type(S) == "string" and S:match("^cook_%d+$") then
    local k = tonumber(S:match("^cook_(%d+)$"))
    if X then
      if not k or not p[k] then
        growtopia["notify"]("This food is not available in the cooking database.")
        editValue(S, false)
        return
      end
      if o ~= k then
        local k = "cook_" .. tostring(o)
        if p[o] then
          editValue(k, false)
        end
      end
      o = k
      l = p[o][1]["cooking_on"] or "low"
      if check_item() then
        J = false
        editValue(S, false)
        growtopia["notify"]("Missing ingredients. Add the required items before starting.")
        return
      end
      J = true
      local X = getItemInfoByID(o)
      growtopia["notify"]("Auto Cook started: " .. (X and X["name"] or tostring(o)))
    elseif o == k then
      J = false
      E = 0
      a = 0
    end
  end
end, "onValue")
growtopia["notify"]("ZS Auto Cook V1 loaded. Open the ZS menu to configure recipes.")
if type(applyHook) == "function" then
  pcall(applyHook)
end
