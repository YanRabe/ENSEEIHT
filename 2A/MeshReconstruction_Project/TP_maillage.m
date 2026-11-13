clear;
close all;
% Nombre d'images utilisees
nb_images = 36; 

% chargement des images
for i = 1:nb_images
    if i<=10
        nom = sprintf('images/viff.00%d.ppm',i-1);
    else
        nom = sprintf('images/viff.0%d.ppm',i-1);
    end
    % im est une matrice de dimension 4 qui contient 
    % l'ensemble des images couleur de taille : nb_lignes x nb_colonnes x nb_canaux 
    % im est donc de dimension nb_lignes x nb_colonnes x nb_canaux x nb_images
    im(:,:,:,i) = imread(nom); 
end

% Affichage des images
figure; 
subplot(2,2,1); imshow(im(:,:,:,1)); title('Image 1');
subplot(2,2,2); imshow(im(:,:,:,9)); title('Image 9');
subplot(2,2,3); imshow(im(:,:,:,17)); title('Image 17');
subplot(2,2,4); imshow(im(:,:,:,25)); title('Image 25');
drawnow;

% ........................................................%
fichier_sauvegarde = 'mask.mat';

[lines,col,~] = size(im(:,:,:,1));
nb_pix = lines * col;

if isfile(fichier_sauvegarde)
    load(fichier_sauvegarde, 'im_mask');
else  
    % Paramètres
    K = 200; % nombre de superpixels
    m = 30;  % compacité

    esp = sqrt(nb_pix/K); % espacement des germes

    im_mask = zeros(lines, col, nb_images);

