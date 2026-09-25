<p align="center">
<img width="804" height="789" alt="turtle bucheron" src="https://github.com/user-attachments/assets/15865d83-ad3f-4b03-ba68-0bbddb3e90d8" />
</p>

<img width="16" height="16" alt="image" src="https://github.com/user-attachments/assets/a03063ab-5834-437d-846d-acc130d903ab" /> [English version](English/README.md)

# ComputerCraft Turtle Bucheron
Programme ComputerCraft pour Turtle bucheron

Installation du programme : 
  - Dans Minecraft, commencez par placer une turtle dans votre monde, cela va créer un dossier sur votre PC.
  - Dans la turtle, tapez la commande *id*, vous obtiendrez l'ID de votre turtle (numéro unique).
  - Téléchargez les fichiers *Bucheron.lua* et *startup.lua*, puis copiez les dans : **saves/*MONDE*/computercraft/computer/*id*/** (le dossier *saves* se trouve dans votre dossier d'instance Minecraft/FTB).
  - Le programme *Bucheron.lua* est désormais strictement identique sur toutes vos turtles bucheron : toute la configuration propre à une instance (nom du serveur à rejoindre) se fait exclusivement dans *startup.lua*.
  - Ouvrez *startup.lua* et adaptez si besoin `SERVER_HOSTNAME` au nom de service annoncé par votre serveur sur le réseau PixelLink (`bucheron_server` par défaut) :
```
local METIER = "Bucheron"
local SERVER_HOSTNAME = "bucheron_server"
shell.run(METIER, SERVER_HOSTNAME)
```
  - Retournez ensuite dans Minecraft, puis, dans votre Turtle, maintenez Ctrl + R jusqu'à ce qu'elle redémarre. Le programme bucheron se lance.

## Exemple de structure d'une ferme à bois : 
<p align="center">
<img width="758" height="465" alt="Capture d'écran 2025-08-04 133309" src="https://github.com/user-attachments/assets/82b1ffb9-e710-42f6-a247-0b3832217c69" />
<img width="3840" height="2019" alt="2025-08-07_19 03 32" src="https://github.com/user-attachments/assets/b49c0819-012c-4e04-9d40-213d8377357a" />
</p>

---

# Programme : Turtle Bucheron
## Version : 5.0-alpha02
### Génération : Lumen 🔆

### Patchnote : 

<details>
  
<summary>Voir l'historique des versions précédentes</summary>

*1.0 : Version de base de la turtle bucheron  
Rechargement et Déchargement manuel de la turtle  
Refueling uniquement au reboot de la turtle  
Ne peut gérer que 2 lignes d'arbre de longueur illimitée.  
La zone doit être délimitée par le type de bloc qui sera placé en slot 3.*

*1.1 : Surveillance des quantités de materiaux dans l'inventaire.  
Surveillance des limites de zone en dessous de la turtle en plus de sa face.*

*2.0 : Refonte du programme  
Ajout de la fonction de vidage/remplissage automatique de l'inventaire de la turtle.  
Ajout de la fonction d'utilisation de rangées multiples.  
Ajout du GPS.  
Suppression des blocs limites, guidage GPS complet.  
Elargissement de l'inventaire.  
Ajout du mode de marche manu/auto - `Manuel pas encore opérationnel.`*

*2.1 : Gestion de l'inventaire fluidifiée.*

*2.2 : Casse non prise en compte dans les entrées de strings.  
Affichage de la version du programme au démarrage de la turtle.*

*2.3 : Correction du bug de redescente après la coupe d'un arbre.*

*3.0 : Intégration de la communication réseau avec le serveur.*

*3.1 : Envoi de la position, de l'orientation de la turtle et du nombre d'arbres coupés sur la run en cours au serveur à chaque cycle de communication sur le protocol CraftNET.*

*3.2 : Amélioration de l'efficience énergétique.*

*3.3 : Ajout de la fonction d'arrêt de la turtle depuis le serveur.  
Modification de la trame d'informations envoyée au serveur.*

*4.0-alpha02 : Intégration de PixelLink.  
Modification du programme en conséquence.*

*4.0-alpha03 : Corrections programme pendant tests.*

*4.0-alpha04 : Corrections programme pendant tests.*

*4.0-alpha05 : Corrections programme pendant tests.  
Ajout de la fonction de détection du sens de rotation intelligente.  
Consolidation des fonctions de communication PixelLink.*

*5.0-alpha01 : Implémentation de touches tactiles sur l'écran du serveur.  
Suppression de l'autorisation de marche via un levier redstone.  
Consolidation des fonctions de communication PixelLink.  
Correction de la remontée d'erreurs de ravitaillement (un échec de carburant n'était jamais détecté).  
Arrêt réel (redémarrage) de la turtle en cas d'échec de ravitaillement au démarrage, au lieu de continuer silencieusement.  
Correction d'un bug de précédence empêchant la turtle de tourner correctement vers les coffres selon les besoins restants.  
Correction du déclencheur de dépose des buches, basé désormais sur le stock total plutôt qu'un seul slot qui se remplissait toujours en dernier.  
Suppression de l'hypothèse d'un sol toujours en terre à la redescente après abattage (comptage des blocs montés/descendus à la place).  
Gestion d'un obstacle bloquant le calibrage de position au démarrage (dégagement automatique).  
Vérification effective du succès de chaque ravitaillement (buches/carburant/pousses), avec remontée d'erreur en cas d'échec.  
Recalcul complet des besoins d'inventaire à chaque passage, pour éviter toute dérive.  
Correction de la persistance de l'état "Turtle connectée" qui ne redevenait jamais NON après une perte de connexion réelle.*

