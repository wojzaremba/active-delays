initialize();
subjects = [8, 9];

for s = 1:length(subjects)
    writelnLog(0, ['Processing subject nr ', num2str(subjects(s))]);
    try
        [X, Y, channels] = getBackusDataset(subjects(s));
    catch
        writelnLog(0, ['Missing data file for subject nr ', num2str(subjects(s)]);
        continue;
    end
    [X, Y, channels] = removeBrokenData(X, Y, channels);
    npca = 60;
    [X, pca_reconstruct] = pcaWhite(X, npca);
    writelnLog(0, 'Saved pca proprocessed data to file');
    save([getenv('data_path'), 'processed0', num2str(subjects(s)), '_pca.mat'], 'X', 'Y', 'channels', 'pca_reconstruct');
    [X, icaweights, icasphere, icawinv] = ica(X);
    save([getenv('data_path'), 'processed0', num2str(subjects(s)), '_ica.mat'], 'X', 'Y', 'channels', 'icaweights', 'icasphere', 'icawinv', 'pca_reconstruct');
    writelnLog(0, 'Saved ica proprocessed data to file');
end