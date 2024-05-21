#!/bin/bash
# Défini un tableau avec les contianers
containers=('myprojectdocker-test-1' 'myprojectdocker-dev-1' 'myprojectdocker-db-1')

# Défini un tableau avec les images
images=('mysql' 'myprojectdocker_dev' 'myprojectdocker_test', 'geircode/string_to_hex')

# Informet l'utilisateur du début du script
echo ""
echo "Supprimer les conteneurs..."
echo ""

# Défini les variables pour un meilleur interaction utilisateurs
count=1
total_step=6

# Boucle sur le tableau des containers
for container in "${containers[@]}"
do
    # Informe, stoppe et supprimme les containers dans le tableau
    echo ""
    echo "[Step $count/$total_step] En train de supprimer le conteneur $container..."
    sudo docker stop $container
    sudo docker rm $container
    echo "Conteneur $container a été supprimé"
    echo ""
    # Incrémente la variable count pour avoir un suivi
    ((count++))
done

# Boucle sur le tableau des images
for image in "${images[@]}"
do
    # Informe et supprimme les images dans le tableau
    echo ""
    echo "[Step $count/$total_step] En train de supprimer l'image $image..."
    sudo docker rmi $image
    echo "Image $image a été supprimée"
    echo ""
    # Incrémente la variable count pour avoir un suivi
    ((count++))
done

# Informe l'utilisateur que toute à réussi
echo ""
echo "Tous les conteneurs et images ont été supprimés."
echo ""

# Informe l'utilisateur du démarrage des services
echo ""
echo "Démarrage des services avec docker-compose..."
echo ""

# Informe et installe la librairie xdg
echo ""
echo "Installer les dépendances nécessaires à xdg"
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install xdg-utils
echo ""

# Lance la création des services
sudo docker-compose up -d

# Ouvre une page web à l'url suivante.
xdg-open 'http://localhost:8080'
