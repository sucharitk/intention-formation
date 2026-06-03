function nll = nll_dalton_study2(data, p_target_model, p_nontarget_model, n_subject)

n_target = [5 15];
n_nontarget = [30 20];

nll = 0;

for g = 1:2
    for i = 1:2

        % model difference
        D_model = p_target_model(g,i) - p_nontarget_model(g,i);

        % observed difference
        D_obs = data(g,i);

        % estimate variance
        pT = .5;
        pN = .5;

        % variance of difference of proportions
        var_D = (pT*(1-pT))/n_target(g) + (pN*(1-pN))/n_nontarget(g);

        % safeguard
        var_D = max(var_D, 1e-6) / n_subject;

        % Gaussian negative log likelihood
        nll = nll + 0.5 * log(2*pi*var_D) + ((D_obs - D_model)^2)/(2*var_D);

    end
end

end