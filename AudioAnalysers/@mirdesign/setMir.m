function a = set(a,varargin)
% SET Set properties for the MIRdesign object
% and return the updated object

propertyArgIn = varargin;
while length(propertyArgIn) >= 2,
   prop = propertyArgIn{1};
   val = propertyArgIn{2};
   propertyArgIn = propertyArgIn(3:end);
   switch prop
       case 'Eval'
           a.eval = val;
       case 'File'
           a.file = val;
       case 'Sampling'
           a.sampling = val;
       case 'Length'
           a.length = val;
       case 'Size'
           a.size = val;
       case 'Chunk'
           a.chunk = val;
       case 'SamplesIn'
           a.samplesin = val;
           a.samplesout = val;
       case 'SamplesOut'
           a.samplesout = val;
       case 'Frame'
           a.frame = val;
       case 'Segment'
           a.segment = val;
       case 'FrameDecomposition'
           a.frame.decomposition = val;
       case 'FrameLength'
           a.frame.length.val = val;
       case 'FrameHop'
           a.frame.hop.val = val;
       case 'FrameLengthUnit'
           a.frame.length.unit = val;
       case 'FrameHopUnit'
           a.frame.hop.unit = val;
       case 'FrameEval'
           a.frame.eval = val;
       case 'FrameDontChunk'
           a.frame.dontchunk = val;
       case 'Path'
           a.path = val;
       case 'Specif'
           a.specif = val;
       case 'InterChunk'
           a.interchunk = val;
       case 'AcrossChunks'
           a.acrosschunks = val;
       case 'NoChunk'
           a.nochunk = val;
       case 'Struct'
           a.struct = val;
       case 'Stored'
           a.stored = val;
       case 'Index'
           a.index = val;
       case 'TmpFile'
           a.tmpfile = val;
       case 'TmpOf'
           a.tmpof = val;
       case 'ChunkDecomposed'
           a.chunkdecomposed = val;
       case 'Argin'
           a.argin = val;
       case 'Option'
           a.option = val;
       case 'Overlap'
           a.overlap = val;
       case 'SeparateChannels'
           a.separate = val;
       case 'Channel'
           a.channel = val;
       case 'Scale'
           a.scale = val;
       otherwise
           error(['Unknown MIRdesign property: ' prop])
   end
end