import itertools
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation

fig = plt.figure()
ax = fig.add_subplot(projection='3d')

n_poissons = 30
dt = 0.05
area_lim = 1.0

# 1. Positions aléatoires (entre 0 et area_lim)
P = np.random.rand(n_poissons, 3) * area_lim

# 2. Vitesses aléatoires entre -1 et 1
V = (np.random.rand(n_poissons, 3) - 0.5) * 2 

def animate(i): 
    global P, V
    ax.clear()
    
    # Application de la formule : position(t + dt) = position(t) + vitesse(t) * dt
    P += V * dt
    
    # Gestion des bords virtuels (rebond)
    out_of_bounds_low = P < 0
    out_of_bounds_high = P > area_lim
    
    # Inverser la vitesse si on touche un mur
    V[out_of_bounds_low | out_of_bounds_high] *= -1
    
    # Forcer la position à rester dans les area_limites pour éviter les bugs visuels
    P = np.clip(P, 0, area_lim)
    
    # Redessine les vecteurs
    ax.quiver(P[:, 0], P[:, 1], P[:, 2], 
              V[:, 0], V[:, 1], V[:, 2], 
              length=0.1, normalize=True)
    
    # axes
    ax.set_xlim(0, area_lim)
    ax.set_ylim(0, area_lim)
    ax.set_zlim(0, area_lim)
    
    return ax,
 
ani = animation.FuncAnimation(fig, animate, frames=itertools.count(),
                              interval=35, blit=False, repeat=False)

plt.show()