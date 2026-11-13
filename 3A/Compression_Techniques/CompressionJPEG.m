
% TP CoCodages JPEG et MPEG-2 - 3SN-M - 2022

%--------------------------------------------------------------------------
% Fonction de compression JPEG d'une image
%--------------------------------------------------------------------------
% [I_Codee,Poids,Compression,nb_coeffs_AC,nb_coeffs_DC] =
%                        CompressionJPEG(I_Origine,canal,methode,F_Qualite)
%
% sorties : I_Codee = image de DCT quantifiee
%           Poids = poids de l'image d'origine en ko pour les differentes
%                   etapes de la compression
%           Compression = taux de compression final
%           nb_coeffs_AC = nombre de coefficients AC dans l'image compressee
%           nb_coeffs_DC = nombre de coefficients DC dans l'image compressee
%
% entrees : I_Origine = image originale (ou residuelle)
%           canal = canal pour le choix de la table de quantification :
%                   'Luminance', 'Chrominance' ou 'Residu'
%           methode = methode de calcul de la DCT : 'Matlab' ou 'Rapide'
%           F_Qualite = facteur de qualite pour la compression
%--------------------------------------------------------------------------
% Fonctions a coder/utiliser : DCT2DParBlocs.m
%                              QuantificationDCT.m
%                              CodageEntropique.m
%                              CoefficientsACDC.m
%--------------------------------------------------------------------------

function [I_Codee,Poids,Compression,nb_coeffs_AC,nb_coeffs_DC] = CompressionJPEG(I_Origine,canal,methode,F_Qualite)
taille_bloc = 8;
sens = 'Direct';

Poids.Origine = numel(I_Origine) / 1024;

I_DCT = DCT2DParBlocs(sens, I_Origine, methode, taille_bloc);
I_Codee = QuantificationDCT(sens, I_DCT, canal, F_Qualite, taille_bloc);

[Coeff_AC, Coeff_DC] = CoefficientsACDC(I_Codee, taille_bloc);
nb_coeffs_AC = length(Coeff_AC);
nb_coeffs_DC = length(Coeff_DC);

[Poids.AC, ~] = CodageEntropique(Coeff_AC);
[Poids.DC, ~] = CodageEntropique(Coeff_DC);

Poids.H_JPEG = Poids.AC + Poids.DC;
Compression = (1 - Poids.H_JPEG / Poids.Origine) * 100;
end

%--------------------------------------------------------------------------
% Fonction de recuperation des coefficients AC/DC de la DCT par blocs
%--------------------------------------------------------------------------
%[Coeff_AC_Image, Coeff_DC_Image] = CoefficientsACDC(I_Quant, taille_bloc)
%
% sortie : Coeff_AC = vecteur reunissant tous les coefficients AC de
%                     l'image jusqu'au dernier coefficient non nul
%                     (taille variable)
%          Coeff_DC = vecteur reunissant tous les coefficients DC de
%                     l'image (taille fixe)
%
% entree : I_Quant = Image de DCT quantifiee
%          taille_bloc = taille des blocs pour la DCT (ici 8x8)
%--------------------------------------------------------------------------
function [Coeff_AC, Coeff_DC] = CoefficientsACDC(I_Quant, taille_bloc)
[height, width] = size(I_Quant);
Coeff_AC = [];
Coeff_DC = [];

for i= 1:taille_bloc:height
    for j = 1:taille_bloc:width
        bloc = I_Quant(i:i+taille_bloc-1, j:j+taille_bloc-1);
        zig_i = ParcoursBlocZigzag(bloc, taille_bloc^2);

        Coeff_DC(end+1) = zig_i(1);

        coeff_ac = zig_i(2:end);
        non_nul = find(coeff_ac ~= 0, 1, 'last');

        if isempty(non_nul)
            Coeff_AC(end+1) = 1000;
        else
            Coeff_AC = [Coeff_AC coeff_ac(1:non_nul)];

            Coeff_AC(end+1) = 1000;
        end
    end
end
end

%--------------------------------------------------------------------------
% Fonction de parcours d'un bloc en zigzag pour recuperer les coefficients
% AC/DC de la DCT
%--------------------------------------------------------------------------
% Vecteur_zigzag = ParcoursBlocZigzag(Bloc_DCT,nb_pixels)
%
% sortie : Vecteur_zigzag = vecteur des coefficients DC/AC ordonnes du bloc
%
% entrée : Bloc_DCT = DCT du bloc courant
%          nb_pixels = nombre de pixels dans le bloc
%--------------------------------------------------------------------------
function Vecteur_zigzag = ParcoursBlocZigzag(Bloc_DCT,nb_pixels)
% Initialisation du vecteur qui contiendra les coefficients
Vecteur_zigzag = zeros(1,nb_pixels);
% Remplissage en partant du debut et de la fin
for k = 1:nb_pixels/2
    n = ceil(sqrt(2*k+1/4)-0.5);
    temp = k - n*(n-1)/2;
    if (mod(n,2) < 1)
        i = temp;
    else
        i = n + 1 - temp;
    end
    j = n + 1 - i;
    % Positionnement des coefficients dans le vecteur
    Vecteur_zigzag(k) = Bloc_DCT(i,j);
    Vecteur_zigzag(65-k) = Bloc_DCT(9-j,9-i);
end
end




