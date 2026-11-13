import dark_channel_computation, cv2, numpy as np

def estim_trans(image, atm, w, kernel_size):
    ratio = image.astype(np.float32) / atm.astype(np.float32)
    # Dark channel is uint8 [0,255], normalize to [0,1], compute transmission, scale back to uint8
    dc = dark_channel_computation.dark_channel(ratio, kernel_size).astype(np.float32) / 255.0
    transmission_float = 1 - w * dc  # Now in [0.05, 1] for typical cases
    # Return as uint8 [0, 255] for trans_refined compatibility
    return (transmission_float * 255.0).astype(np.uint8)

# Refine transmission using guided filter (résultats similaires à Levin mais plus rapide!!!)
def trans_refined(transmission, image, w_size):
    # Convert to float
    transmission = transmission.astype(np.float32) / 255.0
    image_gray = cv2.cvtColor((image * 255.0).astype(np.uint8), cv2.COLOR_BGR2GRAY).astype(np.float32) / 255.0

    # Guided filter parameters
    radius = w_size * 5
    eps = 1e-3

    refined = cv2.ximgproc.guidedFilter(
        guide=image_gray,
        src=transmission,
        radius=radius,
        eps=eps
    )

    return refined
