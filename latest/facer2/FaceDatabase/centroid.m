function [ p,V,v, cv,D,rc ] = centroid(ri,i,w)
%CENTROID Summary of this function goes here
%   Detailed explanation goes here

rc=w(:,ri);                          
v=w(:,[1:ri-1 ri+1:end]);          

N=20;                             
O=uint8(ones(1,size(v,2))); 
m=uint8(mean(v,2));                 
vzm=v-uint8(single(m)*single(O));    

L=single(vzm)'*single(vzm);
[V,D]=eig(L);
V=single(vzm)*V;
V=V(:,end:-1:end-(N-1));           


cv=zeros(size(v,2),N);
for i=1:size(v,2);
    cv(i,:)=single(vzm(:,i))'*V;    
end
p=rc-m;    

