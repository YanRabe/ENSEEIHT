using LinearAlgebra
"""
Approximation de la solution du problème 

    min qₖ(s) = s'gₖ + 1/2 s' Hₖ s

        sous les contraintes s = -t gₖ, t > 0, ‖s‖ ≤ Δₖ

# Syntaxe

    s = cauchy(g, H, Δ; kwargs...)

# Entrées

    - g : (Vector{<:Real}) le vecteur gₖ
    - H : (Union{Matrix{<:Real}, UniformScaling{Bool}}) la matrice Hₖ
    - Δ : (Real) le scalaire Δₖ
    - kwargs  : les options sous formes d'arguments "keywords", c'est-à-dire des arguments nommés
        • tol_abs  : la tolérence absolue (optionnel, par défaut 1e-10)

# Sorties

    - s : (Vector{<:Real}) la solution du problème

# Exemple d'appel

    g = [0; 0]
    H = [7 0 ; 0 2]
    Δ = 1
    s = cauchy(g, H, Δ)

"""
function cauchy(g::Vector{<:Real}, H::Union{Matrix{<:Real}, UniformScaling{Bool}}, Δ::Real;
    tol_abs::Real = 1e-10)
    
    a = transpose(g) * H * g
    b = norm(g)^2 
    t_max = Δ / norm(g)

    s = zeros(eltype(g), length(g))

    if b == 0 ||norm(g) <=tol_abs
        return s
    end

    if a > 0
        t = b / a
        if norm(t) >= t_max
            t = t_max
        end
    else
        t = t_max
    end
    s = -t * g
    return s
end