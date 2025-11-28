#!/usr/bin/env python3
"""
N-Body Simulation Performance Analysis

This script analyzes the performance of sequential vs parallel N-body simulations.
It reads timing data from CSV files, computes speedup, and generates plots for
inclusion in the project report.

Outputs:
- Table of results (threads, Tp, speedup)
- Plot: Execution time vs number of threads
- Plot: Speedup vs number of threads (with ideal speedup line)

Usage:
    python analyze_speedup.py
    
Requirements:
    pip install matplotlib pandas numpy
"""

import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import os
import sys

def read_sequential_time(filename='sequential_time.csv'):
    """
    Read sequential timing data.
    
    Returns:
        float: Sequential execution time (Ts)
    """
    if not os.path.exists(filename):
        print(f"Error: {filename} not found!")
        print("Please run the sequential program first.")
        sys.exit(1)
    
    df = pd.read_csv(filename)
    Ts = df['Ts'].iloc[0]
    return Ts

def read_parallel_times(filename='results_parallel.csv'):
    """
    Read parallel timing data for different thread counts.
    
    Returns:
        DataFrame: Contains columns [threads, Tp]
    """
    if not os.path.exists(filename):
        print(f"Error: {filename} not found!")
        print("Please run the parallel program with different thread counts first.")
        sys.exit(1)
    
    df = pd.read_csv(filename)
    # Group by threads in case there are multiple runs
    df_grouped = df.groupby('threads')['Tp'].mean().reset_index()
    return df_grouped.sort_values('threads')

def compute_speedup(Ts, df_parallel):
    """
    Compute speedup for each thread count.
    
    Speedup = Ts / Tp
    
    Args:
        Ts (float): Sequential time
        df_parallel (DataFrame): Parallel results with 'threads' and 'Tp' columns
    
    Returns:
        DataFrame: Original data with added 'speedup' column
    """
    df_parallel['speedup'] = Ts / df_parallel['Tp']
    return df_parallel

def print_results_table(Ts, df_results):
    """
    Print formatted results table for report.
    
    Args:
        Ts (float): Sequential time
        df_results (DataFrame): Results with threads, Tp, speedup
    """
    print("\n" + "="*60)
    print("PERFORMANCE ANALYSIS RESULTS")
    print("="*60)
    print(f"\nSequential Time (Ts): {Ts:.6f} seconds")
    print("\nParallel Results:")
    print("-"*60)
    print(f"{'Threads':<10} {'Tp (seconds)':<20} {'Speedup':<15} {'Efficiency':<15}")
    print("-"*60)
    
    for _, row in df_results.iterrows():
        threads = int(row['threads'])
        Tp = row['Tp']
        speedup = row['speedup']
        efficiency = speedup / threads * 100  # Parallel efficiency in %
        print(f"{threads:<10} {Tp:<20.6f} {speedup:<15.3f} {efficiency:<15.2f}%")
    
    print("-"*60)
    
    # Find maximum speedup
    max_speedup_idx = df_results['speedup'].idxmax()
    max_speedup_row = df_results.loc[max_speedup_idx]
    print(f"\nMaximum speedup: {max_speedup_row['speedup']:.3f}x with {int(max_speedup_row['threads'])} threads")
    print("="*60 + "\n")

def plot_execution_time(Ts, df_results, output_file='time_vs_threads.png'):
    """
    Plot execution time vs number of threads.
    
    Args:
        Ts (float): Sequential time
        df_results (DataFrame): Results with threads and Tp
        output_file (str): Output filename for plot
    """
    plt.figure(figsize=(10, 6))
    
    # Plot sequential time as horizontal line
    threads = df_results['threads'].values
    plt.axhline(y=Ts, color='red', linestyle='--', linewidth=2, label='Sequential (Ts)')
    
    # Plot parallel times
    plt.plot(threads, df_results['Tp'].values, 'bo-', linewidth=2, markersize=8, label='Parallel (Tp)')
    
    plt.xlabel('Number of Threads', fontsize=12, fontweight='bold')
    plt.ylabel('Execution Time (seconds)', fontsize=12, fontweight='bold')
    plt.title('N-Body Simulation: Execution Time vs Thread Count', fontsize=14, fontweight='bold')
    plt.grid(True, alpha=0.3)
    plt.legend(fontsize=11)
    plt.tight_layout()
    
    plt.savefig(output_file, dpi=300, bbox_inches='tight')
    print(f"Plot saved: {output_file}")
    plt.close()

