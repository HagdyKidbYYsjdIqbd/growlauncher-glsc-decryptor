local n="LOLI STORE"
local H="discord.gg/2PMRnwtNT"
local e=require("preferences")
local k=e:new("auto_growganoth_lolistore.json")
local I={["key"]=k:get("lite_key","");["itemIDs"]="1542";["srcWorld"]="";["dropWorld"]="";["posX"]=50,["posY"]=15;["rewardWorld"]="";["rewardX"]=10;["rewardY"]=10,["amount"]=1;["batch"]=20;["maxFail"]=3;["dropRewards"]=true}
local a="i0M15rvpt7VqEJrTewzY0kRs"
local E="discord.gg/2PMRnwtNT"
local B="ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
local Z=320400
local O=604800
local h=43200
local T=a~="ISI_KEY_SECRET_DI_SINI"
local function G(n)local H=a..(":"..math["floor"](n))local e,k=5381,52711 for n=1,#H,1 do local I=H:byte(n)e=((e*(33)+I))%(2147483647)k=(((k*(131)+I*(7))+n))%(2147483629)end for n=1,12,1 do e=((e*(48271)+k))%(2147483647)k=((k*(69621)+e))%(2147483629)end local I={}for n,H in ipairs({e;k})do for n=1,4,1 do local e=H%(32)H=H//(32)I[#I+(1)]=B:sub(e+(1),e+(1))end end return "LS-"..(table["concat"](I,"",1,4)..("-"..table["concat"](I,"",5,8)))end
local function d()return math["floor"](((os["time"]()-Z))/O)end
local function t(n)return(((tostring(n or "")):upper()):gsub("%s+",""))end
local function F()if not T then return false end local n=t(I["key"])if n==""then return false end local H=d()if n==G(H)then return true end local e=((os["time"]()-Z))%O return e<h and n==G(H-1)end
local o={["path"]=1000;["collect"]=1500,["drop"]=500,["refresh"]=1000,["death"]=2000,["warp"]=7000}
local l={[242]=true;[1796]=true,[7188]=true;[11550]=true;[18]=true,[32]=true}
local u=false
local j="Idle"
local A=nil
local R,L,J,S={},{},{},{}
local D={}
local p={}
local X={}
local x=0
local function Y()p={}for n in(tostring(I["itemIDs"])):gmatch("%d+")do p[tonumber(n)]=true end end
Y()
local function z(n)local H=getItemInfoByID(n)return H and H["name"]or("ID "..n)end
local function f()D={}for n,H in pairs(getInventory())do D[H["id"]]=H["amount"]end end
local function V(n)local H={}for e,k in pairs(getInventory())do if k["amount"]>0 and(not l[k["id"]]and not R[k["id"]])then local e=k["amount"]-((D[k["id"]]or 0))local I=nil if n=="fodder"and p[k["id"]]then I=k["amount"]elseif n=="reward"and(u and e>0)then I=e end if I then H[#H+1]={["id"]=k["id"];["name"]=z(k["id"]);["limit"]=I}end end end return H end
local function m()Y()local n=V("fodder")x=#n X={}for H=1,math["min"](#n,8),1 do X[H]=n[H]["name"]..(" (ID "..(n[H]["id"]..(") x"..n[H]["limit"])))end end
local function b()local n,H=pcall(GetWorldName)return n and(tostring(H or "")):upper()or ""end
local function y(n,H)if n==H then return true end if H:match("%d$")then return false end return n:sub(1,#H)==H and(n:sub(#H+(1))):match("^%d+$")~=nil end
local function P(n)n=(((tostring(n or "")):gsub("^%s+","")):gsub("%s+$","")):upper()if n==""then return true end for H=1,4,1 do if not u then return false end local e=b()if y(e,n)then return true end j="Warp ke "..(n..(" ("..(H.."/4)")))log("Warp "..(H..(": sekarang '"..(e..("' -> '"..(n.."'"))))))if H%(2)==1 then pcall(growtopia["warpTo"],n)else pcall(sendPacket,3,"action|join_request\nname|"..(n.."\ninvitedWorld|0"))end sleep(o["warp"])end if y(b(),n)then return true end A="Gagal masuk world "..(n..(" (sekarang di '"..(b().."')")))log(A)return false end
local function M(n,H)local e=0 while u do if growtopia["isOnPos"](n,H)then return true end e=e+1 j="Menuju ("..(n..(","..(H..")")))FindPath(n,H)sleep(o["path"])if e%(10)==0 then log("Masih nyoba FindPath ke ("..(n..(","..(H..("), percobaan "..e)))))end end return false end
local function W()local n=getLocal()local H=math["floor"](n["posX"]/(32))local e=math["floor"](n["posY"]/(32))local k,I=nil,nil for n,a in pairs(getObjectList())do if p[a["itemid"]]and(not l[a["itemid"]]and not J[a["id"]])then local n=math["floor"](a["pos"]["x"]/(32))local E=math["floor"](a["pos"]["y"]/(32))local B=((n-H))^(2)+((E-e))^(2)if not I or B<I then k={["id"]=a["id"],["tx"]=n;["ty"]=E;["name"]=z(a["itemid"])}I=B end end end return k end
local function q(n)for H,e in pairs(getObjectList())do if e["id"]==n then return true end end return false end
local function s()if I["srcWorld"]==""then return 0 end if not P(I["srcWorld"])then return-1 end local n=0 while u and n<I["batch"]do local H=W()if not H then break end j="Ambil "..(H["name"]..(" ("..((n+(1))..("/"..(I["batch"]..")")))))FindPath(H["tx"],H["ty"])sleep(o["collect"])if q(H["id"])then S[H["id"]]=((S[H["id"]]or 0))+(1)if S[H["id"]]>=2 then J[H["id"]]=true end else n=n+(1)end end return n end
local function v(n,H,e,k)while u do local a=V(n)if#a==0 then return true end if not P(H)then return false end if not M(e,k)then return false end local E=a[1]local B=growtopia["checkInventoryCount"](E["id"])local Z=math["min"](I["amount"],E["limit"],B)j="Drop "..E["name"]sendPacket(2,"action|drop\n|itemID|%s":format(E["id"]))sleep(o["drop"])sendPacket(2,"action|dialog_return\ndialog_name|drop_item\nitemID|%s|\ncount|%s":format(E["id"],Z))sleep(o["death"])if growtopia["checkInventoryCount"](E["id"])>=B then L[E["id"]]=((L[E["id"]]or 0))+(1)if L[E["id"]]>=I["maxFail"]then R[E["id"]]=true end else L[E["id"]]=nil end sleep(o["refresh"])end return false end
local function U()R,L,J,S={},{},{},{}A=nil Y()f()local n="Selesai"while u do if not F()then A="Key kadaluarsa, ambil key baru di Discord"break end local H=s()if H<0 then break end if not v("fodder",I["dropWorld"],I["posX"],I["posY"])then break end if I["dropRewards"]then if not v("reward",I["rewardWorld"],I["rewardX"],I["rewardY"])then break end end if I["srcWorld"]==""or H==0 then n="Selesai, nggak ada item itu lagi"break end end if not u then n="Dihentikan"elseif A then n="Berhenti: "..A growtopia["notify"](n)end u=false j=n end
local c={["key"]="gg_key",["ids"]="gg_ids",["amount"]="gg_amount";["src"]="gg_src",["batch"]="gg_batch",["dropW"]="gg_dropw",["px"]="gg_px";["py"]="gg_py",["rew"]="gg_rew";["rewW"]="gg_reww";["rx"]="gg_rx",["ry"]="gg_ry",["start"]="gg_start"}
local function N(n,H)local e,k=pcall(getValue,n,H)if e then return k end return nil end
local function Q(n,H)local e=N(2,n)if e==nil then e=N(1,n)end if e==nil then return H end return tostring(e)end
local function i(n,H,e)local k=N(1,n)if k==nil then k=N(2,n)end k=tonumber(k)if not k then return H end return math["max"](e or-math["huge"],math["floor"](k))end
local g=nil
local function w()local n=((Q(c["key"],I["key"])):gsub("^%s+","")):gsub("%s+$","")I["key"]=n if n~=g then g=n k:set("lite_key",n)if F()then k:save()end end I["itemIDs"]=Q(c["ids"],I["itemIDs"])Y()I["amount"]=i(c["amount"],I["amount"],1)I["srcWorld"]=Q(c["src"],I["srcWorld"])I["batch"]=i(c["batch"],I["batch"],1)I["dropWorld"]=Q(c["dropW"],I["dropWorld"])I["posX"]=i(c["px"],I["posX"])I["posY"]=i(c["py"],I["posY"])I["rewardWorld"]=Q(c["rewW"],I["rewardWorld"])I["rewardX"]=i(c["rx"],I["rewardX"])I["rewardY"]=i(c["ry"],I["rewardY"])local H=N(0,c["rew"])if H~=nil then I["dropRewards"]=H and true or false end end
local function r(n,H)pcall(editToggle,n,H)end
local function C(n)pcall(growtopia["notify"],n)end
local function K()if u then return end if not F()then j="Key salah / kadaluarsa"C(n..(": key salah / kadaluarsa. Ambil di "..E))r(c["start"],false)return end u=true runThread(function()U()r(c["start"],false)C(n..(": "..j))end)end
local function n4()local n=false while true do w()local H=N(0,c["start"])and true or false if H and not n then log("START ON")K()elseif not H and n then log("START OFF -> stop")u=false end n=H sleep(500)end end
local function H4()local e=UserInterface["new"]("Auto Growganoth","Verified")e:addLabel(n.." - Growtopia scripts")e:addLabel("Discord: "..H)e:addDivider()e:addLabel("Key mingguan (ambil di "..(E.." #key-lite)"))e:addInputString("Key",I["key"],"Key","LS-XXXX-XXXX","Verified",c["key"])e:addDivider()e:addInputString("Item ID (pisah koma)",I["itemIDs"],"Item ID","1542","Verified",c["ids"])e:addInputInt("Jumlah per drop",tostring(I["amount"]),"Jumlah","1","Verified",c["amount"])e:addDivider()e:addLabel("1. Ambil item")e:addInputString("World sumber",I["srcWorld"],"World","kosong = pakai inventory","Home",c["src"])e:addInputInt("Max ambil/putaran",tostring(I["batch"]),"Max","20","Verified",c["batch"])e:addDivider()e:addLabel("2. Sacrifice")e:addInputString("World sacrifice",I["dropWorld"],"World","kosong = world sekarang","Home",c["dropW"])e:addInputInt("Pos X",tostring(I["posX"]),"X","50","Verified",c["px"])e:addInputInt("Pos Y",tostring(I["posY"]),"Y","15","Verified",c["py"])e:addDivider()e:addLabel("3. Reward")e:addToggle("Drop item reward",I["dropRewards"],c["rew"],true)e:addInputString("World reward",I["rewardWorld"],"World","kosong = world sekarang","Home",c["rewW"])e:addInputInt("Reward X",tostring(I["rewardX"]),"X","10","Verified",c["rx"])e:addInputInt("Reward Y",tostring(I["rewardY"]),"Y","10","Verified",c["ry"])e:addDivider()e:addToggleButton("START (ON = jalan, OFF = stop)",false,c["start"])local k=e:generateJSON()pcall(addCategory,n,"Verified")addIntoModule(k,n)end
local function e4(n,H)local e,k=ImGui["InputText"](n,I[H],64)if e then I[H]=k end return e end
local function k4(n,H,e)local k,a=ImGui["InputInt"](n,I[H])if k then I[H]=math["max"](e or 0,a)end end
function onDrawImGui(e)if ImGui["Begin"]("Auto Ambil & Drop | "..n)then ImGui["Text"](n.." - Growtopia scripts")ImGui["Text"]("Discord: "..H)ImGui["Separator"]()ImGui["Text"]("Key (wajib)")if e4("Key","key")then k:set("lite_key",I["key"])if F()then k:save()end end if not T then ImGui["Text"]("KEY_SECRET belum diisi di script!")elseif F()then ImGui["Text"]("Key valid")else ImGui["Text"]("Key belum valid / kadaluarsa")end ImGui["Text"]("Ambil key di Discord: "..(E.." (#key-lite)"))ImGui["Separator"]()ImGui["Text"]("Item")if e4("Item ID (pisah koma)","itemIDs")then Y()end k4("Jumlah per drop","amount",1)ImGui["Separator"]()ImGui["Text"]("1. Ambil item")e4("World sumber","srcWorld")k4("Max ambil/putaran","batch",1)ImGui["Separator"]()ImGui["Text"]("2. Sacrifice")e4("World sacrifice","dropWorld")k4("Pos X","posX")k4("Pos Y","posY")ImGui["Separator"]()ImGui["Text"]("3. Reward")local e,a=ImGui["Checkbox"]("Drop item reward",I["dropRewards"])if e then I["dropRewards"]=a end e4("World reward","rewardWorld")k4("Reward X","rewardX")k4("Reward Y","rewardY")ImGui["Separator"]()if ImGui["Button"]("Scan inventory")then m()end ImGui["Text"]("Item cocok di inventory: "..(x.." jenis"))for n,H in ipairs(X)do ImGui["Text"]("- "..H)end ImGui["Separator"]()if not u then if ImGui["Button"]("Start")then if F()then u=true runThread(U)else j="Key salah / kadaluarsa"end end else if ImGui["Button"]("Stop")then u=false end end ImGui["Text"]("Status: "..j)end ImGui["End"]()end
local I4,a4=pcall(H4)
if I4 then runThread(n4)log(n..(": UI di menu Module > "..n))else log(n..(": module gagal ("..(tostring(a4).."), pakai panel ImGui")))addHook(onDrawImGui,"onDrawImGui")applyHook()end
log(n..(" | "..H))
growtopia["notify"](n.." script loaded")
