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
        
        function initNormalization(app)
            Visualization.plotRawMSData_Normalization(app);
            app.TabGroup.SelectedTab = app.NormalizationTab;
            MSpecController.setDefaultReferencePeak(app);
            MSpecController.DisplaySamplePointOption(app);
        end
        
        function updateNormalizedSpectra(app)
            Preprocessing.updateNormalizedSpectra(app);
            Visualization.plotNormalizedSpectra(app);
            Visualization.displayNormalizedDataTable(app);
        end
        
        function setDefaultReferencePeak(app)
            SD = std(app.CurrentProject.PreprocessedData.AlignedSpectra,0,2); % dim = 2 means for each row
            [Max,IndexMax] = max(SD);
            app.CurrentProject.PreprocessedData.ReferencePeak = IndexMax;
            app.Normalization_PeakSpinner.Value = double(IndexMax);
        end
        
        function DisplaySamplePointOption(app)
            SampleIndex = transpose(1:app.CurrentProject.RawData.NumberOfSpectra);
            F = false(app.CurrentProject.RawData.NumberOfSpectra,1);
            F = [SampleIndex F];
            app.Normalization_SelectDataTable.Data = F;
            app.Normalization_SelectDataTable.ColumnFormat = {'char', 'logical'};
            s = uistyle('HorizontalAlignment','center');
            addStyle(app.Normalization_SelectDataTable,s);
        end
        
        function startPeakDetection(app)
            CurrentPreprocessedData = app.CurrentProject.PreprocessedData;
            value = app.Detection_MethodDropDown.Value;
            switch value % Get Tag of selected object.
                case 'Auto'
                    CurrentPreprocessedData.IsAutoDetected = true;
                otherwise
                    CurrentPreprocessedData.IsAutoDetected = false;
                    CurrentPreprocessedData.Base = app.Detection_BASEEditField.Value;
                    CurrentPreprocessedData.Multiplier = app.Detection_MULTIPLIEREditField.Value;
                    CurrentPreprocessedData.HeightFilter = app.Detection_HEIGHTFILTEREditField.Value;
                    CurrentPreprocessedData.PeakThreshold = app.Detection_PeakThresholdEditField.Value;
            end
            

            Preprocessing.peakDetection(app);
            Visualization.plotPeakDetection(app);
            %Preprocessing.peakBinning_Hierachical(app);
        end
        
        function startPeakBinning(app)
            app.CurrentProject.PreprocessedData.Cutoff = app.CUTOFFSpinner.Value;
            Preprocessing.peakBinning_Hierachical(app);
        end
        
        function startAlignPeakBinning(app)
           Preprocessing.peakBinning_Dynamic(app); 
        end
        
        function startRealPeakBinning(app)
            Preprocessing.startPeakBinning(app);
        end
    end
end

