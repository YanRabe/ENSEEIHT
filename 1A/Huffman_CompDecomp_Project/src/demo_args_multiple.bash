echo "--- Suppression des fichiers précédents ---"
rm -f results/exemple_demo.txt.hff
rm -f results/exemple_demo.txt.hff.d

sleep 5

# Vérifier pour multiples arguments
echo "=== Tests pour de multiples arguments ==="

echo "--- Test pour la compression avec -s comme argument final ---"
./compression -b -s -b -s tests/arguments_demo.txt

sleep 5

echo "--- Test pour la compression avec -b comme argument final ---"
./compression -s -b -s -b tests/arguments_demo.txt
mv tests/arguments_demo.txt.hff results/

sleep 7

echo "--- Test pour la décompression avec -s comme argument final ---"
./decompression -b -s -b -s results/arguments_demo.txt.hff

sleep 5

echo "--- Test pour la décompression avec -b comme argument final ---"
./decompression -s -b -s -b results/arguments_demo.txt.hff