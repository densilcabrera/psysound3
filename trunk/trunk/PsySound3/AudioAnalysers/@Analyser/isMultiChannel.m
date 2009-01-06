function val = isMultiChannel(obj)
% ISMULTICHANNEL  Returns true if this Analyser support multilpe
%                 channels (eg. Stereo audio).  If true then, the
%                 processWindow method will recevie more than one
%                 column of data

val = obj.multiChannelSupport;

