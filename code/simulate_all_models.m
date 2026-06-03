function pred = simulate_all_models(params, model)

switch model
    
    case {'gating','associative','independent'}
        vt  = simulate_vanTimmeren(params, model);
        dal = simulate_dalton(params, model);
        mas = simulate_masicampo(params, model);
        
    case 'global_gain'
        vt  = simulate_vanTimmeren_gain(params);
        dal = simulate_dalton_gain(params);
        mas = simulate_masicampo_gain(params);
        
    case 'compression'
        vt  = simulate_vanTimmeren_compression(params);
        dal = simulate_dalton_compression(params);
        mas = simulate_masicampo_compression(params);
end

pred = [vt(:); dal(:); mas(:)];

end