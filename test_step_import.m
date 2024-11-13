% test of step import
%
% this function should not be merged in the final code, but is only used to
% test and develope the functions related to the step import
%
% 2023, UniBW, Department of Civil Engineering and Environmental Sciences
% M. Loibl

clear
close all
clc

% geometry file
jobname = 'geometry_rectangle_circle.stp';

% import geometry
surf_geo = import_STEP(jobname);

% plot geometry
resolution_param = 20;
list_plot_patch = [];
plot_geo_param_step(surf_geo,resolution_param,list_plot_patch) % plot in parametric space
resolution_phys = struct('surf',10,'curv',10);
vector_size = 2;
plot_geo_phys_step(surf_geo,resolution_phys,vector_size,list_plot_patch) % plot in physical space

% end of script
disp('The geometry is successfully imported. Go, take a break!')