
function simulate_IntentionFormation
%% The computational optimality of implementation intentions for goal pursuit
% Sucharit Katyal, Thor Grünbaum, and Søren Kyllingsbæk
%
% Code to simulate toy example in the paper
%
%

beta = 1;
softmax_fn = @(d1,d2) exp(beta * d1) ./ (exp(beta * d1) + exp(beta * d2));

%
subjval_intents = [.05:.1:.25, .75:.5:2] ; % range of expected values of intention setting

context_specificities = 1.0:.05:5; % range of state selectivities

n_states = 4; % number of future states
cued_state = 2; % state set for transitioning to goal during implementation intention
m = [0, 2, 4]; % anticipated execution reliability / suppression exponent

n_subjval = numel(subjval_intents);
n_contspec = numel(context_specificities);
nm = numel(m);
trans_prob = NaN(n_subjval, n_contspec, n_states);
p_goal = NaN(n_subjval, n_contspec, nm);

figure,
cols = colorSpectrum(n_subjval*2.2);
cols = cols([1:3,5:7],:);
cols = cols(end:-1:1,:);

for mm = 1:nm
    for vi = 1:n_subjval
        expectval_intent = subjval_intents(vi);
        for b = 1:n_contspec
            context_specificity = context_specificities(b);

            % suppress context specicificity non-cued states
            ss = 1/context_specificity^m(mm);
            trans_prob(vi,b,:) = softmax_fn(ss*expectval_intent, 1);

            % heighten context specificity from cued state
            ss = context_specificity;
            trans_prob(vi,b,cued_state) = softmax_fn(ss*expectval_intent, 1);

            p_goal(vi,b,mm) = trans_prob(vi,b,1);
            for ns = 2:n_states
                p_goal(vi,b,mm) = p_goal(vi,b,mm) + (1-p_goal(vi,b,mm))*trans_prob(vi,b,ns);
            end
        end
        subplot(1,nm,mm)

        plot(context_specificities, p_goal(:,:,mm)', 'LineWidth', 2.5)
        xlabel('state selectivity', 'FontSize', 14)
        xticks([])
        % yticks([.75 1])
    end
    ax = gca;
    ax.ColorOrder = cols;
    ax.FontSize = 12;
    ax.XLim = [.75 5];
end

end