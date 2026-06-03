function plot_from_fitResults(data, fitResults, modelA, modelB, condition_labels)

% modelA, modelB: strings, e.g. 'gating', 'associative'

% extract fits
fitA = fitResults.(modelA).fit;
fitB = fitResults.(modelB).fit;

% reshape to match data
fitA = reshape_fit_to_data(fitA, data);
fitB = reshape_fit_to_data(fitB, data);

% plot
plot_model_fits(data, fitA, fitB, condition_labels);

title(sprintf('%s (%.4g,%.4g) vs %s (%.4g,%.4g) ', ...
    modelA, mean(fitResults.(modelA).AIC), mean(fitResults.(modelA).BIC), ...
    modelB, mean(fitResults.(modelB).AIC), mean(fitResults.(modelB).BIC)));

end