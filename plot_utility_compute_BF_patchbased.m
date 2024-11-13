function [BF] = plot_utility_compute_BF_patchbased(par_coord,patch,order)
% [BF] = compute_BF_patchbased(par_coord,patch,order)
%
% compute basis functions and derivatives for all the non zero basis functions
% spanning on the element containing par_coord
%
% Parameters: 
%     [BF]      : every column relates to a different base funtions (BF). Rows collect the derivatives
%     par_coord : paramteric coordinates of the point (u,v,w)
%     patch     : struct of the patch (geometrical quantities of the patch)
%     order     : order of derivatives
%                 (0=only basis functions, 1=1st derivatives also, 2=2nd derivatives also)
%
% 2018-2019, NTNU, Department of Marine Technology
% D. Proserpio, J. Kiendl 

if (length(patch.U)==1) % curves
    
    % compute shape functions for curves
    error('compute_BF not yet implemented for NURBS curves')
    
elseif (length(patch.U)==2) % surfaces 
    
    if (~isfield(patch,'lr')) % NURBS
        if (order==0)
            [BF] = plot_utility_compute_bf_NURBS_surf_d0_patchbased(patch,par_coord(1),par_coord(2));  % every row corresponds to: [BF]
        elseif (order==1)
            [BF] = compute_bf_NURBS_surf_d1_patchbased(patch,par_coord(1),par_coord(2));  % every row corresponds to: [BF; dBF/du; dBF/dv]
        elseif (order==2)
            [BF] = compute_bf_NURBS_surf_d2_patchbased(patch,par_coord(1),par_coord(2));  % every row corresponds to: [BF; dBF/du; dBF/dv; d^2BF/du^2; d^2BF/dudv; d^2BF/dv^2]
        elseif (order==3)
            [BF] = compute_bf_NURBS_surf_d3_patchbased(patch,par_coord(1),par_coord(2));    % every row corresponds to: [BF; dBF/du; dBF/dv; d^2BF/du^2; d^2BF/dudv; d^2BF/dv^2; 
                                                                                                % d^3BF/du^3; d^3BF/dv^3; d^3BF/du^2dv; d^3BF/dudv^2]
        end
        
    elseif (isfield(patch,'lr')) % LR
        lr = patch.lr;
        [BF] = lr.computeBasis(par_coord(1),par_coord(2),order); 
    end
    
elseif (length(patch.U)==3) % volumes
    
    if (order==0)
        [BF] = compute_bf_NURBS_volume_d0_patchbased(patch,par_coord(1),par_coord(2),par_coord(3));  % every row corresponds to: [BF]
    elseif (order==1)
        [BF] = compute_bf_NURBS_volume_d1_patchbased(patch,par_coord(1),par_coord(2),par_coord(3));  % every row corresponds to: [BF; dBF/du; dBF/dv; dBF/dw]
    end
    
end

end % function