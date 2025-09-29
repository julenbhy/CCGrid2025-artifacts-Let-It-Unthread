import pandas as pd
import matplotlib.pyplot as plt

# Read the CSV file
data = pd.read_csv('result.csv')

# Extract numerical data (all columns except the first one)
numeric_data = data.iloc[:, 1:].to_numpy()

# Boxplot
plt.figure(figsize=(10, 6))
plt.boxplot(numeric_data.T, labels=data.iloc[:, 0])
plt.xlabel('Benchmark')
plt.ylabel('Time (ns)')
plt.title('Embedding Overheads')
plt.xticks(rotation=45)

# Save the plot (MATLAB's .fig has no direct equivalent, using .png instead)
plt.savefig('boxplot.png', bbox_inches='tight')
plt.show()

# Optional: Bar plot of averages (commented out in MATLAB)
# averages = numeric_data.mean(axis=1)
# plt.figure(figsize=(10, 6))
# plt.bar(data.iloc[:, 0], averages)
# plt.xlabel('Benchmark')
# plt.ylabel('Average Time (ns)')
# plt.xticks(rotation=45)
# plt.title('Average Embedding Overheads')
# plt.savefig('barplot.png', bbox_inches='tight')
# plt.show()