import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

benchmarks = ["blackscholes", "fluidanimate", "swaptions"]
threads = 64

# Store mean and std values
mean_values = []
std_values = []

runtimes_all = None

# Iterate over benchmarks
for bench in benchmarks:
    print(f'Reading data for {bench}')
    filename = f'result/{bench}.csv'
    data = pd.read_csv(filename)

    # Filter by number of threads
    data = data[data['Threads'] == threads]

    runtimes = data['Runtime'].unique()
    if runtimes_all is None:
        runtimes_all = runtimes

    mean_vals = []
    std_vals = []
    for runtime in runtimes_all:
        subset = data[data['Runtime'] == runtime]
        mean_vals.append(subset['Time'].values[0])
        std_vals.append(subset['StdDev'].values[0])

    mean_values.append(mean_vals)
    std_values.append(std_vals)

mean_values = np.array(mean_values).T  # Shape: (num_runtimes, num_benchmarks)
std_values = np.array(std_values).T

# Normalize to the first runtime (assumed glibc/native)
std_values = std_values / mean_values[0, :]
mean_values = mean_values / mean_values[0, :]

# Plotting
numgroups, numbars = mean_values.shape
groupwidth = min(0.8, numbars / (numbars + 1.5))
x = np.arange(numgroups)

fig, ax = plt.subplots(figsize=(12, 6))

for i in range(numbars):
    ax.bar(x + (2*i - 1) * groupwidth/(2*numbars), mean_values[:, i], groupwidth/numbars, 
           yerr=std_values[:, i], capsize=3, label=benchmarks[i])

ax.set_xticks(x)
ax.set_xticklabels(runtimes_all, rotation=45, ha='right')
ax.set_ylabel('Mean time (s)')
ax.set_xlabel('Runtime')
ax.set_title(f'{threads} threads')
ax.legend(title='Benchmark')

# Add percentages on top of bars (skip first runtime if needed)
for i in range(numbars):
    percentages = mean_values[:, i] * 100
    for j in range(numgroups):
        ax.text(x[j] + (2*i - 1) * groupwidth/(2*numbars), mean_values[j, i]+0.1, 
                f'{percentages[j]:.1f}%', rotation=90, ha='left', va='bottom', fontsize=8)

plt.tight_layout()
plt.show()
