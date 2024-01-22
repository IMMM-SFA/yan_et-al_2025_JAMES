%% find GSCD raw constrain and GSCD regression constrain

clear all; clc;

US = load('us_coor.txt');
SL = load('sl_coor.txt');
scatter_size = 20; label_size = 10; legend_size = 10; tick_size = 10; colorbar_size= 11;title_size = 10; line_width = 1; text_size = 11;

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
    out_q10_metric(i,6) = 1 - crps(temp2, out_obs(i,5)) / abs(out_default(i,5) - out_obs(i,5)); 
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
    out_q90_metric(i,6) = 1 - crps(temp2, out_obs(i,6)) / abs(out_default(i,6) - out_obs(i,6)); 
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
    out_qmean_metric(i,6) = 1 - crps(temp2, out_obs(i,7)) / abs(out_default(i,7) - out_obs(i,7));



    if out_qmean_metric(i,1) == 1144000
        regional_best_c1 = temp2;
    end
    if out_qmean_metric(i,1) == 14216500
        regional_best_c2 = temp2;
    end
    if out_qmean_metric(i,1) == 9430500
        regional_best_c3 = temp2;
    end
    if out_qmean_metric(i,1) == 9312600
        regional_best_c4 = temp2;
    end    
    if out_qmean_metric(i,1) == 8195000
        regional_best_c5 = temp2;
    end    
    if out_qmean_metric(i,1) == 5507600
        regional_best_c6 = temp2;
    end
    if out_qmean_metric(i,1) == 2363000
        regional_best_c7 = temp2;
    end 
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
        out_q10_metric(i,7) = 1 - crps(temp2, out_obs(i,5)) / abs(out_default(i,5) - out_obs(i,5)); 
    end

    if length(indices)==1
        temp2 = temp1(indices);
        out_q10_metric(i,7) = 1 - abs(temp2 - out_obs(i,5)) / abs(out_default(i,5) - out_obs(i,5)); 
    end
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
        out_q90_metric(i,7) = 1 - crps(temp2, out_obs(i,6)) / abs(out_default(i,6) - out_obs(i,6)); 
    end

    if length(indices)==1
        temp2 = temp1(indices);
        out_q90_metric(i,7) = 1 - abs(temp2 - out_obs(i,6)) / abs(out_default(i,6) - out_obs(i,6)); 
    end
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
        out_qmean_metric(i,7) = 1 - crps(temp2, out_obs(i,7)) / abs(out_default(i,7) - out_obs(i,7)); 
    end

    if length(indices)==1
        temp2 = temp1(indices);
        out_qmean_metric(i,7) = 1 - abs(temp2 - out_obs(i,7)) / abs(out_default(i,7) - out_obs(i,7)); 
    end



        if out_qmean_metric(i,1) == 1144000
        regression_c1 = temp2;
    end
    if out_qmean_metric(i,1) == 14216500
        regression_c2 = temp2;
    end
    if out_qmean_metric(i,1) == 9430500
        regression_c3 = temp2;
    end
    if out_qmean_metric(i,1) == 9312600
        regression_c4 = temp2;
    end    
    if out_qmean_metric(i,1) == 8195000
        regression_c5 = temp2;
    end    
    if out_qmean_metric(i,1) == 5507600
        regression_c6 = temp2;
    end
    if out_qmean_metric(i,1) == 2363000
        regression_c7 = temp2;
    end    

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
        out_q10_metric(i,9) = 1 - crps(temp2, out_obs(i,5)) / abs(out_default(i,5) - out_obs(i,5));
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
        out_q10_metric(i,9) = 1 - crps(temp2, out_obs(i,5)) / abs(out_default(i,5) - out_obs(i,5));
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
        out_q10_metric(i,9) = 1 - crps(temp2, out_obs(i,5)) / abs(out_default(i,5) - out_obs(i,5)); 
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


    if out_qmean_metric(i,1) == 1144000
        hybrid_c1 = temp2;
    end
    if out_qmean_metric(i,1) == 14216500
        hybrid_c2 = temp2;
    end
    if out_qmean_metric(i,1) == 9430500
        hybrid_c3 = temp2;
    end
    if out_qmean_metric(i,1) == 9312600
        hybrid_c4 = temp2;
    end    
    if out_qmean_metric(i,1) == 8195000
        hybrid_c5 = temp2;
    end    
    if out_qmean_metric(i,1) == 5507600
        hybrid_c6 = temp2;
    end
    if out_qmean_metric(i,1) == 2363000
        hybrid_c7 = temp2;
    end



