function str = getDataUnit(obj)
     % GETDATAUNIT Returns the data unit for the underlying timeseries object

str = obj.tsObj.DataInfo.units;
