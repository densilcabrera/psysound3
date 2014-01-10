function [data,Fs,nBits,formChunk] = aiffread(filePath,indexRange)
%AIFFREAD   Read AIFF (Audio Interchange File Format) sound file.
%   Y = AIFFREAD(FILE) reads an AIFF file specified by the string FILE,
%   returning the sampled data in Y. The ".aif" extension is appended if no
%   extension is given.
%
%   [Y,FS,NBITS,CHUNKDATA] = AIFFREAD(FILE) returns the sample rate (FS) in
%   Hertz, the number of bits per sample (NBITS) used to encode the data in
%   the file, and a complete structure of the chunk data (CHUNKDATA)
%   contained in the AIFF file (minus the actual audio data returned in Y).
%   See below for a description of CHUNKDATA.
%
%   [...] = AIFFREAD(FILE,N) returns only the first N samples from each
%   channel in the file.
%
%   [...] = AIFFREAD(FILE,[N1 N2]) returns only samples N1 through N2 from
%   each channel in the file.
%
%   [SIZ,...] = AIFFREAD(FILE,'size') returns the size of the audio data
%   contained in the file in place of the actual audio data, where
%   SIZ = [nSampleFrames nChannels].
%
%-NOTES--------------------------------------------------------------------
%
%   A note on compressed files:
%
%      Both AIFF and AIFC/AIFF-C (compressed) file types can be read by
%      AIFFREAD, but the data returned for AIFC/AIFF-C files will be the
%      raw, compressed data (i.e. AIFFREAD loads the data from the file
%      without modification). Currently, since there are many compression
%      formats, it is the responsibility of the user to uncompress the
%      sound data using parameters defined in the COMM chunk (contained in
%      the returned CHUNKDATA structure). When loading AIFC/AIFF-C files,
%      any optional numerical subranges are ignored and the entire set of
%      compressed data is returned as a column vector of signed bytes
%      (INT8 type).
%
%   A note on the CHUNKDATA structure:
%
%      The CHUNKDATA structure has the following fields:
%
%         -'chunkID': The 4-character ID for the chunk. This will always be
%                     the string 'FORM'.
%         -'chunkSize': The size (in bytes) of the remaining data in the
%                       file.
%         -'formType': A 4-character string for the file type that should
%                      be either 'AIFF' or 'AIFC'.
%         -'chunkArray': An array of structures, one entry for every chunk
%                        that is in the file (not counting this parent FORM
%                        chunk). The fields of this structure are:
%                           -'chunkID': The 4-character ID for the chunk.
%                           -'chunkSize': The size (in bytes) of the
%                                         remaining data in the chunk.
%                           -'chunkData': A structure of data for the
%                                         chunk. The form of this data for
%                                         a given chunkID can be found at
%                                         the links given below for the
%                                         file format standards.
%
%      The data portion of certain chunks may not have a clearly defined
%      format, or that format may be dependent on the implementation or
%      application that will be using the data. In such cases, the data
%      returned for that chunk in the CHUNKDATA structure will be in a raw
%      format (vectors of signed or unsigned 8-bit integers) and it will be
%      up to the user/application to parse and format this data correctly.
%      The following is a list of such AIFF/AIFF-C chunks:
%
%         -Audio Recording Chunk (chunkID = 'AESD'): The chunkData
%          structure has one field 'aesChannelStatusData' that stores a
%          column vector of 24 8-bit unsigned integers.
%         -Application Specific Chunk (chunkID = 'APPL'): The chunkData
%          structure has two fields. 'applicationSignature' stores a
%          4-character string identifying the application. 'data' stores a
%          column vector of 8-bit signed integers.
%         -MIDI Data Chunk (chunkID = 'MIDI'): The chunkData structure has
%          one field 'midiData' that stores a column vector of 8-bit
%          unsigned integers.
%         -Sound Accelerator (SAXEL) Chunk (chunkID = 'SAXL'): There is no
%          finalized format for Saxel chunks, so the chunkData structure
%          follows the draft format given in Appendix D of the AIFF-C
%          standard.
%
%   Description for the AIFF standard can be found here:
%
%      http://muratnkonar.com/aiff/index.html
%
%   Descriptions for the AIFC/AIFF-C standard can be found here:
%
%      http://www.cnpbagwell.com/aiff-c.txt
%      http://www-mmsp.ece.mcgill.ca/Documents/AudioFormats/AIFF/Docs/...
%             AIFF-C.9.26.91.pdf

