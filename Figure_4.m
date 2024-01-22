%% find GSCD raw constrain and GSCD regression constrain

clear all; clc;

US = load('us_coor.txt');
SL = load('sl_coor.txt');
scatter_size = 20; label_size = 11; legend_size = 11; tick_size = 11; colorbar_size= 11;title_size = 10; line_width = 1; text_size = 9;

%1-gauge id, 2-lat, 3-lon, 4-cluster id, 5- default, 6-regional best,
%7-gscd mean, 8-gscd std, 9-gscd 95% PI mean, 10 gscd 95% PI std 
out_q10_metric = nan(464, 10); 
out_q90_metric = nan(464, 10); 
out_qmean_metric = nan(464, 10); 

% load observations
obs = readtable('../camel_Hydrologic_features.csv');
out_obs = nan(464,7); %1-gauge id, 2-lat, 3-lon, 4-cluster id,, 5-q10_mm_d, 6-q90_mm_d, 7-qmean_mm_d
out_obs(:,1) = obs.Gauge_ID;
out_obs(:,2) = obs.Gauge_Lat;
out_obs(:,3) = obs.Gauge_Lon;
out_obs(:,4) = obs.Cluster;
out_obs(:,5) = obs.q10_mm_d;
out_obs(:,6) = obs.q90_mm_d;
out_obs(:,7) = obs.mean_annual_mm_d;
out_obs = sortrows(out_obs, 1);

out_q10_metric(:,1:4)   = out_obs(:,1:4);
out_q90_metric(:,1:4)   = out_obs(:,1:4);
out_qmean_metric(:,1:4) = out_obs(:,1:4);

clear obs;


%% ---------------------------------------------------------------------------------------------------------
% 1) default metric 
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
 
out_q10_metric(:,5)   = (out_default(:,5) - out_obs(:,5));  % sim - obs
out_q90_metric(:,5)   = (out_default(:,6) - out_obs(:,6));  % sim - obs
out_qmean_metric(:,5) = (out_default(:,7) - out_obs(:,7));  % sim - obs

%%  ---------------------------------------------------------------------------------------------------------
% 2) regional best 
% region_par_qmean = [954	1300	518	1276	680	496	118];  % 1- 1307
% region_par_q10   = [1	1	1	1	8	2	1]; 
% region_par_q90   = [49	24	247	579	963	172	210]; 


para_q10   = load('camel_regional_id_1000_q10.txt');
para_q90   = load('camel_regional_id_1000_q90.txt');
para_qmean = load('camel_regional_id_1000_qmean.txt');

par1000 = load('./sucessful_par_id_1000');
par1307 = load('./sucessful_par_id_1307');
index1000 = ismember(par1307, par1000);




temp = readtable('../../ensemble_sim/ensemble_q10');
out_regional = nan(464, 7);  %1-gauge id, 2-lat, 3-lon, 4-cluster id, 5-q10_mm_d, 6-q90_mm_d, 7-qmean_mm_d
out_regional(:,1) = temp.Var1; 
out_regional(:,2) = temp.Var2;
out_regional(:,3) = temp.Var3;
out_regional(:,4) = temp.Var4;
out_regional = sortrows(out_regional, 1);
temp = sortrows(temp, 1);

for i = 1:464
    temp1 = table2array(temp(i, 5:end));
    temp1 = temp1(index1000);
    temp2 = nan(10,1);
    for j = 1:7
        if out_regional(i,4)==j
            par_id = para_q10(j,2:11);
            for k = 1:10
                temp2(k,1) = temp1(par_id(k));

            end

        end
    end
%     out_q10_metric(i,6) = 1 - crps(temp2, out_obs(i,5)) / abs(out_default(i,5) - out_obs(i,5)); 
    out_q10_metric(i,6) = mean(temp2)-out_obs(i,5); 
end


temp = readtable('../../ensemble_sim/ensemble_q90');
temp = sortrows(temp, 1);
for i = 1:464
    temp1 = table2array(temp(i, 5:end));
    temp1 = temp1(index1000);
    temp2 = nan(10,1);
    for j = 1:7
        if out_regional(i,4)==j
            par_id = para_q90(j,2:11);
            for k = 1:10
                temp2(k,1) = temp1(par_id(k));

            end

        end
    end
%     out_q90_metric(i,6) = 1 - crps(temp2, out_obs(i,6)) / abs(out_default(i,6) - out_obs(i,6)); 
    out_q90_metric(i,6) = mean(temp2)-out_obs(i,6); 
