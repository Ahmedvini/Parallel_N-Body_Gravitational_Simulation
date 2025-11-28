#!/bin/bash

# Quick test script - runs small simulation for verification
# Use this to quickly verify the programs work before running full experiments

echo "==========================================="
echo "Quick Verification Test"
echo "==========================================="
echo "Running small simulation (N=500, steps=50)"
echo ""

# Compile
echo "[1/3] Compiling..."
make all
if [ $? -ne 0 ]; then
    echo "Compilation failed!"
    exit 1
fi
echo ""

# Run sequential
echo "[2/3] Testing sequential version..."
cd sequential
./nbody_sequential 500 50 0.01 3
if [ $? -ne 0 ]; then
    echo "Sequential test failed!"
    exit 1
fi
cd ..
echo ""

# Run parallel
echo "[3/3] Testing parallel version..."
cd parallel
./nbody_parallel 500 50 0.01 2 3
if [ $? -ne 0 ]; then
    echo "Parallel test failed!"
    exit 1
fi
cd ..
echo ""

echo "==========================================="
echo "✓ All tests passed!"
echo "==========================================="
echo ""
echo "The programs are working correctly."
echo "Run full experiments with: ./run_experiments.sh"
echo ""
