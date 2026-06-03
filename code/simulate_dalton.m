function p_goal = simulate_dalton(params, model)

v_targ = params(1);
v_nontarg = params(4);
v_routine = params(5);

gamma = params(2:3);
m     = params(end);

n_int_conds = numel(gamma);

num_nontarg_intent = 5;

num_targ_intent = [1 6];

num_routine_actions = 1; % this parameter does not impact the results

n_num_int = numel(num_targ_intent);

p_goal = zeros(n_num_int, n_int_conds, 2);

for ni = 1:n_num_int
    n_targ_intent = num_targ_intent(ni);     % number of target intentions for this condition
    n_states = n_targ_intent + num_nontarg_intent; % one routine state after each intention

    n_actions = n_states + num_routine_actions;  % extra action for routine state

    % <10 for target & >10 for nontarget
    switch ni
        case 1
            % for 1 intention
            targ_nontarg = [1 11 12 13 14 15 zeros(1, num_routine_actions)];

        case 2
            % for 6 intentions
            targ_nontarg = zeros(1, n_actions);
            targ_nontarg(1:n_targ_intent) = 1:n_targ_intent;
            targ_nontarg(n_targ_intent+1:n_targ_intent+num_nontarg_intent) = ...
                (1:num_nontarg_intent)+10;

    end

    % set values for targets and nontargets
    val = zeros(n_states, n_actions);
    val(:, targ_nontarg<10) = v_targ; % set target value
    val(:, targ_nontarg>10) = v_nontarg; % set nontarget value
    val(:, ~targ_nontarg) = v_routine; % set nontarget value


    for nic = 1:n_int_conds % GI or II
        % form intention
        g = gamma(nic);
        psi = ones(n_states, n_actions);

        for na = 1:n_targ_intent 
            % for all target actions
            current_action = zeros(1, n_actions);
            current_action(na) = 1;

            for ns = 1:n_states
                % for each state
                if targ_nontarg(na)==ns
                    % if it is the intended state for that action, amplify
                    psi(ns,na) = psi(ns,na) * g;

                    % and suppress all other target actions in that state
                    psi(ns, targ_nontarg<10 & targ_nontarg>0 & ~current_action) = ...
                        psi(ns, targ_nontarg<10 & targ_nontarg>0 & ~current_action) * g^(-m);

                else
                    % if it is not the intended state, suppress it
                    psi(ns,na) = psi(ns,na) * g^(-m);
                end
            end


        end

        % form policy

        Q = val.*psi;
        w = exp(Q);
        pi = w ./ sum(w,2);

        p_g = pi(1,1:end);
        for ns = 2:n_states
            p_g = p_g + (1-p_g).*pi(ns,:);
        end

        targ_idx = (targ_nontarg<10 & targ_nontarg>0);
        nont_idx = (targ_nontarg>10);

        p_goal(ni,nic,1) = mean(p_g(targ_idx));
        p_goal(ni,nic,2) = mean(p_g(nont_idx));    
    end
end

end
