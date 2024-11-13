function surf_geo = import_STEP(filename)
% surf_geo = import_STEP(filename)
%
% This function reads in the geometry of a trimmed NURBS surface from a
% .stp/.step file.
% Knot vectors are normalized to the space [0 1] throughout the import for convenience.
%
% Input:
%   filename:   name of step file (the file is located in one of the folder
%               previously added to the path)
%
% Output:
%   surf_geo:   geometry consisting of surface (object)
%
% 2023, UniBW, Department of Civil Engineering and Environmental Sciences
% M. Loibl

%------------------------------------
% read step file
[file_ID, ~]=fopen(filename,'r');
[file_loaded]=fread(file_ID)';
file_loaded=char(file_loaded);      % convert to char

%-----------------------------------
% extract data part (delete unnecessary lines)
index = strfind(file_loaded,'DATA;');
file_loaded = file_loaded(index+5:end);
index = strfind(file_loaded,'ENDSEC;');
file_loaded = file_loaded(1:index-1);
empty_spaces = 0; % number of empty spaces before the next #
while ~strcmp(file_loaded(1),'#')
    file_loaded = file_loaded(2:end);
    empty_spaces = empty_spaces + 1;    % the number of empty spaces may differ from file to file and is therefore determined here; it is assumed that it is equal for all lines
end

%-----------------------------------
% extract objects
index = strfind(file_loaded,';');
index_start = 2;
text = {};
for i = 1:length(index)
    text_temp = file_loaded(index_start:index(i)-1);
    char_nr = 1;
    identifier = '';
    while ~strcmp(text_temp(char_nr),'=')
           identifier = [identifier text_temp(char_nr)]; %#ok<AGROW>
           char_nr = char_nr + 1;
    end
    text{str2double(identifier)} = text_temp(char_nr + 1:end); %#ok<AGROW>
    index_start = index(i) + empty_spaces + 2;
end

%-----------------------------------
% closed and open shells
shells = [];
patches_shell = [];
index_patches = [];
for i = 1:length(text)
    text_temp = text{i};
    if isempty(text_temp)
        continue
    end
    if contains(text_temp,'OPEN_SHELL')
        [shells,patches_shell,index_patches] = find_faces(shells,patches_shell,index_patches,'OPEN_SHELL',text_temp);
    elseif contains(text{i},'CLOSED_SHELL')
        [shells,patches_shell,index_patches] = find_faces(shells,patches_shell,index_patches,'CLOSED_SHELL',text_temp);
    end
end

