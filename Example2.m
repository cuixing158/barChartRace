%% 全国房价
filename = './dataSets/主要城市年度数据 -住宅平均销售价格.csv';
inData = readmatrix(filename,'Range','B5:T39');
labelnames = readcell(filename,'Range','A5:A39');
timesStr = readcell(filename,'Range','B4:T4');
inData = fillmissing(inData,'linear',2,'EndValues','nearest');

% 整理成合适的格式
inData = fliplr(inData);
timesStr = fliplr(timesStr);
labels = categorical(labelnames);
h = barChartRace2(inData,...
    "TopK",10,...
    "Categories",labels,...
    "TimeLabels",timesStr,...
    "FramesPerDataTick",100,...
    "TitleLabel",'主要城市年度数据 -2001-2019年住宅平均销售价格（元/平米）',...
    "GenerateGIF",false);
