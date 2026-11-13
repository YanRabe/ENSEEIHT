import numpy as np

def atmospheric_light(image, dark_channel):

    h, w = dark_channel.shape
    num_pixels = h * w

    # top 0.1%
    num_bright = max(int(num_pixels * 0.001), 1)

    flat_dark = dark_channel.ravel()
    flat_image = image.reshape(num_pixels, 3)

    # indices of brightest pixels in dark channel
    indices = np.argpartition(flat_dark, -num_bright)[-num_bright:]

    # candidate atmospheric pixels
    candidates = flat_image[indices]

    # choose brightest candidate in original image
    atm = candidates[np.argmax(np.sum(candidates, axis=1))]

    return atm.astype(np.float32) # atm type 3x [0,1] float32