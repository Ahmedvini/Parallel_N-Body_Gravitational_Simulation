/*
 * N-Body Gravitational Simulation - Sequential Implementation
 * 
 * This program simulates N bodies (particles/stars) interacting via Newtonian gravity.
 * The simulation uses a brute-force O(N²) algorithm to compute gravitational forces
 * between all pairs of bodies at each time step.
 * 
 * Physical Model:
 * - Each body has position (x,y,z), velocity (vx,vy,vz), and mass
 * - Gravitational force: F = G * m1 * m2 / r²
 * - Time integration: Explicit Euler method
 * 
 * Compile: g++ -std=c++17 -O3 nbody_sequential.cpp -o nbody_sequential
 * Run: ./nbody_sequential <N> <steps> <dt> <runs>
 * Example: ./nbody_sequential 1000 100 0.01 5
 */

#include <iostream>
#include <vector>
#include <array>
#include <random>
#include <chrono>
#include <cmath>
#include <iomanip>
#include <string>
#include <fstream>

// ============================================================================
// DATA STRUCTURES
// ============================================================================

/**
 * Represents a single body in the N-body simulation.
 * Contains position, velocity, and mass.
 */
struct Body {
    double x, y, z;       // Position in 3D space
    double vx, vy, vz;    // Velocity components
    double mass;          // Mass of the body
};

// ============================================================================
// INITIALIZATION FUNCTIONS
// ============================================================================

/**
 * Initialize N bodies with random positions, velocities, and masses.
 * 
 * @param bodies Vector to store the bodies
 * @param N Number of bodies to create
 * @param seed Random seed for reproducibility (0 = random seed)
 */
void initialize_bodies(std::vector<Body>& bodies, int N, unsigned int seed = 42) {
    bodies.resize(N);
    
    // Set up random number generator
    std::mt19937 gen(seed);
    std::uniform_real_distribution<double> pos_dist(-1.0, 1.0);      // Position in [-1, 1]
    std::uniform_real_distribution<double> vel_dist(-0.01, 0.01);    // Small initial velocities
    std::uniform_real_distribution<double> mass_dist(0.5, 2.0);      // Mass in [0.5, 2.0]
    
    // Generate random initial conditions for each body
    for (int i = 0; i < N; ++i) {
        bodies[i].x = pos_dist(gen);
        bodies[i].y = pos_dist(gen);
        bodies[i].z = pos_dist(gen);
        
        bodies[i].vx = vel_dist(gen);
        bodies[i].vy = vel_dist(gen);
        bodies[i].vz = vel_dist(gen);
        
        bodies[i].mass = mass_dist(gen);
    }
}

// ============================================================================
// FORCE COMPUTATION (SEQUENTIAL O(N²) ALGORITHM)
// ============================================================================

/**
 * Compute gravitational forces on all bodies - SEQUENTIAL VERSION.
 * 
 * This is the computationally expensive part: O(N²) complexity.
 * For each body i, we compute the force from all other bodies j.
 * 
 * Newton's law of gravitation: F = G * m1 * m2 / r²
 * Direction: force points from body i toward body j
 * 
 * @param bodies Vector of all bodies (positions and masses)
 * @param forces Output: force vectors for each body [Fx, Fy, Fz]
 * @param G Gravitational constant
 * @param softening Softening parameter to avoid singularities (r² -> r² + ε²)
 */
void compute_forces(const std::vector<Body>& bodies, 
                   std::vector<std::array<double, 3>>& forces,
                   double G, 
                   double softening) {
    const int N = bodies.size();
    
    // For each body i, compute total force from all other bodies
    for (int i = 0; i < N; ++i) {
        double Fx = 0.0, Fy = 0.0, Fz = 0.0;
        
        // Sum forces from all other bodies j
        for (int j = 0; j < N; ++j) {
            if (i == j) continue;  // Skip self-interaction
            
            // Vector from body i to body j
            double dx = bodies[j].x - bodies[i].x;
            double dy = bodies[j].y - bodies[i].y;
            double dz = bodies[j].z - bodies[i].z;
            
            // Distance squared with softening to prevent division by zero
            double dist_sq = dx * dx + dy * dy + dz * dz + softening * softening;
            double dist = std::sqrt(dist_sq);
            
            // Gravitational force magnitude: F = G * m1 * m2 / r²
            double force_mag = G * bodies[i].mass * bodies[j].mass / dist_sq;
            
            // Force components (normalized by distance)
            Fx += force_mag * dx / dist;
            Fy += force_mag * dy / dist;
            Fz += force_mag * dz / dist;
        }
        
        // Store computed forces
        forces[i][0] = Fx;
        forces[i][1] = Fy;
        forces[i][2] = Fz;
    }
}

// ============================================================================
// TIME INTEGRATION (EXPLICIT EULER METHOD)
// ============================================================================

/**
 * Update body positions and velocities using explicit Euler integration.
 * 
 * Euler method:
 * - v(t+dt) = v(t) + (F/m) * dt    (update velocity from force)
 * - x(t+dt) = x(t) + v(t+dt) * dt  (update position from new velocity)
 * 
 * @param bodies Vector of bodies to update (modified in place)
 * @param forces Force vectors for each body
 * @param dt Time step size
 */
