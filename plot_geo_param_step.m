function plot_geo_param_step(surf_geo,resolution,list_plot_patch)
% plot_geo_param_step(surf_geo,resolution,list_plot_patch)
%
% plot of all or selected patches (separately) in their parametric spaces
% the orientation of the curves is given to indicate which regions are
% trimmed
%
% Input:
%   surf_geo:           object of a surface geometry
%   resolution:         resolution of the trimming curves
%   list_plot_patch:    list of the patches which should be plotted; if it
%                       is empty all patches are plotted
%
% 2023, UniBW, Department of Civil Engineering and Environmental Sciences
% M. Loibl

%---------------
% plot all if list_plot_patch is empty
if isempty(list_plot_patch)
    list_plot_patch = [1:length(surf_geo.patch)]; %#ok<NBRAK>
end

%--------------
% informations about plot colors
color_mesh = 'k';
color_curv_trimm = 'r';
color_curv_untrimm = 'g';
line_style_control_polygon = '--ok';
fprintf('The following plot settings are used: \nFor the mesh: %s\nFor trimming curves: %s\nFor regular boundary curves: %s\nFor control polygons: %s\n\n',...
    color_mesh,color_curv_trimm,color_curv_untrimm,line_style_control_polygon);

point = zeros(2,3);

for ip = 1:length(surf_geo.patch)
    if any(ip==list_plot_patch)
        figure()
        p = surf_geo.patch(ip).p(1);
        q = surf_geo.patch(ip).p(2);
        U = surf_geo.patch(ip).U{1};
        V = surf_geo.patch(ip).U{2};
        for iv = q+1:length(V)-q
            if V(iv) ~= V(iv+1) || iv==(length(V)-q)
                for iu = p+1:length(U)-p
                    if U(iu) ~= U(iu+1) || iu==(length(U)-p)
                        plot([U(iu) U(iu+1)],[V(iv) V(iv)],'color',color_mesh)
                        hold on
                        plot([U(iu) U(iu)],[V(iv) V(iv+1)],'color',color_mesh)
                        hold on
                    end
                end
            end
        end
        bounds_index = surf_geo.patch(ip).bounds;
        for ib = 1:length(bounds_index)
            bound = surf_geo.bounds(bounds_index(ib));
            for ic = 1:length(bound.curves)
                curve = surf_geo.curves(bound.curves(ic));
                curve_param = curve.parametric;
                if curve.trimming_curve
                    color_curv = color_curv_trimm;
                else
                    color_curv = color_curv_untrimm;
                end
                
                % plot control polygon
                plot(curve_param.CP_curv(:,1),curve_param.CP_curv(:,2),line_style_control_polygon)
                hold on
                
                % plot curve
                u_step = (curve_param.U_curv(end) - curve_param.U_curv(1))/resolution;
                u = curve_param.U_curv(1);
                point(1,:) = plot_utility_get_point_curv(curve_param.p_curv,0,u,curve_param.U_curv,curve_param.CP_curv);
                text(point(1,1)+0.015,point(1,2),point(1,3),['C' num2str(bound.curves(ic))]);   % plot curve number
                for ir = 1:resolution
                    u = u + u_step;
                    point(2,:) = plot_utility_get_point_curv(curve_param.p_curv,0,u,curve_param.U_curv,curve_param.CP_curv);
                    plot(point(:,1),point(:,2),'color',color_curv)
                    hold on
                    point(1,:) = point(2,:);
                end
                
                % plot knots
                for iu = curve_param.p_curv+2:length(curve_param.U_curv)-curve_param.p_curv-2
                    point = plot_utility_get_point_curv(curve_param.p_curv,0,curve_param.U_curv(iu),...
                        curve_param.U_curv,curve_param.CP_curv);
                    line(point(1),point(2),'LineStyle','none','Marker','x','color',color_curv)
                    hold on
                end

                % draw tangent vector for orientation
                tangent_size = 0.2; % should normally fit if parameter space is normalized
                tangent = plot_utility_get_deriv_point_curv(curve_param.p_curv,0,curve_param.U_curv(1),curve_param.U_curv,curve_param.CP_curv);
                tangent = tangent/norm(tangent)*tangent_size;
                point(1,:) = plot_utility_get_point_curv(curve_param.p_curv,0,curve_param.U_curv(1),curve_param.U_curv,curve_param.CP_curv);
                point(2,:) = point(1,:) + tangent;
                vectarrow(point(1,:),point(2,:));
                hold on
            end
        end

        title(['Parametric description of patch ' num2str(ip)])
        xlabel('parameter u');
        ylabel('parameter v');
        axis equal;
    end
end

end %function