function p = simulate_masicampo_models(params, model)

switch model
    case 'PC'
        p = simulate_masicampo_compression(params);
    
    case {'ACU', 'CA', 'ACU-A', 'LIM'}
        p = simulate_masicampo(params, model);
end

end