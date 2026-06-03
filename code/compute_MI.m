% =========================
% Mutual Information
% =========================
function MI = compute_MI(pi)

% assume uniform state distribution
[n_states, n_actions] = size(pi);

p_s = ones(n_states,1) / n_states;

% marginal p(a)
p_a = zeros(1,n_actions);
for a = 1:n_actions
    p_a(a) = sum(p_s .* pi(:,a));
end

MI = 0;

for s = 1:n_states
    for a = 1:n_actions
        
        if pi(s,a) > 0
            MI = MI + p_s(s) * pi(s,a) * log(pi(s,a) / p_a(a));
        end
        
    end
end

end