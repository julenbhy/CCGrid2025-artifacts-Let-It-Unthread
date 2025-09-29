import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

def plot_benchmark(bench, ax):
    filename = f'result/{bench}.csv'
    print(f'Reading {filename}')
    data = pd.read_csv(filename)

    runtimes = ['native(glibc)', 'native(musl)', 'wasmtime', 'iwasm', 'wasmer']
    threads = data['Threads'].unique()

    mean_values = np.zeros((len(runtimes), len(threads)))
    std_values = np.zeros_like(mean_values)

    # Fill arrays
    for i, runtime in enumerate(runtimes):
        for j, thread in enumerate(threads):
            subset = data[(data['Runtime'] == runtime) & (data['Threads'] == thread)]
            mean_values[i, j] = subset['Mean'].values[0]
            std_values[i, j] = subset['StdDev'].values[0]

    # Normalize to glibc
    std_values = std_values / mean_values[0, :]
    mean_values = mean_values / mean_values[0, :]

    # Remove glibc values
    mean_values = mean_values[1:, :]
    std_values = std_values[1:, :]
    runtimes_plot = runtimes[1:]

    # Plot
    numgroups, numbars = mean_values.shape
    groupwidth = min(0.8, numbars / (numbars + 1.5))
    x = np.arange(numgroups)

    for i in range(numbars):
        ax.bar(x + (2*i - 1) * groupwidth/(2*numbars), mean_values[:, i], groupwidth/numbars,
               yerr=std_values[:, i], capsize=3, label=str(threads[i]))

    ax.set_xticks(x)
    ax.set_xticklabels(runtimes_plot, rotation=45, ha='right')
    ax.set_xlabel('Runtime')
    ax.set_ylabel('Slowdown (S) (Glibc as baseline)')
    ax.axhline(1, color='r', linestyle='--', linewidth=1)
    ax.legend(title='Number of Threads', loc='best')

    # Add percentages on top of bars
    for i in range(numbars):
        percentages = mean_values[:, i] * 100
        for j in range(numgroups):
            ax.text(x[j] + (2*i - 1) * groupwidth/(2*numbars),
                    mean_values[j, i]+0.1,
                    f'{percentages[j]:.1f}%',
                    rotation=90,
                    ha='left',
                    va='bottom',
                    fontsize=8)


# Benchmarks list
benchmarks = ['contention', 'no_contention']

fig, axes = plt.subplots(2, 1, figsize=(12, 8))

for i, bench in enumerate(benchmarks):
    plot_benchmark(bench, axes[i])
    axes[i].set_title(bench)

plt.tight_layout()
plt.show()
