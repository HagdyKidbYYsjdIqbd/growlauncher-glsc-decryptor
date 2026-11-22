


sendNotification("KILLYOURIDOL PROJECT")

function ontext(str)
    local o = {}
    o.v1 = "OnTextOverlay"
    o.v2 = str
    SendVariant(o)
end


function raw(a)
if a.type == 3 then
ontext("`#X : `3"..a.px.." `6Y : `9"..a.py)
log("`#X : `3"..a.px.." `6Y : `9"..a.py)
end
return false
end


local hookApi = addHook or AddHook
if type(hookApi) == "function" then

    hookApi(raw, "onSendPacketRaw")


    local applyApi = applyHook or ApplyHook
    if type(applyApi) == "function" then
        applyApi()
    end
else
    log("`4[KILLYOURIDOL Project] Hook API addHook tidak tersedia.")
end