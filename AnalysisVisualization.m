classdef AnalysisVisualization
    
    properties
    end
    
    methods (Static)
        
        function displayImportedDataTable(app)
            app.NumberofMassSpectraEditField_2.Value = app.CurrentProject.RawData.NumberOfSpectra;
            switch app.DataTypesButtonGroup.SelectedObject
                case app.MassSpectra1DButton
                    app.DataTypeButtonGroup.SelectedObject = app.MassSpectra1DButton_2;
                otherwise
                    app.DataTypeButtonGroup.SelectedObject = Imaging2DButton_2;
            end
            app.WidthField_2.Value = app.CurrentProject.RawData.RowNumber;
            app.HeightField_2.Value = app.CurrentProject.RawData.ColumnNumber;
            
            %Table
            tdata = table(app.CurrentProject.RawData.RawMzValues,app.CurrentProject.RawData.RawSpectraIntensities,'VariableNames',{'M/Z','Spectrum'});
            
            app.ImportedDataTable.Data = tdata;
            app.ImportedDataTable.ColumnName = tdata.Properties.VariableNames;
            s = uistyle('HorizontalAlignment','center');
            addStyle(app.ImportedDataTable,s);

        end
        
        function plotPreprocessedData(app)
            cla(app.PreprocessedDataPlot)
            app.PreprocessedDataPlot.XLim = [app.CurrentProject.RawData.MinIntensity app.CurrentProject.RawData.MaxIntensity];
            data = app.CurrentProject.PreprocessedData;
            
            switch app.BinningDisplay
                case 'All'
                    bar(app.PreprocessedDataPlot,data.BinIndexList, data.BinnedSpectra);
                case 'Single'
                    bar(app.PreprocessedDataPlot,data.BinIndexList, data.BinnedSpectra(:, app.Binning_SamplePointSpinner.Value));
                case 'Multiple'
                    retreivedata = get(app.Binning_SelectDataTable,'data');
                    hold(app.PreprocessedDataPlot,"on");
                    for k = 1:length(retreivedata(:,2))
                        if retreivedata(k,2) == 1
                            bar(app.PreprocessedDataPlot,data.BinIndexList, adata.BinnedSpectra(:, k));
                        end
                    end
                    hold(app.PreprocessedDataPlot,"off");
            end     
            
        end
    end
end

