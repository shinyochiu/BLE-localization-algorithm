function [his_update,P]=track1(angle,dis,his,P)
x=dis.*cos(angle);
y=dis.*sin(angle);
X_new=[x;y;x-his(end,1);y-his(end,2)];

[X_new,P]=kalman(his,P,X_new);  
his_update(1:size(his,1),:)=his;
his_update(size(his,1)+1,:)=[X_new(1) X_new(2)];
if size(his_update,1)>100
   his_update=his_update(end-100:end,:); 
end

end


function [X_new,P_new]=kalman(his,P,X)
num_group=10;
% x=formal_loc(end,1);
% y=formal_loc(end,2);
% vx=formal_loc(end,1)-formal_loc(size(formal_loc,1)-num_group,1)/num_group;
% vy=formal_loc(end,2)-formal_loc(size(formal_loc,1)-num_group,2)/num_group;
% X=[x;y;vx;vy];
Z=X(1:2,:);
det = 1;
F=[1,0,det,0;0,1,0,det;0,0,1,0;0,0,0,1];
H=[1,0,0,0;0,1,0,0];

% Q=[0.01,0,0.0,0;0,0.01,0,0.0;0.0,0,0.01,0;0,0.0,0,0.01];
if size(his,1) < num_group+1
    R=cov(his);
elseif size(his,1) >= num_group+1
    R=cov(his(size(his,1)-num_group:end,:));
end
 
Q = [ det^3/3 0 det^2/2 0
    0 det^3/3 0 det^2/2
    det^2/2 0 det 0
    0 det^2/2 0 det];

X_pre=F*X;
P_pre=F*P*F'+Q;
K=P_pre*H'*inv(H*P_pre*H'+R);
X_new=X_pre+K*(Z-H*X_pre);
P_new=(eye(4)-K*H)*P_pre;

end