%Première image
img = double(im(:,:,:,1));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 1. PARTIE SUPERPIXELS (Calcul)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Initialisation des centres
    centers = [];
    for x = esp/2:esp:col
        for y = esp/2:esp:lines
            centers = [centers; [round(y), round(x), img(round(y),round(x),1), img(round(y),round(x),2), img(round(y),round(x),3)]];
        end
    end

    nb_centres = size(centers,1);
    disp(nb_centres);
    labels = -ones(lines,col);

    % ITERATIONS
    for iter = 1:5
        distances = inf(lines,col);
        % Affectation
        for k = 1:nb_centres
            yc = centers(k,1);
            xc = centers(k,2);
            color = centers(k,3:5);
            
            % voisinage local
            for y = max(1,round(yc-esp)):min(lines,round(yc+esp))
                for x = max(1,round(xc-esp)):min(col,round(xc+esp))
                    
                    dc = norm(double(squeeze(img(y,x,:))') - color); % distance couleur
                    ds = norm([y x] - [yc xc]); % distance spatiale

                    D = sqrt(dc^2 + (m/esp)^2*ds^2); % combinaison pondérée
                    
                    if D < distances(y,x)
                        distances(y,x) = D;
                        labels(y,x) = k;
                    end
                end
            end
        end
        
        % Mise à jour des centres
        for k = 1:nb_centres
            [yk,xk] = find(labels==k);
            if ~isempty(yk)
                centers(k,1) = mean(yk);
                centers(k,2) = mean(xk);
                for c=1:3
                    centers(k,2+c) = mean(img(sub2ind([lines,col],yk,xk)+(c-1)*lines*col));
                end
            end
        end
        labels(labels==-1) = 0;
        % Calcul des contours
        edges = computeBoundaries(labels);
        
        figure(100);
        clf;
        imshow(uint8(img)); hold on;
        
        % Contours en rouge
        [y_edge,x_edge] = find(edges==1);
        plot(x_edge,y_edge,'r.','MarkerSize',1);
        
        % Centres en vert
        plot(centers(:,2), centers(:,1), 'g+','LineWidth',2);
        
        title(['Image 1 - Iteration ', num2str(iter)]);
        drawnow;
    end
    
    %pour chaque image après
    for i = 2:nb_images 
        img = double(im(:,:,:,i));
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 1. PARTIE SUPERPIXELS (Calcul)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Initialisation des centres
        centers = zeros(nb_centres, 5); % maintenant on initialise avec une taille fixe (on gagne du temps d'exec)
        k = 0;
        for x = esp/2:esp:col
            for y = esp/2:esp:lines
                k = k + 1;
                centers(k,:) = [round(y), round(x), img(round(y),round(x),1), img(round(y),round(x),2), img(round(y),round(x),3)];
            end
        end

        nb_centres = size(centers,1);
        disp(nb_centres);
        labels = -ones(lines,col);

        % ITERATIONS
        for iter = 1:5
            distances = inf(lines,col);
            % Affectation
            for k = 1:nb_centres
                yc = centers(k,1);
                xc = centers(k,2);
                color = centers(k,3:5);
                
                % voisinage local
                for y = max(1,round(yc-esp)):min(lines,round(yc+esp))
                    for x = max(1,round(xc-esp)):min(col,round(xc+esp))
                        
                        dc = norm(double(squeeze(img(y,x,:))') - color); % distance couleur
                        ds = norm([y x] - [yc xc]); % distance spatiale

                        D = sqrt(dc^2 + (m/esp)^2*ds^2); % combinaison pondérée
                        
                        if D < distances(y,x)
                            distances(y,x) = D;
                            labels(y,x) = k;
                        end
                    end
                end
            end
            
            % Mise à jour des centres
            for k = 1:nb_centres
                [yk,xk] = find(labels==k);
                if ~isempty(yk)
                    centers(k,1) = mean(yk);
                    centers(k,2) = mean(xk);
                    for c=1:3
                        centers(k,2+c) = mean(img(sub2ind([lines,col],yk,xk)+(c-1)*lines*col));
                    end
                end
            end
            labels(labels==-1) = 0;
            % Affichage à chaque itération pour l'image 1
            if i == 1
                % Calcul des contours
                edges = computeBoundaries(labels);
                
                figure(100);
                clf;
                imshow(uint8(img)); hold on;
                
                % Contours en rouge
                [y_edge,x_edge] = find(edges==1);
                plot(x_edge,y_edge,'r.','MarkerSize',1);
                
                % Centres en vert
                plot(centers(:,2), centers(:,1), 'g+','LineWidth',2);
                
                title(['Image 1 - Iteration ', num2str(iter)]);
                drawnow;
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 2. PARTIE BINARISATION (à partir des superpixels)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        mask_courant = zeros(lines,col);

        for k = 1:size(centers,1)

            color = centers(k,3:5);

            % Fond en bleu
            if color(3) > color(1) && color(3) > color(2)
                value = 0; % fond
            else
                value = 1; % objet
            end

            mask_courant(labels==k) = value;
        end

        % Filtrer les artefacts 
        mask_courant = bwareafilt(logical(mask_courant), 1); 
        mask_courant = imfill(mask_courant, 'holes');
        
        % Enregistrement dans l'ensemble de masks
        im_mask(:,:,i) = mask_courant;
        
    end

    % On save pcq sinon c'est trop long
    save(fichier_sauvegarde, 'im_mask');
end

%affichage du masque 1
mask = im_mask(:,:,1);
figure; imshow(mask); title('Masque binaire');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Estimation de l'axe médian                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ........................................................%

% Recherche d'un point de départ pour bwtraceboundary
[start_y, start_x] = find(mask, 1, 'first');

% Extraction de la frontière
% N pour Nord, c'est la direction initiale de contournement
frontiere = bwtraceboundary(mask, [start_y, start_x], 'N');

% Affichage du résultat
figure; 
imshow(mask); % Affichage du masque nettoyé
hold on;

% frontière en vert.
plot(frontiere(:,2), frontiere(:,1), 'g.', 'LineWidth', 2);
title('frontière estimée');

% Estimation des points du squelette avec delaunay
DT = delaunayTriangulation(frontiere(:,2),frontiere(:,1));
size(DT);

%triplot(DT,contour(:,2),contour(:,1));
C = circumcenter(DT); %centres des cercles circonscrits
C_bis = circumcenter(DT);
hold on

% Estimation topologie du squelette
triangle = DT.ConnectivityList;
TR = triangulation(triangle, DT.Points);
vois = neighbors(TR);   % voisins des triangles : N(i,:)= voisins du triangle i
nb_tri = size(triangle,1);

% filtrer les centres qui sont en dehors de l'image
[taille_C,~] = size(C);
conserve = false(nb_tri,1);

for i=1:nb_tri
    if floor(C(i,1)) >= 1 && floor(C(i,1))<= col && floor(C(i,2)) >= 1 && floor(C(i,2)) <= lines
        if mask(floor(C(i,2)),floor(C(i,1))) == 1
            conserve(i)=true; % si on est dans limage on garde
        end
    end 
end

% Calcul du rayon des cercles circonscrits
rayons = zeros(size(C,1),1);
seuil_rayon = 8;

for i = 1:size(C,1)
    % sommets du triangle i
    pts = DT.Points(triangle(i,:), :);
    % rayon
    rayons(i) = norm(C(i,:) - pts(1,:));
end
conserve = conserve & (rayons > seuil_rayon);

adjacence = zeros(nb_tri);

for i = 1:nb_tri
    for k = 1:3   
        j = vois(i,k);
        if j > 0 && conserve(j)
            adjacence(i,j) = 1;
            adjacence(j,i) = 1;
        end
    end
end
C = C(conserve,:);
adjacence = adjacence(conserve, conserve);
gplot(adjacence,C, 'b-');
plot(C(:,1),C(:,2),'r.', 'MarkerSize', 5);
hold off

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A FAIRE SI VOUS UTILISEZ LES MASQUES BINAIRES FOURNIS   %
% Chargement des masques binaires                         %
% de taille nb_lignes x nb_colonnes x nb_images           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%load mask;
%fprintf('Chargement des donnees termine\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A DECOMMENTER ET COMPLETER                              %
% quand vous aurez les images segmentées                  %
% Affichage des masques associes                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure;
subplot(2,2,1); imshow(im_mask(:,:,1)); title('Masque image 1');
subplot(2,2,2); imshow(im_mask(:,:,9)); title('Masque image 9');
subplot(2,2,3); imshow(im_mask(:,:,17)); title('Masque image 17');
subplot(2,2,4); imshow(im_mask(:,:,25)); title('Masque image 25');

% chargement des points 2D suivis 
% pts de taille nb_points x (2 x nb_images)
% sur chaque ligne de pts 
% tous les appariements possibles pour un point 3D donne
% on affiche les coordonnees (xi,yi) de Pi dans les colonnes 2i-1 et 2i
% tout le reste vaut -1
pts = load('viff.xy');
% Chargement des matrices de projection
% Chaque P{i} contient la matrice de projection associee a l'image i 
% RAPPEL : P{i} est de taille 3 x 4
load dino_Ps;

% Reconstruction des points 3D
X = []; % Contient les coordonnees des points en 3D
color = []; % Contient la couleur associee
% Pour chaque couple de points apparies
for i = 1:size(pts,1)
    % Recuperation des ensembles de points apparies
    l = find(pts(i,1:2:end)~=-1);
    % Verification qu'il existe bien des points apparies dans cette image
    if size(l,2) > 1 & max(l)-min(l) > 1 && max(l)-min(l) < 36
        A = [];
        R = 0;
        G = 0;
        B = 0;
        % Pour chaque point recupere, calcul des coordonnees en 3D
        for j = l
            A = [A;P{j}(1,:)-pts(i,(j-1)*2+1)*P{j}(3,:);
            P{j}(2,:)-pts(i,(j-1)*2+2)*P{j}(3,:)];
            R = R + double(im(int16(pts(i,(j-1)*2+1)),int16(pts(i,(j-1)*2+2)),1,j));
            G = G + double(im(int16(pts(i,(j-1)*2+1)),int16(pts(i,(j-1)*2+2)),2,j));
            B = B + double(im(int16(pts(i,(j-1)*2+1)),int16(pts(i,(j-1)*2+2)),3,j));
        end
        [U,esp,V] = svd(A);
        X = [X V(:,end)/V(end,end)];
        color = [color [R/size(l,2);G/size(l,2);B/size(l,2)]];
    end
end
X = X(1:3,:) ./ X(4,:);
fprintf('Calcul des points 3D termine : %d points trouves. \n',size(X,2));

%affichage du nuage de points 3D
figure;
hold on;
for i = 1:size(X,2)
    plot3(X(1,i),X(2,i),X(3,i),'.','col',color(:,i)/255);
end
axis equal;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A COMPLETER                  %
% Tetraedrisation de Delaunay  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Points = [X(1,:)', X(2,:)', X(3,:)'];
DT = delaunayTriangulation(Points);
T = DT.ConnectivityList;
% A DECOMMENTER POUR AFFICHER LE MAILLAGE
fprintf('Tetraedrisation terminee : %d tetraedres trouves. \n',size(T,1));
% Affichage de la tetraedrisation de Delaunay
figure;
tetramesh(T, Points);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Élimination des tétraèdres superflus 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Définition des poids
poids = [1/4 1/4 1/4 1/4;   % centre
    0.7 0.1 0.1 0.1;   % proche sommet 1
    0.1 0.7 0.1 0.1;   % sommet 2
    0.1 0.1 0.7 0.1;   % sommet 3
    0.1 0.1 0.1 0.7];  % sommet 4

% Initialisation
C_g = zeros(4, size(T,1));

% tétraèdres initiaux
nb_barycentres = size(T, 1);

for i = 1:size(T, 1)
    % Calcul des barycentres differents en fonction des poids differents
    % En commencant par le barycentre avec poids uniformes
    C_g(1:3, i) = poids(1,:) * DT.Points(T(i, :), :);
    C_g(4, i) = 1;
end

% Retrait des tetraedres dont au moins un des barycentres
% ne se trouvent pas dans au moins un des masques des images de travail
% Pour chaque barycentre
to_save = [];

for k = 1:nb_barycentres
    valide = 0;

    for i = 1:nb_images
        % Projection 2D
        o = P{i} * C_g(:, k);
        % On normalise les coord homogènes
        o = o / o(3);
        x = floor(o(1));
        y = floor(o(2));

        if im_mask(x, y, i) == 0
            % Le barycentre est projeté sur le fond
            valide = 1;
            break
        end

    end
    
    % Si valide (à retirer) on skip
    if valide
        continue
    end

    to_save = [to_save k];
end

TBis = T(to_save, :);
nb_barycentres = length(to_save);

fprintf('Retrait des tetraedres exterieurs a la forme 3D termine : %d tetraedres restants. \n', size(T, 1));

figure(8);
tetramesh(TBis, DT.Points);
view(80, -10); 

% Sauvegarde des donnees
save donnees;

%%%%%%%%%%%%%%%%%%%%%%%%
%% Affichage du maillage

% Calcul des faces du maillage à garder
% On recup les faces des tétraèdres
FACES = [sort(TBis(:, [2 3 4]), 2); sort(TBis(:, [1 3 4]), 2); sort(TBis(:, [1 2 4]), 2); sort(TBis(:, [1 2 3]), 2)];
% On met les duplicata côte à côte
FACES = sortrows(FACES);
% face i == face i+1 ?
rep = sum(FACES(1:end - 1, :) == FACES(2:end, :), 2) == 3;
% on efface les doubles de faces
FACES([0; rep] | [rep; 0], :) = [];

fprintf('Calcul du maillage final termine : %d faces. \n', size(FACES, 1));

% Affichage du maillage final
figure(9);
hold on;

for i = 1:size(FACES, 1)
    % on trace les 3 arrêtes de chaque face
    plot3([X(1, FACES(i, 1)) X(1, FACES(i, 2))], [X(2, FACES(i, 1)) X(2, FACES(i, 2))], [X(3, FACES(i, 1)) X(3, FACES(i, 2))], 'r');
    plot3([X(1, FACES(i, 1)) X(1, FACES(i, 3))], [X(2, FACES(i, 1)) X(2, FACES(i, 3))], [X(3, FACES(i, 1)) X(3, FACES(i, 3))], 'r');
    plot3([X(1, FACES(i, 3)) X(1, FACES(i, 2))], [X(2, FACES(i, 3)) X(2, FACES(i, 2))], [X(3, FACES(i, 3)) X(3, FACES(i, 2))], 'r');
end;

view(80, -10);
