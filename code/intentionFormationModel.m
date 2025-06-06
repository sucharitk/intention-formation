%% The computational optimality of implementation intentions for goal pursuit
% Sucharit Katyal, Thor Grünbaum, and Søren Kyllingsbæk
%
% Code to implemention a computational model of intention formation that
% explains the psychological literature on how Implementation and Goal
% Intentions impact goal pursuit  
%
%

%%
subjval_intents = [.01 .025 .05 .2 .5 1.4]; % range of expected values of intention setting

state_selectivities = 1:.1:20; % range of state selectivities
n_states = 5; % number of future states
target_trans_state = 3; % state set for transitioning to goal during implementation intention
m = [0, 1, 2]; % suppression exponent

nvi = numel(subjval_intents);
nb = numel(state_selectivities);
nm = numel(m);
tint = NaN(nvi, nb, n_states);
pcomp = NaN(nvi, nb, nm);
figure,
cols = colorSpectrum(nvi*2.2);
cols = cols([1:3,5:7],:);
cols = cols(end:-1:1,:);

for mm = 1:nm
    for vi = 1:nvi
        expectval_intent = subjval_intents(vi);
        for b = 1:nb
            state_selectivity = state_selectivities(b);

            ss = 1/state_selectivity^m(mm);
            tint(vi,b,:) = 1/(1+1/(ss*expectval_intent));
            ss = state_selectivity;
            tint(vi,b,target_trans_state) = 1/(1+1/(ss*expectval_intent));

            pcomp(vi,b,mm) = tint(vi,b,1);
            for ns = 2:n_states
                pcomp(vi,b,mm) = pcomp(vi,b,mm) + (1-pcomp(vi,b,mm))*tint(vi,b,ns);
            end
        end
        subplot(1,nm,mm)
        % hold on
        plot(state_selectivities, pcomp(:,:,mm)', 'LineWidth', 3)
        xlabel('state selectivity', 'FontSize', 18)
        xticks([1 10 20])
    end
    ax = gca;
    ax.ColorOrder = cols;
    ax.FontSize = 18;

end
