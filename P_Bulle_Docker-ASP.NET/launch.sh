#!/bin/bash
dotnet dev-certs https

# Informe et installe sudo
echo ""
echo "Installtion de sudo"
apt-get update -y
apt-get install sudo -y
echo ""

# Informe et installe xdg
echo ""
echo "Installer les dépendances nécessaires à xdg"
sudo apt-get update -y
sudo apt-get install xdg-utils -y
echo ""

# Lance une page web avec l'url suivante
xdg-open 'https://localhost:7218'

# lance l'application .NET
dotnet run
