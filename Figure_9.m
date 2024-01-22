
clear all; clc;
days = 3650;

data = readtable('H:\SA_HY\1500Ensemble\flow_metrics/default_daily_metrics.csv');
lat = data.Var2; lon = data.Var3; cluster_ID = data.Var4; basin_ID = data.Var1; clear data;
gauge = 5507600;

% load default
default_m_flow = nan(1, days);
obs_m_flow = nan(1, days);
data = load('H:\SA_HY\1500Ensemble\basin_index_areaKM2.txt');
basin_area = data(:,6)*1000000;  % m^2
index = find(data(:,1)==gauge);
basin_area = basin_area(index);

data = (load(sprintf('H:\\SA_HY\\1500Ensemble\\default_flow\\%08d_daily', gauge)));
data(:,4:5) = data(:,4:5)/basin_area*1000*24*60*60;  % mm/day
default_m_flow(1,:) = data(:,4)';
obs_m_flow(1,:) = data(:,5)';
obs_m_flow(obs_m_flow<0) = nan;

% load ensemble flow
data = (load(sprintf('H:\\SA_HY\\1500Ensemble\\ensemble_flow\\%08d_daily_ensemble', gauge)));
data(data<0)=0;
data = data/basin_area*1000*24*60*60;  % mm/day


par1000 = load('./sucessful_par_id_1000');
par1307 = load('./sucessful_par_id_1307');
index1000 = ismember(par1307, par1000);

data = data(:,index1000);



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

index = find(out_obs(:,1)==gauge);
out_obs = out_obs(index,:);
obs_q10 = out_obs(1,5);
obs_q90 = out_obs(1,6);
obs_qmean = out_obs(1,7);

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
index = find(out_default(:,1)==gauge);
out_default = out_default(index,:);
def_q10 = out_default(1,5);
def_q90 = out_default(1,6);
def_qmean = out_default(1,7);





%%
q_obs = nan(1, 9);
q_def = nan(1, 9);
q_min_prior = nan(1, 9);
q_max_prior = nan(1, 9);
q_min_q10 = nan(1, 9);
q_max_q10 = nan(1, 9);
q_min_q90 = nan(1, 9);
q_max_q90 = nan(1, 9);
q_min_qmean = nan(1, 9);
q_max_qmean = nan(1, 9);
q_min_qmean_q10 = nan(1, 9);
q_max_qmean_q10 = nan(1, 9);
q_min_qmean_q90 = nan(1, 9);
q_max_qmean_q90 = nan(1, 9);
q_min_q10_q90 = nan(1, 9);
q_max_q10_q90 = nan(1, 9);
q_min_all = nan(1, 9);
q_max_all = nan(1, 9);

quantiles = [1, 5, 10, 25, 50, 75, 90, 95, 99]/100;
for i = 1:9
    q_obs(1,i) = quantile(obs_m_flow, quantiles(i));
    q_def(1,i) = quantile(default_m_flow, quantiles(i));
    q_min_prior(1,i) = min(quantile(data, quantiles(i)));
    q_max_prior(1,i) = max(quantile(data, quantiles(i)));
end


var = nan(1, 10); % 1-gauge id, 2-lat, 3-lon, 4-cluster id, 5-q10 low, 6-q_10 up, 7-q90 low, 8-q90 up, 9-qmean low, 10-qmean up
temp = table2array(readtable('../gscd_camel_regression/q10.csv'));
index = find(temp(:,1)==gauge);
var(1,1) = temp(index,1); var(1,2) = temp(index,3); var(1,3) = temp(index,4); var(1,4) = temp(index,2); var(1,5) = temp(index,7); var(1,6) = temp(index,8); 
temp = table2array(readtable('../gscd_camel_regression/q90.csv'));
index = find(temp(:,1)==gauge);
var(1,7) = temp(index,7); var(1,8) = temp(index,8); 
temp = table2array(readtable('../gscd_camel_regression/qmean.csv'));
index = find(temp(:,1)==gauge);
var(1,9) = temp(index,7); var(1,10) = temp(index,8); 



% q10 CRPS value
temp = table2array(readtable('../../ensemble_sim/ensemble_q10'));
index = find(temp(:,1)==gauge);
temp1 = temp(index, 5:end);
temp1 = temp1(index1000);
low = var(1,5);
up  = var(1,6);
indices = find(temp1 > low & temp1 < up);
q10_ensemble = temp1(indices);
crps_q10_q10 = 1 - crps(q10_ensemble, obs_q10) / abs(obs_q10 - def_q10);

temp = table2array(readtable('../../ensemble_sim/ensemble_q90'));
index = find(temp(:,1)==gauge);
temp1 = temp(index, 5:end);
temp1 = temp1(index1000);
q90_ensemble = temp1(indices);
crps_q10_q90 = 1 - crps(q90_ensemble, obs_q90) / abs(obs_q90 - def_q90);

