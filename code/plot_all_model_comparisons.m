function plot_all_model_comparisons(data, fitResults, condition_labels)

baseline = 'ACU'; % your main model

models = fieldnames(fitResults);
n_models = numel(models);

% ---- collect all fits ----
fits = struct();
for i = 1:n_models
    m = models{i};
    fits.(m) = reshape_fit_to_data(fitResults.(m).fit, data);
    fprintf('Model %s: %.4g, %.4g\n',m,fitResults.(m).AIC, fitResults.(m).BIC)
end

% ---- call plotting ----
plot_model_fits_multi(data, fits, condition_labels, baseline, fitResults);

end