SendPacket(2, "action|setDeath\nanimDeath|1")
local function FakeRes()
  local pkt = {}
  pkt.type = 0
  pkt.state = 2356
  pkt.x = GetLocal().pos.x
  pkt.y = GetLocal().pos.y
  SendPacketRaw(false, pkt)
end
FakeRes()
LogToConsole("Don't Jump")
