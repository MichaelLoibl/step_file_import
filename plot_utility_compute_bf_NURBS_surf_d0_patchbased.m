function [BF] = plot_utility_compute_bf_NURBS_surf_d0_patchbased(patch,u,v)
% [BF] = compute_bf_NURBS_surf_d0_patchbased(patch,u,v)
%
% computes bivariate basis functions (NURBS), no derivatives, in u,v for a
% NURBS surface geometry
%
% Parameters: 
%     [BF] : every column relates to a different base funtions (BF)
%            every row correspons to: [BF]
%     patch: struct of the patch (geometrical quantities of the patch)
%     u,v  : paramteric coordinates of the point
%
% 2018-2019, NTNU, Department of Marine Technology
% D. Proserpio, adapted from J. Kiendl code

% computes value of all the non zero base functions spanning on the element/knot span containing u,v

% extract data from struct
U = patch.U{1};
V = patch.U{2}; % global knot vectors
p = patch.p(1);
q = patch.p(2);
CP = patch.CP;

i = plot_utility_findspan_LR(u,U);  
j = plot_utility_findspan_LR(v,V);

ncp_e = (p+1)*(q+1);      % Control Points per element

N = plot_utility_basisfunc(i,p,u,U);    % univariate BF in u direction 
                           % computes all bf on the knot span i (every column is a bf, in every column there is [N]
M = plot_utility_basisfunc(j,q,v,V);    % univariate BF in v direction 
                           % computes all bf on the knot span j (every column is a bf, in every column there is [M]

%initialize
BF = zeros(1,ncp_e); %vector of non-zero b.f. on the element

sum = 0;
kk = 0;
for c = 0:q
    for b = 0:p % loop over the univariate bf spanning over the element/knot span
        
        kk = kk+1; %BF counter
    
        % base function
        BF(1,kk) = N(1,b+1)*M(1,c+1)*CP(i-p+b,j-q+c,4); % N*M*weight
        sum = sum + BF(1,kk);                           % contribution to the sum of the BF
       
    end
end

% divide through by sum
for kk = 1:ncp_e %loop over the computed BF

    BF(1,kk) = BF(1,kk)/sum;              
  
end

end %function


