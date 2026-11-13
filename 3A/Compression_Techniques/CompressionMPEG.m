
% TP Codages JPEG et MPEG-2 - 3SN-M - 2022

%--------------------------------------------------------------------------
% Fonction d'encodage MPEG d'une image (+ reference en JPEG)
%--------------------------------------------------------------------------
% [IRes_Codee,MVdr,Ir_Codee,Poids,Compression] = ...
%        CompressionMPEG(Ic_Originale,Ir_Originale,canal,methode,F_Qualite)
%
% sorties : IRes_Codee = image residuelle (DCT quantifiee)
%           MVdr = matrice des vecteurs de deplacements relatifs
%           Ir_Codee = image de reference (DCT quantifiee)
%           Poids = poids de l'image en ko pour les differentes etapes de 
%                   la compression (inclure les mouvements pour MPEG)
%           Compression = taux de compression final
% 
% entrees : Ic_Originale = image courante originale
%           Ir_Originale = image de reference originale
%           canal = canal pour le choix de la table de quantification :
%                   'Luminance', 'Chrominance' ou 'Residu'
%           methode = methode de calcul de la DCT : 'Matlab' ou 'Rapide'
%           F_Qualite = facteur de qualite pour la compression
%--------------------------------------------------------------------------
% Fonctions a coder/utiliser : EstimationMouvement.m
%                              PredictionImage.m
%                              CompressionJPEG.m
%--------------------------------------------------------------------------

function [IRes_Codee,MVdr,Ir_Codee,Poids,Compression] = CompressionMPEG(Ic_Originale,Ir_Originale,canal,methode,F_Qualite)

    % Cartes mouv
    MVdr = EstimationMouvement(Ic_Originale, Ir_Originale);

    % pred image courante
    Ip = PredictionImage(Ir_Originale, MVdr);

    % Image residuelle
    IRes = Ic_Originale - Ip;
    
    % Compression JPEG de l'image de ref
    [Ir_Codee, ~, ~, ~, ~] = CompressionJPEG(Ir_Originale, canal, methode, F_Qualite);

    % Compression JPEG de l'image residuelle
    [IRes_Codee, Poids, ~, ~, ~] = CompressionJPEG(IRes, 'Residu', methode, F_Qualite);

    % Codage entropique des mouvements
    [Poids.MVdr, ~] = CodageEntropique(MVdr(:));

    % Poids
    Poids.Origine = numel(Ic_Originale) / 1024;
    Poids.H_MPEG  = Poids.H_JPEG + Poids.MVdr;

    % Taux de compression
    Compression = (1 - Poids.H_MPEG / Poids.Origine) * 100;
end