temp = table2array(readtable('../../ensemble_sim/ensemble_qmean'));
index = find(temp(:,1)==gauge);
temp1 = temp(index, 5:end);
temp1 = temp1(index1000);
qmean_ensemble = temp1(indices);
crps_q10_qmean = 1 - crps(qmean_ensemble, obs_qmean) / abs(obs_qmean - def_qmean);












% q10 
temp = table2array(readtable('../../ensemble_sim/ensemble_q10'));
index = find(temp(:,1)==gauge);
temp1 = temp(index, 5:end);
temp1 = temp1(index1000);
low = var(1,5);
up  = var(1,6);
indices = find(temp1 > low & temp1 < up);


ensemble = nan(3650, length(indices));
for i = 1:length(indices)
    ensemble(:,i) = data(:,indices(i));
end
for i = 1:9
    q_min_q10(1,i) = min(quantile(ensemble, quantiles(i)));
    q_max_q10(1,i) = max(quantile(ensemble, quantiles(i)));
end


% q90 CRPS value
temp = table2array(readtable('../../ensemble_sim/ensemble_q90'));
index = find(temp(:,1)==gauge);
temp1 = temp(index, 5:end);
temp1 = temp1(index1000);
low = var(1,7);
up  = var(1,8);
indices = find(temp1 > low & temp1 < up);
q10_ensemble = temp1(indices);
crps_q90_q10 = 1 - crps(q10_ensemble, obs_q10) / abs(obs_q10 - def_q10);

temp = table2array(readtable('../../ensemble_sim/ensemble_q90'));
index = find(temp(:,1)==gauge);
temp1 = temp(index, 5:end);
temp1 = temp1(index1000);
q90_ensemble = temp1(indices);
crps_q90_q90 = 1 - crps(q90_ensemble, obs_q90) / abs(obs_q90 - def_q90);

temp = table2array(readtable('../../ensemble_sim/ensemble_qmean'));
index = find(temp(:,1)==gauge);
temp1 = temp(index, 5:end);
temp1 = temp1(index1000);
qmean_ensemble = temp1(indices);
crps_q90_qmean = 1 - crps(qmean_ensemble, obs_qmean) / abs(obs_qmean - def_qmean);







% q90 
temp = table2array(readtable('../../ensemble_sim/ensemble_q90'));
index = find(temp(:,1)==gauge);
temp1 = temp(index, 5:end);
temp1 = temp1(index1000);
low = var(1,7);
up  = var(1,8);
indices = find(temp1 > low & temp1 < up);
ensemble = nan(3650, length(indices));
for i = 1:length(indices)
    ensemble(:,i) = data(:,indices(i));
end
for i = 1:9
    q_min_q90(1,i) = min(quantile(ensemble, quantiles(i)));
    q_max_q90(1,i) = max(quantile(ensemble, quantiles(i)));
end






% qmean CRPS value
temp = table2array(readtable('../../ensemble_sim/ensemble_qmean'));
index = find(temp(:,1)==gauge);
temp1 = temp(index, 5:end);
temp1 = temp1(index1000);
low = var(1,9);
up  = var(1,10);
indices = find(temp1 > low & temp1 < up);
q10_ensemble = temp1(indices);
crps_qmean_q10 = 1 - crps(q10_ensemble, obs_q10) / abs(obs_q10 - def_q10);

temp = table2array(readtable('../../ensemble_sim/ensemble_q90'));
index = find(temp(:,1)==gauge);
temp1 = temp(index, 5:end);
temp1 = temp1(index1000);
q90_ensemble = temp1(indices);
crps_qmean_q90 = 1 - crps(q90_ensemble, obs_q90) / abs(obs_q90 - def_q90);

temp = table2array(readtable('../../ensemble_sim/ensemble_qmean'));
index = find(temp(:,1)==gauge);
temp1 = temp(index, 5:end);
temp1 = temp1(index1000);
qmean_ensemble = temp1(indices);
crps_qmean_qmean = 1 - crps(qmean_ensemble, obs_qmean) / abs(obs_qmean - def_qmean);





% qmean
temp = table2array(readtable('../../ensemble_sim/ensemble_qmean'));
index = find(temp(:,1)==gauge);
temp1 = temp(index, 5:end);
temp1 = temp1(index1000);
low = var(1,9);
up  = var(1,10);
indices = find(temp1 > low & temp1 < up);
ensemble = nan(3650, length(indices));
for i = 1:length(indices)
    ensemble(:,i) = data(:,indices(i));
end
for i = 1:9
    q_min_qmean(1,i) = min(quantile(ensemble, quantiles(i)));
    q_max_qmean(1,i) = max(quantile(ensemble, quantiles(i)));
end





