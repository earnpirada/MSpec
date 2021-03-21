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
        
        function plotRawMSData_Normalization(app)
            app.Normalization_ProcessedMSPlot.XLim = [app.CurrentProject.RawData.MinIntensity app.CurrentProject.RawData.MaxIntensity];
            plot(app.Normalization_ProcessedMSPlot,app.CurrentProject.RawData.RawMzValues, app.CurrentProject.PreprocessedData.BaselinedSpectra)
        end
        
        function plotNormalizedSpectra(app)
            app.Normalization_NormalizedMSPlot.XLim = [app.CurrentProject.RawData.MinIntensity app.CurrentProject.RawData.MaxIntensity];
            cla(app.Normalization_NormalizedMSPlot)
            % Plotting Normalized Data
            
            switch app.CurrentProject.PreprocessedData.NormalizeDisplay
                case 'All'
                    plot(app.Normalization_NormalizedMSPlot, app.CurrentProject.RawData.RawMzValues, app.CurrentProject.PreprocessedData.NormalizedSpectra)
                    %hold(app.Normalization_NormalizedMSPlot,"on");
                    %for k = 1:app.ColumnNumber
                        %stem(app.Normalization_NormalizedMSPlot, app.XAxisPlot, app.NormalizedArray(:, k))
                    %end
                    %hold(app.Normalization_NormalizedMSPlot,"off");
                case 'Single'
                    [x,y] = size(app.CurrentProject.RawData.RawMzValues);
                    sprintf('MZ x: %d, y: %d',x,y)
                    [x,y] = size(app.CurrentProject.PreprocessedData.NormalizedSpectra);
                    sprintf('Normalized x: %d, y: %d',x,y)
                    plot(app.Normalization_NormalizedMSPlot, app.CurrentProject.RawData.RawMzValues, app.CurrentProject.PreprocessedData.NormalizedSpectra(:, app.Normalization_SamplePointSpinner.Value));
                case 'Multiple'
                    retreivedata = get(app.Normalization_SelectDataTable,'data');
                    hold(app.Normalization_NormalizedMSPlot,"on");
                    for k = 1:length(retreivedata(:,2))
                        if retreivedata(k,2) == 1
                            plot(app.Normalization_NormalizedMSPlot, app.CurrentProject.RawData.RawMzValues, app.CurrentProject.PreprocessedData.NormalizedSpectra(:, k))
                        end
                    end
                    hold(app.Normalization_NormalizedMSPlot,"off");
            end     
        end
        
        function displayNormalizedDataTable(app)
            %NormData = app.CurrentProject.PreprocessedData.NormalizedSpectra;
            %SampleIndex = transpose(1:app.ColumnNumber);
            %DataToDisplay = cat(2,SampleIndex,NormData);
            app.Normalization_DataTable.RowName = 'numbered';
            app.Normalization_DataTable.ColumnName = 'numbered';

            app.Normalization_DataTable.Data = app.CurrentProject.PreprocessedData.NormalizedSpectra;
            s = uistyle('HorizontalAlignment','center');
            addStyle(app.Normalization_DataTable,s);
        end
        
        function plotPeakDetection(app)
            cla(app.Detection_PeakDetectionPlot)
            app.Detection_PeakDetectionPlot.XLim = [app.CurrentProject.RawData.MinIntensity app.CurrentProject.RawData.MaxIntensity];

            if isempty(app.Detection_SpectrumtodisplayEditField.Value)
                hold(app.Detection_PeakDetectionPlot,"on");
                for i=1:app.CurrentProject.RawData.NumberOfSpectra
                    plot(app.Detection_PeakDetectionPlot,app.CurrentProject.RawData.RawMzValues,app.CurrentProject.PreprocessedData.NormalizedSpectra(:,i),app.CurrentProject.PreprocessedData.CutThresholdPeak{i}(:,1),app.CurrentProject.PreprocessedData.CutThresholdPeak{i}(:,2),'rx')
                end
                hold(app.Detection_PeakDetectionPlot,"off");

            else
                app.UIAxes.Title.String = 'Selected spectra';
                index = str2num(app.Detection_SpectrumtodisplayEditField.Value);
                plot(app.Detection_PeakDetectionPlot,app.CurrentProject.RawData.RawMzValues,app.CurrentProject.PreprocessedData.NormalizedSpectra(:,index),'b',app.CurrentProject.PreprocessedData.CutThresholdPeak{index}(:,1),app.CurrentProject.PreprocessedData.CutThresholdPeak{index}(:,2),'rx')
            end
        end
        
        function plotPeakBinning_Hierachical(app)
            hold(app.Binning_PeakBinningPlot,"on");
            box(app.Binning_PeakBinningPlot,"on");
            plot(app.Binning_PeakBinningPlot,[CMZ CMZ],[-10 100],'-k');
            plot(MZ,YN2)
            axis([7200 8500 -10 100])
            xlabel('Mass/Charge (M/Z)')
            ylabel('Relative Intensity')
            title('Common Mass/Charge (M/Z) Locations found by Clustering') 
        end
        
    end
end

