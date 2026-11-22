local U, Z = fetch(
  "https://gist.githubusercontent.com/V7Factory/545ea5feeea84a8e275bf2ef491088e2/raw/V7-Factory%2520RGT%2520Free%2520Proxy.lua"
)
if not U then
  LogToConsole(Z)
  return
end
local m, I = load(U)
if not m then
  LogToConsole(I)
  return
end
m()
