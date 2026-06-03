clear; clc;

%% =========================
% TRUE PARAMETER GRID
%% =========================

% v_grid     = [0.5 1 2];
% gamma_grid = [1.2 2 3];
% m_grid     = [0.5 1 2];
v_grid     = .5:.5:4;
gamma_grid = 1:.5:4;
m_grid     = 0:5;

n_rep = 1;   % repetitions per combo

results = [];

idx = 1;

%%% =========================
% LOOP OVER PARAMETERS
%%% =========================
for v_true = v_grid
    for g_true = gamma_grid
        for m_true = m_grid
            for r = 1:n_rep

                true_params = [v_true g_true m_true];

                %%% -------------------------
                % simulate dataset
                %%% -------------------------
                data_sim = simulate_dataset_vt(true_params);

                %%% -------------------------
                % recover parameters
                %%% -------------------------
                x0 = [log(1) log(2) log(1)];

                loss_fn = @(x) recovery_loss_vt(x, data_sim);

                % bounds in LOG-space
                lb = [log(0.1) log(.8) log(0.01)];
                ub = [log(8)   log(15)  log(10)];
                

                opts = optimoptions('fmincon', ...
                    'Display','off', ...
                    'Algorithm','interior-point');

                xhat = fmincon( ...
                    loss_fn, ...
                    x0, ...
                    [], [], [], [], ...
                    lb, ub, ...
                    [], ...
                    opts);

                v_rec = exp(xhat(1));
                g_rec = exp(xhat(2));
                m_rec = exp(xhat(3));

                %%% -------------------------
                % store results
                %%% -------------------------
                results(idx).true = true_params;
                results(idx).rec  = [v_rec g_rec m_rec];

                idx = idx + 1;

            end
        end
    end
end

%%%
true_vals = vertcat(results.true);
rec_vals  = vertcat(results.rec);

names = {'v_{high}','\gamma_I_I','m'};

figure;

for i = 1:3

    x_all = true_vals(:,i);
    y_all = rec_vals(:,i);

    % ---------------------------------
    % Percentile-based trimming
    % ---------------------------------
    x_lo = prctile(x_all,5);
    x_hi = prctile(x_all,95);

    y_lo = prctile(y_all,5);
    y_hi = prctile(y_all,95);

    keep_idx = ...
        x_all >= x_lo & x_all <= x_hi & ...
        y_all >= y_lo & y_all <= y_hi;

    x = x_all(keep_idx);
    y = y_all(keep_idx);

    % Correlation on filtered plot
    r = corr(x,y);

    subplot(1,3,i); hold on;

    scatter(x, y, 60, 'filled');

    lims = [min([x; y]) max([x; y])];
    plot(lims, lims, 'k--');

    xlabel(['True ' names{i}]);
    ylabel(['Recovered ' names{i}]);
    title(sprintf('%s (r = %.2f, n=%d)', names{i}, r, sum(keep_idx)));
    box off;

end
%% =========================
% PLOT RECOVERY
%% =========================

true_vals = vertcat(results.true);
rec_vals  = vertcat(results.rec);

names = {'v_{goal}','\gamma_2','m'};

figure;

for i = 1:3
    
    x = true_vals(:,i);
    y = rec_vals(:,i);

    % correlation
    r = corr(x,y);

    subplot(1,3,i); hold on;
    
    scatter(x, y, 60, 'filled');
    
    plot([min(x) max(x)], ...
         [min(x) max(x)], 'k--');
    
    xlabel(['True ' names{i}]);
    ylabel(['Recovered ' names{i}]);
    title(sprintf('%s (r = %.2f)', names{i}, r));
    box off;
    
end


%%
function data = simulate_dataset_vt(params)

v_high = params(1);
gamma2 = params(2);
m      = params(3);

model = 'gating'; % or your full model name

p_goal = simulate_vanTimmeren([v_high 1 gamma2 m], model);

data = p_goal;

end

%%

function nll = recovery_loss_vt(x, data)

v_high = exp(x(1));
gamma2 = exp(x(2));
m      = exp(x(3));

params = [v_high 1 gamma2 m];

model = 'gating';

pred = simulate_vanTimmeren(params, model);

epsv = 1e-8;
pred = min(max(pred, epsv), 1-epsv);

nll = -sum(data(:).*log(pred(:)) + (1-data(:)).*log(1-pred(:)));

end