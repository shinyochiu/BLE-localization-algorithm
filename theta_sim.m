
clear all; close all; clc;

fc = 2402e6;%3.744e+9;
c = 299792458;
lambda = c/fc;
d_Multinterval = 0.5; %天线间隔(倍波长)
d12 = lambda * d_Multinterval; %边长
d = d12/sqrt(3);%距圆心距离
AntennaNum = [3 4 5 6 7 8];
% alpha1 = pi/6; alpha2 = 5*pi/6; alpha3 = 3*pi/2;

sigma = sqrt(10^(-2.5));  %标准差
beta_tr = 0   /180*pi;  %仰角
theta_tr = 0 : 0.01 : 2*pi;  %标签绕锚点两周
% scopp = 1; %初始AOA概率分布为均匀分布
simulation_num = 10;  %仿真次数
total_num = simulation_num * length(theta_tr) * length(AntennaNum);
err_num = 0;
rmse_theta_est = zeros(1,length(AntennaNum));
fd = 250000;
%% 计算CRLB
for i = 1 : length(AntennaNum)
    N = AntennaNum(i);
%     alpha = 0 : 2*pi/N : 2*pi-0.001;
%     fisher = sum(4*(pi^2)*(fc^2).*(d^2)/(c^2)/(sigma^2)*sin(0 - alpha).^2);%计算Fisher信息
    fisher = N*((d*2*pi/c).^2)*(1/(2*(sigma)^2))*(fc+fd*(0.9))^2;%2*N*(pi^2)*(fc^2)*(d^2)/(c^2)/(sigma^2);%计算Fisher信息
    theta_crlb(i) = 1/fisher;%计算CRLB
end

%% 仿真数据并计算AOA
for ss = 1 : length(AntennaNum)
    N = AntennaNum(ss)
    alpha = 0 : 2*pi/N : 2*pi-0.001;
    scopp = 1;
    for n = 1 : simulation_num
        for i = 1 : length(theta_tr)
            while theta_tr(i)>2*pi
                theta_tr(i) = theta_tr(i)-2*pi;
            end
            for j = 1 : N %生成原始相位
                phi_ob(j) = -2*pi*fc/c*d*cos(beta_tr)*cos(theta_tr(i) - alpha(j)) + randn*sigma;%仿真生成ABC天线的phi
            end
            for j = 1 : N %计算两两相位差
                if j < N
                    phi_dif_ob(j) = phi_ob(j)-phi_ob(j+1);
                else
                     phi_dif_ob(j) = phi_ob(j)-phi_ob(1);
                end
            end
            for j = 1 : N %将相位差搬移至-pi到pi，模拟实际接收到的数据
                if phi_dif_ob(j)>pi 
                    phi_dif_ob(j) = phi_dif_ob(j) - 2*pi;
                elseif phi_dif_ob(j)<-pi
                    phi_dif_ob(j) = phi_dif_ob(j) + 2*pi;
                end
            end
            [theta_est(n,i)] = AOA_ML_theta(theta_tr(i), phi_dif_ob);%调用定位算法
            if theta_est(n,i) - theta_tr(i) > 6%这部分代码使得0度和360度误差没有差别
                theta_est(n,i) = theta_est(n,i) - 2*pi;
            end
            if theta_est(n,i) - theta_tr(i) < -6
                theta_est(n,i) = theta_est(n,i) + 2*pi;
            end
            if abs(theta_est(n,i) - theta_tr(i)) > 20/180*pi
                err_num = err_num + 1;
            end
        end
%         if mod(n,10)==0
%             n
%         end
    end
    rmse_theta_est(ss) = sqrt(mean(mean((theta_est - theta_tr).^2)));%计算均方根误差
    var_theta_est(ss) = mean(var(theta_est));
end
rmse_theta_est = rmse_theta_est/pi*180;
sqrttheta_crlb = sqrt(theta_crlb)/pi*180;
% save rmse_theta_est.mat rmse_theta_est;
% save theta_crlb.mat theta_crlb;

%% 画图



figure
plot(AntennaNum, rmse_theta_est, 'b','LineWidth',2); hold on;
plot(AntennaNum, sqrttheta_crlb,'r','LineWidth',2);
set(gca,'XTick',AntennaNum)
legend('AOA-ML','crlb');
xlabel('Antenna Number');
ylabel('RMSE');
title('AOA-RMSE under Different Antenna Number')

% figure
% plot(0:720/(length(rmse_theta_est)-1):720,rmse_theta_est,'b','LineWidth',2); hold on;
% plot(0:720/(length(rmse_theta_est)-1):720,sqrt(theta_crlb),'r','LineWidth',2);
% legend('AOA-ML','crlb');
% xlabel('Angle(degree)');
% ylabel('RMSE');

mean(rmse_theta_est)
err_rate = err_num / total_num


