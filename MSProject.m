classdef MSProject < handle
    %MSPROJECT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        ProjectName
        CreatedDate
        RawData MSData
        PreprocessedData PreprocessedMSData
    end
    
    methods
        function obj = MSProject(importedData)
            % constructor
            % obj.ProjectName = projName;
            obj.RawData = importedData;
            %obj.CreatedDate = datetime('now','Format','d-MMM-y HH:mm:ss');
        end
        
        function setProjectInfo (obj, projName)
            obj.ProjectName = projName;
            obj.CreatedDate = datetime('now','Format','d-MMM-y HH:mm:ss');
            obj.PreprocessedData = PreprocessedMSData();
        end
        
    end
end

