function SaveSufix = CreateSaveSufix(opt, FWHM, NbLayers)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if numel(opt.svm.log2c)==1
    SaveSufix = ['_results_vol_C-' num2str(opt.svm.log2c)];
else
    SaveSufix = '_results_vol';
end

if opt.layersubsample.do
    SaveSufix = [SaveSufix '_subsamp-1'];
end

if opt.fs.do
    SaveSufix = [SaveSufix '_fs-1']; %#ok<*AGROW>
end

if opt.rfe.do
    SaveSufix = [SaveSufix '_rfe-1'];
end

if opt.permutation.test
    SaveSufix = [SaveSufix '_perm-1'];
end

if opt.session.curve
    SaveSufix = [SaveSufix '_lear-1'];
end

SaveSufix = [SaveSufix '_NORM'];
if opt.scaling.idpdt
    SaveSufix = [SaveSufix '-Idpdt'];
end

SaveSufix = [SaveSufix '_IMG'];
if opt.scaling.img.zscore
    SaveSufix = [SaveSufix '-ZScore'];
end
if opt.scaling.img.eucledian
    SaveSufix = [SaveSufix '-Eucl'];
end

SaveSufix = [SaveSufix '_FEAT'];
if opt.scaling.feat.mean
    SaveSufix = [SaveSufix '-MeanCent'];
end
if opt.scaling.feat.range
    SaveSufix = [SaveSufix '-Range'];
end
if opt.scaling.feat.sessmean
    SaveSufix = [SaveSufix '-SessMeanCent'];
end

if exist('NbLayers', 'var')
SaveSufix = [SaveSufix '_l-' num2str(NbLayers)];
end

if exist('FWHM', 'var')
SaveSufix = [SaveSufix '_s-' num2str(FWHM)  '.mat'];
else
    SaveSufix = [SaveSufix '.mat'];
end

end

