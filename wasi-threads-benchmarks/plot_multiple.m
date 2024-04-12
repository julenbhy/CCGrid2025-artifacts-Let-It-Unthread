clc
benchmarks = {"blackscholes", "fluidanimate", "merge-sort", "parallel-grep", "parallel-mat-mul", "swaptions"};



% Iterate over the benchmarks
for i = 1:length(benchmarks)
    plot(benchmarks{i});
end



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

            mean_values(i, j) = data(strcmp(data.Runtime, runtime) & data.Threads == thread, :).Time;
            std_values(i, j) = data(strcmp(data.Runtime, runtime) & data.Threads == thread, :).StdDev;
        end
    end

    figure('Position', [100, 100, 1200, 600]);

    hold on
    bar(runtimes, mean_values);

    ylabel('Mean time (s)');
    title({bench});


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

    % Add values on top of the bars (center of the bar)
    for i = 1:numbars
        text((1:numgroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*numbars), mean_values(:,i)+0.05, num2str(mean_values(:,i), '%0.2f'), ...
            'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center');
    end

end