%----------------------------------
% patches
bounds = [];
curves = [];
for ip = 1:length(patches_shell)
    flag_patch_trimm = false;
    
    %-----------------
    % initialize patch object
    patch_temp = class_stp_patch();
    
    %-----------------
    % face types
    patch_temp.patch_nr = ip;
    text_temp = text{index_patches(ip)};
    if contains(text_temp,'ADVANCED_FACE')
        patch_temp.type_face = 'ADVANCED_FACE';
    elseif contains(text_temp,'FACE_SURFACE')
        patch_temp.type_face = 'FACE_SURFACE';
    end
    
    %-----------------
    % find bounds
    right_brackets = strfind(text_temp,')');
    bounds_index = find_attribute(text_temp(1:right_brackets(1)));
    count_bounds = length(bounds);
    patch_temp.bounds = count_bounds+1:count_bounds+length(bounds_index);
    
    %-----------------
    % find surface
    index = find_attribute(text_temp(right_brackets(1)+1:end));
        
    %-----------------
    % read surfaces
    text_temp = text{index};
    if (contains(text_temp,'B_SPLINE_SURFACE_WITH_KNOTS') && ~contains(text_temp,'BOUNDED_SURFACE'))
        patch_temp.type_surf = 'B_SPLINE_SURFACE_WITH_KNOTS';
        [patch_temp,U_normalize] = read_b_spline_surface(patch_temp,text,index);
    elseif (contains(text_temp,'B_SPLINE_SURFACE_WITH_KNOTS') && contains(text_temp,'BOUNDED_SURFACE'))
        patch_temp.type_surf = 'BOUNDED_SURFACE';
        [patch_temp,U_normalize] = read_bounded_surface(patch_temp,text,index);
    else
        error('Unknown surface entity in patch %d. Maybe it can be added in the code.',ip)
    end
    
    %-----------------
    % read bounds
    for i = 1:length(bounds_index)
        bound_patch = class_stp_bound();
        bound_patch.bound_nr = i;
        text_temp = text{bounds_index(i)};
        if contains(text_temp,'FACE_BOUND')
            bound_patch.type = 'inner';
        elseif contains(text_temp,'FACE_OUTER_BOUND')
            bound_patch.type = 'outer';
        end
        
        hashtag = strfind(text_temp,'#');
        commas = strfind(text_temp(hashtag:end),',') + hashtag - 1;
        index = str2double(text_temp(hashtag+1:commas-1));
        
        %-------------
        % read EDGE_LOOP
        text_temp = text{index};
        hashtag = strfind(text_temp,'#');
        edges = [];
        for j = 1:length(hashtag)
            char_nr = hashtag(j) + 1;
            string_temp = [];
            while ~(strcmp(text_temp(char_nr),',') || strcmp(text_temp(char_nr),')'))
                string_temp = [string_temp text_temp(char_nr)];
                char_nr = char_nr + 1;
            end
            edges = [edges str2double(string_temp)];
        end
        count_curves = length(curves);
        bound_patch.curves = count_curves+1:count_curves+length(edges);
        
        bound_trimm_curves = [];   % list all curves of the bound which are trimming curves
        
        %-------------
        % read ORIENTED_EDGE
        for j = 1:length(edges)
            curve = class_stp_curve();
            text_temp = text{edges(j)};
            hashtag = strfind(text_temp,'#');
            commas = strfind(text_temp(hashtag:end),',') + hashtag - 1;
            index = str2double(text_temp(hashtag+1:commas-1));
            dots = strfind(text_temp(commas:end),'.') + commas - 1;
            orientation = text_temp(dots(1)+1);
            if strcmp(orientation,'T')
                orientation = true;
            elseif strcmp(orientation,'F')
                orientation = false;
            end
            % read EDGE_CURVE
            text_temp = text{index};
            hashtag = strfind(text_temp,'#');
            commas = strfind(text_temp(hashtag(1):end),',') + hashtag(1) - 1;
            index = [str2double(text_temp(hashtag(1)+1:commas(1)-1)) str2double(text_temp(hashtag(2)+1:commas(2)-1))...
                str2double(text_temp(hashtag(3)+1:commas(3)-1))];
            % read start and end VERTEX_POINT of EDGE_CURVE
            vertex = zeros(2,3);
            for k = 1:2
                text_temp = text{index(k)};            
                hashtag = strfind(text_temp,'#');
                right_brackets = strfind(text_temp(hashtag:end),')') + hashtag - 1;
                index(k) = str2double(text_temp(hashtag+1:right_brackets-1));   % just overwrite index to not define an additional variable
                text_temp = text{index(k)};
                vertex(k,:) = read_cartesian_point(text_temp);
            end
            if orientation
                curve.vertex_start = vertex(1,:);
                curve.vertex_end = vertex(2,:);
            else
                curve.vertex_start = vertex(2,:);
                curve.vertex_end = vertex(1,:);
            end
            
            %-------------
            % read SURFACE_CURVE
            text_temp = text{index(3)};
            if ~contains(text_temp,'SURFACE_CURVE') % check for user
                error('At this point a SURFACE_CURVE is expected as curve attribute of an EDGE_CURVE. Maybe the step file does not contain parametric descriptions of the trimming curve!?')
            end
            hashtag = strfind(text_temp,'#');
            index = [];
            for k = 1:length(hashtag)
                char_nr = hashtag(k) + 1;
                string_temp = [];
                while ~(strcmp(text_temp(char_nr),',') || strcmp(text_temp(char_nr),')'))
                    string_temp = [string_temp text_temp(char_nr)];
                    char_nr = char_nr + 1;
                end
                index = [index str2double(string_temp)];
            end
            
            %-------------
            % read B_SPLINE_CURVE_WITH_KNOTS or BOUNDED_CURVE defined in physical space    
            text_temp = text{index(1)};
            if (contains(text_temp,'B_SPLINE_CURVE_WITH_KNOTS') && ~contains(text_temp,'BOUNDED_CURVE'))
                curve.physical = read_b_spline_curve(text,index(1));
            elseif (contains(text_temp,'B_SPLINE_CURVE_WITH_KNOTS') && contains(text_temp,'BOUNDED_CURVE'))
                curve.physical = read_bounded_curve(text,index(1));
            else
                error('Unknown curve entity in patch %d. Maybe it can be added in the code.',ip)
            end
            
            %-------------
            % read PCURVE (can be a list of two PCURVEs; this is the case
            % for the cylinder and probably for closed surfaces in general)
            if orientation
                k = 2;
            else
                k = 3;
            end
            text_temp = text{index(k)};
            hashtag = strfind(text_temp,'#');
            right_brackets = strfind(text_temp,')');
            index(k) = str2double(text_temp(hashtag(2)+1:right_brackets-1));    % just overwrite index to use not an additional variable
            % read DEFINITIONAL_REPRESENTATION
            text_temp = text{index(k)};
            hashtag = strfind(text_temp,'#');
            right_brackets = strfind(text_temp,')');
            index(k) = str2double(text_temp(hashtag(1)+1:right_brackets(1)-1));    % just overwrite index to use not an additional variable
            % read B_SPLINE_CURVE_WITH_KNOTS or BOUNDED_CURVE defined in parametric
            % space            
            text_temp = text{index(k)};
            if (contains(text_temp,'B_SPLINE_CURVE_WITH_KNOTS') && ~contains(text_temp,'BOUNDED_CURVE'))
                curve_param = read_b_spline_curve(text,index(k));
                % normalize CPs (because the parametric space of the
                % underlying patch was normalized)
                curve_param.CP_curv(:,1) = (curve_param.CP_curv(:,1) - U_normalize(1,1)) / (U_normalize(1,2) - U_normalize(1,1));
                curve_param.CP_curv(:,2) = (curve_param.CP_curv(:,2) - U_normalize(2,1)) / (U_normalize(2,2) - U_normalize(2,1));
            elseif (contains(text_temp,'B_SPLINE_CURVE_WITH_KNOTS') && contains(text_temp,'BOUNDED_CURVE'))
                curve_param = read_bounded_curve(text,index(k));                    
                % normalize CPs (because the parametric space of the
                % underlying patch was normalized)
                curve_param.CP_curv(:,1) = (curve_param.CP_curv(:,1) - U_normalize(1,1)) / (U_normalize(1,2) - U_normalize(1,1));
                curve_param.CP_curv(:,2) = (curve_param.CP_curv(:,2) - U_normalize(2,1)) / (U_normalize(2,2) - U_normalize(2,1));
            else
                error('Unknown curve entity in patch %d. Maybe it can be added in the code.',ip)
            end
            if ~orientation     % change ordering of CP
                curve_param.CP_curv = curve_param.CP_curv(end:-1:1,:);
                curve.physical.CP_curv = curve.physical.CP_curv(end:-1:1,:);
            end
            curve.parametric = curve_param;
            
            %-------------
            % check whether edge is trimming line
            flag_trimm_line = check_trimming_curve(curve);
            curve.trimming_curve = flag_trimm_line;
            curve.trimmed_edge = false;
            if flag_trimm_line
                bound_trimm_curves = [bound_trimm_curves count_curves+j];
                flag_patch_trimm = true;
            else
                curve.trimmed_edge = check_trimmed_edge(curve);
            end
            
            %-------------
            % reference backwards from curve to bound
            curve.bound = length(bounds) + 1;
            curve.bound_type = bound_patch.type;
            
            %-------------
            % reference backwards from curve to patch
            curve.patch = ip;
            
            %-------------
            % global curves
            curves = [curves curve];
        end
        
        %-------------
        % global bounds
        bound_patch.patch = ip;
        bound_patch.trimming_curves = bound_trimm_curves;
        bounds = [bounds bound_patch];
        
    end % read bounds

    %-----------------------
    % global patches
    patch_temp.trimm = flag_patch_trimm;
    patch(ip) = patch_temp;
