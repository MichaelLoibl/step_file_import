function [dR,ddR,dddR] = plot_utility_basisfunc_deriv1to3(p,i,u,U,q,j,v,V,CP)
% [dR,ddR,dddR] =  basisfunc_deriv1to3(p,i,u,U,q,j,v,V,CP) 
%
% returns the first, second and third derivative of NURBS basis functions w.r.t u,v
% i,j are the knot span indices. if unknown, insert 0!
% This functions is kept even though it exists also
% "compute_bf_NURBS_surf_d3_patchbased.m" because here the basis functions
% themselves are not evaluated.
%
% Input:
%   p:  polynomial degree in u-direction
%   i:  number of knot span in u-direction where the basis functions should
%       be evaluated
%   u:  u-coordinate
%   U:  knot span in u-direction
%   q:  polynomial degree in v-direction
%   j:  number of knot span in v-direction where the basis functions should
%       be evaluated
%   v:  v-coordinate
%   V:  knot span in v-direction
%   CP: control points
%
% Output:
%   dR:     first derivative of the NURBS basis functions (order: du, dv)
%   ddR:    second derivatives of the NURBS basis functions (order: du^2,
%           dv^2, dudv)
%   dddR:   third derivatives of the NURBS basis functions (order: du^3, 
%           dv^3, du^2dv, dudv^2)

if (i==0); i = plot_utility_findspan(u,U,length(CP(:,1,1)));  end
if (j==0); j = plot_utility_findspan(v,V,length(CP(1,:,1)));  end

ne = (p+1)*(q+1);      % Control Points per element
N = plot_utility_deriv3(i,p,u,U);   % basisfunc in u
M = plot_utility_deriv3(j,q,v,V);   % basisfunc in v

R = zeros(ne,1);
dR = zeros(ne,2);
ddR = zeros(ne,3);   % du^2, dv^2, dudv
dddR = zeros(ne,4);   
sum = 0;
dsum = zeros(2,1);
ddsum = zeros(3,1);
dddsum = zeros(4,1);

k = 0;
for c = 0:q
  for b = 0:p
    k = k+1;
    R(k) = N(1,b+1)*M(1,c+1)*CP(i-p+b,j-q+c,4);
    sum = sum + R(k);
            
    % first derivatives
    dR(k,1) = N(2,b+1)*M(1,c+1)*CP(i-p+b,j-q+c,4);
    dsum(1)  = dsum(1) + dR(k,1);
    dR(k,2) = N(1,b+1)*M(2,c+1)*CP(i-p+b,j-q+c,4);
    dsum(2)  = dsum(2) + dR(k,2);
            
    % second derivatives  1-du^2, 2-dv^2, 3-dudv
    ddR(k,1) = N(3,b+1)*M(1,c+1)*CP(i-p+b,j-q+c,4);
    ddsum(1)  = ddsum(1) + ddR(k,1);
    ddR(k,2) = N(1,b+1)*M(3,c+1)*CP(i-p+b,j-q+c,4);
    ddsum(2)  = ddsum(2) + ddR(k,2);
    ddR(k,3) = N(2,b+1)*M(2,c+1)*CP(i-p+b,j-q+c,4);
    ddsum(3)  = ddsum(3) + ddR(k,3);
    
            
    % third derivatives  1-du^3, 2-dv^3, 3-du^2dv, 4-dudv^2
    dddR(k,1) = N(4,b+1)*M(1,c+1)*CP(i-p+b,j-q+c,4);
    dddsum(1)  = dddsum(1) + dddR(k,1);
    dddR(k,2) = N(1,b+1)*M(4,c+1)*CP(i-p+b,j-q+c,4);
    dddsum(2)  = dddsum(2) + dddR(k,2);
    dddR(k,3) = N(3,b+1)*M(2,c+1)*CP(i-p+b,j-q+c,4);
    dddsum(3)  = dddsum(3) + dddR(k,3);
    dddR(k,4) = N(2,b+1)*M(3,c+1)*CP(i-p+b,j-q+c,4);
    dddsum(4)  = dddsum(4) + dddR(k,4);
  end
end

    % divide through by sum
for k = 1:ne                   

  dddR(k,1) = dddR(k,1)/sum ...
            - (3*ddR(k,1)*dsum(1) + 3*dR(k,1)*ddsum(1) + R(k)*dddsum(1))/sum^2 ...
            + (6*dR(k,1)*dsum(1)^2 + 6*R(k)*ddsum(1)*dsum(1))/sum^3 ...
            - 6*R(k)*dsum(1)^3/sum^4;
  dddR(k,2) = dddR(k,2)/sum ...
            - (3*ddR(k,2)*dsum(2) + 3*dR(k,2)*ddsum(2) + R(k)*dddsum(2))/sum^2 ...
            + (6*dR(k,2)*dsum(2)^2 + 6*R(k)*ddsum(2)*dsum(2))/sum^3 ...
            - 6*R(k)*dsum(2)^3/sum^4;
          
  dddR(k,3) = dddR(k,3)/sum ...
            - (ddR(k,1)*dsum(2) + 2*ddR(k,3)*dsum(1) + 2*dR(k,1)*ddsum(3) + dR(k,2)*ddsum(1) + R(k)*dddsum(3))/sum^2 ...
            + (4*dR(k,1)*dsum(1)*dsum(2) + 2*R(k)*ddsum(1)*dsum(2) + 2*dR(k,2)*dsum(1)^2 + 4*R(k)*ddsum(3)*dsum(1))/sum^3 ...
            - 6*R(k)*dsum(1)^2*dsum(2)/sum^4;
          
  dddR(k,4) = dddR(k,4)/sum ...
            - (ddR(k,2)*dsum(1) + 2*ddR(k,3)*dsum(2) + 2*dR(k,2)*ddsum(3) + dR(k,1)*ddsum(2) + R(k)*dddsum(4))/sum^2 ...
            + (4*dR(k,2)*dsum(2)*dsum(1) + 2*R(k)*ddsum(2)*dsum(1) + 2*dR(k,1)*dsum(2)^2 + 4*R(k)*ddsum(3)*dsum(2))/sum^3 ...
            - 6*R(k)*dsum(2)^2*dsum(1)/sum^4;
       
  ddR(k,1) = ddR(k,1)/sum - 2*dR(k,1)*dsum(1)/sum^2 ...
             -R(k)*ddsum(1)/sum^2 + 2*R(k)*dsum(1)^2/sum^3;
  ddR(k,2) = ddR(k,2)/sum - 2*dR(k,2)*dsum(2)/sum^2 ...
             -R(k)*ddsum(2)/sum^2 + 2*R(k)*dsum(2)^2/sum^3;
  ddR(k,3) = ddR(k,3)/sum - dR(k,1)*dsum(2)/sum^2 - dR(k,2)*dsum(1)/sum^2 ...
             -R(k)*ddsum(3)/sum^2 + 2*R(k)*dsum(1)*dsum(2)/sum^3;
      
  dR(k,1) = dR(k,1)/sum - R(k)*dsum(1)/sum^2;
  dR(k,2) = dR(k,2)/sum - R(k)*dsum(2)/sum^2;
end