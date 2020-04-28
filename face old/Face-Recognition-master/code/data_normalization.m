function d = data_normalization()
    d.normalize = @normalize;
end


% PUBLIC
% ********************************************************************* %
% ********************************************************************* %

function r = normalize( dataStructure , image , image_names )
    num = size( dataStructure , 2 );
    
    F = dataStructure;              % temporal

    %% Compute the first transformation (average locations)
    % Predetermined locations
    p1 = [13;20];
    p2 = [50;20];
    p3 = [34;34]; 
    p4 = [16;50];
    p5 = [48;50];
    Fp = [p1,p2,p3,p4,p5];

    % Compute the first average locations, which at first is the first images
    b_tmp = reshape(Fp, [10,1]);%store b in Ax = b
    A_tmp = [];%store A in Ax = b
    for i = 1 : 5 %5 feature points
        % Put all the known variables in A, order is:
        % [x y 1 0 0 0;
        %  0 0 0 x y 1]
        % All five coordinates, so A is a 10*6 matrix
        A_tmp = [A_tmp;F{1}(1,i), F{1}(2,i), 1, 0 ,0 ,0; 0, 0, 0, F{1}(1,i), F{1}(2,i), 1];
    end
    [U, S, V] = svd(A_tmp);
    A_tmp_inv = V * pinv(S) * U';
    x = A_tmp_inv * b_tmp;%6 * 1

    A1 = [x(1), x(2);x(4), x(5)]; % Get the first A (A in the pdf, not in Ax = b)
    b1 = [x(3);x(6)];% Get the first b (b in the pdf, not in Ax = b)

    % Get the first transformation
    F_average = A1 * F{1} + [b1, b1, b1, b1, b1];%5*2
    F_average = reshape(F_average, [10,1]);


    %% Compute the best transformation for all faces

    % Use SVD to get pseudo inverse A (A in Ax = b) for all faces, so we only compute
    % once.
    A_tmp_inv_all = [A_tmp_inv];% First include first image that we just calculate
    for i = 2 : num % all the images except the first one
        A_tmp = [];
        for j = 1 : 5
            A_tmp = [A_tmp;F{i}(1,j), F{i}(2,j), 1, 0 ,0 ,0; 0, 0, 0, F{i}(1,j), F{i}(2,j), 1];

        end
        [U, S, V] = svd(A_tmp);
        A_tmp_inv = V * pinv(S) * U';
        A_tmp_inv_all = [A_tmp_inv_all; A_tmp_inv]; %Finally should be (5*6)*10
    end

    A{1} = A1;
    b{1} = b1;

    itr = 0;
    dif = 1000.0;%threshold, which should be changed according to the number of images
    while (dif > 10)
        F_all = [];% For keeping four transformation, in order to compute the mean value
        F_last = F_average;
        for i = 1 : num 
            % We will not include first image used for computing initial F_average
            if itr == 0 && i == 1 
                continue;
            else
            x = A_tmp_inv_all((6*i-5):6*i,:) * F_average;
            A{i} = [x(1), x(2);x(4), x(5)];
            b{i} = [x(3);x(6)];
            % store the best transformation for this face
            F_tmp = A{i} * F{i} + [b{i}, b{i}, b{i}, b{i}, b{i}];%5*2
            F_tmp = reshape(F_tmp, [10,1]); %reshape to 10*1

            F_all = [F_all, F_tmp];% finally this one will be 10*4
            end
        end
        F_average = mean(F_all, 2);%update F_average, Step 4
        dif = sum(abs(F_last - F_average));
        itr = itr + 1;
    end

    %Final average transformation.
    %display(F_average);

    %% Yield affine transformation that maps the face to the 64*64 window
    %image = imread('../all_faces/eric_3.JPG');
    %t = 3 + 10;
    % new = zeros(64,64,3);
    % for i = 1 : 240
    %     for j = 1 : 320
    %         f = A{t - 1} * [j;i] + b;
    %         if f(1) <= 1 || f(2) <= 1 || f(1) > size(image,2) || f(2) >
    %         size(image,1)
    %             continue;
    %         else
    %             f(1) = round(f(1));
    %             f(2) = round(f(2));
    %             new(f(2), f(1), 1) = image(i, j, 1);
    %             new(f(2), f(1), 2) = image(i, j, 2);
    %             new(f(2), f(1), 3) = image(i, j, 3);
    %         end
    %     end
    % end
    % imshow(uint8(new));%show mapped 64*64 image

    % Compute the inverse transformation

    mapped_path = 'mapped_images/';
    for k = 1 : num

        new = zeros(64,64,3);
        for i = 1 : 64
            for j = 1 : 64
                f = A{k} \ ([i;j] - b{k});% inverse version
                if f(1) <= 1 || f(2) <= 1 || f(1) > size(image{k},2) || f(2) > size(image{k},1)
                    continue;
                else
                    f(1) = floor(f(1));
                    f(2) = floor(f(2));
                    new(j, i, 1) = image{k}(f(2), f(1), 1);
                    new(j, i, 2) = image{k}(f(2), f(1), 2);
                    new(j, i, 3) = image{k}(f(2), f(1), 3);
                end
            end
        end
        
        
        
        
        % if the image is in the test_images folder, save the normalized
        % one to it. 
        % Otherwise, to the train_images folder
        cd test_images/ %less images to check here
        
        % Unify name extension to .jpg
        base = sprintf( image_names{k} );
        base = strcat( base( 1 : size( base , 2 ) - 4 ) , '.jpg' );
        
        % Saving the images according to its function (train or test)
        if( exist( image_names{k} , 'file' ) == 2 )
            %display('train')
            %image_names{k}
            imwrite( uint8( new ) , fullfile( '_norm/' , base ) );
        else
            %display('test')
            %image_names{k}
            imwrite( uint8( new ) , fullfile( '../train_images/_norm/' , base ) );
        end
        
        
        % going back to the original path
        cd ../
        
        
        
        
        %base = sprintf('%d.jpg', k);
        %base = sprintf( image_names{k} ); 
        %imwrite(uint8(new), fullfile(mapped_path, base));   
    end
