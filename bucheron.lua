--Déclaration des variables
	--Globales
		local WorkingMode		= ""
		local ProgramVersion	=	"2.3"
	--Inventaire
		--Inventaire flottant (S = Start / E = End)
			local SSapplings	=	1	--Début du stock de pousses d'arbre
			local ESapplings	=	3	--Fin du stock de pousses d'arbre
			local SFuel			=	5	--Début du réservoir à carburant
			local EFuel			=	6	--Fin du réservoir à carburant
			local SWoodStock	=	8	--Début du stock de buches
			local EWoodStock	=	16	--Fin du stock de buches
		--Inventaire fixe
			local WoodType		=	4	--Type de bois à récolter
			
		local InventoryNOK		=	0	--Inventaire pas prêt pour démarrage de la turtle
		local InventoryNeeds	=	0	--Type de besoin de l'inventaire lors de la prochaine sortie (3 bits --> 1 = Pousses à recharger / 10 = Carburant à recharger / 100 = Buches à déposer)
			
	--Mouvements
		local RangesQty			=	3	--Nombre de rangées gérées par la turtle
		local RangesDone		=	0	--Nombre de rangées où la turtle est passée
		local TypeOfMvmt		=	0	--Type de mouvement (0 = Stop / 1 = Avance normale / 2 = Evitement pousse / 3 = Virage gauche / 4 = Virage droit / 5 = guidage GPS)
		local FrontBlock		=	0	--Bloc frontal (0 = Vide / 1 = Pousse / 2 = Arbre prêt à couper / 3 = Limite)
		
		--Coordonnées
			local TurtleGPSPos	=	{0, 0, 0}		--Position GPS actuelle de la turle
			local TurtleStartPos=	{-81, 64, 48}	--Position GPS de démarrage de la turtle
			local TurtleExitPos	=	{0, 0, 0}		--Position GPS d'entrée/sortie de la zone de travail
			local TurtleFacing	=	0				--Orientation de la turtle (1 = Nord / 2 = Sud / 3 = Est / 4 = Ouest)
			local FuelChest		=	{-79, 64, 47}	--Position du coffre de carburant
			local LogsChest		=	{-79, 64, 50}	--Position du coffre de bois
			local SapsChest		=	{-83, 64, 48}	--Position du coffre des pousses d'arbre
			local xLine			=	{-88, -70, 0}	--Zone de travail x (min, max, pas utilisé)
			local zLine			=	{53 ,63 , 0}	--Zone de travail z (min, max, pas utilisé)
			
			--Grille des arbres (à gauche de la grille se situe le stand de retrait de la turtle)
			local C7, B7, A7	=	{-73, 65, 56}, {-73, 65, 58}, {-73, 65, 60}
			local C6, B6, A6	=	{-75, 65, 56}, {-75, 65, 58}, {-75, 65, 60}
			local C5, B5, A5	=	{-77, 65, 56}, {-77, 65, 58}, {-77, 65, 60}
			local C4, B4, A4	=	{-79, 65, 56}, {-79, 65, 58}, {-79, 65, 60}
			local C3, B3, A3	=	{-81, 65, 56}, {-81, 65, 58}, {-81, 65, 60}
			local C2, B2, A2	=	{-83, 65, 56}, {-83, 65, 58}, {-83, 65, 60}
			local C1, B1, A1	=	{-85, 65, 56}, {-85, 65, 58}, {-85, 65, 60}

--Création des fonctions
--FONCTIONS DEPLACEMENTS DE BASE
function TurnLeft()
	--Virage à gauche et actualisation de la direction de la turtle
	turtle.turnLeft()
	if     TurtleFacing == 1 then TurtleFacing = 4
	elseif TurtleFacing == 2 then TurtleFacing = 3
	elseif TurtleFacing == 3 then TurtleFacing = 1
	else   TurtleFacing = 2
	end
	--Remise à 0 de la commande de mouvement
	TypeOfMvmt = 0
end

