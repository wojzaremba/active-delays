function initialize()
    clc;
    clear;
    external_tools = '/home/wojto/bio/Dropbox/external/';
    setenv('code_path', '/home/wojto/bio/Dropbox/Wojciechs_shared/');
    setenv('output_images', '/home/wojto/bio/Dropbox/Wojciechs_shared/ipmi2013_writing/images_new');    
    setenv('cache_path', '/home/wojto/bio/Dropbox/Cache/');
    setenv('log_path', '/home/wojto/bio/Dropbox/Logs/');
    setenv('data_path', '/home/wojto/data/');
    setenv('log_level', '0');
    setenv('external_tools', external_tools);
    setenv('date_free', 'false');
    addpath(genpath('/home/wojto/bio/Dropbox/Wojciechs_shared'));
    rng('default');
    addpath([external_tools, 'mosek/6/toolbox/r2009b']);
    addpath(genpath([external_tools, 'eeglab11_0_4_3b']));
    addpath(genpath([external_tools, 'CPM_code_v1.0']));
    addpath(genpath([external_tools, 'shadedErrorBar']));
    setenv('MOSEKLM_LICENSE_FILE', [external_tools, 'mosek/6/licenses/mosek.lic']);
    setenv('LD_LIBRARY_PATH', [external_tools, 'mosek/6/tools/platform/linux64x86/bin']);        
    writeLog(0, 'Starting new execution\n');
end