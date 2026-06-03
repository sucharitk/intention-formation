function plot_model_fits_core_multi(data, fits, condition_labels, baseline, fitResults)

model_names = fieldnames(fits);
n_models = numel(model_names);

is_subject_level = (ndims(data) == 3);

%% =========================
%  COMPUTE DATA STATS
%% =========================
if is_subject_level
    
    nsub = size(data,1);
    ncond = size(data,2);
    
    subj_mean = mean(data, [2 3]);
    
    data_norm = data;
    for s = 1:nsub
        data_norm(s,:,:) = data(s,:,:) - subj_mean(s) + mean(data(:));
    end
    
    data_mean = squeeze(mean(data,1));
    data_sem_raw = squeeze(std(data_norm,0,1) ./ sqrt(nsub));
    
    corr_factor = sqrt(ncond/(ncond-1));
    data_sem = data_sem_raw * corr_factor;
    
else
    data_mean = data;
    data_sem = zeros(size(data));
end

%% =========================
%  PLOT DATA
%% =========================
bar_width = 0.35;
x = 1:size(data_mean,1);

col_GI = [0 0 0];        % black outline
col_II = [0.8 0.8 0.8];  % filled grey

x_GI = x - bar_width/2;
x_II = x + bar_width/2;

hold on

for i = 1:size(data_mean,1)
    
    % ---- GI = white fill, black outline ----
    bar(x_GI(i), data_mean(i,1), bar_width, ...
        'FaceColor','w', ...
        'EdgeColor','k', ...
        'LineWidth',.8);
    
    if is_subject_level
        errorbar(x_GI(i), data_mean(i,1), data_sem(i,1), ...
            'Color', col_GI, ...
            'LineStyle','none', ...
            'LineWidth',1.5);
    end
    
    % ---- II = filled grey ----
    bar(x_II(i), data_mean(i,2), bar_width, ...
        'FaceColor',col_II, ...
        'EdgeColor','k', ...
        'LineWidth',.8);

    if is_subject_level
        errorbar(x_II(i), data_mean(i,2), data_sem(i,2), ...
            'Color', col_GI, ...
            'LineStyle','none', ...
            'LineWidth',1.5);
    end
end

%% =========================
%  MODEL STYLE SETTINGS
%% =========================

markers = {'o','s','d','^','v','>','<','p','h'};
linestyles = {'-','--',':','-.'};

base_alpha = 1.0;
other_alpha = 1;

max_offset = 0.12;
offsets = linspace(-max_offset, max_offset, n_models);

%% =========================
%  PLOT MODELS
%% =========================
color_idx = 1;

model_colors = [
    0.00 0.45 0.70;
    0.85 0.33 0.10;
    0.47 0.67 0.19;
    0.49 0.18 0.56;
    ];

desat_factor = 0;

for m = 1:n_models
    
    name = model_names{m};
    fit = fits.(name);
    
    if is_subject_level
        fit_mean = squeeze(mean(fit,1));
    else
        fit_mean = fit;
    end
    
    marker = markers{mod(m-1,numel(markers))+1};
    linestyle = linestyles{mod(m-1,numel(linestyles))+1};

    if strcmp(name, baseline)
        col = [0 0 0];
        lw = 2.5;
        alpha = base_alpha;
    else
        base_col = model_colors(color_idx,:);
        col = base_col*(1-desat_factor) + desat_factor*[1 1 1];
        lw = 1.5;
        alpha = other_alpha;
        color_idx = color_idx + 1;
    end
    
    offset = offsets(m);
    
    for i = 1:size(data_mean,1)
        
        jitter = 0.01;

        x_vals = [x_GI(i)+offset-jitter, x_II(i)+offset+jitter];
        y_vals = [fit_mean(i,1), fit_mean(i,2)];

        p = plot(x_vals, y_vals, ...
            'LineStyle', linestyle, ...
            'Marker', marker, ...
            'Color', col, ...
            'LineWidth', lw, ...
            'MarkerSize', 6);

        try
            p.Color = [col alpha];
        catch
            p.Color = col;
        end

        if strcmp(name, baseline)
            p.MarkerFaceColor = col;
        else
            p.MarkerFaceColor = 'none';
        end

        p.MarkerEdgeColor = col;
    end
end

%% =========================
%  AXES
%% =========================
set(gca, 'XTick', x, 'XTickLabel', condition_labels);
ylabel('Probability');

xlim([0.5, length(x) + 0.5]);
box off;
set(gca,'FontSize',12);

%% =========================
%  LEGEND WITH AIC
%% =========================
h = [];
labels = {};

% ---- DATA LEGEND AS BOXES ----

% GI = white box with black outline
h(end+1) = bar(nan,nan, ...
    'FaceColor','w', ...
    'EdgeColor','k', ...
    'LineWidth',.8);
labels{end+1} = 'GI';

% II = filled grey box
h(end+1) = bar(nan,nan, ...
    'FaceColor',col_II, ...
    'EdgeColor','k', ...
    'LineWidth',.8);
labels{end+1} = 'II';

% ---- MODELS ----
color_idx = 1;

for m = 1:n_models
    
    orig_name = model_names{m};
    name = orig_name;

    if strcmp(name, 'ACU_A')
        name='ACU-A'; 
    end
    
    marker = markers{mod(m-1,numel(markers))+1};
    linestyle = linestyles{mod(m-1,numel(linestyles))+1};
    
    if strcmp(orig_name, baseline)
        col = [0 0 0];
        lw = 2.5;
    else
        base_col = model_colors(color_idx,:);
        col = base_col*(1-desat_factor) + desat_factor*[1 1 1];
        lw = 1.5;
        color_idx = color_idx + 1;
    end
    
    if nargin > 4 && isfield(fitResults.(orig_name),'AIC')
        aic_val = mean(fitResults.(orig_name).AIC);
        label = sprintf('%s (AIC=%.1f)', name, aic_val);
    else
        label = name;
    end
    
    h(end+1) = plot(nan,nan, ...
        'LineStyle', linestyle, ...
        'Marker', marker, ...
        'Color', col, ...
        'MarkerFaceColor', col, ...
        'LineWidth', lw);
    
    labels{end+1} = label;
end

legend(h, labels, ...
    'Location','northoutside', ...
    'Orientation','horizontal', ...
    'Box','off');

end