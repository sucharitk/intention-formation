function p_goal = simulate_vanTimmeren_compression(params, model)

v_high = params(1);
v_low = 1;

gamma = params(2:3);
tau  = params(4);

N = 4; % number of intentions

% 1: is NOGO is rewarded, 2 is GO is rewarded
train_vals = [2 1 1 2]; % intention value at formation
test_vals  = [2 2 1 1];  % intention value at test

softmax = @(X) exp(X - max(X,[],2)) ./ sum(exp(X - max(X,[],2)), 2);

p_goal = zeros(N,2);

log_pi0 = log([0.5 0.5]);  % uniform prior over NOGO and GO

for cond = 1:2

    g = gamma(cond);
    psi = ones(N,2); % col1: NOGO, col2: GO
    
    j = 1:N; % all intentions

    for i = 1:N
        % for each intention

        for a = 1:2 % actions: NOGO and GO
            if a==train_vals(i)

                % amplify the action in current state
                psi(j==i, a) = psi(j==i,a) * g;

            end
        end

    end

    for i = 1:N
        if test_vals(i)==2
            % GO correct in the test phase
            Q = [v_low v_high].*psi(i,:);
            logw = log_pi0 + tau*Q;
            pi = softmax(logw);
            p_goal(i,cond) = pi(2);

        else
            % NOGO correct in the test phase
            Q = [v_high v_low].*psi(i,:);
            logw = log_pi0 + tau*Q;
            pi = softmax(logw);
            p_goal(i,cond) = pi(1);
        end
    end

end


end