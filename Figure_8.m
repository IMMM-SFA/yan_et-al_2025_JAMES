
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















%% find GSCD regression constrain

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

clc





% c1 (1144000), c6 (05507600)  . c5(08195000), c7 (02363000)  c4 (09312600)
gauge_id = 1144000;
metric_daily = nan(464,1); 
for i = 1:464

    if out_regional(i,1)==gauge_id


        

        temp = out_para_basin_hybrid(i,:); temp = temp(~isnan(temp));
        temp1 = nan(length(temp),1);

        data_pdf = nan(size(temp1,1), 15);

        for k = 1:15
            for j = 1:length(temp)
                temp1(j,1) = para(temp(j),k);
            end
    
    
        
            data_pdf(:,k) = temp1;

        end

    end
end

% normalize the value
min_p = [0.02, 1, 0.0005, 0.01, 0.8, 0.1, 0.1, 0.8, 180, 0.1, 1.4, 0.05, 0.01, 10, 0.5];
max_p = [5, 2, 0.07, 0.02, 1.2, 5, 5, 1.2, 220, 0.4, 9.5, 2, 0.5, 60, 1];

n_data = data_pdf;
for i = 1:15
    n_data(:,i) =  (data_pdf(:,i) - min_p(i))/(max_p(i)-min_p(i));
end



for i = 1:size(n_data,1)

    plot(1:15, n_data(i,:), 'LineWidth', 0.5); hold on;
    xlim([1,15])
    ylim([0,1])
    ylabel('Normalized Range', 'FontSize', label_size); 
    xlabel('Minimum Values', 'FontSize', label_size); 

    if i == 40
        for j = 2:14
            xline(j, 'k', 'LineWidth', 2);
        end
    end
end

xticks(1:15);
set(gca(),'XTickLabel',{sprintf('fff\\newline0.02'), sprintf('N_{bf}\\newline1'), sprintf('K_{bf}\\newline0.0005'), sprintf('S_{y}\\newline0.01'),...
    sprintf('B\\newline0.8'), sprintf('ψ_{sat}\\newline0.1'), sprintf('k_{sat}\\newline0.1'), sprintf('Ɵ_{sat}\\newline0.8'), ...
    sprintf('N_{melt}\\newline180'), sprintf('k_{acc}\\newline0.1'), sprintf('p_{sno}\\newline1.4'), sprintf('p_{lip}\\newline0.05'),...
    sprintf('f_{wet}\\newline0.01'), sprintf('d_{max}\\newline10'), sprintf('Ɵ_{ini}\\newline0.5')});

ax1 = gca;
ax2=axes('Position',ax1.Position,'XAxisLocation','top','xlim',[1 15], 'ylim',[0 1], 'YTick', [], 'Color', 'none');
xticks(ax2, 1:1:15);
% xlabel('Minimum Values', 'FontSize', label_size); 
set(ax2,'XTickLabel',{'5', '2', '0.07', '0.02', '1.2', '5', '5', '1.2', '220', '0.4', '9.5', '2', '0.5', '60', '1'});
xlabel(ax2, 'Maximum Values', 'FontSize', label_size); 







%% output the plot

fig = gcf;
fig.PaperUnits = 'inches';
% fig.PaperPosition = [0 0 10 5];

fig.PaperPositionMode = 'auto';
fig.PaperPosition = [0 0 10 6];
print('./figure', '-dpng', '-r300')


