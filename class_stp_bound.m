classdef class_stp_bound < handle
% class definition for bound obtained by a .stp (step) import
%
% 2023, UniBW, Department of Civil Engineering and Environmental Sciences 
% M. Loibl

    % declare all parameters
    properties
        
        bound_nr
        type            % inner or outer
        curves          % list of boundary curves
        patch
        trimming_curves % list of trimming curves (it is a subgroup of the curves list)
        trimmed_edges   % list of trimmed edges which indicates it is a "trimmed" ...
                        % part of the outer boundary of the untrimmed patch ...
                        % (it is a subgroup of the curves list)

    end
    
    methods
        
        % initialize all parameters
        function bound = class_stp_bound()
            % nothing initialized; everything added step by step
        end
        
    end
    
end