end



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
                temp2(k,1) = temp1(par_id(k));

            end

        end
    end
%     out_qmean_metric(i,6) = 1 - crps(temp2, out_obs(i,7)) / abs(out_default(i,7) - out_obs(i,7));
    out_qmean_metric(i,6) = mean(temp2)-out_obs(i,7);
end



% out_q10_metric(:,6)   = abs(out_regional(:,5) - out_obs(:,5));  % sim - obs
% out_q90_metric(:,6)   = abs(out_regional(:,6) - out_obs(:,6));  % sim - obs
% out_qmean_metric(:,6) = abs(out_regional(:,7) - out_obs(:,7));  % sim - obs

% out_q10_metric(:,6) = out_regional(:,5);
% out_q90_metric(:,6) = out_regional(:,6);
% out_qmean_metric(:,6) = out_regional(:,7);



















%%  ---------------------------------------------------------------------------------------------------------
% 4) GSCD regression data only

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




temp = readtable('../../ensemble_sim/ensemble_q10');
temp = sortrows(temp,1);

for i = 1:464
    temp1 = table2array(temp(i, 5:end));
    temp1 = temp1(index1000);
    low = var(i,5);
    up  = var(i,6);
    indices = find(temp1 > low & temp1 < up);  % 1- 350
    if length(indices)>1
        temp2 = nan(length(indices), 1);
        for j = 1:length(indices)
            temp2(j,1) = temp1(indices(j));
        end
%         out_q10_metric(i,7) = 1 - crps(temp2, out_obs(i,5)) / abs(out_default(i,5) - out_obs(i,5)); 
        out_q10_metric(i,7) = mean(temp2) - out_obs(i,5); 
    end

%     if length(indices)==1
%         temp2 = temp1(indices);
%         out_q10_metric(i,7) = 1 - abs(temp2 - out_obs(i,5)) / abs(out_default(i,5) - out_obs(i,5)); 
%     end
end

temp = readtable('../../ensemble_sim/ensemble_q90');
temp = sortrows(temp,1);
for i = 1:464
    temp1 = table2array(temp(i, 5:end));
    temp1 = temp1(index1000);
    low = var(i,7);
    up  = var(i,8);
    indices = find(temp1 > low & temp1 < up);  % 1- 350
    if length(indices)>1
        temp2 = nan(length(indices), 1);
        for j = 1:length(indices)
            temp2(j,1) = temp1(indices(j));
        end
%         out_q90_metric(i,7) = 1 - crps(temp2, out_obs(i,6)) / abs(out_default(i,6) - out_obs(i,6)); 
        out_q90_metric(i,7) = mean(temp2) - out_obs(i,6); 
    end

%     if length(indices)==1
%         temp2 = temp1(indices);
%         out_q90_metric(i,7) = 1 - abs(temp2 - out_obs(i,6)) / abs(out_default(i,6) - out_obs(i,6)); 
%     end
end

temp = readtable('../../ensemble_sim/ensemble_qmean');
temp = sortrows(temp,1);
for i = 1:464
    temp1 = table2array(temp(i, 5:end));
    temp1 = temp1(index1000);
    low = var(i,9);
    up  = var(i,10);
    indices = find(temp1 > low & temp1 < up);  % 1- 350
    if length(indices)>1
        temp2 = nan(length(indices), 1);
        for j = 1:length(indices)
            temp2(j,1) = temp1(indices(j));
        end
%         out_qmean_metric(i,7) = 1 - crps(temp2, out_obs(i,7)) / abs(out_default(i,7) - out_obs(i,7)); 
        out_qmean_metric(i,7) = mean(temp2) - out_obs(i,7); 
    end

%     if length(indices)==1
%         temp2 = temp1(indices);
%         out_qmean_metric(i,7) = 1 - abs(temp2 - out_obs(i,7)) / abs(out_default(i,7) - out_obs(i,7)); 
%     end
end











%%  ---------------------------------------------------------------------------------------------------------
% 4) GSCD regression data + regional best


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

temp = readtable('../../ensemble_sim/ensemble_q10');
temp = sortrows(temp,1);
cluster_id = table2array(temp(:,4));
for i = 1:464
    temp1 = table2array(temp(i, 5:end));
    temp1 = temp1(index1000);
    low = var(i,5);
    up  = var(i,6);
    indices = find(temp1 > low & temp1 < up);  % 1- 350

    % 1) use full constrain members
    if length(indices)>=10 
        temp2 = nan(length(indices), 1);
        for j = 1:length(indices)
            temp2(j,1) = temp1(indices(j));
        end