end % loop over shell patches
  
%-------------------------
% transfer data
surf_geo = class_stp_surf_geo(patch,bounds,curves);

fclose(file_ID);

end % function

function flag_trimmed_edge = check_trimmed_edge(curve)
% function checks whether the edge curve is part of an edge of the untrimmed
% patch, but not the complete one

    CP = curve.parametric.CP_curv;
    flag_trimmed_edge = false;    
    if ~(isequal(CP(1,1:2),[0 0]) && isequal(CP(end,1:2),[1 0])) && ...
            ~(isequal(CP(1,1:2),[1 0]) && isequal(CP(end,1:2),[1 1])) && ...
            ~(isequal(CP(1,1:2),[1 1]) && isequal(CP(end,1:2),[0 1])) && ...
            ~(isequal(CP(1,1:2),[0 1]) && isequal(CP(end,1:2),[0 0]))
        flag_trimmed_edge = true;
    end
    
end % function check_trimmed_edge

function flag_trimming_curve = check_trimming_curve(curve)
% function checks whether the edge curve is a trimming curve or just the
% regular boundary of the untrimmed patch

    CP = curve.parametric.CP_curv;
    
    flag_trimming_curve = true;
    
    if all(CP(:,1)<eps) || all(CP(:,1)>1-eps) || all(CP(:,2)<eps) || all(CP(:,2)>1-eps)
        flag_trimming_curve = false;
    end
    
