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
    end
end