%         out_q10_metric(i,9) = 1 - crps(temp2, out_obs(i,5)) / abs(out_default(i,5) - out_obs(i,5));
        out_q10_metric(i,9) = mean(temp2) - out_obs(i,5);
    end
    
    % 2) if no constrain, use the top 10 members 
    if length(indices)==0
        temp2 = nan(10,1);
        
        for k = 1:7
            if cluster_id(i)==k
                par_id = para_q10(k,2:21);
                for j = 1:10
                    temp2(j,1) = temp1(par_id(j));
                end
            end
        end
%         out_q10_metric(i,9) = 1 - crps(temp2, out_obs(i,5)) / abs(out_default(i,5) - out_obs(i,5));
         out_q10_metric(i,9) = mean(temp2) - out_obs(i,5);
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
                par_id = para_q10(k,2:21);

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
%         out_q10_metric(i,9) = 1 - crps(temp2, out_obs(i,5)) / abs(out_default(i,5) - out_obs(i,5)); 
        out_q10_metric(i,9) = mean(temp2) - out_obs(i,5);
    end








%     if length(indices)>=1
%         temp2 = nan(length(indices), 1);
%         for j = 1:length(indices)
%             temp2(j,1) = abs(temp1(indices(j)) - out_obs(i,5));
%         end
%         out_q10_metric(i,9) = mean(temp2);
%     end
%     if length(indices)>=2
%         out_q10_metric(i,10) = std(temp2);
%     end



end









temp = readtable('../../ensemble_sim/ensemble_q90');
temp = sortrows(temp,1);
for i = 1:464
    temp1 = table2array(temp(i, 5:end));
        temp1 = temp1(index1000);
    low = var(i,7);
    up  = var(i,8);
    indices = find(temp1 > low & temp1 < up);  % 1- 350


    % 1) use full constrain members
    if length(indices)>=10 
        temp2 = nan(length(indices), 1);
        for j = 1:length(indices)
            temp2(j,1) = temp1(indices(j));
        end
        out_q90_metric(i,9) = 1 - crps(temp2, out_obs(i,6)) / abs(out_default(i,6) - out_obs(i,6)); 
        out_q90_metric(i,9) = mean(temp2) - out_obs(i,6);
    end
    
    % 2) if no constrain, use the top 10 members 
    if length(indices)==0
        temp2 = nan(10,1);
        
        for k = 1:7
            if cluster_id(i)==k
                par_id = para_q90(k,2:21);
                for j = 1:10
                    temp2(j,1) = temp1(par_id(j));
                end
            end
        end
        out_q90_metric(i,9) = 1 - crps(temp2, out_obs(i,6)) / abs(out_default(i,6) - out_obs(i,6)); 
        out_q90_metric(i,9) = mean(temp2) - out_obs(i,6);
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
                par_id = para_q90(k,2:21);

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
        out_q90_metric(i,9) = 1 - crps(temp2, out_obs(i,6)) / abs(out_default(i,6) - out_obs(i,6)); 
        out_q90_metric(i,9) = mean(temp2) - out_obs(i,6);
    end






%     if length(indices)>=1
%         temp2 = nan(length(indices), 1);
%         for j = 1:length(indices)
%             temp2(j,1) = abs(temp1(indices(j)) - out_obs(i,6));
%         end
%         out_q90_metric(i,9) = mean(temp2);
%     end
%     if length(indices)>=2
%         out_q90_metric(i,10) = std(temp2);
%     end

end















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
        out_qmean_metric(i,9) = 1 - crps(temp2, out_obs(i,7)) / abs(out_default(i,7) - out_obs(i,7)); 
        out_qmean_metric(i,9) = mean(temp2) - out_obs(i,7);
%         out_qmean_metric(i,9) = mean(temp2) - out_default(i,7);
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
        out_qmean_metric(i,9) = 1 - crps(temp2, out_obs(i,7)) / abs(out_default(i,7) - out_obs(i,7)); 
        out_qmean_metric(i,9) = mean(temp2) - out_obs(i,7);
%         out_qmean_metric(i,9) = mean(temp2) - out_default(i,7);
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
        out_qmean_metric(i,9) = 1 - crps(temp2, out_obs(i,7)) / abs(out_default(i,7) - out_obs(i,7)); 
        out_qmean_metric(i,9) = mean(temp2) - out_obs(i,7);
