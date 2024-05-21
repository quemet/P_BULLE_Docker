#!/bin/bash
containers=('application' 'mysql' 'test')
images=('p_bulle_docker-aspnet-db' 'p_bulle_docker-aspnet-test' 'p_bulle_docker-aspnet-webapp')

echo ""
echo "Supprimer les conteneurs..."
echo ""

count=1
total_step=6

for container in "${containers[@]}"
do
    echo ""
    echo "[Step $count/$total_step] En train de supprimer le conteneur $container..."
    sudo docker stop $container
    sudo docker rm $container
    echo "Conteneur $container a été supprimé"
    echo ""
    ((count++))
done

for image in "${images[@]}"
do
    echo ""
    echo "[Step $count/$total_step] En train de supprimer l'image $image..."
    sudo docker rmi $image
    echo "Image $image a été supprimée"
    echo ""
    ((count++))
done

echo ""
echo "Tous les conteneurs et images ont été supprimés."
echo ""

echo ""
echo "Démarrage des services avec docker-compose..."
echo ""

echo ""
echo "Installer les dépendances nécessaires à xpg"
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install xpg-utils
echo ""

sudo docker-compose up -d

xdg-open 'http://localhost:8080'