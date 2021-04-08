classdef MSAnalysisProject < handle
    
    properties
        ProjectName
        CreatedDate
        Description
        ClassificationModel
        PreprocessParameters PreprocessingParameters
        RawData MSData
        PreprocessedData PreprocessedMSAData
        PredictionResult
    end
    
    methods
        function obj = MSAnalysisProject(importedData)
            % constructor
            % obj.ProjectName = projName;
            obj.RawData = importedData;
            %obj.CreatedDate = datetime('now','Format','d-MMM-y HH:mm:ss');
        end
        
        function setProjectInfo (obj, projName, description)
            obj.ProjectName = projName;
            obj.Description = description;
            obj.CreatedDate = datetime('now','Format','d-MMM-y HH:mm:ss');
            obj.PreprocessedData = PreprocessedMSAData();
        end
        
    end
end