%         out_qmean_metric(i,9) = mean(temp2) - out_default(i,7);
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





%%  plot the metric

figure;

q90_max = 5.5;
q90_min = -5.5;

qmean_max = 2.6;
qmean_min = -2.6;

% defualt parameter --------------------------------------------------------
ax(1) = subplot(5,3,1)
variable = out_q10_metric; obs_index = 7;              %1-gauge id, 2-lat, 3-lon, 4-cluster id,, 5-q10_mm_d, 6-q90_mm_d, 7-qmean_mm_d

cmin = 0; cmax = 0.45; 
scatter_size = 25;

cluster_ID = variable(:,4); lat = variable(:,2); lon = variable(:,3);metric_daily = out_obs(:,5);
% fmt = {'o','^','v','s','>','h','<'};
fmt = {'o','o','o','o','o','o','o'};
cluster=1; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=2; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=3; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=4; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=5; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=6; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=7; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;

set(gca,'FontSize',tick_size);

plot(US(:,1), US(:,2),'.','MarkerSize',2,'Color','black'); hold on; 
plot(SL(:,1), SL(:,2),'.','MarkerSize',2,'Color','black');
xlim([-128 -64]); ylim([23 52]); box on;
caxis([cmin cmax]);  
colormap(ax(1), brewermap([],'*Spectral'));  
colorbar

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
set(gca, 'GridLineStyle', ':');
% text(0.02, 0.15, '(a)', 'FontSize',text_size, 'FontWeight', 'bold', 'Units','Normalized');
title('(a1) Obs. Q10 (mm/d)', 'FontSize', title_size);

grid on;
set(gca, 'GridLineStyle', ':');
set(gca, 'Color', [220 220 220]/255);
% colormap(brewermap([],'*Spectral'));  




% defualt parameter --------------------------------------------------------
ax(2) = subplot(5,3,2)
variable = out_q90_metric; obs_index = 7;              %1-gauge id, 2-lat, 3-lon, 4-cluster id,, 5-q10_mm_d, 6-q90_mm_d, 7-qmean_mm_d

cmin = 0; cmax = 5.3; 
scatter_size = 25;

cluster_ID = variable(:,4); lat = variable(:,2); lon = variable(:,3);metric_daily = out_obs(:,6);
% fmt = {'o','^','v','s','>','h','<'};
fmt = {'o','o','o','o','o','o','o'};
cluster=1; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=2; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=3; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=4; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=5; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=6; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=7; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;

set(gca,'FontSize',tick_size);

plot(US(:,1), US(:,2),'.','MarkerSize',2,'Color','black'); hold on; 
plot(SL(:,1), SL(:,2),'.','MarkerSize',2,'Color','black');
xlim([-128 -64]); ylim([23 52]); box on;
caxis([cmin cmax]);  
colormap(ax(2), brewermap([],'*Spectral'));  
colorbar

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
set(gca, 'GridLineStyle', ':');
% text(0.02, 0.15, '(a)', 'FontSize',text_size, 'FontWeight', 'bold', 'Units','Normalized');
title('(b1) Obs. Q90 (mm/d)', 'FontSize', title_size);

grid on;
set(gca, 'GridLineStyle', ':');
set(gca, 'Color', [220 220 220]/255);





% defualt parameter --------------------------------------------------------
ax(3) = subplot(5,3,3)
variable = out_qmean_metric; obs_index = 7;              %1-gauge id, 2-lat, 3-lon, 4-cluster id,, 5-q10_mm_d, 6-q90_mm_d, 7-qmean_mm_d

cmin = 0; cmax = 2.2; 
scatter_size = 25;

cluster_ID = variable(:,4); lat = variable(:,2); lon = variable(:,3);metric_daily = out_obs(:,7);
% fmt = {'o','^','v','s','>','h','<'};
fmt = {'o','o','o','o','o','o','o'};
cluster=1; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=2; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=3; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=4; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=5; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=6; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=7; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;

set(gca,'FontSize',tick_size);

plot(US(:,1), US(:,2),'.','MarkerSize',2,'Color','black'); hold on; 
plot(SL(:,1), SL(:,2),'.','MarkerSize',2,'Color','black');
xlim([-128 -64]); ylim([23 52]); box on;
caxis([cmin cmax]);  
colormap(ax(3), brewermap([],'*Spectral'));  
colorbar

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
set(gca, 'GridLineStyle', ':');
% text(0.02, 0.15, '(a)', 'FontSize',text_size, 'FontWeight', 'bold', 'Units','Normalized');
title('(c1) Obs. Qmean (mm/d)', 'FontSize', title_size);

