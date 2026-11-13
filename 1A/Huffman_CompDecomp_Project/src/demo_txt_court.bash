# Test pour exemple du sujet
echo "=== Test pour l'exemple du sujet ==="
sleep 5

echo "--- Compression du texte court ---"
sleep 2

./compression -b tests/texte_sujet.txt
mv tests/texte_sujet.txt.hff results/

sleep 15

echo "--- Affichage du fichier compressé avec xxd ---"
sleep 2
xxd -b results/texte_sujet.txt.hff

sleep 15

echo "--- Taille du fichier d'origine ---"
stat -c %s tests/texte_sujet.txt

sleep 2

echo "--- Taille du fichier compressé ---"
stat -c %s results/texte_sujet.txt.hff

sleep 10

echo "--- Décompression du résultat ---"
./decompression -b results/texte_sujet.txt.hff

sleep 5
echo "--- Comparaison des fichiers d'origine et décompressé ---"
diff -s tests/texte_sujet.txt results/texte_sujet.txt.hff.d
echo " "

sleep 5

echo "--- Affichage du fichier décompressé avec xxd ---"
xxd -b results/texte_sujet.txt.hff.d
