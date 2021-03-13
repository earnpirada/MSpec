classdef MSProject < handle
    %MSPROJECT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        ProjectName
        CurrentData MSData
        CreatedDate
    end
    
    methods
        function obj = MSProject(importedData)
            % constructor
            % obj.ProjectName = projName;
            obj.CurrentData = importedData;
            %obj.CreatedDate = datetime('now','Format','d-MMM-y HH:mm:ss');
        end
        
        function setProjectInfo (obj, projName)
            obj.ProjectName = projName;
            obj.CreatedDate = datetime('now','Format','d-MMM-y HH:mm:ss');
        end
        
    end
end

