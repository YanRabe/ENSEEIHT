# Fish School Simulation -- ENSEEIHT 2SN Geometric Modeling

This project provides a series of 3D fish school simulations using Python and Matplotlib. It progresses from basic random movement to a vision-based influence network. Furthermore, a final custom model is featured, combining elements from each previous system.

## The Simulations

The project is divided into 6 progressive stages:

### 1. Random Movement (`random_movement.py`)

Models simple entities moving (almost) randomly in a confined space.

### 2. Trafalgar Effect (`trafalgar.ipynb` / `trafalgar_animation_manager.py`)

Simulates the transmission of a behvaiour through the group. An initiating leader-fish is randomly granted abnormal behaviour (here its speed) and the color red to signify its contagious state. The latter propagates to neighboring fish within a defined radius, each N (here N=4) cycles.

### 3. Aoki Behavioral Rules (`aoki_behaviour.py`)

Implements the classic Aoki behavioural rules model, optimized with `scipy.spatial.KDTree` for fast distance calculations. Each fish reacts to its neighbors based on three mutually exclusive concentric zones:

* **Repulsion:** Avoids collisions (closest zone).
* **Alignment:** Matches velocity with the group (middle zone).
* **Attraction:** Keeps the group united (farthest zone).

### 4. Density Influence (`density_influence.py`)

Adapts the Aoki model to limit behavioral influence to the **6 nearest neighbors** (using `kd_tree.query(k=7)`) of each fish.

### 5. Influence Network (`influence_network.py`)

Adds a visual component using a directional vision cone (e.g., 60°). The former is calculated using the dot product of trajectory vectors. Fish are therefore influenced (via repulsion, alignment, and attraction) **only by neighbors located within their frontal field of view** (ray casting).

## 6. Final Model (`final_model.py`)

This final script combines elements from each model to obtain a more realistic and telling simulation. It also adds a "*current simulation*" feature, where pressing directional keys adds current to the X and Y axis, thus influencing the fish'speeds.

---

## Interactivity and Jupyter Notebooks

The `tests.ipynb` Jupyter Notebook serves as an interactive hub to launch all models. It uses `%matplotlib widget` for in-line 3D manipulation.

For the **Final Model**, the notebook utilizes `ipywidgets` to render **sliders** that allow you to dynamically alter behavioral variables (repulsion radii, speeds, attraction forces, etc.) *while the simulation is running*.

---

## Requirements

Ensure you have Python installed (Python 3.8+ recommended).

The following libraries are required:

* `numpy` (Matrix and vector calculations)
* `matplotlib` (3D Rendering and animations)
* `scipy` (For the `KDTree` data structure)
* `ipywidgets` (For the interactive notebook sliders)
* `ipympl` (To support interactive 3D matplotlib plots inside Jupyter)
* `ipykernel` (To run the notebook)

*(The built-in Python module `itertools` is also used.)*

You can install all dependencies easily via the provided `requirements.txt`:

```bash
pip install -r requirements.txt
```

## How to use

There are two ways to view the simulations:

* Jupyter Notebook (Recommended): Open tests.ipynb and run the cells to launch interactive windows for each simulation step.

* Standalone Scripts: Each model stage is structured as a standalone script. To view a specific simulation directly from the terminal, simply run the corresponding Python file.
