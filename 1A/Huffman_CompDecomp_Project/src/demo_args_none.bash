#!/bin/bash

# Compiler les fichiers ada
echo "=== Compilation des fichiers de l'application ==="
gnatclean *.adb
gnatmake compression compression.adb
gnatmake decompression decompression.adb

sleep 5

# Lancer pour test d'arguments d'affichage
echo "=== Tests pour les arguments d'affichage ==="
sleep 3

echo "--- Fichier d'origine ---"
cat tests/exemple_demo.txt
echo " "

sleep 3

echo "--- Test sans argument pour la compression ---"
sleep 2

./compression tests/exemple_demo.txt
mv tests/exemple_demo.txt.hff results/

sleep 5

echo "--- Test sans argument pour la décompression ---"
sleep 2

./decompression results/exemple_demo.txt.hff