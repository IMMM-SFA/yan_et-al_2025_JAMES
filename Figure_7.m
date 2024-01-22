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

para_uniform = para(par1000,para_index);


ax(1) = subplot(3,3,1)
gauge_id = 1144000;
metric_daily = nan(464,1); 
for i = 1:464
    temp = out_para_basin_hybrid(i,:); temp = temp(~isnan(temp));
    temp1 = nan(length(temp),1);

    for j = 1:length(temp)
        temp1(j,1) = para(temp(j),para_index);
    end
    metric_daily(i,1) = mean(temp1);

    if out_regional(i,1)==gauge_id
        data_pdf = temp1;
    end
end
[f,xi] = ksdensity(para_uniform, 'bandwidth', 2); 
fill([xi fliplr(xi)], [f zeros(size(f))],  [0.8500 0.3250 0.0980], 'FaceAlpha', 0.3, 'EdgeColor', 'none'); hold on;
[f,xi] = ksdensity(data_pdf); 
fill([xi fliplr(xi)], [f zeros(size(f))], 'b', 'FaceAlpha', 0.2, 'EdgeColor', 'none'); hold on;
xlim([0, 5]);
ylim([0, 2]);
xlabel('fff Parameter (1/m)', 'FontSize', label_size);  
ylabel('Density', 'FontSize', label_size); 
title('(a) C1-Northeast: Gauge 01144000', 'FontSize', label_size)



ax(1) = subplot(3,3,2)
gauge_id = 14216500;
metric_daily = nan(464,1); 
for i = 1:464
    temp = out_para_basin_hybrid(i,:); temp = temp(~isnan(temp));
    temp1 = nan(length(temp),1);

    for j = 1:length(temp)
        temp1(j,1) = para(temp(j),para_index);
    end
    metric_daily(i,1) = mean(temp1);

    if out_regional(i,1)==gauge_id
        data_pdf = temp1;
    end
end
[f,xi] = ksdensity(para_uniform, 'bandwidth', 2); 
fill([xi fliplr(xi)], [f zeros(size(f))],  [0.8500 0.3250 0.0980], 'FaceAlpha', 0.3, 'EdgeColor', 'none'); hold on;
[f,xi] = ksdensity(data_pdf); 
fill([xi fliplr(xi)], [f zeros(size(f))], 'b', 'FaceAlpha', 0.2, 'EdgeColor', 'none'); hold on;
xlim([0, 5]);
xlabel('fff Parameter (1/m)', 'FontSize', label_size);  
ylabel('Density', 'FontSize', label_size); 
title('(b) C2-Pacific: Gauge 14216500', 'FontSize', label_size)
ylim([0, 1]);


ax(1) = subplot(3,3,3)
gauge_id = 09430500;
metric_daily = nan(464,1); 
for i = 1:464
    temp = out_para_basin_hybrid(i,:); temp = temp(~isnan(temp));
    temp1 = nan(length(temp),1);

    for j = 1:length(temp)
        temp1(j,1) = para(temp(j),para_index);
    end
    metric_daily(i,1) = mean(temp1);

    if out_regional(i,1)==gauge_id
        data_pdf = temp1;
    end
end
[f,xi] = ksdensity(para_uniform, 'bandwidth', 2); 
fill([xi fliplr(xi)], [f zeros(size(f))],  [0.8500 0.3250 0.0980], 'FaceAlpha', 0.3, 'EdgeColor', 'none'); hold on;
[f,xi] = ksdensity(data_pdf); 
fill([xi fliplr(xi)], [f zeros(size(f))], 'b', 'FaceAlpha', 0.2, 'EdgeColor', 'none'); hold on;
xlim([0, 5]);
xlabel('fff Parameter (1/m)', 'FontSize', label_size);  
ylabel('Density', 'FontSize', label_size); 
title('(c) C3-AZ/NM: Gauge 09430500', 'FontSize', label_size)
ylim([0, 1.5]);



ax(1) = subplot(3,3,4)
gauge_id = 09312600;
metric_daily = nan(464,1); 
for i = 1:464
    temp = out_para_basin_hybrid(i,:); temp = temp(~isnan(temp));
    temp1 = nan(length(temp),1);

    for j = 1:length(temp)
        temp1(j,1) = para(temp(j),para_index);
    end
    metric_daily(i,1) = mean(temp1);

    if out_regional(i,1)==gauge_id
        data_pdf = temp1;
    end
end
[f,xi] = ksdensity(para_uniform, 'bandwidth', 2); 
fill([xi fliplr(xi)], [f zeros(size(f))],  [0.8500 0.3250 0.0980], 'FaceAlpha', 0.3, 'EdgeColor', 'none'); hold on;
[f,xi] = ksdensity(data_pdf); 
fill([xi fliplr(xi)], [f zeros(size(f))], 'b', 'FaceAlpha', 0.2, 'EdgeColor', 'none'); hold on;
xlim([0, 5]);
xlabel('fff Parameter (1/m)', 'FontSize', label_size);  
ylabel('Density', 'FontSize', label_size); 
title('(d) C4-Rockies: Gauge 09312600', 'FontSize', label_size)
ylim([0, 1.5]);




