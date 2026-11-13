#dark channel computation
import atm_light, dark_channel_computation, transmission_est
import numpy as np
import cv2

#######################################################################
####### THIS MAIN IS USED FOR METRICS EVALUATION ONLY, SEE main_commands.py FOR THE FULL PIPELINE WITH VISUALIZATION #######
#######################################################################

def main(kernel_size, w_size, beta, gamma, t0, w, img_path, save_path):
    #load image
    image = cv2.imread(img_path)
    image_s = dark_channel_computation.resize(image) # nouvelle taille: 600x?
    image = image_s.astype(np.float32) / 255.0 # normalisation [0, 1]

    #Compute dark_channel
    dark_channel = dark_channel_computation.dark_channel(image, kernel_size)

    #Compute atmospheric light
    atm = atm_light.atmospheric_light(image, dark_channel)

    #Compute transmission
    transmission = transmission_est.estim_trans(image, atm, w, kernel_size)

    #Refine transmission
    refined_transmission = transmission_est.trans_refined(transmission, image, w_size)  # Renvoie float [0,1]

    #Recover scene radiance
    t = np.maximum(refined_transmission, t0)
    J = (image - atm) / t[..., None] + atm

    #Adjust exposure with gamma correction
    lut = np.array([((i/255)**gamma)*255 for i in range (256)], dtype = np.uint8)
    J_uint8 = np.clip(J * 255, 0, 255).astype(np.uint8)
    JCorrected = cv2.LUT(J_uint8, lut)

    cv2.imwrite(save_path, JCorrected)