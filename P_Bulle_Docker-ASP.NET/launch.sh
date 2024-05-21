#!/bin/bash
dotnet dev-certs https

echo ""
echo "Installtion de sudo"
apt-get update
apt-get install sudo
echo ""

echo ""
echo "Installer les dépendances nécessaires à xdg"
sudo apt-get update
sudo apt-get install xdg-utils
echo ""

xdg-open 'https://localhost:7218'

dotnet run