clc

% List of benchmarks (barrier, barrier_rss)
benchmarks = {'create', 'create_rss'};

% Iterate over the benchmarks
plot('create');
title('Thread creation time comparison');
ylabel('Time (s)')

plot('create_rss');
title('Thread creation Max RSS comparison');
ylabel('Max RSS (KB)')





function plot(bench)
    filename = strcat('result/', bench, '.csv')
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
            std_values(i, j) = data(strcmp(data.Runtime, runtime) & data.Threads == thread, :).StDev;
        end
    end


    figure('Position', [100, 100, 1200, 600]);

    hold on
    bar(runtimes, mean_values);


    % Add error bars
    hold on;
    numgroups = size(mean_values, 1);
    numbars = size(mean_values, 2);
    groupwidth = min(0.8, numbars/(numbars+1.5));
    for i = 1:numbars
        x = (1:numgroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*numbars);
        errorbar(x, mean_values(:,i), std_values(:,i), 'k', 'linestyle', 'none');
    end
    hold off;


    % Add a legend for the number of threads with title for the number of threads
    lgd = legend(num2str(threads), "Location", "best");
    lgd.Title.String = 'Number of Threads';


    % Add values on top of the bars (center of each of the bars) rotated 90 degrees
    for i = 1:numbars
        % Convert to percentages
        percentages = mean_values(:, i);
        text((1:numgroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*numbars), mean_values(:,i)+mean_values(:,i)*0.1, num2str(percentages, '%0.4f%'), ...
            'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left', 'FontSize', 8, 'Rotation', 90);
    end
end
