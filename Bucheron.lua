-- DECLARATION DES VARIABLES
	-- Globales
		local ProgramVersion	=	"4.0a02"	-- Version actuelle du programme
		local TurtleFunction	=	"bucheron"	-- Fonction de la turtle
		local TreesHarvested 	=	0			-- Nombre d'arbres récoltés sur la run en cours
		local ErrorDetected	=	false		-- Erreur détectée
		local Error		=	""			-- Erreur remontée par la Turtle
		local InCycle		=	false		-- Turtle en production
		
	-- Réseau
		local LocalID		=	os.getComputerID()	-- ID de la turtle
		local ServerID		=	11					-- ID du serveur
		local ModemSide		=	"right"				-- Côté du modem sur la turtle
		local ServerConnected	=	false				-- Serveur ateignable et connecté à la turtle
		local ServerAuthorized	=	false				-- Serveur connecté à la turtle et autorisant le travail
		local CurrentFuelLevel	=	0					-- Niveau de carburant actuel
		local PixelLink 	=	require("PixelLink")
		
		
	-- Inventaire
		-- Inventaire flottant (S = Start / E = End)
			local SSapplings	=	1	-- Début du stock de pousses d'arbre
			local ESapplings	=	3	-- Fin du stock de pousses d'arbre
			local SFuel		=	5	-- Début du réservoir à carburant
			local EFuel		=	6	-- Fin du réservoir à carburant
			local SWoodStock	=	8	-- Début du stock de buches
			local EWoodStock	=	16	-- Fin du stock de buches
		-- Inventaire fixe
			local WoodType		=	4	-- Type de bois à récolter
		-- Quantités		
			local SapplingsQty 	= 	0
			local FuelQty 		= 	0
			local LogQty 		=	0
			
		local InventoryNOK	=	0	-- Inventaire pas prêt pour démarrage de la turtle
		local InventoryNeeds	=	0	-- Type de besoin de l'inventaire lors de la prochaine sortie (3 bits -- > 1 = Pousses à recharger / 10 = Carburant à recharger / 100 = Buches à déposer)
			
	-- Mouvements
		local RangesQty		=	3	-- Nombre de rangées gérées par la turtle
		local RangesDone	=	0	-- Nombre de rangées où la turtle est passée
		local TypeOfMvmt	=	0	-- Type de mouvement (0 = Stop / 1 = Avance normale / 2 = Evitement pousse / 3 = Virage gauche / 4 = Virage droit / 5 = guidage GPS)
		
		-- Coordonnées
			local TurtleGPSPos	=	{0, 0, 0}		-- Position GPS actuelle de la turle
			local TurtleStartPos	=	{-81, 64, 48}	-- Position GPS de démarrage de la turtle
			local TurtleExitPos	=	{0, 0, 0}		-- Position GPS d'entrée/sortie de la zone de travail
			local TurtleFacing	=	0				-- Orientation de la turtle (1 = Nord / 2 = Sud / 3 = Est / 4 = Ouest)
			local FuelChest		=	{-79, 64, 47}	-- Position du coffre de carburant
			local LogsChest		=	{-79, 64, 50}	-- Position du coffre de bois
			local SapsChest		=	{-83, 64, 48}	-- Position du coffre des pousses d'arbre
			local xLimitLine	=	{-88, -70, 0}	-- Zone de travail x (min, max, pas utilisé)
			local zLimitLine	=	{53 ,63 , 0}	-- Zone de travail z (min, max, pas utilisé)
			local xTreeLine		=	{0, 0, 0}		-- Zone de bucheronnage x (min, max, pas utilisé)
			local zTreeLine		=	{0, 0, 0}		-- Zone de bucheronnage z (min, max, pas utilisé)

