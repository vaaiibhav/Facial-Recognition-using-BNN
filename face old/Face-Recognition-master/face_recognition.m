% Face recognition project, 2015 - 2016
%
% Eric Pairet Artau: ericpairet@gmail.com
% Songyou Peng: psy920710@gmail.com
%

% Clear workspace
clear all;
clc;

% Include path to the other files
addpath('code/');

% Handler for the different files
h_normalization = data_normalization;
h_files = files_management;
h_gui = gui;
h_pca = pca;

% Clean normalization folders
mkdir( 'train_images/_norm/' );
mkdir( 'test_images/_norm/' );

% Call GUI and save item handlers
h_items = h_gui.createGui( h_files , h_normalization , h_pca );

% Eliminate temporal files
uiwait( h_items.hFig );
rmdir( 'train_images/_norm/' , 's' );
rmdir( 'test_images/_norm/' , 's' );
disp('Temporal files deleted');
