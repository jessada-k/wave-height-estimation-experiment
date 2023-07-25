% Wave height estimation from data collected by a pressure sensor
% Jessada K.
% 2023.7.11

function show_graph(data,fs,h,phase)

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
    
    y_seg = zeros(W,NoDW);
    for i = 1:NoDW
        y_seg(:,i) = data((i-1)*W+1:W*i);
    end
    
    fg = figure();
    fg.WindowState = 'maximized';
    subplot(211)
    plot(data,'.-k','MarkerSize',12);
    set(gca,'fontsize',12)
    axis([0 L 0 max(data)+1])
    hold on
    yline(mean(data),'k')
    xlabel('Time (sample)','FontSize',12)
    ylabel('Water surface level (cm)','FontSize',12)
    title('Time series','FontSize',12)
    grid on
    
    subplot(212)
    plot(data-mean(data),'.-k','MarkerSize',12');
    set(gca,'fontsize',12)
    axis([0 L -round(max(data)/2) round(max(data)/2)])
    hold on
    yline(mean(data-mean(data)),'k')
    xlabel('Time (sample)','FontSize',12)
    ylabel('Water surface level (cm)','FontSize',12)
    title('Mean-subtracted time series','FontSize',12)
    grid on
    
    fg = figure();
    fg.WindowState = 'maximized';
    subplot(211)
    plot(data-mean(data),'.-k','MarkerSize',12');
    set(gca,'fontsize',12)
    axis([0 L min(data-mean(data))-1 max(data-mean(data))+1])
    hold on
    yline(mean(data-mean(data)),'k')
    xlabel('Time (sample)','FontSize',12)
    ylabel('Water surface level (cm)','FontSize',12)
    title('Mean-subtracted time series','FontSize',12)
    grid on
    
    subplot(212)
    plot(f,p1,'.-k','MarkerSize',12');
    set(gca,'fontsize',12)
    xlabel('Frequency (Hz)','FontSize',12)
    ylabel('|FFT|','FontSize',12)
    title('Spectrum of mean-subtracted time series','FontSize',12)
    grid on
    
    fg = figure();
    fg.WindowState = 'maximized';
    subplot(211)
    plot(data,'.-k','MarkerSize',12');
    set(gca,'fontsize',12)
    axis([0 1680 min(data)-1 max(data)+1])
    hold on
    yline(mean(data),'k')
    xlabel('Time (sample)','FontSize',12)
    ylabel('Water surface level (cm)','FontSize',12)
    title('Time series with partitions','FontSize',12)
    grid on
    for i = 1:NoDW
        xline(W*i,'k--',"LineWidth",1);
    end
    
    % Add a sinusoidal wave (in red)
    hold on
    Fs = 28;                     % samples per second
    dt = 1/Fs;                   % seconds per sample
    StopTime = 60;               % seconds
    t = (0:dt:StopTime-dt)';     % seconds
    Fc = df;                     % hertz
    x = (h/2)*cos(2*pi*Fc*t+phase) + mean(data);
    plot(x,'.red',"LineWidth",1.5);
    
end