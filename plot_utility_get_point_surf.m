function S = plot_utility_get_point_surf(p,i,u,U,q,j,v,V,CP)
% returns X,Y,Z coordinates corresponding to u,v
% i,j are the knot span indices. if unknown, insert 0!
% J. Kiendl

if (i==0); i = plot_utility_findspan(u,U,length(CP(:,1,1)));  end
if (j==0); j = plot_utility_findspan(v,V,length(CP(1,:,1)));  end
Nu=plot_utility_basisfunc_trimm(i,p,u,U,CP);
Nv=plot_utility_basisfunc_trimm(j,q,v,V,CP);
SumNw = 0;
for c = 0:q
  for b = 0:p
    SumNw = Nu(b+1)*Nv(c+1)*CP(i-p+b,j-q+c,4)+SumNw;
  end
end

S(1) = 0;
S(2) = 0;
S(3) = 0;
for c = 0:q 
  for b = 0:p
    S(1) = Nu(b+1)*Nv(c+1)*CP(i-p+b,j-q+c,4)*CP(i-p+b,j-q+c,1)/SumNw+S(1);
    S(2) = Nu(b+1)*Nv(c+1)*CP(i-p+b,j-q+c,4)*CP(i-p+b,j-q+c,2)/SumNw+S(2);
    S(3) = Nu(b+1)*Nv(c+1)*CP(i-p+b,j-q+c,4)*CP(i-p+b,j-q+c,3)/SumNw+S(3); 
  end
end