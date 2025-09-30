import os
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from glob import glob

# Get list of CSV filenames in the "result" directory
filenames = glob('result/*.csv')

# Extract benchmark names
benchmarks = [os.path.splitext(os.path.basename(f))[0] for f in filenames]

runtimes = ['native(glibc)', 'native(musl)', 'wasmtime', 'iwasm', 'wasmer']

# Initialize arrays
mean_values_list = []
std_values_list = []

# Iterate over benchmarks
for filename in filenames:
    data = pd.read_csv(filename)
    mean_vals = []
    std_vals = []
    for runtime in runtimes:
        subset = data[data['Runtime'] == runtime]
        mean_vals.append(subset['Mean'].values[0])
        std_vals.append(subset['StDev'].values[0])
    mean_values_list.append(mean_vals)
    std_values_list.append(std_vals)

mean_values = np.array(mean_values_list)  # shape: (num_benchmarks, num_runtimes)
std_values = np.array(std_values_list)

# Normalize to glibc (first column)
std_values = std_values / mean_values[:, [0]]
mean_values = mean_values / mean_values[:, [0]]

# Remove glibc values
mean_values = mean_values[:, 1:]
std_values = std_values[:, 1:]
runtimes_plot = runtimes[1:]

# Plotting
numgroups, numbars = mean_values.shape
groupwidth = min(0.8, numbars / (numbars + 1.5))
x = np.arange(numgroups)

fig, ax = plt.subplots(figsize=(12, 6))

for i in range(numbars):
    ax.bar(x + (2*i - 1) * groupwidth/(2*numbars), mean_values[:, i], groupwidth/numbars,
           yerr=std_values[:, i], capsize=3, label=runtimes_plot[i])

ax.set_xticks(x)
ax.set_xticklabels(benchmarks, rotation=45, ha='right')
ax.set_ylabel('Time (Relative to glibc)')
ax.set_xlabel('Benchmarks')
ax.set_title('Runtime comparison')

# Red line at y=1
ax.axhline(1, color='r', linestyle='--', linewidth=1)

# Add percentages on top of bars
for i in range(numbars):
    percentages = mean_values[:, i] * 100
    for j in range(numgroups):
        ax.text(x[j] + (2*i - 1) * groupwidth/(2*numbars),
                mean_values[j, i],
                f'{percentages[j]:.1f}%',
                rotation=90,
                ha='left',
                va='bottom',
                fontsize=8)

ax.legend(title='Runtime', loc='upper left')

plt.tight_layout()
plt.show()
