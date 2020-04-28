function [bpnnout] = bpnn(Edges, Edges2,n,y  )
%BPNN is Back Propogation Neural Network
%   Train nets for Neural Networks using Back Propogation 
%   
%
%
global A;
 disp('Training Neural Network');
 p123 = [-1 -1 2 2;0 5 0 5];
t123 = [-1 -1 1 1];
net = feedforwardnet(3,'trainrp');
net = train(net,p123,t123);
disp('Trained Neural Network');
disp('Found Match');
y = net(p123);
bpnnout=y;
end