end



%%  plot the metric

figure;

% regional best parameter --------------------------------------------------------
ax(1) = subplot(3,3,1)
gauge_id = 1144000;
index = find(out_qmean_metric(:,1)==gauge_id);
[f,xi] = ksdensity(regional_best_c1); 
fill([xi fliplr(xi)], [f zeros(size(f))], 'b', 'FaceAlpha', 0.2, 'EdgeColor', 'none'); hold on;
% plot(xi,f); hold on; 
[f,xi] = ksdensity(regression_c1); 
fill([xi fliplr(xi)], [f zeros(size(f))],  [0.8500 0.3250 0.0980], 'FaceAlpha', 0.3, 'EdgeColor', 'none'); hold on;
% plot(xi,f); hold on;
xline(out_obs(index, 7), '--g', 'Linewidth', line_width+1); 
xline(out_default(index, 7), '--r', 'Linewidth', line_width+1);  
% xline(out_regional(index, 7), '--g', 'Linewidth', line_width+1); 
xlabel('Qmean (mm/d)', 'FontSize', label_size);  
ylabel('Density', 'FontSize', label_size); 
title('(a) C1-Northeast: Gauge 01144000', 'FontSize', label_size)
% legend('GSCD Data Constrain', 'GSCD Regression 95% P.I. Constrain', 'Obs.', 'Default Parameter', 'Regional Best Parameter')
set(gca,'FontSize',tick_size);
% text(0.05, 0.15, '(a)', 'FontSize',text_size, 'FontWeight', 'bold', 'Units','Normalized')
text(0.05, 0.9, 'CRPSS R-P = −0.15', 'FontSize',text_size, 'Units','Normalized')
text(0.05, 0.80, 'CRPSS Hybrid/R-S = 0.23', 'FontSize',text_size,  'Units','Normalized')
ylim([0, 10]);

ax(2) = subplot(3,3,2)
gauge_id = 14216500;
index = find(out_qmean_metric(:,1)==gauge_id);
[f,xi] = ksdensity(regional_best_c2); 
fill([xi fliplr(xi)], [f zeros(size(f))], 'b', 'FaceAlpha', 0.2, 'EdgeColor', 'none'); hold on;
% plot(xi,f); hold on; 
[f,xi] = ksdensity(regression_c2); 
fill([xi fliplr(xi)], [f zeros(size(f))],  [0.8500 0.3250 0.0980], 'FaceAlpha', 0.3, 'EdgeColor', 'none'); hold on;
% plot(xi,f); hold on;
xline(out_obs(index, 7), '--g', 'Linewidth', line_width+1); 
xline(out_default(index, 7), '--r', 'Linewidth', line_width+1);  
% xline(out_regional(index, 7), '--g', 'Linewidth', line_width+1); 
xlabel('Qmean (mm/d)', 'FontSize', label_size);  
ylabel('Density', 'FontSize', label_size); 
title('(b) C2-Pacific: Gauge 14216500', 'FontSize', label_size)
% legend('GSCD Data Constrain', 'GSCD Regression 95% P.I. Constrain', 'Obs.', 'Default Parameter', 'Regional Best Parameter')
set(gca,'FontSize',tick_size);
% text(0.05, 0.15, '(a)', 'FontSize',text_size, 'FontWeight', 'bold', 'Units','Normalized')
text(0.05, 0.9, 'CRPSS R-P = 0.50', 'FontSize',text_size, 'Units','Normalized')
text(0.05, 0.80, 'CRPSS Hybrid/R-S = 0.10', 'FontSize',text_size,  'Units','Normalized')
ylim([0, 3.5]);

