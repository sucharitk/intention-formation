function nll = negloglik(x, model, data, dataset_type, nTotalSubjects)

p = transform_params(x, model, dataset_type);

if strcmp(dataset_type, 'dalton_2')
    [pred, p_targ, p_nontarg] = simulate_dalton_study2_allmodels(p, model);
else
    pred = simulate_dataset(p, model, dataset_type);
end

pred = reshape(pred, size(data));

eps_val = 1e-8;
pred = max(min(pred,1-eps_val), eps_val);

switch dataset_type
    case 'dalton'
        % in dalton different subjects and conditions had different number of
        % trial, so likelihood needs to scale accordingly
        Neff(:,:,1) = [1 1; 6 6];
        Neff(:,:,2) = [5 5; 5 5];

        n_days = 5; % each intention was to be followed every day for 5 days

        % here nTotalSubjects is number of subjects per condition

        nll = -sum(n_days*nTotalSubjects*Neff(:).*(data(:).*log(pred(:)) + (1-data(:)).*log(1-pred(:))));

    case 'dalton_2'
        % in dalton 2 different conditions had different number of
        % trial, so likelihood needs to be calculated accordingly

        nll = nll_dalton_study2(data, p_targ, p_nontarg, nTotalSubjects);

    case 'vanTimmeren'
        % each test trial was repeated 4 times/block and there were 2 per
        % condition, and there 4 blocks
        num_trials = 4*4*2;
        nll = -nTotalSubjects*num_trials*sum(data(:).*log(pred(:)) + (1-data(:)).*log(1-pred(:)));

    case 'masicampo'
            nll = -nTotalSubjects*sum(data(:).*log(pred(:)) + (1-data(:)).*log(1-pred(:)));

end

end