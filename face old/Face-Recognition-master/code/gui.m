function g = gui()
    g.createGui = @createGui;
end

function handles = createGui( h_f , h_n , h_p )
    
    % Set the figure (origin at top-left corner)
    hFig = figure( 'NumberTitle' , 'off' , 'Name' , 'Face Recognition' , 'Position' , [500 , 300 , 710 , 450 ] , 'Resize' , 'off' , 'MenuBar' , 'none' );
    
    % Set the description
    description_text = sprintf(' \n  Usage of the software:\n\n    1) ''Browse database'' and ''Process database''\n    2) ''Browse picture'' and ''Identify Person''\n\n  The bottom-right table will list the results of the computation.\n  A gender filter can be applied by selecting the ''Male'' and/or\n  ''Female'' button ');
    description = uicontrol( 'Style' , 'text' , 'String' , description_text , 'HorizontalAlignment' , 'left' , 'Enable' , 'inactive' , 'Position' , [390 315 289 105] );
    
    % Set the train group
    train_group = uipanel( hFig , 'Units' , 'pixels' , 'Position', [30 315 330 105] );
    train_browse = uicontrol( 'Style' , 'pushbutton' , 'String' , 'Browse database' , 'Tag' , 'train_browse' , 'Units' , 'pixels' , 'Position' , [45 370 120 30] , 'Callback' , @database_browse );
    train_execute = uicontrol( 'Style' , 'pushbutton' , 'String' , 'Process database' , 'Tag' , 'train_execute' , 'Enable' , 'off' , 'Units' , 'pixels' , 'Position' , [225 370 120 30] , 'Callback' , @database_execute );
    train_text = uicontrol( 'Style' , 'edit' , 'String' , 'Database path...' , 'Enable' , 'inactive' , 'Position' , [45 330 300 30] );
    
    % Set the pca buttons
    pca_group = uipanel( hFig , 'Units' , 'pixels' , 'Position', [30 195 330 105] );
    pca_browse = uicontrol( 'Style' , 'pushbutton' , 'String' , 'Browse picture' , 'Enable' , 'off' , 'Tag' , 'pca_browse' , 'Units' , 'pixels' , 'Position' , [45 250 120 30] , 'Callback' , @recongnition_browse );
    pca_execute = uicontrol( 'Style' , 'pushbutton' , 'String' , 'Identify person' , 'Enable' , 'off' , 'Tag' , 'pca' , 'Units' , 'pixels' , 'Position' , [225 250 120 30] , 'Callback' , @recongnition_execute );
    gender_text = uicontrol( 'Style' , 'edit' , 'String' , '' , 'Enable' , 'inactive' , 'Position' , [45 210 300 30] );
    
    % Set the table
    %table = uitable( 'Data' , zeros(0,3) , 'ColumnWidth', {50} , 'RowName' , [] , 'ColumnWidth', {60 , 150 , 60} , 'ColumnName' , {'Ranking','Name','Gender'} , 'ColumnEditable' , [false false false] , 'Position' , [390 30 289 270] , 'CellSelectionCallback' , @table_callback );
    table = uitable( 'Data' , zeros(0,2) , 'ColumnWidth', {70} , 'RowName' , [] , 'ColumnWidth', {80 , 190} , 'ColumnName' , {'Ranking','Name'} , 'ColumnEditable' , [false false] , 'Position' , [390 30 289 270] , 'CellSelectionCallback' , @table_callback );
    
    % Save the items' handles
    handles = struct( 'hFig' , hFig , ...
                      'description' , description , ...
                      'train_group' , train_group , ...
                      'train_browse' , train_browse , ...
                      'train_execute' , train_execute , ...
                      'train_text' , train_text , ...
                      'pca_group' , pca_group , ...
                      'pca_browse' , pca_browse , ...
                      'pca_execute' , pca_execute , ...
                      'gender_text' , gender_text , ...
                      'table' , table );
    
    % Making files handles global to this file
    global h_files h_gui_h h_normalization h_pca;
    h_files = h_f;
    h_gui_h = handles;
    h_normalization = h_n;
    h_pca = h_p;
end

