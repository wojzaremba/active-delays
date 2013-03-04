function writeLogDataFree(log_level_, data, varargin)
    log_level = str2num(getenv('log_level'));
    persistent FID   
    if (isempty(FID))
        log_path = getenv('log_path'); 
        host = getComputerName();
        FID = fopen(fullfile([log_path, 'LogFile', host , '.txt']), 'w');
        if FID < 0
            error('Cannot open file');
            return;
        end
    end
    if (log_level_ < 0)
        err = 'Some issue with lavel %d';
        fprintf(FID, err, log_level_);
        fprintf(err, log_level_);
    end
    if (log_level >= log_level_)
      fprintf(FID, data, varargin{:});        
      fprintf(data, varargin{:});
    end
    if (log_level_ < -1)        
        keyboard;
    end
end

