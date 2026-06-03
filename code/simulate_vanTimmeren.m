function p_goal = simulate_vanTimmeren(params, model)

v_high = params(1);
v_low = 1;

gamma = params(2:3);
m     = params(end);

softmax = @(d1,d2) exp(d1) ./ (exp(d1) + exp(d2));


% 1: is NOGO is rewarded, 2 is GO is rewarded
train_vals = [2 1 1 2]; % intention value at formation
test_vals  = [2 2 1 1];  % intention value at test

N = numel(train_vals); % number of intentions


p_goal = zeros(N,2);

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

                % suppress the action in other states
                psi(j~=i, a) = psi(j~=i,a) * (1/g^m);

            end
        end

    end

    for i = 1:N
        if test_vals(i)==2
            % GO correct in the test phase
            p_goal(i,cond) = softmax(v_high * psi(i,2), v_low * psi(i,1));
        else
            % NOGO correct in the test phase
            p_goal(i,cond) = softmax(v_high * psi(i,1), v_low * psi(i,2));
        end
    end
end

end