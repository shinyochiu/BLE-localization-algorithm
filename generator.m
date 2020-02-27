function [phase]=generator(theta,fd,n_factor,antenna_num)
% input: signal AOA, GFSK offset frequency
% output : sudo phase difference data
BLE=BLE_config();
lambda=BLE.c/BLE.freq;
M=antenna_num; % element number
N=8; % sampling number
T=10; % sampling period
r = 4e6; % sampling rate
ARRAY=zeros(M,3);
d_r = BLE.R/sin(2*pi/M)*sin((pi-2*pi/M)/2)-0.01;
%d_r = BLE.R/sqrt(3);
for m=1:M
    ARRAY(m,:) = d_r*[cos(2*pi*(1-m)/M),sin(2*pi*(1-m)/M),0];
end
% ARRAY(1,:)=[-BLE.R/2,-BLE.R/2/sqrt(3),0];
% ARRAY(2,:)=[0,BLE.R/sqrt(3),0];
% ARRAY(3,:)=[BLE.R/2,-BLE.R/2/sqrt(3),0];
phase=zeros(N*T,M);
phase_0=psuedo(ARRAY,theta,lambda); 
for m=1:M
    %f_d = fd*(1+unifrnd(-0.1,0.1));
    for n=1:N*T
        phase(n,m)=phase_0(m) + mod((n-1),N)*2*pi*fd/r + randn*sqrt(10^n_factor);
    end
end
phase(phase>2*pi)=phase(phase>2*pi)-2*pi;
phase(phase<0)=phase(phase<0)+2*pi;
% figure();
% subplot(3,1,1);
% stem(phase(:,1));
% subplot(3,1,2);
% stem(phase(:,2));
% subplot(3,1,3);
% stem(phase(:,3));
end
    
function phase=psuedo(ARRAY,theta,lambda)
for ii=1:size(ARRAY,1)
   phase(ii) = sum(ARRAY(ii,:)*[cos(theta);sin(theta);0])/lambda*2*pi; % generate phase0 with var = 10
end

end