ax(3) = subplot(3,3,3)
gauge_id = 09430500;
index = find(out_qmean_metric(:,1)==gauge_id);
[f,xi] = ksdensity(regional_best_c3); 
fill([xi fliplr(xi)], [f zeros(size(f))], 'b', 'FaceAlpha', 0.2, 'EdgeColor', 'none'); hold on;
% plot(xi,f); hold on; 
[f,xi] = ksdensity(regression_c3); 
fill([xi fliplr(xi)], [f zeros(size(f))],  [0.8500 0.3250 0.0980], 'FaceAlpha', 0.3, 'EdgeColor', 'none'); hold on;
% plot(xi,f); hold on;
xline(out_obs(index, 7), '--g', 'Linewidth', line_width+1); 
xline(out_default(index, 7), '--r', 'Linewidth', line_width+1);  
% xline(out_regional(index, 7), '--g', 'Linewidth', line_width+1); 
xlabel('Qmean (mm/d)', 'FontSize', label_size);  
ylabel('Density', 'FontSize', label_size); 
title('(c) C3-AZ/NM: Gauge 09430500', 'FontSize', label_size)
% legend('GSCD Data Constrain', 'GSCD Regression 95% P.I. Constrain', 'Obs.', 'Default Parameter', 'Regional Best Parameter')
set(gca,'FontSize',tick_size);
% text(0.05, 0.15, '(a)', 'FontSize',text_size, 'FontWeight', 'bold', 'Units','Normalized')
text(0.05, 0.9, 'CRPSS R-P = −0.01', 'FontSize',text_size, 'Units','Normalized')
text(0.05, 0.80, 'CRPSS Hybrid/R-S = 0.58', 'FontSize',text_size,  'Units','Normalized')
ylim([0, 25]);



ax(4) = subplot(3,3,4)
gauge_id = 09312600;
index = find(out_qmean_metric(:,1)==gauge_id);
[f,xi] = ksdensity(regional_best_c4); 
fill([xi fliplr(xi)], [f zeros(size(f))], 'b', 'FaceAlpha', 0.2, 'EdgeColor', 'none'); hold on;
% plot(xi,f); hold on; 
[f,xi] = ksdensity(regression_c4); 
fill([xi fliplr(xi)], [f zeros(size(f))],  [0.8500 0.3250 0.0980], 'FaceAlpha', 0.3, 'EdgeColor', 'none'); hold on;
% plot(xi,f); hold on;
xline(out_obs(index, 7), '--g', 'Linewidth', line_width+1); 
xline(out_default(index, 7), '--r', 'Linewidth', line_width+1);  
% xline(out_regional(index, 7), '--g', 'Linewidth', line_width+1); 
xlabel('Qmean (mm/d)', 'FontSize', label_size);  
ylabel('Density', 'FontSize', label_size); 
title('(d) C4-Rockies: Gauge 09312600', 'FontSize', label_size)
% legend('GSCD Data Constrain', 'GSCD Regression 95% P.I. Constrain', 'Obs.', 'Default Parameter', 'Regional Best Parameter')
set(gca,'FontSize',tick_size);
% text(0.05, 0.15, '(a)', 'FontSize',text_size, 'FontWeight', 'bold', 'Units','Normalized')
text(0.05, 0.9, 'CRPSS R-P = 0.11', 'FontSize',text_size, 'Units','Normalized')
text(0.05, 0.80, 'CRPSS Hybrid/R-S = 0.79', 'FontSize',text_size,  'Units','Normalized')
ylim([0, 24]);



ax(5) = subplot(3,3,5)
gauge_id = 08195000;
index = find(out_qmean_metric(:,1)==gauge_id);
[f,xi] = ksdensity(regional_best_c5); 
fill([xi fliplr(xi)], [f zeros(size(f))], 'b', 'FaceAlpha', 0.2, 'EdgeColor', 'none'); hold on;
% plot(xi,f); hold on; 
[f,xi] = ksdensity(regression_c5); 
fill([xi fliplr(xi)], [f zeros(size(f))],  [0.8500 0.3250 0.0980], 'FaceAlpha', 0.3, 'EdgeColor', 'none'); hold on;
% plot(xi,f); hold on;
xline(out_obs(index, 7), '--g', 'Linewidth', line_width+1); 
xline(out_default(index, 7), '--r', 'Linewidth', line_width+1);  
% xline(out_regional(index, 7), '--g', 'Linewidth', line_width+1); 
xlabel('Qmean (mm/d)', 'FontSize', label_size);  
ylabel('Density', 'FontSize', label_size); 
title('(e) C5-Great Plains: Gauge 08195000', 'FontSize', label_size)
% legend('GSCD Data Constrain', 'GSCD Regression 95% P.I. Constrain', 'Obs.', 'Default Parameter', 'Regional Best Parameter')
set(gca,'FontSize',tick_size);
% text(0.05, 0.15, '(a)', 'FontSize',text_size, 'FontWeight', 'bold', 'Units','Normalized')
text(0.05, 0.9, 'CRPSS R-P = 0.75', 'FontSize',text_size, 'Units','Normalized')
text(0.05, 0.80, 'CRPSS Hybrid/R-S = 0.86', 'FontSize',text_size,  'Units','Normalized')
ylim([0, 12]);
xlim([0, 0.5]);


