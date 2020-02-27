%close all, clear all
hold on;
BLE=BLE_config();
M = 3;
d_r = BLE.R/sin(2*pi/M)*sin((pi-2*pi/M)/2)-0.01;
fc = BLE.freq;
fd = 250000;
c = BLE.c;
N = 80;
sig_theta = 0.769902591241258*pi/180; % 0.1778 rad , about 10 degree std for phase observation

dis2center = 2;
sig_x=0.1;
sig_y=0.1;
sig_vx=0.005;
sig_vy=0.005;
x1=-0.5; y1=0; x2=0.5; y2=0;
anchor1 = [x1;y1];
anchor2 = [x2;y2];
true_agent_pos = dis2center*[cos(90*pi/180:1*pi/180:449*pi/180);sin(90*pi/180:1*pi/180:449*pi/180)];
pos_offset1 = true_agent_pos-repmat(anchor1,1,size(true_agent_pos,2));
pos_offset2 = true_agent_pos-repmat(anchor2,1,size(true_agent_pos,2));
theta1=atan2(pos_offset1(2,:),pos_offset1(1,:));%+normrnd(0,sig_theta,[size(true_agent_pos,1),size(true_agent_pos,2)]);
theta2=atan2(pos_offset2(2,:),pos_offset2(1,:));%+normrnd(0,sig_theta,[size(true_agent_pos,1),size(true_agent_pos,2)]);
x0 = (y2-y1+x1*tan(theta1)-x2*tan(theta2))./(tan(theta1)-tan(theta2));% + normrnd(0,sig_x,[1,size(true_agent_pos,2)]);
x0(x0==inf) = dis2center;
x0(x0==-inf) = -dis2center;
y0 = y1 + (x0-x1).*tan(theta1);% + normrnd(0,sig_y,[1,size(true_agent_pos,2)]);
%%initial value
d1=(x0(1)-x1)^2 + (y0(1)-y1)^2;
d2=(x0(1)-x2)^2 + (y0(1)-y2)^2;
T = [-(y0(1)-y1)/d1 (x0(1)-x1)/d1 0 0;-(y0(1)-y2)/d2 (x0(1)-x2)/d2 0 0];
%T_1 = [-(y0(1)-y1)/d1 (x0(1)-x1)/d1;-(y0(1)-y2)/d2 (x0(1)-x2)/d2];
I = M/(2*(sig_theta)^2)*((d_r*2*pi/c)^2)*[N*(fc+fd)^2 0;0 N*(fc+fd)^2];
J(1,:,:) = T'*I*T;
P(1) = trace(inv(squeeze(J(1,:,:))));
%%recursive  solution
for n=2:size(true_agent_pos,2)
    %estimate distance from anchor calculated from two AOA observations 
    d1=(x0(n)-x1)^2 + (y0(n)-y1)^2;
    d2=(x0(n)-x2)^2 + (y0(n)-y2)^2;
    T = [-(y0(n)-y1)/d1 (x0(n)-x1)/d1 0 0;-(y0(n)-y2)/d2 (x0(n)-x2)/d2 0 0];
    
    D_11=[1/sig_x^2 0 1/sig_x^2 0;0 1/sig_y^2 0 1/sig_y^2;1/sig_x^2 0 (1/sig_x^2)+(1/sig_vx^2) 0;0 1/sig_y^2 0 (1/sig_y^2)+(1/sig_vy^2)];
    D_12=-[1/sig_x^2 0 0 0;0 1/sig_y^2 0 0;1/sig_x^2 0 1/sig_vx^2 0;0 1/sig_y^2 0 1/sig_vy^2];
    %D_22=[1/sig_x^2 0 1/sig_x^2 0;0 1/sig_y^2 0 1/sig_y^2;1/sig_x^2 0 (1/sig_x^2)+(1/sig_vx^2) 0;0 1/sig_y^2 0 (1/sig_y^2)+(1/sig_vy^2)];
    %J_22=T'*I*T+D_22;
    D_22=[(1/sig_x^2)+((y0(n)-y1)^2)/((d1*sig_theta)^2)+((y0(n)-y2)^2)/((d2*sig_theta)^2),(-(y0(n)-y1)*(x0(n)-x1))/((d1*sig_theta)^2)+(-(y0(n)-y2)*(x0(n)-x2))/((d2*sig_theta)^2),0,0
        (-(y0(n)-y1)*(x0(n)-x1))/((d1*sig_theta)^2)+(-(y0(n)-y2)*(x0(n)-x2))/((d2*sig_theta)^2),(1/sig_y^2)+((x0(n)-x1)^2)/((d1*sig_theta)^2)+((x0(n)-x2)^2)/((d2*sig_theta)^2),0,0
        0,0,1/(1/sig_vx^2),0
        0,0,0,(1/sig_vy^2)];

%     D_11=[1/sig_x^2 0;0 1/sig_y^2];
%     D_12=-[1/sig_x^2 0;0 1/sig_y^2];
%     D_22=[(1/sig_x^2)+((y0(n)-y1)^2)/((d1*sig_theta)^2)+((y0(n)-y2)^2)/((d2*sig_theta)^2),((y0(n)-y1)*(x0(n)-x1))/((d1*sig_theta)^2)+((y0(n)-y2)*(x0(n)-x2))/((d2*sig_theta)^2)
%     ((y0(n)-y1)*(x0(n)-x1))/((d1*sig_theta)^2)+((y0(n)-y2)*(x0(n)-x2))/((d2*sig_theta)^2),(1/sig_y^2)+((x0(n)-x1)^2)/((d1*sig_theta)^2)+((x0(n)-x2)^2)/((d2*sig_theta)^2)];
    J(n,:,:)= D_22-D_12'/(squeeze(J(n-1,:,:))+D_11)*D_12;
    P(n) = trace(inv(squeeze(J(n,:,:))));
end

plot(1:360,P,'DisplayName','Root SPEB','LineWidth',2);

xlabel('number [n]');
ylabel('RMSE [m]');
legend();