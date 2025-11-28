# Makefile for N-Body Simulation Project
# Compiles both sequential and parallel versions

# Compiler settings
CXX = g++
CXXFLAGS = -std=c++17 -O3 -Wall
OMPFLAGS = -fopenmp

# Directories
SEQ_DIR = sequential
PAR_DIR = parallel

# Targets
SEQ_TARGET = $(SEQ_DIR)/nbody_sequential
PAR_TARGET = $(PAR_DIR)/nbody_parallel

# Default target: build both
.PHONY: all
all: sequential parallel
	@echo ""
	@echo "✓ All programs compiled successfully!"
	@echo ""
	@echo "Run sequential: cd sequential && ./nbody_sequential 1000 100 0.01 5"
	@echo "Run parallel:   cd parallel && ./nbody_parallel 1000 100 0.01 4 5"
	@echo ""

# Build sequential version
.PHONY: sequential
sequential: $(SEQ_TARGET)

$(SEQ_TARGET): $(SEQ_DIR)/nbody_sequential.cpp
	@echo "Compiling sequential version..."
	$(CXX) $(CXXFLAGS) $< -o $@
	@echo "✓ Sequential version compiled: $(SEQ_TARGET)"

# Build parallel version
.PHONY: parallel
parallel: $(PAR_TARGET)

$(PAR_TARGET): $(PAR_DIR)/nbody_parallel.cpp
	@echo "Compiling parallel version with OpenMP..."
	$(CXX) $(CXXFLAGS) $(OMPFLAGS) $< -o $@
	@echo "✓ Parallel version compiled: $(PAR_TARGET)"

# Clean compiled binaries and output files
.PHONY: clean
clean:
	@echo "Cleaning build artifacts and output files..."
	rm -f $(SEQ_TARGET) $(PAR_TARGET)
	rm -f $(SEQ_DIR)/*.csv $(SEQ_DIR)/*.txt
	rm -f $(PAR_DIR)/*.csv $(PAR_DIR)/*.txt
	rm -f analysis/*.csv analysis/*.png
	@echo "✓ Clean complete"

# Run experiments
.PHONY: run
run: all
	@echo "Running automated experiments..."
	./run_experiments.sh

# Quick test with small parameters
.PHONY: test
test: all
	@echo "Running quick test (N=500)..."
	cd $(SEQ_DIR) && ./nbody_sequential 500 50 0.01 3
	cd $(PAR_DIR) && ./nbody_parallel 500 50 0.01 2 3
	cd $(PAR_DIR) && ./nbody_parallel 500 50 0.01 4 3
	@echo "✓ Quick test complete"

# Help
.PHONY: help
help:
	@echo "N-Body Simulation Makefile"
	@echo ""
	@echo "Targets:"
	@echo "  make all        - Compile both sequential and parallel versions (default)"
	@echo "  make sequential - Compile only sequential version"
	@echo "  make parallel   - Compile only parallel version"
	@echo "  make clean      - Remove compiled binaries and output files"
	@echo "  make run        - Compile and run complete experiments"
	@echo "  make test       - Quick test with small parameters"
	@echo "  make help       - Show this help message"
	@echo ""
	@echo "Manual usage:"
	@echo "  Sequential: cd sequential && ./nbody_sequential <N> <steps> <dt> [runs]"
	@echo "  Parallel:   cd parallel && ./nbody_parallel <N> <steps> <dt> <threads> [runs]"
	@echo ""