% Author: Ken Eaton
% Last modified: 3/17/09
%--------------------------------------------------------------------------

  % Initializations:

  aiffChunkPrecedence = {'COMM' 'SSND' 'MARK' 'INST' 'COMT' 'NAME' ...
                         'AUTH' '[c] ' 'ANNO' 'AESD' 'MIDI' 'APPL'};
  aiffChunkLimits = [1 1 1 1 1 1 1 1 inf 1 inf inf];
  aifcChunkPrecedence = {'FVER' 'COMM' 'INST' 'SAXL' 'COMT' 'MARK' ...
                         'SSND' 'NAME' 'AUTH' '[c] ' 'ANNO' 'AESD' ...
                         'MIDI' 'APPL'};
  aifcChunkLimits = [1 1 1 inf 1 1 1 1 1 1 inf 1 inf inf];
  fid = -1;

  % Check the number of input arguments:

  switch nargin,
    case 0,
      error(error_message('notEnoughInputs'));
    case 1,
      indexRange = [1 inf];
  end

  % Check the file name input argument:

  if ~ischar(filePath),
    error(error_message('badArgumentType','File name','char'));
  end
  [filePath,fileName,fileExtension] = fileparts(filePath);
  if isempty(fileExtension),
    fileExtension = '.aif';
  end
  if ~any(strcmpi(fileExtension,{'.aif' '.afc' '.aiff' '.aifc'})),
    error(error_message('unknownExtension',fileExtension));
  end

  % Check the optional input argument:

  if isnumeric(indexRange),  % Numeric range specification

    indexRange = double(indexRange);
    nRange = numel(indexRange);
    if (nRange > 2) || any(indexRange < 1) || any(isnan(indexRange)),
      error(error_message('badIndexValue'));
    end
    indexRange = [ones(nRange ~= 2) round(indexRange) inf(nRange == 0)];

  elseif ischar(indexRange),  % Specification for returning just the size

    if ~strncmpi(indexRange,'size',numel(indexRange)),
      error(error_message('invalidString'));
    end
    indexRange = [];

  else  % Invalid input

    error(error_message('badArgumentType','Optional argument',...
                        'numeric or char'));

  end

  % Check that the file exists and can be opened:

  fid = fopen(fullfile(filePath,[fileName fileExtension]),'r','b');
  if fid == -1,
    error(error_message('invalidFile',[fileName fileExtension]));
  end

  % Initialize formChunk structure:

  formChunk = struct('chunkID',[],'chunkSize',[],'formType',[],...
                     'chunkArray',[]);

  % Read FORM chunk data:

  formChunk.chunkID = read_text(fid,4);
  if ~strcmp(formChunk.chunkID,'FORM'),
    error(error_message('invalidFileFormat',fileExtension));
  end
  formChunk.chunkSize = fread(fid,1,'int32');
  formType = read_text(fid,4);
  if ~any(strcmp(formType,{'AIFF' 'AIFC'})),
    error(error_message('invalidFileFormat',fileExtension));
  end
  formChunk.formType = formType;

  % Since the order of chunks is not guaranteed, first skip through the
  %   file and read just the chunkIDs and chunkSizes:

  iChunk = 0;
  chunkIDArray = {};
  chunkSizeArray = {};
  chunkDataIndex = [];
  nextChunkID = read_text(fid,4);
  while ~feof(fid),
    iChunk = iChunk+1;
    chunkIDArray{iChunk} = nextChunkID;
    chunkSize = fread(fid,1,'int32');
    chunkSizeArray{iChunk} = chunkSize;
    chunkDataIndex(iChunk) = ftell(fid);
    fseek(fid,chunkSize+rem(chunkSize,2),'cof');
    nextChunkID = read_text(fid,4);
  end

  % Check for the presence of required chunks:

  if ~ismember('COMM',chunkIDArray),
    error(error_message('missingChunk','COMM',formType));
  end
  if strcmp(formType,'AIFC') && ~ismember('FVER',chunkIDArray),
    error(error_message('missingChunk','FVER',formType));
  end

  % Check for unknown chunks and order chunks based on chunk precedence:

  if strcmp(formType,'AIFF'),
    [isChunk,orderIndex] = ismember(chunkIDArray,aiffChunkPrecedence);
  else
    [isChunk,orderIndex] = ismember(chunkIDArray,aifcChunkPrecedence);
  end
  if ~all(isChunk),
    unknownChunks = [chunkIDArray(~isChunk); ...
                     repmat({', '},1,sum(~isChunk)-1) {'.'}];
    orderIndex = orderIndex(isChunk);
    chunkIDArray = chunkIDArray(isChunk);
    chunkSizeArray = chunkSizeArray(isChunk);
    chunkDataIndex = chunkDataIndex(isChunk);
    warning('aiffread:unknownChunk',...
            ['The following chunk IDs are unknown for an ' formType ...
             ' file and will be ignored: ' unknownChunks{:}]);
  end
  [index,orderIndex] = sort(orderIndex);
  chunkIDArray = chunkIDArray(orderIndex);
  chunkSizeArray = chunkSizeArray(orderIndex);
  chunkDataIndex = chunkDataIndex(orderIndex);

  % Check for chunks that should not appear more than once:

  index = unique(index(diff(index) < 1));
  if strcmp(formType,'AIFF'),
    repeatChunks = aiffChunkPrecedence(aiffChunkLimits(index) == 1);
  else
    repeatChunks = aifcChunkPrecedence(aifcChunkLimits(index) == 1);
  end
  if ~isempty(repeatChunks),
    repeatChunks = [repeatChunks; ...
                    repmat({', '},1,numel(repeatChunks)-1) {'.'}];
    error(error_message('repeatChunk',formType,[repeatChunks{:}]));
  end

  % Initialize chunkArray data:

  formChunk.chunkArray = struct('chunkID',chunkIDArray,...
                                'chunkSize',chunkSizeArray,...
                                'chunkData',[]);

  % Read the data for each chunk:

  for iChunk = 1:numel(chunkIDArray),
    chunkData = [];
    fseek(fid,chunkDataIndex(iChunk),'bof');
    switch chunkIDArray{iChunk},

      case '[c] ',  % Copyright Chunk

        chunkData.text = read_text(fid,chunkSizeArray{iChunk});

      case 'AESD',  % Audio Recording Chunk

        chunkData.aesChannelStatusData = ...
          fread(fid,[chunkSizeArray{iChunk} 1],'*uint8');

      case 'ANNO',  % Annotation Chunk

        chunkData.text = read_text(fid,chunkSizeArray{iChunk});

      case 'APPL',  % Application Specific Chunk

        chunkData.applicationSignature = read_text(fid,4);
        chunkData.data = fread(fid,[chunkSizeArray{iChunk}-4 1],'*int8');

      case 'AUTH',  % Author Chunk

        chunkData.text = read_text(fid,chunkSizeArray{iChunk});

      case 'COMM',  % Common Chunk

        nChannels = fread(fid,1,'int16');
        chunkData.nChannels = nChannels;
        nSampleFrames = fread(fid,1,'uint32');
        if (nSampleFrames > 0) && ~ismember('SSND',chunkIDArray),
          error(error_message('missingChunk','SSND',formType));
        end
        chunkData.nSampleFrames = nSampleFrames;
        nBits = fread(fid,1,'int16');
        chunkData.sampleSize = nBits;
        exponent = fread(fid,1,'uint16');
        highMantissa = fread(fid,1,'uint32');
        lowMantissa = fread(fid,1,'uint32');
        Fs = extended2double(exponent,highMantissa,lowMantissa);
        chunkData.sampleRate = Fs;
        if strcmp(formType,'AIFF'),
          compressionType = 'NONE';
        else
          compressionType = read_text(fid,4);
          chunkData.compressionType = compressionType;
          chunkData.compressionName = read_pstring(fid);
        end

      case 'COMT',  % Comments Chunk

        nComments = fread(fid,1,'uint16');
        chunkData.nComments = nComments;
        chunkData.commentArray = struct('timeStamp',cell(nComments,1),...
                                        'marker',[],'count',[],'text',[]);
        for iComment = 1:nComments,
          chunkData.commentArray(iComment) = read_comment(fid);
        end

      case 'FVER',  % Format Version Chunk (AIFC/AIFF-C only)

        timeStamp = fread(fid,1,'uint32');
        if timeStamp ~= 2726318400,
          warning('aiffread:unknownVersion',...
                  ['File contains an unrecognized version of the ' ...
                   'AIFC/AIFF-C standard.']);
        end
        chunkData.timeStamp = timeStamp;

      case 'INST',  % Instrument Chunk

        chunkData.baseNote = fread(fid,1,'int8');
        chunkData.detune = fread(fid,1,'int8');
        chunkData.lowNote = fread(fid,1,'int8');
        chunkData.highNote = fread(fid,1,'int8');
        chunkData.lowVelocity = fread(fid,1,'int8');
        chunkData.highVelocity = fread(fid,1,'int8');
        chunkData.gain = fread(fid,1,'int16');
        chunkData.sustainLoop = read_loop(fid);
        chunkData.releaseLoop = read_loop(fid);

      case 'MARK',  % Marker Chunk

        nMarkers = fread(fid,1,'uint16');
        chunkData.nMarkers = nMarkers;
        chunkData.markerArray = struct('id',cell(nMarkers,1),...
                                       'position',[],'markerName',[]);
        for iMarker = 1:nMarkers,
          chunkData.markerArray(iMarker) = read_marker(fid);
        end
        markerIDs = [chunkData.markerArray.id];
        if any(markerIDs < 1) || (numel(unique(markerIDs)) < nMarkers),
          warning('aiffread:invalidMarkers',...
                  'Invalid or repeated marker IDs were detected.');
        end

      case 'MIDI',  % MIDI Data Chunk

        chunkData.midiData = fread(fid,[chunkSizeArray{iChunk} 1],...
                                   '*uint8');

      case 'NAME',  % Name Chunk

        chunkData.text = read_text(fid,chunkSizeArray{iChunk});

      case 'SAXL',  % Sound Accelerator (SAXEL) Chunk (AIFC/AIFF-C only)

        nSaxels = fread(fid,1,'uint16');
        chunkData.nSaxels = nSaxels;
        chunkData.saxelArray = struct('id',cell(nSaxels,1),'size',[],...
                                      'saxelData',[]);
        for iSaxel = 1:nSaxels,
          chunkData.saxelArray(iSaxel) = read_saxel(fid);
        end

      case 'SSND',  % Sound Data Chunk

        nBytes = ceil(nBits/8);
        chunkData.offset = fread(fid,1,'uint32');
        chunkData.blockSize = fread(fid,1,'uint32');
        if isempty(indexRange),
          data = [nSampleFrames nChannels];
        elseif strcmp(compressionType,'NONE'),
          if (chunkSizeArray{iChunk}-8 ~= nChannels*nSampleFrames*nBytes),
            error(error_message('sizeMismatch'));
          end
          fseek(fid,nBytes*nChannels*(indexRange(1)-1),'cof');
          nRead = min(indexRange(2),nSampleFrames)-indexRange(1)+1;
          data = fread(fid,[nChannels nRead],['*bit' int2str(nBytes*8)]).';
          if nBits < nBytes*8,
            data = data./(2^(nBytes*8-nBits));
          end
        else
          data = fread(fid,[chunkSizeArray{iChunk}-8 1],'*int8');
        end

    end
    formChunk.chunkArray(iChunk).chunkData = chunkData;
  end

  % Close the file:

  fclose(fid);