% q10 and q90 CRPS value
temp = table2array(readtable('../../ensemble_sim/ensemble_q10'));
index = find(temp(:,1)==gauge);
temp1 = temp(index, 5:end);
temp1 = temp1(index1000);
low = var(1,5);
up  = var(1,6);
indices1 = find(temp1 > low & temp1 < up);

temp = table2array(readtable('../../ensemble_sim/ensemble_q90'));
index = find(temp(:,1)==gauge);
temp1 = temp(index, 5:end);
temp1 = temp1(index1000);
low = var(1,7);
up  = var(1,8);
indices2 = find(temp1 > low & temp1 < up);

indices = intersect(indices1, indices2);
q10_ensemble = temp1(indices);
crps_q10_q90_q10 = 1 - crps(q10_ensemble, obs_q10) / abs(obs_q10 - def_q10);

temp = table2array(readtable('../../ensemble_sim/ensemble_q90'));
index = find(temp(:,1)==gauge);
temp1 = temp(index, 5:end);
temp1 = temp1(index1000);
q90_ensemble = temp1(indices);
crps_q10_q90_q90 = 1 - crps(q90_ensemble, obs_q90) / abs(obs_q90 - def_q90);

temp = table2array(readtable('../../ensemble_sim/ensemble_qmean'));
index = find(temp(:,1)==gauge);
temp1 = temp(index, 5:end);
temp1 = temp1(index1000);
qmean_ensemble = temp1(indices);
crps_q10_q90_qmean = 1 - crps(qmean_ensemble, obs_qmean) / abs(obs_qmean - def_qmean);



% q10 & q90
temp = table2array(readtable('../../ensemble_sim/ensemble_q10'));
index = find(temp(:,1)==gauge);
temp1 = temp(index, 5:end);
temp1 = temp1(index1000);
low = var(1,5);
up  = var(1,6);
indices1 = find(temp1 > low & temp1 < up);

temp = table2array(readtable('../../ensemble_sim/ensemble_q90'));
index = find(temp(:,1)==gauge);
temp1 = temp(index, 5:end);
temp1 = temp1(index1000);
low = var(1,7);
up  = var(1,8);
indices2 = find(temp1 > low & temp1 < up);

indices = intersect(indices1, indices2);

ensemble = nan(3650, length(indices));
for i = 1:length(indices)
    ensemble(:,i) = data(:,indices(i));
end
for i = 1:9
    q_min_q10_q90(1,i) = min(quantile(ensemble, quantiles(i)));
    q_max_q10_q90(1,i) = max(quantile(ensemble, quantiles(i)));
end



% qmean and q10 CRPS value
temp = table2array(readtable('../../ensemble_sim/ensemble_q10'));
index = find(temp(:,1)==gauge);
temp1 = temp(index, 5:end);
temp1 = temp1(index1000);
low = var(1,5);
up  = var(1,6);
indices1 = find(temp1 > low & temp1 < up);

temp = table2array(readtable('../../ensemble_sim/ensemble_qmean'));
index = find(temp(:,1)==gauge);
temp1 = temp(index, 5:end);
temp1 = temp1(index1000);
low = var(1,9);
up  = var(1,10);
indices2 = find(temp1 > low & temp1 < up);

indices = intersect(indices1, indices2);
q10_ensemble = temp1(indices);
crps_q10_qmean_q10 = 1 - crps(q10_ensemble, obs_q10) / abs(obs_q10 - def_q10);

temp = table2array(readtable('../../ensemble_sim/ensemble_q90'));
index = find(temp(:,1)==gauge);
temp1 = temp(index, 5:end);
temp1 = temp1(index1000);
q90_ensemble = temp1(indices);
crps_q10_qmean_q90 = 1 - crps(q90_ensemble, obs_q90) / abs(obs_q90 - def_q90);

temp = table2array(readtable('../../ensemble_sim/ensemble_qmean'));
index = find(temp(:,1)==gauge);
temp1 = temp(index, 5:end);
temp1 = temp1(index1000);
qmean_ensemble = temp1(indices);
crps_q10_qmean_qmean = 1 - crps(qmean_ensemble, obs_qmean) / abs(obs_qmean - def_qmean);









% qmean & q10
temp = table2array(readtable('../../ensemble_sim/ensemble_q10'));
index = find(temp(:,1)==gauge);
temp1 = temp(index, 5:end);
temp1 = temp1(index1000);
low = var(1,5);
up  = var(1,6);
indices1 = find(temp1 > low & temp1 < up);

temp = table2array(readtable('../../ensemble_sim/ensemble_qmean'));
index = find(temp(:,1)==gauge);
temp1 = temp(index, 5:end);
temp1 = temp1(index1000);
low = var(1,9);
up  = var(1,10);
indices2 = find(temp1 > low & temp1 < up);

indices = intersect(indices1, indices2);

