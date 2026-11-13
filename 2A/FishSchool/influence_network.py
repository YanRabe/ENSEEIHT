import matplotlib.pyplot as plt
import numpy as np
from scipy.spatial import KDTree
from matplotlib.animation import FuncAnimation
import itertools

class NetworkAnimationManager:
    def __init__(self):
        # 3d plot
        self.fig = plt.figure(figsize=(10, 8))
        self.ax = self.fig.add_subplot(111, projection='3d')
        
        self.ani = None


    def init_banc_de_poissons(self):
        self.ax.clear()
        
        self.n_poissons = 30
        self.dist_repulsion = 1
        self.dist_alignement = 2.5
        self.dist_attraction = 5.0
        self.dt = 0.05
        self.k_repulsion = 2.0
        self.k_attraction = -0.5
        self.area_lim = 10.0  #limite de zone
        self.vision_angle = 30

        # Positions entre -area_lim et +area_lim
        self.P = (np.random.rand(self.n_poissons, 3) * 2 - 1) * (self.area_lim)
        # Vitesses aléatoires initiales
        self.V = (np.random.rand(self.n_poissons, 3) - 0.5) * 2 
        

    def create_animation(self):
        self.init_banc_de_poissons()
                
        # Initialisation du champ de vecteurs 3D
        ## Aidé par IA pour la partie esthétique
        self.quiver = self.ax.quiver(
                self.P[:, 0], self.P[:, 1], self.P[:, 2],
                self.V[:, 0], self.V[:, 1], self.V[:, 2],
                length=1.0,                
                normalize=True, 
                linewidth=1.5,
                arrow_length_ratio=0.7,
                alpha=0.8,
                pivot='tail'               # Pivot from the tail for natural movement
            )
        
        self.ax.set_xlim([-self.area_lim, self.area_lim])
        self.ax.set_ylim([-self.area_lim, self.area_lim])
        self.ax.set_zlim([-self.area_lim, self.area_lim])

        self.ax.set_title("Influence de la Densité")


        def update(frame):
            # Maj des positions
            self.P += self.V * self.dt
            
            # Vérification des frontières et inversion de la vitesse si atteintes
            out_of_bounds = (self.P < -self.area_lim) | (self.P > self.area_lim)
            self.V[out_of_bounds] *= -1

            # forcer à rester dans la box
            self.P = np.clip(self.P, -self.area_lim, self.area_lim)

            kd_tree = KDTree(self.P)
            tmp_V = np.copy(self.V)

            for i in range(self.n_poissons):
                voisins_repulsion = []
                voisins_alignement = []
                voisins_attraction = []
                
                voisins_max = kd_tree.query_ball_point(self.P[i], r=self.dist_attraction)
                voisins_max.remove(i)

                norm_vi = np.linalg.norm(self.V[i])
                if norm_vi == 0:
                    dir_i = np.zeros(3)
                else:
                    dir_i = self.V[i] / norm_vi

                # cône de vision
                for j in voisins_max:
                    dist_vec = self.P[j] - self.P[i]
                    dist = np.linalg.norm(dist_vec)
                    if dist == 0:
                        continue

                    dir_j = dist_vec / dist

                    cos_theta = np.clip(np.dot(dir_i, dir_j), -1.0, 1.0)
                    angle = np.degrees(np.arccos(cos_theta))

                    # visiblité et voisinages
                    if angle < self.vision_angle:
                        if dist < self.dist_repulsion:
                            voisins_repulsion.append(j)
                        elif dist < self.dist_alignement:
                            voisins_alignement.append(j)
                        else: # dist < dist_attraction
                            voisins_attraction.append(j)

                # Répulsion
                for j in voisins_repulsion:
                    dist_vec = self.P[i] - self.P[j]
                    dist = np.linalg.norm(dist_vec)
                    if dist > 0:
                        tmp_V[i] += self.k_repulsion * (dist_vec / dist)

                # Alignement
                n_aligne = len(voisins_alignement)
                if n_aligne > 0:
                    sum_V = np.zeros(3)
                    for j in voisins_alignement:
                        sum_V += self.V[j]

                    tmp_V[i] += sum_V / n_aligne

                # Attraction
                for j in voisins_attraction:
                    dist_vec = self.P[i] - self.P[j]
                    dist = np.linalg.norm(dist_vec)
                    if dist > 0:
                        tmp_V[i] += self.k_attraction * (dist_vec / dist)

            self.V = tmp_V

            # Normalisation de la vitesse
            speed = 3.0
            norms = np.linalg.norm(self.V, axis=1, keepdims=True)
            self.V = np.where(norms > 0, (self.V / norms) * speed, self.V)

            # Maj graphique avec Quiver
            # On efface les flèches de l'itération précédente
            self.quiver.remove()
            
            # On redessine les flèches avec les nouvelles directions
            self.quiver = self.ax.quiver(
                self.P[:, 0], self.P[:, 1], self.P[:, 2],
                self.V[:, 0], self.V[:, 1], self.V[:, 2],
                length=1.0,
                normalize=True, 
                linewidth=1.5,
                arrow_length_ratio=0.7,
                alpha=0.8,
                pivot='tail'
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
    manager = NetworkAnimationManager()
    manager.create_animation()