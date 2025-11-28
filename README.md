# N-Body Gravitational Simulation - Parallel Programming Project

A comprehensive parallel programming project implementing N-body gravitational simulation in C++17, comparing sequential and parallel (OpenMP) implementations.

## 📋 Project Overview

This project demonstrates:
- **Sequential N-body simulation** with O(N²) complexity
- **Parallel implementation** using OpenMP multi-core processing
- **Performance analysis** with speedup measurements
- **Visualization** of execution time and speedup results

## 📁 Project Structure

```
.
├── sequential/
│   └── nbody_sequential.cpp    # Sequential implementation
├── parallel/
│   └── nbody_parallel.cpp      # OpenMP parallel implementation
├── analysis/
│   └── analyze_speedup.py      # Python analysis and plotting script
├── README.md                   # This file
└── run_experiments.sh          # Automated experiment runner
```

## 🔧 Requirements

### For C++ Programs:
- C++17 compatible compiler (g++ 7.0+)
- OpenMP support (included with most g++ installations)

### For Analysis Script:
- Python 3.6+
- Required packages: `matplotlib`, `pandas`, `numpy`

Install Python dependencies:
```bash
pip install matplotlib pandas numpy
```

## 🚀 Quick Start

### 1. Compile the Programs

**Sequential version:**
```bash
cd sequential
g++ -std=c++17 -O3 nbody_sequential.cpp -o nbody_sequential
```

**Parallel version:**
```bash
cd parallel
g++ -std=c++17 -O3 -fopenmp nbody_parallel.cpp -o nbody_parallel
```

### 2. Run Sequential Simulation

```bash
cd sequential
./nbody_sequential <N> <steps> <dt> [runs]
```

Example:
```bash
./nbody_sequential 1000 100 0.01 5
```

Parameters:
- `N`: Number of bodies (e.g., 1000)
- `steps`: Number of time steps (e.g., 100)
- `dt`: Time step size (e.g., 0.01)
- `runs`: Number of timing runs for averaging (default: 5)

### 3. Run Parallel Simulation

```bash
cd parallel
./nbody_parallel <N> <steps> <dt> <num_threads> [runs]
```

Example with 4 threads:
```bash
./nbody_parallel 1000 100 0.01 4 5
```

Run with different thread counts to collect data:
```bash
./nbody_parallel 1000 100 0.01 1 5
./nbody_parallel 1000 100 0.01 2 5
./nbody_parallel 1000 100 0.01 4 5
./nbody_parallel 1000 100 0.01 8 5
```

### 4. Analyze Results

```bash
cd analysis
python analyze_speedup.py
```

This generates:
- `time_vs_threads.png` - Execution time comparison
- `speedup_vs_threads.png` - Speedup with ideal speedup line
- `analysis_results.csv` - Complete results table

## 📊 Automated Experiments

Use the provided script to run a complete set of experiments:

```bash
chmod +x run_experiments.sh
./run_experiments.sh
```

This will:
1. Compile both programs
2. Run sequential version
3. Run parallel version with various thread counts (1, 2, 4, 8)
4. Generate analysis plots

## 🧪 Understanding the Results

### Sequential Time (Ts)
The baseline execution time using a single core.

### Parallel Time (Tp)
Execution time using multiple cores with OpenMP.

### Speedup
```
Speedup = Ts / Tp
```
- Ideal speedup = number of threads (linear scaling)
- Actual speedup is usually less due to:
  - Parallel overhead
  - Memory bandwidth limitations
  - Synchronization costs

### Efficiency
```
Efficiency = (Speedup / Number of Threads) × 100%
```
Measures how effectively threads are utilized.

## 📈 Expected Performance

For N=1000 bodies:
- Sequential: ~several seconds
- Parallel (4 threads): ~3-4x speedup
- Parallel (8 threads): ~5-7x speedup

Performance scales well for larger N due to O(N²) complexity.

## 🔬 Algorithm Details

### N-Body Problem
Simulates gravitational interactions between N bodies in 3D space.

**Force calculation (Newton's law):**
```
F = G × m₁ × m₂ / r²
```

**Time integration (Euler method):**
```
v(t+dt) = v(t) + (F/m) × dt
x(t+dt) = x(t) + v × dt
```

### Parallelization Strategy

**Sequential:** O(N²) operations, single thread
```cpp
for (i = 0; i < N; i++)
    for (j = 0; j < N; j++)
        compute_force(i, j)
```

**Parallel:** O(N²) operations distributed across threads
```cpp
#pragma omp parallel for
for (i = 0; i < N; i++)  // Each thread gets subset of i values
    for (j = 0; j < N; j++)
        compute_force(i, j)
```

**Why it's parallelizable:**
- Force calculation for each body `i` is independent
- No data races: each thread writes to `forces[i]`
- Read-only access to other bodies' positions
- Embarrassingly parallel workload

## 🐛 Troubleshooting

### OpenMP not found
```bash
# Check if OpenMP is available
g++ -fopenmp --version

# On Ubuntu/Debian
sudo apt-get install libomp-dev

# On macOS with Homebrew
brew install libomp
```

### Python packages missing
```bash
pip install --upgrade matplotlib pandas numpy
```

### Timing results seem wrong
- Make sure to use `-O3` optimization flag
- Close other programs to reduce system load
- Run with higher `runs` parameter for more stable averages
- Use larger `N` for more significant timing differences

## 📝 Output Files

- `sequential_time.csv` - Sequential timing results
- `results_parallel.csv` - Parallel timing for all thread counts
- `analysis_results.csv` - Complete speedup analysis
- `time_vs_threads.png` - Execution time plot
- `speedup_vs_threads.png` - Speedup plot
- `final_positions_*.txt` - Final body positions (optional)

## 🎓 Academic Usage

This project includes:
- ✅ Heavily commented code explaining algorithms
- ✅ Clear parallelization strategy documentation
- ✅ Performance measurement methodology
- ✅ Speedup analysis with visualization
- ✅ Discussion of why the problem is parallelizable

Perfect for academic reports on parallel programming!

## 📧 Questions?

Review the code comments for detailed explanations of:
- Physical simulation details
- Algorithm complexity analysis
- Parallelization strategy
- Performance measurement approach

## 🏆 Tips for Best Results

1. **Use larger N** (2000-5000) for more dramatic speedup
2. **Run on a multi-core machine** (4+ cores)
3. **Close other applications** during timing runs
4. **Use multiple runs** (5-10) for stable averages
5. **Test various thread counts** (1, 2, 4, 8, 16)

## 📄 License

Educational project - free to use and modify.
