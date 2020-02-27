close all, clear all
BLE=BLE_config();
M = 3:8;
d_r = BLE.R./sin(2*pi./M).*sin((pi-2*pi./M)/2)-0.01; % array radius
%d_r = BLE.R/sqrt(3);
fc = BLE.freq;
fd = 250000;
c = BLE.c;
%sig_d = 10;
N = 80;
epsilon = 0.;

% for e = 1:20
%     FI_AOA(1,e) = (2*pi*d_r/c)^2*(fc+fd*(0.9+e/100))^2;
%     for k = 2:N
%         FI_AOA(k,e) = FI_AOA(k-1,e) + (2*pi*d_r/c)^2*(fc+fd*(0.9+e/100))^2;
%     end
% end
%sig_d = sqrt(10.^((0:-0.5:-5)));
sig_d = sqrt(10^(-1.5)); % phase noise
db = 0:5:50;
% calculate fisher information
for i = 1:numel(sig_d)
    FI_AOA_n(1,i) = (1/(2*(sig_d(i))^2))*(fc+fd*(0.9))^2;
    for k = 2:N
        FI_AOA_n(k,i) = FI_AOA_n(k-1,i) + (1/(2*(sig_d(i))^2))*(fc+fd*(0.9))^2;
    end
end

% for sig_d = 1:10
%     FI_epsilon_n(1,sig_d) = (1/(2*(sig_d*pi/180)^2))*((2*pi*d_r*fd/c)^2 + 2*(pi*mod(1,8)/8)^2);
%     for k = 2:N
%         FI_epsilon_n(k,sig_d) = FI_epsilon_n(k-1,sig_d) + (1/(2*(sig_d*pi/180)^2))*((2*pi*d_r*fd/c)^2 + 2*(pi*mod(k,8)/8)^2);
%     end
% end
% antenna number =3:8
% noise = 10^-1.5
RMSE=[1.014396372233264;0.699106572705480;0.489387372129688;0.392109678533954;0.311849322590253;0.264102252924885];
RMSE_2=[0.769902591241258;0.532916503778971;0.385681215513538;0.310644491340181;0.243413228892762;0.189076704011891];
RMSE_c=[0.810092587300985,0.538980519128476,0.381444622455214,0.315039680040467,0.244948974278318,0.206760731281354];
% noise = 10^-2
% RMSE = [0.608175550314216;0.401886177916086;0.284011443431423;0.222643212337588;0.169425499851705;0.142249780316175];
% RMSE_2 = [0.475197327433562;0.309790251621965;0.231559927448599;0.169933810644027;0.128500972758964;0.108408947970175];
% RMSE_c = [0.447548880012004,0.286561511721306,0.217657988596790,0.155892591228705,0.118764472802266,0.0994736145920116];
% noise = 10^-3.5
% RMSE = [0.138356423775696;0.088867879461592;0.063146654701576;0.048989794855665;0.040496913462635;0.034532593299666];
% RMSE_2 = [0.112238585165709;0.072594765651527;0.051889305256480;0.041922547632511;0.034387497728100;0.029832867780354];
% RMSE_c = [0.0862699252346965,0.0575760366819400,0.0423379262600344,0.0322490309931959,0.0265518360947054,0.0217944947177044];
crlb = sqrt(1./(FI_AOA_n(80,1).*M.*(d_r*2*pi/c).^2));
plot(3:8,crlb(:)*180/pi,'DisplayName','Root CRLB of AOA','LineWidth',2);
hold on;
plot(3:8,RMSE(1:6),'DisplayName','RMSE of  estimation at step 1','LineWidth',2,'LineStyle','--');
hold on;
plot(3:8,RMSE_2(1:6),'DisplayName','RMSE of estimation at step 2','LineWidth',2,'LineStyle','--');
hold on;
plot(3:8,RMSE_c(1:6),'DisplayName','RMSE of estimation at step 5','LineWidth',2,'LineStyle','--');
set(gca,'xtick',3:8);
xlabel('antenna number');
ylabel('RMSE [degree]');
legend();
% %N=80
% RMSE=[6.17478744573447,4.02998138953519,2.50898385805888,1.57829021412413,0.985393322486001,0.601040764008565,0.321714158842908,0.167332005306815,0.115108644332213,0.0500000000000000,0];
% RMSE_c=[6.00845237977302,3.90666097838039,1.91167465851279,1.14214710085873,0.814401620823535,0.403112887414928,0.255440795488896,0.150000000000000,0.0948683298050514,0.0387298334620742,0];
% plot(db,crlb*180/pi,'DisplayName','Root CRLB of AOA','LineWidth',2);
% hold on;
% plot(db,RMSE,'DisplayName','RMSE of  estimation at step 1','LineWidth',2,'LineStyle','--');
% hold on;
% plot(db,RMSE_c,'DisplayName','RMSE of estimation at step 2','LineWidth',2,'LineStyle','--');
% xlabel('dB');
% ylabel('RMSE [degree]');
% legend();