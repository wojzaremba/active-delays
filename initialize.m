function initialize()
    clc;
    clear;
    mainpath = [pwd, '/'];
    external_tools = [mainpath, 'external_tools/'];
    setenv('code_path', mainpath);
    setenv('output_images', [mainpath, '/output/images']);    
    setenv('cache_path', [mainpath, '/output/cache/']);
    setenv('data_path', [mainpath, '/data/']);
    setenv('log_level', '0');
    setenv('external_tools', external_tools);
    setenv('date_free', 'false');
    addpath(genpath(mainpath));
    rng('default');
    addpath([external_tools, 'mosek/6/toolbox/r2009b']);
    addpath(genpath([external_tools, 'eeglab11_0_4_3b']));
    addpath(genpath([external_tools, 'CPM_code_v1.0']));
    addpath(genpath([external_tools, 'shadedErrorBar']));
    setenv('MOSEKLM_LICENSE_FILE', [external_tools, 'mosek/6/licenses/mosek.lic']);
    setenv('LD_LIBRARY_PATH', [external_tools, 'mosek/6/tools/platform/linux64x86/bin']);        
    writeLog(0, 'Starting new execution\n');
end