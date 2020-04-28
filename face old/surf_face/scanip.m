function newimg = scanip(input1)
%SCANIP Summary of this function goes here
%   Detailed explanation goes here


matcher =50;

% for i=1:27
      %  b=cd(strcat('s',num2str(i)));
        for j=1:7
            %a=imread(strcat(num2str(j),'.pgm'));
            a=(strcat(num2str(j),'.pgm'));
           % v(:,(i-1)*4+j)=reshape(a,size(a,1)*size(a,2),1);
           %a=(strcat(b,'\',a))
             match(input1,a);
             if ans >matcher
                facer = a;
                   v=a;
             end      
        end
       % cd ..
 %end
  figure (6);
subplot(122);
imshow(v);title('Found!','FontWeight','bold','Fontsize',16,'color','red');

  
end

