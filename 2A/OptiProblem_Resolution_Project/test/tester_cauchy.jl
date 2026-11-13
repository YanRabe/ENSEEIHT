# Ecrire les tests de l'algorithme du pas de Cauchy
using Test
include("../test/fonctions_de_tests.jl")

function tester_cauchy(cauchy::Function)

    # tolérance pour les tests
    tol_abs = 1e-10

    # g = [0; 0]
    H = [7 0 ; 0 2]
    Δ = 1
    # s = cauchy(g, H, Δ)

	Test.@testset "Pas de Cauchy" begin
        Test.@testset "Gradient presque nul: pas nul" begin
            g0 = [1e-12; 1e-12]
            s0 = cauchy(g0, H, Δ, tol_abs=tol_abs)

            @test [0, 0] ≈ s0
        end
        Test.@testset "SPD non saturé: pas dans la région de confiance" begin
            g1 = [6.0; 0]
            s1 = cauchy(g1, H, Δ, tol_abs=tol_abs)

            @test [-6/7; 0.0] ≈ s1
        end
        Test.@testset "SPD saturé: pas ramené sur la frontière" begin
            g2 = [0.5; 1]
            Δ2 = 0.1
            s2 = cauchy(g2, H, Δ2, tol_abs=tol_abs)

            @test [-1/(10*sqrt(5)); -1/(5*sqrt(5))] ≈ s2
        end
        Test.@testset "Hessienne indéfinie avec g'Hg > 0 non saturé" begin
            g3 = [1; 0]
            H3 = [2 0; 0 -1]
            Δ3 = 10.0
            s3 = cauchy(g3, H3, Δ3, tol_abs=tol_abs)

            @test [-0.5; 0.0] ≈ s3 
        end
        Test.@testset "Hessienne indéfinie avec g'Hg > 0 saturé" begin
            # Même cas mais avec petit Δ
            g4 = [1.0; 0.0]
            H4 = [2.0 0.0; 0.0 -1.0]
            Δ4 = 0.25
            s4 = cauchy(g4, H4, Δ4, tol_abs=tol_abs)

            @test [-0.25; 0.0] ≈ s4
            @test norm(s4) ≈ Δ4
        end
        
        Test.@testset "Hessienne avec g'Hg < 0: saturation obligatoire" begin
            # Gradient dans la direction de valeur propre négative
            g5 = [0.0; 1.0]
            H5 = [2.0 0.0; 0.0 -1.0]
            Δ5 = 3.0
            s5 = cauchy(g5, H5, Δ5, tol_abs=tol_abs)
            
            @test [0.0; -3.0] ≈ s5
            @test norm(s5) ≈ Δ5
        end
        
        Test.@testset "Cas dégénéré g'Hg = 0: saturation" begin
            # On veut g'Hg = 0
            g6 = [1.0; 1.0]
            H6 = [1.0 -1.0; -1.0 1.0]
            Δ6 = 2.0
            s6 = cauchy(g6, H6, Δ6, tol_abs=tol_abs)
            
            s_attendu = -(Δ6/norm(g6)) * g6
            @test s_attendu ≈ s6
            @test norm(s6) ≈ Δ6
        end
    end
end