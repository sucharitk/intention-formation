function pcomp = simulate_masicampo(params, model)

v = params(1);

gamma = params(2:3);

switch model
    case 'LIM'
        lambda = params(end);
    otherwise
        m     = params(end);
end

n_states = 2;
cued_state = 2;
time_cond = [2 1];

pcomp = zeros(2,2);

for n_time_cond = 1:2
    for int_cond = 1:2
        
        g = gamma(int_cond);
        Q = ones(n_states, 2);
        % pi = Q;
        states = 1:n_states;

        % compute Q-vals
        switch model
            case {'ACU', 'CA'}
                % for s = 1:n_states
                Q(states==cued_state,1) = v * g;
                Q(states~=cued_state,1) = v * g^(-m);
                 
            case 'ACU-A'
                Q(states==cued_state,1) = v + g;
                Q(states~=cued_state,1) = v - m*g;

            case 'LIM'
                % for 1 intention, capacity limitation model is identical
                % to CA
                n_goals = 1;
                g_eff = g / (1 + lambda * (n_goals - 1));
                Q(states==cued_state,1) = v * g_eff;
                
        end
        
        pi = exp(Q) ./ sum(exp(Q),2);

        % prob of goal pursuit
        p = pi(1,1);
        for t = 2:time_cond(n_time_cond)
            p = p + (1-p)*pi(t,1);
        end
        
        pcomp(n_time_cond,int_cond) = p;
    end
end

end