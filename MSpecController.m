classdef MSpecController
    
    properties
    end
    
    methods (Static)
        
        function initAppFromFiles(app)
            prj = app.CurrentProject;
            
            if ~isempty(prj.PreprocessedData.AlignedSpectra)
                % PreProcessing Part
                Visualization.plotRawMSData(app);
                % set UI parameters
                app.Preprocessing_WindowSizeEditField.Value = prj.PreprocessedData.WindowSize; %window size
                app.Preprocessing_StepsizeEditField.Value = prj.PreprocessedData.StepSize; %step size
                app.Preprocessing_QuantilevalueEditField.Value = prj.PreprocessedData.QuantileValue; %quantile value

                app.Preprocessing_ReferenceSpectrumEditField.Value = prj.PreprocessedData.ReferenceSpectrum; %alignment refernce spectrum
                app.Preprocessing_MinimumsegementsizeallowedEditField.Value = prj.PreprocessedData.SegmentSize; %alignment segment size
                app.Preprocessing_MaximumshiftallowedEditField.Value = prj.PreprocessedData.ShiftAllowance; %alignment shift alowance

                app.Preprocessing_SpectrumtodisplayEditField.Value = num2str(prj.PreprocessedData.DisplayingSpectra); %spectra to display
                app.Preprocessing_StartingpointEditField.Value = num2str(prj.PreprocessedData.SectionStart); %starting point of section of interest
                app.Preprocessing_EndingpointEditField.Value = num2str(prj.PreprocessedData.SectionEnd); %ending point of section of interest

                % Plotpreprocessed
                Visualization.plotPreprocessedMSData(app);
            end
            
            % Normalization
            if ~isempty(prj.PreprocessedData.NormalizedSpectra)
                % load parameters to UI
                currentOption = prj.PreprocessedData.NormalizeMethod;
                app.Normalization_PeakSpinner.Enable = false;
                app.Normalization_pvalueSpinner.Enable = false;
                switch currentOption
                    case 'Sum'
                        app.NormalizationMethodsButtonGroup.SelectedObject = app.Normalization_ioncountsButton;
                    case 'Norm'
                        app.NormalizationMethodsButtonGroup.SelectedObject = app.Normalization_pnormButton;
                        app.Normalization_pvalueSpinner.Enable = true;
                        app.Normalization_pvalueSpinner.Value = prj.PreprocessedData.NormalizationNormValue;
                    case 'Median'
                        app.NormalizationMethodsButtonGroup.SelectedObject = app.Normalization_MedianButton;
                    case 'Noise'
                        app.NormalizationMethodsButtonGroup.SelectedObject = app.Normalization_NoiseLevelButton;
                    otherwise
                        app.NormalizationMethodsButtonGroup.SelectedObject = app.Normalization_ReferencePeakButton;
                        app.Normalization_PeakSpinner.Enable = true;
                        app.Normalization_PeakSpinner.Value = prj.PreprocessedData.ReferencePeak;
                end
                
                option = prj.PreprocessedData.NormalizeDisplay;
                app.Normalization_SamplePointSpinner.Enable = false;
                app.Normalization_SelectDataTable.Enable = 'off';
                switch option
                    case 'All'
                        app.ViewOptionButtonGroup.SelectedObject = app.Normalization_AllSpectraButton;
                    case 'Single'
                        app.ViewOptionButtonGroup.SelectedObject = app.Normalization_SingleSpectrumButton;
                        app.Normalization_SamplePointSpinner.Enable = true;
                    otherwise
                        app.ViewOptionButtonGroup.SelectedObject = Normalization_MultipleSpectraButton;
                        app.Normalization_SelectDataTable.Enable = 'on';
                end
                               
                Visualization.plotRawMSData_Normalization(app);
                MSpecController.DisplaySamplePointOption(app);
                Preprocessing.updateNormalizedSpectra(app);
                Visualization.plotNormalizedSpectra(app);
                Visualization.displayNormalizedDataTable(app);
            end
        end
        
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
            
            %=========IMPORTANT================
            MSpecController.initAppFromFiles(app);
        end
        
        function initProjectInfo(app)
            app.ProjectInfo_ProjectNameEditField.Value = app.CurrentProject.ProjectName;
            app.ProjectInfo_ImportedFileEditField.Value = app.CurrentProject.RawData.FileName;
            app.ProjectInfo_CreatedDate.Value = datestr(app.CurrentProject.CreatedDate);
            app.ProjectInfo_DescriptionTextArea.Value = app.CurrentProject.Description;
        end
        
        function saveProject(app)
            projectName = app.CurrentProject.ProjectName;            
            Location = pwd; 
            ProjectData = app.CurrentProject;
            dir = '\projects';
            Location = strcat(Location,dir);
            FileName = strcat(projectName,'.mat');

            % if the file already exists then just save
            if exist(fullfile(Location, FileName), 'file')
                % File exists.  Do stuff....
                msg = 'Saving these changes will overwrite previous changes.';
                title = 'Confirm Save';
                selection = uiconfirm(app.MSPECAppUIFigure,msg,title,...
                    'Options',{'Overwrite','Save as new','Cancel'},...
                    'DefaultOption',1,'CancelOption',3);
                if selection == "Overwrite"
                    save(fullfile(Location, projectName), 'ProjectData');
                elseif selection == "Save as new"
                    % create new project to be done later
                else
                    % do nothing
                    uiconfirm(app.MSPECAppUIFigure,'Your project is not saved.','Cancel','Options',{'OK'},'Icon','error');
                end
            else
                % File does not exist.
                save(fullfile(Location, projectName), 'ProjectData');
                msg = sprintf('Your project has been saved to %s',Location);
                selection = uiconfirm(app.MSPECAppUIFigure,msg,'Saved Sucessfully','Options',{'OK'},'Icon','success');
                if selection == "OK"
                    % do nothing
                end
            end 
        end
        
        function temp(app)
            % ----------- NOT USED
            % ----------- kept here for future use
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
            
            d = uiprogressdlg(app.MSPECAppUIFigure,'Title','Processing your data','Message','Please wait . . .','Indeterminate','on');
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
            Visualization.plotPreprocessedMSData(app);
        end
        
        function initNormalization(app)
            Visualization.plotRawMSData_Normalization(app);
            app.TabGroup.SelectedTab = app.NormalizationTab;
            MSpecController.DisplaySamplePointOption(app);
            Preprocessing.updateNormalizedSpectra(app);
        end
        
        function updateNormalizedSpectra(app)
            Preprocessing.updateNormalizedSpectra(app);
            Visualization.plotNormalizedSpectra(app);
            Visualization.displayNormalizedDataTable(app);
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
            switch app.Binning_ImportEdgesCheckBox.Value
                case true % use imported Edge
                    if app.Binning_FileLabel.Text == "Choose File . . ." % users not yet import the file
                        % error window
                        msg = 'No Edges Imported';
                        errordlg('Please import the file first',msg);
                    else
                        Preprocessing.startPeakBinningFromEdges(app); % Find Edges and Bin data
                        Visualization.plotBinningEdgeList(app);
                        Visualization.plotBinningSpectra(app);
                        MSpecController.Binning_displaySamplePointOption(app);
                        Visualization.displayBinDataTable(app);
                    end
                otherwise % use parameters
                    Preprocessing.startPeakBinning(app); % Find Edges and Bin data
                    if isempty(app.CurrentProject.PreprocessedData.EdgeList)
                        msg = 'No Edges found.';
                        errordlg('Please re-adjust the parameters and try again',msg);
                    else
                        Visualization.plotBinningEdgeList(app);
                        Visualization.plotBinningSpectra(app);
                        MSpecController.Binning_displaySamplePointOption(app);
                        Visualization.displayBinDataTable(app);
                    end
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

