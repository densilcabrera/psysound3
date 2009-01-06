function dsArr = addNode(dsArr, dsObj)
% ADDNODE  Adds the given node to the array, if not already present

num = getNumChildren(dsArr);

if num
  % See if already present
  ind = findeq(dsArr, dsObj);

  if ind == 0
    % Append to the end
    dsArr.children(end+1) = dsObj;
  else
    % Just update the timestamp
    set(dsArr.children(ind), 'date', datestr(now));
  end
else
  dsArr.children = dsObj;
end

% EOF
