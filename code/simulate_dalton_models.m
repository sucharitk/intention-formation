function p = simulate_dalton_models(params, model)

switch model
    case 'PC'
        p = simulate_dalton_compression(params);
        
    case 'ACU-A'
        p = simulate_dalton_additive(params);
        
    case {'ACU', 'CA'}
        p = simulate_dalton(params, model);

    case 'LIM'
        % capacity limitation model
        p = simulate_dalton_capacity(params,model);
end

end