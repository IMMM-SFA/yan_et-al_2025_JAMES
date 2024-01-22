
clear all; clc

% view the CONUS map to make sure the gscd conus regression works

lat = load('lat_2d');
lon = load('lon_2d');
data = readtable('./CONUS_clustering_id.csv');
data = sortrows(data,[4,5]);
cluster_id = data.clustering_7;
class_maxtri = nan(224, 464);
lat_index = data.Lat_index;
lon_index = data.Lon_index;

sim = readtable('../gscd_conus_regression/qmean.csv');
sim = sortrows(sim,[2,3]);
sim = sim.V8;
class_maxtri = nan(224, 464);
for i = 1:length(cluster_id)
      class_maxtri(lat_index(i),lon_index(i)) = sim(i);
end

subplot(2,1,1)
pcolor(lon, lat, class_maxtri); hold on; shading flat;
caxis([0,5])




obs = readtable('../gscd_CONUS_land_cell.csv');
obs = sortrows(obs, [2,3]);
obs = obs.qmean_mm_yr/365;
class_maxtri = nan(224, 464);
for i = 1:length(cluster_id)
      class_maxtri(lat_index(i),lon_index(i)) = obs(i);
end

subplot(2,1,2)
pcolor(lon, lat, class_maxtri); hold on; shading flat;
caxis([0,5])













%% find defualt CONUS
clear all; clc;

US = load('us_coor.txt');
SL = load('sl_coor.txt');
scatter_size = 20; label_size = 10; legend_size = 10; tick_size = 10; colorbar_size= 10;title_size = 12; line_width = 1; text_size = 10;

lat = load('lat_2d');
lon = load('lon_2d');
data = readtable('./CONUS_clustering_id.csv');
data = sortrows(data,[4,5]);

cluster_id = data.clustering_7;

class_maxtri = nan(224, 464);
lat_index = data.Lat_index;
lon_index = data.Lon_index;

default_sim = load('../default_sim/qmean');


%% find defualt CAMELS
temp = readtable('../../ensemble_sim/default_sim1.csv');
out_default = nan(464,7); %1-gauge id, 2-lat, 3-lon, 4-cluster id,, 5-q10_mm_d, 6-q90_mm_d, 7-qmean_mm_d
out_default(:,1) = temp.Gauge_ID;
out_default(:,2) = temp.Gauge_Lat;
out_default(:,3) = temp.Gauge_Lon;
out_default(:,4) = temp.Cluster;
out_default(:,5) = temp.q10_mm_d;
out_default(:,6) = temp.q90_mm_d;
out_default(:,7) = temp.qmean_mm_d;
out_default = sortrows(out_default, 1);
clear temp;
camel_default = out_default(:,7); 
basin_lat = out_default(:,2);
basin_lon = out_default(:,3);

%% find hybrid GSCD regression constrain

lat = load('lat_2d');
lon = load('lon_2d');
data = readtable('./CONUS_clustering_id.csv');
data = sortrows(data,[4,5]);

cluster_id = data.clustering_7;

class_maxtri = nan(224, 464);
lat_index = data.Lat_index;
lon_index = data.Lon_index;


para = load('../../conus_ensemble_sim/parameter_ensemble_LHS700');
para_id_350 = load('../../conus_ensemble_sim/succ_id_350');  % 1-700
para_id_400 = load('../../conus_ensemble_sim/succ_id_400');  % 1-700

ensemble_qmean_400 = load('../../conus_ensemble_sim/Vol_Annual');
ensemble_qmean_350 = nan(350, 50629);

count = 1;
for i = 1:400
    isValueInArray = ismember(para_id_400(i), para_id_350);
    if isValueInArray
        ensemble_qmean_350(count,:) = ensemble_qmean_400(i,:);
        count = count + 1;
    end
end
clear ensemble_qmean_400;

para_qmean = load('conus_regional_id_350_qmean.txt');




% find GSCD regression
temp = readtable('../gscd_conus_regression/qmean.csv');
var = nan(50629, 4); %1-lat, 2-lon, 3-low, 4-up   V4 V5 (95 CI),  V6 V7 (95 PI)
var(:,1) = temp.V2;
var(:,2) = temp.V3;
var(:,3) = temp.V6;
var(:,4) = temp.V7;
var = sortrows(var,[1,2]);

out_para_regression = nan(50629, 350);  % para id from 1-700
out_sim_regression  = nan(50629, 350);  

