classdef ReportGeneration
    
    properties
    end
    
    methods (Static)
        function generatePDFReport(app)
            % Import report API classes (optional)
            import mlreportgen.report.*
            
            % Add report container (required)
            rpt = Report('output','pdf');
            
            % Add content to container (required)
            % Types of content added here: title 
            % page and table of contents reporters
            titlepg = TitlePage;
            titlepg.Title = 'MSPEC Report';
            titlepg.Author = sprintf('From: %s',app.FileName);
            add(rpt,titlepg);
            
            % Add content to report sections (optional)
            % Text and formal image added to chapter
            chap1 = Chapter('Normalization');
            add(chap1,['Method: ',app.NormalizeMethod]);
            
            f1 = figure('visible','off');
            %plotting the raw data
            subplot(2,1,1,"Units","pixels");
            hold on;
            for i = 1:app.ColumnNumber
                plot(app.XAxisPlot,app.DataArray(:, i));
            end
            hold off;
            title('Raw Data');
            % Normalized
            subplot(2,1,2,"Units","pixels");
            hold on;
            for k = 1:app.ColumnNumber
               plot(app.XAxisPlot, app.NormalizedArray(:, k))
            end
            %xline(app.FeaturePeak,'-.r',{'Selected','Peak'});
            hold off;
            title('Normalized Data');
            
            add(chap1,Figure(f1));
            add(rpt,chap1);
            
            
            % Close the report (required)
            close(rpt);
            % Display the report (optional)
            rptview(rpt);
        end
    end
end

