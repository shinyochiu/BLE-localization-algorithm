function angle=AOA(phasediff,map,last_angle)
% map=map_phase_angle();
if nargin<3
    for ii=1:size(phasediff,1)
        angle(ii)=cost(phasediff(ii,:),map); 
   %angle(ii)=gradient_descent(phasediff(ii,:),map); 
    end
else
    for ii=1:size(phasediff,1)
       angle(ii)=cost(phasediff(ii,:),map,last_angle); 
       %angle(ii)=gradient_descent(phasediff(ii,:),map); 
    end
end
end

function opt_angle=cost(phasediff,map,last_angle)
angle_range = 0: 2*pi/360 : 2*pi-2*pi/360;
res=abs(repmat(phasediff,[size(map,1),1])-map);
res(res>2*pi)=res(res>2*pi)-2*pi;
%res(res<-2*pi)=2*pi+res(res<-2*pi);
for ii=1:size(res,1)
    angle(ii)=sum(res(ii,:).^2,2);
end
if nargin<3
    [~,index]=min(angle);
    opt_angle = angle_range(index);
else
    low_bnd = find(angle_range==last_angle)-3;
    high_bnd = find(angle_range==last_angle)+3;
    if low_bnd<=0
        opt_angle = angle_range(angle==min([angle(end+low_bnd:end) angle(1:high_bnd)]));
    elseif high_bnd>size(angle,2)
        opt_angle = angle_range(angle==min([angle(low_bnd:end) angle(1:high_bnd-size(angle,2))]));
    else
        opt_angle = angle_range(angle==min(angle(low_bnd:high_bnd)));
    end
end

end

function angle=gradient_descent(phasediff,map)
    angle = cost(phasediff,map); 
    res=map(angle,:)-phasediff;
    res(res>180)=360-res(res>180);
    res(res<-180)=360+res(res<-180);
    gradient = 2*res;
    epsilon = 1e-3;
    gamma = 0.1;
    count=0;
    while any(gradient > epsilon) && gamma>0
        phasediff = phasediff + gamma*gradient;
        angle = cost(phasediff,map); 
        res=map(angle,:)-phasediff;
        res(res>180)=360-res(res>180);
        res(res<-180)=360+res(res<-180);
        gradient = 2*res;
        gamma=gamma-0.005;
    end
end