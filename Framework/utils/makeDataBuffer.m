function dataBuf = makeDataBuffer(nRows, nCols)
% MAKEDATABUFFER Creates an instance of a data buffer
%                nRows and nCols are the number of rows and columns
%                required, respectively
%
% Note: This should to be updated to handle nD arrays

  % nCols can be optional
  if nargin < 2
    nCols = 1;
  end
  
  % Initialise data - this is where the memory physically lives
  data = zeros(nRows, nCols);
  
  % Use assigndata to change values, getData to retrieve the actual data
  dataBuf.assign = @assignData;
  dataBuf.get    = @getData;
  dataBuf.size   = @getDataSize;
  dataBuf.sizeMB = @getDataSizeMB;
  dataBuf.show   = @showData;

  % Points to one after the existing data (one for each coloumn)
  currPtr(1:nCols) = 1;
  
  % ASSIGNDATA - Append to existing data
  %
  function assignData(newVals, col)

    % Optional argument for column
    rowVect = 0;  
    if nargin < 2
      col     = 1;
      rowVect = 1;
    end
    
    % Check column bounds
    if col > size(data, 2)
      error('assignData: expanding columns!');
    end
    
    % Data shouldn't be empty
    if ~isempty(data)
      if ~isempty(newVals)
        %transpose if necessary (only for vectors)
%         if size(newVals, 1) < size(newVals, 2) && min(size(newVals)) < 8
%         newVals = newVals';
%         end
        
        % Length down
        newValsLen = size(newVals, 1);
        
        % begin and end row pointers
        start  = currPtr(col);
        finish = start + newValsLen - 1;
        
        % Check row bounds
        if finish > size(data, 1) + 20
          error(['assignData: adding ' num2str(finish - size(data, 1)) ' extra row(s)!']);
        end
        
        % Do the assignment
        if rowVect
          % Copy entire column vector
          data(start:finish, :) = newVals;
        else
          % Copy column block
          data(start:finish, col) = newVals;
        end
        % Update pointer for next time
        currPtr(col) = currPtr(col) + newValsLen;
      else
        % Skip
      end
    else
      % getData has already been called, thus invalidating this
      % buffer
      error('assignData: DataBuffer is empty!');
    end
  end
  
  function out = getData
    if isempty(data)
      warning('getData: DataBuffer is empty!');
      out  = [];
    else
      % In case there is redundant data at the end
      out = data(1:currPtr-1, :);
      
      if any(data(currPtr:end, :))
        error('makeDataBuffer : missing data');
      end
      
      data = []; % Steal the pointer
    end
  end % getData
  
  % Returns the data size
  function sz = getDataSize
    sz = size(data);
  end % getDataSize
  
  % Returns the data size in MB
  function sz = getDataSizeMB
    w  = whos('data');
    sz = w.bytes/1024/1024;
  end % getDataSizeMB
  
  function showData
    data
  end % showData
end % makeDataBuffer

% EOF

