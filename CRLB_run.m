close all, clear all
BLE=BLE_config();
antenna_num = 3:8;
d_r = BLE.R./sin(2*pi./antenna_num).*sin((pi-2*pi./antenna_num)/2);
%d_r = BLE.R/sqrt(3);
fc = BLE.freq;
fd = 250000;
theta = pi/2;%0: 2*pi/720 : 2*pi-2*pi/720;
noise=-2;
for n = 1:numel(antenna_num)
    map=map_phase_angle(antenna_num(n));
    for k = 1:numel(theta)
        for m = 1:1000
            % initial estimate 
            pseudo=generator(theta(k),fd,noise,antenna_num(n));% create fake observation
            [v_phi,phi0]=search_test(pseudo,antenna_num(n));
            % initial weight and loss
            [weight,loss]= weighted(pseudo,v_phi,phi0);
            [v_phi_2,phi0_2]=search_test(pseudo,antenna_num(n),weight);
            % initial target waveform value
            v_phi_c = v_phi_2;
            phi0_c = phi0_2;
            v_phi_t = v_phi_2;
            phi0_t = phi0_2;
            step(n,m) = 1;
            while step(n,m)<5 % find the optimal solution until converge
                % weight update and loss calculate
                [weight,loss_t] = weighted(pseudo,v_phi_t,phi0_t);
                % estimate with weight
                [v_phi_t,phi0_t]=search_test(pseudo,antenna_num(n),weight);
                % save results with lowest loss
                v_phi_c = [v_phi_c;v_phi_t];
                phi0_c = [phi0_c;phi0_t];
                step(n,m) = step(n,m) + 1;
            end
            phasediff = [];
            phasediff_2 = [];
            phasediff_c = [];
            for n_prime = 1:antenna_num(n)
                if n_prime<antenna_num(n)
                    phasediff=[phasediff phi0(:,mod(n_prime,antenna_num(n))+1)-phi0(:,mod(n_prime,antenna_num(n)))];
                    phasediff_2=[phasediff_2 phi0_2(:,mod(n_prime,antenna_num(n))+1)-phi0_2(:,mod(n_prime,antenna_num(n)))];
                    phasediff_c=[phasediff_c phi0_c(:,mod(n_prime,antenna_num(n))+1)-phi0_c(:,mod(n_prime,antenna_num(n)))];
                else
                    phasediff=[phasediff phi0(1,1)-phi0(1,n_prime)];
                    phasediff_2=[phasediff_2 phi0_2(:,1)-phi0_2(:,n_prime)];
                    phasediff_c=[phasediff_c phi0_c(:,1)-phi0_c(:,n_prime)];
                end
            end
            phasediff = wrapToPi(phasediff);
            phasediff_2 = wrapToPi(phasediff_2);
            phasediff_c = wrapToPi(phasediff_c);
            angle(n,m)=AOA(phasediff,map);
            angle_2(n,m)=AOA(phasediff_2,map);
            for i=1:size(phasediff_c,1)
                angle_c(n,m,i)=AOA(phasediff_c(i,:),map);
            end
        end
        RMSE(n,k) = sqrt(mean((theta(k)-angle(n,:)).^2))*180/pi;
        RMSE_2(n,k) = sqrt(mean((theta(k)-angle_2(n,:)).^2))*180/pi;
        for i=1:size(angle_c,3)
            RMSE_c(i,n,k) = sqrt(mean((theta(k)-angle_c(n,:,i)).^2))*180/pi;
        end
    end
%     RMSE = mean(RMSE,2);
%     RMSE_2 = mean(RMSE_2,2);
%     RMSE_c = mean(RMSE_c,3);
end

function output=restrict(input)
    input(input<-pi) = input(input<-pi) + 2*pi;
    input(input>pi) = input(input>pi) - 2*pi;
    output = input;
end

function angle=med_filt(angle)
window_size = 25;
history = [];
for n=1:size(angle,2)
    history=[history angle(:,n)];
    angle(:,n) = median(history,2);
    if mod(n,2*window_size)==0%size(history,2)>window_size
        history = [];%history(:,end-window_size+1:end);
    else
        if size(history,2)>window_size
            history = history(:,end-window_size+1:end);
        end
    end
end
end

function angle=gaussian_filter(angle)
window_size = 10;
history = [angle(:,1)];
for n=2:size(angle,2)
    if size(history,2)>window_size
        history = history(:,2:end);
    end
    history=[history angle(:,n)];
    sigma = std(history);
    x = linspace(-window_size / 2, window_size / 2, window_size);
    gaussFilter = exp(-x .^ 2 / (2 * sigma ^ 2));
    gaussFilter = gaussFilter / sum (gaussFilter);
    angle(:,n) = mean(filter(gaussFilter,1,history));
end
end