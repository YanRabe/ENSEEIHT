import cv2
import numpy as np

def dark_channel(image, kernel_size):
    b, g, r = cv2.split(image)

    r = r.astype('float32')
    g = g.astype('float32')
    b = b.astype('float32')

    n, m = b.shape
    dark_channel = np.ndarray([n,m])
    
    #fenêtres 3x3
    #dim = 3
    #d = math.floor(dim / 2) 
    kernel = np.ones((kernel_size, kernel_size), dtype=np.float32)
    rmin = cv2.erode(r,kernel)
    gmin = cv2.erode(g,kernel)
    bmin = cv2.erode(b,kernel)

    dark_channel = np.minimum(np.minimum(rmin, gmin), bmin)

    dark_channel = (dark_channel * 255.0).astype('uint8') 

    return dark_channel

def resize(image):
    n, m = image.shape[0:2]
    aspect_ratio = 600 / m
    new_height = int(n * aspect_ratio)
    resized_image = cv2.resize(image, (600, new_height))
    return resized_image
