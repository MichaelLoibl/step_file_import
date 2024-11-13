function i = plot_utility_findspan_LR(u,U)
% i = findspan_LR(u,U)
%
% returns the knot span i where u lies, wrt to global knot vector U, for a
% geometry defined by LR NURBS or NURBS
%
% open global knot vector assumed
%
% Note: due to rounding errors in u findspan can be ambiguous at knots.
% There's no problem for the inner knots but to get the last knot (special case) 
% rounding range must be considered
%
% 2018-2019, NTNU, Department of Marine Technology
% D. Proserpio, adapted from J. Kiendl code

m = length(U); %length of global knot span
p = length(find(U==U(1)))-1; %find the degree of the knot span by checking multiplicity of knot vector extremes

n = m-p-1; %index of the last non-null knot span

eps = 10e-10;
if ( abs(u-U(n+1)) < eps)  % special case: last knot. If u is close to the last knot point, the knot vector index for u is the one of the first null knot
  i = n;
  return
end

for i = 1:(m-1)
    if (u<U(i+1))
        return
    end
end  

error('u outside of U!')

end %function