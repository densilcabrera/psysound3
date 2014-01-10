function [d,tp,fp,f,l,b,n,ch] = mirread(extract,orig,load,folder,verbose)
% Read the audio file ORIG, at temporal position indicated by EXTRACT. If
% EXTRACT is empty, all the audio file is loaded.
%   If LOAD is set to 0, just the meta-data is collected, and the actual
%       audio data is not taken into consideration. If it is set to 1, the
%       data are loaded from the current directory. If LOAD is a string, it
%       is considered as the path of the directory.   
%   If FOLDER is set to 1, no error is returned if an audio file cannot be
%       loaded.
% Output:
%   D is the audio signal,
%   TP are the temporal positions,
%   FP are the two extreme temporal positions (used for frame positions),
%   F is the sampling rate,
%   L is the duration in seconds,
%   B is the resolution in number of bits,
%   N is the file name.
%   CH are the channel index.

if nargin < 5
    verbose = 0;
end
d = {};
f = {};
l = {};
b = {};
tp = {};
fp = {};
n = {};
ch = {};
try
    [d,f,l,b,tp,fp,n,ch] = audioread(extract,@wavread,orig,load,verbose,folder);
catch
    err.wav = lasterr;
    try
       [d,f,l,b,tp,fp,n,ch] = audioread(extract,@auread,orig,load,verbose,folder);
    catch
        err.au = lasterr;
        try
            [d,f,l,b,tp,fp,n,ch] = audioread(extract,@mp3read,orig,load,verbose,folder);
        catch
            err.mp3 = lasterr;
            try
                [d,f,l,b,tp,fp,n,ch] = audioread(extract,@aiffread,orig,load,verbose,folder);
            catch
                err.aiff = lasterr;
                if length(orig)>4 && strcmpi(orig(end-3:end),'.bdf')
                    try
                       [d,f,l,b,tp,fp,n,ch] = audioread(extract,@bdfread,orig,load,verbose,folder);
                    catch
                        if not(strcmp(err.wav(1:11),'Error using') && folder)
                            misread(orig, err);
                        end
                    end
                else
                    if not(strcmp(err.wav(1:11),'Error using') && folder)
                        misread(orig, err);
                    end
                end
            end
        end
    end
end

        
function [d,f,l,b,tp,fp,n,ch] = audioread(extract,reader,file,load,verbose,folder)
n = file;
if folder
    file = ['./',file];
end
if load
    if isempty(extract)
        [s,f,b] = reader(file);
    else
        [unused,f,b] = reader(file,1);
        s = reader(file,extract(1:2));
        if length(extract) > 2
            s = s(:,extract(3));
        end
    end
    if verbose
        disp([file,' loaded.']);
    end
    d{1} = reshape(s,size(s,1),1,size(s,2)); %channels along dim 3
    ch = 1:size(s,2);
    if isempty(extract)
        tp{1} = (0:size(s,1)-1)'/f;
    else
        tp{1} = (extract(1)-1+(0:size(s,1)-1))'/f;
    end
    l{1} = (size(s,1)-1)/f;
    if isempty(s)
        fp{1} = 0;
    else
        fp{1} = tp{1}([1 end]);
    end
else
    [unused,f,b] = reader(file,1);
    dsize = reader(file,'size');
    d = dsize(1);
    l = d/f;
    tp = {};
    fp = {};
    ch = dsize(2);
end


function [y,fs,nbits] = bdfread(file,check)
DAT = openbdf(file);
NRec = DAT.Head.NRec;
if not(length(check)==2)
    b = readbdf(DAT,1);
    y = length(b.Record(43,:)) * NRec;
else
    y = [];
    if mirwaitbar
        handle = waitbar(0,'Loading BDF channel...');
    else
        handle = 0;
    end
    for i = 1:NRec
        b = readbdf(DAT,i);
        y = [y;b.Record(43,:)'];
        if handle
            waitbar(i/NRec,handle);
        end
    end
    if handle
        delete(handle)
    end
end
fs = DAT.Head.SampleRate(43);
nbits = NaN;


function misread(file,err)
display('Here are the error message returned by each reader:');
display(err.wav);
display(err.au);
display(err.mp3);
display(err.aiff);
mirerror('MIRREAD',['Cannot open file ',file]);