ensemble = nan(3650, length(indices));
for i = 1:length(indices)
    ensemble(:,i) = data(:,indices(i));
end
for i = 1:9
    q_min_qmean_q10(1,i) = min(quantile(ensemble, quantiles(i)));
    q_max_qmean_q10(1,i) = max(quantile(ensemble, quantiles(i)));
end





% qmean and q90 CRPS value
temp = table2array(readtable('../../ensemble_sim/ensemble_q90'));
index = find(temp(:,1)==gauge);
temp1 = temp(index, 5:end);
temp1 = temp1(index1000);
low = var(1,7);
up  = var(1,8);
indices1 = find(temp1 > low & temp1 < up);

temp = table2array(readtable('../../ensemble_sim/ensemble_qmean'));
index = find(temp(:,1)==gauge);
temp1 = temp(index, 5:end);
temp1 = temp1(index1000);
low = var(1,9);
up  = var(1,10);
indices2 = find(temp1 > low & temp1 < up);

indices = intersect(indices1, indices2);
q10_ensemble = temp1(indices);
crps_q90_qmean_q10 = 1 - crps(q10_ensemble, obs_q10) / abs(obs_q10 - def_q10);

temp = table2array(readtable('../../ensemble_sim/ensemble_q90'));
index = find(temp(:,1)==gauge);
temp1 = temp(index, 5:end);
temp1 = temp1(index1000);
q90_ensemble = temp1(indices);
crps_q90_qmean_q90 = 1 - crps(q90_ensemble, obs_q90) / abs(obs_q90 - def_q90);

temp = table2array(readtable('../../ensemble_sim/ensemble_qmean'));
index = find(temp(:,1)==gauge);
temp1 = temp(index, 5:end);
temp1 = temp1(index1000);
qmean_ensemble = temp1(indices);
crps_q90_qmean_qmean = 1 - crps(qmean_ensemble, obs_qmean) / abs(obs_qmean - def_qmean);








% qmean & q90
temp = table2array(readtable('../../ensemble_sim/ensemble_q90'));
index = find(temp(:,1)==gauge);
temp1 = temp(index, 5:end);
temp1 = temp1(index1000);
low = var(1,7);
up  = var(1,8);
indices1 = find(temp1 > low & temp1 < up);

temp = table2array(readtable('../../ensemble_sim/ensemble_qmean'));
index = find(temp(:,1)==gauge);
temp1 = temp(index, 5:end);
temp1 = temp1(index1000);
low = var(1,9);
up  = var(1,10);
indices2 = find(temp1 > low & temp1 < up);

indices = intersect(indices1, indices2);

ensemble = nan(3650, length(indices));
for i = 1:length(indices)
    ensemble(:,i) = data(:,indices(i));
end
for i = 1:9
    q_min_qmean_q90(1,i) = min(quantile(ensemble, quantiles(i)));
    q_max_qmean_q90(1,i) = max(quantile(ensemble, quantiles(i)));
end




% qmean and q90 and q10 CRPS value
temp = table2array(readtable('../../ensemble_sim/ensemble_q90'));
index = find(temp(:,1)==gauge);
temp1 = temp(index, 5:end);
temp1 = temp1(index1000);
low = var(1,7);
up  = var(1,8);
indices1 = find(temp1 > low & temp1 < up);

temp = table2array(readtable('../../ensemble_sim/ensemble_qmean'));
index = find(temp(:,1)==gauge);
temp1 = temp(index, 5:end);
temp1 = temp1(index1000);
low = var(1,9);
up  = var(1,10);
indices2 = find(temp1 > low & temp1 < up);

temp = table2array(readtable('../../ensemble_sim/ensemble_q10'));
index = find(temp(:,1)==gauge);
temp1 = temp(index, 5:end);
temp1 = temp1(index1000);
low = var(1,5);
up  = var(1,6);
indices3 = find(temp1 > low & temp1 < up);



indices4 = intersect(indices1, indices2);
indices = intersect(indices4, indices3);
q10_ensemble = temp1(indices);
crps_q10_q90_qmean_q10 = 1 - crps(q10_ensemble, obs_q10) / abs(obs_q10 - def_q10);

temp = table2array(readtable('../../ensemble_sim/ensemble_q90'));
index = find(temp(:,1)==gauge);
temp1 = temp(index, 5:end);
temp1 = temp1(index1000);
q90_ensemble = temp1(indices);
crps_q10_q90_qmean_q90 = 1 - crps(q90_ensemble, obs_q90) / abs(obs_q90 - def_q90);

temp = table2array(readtable('../../ensemble_sim/ensemble_qmean'));
index = find(temp(:,1)==gauge);
temp1 = temp(index, 5:end);
temp1 = temp1(index1000);
qmean_ensemble = temp1(indices);
crps_q10_q90_qmean_qmean = 1 - crps(qmean_ensemble, obs_qmean) / abs(obs_qmean - def_qmean);






