function JOBLIST = spcJobList_mc()

DefaultJob.JobOptions.NumberOfProcessors = 1;
DefaultJob.JobOptions.NumberOfDigits = 6;
DefaultJob.JobOptions.BooleanGenerateParticleImages = false;
DefaultJob.JobOptions.BooleanRunAnalysis = true;
DefaultJob.JobOptions.FlipYTranslation = false;
DefaultJob.JobOptions.SkipExistingSets = false;
DefaultJob.JobOptions.RepositoryPathIsAbsolute = 0;
DefaultJob.JobOptions.DoAffineTransform = 0;

DefaultJob.ImageType = 'synthetic';
DefaultJob.SetType = 'mc';
DefaultJob.CaseName = 'SPCtest_2014-11-04_translation_x_only';
DefaultJob.CorrelationType = 'spc';
DefaultJob.Parameters.RegionHeight = 64;
DefaultJob.Parameters.RegionWidth = 64;
DefaultJob.Parameters.Sets.Start = 1;
DefaultJob.Parameters.Sets.End = 1;
DefaultJob.Parameters.Sets.ImagesPerSet = 10000;
DefaultJob.Parameters.RepositoryPath =  '/Users/matthewgiarra/Dropbox/School/VT/Research/SPC/analysis/data';

DefaultJob.Parameters.Processing.SpatialWindowFraction = [0.5 0.5];
DefaultJob.Parameters.Processing.SpatialWindowType = 'fraction';
DefaultJob.Parameters.Processing.SpatialRPCDiameter = 2.8;

% This is the mean of the additive gaussian white noise
% as a fraction of the maximum image intensity
DefaultJob.Parameters.Processing.Noise.Mean = 0.00;

% This is the 99.5% confidence interval of the noise
% as a fraction of the maximum image intensity.
DefaultJob.Parameters.Processing.Noise.Std = 0.00;

% JOB 1
SegmentItem = DefaultJob;
SegmentItem.CaseName = 'SPCtest_2014-11-04_translation_x_with_noise';
SegmentItem.CorrelationType = 'spc';
SegmentItem.Parameters.RegionHeight = 64;
SegmentItem.Parameters.RegionWidth = 64;
SegmentItem.Parameters.Processing.SpatialWindowFraction = 0.50 * [1 1];
JOBLIST(1) = SegmentItem;

% JOB 2
SegmentItem = DefaultJob;
SegmentItem.CaseName = 'SPCtest_2014-11-04_translation_x_with_noise_shear_01';
SegmentItem.CorrelationType = 'spc';
SegmentItem.Parameters.RegionHeight = 64;
SegmentItem.Parameters.RegionWidth = 64;
SegmentItem.Parameters.Processing.SpatialWindowFraction = 0.50 * [1 1];
JOBLIST(end + 1) = SegmentItem;

% JOB 2
SegmentItem = DefaultJob;
SegmentItem.CaseName = 'SPCtest_2014-11-04_translation_x_with_noise_shear_02';
SegmentItem.CorrelationType = 'spc';
SegmentItem.Parameters.RegionHeight = 64;
SegmentItem.Parameters.RegionWidth = 64;
SegmentItem.Parameters.Processing.SpatialWindowFraction = 0.50 * [1 1];
JOBLIST(end + 1) = SegmentItem;



end







