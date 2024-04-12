import pandas as pd
import matplotlib.pyplot as plt


def barplot_results(df):

    # Calculate the average time for each benchmark
    df['Average Time'] = df.iloc[:, 1:].mean(axis=1)

    # Plotting
    plt.figure(figsize=(10, 6))
    plt.bar(df['Bench'], df['Average Time'])
    plt.xlabel('Benchmark')
    plt.ylabel('Average Time')
    plt.title('Average Time for Each Benchmark')
    plt.xticks(rotation=45, ha='right')
    plt.tight_layout()
    plt.show()

def boxplot_results(df):

    # Extracting the numerical values for each benchmark
    values = [df.iloc[i, 1:].tolist() for i in range(len(df))]

    # Plotting
    plt.figure(figsize=(10, 6))
    plt.boxplot(values, patch_artist=True)
    plt.xlabel('Benchmark')
    plt.ylabel('Time')
    plt.title('Boxplot of Time for Each Benchmark')
    plt.xticks(range(1, len(df) + 1), df['Bench'], rotation=45, ha='right')
    plt.tight_layout()
    plt.show()

if __name__ == "__main__":
    csv_file = "result.csv"
    df = pd.read_csv(csv_file)
    boxplot_results(df)
