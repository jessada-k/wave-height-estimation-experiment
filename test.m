% Wave height estimation from data collected by a pressure sensor
% Jessada K.
% 2023.7.11

clear
clc
close all

fs = 28;                % Sampling frequency (Data collection)

load Y.mat              % Signals (Time series) from the sensor
load G.mat              % Water surface levels from VDO

Y = Yd_matrix;          
G = Gd_matrix;          % 1st row = max in 1-min
                        % 2nd row = min in 1-min
                        % 3rd row = count (no. of dominant waves)
[m,n] = size(Y);

w_max = zeros(1,n);     % Max of water surface level (wsl)
gw_max = G(1,:);
w_min = zeros(1,n);     % Min of water surface level (wsl)
gw_min = G(2,:);
h_max = zeros(1,n);     % Max height
h_min = zeros(1,n);     % Min height
h_av = zeros(1,n);      % Average height
h_mmax = zeros(1,n);    % Max(wsl) - Min(wsl)
gh_mmax = gw_max - gw_min;
count = zeros(1,n);     % No of dominant waves
phase = zeros(1,n);     % Phase of dominant waves
gcount = G(3,:);

for i = 1:n
    [w_max(i), w_min(i), h_max(i), h_min(i), h_av(i), h_mmax(i), count(i), phase(i)] = wave_height(Y(:,i),fs);
end

% Correlation coefficient
r_w_max = corrcoef(gw_max,w_max);
r_w_min = corrcoef(gw_min,w_min);
r_h_mmax = corrcoef(gh_mmax,h_mmax);
r_h_max = corrcoef(gh_mmax,h_max);

disp('=================================================================');
disp(['Correlation Coefficient (Max of Water Surface Level) = ' num2str(r_w_max(2))]);
disp(['Correlation Coefficient (Min of Water Surface Level) = ' num2str(r_w_min(2))]);
disp(['Correlation Coefficient (Max of WSL - Min of WSL) = ' num2str(r_h_mmax(2))]);
disp(['Correlation Coefficient (Max - Min vs Max wave height) = ' num2str(r_h_mmax(2))]);
disp('=================================================================');

% Mean absolute error
mae_w_max = mean(abs(gw_max - w_max));
mae_w_min = mean(abs(gw_min - w_min));
mae_h_mmax = mean(abs(gh_mmax - h_mmax));
mae_h_max = mean(abs(gh_mmax - h_max));

disp('================================================');
disp(['MAE (Max of Water Surface Level) = ' num2str(mae_w_max) ' cm.']);
disp(['MAE (Min of Water Surface Level) = ' num2str(mae_w_min) ' cm.']);
disp(['MAE (Max of WSL - Min of WSL) = ' num2str(mae_h_mmax) ' cm.']);
disp(['MAE (Max - Min vs Max wave height) = ' num2str(mae_h_mmax) ' cm.']);
disp('================================================');

% Compare Max WSL
figure;
set(gcf,'position',[10,10,600,600])
plot(w_max,gw_max,'.k','MarkerSize',20)
set(gca,'fontsize',12)
axis([16 26 16 26])
axis square
hold on
plot([16 26],[16 26],'--k')
grid on
xlabel('Maximum water surface level (cm) from the proposed method','FontSize',12)
ylabel('Maximum water surface level (cm) from the VDO clip','FontSize',12);

% Compare Min WSL
figure;
set(gcf,'position',[10,10,600,600])
plot(w_min,gw_min,'.k','MarkerSize',20)
set(gca,'fontsize',12)
axis([10 19 10 19])
axis square
hold on
plot([10 19],[10 19],'--k')
grid on
xlabel('Minimum water surface level (cm) from the proposed method','FontSize',12)
ylabel('Minimum water surface level (cm) from the VDO clip','FontSize',12);

% Compare Max-Min wave height
figure;
set(gcf,'position',[10,10,600,600])
plot(h_mmax,gh_mmax,'.k','MarkerSize',20)
set(gca,'fontsize',12)
axis([4 11 4 11])
axis square
hold on
plot([4 11],[4 11],'--k')
grid on
xlabel('Wave height (cm) from the proposed method','FontSize',12)
ylabel('Wave height (cm) from the VDO clip','FontSize',12);

%% Display plots
sig_id = 30;    % sig_id can be 1 to 35
show_graph(Y(:,sig_id),fs,h_av(sig_id),phase(sig_id));

