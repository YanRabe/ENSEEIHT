using LinearAlgebra
include("../src/newton.jl")
include("../src/regions_de_confiance.jl")
"""

Approximation d'une solution au problème 

    min f(x), x ∈ Rⁿ, sous la contrainte c(x) = 0,

par l'algorithme du lagrangien augmenté.

# Syntaxe

    x_sol, f_sol, flag, nb_iters, μs, λs = lagrangien_augmente(f, ∇f, ∇²f, c, ∇c, ∇²c, x0; kwargs...)

# Entrées

    - f      : (Function) la fonction à minimiser
    - ∇f     : (Function) le gradient de f
    - ∇²f    : (Function) la hessienne de f
    - c      : (Function) la contrainte à valeur dans R
    - ∇c     : (Function) le gradient de c
    - ∇²c    : (Function) la hessienne de c
    - x0     : (Vector{<:Real}) itéré initial
    - kwargs : les options sous formes d'arguments "keywords"
        • max_iter  : (Int) le nombre maximal d'iterations (optionnel, par défaut 1000)
        • tol_abs   : (Real) la tolérence absolue (optionnel, par défaut 1e-10)
        • tol_rel   : (Real) la tolérence relative (optionnel, par défaut 1e-8)
        • λ0        : (Real) le multiplicateur de lagrange associé à c initial (optionnel, par défaut 2)
        • μ0        : (Real) le facteur initial de pénalité de la contrainte (optionnel, par défaut 10)
        • τ         : (Real) le facteur d'accroissement de μ (optionnel, par défaut 2)
        • algo_noc  : (String) l'algorithme sans contrainte à utiliser (optionnel, par défaut "rc-gct")
            * "newton"    : pour l'algorithme de Newton
            * "rc-cauchy" : pour les régions de confiance avec pas de Cauchy
            * "rc-gct"    : pour les régions de confiance avec gradient conjugué tronqué

# Sorties

    - x_sol    : (Vector{<:Real}) une approximation de la solution du problème
    - f_sol    : (Real) f(x_sol)
    - flag     : (Int) indique le critère sur lequel le programme s'est arrêté
        • 0 : convergence
        • 1 : nombre maximal d'itération dépassé
    - nb_iters : (Int) le nombre d'itérations faites par le programme
    - μs       : (Vector{<:Real}) tableau des valeurs prises par μk au cours de l'exécution
    - λs       : (Vector{<:Real}) tableau des valeurs prises par λk au cours de l'exécution

# Exemple d'appel

    f(x)=100*(x[2]-x[1]^2)^2+(1-x[1])^2
    ∇f(x)=[-400*x[1]*(x[2]-x[1]^2)-2*(1-x[1]) ; 200*(x[2]-x[1]^2)]
    ∇²f(x)=[-400*(x[2]-3*x[1]^2)+2  -400*x[1];-400*x[1]  200]
    c(x) =  x[1]^2 + x[2]^2 - 1.5
    ∇c(x) = 2*x
    ∇²c(x) = [2 0; 0 2]
    x0 = [1; 0]
    x_sol, _ = lagrangien_augmente(f, ∇f, ∇²f, c, ∇c, ∇²c, x0, algo_noc="rc-gct")

"""
function lagrangien_augmente(f::Function, ∇f::Function, ∇²f::Function, 
        c::Function, ∇c::Function, ∇²c::Function, x0::Vector{<:Real}; 
        max_iter::Int=1000, tol_abs::Real=1e-10, tol_rel::Real=1e-8,
        λ0::Real=2, μ0::Real=10, τ::Real=2, algo_noc::String="rc-gct")

    x_sol = x0
    f_sol = f(x_sol)
    flag = -1
    nb_iters = 0
    μs = [Float64(μ0)]
    λs = [Float64(λ0)]

    β = 0.9
    η_chapeau = 0.1258925
    α = 0.1
    ε0 = 1 / μ0
    εk = ε0
    ηk = η_chapeau / μ0^α
    μk = Float64(μ0)
    λk = Float64(λ0)

    Lμ(x) = f(x) + λk * c(x) + (μk / 2) * c(x)^2
    ∇Lμ(x) = ∇f(x) + λk * ∇c(x) + μk * c(x) * ∇c(x)
    ∇²Lμ(x) = ∇²f(x) + λk * ∇²c(x) + μk * (∇c(x) * transpose(∇c(x)) + c(x) * ∇²c(x))

    ∇L0 = ∇f(x0) + λk * ∇c(x0)
    
    while flag == -1
        # Mise à jour des fonctions avec les valeurs courantes de λk et μk
        Lμ(x) = f(x) + λk * c(x) + (μk / 2) * c(x)^2
        ∇Lμ(x) = ∇f(x) + λk * ∇c(x) + μk * c(x) * ∇c(x)
        ∇²Lμ(x) = ∇²f(x) + λk * ∇²c(x) + μk * (∇c(x) * transpose(∇c(x)) + c(x) * ∇²c(x))

        # Résolution du sous-problème sans contrainte
        if algo_noc == "newton"
            x_sol, _, _, _, _ = newton(Lμ, ∇Lμ, ∇²Lμ, x_sol, tol_abs=εk, tol_rel=0.0)
        elseif algo_noc == "rc-cauchy"
            x_sol, _, _, _, _ = regions_de_confiance(Lμ, ∇Lμ, ∇²Lμ, x_sol, algo_pas="cauchy", tol_abs=εk, tol_rel=0.0)
        else  # rc-gct par défaut
            x_sol, _, _, _, _ = regions_de_confiance(Lμ, ∇Lμ, ∇²Lμ, x_sol, algo_pas="gct", tol_abs=εk, tol_rel=0.0)
        end

        if norm(c(x_sol)) <= ηk
            λk = λk + μk * c(x_sol)
            εk = εk / μk
            ηk = ηk / μk^β
        else
            μk = τ * μk
            εk = ε0 / μk
            ηk = η_chapeau / μk^α
        end

        f_sol = f(x_sol)
        nb_iters += 1
        push!(μs, μk)
        push!(λs, λk)

        ∇L_sol = ∇f(x_sol) + λk * ∇c(x_sol)
        if norm(∇L_sol) <= max(tol_rel * norm(∇L0), tol_abs) && norm(c(x_sol)) <= max(tol_rel * norm(c(x0)), tol_abs)
            flag = 0
        elseif nb_iters >= max_iter
            flag = 1
        end
    end

    return x_sol, f_sol, flag, nb_iters, μs, λs
end