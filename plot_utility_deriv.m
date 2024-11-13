function Nd = plot_utility_deriv(i,p,u,U,CP)
% Evaluates the basis functions and first derivatives at u

% adapted from algorithm in Piegl, Les. "The NURBS Book". Springer-Verlag:
% Berlin 1995; p. 206.
if (i==0); i = plot_utility_findspan(u,U,length(CP(:,1,1)));
end

left = zeros(1,p+1);
right = zeros(1,p+1);
ndu = zeros(p+1,p+1);
Nd = zeros(2,p+1);
a = zeros(2,2);
     
ndu(1,1) = 1;
for j = 1:p
   left(j+1) = u - U(i+1-j);
   right(j+1) = U(i+j) - u;
   saved = 0;
   for r = 0:j-1
      ndu(j+1,r+1) = right(r+2) + left(j-r+1);
      temp = ndu(r+1,j)/ndu(j+1,r+1);
      ndu(r+1,j+1) = saved + right(r+2)*temp;
      saved = left(j-r+1)*temp;
   end
   ndu(j+1,j+1) = saved;
end

                         % load basis functions
for j = 0:p
   Nd(1,j+1) = ndu(j+1,p+1);
end
                         % compute derivatives
for r = 0:p              % loop over function index
  s1 = 0;
  s2 = 1;                % alternate rows in array a
  a(1,1) = 1;
  k = 1;                 % loop to compute 1st derivative
  d = 0;
  rk = r-k;
  pk = p-k;
  if (r >= k)
     a(s2+1,1) = a(s1+1,1)/ndu(pk+2,rk+1);
     d = a(s2+1,1)*ndu(rk+1,pk+1);
  end
  if (r <= pk)
     a(s2+1,k+1) = -a(s1+1,k)/ndu(pk+2,r+1);
     d = d + a(s2+1,k+1)*ndu(r+1,pk+1);
  end
  Nd(k+1,r+1) = d;
end
      
% Multiply through by the correct factors
r = p;
for j = 0:p
  Nd(k+1,j+1) = Nd(k+1,j+1)*r;
end