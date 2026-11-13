echo "--- Suppression des fichiers précédents ---"
rm -f results/arguments_demo.txt.hff
rm -f results/arguments_demo.txt.hff.d

# Test pour fichier non existants
echo "=== Tests pour les fichiers non existants ==="

echo "--- Pour la compression ---"
./compression -b tests/fichier_non_existant.txt

sleep 5

echo "--- Pour la décompression ---"
./decompression -b results/fichier_non_existant.hff