%~~~Begin nested functions~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  %------------------------------------------------------------------------
  function errorStruct = error_message(errorCode,varargin)
  %
  %   Initialize an error message (and close open files, if necessary).
  %
  %------------------------------------------------------------------------

    % Close open files, if necessary:

    if ~isempty(fopen(fid)),
      fclose(fid);
    end

    % Initialize error message text:

    switch errorCode,
      case 'badArgumentType',
        errorText = [varargin{1} ' should be of type ' varargin{2} '.'];
      case 'badIndexValue',
        errorText = ['Index range must be specified as a scalar or ' ...
                     '2-element vector of positive, non-zero, non-NaN ' ...
                     'values.'];
      case 'invalidFile',
        errorText = ['Could not open file ''' varargin{1} '''.'];
      case 'invalidFileFormat',
        errorText = ['Not a valid ' varargin{1} ' file.'];
      case 'invalidString',
        errorText = '''size'' is the only valid string argument.';
      case 'missingChunk',
        errorText = ['''' varargin{1} ''' chunk is required for a ' ...
                     varargin{2} ' file.'];
      case 'notEnoughInputs',
        errorText = 'Not enough input arguments.';
      case 'repeatChunk',
        errorText = ['The following chunk IDs should not appear more ' ...
                     'than once in an ' varargin{1} ' file: ' varargin{2}];
      case 'sizeMismatch',
        errorText =  'Data size mismatch between COMM and SSND chunks.';
      case 'unknownExtension',
        errorText = ['Unknown file extension ''' varargin{1} '''.'];
    end

    % Create error structure:

    errorStruct = struct('message',errorText,...
                         'identifier',['aiffread:' errorCode]);

  end

%~~~End nested functions~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

end

%~~~Begin subfunctions~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

%--------------------------------------------------------------------------
function value = extended2double(exponent,highMantissa,lowMantissa)
%
%   Converts an 80-bit extended floating-point type to a double.
%
%--------------------------------------------------------------------------

  signBit = bitand(exponent,32768);
  exponent = bitand(exponent,32767);
  highMantissa = bitand(highMantissa,4294967295);
  lowMantissa = bitand(lowMantissa,4294967295);
  if (exponent == 0) && (highMantissa == 0) && (lowMantissa == 0),
    value = 0;
  elseif exponent == 32767,
    if (highMantissa > 0) || (lowMantissa > 0),
      value = nan;
    else
      value = inf;
    end
  else
    value = highMantissa*2^(exponent-16414)+lowMantissa*2^(exponent-16446);
  end
  if signBit,
    value = -value;
  end

end

%--------------------------------------------------------------------------
function commentStruct = read_comment(fid)
%
%   Reads a structure of comment data from a file.
%
%--------------------------------------------------------------------------

  commentStruct = struct('timeStamp',fread(fid,1,'uint32'),...
                         'marker',fread(fid,1,'int16'),...
                         'count',[],'text',[]);
  charCount = fread(fid,1,'uint16');
  commentStruct.count = charCount;
  commentStruct.text = read_text(fid,charCount);

end

%--------------------------------------------------------------------------
function loopStruct = read_loop(fid)
%
%   Reads a structure of loop data from a file.
%
%--------------------------------------------------------------------------

  loopStruct = struct('playMode',fread(fid,1,'int16'),...
                      'beginLoop',fread(fid,1,'int16'),...
                      'endLoop',fread(fid,1,'int16'));

end

%--------------------------------------------------------------------------
function markerStruct = read_marker(fid)
%
%   Reads a structure of marker data from a file.
%
%--------------------------------------------------------------------------

  markerStruct = struct('id',fread(fid,1,'int16'),...
                        'position',fread(fid,1,'uint32'),...
                        'markerName',read_pstring(fid));

end

%--------------------------------------------------------------------------
function pascalString = read_pstring(fid)
%
%   Reads a Pascal-style string from a file, and afterwards shifts the file
% pointer ahead by one byte if necessary to make the total number of bytes
% read an even number.
%
%--------------------------------------------------------------------------

  charCount = fread(fid,1,'uint8');
  pascalString = fread(fid,[1 charCount],'int8=>char');
  if rem(charCount+1,2),
    fseek(fid,1,'cof');
  end

end

%--------------------------------------------------------------------------
function saxelStruct = read_saxel(fid)
%
%   Reads a structure of saxel data from a file.
%
%--------------------------------------------------------------------------

  saxelStruct = struct('id',fread(fid,1,'int16'),'size',[],'saxelData',[]);
  saxelBytes = fread(fid,1,'uint16');
  saxelStruct.size = saxelBytes;
  saxelStruct.saxelData = fread(fid,[saxelBytes 1],'*int8');
  if rem(saxelBytes,2),
    fseek(fid,1,'cof');
  end

end

%--------------------------------------------------------------------------
function textString = read_text(fid,charCount)
%
%   Reads ASCII text from a file, and afterwards shifts the file pointer
% ahead by one byte if necessary to make the total number of bytes read an
% even number.
%
%--------------------------------------------------------------------------

  textString = fread(fid,[1 charCount],'int8=>char');
  if rem(charCount,2),
    fseek(fid,1,'cof');
  end

end

%~~~End subfunctions~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~