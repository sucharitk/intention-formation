function pi = softmax_rows(U)
% stable row-wise softmax for U: [nStates x nActions]
U = U - max(U, [], 2);
pi = exp(U) ./ sum(exp(U), 2);
end
