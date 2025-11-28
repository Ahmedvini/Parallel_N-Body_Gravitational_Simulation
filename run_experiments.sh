#!/bin/bash

# =============================================================================
# Automated N-Body Simulation Experiment Runner
# =============================================================================
# This script automates the complete workflow:
# 1. Compiles sequential and parallel programs
# 2. Runs sequential version to get baseline Ts
# 3. Runs parallel version with multiple thread counts
# 4. Analyzes results and generates plots
#
# Usage: ./run_experiments.sh [N] [steps] [dt] [runs]
# Example: ./run_experiments.sh 1000 100 0.01 5
# =============================================================================

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Default parameters
N=${1:-1000}        # Number of bodies
STEPS=${2:-100}     # Time steps
DT=${3:-0.01}       # Time step size
RUNS=${4:-5}        # Number of runs for averaging

# Thread counts to test
THREAD_COUNTS=(1 2 4 8)

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}N-Body Simulation - Automated Experiments${NC}"
echo -e "${CYAN}========================================${NC}"
echo -e "Parameters:"
echo -e "  Bodies (N):     ${GREEN}${N}${NC}"
echo -e "  Time steps:     ${GREEN}${STEPS}${NC}"
echo -e "  Time step (dt): ${GREEN}${DT}${NC}"
echo -e "  Timing runs:    ${GREEN}${RUNS}${NC}"
echo -e "  Thread counts:  ${GREEN}${THREAD_COUNTS[@]}${NC}"
echo -e "${CYAN}========================================${NC}\n"

# =============================================================================
# Step 1: Compilation
# =============================================================================

echo -e "${BLUE}[Step 1/4] Compiling programs...${NC}"

# Compile sequential version
echo -e "Compiling sequential version..."
cd sequential || exit 1
if g++ -std=c++17 -O3 nbody_sequential.cpp -o nbody_sequential 2>&1; then
    echo -e "${GREEN}✓ Sequential program compiled successfully${NC}"
else
    echo -e "${RED}✗ Failed to compile sequential program${NC}"
    exit 1
fi
cd ..

# Compile parallel version
echo -e "Compiling parallel version..."
cd parallel || exit 1
if g++ -std=c++17 -O3 -fopenmp nbody_parallel.cpp -o nbody_parallel 2>&1; then
    echo -e "${GREEN}✓ Parallel program compiled successfully${NC}"
else
    echo -e "${RED}✗ Failed to compile parallel program${NC}"
    echo -e "${YELLOW}Note: Make sure OpenMP is installed (libomp-dev on Ubuntu)${NC}"
    exit 1
fi
cd ..

echo ""

# =============================================================================
# Step 2: Run Sequential Version
# =============================================================================

echo -e "${BLUE}[Step 2/4] Running sequential version...${NC}"
cd sequential || exit 1

# Clean up previous results
rm -f sequential_time.csv final_positions_sequential.txt

# Run sequential version
if ./nbody_sequential ${N} ${STEPS} ${DT} ${RUNS}; then
    echo -e "${GREEN}✓ Sequential run completed${NC}"
    
    # Check if output file was created
    if [ -f "sequential_time.csv" ]; then
        echo -e "${GREEN}✓ Sequential timing data saved${NC}"
        # Move CSV to analysis folder
        cp sequential_time.csv ../analysis/
    else
        echo -e "${RED}✗ Sequential timing data not found${NC}"
        exit 1
    fi
else
    echo -e "${RED}✗ Sequential run failed${NC}"
    exit 1
fi

cd ..
echo ""

# =============================================================================
# Step 3: Run Parallel Versions with Different Thread Counts
# =============================================================================

echo -e "${BLUE}[Step 3/4] Running parallel versions with different thread counts...${NC}"
cd parallel || exit 1

# Clean up previous results
rm -f results_parallel.csv final_positions_parallel.txt

# Run for each thread count
for threads in "${THREAD_COUNTS[@]}"; do
    echo -e "${YELLOW}Testing with ${threads} thread(s)...${NC}"
    
    if ./nbody_parallel ${N} ${STEPS} ${DT} ${threads} ${RUNS}; then
        echo -e "${GREEN}✓ Completed with ${threads} thread(s)${NC}"
    else
        echo -e "${RED}✗ Failed with ${threads} thread(s)${NC}"
        exit 1
    fi
    echo ""
done

# Check if results file exists
if [ -f "results_parallel.csv" ]; then
    echo -e "${GREEN}✓ All parallel runs completed${NC}"
    # Move CSV to analysis folder
    cp results_parallel.csv ../analysis/
else
    echo -e "${RED}✗ Parallel timing data not found${NC}"
    exit 1
fi

cd ..
echo ""

# =============================================================================
# Step 4: Analyze Results and Generate Plots
# =============================================================================

echo -e "${BLUE}[Step 4/4] Analyzing results and generating plots...${NC}"
cd analysis || exit 1

# Check if Python is available
if ! command -v python3 &> /dev/null; then
    echo -e "${YELLOW}Warning: python3 not found. Skipping analysis.${NC}"
    echo -e "${YELLOW}Install Python 3 and run: python3 analyze_speedup.py${NC}"
    cd ..
    exit 0
fi

# Check if required packages are installed
python3 -c "import matplotlib, pandas, numpy" 2>/dev/null
if [ $? -ne 0 ]; then
    echo -e "${YELLOW}Warning: Required Python packages not found.${NC}"
    echo -e "${YELLOW}Install with: pip install matplotlib pandas numpy${NC}"
    echo -e "${YELLOW}Then run: python3 analyze_speedup.py${NC}"
    cd ..
    exit 0
fi

# Run analysis
if python3 analyze_speedup.py; then
    echo -e "${GREEN}✓ Analysis completed successfully${NC}"
else
    echo -e "${RED}✗ Analysis failed${NC}"
    cd ..
    exit 1
fi

cd ..
echo ""

# =============================================================================
# Summary
# =============================================================================

echo -e "${CYAN}========================================${NC}"
echo -e "${GREEN}✓ All experiments completed successfully!${NC}"
echo -e "${CYAN}========================================${NC}"
echo -e "\n${YELLOW}Generated files:${NC}"
echo -e "  📊 ${BLUE}analysis/time_vs_threads.png${NC}      - Execution time plot"
echo -e "  📊 ${BLUE}analysis/speedup_vs_threads.png${NC}   - Speedup plot"
echo -e "  📄 ${BLUE}analysis/analysis_results.csv${NC}     - Complete results table"
echo -e "  📄 ${BLUE}analysis/sequential_time.csv${NC}      - Sequential timing"
echo -e "  📄 ${BLUE}analysis/results_parallel.csv${NC}     - Parallel timing"
echo -e "\n${YELLOW}Next steps:${NC}"
echo -e "  1. View plots in ${BLUE}analysis/${NC} folder"
echo -e "  2. Check ${BLUE}analysis/analysis_results.csv${NC} for detailed data"
echo -e "  3. Use results in your report"
echo -e "\n${YELLOW}To run with different parameters:${NC}"
echo -e "  ${GREEN}./run_experiments.sh <N> <steps> <dt> <runs>${NC}"
echo -e "  Example: ${GREEN}./run_experiments.sh 2000 150 0.01 10${NC}"
echo -e "${CYAN}========================================${NC}\n"
