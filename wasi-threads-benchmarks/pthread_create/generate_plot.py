import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

def plot(bench):
    filename = f'result/{bench}.csv'
    print(f'Reading {filename}')
    data = pd.read_csv(filename)

    runtimes = ['native(glibc)', 'native(musl)', 'wasmtime', 'iwasm', 'wasmer']
    threads = data['Threads'].unique()

    # Initialize arrays
    mean_values = np.zeros((len(runtimes), len(threads)))
    std_values = np.zeros_like(mean_values)

    # Fill arrays
    for i, runtime in enumerate(runtimes):
        for j, thread in enumerate(threads):
            subset = data[(data['Runtime'] == runtime) & (data['Threads'] == thread)]
            mean_values[i, j] = subset['Mean'].values[0]
            std_values[i, j] = subset['StDev'].values[0]

    # Plotting
    numgroups, numbars = mean_values.shape
    groupwidth = min(0.8, numbars/(numbars+1.5))
    x = np.arange(numgroups)

    fig, ax = plt.subplots(figsize=(12, 6))

    for i in range(numbars):
        ax.bar(x + (2*i - 1) * groupwidth/(2*numbars), mean_values[:, i], groupwidth/numbars,
               yerr=std_values[:, i], capsize=3, label=str(threads[i]))

    ax.set_xticks(x)
    ax.set_xticklabels(runtimes, rotation=45, ha='right')
    ax.set_xlabel('Runtime')
    ax.set_ylabel('Time (s)')
    ax.set_title('Thread creation time comparison')
    ax.legend(title='Number of Threads', loc='best')

    # Add values on top of bars (rotated 90°)
    for i in range(numbars):
        for j in range(numgroups):
            ax.text(x[j] + (2*i - 1) * groupwidth/(2*numbars),
                    mean_values[j, i] + mean_values[j, i]*0.1,
                    f'{mean_values[j, i]:.4f}',
                    rotation=90,
                    ha='left',
                    va='bottom',
                    fontsize=8)

    plt.tight_layout()
    plt.show()


# Call the function for your benchmark
plot('create')