%% Additional Analysis
% Construct 5-min signals from Y
Y5 = zeros(5*m,7);
for i=1:7
    Y5(:,i) = [Y(:,1+5*(i-1));Y(:,2+5*(i-1));Y(:,3+5*(i-1));Y(:,4+5*(i-1));Y(:,5+5*(i-1))];
end

% Construct 10-min signals from Y
Y10 = zeros(10*m,3);
for i=1:3
    Y10(:,i) = [Y5(:,1+2*(i-1));Y5(:,2+2*(i-1))];
end

% Construct 30-min signals from Y
Y30 = [Y10(:,1);Y10(:,2);Y10(:,3)];

% Plot the first signals of 5-min, 10-min, and 30-min time series
fg = figure();
fg.WindowState = 'maximized';
subplot(311)
plot(Y5(:,1),'.-k','MarkerSize',8');
set(gca,'fontsize',12)
axis([0 5*m min(Y5(:,1))-1 max(Y5(:,1))+1])
grid on
yline(mean(Y5(:,1)),'k')
%xlabel('Time (sample)','FontSize',12)
%ylabel('Water surface level (cm)','FontSize',12)
title('5-min time series','FontSize',12)

subplot(312)
plot(Y10(:,1),'.-k','MarkerSize',8');
set(gca,'fontsize',12)
axis([0 10*m min(Y10(:,1))-1 max(Y10(:,1))+1])
grid on
yline(mean(Y10(:,1)),'k')
%xlabel('Time (sample)','FontSize',12)
ylabel('Water surface level (cm)','FontSize',12)
title('10-min time series','FontSize',12)

subplot(313)
plot(Y30(:,1),'.-k','MarkerSize',8');
set(gca,'fontsize',12)
axis([0 30*m min(Y30(:,1))-1 max(Y30(:,1))+1])
grid on
yline(mean(Y30(:,1)),'k')
xlabel('Time (sample)','FontSize',12)
%ylabel('Water surface level (cm)','FontSize',12)
title('30-min time series','FontSize',12)


%% Compute delta_r
disp('================================');
disp(['delta_140 (1-min) = ' num2str(mean(Y(1:140,1)) - mean(Y(end-141:end,1))) ' cm']);
disp(['delta_140 (5-min) = ' num2str(mean(Y5(1:140,1)) - mean(Y5(end-141:end,1))) ' cm']);
disp(['delta_140 (10-min) = ' num2str(mean(Y10(1:140,1)) - mean(Y10(end-141:end,1))) ' cm']);
disp(['delta_140 (30-min) = ' num2str(mean(Y30(1:140,1)) - mean(Y30(end-141:end,1))) ' cm']);
disp('================================');

%% Plot spectra of 5-min, 10-min, and 30-min signals

[p1,f] = find_pos_spectrum(Y5(:,1),fs);
fg = figure();
fg.WindowState = 'maximized';
subplot(311)
plot(f,p1,'.-k','MarkerSize',8');
set(gca,'fontsize',12)
axis([0 2 min(p1) max(p1)])
hold on
grid on
yline(mean(Y5(:,1)),'k')
%xlabel('Time (sample)','FontSize',12)
%ylabel('Water surface level (cm)','FontSize',12)
title('Spectrum of mean-subtracted 5-min time series','FontSize',12)

[p1,f] = find_pos_spectrum(Y10(:,1),fs);
subplot(312)
plot(f,p1,'.-k','MarkerSize',8');
set(gca,'fontsize',12)
axis([0 1 min(p1) max(p1)])
hold on
grid on
yline(mean(Y10(:,1)),'k')
%xlabel('Time (sample)','FontSize',12)
ylabel('|FFT|','FontSize',12)
title('Spectrum of mean-subtracted 10-min time series','FontSize',12)

[p1,f] = find_pos_spectrum(Y30(:,1),fs);
subplot(313)
plot(f,p1,'.-k','MarkerSize',8');
set(gca,'fontsize',12)
axis([0 0.75 min(p1) max(p1)])
hold on
grid on
yline(mean(Y30(:,1)),'k')
xlabel('Frequency (Hz)','FontSize',12)
%ylabel('Water surface level (cm)','FontSize',12)
title('Spectrum of mean-subtracted 30-min time series','FontSize',12)