ax(1) = subplot(3,3,5)
gauge_id = 08195000;
metric_daily = nan(464,1); 
for i = 1:464
    temp = out_para_basin_hybrid(i,:); temp = temp(~isnan(temp));
    temp1 = nan(length(temp),1);

    for j = 1:length(temp)
        temp1(j,1) = para(temp(j),para_index);
    end
    metric_daily(i,1) = mean(temp1);

    if out_regional(i,1)==gauge_id
        data_pdf = temp1;
    end
end
[f,xi] = ksdensity(para_uniform, 'bandwidth', 2); 
fill([xi fliplr(xi)], [f zeros(size(f))],  [0.8500 0.3250 0.0980], 'FaceAlpha', 0.3, 'EdgeColor', 'none'); hold on;
[f,xi] = ksdensity(data_pdf); 
fill([xi fliplr(xi)], [f zeros(size(f))], 'b', 'FaceAlpha', 0.2, 'EdgeColor', 'none'); hold on;
xlim([0, 5]);
xlabel('fff Parameter (1/m)', 'FontSize', label_size);  
ylabel('Density', 'FontSize', label_size); 
title('(e) C5-Great Plains: Gauge 08195000', 'FontSize', label_size)
ylim([0, 1.5]);



ax(1) = subplot(3,3,6)
gauge_id = 05507600;
metric_daily = nan(464,1); 
for i = 1:464
    temp = out_para_basin_hybrid(i,:); temp = temp(~isnan(temp));
    temp1 = nan(length(temp),1);

    for j = 1:length(temp)
        temp1(j,1) = para(temp(j),para_index);
    end
    metric_daily(i,1) = mean(temp1);

    if out_regional(i,1)==gauge_id
        data_pdf = temp1;
    end
end
[f,xi] = ksdensity(para_uniform, 'bandwidth', 2); 
fill([xi fliplr(xi)], [f zeros(size(f))],  [0.8500 0.3250 0.0980], 'FaceAlpha', 0.3, 'EdgeColor', 'none'); hold on;
[f,xi] = ksdensity(data_pdf); 
fill([xi fliplr(xi)], [f zeros(size(f))], 'b', 'FaceAlpha', 0.2, 'EdgeColor', 'none'); hold on;
xlim([0, 5]);
xlabel('fff Parameter (1/m)', 'FontSize', label_size);  
ylabel('Density', 'FontSize', label_size); 
title('(f) C6-Midwest: Gauge 05507600', 'FontSize', label_size)
ylim([0, 1]);

ax(1) = subplot(3,3,7)
gauge_id = 02363000;
metric_daily = nan(464,1); 
for i = 1:464
    temp = out_para_basin_hybrid(i,:); temp = temp(~isnan(temp));
    temp1 = nan(length(temp),1);

    for j = 1:length(temp)
        temp1(j,1) = para(temp(j),para_index);
    end
    metric_daily(i,1) = mean(temp1);

    if out_regional(i,1)==gauge_id
        data_pdf = temp1;
    end
end
[f,xi] = ksdensity(para_uniform, 'bandwidth', 2); 
fill([xi fliplr(xi)], [f zeros(size(f))],  [0.8500 0.3250 0.0980], 'FaceAlpha', 0.3, 'EdgeColor', 'none'); hold on;
[f,xi] = ksdensity(data_pdf); 
fill([xi fliplr(xi)], [f zeros(size(f))], 'b', 'FaceAlpha', 0.2, 'EdgeColor', 'none'); hold on;
xlim([0, 5]);
xlabel('fff Parameter (1/m)', 'FontSize', label_size);  
ylabel('Density', 'FontSize', label_size); 
title('(g) C7-Southeast: Gauge 02363000', 'FontSize', label_size)
ylim([0, 1]);




ax(1) = subplot(3,3,8)
gauge = [1144000, 14216500, 9430500, 9312600, 8195000, 5507600, 2363000];
coor = nan(7, 2);
for i = 1:7
    index = find(out_regional(:,1)==gauge(i));
    coor(i,1:2) = out_regional(index,2:3);
end

plot(US(:,1), US(:,2),'.','MarkerSize',2,'Color','black'); hold on; 
plot(SL(:,1), SL(:,2),'.','MarkerSize',2,'Color','black'); hold on;
scatter(coor(:,2), coor(:,1), scatter_size, 'o','filled', 'MarkerFaceColor',[0.8500 0.3250 0.0980], 'LineWidth',line_width-0.5); hold on;
labels = {'C1', 'C2', 'C3', 'C4', 'C5', 'C6', 'C7'};
text(coor(:,2), coor(:,1), labels, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize',text_size+4,'FontWeight','BOLD' ,'Color',[0.8500 0.3250 0.0980]);


xlim([-128 -64]); ylim([23 52]); box on;
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
% text(0.05, 0.15, '(h)', 'FontSize',text_size, 'FontWeight', 'bold', 'Units','Normalized')
title('(h) Selected Basin Location', 'FontSize', label_size)




%% output the plot

fig = gcf;
fig.PaperUnits = 'inches';
% fig.PaperPosition = [0 0 10 5];

fig.PaperPositionMode = 'auto';
fig.PaperPosition = [0 0 14 8];
print('./figure', '-dpng', '-r300')