grid on;
set(gca, 'GridLineStyle', ':');
set(gca, 'Color', [220 220 220]/255);









% regional best parameter --------------------------------------------------------
ax(4) = subplot(5,3,4)
variable = out_q10_metric;
cluster_ID = variable(:,4); lat = variable(:,2); lon = variable(:,3);metric_daily = (out_default(:,5) - out_obs(:,5))./out_obs(:,7);
% fmt = {'o','^','v','s','>','h','<'};
fmt = {'o','o','o','o','o','o','o'};
cluster=1; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=2; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=3; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=4; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=5; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=6; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=7; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;

set(gca,'FontSize',tick_size);

plot(US(:,1), US(:,2),'.','MarkerSize',2,'Color','black'); hold on; 
plot(SL(:,1), SL(:,2),'.','MarkerSize',2,'Color','black');
xlim([-128 -64]); ylim([23 52]); box on;
% caxis([cmin cmax]);  
colormap(ax(4), brewermap([],'*RdBu'));  
% colormap(brewermap([],'RdYlBu'));  
colorbar
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
% set(gca, 'YTickLabel', []);
set(gca, 'XTickLabel', []);
set(gca, 'GridLineStyle', ':');
% text(0.02, 0.15, '(b)', 'FontSize',text_size, 'FontWeight', 'bold', 'Units','Normalized');
title('(a2) (Default Q10 − Obs. Q10) / Obs. Qmean', 'FontSize', title_size);
caxis([-0.8 0.8]);   
grid on;
set(gca, 'GridLineStyle', ':');
set(gca, 'Color', [220 220 220]/255);




% regional best parameter --------------------------------------------------------
ax(5) = subplot(5,3,5)
variable = out_q90_metric;
cluster_ID = variable(:,4); lat = variable(:,2); lon = variable(:,3);metric_daily = (out_default(:,6) - out_obs(:,6))./out_obs(:,7);
% fmt = {'o','^','v','s','>','h','<'};
fmt = {'o','o','o','o','o','o','o'};
cluster=1; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=2; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=3; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=4; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=5; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=6; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=7; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;

set(gca,'FontSize',tick_size);

plot(US(:,1), US(:,2),'.','MarkerSize',2,'Color','black'); hold on; 
plot(SL(:,1), SL(:,2),'.','MarkerSize',2,'Color','black');
xlim([-128 -64]); ylim([23 52]); box on;
% caxis([cmin cmax]);  
colormap(ax(5), brewermap([],'*RdBu'));  
% colormap( brewermap([],'*RdBu'));  
colorbar
caxis([q90_min q90_max]);   
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
set(gca, 'YTickLabel', []);
set(gca, 'XTickLabel', []);
set(gca, 'GridLineStyle', ':');
% text(0.02, 0.15, '(b)', 'FontSize',text_size, 'FontWeight', 'bold', 'Units','Normalized');
title('(b2) (Default Q90 − Obs. Q90) / Obs. Qmean', 'FontSize', title_size);

grid on;
set(gca, 'GridLineStyle', ':');
set(gca, 'Color', [220 220 220]/255);
% colormap(brewermap([],'*RdYlBu'));  





% regional best parameter --------------------------------------------------------
ax(6) = subplot(5,3,6)
variable = out_qmean_metric;
cluster_ID = variable(:,4); lat = variable(:,2); lon = variable(:,3);metric_daily = (out_default(:,7) - out_obs(:,7))./out_obs(:,7);
% fmt = {'o','^','v','s','>','h','<'};
fmt = {'o','o','o','o','o','o','o'};
cluster=1; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=2; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=3; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=4; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=5; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=6; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=7; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;

set(gca,'FontSize',tick_size);

plot(US(:,1), US(:,2),'.','MarkerSize',2,'Color','black'); hold on; 
plot(SL(:,1), SL(:,2),'.','MarkerSize',2,'Color','black');
xlim([-128 -64]); ylim([23 52]); box on;
caxis([qmean_min qmean_max]);   
colormap(ax(6), brewermap([],'*RdBu'));   
colorbar
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
set(gca, 'YTickLabel', []);
set(gca, 'XTickLabel', []);
set(gca, 'GridLineStyle', ':');
% text(0.02, 0.15, '(b)', 'FontSize',text_size, 'FontWeight', 'bold', 'Units','Normalized');
title('(c2) (Default Qmean − Obs. Qmean) / Obs. Qmean', 'FontSize', title_size);

