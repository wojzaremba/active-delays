function writeLog(log_level_, data, varargin)
    date_free = getenv('date_free');
    if (~strcmp(date_free, 'true')) 
        date = datestr(now, 'yy.mm.dd HH:MM:SS');
        data = [date, ' ', data];
    end
    
    writeLogDataFree(log_level_, data, varargin{:});
end
