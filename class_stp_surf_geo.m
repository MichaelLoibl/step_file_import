classdef class_stp_surf_geo < handle
% class definition for surface geometries obtained by a .stp (step) import
%
% 2023, UniBW, Department of Civil Engineering and Environmental Sciences 
% M. Loibl

    % declare all parameters
    properties
        
        patch
        bounds
        curves
        
    end
    
    methods
        
        % initialize all parameters
        function surf_geo = class_stp_surf_geo(patch,bounds,curves)
            surf_geo.patch = patch;
            surf_geo.bounds = bounds;
            surf_geo.curves = curves;
        end
        
    end
    
end