%gets fileNames filtered by 'fileExtension' from 'directory' recursively
%usage: fNames = GetFileNames('D:\bla\', '.m');
function fileNames = GetFileNames(directory, fileExtension)
    
    contents    = dir(directory);
    directories = find([contents.isdir]);

    fileIndicies = find(~[contents.isdir]);    
    fileStructures = contents(fileIndicies);

    %get files
    fileNames = {};
    for i = 1 : 1 : length(fileStructures)
        fileName = fullfile(directory, fileStructures(i).name);

        %**************filter****************
        [folder, name, extension] = fileparts(fileName);
        if( strcmp(extension, fileExtension) )       
            fileNames = cat(1, fileNames, fileName);
        end
    end

    %recurse down (directory tree)
    for idxDir = directories

        subDirectory  = contents(idxDir).name;
        fullDirectory = fullfile(directory, subDirectory);

        % ignore '.' and '..'
        if (strcmp(subDirectory, '.') || strcmp(subDirectory, '..'))
            continue;
        end 

        % Recurse down
        fileNames = cat(1, fileNames, GetFileNames(fullDirectory, fileExtension));
    end

end