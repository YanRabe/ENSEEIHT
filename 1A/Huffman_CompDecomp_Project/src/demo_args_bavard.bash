echo "--- Suppression des fichiers précédents ---"
rm -f results/exemple_demo.txt.hff
rm -f results/exemple_demo.txt.hff.d

sleep 5

echo "--- Test pour l'argument -b pour la compression ---"
sleep 2

./compression -b tests/exemple_demo.txt
mv tests/exemple_demo.txt.hff results/

sleep 5

echo "--- Test pour l'argument --bavard pour la compression ---"
sleep 2

./compression --bavard tests/exemple_demo.txt
mv tests/exemple_demo.txt.hff results/

sleep 5

echo "--- Test pour l'argument -b pour la décompression ---"
sleep 2
./decompression -b results/exemple_demo.txt.hff

sleep 5

echo "--- Test pour l'argument --bavard pour la décompression ---"
sleep 2
./decompression --bavard results/exemple_demo.txt.hff
