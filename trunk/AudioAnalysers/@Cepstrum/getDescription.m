function str = getDescription(obj)
% GETDESCRIPTION Returns a text string of the description

str = {'Derives successive cepstra (real) of the input wave. ', ...
    ' ', ...
    'Outputs are:', ...
    '* Magnitude cepstrogram', ...
    '* Average power cepstrum', ...
    'Standardized and non-standardized power cepstral moments, such as', ...
    '* Centroid', ...
    '* Standard deviation', ...
    '* Skewness', ...
    '* Kurtosis'};
