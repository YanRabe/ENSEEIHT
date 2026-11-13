#dark channel computation
import os
import numpy as np
import cv2, math
os.environ['QT_QPA_PLATFORM'] = 'xcb'

image = cv2.imread('bleak-désint.jpg')
if image is None:
    raise FileNotFoundError("L'image n'existe pas. Vérifiez le casing svp.")
b, g, r = cv2.split(image)

r = r.astype('uint8')
g = g.astype('uint8')
b = b.astype('uint8')

n, m = b.shape
print(n, m)
dark_channel = np.zeros((n, m))

#fenêtres 3x3
dim = 3
d = math.floor(dim / 2) 

# Create an image containing the minimum pixel value among the 3 channels
min_channels = np.min(image, axis=2) 

# The physical patch minimum equivalent is a morphological erosion
kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (dim, dim))
dark_channel = cv2.erode(min_channels, kernel)

dark_channel = dark_channel.astype('uint8')

cv2.imshow("dark channel",dark_channel)
cv2.imwrite("dark_channel2.png", dark_channel)
cv2.waitKey(0)
cv2.destroyAllWindows()