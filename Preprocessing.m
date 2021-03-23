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
        
        
        
        %================Data Normalization==========
        
        function updateNormalizedSpectra(app)
            % Data Normalization
                
            NormalizedSpectra = transpose(app.CurrentProject.PreprocessedData.AlignedSpectra);
            numberOfSpectra = app.CurrentProject.RawData.NumberOfSpectra;
            [x,y] = size(app.CurrentProject.RawData.RawSpectraIntensities);
            sprintf('Raw x: %d, y: %d',x,y)
            [x,y] = size(app.CurrentProject.PreprocessedData.NormalizedSpectra);
            sprintf('Normalized x: %d, y: %d',x,y)
            sprintf(' %d',NormalizedSpectra)

            switch app.CurrentProject.PreprocessedData.NormalizeMethod % Get Tag of selected object.
                case 'Sum'
                    for j = 1:numberOfSpectra
                        colj = NormalizedSpectra(:,j);
                        NormalizedSpectra(:, j) = NormalizedSpectra(:, j)./sum(colj);
                    end
                 case 'Area'
                    for j = 1:numberOfSpectra
                        colj = NormalizedSpectra(:,j);
                        NormalizedSpectra(:, j) = NormalizedSpectra(:, j)./trapz(app.CurrentProject.RawData.RawMzValues, colj);
                    end
                 case 'Norm'
                    for j = 1:numberOfSpectra
                        factor = norm(NormalizedSpectra(:,j),app.CurrentProject.PreprocessedData.NormalizationNormValue);
                        NormalizedSpectra(:, j) = NormalizedSpectra(:, j)./factor;
                    end
                 case 'Median'
                     for j = 1:numberOfSpectra
                        factor = median(NormalizedSpectra(:,j));
                        NormalizedSpectra(:, j) = NormalizedSpectra(:, j)./factor;
                     end
                 case 'Noise'
                    for j = 1:numberOfSpectra
                        % Noise Level
                        DifVector = diff(NormalizedSpectra(:,j));
                        % universal thresholding
                        MedOfDif = median(DifVector);
                        e = abs(DifVector-MedOfDif);
                        factor = median(e);
                        NormalizedSpectra(:, j) = NormalizedSpectra(:, j)./factor;
                    end
                 otherwise %peak
                    for j = 1:numberOfSpectra
                        ref = NormalizedSpectra(app.CurrentProject.PreprocessedData.ReferencePeak,j);
                        NormalizedSpectra(:, j) = NormalizedSpectra(:, j)./ref;
                    end
            end
            app.CurrentProject.PreprocessedData.NormalizedSpectra = NormalizedSpectra;
        end
        
        %===========Peak Detection=================
        
        function peakDetection(app)
            if (app.CurrentProject.PreprocessedData.IsAutoDetected)
                app.CurrentProject.PreprocessedData.DetectedPeak = mspeaks(app.CurrentProject.RawData.RawMzValues,app.CurrentProject.PreprocessedData.NormalizedSpectra);
            else
                app.CurrentProject.PreprocessedData.DetectedPeak = mspeaks(app.CurrentProject.RawData.RawMzValues,app.CurrentProject.PreprocessedData.NormalizedSpectra,'DENOISING',true,'BASE',app.CurrentProject.PreprocessedData.Base,'MULTIPLIER',app.CurrentProject.PreprocessedData.Multiplier,'HEIGHTFILTER',app.CurrentProject.PreprocessedData.HeightFilter);
            end
            app.CurrentProject.PreprocessedData.CutThresholdPeak = cellfun(@(p) p(p(:,1)>app.CurrentProject.PreprocessedData.PeakThreshold,:),app.CurrentProject.PreprocessedData.DetectedPeak,'Uniform',false); 
        end
        
        %==========Binning==========================
        
        function peakBinning_Hierachical(app)
            %Put all the peaks into a single array and construct a vector with the spectrogram index for each peak.

            allPeaks = cell2mat(app.CurrentProject.PreprocessedData.CutThresholdPeak);
            numPeaks = cellfun(@(x) length(x),app.CurrentProject.PreprocessedData.CutThresholdPeak);
            Sidx = accumarray(cumsum(numPeaks),1);
            Sidx = cumsum(Sidx)-Sidx;
            
            %Create a custom distance function that penalizes clusters containing peaks from the same spectrogram, then perform hierarchical clustering.

            distfun = @(x,y) (x(:,1)-y(:,1)).^2 + (x(:,2)==y(:,2))*10^6;

            tree = linkage(pdist([allPeaks(:,1),Sidx],distfun));
            clusters = cluster(tree,'CUTOFF',app.CurrentProject.PreprocessedData.Cutoff,'CRITERION','Distance');
            
            %The common mass/charge reference vector (CMZ) is found by calculating the centroids for each cluster.
            CMZ = accumarray(clusters,prod(allPeaks,2))./accumarray(clusters,allPeaks(:,2));
            
            % Similarly, the maximum peak intensity of every cluster is also computed.

            PR = accumarray(clusters,allPeaks(:,2),[],@max);
            [CMZ,h] = sort(CMZ);
            PR = PR(h);
            
            cla(app.Binning_PeakBinningPlot);
            app.Binning_PeakBinningPlot.XLim = [app.CurrentProject.RawData.MinIntensity app.CurrentProject.RawData.MaxIntensity];
            
            if isempty(app.Detection_SpectrumtodisplayEditField.Value)
                hold(app.Binning_PeakBinningPlot,"on");
                box(app.Binning_PeakBinningPlot,"on");
                for i=1:length(CMZ)
                    %plot(app.Binning_PeakBinningPlot,[CMZ CMZ],[-100 inf],'-k');
                    xline(app.Binning_PeakBinningPlot,CMZ(i),'k');
                end
                plot(app.Binning_PeakBinningPlot,app.CurrentProject.RawData.RawMzValues,app.CurrentProject.PreprocessedData.NormalizedSpectra)
            else
                index = str2num(app.Detection_SpectrumtodisplayEditField.Value);
                hold(app.Binning_PeakBinningPlot,"on");
                box(app.Binning_PeakBinningPlot,"on");
                for i=1:length(CMZ)
                    %plot(app.Binning_PeakBinningPlot,[CMZ CMZ],[-100 inf],'-k');
                    xline(app.Binning_PeakBinningPlot,CMZ(i),'k');
                end
                plot(app.Binning_PeakBinningPlot,app.CurrentProject.RawData.RawMzValues,app.CurrentProject.PreprocessedData.NormalizedSpectra(:,index))
            end
            
            app.CurrentProject.PreprocessedData.CMZ = CMZ;
            app.CurrentProject.PreprocessedData.PR = PR;

        end
        
        
        function peakBinning_Dynamic(app)
            currentCMZ = app.CurrentProject.PreprocessedData.CMZ;
            num = app.CurrentProject.RawData.NumberOfSpectra;
            PA = nan(numel(currentCMZ),num);
            DetectedSpectra = app.CurrentProject.PreprocessedData.CutThresholdPeak;
            for i = 1:num
                [j,k] = samplealign([currentCMZ app.CurrentProject.PreprocessedData.PR],DetectedSpectra{i},'BAND',15,'WEIGHTS',[1 .1]);
                %[j,k] = samplealign([currentCMZ app.CurrentProject.PreprocessedData.PR],DetectedSpectra{i});
                PA(j,i) = DetectedSpectra{i}(k,2);
            end

            cla(app.Binning_AlignedPeakBinningPlot);
            app.Binning_AlignedPeakBinningPlot.XLim = [app.CurrentProject.RawData.MinIntensity app.CurrentProject.RawData.MaxIntensity];
            
            if isempty(app.Detection_SpectrumtodisplayEditField.Value)
                hold (app.Binning_AlignedPeakBinningPlot, "on");
                box (app.Binning_AlignedPeakBinningPlot, "on");
                for i=1:length(currentCMZ)
                    xline(app.Binning_AlignedPeakBinningPlot,currentCMZ(i),'k');
                end
                plot(app.Binning_AlignedPeakBinningPlot,app.CurrentProject.RawData.RawMzValues,app.CurrentProject.PreprocessedData.NormalizedSpectra)
                plot(app.Binning_AlignedPeakBinningPlot,currentCMZ,PA,'o')
            else
                index = str2num(app.Detection_SpectrumtodisplayEditField.Value);
                hold (app.Binning_AlignedPeakBinningPlot, "on");
                box (app.Binning_AlignedPeakBinningPlot, "on");
                for i=1:length(currentCMZ)
                    xline(app.Binning_AlignedPeakBinningPlot,currentCMZ(i),'k');
                end
                plot(app.Binning_AlignedPeakBinningPlot,app.CurrentProject.RawData.RawMzValues,app.CurrentProject.PreprocessedData.NormalizedSpectra(:,index))
                plot(app.Binning_AlignedPeakBinningPlot,currentCMZ,PA(:,index),'o')
            end
            
            sprintf("%d ",PA)
            app.CurrentProject.PreprocessedData.AlignedDetectedPeak = PA;
        end
        
        function startPeakBinning(app)
            
            method = app.Binning_BinningMethod.Value;
            maxPeaks = app.Binning_NumberofBinsSpinner.Value;
            tolerance = app.Binning_ToleranceEditField.Value;
            edgeList = generateBins(app.CurrentProject.PreprocessedData.CMZ, maxPeaks, tolerance, method);
            app.CurrentProject.PreprocessedData.EdgeList = edgeList;
            
            binnedData = generateBinsFromEdges(edgeList, app.CurrentProject.RawData.RawMzValues, app.CurrentProject.PreprocessedData.NormalizedSpectra);
            
            app.CurrentProject.PreprocessedData.BinIndexList = binnedData(:,1);
            binnedData(:,1) = [];

            app.CurrentProject.PreprocessedData.BinnedSpectra = binnedData;

            sprintf(" %d",app.CurrentProject.PreprocessedData.BinnedSpectra)
            
        end
                
    end
end

