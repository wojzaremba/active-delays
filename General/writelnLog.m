function writelnLog(log_level_, data, varargin)    
    writeLog(log_level_, [data, '\n'], varargin{:});
end
