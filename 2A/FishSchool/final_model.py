import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation
from scipy.spatial import KDTree
import itertools

class UltimateAnimationManager:
    def __init__(self):

        # Configuration esthétique style "Océan"
        ## Demandé à l'IA pcq c'état très laid sinon
        self.fig = plt.figure(figsize=(10, 8))
        self.fig.patch.set_facecolor('#001a33')
        self.ax = self.fig.add_subplot(111, projection='3d')
        self.ax.set_facecolor('#001a33')
        self.ax.grid(False)
        self.ax.set_axis_off()
        
        self.n_poissons = 100
        self.area_lim = 20.0
        self.dt = 0.05
        
        # Densité et Vision
        self.n_voisins = 6            # max 6 voisins influenceurs
        self.vision_angle = 60   # degré du cône de vision
        
        # Seuils Aoki
        self.dist_repulsion = 1.0
        self.dist_alignement = 3.0
        self.dist_attraction = 7.0
        self.k_repulsion = 2.5
        self.k_attraction = -0.5
        
        # Facteurs Trafalgar (Vitesse et Propagation)
        self.normal_speed = 3.0
        self.contaminated_speed = 5.0        # Les poissons contaminés fuient plus vite
        self.nb_cycles = 4            # Propagation tous les 4 cycles
        self.reset_cycle = 150        # Remise à zéro et nouveau leader tous les 150 cycles

        # Courant de l'eau (force extérieure)
        self.current = np.array([0.0, 0.0, 0.0]) # Courant par défaut
        self.current_step = 0.25 # Sensibilité des touches
        
        # Initialisation Random
        self.P = (np.random.rand(self.n_poissons, 3) * 2 - 1) * self.area_lim
        self.V = (np.random.rand(self.n_poissons, 3) - 0.5) * 2
        
        # Trafalgar - Statut d'alerte (0 = Normal, 1 = Leader, 2 = Contaminé)
        self.etat = np.zeros(self.n_poissons, dtype=int)
        
        # Choix du leader random
        self.leader_idx = np.random.randint(0, self.n_poissons)
        self.etat[self.leader_idx] = 1
        
        # Comportement distinct initial au leader
        self.V[self.leader_idx] += np.array([3.0, 3.0, 3.0])
        
        self.quiver = None
    

    def on_key_press(self, event):
        if event.key == 'up':
            self.current[1] += self.current_step
        if event.key == 'down':
            self.current[1] -= self.current_step
        if event.key == 'left':
            self.current[0] -= self.current_step
        if event.key == 'right':
            self.current[0] += self.current_step
        if event.key == ' ':
            self.current = np.zeros(3)
        if event.key == 'q':
            self.ani.event_source.stop()

        print(f"Courant actuel modifié : [X:{self.current[0]:.1f}, Y:{self.current[1]:.1f}]")

    def get_colors(self):
        # Bleu = normal, Rouge = leader, Vert = contaminé
        return ['red' if e == 1 else '#33cc33' if e == 2 else '#00e6e6' for e in self.etat]


    def create_animation(self):
        self.quiver = self.ax.quiver(
            self.P[:, 0], self.P[:, 1], self.P[:, 2],
            self.V[:, 0], self.V[:, 1], self.V[:, 2],
            length=1.2, normalize=True, colors=self.get_colors(),
            linewidth=1.5, arrow_length_ratio=0.7, alpha=0.9, pivot='tail'
        )
        
        self.ax.set_xlim([-self.area_lim, self.area_lim])
        self.ax.set_ylim([-self.area_lim, self.area_lim])
        self.ax.set_zlim([-self.area_lim, self.area_lim])
        self.ax.set_title("L'Ultime Banc de Poissons", color="white")

        #Plug les touches clavier et désativer celles par défaut
        self.fig.canvas.mpl_disconnect(self.fig.canvas.manager.key_press_handler_id)
        self.fig.canvas.mpl_connect('key_press_event', self.on_key_press)

        def update(frame):
            # Update de la position
            self.P += self.V * self.dt
            
            # Gestion des collisions avec les bordures
            out_of_bounds = (self.P < -self.area_lim) | (self.P > self.area_lim)
            self.V[out_of_bounds] *= -1
            self.P = np.clip(self.P, -self.area_lim, self.area_lim)

            #le KD_tree pour trouver les voisinages rapidement
            kd_tree = KDTree(self.P)

            tmp_V = np.copy(self.V)
            nv_etat = np.copy(self.etat)

            # contagion tous les 4 cycles
            contagion_active = (frame % self.nb_cycles == 0)

            for i in range(self.n_poissons):
                # Trouver les K plus proches voisins
                distances, idx = kd_tree.query(self.P[i], k=self.n_voisins + 1)
                
                voisins_repulsion = []
                voisins_alignement = []
                voisins_attraction = []
                
                # 
                norm_vi = np.linalg.norm(self.V[i])
                dir_i = self.V[i] / norm_vi if norm_vi > 0 else np.zeros(3)
                
                # Checker le cône de vision
                for d, j in zip(distances[1:], idx[1:]):
                    if d == 0: continue
                    
                    dist_vec = self.P[j] - self.P[i]
                    dir_j = dist_vec / d
                    
                    cos_theta = np.clip(np.dot(dir_i, dir_j), -1.0, 1.0)
                    angle = np.degrees(np.arccos(cos_theta))
                    
                    # visibilité et voisinages pour la contagion et les influences
                    if angle < self.vision_angle:
                        # Trafalgar
                        if contagion_active and self.etat[i] == 0 and self.etat[j] > 0:
                            nv_etat[i] = 2  # Devient contaminé
                            
                            # Contagion sur la vitesse
                            rand_bruit = (np.random.rand(3) - 0.5)
                            tmp_V[i] += self.V[j] * 0.66 + rand_bruit * 0.33
                            
                        # AOKI voisinages
                        if d < self.dist_repulsion:
                            voisins_repulsion.append(j)
                        elif d < self.dist_alignement:
                            voisins_alignement.append(j)
                        elif d < self.dist_attraction:
                            voisins_attraction.append(j)
                            
                # Influence des forces
                for j in voisins_repulsion:
                    dist_vec = self.P[i] - self.P[j]
                    dist = np.linalg.norm(dist_vec)
                    if dist > 0:
                        tmp_V[i] += self.k_repulsion * (dist_vec / dist)
                    
                n_alignes = len(voisins_alignement)
                if n_alignes > 0:
                    sum_V = np.zeros(3)
                    for j in voisins_alignement:
                        sum_V += self.V[j]
                    tmp_V[i] += sum_V / n_alignes
                    
                for j in voisins_attraction:
                    dist_vec = self.P[i] - self.P[j]
                    dist = np.linalg.norm(dist_vec)
                    if dist > 0:
                        tmp_V[i] += self.k_attraction * (dist_vec / dist)

            # effet du courant
            tmp_V += self.current

            self.V = tmp_V
            self.etat = nv_etat

            # Normalisation
            # Les poissons normaux (0) vont à normal_speed, les fuyards (1 ou 2) vont à contaminated_speed
            speeds = np.where(self.etat > 0, self.contaminated_speed, self.normal_speed)
            norms = np.linalg.norm(self.V, axis=1)
            norms = np.where(norms == 0, 1.0, norms)
            
            for i in range(self.n_poissons):
                self.V[i] = (self.V[i] / norms[i]) * speeds[i]

            # Mise à jour graphique
            self.quiver.remove()
            self.quiver = self.ax.quiver(
                self.P[:, 0], self.P[:, 1], self.P[:, 2],
                self.V[:, 0], self.V[:, 1], self.V[:, 2],
                length=1.2, normalize=True, colors=self.get_colors(),
                linewidth=1.5, arrow_length_ratio=0.7, alpha=0.9, pivot='tail'
            )

            # Reset périodique de l'alerte et changement de leader
            if frame > 0 and frame % self.reset_cycle == 0:
                # on remet tt le monde à l'état 0
                nv_etat.fill(0)
                
                # nouveau leader aléatoire
                nouveau_leader = np.random.randint(0, self.n_poissons)
                nv_etat[nouveau_leader] = 1
                
                #comportement distinct du nv leader
                tmp_V[nouveau_leader] += (np.random.rand(3) - 0.5) * 6.0

            return self.quiver,

        self.ani = FuncAnimation(
            self.fig, update, frames=itertools.count(), interval=35, blit=False, save_count=100
        )
        plt.show()

if __name__ == "__main__":
    manager = UltimateAnimationManager()
    manager.create_animation()