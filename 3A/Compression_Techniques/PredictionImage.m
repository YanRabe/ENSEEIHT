
% TP Codages JPEG et MPEG-2 - 3SN-M - 2022

%--------------------------------------------------------------------------
% Prediction de l'image courante avec l'image de reference et le mouvement
%--------------------------------------------------------------------------
% Ip = PredictionImage(Ir,MVr)
%
% sortie  : Ip = image predictive
%           
% entrees : Ir = image de reference
%           MVr = matrice des vecteurs de déplacements relatifs
%--------------------------------------------------------------------------

function Ip = PredictionImage(Ir,MVr)
        k = 16;
        [n, m] = size(Ir);
        Ip = zeros(size(Ir), 'like', Ir);

        for i = 1:k:n
            for j = 1:k:m
                l_bloc = ceil(i / k);
                col_bloc = ceil(j / k);

                lignes = i:min(i + k - 1, n);
                cols = j:min(j + k - 1, m);

                dx = MVr(l_bloc, col_bloc, 1);
                dy = MVr(l_bloc, col_bloc, 2);

                lignesRef = lignes + dx;
                colsRef = cols + dy;

                lignesRef = min(max(lignesRef, 1), n);
                colsRef = min(max(colsRef, 1), m);

                Ip(lignes, cols) = Ir(lignesRef, colsRef);
            end
        end
end
