echo "--- Suppression des fichiers précédents ---"
rm -f results/exemple_demo.txt.hff
rm -f results/exemple_demo.txt.hff.d

sleep 5

echo "--- Test pour l'argument -s pour la compression ---"
sleep 2

./compression -s tests/exemple_demo.txt
mv tests/exemple_demo.txt.hff results/

sleep 5

rm -f results/exemple_demo.txt.hff
echo "--- Test pour l'argument --silencieux pour la compression ---"
sleep 3

./compression --silencieux tests/exemple_demo.txt
mv tests/exemple_demo.txt.hff results/

sleep 5

echo "--- Test pour l'argument -s pour la décompression ---"
sleep 2

./decompression -s results/exemple_demo.txt.hff

sleep 5

rm -f results/exemple_demo.txt.hff.d
echo "--- Test pour l'argument --silencieux pour la décompression ---"
sleep 3

./decompression --silencieux results/exemple_demo.txt.hff