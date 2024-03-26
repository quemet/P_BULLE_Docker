[String]$nameProject = $args[0];
[String]$version = $args[1];

[String[]]$commandes =
    "sudo -i",
    "apt-get upgrade",
    "apt-get install sudo",
    "sudo apt update",
    "sudo apt install -y wget apt-transport-https software-properties-commo",
    "wget https://packages.microsoft.com/config/debian/11/packages-microsoft-prod.deb -O packages-microsoft-prod.deb",
    "sudo dpkg -i packages-microsoft-prod.deb",
    "sudo apt update",
    "sudo apt install -y aspnetcore-runtime-$version",
    "sudo apt update",
    "sudo apt install -y dotnet-sdk-$version",
    "cd ..",
    "cd bin",
    "cd Debug",
    "cd net$version",
    "dotnet $nameProject.dll"

foreach($commande in $commandes) {
    &"$commande";
}