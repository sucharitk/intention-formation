function k = get_num_params(model, dataset_type)

switch model

    case 'ACU'
        k = 4;

    case 'CA'
        k = 3;

    case 'PC'
        k = 4;

    case 'ACU-A'
        k = 4;

    case 'LIM'
        k = 4;

end

if strcmp(dataset_type, 'dalton')
    % add to extra parameters
    k = k+2;
end
end