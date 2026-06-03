function plot_model_fits(data, cuu_fit, ca_fit, condition_labels)

%% =========================
%  CHECK IF DALTON FORMAT
%% =========================
is_dalton = (ndims(data) == 3 && size(data,1) == 2);

if is_dalton
    
    figure;
    
    labels_3rd = {'Target','Nontarget'};
    
    for k = 1:2
        
        subplot(1,3,k); hold on;
        
        % slice data
        if ndims(data) == 4
            data_k = squeeze(data(:,:,:,k));
            cuu_k  = squeeze(cuu_fit(:,:,:,k));
            ca_k   = squeeze(ca_fit(:,:,:,k));
        else
            data_k = squeeze(data(:,:,k));
            cuu_k  = squeeze(cuu_fit(:,:,k));
            ca_k   = squeeze(ca_fit(:,:,k));
        end
        
        % call SAME plotting logic (recursive reuse)
        plot_model_fits_core(data_k, cuu_k, ca_k, condition_labels);
        
        title(labels_3rd{k});
    end
    
    subplot(1,3,3), hold on
    plot_model_fits_core(squeeze(data(:,:,1)-data(:,:,2)), ...
        squeeze(cuu_fit(:,:,1)-cuu_fit(:,:,2)), ...
        squeeze(ca_fit(:,:,1)-ca_fit(:,:,2)), condition_labels);

    
    return;
end

%% =========================
%  NORMAL CASE
%% =========================
figure; hold on;
plot_model_fits_core(data, cuu_fit, ca_fit, condition_labels);

end

function plot_model_fits_core(data, cuu_fit, ca_fit, condition_labels)

is_subject_level = (ndims(data) == 3);

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
    
    % CUU
    cuu_mean = squeeze(mean(cuu_fit,1));
    
    cuu_norm = cuu_fit;
    subj_mean_cuu = mean(cuu_fit, [2 3]);
    for s = 1:size(cuu_fit,1)
        cuu_norm(s,:,:) = cuu_fit(s,:,:) - subj_mean_cuu(s) + mean(cuu_fit(:));
    end
    
    cuu_sem_raw = squeeze(std(cuu_norm,0,1) ./ sqrt(size(cuu_fit,1)));
    cuu_sem = cuu_sem_raw * corr_factor;
    
    % CA
    ca_mean = squeeze(mean(ca_fit,1));
    
    ca_norm = ca_fit;
    subj_mean_ca = mean(ca_fit, [2 3]);
    for s = 1:size(ca_fit,1)
        ca_norm(s,:,:) = ca_fit(s,:,:) - subj_mean_ca(s) + mean(ca_fit(:));
    end
    
    ca_sem_raw = squeeze(std(ca_norm,0,1) ./ sqrt(size(ca_fit,1)));
    ca_sem = ca_sem_raw * corr_factor;

else
    data_mean = data;
    data_sem = zeros(size(data));
    
    cuu_mean = cuu_fit;
    cuu_sem = zeros(size(cuu_fit));
    
    ca_mean = ca_fit;
    ca_sem = zeros(size(ca_fit));
    
    ncond = size(data,1);
end

%% ===== plotting (unchanged) =====
bar_width = 0.35;
x = 1:size(data_mean,1);

col_GI = [0 0.45 0.74];
col_II = [0.85 0.33 0.10];
col_CUU = [0 0 0];
col_CA  = [0.5 0.5 0.5];

x_GI = x - bar_width/2;
x_II = x + bar_width/2;

for i = 1:size(data_mean,1)
    
    bar(x_GI(i), data_mean(i,1), bar_width, ...
        'FaceColor','none','EdgeColor',col_GI,'LineWidth',1.5);
    
    errorbar(x_GI(i), data_mean(i,1), data_sem(i,1), ...
        'Color', col_GI, 'LineStyle','none','LineWidth',1.5);
    
    bar(x_II(i), data_mean(i,2), bar_width, ...
        'FaceColor','none','EdgeColor',col_II,'LineWidth',1.5);
    
    errorbar(x_II(i), data_mean(i,2), data_sem(i,2), ...
        'Color', col_II, 'LineStyle','none','LineWidth',1.5);
end

offset = 0.06;

for i = 1:size(data_mean,1)
    
    x_cuu = [x_GI(i)-offset, x_II(i)-offset];
    y_cuu = [cuu_mean(i,1), cuu_mean(i,2)];
    
    plot(x_cuu, y_cuu, '-o', 'Color', col_CUU, ...
        'MarkerFaceColor', col_CUU, 'LineWidth', 1.5);
    
    errorbar(x_cuu, y_cuu, ...
        [cuu_sem(i,1), cuu_sem(i,2)], ...
        'Color', col_CUU, 'LineStyle','none', 'LineWidth', 1.5);
    
    x_ca = [x_GI(i)+offset, x_II(i)+offset];
    y_ca = [ca_mean(i,1), ca_mean(i,2)];
    
    plot(x_ca, y_ca, '--o', 'Color', col_CA, ...
        'MarkerFaceColor', col_CA, 'LineWidth', 1.5);
    
    errorbar(x_ca, y_ca, ...
        [ca_sem(i,1), ca_sem(i,2)], ...
        'Color', col_CA, 'LineStyle','none', 'LineWidth', 1.5);
end

set(gca, 'XTick', x, 'XTickLabel', condition_labels);
ylabel('Probability');

xlim([0.5, length(x) + 0.5]);
% ylim([0 1]);

box off;
set(gca,'FontSize',16);

end