end % function check_trimming_curve

function attribute = find_attribute(text)
% function finds attributes marked by a '#' in .step files in a certain
% text portion

    index_attribute = strfind(text,'#');
    attribute = zeros(length(index_attribute),1);
    for j = 1:length(index_attribute)
        char_nr = index_attribute(j)+1;
        attribute_number = [];
        while ~(strcmp(text(char_nr),',') || strcmp(text(char_nr),')'))
            attribute_number = [attribute_number text(char_nr)];
            char_nr = char_nr + 1; 
        end
        attribute(j) = str2double(attribute_number);
    end
    
end % function find_attribute

function [shells,patches,index_patches] = find_faces(shells,patches,index_patches,shell_type,text)
% function finds faces
% Parameters:
%   shells:         type of shell and index of associated patch
%   patches:        reference to associated shell for each patch
%   index_patches:  object number for each face (patch) in the .step file

    count_shells = length(shells) + 1;
    if isempty(shells)
        count_patches = 0;
    else
        count_patches = length(patches);
    end
    shells(count_shells).type = shell_type;
    patches_number = find_attribute(text);
    for i = 1:length(patches_number)
        index_patches(count_patches+i) = patches_number(i);
        patches(count_patches+i) = count_shells;
    end
    shells(count_shells).patches = [count_patches+1:count_patches+i]; %#ok<NBRAK>

end % function find_faces

