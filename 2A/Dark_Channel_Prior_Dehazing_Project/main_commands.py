#dark channel computation
import atm_light, dark_channel_computation, transmission_est
import numpy as np
import cv2

# Ligne de commande paramètres
print("Spécification des paramètres de dehazing (appuyer sur Entrée pour les valeurs par défaut) ===")

try:
    kernel_size = int(input("Enter kernel size for dark channel computation (default 10): ") or 10)
    w_size = int(input("Enter window size for transmission refinement (default 3): ") or 3)
    beta = float(input("Enter beta (scattering coefficient, default 0.2): ") or 0.2)
    gamma = float(input("Enter gamma (exposure correction, default 0.8): ") or 0.8)
    t0 = float(input("Enter t0 (minimum transmission, default 0.1): ") or 0.1)
    w = float(input("Enter w (haze removal strength, default 0.85): ") or 0.85)
    img_path = input("Enter image path (default 'images/temple.jpg'): ") or 'images/temple.jpg'
except ValueError:
    print("Invalid input detected. Using default values.")
    kernel_size, w_size, beta, gamma, t0, w = 10, 3, 0.2, 0.8, 0.1, 0.85

print(f"\nParameters set:\n  kernel_size = {kernel_size}\n  w_size = {w_size}\n  beta = {beta}\n  gamma = {gamma}\n  t0 = {t0}\n  w = {w}\n img_path = '{img_path}'\n")

# Pipeline de dehazing
def main(kernel_size, w_size, beta, gamma, t0, w, img_path):
    #load image
    image = cv2.imread(img_path)
    image_s = dark_channel_computation.resize(image) # nouvelle taille: 600x?
    image = image_s.astype(np.float32) / 255.0 # normalisation [0, 1]

    #Compute dark_channel
    dark_channel = dark_channel_computation.dark_channel(image, kernel_size)
    cv2.imwrite("images/visual_res/dark_channel.png", dark_channel)

    #Compute atmospheric light
    atm = atm_light.atmospheric_light(image, dark_channel)
    print("Atmospheric light:", atm)

    #Compute transmission
    transmission = transmission_est.estim_trans(image, atm, w, kernel_size)
    cv2.imwrite("images/visual_res/transmission.png", transmission)

    #Refine transmission
    refined_transmission = transmission_est.trans_refined(transmission, image, w_size)  # Renvoie float [0,1]
    cv2.imwrite("images/visual_res/refined_transmission.png", (refined_transmission * 255).astype(np.uint8))

    #Recover scene radiance
    t = np.maximum(refined_transmission, t0)
    J = (image - atm) / t[..., None] + atm

    #Adjust exposure with gamma correction
    lut = np.array([((i/255)**gamma)*255 for i in range (256)], dtype = np.uint8)
    J_uint8 = np.clip(J * 255, 0, 255).astype(np.uint8)
    JCorrected = cv2.LUT(J_uint8, lut)
    cv2.imwrite("images/visual_res/radiance.png", JCorrected)

    #Depth map
    #t = e^(-beta * depth)
    #beta scattering coefficient of the atm
    depth = -np.log(np.clip(refined_transmission, 0.01, 1.0)) / beta # t >= 0.01 on évite log(0)

    # On affiche en [0,255]
    depth_norm = cv2.normalize(depth, None, 0, 255, cv2.NORM_MINMAX)
    depth_uint8 = depth_norm.astype(np.uint8)
    # Application du colormap
    depth_color = cv2.applyColorMap(depth_uint8, cv2.COLORMAP_HOT)
    cv2.imwrite("images/visual_res/depth_map.png", depth_color)

    # Affichage des résultats !
    cv2.imshow("lower quality image",image_s)
    cv2.imshow("dark channel",dark_channel)
    cv2.imshow("transmission", transmission)
    cv2.imshow("refined transmission",(refined_transmission * 255).astype(np.uint8))
    cv2.imshow('Gamma%s' % gamma, JCorrected)
    cv2.imshow("depth map", depth_color)


    cv2.waitKey(0)
    cv2.destroyAllWindows()

main(kernel_size, w_size, beta, gamma, t0, w, img_path)