% Wave height estimation from data collected by a pressure sensor
% Jessada K.
% 2023.7.11

function [spec,f] = find_pos_spectrum(data,fs)

    L = length(data);
    Y = fft(data-mean(data));
    p2 = abs(Y/L);               
    p1 = p2(1:L/2+1);
    p1(2:end-1) = 2*p1(2:end-1);
    f = fs*(0:(L/2))/L;
    spec = p1;
    
end