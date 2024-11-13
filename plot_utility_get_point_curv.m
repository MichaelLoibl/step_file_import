function C = plot_utility_get_point_curv(p,i,u,U,CP)
% C = get_point_curv(p,i,u,U,CP)
%
% computes point on the curve
%
% Input:
%   p:      polynomial order of the NURBS
%   i:      knot span (if 0, the respective knot span is determined here)
%   u:      position u at which the curve is evaluated
%   U:      knot span of the curve
%   CP:     control points of the curve
%
% Output:
%   C:          curve position
%
% J. Kiendl

if (i==0); i = plot_utility_findspan(u,U,length(CP(:,1)));  end
N=plot_utility_basisfunc(i,p,u,U);
SumNw = 0;
for b = 0:p
  SumNw = N(b+1)*CP(i-p+b,4)+SumNw;
end
C(1) = 0;
C(2) = 0;
C(3) = 0;
for b = 0:p 
  C(1) = N(b+1)*CP(i-p+b,4)*CP(i-p+b,1)/SumNw+C(1);
  C(2) = N(b+1)*CP(i-p+b,4)*CP(i-p+b,2)/SumNw+C(2);
  C(3) = N(b+1)*CP(i-p+b,4)*CP(i-p+b,3)/SumNw+C(3);
end

 