function TurnRight()
	--Virage à droite et actualisation de la direction de la turtle
	turtle.turnRight()
	if     TurtleFacing == 1 then TurtleFacing = 3
	elseif TurtleFacing == 2 then TurtleFacing = 4
	elseif TurtleFacing == 3 then TurtleFacing = 2
	else   TurtleFacing = 1
	end
	--Remise à 0 de la commande de mouvement
	TypeOfMvmt = 0
end

function MoveUp()
	turtle.up()
	GetGPSCurrentLoc()
end

function MoveDown()
	turtle.down()
	GetGPSCurrentLoc()
end

function MoveForward(Distance)
	local DistanceDone	=	0
	while DistanceDone < Distance do
		turtle.forward()
		GetGPSCurrentLoc()
		DistanceDone = DistanceDone + 1
	end
	--Remise à 0 de la commande de mouvement
	TypeOfMvmt = 0
	DistanceDone = 0
end

function MoveBackward()
	turtle.back()
	GetGPSCurrentLoc()
end

function DodgeSappling()
	turtle.digUp()
	MoveUp()
	turtle.dig()
	MoveForward(1)
	turtle.dig()
	MoveForward(1)
	MoveDown()
	--Remise à 0 de la commande de mouvement
	TypeOfMvmt = 0
end

--ACQUISITION DE LA POSITION GPS ACTUELLE
function GetGPSCurrentLoc()
	TurtleGPSPos = {gps.locate()}
	return TurtleGPSPos
end

--PHASE DE DEMARRAGE DE LA TURTLE
function TurtleBooting()
	print("Vérification carburant de la turtle...")
	--Rechargement en carburant de la turtle
	if (turtle.getFuelLevel() < 100) then
		Refuel()
	end
	print("Carburant OK.")
	
	--Instructions de démarrage
	print("Charger la turtle : 1 à 3 = max pousses, 4 = bois à récolter, 5 et 6 = max carburant.")
	print("Vérification du matériel nécessaire en cours.")
	os.sleep(5)

	--Vérification inventaire
	if (turtle.getItemCount(SSapplings) < 5) or (turtle.getItemCount(WoodType) == 0)then
		print("Chargez la turtle, le système redémarrera dans 5 secondes.")
		os.sleep(5)
		os.reboot()
	else
	--Inventaire OK, préparation turtle
		print("Inventaire OK.")
		os.sleep(1)
		print("Acquisition de la position de départ de la turtle.")
		GetStartLocation()
		print("Démarrage de la turtle dans 10s.")
	end

	os.sleep(10)
	
	GetInWorkPosition()
	os.sleep(2)
end

function GetStartLocation()
	--Demande de démarrage manuel ou automatique
	print("Fonctionnement 'auto' ou 'manu'?")
	WorkingMode = string.lower(read())

	if WorkingMode == "auto" then
		--Acquisition de la position de départ
		GetGPSCurrentLoc()
		print("Calibrage position en cours...")
		--Acquisition de l'orientation initiale de la turtle
		TurtleStartPos = TurtleGPSPos
		turtle.forward()
		GetGPSCurrentLoc()
		if     (TurtleGPSPos[3]) < (TurtleStartPos[3]) then TurtleFacing = 1
		elseif (TurtleGPSPos[3]) > (TurtleStartPos[3]) then TurtleFacing = 2
		elseif (TurtleGPSPos[1]) > (TurtleStartPos[1]) then TurtleFacing = 3
		elseif (TurtleGPSPos[1]) < (TurtleStartPos[1]) then TurtleFacing = 4
		end
		turtle.back()
	elseif WorkingMode == "manu" then
		print("Entrez point de départ x.")
		TurtleStartPos[1] = tonumber(read())
		print("Entrez point de départ y.")
		TurtleStartPos[2] = tonumber(read())
		print("Entrez point de départ z.")
		TurtleStartPos[3] = tonumber(read())
		print("Entrez orientation de départ : 1 = Nord, 2 = Sud, 3 = Est, 4 = Ouest.")
		TurtleFacing = tonumber(read())
	end
	print("Calibrage position terminée.")
	GetGPSCurrentLoc()
	os.sleep(2)
	