for i = 1:50629
    low = var(i,3);
    up  = var(i,4);
    indices = find(ensemble_qmean_350(:,i) > low & ensemble_qmean_350(:,i) < up);  % 1- 350

    % 1) full constrain
    if length(indices)>=10
        for j = 1:length(indices)
            out_sim_regression(i,j) = ensemble_qmean_350(indices(j),i);
            out_para_regression(i,j) = para_id_350(indices(j));
        end
    end

    % 2) if no constrain, use top 10 members
    if length(indices)==0
        temp2 = nan(10,1);
        for k = 1:7
            if cluster_id(i)==k
                par_id = para_qmean(k,2:21);
                for j = 1:10
                    out_sim_regression(i,j) = ensemble_qmean_350(par_id(j),i);
                    out_para_regression(i,j) = para_id_350(par_id(j));  % 1-700
                end
            end
        end
        
    end


    % 3) between 1- 10 parameters
    if length(indices)>0 && length(indices)<10
        temp2 = nan(10, 1);
        for j = 1:length(indices)
            out_sim_regression(i,j) = ensemble_qmean_350(indices(j),i);
            out_para_regression(i,j) = para_id_350(indices(j));  % 1-700
        end       
        
        need_num = 10 - length(indices);
        count1 = length(indices)+1;

        for k = 1:7
            if cluster_id(i)==k
                par_id = para_qmean(k,2:21);

                for j = 1:20
                    if ismember(par_id(j), indices)
                        continue
                    else
                        out_sim_regression(i,count1) = ensemble_qmean_350(par_id(j),i);
                        out_para_regression(i,count1) = para_id_350(par_id(j));  % 1-700
                        count1 = count1 + 1;
                        if count1 == 11
                            break
                        end
                    end
                end
            end
        end
    end


end




%% find CAMELS basin regression

para_q10   = load('camel_regional_id_1000_q10.txt');
para_q90   = load('camel_regional_id_1000_q90.txt');
para_qmean = load('camel_regional_id_1000_qmean.txt');

par1000 = load('./sucessful_par_id_1000');
par1307 = load('./sucessful_par_id_1307');
index1000 = ismember(par1307, par1000);

var = nan(464, 10); % 1-gauge id, 2-lat, 3-lon, 4-cluster id, 5-q10 low, 6-q_10 up, 7-q90 low, 8-q90 up, 9-qmean low, 10-qmean up

temp = readtable('../gscd_camel_regression/q10.csv');
var(:,1)  = temp.V1;
var(:,2)  = temp.V3;
var(:,3)  = temp.V4;
var(:,4)  = temp.V2;
var(:,5)  = temp.V7;
var(:,6)  = temp.V8;
temp = readtable('../gscd_camel_regression/q90.csv');
var(:,7)  = temp.V7;
var(:,8)  = temp.V8;
temp = readtable('../gscd_camel_regression/qmean.csv');
var(:,9)  = temp.V7;
var(:,10)  = temp.V8;
var = sortrows(var,1);
out_qmean_metric = nan(464, 10); 

temp = readtable('../../ensemble_sim/ensemble_qmean');
temp = sortrows(temp,1);
for i = 1:464
    temp1 = table2array(temp(i, 5:end));
        temp1 = temp1(index1000);
    low = var(i,9);
    up  = var(i,10);
    indices = find(temp1 > low & temp1 < up);  % 1- 350

    % 1) use full constrain members
    if length(indices)>=10 
        temp2 = nan(length(indices), 1);
        for j = 1:length(indices)
            temp2(j,1) = temp1(indices(j));
        end
%         out_qmean_metric(i,9) = 1 - crps(temp2, out_obs(i,7)) / abs(out_default(i,7) - out_obs(i,7)); 
%         out_qmean_metric(i,9) = mean(temp2) - out_obs(i,7);
        out_qmean_metric(i,9) = mean(temp2) - out_default(i,7);
        out_qmean_metric(i,10) = std(temp2)/mean(temp2);
        
    end
    
    % 2) if no constrain, use the top 10 members 
    if length(indices)==0
        temp2 = nan(10,1);
        
        for k = 1:7
            if cluster_id(i)==k
                par_id = para_qmean(k,2:21);
                for j = 1:10
                    temp2(j,1) = temp1(par_id(j));
                end
            end
        end
