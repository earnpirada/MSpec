classdef DataImportExport
    
    properties
        Property1
    end
    
    methods (Static)
        function importData(app)
            fig = uifigure;
            d = uiprogressdlg(fig,'Title','Please Wait',...
                'Message','Opening the import window');
            pause(.5)
            [file, path] = uigetfile('*.csv');
            if isequal(file,0)
                % display error message
                msgbox('Please input CSV files')
                app.ImportStatusLabel.FontColor = [0.6902 0.2549 0.2549];
                app.ImportStatusLabel.Text = 'The file must be in .csv format';
                close(d)
                close(fig)
            else
                % Perform calculations
                % ...
                d.Value = .33; 
                d.Message = 'Loading your data';
                pause(1)
                % read data
                fileName = file;
                RawImportData = csvread(fullfile(path,file));
                % update field
                app.ImportStatusLabel.FontColor = [0.1333 0.4588 0.1137];
                app.ImportStatusLabel.Text = [fileName,' has been imported successfully !'];
            end
            
            % Perform calculations
            % ...
            d.Value = .67;
            d.Message = 'Processing the data';
            pause(1)
            
            RawMzValues=RawImportData(:,1);
            %[RowNumber,ColumnNumber]= size(RawImportData);
            [x,y] = size(RawImportData);
            RawSpectraIntensities=zeros(x,y);
            for i = 2:y
                RawSpectraIntensities(:,i)  = RawImportData(:,i);
            end
            RawSpectraIntensities(:,1)=[];
            % MinIntensity = min(RawMzValues);
            % MaxIntensity = max(RawMzValues);
            [m,n] = size(RawSpectraIntensities);
            NumberOfSpectra = n;
            
             
            % Finish calculations
            % ...
            d.Value = 1;
            d.Message = 'Finishing';
            pause(1)
            
            importedMSData = MSData(RawImportData,RawMzValues,RawSpectraIntensities,NumberOfSpectra);

            % Close dialog box
            close(d)
            close(fig)
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end