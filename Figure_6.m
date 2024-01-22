%%  find the CAMELS basin parameter constrain

clear all; clc;

temp = readtable('../../ensemble_sim/ensemble_q10');
out_regional = nan(464, 7);  %1-gauge id, 2-lat, 3-lon, 4-cluster id, 5-q10_mm_d, 6-q90_mm_d, 7-qmean_mm_d
out_regional(:,1) = temp.Var1; 
out_regional(:,2) = temp.Var2;
out_regional(:,3) = temp.Var3;
out_regional(:,4) = temp.Var4;
out_regional = sortrows(out_regional, 1);
temp = sortrows(temp, 1);

para_qmean = load('camel_regional_id_1000_qmean.txt');
par1000 = load('./sucessful_par_id_1000');  % id 1-1500
par1307 = load('./sucessful_par_id_1307');  % id 1-1500
index1000 = ismember(par1307, par1000);


out_para_basin_r_p = nan(464, 1000);  %id 1-1500
temp = readtable('../../ensemble_sim/ensemble_qmean');
temp = sortrows(temp, 1);
for i = 1:464
    temp1 = table2array(temp(i, 5:end));
    temp1 = temp1(index1000);
    temp2 = nan(10,1);
    for j = 1:7
        if out_regional(i,4)==j
            par_id = para_qmean(j,2:11);
            for k = 1:10
                out_para_basin_r_p(i,k) = par1000(par_id(k));
            end
        end
    end
end






temp = readtable('../gscd_camel_regression/qmean.csv');
var(:,9)  = temp.V7;
var(:,10)  = temp.V8;
var = sortrows(var,1);

temp = readtable('../../ensemble_sim/ensemble_q10');
temp = sortrows(temp,1);
cluster_id = table2array(temp(:,4));

out_para_basin_hybrid = nan(464, 1000);  %id 1-1500
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
            out_para_basin_hybrid(i,j) = par1000(indices(j));
        end
    end
    
    % 2) if no constrain, use the top 10 members 
    if length(indices)==0
        temp2 = nan(10,1);
        
        for k = 1:7
            if cluster_id(i)==k
                par_id = para_qmean(k,2:21);
                for j = 1:10
                    out_para_basin_hybrid(i,j) = par1000(par_id(j));
                end
            end
        end
    end

    % 3) mixed with constain but no 10 parameters 
    if length(indices)>0 && length(indices)<10
        temp2 = nan(10, 1);
        for j = 1:length(indices)
            temp2(j,1) = temp1(indices(j));
            out_para_basin_hybrid(i,j) = par1000(indices(j));
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
                        out_para_basin_hybrid(i,count1) = par1000(par_id(j));
%                         temp2(count1,1) = temp1(par_id(j));
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















%% find hybrid constrain

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

US = load('us_coor.txt');
SL = load('sl_coor.txt');
scatter_size = 20; label_size = 10; legend_size = 10; tick_size = 10; colorbar_size= 10;title_size = 10; line_width = 1; text_size = 10;


lat = load('lat_2d');
lon = load('lon_2d');
data = readtable('./CONUS_clustering_id.csv');
data = sortrows(data,[4,5]);

cluster_id = data.clustering_7;

class_maxtri = nan(224, 464);
lat_index = data.Lat_index;
lon_index = data.Lon_index;




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
    if length(indices)>=10
        for j = 1:length(indices)
            out_sim_regression(i,j) = ensemble_qmean_350(indices(j),i);
            out_para_regression(i,j) = para_id_350(indices(j));
        end
    end

    if length(indices)==0
        temp2 = nan(10,1);
        
        for k = 1:7
            if cluster_id(i)==k
                par_id = para_qmean(k,2:21);
                for j = 1:10
                    out_para_regression(i,j) = para_id_350(par_id(j));
                end
            end
        end
    end


    if length(indices)>0 && length(indices)<10
        temp2 = nan(10, 1);
        for j = 1:length(indices)
            out_para_regression(i,j) = para_id_350(indices(j));
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
                        out_para_regression(i,count1) = para_id_350(par_id(j));
