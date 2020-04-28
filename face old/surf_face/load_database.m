function out=load_database()
% We load the database the first time we run the program.

persistent loaded;
persistent w;
if(isempty(loaded))
    v=zeros(10304,400);
    for i=1:27
        cd(strcat('s',num2str(i)));
        for j=1:4
            %a=imread(strcat(num2str(j),'.pgm'));
            a=strcat(num2str(j),'.pgm');
           % v(:,(i-1)*4+j)=reshape(a,size(a,1)*size(a,2),1);
           v=a;
        end
        cd ..
    end
    %w=uint8(v); % Convert to unsigned 8 bit numbers to save memory. 
    w=a;
end
loaded=1;  % Set 'loaded' to aviod loading the database again. 
out=w;