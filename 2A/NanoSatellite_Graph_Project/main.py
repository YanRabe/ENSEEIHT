from csv_handler import avg, low, high
import matplotlib.pyplot as plt
import networkx as nx
import numpy as np

### variables de config
ESSAIMS = {"densité faible": low,"densité moyenne":avg, "densité forte":high}
# ESSAIMS = {"densité moyenne":avg, "densité forte":high}
PORTEES = [20000, 40000, 60000] #portée des satellites


essaims_G = [[nx.Graph() for _ in PORTEES] for _ in ESSAIMS]
NB_SAT = 100 #nombre de satellites

# pour chaque satellite on crée un noeud
for e_id, coord in enumerate(ESSAIMS.values()):
    for p_id in range(len(PORTEES)):
        graph = essaims_G[e_id][p_id]
        for i, coord in enumerate(coord):
            # on stocke la position dans le noeud pour la visu ou les calculs futurs
            graph.add_node(i, pos=coord)


# fonction pour calculer la distance entre deux points
def calc_distance(x1,y1,z1,x2,y2,z2):
    p1 = np.array([x1,y1,z1])
    p2 = np.array([x2,y2,z2])
    return np.linalg.norm(p1 - p2)


#pour chaque satellite, calculer sa distance à tous les autres, ajouter un edge si distance < portée
mat_distances = [np.zeros((NB_SAT, NB_SAT)) for e in ESSAIMS]

for e_id, essaim in enumerate(ESSAIMS.values()):
    for i, c1 in enumerate(essaim):
        for j, c2 in enumerate(essaim):
            if i >= j: # On calcule qu'une fois pour (i,j)
                continue
            # Calcul de la distance
            d = calc_distance(c1[0], c1[1], c1[2], c2[0], c2[1], c2[2])
            # Stockage dans la matrice
            mat_distances[e_id][i][j] = d
            mat_distances[e_id][j][i] = d

            # pour chaque portée
            for p_id, portee in enumerate(PORTEES):
                if d < portee:
                    # on ajoute l'edge
                    essaims_G[e_id][p_id].add_edge(i, j, weight=d)


### Visualiser (Partie 1)

def _format_axes(ax):
    """config pour la visu en 3D."""
    # Pas besoin des grilles
    ax.grid(False)
    # On retire les labels des ticks
    for dim in (ax.xaxis, ax.yaxis, ax.zaxis):
        dim.set_ticks([])
    ax.set_xlabel("x")
    ax.set_ylabel("y")
    ax.set_zlabel("z")


print("Configuration 0: Densité faible.\n")
print("Configuration 1: Densité moyenne.\n")
print("Configuration 2: Densité élevée.\n")


# for id in ESSAIMS:
#     viz = plt.figure().add_subplot(projection='3d')
#     viz.plot(ESSAIMS[id][:, 0], ESSAIMS[id][:, 1], ESSAIMS[id][:, 2], 'ro')
#     plt.title(f"Représentation de l'essaim de {id}")

# plt.show()

# affichage des essaims avec les arêtes
for e_id, (name, coord) in enumerate(ESSAIMS.items()):
    for p_id, portee in enumerate(PORTEES):
        essaim = essaims_G[e_id][p_id]
        dist_matrix = mat_distances[e_id]

        # # récup les noeuds et les arêtes
        # node_xyz = np.array([coord[v, :] for v in sorted(essaim.nodes)])
        # edge_xyz = np.array([(coord[u, :], coord[v, :]) for u, v in essaim.edges()])

        # # fig 3d avec matplotlib et nx
        # fig = plt.figure()
        # ax = fig.add_subplot(111, projection="3d")

        # # Plot les noeuds
        # ax.scatter(*node_xyz.T, s=100, ec="w")

        # # Plot les arêtes
        # for vizedge in edge_xyz:
        #     ax.plot(*vizedge.T, color="tab:gray")

        # _format_axes(ax)
        # plt.title(f"Représentation de l'essaim de {name} avec la configuration {p_id}")
        # fig.tight_layout()

plt.show()

