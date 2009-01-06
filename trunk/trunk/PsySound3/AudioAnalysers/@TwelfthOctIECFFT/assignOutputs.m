function obj = assignOutputs(obj, dataIn, dataBuf, s)
% ASSIGNOUTPUTS This method updates the output structure with each
%               new block of analysed data.  The output structures
%               (and any underlying data objects, eg. timeseries)
%               should already be allocated and all that should be
%               needed is assignment

% Convenience variables
% N   = get(obj, 'windowLength') - 1;
% N2  = N/2;
% fs  = get(obj, 'fs');

% Moment calculations
% if ~isempty(obj.cztF)
%   % We already have the frequency range
%   f1 = obj.cztF(1); f2 = obj.cztF(2);
%   fBin = (f2-f1)/N;
%   frequencies = (f1:fBin:f2);
%   DFT = dataIn / N;
% else
%   DFT = dataIn(1:end/2) / N;
%   frequencies = (fs/N) * (0:N2); % row vect
% end



N2           = (get(obj, 'windowLength')/65536)^2;
%frequencies = [20	21.1	22.4	23.7	25.1	26.6	28.2	29.9	31.6	33.5	35.5	37.6	39.8	42.2	44.7	47.3	50.1	53.1	56.2	59.6	63.1	66.8	70.8	75	79.4	84.1	89.1	94.4	100	106	112	119	126	133	141	150	158	168	178	188	200	211	224	237	251	266	282	299	316	335	355	376	398	422	447	473	501	531	562	596	631	668	708	750	794	841	891	944	1000	1059	1122	1189	1259	1334	1413	1496	1585	1679	1778	1884	1995	2113	2239	2371	2512	2661	2818	2985	3162	3350	3548	3758	3981	4217	4467	4732	5012	5309	5623	5957	6310	6683	7079	7499	7943	8414	8913	9441	10000	10593	11220	11885	12589	13335	14125	14962	15849	16788	17783	18836	19953];
PowSpec     = dataIn / N2;

chan = get(obj,'channels');

if chan == 1
% Assign the power spectrum
dataBuf.twelfthoctspec.assign(PowSpec);
end
if chan == 2
    dataBuf.twelfthoctspecL.assign(PowSpec(:,1)');
    dataBuf.twelfthoctspecR.assign(PowSpec(:,2)');
end
% Assign the level
%Power = sum(PowSpec);
%dataBuf.level.assign(Power);

% Normalize the PowSpectrum
%PowSpec = PowSpec/Power;

% Mean, which is also the 1st Moment
%meanPowSpec = frequencies * PowSpec';

% moments = meanPowSpec;
% % Calculate higher-order moments
% n = 4;  % Change to get higher ones
% for i=2:n
%   moments(1,i) = ((frequencies - meanPowSpec) .^ i) * PowSpec';
% end
% 
% % Assign moments
% dataBuf.moments.assign(moments);
% 
% % SD - this is the square root of the 2nd moment which is the
% %      variance
% SD = sqrt(moments(2));
% dataBuf.SD.assign(SD);
% 
% % Skewness and Kurtosis
% % This are the 3rd and 4th standardised moments, respectively
% dataBuf.skewness.assign(moments(3)/ (SD^3));
% dataBuf.kurtosis.assign(moments(4)/ (SD^4));

% end assignOutputs