end

function GetInWorkPosition()
	if WorkingMode == "auto" then
		--Comparaison de l'altitude
		GetGPSCurrentLoc()
		if TurtleGPSPos[2] == TurtleStartPos[2] then
			--Décollage de la turtle
			MoveUp()
			GetGPSCurrentLoc()
		end

		--Vérification du sens de démarrage de la turtle et déplacement pour rentrer au point le plus proche dans la zone de travail
		if TurtleFacing == 1 then
			MoveForward(math.abs(TurtleGPSPos[3] - zLine[2]))
		elseif TurtleFacing == 2 then
			MoveForward(math.abs(TurtleGPSPos[3] - zLine[1]))
		elseif TurtleFacing == 3 then
			MoveForward(math.abs(TurtleGPSPos[1] - xLine[1]))
		else
			MoveForward(math.abs(TurtleGPSPos[1] - xLine[2]))
		end
		
		--Mémorisation du point d'entrée/sortie de la zone de travail
		GetGPSCurrentLoc()
		TurtleExitPos = TurtleGPSPos
		
		--Déplacement vers arbre A1 pour démarrage cycle de récolte
		TurnRight()
		MoveForward(math.abs(TurtleGPSPos[1]-A1[1]))
		MoveForward(1)
		TurnLeft()	
		MoveForward(math.abs(TurtleGPSPos[3]-A1[3]))
		TurnLeft()
		
	elseif WorkingMode == "manu" then
		local ManualCoordinates = {0, 0, 0}
		print("Entrez coordonnée x cible. - INACTIF EN v2.0")
		ManualCoordinates[1] = tonumber(read())
		print("Entrez coordonnée y cible.")
		ManualCoordinates[2] = tonumber(read())
		print("Entrez coordonnée z cible. - INACTIF EN v2.0")
		ManualCoordinates[3] = tonumber(read())
		
		GetGPSCurrentLoc()
		while not TurtleGPSPos[2] == ManualCoordinates[2] do
			if TurtleGPSPos < ManualCoordinates[2] then MoveUp() else MoveDown() end
		end
		
		print("Placement manuel autre que 'y' inactif en v2.0, patientez...")
		os.sleep(2)
		
	elseif WorkingMode == "hold" then 
		os.sleep(2) 
	end
		
end

