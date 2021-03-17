classdef Visualization
    
    properties
    end
    
    methods (Static)
        function plotRawMSData(app)
            %plot(app.Preprocessing_RawMSPlot,app.CurrentProject.RawData.RawMzValues, app.CurrentProject.RawData.RawSpectraIntensities(:, 3))
            %xlim(app.Preprocessing_RawMSPlot,[50000 60000])
            %hold(app.Preprocessing_RawMSPlot,"on");
            %for k = 1:app.CurrentProject.RawData.NumberOfSpectra
               %plot(app.Preprocessing_RawMSPlot,app.CurrentProject.RawData.RawMzValues, app.CurrentProject.RawData.RawSpectraIntensities(:, k))
            %end
            %hold(app.Preprocessing_RawMSPlot,"off");
            %fprintf('%d',app.CurrentProject.RawData.RawMzValues)
            app.Preprocessing_RawMSPlot.XLim = [app.CurrentProject.RawData.MinIntensity app.CurrentProject.RawData.MaxIntensity];
            plot(app.Preprocessing_RawMSPlot,app.CurrentProject.RawData.RawMzValues, app.CurrentProject.RawData.RawSpectraIntensities)
        end
        
        function plotPreprocessedMSData(app)
            app.Preprocessing_PreprocessedMSPlot.XLim = [app.CurrentProject.PreprocessedData.SectionStart app.CurrentProject.PreprocessedData.SectionEnd];
            app.Preprocessing_RawMSPlot.XLim = [app.CurrentProject.PreprocessedData.SectionStart app.CurrentProject.PreprocessedData.SectionEnd];
            if isempty(app.Preprocessing_SpectrumtodisplayEditField.Value)
                cla(app.Preprocessing_PreprocessedMSPlot)
                plot(app.Preprocessing_PreprocessedMSPlot,app.CurrentProject.RawData.RawMzValues,app.CurrentProject.PreprocessedData.BaselinedSpectra)
                    %plot(app.UIAxes,app.SectionOfInterest,app.AlignedSectionOfInterest)
            else
                cla(app.Preprocessing_PreprocessedMSPlot)
                plot(app.Preprocessing_PreprocessedMSPlot,app.CurrentProject.RawData.RawMzValues,app.CurrentProject.PreprocessedData.BaselinedSpectra(:,app.CurrentProject.PreprocessedData.DisplayingSpectra))                   
            end
        end
    end
end

