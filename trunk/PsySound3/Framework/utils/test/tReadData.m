function fileHandle=tReadData

    % general test file for matlab code ...
    
    % open a file, get file variables and read the first window of data.
    fileHandle=readData
    % read the next block of data
    
    fileHandle=readData(fileHandle);
    subplot(2,1,1)
    plot(fileHandle.data); pause

    fileHandle=readData(fileHandle,'WindowSize',1024)
    subplot(2,1,2)
    plot(fileHandle.data);
    xlim([1 2500]);
    ylim([-0.4 0.4]);
    while fileHandle.loc<fileHandle.samples
        fileHandle=readData(fileHandle);
    end
end