grid on;
set(gca, 'GridLineStyle', ':');
set(gca, 'Color', [220 220 220]/255);










% GSCD regression only --------------------------------------------------------
ax(7) = subplot(5,3,7)
variable = out_q10_metric;
cluster_ID = variable(:,4); lat = variable(:,2); lon = variable(:,3);metric_daily = variable(:,6)./out_obs(:,7);
% fmt = {'o','^','v','s','>','h','<'};
fmt = {'o','o','o','o','o','o','o'};
cluster=1; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=2; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=3; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=4; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=5; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=6; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=7; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;

set(gca,'FontSize',tick_size);

plot(US(:,1), US(:,2),'.','MarkerSize',2,'Color','black'); hold on; 
plot(SL(:,1), SL(:,2),'.','MarkerSize',2,'Color','black');
xlim([-128 -64]); ylim([23 52]); box on;
% caxis([cmin cmax]);  
colormap(ax(7), brewermap([],'*RdBu'));   
colorbar
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
% set(gca, 'YTickLabel', []);
set(gca, 'XTickLabel', []);
set(gca, 'GridLineStyle', ':');
% text(0.02, 0.15, '(b)', 'FontSize',text_size, 'FontWeight', 'bold', 'Units','Normalized');
title('(a3) [R-P Q10 (mean) − Obs. Q10] / Obs. Qmean', 'FontSize', title_size);
caxis([-0.8 0.8]);     
grid on;
set(gca, 'GridLineStyle', ':');
set(gca, 'Color', [220 220 220]/255);




% GSCD regression only --------------------------------------------------------
ax(8) = subplot(5,3,8)
variable = out_q90_metric;
cluster_ID = variable(:,4); lat = variable(:,2); lon = variable(:,3);metric_daily = variable(:,6)./out_obs(:,7);
% fmt = {'o','^','v','s','>','h','<'};
fmt = {'o','o','o','o','o','o','o'};
cluster=1; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=2; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=3; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=4; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=5; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=6; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=7; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;

set(gca,'FontSize',tick_size);

plot(US(:,1), US(:,2),'.','MarkerSize',2,'Color','black'); hold on; 
plot(SL(:,1), SL(:,2),'.','MarkerSize',2,'Color','black');
xlim([-128 -64]); ylim([23 52]); box on;
caxis([q90_min q90_max]);   
colormap(ax(8), brewermap([],'*RdBu'));   
colorbar
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
set(gca, 'YTickLabel', []);
set(gca, 'XTickLabel', []);
set(gca, 'GridLineStyle', ':');
% text(0.02, 0.15, '(b)', 'FontSize',text_size, 'FontWeight', 'bold', 'Units','Normalized');
title('(b3) [R-P Q90 (mean) − Obs. Q90] / Obs. Qmean', 'FontSize', title_size);

grid on;
set(gca, 'GridLineStyle', ':');
set(gca, 'Color', [220 220 220]/255);




% GSCD regression only --------------------------------------------------------
ax(9) = subplot(5,3,9)
variable = out_qmean_metric;
cluster_ID = variable(:,4); lat = variable(:,2); lon = variable(:,3);metric_daily = variable(:,6)./out_obs(:,7);
% fmt = {'o','^','v','s','>','h','<'};
fmt = {'o','o','o','o','o','o','o'};
cluster=1; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=2; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=3; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=4; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=5; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=6; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=7; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;

set(gca,'FontSize',tick_size);

plot(US(:,1), US(:,2),'.','MarkerSize',2,'Color','black'); hold on; 
plot(SL(:,1), SL(:,2),'.','MarkerSize',2,'Color','black');
xlim([-128 -64]); ylim([23 52]); box on;
caxis([qmean_min qmean_max]);  
colormap(ax(9), brewermap([],'*RdBu'));   
colorbar
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
set(gca, 'YTickLabel', []);
set(gca, 'XTickLabel', []);
set(gca, 'GridLineStyle', ':');
% text(0.02, 0.15, '(b)', 'FontSize',text_size, 'FontWeight', 'bold', 'Units','Normalized');
title('(c3) [R-P Qmean (mean) − Obs. Qmean] / Obs. Qmean', 'FontSize', title_size);

grid on;
set(gca, 'GridLineStyle', ':');
set(gca, 'Color', [220 220 220]/255);








