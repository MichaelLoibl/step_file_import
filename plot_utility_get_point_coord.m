function [XYZ] = get_point_coord(par_coord,patch)
% [XYZ] = get_point_coord(par_coord,patch)
%
% returns X,Y,Z coordinates corresponding to a set of parametric coordinates 
% (all belonging to the same patch)
%
% Parameters: 
%     [XYZ]    : coordinates array (each row contains the coordinates of a point)
%     par_coord: array of parametric coordinates of the point (each row is a point)
%     patch    : struct of the patch (geometrical quantities of the patch)
%
% 2018-2019, NTNU, Department of Marine Technology
% D. Proserpio, adapted from J. Kiendl code

XYZ = zeros(size(par_coord,1),3); % intialize

% extract data from patch struct
if ( length(patch.U)==1 )      % curves 
    U = patch.U{1}; % global knot vectors
    p = patch.p(1);
    CP = patch.CP;
elseif ( length(patch.U)==2 )  % surfaces
    spline_type = isfield(patch,'lr');
    if (spline_type==0) %NURBS
        U = patch.U{1};
        V = patch.U{2}; % global knot vectors
        p = patch.p(1);
        q = patch.p(2);
        CP = patch.CP;
    elseif (spline_type==1) % LR 
        lr = patch.lr;
    end
elseif ( length(patch.U)==3 )  % volumes
        U = patch.U{1};
        V = patch.U{2}; 
        W = patch.U{3}; % global knot vectors
        p = patch.p(1);
        q = patch.p(2);
        r = patch.p(3);
        CP = patch.CP;
end

% loop on all the paramteric coordinates
for ipc = 1:size(par_coord,1) 
    
    [BF] = plot_utility_compute_BF_patchbased(par_coord(ipc,:),patch,0); % compute BF

    if ( length(patch.U)==1 )      % curves, check !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        
        ncp_e = (p+1);
        
        i = plot_utility_findspan_LR(par_coord(ipc,1),U);  

        xyz_CP = CP(i-p:i,1:3); % coordinates of CP corresponding to BF having support on the element
        xyz_CP = reshape(xyz_CP(:,1:3),[ncp_e,3]);
        
    elseif ( length(patch.U)==2 )  % surfaces
        
        if (spline_type==0) %NURBS
            
            ncp_e = (p+1)*(q+1);
            
            i = plot_utility_findspan_LR(par_coord(ipc,1),U);  
            j = plot_utility_findspan_LR(par_coord(ipc,2),V);          
            
            xyz_CP = CP(i-p:i,j-q:j,1:3); % coordinates of CP to BF having support on the element            
            xyz_CP = reshape(xyz_CP(:,:,1:3),[ncp_e,3]);
            
        elseif (spline_type==1) % LR 
            
            iel = lr.getElementContaining(par_coord(ipc,1),par_coord(ipc,2));    %determine element including u,v
            
            xyz_CP = patch.lr.cp(1:end-1,lr.support{iel})';
           
        end
    elseif ( length(patch.U)==3 )  % volumes, check !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

        ncp_e = (p+1)*(q+1)*(r+1);

        i = plot_utility_findspan_LR(par_coord(ipc,1),U);  
        j = plot_utility_findspan_LR(par_coord(ipc,2),V);
        k = plot_utility_findspan_LR(par_coord(ipc,3),W);          

        xyz_CP = CP(i-p:i,j-q:j,k-r:k,1:3); % coordinates of CP to BF having support on the element
        xyz_CP = reshape(xyz_CP(:,:,:,1:3),[ncp_e,3]);
                
    end

    XYZ(ipc,:) = BF*xyz_CP;
end

end %function


