local signalTarget = peripheral.wrap("create_target_10")
local departureTarget = peripheral.wrap("create_target_11")

local open = true
local time = 0

if fs.exists("state.dat") then
  local file = fs.open("state.dat", "rb")
  open = file.read() ~= 0
  file.close()
end

while true do
  local shouldBeOpen = string.match(signalTarget.getLine(1), "Clear") ~= nil
  local anotherTrain = string.match(departureTarget.getLine(1), "now") ~= nil

  print("  another train", anotherTrain)

  if not shouldBeOpen then
    time = 5
    print("  danger")
  else
    print("  clear")
  end

  if shouldBeOpen and anotherTrain then
    shouldBeOpen = false
  end
  
  if shouldBeOpen ~= open then
    local gates = {peripheral.find("Create_SequencedGearshift")}
    local mod = 1
  
    open = shouldBeOpen
    rs.setOutput("top", not open)
      
    if open then
      mod = -1
      print("open")
    else
      print("close")
    end
  
    local cancel = false
    for i, gate in ipairs(gates) do
      if gate.isRunning() then
        cancel = true
      end
    end
    
    if not cancel then
      for i, gate in ipairs(gates) do
        gate.rotate(90, mod)
      end
    else
      open = not open
    end

    local file = fs.open("state.dat", "wb")
    file.write(open and 1 or 0)
    file.close()
  end

  sleep(1)
end