ax(6) = subplot(3,3,6)
gauge_id = 05507600;
index = find(out_qmean_metric(:,1)==gauge_id);
[f,xi] = ksdensity(regional_best_c6); 
fill([xi fliplr(xi)], [f zeros(size(f))], 'b', 'FaceAlpha', 0.2, 'EdgeColor', 'none'); hold on;
% plot(xi,f); hold on; 
[f,xi] = ksdensity(regression_c6); 
fill([xi fliplr(xi)], [f zeros(size(f))],  [0.8500 0.3250 0.0980], 'FaceAlpha', 0.3, 'EdgeColor', 'none'); hold on;
% plot(xi,f); hold on;
xline(out_obs(index, 7), '--g', 'Linewidth', line_width+1); 
xline(out_default(index, 7), '--r', 'Linewidth', line_width+1);  
% xline(out_regional(index, 7), '--g', 'Linewidth', line_width+1); 
xlabel('Qmean (mm/d)', 'FontSize', label_size);  
ylabel('Density', 'FontSize', label_size); 
title('(f) C6-Midwest: Gauge 05507600', 'FontSize', label_size)
% legend('GSCD Data Constrain', 'GSCD Regression 95% P.I. Constrain', 'Obs.', 'Default Parameter', 'Regional Best Parameter')
set(gca,'FontSize',tick_size);
% text(0.05, 0.15, '(a)', 'FontSize',text_size, 'FontWeight', 'bold', 'Units','Normalized')
text(0.05, 0.9, 'CRPSS R-P = 0.45', 'FontSize',text_size, 'Units','Normalized')
text(0.05, 0.80, 'CRPSS Hybrid/R-S = 0.92', 'FontSize',text_size,  'Units','Normalized')
ylim([0, 4]);


ax(7) = subplot(3,3,7)
gauge_id = 02363000;
index = find(out_qmean_metric(:,1)==gauge_id);
[f,xi] = ksdensity(regional_best_c7); 
fill([xi fliplr(xi)], [f zeros(size(f))], 'b', 'FaceAlpha', 0.2, 'EdgeColor', 'none'); hold on;
% plot(xi,f); hold on; 
[f,xi] = ksdensity(regression_c7); 
fill([xi fliplr(xi)], [f zeros(size(f))],  [0.8500 0.3250 0.0980], 'FaceAlpha', 0.3, 'EdgeColor', 'none'); hold on;
% plot(xi,f); hold on;
xline(out_obs(index, 7), '--g', 'Linewidth', line_width+1); 
xline(out_default(index, 7), '--r', 'Linewidth', line_width+1);  
% xline(out_regional(index, 7), '--g', 'Linewidth', line_width+1); 
xlabel('Qmean (mm/d)', 'FontSize', label_size);  
ylabel('Density', 'FontSize', label_size); 
title('(g) C7-Southeast: Gauge 02363000', 'FontSize', label_size)
% legend('GSCD Data Constrain', 'GSCD Regression 95% P.I. Constrain', 'Obs.', 'Default Parameter', 'Regional Best Parameter')
set(gca,'FontSize',tick_size);
% text(0.05, 0.15, '(a)', 'FontSize',text_size, 'FontWeight', 'bold', 'Units','Normalized')
text(0.05, 0.9, 'CRPSS R-P = 0.14', 'FontSize',text_size, 'Units','Normalized')
text(0.05, 0.80, 'CRPSS Hybrid/R-S = 0.63', 'FontSize',text_size,  'Units','Normalized')
ylim([0, 6]);










ax(1) = subplot(3,3,8)
gauge = [1144000, 14216500, 9430500, 9312600, 8195000, 5507600, 2363000];
coor = nan(7, 2);
for i = 1:7
    index = find(out_qmean_metric(:,1)==gauge(i));
    coor(i,1:2) = out_qmean_metric(index,2:3);
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


