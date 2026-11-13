lien slides présentation: https://canva.link/vm9d57rgtkxl3rz
--Il faut installer opencv-contrib-python et non opencv-python pour utiliser guided filter dans le raffinage de la transmission--

######## Pour visualiser les résultats de la pipeline sur une image,
 lancer le fichier */main_commands_py*, puis entrer dans la ligne de commande les paramètres demandés. Ces résultats sont sauvegardés dans images/visual_res (chaque éxectution écrase les anciens résultats).

######## Pour calculer les dehazed images à partir de la database SOTS, 
lancer */apply_dehazing2database.py*, les images obtenues seront enregistrées dans images/dehazed, séparées en outdoor et indoor. ATTENTION, on a renommé les images SOTS/SOTS/outdoor/hazy en enlevant les suffixes à partir du premier underscore avant de lancer ce programme.

######## Une fois les images calculées avec notre pipeline, on peut lancer */evaluation_psnr* qui calcule les moyennes de métriques PSNR et d'indice SSIM sur l'ensemble de la base de données SOTS, en séparant les moyennes sur les images outdoor et les images indoor. 
(ATTENTION, ce programme est très lent, peut prendre 15-20min, et les warnings sont dûs à la numérotation spéciale des images outdoor dans la base de données, bien qu'il y ait environ 500 images, elles sont numéroté de 0001 jusqu'à ~1990, et on n'a pas trouvé de manière correcte de les renuméroter qui ne soit pas chronophage, ou qui conserve la correspondance entre les images ground truth et hazy.) 
