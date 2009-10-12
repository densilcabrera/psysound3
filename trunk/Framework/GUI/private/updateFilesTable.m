function handles = updateFilesTable(handles)
% UPDATEFILESTABLE 
%

% find the Table Model
try 
    ht = getTableModel(handles.Table);
catch
    ht = getTableModel(handles.mtable);
end
% find the size of the data
[rows,columns]= size(handles.Data);

% set the number of columns
% setColumnCount(ht,columns);

% set the number of Rows
setRowCount(ht, rows);

try
    colWidth = getColumnWidth(handles.Table);
    % set Column Width
    if colWidth>151 || colWidth<149
        setColumnWidth(handles.Table, 150);
    else
        setColumnWidth(handles.Table, colWidth);
    end
catch
    colWidth = handles.mtable.getColumnWidth();
    if colWidth>151 || colWidth<149
        handles.mtable.setColumnWidth(150);
    else
        handles.mtable.setColumnWidth(ColWidth);
    end
end
   
    
% replace the Headers with current handles.TableHeaders
try
    if length(handles.DataHeaders) > 1
        setColumnNames(handles.Table, handles.DataHeaders);
    end
catch
    if length(handles.DataHeaders) > 1
        handles.mtable.setColumnNames(handles.DataHeaders);
    end
end


% replace the Data Model
for i = 1:rows
  for j=1:columns
    try
      try
        ht.setValueAt(char(handles.Data(i,j)),i-1,j-1);
      catch
        ht.setValueAt(cell2mat(handles.Data(i,j)),i-1,j-1);
      end
    catch
      ht.setValueAt(char(' '),i-1,j-1);
    end
  end
end

% end updateFilesTable

