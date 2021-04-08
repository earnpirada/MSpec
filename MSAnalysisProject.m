classdef MSAnalysisProject < handle
    
    properties
        ProjectName
        CreatedDate
        Description
        RawData MSData
        PreprocessedData PreprocessedMSData
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
            obj.PreprocessedData = PreprocessedMSData();
        end
        
    end
end

