clc

% List of benchmarks (barrier, barrier_rss)
benchmarks = {'contention', 'no_contention'};

figure('Position', [100, 100, 1200, 800]);
% Iterate over the benchmarks
for i = 1:length(benchmarks)
    subplot(2, 1, i);
    % Add benchmark name as subplot title
    plot(benchmarks{i});
    title(benchmarks{i})

    % Save the plot as a png and fig files
    %saveas(gcf, strcat('result/', benchmarks{i}, '.png'));
    %saveas(gcf, strcat('result/', benchmarks{i}, '.fig'));
end



function plot(bench)
    filename = strcat('result/', bench, '.csv');
    data = readtable(filename);

    runtimes = {'native(glibc)', 'native(musl)', 'wasmtime', 'iwasm', 'wasmer'};
    threads = unique(data{:, 'Threads'});

    % Get mean values for each runtime (runtime is a string )
    mean_values = zeros(length(runtimes), length(threads));
    std_values = zeros(length(runtimes), length(threads));

    for i = 1:length(runtimes)
        for j = 1:length(threads)
            runtime = runtimes(i);
            thread = threads(j);

            mean_values(i, j) = data(strcmp(data.Runtime, runtime) & data.Threads == thread, :).Mean;
            std_values(i, j) = data(strcmp(data.Runtime, runtime) & data.Threads == thread, :).StdDev;
        end
    end


    % Normalize the values to the native(glibc) runtime
    std_values = std_values ./ mean_values(1, :);
    mean_values = mean_values ./ mean_values(1, :);

    % Remove the native(glibc) runtime
    mean_values = mean_values(2:end, :);
    std_values = std_values(2:end, :);
    runtimes = runtimes(2:end);

    bar(runtimes, mean_values);

    ylabel('Slowdown (S) (Glibc as baseline)');
    xlabel('Runtime');

    % Plot a red line at y = 1
    yline(1,'--', 'Color', 'r', 'LineWidth', 1)


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


    % Add a legend for the number of threads with title for the number of threads
    lgd = legend(num2str(threads));
    lgd.Title.String = 'Number of Threads';


    % Add values on top of the bars (center of each of the bars) rotated 90 degrees
    for i = 1:numbars
        % Convert to percentages
        percentages = mean_values(:, i) * 100;
        text((1:numgroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*numbars), mean_values(:,i)+0.1, num2str(percentages, '%0.1f%%'), ...
            'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left', 'FontSize', 8, 'Rotation', 90);
    end

    
end
