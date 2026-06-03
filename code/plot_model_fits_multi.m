function plot_model_fits_multi(data, fits, condition_labels, baseline, fitResults)

model_names = fieldnames(fits);

%% =========================
%  CHECK DALTON FORMAT
%% =========================
is_dalton = (ndims(data) >= 3 && size(data,1) == 2);

if is_dalton
    
    figure;
    labels_3rd = {'Target','Nontarget','Difference'};
    
    for k = 1:3
        
        subplot(1,3,k); hold on;
        
        if k <= 2
            data_k = squeeze(data(:,:,k));
            
            fits_k = struct();
            for m = 1:numel(model_names)
                fits_k.(model_names{m}) = squeeze(fits.(model_names{m})(:,:,k));
            end
            
        else
            % difference panel
            data_k = squeeze(data(:,:,1) - data(:,:,2));
            
            fits_k = struct();
            for m = 1:numel(model_names)
                fits_k.(model_names{m}) = ...
                    squeeze(fits.(model_names{m})(:,:,1) - fits.(model_names{m})(:,:,2));
            end
        end
        
        plot_model_fits_core_multi(data_k, fits_k, condition_labels, baseline);
        title(labels_3rd{k});
    end
    
    return;
end

%% =========================
%  NORMAL CASE
%% =========================
figure; hold on;
plot_model_fits_core_multi(data, fits, condition_labels, baseline);

end