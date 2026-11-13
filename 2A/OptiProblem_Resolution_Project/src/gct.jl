using LinearAlgebra
"""
Approximation de la solution du problème 

    min qₖ(s) = s'gₖ + 1/2 s' Hₖ s, sous la contrainte ‖s‖ ≤ Δₖ

# Syntaxe

    s = gct(g, H, Δ; kwargs...)

# Entrées

    - g : (Vector{<:Real}) le vecteur gₖ
    - H : (Matrix{<:Real}) la matrice Hₖ
    - Δ : (Real) le scalaire Δₖ
    - kwargs  : les options sous formes d'arguments "keywords", c'est-à-dire des arguments nommés
        • max_iter : le nombre maximal d'iterations (optionnel, par défaut 100)
        • tol_abs  : la tolérence absolue (optionnel, par défaut 1e-10)
        • tol_rel  : la tolérence relative (optionnel, par défaut 1e-8)

# Sorties

    - s : (Vector{<:Real}) une approximation de la solution du problème

# Exemple d'appel

    g = [0; 0]
    H = [7 0 ; 0 2]
    Δ = 1
    s = gct(g, H, Δ, max_iter = 10)

"""
function gct(g::Vector{<:Real}, H::Matrix{<:Real}, Δ::Real; 
    max_iter::Int = 100, 
    tol_abs::Real = 1e-10, 
    tol_rel::Real = 1e-8)

    n = length(g)
    s = zeros(n)
    g_0 = g
    p = -g
    g_j = g
    j = 0
    
    while j < max_iter && norm(g_j) > max(norm(g_0) * tol_rel, tol_abs)
        κ_j = transpose(p) * H * p
        
        if κ_j <= 0
            # racine de ||s_j + σ_j * p_j|| = Δ pour laquelle q(s + σ* p_j) est la plus petite
            a = norm(p)^2
            b = 2 * transpose(s) * p
            c = norm(s)^2 - Δ^2
            discriminant = b^2 - 4 * a * c
            σ_j = (-b + sqrt(discriminant)) / (2 * a)
            return s + σ_j * p
        end
        
        α_j = transpose(g_j) * g_j / κ_j
        
        if norm(s + α_j * p) >= Δ
            # racine positive de ||s_j + σ_j * p_j|| = Δ
            a = norm(p)^2
            b = 2 * transpose(s) * p
            c = norm(s)^2 - Δ^2
            discriminant = b^2 - 4 * a * c
            σ_j = (-b + sqrt(discriminant)) / (2 * a)
            return s + σ_j * p
        end
        
        s = s + α_j * p
        g_j_plus_1 = g_j + α_j * H * p
        β_j = transpose(g_j_plus_1) * g_j_plus_1 / (transpose(g_j) * g_j)
        p = -g_j_plus_1 + β_j * p
        g_j = g_j_plus_1
        j = j + 1
    end
    return s
end