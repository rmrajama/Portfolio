function [fq iq] = quantizeToBin(fu,f)
% [fq iq] = quantizeToBin(fu,f)
% 
% Quantize the value fu to the nearest value in f.
%
% Arguments:
%   fu = unquantized element
%   f  = vector with quantized values
%
% Output:
%   fq = quantized element
%   iq = index of quantized element in f

%% Quantize fu to the nearest bin
df = f(2)-f(1);
iq = round(fu/df)+1;          % bin index of fq
iq(iq>length(f) | iq<1) = 1;  % out of range bins to 0
fq = f(iq);                   % quantized output


end