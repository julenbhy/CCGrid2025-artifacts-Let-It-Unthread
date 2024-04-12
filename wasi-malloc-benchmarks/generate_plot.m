clc

non_thread_benchmarks = {'cfrac', 'barnes', 'espresso', 'malloc-large', 'bench-malloc-simple'};
thread_benchmarks = {'larson-sized', 'larson', 'mstress', 'xmalloc-test,' 'mleak', 't-test1', 'bench-malloc-threads'};

num_threads = [64];

% create plots directory
if ~exist('plots', 'dir')
    mkdir('plots');
end

% Iterate over thread nums
for i = 1:numel(num_threads)
    %filename = strcat('result/', num2str(num_threads(i)), '.csv');
    filename = 'result/64_rack.csv';
    all_benchmarks = readtable(filename);

    figure('Position', [100, 100, 1200, 800]);
    sgtitle(strcat('Execution Time and Max RSS (non threaded benchmarks)'));
    non_thread_benchmarks = all_benchmarks(ismember(all_benchmarks.test, non_thread_benchmarks), :);
    plot(non_thread_benchmarks, 'time', 1);
    ylabel('Slowdown (Relative to "glibc")')
    plot(non_thread_benchmarks, 'rss', 2);
    ylabel('Max RSS (KB) (Relative to "glibc")')
    saveas(gcf, 'plots/non_threaded.png')
    saveas(gcf, 'plots/non_threaded.fig')

    figure('Position', [100, 100, 1200, 800]);
    sgtitle(strcat('Execution Time and Max RSS (', num2str(num_threads(i)), ' threads)'));
    thread_benchmarks = all_benchmarks(ismember(all_benchmarks.test, thread_benchmarks), :);
    plot(thread_benchmarks, 'time', 1);
    ylabel('Slowdown (Relative to "glibc")')
    plot(thread_benchmarks, 'rss', 2);
    ylabel('Max RSS (KB) (Relative to "glibc")')
    saveas(gcf, strcat('plots/', num2str(num_threads(i)), '_threaded.png'))
    saveas(gcf, strcat('plots/', num2str(num_threads(i)), '_threaded.fig'))
end





function plot(data, param, pos)
    
    subplot(2, 1, pos);

    runtimes = unique(data.runtime, 'stable');
    benchmarks = unique(data.test, 'stable');

    for i = 1:numel(benchmarks)
        benchmark = benchmarks(i);
        for j = 1:numel(runtimes)
            runtime = runtimes(j);
            % Extract execution mean time for the current test and runtime combination
            mean_values(i, j) = mean(data(strcmp(data.test, benchmark) & strcmp(data.runtime, runtime), :).(param));
            %Calcula stddev
            std_values(i, j) = std(data(strcmp(data.test, benchmark) & strcmp(data.runtime, runtime), :).(param));
        end
    end

    % Normalize the values to the native(glibc) runtime
    std_values = std_values ./ mean_values(:, 1); % standard deviation must be normalized first to avoid division by 1
    mean_values = mean_values ./ mean_values(:, 1);

    % Remove the glibc values
    mean_values = mean_values(:, 2:end);
    std_values = std_values(:, 2:end);

    % Create bar plot
    bar(benchmarks, mean_values)

    % Plot a red line at y = 1
    yline(1,'--', 'Color', 'r', 'LineWidth', 1)

    % Rotate x-axis labels for better readability
    xtickangle(45)

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


    % Create legend for runtimes (set glibc as the last runtime)
    lgd = legend([runtimes(2:end); runtimes(1)], 'Location', 'bestoutside');
    lgd.Title.String = 'Runtime';


    % Add values on top of the bars (center of the bar) rotated 90 degrees
    for i = 1:numbars
        % Convert to percentages
        percentages = mean_values(:, i) * 100;
        text((1:numgroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*numbars), mean_values(:,i)+0.2, num2str(percentages, '%0.1f%%'), ...
            'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left', 'FontSize', 8, 'Rotation', 90);
    end


end