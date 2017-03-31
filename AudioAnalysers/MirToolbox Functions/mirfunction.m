function o = mirfunction(method,x,varg,nout,specif,init,main)
% Meta function called by all MIRtoolbox functions.
% Integrates the function into the general flowchart
%   and eventually launches the "mireval" evaluation process.
% Here are the successive steps in the following code:
%   - If the input is an audio filename, instantiates a new design flowchart.
%   - Reads all the options specified by the user.
%   - Performs the 'init' part of the MIRtoolbox function:
%       - If the input is a design flowchart,
%           add the 'init' part in the flowchart.
%       - If the input is some MIRtoolbox data,
%           execute the 'init' part on that data.
%   - Performs the 'main' part of the MIRtoolbox function.

if isempty(x)
    o = {{},{},{}};
    return
end

if ischar(x) % The input is a file name.
    % Starting point of the design process
    design_init = 1;
    filename = x;
    if strcmpi(func2str(method),'miraudio')
        postoption = {};
    else
        postoption.mono = 1;
    end
    orig = mirdesign(@miraudio,'Design',{varg},postoption,struct,'miraudio'); 
    % Implicitly, the audio file needs to be loaded first.
elseif isnumeric(x)
    mirerror(func2str(method),'The input should be a file name or a MIRtoolbox object.');
else
    design_init = 0;
    orig = x;
end

% Reads all the options specified by the user.
[orig during after] = miroptions(method,orig,specif,varg);

% Performs the 'init' part of the MIRtoolbox function.
if isa(orig,'mirdesign')
    if not(get(orig,'Eval'))
        % Top-down construction of the general design flowchart
        
        if isstruct(during) && isfield(during,'frame') && ...
                isstruct(during.frame) && during.frame.auto
            % 'Frame' option: 
            % Automatic insertion of the mirframe step in the design
            orig = mirframe(orig,during.frame.length.val,...
                                 during.frame.length.unit,...
                                 during.frame.hop.val,...
                                 during.frame.hop.unit);   
        end
        
        % The 'init' part of the function can be integrated into the design
        % flowchart. This leads to a top-down construction of the
        % flowchart.
        % Automatic development of the implicit prerequisites,
        % with management of the data types throughout the design process.
        [orig type] = init(orig,during);
                
        o = mirdesign(method,orig,during,after,specif,type);
                    
        if design_init && not(strcmpi(filename,'Design'))
            % Now the design flowchart has been completed created.
            % If the 'Design' keyword not used,
            % the function is immediately evaluated
            o = mireval(o,filename,nout);
        else
            o = returndesign(o,nout);
        end
        if not(iscell(o))
            o = {o};
        end
        return
    else
        % During the top-down traversal of the flowchart (evaleach), at the
        % beginning of the evaluation process.
        
        if not(isempty(get(orig,'TmpFile'))) && get(orig,'ChunkDecomposed')
            orig = evaleach(orig);
            if iscell(orig)
                orig = orig{1};
            end
            x = orig;
        else
            [orig x] = evaleach(orig);
        end
        
        if not(isequal(method,@nthoutput))
            if iscell(orig)
                orig = orig{1};
            end
            if isempty(get(orig,'InterChunk'))
                orig = set(orig,'InterChunk',get(x,'InterChunk'));
            end
        end
    end
else
    design = 0;
    if iscell(orig)
        i = 0;
        while i<length(orig) && not(design)
            i = i+1;
            if isa(orig{i},'mirdesign')
                design = i;
            end
        end
    end
    if design
        % For function with multiple inputs
        if design == 1 && not(get(orig{1},'Eval'))
            % Progressive construction of the general design
            [orig type] = init(orig,during);
            o = mirdesign(method,orig,during,after,specif,type);
            o = set(o,'Size',get(orig{1},'Size'));
            o = returndesign(o,nout);
            return
        else
            % Evaluation of the design.
            % First top-down initiation (evaleach), then bottom-up process.
            for io = 1:length(orig)
                if isa(orig{io},'mirdesign')
                    o = evaleach(orig{io});
                    if iscell(o)
                        o = o{:};
                    end
                    orig{io} = o;
                end
            end
        end
    elseif not(isempty(init)) && not(isempty(during))
        if isstruct(during) && isfield(during,'frame') && ...
                isstruct(during.frame) && during.frame.auto
            orig = mirframe(orig,during.frame.length,during.frame.hop);        
        end
        % The input of the function is not a design flowchart, which
        % the 'init' part of the function could be integrated into.
            % (cf. previous call of 'init' in this script). 
        % For that reason, the 'init' part of the function needs to be
        % evaluated now.
        orig = init(orig,during);
    end
end

% Performs the 'main' part of the MIRtoolbox function.
if not(iscell(orig) && not(ischar(orig{1}))) && ...
        not(isa(orig,'mirdesign') || isa(orig,'mirdata'))
    o = {orig};
    return
end
filenamearg = orig;
if iscell(filenamearg) && not(ischar(filenamearg{1}))
    filenamearg = filenamearg{1};
end
if iscell(filenamearg) && not(ischar(filenamearg{1}))
    filenamearg = filenamearg{1};
end
filename = get(filenamearg,'Name');
if not(isempty(during)) && mirverbose
    if length(filename) == 1
%         disp(['Computing ',func2str(method),' related to ',filename{1},'...'])
    else
%         disp(['Computing ',func2str(method),' for all audio files ...'])
    end
end
if iscell(x)
    x1 = x{1};
else
    x1 = x;
end
if not(iscell(orig) || isnumeric(x))
    orig = set(orig,'Index',get(x1,'Index'));
end
if iscell(orig)
    o = main(orig,during,after);
else
    d = get(orig,'Data');
    if isamir(orig,'miraudio') && ...
        length(d) == 1 && length(d{1}) == 1 && isempty(d{1}{1})
        % To solve a problem when MP3read returns empty chunk.
        % Warning: it should not be a cell, because for instance nthoutput can have first input empty... 
        o = orig;
    else
        o = main(orig,during,after);
    end
end
if not(iscell(o) && length(o)>1) || (isa(x,'mirdesign') && get(x,'Eval'))
    o = {o x};
elseif iscell(x) && isa(x{1},'mirdesign') && get(x{1},'Eval')
    o = {o x{1}};
elseif not(isempty(varg)) && isstruct(varg{1}) ...
            && not(iscell(o) && iscell(o{1}))
    % When the function was called by mireval, the output should be packed
    % into one single cell array (in order to be send back to calling
    % routines).
    o = {o};
end


function o = returndesign(i,nout)
o = cell(1,nout);
o{1} = i;
for k = 2:nout
    o{k} = nthoutput(i,k);
end