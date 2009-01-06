function obj = CDF(obj,varargin)
% Calculate CDF of DAAF Object 
%
% Sort Data and then sort Frames in the same way

[sortedData,orders] = sort(obj.DataPoints);       % Indexes in order

% Dump NaNs 
notNaNs = find(~isnan(sortedData));
sortedData = sortedData(notNaNs);
orders = orders(notNaNs);


obj.OutputFrames = obj.Frames(orders);                % Re-order


if nargin == 3
	ax = varargin{2};
	switch varargin{1}
		case 'Graph'
			axes(ax{1});
      tag = get(ax{1},'Tag');
			h = plot(obj.TimePoints,obj.DataPoints);
      title('Original Descriptor Data');
      xlabel('Time (s)');
      ylabel([obj.Name ' (' obj.Units.Unit ')']);
      axis([0 max(obj.TimePoints) min(obj.DataPoints) max(obj.DataPoints)]);
			set(get(h,'Parent'),'Tag',tag);
      
      axes(ax{2});
			tag = get(ax{2},'Tag');
			h = plot(obj.TimePoints(1:length(sortedData)),sortedData);
      title('Cumulative Distribution Function');
      xlabel('Time (s)');
      ylabel([obj.Name ' (' obj.Units.Unit ')']);
      axis([0 max(obj.TimePoints(1:length(sortedData))) min(obj.DataPoints) max(obj.DataPoints)]);
      set(get(h,'Parent'),'Tag',tag);
		end
	end
end	
			