% qmean & q90 & q10
temp = table2array(readtable('../../ensemble_sim/ensemble_q90'));
index = find(temp(:,1)==gauge);
temp1 = temp(index, 5:end);
temp1 = temp1(index1000);
low = var(1,7);
up  = var(1,8);
indices1 = find(temp1 > low & temp1 < up);

temp = table2array(readtable('../../ensemble_sim/ensemble_qmean'));
index = find(temp(:,1)==gauge);
temp1 = temp(index, 5:end);
temp1 = temp1(index1000);
low = var(1,9);
up  = var(1,10);
indices2 = find(temp1 > low & temp1 < up);

temp = table2array(readtable('../../ensemble_sim/ensemble_q10'));
index = find(temp(:,1)==gauge);
temp1 = temp(index, 5:end);
temp1 = temp1(index1000);
low = var(1,5);
up  = var(1,6);
indices3 = find(temp1 > low & temp1 < up);



indices4 = intersect(indices1, indices2);
indices = intersect(indices4, indices3);


ensemble = nan(3650, length(indices));
for i = 1:length(indices)
    ensemble(:,i) = data(:,indices(i));
end
for i = 1:9
    q_min_all(1,i) = min(quantile(ensemble, quantiles(i)));
    q_max_all(1,i) = max(quantile(ensemble, quantiles(i)));
end

%%
marksize=5; linewidth=2;tick_size=10;label_size=10;title_size=10;legend_size=10;text_size=10;

subplot(3,3,1)
clear temp; x=1:9;
h1 = plot(x, q_obs, '-o','MarkerSize',marksize,'Color',[205 92 92]/255,'linewidth',linewidth,'MarkerFaceColor',[205 92 92]/255); hold on; 
h2 = plot(x, q_def, '-o','MarkerSize',marksize,'Color',[100 149 237]/255,'linewidth',linewidth,'MarkerFaceColor',[100 149 237]/255); hold on;     

c = [0, 128, 0]/255;
ensemble_M_min = q_min_prior;
ensemble_M_max = q_max_prior;



x2 = [x, fliplr(x)];
inBetween = [ensemble_M_min, fliplr(ensemble_M_max)];

h3 = fill(x2, inBetween, c); alpha(h3, .2); hold on;
h3.EdgeColor = 'none';


c = [255 127 80]/255;
ensemble_M_min = q_min_q10;
ensemble_M_max = q_max_q10;

x2 = [x, fliplr(x)];
inBetween = [ensemble_M_min, fliplr(ensemble_M_max)];

h4 = fill(x2, inBetween, c); alpha(h4, .2); hold on;
h4.EdgeColor = 'none';



% set(gca, 'YScale', 'log')
ylabel('Daily Runoff (mm/day)', 'FontSize', label_size);
title('(a) Q10 Constrain', 'FontSize', title_size);
xticks([1 2 3 4 5 6 7 8 9])
xticklabels({'0.01','0.05','0.10','0.25','0.50','0.75','0.90','0.95','0.99'})
xlabel('FDC Non-exceedance Probability', 'FontSize', label_size);
% grid on;
xlim([3, 7]);
ylim([0,6]);
set(gca,'FontSize',tick_size);
% l = legend([h1, h2, h3, h4], {'Obs.', 'Default Sim.', 'Prior Range', 'Behavioral Range'});
% set(l,'FontSize',legend_size, 'Location','northwest','Orientation','vertical'); 
% legend boxoff
grid on;
box on;
text(0.05, 0.9, sprintf('CRPSS Q10 = %3.2f', crps_q10_q10), 'FontSize',text_size, 'Units','Normalized')
text(0.05, 0.80, sprintf('CRPSS Q90 = %3.2f', crps_q10_q90), 'FontSize',text_size,  'Units','Normalized')
text(0.05, 0.70, sprintf('CRPSS Qmean = %3.2f', crps_q10_qmean), 'FontSize',text_size,  'Units','Normalized')





subplot(3,3,2)
clear temp; x=1:9;
h1 = plot(x, q_obs, '-o','MarkerSize',marksize,'Color',[205 92 92]/255,'linewidth',linewidth,'MarkerFaceColor',[205 92 92]/255); hold on; 
h2 = plot(x, q_def, '-o','MarkerSize',marksize,'Color',[100 149 237]/255,'linewidth',linewidth,'MarkerFaceColor',[100 149 237]/255); hold on;     

c = [0, 128, 0]/255;
ensemble_M_min = q_min_prior;
ensemble_M_max = q_max_prior;

x2 = [x, fliplr(x)];
inBetween = [ensemble_M_min, fliplr(ensemble_M_max)];

h3 = fill(x2, inBetween, c); alpha(h3, .2); hold on;
h3.EdgeColor = 'none';


