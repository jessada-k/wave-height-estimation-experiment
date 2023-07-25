% Wave height estimation from data collected by a pressure sensor
% Jessada K.
% 2023.7.11

function [w_max, w_min, h_max, h_min, h_av, h_mmax, count, phase] = wave_height(data,fs)
 
    L = length(data);
    Y = fft(data-mean(data));
    p2 = abs(Y/L);               
    p1 = p2(1:L/2+1);
    p1(2:end-1) = 2*p1(2:end-1);
    f = fs*(0:(L/2))/L;
    
    [~,index] = max(p1);
    df = f(index);      % Dominant frequency (Hz)
    T = 1/df;           % Period (Sec)
    W = ceil(T*fs);     % No. of samples in 1 period
    NoDW = floor(L/W);  % No. of dominant wave
    phase = angle(Y(index));
    
    y_seg = zeros(W,NoDW);
    for i = 1:NoDW
        y_seg(:,i) = data((i-1)*W+1:W*i);
    end
    
    y_max = max(y_seg);
    y_min = min(y_seg);
    y_height = y_max-y_min;
    
    h_max = max(y_height);
    h_av = mean(y_height);
    h_min = min(y_height);
    w_max = max(y_max);
    w_min = min(y_min);
    h_mmax = w_max - w_min;
    count = NoDW;
    
end