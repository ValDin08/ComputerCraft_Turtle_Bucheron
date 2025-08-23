-- VARIABLE DECLARATION
	-- Globals
		local ProgramVersion	=	"4.0-a05"	-- Current program version
		local TurtleFunction	=	"bucheron"	-- Turtle function
		local TreesHarvested 	=	0			-- Number of trees harvested in current run
		local ErrorDetected		=	false		-- Error detected
		local Error				=	""			-- Erreur remontée par la Turtle
		local InCycle			=	false		-- Turtle in production
		
	-- Network
		local LocalID			=	os.getComputerID()	-- ID de la turtle
		local ServerID			=	11					-- Server ID
		local ModemSide			=	"right"				-- Modem side on the turtle
		local ServerConnected	=	false				-- Server reachable and connected to the turtle
		local ServerAuthorized	=	false				-- Server connected to the turtle and authorizing work
		local CurrentFuelLevel	=	0					-- Current fuel level
		local PixelLink 		=	require("PixelLink")
		
		
	-- Inventory
		-- Floating inventory (S = Start / E = End)
			local SSapplings	=	1	-- Start of saplings stock
			local ESapplings	=	3	-- End of saplings stock
			local SFuel			=	5	-- Start of fuel reserve
			local EFuel			=	6	-- End of fuel reserve
			local SWoodStock	=	8	-- Start of logs stock
			local EWoodStock	=	16	-- End of logs stock
		-- Fixes inventory
			local WoodType		=	4	-- Type of wood to harvest
		-- Quantities		
			local SapplingsQty 	= 	0
			local FuelQty 		= 	0
			local LogQty 		=	0
			
		local InventoryNOK		=	0	-- Inventory not ready to start la turtle
		local InventoryNeeds	=	0	-- Inventory need type lors de la prochaine sortie (3 bits -- > 1 = Pousses à recharger / 10 = Carburant à recharger / 100 = Buches à déposer)
			
	-- Movements
		local RangesQty			=	3	-- Ranges quantity to harvest
		local RangesDone		=	0	-- Range quantity harvested
		local TypeOfMvmt		=	0	-- Movement type (0 = Stop / 1 = Forward / 2 = Sappling dodge / 3 = Left turn / 4 = Right turn / 5 = GPS guidance)
		local nextRotation		=   ""  -- Rotation suivante
		
		-- Coordinates
			local TurtleGPSPos	=	{0, 0, 0}		-- Current turtle GPS position
			local TurtleStartPos=	{-81, 64, 48}	-- Turtle start GPS position
			local TurtleExitPos	=	{0, 0, 0}		-- Work zone entry/exit GPS position
			local TurtleFacing	=	0				-- Turtle orientation (1 = Nord / 2 = Sud / 3 = Est / 4 = Ouest)
			local FuelChest		=	{-79, 64, 47}	-- Fuel chest position
			local LogsChest		=	{-79, 64, 50}	-- Wood logs chest position
			local SapsChest		=	{-83, 64, 48}	-- Sapplings chest position
			local xLimitLine	=	{-88, -70, 0}	-- Working area x (min, max, not used)
			local zLimitLine	=	{53 ,63 , 0}	-- Working area z (min, max, not used)
			local xTreeLine		=	{-85, -73, 0}   -- Lumberjacking area x (min, max, not used)
			local zTreeLine		=	{56, 60, 0}		-- Lumberjacking area z (min, max, not used)

