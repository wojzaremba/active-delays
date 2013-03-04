function [ X, Y, A, W ] = getBackusDatasetProcessed()
    data_path = getenv('data_path');
    load([data_path, 'processed08'], 'icasig', 'Y', 'A', 'W');
    X = icasig;
    writeLog(0, 'Returning processed data\n');
end