function curve = read_b_spline_curve(text,index)
% function reads b-spline curves
% the knot vector is normalized within this function

    text_temp = text{index};
    commas = strfind(text_temp,',');
    degree = str2double(text_temp(commas(1)+1:commas(2)-1));
    hashtag = strfind(text_temp,'#');
    left_brackets = strfind(text_temp(hashtag(end):end),'(') + hashtag(end) - 1;
    right_brackets = strfind(text_temp(hashtag(end):end),')') + hashtag(end) - 1;
    right_brackets(1) = [];

    knot_multiplicities = read_knots(text_temp,left_brackets(1),right_brackets(1));
    knots = read_knots(text_temp,left_brackets(2),right_brackets(2));

    n = sum(knot_multiplicities) - degree - 1;

    %-----------
    % prepare knots for curve struct
    U = transfer_knots_structure(knots,knot_multiplicities);

    CP_index = zeros(n,1);
    for iu = 1:n
        char_nr = hashtag(iu) + 1;
        string_temp = [];
        while ~(strcmp(text_temp(char_nr),',') || strcmp(text_temp(char_nr),')'))
            string_temp = [string_temp text_temp(char_nr)];
            char_nr = char_nr + 1;
        end
        CP_index(iu) = str2double(string_temp);
    end
    
    %-----------
    % read CP
    CP = ones(n,4);   % weight is 1 for the B_SPLINE_CURVE_WITH_KNOTS which is the only considered curve type so far
    for iu = 1:n
        text_temp = text{CP_index(iu)};
        CP(iu,1:3) = read_cartesian_point(text_temp);
    end

    %-----------
    % transfer curve geometry
    curve = class_nurbs_curve(CP,U,degree,n,'B_SPLINE_CURVE_WITH_KNOTS');

end % function read_b_spline_curve

function [patch,U_normalize] = read_b_spline_surface(patch,text,index)
% function reads b-spline surface
% the knot vectors are normalized within this function
% Parameters:
%   U_normalize:    first and last knots of the non-normalized knot vector
%                   for later normalization of the parametric curves embedded 
%                   in the parametric space of the patch

    text_temp = text{index};
    commas = strfind(text_temp,',');
    u_degree = str2double(text_temp(commas(1)+1:commas(2)-1));
    v_degree = str2double(text_temp(commas(2)+1:commas(3)-1));
    hashtag = strfind(text_temp,'#');
    left_brackets = strfind(text_temp(hashtag(end):end),'(') + hashtag(end) - 1;
    right_brackets = strfind(text_temp(hashtag(end):end),')') + hashtag(end) - 1;
    right_brackets(1:2) = [];
    
    u_multiplicities = read_knots(text_temp,left_brackets(1),right_brackets(1));
    v_multiplicities = read_knots(text_temp,left_brackets(2),right_brackets(2));
    u_knot = read_knots(text_temp,left_brackets(3),right_brackets(3));
    v_knot = read_knots(text_temp,left_brackets(4),right_brackets(4));
    
    n_u = sum(u_multiplicities) - u_degree - 1;
    n_v = sum(v_multiplicities) - v_degree - 1;
    
    count_CP = 1;
    CP_index = zeros(n_u,n_v);
    for iu = 1:n_u
        for iv = 1:n_v
            char_nr = hashtag(count_CP) + 1;
            string_temp = [];
            while ~(strcmp(text_temp(char_nr),',') || strcmp(text_temp(char_nr),')'))
                string_temp = [string_temp text_temp(char_nr)];
                char_nr = char_nr + 1;
            end
            CP_index(iu,iv) = str2double(string_temp);
            count_CP = count_CP + 1;
        end
    end
    
    %-------------
    % prepare knots for patch struct
    U_normalize = [u_knot(1) u_knot(end); v_knot(1) v_knot(end)];
    U = transfer_knots_structure(u_knot,u_multiplicities);
    V = transfer_knots_structure(v_knot,v_multiplicities);
    
    %-------------
    % read CP
    CP = ones(n_u,n_v,4);   % weight is 1 for the B_SPLINE_SURFACE_WITH_KNOTS which is the only considered surface type so far
    for iu = 1:n_u
        for iv = 1:n_v
            text_temp = text{CP_index(iu,iv)};
            CP(iu,iv,1:3) = read_cartesian_point(text_temp);
        end
    end
    
    %-------------
    % transfer patch geometry
    patch.CP = CP;
    patch.U = {U V};
    patch.p = [u_degree v_degree];
    patch.nu = [n_u n_v];
    
end % function read_b_spline_surface

