function Cderiv = plot_utility_get_deriv_point_curv(p,i,u,U,CP)
% Cderiv = get_deriv_point_curv(p,i,u,U,CP)
%
% Determines the derivatives of a curve wrt. parametric or physical coordinates 
% at a specific point whereby the position of the point is specified by the curve 
% parameter of the point.
%
% Input:
%   p:  polynomial order of NURBS
%   i:  knot span in which the point is, 0 if unknown
%   u:  curve parameter of the point
%   U:  knot span of the curve
%   CP: control point of the curve
%
% Output:
%   Cderiv:  derivatives wrt. parametric or physical coordinates depending
%               on whether the curve is defined in parametric or physical coordinates;
%               if parametric, Cderiv(3)=0
%
% Master thesis at NTNU

if (i==0); i = plot_utility_findspan(u,U,length(CP(:,1)));  end
Nd=plot_utility_deriv(i,p,u,U,CP);
N=Nd;
SumNw = 0;
SumdNw=0;
for b = 0:p
  SumNw = N(1,b+1)*CP(i-p+b,4)+SumNw;
  SumdNw=N(2,b+1)*CP(i-p+b,4)+SumdNw;
end


Cd(1) = 0;
Cd(2) = 0;
Cd(3) = 0;
C(1)=0;
C(2)=0;
C(3)=0;
for b = 0:p 
  Cd(1) = N(2,b+1)*CP(i-p+b,4)*CP(i-p+b,1)+Cd(1);
  Cd(2) = N(2,b+1)*CP(i-p+b,4)*CP(i-p+b,2)+Cd(2);
  Cd(3) = N(2,b+1)*CP(i-p+b,4)*CP(i-p+b,3)+Cd(3);
end

for b = 0:p 
  C(1) = N(1,b+1)*CP(i-p+b,4)*CP(i-p+b,1)+C(1);
  C(2) = N(1,b+1)*CP(i-p+b,4)*CP(i-p+b,2)+C(2);
  C(3) = N(1,b+1)*CP(i-p+b,4)*CP(i-p+b,3)+C(3);
end 
Cderiv=Cd/SumNw-(C*SumdNw/(SumNw^2));
