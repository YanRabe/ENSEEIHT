using LinearAlgebra
"""
Approximation d'une solution du problème min f(x), x ∈ Rⁿ, en utilisant l'algorithme de Newton.

# Syntaxe

   x_sol, f_sol, flag, nb_iters, xs = newton(f, ∇f, ∇²f, x0; kwargs...)

# Entrées

   - f       : (Function) la fonction à minimiser
   - ∇f   : (Function) le gradient de la fonction f
   - ∇²f   : (Function) la Hessienne de la fonction f
   - x0      : (Union{Real,Vector{<:Real}}) itéré initial
   - kwargs  : les options sous formes d'arguments "keywords"
      • max_iter : (Int) le nombre maximal d'iterations (optionnel, par défaut 1000)
      • tol_abs  : (Real) la tolérence absolue (optionnel, par défaut 1e-10)
      • tol_rel  : (Real) la tolérence relative (optionnel, par défaut 1e-8)
      • δ        : (Real) pour considérer ou non les tests de stagnation (optionnel, par défaut 1)

# Sorties

   - x_sol : (Union{Real,Vector{<:Real}}) une approximation de la solution du problème
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
   x_sol, f_sol, flag, nb_iters, xs = newton(f, ∇f, ∇²f, x0, max_iter=10)

"""
function newton(f::Function, ∇f::Function, ∇²f::Function, x0::Union{Real,Vector{<:Real}};
   max_iter::Int=1000,
   tol_abs::Real=1e-10,
   tol_rel::Real=1e-8,
   δ::Real=1)

   x_sol = x0
   f_sol = f(x_sol)
   flag = -1
   xs = [Float64.(x0)] # vous pouvez faire push!(xs, xk) pour créer le vecteur des itérés (xs isa Vector{Vector{Float64}})

   global nb_iters = 0
   if norm(∇f(x_sol)) <= max(tol_rel * norm(∇f(x0)), tol_abs)
      flag = 0
   end
   while flag == -1
      dk = ∇²f(x_sol) \ -∇f(x_sol)
      x_sol += dk
      push!(xs, x_sol)
      nb_iters += 1
      f_sol = f(x_sol)

      flag = condArret(f, ∇f, tol_rel, tol_abs, max_iter, δ, x_sol, dk, x0)
   end
   return x_sol, f_sol, flag, nb_iters, xs

end

function condArret(f::Function, ∇f::Function, tol_rel::Real, tol_abs::Real, max_iter::Int, δ::Real, x_sol::Union{Real,Vector{<:Real}}, dk::Union{Real,Vector{<:Real}}, x0::Union{Real,Vector{<:Real}})
   flag = -1
   if norm(∇f(x_sol)) <= max(tol_rel * norm(∇f(x0)), tol_abs)
      flag = 0
   elseif norm(dk) <= δ * max(tol_rel * norm(x_sol - dk), tol_abs)
      flag = 1
   elseif abs(f(x_sol) - f(x_sol-dk)) <= δ * max(tol_rel * abs(f(x_sol-dk)), tol_abs)
      flag = 2
   elseif nb_iters >= max_iter
      flag = 3
   end
   return flag
end