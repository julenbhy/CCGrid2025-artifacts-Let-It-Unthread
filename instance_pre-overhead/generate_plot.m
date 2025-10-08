% === generate_plot.m ===
% Read the CSV file
data = readtable('result.csv');

% Ensure valid column names
data.Properties.VariableNames = matlab.lang.makeValidName(data.Properties.VariableNames);

% Extract unique function counts and thread counts
functions = unique(data.Functions);
threads = unique(data.Threads);

% Build a time matrix
time_matrix = zeros(length(functions), length(threads));
timeVar = data.Properties.VariableNames{contains(data.Properties.VariableNames, 'Time')};

for i = 1:length(functions)
    for j = 1:length(threads)
        time_matrix(i, j) = data.(timeVar)(data.Functions == functions(i) & data.Threads == threads(j));
    end
end

% Create the output folder if it doesn't exist
if ~exist('plots', 'dir')
    mkdir('plots');
end

% Create the figure
figure;
b = bar(log10(functions), time_matrix, 'grouped');
hold on;

% Colors and borders
b(1).FaceColor = [0.35 0.1 0.6]; % purple
b(2).FaceColor = [1 0.75 0];     % yellow
b(1).EdgeColor = 'k';
b(2).EdgeColor = 'k';
b(1).LineStyle = '--';
b(2).LineStyle = '--';

% Axis labels and ticks
xticks(log10(functions));
xticklabels({'10^{0}','10^{1}','10^{2}','10^{3}'});
xlabel('# of imports');
ylabel('Instantiation time (\mus)');
ylim([0 300]);

% Legend
legend({'1 Thread', '16 Threads'}, 'Location', 'northwest');

% Style
set(gca, 'FontSize', 10);
box on;
grid on;
hold off;

% Save plots
saveas(gcf, fullfile('plots', 'instantiation_time.fig'));
saveas(gcf, fullfile('plots', 'instantiation_time.png'));
