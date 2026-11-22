idfinder = [[
{
    "sub_name": "ID FINDER",
    "icon": "RemoveRedEye",
    "description": "Find ID Of Item",
    "menu": [
        {
            "type": "labelapp",
            "icon": "RemoveRedEye",
            "text": "ID Checker",
            "description": "ID Checker."
        },
        {
            "type": "item_picker",
            "text": "ID Finder",
            "item": "Blank",
            "default": "Blank",
            "alias": "selected_item"
        }
    ]
}
]]

addCategory("KOU PROJECT", "settings")
addIntoModule(idfinder, "KOU PROJECT")
sendNotification("KILLYOURIDOL PROJECT")

function ontext(str)
    local o = {}
    o.v1 = "OnTextOverlay"
    o.v2 = str
    SendVariant(o)
end

function ontalk(str)
    local s = {}
    s.v1 = "OnTalkBubble"
    s.v2 = GetLocal().netID
    s.v3 = str
    SendVariant(s)
end

function OnValue(type, name, value)
    if name == "selected_item" then
        local selectedItemID = findItemID(value)

        if selectedItemID then
            log("`2[ID FINDER] Item ditemukan")
            log("`wName: `9" .. tostring(value))
            log("`wID: `9" .. tostring(selectedItemID))

            ontext("ID: " .. tostring(selectedItemID))
            ontalk("`2Item ditemukan")
            ontalk("`wName: `9" .. tostring(value))
            ontalk("`wID: `9" .. tostring(selectedItemID))

            if growtopia.checkInventory(selectedItemID) then
                log("`2Status: Item ada di inventory")
            else
                log("`4Status: Item tidak ada di inventory")
            end
        else
            log("`4[ID FINDER] ID item tidak ditemukan")
            log("`wName: `9" .. tostring(value))

            ontext("ID item tidak ditemukan")
            ontalk("`4ID item tidak ditemukan")
        end

        return true
    end

    return false
end

local hookApi = addHook or AddHook

if type(hookApi) == "function" then
    hookApi(OnValue, "onValue")

    local applyApi = applyHook or ApplyHook

    if type(applyApi) == "function" then
        applyApi()
    end
else
    log("`4[KILLYOURIDOL Project] Hook API addHook tidak tersedia.")
end