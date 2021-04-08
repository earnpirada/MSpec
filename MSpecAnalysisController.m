classdef MSpecAnalysisController
    
    properties
    end
    
    methods (Static)
        
        function importData(app)
            d = uiprogressdlg(app.MSpecAnalysisUIFigure,'Title','Please Wait',...
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
            d = uiprogressdlg(app.MSpecAnalysisUIFigure,'Title','Initializing the Preprocessing',...
            'Indeterminate','on');
            drawnow
            % LOAD and STORE PARAM from the model
            MSpecAnalysisController.loadPreprocessParameters(app);
            % set UI params
            MSpecAnalysisController.parametersToUI(app);
            
            MSpecAnalysisController.preprocessing(app);
            close(d)
        end
        
        
        function preprocessing(app)
            rawData = app.CurrentProject.RawData;
            params = app.CurrentPreprocessParameters;

            preprocessedData = PreprocessedMSAData();
            
            % start
            MSpecAnalysisController.alignment(rawData,params,preprocessedData);
            MSpecAnalysisController.baselineCorrection(rawData, preprocessData, params);
            
            sprintf("it works !")
            
        end
        
        function alignment(rawData,params,preprocessedData)
            sample = rawData.RawSpectraIntensities;
            spectra = transpose(sample);
            reference = spectra(params.ReferenceSpectrum,:);
            segSize = params.SegmentSize;
            shift = params.ShiftAllowance;
            params
            
            if length(reference)~=length(spectra)
                error('Reference and spectra of unequal lengths');
            elseif length(reference)== 1
                error('Reference cannot be of length 1');
            end
            if nargin==3
                shift = length(reference);
            end
            for i=1:size(spectra,1)
                startpos = 1;
                aligned =[];
                while startpos <= length(spectra)
                    endpos=startpos+(segSize*2);
                    if endpos >=length(spectra)
                        samseg= spectra(i,startpos:length(spectra));
                        refseg= reference(1,startpos:length(spectra));
                    else
                        samseg = spectra(i,startpos+segSize:endpos-1);
                        refseg = reference(1,startpos+segSize:endpos-1);
                        MSpecAnalysisController.findMin(preprocessedData,samseg,refseg);
                        minpos = preprocessedData.MinPosition;
                        endpos = startpos+minpos+segSize;
                        samseg = spectra(i,startpos:endpos);
                        refseg = reference(1,startpos:endpos);
                    end
                    MSpecAnalysisController.FFTcorr(preprocessedData,samseg,refseg,shift);
                    lag = preprocessedData.SegmentLag;
                    samseg
                    lag
                    MSpecAnalysisController.move(preprocessedData,samseg,lag);
                    aligned = [aligned params.ShiftedSegment];
                    startpos=endpos+1;
                end
                preprocessedData.PreprocessedSpectra(i,:) = aligned;
            end
        end
        
        function FFTcorr(preprocessedData,spectrum, target, shift)
            %padding
            M=size(target,2);
            diff = 1000000;
            for i=1:20
                curdiff=((2^i)-M);
                if (curdiff > 0 && curdiff<diff)
                    diff = curdiff;
                end
            end
            
            target(1,M+diff)=0;
            spectrum(1,M+diff)=0;
            M= M+diff;
            X=fft(target);
            Y=fft(spectrum);
            R=X.*conj(Y);
            R=R./(M);
            rev=ifft(R);
            vals=real(rev);
            maxpos = 1;
            maxi = -1;
            if M<shift
                shift = M;
            end
            
            for i = 1:shift
                if (vals(1,i) > maxi)
                    maxi = vals(1,i);
                    maxpos = i;
                end
                if (vals(1,length(vals)-i+1) > maxi)
                    maxi = vals(1,length(vals)-i+1);
                    maxpos = length(vals)-i+1;
                end
            end
        
            if maxi < 0.1
                lag =0;
            end
            if maxpos > length(vals)/2
               lag = maxpos-length(vals)-1;
            else
               lag =maxpos-1;
            end
            preprocessedData.SegmentLag = lag;
        end

        function move(preprocessedData, seg, lag)
            
            if (lag == 0) || (lag >= length(seg))
                movedSeg = seg;
            end
            
            if lag > 0
                ins = ones(1,lag)*seg(1);
                movedSeg = [ins seg(1:(length(seg) - lag))];
            elseif lag < 0
                lag = abs(lag);
                ins = ones(1,lag)*seg(length(seg));
                movedSeg = [seg((lag+1):length(seg)) ins];
            end
            preprocessedData.ShiftedSegment = movedSeg;
        end
        
        function findMin(preprocessedData, samseg,refseg)
        
            [Cs,Is]=sort(samseg);
            [Cr,Ir]=sort(refseg);
            minposA = [];
            minInt = [];
            for i=1:round(length(Cs)/20)
                for j=1:round(length(Cs)/20)
                    if Ir(j)==Is(i);
                        minpos = Is(i);
                    end
                end
            end
            preprocessedData.MinPosition = Is(1,1);
        end
        
        function baselineCorrection(rawData, preprocessData, params)
            baselined = msbackadj(rawData.RawMzValues,transpose(preprocessData.PreprocessedSpectra),'STEPSIZE', params.StepSize,...
                'WINDOWSIZE', params.WindowSize,'QuantileValue',params.QuantileValue,'SmoothMethod','lowess');        
            baselined = max(baselined,0);
            preprocessData.PreprocessedSpectra = mslowess(rawData.RawMzValues,baselined);
        end
    end
end