function curve = read_bounded_curve(text,index)
% function reads bounded curves
% the knot vector is normalized within this function

    text_temp = text{index};
    
    % read B_SPLINE_CURVE
    if (contains(text_temp,'B_SPLINE_CURVE') && contains(text_temp,'B_SPLINE_CURVE_WITH_KNOTS') && contains(text_temp,'RATIONAL_B_SPLINE_CURVE'))
        char_nr = strfind(text_temp,'B_SPLINE_CURVE') + 15;
        commas = strfind(text_temp(char_nr(1):end),',') + char_nr(1) - 1;
        p_curv = str2double(text_temp(char_nr(1):commas(1)-1));
        hashtag = strfind(text_temp,'#');
        left_brackets = strfind(text_temp(char_nr(2):char_nr(3)),'(') + char_nr(2) - 1;
        right_brackets = strfind(text_temp(char_nr(2):char_nr(3)),')') + char_nr(2) - 1;
        left_brackets(1) = [];
        
        knot_multiplicities = read_knots(text_temp,left_brackets(1),right_brackets(1));
        knots = read_knots(text_temp,left_brackets(2),right_brackets(2));
        
        %-------------
        % prepare knots for curve struct
        U_curv = transfer_knots_structure(knots,knot_multiplicities);
        
        n_curv = sum(knot_multiplicities) - p_curv - 1;
        
        CP_curv = zeros(n_curv,4);  % also CP weights are defined for the BOUNDED_CURVE
        
        % CP weights
        left_brackets = strfind(text_temp(char_nr(3):end),'(') + char_nr(3) - 1;
        right_brackets = strfind(text_temp(char_nr(3):end),')') + char_nr(3) - 1;
        CP_curv(:,4) = read_knots(text_temp,left_brackets(1),right_brackets(1));
        
        %-----------
        % read CP        
        CP_index = zeros(n_curv,1);
        for iu = 1:n_curv
            char_nr = hashtag(iu) + 1;
            string_temp = [];
            while ~(strcmp(text_temp(char_nr),',') || strcmp(text_temp(char_nr),')'))
                string_temp = [string_temp text_temp(char_nr)];
                char_nr = char_nr + 1;
            end
            CP_index(iu) = str2double(string_temp);
        end
        for iu = 1:n_curv
            text_temp = text{CP_index(iu)};
            CP_curv(iu,1:3) = read_cartesian_point(text_temp);
        end
        
        %-------------
        % transfer curve geometry
        curve = class_nurbs_curve(CP_curv,U_curv,p_curv,n_curv,'BOUNDED_CURVE');

    else
        error('BOUNDED_CURVE is differently constructed than expected.')
    end
    
end % function read_bounded_curve

