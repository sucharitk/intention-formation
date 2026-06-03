function pred = simulate_dataset(params, model, dataset_type)

switch dataset_type
    
    case 'vanTimmeren'
        pred = simulate_vanTimmeren_models(params, model);
        
    case 'dalton'
        pred = simulate_dalton_models(params, model);
        
    case 'masicampo'
        pred = simulate_masicampo_models(params, model);

    case 'dalton_2'
        pred = simulate_dalton_study2_allmodels(params, model);
        
    otherwise
        error('Unknown dataset type');
end

end