classdef Preprocessing
    properties
    end
    
    methods (Static)
        function plotButtonPushedHandler(app)
            
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
        end
        
        
        function baselineCorrection(app)
            %alignment(app);
            baselined = msbackadj(app.CurrentProject.RawData.RawMzValues,transpose(app.CurrentProject.PreprocessedData.AlignedSpectra),'STEPSIZE', app.CurrentProject.PreprocessedData.StepSize, 'WINDOWSIZE', app.CurrentProject.PreprocessedData.WindowSize,'QuantileValue',app.CurrentProject.PreprocessedData.QuantileValue,'SmoothMethod','lowess');        
            baselined = max(baselined,0);
            app.CurrentProject.PreprocessedData.BaselinedSpectra = mslowess(app.CurrentProject.RawData.RawMzValues,baselined);
        end
        
        function alignment(app)
            sample = app.CurrentProject.RawData.RawSpectraIntensities;
            spectra = transpose(sample);
            reference = spectra(app.CurrentProject.PreprocessedData.ReferenceSpectrum,:);
            segSize = app.CurrentProject.PreprocessedData.SegmentSize;
            shift = app.CurrentProject.PreprocessedData.ShiftAllowance;
            
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
                        Preprocessing.findMin(app,samseg,refseg);
                        minpos = app.CurrentProject.PreprocessedData.MinPosition;
                        endpos = startpos+minpos+segSize;
                        samseg = spectra(i,startpos:endpos);
                        refseg = reference(1,startpos:endpos);
                    end
                    Preprocessing.FFTcorr(app,samseg,refseg,shift);
                    lag = app.CurrentProject.PreprocessedData.SegmentLag;
                    Preprocessing.move(app,samseg,lag);
                    aligned = [aligned app.CurrentProject.PreprocessedData.ShiftedSegment];
                    startpos=endpos+1;
                end
                app.CurrentProject.PreprocessedData.AlignedSpectra(i,:) = aligned;
            end
        end
        
        function FFTcorr(app,spectrum, target, shift)
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
            app.CurrentProject.PreprocessedData.SegmentLag = lag;
        end

        function move(app, seg, lag)
            
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
            app.CurrentProject.PreprocessedData.ShiftedSegment = movedSeg;
        end
        
        function findMin(app, samseg,refseg)
        
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
            app.CurrentProject.PreprocessedData.MinPosition = Is(1,1);
        end
        
    end
end

