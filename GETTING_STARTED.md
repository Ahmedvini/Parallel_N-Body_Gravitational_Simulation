# 🚀 Getting Started - N-Body Simulation Project

This guide will help you compile, run, and analyze the N-body simulation project in just a few minutes!

---

## ⚡ Quick Start (3 Steps)

### Step 1: Verify Prerequisites
```bash
# Check if g++ is installed
g++ --version

# Check if OpenMP is available
echo "#include <omp.h>" | g++ -fopenmp -x c++ - -o /tmp/test && echo "✓ OpenMP available"

# Check if Python 3 is installed (optional, for analysis)
python3 --version
```

### Step 2: Run Automated Tests
```bash
# Quick verification (runs in ~10 seconds)
./quick_test.sh
```

### Step 3: Run Full Experiments
```bash
# Complete experiment with default parameters (runs in ~2-5 minutes)
./run_experiments.sh

# Or with custom parameters: N=2000, steps=150
./run_experiments.sh 2000 150 0.01 5
```

**Done!** Check the `analysis/` folder for plots and results.

---

## 🎯 What Gets Generated

After running experiments, you'll have:

1. **Plots** (in `analysis/` folder):
   - `time_vs_threads.png` - Execution time comparison
   - `speedup_vs_threads.png` - Speedup with ideal line

2. **Data Files**:
   - `sequential_time.csv` - Sequential baseline
   - `results_parallel.csv` - Parallel results for all thread counts
   - `analysis_results.csv` - Complete speedup analysis

3. **Body Position Files** (optional):
   - `final_positions_sequential.txt`
   - `final_positions_parallel.txt`

---

## 📚 Detailed Usage

### Method 1: Using Makefile (Easiest)
```bash
# Compile everything
make all

# Run full experiments
make run

# Quick test
make test

# Clean all outputs
make clean

# Show help
make help
```

### Method 2: Manual Compilation
```bash
# Compile sequential version
cd sequential
g++ -std=c++17 -O3 nbody_sequential.cpp -o nbody_sequential

# Compile parallel version
cd ../parallel
g++ -std=c++17 -O3 -fopenmp nbody_parallel.cpp -o nbody_parallel
```

### Method 3: Using Scripts
```bash
# Quick verification (small problem)
./quick_test.sh

# Full automated experiments
./run_experiments.sh

# Custom parameters
./run_experiments.sh <N> <steps> <dt> <runs>
```

---

## 🔬 Running Individual Programs

### Sequential Version
```bash
cd sequential
./nbody_sequential <N> <steps> <dt> [runs]

# Example: 1000 bodies, 100 steps, dt=0.01, 5 timing runs
./nbody_sequential 1000 100 0.01 5
```

**Output:**
- Timing for each run
- Average sequential time (Ts)
- CSV file: `sequential_time.csv`

### Parallel Version
```bash
cd parallel
./nbody_parallel <N> <steps> <dt> <num_threads> [runs]

# Example: 1000 bodies, 100 steps, dt=0.01, 4 threads, 5 runs
./nbody_parallel 1000 100 0.01 4 5
```

**Run with different thread counts:**
```bash
./nbody_parallel 1000 100 0.01 1 5    # 1 thread (baseline)
./nbody_parallel 1000 100 0.01 2 5    # 2 threads
./nbody_parallel 1000 100 0.01 4 5    # 4 threads
./nbody_parallel 1000 100 0.01 8 5    # 8 threads
```

**Output:**
- Timing for each run
- Average parallel time (Tp)
- CSV file: `results_parallel.csv` (appends each run)

### Analysis Script
```bash
cd analysis

# Install Python dependencies (first time only)
pip install -r requirements.txt

# Run analysis
python3 analyze_speedup.py
```

**Output:**
- Results table printed to console
- Plots: `time_vs_threads.png`, `speedup_vs_threads.png`
- CSV: `analysis_results.csv`

---

## 📊 Understanding Parameters

### N (Number of Bodies)
- Small: 500-1000 (fast, for testing)
- Medium: 1000-2000 (good for demonstrations)
- Large: 2000-5000+ (better speedup, longer runtime)

**Effect:** O(N²) complexity - doubling N quadruples runtime

### steps (Time Steps)
- Fewer: 50-100 (faster, less smooth)
- More: 100-200 (more computation)

**Effect:** Linear scaling with runtime

### dt (Time Step Size)
- Typical: 0.01
- Smaller: More accurate, can use fewer steps
- Larger: Less accurate, need more steps

**Effect:** Doesn't significantly impact performance

### runs (Timing Runs)
- Few: 3 (quick testing)
- Standard: 5 (good average)
- Many: 10+ (very stable timing)

**Effect:** More runs = more stable average, longer total runtime

### num_threads
- 1: Sequential baseline within parallel program
- 2, 4, 8: Typical multi-core configurations
- Match your CPU cores for best results

**Effect:** Check your CPU: `lscpu | grep "^CPU(s)"`

---

## 🎓 Tips for Best Results

1. **Close other applications** during timing runs
2. **Use larger N** (1500+) for more dramatic speedup
3. **Match thread count to CPU cores** for optimal performance
4. **Run multiple times** (5-10 runs) for stable averages
5. **Use -O3 optimization** (already in Makefile)

---

## 🐛 Troubleshooting

### "OpenMP not found" error
```bash
# Ubuntu/Debian
sudo apt-get install libomp-dev

# macOS (Homebrew)
brew install libomp

# Verify
g++ -fopenmp --version
```

### "Python module not found" error
```bash
# Install Python packages
pip install matplotlib pandas numpy

# Or use requirements file
cd analysis
pip install -r requirements.txt
```

### Programs compile but won't run
```bash
# Check if executable
ls -l sequential/nbody_sequential
ls -l parallel/nbody_parallel

# Make executable if needed
chmod +x sequential/nbody_sequential
chmod +x parallel/nbody_parallel
```

### Very slow execution
- Use smaller N (try 500) for testing
- Reduce steps (try 50)
- Check system load: `top` or `htop`

---

## 📈 Expected Performance

### Typical Results (N=1000, steps=100)

| Hardware | Sequential | 4 Threads | 8 Threads | Speedup |
|----------|------------|-----------|-----------|---------|
| 4-core   | ~10s       | ~3s       | ~3s       | ~3.3x   |
| 8-core   | ~10s       | ~3s       | ~1.6s     | ~6.2x   |
| 16-core  | ~10s       | ~3s       | ~1.5s     | ~6.7x   |

*Actual values depend on CPU model, memory speed, and system load*

---

## 🎯 Next Steps

1. ✅ Run `./quick_test.sh` to verify everything works
2. ✅ Run `./run_experiments.sh` for complete results
3. ✅ Check `analysis/` folder for plots
4. ✅ Review `README.md` for detailed documentation
5. ✅ Read code comments for algorithm explanations
6. ✅ Use results in your report!

---

## 📧 Need Help?

1. Check `README.md` for detailed documentation
2. Read code comments for implementation details
3. Review this getting started guide
4. Verify all prerequisites are installed

**Happy simulating! 🚀**