void update_bodies(std::vector<Body>& bodies, 
                  const std::vector<std::array<double, 3>>& forces,
                  double dt) {
    const int N = bodies.size();
    
    for (int i = 0; i < N; ++i) {
        // Acceleration = Force / mass
        double ax = forces[i][0] / bodies[i].mass;
        double ay = forces[i][1] / bodies[i].mass;
        double az = forces[i][2] / bodies[i].mass;
        
        // Update velocities: v = v + a * dt
        bodies[i].vx += ax * dt;
        bodies[i].vy += ay * dt;
        bodies[i].vz += az * dt;
        
        // Update positions: x = x + v * dt
        bodies[i].x += bodies[i].vx * dt;
        bodies[i].y += bodies[i].vy * dt;
        bodies[i].z += bodies[i].vz * dt;
    }
}

// ============================================================================
// OUTPUT FUNCTIONS
// ============================================================================

/**
 * Save final body positions to a file for visualization (optional).
 * 
 * @param bodies Vector of bodies
 * @param filename Output filename
 */
void save_bodies(const std::vector<Body>& bodies, const std::string& filename) {
    std::ofstream file(filename);
    if (!file.is_open()) {
        std::cerr << "Warning: Could not open file " << filename << " for writing.\n";
        return;
    }
    
    file << std::fixed << std::setprecision(6);
    file << "# x y z vx vy vz mass\n";
    
    for (const auto& body : bodies) {
        file << body.x << " " << body.y << " " << body.z << " "
             << body.vx << " " << body.vy << " " << body.vz << " "
             << body.mass << "\n";
    }
    
    file.close();
    std::cout << "Final positions saved to " << filename << "\n";
}

// ============================================================================
// MAIN PROGRAM
// ============================================================================

int main(int argc, char* argv[]) {
    // Parse command line arguments
    if (argc < 4) {
        std::cerr << "Usage: " << argv[0] << " <N> <steps> <dt> [runs]\n";
        std::cerr << "  N     : Number of bodies\n";
        std::cerr << "  steps : Number of time steps\n";
        std::cerr << "  dt    : Time step size\n";
        std::cerr << "  runs  : Number of timing runs (default: 5)\n";
        std::cerr << "Example: " << argv[0] << " 1000 100 0.01 5\n";
        return 1;
    }
    
    const int N = std::stoi(argv[1]);
    const int steps = std::stoi(argv[2]);
    const double dt = std::stod(argv[3]);
    const int runs = (argc >= 5) ? std::stoi(argv[4]) : 5;
    
    // Physical constants
    const double G = 1.0;           // Gravitational constant (normalized)
    const double softening = 1e-9;  // Softening parameter to avoid singularities
    
    std::cout << "========================================\n";
    std::cout << "N-Body Simulation - SEQUENTIAL VERSION\n";
    std::cout << "========================================\n";
    std::cout << "Number of bodies (N): " << N << "\n";
    std::cout << "Time steps: " << steps << "\n";
    std::cout << "Time step size (dt): " << dt << "\n";
    std::cout << "Number of runs: " << runs << "\n";
    std::cout << "Gravitational constant (G): " << G << "\n";
    std::cout << "Softening parameter: " << softening << "\n";
    std::cout << "Computational complexity: O(N²) = O(" << (long long)N * N << ")\n";
    std::cout << "========================================\n\n";
    
    // Storage for timing results
    std::vector<double> run_times;
    run_times.reserve(runs);
    
    // Perform multiple runs for accurate timing
    for (int run = 0; run < runs; ++run) {
        std::cout << "Run " << (run + 1) << "/" << runs << "... ";
        std::cout.flush();
        
        // Initialize bodies
        std::vector<Body> bodies;
        initialize_bodies(bodies, N, 42 + run);  // Different seed per run
        
        // Allocate force storage
        std::vector<std::array<double, 3>> forces(N);
        
        // ====================================================================
        // START TIMING - Measure only the simulation loop
        // ====================================================================
        auto start_time = std::chrono::high_resolution_clock::now();
        
        // Main simulation loop
        for (int step = 0; step < steps; ++step) {
            compute_forces(bodies, forces, G, softening);
            update_bodies(bodies, forces, dt);
        }
        
        auto end_time = std::chrono::high_resolution_clock::now();
        // ====================================================================
        // END TIMING
        // ====================================================================
        
        // Compute elapsed time in seconds
        std::chrono::duration<double> elapsed = end_time - start_time;
        double time_seconds = elapsed.count();
        run_times.push_back(time_seconds);
        
        std::cout << time_seconds << " seconds\n";
        
        // Optionally save final positions from last run
        if (run == runs - 1) {
            save_bodies(bodies, "final_positions_sequential.txt");
        }
    }
    
    // Compute statistics
    double total_time = 0.0;
    for (double t : run_times) {
        total_time += t;
    }
    double avg_time = total_time / runs;
    
    // Print results
    std::cout << "\n========================================\n";
    std::cout << "TIMING RESULTS\n";
    std::cout << "========================================\n";
    for (int i = 0; i < runs; ++i) {
        std::cout << "Run " << (i + 1) << ": " << std::fixed 
                  << std::setprecision(6) << run_times[i] << " s\n";
    }
    std::cout << "----------------------------------------\n";
    std::cout << "Average sequential time (Ts): " << std::fixed 
              << std::setprecision(6) << avg_time << " s\n";
    std::cout << "========================================\n";
    
    // Save timing data to CSV for analysis
    std::ofstream csv("sequential_time.csv");
    if (csv.is_open()) {
        csv << "N,steps,dt,Ts\n";
        csv << N << "," << steps << "," << dt << "," << avg_time << "\n";
        csv.close();
        std::cout << "\nTiming data saved to sequential_time.csv\n";
    }
    
    return 0;
}
