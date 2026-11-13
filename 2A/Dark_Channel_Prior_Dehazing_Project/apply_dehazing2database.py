from main import main
import numpy as np, cv2

def calculate_dehazed_img(kernel_size, w_size, beta, gamma, t0, w):
    #indoors images
    for i in range(50):
        for version in range(1,10):
            # C:\Users\lnafl\OneDrive\Projet Image\SOTS\SOTS\indoor\hazy\1400_1.png
            if i < 10:
                img_path = f"SOTS\SOTS\indoor\hazy\\140{i}_{version}.png"
                save_path = f"images\dehazed\indoor\\140{i}_{version}.png"
            else:
                img_path = f"SOTS\SOTS\indoor\hazy\\14{i}_{version}.png"
                save_path = f"images\dehazed\indoor\\14{i}_{version}.png"
            main(kernel_size, w_size, beta, gamma, t0, w, img_path, save_path)
    #outdoors images
    for i in range(1, 1988):
        # C:\Users\lnafl\OneDrive\Projet Image\SOTS\SOTS\outdoor\hazy\1400_1.png
        if i < 10:
            img_path = f"SOTS\SOTS\outdoor\hazy\\000{i}.jpg"
            save_path = f"images\dehazed\outdoor\\000{i}.jpg"
        elif 10 <= i < 100:
            img_path = f"SOTS\SOTS\outdoor\hazy\\00{i}.jpg"
            save_path = f"images\dehazed\outdoor\\00{i}.jpg"
        elif 100 <= i < 1000:
            img_path = f"SOTS\SOTS\outdoor\hazy\\0{i}.jpg"
            save_path = f"images\dehazed\outdoor\\0{i}.jpg"
        else:
            img_path = f"SOTS\SOTS\outdoor\hazy\\{i}.jpg"
            save_path = f"images\dehazed\outdoor\\{i}.jpg"
        if cv2.imread(img_path) is not None:
            main(kernel_size, w_size, beta, gamma, t0, w, img_path, save_path)

# paramètres de dehazing
kernel_size = 10
w_size = 3
beta, gamma, t0, w = 0.2, 0.8, 0.1, 0.85

# Lancer la création des images dehazed pour la base de données SOTS (pour évaluation PSNR/SSIM)
calculate_dehazed_img(kernel_size, w_size, beta, gamma, t0, w)