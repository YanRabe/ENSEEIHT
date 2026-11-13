#!/bin/bash

KMEANS_EXEC="./build/bin/kmeans"
MEANSHIFT_EXEC="./build/bin/meanshiftComp"
IMG_DIR="./data/images"
K=2

echo "--- Test des différentes implémentations de segmentation ---"

shopt -s nullglob

rm -f "$IMG_DIR"/*_output.png

for img in "$IMG_DIR"/texture*.png; do
    if [[ "$img" == *"_VT.png" ]]; then
        continue
    fi

    basename=$(basename "$img" .png)
    gt="$IMG_DIR/${basename}_VT.png"
    gt_arg=""
    if [[ -f "$gt" ]]; then
        gt_arg="-gt=$gt"
    fi

    echo ""
    echo "==> Image: $basename"

    for version in 0 1; do
        echo ""
        echo "==> kmeans version: $version"
        output="$IMG_DIR/${basename}_kmeans_ver${version}_output.png"
        $KMEANS_EXEC -i="$img" -k=$K $gt_arg -v=$version -o="$output"
        if [[ $? -ne 0 ]]; then
            echo "==> Échec kmeans version $version pour $basename"
        else
            echo "==> Résultat sauvegardé en tant que $output"
        fi
    done

    echo ""
    echo "==> meanshift"
    output="$IMG_DIR/${basename}_meanshift_output.png"
    $MEANSHIFT_EXEC -i="$img" -k=$K $gt_arg -o="$output"
    if [[ $? -ne 0 ]]; then
        echo "==> Échec meanshift pour $basename"
    else
        echo "==> Résultat sauvegardé en tant que $output"
    fi

done