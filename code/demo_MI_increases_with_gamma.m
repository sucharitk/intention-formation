demo_MI_vs_gamma_m

%%

function demo_MI_vs_gamma_m()

clc; clear;

% -------------------------
% PARAMETERS
% -------------------------
beta = 1;              % inverse temperature
v_go = 2;              % value of GO
v_nogo = 1;            % value of NO-GO

n_states = 5;          % number of states
cue_state = 3;         % which state is cued

gamma_vals = linspace(1, 5, 30);   % context specificity
m_vals = linspace(0, 3, 30);       % selectivity

MI = zeros(length(gamma_vals), length(m_vals));
MI_GI = compute_MI_GI(beta, v_go, v_nogo, n_states);

% -------------------------
% MAIN LOOP
% -------------------------
for i = 1:length(gamma_vals)
    for j = 1:length(m_vals)
        
        gamma = gamma_vals(i);
        m = m_vals(j);
        
        % compute policy π(a|s)
        pi = zeros(n_states, 2); % columns: [GO, NO-GO]
        
        for s = 1:n_states
            
            % -------------------------
            % ψ(s,a)
            % -------------------------
            psi = ones(1,2);
            
            if s == cue_state
                psi(1) = gamma;         % GO boosted
            else
                % psi(1) = gamma^(-m);    % GO suppressed
            end
            
            % -------------------------
            % Q(s,a)
            % -------------------------
            Q_go   = v_go   * psi(1);
            Q_nogo = v_nogo * psi(2);
            
            % -------------------------
            % softmax
            % -------------------------
            exp_go   = exp(beta * Q_go);
            exp_nogo = exp(beta * Q_nogo);
            
            pi(s,1) = exp_go / (exp_go + exp_nogo);
            pi(s,2) = exp_nogo / (exp_go + exp_nogo);
        end
        
        % -------------------------
        % compute mutual information
        % -------------------------
        MI(i,j) = compute_MI(pi);
        
    end
end

% -------------------------
% PLOT
% -------------------------
figure;
imagesc(m_vals, gamma_vals, MI);
set(gca,'YDir','normal')
xlabel('m (selectivity)');
ylabel('\gamma (context specificity)');
title(sprintf('Mutual Information I(S;A) (GI baseline = %.3f)', MI_GI));
colorbar;

end

% =========================
% GI baseline
% =========================
function MI = compute_MI_GI(beta, v_go, v_nogo, n_states)

pi = zeros(n_states,2);

for s = 1:n_states
    exp_go   = exp(beta * v_go);
    exp_nogo = exp(beta * v_nogo);
    
    pi(s,1) = exp_go / (exp_go + exp_nogo);
    pi(s,2) = exp_nogo / (exp_go + exp_nogo);
end

MI = compute_MI(pi);

end

