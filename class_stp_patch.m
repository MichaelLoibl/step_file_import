classdef class_stp_patch < handle
% class definition for patches obtained by a .stp (step) import
%
% 2023, UniBW, Department of Civil Engineering and Environmental Sciences 
% M. Loibl

    % declare all parameters
    properties
        
        patch_nr
        type_face   % ADVANCED_FACE or FACE_SURFACE
        bounds
        type_surf   % B_SPLINE_SURFACE_WITH_KNOTS or BOUNDED_SURFACE
        CP
        U
        p
        nu          % number of CP in the two directions
        trimm       % flag
        
    end
    
    methods
        
        % initialize all parameters
        function patch = class_stp_patch()
            % nothing initialized; everything added step by step
        end
        
    end
    
end