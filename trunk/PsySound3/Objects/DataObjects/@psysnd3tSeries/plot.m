function varargout = plot(obj, varargin)
% PLOT  Plot function for psysnd3Timeseries

out    = [];
doPlot = true;

objName = get(obj, 'Name');

option = 'plot';
if ~isempty(varargin)
  option = varargin{1};
end

% Switch on option
switch(option)
  case 'GetList'
    out    = {'plot','histogram'};
    doPlot = false;

  case 'plot'
    % Treat ts data with events differently
    if isempty(obj.tsObj.Events)
      % Call plot on the underlying timeseries object
      plot(obj.tsObj);

      % Special handling for the Sound-level-meter
      if strncmp(objName, 'SPL', 3)
        minVal = obj.tsObj.min;
        maxVal = obj.tsObj.max;

        % Put up a +/-5dB margin at the top and bottom
        set(gca, 'YLim', [minVal-5 maxVal+5]);
      end

    else
      % Call plot on the underlying timeseries object
			try
      h = plot(obj.tsObj);
      % Annotate each event
      ev = obj.tsObj.Events;
      s    = get(h,'XData');
      minX = min(s{1}); 
      maxX = max(s{1});
      s    = get(h,'YData');
      minY = min(s{1});
      maxY = max(s{1});                 
      minX = minX - (maxX - minX)*0.02; 
      minY = minY - (maxY - minY)*0.02; 
      maxX = maxX + (maxX - minX)*0.02; 
      maxY = maxY + (maxY - minY)*0.2;  % Because the annotations are rotated to be vertically aligned
      axis([minX maxX minY maxY]);
      for i = 1:length(ev)
        tempTS = getsampleusingtime(obj.tsObj,ev(i).Time);
        datarange = max(obj.tsObj.data) - min(obj.tsObj.data);
        vertOS = 0.05 * datarange;
        text(ev(i).Time, tempTS.data + vertOS,ev(i).Name,'Rotation',90,'Interpreter','none');
      end
     	catch
			
			end
    end
	case 'histogram'
	    % Call plot on the underlying timeseries object
      hist(obj.tsObj.Data,25);

  otherwise
    error(['Unknown option : ', option, ' given']);
end

% Modify graph, if plotting
if doPlot
  title('');
end

% Assign output, if needed
if nargout
  varargout{1} = out;
end

% [EOF]