-- FUNCTIONS
	-- FUNCTIONS BASIC MOVEMENTS
		-- Left turn
		function TurnLeft()
			-- Left turn and update turtle facing
			turtle.turnLeft()
			if     TurtleFacing == 1 then TurtleFacing = 4
			elseif TurtleFacing == 2 then TurtleFacing = 3
			elseif TurtleFacing == 3 then TurtleFacing = 1
			else   TurtleFacing = 2
			end
			-- Reset movement command
			TypeOfMvmt = 0
		end

		-- Right turn
		function TurnRight()
			-- Right turn and update turtle facing
			turtle.turnRight()
			if     TurtleFacing == 1 then TurtleFacing = 3
			elseif TurtleFacing == 2 then TurtleFacing = 4
			elseif TurtleFacing == 3 then TurtleFacing = 2
			else   TurtleFacing = 1
			end
			-- Reset movement command
			TypeOfMvmt = 0
		end

		-- Up
		function MoveUp(distance)
			for i = 1, distance do
        		turtle.up()
   			end
			GetGPSCurrentLoc()
			TypeOfMvmt = 0
		end

		-- Down
		function MoveDown(distance)
			for i = 1, distance do
        		turtle.down()
   			end
			GetGPSCurrentLoc()
			TypeOfMvmt = 0
		end

		-- Forward
		function MoveForward(distance)
			for i = 1, distance do
        		turtle.forward()
   			end
			GetGPSCurrentLoc()
			TypeOfMvmt = 0
		end

		-- Reverse
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
				Refuel()
			end
		end

		-- Refueling
		function Refuel()
			print("Turtle refueling...")
			turtle.select(SFuel)
			local succes = turtle.refuel(turtle.getItemCount(SFuel))
			-- Check if refueling correctly done
			if succes then
				TransferIntraInventory(EFuel, SFuel, turtle.getItemCount(EFuel))
				return {false, ""}
			else
				return {true, "Refueling failed"}
			end
		end

	-- ACQUIRE CURRENT GPS POSITION
		function GetGPSCurrentLoc()
			TurtleGPSPos = {gps.locate()}
			return TurtleGPSPos
		end

	-- ACQUIRING START POSITION
		function GetStartLocation()
			-- Acquiring start position
			GetGPSCurrentLoc()
			print("Position calibration in progress...")
			-- Acquiring start orientation
			TurtleStartPos = TurtleGPSPos
			turtle.forward()
			GetGPSCurrentLoc()
			if     (TurtleGPSPos[3]) < (TurtleStartPos[3]) then TurtleFacing = 1
			elseif (TurtleGPSPos[3]) > (TurtleStartPos[3]) then TurtleFacing = 2
			elseif (TurtleGPSPos[1]) > (TurtleStartPos[1]) then TurtleFacing = 3
			elseif (TurtleGPSPos[1]) < (TurtleStartPos[1]) then TurtleFacing = 4
			end
			turtle.back()
			print("Position calibration finished.")
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
				os.sleep()

			end
			
			-- Startup instructions
			print("Load turtle : 1 to 3 : max sapplings, 4 : wood to harvest, 5 and 6 : max fuel. 7+ : leave empty.")
			print("Checking required supplies...")
			os.sleep(5)

			-- Inventory check
			if (turtle.getItemCount(SSapplings) < 5) or (turtle.getItemCount(WoodType) == 0)then
				print("Load the turtle, system will reboot in 5 seconds.")
				os.sleep(5)
				os.reboot()
			else
			-- Inventory OK, preparing turtle
				print("Inventory OK.")
				os.sleep(1)
				print("Acquiring turtle start position.")
				GetStartLocation()
				print("Starting the turtle in 10s.")
			end
			os.sleep(10)

		end

	-- GETTING IN WORK POSITION
		function GetInWorkPosition()
			-- Compare altitude
			GetGPSCurrentLoc()
			-- Turtle lift-off
			MoveUp(2)

			-- Checking starting orientation and moving toward nearest entry position
			if TurtleFacing == 1 then
				MoveForward(math.abs(TurtleGPSPos[3] - zLimitLine[2]))
			elseif TurtleFacing == 2 then
				MoveForward(math.abs(TurtleGPSPos[3] - zLimitLine[1]))
			elseif TurtleFacing == 3 then
				MoveForward(math.abs(TurtleGPSPos[1] - xLimitLine[1]))
			else
				MoveForward(math.abs(TurtleGPSPos[1] - xLimitLine[2]))
			end
			
			-- Save work zone entry/exit point
			GetGPSCurrentLoc()
			TurtleExitPos = TurtleGPSPos
			
			-- Moving toward first tree to start cycle
			TurnRight()
			MoveForward(math.abs(TurtleGPSPos[1]-xTreeLine[1]))
			MoveForward(1)
			TurnLeft()	
			MoveForward(math.abs(TurtleGPSPos[3]-zTreeLine[1]))
			TurnLeft()

			InCycle = true
						
		end

	-- TURTLE EXIT
		function ExitWorkZone()
			-- Acquiring GPS position
			GetGPSCurrentLoc()
			
			-- Check orientation to define exit turn
			if TurtleFacing == 2 then 
				TurnLeft()
				TurnLeft()
			elseif TurtleFacing == 3 then
				TurnLeft()
			elseif TurtleFacing == 4 then
				TurnRight()
			end
			
			-- Check if no obstacle in front of the turtle, if not, moving to zLimitLine[1]
			while turtle.detect() do
				TurnRight()
				MoveForward(1)
				TurnLeft()
			end
			
			-- Réacquisition position GPS et déplacement vers zLimitLine[1]
			GetGPSCurrentLoc()
			MoveForward(math.abs(TurtleGPSPos[3]-TurtleExitPos[3]))
			
			-- Check x position relative to exit point
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
			
			-- If turtle is at exit point, then exit allowed
			GetGPSCurrentLoc()
			-- Actions outside the zone 
			if InventoryNeeds > 0 then
				-- Check need to drop wood
				if InventoryNeeds >= 100 then
					GetGPSCurrentLoc()
					MoveForward(math.abs(TurtleGPSPos[3]-(LogsChest[3])))
					TurnRight()
					MoveForward(math.abs(TurtleGPSPos[1]-(LogsChest[1]+1)))
					for i=SWoodStock,EWoodStock do
						TransferExtraInventory(i, turtle.getItemCount(i))
					end
					InventoryNeeds = InventoryNeeds - 100
					MoveBackward(1)
					if not InventoryNeeds == 0 then	TurnLeft() else TurnRight() end
				end
				
				-- Check need to refuel
				if InventoryNeeds >= 10 then
					GetGPSCurrentLoc()
					MoveForward(math.abs(TurtleGPSPos[3]-(FuelChest[3])))
					TurnRight()
					MoveForward(math.abs(TurtleGPSPos[1]-(FuelChest[1]+1)))
					for i=SFuel,EFuel do
						TransferIntoInventory(i)
					end
					InventoryNeeds = InventoryNeeds - 10
					MoveBackward(1)
					TurnRight()
				end
				
				-- Check need to restock saplings
				if InventoryNeeds == 1 then
					GetGPSCurrentLoc()
					MoveForward(math.abs(TurtleGPSPos[3]-SapsChest[3]))
					if TurtleFacing == 1 then TurnLeft() elseif TurtleFacing == 2 then TurnRight() end
					MoveForward(math.abs(TurtleGPSPos[1]-(SapsChest[1]+1)))
					for i=SSapplings,ESapplings do
						TransferIntoInventory(i)
					end
					InventoryNeeds = InventoryNeeds - 1
					MoveBackward(1)
					TurnLeft()
				end
			elseif not ServerAuthorized then
				MoveForward(math.abs(TurtleGPSPos[3]-TurtleStartPos[3]))
				TurnLeft()
				TurnLeft()
			end

			-- Out of cycle signal
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
			-- Check if no obstacle in front of the turtle
			if turtle.detect() then CutDown() else TypeOfMvmt = 1 end
			-- Re-acquire GPS position
			GetGPSCurrentLoc()	
		end

		-- Block under the turtle
		function CheckBottomBlock()
			-- Analyze the block bellow the Turtle
			local BlockDetected, BlockName = turtle.inspectDown()
			if BlockDetected == true then return BlockName.name end
		end

		-- Check work zone limits
		function CheckWorkZoneLimits()
			-- Re-acquire GPS position
			GetGPSCurrentLoc()
			-- Check work zone
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
		function Movement()
			GetGPSCurrentLoc()
			-- First rotation
				if TurtleGPSPos[1] > (xTreeLine[2]+1) and RangesDone == 0 then
					if TurtleGPSPos[3] == zTreeLine[1] then
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
			
			-- Check tree growing area
				elseif TurtleGPSPos[1] > (xTreeLine[2]+1) and RangesDone < RangesQty then
					if nextRotation == "right" then
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
		
			elseif TurtleGPSPos[1] < (xTreeLine[1]-1) and RangesDone < RangesQty then
				if nextRotation == "right" then
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

	-- CUT AND REPLANT
		-- Cut
			function CutDown()
				turtle.select(WoodType)
				-- Harvest first block and getting beneath the tree
				turtle.dig()
				MoveForward(1)
				
				-- Full tree harvest
				while turtle.detectUp() do
					turtle.digUp()
					MoveUp(1)
				end
				
				-- Going back to the ground
				while CheckBottomBlock() ~= "minecraft:dirt" do
					turtle.digDown()
					MoveDown(1)
				end
				
				MoveUp(1)
				-- Call replant function
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
		-- Inventory counting
			function InventoryMonitor(StartSlot, EndSlot)
				local ItemCount = 0
				for i=StartSlot, EndSlot, 1 do
					ItemCount = ItemCount + turtle.getItemCount(i)
				end
				return ItemCount
			end

		-- Transfer from exterior to internal inventory
			function TransferIntoInventory(SlotTo)
				turtle.select(SlotTo)
				turtle.suck(64-turtle.getItemCount())
			end

		-- Transfer inside internal inventory
			function TransferIntraInventory(SlotFrom,SlotTo, Quantity)
				turtle.select(SlotFrom)
				turtle.transferTo(SlotTo , Quantity)
			end

		-- Transfer from internal inventory to exterior
			function TransferExtraInventory(SlotFrom, Quantity)
				turtle.select(SlotFrom)
				turtle.drop(Quantity)
			end

		-- Check turtle needs
			function InventoryCheck()
				-- Inventory count
					SapplingsQty = InventoryMonitor(SSapplings,ESapplings)
					FuelQty = InventoryMonitor(SFuel,EFuel)
					LogQty = InventoryMonitor(SWoodStock,EWoodStock)

				-- Moving logs in inventory
					if turtle.getItemCount(WoodType) > 1 then
						for i=EWoodStock,SWoodStock, -1 do
							if turtle.getItemCount(i) <= (64 - (turtle.getItemCount(WoodType) - 1)) then
								TransferIntraInventory(WoodType, i, turtle.getItemCount(WoodType) - 1)
								break
							end
						end
					end
				
				-- Check need to empty logs
					if turtle.getItemCount(SWoodStock) > 32 then
						InventoryNeeds = InventoryNeeds + 100
					end
				
				-- Check if need to get fuel
					if FuelQty < 8 then
						InventoryNeeds = InventoryNeeds + 10
					end
				
				-- Check if need to get sapplings
					if SapplingsQty < 8 then
						InventoryNeeds = InventoryNeeds + 1
					end
		end

	-- PIXELLINK
		-- Server connection
			function ConnectToServer()
				local payload = {}
				ServerConnected = PixelLink.request("connect", "turtle", ServerID, payload)
				if ServerConnected then print("Serveur connecté") else print("Serveur déconnecté") end

			end

		-- Sending turtle status
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
					errors      = {Error},                    
					extra       = {}

					}				
				PixelLink.send("status", "turtle", ServerID, payload)
			end	

		-- Authorization to server
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

				if ServerConnected and ServerAuthorized then 
					print("Server connected, authorized to work") 

				elseif ServerConnected and not ServerAuthorized then
					print("Server connected, unauthorized to work") 

				else
					print("Server disctonnected, revoke work authorization") 

				end

			end

