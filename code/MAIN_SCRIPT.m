%% Fitting Masicampo & Baumeister (2012)

% data from the paper
p_success = [.680 .955; .714 .367]; % rows: time condition, cols: goal vs. implementation intention

study = 'masicampo';  
n_subj_per_cond = 25;

% fit models
fitResults = fit_models_dataset(p_success, study, n_subj_per_cond);

% plot 
condition_labels = {'Planned Cue Available','Planned Cue Omitted'};
plot_all_model_comparisons(p_success, fitResults, condition_labels)

%% Fitting Dalton & Spiller (2012) Study 1

p_success(:,:,1) = [.40 .61; .48 .43]; % rows: number of intentions, cols: goal vs. implementation intention
p_success(:,:,2) = [.48 .44; .42 .48]; % rows: number of intentions, cols: goal vs. implementation intention

study = 'dalton';  
n_subj_per_cond = 17;
fitResults = fit_models_dataset(p_success, study, n_subj_per_cond);

% Compare your model vs associative
plot_all_model_comparisons(p_success, fitResults, ...
    {'One Intention','Six Intentions'});

%% Fitting Dalton & Spiller (2012) Study 2

p_success = [.002 .045; .006 -.003]; % rows: number of intentions, cols: goal vs. implementation intention

study = 'dalton_2';  
n_subj_per_cond = 54;
fitResults = fit_models_dataset(p_success, study, n_subj_per_cond);

% Compare your model vs associative
plot_all_model_comparisons(p_success, fitResults, ...
    {'One Intention','Three Intentions'});

%% Fit van Timmeren & de Wit (2023) Study 1

% load data
data = readtable('vanTimmeren2023_Study1.xlsx', 'Sheet', 'SSG_IIGI_betw-subj_FINAL_OSF');

Testacc_sv = data.Testacc_sv;
Testacc_up = data.Testacc_up;
Testacc_sn = data.Testacc_sn;
Testacc_de = data.Testacc_de;

group = data.Group_II1_or_GI2;
included = data.incl;

gg = group==1 & included==1;
accu_II = [mean(Testacc_sv(gg)), mean(Testacc_up(gg)),...
    mean(Testacc_sn(gg)), mean(Testacc_de(gg))];
gg = group==2 & included==1;
accu_GI = [mean(Testacc_sv(gg)), mean(Testacc_up(gg)),...
    mean(Testacc_sn(gg)), mean(Testacc_de(gg))];

data2fit = [accu_GI; accu_II]';
data2fit = data2fit/100;

data2fit(data2fit==1) = .999;
data2fit(data2fit==0) = .001;

study = 'vanTimmeren';  
n_subj_per_cond = 35;

fitResults = fit_models_dataset(data2fit, study, n_subj_per_cond);

plot_all_model_comparisons(data2fit, fitResults, ...
    {'Still Valuable', 'Upvalued', 'Still Not Valuable', 'Devalued'});


%% Fit van Timmeren & de Wit (2023) Study 1

data = readtable('vanTimmeren2023_Study2.xlsx', 'Sheet', 'SSG_IIGI_within-subj_FINAL_OSF');

Testacc_sv_II = data.Testacc_sv_II;
Testacc_up_II = data.Testacc_up_II;
Testacc_sn_II = data.Testacc_sn_II;
Testacc_de_II = data.Testacc_de_II;
Testacc_sv_GI = data.Testacc_sv_GI;
Testacc_up_GI = data.Testacc_up_GI;
Testacc_sn_GI = data.Testacc_sn_GI;
Testacc_de_GI = data.Testacc_de_GI;

included = logical(data.Incl);

accu_II = [Testacc_sv_II, Testacc_up_II,...
    Testacc_sn_II, Testacc_de_II];
accu_GI = [Testacc_sv_GI, Testacc_up_GI,...
    Testacc_sn_GI, Testacc_de_GI];

data2fit = [];
data2fit(:,:,1)=accu_GI(included, :)/100;
data2fit(:,:,2)=accu_II(included, :)/100;
data2fit(data2fit==1) = .999;
data2fit(data2fit==0) = .001;

study = 'vanTimmeren';  
n_subj_per_cond = 1;
fitResults = fit_models_dataset(data2fit, study, n_subj_per_cond);

% Compare your model vs associative
plot_all_model_comparisons(data2fit, fitResults, ...
    {'Still Valuable', 'Upvalued', 'Still Not Valuable', 'Devalued'});


plot_parameters(fitResults.ACU.params, {'Value', '\gamma_G_I', '\gamma_I_I', 'm'})


%% Simulate toy example from paper - Figure 2

simulate_IntentionFormation

