--Déclaration des variables
local Pousses	= 1
local Buches	= 2
local Limites	= 3
local PasDePousse

--Rechargement en carburant de la turtle
turtle.refuel()

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
	if turtle.compare() then
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
--Lancer la boucle de déplacement
print("Charger la turtle : 1 = max pousses, 2 = 1 buche, 3 = 1 bloc limite")
print("Démarrage de la turtle dans 30s")
os.sleep(30)
while true do
	Deplacement()
end
