classdef ReportGeneration
    
    properties
    end
    
    methods (Static)
        function generatePDFReport(app)
            
            waitbar = uiprogressdlg(app.MSPECAppUIFigure,'Title','Please Wait',...
                'Message','Initializing');
            pause(.5)
            
            project = app.CurrentProject;
            ppms = project.PreprocessedData;

            Parameter = {'Window Size';'Step Size';'Quantile Value' ...
            ;'Reference Spectrum'; 'Minimum Segment Size Allowed';'Maximum Shift Allowed'};

            Value = {ppms.WindowSize;ppms.StepSize;ppms.QuantileValue; ...
                ppms.ReferenceSpectrum;ppms.SegmentSize;ppms.ShiftAllowance};

            
            % Import report API classes (optional)
            import mlreportgen.report.* 
            import mlreportgen.dom.* 
            
            
            %*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

            waitbar.Value = .2; 
            waitbar.Message = 'Generating the Report';
            pause(.5)
            
            % Add report container (required)
            report = Report('output','pdf');
            
            % Add content to container (required)
            % Types of content added here: title 
            % page and table of contents reporters
            titlepg = TitlePage;
            titlepg.Title = project.ProjectName;
            titlepg.Subtitle = 'MSpec'; 
            %titlepg.Author = sprintf('Created: %s',datestr(datetime('now')));
            add(report,titlepg);
            
            %================================================
            
            append(report,TableOfContents); 
            
            %*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
            
            waitbar.Value = .4; 
            waitbar.Message = 'Generating the Preprocessing Report';
            pause(.5)
            
            % Add content to report sections (optional)
            % Text and formal image added to chapter
            chapter1 = Chapter('Data Preprocessing');
            
            sec1_1 = Section; 
            sec1_1.Title = 'About MSpec Preprocessing'; 
            para = Paragraph(['ใช้ฟังก์ชั่นอะไร ทำงานยังไง '... 
            'constructed from the integers 1 through N^2 '... 
            'with equal row, column, and diagonal sums.']); 
            append(sec1_1,para) 
            append(chapter1,sec1_1) 
            
            sec1_2 = Section; 
            sec1_2.Title = 'Parameters'; 
            % new line
            append(sec1_2,[newline]);
            
            concatTable = table(Parameter,Value);
            t = Table(concatTable);
            t.Style = {RowHeight('0.5in'),HAlign('center');};
            t.Border = 'solid';
            t.BorderWidth = '1px';
            t.ColSep = 'solid';
            t.ColSepWidth = '1';
            t.RowSep = 'solid';
            t.RowSepWidth = '1';

            % Set this property first to prevent overwriting alignment properties
            t.TableEntriesStyle = {FontFamily('Arial'),Width('3in'),Color('black')};
            t.TableEntriesHAlign = 'center';
            t.TableEntriesVAlign = 'middle';
            r = row(t,1);
            r.Style = [r.Style {Bold}];
            append(sec1_2,t) 
            
            append(chapter1,sec1_2) 
            
            sec1_3 = Section; 
            sec1_3.Title = 'Result'; 
            
            f1 = figure('visible','off');
            %plotting the raw data
            subplot(2,1,1,"Units","pixels");
            plot(project.RawData.RawMzValues, project.RawData.RawSpectraIntensities);
            xlim([project.RawData.MinIntensity project.RawData.MaxIntensity]);
            title('Raw Mass Spectra');

            % preprocessed
            subplot(2,1,2,"Units","pixels");
            plot(project.RawData.RawMzValues,project.PreprocessedData.BaselinedSpectra);
            xlim([project.PreprocessedData.SectionStart project.PreprocessedData.SectionEnd]);
            title('Preprocessed Mass Spectra');
            
            append(sec1_3,Figure(f1));
            
            append(chapter1,sec1_3) 
            %add(chap1,['Method: ',app.NormalizeMethod]);
            
            %*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
            waitbar.Value = .6; 
            waitbar.Message = 'Generating the Normalization Report';
            pause(.5)
            
            chapter2 = Chapter('Data Normalization');
            
            sec2_1 = Section; 
            sec2_1.Title = 'Normalization Method'; 
            
            %method = ['Method: ', ]
            
            append(sec2_1,para);

            append(chapter2,sec2_1) 
            
            %*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
            
            waitbar.Value = 0.9; 
            waitbar.Message = 'Finishing';
            pause(.5)
            
            append(report,chapter1);
            append(report,chapter2);

            % Close the report (required)
            close(report);
            
            waitbar.Value = 1; 
            waitbar.Message = 'Displaying the Report';
            pause(.5)
            
            % Display the report (optional)
            rptview(report);
            
            %close wait bar
            close(waitbar)
        end
    end
end

