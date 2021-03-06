function [jac, jacFileName] = DOTHUB_writeJAC(jacFileName,logData,J,basis)

% This script creates a .jac file, which organizes and stores Jacobians for
% DOT reconstruction.
%
% ####################### INPUTS ##########################################
%
% jacFileName       :  The desired path &/ filename for the .jac file.
%                      This can be anything, but we recommend this variable be defined with the
%                      following code snippet, where: rmapFileName = full path and name
%                      of rmap on which jacobian calculated; transportPackage = 'toast++' or
%                      equivalent. opticalPropertiesByTissue = matrix of optical properties used.
%                      This snippet also provides recommended input variable 'logData'. 
%
%                        % ds = datestr(now,'yyyymmDDHHMMSS');
%                        % [pathstr, name, ~] = fileparts(rmapFileName);
%                        % jacFileName = fullfile(pathstr,[name '.jac']);
%                        % transportPackage = 'toast';
%                        % logData(1,:) = {'Created on: ', ds};
%                        % logData(2,:) = {'Derived from rmap file: ', rmapFileName};
%                        % logData(3,:) = {'Calculated using: ', transportPackage};
%                        % logData(4,:) = {'Optical properties (tissueInd,
%                        wavelength,[mua musPrime refInd]): ', opticalPropertiesByTissue};%
%
% logData           :  (Optional). logData is a cell array of strings containing useful
%                      info as per snippet above. Parse empty to ignore.
%                        
% J                 :   A cell structure of length nWavs, containing .vol .basis and .gm 
%                       of dimensions #channels x #nodes
%                       Units are mm:
%                       d(ln(Intensity_active/Intensity_baseline))/d(absorbtion coefficient (mm-1))
%                       If the Jacobian was calculated using a basis, J{i}.basis will be populated.  
%                       If the Jacobian was calculated on the full volume mesh, J{i}.vol will be 
%                       populated (and have dimensions nChan x nVolumeNodes). J{1}.gm is always 
%                       populated, and is the vol2gm extracted of the full volume Jacobian 
%                       (useful for visualization, masking etc.).
%
% basis             :   (Optional) 1x3 vector specifying the basis in which J is defined.
%                       If basis is not parsed, jac.basis will be saved empty = [] 
%                       and J{i}.vol is assumed to be in the volume mesh space
%
% ####################### OUTPUTS #########################################
%
% jac                      :  Structure containing all data inputs
%
% jacFileName              :  The full path of the resulting .jac file
%
% .jac                     :  A file containing a structure of:
%                           jac.logData             - as defined above
%                           jac.J                   - as defined above
%                           jac.basis               - as defined above
%                           jac.fileName            - the path of the saved jac file
%
% ####################### Dependencies ####################################
% #########################################################################
% RJC, UCL, April 2020
%
% ############################# Updates ###################################
% #########################################################################

% MANAGE VARIABLES
% #########################################################################

jac.J = J;

if isempty(logData)
    logData = {};
    warning('logData is empty: this might make it harder to keep track of your data...');
end
jac.logData = logData;

if ~exist('basis','var')
    jac.basis = [];
else
    jac.basis = basis;
end

%Create filename ##########################################################
[pathstr, name, ext] = fileparts(jacFileName);
if isempty(ext) || ~strcmpi(ext,'.jac')
    ext = '.jac';
end
if isempty(pathstr)
    pathstr = pwd;
end
jacFileName = fullfile(pathstr,[name ext]);
jac.fileName = jacFileName; %including the fileName within the structure is very useful 
%for tracking and naming things derived further downstream.

if exist(jacFileName,'file')
    warning([name ext ' will be overwritten...']);
end

%Save .jac file ###########################################################
save(jacFileName,'-struct','jac','-v7.3');
fprintf('##################### Writing .jac file #########################\n');
fprintf(['.jac data file saved as ' jacFileName '\n']);
fprintf('\n');
