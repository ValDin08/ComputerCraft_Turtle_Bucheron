--Variables declaration
local Sapplings	= 1
local Wood    	= 2
local Limits  	= 3
local NoTree

--Refueling turtle
turtle.refuel()

--Functions
function CheckTree(Slot)
	turtle.select(Slot)
	if turtle.compare() then
		NoTree = 0
	else
		NoTree = 1
	end
	return NoTree
end

function CheckAreaLimits(Slot)
	turtle.select(Slot)
	if turtle.compare() then
		turtle.turnLeft()
		turtle.forward()
		turtle.forward()
		turtle.turnLeft()
	end
end

function Moving()
--Checking lumber limits
	CheckAreaLimits(Limits)
--Checking if a tree has grown
	CheckTree(Wood)
	if NoTree == 1 then
		turtle.digUp()
		turtle.up()
		turtle.dig()
		turtle.forward()
		turtle.dig()
		turtle.forward()
		turtle.down()
	else
		Cut()
	end
end

function Cut()
--Breaking the front block and moving bellow the tree
	turtle.dig()
	turtle.forward()
--Breaking the whole tree
	while turtle.detectUp() do
		turtle.digUp()
		turtle.up()
	end
--Going back on the floor
	while not turtle.detectDown() do
		turtle.down()
	end
	turtle.back()
--Calling plant function
	Replant()
end

function Replant()
--Replant the tree
	turtle.select(Sapplings)
	turtle.place()
--Bypassing the sappling
	turtle.digUp()
	turtle.up()
	turtle.dig()
	turtle.forward()
	turtle.dig()
	turtle.forward()
	turtle.down()
end

function EmptyInventory()

end

--Program
--Start moving loop
print("Load turtle : 1 = max sapplings, 2 = 1 wood to harvest, 3 = 1 limit block")
print("Turtle starting in 30s")
os.sleep(30)
while true do
	Moving()
end