% GSCD regression only --------------------------------------------------------
ax(10) = subplot(5,3,10)
variable = out_q10_metric;
cluster_ID = variable(:,4); lat = variable(:,2); lon = variable(:,3);metric_daily = variable(:,7)./out_obs(:,7);
% fmt = {'o','^','v','s','>','h','<'};
fmt = {'o','o','o','o','o','o','o'};
cluster=1; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=2; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=3; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=4; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=5; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=6; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=7; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;

set(gca,'FontSize',tick_size);

plot(US(:,1), US(:,2),'.','MarkerSize',2,'Color','black'); hold on; 
plot(SL(:,1), SL(:,2),'.','MarkerSize',2,'Color','black');
xlim([-128 -64]); ylim([23 52]); box on;
% caxis([cmin cmax]);  
colormap(ax(10), brewermap([],'*RdBu'));   
colorbar
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
% set(gca, 'YTickLabel', []);
set(gca, 'XTickLabel', []);
set(gca, 'GridLineStyle', ':');
% text(0.02, 0.15, '(b)', 'FontSize',text_size, 'FontWeight', 'bold', 'Units','Normalized');
title('(a4) [R-S Q10 (mean) − Obs. Q10] / Obs. Qmean', 'FontSize', title_size);
caxis([-0.8 0.8]);    
grid on;
set(gca, 'GridLineStyle', ':');
set(gca, 'Color', [220 220 220]/255);



% GSCD regression only --------------------------------------------------------
ax(11) = subplot(5,3,11)
variable = out_q90_metric;
cluster_ID = variable(:,4); lat = variable(:,2); lon = variable(:,3);metric_daily = variable(:,7)./out_obs(:,7);
% fmt = {'o','^','v','s','>','h','<'};
fmt = {'o','o','o','o','o','o','o'};
cluster=1; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=2; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=3; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=4; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=5; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=6; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=7; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;

set(gca,'FontSize',tick_size);

plot(US(:,1), US(:,2),'.','MarkerSize',2,'Color','black'); hold on; 
plot(SL(:,1), SL(:,2),'.','MarkerSize',2,'Color','black');
xlim([-128 -64]); ylim([23 52]); box on;
caxis([q90_min q90_max]); 
colormap(ax(11), brewermap([],'*RdBu'));   
colorbar
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
set(gca, 'YTickLabel', []);
set(gca, 'XTickLabel', []);
set(gca, 'GridLineStyle', ':');
% text(0.02, 0.15, '(b)', 'FontSize',text_size, 'FontWeight', 'bold', 'Units','Normalized');
title('(b4) [R-S Q90 (mean) − Obs. Q90] / Obs. Qmean', 'FontSize', title_size);

grid on;
set(gca, 'GridLineStyle', ':');
set(gca, 'Color', [220 220 220]/255);




% GSCD regression only --------------------------------------------------------
ax(12) = subplot(5,3,12)
variable = out_qmean_metric;
cluster_ID = variable(:,4); lat = variable(:,2); lon = variable(:,3);metric_daily = variable(:,7)./out_obs(:,7);
% fmt = {'o','^','v','s','>','h','<'};
fmt = {'o','o','o','o','o','o','o'};
cluster=1; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=2; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=3; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=4; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=5; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=6; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=7; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;

set(gca,'FontSize',tick_size);

plot(US(:,1), US(:,2),'.','MarkerSize',2,'Color','black'); hold on; 
plot(SL(:,1), SL(:,2),'.','MarkerSize',2,'Color','black');
xlim([-128 -64]); ylim([23 52]); box on;
caxis([qmean_min qmean_max]);  
colormap(ax(12), brewermap([],'*RdBu'));   
colorbar
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
set(gca, 'YTickLabel', []);
set(gca, 'XTickLabel', []);
set(gca, 'GridLineStyle', ':');
% text(0.02, 0.15, '(b)', 'FontSize',text_size, 'FontWeight', 'bold', 'Units','Normalized');
title('(c4) [R-S Qmean (mean) − Obs. Qmean] / Obs. Qmean', 'FontSize', title_size);

grid on;
set(gca, 'GridLineStyle', ':');
set(gca, 'Color', [220 220 220]/255);







% GSCD hybrid only --------------------------------------------------------
ax(13) = subplot(5,3,13)
variable = out_q10_metric;
cluster_ID = variable(:,4); lat = variable(:,2); lon = variable(:,3);metric_daily = variable(:,9)./out_obs(:,7);
% fmt = {'o','^','v','s','>','h','<'};
fmt = {'o','o','o','o','o','o','o'};
cluster=1; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=2; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=3; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=4; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=5; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=6; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=7; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;

