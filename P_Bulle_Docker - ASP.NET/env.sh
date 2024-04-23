containers=('application' 'mysql' 'test')
images=('p_bulle_docker-aspnet-db' 'p_bulle_docker-aspnet-test' 'p_bulle_docker-aspnet-webapp')

echo ""
echo "Supprimer les conteneurs..."
echo ""

count=1


for container in "${containers[@]}"; do
    echo ""
    echo "[Step $count/6] En train de supprimer le conteneur $container..."
    docker rm $container
    echo "Conteneur $container a été supprimé"
    echo ""
    if [[ $count -eq 1 ]]
    then
        echo "Progression : [###               ] 16 %"
    elif [[ $count -eq 2 ]]
    then
        echo "Progression : [######            ] 32 %"
    else
        echo "Progression : [#########         ] 48 %"
    fi
    ((count++))
done

for image in "${images[@]}"; do
    echo ""
    echo "[Step $count/6] En train de supprimer l'image $image..."
    docker rmi $image
    echo "Image $image a été supprimée"
    echo ""
    if [[ $count -eq 4 ]]
    then
        echo "Progression : [############      ] 64 %"
    elif [[ $count -eq 5 ]]
    then
        echo "Progression : [###############   ] 80 %"
    else
        echo "Progression : [##################] 100 %"
    fi
    ((count++))
done

echo ""
echo "Tous les conteneurs et images ont été supprimés."

echo ""
echo "Démarrage des services avec docker-compose..."
docker-compose up
