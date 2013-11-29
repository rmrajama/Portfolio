function d = xamdf(x,varargin)
% function d = xamdf(x)
% function d = xamdf(x,norm)
% function d = xamdf(x,norm,xb)
%
% Calculates the the average magnitude distance function.
%
% Arguments:
%   xc   = input block (vector)
%   xb   = previous block (vector)
%   norm = normalization mode: 'coeff','biased'
%
% Output:
%   d = distance function

L = length(x);  % number of samples

% Buffer
if nargin > 2
   xb = varargin{2};
else
   xb = zeros(L,1);
end

%% Distance calculation: 

%% Method 1
% if length(varargin) == 2
%    xp = varargin{2};
% else
%    xp = zeros(L,1);
% end
% 
% x_tau = zeros(L);
% for i = 1:L
% %     x_tau(i:end,i) = xc(1:end-i+1);
%     x_tau(:,i) = [xp(end-i+2:end); xc(1:end-i+1)]; 
% end
% % d = mean(abs(repmat(x,1,L)-x_tau)).';   % definition 1
% d = mean((repmat(xc,1,L)-x_tau).^2).';   % definition 2

%% Method 2
% d = mean((repmat(x,1,L)-tril(toeplitz(x))).^2).'; % slow...

%% Method 3

d = zeros(L,1);
for i = 1:L
    x_tau = [xb(end-i+2:end); x(1:end-i+1)];
    d(i) = sum((x-x_tau).^2);
%     d(i) = sum(abs(x-x_tau));
end

%% Normalisation
if nargin > 1
    norm = varargin{1};
    switch norm
        case ''
            return;
        case 'coeff'
            d = d/max(d);
        case 'biased'
            d = d/L;
        case 'cmnd' % cumulative mean normalized difference
            d = d./(cumsum(d).*(1./(0:(L-1))).');
            d(1) = 1;
    end
end