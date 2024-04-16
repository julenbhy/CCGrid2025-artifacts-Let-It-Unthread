clc
benchmarks = {"blackscholes", "fluidanimate", "merge-sort", "parallel-grep", "parallel-mat-mul", "swaptions"};
threads = 64;


% Iterate over the benchmarks
for i = 1:length(benchmarks)
    % Read the data for the benchmark
    disp('Reading data for ' + benchmarks{i})
    bench = benchmarks{i};
    filename = strcat('result/', bench, '.csv');
    data = readtable(filename);

    % Get the unique runtimes
    runtimes = unique(data.Runtime, 'stable');

    % Get the mean values for each runtime
    for j = 1:length(runtimes)
        runtime = runtimes(j);
    
        mean_values(j, i) = data(strcmp(data.Runtime, runtime) & data.Threads == threads, :).Time;
        std_values(j, i) = data(strcmp(data.Runtime, runtime) & data.Threads == threads, :).StdDev;
    end

end


% Normalize the values to the native(glibc) runtime
std_values = std_values ./ mean_values(1, :);
mean_values = mean_values ./ mean_values(1, :);


figure('Position', [100, 100, 1200, 600]);

hold on
bar(runtimes, mean_values);

title({threads} + " threads");
ylabel('Mean time (s)');
xlabel('Runtime');

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
lgd = legend(benchmarks);
lgd.Title.String = 'Benchmark';


% Add values on top of the bars (center of the bar) (dont add values for the first runtime)
for i = 1:numbars
    % Convert to percentages
    percentages = mean_values(:, i) * 100;
    text((1:numgroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*numbars), mean_values(:,i)+10, num2str(percentages, '%0.1f%%'), ...
        'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left', 'FontSize', 8, 'Rotation', 90);
end

