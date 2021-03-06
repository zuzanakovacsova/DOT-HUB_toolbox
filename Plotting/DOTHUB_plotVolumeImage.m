function DOTHUB_plotVolumeImage(mesh,image,slice_dim,slice_pos,imageThresh,cmap,crange,image_label)

%This function plots a volumetric node-wise image overlayed onto a volume 
%mesh.
%
%############################### INPUTS ###################################
%
% mesh =            The volume mesh structure with fields .node and .elem. The fifth
%                   dimension of mesh.elem is assumed to contain the tissue-label,
%                   
%
% image =           A node-wise intensity distribution
%
% slice_dim =       The dimension to take the slice. If a vector, create a
%                   sublot for each up to N = 3;
%
% slice_pos =       The dist (in same units as mesh) of the slice to take for 
%                   each dimension. Must have the same size as slice_dim
%
% imageThresh =     The value below which the values of the image are
%                   rendered transparent (e.g. a significance threshold)
%
% cmap =            colormap. (Optional).
%
%############################# Dependencies ###############################
%
% #########################################################################
% RJC, UCL, February 2020
% 
% ############################## Updates ##################################
% #########################################################################
%
% ############################### TO DO ###################################
% #########################################################################

%Manage variables #################################
tiss_ind = unique(mesh.elem(:,5));
if ~isfield(mesh,'labels')
    tissue_labels = unique(mesh.elem(:,5));
else
    tissue_labels = mesh.labels;
end

if ~exist('image_label','var')
    image_label = '';
elseif isempty(image_label)
    image_label = '';
end

load('greyJet.mat');
if ~exist('cmap','var')
    cmap = greyJet;
end
% #################################
% #################################

%Image prep
image(abs(image)<imageThresh) = nan;

sliceWidth = 1.5;
dim_label = {'x' 'y' 'z'};
view_def = [90 0;180 0;0 90];

%Handle tissue colormap
nTiss = length(tiss_ind);
tiss_cmap = gray(nTiss);
%#####
tiss_cmap(3,:)=greyJet(32,:);
%#####

set(gcf,'Color','w');
for i = 1:length(slice_dim)
    h(i).ax1 = subplot(1,length(slice_dim)+1,i);
    plotmesh(mesh.node(:,1:3),mesh.elem(:,1:5),[dim_label{slice_dim(i)} ' <' num2str(slice_pos(i)) ' & ' dim_label{slice_dim(i)} ' >' num2str(slice_pos(i)-sliceWidth)],'EdgeAlpha',0.2);
    h(i).ax1.Visible = 'off';
    h(i).ax1.View = view_def(slice_dim(i),:);
    h(i).ax1.Colormap = tiss_cmap;    
    h(i).ax1.CLim = [tiss_ind(1)-0.5 tiss_ind(end)+0.5];
    view(view_def(slice_dim(i),:));
    drawnow
    
    h(i).ax2 = axes;
    mesh.node(:,4) = image;
    plotmesh(mesh.node,mesh.elem(:,1:4),[dim_label{slice_dim(i)} ' <' num2str(slice_pos(i)) '&' dim_label{slice_dim(i)} ' >' num2str(slice_pos(i)-sliceWidth)],'EdgeAlpha',0);
    h(i).ax2.Visible = 'off';
    h(i).ax2.Colormap = cmap;    
    h(i).ax2.CLim = crange;
    view(view_def(slice_dim(i),:));
    drawnow
    h(i).ax2.Position = h(i).ax1.Position;
    
end

i = i+1;

h(i).ax1 = subplot(1,length(slice_dim)+1,i);
h(i).ax1.Visible = 'off';
h(i).ax1.Colormap = tiss_cmap;
h(i).cb1 = colorbar;
h(i).cb1.Location = 'west';
h(i).cb1.AxisLocation = 'in';
h(i).cb1.Position(2) = h(i).cb1.Position(2)+h(i).cb1.Position(4)/4;
h(i).cb1.Position(4) = h(i).cb1.Position(4)/2;
h(i).ax1.CLim = [tiss_ind(1)-0.5 tiss_ind(end)+0.5];
set(h(i).cb1,'YTick',tiss_ind,'YTickLabel',tissue_labels);
ylabel(h(i).cb1,'Tissue');

h(i).ax2 = axes;
h(i).ax2.Position = h(i).ax1.Position;
h(i).ax2.Visible = 'off';
h(i).ax2.CLim = crange;
h(i).ax2.Colormap = cmap;   
h(i).cb2 = colorbar;
h(i).cb2.Location = 'east';
h(i).cb2.AxisLocation = 'out';
h(i).cb2.Position(2) = h(i).cb2.Position(2)+h(i).cb2.Position(4)/4;
h(i).cb2.Position(4) = h(i).cb2.Position(4)/2;
ylabel(h(i).cb2,image_label);

cla(h(i).ax1);
cla(h(i).ax2);

drawnow;




