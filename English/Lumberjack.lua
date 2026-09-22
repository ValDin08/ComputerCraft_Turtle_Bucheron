-- VARIABLE DECLARATION
	-- Globals
		local ProgramVersion	=	"5.0-alpha01"	-- Current program version
		local TurtleFunction	=	"bucheron"	-- Turtle function
		local TreesHarvested 	=	0			-- Number of trees harvested in the current run
		local ErrorDetected		=	false		-- Error detected
		local Error				=	""			-- Error reported by the Turtle
		local InCycle			=	false		-- Turtle in production

	-- Network
		local ServerID			=	11					-- Server ID
		local ModemSide			=	"right"				-- Modem side on the turtle
		local ServerConnected	=	false				-- Server reachable and connected to the turtle
		local ServerAuthorized	=	false				-- Server connected to the turtle and authorizing work
		local CurrentFuelLevel	=	0					-- Current fuel level
		local PixelLink 		=	require("PixelLink")


	-- Inventory
		-- Floating inventory (S = Start / E = End)
			local SSapplings	=	1	-- Start of the saplings stock
			local ESapplings	=	3	-- End of the saplings stock
			local SFuel			=	5	-- Start of the fuel reserve
			local EFuel			=	6	-- End of the fuel reserve
			local SWoodStock	=	8	-- Start of the logs stock
			local EWoodStock	=	16	-- End of the logs stock
		-- Fixed inventory
			local WoodType		=	4	-- Type of wood to harvest
		-- Quantities
			local SapplingsQty 	= 	0
			local FuelQty 		= 	0
			local LogQty 		=	0

		local InventoryNOK		=	0	-- Inventory not ready for turtle startup
		-- Inventory needs at the next exit, recalculated on every InventoryCheck()
		local NeedWoodDrop		=	false	-- Need to drop off logs
		local NeedFuel			=	false	-- Need to restock fuel
		local NeedSaplings		=	false	-- Need to restock saplings
		-- Needs forced by the server (touchscreen command), applied on the next exit then cleared
		local ForcedNeedWoodDrop	=	false
		local ForcedNeedFuel		=	false
		local LastAppliedCommandID	=	nil	-- Last server command applied (avoids re-applying it in a loop)

	-- Movements
		local RangesQty			=	3	-- Number of rows managed by the turtle
		local RangesDone		=	0	-- Number of rows the turtle has already passed
		local TypeOfMvmt		=	0	-- Movement type (0 = Stop / 1 = Forward)
		local nextRotation		=   ""  -- Next rotation

		-- Coordinates
			local TurtleGPSPos	=	{0, 0, 0}		-- Current turtle GPS position
			local TurtleStartPos=	{-81, 64, 48}	-- Turtle start GPS position
			local TurtleExitPos	=	{0, 0, 0}		-- Work zone entry/exit GPS position
			local TurtleFacing	=	0				-- Turtle orientation (1 = North / 2 = South / 3 = East / 4 = West)
			local FuelChest		=	{-79, 64, 47}	-- Fuel chest position
			local LogsChest		=	{-79, 64, 50}	-- Wood logs chest position
			local SapsChest		=	{-83, 64, 48}	-- Saplings chest position
			local xLimitLine	=	{-88, -70, 0}	-- Work zone x (min, max, unused)
			local zLimitLine	=	{53 ,63 , 0}	-- Work zone z (min, max, unused)
			local xTreeLine		=	{-85, -73, 0}   -- Lumberjacking zone x (min, max, unused)
			local zTreeLine		=	{56, 60, 0}		-- Lumberjacking zone z (min, max, unused)