set(gca,'FontSize',tick_size);

plot(US(:,1), US(:,2),'.','MarkerSize',2,'Color','black'); hold on; 
plot(SL(:,1), SL(:,2),'.','MarkerSize',2,'Color','black');
xlim([-128 -64]); ylim([23 52]); box on;
% caxis([cmin cmax]);  
colormap(ax(13), brewermap([],'*RdBu'));   
colorbar
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
% set(gca, 'YTickLabel', []);
% set(gca, 'XTickLabel', []);
set(gca, 'GridLineStyle', ':');
% text(0.02, 0.15, '(b)', 'FontSize',text_size, 'FontWeight', 'bold', 'Units','Normalized');
title('(a5) [Hybrid Q10 (mean) − Obs. Q10] / Obs. Qmean', 'FontSize', title_size);
caxis([-0.8 0.8]);     
grid on;
set(gca, 'GridLineStyle', ':');
set(gca, 'Color', [220 220 220]/255);

xtickangle(45)




% GSCD hybrid only --------------------------------------------------------
ax(14) = subplot(5,3,14)
variable = out_q90_metric;
cluster_ID = variable(:,4); lat = variable(:,2); lon = variable(:,3);metric_daily = variable(:,9)./out_obs(:,7);
% fmt = {'o','^','v','s','>','h','<'};
fmt = {'o','o','o','o','o','o','o'};
cluster=1; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=2; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=3; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=4; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=5; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=6; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=7; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;

set(gca,'FontSize',tick_size);

plot(US(:,1), US(:,2),'.','MarkerSize',2,'Color','black'); hold on; 
plot(SL(:,1), SL(:,2),'.','MarkerSize',2,'Color','black');
xlim([-128 -64]); ylim([23 52]); box on;
caxis([q90_min q90_max]); 
colormap(ax(14), brewermap([],'*RdBu'));   
colorbar
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
set(gca, 'YTickLabel', []);
% set(gca, 'XTickLabel', []);
set(gca, 'GridLineStyle', ':');
% text(0.02, 0.15, '(b)', 'FontSize',text_size, 'FontWeight', 'bold', 'Units','Normalized');
title('(b5) [Hybrid Q90 (mean) − Obs. Q90] / Obs. Qmean', 'FontSize', title_size);
 
grid on;
set(gca, 'GridLineStyle', ':');
set(gca, 'Color', [220 220 220]/255);
xtickangle(45)





% GSCD hybrid only --------------------------------------------------------
ax(15) = subplot(5,3,15)
variable = out_qmean_metric;
cluster_ID = variable(:,4); lat = variable(:,2); lon = variable(:,3);metric_daily = variable(:,9)./out_obs(:,7);
% fmt = {'o','^','v','s','>','h','<'};
fmt = {'o','o','o','o','o','o','o'};
cluster=1; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=2; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=3; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=4; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=5; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=6; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;
cluster=7; scatter(lon(cluster_ID==cluster), lat(cluster_ID==cluster), scatter_size, metric_daily(cluster_ID==cluster), fmt{cluster},'filled', 'MarkerEdgeColor',[105 105 105]/255, 'LineWidth',line_width-0.5); hold on;

set(gca,'FontSize',tick_size);

plot(US(:,1), US(:,2),'.','MarkerSize',2,'Color','black'); hold on; 
plot(SL(:,1), SL(:,2),'.','MarkerSize',2,'Color','black');
xlim([-128 -64]); ylim([23 52]); box on;
caxis([qmean_min qmean_max]); 
colormap(ax(15), brewermap([],'*RdBu'));   
colorbar
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
set(gca, 'YTickLabel', []);
% set(gca, 'XTickLabel', []);
set(gca, 'GridLineStyle', ':');
% text(0.02, 0.15, '(b)', 'FontSize',text_size, 'FontWeight', 'bold', 'Units','Normalized');
title('(c5) [Hybrid Qmean (mean) − Obs. Qmean] / Obs. Qmean', 'FontSize', title_size);
 
grid on;
set(gca, 'GridLineStyle', ':');
set(gca, 'Color', [220 220 220]/255);
xtickangle(45)

%% output the plot

fig = gcf;
fig.PaperUnits = 'inches';
set(gcf, 'InvertHardCopy', 'off');

% fig.PaperPosition = [0 0 18 7];
fig.PaperPosition = [0 0 18*0.8 16*0.8];
print('figure', '-dpng', '-r300')


