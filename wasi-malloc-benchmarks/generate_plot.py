import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

# Benchmarks
non_thread_benchmarks = ['cfrac', 'barnes', 'espresso', 'malloc-large', 'bench-malloc-simple']
thread_benchmarks = ['larson-sized', 'larson', 'mstress', 'xmalloc-test', 'mleak', 't-test1', 'bench-malloc-threads']

num_threads = [64]

# Create plots directory if it doesn't exist
os.makedirs('plots', exist_ok=True)

# Iterate over thread counts
for n_threads in num_threads:
    filename = 'result/mimalloc.csv'
    all_benchmarks = pd.read_csv(filename)

    # ---- Non-threaded benchmarks ----
    non_threaded = all_benchmarks[all_benchmarks['test'].isin(non_thread_benchmarks)]
    fig, axes = plt.subplots(2, 1, figsize=(12, 8))
    fig.suptitle('Execution Time and Max RSS (non threaded benchmarks)', fontsize=16)

    def plot(data, param, ax):
        runtimes = data['runtime'].unique()
        benchmarks = data['test'].unique()
        
        mean_values = np.zeros((len(benchmarks), len(runtimes)))
        std_values = np.zeros_like(mean_values)
        
        for i, benchmark in enumerate(benchmarks):
            for j, runtime in enumerate(runtimes):
                subset = data[(data['test'] == benchmark) & (data['runtime'] == runtime)]
                mean_values[i, j] = subset[param].mean()
                std_values[i, j] = subset[param].std()
        
        # Normalize to the first runtime (assumed glibc/native)
        std_values = std_values / mean_values[:, [0]]
        mean_values = mean_values / mean_values[:, [0]]
        
        # Remove glibc values (first column)
        mean_values_plot = mean_values[:, 1:]
        std_values_plot = std_values[:, 1:]
        runtimes_plot = runtimes[1:]

        # Bar plot
        num_benchmarks, num_runtimes = mean_values_plot.shape
        bar_width = 0.8 / num_runtimes
        x = np.arange(num_benchmarks)
        for i in range(num_runtimes):
            ax.bar(x + i * bar_width, mean_values_plot[:, i], bar_width, yerr=std_values_plot[:, i], capsize=3, label=runtimes_plot[i])
        
        ax.axhline(1, color='r', linestyle='--', linewidth=1)
        ax.set_xticks(x + bar_width*(num_runtimes-1)/2)
        ax.set_xticklabels(benchmarks, rotation=45, ha='right')
        ax.set_ylabel('Slowdown (Relative to "glibc")' if param == 'time' else 'Max RSS (KB) (Relative to "glibc")')
        ax.legend(title='Runtime', loc='best')

    plot(non_threaded, 'time', axes[0])
    plot(non_threaded, 'rss', axes[1])

    plt.tight_layout(rect=[0, 0, 1, 0.96])
    plt.savefig('plots/non_threaded.png', bbox_inches='tight')
    plt.show()
    plt.close(fig)

    # ---- Threaded benchmarks ----
    threaded = all_benchmarks[all_benchmarks['test'].isin(thread_benchmarks)]
    fig, axes = plt.subplots(2, 1, figsize=(12, 8))
    fig.suptitle(f'Execution Time and Max RSS ({n_threads} threads)', fontsize=16)

    plot(threaded, 'time', axes[0])
    plot(threaded, 'rss', axes[1])

    plt.tight_layout(rect=[0, 0, 1, 0.96])
    plt.savefig(f'plots/{n_threads}_threaded.png', bbox_inches='tight')
    plt.show()
    plt.close(fig)
