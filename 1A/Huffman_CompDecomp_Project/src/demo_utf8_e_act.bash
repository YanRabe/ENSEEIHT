echo "--- Suppression des fichiers précédents ---"
rm -f results/texte_sujet.utf8.converted.hff
rm -f results/texte_sujet.utf8.converted.hff.d

echo "=== Test avec caractère codé sur 2 octets ==="

echo "--- Vérification du codage ---"
file -i tests/texte_e_act.txt

sleep 3

echo "--- Compression du fichier ---"
sleep 2

./compression -b tests/texte_e_act.txt
mv tests/texte_e_act.txt.hff results/

sleep 5

echo "--- Décompression du résultat ---"
sleep 2
./decompression -b results/texte_e_act.txt.hff

echo "---Comparaison des fichiers ---"
sleep 2
diff -s tests/texte_e_act.txt results/texte_e_act.txt.hff.d