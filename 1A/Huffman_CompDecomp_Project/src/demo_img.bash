echo "--- Suppression des fichiers précédents ---"
rm -f results/texte_e_act.txt.hff
rm -f results/texte_e_act.txt.hff.d

echo "=== Test pour une image ==="

echo "--- Compression de l'image ---"
./compression -b tests/texte_sujet_comp.png
mv tests/texte_sujet_comp.png.hff results/

sleep 5

echo "--- Décompression de l'image ---"
./decompression -b results/texte_sujet_comp.png.hff

sleep 2

echo "--- Comparaison des fichiers ---"
diff tests/texte_sujet_comp.png results/texte_sujet_comp.png.hff.d