close all,clear all
%clear;
antenna_num=3;
BLE=BLE_config();
map=map_phase_angle(antenna_num);
% 
file = fopen('C:\Users\xinyouqiu\Desktop\ble5.0\09-27\123s_1.txt');
[Idata,Qdata,rssi]=read_file16(file);
for i=1:size(Idata,2)
phase_diff = calc_phase(Idata(:,i),Qdata(:,i));
[v_phi,phi0]=search_test(phase_diff,3);
% initial weight and loss
[weight,loss]= weighted(phase_diff,v_phi,phi0);
[v_phi_2,phi0_2]=search_test(phase_diff,antenna_num,weight);
phasediff = [];
phasediff_2 = [];
for n_prime = 1:antenna_num
    if n_prime<antenna_num
        phasediff=[phasediff phi0(:,mod(n_prime,antenna_num)+1)-phi0(:,mod(n_prime,antenna_num))];
        phasediff_2=[phasediff_2 phi0_2(:,mod(n_prime,antenna_num)+1)-phi0_2(:,mod(n_prime,antenna_num))];
    else
        phasediff=[phasediff phi0(1,1)-phi0(1,n_prime)];
        phasediff_2=[phasediff_2 phi0_2(1,1)-phi0_2(1,n_prime)];
    end
end
phasediff = wrapToPi(phasediff);
phasediff_2 = wrapToPi(phasediff_2);
if i>1
    angle(i)=AOA(phasediff,map);
    angle_2(i)=AOA(phasediff_2,map);
else
    angle(i)=AOA(phasediff,map);
    angle_2(i)=AOA(phasediff_2,map);
end
end
%angle_2 = med_filt(angle_2);
% min_angle = find(angle_2==min(angle_2));
% %angle_2 = [angle_2(min_angle(1):end) angle_2(1:min_angle(1)-5)];
% angle_2 = [angle_2(min_angle+1:end) angle_2(1:min_angle)];
% angle_2=flip(angle_2);
plot(angle_2);
%angle_2=med_filt(angle_2(5:end));

a=1:size(angle_2,2);
true_angle=fit(a',angle_2','sin8');
err=abs(true_angle(a)-angle_2');
RMSE=[true_angle(a') sqrt(err.^2)];
RMSE = sortrows(RMSE,1);
x=360/size(a,2):360/size(a,2):360;
y=RMSE(:,2)'*180/pi;
options = fitoptions('Method','SmoothingSpline',...
                     'SmoothingParam',6.3240582419587496E-6);
RMSEplot=fit(x',y','SmoothingSpline',options);
plot(x,RMSEplot(x));
% RMSE_t = sum((true_angle-angle).^2);
%dis=TOF(Idata,Qdata,rssi);

%track_movie(angle,dis);
function angle=med_filt(angle)
window_size = 10;
history = [];
for n=1:size(angle,2)
    history=[history angle(:,n)];
    angle(:,n) = median(history,2);
    if size(history,2)>window_size
        history = history(end-window_size+1:end);
    end
end
end