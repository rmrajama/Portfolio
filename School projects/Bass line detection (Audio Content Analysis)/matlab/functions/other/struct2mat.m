function [M names] = struct2mat(S)
% function [M names] = struct2mat(S)
%
% Convert the structure S into a numerical matrix M.
%
% Arguments:
%   S = struct containing (identical) elements with numeric fields
%
% Output:
%   M     = matrix with struct field values
%   names = cell array with labels corresponding to the rows of M 

%% Init
names = fieldnames(S(1));
N_field = length(names);
N_el = length(S);
M = zeros(N_field,N_el);

%% Read elements of S into M
for i = 1:N_el
    for j = 1:N_field
        M(j,i) = getfield(S(i),names{j});
    end
end

end