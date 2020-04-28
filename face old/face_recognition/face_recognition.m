

clear all;
close all;
clc;

w=load_database();



ri=round(400*rand(1,1));   
[c,cp]=uigetfile('*.pgm','Select the face to MAtch');
c = fullfile(cp,c);
r=imread(c);       

stat = regionprops(Ilabel,'centroid');
Edges = quickmask(r);
[p,V,v, cv,D,rc] = centroid(ri,i,w);
figure(2);

subplot(121); 
imshow(reshape(r,112,92));title('Looking for ...','FontWeight','bold','Fontsize',16,'color','red');

subplot(122);
                         
s=single(p)'*V;
z=[];
for i=1:size(v,2)
    z=[z,norm(cv(i,:)-s,2)];
    if(rem(i,20)==0),imshow(reshape(v(:,i),112,92)),end;
    drawnow;
end

[a,i]=min(z);
Edges2 = quickmask((reshape(v(:,i),112,92)));
figure(5);
imshowpair(Edges,Edges2,'montage');
bpnnout=bpnn(Edges,Edges2);
figure (6);
subplot(122);
imshow(reshape(v(:,i),112,92));title('Found!','FontWeight','bold','Fontsize',16,'color','red');
disp(bpnnout);

