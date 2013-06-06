% eeg_helpsigproc() - Help file for EEGLAB

function noname();

command = { ...
'pophelp(''acsobiro.m'');' ...
'pophelp(''adjustlocs.m'');' ...
'pophelp(''angtimewarp.m'');' ...
'pophelp(''axcopy.m'');' ...
'pophelp(''binica.m'');' ...
'pophelp(''biosig2eeglabevent.m'');' ...
'pophelp(''blockave.m'');' ...
'pophelp(''cart2topo.m'');' ...
'pophelp(''cbar.m'');' ...
'pophelp(''celltomat.m'');' ...
'pophelp(''chancenter.m'');' ...
'pophelp(''changeunits.m'');' ...
'pophelp(''compvar.m'');' ...
'pophelp(''condstat.m'');' ...
'pophelp(''convertlocs.m'');' ...
'pophelp(''copyaxis.m'');' ...
'pophelp(''coregister.m'');' ...
'pophelp(''crossf.m'');' ...
'pophelp(''dftfilt.m'');' ...
'pophelp(''eegfilt.m'');' ...
'pophelp(''eegfiltfft.m'');' ...
'pophelp(''eegplot.m'');' ...
'pophelp(''eegplot2event.m'');' ...
'pophelp(''eegplot2trial.m'');' ...
'pophelp(''eegrej.m'');' ...
'pophelp(''eegthresh.m'');' ...
'pophelp(''entropy_rej.m'');' ...
'pophelp(''env.m'');' ...
'pophelp(''envtopo.m'');' ...
'pophelp(''epoch.m'');' ...
'pophelp(''erpimage.m'');' ...
'pophelp(''eventalign.m'');' ...
'pophelp(''eventlock.m'');' ...
'pophelp(''eyelike.m'');' ...
'pophelp(''fastif.m'');' ...
'pophelp(''floatread.m'');' ...
'pophelp(''floatwrite.m'');' ...
'pophelp(''forcelocs.m'');' ...
'pophelp(''headplot.m'');' ...
'pophelp(''icaact.m'');' ...
'pophelp(''icadefs.m'');' ...
'pophelp(''icaproj.m'');' ...
'pophelp(''icavar.m'');' ...
'pophelp(''imagesctc.m'');' ...
'pophelp(''jader.m'');' ...
'pophelp(''jointprob.m'');' ...
'pophelp(''kurt.m'');' ...
'pophelp(''loadavg.m'');' ...
'pophelp(''loadcnt.m'');' ...
'pophelp(''loaddat.m'');' ...
'pophelp(''loadeeg.m'');' ...
'pophelp(''loadtxt.m'');' ...
'pophelp(''matsel.m'');' ...
'pophelp(''mattocell.m'');' ...
'pophelp(''movav.m'');' ...
'pophelp(''moveaxes.m'');' ...
'pophelp(''nan_mean.m'');' ...
'pophelp(''openbdf.m'');' ...
'pophelp(''parsetxt.m'');' ...
'pophelp(''phasecoher.m'');' ...
'pophelp(''plotchans3d.m'');' ...
'pophelp(''plotdata.m'');' ...
'pophelp(''ploterp.m'');' ...
'pophelp(''plotmesh.m'');' ...
'pophelp(''plotsphere.m'');' ...
'pophelp(''plottopo.m'');' ...
'pophelp(''posact.m'');' ...
'pophelp(''projtopo.m'');' ...
'pophelp(''qqdiagram.m'');' ...
'pophelp(''quantile.m'');' ...
'pophelp(''read_erpss.m'');' ...
'pophelp(''readbdf.m'');' ...
'pophelp(''readedf.m'');' ...
'pophelp(''readeetraklocs.m'');' ...
'pophelp(''readegi.m'');' ...
'pophelp(''readegihdr.m'');' ...
'pophelp(''readelp.m'');' ...
'pophelp(''readlocs.m'');' ...
'pophelp(''readneurodat.m'');' ...
'pophelp(''readneurolocs.m'');' ...
'pophelp(''realproba.m'');' ...
'pophelp(''rejkurt.m'');' ...
'pophelp(''rejstatepoch.m'');' ...
'pophelp(''rejtrend.m'');' ...
'pophelp(''reref.m'');' ...
'pophelp(''rmbase.m'');' ...
'pophelp(''runica.m'');' ...
'pophelp(''runica_ml.m'');' ...
'pophelp(''runica_ml2.m'');' ...
'pophelp(''runica_mlb.m'');' ...
'pophelp(''sbplot.m'');' ...
'pophelp(''sdfopen.m'');' ...
'pophelp(''sdfread.m'');' ...
'pophelp(''shuffle.m'');' ...
'pophelp(''signalstat.m'');' ...
'pophelp(''slider.m'');' ...
'pophelp(''snapread.m'');' ...
'pophelp(''sobi.m'');' ...
'pophelp(''spec.m'');' ...
'pophelp(''spectopo.m'');' ...
'pophelp(''sph2topo.m'');' ...
'pophelp(''spher.m'');' ...
'pophelp(''spherror.m'');' ...
'pophelp(''strmultiline.m'');' ...
'pophelp(''textsc.m'');' ...
'pophelp(''timef.m'');' ...
'pophelp(''timefdetails.m'');' ...
'pophelp(''timewarp.m'');' ...
'pophelp(''timtopo.m'');' ...
'pophelp(''topo2sph.m'');' ...
'pophelp(''topoplot.m'');' ...
'pophelp(''transformcoords.m'');' ...
'pophelp(''trial2eegplot.m'');' ...
'pophelp(''uigetfile2.m'');' ...
'pophelp(''uiputfile2.m'');' ...
'pophelp(''writecnt.m'');' ...
'pophelp(''writelocs.m'');' ...
};
vartext = { ...
'acsobiro.m' ...
'adjustlocs.m' ...
'angtimewarp.m' ...
'axcopy.m' ...
'binica.m' ...
'biosig2eeglabevent.m' ...
'blockave.m' ...
'cart2topo.m' ...
'cbar.m' ...
'celltomat.m' ...
'chancenter.m' ...
'changeunits.m' ...
'compvar.m' ...
'condstat.m' ...
'convertlocs.m' ...
'copyaxis.m' ...
'coregister.m' ...
'crossf.m' ...
'dftfilt.m' ...
'eegfilt.m' ...
'eegfiltfft.m' ...
'eegplot.m' ...
'eegplot2event.m' ...
'eegplot2trial.m' ...
'eegrej.m' ...
'eegthresh.m' ...
'entropy_rej.m' ...
'env.m' ...
'envtopo.m' ...
'epoch.m' ...
'erpimage.m' ...
'eventalign.m' ...
'eventlock.m' ...
'eyelike.m' ...
'fastif.m' ...
'floatread.m' ...
'floatwrite.m' ...
'forcelocs.m' ...
'headplot.m' ...
'icaact.m' ...
'icadefs.m' ...
'icaproj.m' ...
'icavar.m' ...
'imagesctc.m' ...
'jader.m' ...
'jointprob.m' ...
'kurt.m' ...
'loadavg.m' ...
'loadcnt.m' ...
'loaddat.m' ...
'loadeeg.m' ...
'loadtxt.m' ...
'matsel.m' ...
'mattocell.m' ...
'movav.m' ...
'moveaxes.m' ...
'nan_mean.m' ...
'openbdf.m' ...
'parsetxt.m' ...
'phasecoher.m' ...
'plotchans3d.m' ...
'plotdata.m' ...
'ploterp.m' ...
'plotmesh.m' ...
'plotsphere.m' ...
'plottopo.m' ...
'posact.m' ...
'projtopo.m' ...
'qqdiagram.m' ...
'quantile.m' ...
'read_erpss.m' ...
'readbdf.m' ...
'readedf.m' ...
'readeetraklocs.m' ...
'readegi.m' ...
'readegihdr.m' ...
'readelp.m' ...
'readlocs.m' ...
'readneurodat.m' ...
'readneurolocs.m' ...
'realproba.m' ...
'rejkurt.m' ...
'rejstatepoch.m' ...
'rejtrend.m' ...
'reref.m' ...
'rmbase.m' ...
'runica.m' ...
'runica_ml.m' ...
'runica_ml2.m' ...
'runica_mlb.m' ...
'sbplot.m' ...
'sdfopen.m' ...
'sdfread.m' ...
'shuffle.m' ...
'signalstat.m' ...
'slider.m' ...
'snapread.m' ...
'sobi.m' ...
'spec.m' ...
'spectopo.m' ...
'sph2topo.m' ...
'spher.m' ...
'spherror.m' ...
'strmultiline.m' ...
'textsc.m' ...
'timef.m' ...
'timefdetails.m' ...
'timewarp.m' ...
'timtopo.m' ...
'topo2sph.m' ...
'topoplot.m' ...
'transformcoords.m' ...
'trial2eegplot.m' ...
'uigetfile2.m' ...
'uiputfile2.m' ...
'writecnt.m' ...
'writelocs.m' ...
};
textgui( vartext, command,'fontsize', 15, 'fontname', 'times', 'linesperpage', 18, 'title',strvcat( 'Signal processing functions', '(Click on blue text for help)'));
icadefs; set(gcf, 'COLOR', BACKCOLOR);h = findobj('parent', gcf, 'style', 'slider');set(h, 'backgroundcolor', GUIBACKCOLOR);return;
