classdef MSData
    %MSDATA Summary of this class goes here test
    %   Detailed explanation goes here
    
    properties
        FileName
        RawData
        RawMzValues
        RawSpectraIntensities
        MinIntensity
        MaxIntensity
        NumberOfSpectra
        RowNumber
        ColumnNumber
    end
    
    methods
        function obj = MSData(fileName,rawData,mzValues,intensityMatrix,numOfSpectra, rowNumber, colNumber)
            % constructor
            obj.FileName = fileName;
            obj.RawData = rawData;
            obj.RawMzValues = mzValues;
            obj.RawSpectraIntensities = intensityMatrix;
            obj.MinIntensity = min(mzValues);
            obj.MaxIntensity = max(mzValues);
            obj.NumberOfSpectra = numOfSpectra;
            obj.RowNumber = rowNumber;
            obj.ColumnNumber = colNumber;
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end

