--Déclaration des variables
local Pousses		=	1
local Buches		=	2
local Limites		=	3
local PasDePousse	=	0
local InventoryNOK	=	0

--Rechargement en carburant de la turtle
if (turtle.getFuelLevel() < 20) then
	turtle.refuel()
end

--Création des fonctions
function CheckArbrePousse(Emplacement)
	turtle.select(Emplacement)
	if turtle.compare() then
		PasDePousse = 0
	else
		PasDePousse = 1
	end
	return PasDePousse
end

function CheckLimitesZone(Emplacement)
	turtle.select(Emplacement)
	if turtle.compare() or turtle.compareDown() then
		turtle.turnLeft()
		turtle.forward()
		turtle.forward()
		turtle.turnLeft()
	end
end

function Deplacement()
--Vérification si la turtle ne sort pas de la zone de bucheronnage
	CheckLimitesZone(Limites)
--Vérification si un arbre a poussé
	CheckArbrePousse(Buches)
	if PasDePousse == 1 then
		turtle.digUp()
		turtle.up()
		turtle.dig()
		turtle.forward()
		turtle.dig()
		turtle.forward()
		turtle.down()
	else
		Coupe()
	end
end

function Coupe()
--Récupération du premier bloc et positionnement sous l'arbre
	turtle.dig()
	turtle.forward()
--Minage de l'arbre complet
	while turtle.detectUp() do
		turtle.digUp()
		turtle.up()
	end
--Redescente au sol
	while not turtle.detectDown() do
		turtle.down()
	end
	turtle.back()
--Appel de la fonction de replantage
	Replanter()
end

function Replanter()
--Replantage de la pousse
	turtle.select(Pousses)
	turtle.place()
--Evitement de la pousse plantée
	turtle.digUp()
	turtle.up()
	turtle.dig()
	turtle.forward()
	turtle.dig()
	turtle.forward()
	turtle.down()
end

function ViderInventaire()

end

--Programme
print("Charger la turtle : 1 = max pousses, 2 = 1 buche, 3 = 1 bloc limite")
print("Vérification du matériel nécessaire en cours")
os.sleep(5)

--Vérification inventaire
if (turtle.getItemCount(Pousses) < 5) or (turtle.getItemCount(Buches) == 0) or (turtle.getItemCount(Limites) == 0) then
	print("Chargez la turtle, puis relancer le système")
	InventoryNOK = 1
else
--Inventaire OK, préparation turtle
	print("Inventaire OK!")
	os.sleep(2)
	print("Démarrage de la turtle dans 10s")
end

os.sleep(10)

--Démarrage turtle
while (turtle.getFuelLevel() > 20) and (InventoryNOK == 0) do
	Deplacement()
end
