classdef class_stp_curve < handle
% class definition for curve obtained by a .stp (step) import
%
% 2023, UniBW, Department of Civil Engineering and Environmental Sciences 
% M. Loibl

    % declare all parameters
    properties
        
        vertex_start
        vertex_end
        physical class_nurbs_curve
        parametric class_nurbs_curve
        trimming_curve          % flag
        trimmed_edge            % flag
        bound
        bound_type              % inner or outer
        patch
        
    end
    
    methods
        
        % initialize all parameters
        function curve = class_stp_curve()
            % nothing initialized; everything added step by step
        end
        
    end
    
end