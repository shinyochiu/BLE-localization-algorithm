function [v_phi,phi0]=search_test(phase,antenna_num,weight)
if nargin == 3
    for ii=1:antenna_num
        [v_phi(ii),phi0(ii)]=sub_search_test(phase,ii,weight);
    end
else
    for ii=1:antenna_num
        [v_phi(ii),phi0(ii)]=sub_search_test(phase,ii);
    end
end

end

function [v_phi,phi0]=sub_search_test(phase,data_index,weight)
v_phi_range = 0.37:0.001:0.395;
% v_phi_range = 0.388;
phi_0_res = zeros(1, numel(v_phi_range));
min_v = zeros(1, numel(v_phi_range));
% data_index = 3;
data = [];
for n = 1:10
    data = [data; (1:8)'+48*(n-1)+16*(data_index-1)];
end
data = [data ,phase(:, data_index)];
if nargin == 3 % weighted LSE
    data = [data ,weight(:, data_index)];
    for n = 1:numel(v_phi_range)
        func = f2(v_phi_range(n), data);
        phi_0_res(n) = fminbnd(func, -pi, pi);
        min_v(n) = func(phi_0_res(n));
    end
else
    for n = 1:numel(v_phi_range)
        func = f(v_phi_range(n), data);
        phi_0_res(n) = fminbnd(func, -pi, pi);
        min_v(n) = func(phi_0_res(n));
    end
end
[~, index] = min(min_v);
v_phi = v_phi_range(index);
phi0 = phi_0_res(index);
end
function func = f(v_phi, data)
    function v = inner_func(phi0)
        v = sum(wrapToPi(data(:, 2) - (v_phi*mod(data(:, 1)-1,8)+phi0)).^2);
    end
func = @inner_func;
end
function func = f2(v_phi, data)
    function v = inner_func(phi0)
        v = sum(data(:,3).*wrapToPi(data(:, 2) - (v_phi*mod(data(:, 1)-1,8)+phi0)).^2);
    end
func = @inner_func;
end