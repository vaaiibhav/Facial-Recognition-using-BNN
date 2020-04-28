clear all; close all ;clc;

global Face;
    [c,cp]=uigetfile('*.pgm','Select the face to MAtch');
c = strcat(cp,c);
     scanip(c);
   fprintf('recognized Face is : ');
 
   

 

