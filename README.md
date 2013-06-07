ABOUT
=====

Code related with the paper "Learning from M/EEG data with variable brainactivation delays" that was published on Information Processing in Medical Imaging 2013.

Full paper : http://students.mimuw.edu.pl/~wz262981/docs/ipmi2013.pdf

ABSTRACT
========

Magneto- and electroencephalography (M/EEG) measure the electromagnetic signals produced by brain activity. In order to address the issue of limited signal-to-noise ratio (SNR) with raw data, acquisitions consist of multiple repetitions of the same experiment. An important challenge arising from such data is the variability of brain activations over the repetitions. It hinders statistical analysis such as prediction performance in a supervised learning setup. One such confounding variability is the time onset of the peak of the activation, which varies across repetitions. We propose to address this misalignment issue by explicitly modeling time shifts of different brain responses in a classification setup. To this end, we use the latent support vector machine (LSVM) formulation, where the latent shifts are imputed while learning the classifier parameters. The imputed shifts are further used to improve the SNR of the M/EEG data, and to infer the chronometry and the sequence of activations across the brain regions that are involved in the experimental task. Results are validated on a long term memory retrieval task, showing significant improvement using the proposed latent discriminative method.

DATA
====

Download exemplary data from 
- https://docs.google.com/file/d/0B3AOXcK7MRHlQnM1SEtEdGl0SVk/edit
- or from the original source : http://www.biomag2012.org/content/data-analysis-competition

Put ltmcla_S08.mat file that constains experimental data of subject nr 8 into directory active-delays/data/ of your project. You can download ltmcla_S09.mat as well.

Related papers are stored in the directory active-delays/data_description

HOW TO RUN
==========

Project is dependent on the mosek (http://mosek.com/). In order to make mosek work, please go to their webside and apply for licence for research purpose. Next please place it in a directory "active-delays/external_tools/mosek/6/licenses". All other external components should work without any additional external twicking. Don't forget about putting exemplary dataset (described in the section DATA) in active-delays/data directory.

Start with executing preprocess.m, which will generate all further neccessary processed files. It performs PCA, ICA and drops mallicious data.

Next you can verify that your environment works well by running tests from the file runTests.m.

Every experiment presented in the paper can be easily reporduced by executing files starting with the name expr : 
- expr1_allcomponents
- expr2_results_per_component
- expr3_1_vis
- expr3_componentvisualization
- expr4_results_per_component_single_fold
- expr5_meassure_for_components
- expr6_dependency
- expr7_permutation_test





