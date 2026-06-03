%% =========================================================
function plot_model_fits_all(data, model_fits, fitResults, baseline, condition_labels)

model_names = fieldnames(model_fits);
n_models = numel(model_names);

%% =========================
%  CHECK DALTON FORMAT
%% =========================
is_dalton = (ndims(data) == 3 && size(data,1) == 2);

if is_dalton
    
    figure;
    labels_3rd = {'Target','Nontarget','Target - Nontarget'};
    
    for k = 1:3
        
        subplot(1,3,k); hold on;
        
        if k <= 2
            % slice
            data_k = squeeze(data(:,:,k));
            
            fits_k = struct();
            for m = 1:n_models
                name = model_names{m};
                fits_k.(name) = squeeze(model_fits.(name)(:,:,k));
            end
        else
            % difference
            data_k = squeeze(data(:,:,1) - data(:,:,2));
            
            fits_k = struct();
            for m = 1:n_models
                name = model_names{m};
                fits_k.(name) = squeeze(model_fits.(name)(:,:,1) - model_fits.(name)(:,:,2));
            end
        end
        
        plot_model_fits_core_all(data_k, fits_k, fitResults, baseline, condition_labels);
        title(labels_3rd{k});
    end
    
    return;
end
