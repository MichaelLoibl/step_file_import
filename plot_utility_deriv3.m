function Nd = plot_utility_deriv3(i,p,u,U)
% Nd = deriv3(i,p,u,U)
%
% Evaluates the basis functions and the first, second and third derivatives
% at u
%
% adapted from algorithm in Piegl, Les. "The NURBS Book". Springer-Verlag:
% Berlin 1995; p. 206.

left = zeros(1,p+1);
right = zeros(1,p+1);
ndu = zeros(p+1,p);
Nd = zeros(4,p+1);
a = zeros(2,p+1);
     
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
for r = 0:p               % loop over function index
   s1 = 0;
   s2 = 1;                % alternate rows in array a
   a(1,1) = 1;
                          % loop to compute 1st derivative
   for k = 1:3
      d = 0;
      rk = r-k;
      pk = p-k;
      if (r >= k)
         a(s2+1,1) = a(s1+1,1)/ndu(pk+2,rk+1);
         d = a(s2+1,1)*ndu(rk+1,pk+1);
      end
      if (rk >= -1)
         j1 = 1;
      else 
         j1 = -rk;
      end
      if ((r-1) <= pk)
         j2 = k-1;
      else 
         j2 = p-r;
      end
      for j = j1:j2
         a(s2+1,j+1) = (a(s1+1,j+1) - a(s1+1,j))/ndu(pk+2,rk+j+1);
         d = d + a(s2+1,j+1)*ndu(rk+j+1,pk+1);
      end
      if (r <= pk)
         a(s2+1,k+1) = -a(s1+1,k)/ndu(pk+2,r+1);
         d = d + a(s2+1,k+1)*ndu(r+1,pk+1);
      end
      Nd(k+1,r+1) = d;
      j = s1;
      s1 = s2;
      s2 = j;             % switch rows
  end
end
      
% Multiply through by the correct factors
r = p;
for k = 1:3
   for j = 0:p
      Nd(k+1,j+1) = Nd(k+1,j+1)*r;
   end
   r = r*(p-k);
end

% end