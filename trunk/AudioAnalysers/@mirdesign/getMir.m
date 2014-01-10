function varargout = getMir(a,varargin)
% GET Get properties from the MIRdesign object and return the value

if ischar(varargin{1})
    switch varargin{1}
        case 'Method'
            varargout = {a.method};
            return
        case 'File'
            varargout = {a.file};
            return
        case 'FrameLength'
            if isstruct(a.frame)
                varargout = {a.frame.length.val};
            else
                varargout = {[]};
            end
            return
        case 'FrameHop'
            if isstruct(a.frame)
                varargout = {a.frame.hop.val};
            else
                varargout = {[]};
            end
            return
        case 'FrameLengthUnit'
            if isstruct(a.frame)
                varargout = {a.frame.length.unit};
            else
                varargout = {[]};
            end
            return
        case 'FrameHopUnit'
            if isstruct(a.frame)
                varargout = {a.frame.hop.unit};
            else
                varargout = {[]};
            end
            return
        case 'FrameDontChunk'
            if isstruct(a.frame)
                varargout = {a.frame.dontchunk};
            else
                varargout = {[]};
            end
            return
        case 'Segment'
            varargout = {a.segment};
            return
        case 'ChunkDecomposed'
            varargout = {a.chunkdecomposed};
            return
        case 'Size'
            varargout = {a.size};
            return
        case 'Type'
            varargout = {a.type};
            return
        case 'Chunk'
            varargout = {a.chunk};
            return
        case 'Eval'
            varargout = {a.eval};
            return
        case 'Argin'
            varargout = {a.argin};
            return
        case 'VarArgin'
            varargout = {a.varargin};
            return
        case 'Specif'
            varargout = {a.specif};
            return
        case 'InterChunk'
            varargout = {a.interchunk};
            return
        case 'AcrossChunks'
            varargout = {a.acrosschunks};
            return
        case 'Option'
            varargout = {a.option};
            return
        case 'PostOption'
            varargout = {a.postoption};
            return
        case 'NoChunk'
            varargout = {a.nochunk};
            return
        case 'Ready'
            varargout = {a.ready};
            return
        case 'Struct'
            varargout = {a.struct};
            return
        case 'Stored'
            varargout = {a.stored};
            return
        case 'Index'
            varargout = {a.index};
            return            
        case 'TmpFile'
            varargout = {a.tmpfile};
            return     
        case 'TmpOf'
            varargout = {a.tmpof};
            return
        case 'Ascending'
            varargout = {a.ascending};
            return            
        case 'SeparateChannels'
            varargout = {a.separate};
            return            
        case 'Channel'
            varargout = {a.channel};
            return
        case 'Scale'
            varargout = {a.scale};
            return 
    end
end

        prop.type = 'String';
        prop.position = 2;
        prop.default = '';
    option.prop = prop;
specif.option = option;
varargout = mirfunction(@get,a,varargin,nargout,specif,@init,@main);

function [x type] = init(x,option)
type = '';

function val = main(a,option,postoption)
val = get(a,option.prop);