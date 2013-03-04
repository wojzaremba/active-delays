function [ XRet, icaweights, icasphere, icawinv ] = ica( X )
    data = pop_importdata('data', permute(X, [2, 3, 1]), 'srate', 300);
    rng('default');
    results_eeglab = pop_runica(data, 'runica');
    comp_acts = results_eeglab.icaweights * results_eeglab.icasphere * results_eeglab.data(:, :);
    comp_acts = reshape(comp_acts, size(X, 2), size(X, 3), size(X, 1));
    XRet = permute(comp_acts, [3, 1, 2]);    
    icaweights = results_eeglab.icaweights;
    icasphere = results_eeglab.icasphere;
    icawinv = results_eeglab.icawinv;
	writeLog(0, 'ICA finished with %d components\n', size(XRet, 2));
end
