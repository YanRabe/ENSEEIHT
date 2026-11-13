import dark_channel_computation as dcc
import numpy as np, cv2
#calc PSNR
from math import log10

# Fonctions d'évaluation métriques PSNR et SSIM
def PSNR(X, Y, Max = 255):
    n, m, c = X.shape[:3]
    X = X.astype(np.float32)
    Y = Y.astype(np.float32)
    MSE = 0
    for i in range(n):
        for j in range(m):
            for k in range(c):
                MSE += pow(X[i, j, k] - Y[i, j, k], 2) / (n * m * c)
    if MSE == 0:
        MSE = 1e-10  # Avoid division by zero
    PSNR = 10 * log10(Max ** 2 / MSE)
    return PSNR

def fast_ssim(img1, img2):
    img1 = img1.astype(np.float32)
    img2 = img2.astype(np.float32)

    C1 = (0.01 * 255) ** 2
    C2 = (0.03 * 255) ** 2

    # Gaussian blur for local means
    mu1 = cv2.GaussianBlur(img1, (11, 11), 1.5)
    mu2 = cv2.GaussianBlur(img2, (11, 11), 1.5)

    mu1_sq = mu1 * mu1
    mu2_sq = mu2 * mu2
    mu1_mu2 = mu1 * mu2

    # Gaussian blur for variances
    sigma1_sq = cv2.GaussianBlur(img1 * img1, (11, 11), 1.5) - mu1_sq
    sigma2_sq = cv2.GaussianBlur(img2 * img2, (11, 11), 1.5) - mu2_sq
    sigma12 = cv2.GaussianBlur(img1 * img2, (11, 11), 1.5) - mu1_mu2

    # SSIM formula
    ssim_map = ((2 * mu1_mu2 + C1) * (2 * sigma12 + C2)) / \
               ((mu1_sq + mu2_sq + C1) * (sigma1_sq + sigma2_sq + C2))

    return ssim_map.mean()

# Evaluer les métriques en moyenne sur les images indoor et outdoor du dataset SOTS
def mean_ssim_indoor():
    ssim_values = []
    for i in range(50):
        for version in range(1,10):
            if i < 10:
                gt_path = f"SOTS\SOTS\indoor\gt\\140{i}.png"
                dehazed_path = f"images\dehazed\indoor\\140{i}_{version}.png"
            else:
                gt_path = f"SOTS\SOTS\indoor\gt\\14{i}.png"
                dehazed_path = f"images\dehazed\indoor\\14{i}_{version}.png"
            
            ssim_value = fast_ssim(dcc.resize(cv2.imread(gt_path)), cv2.imread(dehazed_path))
            ssim_values.append(ssim_value)
    mean_ssim = np.mean(ssim_values)
    return mean_ssim

def mean_ssim_outdoor():
    ssim_values = []
    for i in range(1, 1988):
        # C:\Users\lnafl\OneDrive\Projet Image\SOTS\SOTS\outdoor\hazy\1400_1.png
        if i < 10:
            gt_path = f"SOTS\SOTS\outdoor\gt\\000{i}.png"
            dehazed_path = f"images\dehazed\outdoor\\000{i}.jpg"
        elif 10 <= i < 100:
            gt_path = f"SOTS\SOTS\outdoor\gt\\00{i}.png"
            dehazed_path = f"images\dehazed\outdoor\\00{i}.jpg"
        elif 100 <= i < 1000:
            gt_path = f"SOTS\SOTS\outdoor\gt\\0{i}.png"
            dehazed_path = f"images\dehazed\outdoor\\0{i}.jpg"
        else:
            gt_path = f"SOTS\SOTS\outdoor\gt\\{i}.png"
            dehazed_path = f"images\dehazed\outdoor\\{i}.jpg"
        if cv2.imread(gt_path) is None:
            continue
        elif cv2.imread(dehazed_path) is None:
            continue
        print(f"Processing outdoor image {i}...")
        ssim_value = fast_ssim(dcc.resize(cv2.imread(gt_path)), cv2.imread(dehazed_path))
        ssim_values.append(ssim_value)
    mean_ssim = np.mean(ssim_values)
    return mean_ssim

def mean_psnr_indoor():
    psnr_values = []
    for i in range(50):
        for version in range(1,10):
            if i < 10:
                gt_path = f"SOTS\SOTS\indoor\gt\\140{i}.png"
                dehazed_path = f"images\dehazed\indoor\\140{i}_{version}.png"
            else:
                gt_path = f"SOTS\SOTS\indoor\gt\\14{i}.png"
                dehazed_path = f"images\dehazed\indoor\\14{i}_{version}.png"
            
            psnr_value = PSNR(dcc.resize(cv2.imread(gt_path)), cv2.imread(dehazed_path))
            psnr_values.append(psnr_value)
    mean_psnr = np.mean(psnr_values)
    return mean_psnr

def mean_psnr_outdoor():
    psnr_values = []
    for i in range(1, 1988):
        # C:\Users\lnafl\OneDrive\Projet Image\SOTS\SOTS\outdoor\hazy\1400_1.png
        if i < 10:
            gt_path = f"SOTS\SOTS\outdoor\gt\\000{i}.png"
            dehazed_path = f"images\dehazed\outdoor\\000{i}.jpg"
        elif 10 <= i < 100:
            gt_path = f"SOTS\SOTS\outdoor\gt\\00{i}.png"
            dehazed_path = f"images\dehazed\outdoor\\00{i}.jpg"
        elif 100 <= i < 1000:
            gt_path = f"SOTS\SOTS\outdoor\gt\\0{i}.png"
            dehazed_path = f"images\dehazed\outdoor\\0{i}.jpg"
        else:
            gt_path = f"SOTS\SOTS\outdoor\gt\\{i}.png"
            dehazed_path = f"images\dehazed\outdoor\\{i}.jpg"
        if cv2.imread(gt_path) is None:
            continue
        elif cv2.imread(dehazed_path) is None:
            continue
        psnr_value = PSNR(dcc.resize(cv2.imread(gt_path)), cv2.imread(dehazed_path))
        psnr_values.append(psnr_value)
    mean_psnr = np.mean(psnr_values)
    return mean_psnr

# Lancer calculs PSNR et SSIM pour les images indoor et outdoor du dataset SOTS
psnr_in = mean_psnr_indoor()
psnr_out = mean_psnr_outdoor()
ssim_in = mean_ssim_indoor()
ssim_out = mean_ssim_outdoor()

# Affichage résultats
print(f"Mean SSIM for indoor images: {ssim_in:.4f}")
print(f"Mean SSIM for outdoor images: {ssim_out:.4f}")
print(f"Mean PSNR for indoor images: {psnr_in:.2f} dB")
print(f"Mean PSNR for outdoor images: {psnr_out:.2f} dB")