end

function l = checkDisparisty( dataStructure, A , b )

    % Read valid files in path
    %[ image_name , file_name ] = readValidFiles( path );

    % Display dispersity of the raw data
    figure;
    for f = 1:1:size( dataStructure , 2 )
        try
            %dataStructure{f}(1,1) * A{f} + b{f}
            
            feat1 = A{f}*dataStructure{f}(:,1)+b{f};
            feat2 = A{f}*dataStructure{f}(:,2)+b{f};
            feat3 = A{f}*dataStructure{f}(:,3)+b{f};
            feat4 = A{f}*dataStructure{f}(:,4)+b{f};
            feat5 = A{f}*dataStructure{f}(:,5)+b{f};
            
            %file = dlmread( strcat( path , file_name{ f } ) );
            
            
            
            plot( feat1( 1 , 1 ) , feat1( 2 , 1 ) , 'r*' , 'MarkerSize' , 2 ); hold on;
            plot( feat2( 1 , 1 ) , feat2( 2 , 1 ) , 'g*' , 'MarkerSize' , 2 ); hold on;
            plot( feat3( 1 , 1 ) , feat3( 2 , 1 ) , 'b*' , 'MarkerSize' , 2 ); hold on;
            plot( feat4( 1 , 1 ) , feat4( 2 , 1 ) , 'm*' , 'MarkerSize' , 2 ); hold on;
            plot( feat5( 1 , 1 ) , feat5( 2 , 1 ) , 'y*' , 'MarkerSize' , 2 ); hold on;
            
            %plot( file( 2 , 1 ) , file( 2 , 2 ) , 'g*' , 'MarkerSize' , 2 ); hold on;
            %plot( file( 3 , 1 ) , file( 3 , 2 ) , 'b*' , 'MarkerSize' , 2 ); hold on;
            %plot( file( 4 , 1 ) , file( 4 , 2 ) , 'm*' , 'MarkerSize' , 2 ); hold on;
            %plot( file( 5 , 1 ) , file( 5 , 2 ) , 'y*' , 'MarkerSize' , 2 ); hold on;
        catch
            display('mec')
            %fprintf( 2, cat( 2, cat( 2, 'Error representing ', file_name{f} ), '\n' ) );
        end
    end
    hold off;
end