--SORTIE DE LA TURTLE
function ExitWorkZone()
	--Acquisition position GPS
	GetGPSCurrentLoc()
	--Analyse de l'altitude
	if TurtleGPSPos[2] > (TurtleStartPos[2]+1) then
		while not TurtleGPSPos == (TurtleStartPos[2]+1) do MoveDown() end
	elseif TurtleGPSPos[2] < (TurtleStartPos[2]+1) then
		while not TurtleGPSPos == (TurtleStartPos[2]+1) do MoveUp() end
	end
	
	--Vérification de l'orientation pour définir la rotation de sortie
	if TurtleFacing == 2 then 
		TurnLeft()
		TurnLeft()
	elseif TurtleFacing == 3 then
		TurnLeft()
	elseif TurtleFacing == 4 then
		TurnRight()
	end
	
	--Vérification si pas d'entrave devant la turtle, sinon, avance jusqu'à zLine[1]
	while turtle.detect() do
		TurnRight()
		MoveForward(1)
		TurnLeft()
	end
	
	--Réacquisition position GPS et déplacement vers zLine[1]
	GetGPSCurrentLoc()
	MoveForward(math.abs(TurtleGPSPos[3]-TurtleExitPos[3]))
	
	--Vérification position x par rapport au point de sortie
	GetGPSCurrentLoc()
	if TurtleGPSPos[1] < TurtleExitPos[1] then
		TurnRight()
		MoveForward(math.abs(TurtleGPSPos[1]-TurtleExitPos[1]))
		TurnLeft()
		MoveDown()
	elseif TurtleGPSPos[1] > TurtleExitPos[1] then
		TurnLeft()
		MoveForward(math.abs(TurtleGPSPos[1]-TurtleExitPos[1]))
		TurnRight()
		MoveDown()
	end
	
	--Si la turtle est au point de sortie, alors sortie autorisée
	GetGPSCurrentLoc()
	--Actions en dehors de la zone 
	if InventoryNeeds > 0 then
		--Vérification besoin de dépose du bois
		if InventoryNeeds >= 100 then
			GetGPSCurrentLoc()
			MoveForward(math.abs(TurtleGPSPos[3]-(LogsChest[3])))
			TurnRight()
			MoveForward(math.abs(TurtleGPSPos[1]-(LogsChest[1]+1)))
			for i=SWoodStock,EWoodStock do
				TransferExtraInventory(i, turtle.getItemCount(i))
			end
			InventoryNeeds = InventoryNeeds - 100
			MoveBackward()
			if not InventoryNeeds == 0 then	TurnLeft() else TurnRight() end
		end
		
		--Vérification besoin rechargement en carburant
		if InventoryNeeds >= 10 then
			GetGPSCurrentLoc()
			MoveForward(math.abs(TurtleGPSPos[3]-(FuelChest[3])))
			TurnRight()
			MoveForward(math.abs(TurtleGPSPos[1]-(FuelChest[1]+1)))
			for i=SFuel,EFuel do
				TransferIntoInventory(i)
			end
			InventoryNeeds = InventoryNeeds - 10
			MoveBackward()
			TurnRight()
		end
		
		--Vérification besoin rechargement en pousses
		if InventoryNeeds == 1 then
			GetGPSCurrentLoc()
			MoveForward(math.abs(TurtleGPSPos[3]-SapsChest[3]))
			if TurtleFacing == 1 then TurnLeft() elseif TurtleFacing == 2 then TurnRight() end
			MoveForward(math.abs(TurtleGPSPos[1]-(SapsChest[1]+1)))
			for i=SSapplings,ESapplings do
				TransferIntoInventory(i)
			end
			InventoryNeeds = InventoryNeeds - 1
			MoveBackward()
			TurnLeft()
		end
	end
	
	--Retour à la position de travail
	GetInWorkPosition()
end

--ANALYSE DE L'ENVIRONNEMENT
function CheckFrontBlock()
	--Vérification s'il y a présence d'un bloc devant la turtle
	if turtle.detect() then
		--Vérification si le bloc est une pousse ou un arbre
		turtle.select(SSapplings)
		if turtle.compare() then TypeOfMvmt = 2
		else CutDown()
		end
	else TypeOfMvmt = 1
	end
	--Réacquisition de la position GPS
	GetGPSCurrentLoc()	
end

function CheckBottomBlock()
	--Analyse du bloc sous la turtle
	local BlockDetected, BlockName = turtle.inspectDown()
	if BlockDetected == true then return BlockName.name end
end

function CheckWorkZoneLimits()
	--Réacquisition de la position GPS
	GetGPSCurrentLoc()
	--Vérification de la zone de travail
	if TurtleFacing == 1 then
		if TurtleGPSPos[3] > zLine[2] then
			MoveBackward()
			TurnLeft()
		end
	elseif TurtleFacing == 2 then
		if TurtleGPSPos[3] < zLine[1] then
			MoveBackward()
			TurnLeft()
		end
	elseif TurtleFacing == 3 then
		if TurtleGPSPos[1] < xLine[1] then
			MoveBackward()
			TurnLeft()
		end	
	else
		if TurtleGPSPos[1] > xLine[2] then
			MoveBackward()
			TurnLeft()
		end	
	end
end

