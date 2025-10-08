clc; clear;

% List of benchmarks (create, create_rss)
benchmarks = {'create', 'create_rss'};

% Save plots
if ~exist('plots', 'dir')
    mkdir('plots');
end

% Iterate over the benchmarks
for b = 1:length(benchmarks)
    bench = benchmarks{b};
    plot_benchmark(bench);
end

%% Function Definition
function plot_benchmark(bench)
    filename = fullfile('result', strcat(bench, '.csv'));
    disp(['Reading ', filename])
    data = readtable(filename);

    runtimes = {'native(glibc)', 'native(musl)', 'wasmtime', 'iwasm', 'wasmer'};
    threads = unique(data.Threads);

    % Preallocate mean and std matrices
    mean_values = zeros(length(runtimes), length(threads));
    std_values = zeros(length(runtimes), length(threads));

    % Collect means and stds per runtime/thread combo
    for i = 1:length(runtimes)
        for j = 1:length(threads)
            idx = strcmp(data.Runtime, runtimes{i}) & data.Threads == threads(j);
            mean_values(i, j) = data.Mean(idx);
            std_values(i, j) = data.StDev(idx);
        end
    end

    % Plot figure
    figure('Position', [100, 100, 1200, 600]);
    hb = bar(mean_values);
    hold on;

    % Add error bars
    numgroups = size(mean_values, 1);
    numbars = size(mean_values, 2);
    groupwidth = min(0.8, numbars/(numbars + 1.5));

    for j = 1:numbars
        x = (1:numgroups) - groupwidth/2 + (2*j-1) * groupwidth / (2*numbars);
        errorbar(x, mean_values(:, j), std_values(:, j), 'k', 'linestyle', 'none');
    end

    % Labels and titles
    set(gca, 'XTickLabel', runtimes);
    lgd = legend(string(threads), 'Location', 'best');
    lgd.Title.String = 'Number of Threads';
    xlabel('Runtime');

    if strcmp(bench, 'create')
        title('Thread Creation Time Comparison');
        ylabel('Time (s)');
    elseif strcmp(bench, 'create_rss')
        title('Thread Creation Max RSS Comparison');
        ylabel('Max RSS (KB)');
    else
        title(bench);
    end

    % Add values above bars (rotated)
    for j = 1:numbars
        x = (1:numgroups) - groupwidth/2 + (2*j-1) * groupwidth / (2*numbars);
        y = mean_values(:, j);
        offset = max(mean_values(:)) * 0.07;
        text(x, y + offset, compose('%.2f', y), ...
            'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center', ...
            'FontSize', 8, 'Rotation', 90);
    end

    hold off;

    saveas(gcf, fullfile('plots', strcat(bench, '.fig')));
    saveas(gcf, fullfile('plots', strcat(bench, '.png')));
end
