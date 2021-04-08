classdef MSpecAnalysisController
    
    properties
    end
    
    methods (Static)
        
        function importData(app)
            d = uiprogressdlg(app.UIFigure,'Title','Please Wait',...
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
                
                msgbox('Please input CSV files')
                app.ImportStatusLabel.FontColor = [0.6902 0.2549 0.2549];
                app.ImportStatusLabel.Text = 'The file must be in .csv format';
                close(d)
            end
            
            app.ImportStatusLabel.FontColor = [0.1333 0.4588 0.1137];
            app.ImportStatusLabel.Text = [fileName,' has been imported successfully !'];
            %end
            
            d.Value = .67;
            d.Message = 'Processing the data';
            pause(1)
            
            RawMzValues=RawImportData(:,1);
            [x,y] = size(RawImportData);
            RawSpectraIntensities=zeros(x,y);
            for i = 2:y
                RawSpectraIntensities(:,i)  = RawImportData(:,i);
            end
            RawSpectraIntensities(:,1)=[];
            [m,n] = size(RawSpectraIntensities);
            NumberOfSpectra = n;
            
            % Finish calculations
            % ...
            d.Value = 1;
            d.Message = 'Finishing';
            pause(1)
            
            importedMSData = MSData(fileName,RawImportData,RawMzValues,RawSpectraIntensities,NumberOfSpectra, m , n);
            MSpecAnalysisController.initProjectInfo(app,importedMSData);
            app.CurrentProject = MSAnalysisProject(importedMSData);

            % Close dialog box
            close(d)
        end
        
        function initProjectInfo(app, MSData)
            app.ProjectNameEditField.Value = MSData.FileName(1:end-4);
            app.NumberofMassSpectraEditField.Value = MSData.NumberOfSpectra;
            app.WidthField.Value = 1;
            app.HeightField.Value = MSData.NumberOfSpectra;
            app.WidthField.Editable = 'off';
            app.HeightField.Editable = 'off';
            app.Import_CreateProjectButton.Enable = true;
        end
        
        function createProject (app)
            app.CurrentProject.setProjectInfo(app.ProjectNameEditField.Value,app.DescriptionEditField.Value);
            app.TabGroup.SelectedTab = app.ClassificationTab;
            %Init Classification Tab
            MSpecAnalysisController.displayProjectInfo(app);
            AnalysisVisualization.displayImportedDataTable(app);
            
        end
        
        function displayProjectInfo(app)
            app.ProjectInfo_ProjectNameEditField.Value = app.CurrentProject.ProjectName;
            app.ProjectInfo_ImportedFileEditField.Value = app.CurrentProject.RawData.FileName;
            app.ProjectInfo_CreatedDate.Value = datestr(app.CurrentProject.CreatedDate);
            app.ProjectInfo_DescriptionTextArea.Value = app.CurrentProject.Description;
        end
        
        function retrieveModelTypes(app)
            
            t = app.ModelTypeTree;
            
            % First level nodes
            KNN = app.KNEARESTNEIGHBORKNNNode;
            % Second level nodes.
            knndir = '.\models\KNN\';
            KNNFolderInfo = dir(fullfile(knndir,'*.mat'));
            [numFile,~] = size(KNNFolderInfo);
            for i = 1:numFile
                uitreenode(KNN,'Text',KNNFolderInfo(i).name(1:end-4),'NodeData',[strcat(knndir,KNNFolderInfo(i).name)]);
            end
            
            SVM = app.SUPPORTVECTORMACHINESSVMNode;
            svmdir = '.\models\SVM\';
            SVMFolderInfo = dir(fullfile(svmdir,'*.mat'));
            [numFile,~] = size(SVMFolderInfo);
            for i = 1:numFile
                uitreenode(SVM,'Text',SVMFolderInfo(i).name(1:end-4),'NodeData',[strcat(svmdir,SVMFolderInfo(i).name)]);
            end
            
            DT = app.DECISIONTREESNode;
            dtdir = '.\models\Decision Tree\';
            DTFolderInfo = dir(fullfile(dtdir,'*.mat'));
            [numFile,~] = size(DTFolderInfo);
            for i = 1:numFile
                uitreenode(DT,'Text',DTFolderInfo(i).name(1:end-4),'NodeData',[strcat(dtdir,DTFolderInfo(i).name)]);
            end
            
            NB = app.NAIVEBAYESCLASSIFIERSNode;
            nbdir = '.\models\Naive Bayes\';
            NBFolderInfo = dir(fullfile(nbdir,'*.mat'));
            [numFile,~] = size(NBFolderInfo);
            for i = 1:numFile
                uitreenode(NB,'Text',NBFolderInfo(i).name(1:end-4),'NodeData',[strcat(nbdir,NBFolderInfo(i).name)]);
            end
            
            
            % Expand the tree
            expand(t);
        end
        
        function retrieveModelInfo(app)
            selectedNodes = app.ModelTypeTree.SelectedNodes;
            filename = selectedNodes.NodeData;
            infodir = strcat(filename(1:end-4),'.txt');
            
            fid = fopen(infodir,'r');

            info = textscan(fid, '%s', 'whitespace', '', 'delimiter', ';');

            app.ModelInfoTextArea.Value = info{1};
        end
        
        function mdl = retrieveModel(app)
            selectedNodes = app.ModelTypeTree.SelectedNodes;
            filename = selectedNodes.NodeData;
            mdldir = strcat(filename(1:end-4),'.mat');
            
            mdl = load(mdldir);
        end
        
        function importModel(app)
            handles.filename = uigetfile('*.mat*');
            fileName=handles.filename;
            model=load(fileName);
            app.ImportedModel = model;
            app.ModelFileLabel.Text = [fileName,' has been imported successfully !'];
            app.ModelFileLabel.FontColor = [0.1333 0.4588 0.1137];

            app.ModelNameEditField.Enable = true;
            app.ModelNameEditField.Value = fileName(1:end-4);

            app.ModelTypeDropDown.Enable = true;
            app.ModelDescriptionLabel.Enable = true;
            app.NextButton.Enable = true;
            app.ModelDescriptionTextArea.Enable = true;

        end
        
        function importBinEdges(app)
            handles.filename = uigetfile('*.csv*');
            fileName=handles.filename;
            edgeList=readmatrix(fileName);
            app.Binning_FileLabel.Text = fileName;
            app.ImportedEdgeListFileName = fileName;
            app.ImportedEdgeList = edgeList;
            app.ImportModelButton.Enable = true;
            [~,num] = size(edgeList);
            app.NoofBinsEditField.Value = num;
        end
        
        function setPreprocessParam(app)
            
            startpt = app.Preprocessing_StartingpointEditField.Value;
            endpt = app.Preprocessing_EndingpointEditField.Value;
            
            %baseline
            
            winsize = app.Preprocessing_WindowSizeEditField.Value;
            stepsize = app.Preprocessing_StepsizeEditField.Value;
            quantile = app.Preprocessing_QuantilevalueEditField.Value;
            
            %align
            refspec = app.Preprocessing_ReferenceSpectrumEditField.Value;
            minseg = app.Preprocessing_MinimumsegementsizeallowedEditField.Value;
            maxshift = app.Preprocessing_MaximumshiftallowedEditField.Value;
            
            %Norm
            
            selectedButton = app.NormalizationMethodsButtonGroup.SelectedObject;
            app.Normalization_pvalueSpinner.Enable = false;
            switch selectedButton % Get Tag of selected object.
                case app.Normalization_ioncountsButton
                    norm='Sum';
                case app.Normalization_pnormButton
                    norm='Norm';
                case app.Normalization_MedianButton
                    norm='Median';
                case app.Normalization_NoiseLevelButton
                    norm='Noise';
                case app.Normalization_MaxIntensityButton
                    norm='Max';
                otherwise
                    norm='Peak';
            end
            normrefMZ = app.Normalization_ReferenceMZEditField.Value;
            normpvalue = app.Normalization_pvalueSpinner.Value;
             
            edgeList = app.ImportedEdgeList;
            edgeListFileName =  app.ImportedEdgeListFileName;
             
            app.PreprocessingSetting = PreprocessingParameters(startpt,endpt,winsize,stepsize,quantile,...
                 refspec,minseg,maxshift,norm,normrefMZ,normpvalue,edgeList,edgeListFileName);

        end
        
        function importModelToApp(app)
            
            modelName = app.ModelNameEditField.Value;
            description = string(app.ModelDescriptionTextArea.Value);
            toSavePath = app.ToImportPath; 
            
            if isempty(description)
                description = 'Model Imported By Users';
            end
            
            fileName = strcat(modelName,'.txt');
            fullFileName = strcat(toSavePath,fileName);
            % write model description to txt file
            fid = fopen(fullFileName, 'wt');
            fprintf(fid,'%s\n', description);
            fclose(fid);
            
            MSpecAnalysisController.setPreprocessParam(app); % collect data
            
            model = ClassificationModel(app.ImportedModel,app.PreprocessingSetting);
            modelFileName = strcat(modelName,'.mat');
            modelfullFileName = strcat(toSavePath,modelFileName);
            save(modelfullFileName,'model');
            
        end
        
        function loadPreprocessParameters(app)
            selectedModel = MSpecAnalysisController.retrieveModel(app);
            
            app.CurrentModel = selectedModel.model.Model;
            app.CurrentPreprocessParameters = selectedModel.model.Preprocessing;

        end
        
        function parametersToUI(app)
            params = app.CurrentPreprocessParameters;
            
            % set UI parameters
            app.Preprocessing_WindowSizeEditField.Value = params.WindowSize; %window size
            app.Preprocessing_StepsizeEditField.Value = params.StepSize; %step size
            app.Preprocessing_QuantilevalueEditField.Value = params.QuantileValue; %quantile value

            app.Preprocessing_ReferenceSpectrumEditField.Value = params.ReferenceSpectrum; %alignment refernce spectrum
            app.Preprocessing_MinimumsegementsizeallowedEditField.Value = params.SegmentSize; %alignment segment size
            app.Preprocessing_MaximumshiftallowedEditField.Value = params.ShiftAllowance; %alignment shift alowance

            app.Preprocessing_StartingpointEditField.Value = num2str(params.SectionStart); %starting point of section of interest
            app.Preprocessing_EndingpointEditField.Value = num2str(params.SectionEnd); %ending point of section of interest
        
        end
        
        
        function startPreprocessing(app)
            d = uiprogressdlg(app.UIFigure,'Title','Initializing the Preprocessing',...
            'Indeterminate','on');
            drawnow
            % LOAD and STORE PARAM from the model
            MSpecAnalysisController.loadPreprocessParameters(app);
            % set UI params
            MSpecAnalysisController.parametersToUI(app);
            close(d)
        end
    end
end

