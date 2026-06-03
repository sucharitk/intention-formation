function [p_goal, p_correct_targ, p_correct_nontarg] = simulate_dalton_study2_allmodels(params, model)
% Study 2 (Dalton & Spiller): multiple cues -> same action (GO)
% Models: 'CAU', 'CA', 'CAPC', 'CAI'
%
% OUTPUT:
% p_goal(goal_condition, intention_condition)
%   goal_condition: 1 = 1 goal, 2 = 3 goals
%   intention_condition: 1 = GI, 2 = II

%% PARAMETERS

v_go = params(1);          % value of responding (press)
gamma = params(2:3);       % [GI, II]

switch model
    case {'ACU', 'ACU-A'}
        m = params(4);     % selectivity
    case 'LIM'
        lambda = params(4); % interference
    case 'PC'
        tau = params(4);   % compression precision
end

v_nogo = 1;  % baseline for not responding

%% TASK STRUCTURE

goal_conditions = [1 3];   % number of targets
n_goals = numel(goal_conditions);

n_items_total = 7;        % (5 numbers, 5 letters approx.)
n_states = n_items_total;

softmax_rows = @(U) exp(U - max(U,[],2)) ./ sum(exp(U - max(U,[],2)),2);

p_goal = zeros(n_goals,2);
p_correct_nontarg = p_goal;
p_correct_targ = p_goal;
%% LOOP

for ng = 1:n_goals

    n_targets = goal_conditions(ng);

    target_idx = 1:n_targets;
    distractor_idx = (n_targets+1):n_states;

    %% BASE VALUES
    val = zeros(n_states,2);  % columns: [GO, NOGO]
    val(:,1) = v_go;
    val(:,2) = v_nogo;

    for ic = 1:2  % GI vs II

        g = gamma(ic);

        % ----------------------------
        % MODEL-SPECIFIC ψ CONSTRUCTION
        % ----------------------------

        if strcmp(model, 'ACU-A')
            psi = zeros(n_states,2);
        else
            psi = ones(n_states,2);
        end

        switch model

            case 'CA'
                % Only amplify targets
                psi(target_idx,1) = g;

            case 'ACU'
                % Amplify targets + suppress others proportionally to N

                for i = target_idx
                    % amplify current target
                    psi(i,1) = psi(i,1) * g;

                    % suppress all other states
                    other_states = setdiff(1:n_states,i);
                    psi(other_states,1) = psi(other_states,1) * g^(-m);
                end

            case 'ACU-A'
                % Amplify targets + suppress others proportionally to N

                for i = target_idx
                    % amplify current target
                    psi(i,1) = psi(i,1) + g;

                    % suppress all other states
                    other_states = setdiff(1:n_states,i);
                    psi(other_states,1) = psi(other_states,1) - m*g;
                end

            case 'LIM'
                % Interference: degrade gamma
                g_eff = g / (1 + lambda * (n_targets - 1));
                psi(target_idx,1) = g_eff;

            case 'PC'
                % same as CA for ψ, compression applied later
                psi(target_idx,1) = g;

        end

        % ----------------------------
        % POLICY
        % ----------------------------

        Q = val .* psi;

        switch model
            case 'PC'
                % KL-compression policy
                prob_targ = n_targets/n_items_total;
                pi0 = [prob_targ 1-prob_targ]; % default policy depends on the number of targets 
                % pi0 = [.5 .5];
                logw = log(pi0) + tau * Q;
                pi = softmax_rows(logw);

            otherwise
                pi = softmax_rows(Q);
        end

        % ----------------------------
        % OUTPUT METRIC
        % ----------------------------
        % probability of correct response:
        % target states -> GO
        % distractors -> NOGO

        p_correct_targ(ng,ic) = mean(pi(target_idx,1));      % GO correct
        p_correct_nontarg(ng,ic) = mean(pi(distractor_idx,2)) ;    % NOGO correct


    end
end
p_goal = p_correct_targ - p_correct_nontarg;

end