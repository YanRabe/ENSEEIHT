# Test pour texte long
echo "=== Test pour un texte long ==="
sleep 3

echo "--- Compression du texte long ---"
sleep 2

./compression -b tests/texte_long.txt
mv tests/texte_long.txt.hff results/

sleep 5

echo "--- Taille du fichier d'origine ---"
stat -c %s tests/texte_long.txt

sleep 2

echo "--- Taille du fichier compressé ---"
stat -c %s results/texte_long.txt.hff

sleep 5

echo "--- Décompression du résultat ---"

sleep 2

./decompression -b results/texte_long.txt.hff

sleep 5

echo "--- Comparaison des fichiers d'origine et décompressé ---"
diff -s tests/texte_long.txt results/texte_long.txt.hff.d
echo " "