c = [255 127 80]/255;
ensemble_M_min = q_min_q90;
ensemble_M_max = q_max_q90;

x2 = [x, fliplr(x)];
inBetween = [ensemble_M_min, fliplr(ensemble_M_max)];

h3 = fill(x2, inBetween, c); alpha(h3, .2); hold on;
h3.EdgeColor = 'none';



% set(gca, 'YScale', 'log')
ylabel('Daily Runoff (mm/day)', 'FontSize', label_size);
title('(b) Q90 Constrain', 'FontSize', title_size);
xticks([1 2 3 4 5 6 7 8 9])
xticklabels({'0.01','0.05','0.10','0.25','0.50','0.75','0.90','0.95','0.99'})
xlabel('FDC Non-exceedance Probability', 'FontSize', label_size);
grid on;
xlim([2, 8]);ylim([0, 3.5]);
set(gca,'FontSize',tick_size);
% l = legend([h1, h2, h3], {'Obs.', 'Default Sim.', 'Uncertainty Range'});
% set(l,'FontSize',legend_size, 'Location','northwest','Orientation','vertical'); 
% legend boxoff
grid on;
box on;
xlim([3, 7]);
ylim([0,6]);
text(0.05, 0.9, sprintf('CRPSS Q10 = %3.2f', crps_q90_q10), 'FontSize',text_size, 'Units','Normalized')
text(0.05, 0.80, sprintf('CRPSS Q90 = %3.2f', crps_q90_q90), 'FontSize',text_size,  'Units','Normalized')
text(0.05, 0.70, sprintf('CRPSS Qmean = %3.2f', crps_q90_qmean), 'FontSize',text_size,  'Units','Normalized')




subplot(3,3,3)
clear temp; x=1:9;
h1 = plot(x, q_obs, '-o','MarkerSize',marksize,'Color',[205 92 92]/255,'linewidth',linewidth,'MarkerFaceColor',[205 92 92]/255); hold on; 
h2 = plot(x, q_def, '-o','MarkerSize',marksize,'Color',[100 149 237]/255,'linewidth',linewidth,'MarkerFaceColor',[100 149 237]/255); hold on;     

c = [0, 128, 0]/255;
ensemble_M_min = q_min_prior;
ensemble_M_max = q_max_prior;

x2 = [x, fliplr(x)];
inBetween = [ensemble_M_min, fliplr(ensemble_M_max)];

h3 = fill(x2, inBetween, c); alpha(h3, .2); hold on;
h3.EdgeColor = 'none';


c = [255 127 80]/255;
ensemble_M_min = q_min_qmean;
ensemble_M_max = q_max_qmean;

x2 = [x, fliplr(x)];
inBetween = [ensemble_M_min, fliplr(ensemble_M_max)];

h3 = fill(x2, inBetween, c); alpha(h3, .2); hold on;
h3.EdgeColor = 'none';



% set(gca, 'YScale', 'log')
ylabel('Daily Runoff (mm/day)', 'FontSize', label_size);
title('(c) Qmean Constrain', 'FontSize', title_size);
xticks([1 2 3 4 5 6 7 8 9])
xticklabels({'0.01','0.05','0.10','0.25','0.50','0.75','0.90','0.95','0.99'})
xlabel('FDC Non-exceedance Probability', 'FontSize', label_size);
grid on;
xlim([3, 7]);
ylim([0,6]);
set(gca,'FontSize',tick_size);
% l = legend([h1, h2, h3], {'Obs.', 'Default Sim.', 'Uncertainty Range'});
% set(l,'FontSize',legend_size, 'Location','northwest','Orientation','vertical'); 
% legend boxoff
grid on;
box on;

text(0.05, 0.9, sprintf('CRPSS Q10 = %3.2f', crps_qmean_q10), 'FontSize',text_size, 'Units','Normalized')
text(0.05, 0.80, sprintf('CRPSS Q90 = %3.2f', crps_qmean_q90), 'FontSize',text_size,  'Units','Normalized')
text(0.05, 0.70, sprintf('CRPSS Qmean = %3.2f', crps_qmean_qmean), 'FontSize',text_size,  'Units','Normalized')



subplot(3,3,4)
clear temp; x=1:9;
h1 = plot(x, q_obs, '-o','MarkerSize',marksize,'Color',[205 92 92]/255,'linewidth',linewidth,'MarkerFaceColor',[205 92 92]/255); hold on; 
h2 = plot(x, q_def, '-o','MarkerSize',marksize,'Color',[100 149 237]/255,'linewidth',linewidth,'MarkerFaceColor',[100 149 237]/255); hold on;     

c = [0, 128, 0]/255;
ensemble_M_min = q_min_prior;
ensemble_M_max = q_max_prior;

x2 = [x, fliplr(x)];
inBetween = [ensemble_M_min, fliplr(ensemble_M_max)];

