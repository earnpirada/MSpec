classdef PreprocessedMSData < handle
    properties
        %Parameters go here
        WindowSize %window size
        StepSize %step size
        QuantileValue %quantile value
        
        ReferenceSpectrum %alignment refernce spectrum
        SegmentSize %alignment segment size
        ShiftAllowance %alignment shift alowance

        %Processed Spectra
        BaselinedSpectra %baselined y
        DisplayingSpectra %spectra to display
        AlignedSpectra %aligned spectra
        
        % Plotting Parameters
        MinPosition %min pos to divide segment
        SegmentLag %segment lag
        ShiftedSegment %shifted segment
        SectionStart %starting point of section of interest
        SectionEnd %ending point of section of interest
        SectionOfInterest %section of interest
        AlignedSectionOfInterest %section of interest
        
        
        %Data Normalization Parameters
        
        NormalizeMethod = 'Sum'; % default normalize method
        NormalizeDisplay = 'All'; % default display option
        NormalizedSpectra % processed Data kept here
        %user input
        ReferencePeak =1;
        NormalizationNormValue = 1;
        
        
        % Peak Detection and Binning
        
        %Sabai part
        PreproceesedImportData %raw imported data
        PreproceesedMzValues %raw mz
        PreproceesedSpectraIntensities %raw y
        %Detect
        IsAutoDetected
        Base
        Multiplier
        HeightFilter
        DetectedPeak
        PeakThreshold = 0;
        CutThresholdPeak
        
        Cutoff
        Criterion
        CMZ
        PR
    end
    
    methods
        function obj = PreprocessedMSData()
            % constructor
        end
        function setPreprocessInfo (obj, windowSize,stepSize,quantileValue,referenceSpectrum,segmentSize,shiftAllowance)
            obj.WindowSize = windowSize;
            obj.StepSize = stepSize;
            obj.QuantileValue = quantileValue;
            obj.ReferenceSpectrum = referenceSpectrum;
            obj.SegmentSize = segmentSize;
            obj.ShiftAllowance = shiftAllowance;
        end
    end
end

