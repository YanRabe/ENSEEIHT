echo "--- Suppression des fichiers précédents ---"
rm -f results/texte_long.txt.hff
rm -f results/texte_long.txt.hff.d

echo "=== Test pour un fichier en charset UTF-8 ==="

echo "--- Vérification du codage ---"
file -i tests/sujet_utf8.txt.converted

sleep 3

echo "--- Compression du fichier ---"
sleep 2
./compression -b tests/sujet_utf8.txt.converted
mv tests/sujet_utf8.txt.converted.hff results/

sleep 5

echo "--- Décompression du résultat ---"
sleep 2
./decompression -b results/sujet_utf8.txt.converted.hff

echo "---Comparaison des fichiers ---"
sleep 2
diff -s tests/texte_sujet.utf8.converted results/texte_sujet.utf8.converted.hff.d