</details>

*5.0-alpha02 : Découverte du serveur par nom de service (PixelLink.resolve) au lieu d'un ID codé en dur, avec nouvelle tentative périodique tant que le serveur n'est pas trouvé.  
Le nom du serveur à rejoindre se configure désormais uniquement dans *startup.lua* (argument passé au programme) : *Bucheron.lua* reste strictement identique sur toutes les turtles.  
Correction d'un bug de dérive de hauteur ("escalier") lors de l'abattage d'arbres consécutifs, désormais ancrée sur la position GPS réelle plutôt que sur un comptage de déplacements.  
Relèvement du seuil de déclenchement du tri/dépose du bois pour réduire la fréquence des `turtle.transferTo()`, coûteux en temps d'exécution, et fluidifier le fonctionnement de la turtle.*

### Roadmap :

- [x] OK v4.0-alpha03 : Faire retourner la Turtle en position d'attente en cas de perte de connexion avec le serveur : validé avec plusieurs déconnexions à divers endroits.
- [x] OK v4.0-alpha03 : Idem lorsque le serveur n'autorise plus le travail à la Turtle.
- [x] OK v4.0-alpha03 : Faire sortir la Turtle lorsqu'elle a besoin d'accéder à un coffre, elle doit se ravitailler/déposer dans le bon coffre. 
- [x] OK v4.0-alpha04 : Faire sortir la Turtle lorsqu'elle a besoin d'accéder à plusieurs coffres, elle doit se ravitailler/déposer dans tous les coffres. 
- [ ] Bug détecté en v4.0-alpha03 : la Turtle quitte sa zone de travail, mais s'arrête immédiatement après avoir perdu la connexion au serveur. Sa position est affichée sur l'IHM. --> Une seule occurence, à surveiller...
- [ ] Essais à faire sur une autre ferme (nouvelle configuration, orientation...)
- [x] OK v4.0-alpha05 : Voir pour que la Turtle sache d'elle même dans quel sens tourner au premier virage pour le démarrage du snake. Les virages suivants seront ensuite fait en alternance gauche/droite en fonction du premier virage.
- [ ] Ajouter une mise en position de départ (écrite en dur) si démarrage en dehors de son point de départ.

---

### 🚀 Générations

Chaque génération regroupe une évolution majeure commune à toutes les turtles du projet (bûcheron, fermier, mineur...), indépendamment du numéro de version propre à chacune :

| Génération | Nom | Caractéristique |
|---|---|---|
| 1 | **Flint** | Version manuelle de base : rechargement/déchargement à la main, sans réseau ni GPS. |
| 2 | **Vector** | Autonomie complète : guidage GPS, gestion automatique de l'inventaire, rangées multiples. |
| 3 | **Echo** | Arrivée du réseau : communication avec un serveur (protocole CraftNET), arrêt à distance. |
| 4 | **Nexus** | Protocole PixelLink : communications consolidées, détection de rotation intelligente. |
| 5 | **Lumen** | Pilotage tactile complet depuis l'écran du serveur, fin du levier physique. |

---
> [!NOTE]
> Sortie automatique de la zone de bucheronage pour vidage et remplissage inventaire.

> [!IMPORTANT]
> Dépendante du système GPS. Un satellite doit être mis en place afin de localiser la Turtle.

> [!TIP]
> Le schéma de construction du satellite et ses programmes GPS sont [disponibles sur GitHub](https://github.com/ValDin08/ComputerCraft_Satellite_GPS).

> [!IMPORTANT]
> Dépendante du système Serveur et au réseau PixelLink.
> Un Serveur doit être programmé pour communiquer avec la Turtle.
> Le module PixelLink, [disponible sur GitHub](https://github.com/ValDin08/ComputerCraft_Reseau/tree/main/PixelLink), doit être installé sur la Turtle.

> [!TIP]
> Le programme du serveur bucheron 5.0-alpha02 est [disponible sur GitHub](https://github.com/ValDin08/ComputerCraft_Reseau/tree/main/Serveur_Bucheron).

> [!WARNING]
> Pour le bon fonctionnement de votre Turtle, il faut adapter les coordonnées ci-dessous à votre installation :
> <img width="1407" height="380" alt="image" src="https://github.com/user-attachments/assets/be7f7b5d-6331-40ab-8610-66999624b9bd" />

> [!WARNING]
> Depuis la v5.0-alpha02, la Turtle retrouve automatiquement le serveur par son nom de service (plus besoin d'ID codé en dur) : seul le nom (dans *startup.lua*) et le côté du Modem (variable `ModemSide` dans *Bucheron.lua*) doivent correspondre à votre installation.