%         out_qmean_metric(i,9) = 1 - crps(temp2, out_obs(i,7)) / abs(out_default(i,7) - out_obs(i,7)); 
%         out_qmean_metric(i,9) = mean(temp2) - out_obs(i,7);
        out_qmean_metric(i,9) = mean(temp2) - out_default(i,7);
        out_qmean_metric(i,10) = std(temp2)/mean(temp2);
    end

    % 3) mixed with constain but no 10 parameters 
    if length(indices)>0 && length(indices)<10
        temp2 = nan(10, 1);
        for j = 1:length(indices)
            temp2(j,1) = temp1(indices(j));
        end       
        
        need_num = 10 - length(indices);
        count1 = length(indices)+1;

        
        for k = 1:7
            if cluster_id(i)==k
                par_id = para_qmean(k,2:21);

                for j = 1:20
                    if ismember(par_id(j), indices)
                        continue
                    else
                        temp2(count1,1) = temp1(par_id(j));
                        count1 = count1 + 1;
                        if count1 == 11
                            break
                        end
                    end
                end
            end
        end
%         out_qmean_metric(i,9) = 1 - crps(temp2, out_obs(i,7)) / abs(out_default(i,7) - out_obs(i,7)); 
%         out_qmean_metric(i,9) = mean(temp2) - out_obs(i,7);
        out_qmean_metric(i,9) = mean(temp2) - out_default(i,7);
        out_qmean_metric(i,10) = std(temp2)/mean(temp2);
    end


%     if length(indices)>=1
%         temp2 = nan(length(indices), 1);
%         for j = 1:length(indices)
%             temp2(j,1) = abs(temp1(indices(j)) - out_obs(i,7));
%         end
%         out_qmean_metric(i,9) = mean(temp2);
%     end
%     if length(indices)>=2
%         out_qmean_metric(i,10) = std(temp2);
%     end

end








%%  plot the ensemble output

figure;
scatter_size = 20; label_size = 11; legend_size = 11; tick_size = 11; colorbar_size= 11;title_size = 10; line_width = 1; text_size = 9;