%                         temp2(count1,1) = temp1(par_id(j));
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












%%  choose parameter

US = load('us_coor.txt');
SL = load('sl_coor.txt');
scatter_size = 20; label_size = 11; legend_size = 11; tick_size = 11; colorbar_size= 11;title_size = 10; line_width = 1; text_size = 9;

para_index = 1;

cmin = 0.02;
cmax = 5; 

default_value = 0.5;

figure;

para = load('../../parameter_ensemble_LHS1500');

ax(1) = subplot(3,2,1)


temp = readtable('../../ensemble_sim/ensemble_q10');
out_regional = nan(464, 7);  %1-gauge id, 2-lat, 3-lon, 4-cluster id, 5-q10_mm_d, 6-q90_mm_d, 7-qmean_mm_d
out_regional(:,1) = temp.Var1; 
out_regional(:,2) = temp.Var2;
out_regional(:,3) = temp.Var3;
out_regional(:,4) = temp.Var4;
out_regional = sortrows(out_regional, 1);
temp = sortrows(temp, 1);


lat = table2array(temp(:,2)); lon = table2array(temp(:,3));
metric_daily = nan(464,1); 
metric_daily(:) = default_value;
scatter(lon, lat, scatter_size, metric_daily, 'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on; 
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

colormap(ax(1), brewermap([],'*Spectral'));   
colorbar
caxis([cmin cmax]); 
title('(a1) fff Parameter: Default Value (1/m)', 'FontSize', title_size);
set(gca,'FontSize',tick_size);



% ax(3) = subplot(4,2,3)
% 
% lat = table2array(temp(:,2)); lon = table2array(temp(:,3));
% metric_daily = nan(464,1); 
% 
% for i = 1:464
%     temp = out_para_basin_r_p(i,:); temp = temp(~isnan(temp));
%     temp1 = nan(length(temp),1);
% 
%     for j = 1:length(temp)
%         temp1(j,1) = para(temp(j),para_index);
%     end
%     metric_daily(i,1) = mean(temp1);
% end
% 
% 
% scatter(lon, lat, scatter_size, metric_daily, 'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on; 
% 
% set(gca,'FontSize',tick_size);
% 
% plot(US(:,1), US(:,2),'.','MarkerSize',2,'Color','black'); hold on; 
% plot(SL(:,1), SL(:,2),'.','MarkerSize',2,'Color','black'); hold on; 
% xlim([-128 -64]); ylim([23 52]); box on;
% 
% xticks = [-120,-110,-100,-90,-80, -70];
% xticklabels_deg = cell(size(xticks));
% for i = 1:numel(xticks)
%     xticklabels_deg{i} = [num2str(-xticks(i)) '°W'];
% end
% set(gca, 'XTick', xticks);
% set(gca, 'XTickLabel', xticklabels_deg);
% set(gca, 'XTickLabel', []);
% 
% yticks = [25, 30, 35, 40, 45, 50];
% yticklabels_deg = cell(size(yticks));
% for i = 1:numel(yticks)
%     yticklabels_deg{i} = [num2str(yticks(i)) '°N'];
% end
% set(gca, 'YTick', yticks);
% set(gca, 'YTickLabel', yticklabels_deg);
% 
% 
% % cmin = min(metric_daily)-0.2;
% % cmax = max(metric_daily)+0.2;
% 
% colormap(ax(3), brewermap([],'*Spectral'));   
% colorbar
% caxis([cmin cmax]); 
% title('(a2) R-P Parameter (mean)', 'FontSize', title_size);



ax(3) = subplot(3,2,3)

metric_daily = nan(464,1); 

for i = 1:464
    temp = out_para_basin_hybrid(i,:); temp = temp(~isnan(temp));
    temp1 = nan(length(temp),1);

    for j = 1:length(temp)
        temp1(j,1) = para(temp(j),para_index);
    end
    metric_daily(i,1) = mean(temp1);
end


scatter(lon, lat, scatter_size, metric_daily, 'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on; 
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

colormap(ax(3), brewermap([],'*Spectral'));   
colorbar
caxis([2 3]); 
title('(a2) Hybrid Method: fff Parameter (mean, 1/m)', 'FontSize', title_size);
set(gca,'FontSize',tick_size);


ax(5) = subplot(3,2,5)

metric_daily = nan(464,1); 

for i = 1:464
    temp = out_para_basin_hybrid(i,:); temp = temp(~isnan(temp));
    temp1 = nan(length(temp),1);

    for j = 1:length(temp)
        temp1(j,1) = para(temp(j),para_index);
    end
    metric_daily(i,1) = std(temp1)/mean(temp1);
end


scatter(lon, lat, scatter_size, metric_daily, 'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on; 
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
caxis([0.4 0.8]); 
title('(a3) Hybrid Method: fff Parameter (CV)', 'FontSize', title_size);
set(gca,'FontSize',tick_size);











lat = load('lat_2d');
lon = load('lon_2d');


% defualt parameter --------------------------------------------------------
ax(2) = subplot(3,2,2)

class_maxtri = nan(224, 464);
for i = 1:length(cluster_id)
      class_maxtri(lat_index(i),lon_index(i)) = default_value;
end
pcolor(lon, lat, class_maxtri); hold on; shading flat;
 

% colorbar
% title('{\it fff} (1/m)', 'FontSize', title_size);
% title('{\it p}_{lip} (kg/m^2)', 'FontSize', title_size);
% title('{\it \theta}_{ini}', 'FontSize', title_size);
plot(US(:,1), US(:,2),'.','MarkerSize',2,'Color','black'); hold on;  grid on;
set(gca, 'GridLineStyle', ':');
% ylabel('Latitude (\circ)', 'FontSize', label_size); 
% xlabel('Longitude (\circ)', 'FontSize', label_size); 

% xticks = [-120,-110,-100,-90,-80, -70];
% xticklabels_deg = cell(size(xticks));
% for i = 1:numel(xticks)
%     xticklabels_deg{i} = [num2str(-xticks(i)) '°W'];
% end
% set(gca, 'XTick', xticks);
% set(gca, 'XTickLabel', xticklabels_deg);

yticks = [25, 30, 35, 40, 45, 50];
yticklabels_deg = cell(size(yticks));
for i = 1:numel(yticks)
    yticklabels_deg{i} = [num2str(yticks(i)) '°N'];
end
set(gca, 'YTick', yticks);
set(gca, 'YTickLabel', yticklabels_deg);
set(gca, 'XTickLabel', []);
set(gca, 'YTickLabel', []);
% text(0.02, 0.15, '(a): Default Value', 'FontSize',text_size, 'FontWeight', 'bold', 'Units','Normalized');
caxis([cmin cmax]); 
colormap(brewermap([],'*Spectral'));  
title('(b1) fff Parameter: Default Value (1/m)', 'FontSize',title_size)
colorbar
xlim([-128 -64]); ylim([23 52]); box on;
set(gca,'FontSize',tick_size);





% % best regional parameter --------------------------------------------------------
% para = load('../../parameter_ensemble_LHS1500');
% regional_par = [1093	1493	602	1466	779	578	136];  % qmean 
% 
% 
% 
% 
% ax(2) = subplot(3,2,2)
% class_maxtri = nan(224, 464);
% for i = 1:length(cluster_id)
%     if cluster_id(i)==1
%         class_maxtri(lat_index(i),lon_index(i)) = para(regional_par(1), para_index);
%     end
%     if cluster_id(i)==2
%         class_maxtri(lat_index(i),lon_index(i)) = para(regional_par(2), para_index);
%     end    
%     if cluster_id(i)==3
%         class_maxtri(lat_index(i),lon_index(i)) = para(regional_par(3), para_index);
%     end   
%     if cluster_id(i)==4
%         class_maxtri(lat_index(i),lon_index(i)) = para(regional_par(4), para_index);
%     end 
%     if cluster_id(i)==5
%         class_maxtri(lat_index(i),lon_index(i)) = para(regional_par(5), para_index);
%     end 
%     if cluster_id(i)==6
%         class_maxtri(lat_index(i),lon_index(i)) = para(regional_par(6), para_index);
%     end
%     if cluster_id(i)==7
%         class_maxtri(lat_index(i),lon_index(i)) = para(regional_par(7), para_index);
%     end
% end
% 
% pcolor(lon, lat, class_maxtri); hold on; shading flat;
% 
% 
% % colorbar
% % title('{\it fff} (1/m)', 'FontSize', title_size);
% plot(US(:,1), US(:,2),'.','MarkerSize',2,'Color','black'); hold on;  grid on;
% set(gca, 'GridLineStyle', ':');
% % ylabel('Latitude (\circ)', 'FontSize', label_size); 
% % xlabel('Longitude (\circ)', 'FontSize', label_size); 
% 
% % xticks = [-120,-110,-100,-90,-80, -70];
% % xticklabels_deg = cell(size(xticks));
% % for i = 1:numel(xticks)
% %     xticklabels_deg{i} = [num2str(-xticks(i)) '°W'];
% % end
% % set(gca, 'XTick', xticks);
% % set(gca, 'XTickLabel', xticklabels_deg);
% 
% yticks = [30, 35, 40, 45, 50];
% yticklabels_deg = cell(size(yticks));
% for i = 1:numel(yticks)
%     yticklabels_deg{i} = [num2str(yticks(i)) '°N'];
% end
% set(gca, 'YTick', yticks);
% set(gca, 'YTickLabel', []);
% set(gca, 'XTickLabel', []);
% % text(0.02, 0.15, sprintf('(%s2)', para_num), 'FontSize',text_size, 'FontWeight', 'bold', 'Units','Normalized');
% 
%  
% colormap(brewermap([],'*Spectral'));   
% 
% caxis([cmin cmax]); 
% 
% title('(b): Best Regional Value', 'FontSize',title_size)
% colorbar



% ax(3) = subplot(3,2,3)
% class_maxtri = nan(224, 464);
% for i = 1:length(cluster_id)
%     temp = out_para_raw(i,:); temp = temp(~isnan(temp));
%     temp1 = nan(length(temp),1);
%     if length(temp)>=1
%         for j = 1:length(temp)
%             temp1(j,1) = para(temp(j),para_index);
%         end
%         class_maxtri(lat_index(i),lon_index(i)) = mean(temp1);
%     else
%         class_maxtri(lat_index(i),lon_index(i)) = nan;
%     end
% end
% 
% 
% pcolor(lon, lat, class_maxtri); hold on; shading flat;
% % colorbar
% % title('{\it fff} (1/m)', 'FontSize', title_size);
% plot(US(:,1), US(:,2),'.','MarkerSize',2,'Color','black'); hold on;  grid on;
% set(gca, 'GridLineStyle', ':');
% % ylabel('Latitude (\circ)', 'FontSize', label_size); 
% % xlabel('Longitude (\circ)', 'FontSize', label_size); 
% 
% % xticks = [-120,-110,-100,-90,-80, -70];
% % xticklabels_deg = cell(size(xticks));
% % for i = 1:numel(xticks)
% %     xticklabels_deg{i} = [num2str(-xticks(i)) '°W'];
% % end
% % set(gca, 'XTick', xticks);
% % set(gca, 'XTickLabel', xticklabels_deg);
% 
% yticks = [30, 35, 40, 45, 50];
% yticklabels_deg = cell(size(yticks));
% for i = 1:numel(yticks)
%     yticklabels_deg{i} = [num2str(yticks(i)) '°N'];
% end
% set(gca, 'YTick', yticks);
% set(gca, 'YTickLabel', yticklabels_deg);
% set(gca, 'XTickLabel', []);
% % text(0.02, 0.15, sprintf('(%s3)', para_num), 'FontSize',text_size, 'FontWeight', 'bold', 'Units','Normalized');
% 
% %  
% colormap(brewermap([],'*Spectral'));   
% % cmap = colormap;
% % grayColor = [100 100 100]/255;
% % cmap(1, :) = grayColor;
% % colormap(cmap);
% caxis([cmin+1 cmax-1]);  
% % caxis([cmin cmax]);  
% title('(c): GSCD 95% C.I. Constrain (Mean)', 'FontSize',title_size)
% colorbar


ax(4) = subplot(3,2,4)
class_maxtri = nan(224, 464);
for i = 1:length(cluster_id)
    temp = out_para_regression(i,:); temp = temp(~isnan(temp));
    temp1 = nan(length(temp),1);
    if length(temp)>=1
        for j = 1:length(temp)
            temp1(j,1) = para(temp(j),para_index);
        end
        class_maxtri(lat_index(i),lon_index(i)) = mean(temp1);
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

% xticks = [-120,-110,-100,-90,-80, -70];
% xticklabels_deg = cell(size(xticks));
% for i = 1:numel(xticks)
%     xticklabels_deg{i} = [num2str(-xticks(i)) '°W'];
% end
% set(gca, 'XTick', xticks);
% set(gca, 'XTickLabel', xticklabels_deg);

yticks = [25, 30, 35, 40, 45, 50];
yticklabels_deg = cell(size(yticks));
for i = 1:numel(yticks)
    yticklabels_deg{i} = [num2str(yticks(i)) '°N'];
end
set(gca, 'YTick', yticks);
set(gca, 'YTickLabel', []);
set(gca, 'XTickLabel', []);
% text(0.02, 0.15, sprintf('(%s4)', para_num), 'FontSize',text_size, 'FontWeight', 'bold', 'Units','Normalized');

%  
colormap(brewermap([],'*Spectral'));   
% cmap = colormap;
% grayColor = [100 100 100]/255;
% cmap(1, :) = grayColor;
% colormap(cmap);
% caxis([0 1.2]);  
colorbar
caxis([2 3]); 
title('(b2) Hybrid Method: fff Parameter (mean, 1/m)', 'FontSize',title_size)
xlim([-128 -64]); ylim([23 52]); box on;
set(gca,'FontSize',tick_size);



ax(6) = subplot(3,2,6)
class_maxtri = nan(224, 464);
for i = 1:length(cluster_id)
    temp = out_para_regression(i,:); temp = temp(~isnan(temp));
    temp1 = nan(length(temp),1);
    if length(temp)>=1
        for j = 1:length(temp)
            temp1(j,1) = para(temp(j),para_index);
        end
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
set(gca, 'YTickLabel', []);
% set(gca, 'XTickLabel', []);
% text(0.02, 0.15, sprintf('(%s4)', para_num), 'FontSize',text_size, 'FontWeight', 'bold', 'Units','Normalized');

%  
colormap(brewermap([],'*Spectral'));   
% cmap = colormap;
% grayColor = [100 100 100]/255;
% cmap(1, :) = grayColor;
% colormap(cmap);
% caxis([0 1.2]);  
colorbar
caxis([0.4 0.8]); 
title('(b3) Hybrid Method: fff Parameter (CV)', 'FontSize',title_size)
xlim([-128 -64]); ylim([23 52]); box on;
set(gca,'FontSize',tick_size);

%% output the plot

fig = gcf;
fig.PaperUnits = 'inches';
% fig.PaperPosition = [0 0 10 5];

fig.PaperPositionMode = 'auto';
fig.PaperPosition = [0 0 15 11];
print('./fig', '-dpng', '-r300')


