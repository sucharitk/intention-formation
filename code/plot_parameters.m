function plot_parameters(param_matrix, param_names)

% param_matrix = n_subject x n_parameter
% param_names  = cell array of parameter labels
%
% Example:
% plot_acu_parameters(params, {'gamma','m','beta'})

[nsub, nparam] = size(param_matrix);

if nargin < 2
    param_names = cell(1,nparam);
    for i = 1:nparam
        param_names{i} = sprintf('P%d', i);
    end
end

%% =========================
% COMPUTE MEAN + SEM
%% =========================
param_mean = mean(param_matrix,1);
param_sem  = std(param_matrix,0,1) ./ sqrt(nsub);

x = 1:nparam;

%% =========================
% PLOT
%% =========================
figure;
hold on;

bar_col = [0.7 0.7 0.7];

for i = 1:nparam
    
    % ---- bar ----
    bar(x(i), param_mean(i), 0.6, ...
        'FaceColor', 'w', ...
        'EdgeColor', 'k', ...
        'LineWidth', 1.5);
    
    % ---- SEM ----
    errorbar(x(i), param_mean(i), param_sem(i), ...
        'k', ...
        'LineStyle','none', ...
        'LineWidth',1.8);

    % ---- mean label ----
    y_text = param_mean(i) + .2 ;%+ 0.03*range(param_mean);

    text(x(i)+.25, y_text, ...
        sprintf('%.2f', param_mean(i)), ...
        'HorizontalAlignment','center', ...
        'VerticalAlignment','bottom', ...
        'FontSize',11, ...
        'FontWeight','bold');
end

%% =========================
% OPTIONAL SUBJECT DOTS
%% =========================
jitter = 0.15;

for i = 1:nparam
    x_jitter = x(i) + (rand(nsub,1)-0.5)*2*jitter;
    
    scatter(x_jitter, param_matrix(:,i), ...
        35, ...
        'k', ...
        'filled', ...
        'MarkerFaceAlpha',0.3, ...
        'MarkerEdgeAlpha',0.3);
end

%% =========================
% AXES
%% =========================
set(gca, ...
    'XTick', x, ...
    'XTickLabel', param_names, ...
    'FontSize', 12);

ylabel('Parameter value');
xlim([0.5 nparam+0.5]);

% give some headroom for labels
ylim_curr = ylim;
ylim([ylim_curr(1), ylim_curr(2)*1.15]);

box off;
title('ACU Parameter Estimates');

end