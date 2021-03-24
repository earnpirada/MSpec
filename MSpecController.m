classdef MSpecController
    
    properties
    end
    
    methods (Static)
        
        function getRecentFiles(app)
            % where MS projects are stored
            directory = '.\projects';
            MyFolderInfo = dir(fullfile(directory,'*.mat'))
            [numFile,~] = size(MyFolderInfo);
            fileNameList = {};
            for i = 1:numFile
                fileNameList{end+1} = MyFolderInfo(i).name(1:end-4);
            end
            app.RecentFileListBox.Items = fileNameList;
        end
        
        function loadRecentFiles(app)
            selectedFile = app.RecentFileListBox.Value;
            Location = pwd;
            dir = '\projects';
            Location = strcat(Location,dir);
            FileName = strcat(selectedFile,'.mat');
            loadedData = load(fullfile(Location, FileName))
            app.CurrentProject = loadedData.ProjectData;
        end
        
        function initProjectInfo(app)
            app.ProjectInfo_ProjectNameEditField.Value = app.CurrentProject.ProjectName;
            app.ProjectInfo_ImportedFileEditField.Value = app.CurrentProject.RawData.FileName;
        end
        
        function saveProject(app)
            projectName = app.CurrentProject.ProjectName;            
            Location = pwd; 
            ProjectData = app.CurrentProject;
            dir = '\projects';
            Location = strcat(Location,dir)
            save(fullfile(Location, projectName), 'ProjectData');
        end
        
        function temp(app)
            startingFolder = 'C:\Program Files\MATLAB'
            if ~exist(startingFolder, 'dir')
                % If that folder doesn't exist, just start in the current folder.
                startingFolder = pwd;
            end
            % Put in the name of the mat file that the user wants to save.
            % defaultFileName = fullfile(startingFolder, '*.mat')
            [file,path] = uiputfile('myMatrix.mat','Save file name');
            if file == 0
                % User clicked the Cancel button.
                return;
            end
            fullFileName = fullfile(path, file)
            save(fullFileName)
        end
        
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
            if isempty(app.CurrentProject.PreprocessedData.EdgeList)
                msg = 'No Edges found.';
                errordlg(msg,'Try Again');
            else
                Visualization.plotBinningEdgeList(app);
                Visualization.plotBinningSpectra(app);
                MSpecController.Binning_displaySamplePointOption(app);
                Visualization.displayBinDataTable(app)
            end
        end
        
        function Binning_displaySamplePointOption(app)
            SampleIndex = transpose(1:app.CurrentProject.RawData.NumberOfSpectra);
            F = false(app.CurrentProject.RawData.NumberOfSpectra,1);
            F = [SampleIndex F];
            app.Binning_SelectDataTable.Data = F;
            app.Binning_SelectDataTable.ColumnFormat = {'char', 'logical'};
            s = uistyle('HorizontalAlignment','center');
            addStyle(app.Binning_SelectDataTable,s);
        end
        
        function Binning_updateBinningPlot(app)
            Visualization.plotBinningSpectra(app);
        end
        
        
    end
end