% defualt parameter --------------------------------------------------------
ax(1) = subplot(3,2,1)
metric_daily = camel_default;
scatter(basin_lon, basin_lat, scatter_size, metric_daily, 'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on; 
grid on;
set(gca, 'GridLineStyle', ':');

set(gca,'FontSize',tick_size);

plot(US(:,1), US(:,2),'.','MarkerSize',2,'Color','black'); hold on; 
plot(SL(:,1), SL(:,2),'.','MarkerSize',2,'Color','black'); hold on; 
xlim([-128 -64]); ylim([23 52]); box on;


xticks = [-120,-110,-100,-90,-80, -70];
xticklabels_deg = cell(size(xticks));
for i = 1:numel(xticks)
    xticklabels_deg{i} = [num2str(-xticks(i)) '°W'];
end
set(gca, 'XTick', xticks);
set(gca, 'XTickLabel', xticklabels_deg);
set(gca, 'XTickLabel', []);

yticks = [25, 30, 35, 40, 45, 50];
yticklabels_deg = cell(size(yticks));
for i = 1:numel(yticks)
    yticklabels_deg{i} = [num2str(yticks(i)) '°N'];
end
set(gca, 'YTick', yticks);
set(gca, 'YTickLabel', yticklabels_deg);


% cmin = min(metric_daily)-0.2;
% cmax = max(metric_daily)+0.2;

colormap(ax(1), brewermap([],'*Spectral'));   
colorbar
caxis([0 5]); 
title('(a1) Qmean (mm/d): Default Parameter', 'FontSize', title_size);
set(gca,'FontSize',tick_size);


ax(2) = subplot(3,2,2)
class_maxtri = nan(224, 464);
for i = 1:length(cluster_id)
      class_maxtri(lat_index(i),lon_index(i)) = default_sim(i);
end
pcolor(lon, lat, class_maxtri); hold on; shading flat;
baseline = class_maxtri;
cmin = 0; cmax = 5; 
caxis([cmin cmax]);  
plot(US(:,1), US(:,2),'.','MarkerSize',2,'Color','black'); hold on;  grid on;
set(gca, 'GridLineStyle', ':');
% text(0.02, 0.15, '(a)', 'FontSize',text_size, 'FontWeight', 'bold', 'Units','Normalized');

colormap(ax(2), brewermap([],'*Spectral'));  
title('(b1) Qmean (mm/d): Default Parameter', 'FontSize', title_size);
xticks = [-120,-110,-100,-90,-80, -70];
xticklabels_deg = cell(size(xticks));
for i = 1:numel(xticks)
    xticklabels_deg{i} = [num2str(-xticks(i)) '°W'];
end
set(gca, 'XTick', xticks);
set(gca, 'XTickLabel', xticklabels_deg);
set(gca, 'XTickLabel', []);

yticks = [25, 30, 35, 40, 45, 50];
yticklabels_deg = cell(size(yticks));
for i = 1:numel(yticks)
    yticklabels_deg{i} = [num2str(yticks(i)) '°N'];
end
set(gca, 'YTick', yticks);
set(gca, 'YTickLabel', yticklabels_deg);
set(gca, 'XTickLabel', []);
set(gca, 'YTickLabel', []);
colorbar
% set(gca, 'Color', [200 200 200]/255);
set(gca,'FontSize',tick_size);
xlim([-128 -64]); ylim([23 52]); box on;





ax(3) = subplot(3,2,3)
metric_daily = out_qmean_metric(:,9);
scatter(basin_lon, basin_lat, scatter_size, metric_daily, 'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on; 
grid on;
set(gca, 'GridLineStyle', ':');

set(gca,'FontSize',tick_size);

plot(US(:,1), US(:,2),'.','MarkerSize',2,'Color','black'); hold on; 
plot(SL(:,1), SL(:,2),'.','MarkerSize',2,'Color','black'); hold on; 
xlim([-128 -64]); ylim([23 52]); box on;


xticks = [-120,-110,-100,-90,-80, -70];
xticklabels_deg = cell(size(xticks));
for i = 1:numel(xticks)
    xticklabels_deg{i} = [num2str(-xticks(i)) '°W'];
end
set(gca, 'XTick', xticks);
set(gca, 'XTickLabel', xticklabels_deg);
set(gca, 'XTickLabel', []);

yticks = [25, 30, 35, 40, 45, 50];
yticklabels_deg = cell(size(yticks));
for i = 1:numel(yticks)
    yticklabels_deg{i} = [num2str(yticks(i)) '°N'];
end
set(gca, 'YTick', yticks);
set(gca, 'YTickLabel', yticklabels_deg);


% cmin = min(metric_daily)-0.2;
% cmax = max(metric_daily)+0.2;

colormap(ax(3), brewermap([],'*RdBu'));   
colorbar
caxis([-0.6 0.6]); 
title('(a2) Qmean (mm/d): Hybrid (Mean) − Default Parameter', 'FontSize', title_size);
set(gca,'FontSize',tick_size);





ax(4) = subplot(3,2,4)
class_maxtri = nan(224, 464);
for i = 1:length(cluster_id)
    temp = out_sim_regression(i,:); temp = temp(~isnan(temp));
    temp1 = temp;
    if length(temp)>=1
        class_maxtri(lat_index(i),lon_index(i)) = mean(temp1);
    else
        class_maxtri(lat_index(i),lon_index(i)) = nan;
    end
end


pcolor(lon, lat, class_maxtri-baseline); hold on; shading flat;
% colorbar
% title('{\it fff} (1/m)', 'FontSize', title_size);
plot(US(:,1), US(:,2),'.','MarkerSize',2,'Color','black'); hold on;  grid on;
set(gca, 'GridLineStyle', ':');
% ylabel('Latitude (\circ)', 'FontSize', label_size); 
% xlabel('Longitude (\circ)', 'FontSize', label_size); 



xticks = [-120,-110,-100,-90,-80, -70];
xticklabels_deg = cell(size(xticks));
for i = 1:numel(xticks)
    xticklabels_deg{i} = [num2str(-xticks(i)) '°W'];
end
set(gca, 'XTick', xticks);
set(gca, 'XTickLabel', xticklabels_deg);

yticks = [25, 30, 35, 40, 45, 50];
yticklabels_deg = cell(size(yticks));
for i = 1:numel(yticks)
    yticklabels_deg{i} = [num2str(yticks(i)) '°N'];
end
set(gca, 'YTick', yticks);
set(gca, 'YTickLabel', yticklabels_deg);
set(gca, 'XTickLabel', xticklabels_deg);
xlim([-128 -64]); ylim([23 52]); box on;

%  
colormap(ax(4), brewermap([],'*RdBu'));  
% colorbar_arrow
% cmap = colormap;
% grayColor = [100 100 100]/255;
% cmap(1, :) = grayColor;
% colormap(cmap);
cmin = -0.6; cmax = 0.6; 
caxis([cmin cmax]);  
colorbar
title('(b2) Qmean (mm/d): Hybrid (Mean) − Default Parameter', 'FontSize', title_size);
set(gca, 'XTickLabel', []);
set(gca, 'YTickLabel', []);
set(gca,'FontSize',tick_size);






ax(5) = subplot(3,2,5)
metric_daily = out_qmean_metric(:,10);
scatter(basin_lon, basin_lat, scatter_size, metric_daily, 'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on; 
grid on;
set(gca, 'GridLineStyle', ':');

set(gca,'FontSize',tick_size);

plot(US(:,1), US(:,2),'.','MarkerSize',2,'Color','black'); hold on; 
plot(SL(:,1), SL(:,2),'.','MarkerSize',2,'Color','black'); hold on; 
xlim([-128 -64]); ylim([23 52]); box on;


xticks = [-120,-110,-100,-90,-80, -70];
xticklabels_deg = cell(size(xticks));
for i = 1:numel(xticks)
    xticklabels_deg{i} = [num2str(-xticks(i)) '°W'];
end
set(gca, 'XTick', xticks);
set(gca, 'XTickLabel', xticklabels_deg);
% set(gca, 'XTickLabel', []);

yticks = [25, 30, 35, 40, 45, 50];
yticklabels_deg = cell(size(yticks));
for i = 1:numel(yticks)
    yticklabels_deg{i} = [num2str(yticks(i)) '°N'];
end
set(gca, 'YTick', yticks);
set(gca, 'YTickLabel', yticklabels_deg);


% cmin = min(metric_daily)-0.2;
% cmax = max(metric_daily)+0.2;

colormap(ax(5), brewermap([],'*Spectral'));   
colorbar
caxis([0 2]); 
title('(a3) CV of Qmean: Hybrid', 'FontSize', title_size);
set(gca,'FontSize',tick_size);





ax(6) = subplot(3,2,6)
class_maxtri = nan(224, 464);
for i = 1:length(cluster_id)
    temp = out_sim_regression(i,:); temp = temp(~isnan(temp));
    temp1 = temp;
    if length(temp)>=1
        class_maxtri(lat_index(i),lon_index(i)) = std(temp1)/mean(temp1);
    else
        class_maxtri(lat_index(i),lon_index(i)) = nan;
    end
end


pcolor(lon, lat, class_maxtri); hold on; shading flat;
% colorbar
% title('{\it fff} (1/m)', 'FontSize', title_size);
plot(US(:,1), US(:,2),'.','MarkerSize',2,'Color','black'); hold on;  grid on;
set(gca, 'GridLineStyle', ':');
% ylabel('Latitude (\circ)', 'FontSize', label_size); 
% xlabel('Longitude (\circ)', 'FontSize', label_size); 

xticks = [-120,-110,-100,-90,-80, -70];
xticklabels_deg = cell(size(xticks));
for i = 1:numel(xticks)
    xticklabels_deg{i} = [num2str(-xticks(i)) '°W'];
end
set(gca, 'XTick', xticks);
set(gca, 'XTickLabel', xticklabels_deg);

yticks = [25, 30, 35, 40, 45, 50];
yticklabels_deg = cell(size(yticks));
for i = 1:numel(yticks)
    yticklabels_deg{i} = [num2str(yticks(i)) '°N'];
end
set(gca, 'YTick', yticks);
set(gca, 'YTickLabel', yticklabels_deg);
set(gca, 'XTickLabel', xticklabels_deg);


%  
colormap(ax(6), brewermap([],'*Spectral'));  
% colorbar_arrow
% cmap = colormap;
% grayColor = [100 100 100]/255;
% cmap(1, :) = grayColor;
% colormap(cmap);
cmin = 0; cmax = 0.6; 
caxis([0 2]); 
colorbar
title('(b3) CV of Qmean: Hybrid', 'FontSize', title_size);
% set(gca, 'XTickLabel', []);
set(gca, 'YTickLabel', []);
set(gca,'FontSize',tick_size);
xlim([-128 -64]); ylim([23 52]); box on;













%% output the plot

fig = gcf;
fig.PaperUnits = 'inches';
% fig.PaperPosition = [0 0 10 5];

fig.PaperPositionMode = 'auto';
fig.PaperPosition = [0 0 15 11];
print('./fig', '-dpng', '-r300')




