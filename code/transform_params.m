function p = transform_params(x, model, dataset_type)

% safe transforms

softplus = @(x) log(1+exp(x));

v = softplus(x(1));                  % > 0

gamma = softplus(x(2:3));        % ≥ 0

if strcmp(dataset_type,'dalton')
    % for dalton study restrict gamma to ≥ 1

    % for masicampo, the preliminary exp showed a prior pref for the
    % opposite condition (gamma<1), so we allow that

    % for van timmeren and dalton_2 also we allow gamma<1 because there are only 2
    % choices, and people may have prior preference for 1 or the other,
    % esp. when fitting individual subject data
    gamma = 1+gamma; 
end

switch model
    
    case {'ACU', 'LIM'}
        m = softplus(x(end));

        switch dataset_type
            case 'dalton'
                v_low = softplus(x(4));
                v_rout = softplus(x(5));
                p = [v gamma' v_low v_rout m];
            otherwise
                p = [v gamma' m];
        end

    case 'ACU-A'
        gamma = x(2:3);        % for additive model, allow negative values of gamma
        m = softplus(x(4));
        switch dataset_type
            case 'dalton'
                v_low = softplus(x(4));
                v_rout = softplus(x(5));
                p = [v gamma' v_low v_rout m];

            otherwise
                p = [v gamma' m];
        end

    case 'CA'
        switch dataset_type
            case 'dalton'
                v_low = softplus(x(4));
                v_rout = softplus(x(5));
                p = [v gamma' v_low v_rout 0];
            otherwise
                p = [v gamma' 0];
        end

    case 'PC'
        C = softplus(x(end));
        switch dataset_type
            case 'dalton'
                v_low = softplus(x(4));
                v_rout = softplus(x(5));
                p = [v gamma' v_low v_rout C];
            otherwise
                p = [v gamma' C];
        end

end

end