-- CREATING FUNCTIONS
	-- BASIC MOVEMENT FUNCTIONS
		-- Left turn
		function TurnLeft()
			-- Left turn and update the turtle's facing
			turtle.turnLeft()
			if     TurtleFacing == 1 then TurtleFacing = 4
			elseif TurtleFacing == 2 then TurtleFacing = 3
			elseif TurtleFacing == 3 then TurtleFacing = 1
			else   TurtleFacing = 2
			end
			-- Reset the movement command
			TypeOfMvmt = 0
		end

		-- Right turn
		function TurnRight()
			-- Right turn and update the turtle's facing
			turtle.turnRight()
			if     TurtleFacing == 1 then TurtleFacing = 3
			elseif TurtleFacing == 2 then TurtleFacing = 4
			elseif TurtleFacing == 3 then TurtleFacing = 2
			else   TurtleFacing = 1
			end
			-- Reset the movement command
			TypeOfMvmt = 0
		end

		-- Move up
		function MoveUp(distance)
			for i = 1, distance do
        		turtle.up()
   			end
			GetGPSCurrentLoc()
			TypeOfMvmt = 0
		end

		-- Move down
		function MoveDown(distance)
			for i = 1, distance do
        		turtle.down()
   			end
			GetGPSCurrentLoc()
			TypeOfMvmt = 0
		end

		-- Move forward
		function MoveForward(distance)
			for i = 1, distance do
        		turtle.forward()
   			end
			GetGPSCurrentLoc()
			TypeOfMvmt = 0
		end

		-- Move backward
		function MoveBackward(distance)
			for i = 1, distance do
        		turtle.back()
   			end
			GetGPSCurrentLoc()
			TypeOfMvmt = 0
		end

	-- FUEL MANAGEMENT
		-- Check fuel level
		function FuelManagement()
			CurrentFuelLevel = turtle.getFuelLevel()
			if CurrentFuelLevel < 100 then
				return Refuel()
			end
			return false, ""
		end

		-- Refueling
		function Refuel()
			print("Refueling turtle...")
			turtle.select(SFuel)
			local succes = turtle.refuel(turtle.getItemCount(SFuel))
			-- Check if refueling was successful
			if succes then
				TransferIntraInventory(EFuel, SFuel, turtle.getItemCount(EFuel))
				return false, ""
			else
				return true, "Refueling failed"
			end
		end

	-- ACQUIRING CURRENT GPS POSITION
		function GetGPSCurrentLoc()
			TurtleGPSPos = {gps.locate()}
			return TurtleGPSPos
		end

	-- ACQUIRING START POSITION
		function GetStartLocation()
			-- Acquiring the start position
			GetGPSCurrentLoc()
			print("Calibrating position...")
			-- Acquiring the initial orientation
			TurtleStartPos = TurtleGPSPos
			-- Mandatory move to deduce the orientation: clear any obstacle instead of getting stuck
			while not turtle.forward() do
				print("Calibration blocked by an obstacle, clearing it...")
				turtle.dig()
				os.sleep(1)
			end
			GetGPSCurrentLoc()
			if     (TurtleGPSPos[3]) < (TurtleStartPos[3]) then TurtleFacing = 1
			elseif (TurtleGPSPos[3]) > (TurtleStartPos[3]) then TurtleFacing = 2
			elseif (TurtleGPSPos[1]) > (TurtleStartPos[1]) then TurtleFacing = 3
			elseif (TurtleGPSPos[1]) < (TurtleStartPos[1]) then TurtleFacing = 4
			end
			turtle.back()
			print("Position calibration complete.")
			GetGPSCurrentLoc()
			os.sleep(2)

		end

	-- TURTLE STARTUP PHASE
		function TurtleBooting()
			print("Checking turtle fuel...")
			-- Refueling the turtle
			ErrorDetected, Error = FuelManagement()

			if not ErrorDetected then
				print("Fuel OK.")

			else
				print(Error)
				print("Refueling impossible, the system will reboot in 5 seconds.")
				os.sleep(5)
				os.reboot()

			end

			-- Startup instructions
			print("Load the turtle: 1 to 3: max saplings, 4: wood to harvest, 5 and 6: max fuel. 7+: leave empty.")
			print("Checking required supplies...")
			os.sleep(5)

			-- Inventory check
			if (turtle.getItemCount(SSapplings) < 5) or (turtle.getItemCount(WoodType) == 0)then
				print("Load the turtle, the system will reboot in 5 seconds.")
				os.sleep(5)
				os.reboot()
			else
			-- Inventory OK, preparing the turtle
				print("Inventory OK.")
				os.sleep(1)
				print("Acquiring the turtle's start position.")
				GetStartLocation()
				print("Starting the turtle in 10s.")
			end
			os.sleep(10)

		end

	-- GETTING INTO WORK POSITION
		function GetInWorkPosition()
			-- Compare altitude
			GetGPSCurrentLoc()
			-- Turtle lift-off
			MoveUp(2)

			-- Check starting orientation and move to the nearest entry point of the work zone
			if TurtleFacing == 1 then
				MoveForward(math.abs(TurtleGPSPos[3] - zLimitLine[2]))
			elseif TurtleFacing == 2 then
				MoveForward(math.abs(TurtleGPSPos[3] - zLimitLine[1]))
			elseif TurtleFacing == 3 then
				MoveForward(math.abs(TurtleGPSPos[1] - xLimitLine[1]))
			else
				MoveForward(math.abs(TurtleGPSPos[1] - xLimitLine[2]))
			end

			-- Save the work zone entry/exit point
			GetGPSCurrentLoc()
			TurtleExitPos = TurtleGPSPos

			-- Move toward the first tree to start the harvest cycle
			TurnRight()
			MoveForward(math.abs(TurtleGPSPos[1]-xTreeLine[1]))
			MoveForward(1)
			TurnLeft()
			MoveForward(math.abs(TurtleGPSPos[3]-zTreeLine[1]))
			TurnLeft()

			InCycle = true

		end

	-- LEAVING THE WORK ZONE
		function ExitWorkZone()
			-- Acquiring GPS position
			GetGPSCurrentLoc()

			-- Check orientation to define the exit turn
			if TurtleFacing == 2 then
				TurnLeft()
				TurnLeft()
			elseif TurtleFacing == 3 then
				TurnLeft()
			elseif TurtleFacing == 4 then
				TurnRight()
			end

			-- Check for an obstacle in front of the turtle, otherwise move to zLimitLine[1]
			while turtle.detect() do
				TurnRight()
				MoveForward(1)
				TurnLeft()
			end

			-- Re-acquire GPS position and move to zLimitLine[1]
			GetGPSCurrentLoc()
			MoveForward(math.abs(TurtleGPSPos[3]-TurtleExitPos[3]))

			-- Check x position relative to the exit point
			GetGPSCurrentLoc()
			if TurtleGPSPos[1] < TurtleExitPos[1] then
				TurnRight()
				MoveForward(math.abs(TurtleGPSPos[1]-TurtleExitPos[1]))
				TurnLeft()
			elseif TurtleGPSPos[1] > TurtleExitPos[1] then
				TurnLeft()
				MoveForward(math.abs(TurtleGPSPos[1]-TurtleExitPos[1]))
				TurnRight()
			end

			while TurtleGPSPos[2] > TurtleStartPos[2] do MoveDown(1) end

			-- If the turtle is at the exit point, exiting is allowed
			GetGPSCurrentLoc()
			-- Actions outside the zone
			if NeedWoodDrop or NeedFuel or NeedSaplings then
				-- Check need to drop off wood
				if NeedWoodDrop then
					GetGPSCurrentLoc()
					MoveForward(math.abs(TurtleGPSPos[3]-(LogsChest[3])))
					TurnRight()
					MoveForward(math.abs(TurtleGPSPos[1]-(LogsChest[1]+1)))
					for i=SWoodStock,EWoodStock do
						TransferExtraInventory(i, turtle.getItemCount(i))
					end
					if InventoryMonitor(SWoodStock,EWoodStock) > 0 then
						ErrorDetected = true
						Error = "Wood chest full, drop-off incomplete"
						print(Error)
					end
					NeedWoodDrop = false
					ForcedNeedWoodDrop = false
					MoveBackward(1)
					if NeedFuel or NeedSaplings then TurnLeft() else TurnRight() end
				end

				-- Check need to refuel
				if NeedFuel then
					GetGPSCurrentLoc()
					MoveForward(math.abs(TurtleGPSPos[3]-(FuelChest[3])))
					TurnRight()
					MoveForward(math.abs(TurtleGPSPos[1]-(FuelChest[1]+1)))
					for i=SFuel,EFuel do
						TransferIntoInventory(i)
					end
					if InventoryMonitor(SFuel,EFuel) < 8 then
						ErrorDetected = true
						Error = "Fuel chest empty or insufficient"
						print(Error)
					end
					NeedFuel = false
					ForcedNeedFuel = false
					MoveBackward(1)
					TurnRight()
				end

				-- Check need to restock saplings
				if NeedSaplings then
					GetGPSCurrentLoc()
					MoveForward(math.abs(TurtleGPSPos[3]-SapsChest[3]))
					if TurtleFacing == 1 then TurnLeft() elseif TurtleFacing == 2 then TurnRight() end
					MoveForward(math.abs(TurtleGPSPos[1]-(SapsChest[1]+1)))
					for i=SSapplings,ESapplings do
						TransferIntoInventory(i)
					end
					if InventoryMonitor(SSapplings,ESapplings) < 8 then
						ErrorDetected = true
						Error = "Saplings chest empty or insufficient"
						print(Error)
					end
					NeedSaplings = false
					MoveBackward(1)
					TurnLeft()
				end
			elseif not ServerAuthorized then
				MoveForward(math.abs(TurtleGPSPos[3]-TurtleStartPos[3]))
				TurnLeft()
				TurnLeft()
			end

			-- Out-of-cycle signal
			InCycle = false

			-- Return to work position
			while not ServerAuthorized do
				AuthFromServer()
			end

			if ServerAuthorized then GetInWorkPosition() end

		end

	-- ENVIRONMENT ANALYSIS
		-- Front block
		function CheckFrontBlock()
			-- Check for a block in front of the turtle
			if turtle.detect() then CutDown() else TypeOfMvmt = 1 end
			-- Re-acquire GPS position
			GetGPSCurrentLoc()
		end

		-- Check work zone limits
		function CheckWorkZoneLimits()
			-- Re-acquire GPS position
			GetGPSCurrentLoc()
			-- Check the work zone
			if TurtleGPSPos[3] > zLimitLine[2] then
				MoveBackward(1)
				TurnLeft()
			elseif TurtleGPSPos[3] < zLimitLine[1] then
				MoveBackward(1)
				TurnLeft()
			elseif TurtleGPSPos[1] < xLimitLine[1] then
				MoveBackward(1)
				TurnLeft()
			elseif TurtleGPSPos[1] > xLimitLine[2] then
				MoveBackward(1)
				TurnLeft()
			end
		end

	-- MOVEMENT
		-- Turn at the end of a row (factored out: identical for the first rotation and the following ones)
		function TurnAtRowEnd(direction)
			if direction == "right" then
				TurnRight()
				MoveForward(2)
				TurnRight()
				nextRotation = "left"
			else
				TurnLeft()
				MoveForward(2)
				TurnLeft()
				nextRotation = "right"
			end

			MoveForward(1)
			RangesDone = RangesDone + 1
		end

		function Movement()
			GetGPSCurrentLoc()
			-- First rotation
				if TurtleGPSPos[1] > (xTreeLine[2]+1) and RangesDone == 0 then
					TurnAtRowEnd(TurtleGPSPos[3] == zTreeLine[1] and "right" or "left")

			-- Check tree growing zone
				elseif (TurtleGPSPos[1] > (xTreeLine[2]+1) or TurtleGPSPos[1] < (xTreeLine[1]-1)) and RangesDone < RangesQty then
					TurnAtRowEnd(nextRotation)

			elseif RangesDone == RangesQty then
				GetGPSCurrentLoc()
				MoveForward(math.abs(TurtleGPSPos[1]-xTreeLine[1]))
				MoveForward(1)
				TurnRight()
				MoveForward(math.abs(TurtleGPSPos[3]-zTreeLine[1]))
				TurnRight()
				RangesDone = 0

			else
				CheckFrontBlock()
				if TypeOfMvmt == 1 then MoveForward(1) end

			end

			CheckWorkZoneLimits()

		end

	-- CUTTING AND REPLANTING
		-- Cut
		function CutDown()
			turtle.select(WoodType)
			-- Harvest the first block and get under the tree
			turtle.dig()
			MoveForward(1)

			-- Mine the whole tree, counting the height climbed so we can come back down by exactly
			-- as much (we can't assume the ground is always "minecraft:dirt": grass, podzol, a hole, etc.)
			local TreeHeight = 0
			while turtle.detectUp() do
				turtle.digUp()
				MoveUp(1)
				TreeHeight = TreeHeight + 1
			end

			-- Descend back to the ground: exactly the number of blocks climbed
			for i = 1, TreeHeight do
				turtle.digDown()
				MoveDown(1)
			end

			MoveUp(1)
			-- Call the replant function
			Replant()

			TreesHarvested = TreesHarvested + 1
		end

		-- Replant
		function Replant()
			-- Replanting the sapling
			turtle.select(SSapplings)
			turtle.placeDown()
			if turtle.getItemCount(ESapplings) > 0 then
				TransferIntraInventory(ESapplings, SSapplings, 1)
			elseif turtle.getItemCount(ESapplings) == 0 and turtle.getItemCount(ESapplings - 1) > 0 then
				TransferIntraInventory(ESapplings - 1, SSapplings, 1)
			end
		end

	-- INVENTORY MANAGEMENT
		-- Inventory count
			function InventoryMonitor(StartSlot, EndSlot)
				local ItemCount = 0
				for i=StartSlot, EndSlot, 1 do
					ItemCount = ItemCount + turtle.getItemCount(i)
				end
				return ItemCount
			end

		-- Transfer from outside into the inventory
			function TransferIntoInventory(SlotTo)
				turtle.select(SlotTo)
				local before = turtle.getItemCount(SlotTo)
				turtle.suck(64-before)
				return turtle.getItemCount(SlotTo) > before
			end

		-- Transfer within the inventory
			function TransferIntraInventory(SlotFrom,SlotTo, Quantity)
				turtle.select(SlotFrom)
				turtle.transferTo(SlotTo , Quantity)
			end

		-- Transfer from the inventory to the outside
			function TransferExtraInventory(SlotFrom, Quantity)
				turtle.select(SlotFrom)
				turtle.drop(Quantity)
			end

		-- Check the turtle's needs
			function InventoryCheck()
				-- Inventory count
					SapplingsQty = InventoryMonitor(SSapplings,ESapplings)
					FuelQty = InventoryMonitor(SFuel,EFuel)
					LogQty = InventoryMonitor(SWoodStock,EWoodStock)

				-- Moving logs within the inventory
					if turtle.getItemCount(WoodType) > 1 then
						for i=EWoodStock,SWoodStock, -1 do
							if turtle.getItemCount(i) <= (64 - (turtle.getItemCount(WoodType) - 1)) then
								TransferIntraInventory(WoodType, i, turtle.getItemCount(WoodType) - 1)
								break
							end
						end
					end

				-- Fully recompute needs on every pass (avoids any drift if a previous need couldn't be
				-- fully satisfied, cf TransferIntoInventory), taking into account needs forced by the
				-- server (touchscreen command)

				-- Check need to empty the logs (based on the real total across the range, not a single
				-- slot: the transfer above fills slots starting from EWoodStock, so SWoodStock is the
				-- last one to fill and can't be used alone as a trigger)
					NeedWoodDrop = (LogQty > ((EWoodStock - SWoodStock + 1) * 32)) or ForcedNeedWoodDrop

				-- Check need to restock fuel
					NeedFuel = (FuelQty < 8) or ForcedNeedFuel

				-- Check need to restock saplings
					NeedSaplings = SapplingsQty < 8
		end

	-- PIXELLINK
		-- Connect to the server
			function ConnectToServer()
				local payload = {}
				ServerConnected = PixelLink.request("connect", "turtle", ServerID, payload)
				if ServerConnected then print("Server connected") else print("Server disconnected") end

			end

		-- Sending the turtle's status
			function StatusToServer()
				local SapplingsQty = InventoryMonitor(SSapplings,ESapplings)
				local FuelQty = InventoryMonitor(SFuel,EFuel)
				local LogQty = InventoryMonitor(SWoodStock,EWoodStock)
				local payload = {
					turtleType  = TurtleFunction,
					pos         = TurtleGPSPos,
					orientation = TurtleFacing,
					fuel        = turtle.getFuelLevel() + FuelQty,
					running     = InCycle,
					cycles      = TreesHarvested,
					inventory   = {
						rawMaterial   		= SapplingsQty,
						harvestedMaterial 	= LogQty,
						misc    			= 0
						},
					errors        = {Error},
					ackCommandId  = LastAppliedCommandID, -- Acknowledgement of the last server command applied
					extra         = {}

					}
				PixelLink.send("status", "turtle", ServerID, payload)
			end

		-- Requesting work authorization
			function AuthFromServer()
				local payload = {
					turtleType  		= TurtleFunction,
					pos                 = TurtleGPSPos,
					orientation         = TurtleFacing,
					serverAuthorization = ServerAuthorized
				}
				local ok, payload = PixelLink.request("auth", "turtle", ServerID, payload)
				ServerConnected = ok
				if payload and type(payload) == "table" and payload.authorization ~= nil then
					ServerAuthorized = payload.authorization

				else
					ServerAuthorized = false

				end

				-- Handling an eventual command forced by the server (screen touch buttons). Filtering
				-- by ID avoids re-applying it on every poll until the server has acknowledged it via
				-- StatusToServer (ackCommandId).
				if payload and type(payload) == "table" and payload.command and payload.command.id ~= LastAppliedCommandID then
					local cmd = payload.command
					if cmd.type == "forceRefuel" then
						ForcedNeedFuel = true
						print("Server command received: forced refueling")

					elseif cmd.type == "forceEmpty" then
						ForcedNeedWoodDrop = true
						print("Server command received: forced drop-off")

					elseif cmd.type == "resync" then
						print("Server command received: resynchronization")
						ConnectToServer()
						StatusToServer()

					end
					LastAppliedCommandID = cmd.id
				end

				if ServerConnected and ServerAuthorized then
					print("Server connected, authorized to work")

				elseif ServerConnected and not ServerAuthorized then
					print("Server connected, work forbidden")

				else
					print("Server disconnected, work authorization revoked")

				end

			end

-- PARALLEL FUNCTIONS
	-- Lumberjacking program
		function LumberJacking()
			while ServerConnected do
				FuelManagement()
				InventoryCheck()
				AuthFromServer()

				if not (NeedWoodDrop or NeedFuel or NeedSaplings) and ServerAuthorized then
					Movement()
					StatusToServer()

				else
					ExitWorkZone()

				end

				if not ServerAuthorized then
					print("Authorization denied, waiting 5s before next request.")
					os.sleep(5)
				end

			end

			if not ServerConnected then print("Connection to the server lost, attempting to reconnect...") end

		end

-- PROGRAM
	print("Program version: "..ProgramVersion)
	-- Opening the connection to the RedNET network
	if PixelLink then
		rednet.open(ModemSide)

		while true do
			while not ServerConnected do
				ConnectToServer()
				if not ServerConnected then
					print("Server unreachable, retrying in 10s.")
					os.sleep(10)
				end
			end

			print("Server connected, requesting work authorization...")
			repeat
				AuthFromServer()
				if not ServerAuthorized then
					print("Authorization denied, waiting 5s before next request.")
					os.sleep(5)
				end
			until ServerAuthorized

			TurtleBooting()
			GetInWorkPosition()
			print("Turtle ready, starting the lumberjack program!")

			LumberJacking()  --  exits if ServerConnected becomes false (connection lost)
		end

	else
		print("PixelLink missing, unable to start the turtle. Install the PixelLink module, then reboot the turtle")
		os.sleep()

	end
