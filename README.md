<p align="center">
<img width="804" height="789" alt="turtle bucheron" src="https://github.com/user-attachments/assets/15865d83-ad3f-4b03-ba68-0bbddb3e90d8" />
</p>

<img width="16" height="16" alt="image" src="https://github.com/user-attachments/assets/a03063ab-5834-437d-846d-acc130d903ab" /> [English version](English/README.md)

# ComputerCraft Turtle Bucheron
Programme ComputerCraft pour Turtle bucheron

Installation du programme : 
  - Dans Minecraft, commencez par placer une turtle dans votre monde, cela va créer un dossier sur votre PC.
  - Dans la turtle, tapez la commande *id*, vous obtiendrez l'ID de votre turtle (numéro unique).
  - Téléchargez le fichier *Bucheron.lua*, puis copiez le dans : **saves/*MONDE*/computercraft/computer/*id*/** (le dossier *saves* se trouve dans votre dossier d'instance Minecraft/FTB).
  - Dans votre fichier *startup.lua* de ce même dossier, vous pouvez taper (peut dépendre de votre version de CC:Tweaked) :
```
*local METIER = "Bucheron"
shell.run(METIER)*
```
  - Autre solution : copiez le code contenu dans *Bucheron.lua* dans votre *startup.lua*.
  - Retournez ensuite dans Minecraft, puis, dans votre Turtle, maintenez Ctrl + R jusqu'à ce qu'elle redémarre. Le programme bucheron se lance.

## Exemple de structure d'une ferme à bois : 
<p align="center">
<img width="758" height="465" alt="Capture d'écran 2025-08-04 133309" src="https://github.com/user-attachments/assets/82b1ffb9-e710-42f6-a247-0b3832217c69" />
<img width="3840" height="2019" alt="2025-08-07_19 03 32" src="https://github.com/user-attachments/assets/b49c0819-012c-4e04-9d40-213d8377357a" />
</p>

---

# Programme : Turtle Bucheron
## Version : 4.0-alpha05

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

</details>

*4.0-alpha05 : Corrections programme pendant tests.  
Ajout de la fonction de détection du sens de rotation intelligente.  
Consolidation des fonctions de communication PixelLink.*

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
> Le programme du serveur bucheron 4.0-beta01 est [disponible sur GitHub](https://github.com/ValDin08/ComputerCraft_Reseau/tree/main/Serveur%20Bucheron).

> [!WARNING]
> Pour le bon fonctionnement de votre Turtle, il faut adapter les coordonnées ci-dessous à votre installation :
> <img width="1407" height="380" alt="image" src="https://github.com/user-attachments/assets/be7f7b5d-6331-40ab-8610-66999624b9bd" />


> [!WARNING]
> Pour le bon fonctionnement de votre Turtle, il faut adapter l'ID du serveur et le côté où se situe votre Modem :
> <img width="1001" height="182" alt="image" src="https://github.com/user-attachments/assets/c485b2db-7ea6-4c09-a44b-e4e84dbb856f" />