### analyse pour les graphes non valués (Partie 2)
for e_id, (name, coord) in enumerate(ESSAIMS.items()):
    for p_id, portee in enumerate(PORTEES):
        essaim = essaims_G[e_id][p_id]
        
        print(f"\n[ Analyse Pour la config : {name} - {portee / 1000}km ]")

        #DEGRÉ MOYEN
        deg_moyen = 0
        for i in essaim.nodes:
            deg_moyen += essaim.degree(i)

        deg_moyen = deg_moyen / essaim.number_of_nodes()
        print("Degré moyen :", deg_moyen)

        # DISTRIB DU DEG
        essaim_degree = np.zeros((1))
        for i in essaim.nodes:
            essaim_degree = np.append(essaim_degree,essaim.degree(i))

        res = plt.hist(essaim_degree)
        plt.xlabel("satellites")
        plt.ylabel("degré")
        plt.title(f"Distribution du degré par satellite ({name} - {portee / 1000}km)")
        #DÉCOMMENTER POUR ENREGISTRER LE GRAPHE
        # plt.savefig(f"img/{name}_{portee / 1000}_deg_distrib.png".replace(" ", "_"),
                # dpi=300,
                # bbox_inches='tight') #sauvegarde le graphe en png
        plt.show()


        # CLUSTERING MOYEN
        clustering_moyen = nx.average_clustering(essaim)
        print("Moyernne du clustering :", clustering_moyen)


        # DISTRIBUTION DU DEGRE DE CLUSTERING
        clustering_nodes = nx.clustering(essaim)
        clustering_values = np.array(list(clustering_nodes.values()))
        plt.figure()
        plt.hist(clustering_values, bins=20)
        plt.xlabel("Degré de clustering")
        plt.ylabel("Nombre de satellites")
        plt.title(f"Distribution du degré de clustering ({name} - {portee / 1000}km)")
        #DÉCOMMENTER POUR ENREGISTRER LE GRAPHE
        # plt.savefig(f"img/{name}_{portee / 1000}_clustering_distrib.png".replace(" ", "_"),
        #         dpi=300,
        #         bbox_inches='tight') #sauvegarde le graphe en png
        plt.show()


        #CLIQUE | on utilise fiind_cliques qui ne récupère que les cliques maximales
        # parce que sinon la complexité explose et ca n'en finit pas de tourner...
        clique_by_node = list(nx.find_cliques(essaim))
        NOMBRE_CLIQUE = len(clique_by_node)
        print("Nombre de cliques (maximales) : " +str(NOMBRE_CLIQUE))


        # ORDRE DES CLIQUES
        taille_cliques = [len(c) for c in clique_by_node]
        if taille_cliques:
            plt.figure()
            plt.hist(taille_cliques)
            plt.xlabel("Taille de la clique")
            plt.ylabel("Nombre de cliques")
            plt.title(f"Distribution de l'ordre des cliques ({name} - {portee / 1000}km)")
            #DÉCOMMENTER POUR ENREGISTRER LE GRAPHE
            # plt.savefig(f"img/{name}_{portee / 1000}_cliques_ordre_distrib.png".replace(" ", "_"),
            #     dpi=300,
            #     bbox_inches='tight') #sauvegarde le graphe en png
            plt.show()


        #COMPOSANTES CONNEXES
        NOMBRE_CONNEXE = nx.number_connected_components(essaim)
        print("Nombre de composantes connexes : " + str(NOMBRE_CONNEXE))


        #ORDRE DES COMPOSANTES CONNEXES
        compo_connexes = list(nx.connected_components(essaim))
        taille_connexes = [len(c) for c in compo_connexes]
        print(f"Ordre des composantes connexes : {taille_connexes}")
        if taille_connexes:
            plt.figure()
            plt.hist(taille_connexes)
            plt.xlabel("Taille (ordre) de la composante")
            plt.ylabel("Nombre de composantes")
            plt.title(f"Distribution de l'ordre des composantes connexes ({name} - {portee / 1000}km)")
            #DÉCOMMENTER POUR ENREGISTRER LE GRAPHE
            # plt.savefig(f"img/{name}_{portee / 1000}_connexes_ordre_distrib.png".replace(" ", "_"),
            #     dpi=300,
            #     bbox_inches='tight') #sauvegarde le graphe en png
            plt.show()

        #PLUS COURT CHEMINS ET LONGUEUR
        mat_court_chemin = np.empty((NB_SAT,NB_SAT),dtype=object)
        mat_longueur_chemin = np.zeros((NB_SAT,NB_SAT))
        
        all_paths = dict(nx.all_pairs_shortest_path(essaim))

        for i in range(NB_SAT):
            for j in range(NB_SAT):
                if i in all_paths and j in all_paths[i]:
                    # Chemin trouvé
                    path = all_paths[i][j]
                    mat_court_chemin[i][j] = path
                    
                    # Calcul de la distance
                    d = 0.0
                    for k in range(1, len(path)):
                        u, v = path[k-1], path[k]
                        d += dist_matrix[u][v]
                    mat_longueur_chemin[i][j] = d
                else:
                    # Pas de chemin
                    mat_court_chemin[i][j] = None


        # DISTRIB PLUS COURTS CHEMINS
        path_lengths = []
        for i in range(NB_SAT):
            for j in range(i + 1, NB_SAT):
                if mat_court_chemin[i][j] is not None:
                    path_lengths.append(mat_longueur_chemin[i][j])
        
        if path_lengths:
            plt.figure()
            plt.hist(path_lengths, bins=20)
            plt.xlabel("Longueur du chemin (distance)")
            plt.ylabel("Fréquence")
            plt.title(f"Distribution des plus courts chemins ({name} - {portee / 1000}km)")
            #DÉCOMMENTER POUR ENREGISTRER LE GRAPHE
            # plt.savefig(f"img/{name}_{portee / 1000}_shortest_distrib.png".replace(" ", "_"),
            #     dpi=300,
            #     bbox_inches='tight') #sauvegarde le graphe en png
            plt.show()


        # Nombre des plus courts chemins
        nb_chemins = len(path_lengths)
        print(f"Nombre de plus courts chemins: {nb_chemins}\n")


