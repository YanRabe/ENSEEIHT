# Numerical Optimisation Project -- ENSEEIHT 2SN Numerical Optimisation course

This repository contains implementations of various numerical optimisation algorithms written in Julia. The project covers methods for both unconstrained optimisation (such as Newton's Method and Trust Regions) and constrained optimisation (such as the Augmented Lagrangian method). 

It was developed as part of a numerical optimisation course and includes test functions, test suites, and interactive Jupyter Notebooks for visualisation and validation.

## Project Structure

- **`src/`**: Contains the core Julia implementations of the optimisation algorithms.
  - `newton.jl`: Newton's method.
  - `regions_de_confiance.jl`: Trust-Region framework.
  - `cauchy.jl`: Cauchy point calculation for trust regions.
  - `gct.jl`: Truncated Conjugate Gradient (Steihaug-Toint) algorithm.
  - `lagrangien_augmente.jl`: Augmented Lagrangian method for constrained problems.
- **`notebooks/`**: Jupyter notebooks demonstrating the usage, testing, and convergence plots of the algorithms.
  - `newton.ipynb`
  - `regions_de_confiance.ipynb`
  - `lagrangien_augmente.ipynb`
- **`test/`**: Unit tests and objective functions to validate the algorithm outputs.
  - `fonctions_de_tests.jl`: Standard optimisation test functions (e.g., Rosenbrock).
  - `tester_*.jl`: Test scripts for each specific algorithm.

## Prerequisites

- **Julia**: Version 1.0 or higher.
- **Jupyter / IJulia**: To run the provided interactive notebooks.
- **Plots.jl**: For graphing the convergence results within the notebooks.

## How to Use

There are several ways to interact with and test the algorithms in this project:

### 1. Using Jupyter Notebooks
The easiest, most visual way to test the algorithms is by using the provided notebooks. Ensure you have the `IJulia` package installed to run Julia kernels in Jupyter.

1. Navigate to the `notebooks/` folder.
2. Open the desired notebook (e.g., `newton.ipynb`).
3. Run the cells sequentially to load the source files, define the objective functions, and execute the tests.

### 2. Using the Julia REPL (Direct usage)
You can directly invoke the algorithms from an interactive Julia session from the root directory of the project. Include the source files and pass your functions:

```julia
# Include the specific algorithm and generic test functions
include("src/newton.jl")
include("test/fonctions_de_tests.jl")

# Define a simple objective function, its gradient, and its Hessian
f(x)      =  sin(x)
grad_f(x) =  cos(x)
hess_f(x) = -sin(x)

# Pick a starting point
x0 = -pi/2

# Run the algorithm
x_sol, f_sol, flag, nb_iters = newton(f, grad_f, hess_f, x0)

# Display results using the test utility
afficher_resultats("Newton", "f(x) = sin(x)", x0, x_sol, f_sol, flag, nb_iters, -pi/2)
```

### 3. Running Unit Tests
To verify all implemented methods are working correctly, you can run the test functions provided in the `test/` directory:

```julia
# Example: Testing Newton's method
include("src/newton.jl")
include("test/tester_newton.jl")

# Run the tests and pass 'true' to display detailed output
tester_newton(newton, true)
```