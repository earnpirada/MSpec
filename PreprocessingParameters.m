classdef PreprocessingParameters
    
    properties
        %Parameters go here
        WindowSize %window size
        StepSize %step size
        QuantileValue %quantile value
        
        ReferenceSpectrum %alignment refernce spectrum
        SegmentSize %alignment segment size
        ShiftAllowance %alignment shift alowance
        
        % Plotting Parameters
        SectionStart %starting point of section of interest
        SectionEnd %ending point of section of interest
        
        %Data Normalization Parameters
        
        NormalizeMethod = 'Sum'; % default normalize method
        ReferencePeak =1;
        ReferencePeakIndex
        NormalizationNormValue = 1;
        
        
        % Peak Detection and Binning
        ImportedEdgeListFileName
        ImportedEdgeList
    end
    
    methods
        function obj = PreprocessingParameters(secstart,secend,winsize,stepsize,quantilevalue,refspec,minseg,maxshift,normmethod,refpeak,normvalue,edgeList,edgeFile)
            
            obj.SectionStart = secstart;
            obj.SectionEnd = secend;
        
            obj.WindowSize = winsize;
            obj.StepSize = stepsize;
            obj.QuantileValue = quantilevalue;
        
            obj.ReferenceSpectrum = refspec;
            obj.SegmentSize = minseg;
            obj.ShiftAllowance = maxshift;
            
            obj.NormalizeMethod = normmethod;
            obj.ReferencePeak = refpeak;
            obj.NormalizationNormValue = normvalue;
            
            obj.ImportedEdgeList = edgeList;
            obj.ImportedEdgeListFileName = edgeFile;
        end
        
    end
end

