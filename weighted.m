function [weight,loss]=weighted(phase,v_phi,phi0,weight)
n=size(phase,1);
ant_num = size(phase,2);
phi_i(1:n,:) = restrict(repmat(phi0,n,1) + 0.3927*mod(repmat((0:n-1)',1,ant_num),8));
phi_e(1:n,:) = restrict(repmat(phi0,n,1) + v_phi.*mod(repmat((0:n-1)',1,ant_num),8));
if nargin ==3 % weight initialize
%     if size(find(v_phi>0.3927),2)>=2
%         %weight(n,v) = (exp(-restrict(phase(n,v),phi_e(n,v))));
%         weight = 1./(1 + ((phase - phi_e)./(phase - phi_i)).^4);
%         target = phi_i;
%     else
%         %weight(n,v) = (exp(-restrict(phase(n,v),phi_i(n,v))));
%         weight = 1./(1 + ((phase - phi_i)./(phase - phi_e)).^4);
%         target = phi_e;
%     end
    weight = 1./(1 + ((phase - phi_e)./(phase - phi_i)).^4);
%     for k=1:n/8
%         weight(1+(k-1)*n/10:n/10+(k-1)*n/10,:) = repmat(1./sqrt(sum(((phase(1+(k-1)*n/10:n/10+(k-1)*n/10,:)-phi_e(1+(k-1)*n/10:n/10+(k-1)*n/10,:))./(phase(1+(k-1)*n/10:n/10+(k-1)*n/10,:)-phi_i(1+(k-1)*n/10:n/10+(k-1)*n/10,:))).^2,1)/(n/10)),n/10,1);
%     end
    loss = 1e6;
    
else % weight update & loss calculate
%     if size(find(v_phi>0.3927),2)
%         target = phi_i;
%     else
%         target = phi_e;
%     end
    alpha = 0.9;
    weight_t = 1./(1 + ((phase - phi_e)./(phase - phi_i)).^4);
%     for k=1:n/8
%         weight(1+(k-1)*n/10:n/10+(k-1)*n/10,:) = repmat(1./sqrt(sum(((phase(1+(k-1)*n/10:n/10+(k-1)*n/10,:)-phi_e(1+(k-1)*n/10:n/10+(k-1)*n/10,:))./(phase(1+(k-1)*n/10:n/10+(k-1)*n/10,:)-phi_i(1+(k-1)*n/10:n/10+(k-1)*n/10,:))).^2,1)/(n/10)),n/10,1);
%     end
    loss = sum(sum((weight-weight_t).^2));
    gradient = -2*(weight-weight_t);
    weight = alpha*weight_t + (1-alpha)*weight;
end
end

function phase=restrict(phase1,phase2)
if nargin ==1
    phase1(phase1<0) = phase1(phase1<0) + 2*pi;
    phase1(phase1>2*pi) = phase1(phase1>2*pi) - 2*pi;
    phase = phase1;
else
    res = phase1-phase2;
    res(res<-pi)= 2*pi+res(res<-pi);
    res(res>pi)= 2*pi-res(res>pi);
    phase=res;
end
end