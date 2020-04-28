function p = pca()
    p.execute = @execute;
end

function [ list , string ] = execute( path , test_name )

    I = {};
    D = [];
    
    N = 64;
    M = 64;

    k = 33;
    A = [];
    
    files = dir( cat( 2, path , '*.jpg' ) );
    files = {files.name};
    number_pictures = size( files , 2 );
    
    for i = 1 : number_pictures                            
        baseImageName = files{i};                      
        image_name = fullfile(path, baseImageName);
        I{i} = double(rgb2gray(imread(image_name)));
        I{i} = reshape(I{i}', [1, N*M]);
        A = [A;I{i}];
    end
    
    %{
    
     files = dir( cat( 2, path , '*.JPG' ) );
    files = {files.name};
    size(files,2)
    
    x = 1;
    for i = (size(a,2)+1) : (size(a,2)+size(files,2))
        x
        baseImageName = files(x);
        %baseImageName = sprintf('%d.jpg', i);
        image_name = fullfile(path, baseImageName);
        I{x} = double(rgb2gray(imread(image_name)));
        I{x} = reshape(I{x}', [1, N*M]);
        A = [A;I{x}];
        x = x+1;
    end
    %}
    
    
    
    
    mean_X = mean(A,1);% Get mean value of every dimension
    D = [];
    for i = 1 : number_pictures
        D = [D;(A(i,:) - mean_X)];
    end

    %C =  (D' * D)./(p-1);
    %[U,S,V] = svd(C);
    %Phi = U(:, 1:k);


    C =  (D * D')./(number_pictures-1);
    [U,S,V] = svd(C);
    Phi = D' * U(:, 1:k); % (p-1) is k

    %[V,d] = eig(C);
    % Phi = D' * V(:,3:p);
    %Phi = V;



    %Sigma = U;
    %Sigma = D' * U;
    %eigenface = reshape(Sigma(:,1),[64,64]);


    %Phi = Sigma(:, 1:k);

    %eigenface = D * Phi; 

    F = {};
    for i = 1 : number_pictures
        F{i} = I{i} * Phi;
        %F{i} = D(i,:) * Phi;
    end

    
    
    
    %% Test
    
    test_image = double(rgb2gray(imread(test_name)));
    X_test = reshape(test_image',[1,N*M]);
    %X_test = X_test - mean_X;
    F_test = X_test * Phi;

    min_e = 10e24; % arrange this as the error of the first image
    num = 0;
    error =[];
    for i = 1 : number_pictures
        e = sum((F_test - F{i}).^2);
        error = [error,e];
    end
    
    % Compute and return sorted structure of names
    list = {};
    [~ , Idx] = sort( error );
    for i = 1:1:size( Idx , 2)
        list{ i , 1 } = i;
        tmp = files{ Idx(i) };
        list{ i , 2 } = tmp( 1 : size( tmp , 2 ) - 6 );                                        % This string should be truncated
        list{ i , 3 } = 'm / f';
        list{ i , 4 } = files{ Idx(i) };
    end   




    %% Classification for male and female (Naive bayes classifier)

    % label for everyone, male is 1 and female is 2;
    p = number_pictures;
    label = ones(1,p);
    label(1:3) = 2;
    label(16:18) = 2;

    % prior probability of male and female 
    p_male = 48/54;
    p_female = 6/54;

    % Get mean and variance of each dimension of features in order to get the
    % likelihood probability
    Male_Matrix = [];
    Female_Matrix = [];
    for i = 1 : p
        if label(i) == 1 
            Male_Matrix = [Male_Matrix;F{i}];
        else
            Female_Matrix = [Female_Matrix; F{i}];
        end
    end

    mean_F_male = mean(Male_Matrix);
    var_F_male = var(Male_Matrix);

    mean_F_female = mean(Female_Matrix);
    var_F_female = var(Female_Matrix);



    %% Test classification 
    Likelihood_male = 1;
    Likelihood_female = 1;

    % Likelihood should be according to normal distribution
    for i = 1 : k
        Likelihood_male = Likelihood_male * (1/sqrt(2 * pi * var_F_male(i))) * exp( -(F_test(i) - mean_F_male(i))^2 / (2 * var_F_male(i)));
        Likelihood_female = Likelihood_female * (1/sqrt(2 * pi * var_F_female(i))) * exp( -(F_test(i) - mean_F_female(i))^2 / (2 * var_F_female(i)));
    end


    % Compute the bayes posterior probability

    post_male = Likelihood_male * p_male;
    post_female = Likelihood_female * p_female;

    male = post_male/(post_male + post_female);
    female = post_female/(post_male + post_female);

    if post_male/post_female > 1
        %display('boy');
        string = strcat( 'Looking for a male with a probabilty of' , {' '} , int2str( male * 100 ) , '%' );
    else
        %display('girl');
        string = strcat( 'Looking for a female with a probabilty of' , {' '} , int2str( female * 100 ) , '%' );
    end

end