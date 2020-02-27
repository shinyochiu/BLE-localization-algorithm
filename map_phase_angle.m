function phase_diff=map_phase_angle(antenna_num)
%% 角度与相位差映射图,第一列phase-diff(2-1),第二列phase-diff(3-2)，第三列phase-diff（1-3）
BLE=BLE_config();
lambda=BLE.c/BLE.freq;
N=antenna_num;
ARRAY=zeros(N,3);
d_r = BLE.R/sin(2*pi/N)*sin((pi-2*pi/N)/2);
%d_r = BLE.R/sqrt(3);
for n=1:N
    ARRAY(n,:) = d_r*[cos(2*pi*(1-n)/N),sin(2*pi*(1-n)/N),0];
end
% ARRAY1(1,:)=[-BLE.R/2,-BLE.R/2/sqrt(3),0];
% ARRAY1(2,:)=[0,BLE.R/sqrt(3),0];
% ARRAY1(3,:)=[BLE.R/2,-BLE.R/2/sqrt(3),0];
angle_range = 0: 2*pi/360 : 2*pi-2*pi/360;
phase_diff=zeros(numel(angle_range),N);
for ii=1:numel(angle_range)
    phase=calc_phase(ARRAY,angle_range(ii));
    for n=1:N
        if n<N
            phase_diff(ii,n)=(phase(mod(n,N)+1)-phase(mod(n,N)))/lambda*2*pi;
        else
            phase_diff(ii,n)=(phase(mod(n,N)+1)-phase(n))/lambda*2*pi;
        end
    end
end
% figure();
% subplot(3,1,1);
% stem(phase_diff(:,1));
% subplot(3,1,2);
% stem(phase_diff(:,2));
% subplot(3,1,3);
% stem(phase_diff(:,3));
end
    
function phase=calc_phase(ARRAY,theta)
for ii=1:size(ARRAY,1)
   phase(ii) = sum(ARRAY(ii,:)*[cos(theta);sin(theta);0]); 
end

end