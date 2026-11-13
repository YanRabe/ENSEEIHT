# Nanosatellite Swarm Analysis through Graph Modelisation -- ENSEEIHT 2SN Graph Theory course

This project models and analyzes a swarm of nanosatellites deployed in orbit around the moon. Using graph theory, the goal is to evaluate the communication network's characteristics across 9 different configurations based on two main parameters:
*   **Density of the swarm**: Low, Average, High
*   **Communication Range**: 20 km, 40 km, 60 km

The modeling and quantitative analysis are implemented in **Python** using **NumPy** and **NetworkX**.

## Features & Analysis

The project constructs 3D spatial graphs where nodes represent nanosatellites and edges represent direct communication links (created if the distance between two satellites is within the given communication range).

The analysis computes several key metrics for both **unweighted** and **weighted** (where cost is the squared distance, $d^2$) graphs :
*   **Average Degree**
*   **Average Clustering Coefficient**
*   **Maximum Cliques**
*   **Connected Components**
*   **Shortest Paths & Distribution (Dijkstra's Algorithm)**

### Key Observations
*   **Average Degree & Clustering:** Strongly increase with range, while density has a relatively minor influence.
*   **Maximum Cliques:** Increase with the range, as interconnections expand.
*   **Connected Components:** Drastically decrease with higher ranges due to the merging of isolated sub-groups.
*   **Weighted Graphs:** Introducing continuous weight ($d^2$) provides a more Gaussian distribution of low-cost paths compared to the unweighted setup.

## Project Structure

*   `main.py`: The main entry point to generate the graphs and run the analyses.
*   `csv_handler.py`: Utility module for reading/writing topology and graph metric data.
*   `data/`: Contains the generated node and edge metric text files for each scenario (e.g., `avg_20`, `high_60_VALUED`).
*   `img/`: Contains the generated 3D network visualizations and distribution histograms.
*   `topologies/`: Contains the base spatial coordinates for the nanosatellites (`topology_avg.csv`, `topology_high.csv`, `topology_low.csv`).

## How to Use

### Prerequisites

Ensure you have Python 3.x installed. You will need the libraries mentioned in our study (NetworkX and NumPy). Matplotlib is likely required to render the 3D plots and histograms.

Install the required dependencies using pip:
```bash
pip install networkx numpy matplotlib
```

### Running the Analysis
To execute the graph generations, analyze the topologies, and output the data/images, run the main script from the root of the project:

```bash
python main.py
```

or run it using your chosen IDE.

*Note: Check main.py directly if you need to uncomment or toggle specific density/range scenarios for your test runs.
*

### Viewing the Results
*   **Visualizations:** Generated plots of the swarm topologies and metric distributions will be saved in the `img/` directory.
*   **Raw Metrics:** The statistical outputs and shortest path data will be saved to their respective text files in the `data/` directory.
