classdef MSData
    %MSDATA Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        RawData
        RawMzValues
        RawSpectraIntensities
        MinIntensity
        MaxIntensity
        NumberOfSpectra
    end
    
    methods
        function obj = MSData(rawData,mzValues,intensityMatrix,numOfSpectra)
            % constructor
            obj.RawData = rawData;
            obj.RawMzValues = mzValues;
            obj.RawSpectraIntensities = intensityMatrix;
            obj.MinIntensity = min(mzValues);
            obj.MaxIntensity = max(mzValues);
            obj.NumberOfSpectra = numOfSpectra;
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end

