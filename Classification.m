classdef Classification
    properties
    end
    
    methods (Static)
        
        function runPrediction(app)
            app.CurrentProject.ClassificationModelType
            switch app.CurrentProject.ClassificationModelType
                case 'KNN'
                case 'SVM'
                    
                    model = app.CurrentProject.ClassificationModel.trainedModel.ClassificationSVM;
                    data = transpose(app.CurrentProject.PreprocessedData.BinnedSpectra);
                    [label,~,PBScore,Posterior] = predict(model,data)
                    classNames = model.ClassNames;
                    app.CurrentProject.ClassNames = classNames;
                    app.CurrentProject.PredictionResult = label;
                    app.CurrentProject.ScoreMatrix = Posterior;
                    Classification.displayPredictionResult(app);
                    Classification.displayScoreTable(app,Posterior,classNames);
                    Classification.findClassPercentage(app);

                case 'Decision Tree'
                case 'Naive Bayes'
            end
            app.TabGroup.SelectedTab = app.ResultsTab;
        end
        
        function displayPredictionResult(app)
            sample = (1:app.CurrentProject.RawData.NumberOfSpectra)';
            t = table(sample, app.CurrentProject.PredictionResult,'VariableNames',{'Sample','Predicted Class'});
            app.ResultTable.Data = t;
            app.ResultTable.ColumnName = t.Properties.VariableNames;
            s = uistyle('HorizontalAlignment','center');
            addStyle(app.ResultTable,s,'table','');
        end
        
        function displayScoreTable(app, posterior,classNames)
            app.ScoreTable.RowName = 'numbered';
            app.ScoreTable.Data = posterior;
            app.ScoreTable.ColumnName = classNames;
            s = uistyle('HorizontalAlignment','center');
            addStyle(app.ScoreTable,s,'table','');
        end
        
        function findClassPercentage(app)
            labelsCat = categorical(app.CurrentProject.PredictionResult);
            % find unique elements
            labels = categories(labelsCat);
            % count number
            labelCount = countcats(labelsCat);

            pie(app.PredictionResultPlot,labelCount);
            title(app.PredictionResultPlot,'Predicted Classes');
            
            legend(app.PredictionResultPlot,labels,'Location','bestoutside');

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
            app.RedDropDown.ItemsData = (0:length(classNames)-1)
            app.GreenDropDown.Items = classNames;
            app.GreenDropDown.ItemsData = (0:length(classNames)-1)
            app.BlueDropDown.Items = classNames;
            app.BlueDropDown.ItemsData = (0:length(classNames)-1)

        end
        
        function updateImagingByClass(app)
            labels = app.CurrentProject.PredictionResult;
            [g,gN,gL] = grp2idx(labels);
            
            imageArray = g;
            app.ImagingPlot.Visible='on';

            imageArray = transpose(reshape(imageArray,4,4,[]));
            imaging = imagesc(app.ImagingPlot,imageArray);
            set(imaging, 'ButtonDownFcn', {@ImageClickCallback});

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
            row = 4;
            col = 4;
            C = zeros(4,4,3);
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
            imaging = imagesc(app.ImagingPlot,C);
            
            set(imaging, 'ButtonDownFcn', {@ImageClickCallback});

            function ImageClickCallback ( objectHandle , eventData )
                temp = app.ImagingPlot.CurrentPoint;
                temp = temp(1,1:2);
                x = round(temp(1));
                y = round(temp(2));
                Classification.plotSampleMS(app,x,y);
            end
        end
        
        function plotSampleMS(app,xcoordinate,ycoordinate)
            index = ((ycoordinate-1)*4)+xcoordinate;
            bar(app.UIAxes5, app.CurrentProject.PreprocessedData.BinIndexList, app.CurrentProject.PreprocessedData.BinnedSpectra(:, index));
            
        end
    end
end

