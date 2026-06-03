function p_goal = simulate_dalton_subtractive(params, model)

v_targ = params(1);
v_nontarg = params(4);
v_routine = params(5);

gamma = params(2:3);
m     = params(end);

n_int_conds = numel(gamma);

num_nontarg_intent = 5;

num_targ_intent = [1 6];

num_routine_states = 1;

n_num_int = numel(num_targ_intent);

p_goal = zeros(n_num_int, n_int_conds, 2);

for ni = 1:n_num_int
    n_states = num_targ_intent(ni) + num_nontarg_intent; % one routine state after each intention
    n_actions = n_states + num_routine_states;  % extra action for routine state

    % <10 for target & >10 for nontarget
    switch ni
        case 1
            % for 1 intention, place the taget somehwere in the middle
            targ_nontarg = [1 11 12 13 14 15 zeros(1, num_routine_states)];

        case 2
            % for 6 intentions, intersperse the targets and nontargets
            targ_nontarg = zeros(1, n_actions);
            targ_nontarg(1:num_targ_intent(ni)) = 1:num_targ_intent(ni);
            targ_nontarg(num_targ_intent(ni)+1:num_targ_intent(ni)+num_nontarg_intent) = (1:num_nontarg_intent)+10;
            % targ_nontarg(1:2:end-num_routine_states+1) = 1:num_targ_intent(ni);
            % targ_nontarg(2:2:end-num_routine_states) = (1:num_nontarg_intent)+10;
    end

    % set values for targets and nontargets
    val = zeros(n_states, n_actions);
    val(:, targ_nontarg<10) = v_targ; % set target value
    val(:, targ_nontarg>10) = v_nontarg; % set nontarget value
    val(:, ~targ_nontarg) = v_routine; % set nontarget value

    for nic = 1:n_int_conds % GI or II
        % form intention
        g = gamma(nic);
        psi = zeros(n_states, n_actions);

        for na = 1:n_actions-num_routine_states
            if targ_nontarg(na)<10
                % for all target actions
                current_action = zeros(1, n_actions);
                current_action(na) = 1;

                for ns = 1:n_states
                    % for each state
                    if targ_nontarg(na)==ns
                        % and it is the intended state for that action, amplify
                        psi(ns,na) = psi(ns,na) + g;

                        % also suppress all other target actions in that state 
                        psi(ns, targ_nontarg<10 & targ_nontarg>0 & ~current_action) = ...
                            psi(ns, targ_nontarg<10 & targ_nontarg>0 & ~current_action) - m*g;

                    else
                        % if it is not the intended state, suppress it
                        psi(ns,na) = psi(ns,na) - m*g;
                    end
                end

                
            end
        end

        % form policy
        pi = zeros(n_states, n_actions);
        for ns = 1:n_states

            U = val(ns,:) + psi(ns,:);
            pi(ns,:) = exp(U) / sum(exp(U));

        end

        p_g = pi(1,1:end);
        for ns = 2:n_states
            p_g = p_g + (1-p_g).*pi(ns,1:end);
        end
        p_goal(ni,nic,1) = mean(p_g(targ_nontarg<10 & targ_nontarg>0)); % target
        p_goal(ni,nic,2) = mean(p_g(targ_nontarg>10)); % nontarget
    end
end
end
