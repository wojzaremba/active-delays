function status = checkfigs(h)

% built-in helper function, but I want to use it, so have
% copied it exactly.

status = 1;
for i=1:length(h)
    if ~ishandle(h(i)) | ~strcmp(get(h(i),'type'),'figure')
        status = 0;
        return
    end
end
