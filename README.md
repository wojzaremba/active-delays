ABOUT
=====

Code related with the paper "Learning from M/EEG data with variable brainactivation delays" that was published on Information Processing in Medical Imaging 2013.

Full paper : http://students.mimuw.edu.pl/~wz262981/docs/ipmi2013.pdf

Magneto- and electroencephalography (M/EEG) measure the electromagnetic signals produced by brain activity. In order to address the issue of limited signal-to-noise ratio (SNR) with raw data, acquisitions consist of multiple repetitions of the same experiment. An important challenge arising from such data is the variability of brain activations over the repetitions. It hinders statistical analysis such as prediction performance in a supervised learning setup. One such confounding variability is the time onset of the peak of the activation, which varies across repetitions. We propose to address this misalignment issue by explicitly modeling time shifts of different brain responses in a classification setup. To this end, we use the latent support vector machine (LSVM) formulation, where the latent shifts are imputed while learning the classifier parameters. The imputed shifts are further used to improve the SNR of the M/EEG data, and to infer the chronometry and the sequence of activations across the brain regions that are involved in the experimental task. Results are validated on a long term memory retrieval task, showing significant improvement using the proposed latent discriminative method.

HOW TO RUN
==========

Missing