def plot_speedup(df_results, output_file='speedup_vs_threads.png'):
    """
    Plot speedup vs number of threads with ideal speedup line.
    
    Args:
        df_results (DataFrame): Results with threads and speedup
        output_file (str): Output filename for plot
    """
    plt.figure(figsize=(10, 6))
    
    threads = df_results['threads'].values
    speedup = df_results['speedup'].values
    
    # Plot actual speedup
    plt.plot(threads, speedup, 'go-', linewidth=2, markersize=8, label='Actual Speedup')
    
    # Plot ideal speedup (linear: speedup = threads)
    ideal_speedup = threads
    plt.plot(threads, ideal_speedup, 'r--', linewidth=2, label='Ideal Speedup (Linear)')
    
    plt.xlabel('Number of Threads', fontsize=12, fontweight='bold')
    plt.ylabel('Speedup (Ts / Tp)', fontsize=12, fontweight='bold')
    plt.title('N-Body Simulation: Speedup vs Thread Count', fontsize=14, fontweight='bold')
    plt.grid(True, alpha=0.3)
    plt.legend(fontsize=11)
    
    # Add efficiency annotations
    for i, (t, s) in enumerate(zip(threads, speedup)):
        efficiency = (s / t) * 100
        plt.annotate(f'{efficiency:.1f}%', 
                    xy=(t, s), 
                    xytext=(5, 5), 
                    textcoords='offset points',
                    fontsize=9,
                    alpha=0.7)
    
    plt.tight_layout()
    plt.savefig(output_file, dpi=300, bbox_inches='tight')
    print(f"Plot saved: {output_file}")
    plt.close()

def save_results_to_csv(Ts, df_results, output_file='analysis_results.csv'):
    """
    Save complete analysis results to CSV for easy import into report.
    
    Args:
        Ts (float): Sequential time
        df_results (DataFrame): Results with threads, Tp, speedup
        output_file (str): Output CSV filename
    """
    df_output = df_results.copy()
    df_output['Ts'] = Ts
    df_output['efficiency'] = (df_output['speedup'] / df_output['threads']) * 100
    
    # Reorder columns
    df_output = df_output[['threads', 'Ts', 'Tp', 'speedup', 'efficiency']]
    
    df_output.to_csv(output_file, index=False, float_format='%.6f')
    print(f"Analysis results saved: {output_file}")

def main():
    """Main analysis routine."""
    print("="*60)
    print("N-Body Simulation Performance Analysis")
    print("="*60)
    
    # Read timing data
    print("\nReading timing data...")
    try:
        Ts = read_sequential_time()
        print(f"✓ Sequential time loaded: Ts = {Ts:.6f} s")
    except Exception as e:
        print(f"✗ Error reading sequential time: {e}")
        return
    
    try:
        df_parallel = read_parallel_times()
        print(f"✓ Parallel times loaded for {len(df_parallel)} thread configurations")
    except Exception as e:
        print(f"✗ Error reading parallel times: {e}")
        return
    
    # Compute speedup
    print("\nComputing speedup...")
    df_results = compute_speedup(Ts, df_parallel)
    print("✓ Speedup computed")
    
    # Print results table
    print_results_table(Ts, df_results)
    
    # Generate plots
    print("Generating plots...")
    plot_execution_time(Ts, df_results)
    plot_speedup(df_results)
    print("✓ Plots generated")
    
    # Save results to CSV
    print("\nSaving analysis results...")
    save_results_to_csv(Ts, df_results)
    print("✓ Analysis complete!")
    
    print("\n" + "="*60)
    print("Files generated:")
    print("  - time_vs_threads.png       (execution time plot)")
    print("  - speedup_vs_threads.png    (speedup plot)")
    print("  - analysis_results.csv      (complete results table)")
    print("="*60)

if __name__ == '__main__':
    main()
