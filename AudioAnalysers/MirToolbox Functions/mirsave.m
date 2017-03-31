function mirsave(d,varargin)
%   mirsave(d) saves temporal data d in a file.
%       If d is a miraudio object, the waveform is directly saved.
%       mirenvelope data is sonified using modulated white noise.
%       mirpitch data is sonified using sinusoids.
%    (cf. User's Manual for more details).
%   The file(s) name is based on  the original file name(s), adding '.mir'
%       before the standard extension of the file.
%   mirsave(d,f) specifies the file names.
%       If d contains one single audio sequence, d is saved in a file
%               named f.
%       If d contains multiple audio sequences, each sequence is saved 
%               in a file whose name is the concatenation of the original
%               name and f.
%       If f ends with '.wav', the file is saved in WAV format (by
%               default).
%       If f ends with '.au', the file is saved in AU format.
%   mirsave(d,f,'SeparateChannels') save each separate channel in a 
%               different file.


mirsave(miraudio(d),varargin{:})