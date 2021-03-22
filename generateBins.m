function edgeList = generateBins(commonMZ, maxPeaks, tolerance, method)
    if (checkTolerance(commonMZ,tolerance)) && (size(commonMZ) <= maxPeaks )
    	edgeList = []; 
    else
        edgeList = [];
        difList =  diff(commonMZ);
        maxDif = max( difList(difList>=0));
        index = find(difList==maxDif);
        % divide list by half and append new edge
        edgeList(end+1) = commonMZ(index(1))+ (maxDif/2);
        leftSubList = commonMZ(1:index);
        rightSubList = commonMZ(index+1:end);
        leftEdgeList = generateBins(leftSubList,maxPeaks, tolerance, method);
        rightEdgeList = generateBins(rightSubList,maxPeaks, tolerance, method);
        
        %for i = 1:size(leftEdgeList)
            %edgeList(end+1) = leftEdgeList(i);
        %end
        %for j = 1:size(rightEdgeList)
            %edgeList(end+1) = rightEdgeList(j);
        %end
        edgeList = cat(2,edgeList,leftEdgeList);
        edgeList = cat(2,edgeList,rightEdgeList);
        edgeList = sort(edgeList);
        
        hAxes = axes('NextPlot','add',...           %# Add subsequent plots to the axes,
             'DataAspectRatio',[1 1 1],...  %#   match the scaling of each axis,
             'XLim',[10 40],...               %#   set the x axis limit,
             'YLim',[0 eps],...             %#   set the y axis limit (tiny!),
             'Color','none');               %#   and don't use a background color
        plot(commonMZ,0,'r*','MarkerSize',10);  %# Plot data set 1
        plot(edgeList,0,'b.','MarkerSize',10);  %# Plot data set 2
    end
end

function isBin = checkTolerance(Peaklist,tolerance)
    isBin = true;
    meanMass = mean(Peaklist);
    for i=1:size(Peaklist)
        threshold = (abs(Peaklist(i)-meanMass)/meanMass);
        if threshold > tolerance
            isBin = false;
        end
    end
end

