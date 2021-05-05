classdef Classification
    properties
    end
    
    methods (Static)
        
        function runPrediction(app)
            d = uiprogressdlg(app.MSpecAnalysisUIFigure,'Title','Predicting',...
            'Indeterminate','on');
            drawnow
            switch app.CurrentProject.ClassificationModelType
                case 'KNN'
                    model = app.CurrentProject.ClassificationModel.trainedModel.ClassificationKNN;
                    data = transpose(app.CurrentProject.PreprocessedData.BinnedSpectra);
                    [label,score,~] = predict(model,data);
                    classNames = model.ClassNames;
                    app.CurrentProject.ClassNames = classNames;
                    app.CurrentProject.PredictionResult = label;
                    app.CurrentProject.ScoreMatrix = score;
                    Classification.verifyPrediction(app,classNames);
                    AnalysisVisualization.displayPredictionResult(app);
                    AnalysisVisualization.displayScoreTable(app,score,classNames);
                    AnalysisVisualization.findClassPercentage(app);
                    
                case 'SVM'
                    model = app.CurrentProject.ClassificationModel.trainedModel.ClassificationSVM;
                    data = transpose(app.CurrentProject.PreprocessedData.BinnedSpectra);
                    [label,~,~,Posterior] = predict(model,data);
                    classNames = model.ClassNames;
                    app.CurrentProject.ClassNames = classNames;
                    app.CurrentProject.PredictionResult = label;
                    app.CurrentProject.ScoreMatrix = Posterior;
                    Classification.verifyPrediction(app,classNames);
                    AnalysisVisualization.displayPredictionResult(app);
                    AnalysisVisualization.displayScoreTable(app,Posterior,classNames);
                    AnalysisVisualization.findClassPercentage(app);

                case 'Decision Tree'
                    model = app.CurrentProject.ClassificationModel.trainedModel.ClassificationTree;
                    data = transpose(app.CurrentProject.PreprocessedData.BinnedSpectra);
                    [label,score,~,~] = predict(model,data);
                    classNames = model.ClassNames;
                    app.CurrentProject.ClassNames = classNames;
                    app.CurrentProject.PredictionResult = label;
                    app.CurrentProject.ScoreMatrix = score;
                    Classification.verifyPrediction(app,classNames);
                    AnalysisVisualization.displayPredictionResult(app);
                    AnalysisVisualization.displayScoreTable(app,score,classNames);
                    AnalysisVisualization.findClassPercentage(app);
                    
                case 'Naive Bayes'
                    model = app.CurrentProject.ClassificationModel.trainedModel.ClassificationNaiveBayes;
                    data = transpose(app.CurrentProject.PreprocessedData.BinnedSpectra);
                    [label,Posterior,~] = predict(model,data);
                    classNames = model.ClassNames;
                    app.CurrentProject.ClassNames = classNames;
                    app.CurrentProject.PredictionResult = label;
                    app.CurrentProject.ScoreMatrix = Posterior;
                    Classification.verifyPrediction(app,classNames);
                    AnalysisVisualization.displayPredictionResult(app);
                    AnalysisVisualization.displayScoreTable(app,Posterior,classNames);
                    AnalysisVisualization.findClassPercentage(app);
                    
                case 'Ensemble'
                    model = app.CurrentProject.ClassificationModel.trainedModel.ClassificationEnsemble;
                    data = transpose(app.CurrentProject.PreprocessedData.BinnedSpectra);
                    [label,score] = predict(model,data);
                    classNames = model.ClassNames;
                    app.CurrentProject.ClassNames = classNames;
                    app.CurrentProject.PredictionResult = label;
                    app.CurrentProject.ScoreMatrix = score;
                    Classification.verifyPrediction(app,classNames);
                    AnalysisVisualization.displayPredictionResult(app);
                    AnalysisVisualization.displayScoreTable(app,score,classNames);
                    AnalysisVisualization.findClassPercentage(app);
                    
                case 'LDA'
                    model = app.CurrentProject.ClassificationModel.trainedModel.ClassificationDiscriminant;
                    data = transpose(app.CurrentProject.PreprocessedData.BinnedSpectra);
                    [label,score] = predict(model,data);
                    classNames = model.ClassNames;
                    app.CurrentProject.ClassNames = classNames;
                    app.CurrentProject.PredictionResult = label;
                    app.CurrentProject.ScoreMatrix = score;
                    Classification.verifyPrediction(app,classNames);
                    AnalysisVisualization.displayPredictionResult(app);
                    AnalysisVisualization.displayScoreTable(app,score,classNames);
                    AnalysisVisualization.findClassPercentage(app);
                    
            end
            app.TabGroup.SelectedTab = app.ResultsTab;
            close(d);
        end
        
        function verifyPrediction(app,classNames)
            a = app.CurrentProject.PredictionResult;
            for i = 1:size(a)
                [~, index] = ismember(a{i}, classNames);
                %idx = find([classNames{:}] == a{i})
                if isnan(app.CurrentProject.ScoreMatrix(i,index))
                    app.CurrentProject.PredictionResult{i} = 'undefined';
                elseif app.CurrentProject.ScoreMatrix(i,index)<0.1
                    app.CurrentProject.PredictionResult{i} = 'undefined';
                end
            end
        end
        
        
        function startImaging(app)
            Classification.setDropdownItem(app);
            switch app.OptionButtonGroup.SelectedObject
                case app.PredictedClassesButton_2
                    Classification.updateImagingByClass(app)
                otherwise
                    Classification.updateImagingByScore(app);
            end
            
        end
        
        function setDropdownItem(app)
            classNames = app.CurrentProject.ClassNames;
            classNames = {'---No Selection---', classNames{:,:}};

            app.RedDropDown.Items = classNames;
            app.RedDropDown.ItemsData = (0:length(classNames)-1);
            app.GreenDropDown.Items = classNames;
            app.GreenDropDown.ItemsData = (0:length(classNames)-1);
            app.BlueDropDown.Items = classNames;
            app.BlueDropDown.ItemsData = (0:length(classNames)-1);

        end
        
        function updateImagingByClass(app)
            labels = app.CurrentProject.PredictionResult;
            [g,gN,gL] = grp2idx(labels);
            
            imageArray = g;
            app.ImagingPlot.Visible='on';
            
            imageArray = transpose(reshape(imageArray,app.CurrentProject.RawData.RowNumber,app.CurrentProject.RawData.ColumnNumber,[]));
            imaging = imagesc(app.ImagingPlot,imageArray);
            axis(app.ImagingPlot, 'image');
            set(imaging, 'ButtonDownFcn', {@ImageClickCallback});
            colorbar(app.ImagingPlot,'off') 

            function ImageClickCallback ( objectHandle , eventData )
                temp = app.ImagingPlot.CurrentPoint;
                
                temp = temp(1,1:2);
                x = round(temp(1));
                y = round(temp(2));
                Classification.plotSampleMS(app,x,y);
            end
        end
        
        function updateImagingByScore(app)
            %test
            row = app.CurrentProject.RawData.RowNumber;
            col = app.CurrentProject.RawData.ColumnNumber;
            C = zeros(row,col,3);
            %Red
            if app.RedDropDown.Value ~= 0
                C(:,:,1) = rescale(reshape(app.CurrentProject.ScoreMatrix(:, app.RedDropDown.Value),row,col,[]));
            end
            if app.GreenDropDown.Value ~= 0
                C(:,:,2) = rescale(reshape(app.CurrentProject.ScoreMatrix(:, app.GreenDropDown.Value),row,col,[]));
            end
            if app.BlueDropDown.Value ~= 0
                C(:,:,3) = rescale(reshape(app.CurrentProject.ScoreMatrix(:, app.BlueDropDown.Value),row,col,[]));
            end
            C = permute(C,[2 1 3]);
            imaging = imagesc(app.ImagingPlot,C);
            axis(app.ImagingPlot, 'image');

            set(imaging, 'ButtonDownFcn', {@ImageClickCallback});

            %colorbar(app.ImagingPlot,'off') 


            function ImageClickCallback ( objectHandle , eventData )
                temp = app.ImagingPlot.CurrentPoint;
                temp = temp(1,1:2);
                x = round(temp(1));
                y = round(temp(2));
                Classification.plotSampleMS(app,x,y);
            end
        end
        
        function plotSampleMS(app,xcoordinate,ycoordinate)
            index = ((ycoordinate-1)*app.CurrentProject.RawData.RowNumber)+xcoordinate;
            bar(app.UIAxes5, app.CurrentProject.PreprocessedData.BinIndexList, app.CurrentProject.PreprocessedData.BinnedSpectra(:, index));
            sample = ['Sample: ',num2str(index)];
            class = [', Class: ',char(app.CurrentProject.PredictionResult(index))];
            text = strcat(sample, class);
            title(app.UIAxes5, text);
        end
        
        
    end
    
end

