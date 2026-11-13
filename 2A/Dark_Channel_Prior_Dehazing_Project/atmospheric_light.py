import numpy as np
import cv2 as cv

def estimate_atmospheric_light(image, dark_channel, n, m):
    mat_size = (n * m) // 1000
    gs_image = cv.cvtColor(image, cv.COLOR_BGR2GRAY)

    top_dark_idx = np.argsort(dark_channel.flatten())[-mat_size:]
    top_dark_idx= np.unravel_index(top_dark_idx, dark_channel.shape)

    max_intensity = -np.inf
    max_idx = (0, 0)

    for x, y in zip(*top_dark_idx):
        local_intensity = gs_image[x, y]
        if max_intensity < local_intensity:
            max_intensity = local_intensity
            max_idx = (x, y)
        
    return image[max_idx]