-- PARALLEL FUNCTIONS
	-- Lumberjacking
		function LumberJacking()
			while ServerConnected do
				FuelManagement()
				InventoryCheck()
				AuthFromServer()
								
				if InventoryNeeds == 0 and ServerAuthorized then
					Movement()
					StatusToServer()
					
				else
					ExitWorkZone()
					
				end
				
				if not ServerAuthorized then
					print("Work authorization denied, waiting 5s before new request.")
					os.sleep(5)
				end
				
			end	
			
			if not ServerConnected then print("Server connection lost, waiting for reconnection...") end
			
		end

-- PROGRAM
	print("Program version : "..ProgramVersion)
	-- Opening connection to RedNET
	if PixelLink then
		rednet.open(ModemSide)

		while true do
			while not ServerConnected do
				ConnectToServer()
				if not ServerConnected then
					print("Server not reachable, waiting 10s before new request.")
					os.sleep(10)
				end
			end

			print("Server connected, requesting for work authorization...")
			repeat
				AuthFromServer()
				if not ServerAuthorized then
					print("Work authorization denied, waiting 5s before new request.")
					os.sleep(5)
				end
			until ServerAuthorized

			TurtleBooting()
			GetInWorkPosition()
			print("Turtle ready, starting lumberjacking !")

			LumberJacking()
		end

	else
		print("PixelLink missing, unable to start the turtle. Install PixelLink module, then reboot the turtle.")
		os.sleep()

	end