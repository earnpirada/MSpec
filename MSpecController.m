classdef MSpecController
    
    properties
    end
    
    methods (Static)
        function plotButtonPushedHandler(app)
            
            fig = uifigure;
            d = uiprogressdlg(fig,'Title','Processing your data','Message','Please wait . . .','Indeterminate','on');
            drawnow
    
            % Do the SVD computation
            
            windowSize = app.Preprocessing_WindowSizeEditField.Value;
            stepSize = app.Preprocessing_StepsizeEditField.Value;
            quantileValue = app.Preprocessing_QuantilevalueEditField.Value;

            referenceSpectrum = app.Preprocessing_ReferenceSpectrumEditField.Value;
            segmentSize = app.Preprocessing_MinimumsegementsizeallowedEditField.Value;
            shiftAllowance = app.Preprocessing_MaximumshiftallowedEditField.Value;
            
            app.CurrentProject.PreprocessedData.DisplayingSpectra = str2num(cell2mat(split(app.Preprocessing_SpectrumtodisplayEditField.Value,',')));
            app.CurrentProject.PreprocessedData.SectionStart = str2num(app.Preprocessing_StartingpointEditField.Value);
            app.CurrentProject.PreprocessedData.SectionEnd = str2num(app.Preprocessing_EndingpointEditField.Value);
            
            %Save User Inputs
            app.CurrentProject.PreprocessedData.setPreprocessInfo(windowSize,stepSize,quantileValue,referenceSpectrum,segmentSize,shiftAllowance);
            
            if isempty(app.Preprocessing_StartingpointEditField.Value)
                app.CurrentProject.PreprocessedData.SectionStart = app.CurrentProject.RawData.MinIntensity;
            end
            
            if isempty(app.Preprocessing_EndingpointEditField.Value)
                app.CurrentProject.PreprocessedData.SectionEnd = app.CurrentProject.RawData.MaxIntensity;
            end
            
            Preprocessing.alignment(app);
            Preprocessing.baselineCorrection(app);
            
            % close the dialog box
            close(d)
            close(fig)
            Visualization.plotPreprocessedMSData(app);
        end
    end
end

