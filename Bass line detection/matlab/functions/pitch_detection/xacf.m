function c = xacf(xc,varargin)
% function d = xacf(x)
% function d = xacf(x,norm)
% function d = xacf(x,norm,xp)
%
% Calculates the the (biased) autocorrelation function. When xp = zero, use xcorr 
% for improved performance!
%
% Arguments:
%   xc   = input block (vector)
%   xp   = previous block (vector)
%   norm = normalization mode: 'coeff','biased','ramp'
%
% Output:
%   d = distance function

L = length(xc);  % number of samples

% Buffer
if nargin > 2
   xp = varargin{2};
else
   xp = zeros(L,1);
end

%% ACF calculation: 

%% method 1
% x_tau = zeros(L);
% for i = 1:L
%     x_tau(:,i) = [xp(end-i+2:end); xc(1:end-i+1)]; 
% end
% c = sum(repmat(xc,1,L).*x_tau).';   % autocorrelation

%% method 2
c = zeros(L,1);
for i = 1:L
    x_tau = [xp(end-i+2:end); xc(1:end-i+1)]; 
    c(i) = sum(xc.*x_tau);
end

%% Normalisation
if nargin > 1
    norm = varargin{1};
    switch norm
        case ''
            return;
        case 'coeff'
            c = c/c(1);
        case 'biased'
            c = c/L;
        case 'ramp'
            tau_max = L;
            c = c.*(1-(1:L)/tau_max).';
    end
end

end
