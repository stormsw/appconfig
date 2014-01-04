#!/bin/bash
if [ $1 = "" ]
then
  echo "/data/PROJECT/" should be specified. At ex. ugmn
  exit 1
fi

Appconfig="App.config"

#Normalize
echo -e "\e[1;35mNormalizing source file\e[0m"
bin/appconfig normalize ./data/$1/$Appconfig
echo -e "\e[1;33mBack up as [X]$Appconfig.normalized.original.xml\e[0m"
cp ./data/$1/$Appconfig.xml ./data/$1/$Appconfig.normalized.original.xml
#Optimize
echo -e "\e[1;35mOptimizing source file\e[0m"
bin/appconfig optimize ./data/$1/$Appconfig
echo -e "\e[1;33mBackup as [Y]$Appconfig.optimized.original.xml\e[0m"
cp ./data/$1/$Appconfig.xml ./data/$1/$Appconfig.optimized.original.xml
#Normalize Optimized
echo -e "\e[1;35mNormalizing optimized file\e[0m"
bin/appconfig normalize ./data/$1/$Appconfig.optimized.original.xml
echo -e "\e[1;33mBackup [NO]$Appconfig.normalized.optimized.xml\e[0m"
mv ./data/$1/$Appconfig.optimized.original.xml.xml ./data/$1/$Appconfig.normalized.optimized.xml
#Optimize Normalized
echo -e "\e[1;35mOptimizing normalized file\e[0m"
bin/appconfig optimize ./data/$1/$Appconfig.normalized.original.xml
echo -e "\e[1;33mBackup [ON] $Appconfig.optimized.normalized.xml\e[0m"
mv ./data/$1/$Appconfig.normalized.original.xml.xml ./data/$1/$Appconfig.optimized.normalized.xml
echo -e "\e[1;32m==========TEST==========="
echo -e "[Y].optimized.original.xml EQU [ON]optimized.normalized.xml"
echo -e "[X].normalized.original.xml EQU [NO]normalized.optimized.xml\e[0m"