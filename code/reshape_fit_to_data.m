function fit_out = reshape_fit_to_data(fit_in, data)

if ndims(data) == 3
    % subject-level
    fit_out = reshape(fit_in, size(data));
else
    % aggregate
    fit_out = reshape(fit_in, size(data));
end

end