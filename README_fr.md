# ComputerCraft_Turtle_Bucheron
Programme ComputerCraft pour Turtle bucheron

Installation du programme : 
  - Dans Minecraft, commencez par placer une turtle dans votre monde, cela va créer un dossier sur votre PC.
  - Dans la turtle, tapez la commande *id*, vous obtiendrez l'ID de votre turtle (numéro unique).
  - Téléchargez le fichier *bucheron.lua*, puis copiez le dans : **saves/*MONDE*/computercraft/computer/*id*/** (le dossier *saves* se trouve dans votre dossier d'instance Minecraft/FTB).
  - Dans votre fichier *startup.lua* de ce même dossier, vous pouvez taper *shell.run("bucheron")* (peut dépendre de votre version de CC:Tweaked, un simple *bucheron()* peut faire l'affaire).
  - Autre solution : copiez le code contenu dans *bucheron.lua* dans votre *startup.lua*.
  - Retournez ensuite dans Minecraft, puis, dans votre Turtle, maintenez Ctrl + R jusqu'à ce qu'elle redémarre. Le programme bucheron se lance.

---

# Programme : Turtle Bucheron
## Version : 2.2

### Patchnote : 

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

**2.2 : Casse non prise en compte dans les entrées de strings.  
Affichage de la version du programme au démarrage de la turtle.**

---
> [!NOTE]
> Sortie de la zone de bucheronage pour vidage et remplissage inventaire.

> [!IMPORTANT]
> Dépendante du système GPS. Un GPS doit être ajouté à la Turtle et un satellite doit être mis en place afin de localiser la Turtle.

> [!TIP]
> Le schéma de construction du satellite et ses programmes GPS sont disponibles sur GitHub.

> [!WARNING]
> Pour le bon fonctionnement de votre Turtle, il faut adapter les coordonnées ci-dessous à votre installation :
> <img width="1277" height="347" alt="image" src="https://github.com/user-attachments/assets/bfb4dfd4-5171-4da2-b876-b24ad4e813f6" />
