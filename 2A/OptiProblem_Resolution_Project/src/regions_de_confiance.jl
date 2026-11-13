using LinearAlgebra
include("../src/cauchy.jl")
include("../src/gct.jl")
"""
Approximation de la solution du problème min f(x), x ∈ Rⁿ.

L'algorithme des régions de confiance résout à chaque itération, un modèle quadratique
de la fonction f dans une boule (appelée la région de confiance) de centre l'itéré 
courant. Cette minimisation se fait soit par un pas de Cauchy ou par l'algorithme 
du gradient conjugué tronqué.

# Syntaxe

    x_sol, f_sol, flag, nb_iters, xs = regions_de_confiance(f, ∇f, ∇²f, x0; kwargs...)

# Entrées

    - f       : (Function) la fonction à minimiser
    - ∇f   : (Function) le gradient de la fonction f
    - ∇²f   : (Function) la hessienne de la fonction f
    - x0      : (Vector{<:Real}) itéré initial
    - kwargs  : les options sous formes d'arguments "keywords"
        • max_iter      : (Int) le nombre maximal d'iterations (optionnel, par défaut 5000)
        • tol_abs       : (Real) la tolérence absolue (optionnel, par défaut 1e-10)
        • tol_rel       : (Real) la tolérence relative (optionnel, par défaut 1e-8)
        • δ             : (Real) pour considérer ou non les tests de stagnation (optionnel, par défaut 1)
        • Δ0            : (Real) le rayon initial de la région de confiance (optionnel, par défaut 2)
        • Δmax          : (Real) le rayon maximal de la région de confiance (optionnel, par défaut 10)
        • γ1, γ2        : (Real) les facteurs de mise à jour de la région de confiance (optionnel, par défaut 0.5 et 2)
        • η1, η2        : (Real) les seuils pour la mise à jour de la région de confiance (optionnel, par défaut 0.25 et 0.75)
        • algo_pas      : (String) l'algorithme de calcul du pas - "cauchy" ou "gct" (optionnel, par défaut "gct")
        • max_iter_gct  : (Int) le nombre maximal d'iterations du GCT (optionnel, par défaut 2*length(x0))

# Sorties

    - x_sol : (Vector{<:Real}) une approximation de la solution du problème
    - f_sol : (Real) f(x_sol)
    - flag  : (Int) indique le critère sur lequel le programme s'est arrêté
        • 0  : convergence
        • 1  : stagnation du xk
        • 2  : stagnation du f
        • 3  : nombre maximal d'itération dépassé
    - nb_iters : (Int) le nombre d'itérations faites par le programme
    - xs    : (Vector{Vector{<:Real}}) les itérés

# Exemple d'appel

    f(x)=100*(x[2]-x[1]^2)^2+(1-x[1])^2
    ∇f(x)=[-400*x[1]*(x[2]-x[1]^2)-2*(1-x[1]) ; 200*(x[2]-x[1]^2)]
    ∇²f(x)=[-400*(x[2]-3*x[1]^2)+2  -400*x[1];-400*x[1]  200]
    x0 = [1; 0]
    x_sol, f_sol, flag, nb_iters, xs = regions_de_confiance(f, ∇f, ∇²f, x0, algo_pas="gct")

"""
function regions_de_confiance(f::Function, ∇f::Function, ∇²f::Function, x0::Vector{<:Real};
    max_iter::Int=5000, tol_abs::Real=1e-10, tol_rel::Real=1e-8, δ::Real=1,
    Δ0::Real=2, Δmax::Real=10, γ1::Real=0.5, γ2::Real=2, η1::Real=0.25, η2::Real=0.75, algo_pas::String="gct",
    max_iter_gct::Int=2 * length(x0))

    x_sol = x0
    f_sol = f(x_sol)
    flag = -1
    xs = [Float64.(x0)] # vous pouvez faire push!(xs, xk) pour créer le vecteur des itérés (xs isa Vector{Vector{Float64}})

    nb_iters = 0
    Δk = Δ0

    if norm(∇f(x_sol)) <= max(tol_rel * norm(∇f(x0)), tol_abs)
        flag = 0
    end

    while flag == -1
        gk = ∇f(x_sol)
        hk = ∇²f(x_sol)

        if algo_pas == "cauchy"
            sk = cauchy(gk, hk, Δk, tol_abs=tol_abs)
        else
            sk = gct(gk, hk, Δk, max_iter=max_iter_gct)
        end

        mk0 = f(x_sol)
        mksk = f(x_sol) + transpose(gk) * sk + 0.5 * transpose(sk) * hk * sk
        ρk = (f(x_sol) - f(x_sol + sk)) / (mk0 - mksk)

        xk_prev = x_sol
        if ρk >= η1
            x_sol = x_sol + sk
            f_sol = f(x_sol)
        end
        push!(xs, x_sol)

        if ρk >= η2
            Δk = min(γ2 * Δk, Δmax)
        elseif ρk >= η1
            # Δk reste inchangé
        else
            Δk = γ1 * Δk
        end

        nb_iters += 1

        flag = condArret(f, ∇f, tol_rel, tol_abs, max_iter, δ, x_sol, x_sol - xk_prev, x0, nb_iters)

        if ρk < η1 && flag != 0 && flag != 3
            flag = -1
        end
    end

    return x_sol, f_sol, flag, nb_iters, xs
end

function condArret(f::Function, ∇f::Function, tol_rel::Real, tol_abs::Real, max_iter::Int, δ::Real, x_sol::Vector{<:Real}, dk::Vector{<:Real}, x0::Vector{<:Real}, nb_iters::Int)
    flag = -1
    if norm(∇f(x_sol)) <= max(tol_rel * norm(∇f(x0)), tol_abs)
        flag = 0
    elseif norm(dk) <= δ * max(tol_rel * norm(x_sol - dk), tol_abs)
        flag = 1
    elseif abs(f(x_sol) - f(x_sol - dk)) <= δ * max(tol_rel * abs(f(x_sol - dk)), tol_abs)
        flag = 2
    elseif nb_iters >= max_iter
        flag = 3
    end
    return flag
end
