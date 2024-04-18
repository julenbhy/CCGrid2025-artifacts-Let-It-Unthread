clc

% Get list of filenames in the "result" directory
filenames = {dir('result/*.csv').name};

% Extract benchmark names from filenames
benchmarks = cellfun(@(x) strrep(strrep(x, 'result/', ''), '.csv', ''), filenames, 'UniformOutput', false);

runtimes = {'native(glibc)', 'native(musl)', 'wasmtime', 'iwasm', 'wasmer'};


% Iterate over the benchmarks
for i = 1:length(benchmarks);
    filename = strcat('result/', benchmarks{i}, '.csv');
    data = readtable(filename);

    for j = 1:length(runtimes)
        runtime = runtimes(j);

        mean_values(i, j) = data(strcmp(data.Runtime, runtime), :).Mean;
        std_values(i, j) = data(strcmp(data.Runtime, runtime), :).StDev;
    end
end

% Normalize the values to the native(glibc) runtime
std_values = std_values ./ mean_values(:, 1);
mean_values = mean_values ./ mean_values(:, 1);

% Remove the glibc values
mean_values = mean_values(:, 2:end);
std_values = std_values(:, 2:end);


% Plot
figure('Position', [100, 100, 1200, 600]);

%bar chart without the glibc values
bar(benchmarks, mean_values);

title('Runtime comparison');
ylabel('Time (Relative to glibc)');
xlabel('Benchmarks');

% Plot a red line at y = 1
yline(1,'--', 'Color', 'r', 'LineWidth', 1)

% Set log scale ¿How to manage the std values?
%yscale('log');

% Add error bars
hold on;
numgroups = size(mean_values, 1);
numbars = size(mean_values, 2);
groupwidth = min(0.8, numbars/(numbars+1.5));
for i = 1:numbars
    % Based on barweb.m by Bolu Ajiboye from MATLAB File Exchange
    x = (1:numgroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*numbars);
    errorbar(x, mean_values(:,i), std_values(:,i), 'k', 'linestyle', 'none');
end
hold off;


% Add values on top of the bars (center of each of the bars) rotated 90 degrees
for i = 1:numbars
    % Convert to percentages
    percentages = mean_values(:, i) * 100;
    text((1:numgroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*numbars), mean_values(:,i), num2str(percentages, '%0.1f%%'), ...
        'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left', 'FontSize', 8, 'Rotation', 90);
end


% Add a legend
legend(runtimes(2:end), 'Location', 'northwest');


%saveas(gcf, strcat('result/', benchmarks{i}, '.png'));
%saveas(gcf, strcat('result/', benchmarks{i}, '.fig'));

