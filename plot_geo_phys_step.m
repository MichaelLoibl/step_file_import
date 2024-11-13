function plot_geo_phys_step(surf_geo,resolution,vector_size,list_plot_patch)
% plot_geo_phys_step(surf_geo,resolution,vector_size,list_plot_patch)
%
% plot of all or selected patches in the physical space
% the orientation of the patches and the curves are given to indicate which
% regions are trimmed
%
% Input:
%   surf_geo:           object of a surface geometry
%   resolution:         resolution.surf = resolution of the surfaces; 
%                       resolution.curve = resolution of the curves
%   vector_size:        size of tangent and normal vectors
%   list_plot_patch:    list of the patches which should be plotted; if it
%                       is empty all patches are plotted
%
% 2023, UniBW, Department of Civil Engineering and Environmental Sciences
% M. Loibl

resolution_surf = resolution.surf;
resolution_curv = resolution.curv;

%---------------
% plot all if list_plot_patch is empty
if isempty(list_plot_patch)
    list_plot_patch = [1:length(surf_geo.patch)];
end

figure()
for ip = 1:length(surf_geo.patch)
    if any(ip==list_plot_patch)
        p = surf_geo.patch(ip).p(1);
        q = surf_geo.patch(ip).p(2);
        U = surf_geo.patch(ip).U{1};
        V = surf_geo.patch(ip).U{2};
        CP = surf_geo.patch(ip).CP;

        %-----------------------
        % surface
        point = zeros(2,2,3);
        for iv = q+1:length(V)-q
            if V(iv) ~= V(iv+1) || iv==(length(V)-q)
                v_step = (V(iv+1)-V(iv))/resolution_surf;
                for iu = p+1:length(U)-p
                    if U(iu) ~= U(iu+1) || iu==(length(U)-p)
                        u_step = (U(iu+1)-U(iu))/resolution_surf;
                        for jr = 1:resolution_surf
                            for ir = 1:resolution_surf
                                point(1,1,:) = plot_utility_get_point_surf(p,0,U(iu)+u_step*(ir-1),U,q,0,V(iv)+v_step*(jr-1),V,CP);
                                point(1,2,:) = plot_utility_get_point_surf(p,0,U(iu)+u_step*ir,U,q,0,V(iv)+v_step*(jr-1),V,CP);
                                point(2,1,:) = plot_utility_get_point_surf(p,0,U(iu)+u_step*(ir-1),U,q,0,V(iv)+v_step*jr,V,CP);
                                point(2,2,:) = plot_utility_get_point_surf(p,0,U(iu)+u_step*ir,U,q,0,V(iv)+v_step*jr,V,CP);
                                surf(point(:,:,1),point(:,:,2),point(:,:,3),'FaceColor',([0.75 0.75 0.75]),'EdgeColor','none');
                                hold on
                            end
                        end
                    end
                end
            end
        end
        %-----------------------
        % draw surface normal for orientation at parametric point (0,0)
        point = zeros(2,3);
        
        % get CP for 1st element
        CP_1 = CP(1:p+1,1:q+1,:);
        
        % compute base vectors
        xyz_CP = reshape(CP_1(:,:,1:3),[(p+1)*(q+1),3]);
        [dR,~,~] = plot_utility_basisfunc_deriv1to3(p,p+1,0,U,q,q+1,0,V,CP_1);
        base_vectors = plot_utility_base_vectors_shellKL(dR,xyz_CP);
        point(1,:) = plot_utility_get_point_coord([0 0],surf_geo.patch(ip));
        point(2,:) = point(1,:) + base_vectors.a3_KL' * vector_size;
        vectarrow(point(1,:),point(2,:));
        hold on

        %-----------------------
        % mesh (knots)
        for iv = q+1:length(V)-q
            if V(iv) ~= V(iv+1) || iv==(length(V)-q)
                v_step = (V(iv+1)-V(iv))/resolution_surf;
                for iu = p+1:length(U)-p
                    if U(iu) ~= U(iu+1) || iu==(length(U)-p)
                        u_step = (U(iu+1)-U(iu))/resolution_surf;
                        for ir = 1:resolution_surf
                            point(1,:) = plot_utility_get_point_surf(p,0,U(iu)+u_step*(ir-1),U,q,0,V(iv),V,CP);
                            point(2,:) = plot_utility_get_point_surf(p,0,U(iu)+u_step*ir,U,q,0,V(iv),V,CP);
                            plot3(point(:,1),point(:,2),point(:,3),'color','k')
                            hold on
                        end
                        for jr = 1:resolution_surf
                            point(1,:) = plot_utility_get_point_surf(p,0,U(iu),U,q,0,V(iv)+v_step*(jr-1),V,CP);
                            point(2,:) = plot_utility_get_point_surf(p,0,U(iu),U,q,0,V(iv)+v_step*jr,V,CP);
                            plot3(point(:,1),point(:,2),point(:,3),'color','k')
                            hold on
                        end
                    end
                end
            end
        end

        %-----------------------
        % boundaries
        bounds_index = surf_geo.patch(ip).bounds;
        for ib = 1:length(bounds_index)
            bound = surf_geo.bounds(bounds_index(ib));
            for ic = 1:length(bound.curves)
                curve = surf_geo.curves(bound.curves(ic));
                curve_phys = curve.physical;
                if curve.trimming_curve
                    color_curv = 'r';
                else
                    color_curv = 'g';
                end
                u_step = (curve_phys.U_curv(end) - curve_phys.U_curv(1))/resolution_curv;
                u = curve_phys.U_curv(1);
                point(1,:) = plot_utility_get_point_curv(curve_phys.p_curv,0,u,curve_phys.U_curv,curve_phys.CP_curv);
                for ir = 1:resolution_curv
                    u = u + u_step;
                    point(2,:) = plot_utility_get_point_curv(curve_phys.p_curv,0,u,curve_phys.U_curv,curve_phys.CP_curv);
                    plot3(point(:,1),point(:,2),point(:,3),'color',color_curv,'LineWidth',2)
                    hold on
                    point(1,:) = point(2,:);
                end

                % draw tangent for orientation
                tangent = plot_utility_get_deriv_point_curv(curve_phys.p_curv,0,curve_phys.U_curv(1),curve_phys.U_curv,curve_phys.CP_curv);
                tangent = tangent/norm(tangent)*vector_size;
                point(1,:) = plot_utility_get_point_curv(curve_phys.p_curv,0,curve_phys.U_curv(1),curve_phys.U_curv,curve_phys.CP_curv);
                point(2,:) = point(1,:) + tangent;
                vectarrow(point(1,:),point(2,:));
                hold on
            end
        end
    end
end

title('Geometry in physical space')
xlabel('x');
ylabel('y');
zlabel('z');
axis equal;
end %function