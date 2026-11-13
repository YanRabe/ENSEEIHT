import itertools
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation

fig = plt.figure()
ax = fig.add_subplot(projection='3d')

# Définit les points poissons dans une sphère
n_poissons =  30
R = 0.4 ** 2

Z = np.random.rand(n_poissons, 1) * R
X = np.random.rand(n_poissons, 1) * (R - Z)
Y = np.sqrt(R - X - Z)

X = np.sqrt(X)
Z = np.sqrt(Z)

dt = 0.05

def animate(i): 
    global X, Y, Z
    ax.clear() # Clear le plot
    
    # Calcul des directions (vitesse de la poiscaille)
    u = np.sin(np.pi * X) * np.cos(np.pi * Y) * np.cos(np.pi * Z)
    v = -np.cos(np.pi * X) * np.sin(np.pi * Y) * np.cos(np.pi * Z)
    w = (np.sqrt(2.0 / 3.0) * np.cos(np.pi * X) * np.cos(np.pi * Y) * np.sin(np.pi * Z))
    
    # Maj des coords de poissons avec la formule du sujet
    X = X + u * dt
    Y = Y + v * dt
    Z = Z + w * dt

    # Redessine les vecteurs
    ax.quiver(X, Y, Z, u, v, w, length=0.1, normalize=True)
    
    # axes
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.set_zlim(0, 1)
    
    return ax,
 
ani = animation.FuncAnimation(fig, animate, frames=itertools.count(),
                              interval=1, blit=False, repeat=False)

plt.show()