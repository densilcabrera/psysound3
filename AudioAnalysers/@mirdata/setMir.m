function a = setMir(a,varargin)

% SET Set properties for the MIRdata object
% and return the updated object
propertyArgIn = varargin;

while length(propertyArgIn) >= 2,
   prop = propertyArgIn{1};
   val = propertyArgIn{2};
   propertyArgIn = propertyArgIn(3:end);
   switch prop
       case 'Pos'
           a.pos = val;
       case {'Data','ChunkData'}
           if strcmp(prop,'ChunkData')
               val = {{val}};
           end
           a.data = val;
       case 'Unit'
           a.unit = val;
       case 'FramePos'
           a.framepos = val;
       case 'Sampling'
           a.sr = val;
       case 'Length'
           a.length = val;
       case 'NBits'
           a.nbits = val;
       case 'Name'
           a.name = val;
       case 'Name2'
           a.name2 = val;
       case 'Label'
           a.label = val;
       case 'Channels'
           a.channels = val;
       case 'Clusters'
           a.clusters = val;
       case 'MultiData'
           a.multidata = val;
       case 'Title'
           a.title = val;
       case 'Abs'
           a.abs = val;
       case 'Ord'
           a.ord = val;
       case 'PeakPos'
           a.peak.pos = val;
       case 'PeakVal'
           a.peak.val = val;
       case 'PeakPrecisePos'
           a.peak.precisepos = val;
       case 'PeakPreciseVal'
           a.peak.preciseval = val;
       case 'PeakMode'
           a.peak.mode = val;
       case 'AttackPos'
           a.attack.pos = val;
       case 'ReleasePos'
           a.release.pos = val;
       case 'TrackPos'
           a.track.pos = val;
       case 'TrackVal'
           a.track.val = val;
       case 'TrackPrecisePos'
           a.track.precisepos = val;
       case 'TrackPreciseVal'
           a.track.preciseval = val;
       case 'InterChunk'
           a.interchunk = val;
       case 'TmpIdx'
           a.tmpidx = val;
       case 'AcrossChunks'
           a.acrosschunks = val;
       case 'Interpolable'
           a.interpolable = val;
       case 'TmpFile'
           a.tmpfile = val;
       case 'Index'
           a.index = val;  
       case 'Extracted'
           a.extracted = val;
       
       otherwise
           error(['Unknown MIRdata property: ' prop])
   end
end