h3 = fill(x2, inBetween, c); alpha(h3, .2); hold on;
h3.EdgeColor = 'none';


c = [255 127 80]/255;
ensemble_M_min = q_min_q10_q90;
ensemble_M_max = q_max_q10_q90;

x2 = [x, fliplr(x)];
inBetween = [ensemble_M_min, fliplr(ensemble_M_max)];

h3 = fill(x2, inBetween, c); alpha(h3, .2); hold on;
h3.EdgeColor = 'none';



% set(gca, 'YScale', 'log')
ylabel('Daily Runoff (mm/day)', 'FontSize', label_size);
title('(d) Q10 & Q90 Constrain', 'FontSize', title_size);
xticks([1 2 3 4 5 6 7 8 9])
xticklabels({'0.01','0.05','0.10','0.25','0.50','0.75','0.90','0.95','0.99'})
xlabel('FDC Non-exceedance Probability', 'FontSize', label_size);
grid on;
xlim([3, 7]);
ylim([0,6]);
set(gca,'FontSize',tick_size);
% l = legend([h1, h2, h3], {'Obs.', 'Default Sim.', 'Uncertainty Range'});
% set(l,'FontSize',legend_size, 'Location','northwest','Orientation','vertical'); 
% legend boxoff
grid on;
box on;
text(0.05, 0.9, sprintf('CRPSS Q10 = %3.2f', crps_q10_q90_q10), 'FontSize',text_size, 'Units','Normalized')
text(0.05, 0.80, sprintf('CRPSS Q90 = %3.2f', crps_q10_q90_q90), 'FontSize',text_size,  'Units','Normalized')
text(0.05, 0.70, sprintf('CRPSS Qmean = %3.2f', crps_q10_q90_qmean), 'FontSize',text_size,  'Units','Normalized')

subplot(3,3,5)
clear temp; x=1:9;
h1 = plot(x, q_obs, '-o','MarkerSize',marksize,'Color',[205 92 92]/255,'linewidth',linewidth,'MarkerFaceColor',[205 92 92]/255); hold on; 
h2 = plot(x, q_def, '-o','MarkerSize',marksize,'Color',[100 149 237]/255,'linewidth',linewidth,'MarkerFaceColor',[100 149 237]/255); hold on;     

c = [0, 128, 0]/255;
ensemble_M_min = q_min_prior;
ensemble_M_max = q_max_prior;

x2 = [x, fliplr(x)];
inBetween = [ensemble_M_min, fliplr(ensemble_M_max)];

h3 = fill(x2, inBetween, c); alpha(h3, .2); hold on;
h3.EdgeColor = 'none';


c = [255 127 80]/255;
ensemble_M_min = q_min_qmean_q10;
ensemble_M_max = q_max_qmean_q10;

x2 = [x, fliplr(x)];
inBetween = [ensemble_M_min, fliplr(ensemble_M_max)];

h3 = fill(x2, inBetween, c); alpha(h3, .2); hold on;
h3.EdgeColor = 'none';



% set(gca, 'YScale', 'log')
ylabel('Daily Runoff (mm/day)', 'FontSize', label_size);
title('(e) Q10 & Qmean Constrain', 'FontSize', title_size);
xticks([1 2 3 4 5 6 7 8 9])
xticklabels({'0.01','0.05','0.10','0.25','0.50','0.75','0.90','0.95','0.99'})
xlabel('FDC Non-exceedance Probability', 'FontSize', label_size);
grid on;
xlim([3, 7]);
ylim([0,6]);
set(gca,'FontSize',tick_size);
% l = legend([h1, h2, h3], {'Obs.', 'Default Sim.', 'Uncertainty Range'});
% set(l,'FontSize',legend_size, 'Location','northwest','Orientation','vertical'); 
% legend boxoff
grid on;
box on;
text(0.05, 0.9, sprintf('CRPSS Q10 = %3.2f', crps_q10_qmean_q10), 'FontSize',text_size, 'Units','Normalized')
text(0.05, 0.80, sprintf('CRPSS Q90 = %3.2f', crps_q10_qmean_q90), 'FontSize',text_size,  'Units','Normalized')
text(0.05, 0.70, sprintf('CRPSS Qmean = %3.2f', crps_q10_qmean_qmean), 'FontSize',text_size,  'Units','Normalized')






subplot(3,3,6)
clear temp; x=1:9;
h1 = plot(x, q_obs, '-o','MarkerSize',marksize,'Color',[205 92 92]/255,'linewidth',linewidth,'MarkerFaceColor',[205 92 92]/255); hold on; 
h2 = plot(x, q_def, '-o','MarkerSize',marksize,'Color',[100 149 237]/255,'linewidth',linewidth,'MarkerFaceColor',[100 149 237]/255); hold on;     

