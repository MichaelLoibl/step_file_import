function base_vectors = plot_utility_base_vectors_shellKL(dR,xyz_CP)
% base_vectors = base_vectors_shellKL(dR,ddR,xyz_P)
%
% Input:
% dR:  1st derivatives of bf w.r.t. u and v in the considered GP (2 columns array) [dBS/du, dBS/dv]
% xyz_CP: x,y,z coordinates of CP with corresponding b.f. spanning over the element 
%           (every line is one element coordinate)
%
% Output:
% a:    covariant base vectors [a1,a2]
% a3_KL:    unit normal vector a3_KL_tilde/dA
%
% Note: in this file, base vectors are denoted by a because they are referring to the mid-surface. This is in contrast to 
% the naming used in the KL element formulation, where g is used instead according to Kiendl et al. 2009.
%
% 2020, UniBW, Department of Civil Engineering and Environmental Sciences
% M. Loibl

% base vectors of the mid-surface a and Hessian
a = zeros(3,2);  
a(:,1)=(dR(:,1)'*xyz_CP)'; 
a(:,2)=(dR(:,2)'*xyz_CP)'; 

% a3_KL_tilde
a3_KL_tilde = [0; 0; 0];
a3_KL_tilde(1) = a(2,1)*a(3,2) - a(3,1)*a(2,2);
a3_KL_tilde(2) = a(3,1)*a(1,2) - a(1,1)*a(3,2);
a3_KL_tilde(3) = a(1,1)*a(2,2) - a(2,1)*a(1,2);
% length of a3_KL_tilde
dA = sqrt(a3_KL_tilde(1)^2 + a3_KL_tilde(2)^2 + a3_KL_tilde(3)^2);
% unit normal vector a3_KL
a3_KL = [0; 0; 0];
a3_KL(1) = a3_KL_tilde(1)/dA;
a3_KL(2) = a3_KL_tilde(2)/dA;
a3_KL(3) = a3_KL_tilde(3)/dA;

% pack all in structure
base_vectors = struct('a',a,'a3_KL',a3_KL);                 

end %function