
% TP Codages JPEG et MPEG-2 - 3SN-M - 2022
                                               
%--------------------------------------------------------------------------
% Fonction de transformee (directe et inverse) en cosinus discrete par blocs
%--------------------------------------------------------------------------
% I_DCT = DCT2DParBlocs(sens,I,methode,taille_bloc)
%
% sortie  : I_DCT = image de la DCT ou IDCT par blocs
% 
% entrees : sens = sens pour la DCT : 'Direct' ou 'Inverse'
%           I = image avant DCT ou IDCT par blocs
%           methode = methode de calcul de la DCT : 'Matlab' ou 'Rapide'
%           taille_bloc = taille des blocs pour la DCT (ici 8x8)
%--------------------------------------------------------------------------

function I_DCT = DCT2DParBlocs(sens,I,methode,taille_bloc)
    [height, width] = size(I);
    I_DCT = zeros(size(I));
    for i= 1:taille_bloc:height
        for j = 1:taille_bloc:width
            bloc = I(i:i+taille_bloc-1, j:j+taille_bloc-1);
            if strcmpi(methode, 'Matlab')
                if strcmpi(sens, 'Direct')
                    bloc_transforme = dct2(bloc);
    
                elseif strcmpi(sens, 'Inverse')
                    bloc_transforme = idct2(bloc);
                end
            else
                error('Pas la foi dsl.');
            end
    
            % Remise du bloc transforme dans l image finale
            I_DCT(i:i+taille_bloc-1, j:j+taille_bloc-1) = bloc_transforme;
        end
    end
end
  
%--------------------------------------------------------------------------
% Fonction de calcul de transformee en cosinus discrete rapide 
% pour un bloc de taille 8x8
%--------------------------------------------------------------------------
% Bloc_DCT2 = DCT2Rapide(Bloc_Origine, taille_bloc)
%
% sortie  : Bloc_DCT2 = DCT du bloc
% 
% entrees : Bloc_Origine = Bloc d'origine
%           taille_bloc = taille des blocs pour la DCT (ici 8x8)
%--------------------------------------------------------------------------
function Bloc_DCT2 = DCT2Rapide(Bloc_Origine,taille_bloc)
    


end

%--------------------------------------------------------------------------
% Fonction de calcul de transformee en cosinus discrete inverse rapide
% pour un bloc de taille 8x8
%--------------------------------------------------------------------------
% Bloc_IDCT2 = IDCT2Rapide(Bloc_DCT2,taille_bloc)
%
% sortie  : Bloc_IDCT2 = Bloc reconstruit par DCT inverse
% 
% entrees : Bloc_DCT2 = DCT du bloc 
%           taille_bloc = taille des blocs pour la DCT (ici 8x8)
%--------------------------------------------------------------------------

function Bloc_IDCT2 = IDCT2Rapide(Bloc_DCT2,taille_bloc)
    


end