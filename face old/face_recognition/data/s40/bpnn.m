function bpnnout = bpnn(Edges, Edges2  )
%BPNN is Back Propogation Neural Network
%   Detailed explanation goes here
%   
%
%

 disp('Training Neural Network');
 p = [-1 -1 2 2;0 5 0 5];
t = [-1 -1 1 1];
net = feedforwardnet(3,'trainrp');
net = train(net,p,t);
disp('Trained Neural Network');
disp('Found Match');
y = net(p);
bpnnout=y;
end

