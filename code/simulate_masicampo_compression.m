function pcomp = simulate_masicampo_compression(params)

v = params(1);

gamma = params(2:3);
tau   = params(end);

n_states = 2;
cued_state = 2;
time_cond = [2 1];

pcomp = zeros(2,2);

states = 1:n_states;

for n_time_cond = 1:2
    for int_cond = 1:2
        
        g = gamma(int_cond);
        Q = ones(n_states, 2);
        Q0 = Q;

        % default policy
        % Q0(states==cued_state,1) = v; % does not matter if the default
        % policy is based on reward or is uniform: results are the same
        log_pi0 = log(exp(Q0)./sum(exp(Q0),2));

        Q(states==cued_state,1) = v * g;

        logw = log_pi0 + tau*Q;
        w = exp(logw);
        pi = w ./ sum(w,2);

        % prob of goal pursuit
        p = pi(1,1);
        for t = 2:time_cond(n_time_cond)
            p = p + (1-p)*pi(t,1);
        end
        
        pcomp(n_time_cond,int_cond) = p;
    end
end

end