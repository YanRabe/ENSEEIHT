% TP Codages JPEG et MPEG-2 - 3SN-M - 2022

%--------------------------------------------------------------------------
% Fonction d'estimation du mouvement par "block-matching"
%--------------------------------------------------------------------------
% MVr = EstimationMouvement(Ic,Ir)
%
% sortie  : MVdr = matrice des vecteurs de dx relatifs
% 
% entrees : Ic = image courante
%           Ir = image de reference
%--------------------------------------------------------------------------

function MVr = EstimationMouvement(Ic,Ir)
    k = 16;
    Ic = double(Ic);
    Ir = double(Ir);
    [n, m] = size(Ic);
    MVr = zeros(ceil(n / k), ceil(m / k), 2);
    for i = 1:k:n
        for j = 1:k:m
            lignes = i:min(i + k - 1, n);
            cols = j:min(j + k - 1, m);
            bloc_courant = Ic(lignes, cols);

            l_bloc = ceil(i / k);
            col_bloc = ceil(j / k);
            mouvement = CSAMacroBloc(bloc_courant, [i; j], Ir);
            MVr(l_bloc, col_bloc, :) = reshape(mouvement, 1, 1, 2);
        end
    end
end

%--------------------------------------------------------------------------
% Fonction de recherche par 'Cross Search Algorithm' :         
%   - Recherche pour un macro-bloc de l'image courante
%--------------------------------------------------------------------------
% Vm = CSAMacroBloc(MBc, Vp, Iref)
%
% sorties : Vm = vecteur de mouvement 
% 
% entrées : Mbc = macro-bloc dans l'image courante Ic
%           Vp = vecteur de prediction (point de depart du MacroBloc)
%           Iref = image de reference (qui sera conservee dans le GOP)
%--------------------------------------------------------------------------

function Vm = CSAMacroBloc(MB_IC, Vp, IRef)
    MB_IC_V = double(MB_IC(:));
    [n, m] = size(IRef);
    Vm = [0; 0];
    directions = {'centre','haut','gauche','droite','bas'};
    dx = [0 -1  0 0 1;
          0  0 -1 1 0];
    mouvement = 0;
    while mouvement ~= 1
        coordx = Vp(1) + Vm(1);
        coordy = Vp(2) + Vm(2);
        EQM = zeros(1, 5);
        for v = 1:5
            EQM(v) = EQMMacrocBlocVoisin(MB_IC_V, IRef, n, m, coordx, coordy, directions{v});
        end
        [~, mouvement] = min(EQM);
        Vm = Vm + dx(:, mouvement);
    end
end

%--------------------------------------------------------------------------
% Fonction de calcul de l'EQM avec differents voisins 
% dans l'image de reference
%--------------------------------------------------------------------------
% EQM = EQMMacrocBlocVoisin(MB_IC_V,IRef,size_x_Ref,size_y_Ref,coordx,coordy,voisin)
%
% sortie  : EQM = erreur quadratique moyenne entre macro-blocs
% 
% entrées : MB_IC_V = macro-bloc dans l'image courante (vectorise)
%           Ir = Image de reference
%           size_x_Ir = nombre de lignes de Ir (pour effets de bords)
%           size_y_Ir = nombre de colonnes de Ir (pour effets de bords)
%           coordx = les 16 coordonnees du bloc suivant x
%           coordy = les 16 coordonnees du bloc suivant y
%           voisin = choix du voisin pour decaler le macro-bloc dans Ir
%                    ('haut', 'gauche', 'centre', 'droite', bas', ...)
%--------------------------------------------------------------------------

function EQM = EQMMacrocBlocVoisin(MB_IC_V,Ir,size_x_Ir,size_y_Ir,coordx,coordy,voisin)
    n = sqrt(size(MB_IC_V, 1));
    switch voisin
        case 'gauche'
            dx = 0;
            dy = -1;  
        case 'haut'
            dx = -1;
            dy = 0;
        case 'droite'
            dx = 0;
            dy = 1;
        case 'bas'
            dx = 1;
            dy = 0;
        otherwise
            dx = 0;
            dy = 0;
    end
    coordx = coordx + (0:n-1);
    coordy = coordy + (0:n-1);

    if min(coordx + dx) < 1 || min(coordy + dy) < 1 || ...
            max(coordx + dx) > size_x_Ir || max(coordy + dy) > size_y_Ir
        EQM = inf;
    else
        MB_IR_decal = Ir(coordx + dx, coordy + dy);
        MB_IR_decal_V = double(MB_IR_decal(:));
        EQM = mean((MB_IR_decal_V - MB_IC_V).^2);
        
    end
end