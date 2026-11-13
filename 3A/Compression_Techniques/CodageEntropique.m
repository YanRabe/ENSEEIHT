
% TP Codages JPEG et MPEG-2 - 3SN-M - 2022
                                                                                      
%--------------------------------------------------------------------------
% Fonction de calcul d'entropie binaire
%--------------------------------------------------------------------------
% [poids, H] = CodageEntropique(V_coeff)
%
% sorties : poids = poids du vecteur de donnees encode (en ko)
%           H = entropie de la matrice (en bits/pixel)
% 
% entree  : V_coeff = vecteur contenant les symboles dont on souhaite 
%                     calculer l'entropie (ex : l'image vectorisee)
%--------------------------------------------------------------------------

function [poids, H] = CodageEntropique(V_coeff)
n = numel(V_coeff);
m = size(V_coeff, 2);
toKo = 8 * 1024;
[~, ~, indices] = unique(V_coeff);
f = accumarray(indices, 1) / n;
f = f(f > 0);

H = -sum(f .* log2(f));
poids = H * n  / toKo;
end