c = [0, 128, 0]/255;
ensemble_M_min = q_min_prior;
ensemble_M_max = q_max_prior;

x2 = [x, fliplr(x)];
inBetween = [ensemble_M_min, fliplr(ensemble_M_max)];

h3 = fill(x2, inBetween, c); alpha(h3, .2); hold on;
h3.EdgeColor = 'none';


c = [255 127 80]/255;
ensemble_M_min = q_min_qmean_q90;
ensemble_M_max = q_max_qmean_q90;

x2 = [x, fliplr(x)];
inBetween = [ensemble_M_min, fliplr(ensemble_M_max)];

h3 = fill(x2, inBetween, c); alpha(h3, .2); hold on;
h3.EdgeColor = 'none';



% set(gca, 'YScale', 'log')
ylabel('Daily Runoff (mm/day)', 'FontSize', label_size);
title('(f) Q90 & Qmean Constrain', 'FontSize', title_size);
xticks([1 2 3 4 5 6 7 8 9])
xticklabels({'0.01','0.05','0.10','0.25','0.50','0.75','0.90','0.95','0.99'})
xlabel('FDC Non-exceedance Probability', 'FontSize', label_size);
grid on;
xlim([3, 7]);
ylim([0,6]);
set(gca,'FontSize',tick_size);
% l = legend([h1, h2, h3], {'Obs.', 'Default Sim.', 'Uncertainty Range'});
% set(l,'FontSize',legend_size, 'Location','northwest','Orientation','vertical'); 
% legend boxoff
grid on;
box on;
text(0.05, 0.9, sprintf('CRPSS Q10 = %3.2f', crps_q90_qmean_q10), 'FontSize',text_size, 'Units','Normalized')
text(0.05, 0.80, sprintf('CRPSS Q90 = %3.2f', crps_q90_qmean_q90), 'FontSize',text_size,  'Units','Normalized')
text(0.05, 0.70, sprintf('CRPSS Qmean = %3.2f', crps_q90_qmean_qmean), 'FontSize',text_size,  'Units','Normalized')


subplot(3,3,7)
clear temp; x=1:9;
h1 = plot(x, q_obs, '-o','MarkerSize',marksize,'Color',[205 92 92]/255,'linewidth',linewidth,'MarkerFaceColor',[205 92 92]/255); hold on; 
h2 = plot(x, q_def, '-o','MarkerSize',marksize,'Color',[100 149 237]/255,'linewidth',linewidth,'MarkerFaceColor',[100 149 237]/255); hold on;     

c = [0, 128, 0]/255;
ensemble_M_min = q_min_prior;
ensemble_M_max = q_max_prior;

x2 = [x, fliplr(x)];
inBetween = [ensemble_M_min, fliplr(ensemble_M_max)];

h3 = fill(x2, inBetween, c); alpha(h3, .2); hold on;
h3.EdgeColor = 'none';


c = [255 127 80]/255;
ensemble_M_min = q_min_all;
ensemble_M_max = q_max_all;

x2 = [x, fliplr(x)];
inBetween = [ensemble_M_min, fliplr(ensemble_M_max)];

h3 = fill(x2, inBetween, c); alpha(h3, .2); hold on;
h3.EdgeColor = 'none';



% set(gca, 'YScale', 'log')
ylabel('Daily Runoff (mm/day)', 'FontSize', label_size);
title('(g) Q10 & Q90 & Qmean Constrain', 'FontSize', title_size);
xticks([1 2 3 4 5 6 7 8 9])
xticklabels({'0.01','0.05','0.10','0.25','0.50','0.75','0.90','0.95','0.99'})
xlabel('FDC Non-exceedance Probability', 'FontSize', label_size);
grid on;
xlim([3, 7]);
ylim([0,6]);
set(gca,'FontSize',tick_size);
% % l = legend([h1, h2, h3], {'Obs.', 'Default Sim.', 'Uncertainty Range'});
% % set(l,'FontSize',legend_size, 'Location','northwest','Orientation','vertical'); 
% % legend boxoff
grid on;
box on;
text(0.05, 0.9, sprintf('CRPSS Q10 = %3.2f', crps_q10_q90_qmean_q10), 'FontSize',text_size, 'Units','Normalized')
text(0.05, 0.80, sprintf('CRPSS Q90 = %3.2f', crps_q10_q90_qmean_q90), 'FontSize',text_size,  'Units','Normalized')
text(0.05, 0.70, sprintf('CRPSS Qmean = %3.2f', crps_q10_q90_qmean_qmean), 'FontSize',text_size,  'Units','Normalized')



%% output the plot

fig = gcf;
fig.PaperUnits = 'inches';
% fig.PaperPosition = [0 0 10 5];

fig.PaperPositionMode = 'auto';
fig.PaperPosition = [0 0 14 10];
print('./figure', '-dpng', '-r300')


