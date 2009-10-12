function [data,dataObj,dataObjS] = getDataObjData(varargin)

p = getPsysound3Prefs;
load(fullfile(p.dataDir,varargin{:}));
dataObj = dataObjS.DataObj;
data = dataObjS.DataObj.Data;