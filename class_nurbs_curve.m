classdef class_nurbs_curve < handle
% class definition for curve obtained by a .stp (step) import
%
% 2023, UniBW, Department of Civil Engineering and Environmental Sciences 
% M. Loibl

    % declare all parameters
    properties
        
        CP_curv
        U_curv
        p_curv
        n_curv
        type    % B_SPLINE_CURVE_WITH_KNOTS or BOUNDED_CURVE
        
    end
    
    methods
        
        % initialize all parameters
        function curve = class_nurbs_curve(CP_curv,U_curv,p_curv,n_curv,type)
            curve.CP_curv = CP_curv;
            curve.U_curv = U_curv;
            curve.p_curv = p_curv;
            curve.n_curv = n_curv;
            curve.type = type;
        end
        
    end
    
end