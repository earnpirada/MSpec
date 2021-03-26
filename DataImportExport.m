classdef DataImportExport
    
    properties
    end
    
    methods (Static)
        function importData(app)
            fig = uifigure;
            d = uiprogressdlg(fig,'Title','Please Wait',...
                'Message','Opening the import window');
            pause(.5)
            handles.filename = uigetfile('*.csv*');
            fileName=handles.filename;
            [fPath, fName, fExt] = fileparts(fileName);
            switch lower(fExt)
              case '.ods'
                d.Value = .33; 
                d.Message = 'Loading your data';
                pause(1)
                RawImportData=xlsread(fileName);
              case '.csv'	
                d.Value = .33; 
                d.Message = 'Loading your data';
                pause(1)
                RawImportData=readmatrix(fileName);
              otherwise  % Under all circumstances SWITCH gets an OTHERWISE!
                %error('Unexpected file extension: %s', fExt);
                % display error message
                msgbox('Please input CSV files')
                app.ImportStatusLabel.FontColor = [0.6902 0.2549 0.2549];
                app.ImportStatusLabel.Text = 'The file must be in .csv format';
                close(d)
                close(fig)
            end
            %if isequal(file,0)
                % display error message
                %msgbox('Please input CSV files')
                %app.ImportStatusLabel.FontColor = [0.6902 0.2549 0.2549];
                %app.ImportStatusLabel.Text = 'The file must be in .csv format';
                %close(d)
                %close(fig)
            % Perform calculations
            % ...
            %d.Value = .33; 
            %d.Message = 'Loading your data';
            %pause(1)
                % read data
                
                %fileName = file;
                %RawImportData = csvread(fullfile(path,file));
                %RawImportData=readmatrix(filename);
                % update field
            app.ImportStatusLabel.FontColor = [0.1333 0.4588 0.1137];
            app.ImportStatusLabel.Text = [fileName,' has been imported successfully !'];
            %end
            
            % Perform calculations
            % ...
            d.Value = .67;
            d.Message = 'Processing the data';
            pause(1)
            
            RawImportData(1,:)=[];
            RawMzValues=RawImportData(:,1);
            %[RowNumber,ColumnNumber]= size(RawImportData);
            [x,y] = size(RawImportData);
            RawSpectraIntensities=zeros(x,y);
            for i = 2:y
                RawSpectraIntensities(:,i)  = RawImportData(:,i);
            end
            fprintf('%d loops',y)
            RawSpectraIntensities(:,1)=[];
            % MinIntensity = min(RawMzValues);
            % MaxIntensity = max(RawMzValues);
            [m,n] = size(RawSpectraIntensities);
            NumberOfSpectra = n;
            fprintf('col: %d row: %d s',m,n)
            
            % Finish calculations
            % ...
            d.Value = 1;
            d.Message = 'Finishing';
            pause(1)
            
            importedMSData = MSData(fileName,RawImportData,RawMzValues,RawSpectraIntensities,NumberOfSpectra, m , n);
            DataImportExport.initProjectInfo(app,importedMSData);
            app.CurrentProject = MSProject(importedMSData);

            % Close dialog box
            close(d)
            close(fig)
        end
        
        function initProjectInfo(app, MSData)
            app.ProjectNameEditField.Value = MSData.FileName(1:end-4);
            app.NumberofMassSpectraEditField.Value = MSData.NumberOfSpectra;
            app.WidthField.Value = 1;
            app.HeightField.Value = MSData.NumberOfSpectra;
            app.WidthField.Editable = 'off';
            app.HeightField.Editable = 'off';

        end
        
        function width = calculateWidth (numberOfSpectra, height)
            width = numberOfSpectra/height;
        end
        
        function createProject (app)
            app.CurrentProject.setProjectInfo(app.ProjectNameEditField.Value);
            app.TabGroup.SelectedTab = app.PreprocessingTab;
            %Init Raw Data Plot
            Visualization.plotRawMSData(app);
            MSpecController.initProjectInfo(app);
        end
        
        function exportPreprocessedData(app)
            [file,path] = uiputfile('*.csv');
            filename = fullfile(path,file);
            %Arr = transpose(0:app.RowNumber-1);
            OutputArray = [app.CurrentProject.RawData.RawMzValues app.CurrentProject.PreprocessedData.BaselinedSpectra];
            csvwrite(filename,OutputArray);
        end
        
        function exportBinnedData(app)
            [file,path] = uiputfile('*.csv');
            filename = fullfile(path,file);
            OutputArray = [app.CurrentProject.PreprocessedData.BinIndexList app.CurrentProject.PreprocessedData.BinnedSpectra];
            csvwrite(filename,OutputArray);
        end
        
        function exportBinEdges(app)
            [file,path] = uiputfile('*.csv');
            filename = fullfile(path,file);
            OutputArray = [app.CurrentProject.PreprocessedData.EdgeList];
            csvwrite(filename,OutputArray);
        end
        
        function importBinEdges(app)
            handles.filename = uigetfile('*.csv*');
            fileName=handles.filename;
            edgeList=readmatrix(fileName);
            app.Binning_FileLabel.Text = fileName;
            app.CurrentProject.PreprocessedData.ImportedEdgeList = edgeList;
        end
      
    end
end