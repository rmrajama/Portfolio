function y = medianfilt(x,n,varargin)
% y = medianfilt(x,n)
% y = medianfilt(x,n,order)
%
% Non-linear median filtering.
%
% Arguments:
%   x     = input signal vector
%   n     = median filter window length. Can also be a vector if order > 1 [samples]
%   order = filtering order (i.e. how many times the filtering is applied)
%
% Output:
%   y = output signal vector

%% Error handling

% Filtering order
if nargin >2
    order = varargin{1};
else
    order = 1;
end

% Window length
n(~mod(n,2)) = n(~mod(n,2))-1;  % decrement even n's by 1 (n should be odd)
n = max(n,1);                   % n must be >= 1
ln = length(n);
if ln == 1 && order > 1         % handling of different length n and filtering order
    n = n*ones(order,1);
elseif ln > 1 && ln ~= order
    error('The length of n must = order or 1!')
end

%% Apply median filtering iteratively
y = x;
for j = 1:order
    y = applyMedianfilter(y,n(j)); % subfunction call
end

%% Subfunction
function y = applyMedianfilter(x,n)
    %% Precalculation
    N = length(x);
    y = zeros(N,1);
    x_temp = [zeros((n-1)/2,1); x(:); zeros((n-1)/2,1)]; % temporary variable padded with zeros at the start and end

    %% Filtering
    for i = 1:N
        y(i) = median(x_temp(i:i+n-1));
    end

end
end