--DEPLACEMENTS
function Movement()
	GetGPSCurrentLoc()
	--Vérification zone de pousse des arbres
	if TurtleGPSPos[1] > (C7[1]+1) and RangesDone < RangesQty then
		TurnLeft()
		MoveForward(2)
		TurnLeft()
		MoveForward(1)
		RangesDone = RangesDone + 1
	elseif TurtleGPSPos[1] < (A1[1]-1) and RangesDone < RangesQty then
		TurnRight()
		MoveForward(2)
		TurnRight()
		MoveForward(1)
		RangesDone = RangesDone + 1
	elseif RangesDone == RangesQty then
		GetGPSCurrentLoc()
		MoveForward(math.abs(TurtleGPSPos[1]-A1[1]))
		MoveForward(1)
		TurnLeft()	
		MoveForward(math.abs(TurtleGPSPos[3]-A1[3]))
		TurnLeft()
		RangesDone = 0
	else
		CheckFrontBlock()
		if TypeOfMvmt == 1 then MoveForward(1)
		elseif TypeOfMvmt == 2 then DodgeSappling()
		end
	end	
	CheckWorkZoneLimits()
end

--COUPE ET REPLANTAGE
function CutDown()
	turtle.select(WoodType)
	--Récupération du premier bloc et positionnement sous l'arbre
	turtle.dig()
	MoveForward(1)
	
	--Minage de l'arbre complet
	while turtle.detectUp() do
		turtle.digUp()
		MoveUp()
	end
	
	--Redescente au sol
	while CheckBottomBlock() ~= "minecraft:dirt" do
		turtle.digDown()
		MoveDown()
	end
	
	MoveBackward()
	--Appel de la fonction de replantage
	Replant()
end

function Replant()
	--Replantage de la pousse
	turtle.select(SSapplings)
	turtle.place()
	if turtle.getItemCount(ESapplings) > 0 then
		TransferIntraInventory(ESapplings, SSapplings, 1)
	elseif turtle.getItemCount(ESapplings) == 0 and turtle.getItemCount(ESapplings - 1) > 0 then
		TransferIntraInventory(ESapplings - 1, SSapplings, 1)
	end
	--Evitement de la pousse plantée
	turtle.digUp()
	MoveUp()
	turtle.dig()
	MoveForward(1)
	turtle.dig()
	MoveForward(1)
	MoveDown()
end

--RAVITAILLEMENT CARBURANT
function Refuel()
	print("Ravitaillement turtle en cours...")
	turtle.select(SFuel)
	turtle.refuel(turtle.getItemCount(SFuel))
	TransferIntraInventory(EFuel, SFuel, turtle.getItemCount(EFuel))
	os.sleep(1)
end

--GESTION DE L'INVENTAIRE
function TransferIntoInventory(SlotTo)
	turtle.select(SlotTo)
	turtle.suck(64-turtle.getItemCount())
end

function TransferIntraInventory(SlotFrom,SlotTo, Quantity)
	turtle.select(SlotFrom)
	turtle.transferTo(SlotTo , Quantity)
end

function TransferExtraInventory(SlotFrom, Quantity)
	turtle.select(SlotFrom)
	turtle.drop(Quantity)
end

function InventoryCheck()
	--Déplacement des buches dans l'inventaire
	if turtle.getItemCount(WoodType) > 1 then
		for i=EWoodStock,SWoodStock, -1 do
			if turtle.getItemCount(i) <= (64 - (turtle.getItemCount(WoodType) - 1)) then
				TransferIntraInventory(WoodType, i, turtle.getItemCount(WoodType) - 1)
				break
			end
		end
	end
	
	--Vérification besoin de vider les buches
	if turtle.getItemCount(SWoodStock) > 32 then
		InventoryNeeds = InventoryNeeds + 100
	end
	
	--Vérification besoin de récupérer du carburant
	if turtle.getItemCount(SFuel) < 8 then
		InventoryNeeds = InventoryNeeds + 10
	end
	
	--Vérification besoin de récupérer des pousses
	if turtle.getItemCount(SSapplings) < 8 then
		InventoryNeeds = InventoryNeeds + 1
	end
end

--Programme

print("Version programme : "..ProgramVersion)

TurtleBooting()

while true do
	if (turtle.getFuelLevel() < 100) then
		Refuel()
	end
	InventoryCheck()
	if InventoryNeeds == 0 then
		Movement()
	else
		ExitWorkZone()
	end
end
