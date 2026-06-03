function results = fit_models_dataset(data, dataset_type, nTotalSubjects)

% dataset_type: 'vanTimmeren' | 'dalton' | 'masicampo'

models = {'ACU', 'CA', 'PC', 'LIM'};

is_subject = nTotalSubjects == 1; % if nSubjects is set to 1, then we have subjectwise data, otherwise aggregated data

if ~is_subject
    data = reshape(data, [1 size(data)]);
    nsub = 1;
else
    nsub = size(data,1);
end


for mi = 1:numel(models)
    
    model = models{mi};
    fprintf('Fitting %s on %s\n', model, dataset_type);
    
    params_all = [];
    fits_all = [];
    nll_all = 0;
    
    for s = 1:nsub
        
        d = squeeze(data(s,:,:,:));
        
        num_params = get_num_params(model, dataset_type);
        
        x0 = .5*ones(num_params,1);
        x0(3) = 1;

        fun = @(x) negloglik(x, model, d, dataset_type, nTotalSubjects);
        
        opts = optimset('Display','off');

        ub = 15*ones(size(x0)); 
        A = zeros(1,numel(ub)); A(2:3) = [1 -1];
        b = -.05;
        [xhat,fval(s)] = fmincon(fun, x0, A, b, [], [], [], ub, [], opts);

        p = transform_params(xhat, model, dataset_type);
        pred = simulate_dataset(p, model, dataset_type);
        
        params_all(s,:) = p;
        fits_all(s,:,:,:) = pred;
        
        nll_all = nll_all + fval(s);
       
    end
    
    % ---- model comparison ----
    k = num_params;
    N = numel(data);
    
    AIC = 2*k + 2*nll_all;
    BIC = k*log(N) + 2*nll_all;
    
    if strcmp(model, 'ACU-A')
        model = 'ACU_A';
    end
    results.(model).params = params_all;
    results.(model).fit = fits_all;
    results.(model).nll = nll_all;
    results.(model).AIC = AIC;
    results.(model).BIC = BIC;
end

end