function database_browse( source , ~ )

    % Reading global variables handlers
    global h_gui_h;
    
    % Popup
    train_dir = uigetdir( 'all_faces' , 'Select database' );
    
    % If the path is correct
    if( train_dir ~= 0 )                                                        % Check if the database is ok, not empty,...
        
        % Arranging the obtained path and saving it 
        train_dir = strcat( train_dir , '/' );
        set( source , 'UserData' , train_dir );
        
        % Write part of the path in the textboxs                                % This can be done better (show from the nearest / that fits the length)
        path_length = size( train_dir , 2 );
        set( h_gui_h.train_text , 'String' , strcat( 'Using database ''...' , strcat( train_dir( path_length - 30 : path_length ) , '''' ) ) );
        
        % Set the status of the other buttons
        set( h_gui_h.train_execute , 'Enable' , 'on' );
        set( h_gui_h.pca_browse , 'Enable' , 'off' );
        set( h_gui_h.pca_execute , 'Enable' , 'off' );
        
        % Clean the table with the results
        set( h_gui_h.table , 'Data' , zeros(0,3) );
        
        % Clean the gender dialog box
        set( h_gui_h.gender_text , 'String' , '' );
        
        % Remove the images (overlap it)
        patch( 150 , 150 , 3 ) = 0;
        patch(:,:,1)= 204 * ones( 150 );
        patch(:,:,2)= 204 * ones( 150 );
        patch(:,:,3)= 204 * ones( 150 );
        imshow( uint8( patch ) , 'Parent' , axes( 'Units' , 'pixels' , 'Position' , [30 30 150 150] , 'Parent', h_gui_h.hFig ) );
        imshow( uint8( patch ) , 'Parent' , axes( 'Units' , 'pixels' , 'Position' , [210 30 150 150] , 'Parent', h_gui_h.hFig ) );
    end
end

function database_execute( source , ~ )                                         %The input of this function should be 100% out of errors

    % Reading global variables handlers
    global h_files h_gui_h h_normalization;
    
    % Get the path of the selected database
    train_dir = get( h_gui_h.train_browse , 'UserData' );
    
    % Check valid data in the database
    [ data , images , image_names ] = h_files.createValidDataStructure( train_dir );
    
    % Normalize valid images
    h_normalization.normalize( data , images , image_names );
    
    %Set the status of the other buttons
    set( h_gui_h.train_execute , 'Enable' , 'off' );
    set( h_gui_h.pca_browse , 'Enable' , 'on' );
    
end

function recongnition_browse( source , ~ )
    
    % Reading global variables handlers
    global h_gui_h;

    % Popup
    [FileName , PathName , ~] = uigetfile( {'*.jpg;*.JPG;'} , 'Select image' , 'test_images' );          %Should it limit only validated images? (bug!)
    
    % If the path is correct
    if( FileName ~= 0 )
        
        % Save the entire path of the equivalent 64 x 64 image
        image_path = strcat( PathName , '_norm/' , FileName );
        set( source , 'UserData' , image_path );
        
        % Show the selected image in the GUI
        imshow( imread( image_path ) , 'Parent' , axes( 'Units' , 'pixels' , 'Position' , [30 30 150 150] , 'Parent', h_gui_h.hFig ) );
        
        % Enable execute PCA button
        set( h_gui_h.pca_execute , 'Enable' , 'on' );
        
        % Clean the table with the results
        set( h_gui_h.table , 'Data' , zeros(0,3) );
        
        % Clean the gender dialog box
        set( h_gui_h.gender_text , 'String' , '' ); 
        
        % Remove the output image (overlap it)
        patch( 150 , 150 , 3 ) = 0;
        patch(:,:,1)= 204 * ones( 150 );
        patch(:,:,2)= 204 * ones( 150 );
        patch(:,:,3)= 204 * ones( 150 );
        imshow( uint8( patch ) , 'Parent' , axes( 'Units' , 'pixels' , 'Position' , [210 30 150 150] , 'Parent', h_gui_h.hFig ) );
    end
end

function recongnition_execute( source , ~ )                                         %The input of this function should be 100% out of errors
    
    % Reading global variables handlers
    global h_gui_h h_pca;

    % Recovering previously computed data
    unknown_image_path = get( h_gui_h.pca_browse , 'UserData' );

    % Compute PCA
    [ list , string ] = h_pca.execute( 'train_images/_norm/' , unknown_image_path );
    
    % Save file names of the result
    set( source , 'UserData' , list( : , 4 ) );
    
    % Fill the table with the results
    set( h_gui_h.table , 'Data' , list( : , 1 : 2 ) );
    
    % Fill the gender dialog box
    set( h_gui_h.gender_text , 'String' , string ); 
    
    % Building path
    image_path = strcat( 'train_images/_norm/' , list{ 1 , 4 } );
    
    % Show the selected image in the GUI
    imshow( imread( image_path ) , 'Parent' , axes( 'Units' , 'pixels' , 'Position' , [210 30 150 150] , 'Parent', h_gui_h.hFig ) );
end

function table_callback( ~ , eventData )

    % Reading global variables handlers
    global h_gui_h;
    
    % Avoid crash when automaticaly unselect a cell of table
    try
        % Get pressed row
        row = eventData.Indices( 1 );

        % Recovering previously computed data
        list = get( h_gui_h.pca_execute , 'UserData' );

        % Building path
        image_path = strcat( 'train_images/_norm/' , list{ row } );

        % Show the selected image in the GUI
        imshow( imread( image_path ) , 'Parent' , axes( 'Units' , 'pixels' , 'Position' , [210 30 150 150] , 'Parent', h_gui_h.hFig ) );
    catch
    end
end