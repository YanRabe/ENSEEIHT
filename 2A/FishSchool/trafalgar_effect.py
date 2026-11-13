import random as rd
import matplotlib.pyplot as plt
import numpy as np
from matplotlib.animation import FuncAnimation
import itertools

class TrafalgarAnimationManager:
    def __init__(self):
        # 3d plot
        self.fig = plt.figure(figsize=(10, 8))
        self.ax = self.fig.add_subplot(111, projection='3d')
        
        self.ani = None


    def init_banc_de_poissons(self):
        self.ax.clear()
        
        self.n_poissons = 30
        self.dist_contagion = 2  # distance limite de contamination
        self.dt = 0.05
        self.area_lim = 10.0  #limite de zone
        
        # Positions entre -area_lim et +area_lim
        self.P = (np.random.rand(self.n_poissons, 3) * 2 - 1) * (self.area_lim / 2)
        # Vitesses aléatoires initiales
        self.V = (np.random.rand(self.n_poissons, 3) - 0.5) * 2 
        
        # 0 = Normal, 1 = Leader, 2 = Contaminé
        self.etat = np.zeros(self.n_poissons, dtype=int)

        # Choix du leader random
        self.leader_idx = rd.randint(0, self.n_poissons - 1)
        self.etat[self.leader_idx] = 1
        
        # comportement distinct au leader
        self.V[self.leader_idx] += np.array([3.0, 3.0, 3.0])

    def get_colors(self):
        # Bleu = normal, Rouge = leader, Vert = contaminé
        return ['red' if e == 1 else '#33cc33' if e == 2 else '#00e6e6' for e in self.etat]
    

    def create_animation(self):
        self.init_banc_de_poissons()
                
        # Initialisation du champ de vecteurs 3D 
        self.quiver = self.ax.quiver(
            self.P[:, 0], self.P[:, 1], self.P[:, 2],
            self.V[:, 0], self.V[:, 1], self.V[:, 2],
            colors=self.get_colors(), length=1.5, normalize=True
        )
        
        self.ax.set_xlim([-self.area_lim, self.area_lim])
        self.ax.set_ylim([-self.area_lim, self.area_lim])
        self.ax.set_zlim([-self.area_lim, self.area_lim])

        self.ax.set_title("Effet Trafalgar - Propagation")


        def update(frame):
            # Maj des positions
            self.P += self.V * self.dt
            
            # Vérification des frontières et inversion de la vitesse si atteintes
            out_of_bounds = (self.P < -self.area_lim) | (self.P > self.area_lim)
            self.V[out_of_bounds] *= -1

            # forcer à rester dans la box
            self.P = np.clip(self.P, -self.area_lim, self.area_lim)

            # Propagation périodique
            nb_cycles = 4
            if frame % nb_cycles == 0:
                contagieux_idx = np.where((self.etat == 1) | (self.etat == 2))[0]
                normaux_idx = np.where(self.etat == 0)[0]

                for i in normaux_idx:
                    for c in contagieux_idx:
                        dist = np.linalg.norm(self.P[i] - self.P[c])
                        
                        # Contamination
                        if dist < self.dist_contagion:
                            self.etat[i] = 2
                            
                            # La nouvelle vitesse sera l'influence du contaminant + un bruit
                            rand_bruit = (np.random.rand(3) - 0.5) * 0.33
                            contamination_infl = self.V[c] * 0.66 
                            
                            variation_aleatoire = contamination_infl + rand_bruit
                            self.V[i] += variation_aleatoire
                            
                            break 

            # Maj graphique avec Quiver
            # On efface les flèches de l'itération précédente
            self.quiver.remove()
            
            # On redessine les flèches avec les nouvelles directions
            self.quiver = self.ax.quiver(
                self.P[:, 0], self.P[:, 1], self.P[:, 2],
                self.V[:, 0], self.V[:, 1], self.V[:, 2],
                colors=self.get_colors(), length=1.5, normalize=True
            )

            return self.quiver,

        self.ani = FuncAnimation(
            self.fig, 
            update, 
            frames=itertools.count(), 
            blit=False, 
            interval=35, 
            save_count=100
        )
        plt.show()

if __name__ == "__main__":
    manager = TrafalgarAnimationManager()
    manager.create_animation()