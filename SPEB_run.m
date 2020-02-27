clear all
BLE=BLE_config();
M = 3;
d_r = BLE.R/sin(2*pi/M)*sin((pi-2*pi/M)/2)-0.01;
fc = BLE.freq;
fd = 250000;
c = BLE.c;
N = 80;
sig_theta = 1.044030651*pi/180;

dis2center = 2;
sig_x=0.1;
sig_y=0.1;
sig_vx=0.005;
sig_vy=0.005;
x1=-0.5; y1=0; x2=0.5; y2=0;
anchor1 = [x1;y1];
anchor2 = [x2;y2];
ground_truth = 90;

true_agent_pos = dis2center*[cos(90*pi/180:1*pi/180:449*pi/180);sin(90*pi/180:1*pi/180:449*pi/180)];
angle_c = zeros(2,size(true_agent_pos,2));
%% create sudo observation
for n = 1:size(true_agent_pos,2)
    map=map_phase_angle(M);
    pos_offset1 = true_agent_pos(:,n)-anchor1;
    pos_offset2 = true_agent_pos(:,n)-anchor2;
    theta1=atan2(pos_offset1(2),pos_offset1(1));
    theta2=atan2(pos_offset2(2),pos_offset2(1));
    %estimate for correction
    sudo1=generator(theta1,fd,-1.5,M);
    sudo2=generator(theta2,fd,-1.5,M);
    [v_phi1,phi01]=search_test(sudo1,M);
    [v_phi2,phi02]=search_test(sudo2,M);
    %waveform reconstruct
    [weight1,loss1] = weighted(sudo1,v_phi1,phi01);
    [weight2,loss2] = weighted(sudo2,v_phi2,phi02);
    %estimate again
    [v_phi_c1,phi0_c1]=search_test(sudo1,M,weight1);
    [v_phi_c2,phi0_c2]=search_test(sudo2,M,weight2);
    phasediff_c1=wrapToPi([phi0_c1(:,2)-phi0_c1(:,1) phi0_c1(:,3)-phi0_c1(:,2) phi0_c1(:,1)-phi0_c1(:,3)]);
    phasediff_c2=wrapToPi([phi0_c2(:,2)-phi0_c2(:,1) phi0_c2(:,3)-phi0_c2(:,2) phi0_c2(:,1)-phi0_c2(:,3)]);
    angle_c(1,n)=AOA(phasediff_c1,map);
    angle_c(2,n)=AOA(phasediff_c2,map);
end


%% initial value
dt = 0.1;
x0 = (y2-y1+x1*tan(angle_c(1,:))-x2*tan(angle_c(2,:)))./(tan(angle_c(1,:))-tan(angle_c(2,:))) + randn*sig_x;
x0(x0>dis2center) = dis2center;
x0(x0<-dis2center) = -dis2center;
y0 = y1 + (x0-x1).*tan(angle_c(1,:)) + randn*sig_y;
y0(y0>dis2center) = dis2center;
y0(y0<-dis2center) = -dis2center;
x_est = zeros(4,size(true_agent_pos,2));
P_est = eye(4);
%P_est = [sig_x^2 0 0 0;0 sig_y^2 0 0;0 0 sig_vx^2 0;0 0 0 sig_vy^2];
f = [1,0,dt,0;0,1,0,dt;0,0,1,0;0,0,0,1];
H=[1,0,0,0;0,1,0,0];
x_obs = [x0;y0];
x_est(:,1) = [x0(1);y0(1);x0(2)-x0(1);y0(2)-y0(1)];
% Q = [sig_x^2 0 sig_vx^2 0;0 sig_y^2 0 sig_vy^2;0 0 sig_vx^2 0;0 0 0 sig_vy^2];
Q = [sig_x^2 0 sig_x^2 0;0 sig_y^2 0 sig_y^2;sig_x^2 0 (sig_x^2)+(sig_vx^2) 0;0 sig_y^2 0 (sig_y^2)+(sig_vy^2)];
% Q = [ dt^3/3 0 dt^2/2 0
%     0 dt^3/3 0 dt^2/2
%     dt^2/2 0 dt 0
%     0 dt^2/2 0 dt];

%% start EKF 
for k=2:size(true_agent_pos,2)
%     if mod(k,10)==0
%         P_est = eye(4);
%     end
    % predict state and error covariance
    
    if mod(k,20)==0
        P_est = eye(4);
    end
    x_est_t = f*x_est(:,k-1);
    P_est_t = f*P_est*f' + Q;
    if k<10
        R=cov(x_obs(1:2,1:k)');
    else
        R=cov(x_obs(1:2,k-9:k)');
    end
    % compute Kalman gain
%     d1=(x_est_t(1)-x1)^2+(x_est_t(2)-y1)^2;
%     d2=(x_est_t(1)-x2)^2+(x_est_t(2)-y2)^2;
%     H = [-(x_est_t(2)-y1)/d1 (x_est_t(1)-x1)/d1 0 0;-(x_est_t(2)-y1)/d2 (x_est_t(1)-x1)/d2 0 0];
    K_t = P_est_t*H'/(H*P_est_t*H'+R);
    
    % compute estimate
    %obs_est = [atan2((x_est_t(2)-y1),(x_est_t(1)-x1));atan2((x_est_t(2)-y2),(x_est_t(1)-x2))];
    x_est(:,k) = x_est_t + K_t*(x_obs(:,k)-H*x_est_t);
    x_est(3:4,k) = (x_obs(1:2,k)-x_obs(1:2,k-1));%+[normrnd(0,sig_vx);normrnd(0,sig_vy)];
    P_est = (eye(4)-K_t*H)*P_est_t;
end
% plot(1:360,angle_c(1,:));
% plot(1:360,x_est(1,:));
%RMSE = sqrt(mean((true_agent_pos-x_obs(1:2,:)).^2));
RMSE_filt = sqrt(mean((true_agent_pos-x_est(1:2,:)).^2));
%plot(1:360,RMSE,'DisplayName','original','LineWidth',2,'LineStyle','--');
plot(1:360,RMSE_filt,'DisplayName','Kalman Filter','LineWidth',2,'LineStyle','--');
%axis([1 360 0 1]);
%obj=serial_config();

%BLE_location(obj,map);