-- CREATION DES FONCTIONS
	-- FONCTIONS DEPLACEMENTS DE BASE
		-- Rotation gauche
		function TurnLeft()
			-- Virage à gauche et actualisation de la direction de la turtle
			turtle.turnLeft()
			if     TurtleFacing == 1 then TurtleFacing = 4
			elseif TurtleFacing == 2 then TurtleFacing = 3
			elseif TurtleFacing == 3 then TurtleFacing = 1
			else   TurtleFacing = 2
			end
			-- Remise à 0 de la commande de mouvement
			TypeOfMvmt = 0
		end

		-- Rotation droite
		function TurnRight()
			-- Virage à droite et actualisation de la direction de la turtle
			turtle.turnRight()
			if     TurtleFacing == 1 then TurtleFacing = 3
			elseif TurtleFacing == 2 then TurtleFacing = 4
			elseif TurtleFacing == 3 then TurtleFacing = 2
			else   TurtleFacing = 1
			end
			-- Remise à 0 de la commande de mouvement
			TypeOfMvmt = 0
		end

		-- Montée
		function MoveUp(distance)
			for i = 1, distance do
        		turtle.up()
   			end
			GetGPSCurrentLoc()
			TypeOfMvmt = 0
		end

		-- Descente
		function MoveDown(distance)
			for i = 1, distance do
        		turtle.down()
   			end
			GetGPSCurrentLoc()
			TypeOfMvmt = 0
		end

		-- Avance
		function MoveForward(distance)
			for i = 1, distance do
        		turtle.forward()
   			end
			GetGPSCurrentLoc()
			TypeOfMvmt = 0
		end

		-- Recul
		function MoveBackward(distance)
			for i = 1, distance do
        		turtle.back()
   			end
			GetGPSCurrentLoc()
			TypeOfMvmt = 0
		end

	-- GESTION DU CARBURANT
		-- Vérification niveau carburant
		function FuelManagement()
			CurrentFuelLevel = turtle.getFuelLevel()
			if CurrentFuelLevel < 100 then
				Refuel()
			end
		end

		-- Ravitallement carburant
		function Refuel()
			print("Ravitaillement turtle en cours...")
			turtle.select(SFuel)
			local succes = turtle.refuel(turtle.getItemCount(SFuel))
			-- Vérification si le ravitaillement s'est correctement passé
			if succes then
				TransferIntraInventory(EFuel, SFuel, turtle.getItemCount(EFuel))
				return {false, ""}
			else
				return {true, "Ravitaillement échoué"}
			end
		end

	-- ACQUISITION DE LA POSITION GPS ACTUELLE
		function GetGPSCurrentLoc()
			TurtleGPSPos = {gps.locate()}
			return TurtleGPSPos
		end

	-- ACQUISITION DE LA POSITION DE DEPART
		function GetStartLocation()
			-- Acquisition de la position de départ
			GetGPSCurrentLoc()
			print("Calibrage position en cours...")
			-- Acquisition de l'orientation initiale de la turtle
			TurtleStartPos = TurtleGPSPos
			turtle.forward()
			GetGPSCurrentLoc()
			if     (TurtleGPSPos[3]) < (TurtleStartPos[3]) then TurtleFacing = 1
			elseif (TurtleGPSPos[3]) > (TurtleStartPos[3]) then TurtleFacing = 2
			elseif (TurtleGPSPos[1]) > (TurtleStartPos[1]) then TurtleFacing = 3
			elseif (TurtleGPSPos[1]) < (TurtleStartPos[1]) then TurtleFacing = 4
			end
			turtle.back()
			print("Calibrage position terminée.")
			GetGPSCurrentLoc()
			os.sleep(2)
		
		end

	-- PHASE DE DEMARRAGE DE LA TURTLE
		function TurtleBooting()
			print("Vérification carburant de la turtle...")
			-- Rechargement en carburant de la turtle
			ErrorDetected, Error = FuelManagement()
			
			if not ErrorDetected then 
				print("Carburant OK.") 

			else 
				print(Error)
				os.sleep()

			end
			
			-- Instructions de démarrage
			print("Charger la turtle : 1 à 3 : max pousses, 4 : bois à récolter, 5 et 6 : max carburant. 7+ : laisser vide.")
			print("Vérification du matériel nécessaire en cours...")
			os.sleep(5)

			-- Vérification inventaire
			if (turtle.getItemCount(SSapplings) < 5) or (turtle.getItemCount(WoodType) == 0)then
				print("Chargez la turtle, le système redémarrera dans 5 secondes.")
				os.sleep(5)
				os.reboot()
			else
			-- Inventaire OK, préparation turtle
				print("Inventaire OK.")
				os.sleep(1)
				print("Acquisition de la position de départ de la turtle.")
				GetStartLocation()
				print("Démarrage de la turtle dans 10s.")
			end
			os.sleep(10)

		end

	-- MISE EN POSITION DE TRAVAIL
		function GetInWorkPosition()
			-- Comparaison de l'altitude
			GetGPSCurrentLoc()
			-- Décollage de la turtle
			MoveUp(2)

			-- Vérification du sens de démarrage de la turtle et déplacement pour rentrer au point le plus proche dans la zone de travail
			if TurtleFacing == 1 then
				MoveForward(math.abs(TurtleGPSPos[3] - zLimitLine[2]))
			elseif TurtleFacing == 2 then
				MoveForward(math.abs(TurtleGPSPos[3] - zLimitLine[1]))
			elseif TurtleFacing == 3 then
				MoveForward(math.abs(TurtleGPSPos[1] - xLimitLine[1]))
			else
				MoveForward(math.abs(TurtleGPSPos[1] - xLimitLine[2]))
			end
			
			-- Mémorisation du point d'entrée/sortie de la zone de travail
			GetGPSCurrentLoc()
			TurtleExitPos = TurtleGPSPos
			
			-- Déplacement vers le premier arbre pour démarrage cycle de récolte
			TurnRight()
			MoveForward(math.abs(TurtleGPSPos[1]-xTreeLine[1]))
			MoveForward(1)
			TurnLeft()	
			MoveForward(math.abs(TurtleGPSPos[3]-zTreeLine[1]))
			TurnLeft()

			InCycle = true
						
		end

	-- SORTIE DE LA TURTLE
		function ExitWorkZone()
			-- Acquisition position GPS
			GetGPSCurrentLoc()
			
			-- Vérification de l'orientation pour définir la rotation de sortie
			if TurtleFacing == 2 then 
				TurnLeft()
				TurnLeft()
			elseif TurtleFacing == 3 then
				TurnLeft()
			elseif TurtleFacing == 4 then
				TurnRight()
			end
			
			-- Vérification si pas d'entrave devant la turtle, sinon, avance jusqu'à zLimitLine[1]
			while turtle.detect() do
				TurnRight()
				MoveForward(1)
				TurnLeft()
			end
			
			-- Réacquisition position GPS et déplacement vers zLimitLine[1]
			GetGPSCurrentLoc()
			MoveForward(math.abs(TurtleGPSPos[3]-TurtleExitPos[3]))
			
			-- Vérification position x par rapport au point de sortie
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
			
			-- Si la turtle est au point de sortie, alors sortie autorisée
			GetGPSCurrentLoc()
			-- Actions en dehors de la zone 
			if InventoryNeeds > 0 then
				-- Vérification besoin de dépose du bois
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
				
				-- Vérification besoin rechargement en carburant
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
				
				-- Vérification besoin rechargement en pousses
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

			-- Signal hors cycle
			InCycle = false
			
			-- Retour à la position de travail
			while not ServerAuthorized do
				AuthFromServer()
			end
			
			if ServerAuthorized then GetInWorkPosition() end
			
		end

	-- ANALYSE DE L'ENVIRONNEMENT
		-- Bloc frontal
		function CheckFrontBlock()
			-- Vérification s'il y a présence d'un bloc devant la turtle
			if turtle.detect() then CutDown() else TypeOfMvmt = 1 end
			-- Réacquisition de la position GPS
			GetGPSCurrentLoc()	
		end

		-- Bloc sous la turtle
		function CheckBottomBlock()
			-- Analyse du bloc sous la turtle
			local BlockDetected, BlockName = turtle.inspectDown()
			if BlockDetected == true then return BlockName.name end
		end

		-- Vérfication si dans les limites
		function CheckWorkZoneLimits()
			-- Réacquisition de la position GPS
			GetGPSCurrentLoc()
			-- Vérification de la zone de travail
			if TurtleGPSPos[3] > zLimitLine[2] then
				MoveBackward()
				TurnLeft()
			elseif TurtleGPSPos[3] < zLimitLine[1] then
				MoveBackward()
				TurnLeft()
			elseif TurtleGPSPos[1] < xLimitLine[1] then
				MoveBackward()
				TurnLeft()
			elseif TurtleGPSPos[1] > xLimitLine[2] then
				MoveBackward()
				TurnLeft()
			end
		end

	-- DEPLACEMENTS
		function Movement()
			GetGPSCurrentLoc()
			-- Vérification zone de pousse des arbres
			if TurtleGPSPos[1] > (xTreeLine[2]+1) and RangesDone < RangesQty then
				TurnLeft()
				MoveForward(2)
				TurnLeft()
				MoveForward(1)
				RangesDone = RangesDone + 1
			elseif TurtleGPSPos[1] < (xTreeLine[1]-1) and RangesDone < RangesQty then
				TurnRight()
				MoveForward(2)
				TurnRight()
				MoveForward(1)
				RangesDone = RangesDone + 1
			elseif RangesDone == RangesQty then
				GetGPSCurrentLoc()
				MoveForward(math.abs(TurtleGPSPos[1]-xTreeLine[1]))
				MoveForward(1)
				TurnLeft()	
				MoveForward(math.abs(TurtleGPSPos[3]-zTreeLine[1]))
				TurnLeft()
				RangesDone = 0
			else
				CheckFrontBlock()
				if TypeOfMvmt == 1 then MoveForward(1) end
			end
			CheckWorkZoneLimits()
		end

	-- COUPE ET REPLANTAGE
		-- Coupe
		function CutDown()
			turtle.select(WoodType)
			-- Récupération du premier bloc et positionnement sous l'arbre
			turtle.dig()
			MoveForward(1)
			
			-- Minage de l'arbre complet
			while turtle.detectUp() do
				turtle.digUp()
				MoveUp(1)
			end
			
			-- Redescente au sol
			while CheckBottomBlock() ~= "minecraft:dirt" do
				turtle.digDown()
				MoveDown(1)
			end
			
			MoveUp(1)
			-- Appel de la fonction de replantage
			Replant()
			
			TreesHarvested = TreesHarvested + 1
		end

		-- Replantage
		function Replant()
			-- Replantage de la pousse
			turtle.select(SSapplings)
			turtle.placeDown()
			if turtle.getItemCount(ESapplings) > 0 then
				TransferIntraInventory(ESapplings, SSapplings, 1)
			elseif turtle.getItemCount(ESapplings) == 0 and turtle.getItemCount(ESapplings - 1) > 0 then
				TransferIntraInventory(ESapplings - 1, SSapplings, 1)
			end
		end

	-- GESTION DE L'INVENTAIRE
		-- Comptage inventaire
			function InventoryMonitor(StartSlot, EndSlot)
				local ItemCount = 0
				for i=StartSlot, EndSlot, 1 do
					ItemCount = ItemCount + turtle.getItemCount(i)
				end
				return ItemCount
			end

		-- Transfert vers l'inventaire depuis l'exterieur
			function TransferIntoInventory(SlotTo)
				turtle.select(SlotTo)
				turtle.suck(64-turtle.getItemCount())
			end

		-- Transfert au sein de l'inventaire
			function TransferIntraInventory(SlotFrom,SlotTo, Quantity)
				turtle.select(SlotFrom)
				turtle.transferTo(SlotTo , Quantity)
			end

		-- Transfert vers l'exterieur depuis l'inventaire
			function TransferExtraInventory(SlotFrom, Quantity)
				turtle.select(SlotFrom)
				turtle.drop(Quantity)
			end

		-- Vérification des besoins de la turtle
			function InventoryCheck()
				-- Comptage inventaire
					SapplingsQty = InventoryMonitor(SSapplings,ESapplings)
					FuelQty = InventoryMonitor(SFuel,EFuel)
					LogQty = InventoryMonitor(SWoodStock,EWoodStock)

				-- Déplacement des buches dans l'inventaire
					if turtle.getItemCount(WoodType) > 1 then
						for i=EWoodStock,SWoodStock, -1 do
							if turtle.getItemCount(i) <= (64 - (turtle.getItemCount(WoodType) - 1)) then
								TransferIntraInventory(WoodType, i, turtle.getItemCount(WoodType) - 1)
								break
							end
						end
					end
				
				-- Vérification besoin de vider les buches
					if turtle.getItemCount(SWoodStock) > ((EWoodStock - SWoodStock + 1) * 64 - 32) then
						InventoryNeeds = InventoryNeeds + 100
					end
				
				-- Vérification besoin de récupérer du carburant
					if FuelQty < 8 then
						InventoryNeeds = InventoryNeeds + 10
					end
				
				-- Vérification besoin de récupérer des pousses
					if SapplingsQty < 8 then
						InventoryNeeds = InventoryNeeds + 1
					end
		end

	-- PIXELLINK
		-- Connexion au serveur
			function ConnectToServer()
				local payload = {}
				ServerConnected = PixelLink.request("connect", "turtle", ServerID, payload)
				if ServerConnected then print("Serveur connecté") else print("Serveur déconnecté") end

			end

		-- Envoi du statut de la turtle
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

		-- Demande d'autorisation de travail
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
					print("Serveur connecté, autorisation de travailler") 

				elseif ServerConnected and not ServerAuthorized then
					print("Serveur connecté, interdiction de travailler") 

				else
					print("Serveur déconnecté, révocation de l'autorisation de travailler") 

				end

			end

-- FONCTIONS PARALLELES
	-- Programme de bucheronage
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
			end			
			if not ServerConnected then print("Connexion au serveur perdue, tentative de reconnexion...") end
		end

-- PROGRAMME
	print("Version programme : "..ProgramVersion)
	-- Ouverture de la connexion au réseau RedNET
	if pixellink then
		rednet.open(ModemSide)

		while true do
			while not ServerConnected do
				ConnectToServer()
				if not ServerConnected then
					print("Serveur inaccessible, nouvelle tentative dans 10s.")
					os.sleep(10)
				end
			end

			print("Serveur connecté, demande d'autorisation de travail...")
			repeat
				AuthFromServer()
				if not ServerAuthorized then
					print("Autorisation refusée, attente 5s avant nouvelle demande.")
					os.sleep(5)
				end
			until ServerAuthorized

			TurtleBooting()
			GetInWorkPosition()
			print("Turtle prête, lancement du programme bûcheron !")

			LumberJacking()  --  sort si ServerConnected devient false (perte connexion)
		end

	else
		print("PixelLink manquant, impossible de démarrer la turtle. Installez le module PixelLink, puis redémarrez la turtle")
		os.sleep()

	end
