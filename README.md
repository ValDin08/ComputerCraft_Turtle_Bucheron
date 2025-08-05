<p align="center">
<img width="804" height="789" alt="turtle bucheron" src="https://github.com/user-attachments/assets/15865d83-ad3f-4b03-ba68-0bbddb3e90d8" />
</p>

# ComputerCraft Turtle Bucheron
Programme ComputerCraft pour Turtle bucheron

Installation du programme : 
  - Dans Minecraft, commencez par placer une turtle dans votre monde, cela va créer un dossier sur votre PC.
  - Dans la turtle, tapez la commande *id*, vous obtiendrez l'ID de votre turtle (numéro unique).
  - Téléchargez le fichier *bucheron.lua*, puis copiez le dans : **saves/*MONDE*/computercraft/computer/*id*/** (le dossier *saves* se trouve dans votre dossier d'instance Minecraft/FTB).
  - Dans votre fichier *startup.lua* de ce même dossier, vous pouvez taper *shell.run("bucheron")* (peut dépendre de votre version de CC:Tweaked, un simple *bucheron()* peut faire l'affaire).
  - Autre solution : copiez le code contenu dans *bucheron.lua* dans votre *startup.lua*.
  - Retournez ensuite dans Minecraft, puis, dans votre Turtle, maintenez Ctrl + R jusqu'à ce qu'elle redémarre. Le programme bucheron se lance.

## Exemple de structure d'une ferme à bois : 
<img width="909" height="536" alt="image" src="https://github.com/user-attachments/assets/f4812cc0-8590-4142-bb63-0441faa0f370" />

---

# Programme : Turtle Bucheron
## Version : 3.3

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

*2.2 : Casse non prise en compte dans les entrées de strings.  
Affichage de la version du programme au démarrage de la turtle.*

*2.3 : Correction du bug de redescente après la coupe d'un arbre.*

*3.0 : Intégration de la communication réseau avec le serveur.*

*3.1 : Envoi de la position, de l'orientation de la turtle et du nombre d'arbres coupés sur la run en cours au serveur à chaque cycle de communication sur le protocol CraftNET.*

*3.2 : Amélioration de l'efficience énergétique.*

**3.3 : Ajout de la fonction d'arrêt de la turtle depuis le serveur.  
Modification de la trame d'informations envoyée au serveur.**

---
> [!NOTE]
> Sortie de la zone de bucheronage pour vidage et remplissage inventaire.

> [!IMPORTANT]
> Dépendante du système GPS. Un GPS doit être ajouté à la Turtle et un satellite doit être mis en place afin de localiser la Turtle.

> [!TIP]
> Le schéma de construction du satellite et ses programmes GPS sont disponibles sur GitHub.

> [!IMPORTANT]
> Dépendante du système Serveur et au réseau CraftNET. Un Serveur doit être programmé pour communiquer avec la Turtle.

> [!TIP]
> Le programme du serveur bucheron 1.0 est disponible sur GitHub.

> [!WARNING]
> Pour le bon fonctionnement de votre Turtle, il faut adapter les coordonnées ci-dessous à votre installation :
> <img width="1277" height="347" alt="image" src="https://github.com/user-attachments/assets/bfb4dfd4-5171-4da2-b876-b24ad4e813f6" />


> [!WARNING]
> Pour le bon fonctionnement de votre Turtle, il faut adapter l'ID du serveur et le côté où se situe votre Modem :
> <img width="582" height="156" alt="image" src="https://github.com/user-attachments/assets/5cf5128d-7e1a-4f72-abd1-430c1a21915d" />