### Analayse pour les graphes valués (Partie 3)
for e_id, (name, coord) in enumerate(ESSAIMS.items()):

    p_id = 2 #index de la portée de 60km
    portee = PORTEES[p_id]
    
    # On copie le graphe courant
    essaim = essaims_G[e_id][p_id].copy()
    
    # Mise à jour des poids pour le carré de la distance
    for u, v, data in essaim.edges(data=True):
        d = data['weight']
        essaim[u][v]['weight'] = d**2

    print(f"\n[ Analyse (graphe pondéré) pour la config : {name} - {portee / 1000}km ]")
    
    #DEGRÉ MOYEN
    deg_moyen = 0
    for i in essaim.nodes:
        deg_moyen += essaim.degree(i)

    deg_moyen = deg_moyen / essaim.number_of_nodes()
    print("Degré moyen :", deg_moyen)

    # DISTRIB DU DEG
    essaim_degree = np.zeros((1))
    for i in essaim.nodes:
        essaim_degree = np.append(essaim_degree,essaim.degree(i))

    res = plt.hist(essaim_degree)
    plt.xlabel("satellites")
    plt.ylabel("degré")
    plt.title(f"Distribution du degré par satellite ({name} - {portee / 1000}km - Valué)")
    #DÉCOMMENTER POUR ENREGISTRER LE GRAPHE
    # plt.savefig(f"img/{name}_{portee / 1000}_deg_distrib_VALUED.png".replace(" ", "_"),
    #             dpi=300,
    #             bbox_inches='tight') #sauvegarde le graphe en png
    plt.show()


    # CLUSTERING MOYEN
    clustering_moyen = nx.average_clustering(essaim)
    print("Clustering moyen :", clustering_moyen)


    # DISTRIBUTION DU DEGRE DE CLUSTERING
    clustering_nodes = nx.clustering(essaim)
    clustering_values = np.array(list(clustering_nodes.values()))
    plt.figure()
    plt.hist(clustering_values, bins=20)
    plt.xlabel("Degré de clustering")
    plt.ylabel("Nombre de satellites")
    plt.title(f"Distribution du degré de clustering ({name} - {portee / 1000}km - Valué)")
    #DÉCOMMENTER POUR ENREGISTRER LE GRAPHE
    # plt.savefig(f"img/{name}_{portee / 1000}_clustering_distrib_VALUED.png".replace(" ", "_"),
    #             dpi=300,
    #             bbox_inches='tight') #sauvegarde le graphe en png
    plt.show()


    #CLIQUE
    clique_by_node = list(nx.find_cliques(essaim))
    NOMBRE_CLIQUE = len(clique_by_node)
    print("Nombre de cliques (maximales) : " +str(NOMBRE_CLIQUE))


    # ORDRE DES CLIQUES
    taille_cliques = [len(c) for c in clique_by_node]
    if taille_cliques:
        plt.figure()
        plt.hist(taille_cliques)
        plt.xlabel("Taille de la clique")
        plt.ylabel("Nombre de cliques")
        plt.title(f"Distribution de l'ordre des cliques ({name} - {portee / 1000}km - Valué)")
        #DÉCOMMENTER POUR ENREGISTRER LE GRAPHE
        # plt.savefig(f"img/{name}_{portee / 1000}_cliques_ordre_distrib_VALUED.png".replace(" ", "_"),
        #         dpi=300,
        #         bbox_inches='tight') #sauvegarde le graphe en png
        plt.show()


    #COMPOSANTES CONNEXES
    NOMBRE_CONNEXE = nx.number_connected_components(essaim)
    print("Nombre de composantes connexes : " + str(NOMBRE_CONNEXE))


    #ORDRE DES COMPOSANTES CONNEXES
    compo_connexes = list(nx.connected_components(essaim))
    taille_connexes = [len(c) for c in compo_connexes]
    print(f"Ordre des composantes connexes : {taille_connexes}")
    
    if taille_connexes:
        plt.figure()
        plt.hist(taille_connexes)
        plt.xlabel("Taille (ordre) de la composante")
        plt.ylabel("Nombre de composantes")
        plt.title(f"Distribution de l'ordre des composantes connexes ({name} - {portee / 1000}km - Valué)")
        #DÉCOMMENTER POUR ENREGISTRER LE GRAPHE
        # plt.savefig(f"img/{name}_{portee / 1000}_connexes_ordre_distrib_VALUED.png".replace(" ", "_"),
        #         dpi=300,
        #         bbox_inches='tight') #sauvegarde le graphe en png
        plt.show()


    #PLUS COURT CHEMINS ET LONGUEUR
    mat_court_chemin = np.empty((NB_SAT,NB_SAT),dtype=object)
    mat_longueur_chemin = np.zeros((NB_SAT,NB_SAT))
    
    # all_pairs_dijkstra_path utilise les poids 'weight' par défaut
    all_paths = dict(nx.all_pairs_dijkstra_path(essaim))

    for i in range(NB_SAT):
        for j in range(NB_SAT):
            if i in all_paths and j in all_paths[i]:
                # chemin trouvé
                path = all_paths[i][j]
                mat_court_chemin[i][j] = path
                
                # calcul de la distance
                d = 0.0
                for k in range(1, len(path)):
                    u, v = path[k-1], path[k]
                    # poids stocké dans le graphe
                    d += essaim[u][v]['weight']
                mat_longueur_chemin[i][j] = d
            else:
                # Pas de chemin
                mat_court_chemin[i][j] = None


    # DISTRIB PLUS COURTS CHEMINS
    path_lengths = []
    for i in range(NB_SAT):
        for j in range(i + 1, NB_SAT):
            if mat_court_chemin[i][j] is not None:
                path_lengths.append(mat_longueur_chemin[i][j])
    
    if path_lengths:
        plt.figure()
        plt.hist(path_lengths, bins=20)
        plt.xlabel("Coût du chemin (somme des distances au carré)")
        plt.ylabel("Fréquence")
        plt.title(f"Distribution des plus courts chemins (valués) ({name} - {portee / 1000}km)")
        #DÉCOMMENTER POUR ENREGISTRER LE GRAPHE
        # plt.savefig(f"img/{name}_{portee / 1000}_shortest_distrib_VALUED.png".replace(" ", "_"),
        #         dpi=300,
        #         bbox_inches='tight') #sauvegarde le graphe en png
        plt.show()


    # Nombre des plus courts chemins
    nb_chemins = len(path_lengths)
    print(f"Nombre de plus courts chemins: {nb_chemins}\n")