function [patch,U_normalize] = read_bounded_surface(patch,text,index)
% function reads bounded surface
% the knot vectors are normalized within this function
% Parameters:
%   U_normalize:    first and last knots of the non-normalized knot vector
%                   for later normalization of the parametric curves embedded 
%                   in the parametric space of the patch

    text_temp = text{index};
    
    % read B_SPLINE_SURFACE
    if (contains(text_temp,'B_SPLINE_SURFACE') && contains(text_temp,'B_SPLINE_SURFACE_WITH_KNOTS') && contains(text_temp,'RATIONAL_B_SPLINE_SURFACE'))
        char_nr = strfind(text_temp,'B_SPLINE_SURFACE') + 17;
        commas = strfind(text_temp(char_nr(1):end),',') + char_nr(1) - 1;
        u_degree = str2double(text_temp(char_nr(1):commas(1)-1));
        v_degree = str2double(text_temp(commas(1)+1:commas(2)-1));
        hashtag = strfind(text_temp,'#');
        left_brackets = strfind(text_temp(char_nr(2):char_nr(3)),'(') + char_nr(2) - 1;
        right_brackets = strfind(text_temp(char_nr(2):char_nr(3)),')') + char_nr(2) - 1;
        left_brackets(1) = [];
        
        u_multiplicities = read_knots(text_temp,left_brackets(1),right_brackets(1));
        v_multiplicities = read_knots(text_temp,left_brackets(2),right_brackets(2));
        u_knots = read_knots(text_temp,left_brackets(3),right_brackets(3));
        v_knots = read_knots(text_temp,left_brackets(4),right_brackets(4));
        
        n_u = sum(u_multiplicities) - u_degree - 1;
        n_v = sum(v_multiplicities) - v_degree - 1;
        
        %-------------
        % prepare knots for curve struct
        U_normalize = [u_knots(1) u_knots(end); v_knots(1) v_knots(end)];
        U = transfer_knots_structure(u_knots,u_multiplicities);
        V = transfer_knots_structure(v_knots,v_multiplicities);
        
        % CP weights
        CP = zeros(n_u,n_v,4);
        left_brackets = strfind(text_temp(char_nr(3):end),'(') + char_nr(3) - 1;
        left_brackets(1) = [];
        for iu = 1:n_u
            char_nr = left_brackets(iu) + 1;
            for iv = 1:n_v
                string_temp = [];
                while ~(strcmp(text_temp(char_nr),',') || strcmp(text_temp(char_nr),')'))
                    string_temp = [string_temp text_temp(char_nr)];
                    char_nr = char_nr + 1;
                end
                CP(iu,iv,4) = str2double(string_temp);
                char_nr = char_nr + 1;
            end
        end
        
        %-----------
        % read CP    
        count_CP = 1;
        CP_index = zeros(n_u,n_v);
        for iu = 1:n_u
            for iv = 1:n_v
                char_nr = hashtag(count_CP) + 1;
                string_temp = [];
                while ~(strcmp(text_temp(char_nr),',') || strcmp(text_temp(char_nr),')'))
                    string_temp = [string_temp text_temp(char_nr)];
                    char_nr = char_nr + 1;
                end
                CP_index(iu,iv) = str2double(string_temp);
                count_CP = count_CP + 1;
            end
        end
        for iu = 1:n_u
            for iv = 1:n_v
                text_temp = text{CP_index(iu,iv)};
                CP(iu,iv,1:3) = read_cartesian_point(text_temp);
            end
        end
        
        %-------------
        % transfer patch geometry
        patch.CP = CP;
        patch.U = {U V};
        patch.p = [u_degree v_degree];
        patch.nu = [n_u n_v];

    else
        error('BOUNDED_CURVE is differently constructed than expected.')
    end
    
end % function read_bounded_surface

function xyz = read_cartesian_point(text)

    left_brackets = strfind(text,'(');
    char_nr = left_brackets(2) + 1;
    xyz = zeros(3,1);
    for i = 1:3 % three Cartesian coordinates
        string_temp = [];
        while ~(strcmp(text(char_nr),',') || strcmp(text(char_nr),')'))
            string_temp = [string_temp text(char_nr)];
            char_nr = char_nr + 1;
        end
        char_nr = char_nr + 1;
        if ~isempty(string_temp)    % there is no third coordinate in case of parametric descriptions; therefore, we check whether there is a number at all
            xyz(i) = str2double(string_temp);
        end
    end
    
end % function read_cartesian_point

function knot = read_knots(text,left_bracket,right_bracket)

    knot = [];
    commas = strfind(text(left_bracket:right_bracket),',') + left_bracket - 1;
    index_start = left_bracket + 1;
    for iv = 1:length(commas)+1
        if iv == length(commas)+1
            index_end = right_bracket - 1;
        else
            index_end = commas(iv) - 1;
        end
        knot = [knot str2double(text(index_start:index_end))];
        index_start = index_end + 2;
    end
    
end % function read_knots

function U = transfer_knots_structure(knots,multiplicities)
% Function transfers knot vector written with multiplicities of single
% knots to knot vector where all knots are explicitly written down.
% The knot vectors are normalized within this function.

    U = [];
    for i = 1:length(knots)
        for j = 1:multiplicities(i)
           U = [U knots(i)];
        end
    end
    
    % normalize to a range from 0 to 1
    if U(1) ~= 0
        U = U - U(1);
    end
    if U(end) ~= 1
        U = U/U(end);
    end

end % function transfer_knots_structure