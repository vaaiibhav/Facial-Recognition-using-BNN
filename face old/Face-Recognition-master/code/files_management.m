function f = files_management
    f.createValidDataStructure = @createValidDataStructure;
    f.readValidFiles = @readValidFiles;
    f.checkData = @checkData;
    
    f.checkRawDispersity = @checkRawDispersity;
end


% PUBLIC
% ********************************************************************* %
% ********************************************************************* %

function [ data , images , image_name ] = createValidDataStructure( folder )

    % Check valid files
    [ image_name , file_name ] = readValidFiles( folder );

    % Save valid data in a structure
    for i = 1:1:size( file_name , 2 )
        
        fullFileName = fullfile( folder , file_name{i} );
        fileID = fopen( fullFileName , 'r' );
        
        % Change these two lines for dlmread ??
        F{i} = fscanf( fileID , '%u' );%This is the positions for features in real images, 10*1
        F{i} = reshape(F{i}, [2,5]);% reshape to 2*5

        fullImageName = fullfile( folder , image_name{i} );
        I{i} = imread(fullImageName);
  
    end
    data = F;
    images = I;
end


function [ image_name , file_name ] = readValidFiles( path )
    
    % Take all images in .jpg and .JPG format
    images = [ dir( cat( 2, path , '*.jpg' ) ) ; dir( cat( 2, path , '*.JPG' ) ) ];
    images = {images.name};

    % Take all files in .txt format
    files = dir( cat( 2, path , '*.txt' ) );
    files = {files.name};
    
    % Check some properties of the database
    k = 1;
    for i = 1:1:size( images , 2 )
        % Check if each image .jpg has its file .txt
        tmp_jpg = strsplit( images{ i } , '.jpg' );
        if( not( isempty( find( ismember( files , strcat( tmp_jpg( 1 ) , '.txt' ) ) ) ) ) )
            tmp_file_name = strcat( tmp_jpg{ 1 } , '.txt' );
            
            % Check if the .txt file has the correct amount of data
            % Build two vectors for the correct images and files
            try
                file = dlmread( strcat( path , tmp_file_name ) );
                assert( size( file , 1 ) == 5 );
                assert( size( file , 2 ) == 2 );

                image_name{ k } = images{ i };
                file_name{ k } = strcat( tmp_jpg{ 1 } , '.txt' );
                k = k + 1;
            catch
                fprintf( 2, cat( 2, cat( 2, 'Error reading ', tmp_file_name ), '\n' ) );
            end
            continue;
        end
            
        % Check if each image .JPG has its file .txt
        tmp_JPG = strsplit( images{ i } , '.JPG' );    
        if( not( isempty( find( ismember( files , strcat( tmp_JPG( 1 ) , '.txt' ) ) ) ) ) )
            tmp_file_name = strcat( tmp_JPG{ 1 } , '.txt' );
            
            % Check if the .txt file has the correct amount of data
            % Build two vectors for the correct images and files
            try
                file = dlmread( strcat( path , tmp_file_name ) );
                assert( size( file , 1 ) == 5 );
                assert( size( file , 2 ) == 2 );

                image_name{ k } = images{ i };
                file_name{ k } = strcat( tmp_JPG{ 1 } , '.txt' );
                k = k + 1;
            catch
                fprintf( 2, cat( 2, cat( 2, 'Error reading ', tmp_file_name ), '\n' ) );
            end
            continue;
        end
        
        % Inform which file .txt was not found
        tmp_file_name = strsplit( images{ i } , '.' );
        fprintf( 2, cat( 2, cat( 2, strcat( tmp_file_name{1} , '.txt' ) , ' not found' ), '\n' ) ); 
    end
    
    % Sort names
    try
        image_name = sort( image_name );
        file_name = sort( file_name ); 
    catch
        image_name = 0;
        file_name = 0;
    end
end

function c = checkData( path )
    
    % Clear workspace
    %clearAll();

    % Read valid files in path
    [ image_name , file_name ] = readValidFiles( path );

    % Display all valid images with its features
    e = 21; 
    for f = 1:1:size( image_name , 2 )
        % Show 20 images for figure
        if( e > 20 )
            figure;
            set(gcf, 'Position', get( 0 , 'Screensize' ) );
            e = 1;
        end
        
        try
            file = dlmread( strcat( path , file_name{ f } ) );
            
            subplot( 4 , 5 , e ); imshow( strcat( path , image_name{ f } ) ); hold on;
            plot( file( 1 , 1 ) , file( 1 , 2 ) , 'r*' , 'MarkerSize' , 4 ); hold on;
            plot( file( 2 , 1 ) , file( 2 , 2 ) , 'g*' , 'MarkerSize' , 4 ); hold on;
            plot( file( 3 , 1 ) , file( 3 , 2 ) , 'b*' , 'MarkerSize' , 4 ); hold on;
            plot( file( 4 , 1 ) , file( 4 , 2 ) , 'm*' , 'MarkerSize' , 4 ); hold on;
            plot( file( 5 , 1 ) , file( 5 , 2 ) , 'y*' , 'MarkerSize' , 4 ); hold off;
        catch
            fprintf( 2, cat( 2, cat( 2, 'Error representing ', file_name{f} ), '\n' ) );
        end
        e = e + 1;
    end
end


function c = checkRawDispersity( path )
    
    % Clear workspace
    %clearAll();

    % Read valid files in path
    [ image_name , file_name ] = readValidFiles( path );

    % Display dispersity of the raw data
    figure;
    for f = 1:1:size( image_name , 2 )
        try
            file = dlmread( strcat( path , file_name{ f } ) );
            
            %subplot( 4 , 5 , e ); imshow( strcat( path , image_name{ f } ) ); hold on;
            plot( file( 1 , 1 ) , file( 1 , 2 ) , 'r*' , 'MarkerSize' , 2 ); hold on;
            plot( file( 2 , 1 ) , file( 2 , 2 ) , 'g*' , 'MarkerSize' , 2 ); hold on;
            plot( file( 3 , 1 ) , file( 3 , 2 ) , 'b*' , 'MarkerSize' , 2 ); hold on;
            plot( file( 4 , 1 ) , file( 4 , 2 ) , 'm*' , 'MarkerSize' , 2 ); hold on;
            plot( file( 5 , 1 ) , file( 5 , 2 ) , 'y*' , 'MarkerSize' , 2 ); hold on;
        catch
            fprintf( 2, cat( 2, cat( 2, 'Error representing ', file_name{f} ), '\n' ) );
        end
    end
    hold off;
end



% PRIVATE
% ********************************************************************* %
% ********************************************************************* %

% This function clear the Matlab workspace and screen
function c = clearAll()
    clear all;
    clc;
end