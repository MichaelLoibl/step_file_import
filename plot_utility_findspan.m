function i = plot_utility_findspan(u,U,n)
% returns the knot span where u lies
% Note: due to rounding errors in u findspan can be ambiguous at knots.
% There's no problem for the inner knots but to get the last knot (special
% case) rounding range must be considered
% J. Kiendl

m=length(U);
eps=10e-10;
if (abs(u-U(n+1))<eps)  % special case: last knot (open knot vector assumed)
  i = n;
  return
end
for i = 1:(m-1)
  if (u<U(i+1))
    return
  end
end  

error('u outside of U!')