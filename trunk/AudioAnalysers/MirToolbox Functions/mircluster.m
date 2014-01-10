function [a d] = mircluster(a,varargin)
%   c = mircluster(a,f) clusters the segments in the audio sequence(s) 
%       contained in the audio object a, along the analytic feature(s) 
%       f, using the k-means strategy. Multiple analytic features have to
%       be grouped into one array of cells.
%       Example:
%           sg = mirsegment(a);
%           mircluster(sg, mirmfcc(sg))
%           mircluster(sg, {mirmfcc(sg), mircentroid(sg)})
%   c = mircluster(d) clusters the frame-decomposed data d into groups
%       using K-means clustering.
%       Example:
%           cc = mirmfcc(a,'Frame');
%           mircluster(cc)
%   Optional argument:
%       mircluster(...,n) indicates the maximal number of clusters.
%           Default value: n = 2.
%       mircluster(...,'Runs',r) indicates the maximal number of runs.
%           Default value: r = 5.
%
%   Requires SOM Toolbox (included in the MIRtoolbox distribution).

% web('http://www.jyu.fi/hum/laitokset/musiikki/en/research/coe/materials/mirtoolbox')
error('SORRY! For legal reasons, mircluster is not included in MIRtoolbox Matlab Central Version. MIRtoolbox Complete version is freely available from the official MIRtoolbox website.')