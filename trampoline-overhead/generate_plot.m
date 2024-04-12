% Read the CSV file
data = readtable('result.csv');

% Extract the numerical data
numeric_data = table2array(data(:, 2:end));

% Plot boxplot
boxplot(numeric_data', 'Labels', data.Bench);

% Bar plot
%%averages = mean(numeric_data, 2);
%bar(averages);
%xticklabels(data.Bench);

xlabel('Benchmark');
ylabel('Time (ns)');
title('Embedding Overheads');
xtickangle(45); % Rotate x-axis labels for better readability

% Save the plot as fig
saveas(gcf, 'boxplot.fig');



