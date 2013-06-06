function writeLogDataFree(log_level_, data, varargin)   
    log_level = str2num(getenv('log_level'));
    if (log_level_ < 0)
        err = 'Some issue with lavel %d';
        fprintf(err, log_level_);
    end
    if (log_level >= log_level_)
      fprintf(data, varargin{:});
    end
    if (log_level_ < -1)        
        keyboard;
    end
end

