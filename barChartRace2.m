function hBarObject = barChartRace2(inData,options)
% 功能：实现随时间动态排序的bar分布,每种颜色对应唯一的类别不变,支持topk排序
%Matlab 2020b and higher versions apply!
%
% inputs:
% inData(i,j); value of i-th index at j-th time instance
%   All values in this matrix are assumed to be positive
%
% output:
% hObject： barObject对象句柄.
%
% Example:
%        inData = rand(10,50);% 10 categories with a time series length of 50
%        barChartRace2(inData);
%
% author:cuixingxing
% Email: cuixingxing150@gmail.com
% 2021.7.13
%
arguments
    inData {mustBeNonnegative}
    options.TopK (1,1) {mustBeInteger,mustBePositive} = min(size(inData,1),5);
    options.Categories (1,:) categorical = categorical("categorical:"+string(1:size(inData)));% Number equal to the number of inData rows
    options.FramesPerDataTick {mustBeInteger,mustBePositive} = 24; % Number of frames in transition on a single time step
    options.GenerateGIF (1,1) {mustBeNumericOrLogical} = false
    options.TimeLabels (1,:) string = ""
end
[numClasses,timeSerials,numChannels] = size(inData);
assert(numClasses>1,'inData must have mulity rows');
assert(timeSerials>1,'inData must have mulity coloums');
assert(numChannels==1,'inData must be 2 dims');

%% global set
figure('name','barChartRace','Color','white');
colors = rand(numClasses,3);% 每个类别颜色固定, RGB顺序，[0,1]范围各个强度
initCategories = options.Categories;% 颜色与此类别一一固定对应
%% update
previousCategories = initCategories;
previousState = inData(:,1);
[currentState,ind] = sort(previousState,'descend');
currentCategories = previousCategories(ind);
x = 1:options.TopK;
y = currentState(1:options.TopK);
topKYlabels = currentCategories(1:options.TopK);
colorIdxs = arrayfun(@(x)find(initCategories==x),topKYlabels);
topKColors = colors(colorIdxs,:);
ax = axes;
hBarObject = barh(ax,x,y,'FaceColor','flat','CData',topKColors);
hText = text(ax,y,x,string(y),'FontWeight','bold');
if strlength(options.TimeLabels)
    hTimeText = text(ax,max(y),options.TopK,options.TimeLabels(1),...
        'FontWeight','bold',...
        'FontSize',25);
end
yrange = ylim;
set(gca,'YTick',x,'YTickLabel',topKYlabels,...
    'YDir','reverse','YLim',yrange,'XLim',[0,1.2*max(y)],'XGrid','on',...
    'FontWeight','bold');
title(ax,"top "+options.TopK+ " Race!")

for time = 2:timeSerials
    previousState = currentState;
    previousCategories = currentCategories;
    
    data = inData(:,time);
    [currentState,ind] = sort(data,'descend');
    currentCategories = initCategories(ind);
    idxs = arrayfun(@(x)find(currentCategories==x),previousCategories);
    deltaXState = idxs(:)-(1:numClasses)';
    deltaX = deltaXState./options.FramesPerDataTick;
    deltaYState = currentState(idxs)-previousState;
    deltaY = deltaYState./options.FramesPerDataTick;
    for deltime = 1:options.FramesPerDataTick
        currentXState = (1:numClasses)'+ deltime.*deltaX;
        currentYState = previousState+deltime.*deltaY;
        
        [currentDYState,ind1] = sort(currentYState,'descend');
        [currentDXState,ind2] = sort(currentXState);%currentXState(ind);
        currentDCategories = previousCategories(ind1);
        x = currentDXState(1:options.TopK);
        y = currentDYState(1:options.TopK);
        topKYlabels = currentDCategories(1:options.TopK);
        colorIdxs = arrayfun(@(x)find(initCategories==x),topKYlabels);
        topKColors = colors(colorIdxs,:);
        bwidth = min(diff(x));
        if bwidth>0.05
            hBarObject.XData = x;
            hBarObject.YData = y;
            hBarObject.BarWidth = 0.8/bwidth;
            hBarObject.CData = topKColors;
            set(gca,'YTick',x,'YTickLabel',topKYlabels,...
                'XLim',[0,1.2*max(y)]);
            for ann = 1:options.TopK
                hText(ann).Position = [y(ann),x(ann)];
                hText(ann).String = string(y(ann));
            end
        end
        if strlength(options.TimeLabels)
            hTimeText.Position = [max(y),options.TopK];
            hTimeText.String = options.TimeLabels(time);
        end
        if options.GenerateGIF
            frame = getframe(gcf); 
            tmp = frame2im(frame); 
            [A,map] = rgb2ind(tmp,256); 
            if time == 2 && deltime==1
                imwrite(A,map,'output.gif','gif','LoopCount',Inf,'DelayTime',0.5);
            else 
                imwrite(A,map,'output.gif','gif','WriteMode','append','DelayTime',1/options.FramesPerDataTick);
            end
        end
        drawnow;
    end
end
end