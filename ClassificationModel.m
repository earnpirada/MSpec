classdef ClassificationModel
    
    properties
        Model
        Preprocessing PreprocessingParameters
    end
    
    methods
        function obj = ClassificationModel(model,preproc)
            obj.Model = model;
            obj.Preprocessing = preproc;
        end
    end
end

