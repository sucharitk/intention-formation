function p = simulate_vanTimmeren_models(params, model)

switch model
    case 'PC'
        p = simulate_vanTimmeren_compression(params);
        
    case 'ACU-A'
        p = simulate_vanTimmeren_additive(params, model);
        
    case {'ACU', 'CA'}
        p = simulate_vanTimmeren(params, model);

    case 'LIM'
        p = simulate_vanTimmeren_capacity(params, model);
end

end