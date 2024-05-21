# P_Bulle_Dev_Docker

## Sommaire des fichiers importants

[Dockerfile pour l'application](./P_Bulle_Docker-ASP.NET/Dockerfile)
[Dockerfile pour les tests](./Dockerfile.test)
[Script pour la création des containeurs](./P_Bulle_Docker-ASP.NET/setup.bat)
[Script pour lancer l'application (Façon n°1)](./P_Bulle_Docker-ASP.NET/build.sh)
[Script pour lancer l'application (Façon n°2)](./P_Bulle_Docker-ASP.NET/launch.sh)
[Dump pour la créationde la base de données](./Database/P_Bulle-Docker.sql)
[Fichier source pour les tests unitaires](./testUnitTest1.cs)

## Config de docker et des containeurs

Il y a deux façons de faire des containeurs :

### Façon n°1

#### Création du DevContainer

En suivant les étapes suivantes :
![Etape n°1](https://github.com/quemet/P_BULLE_Docker/blob/main/Image/Documentation/Screen_01.png)
On clique sur le bouton de départ "Create new environment"
![Etape n°2](https://github.com/quemet/P_BULLE_Docker/blob/main/Image/Documentation/Screen_02.png)  
On clique à nouveau sur le bouton "Get Started"
![Etape n°3](https://github.com/quemet/P_BULLE_Docker/blob/main/Image/Documentation/Screen_03.png)
Sur cette fenêtre on choisi si on veut un local ou avec git. j'ai choisi de le faire en local
![Etape n°4](https://github.com/quemet/P_BULLE_Docker/blob/main/Image/Documentation/Screen_04.png)
![Etape n°5](https://github.com/quemet/P_BULLE_Docker/blob/main/Image/Documentation/Screen_05.png)
![Etape n°6](https://github.com/quemet/P_BULLE_Docker/blob/main/Image/Documentation/Screen_06.png)  
On attend que docker fasse sont travail.  
![Etape n°7](https://github.com/quemet/P_BULLE_Docker/blob/main/Image/Documentation/Screen_07.png)  
C'est fini le containeur est crée. On peut l'ouvrir avec VS Code.

#### Lancement du programme

Je lance mon programme avec un script en [bash](./build.sh)

```sh
#!/bin/bash

# Crée un tableau avec le nom des images
containers=('application' 'mysql' 'test')

# Crée un tableau avec le nom des containers
images=('p_bulle_docker-aspnet-db' 'p_bulle_docker-aspnet-test' 'p_bulle_docker-aspnet-webapp')

# Affiche un message pour dire à l'utilisateur ce que va faire le script
echo ""
echo "Supprimer les conteneurs..."
echo ""

# Crée une variable qui est l'incrément des étapes
count=1

# Crée une variable avec tout les étapes
total_step=6

# Fais une boucle sur le tableau des containers
for container in "${containers[@]}"
do

    # Affiche l'étape avec le nom du container, le stoppe et le supprimme
    echo ""
    echo "[Step $count/$total_step] En train de supprimer le conteneur $container..."
    sudo docker stop $container
    sudo docker rm $container
    echo "Conteneur $container a été supprimé"
    echo ""

    # Incrémente la valeur de count
    ((count++))
done

# Fais une boucle sur le tableau des images
for image in "${images[@]}"
do

    # Affiche l'étape avec le nom de l'image et la supprimme
    echo ""
    echo "[Step $count/$total_step] En train de supprimer l'image $image..."
    sudo docker rmi $image
    echo "Image $image a été supprimée"
    echo ""

    # Incrémente la valeur de count
    ((count++))
done

# Informe l'utilisateur que les containeurs et images ont été supprimmé
echo ""
echo "Tous les conteneurs et images ont été supprimés."
echo ""


# Informe l'utilisateur que les containerus vont être lancé
echo ""
echo "Démarrage des services avec docker-compose..."
echo ""

# Informe et installe les dépendances de xdg
echo ""
echo "Installer les dépendances nécessaires à xdg"
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install xdg-utils
echo ""

# Lance le docker-compose pour la création des containeurs
sudo docker-compose up -d

# Ouvre une page web sur l'url suivante
xdg-open 'http://localhost:8080'
```

### Façon n°2

#### Création des containers

Dans la façon numéro 2. Nous démarron nos containeurs avec un [script bat](./setup.bat)

```bat

```

#### Lancement de l'application
