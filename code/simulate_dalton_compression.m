function p_goal = simulate_dalton_compression(params, model)
% KL-regularized compression model for Dalton, using the SAME variable
% n_states/n_actions setup as your CAU backup function.
%
% Output matches CAU:
%   p_goal(ni,nic,1) = mean p_g over target actions
%   p_goal(ni,nic,2) = mean p_g over nontarget actions
%
% params = [v_targ, gamma_GI, gamma_II, v_nontarg, v_routine, tau]

v_targ    = params(1);
gamma     = params(2:3);
v_nontarg = params(4);
v_routine = params(5);
tau       = params(end);

n_int_conds = numel(gamma);

num_nontarg_intent = 5;
num_targ_intent    = [1 6];
num_routine_actions = 1;

n_num_int = numel(num_targ_intent);
p_goal = zeros(n_num_int, n_int_conds, 2);

% stable softmax for row vector
% softmax_col = @(x) (exp(x') ./ sum(exp(x')))';
softmax_row = @(X) exp(X - max(X,[],2)) ./ sum(exp(X - max(X,[],2)), 2);

for ni = 1:n_num_int
    n_targ_intent = num_targ_intent(ni);
    n_states = n_targ_intent + num_nontarg_intent;
    n_actions = n_states + num_routine_actions;

    % --- action labeling (exactly as in your CAU backup) ---
    switch ni
        case 1
            % 1 target + 5 nontarget + routine
            targ_nontarg = [1 11 12 13 14 15 zeros(1, num_routine_actions)];
        case 2
            % 6 targets + 5 nontarget + routine
            targ_nontarg = zeros(1, n_actions);
            targ_nontarg(1:n_targ_intent) = 1:n_targ_intent;
            targ_nontarg(n_targ_intent+1:n_targ_intent+num_nontarg_intent) = (1:num_nontarg_intent)+10;
    end

    % --- values (same as CAU) ---
    val = zeros(n_states, n_actions);
    val(:, targ_nontarg<10 & targ_nontarg>0) = v_targ;
    val(:, targ_nontarg>10)                 = v_nontarg;
    val(:, targ_nontarg==0)                 = v_routine;


    % --- default policy pi0  ---
    % one way to construct defualt policy is to make it uniform across
    % states
    % Q0 = ones(n_states, n_actions);
    % pi0 = softmax_col(Q0);
    % another possibility is to have high probability only for routine
    % state
    Q0 = zeros(n_states, n_actions);
    Q0(:,end) = 10;
    pi0 = softmax_row(Q0);
    log_pi0 = log(pi0);
    
    for nic = 1:n_int_conds
        g = gamma(nic);

        % --- contextual association weights (no suppression) ---
        psi = ones(n_states, n_actions);
        for na = 1:n_targ_intent
            % s_cue = a;                % match your CAU mapping
            % psi(s_cue, a) = psi(s_cue, a) * g;
            for ns = 1:n_states
                % for each state
                if targ_nontarg(na)==ns
                    % if it is the intended state for that action, amplify
                    psi(ns,na) = psi(ns,na) * g;

                end
            end
        end

        Q = val .* psi;

        % --- KL policy: pi(a|s) ∝ pi0(a)*exp(tau*Q(s,a)) ---

        logw = log_pi0 + tau*Q;
        logw = logw - max(logw,[],2);
        w = exp(logw);
        pi = w ./ sum(w,2);

        % --- sequential accumulation (same as CAU) ---
        p_g = pi(1,:);
        for s = 2:n_states
            p_g = p_g + (1 - p_g) .* pi(s,:);
        end

        targ_idx = (targ_nontarg<10 & targ_nontarg>0);
        nont_idx = (targ_nontarg>10);

        p_goal(ni,nic,1) = mean(p_g(targ_idx));
        p_goal(ni,nic,2) = mean(p_g(nont_idx));
    end
end

end