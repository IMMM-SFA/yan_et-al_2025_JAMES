%% 
clear all; clc

marksize=5; linewidth=2;tick_size=10;label_size=10;title_size=10;legend_size=10;

load('regional_daily_flow_1000.mat')


%%
subplot(3, 3, 1)
cluster=1;
clear temp; x=1:9;
temp(:,:) = mean_m_flow(cluster, :,:);
h1 = plot(x, temp(:,1), '-o','MarkerSize',marksize,'Color',[205 92 92]/255,'linewidth',linewidth,'MarkerFaceColor',[205 92 92]/255); hold on; 
h2 = plot(x, temp(:,2), '-o','MarkerSize',marksize,'Color',[100 149 237]/255,'linewidth',linewidth,'MarkerFaceColor',[100 149 237]/255); hold on;     

c = [0, 128, 0]/255;
ensemble_M_min = temp(:,3)';  % must be 1xN
ensemble_M_max = temp(:,4)';

x2 = [x, fliplr(x)];
inBetween = [ensemble_M_min, fliplr(ensemble_M_max)];

h3 = fill(x2, inBetween, c); alpha(h3, .2); hold on;
h3.EdgeColor = 'none';

set(gca, 'YScale', 'log')
ylabel('Daily Runoff (mm/day)', 'FontSize', label_size);
title('C1-Northeast', 'FontSize', title_size);
xticks([1 2 3 4 5 6 7 8 9])
xticklabels({'0.01','0.05','0.10','0.25','0.50','0.75','0.90','0.95','0.99'})
xlabel('FDC Non-exceedance Probability', 'FontSize', label_size);
grid on;
xlim([3, 7]);
ylim([10^-2, 10^1.2]);
set(gca,'FontSize',tick_size);
% l = legend([h1, h2, h3], {'Obs.', 'Default Sim.', 'Uncertainty Range'});
% set(l,'FontSize',legend_size, 'Location','northwest','Orientation','vertical'); 
% legend boxoff
grid on;
box on;

subplot(3, 3, 2)
cluster=2;
clear temp; x=1:9;
temp(:,:) = mean_m_flow(cluster, :,:);
h1 = plot(x, temp(:,1), '-o','MarkerSize',marksize,'Color',[205 92 92]/255,'linewidth',linewidth,'MarkerFaceColor',[205 92 92]/255); hold on; 
h2 = plot(x, temp(:,2), '-o','MarkerSize',marksize,'Color',[100 149 237]/255,'linewidth',linewidth,'MarkerFaceColor',[100 149 237]/255); hold on;     

c = [0, 128, 0]/255;
ensemble_M_min = temp(:,3)';  % must be 1xN
ensemble_M_max = temp(:,4)';

x2 = [x, fliplr(x)];
inBetween = [ensemble_M_min, fliplr(ensemble_M_max)];

h3 = fill(x2, inBetween, c); alpha(h3, .2); hold on;
h3.EdgeColor = 'none';

set(gca, 'YScale', 'log')
ylabel('Daily Runoff (mm/day)', 'FontSize', label_size);
title('C2-Pacific', 'FontSize', title_size);
xticks([1 2 3 4 5 6 7 8 9])
xticklabels({'0.01','0.05','0.10','0.25','0.50','0.75','0.90','0.95','0.99'})
xlabel('FDC Non-exceedance Probability', 'FontSize', label_size);
grid on;
xlim([3, 7]);
ylim([10^-3, 10^1.5]);
set(gca,'FontSize',tick_size);
% l = legend([h1, h2, h3], {'Obs.', 'Default Sim.', 'Uncertainty Range'});
% set(l,'FontSize',legend_size, 'Location','northwest','Orientation','vertical'); 
% legend boxoff
grid on;
box on;

subplot(3, 3, 3)
cluster=3;
clear temp; x=1:9;

temp(:,:) = mean_m_flow(cluster, :,:);
temp(3,2) = 1e-15;
temp(4,2) = 1e-15;
h1 = plot(x, temp(:,1), '-o','MarkerSize',marksize,'Color',[205 92 92]/255,'linewidth',linewidth,'MarkerFaceColor',[205 92 92]/255); hold on; 
h2 = plot(x, temp(:,2), '-o','MarkerSize',marksize,'Color',[100 149 237]/255,'linewidth',linewidth,'MarkerFaceColor',[100 149 237]/255); hold on;     


temp(3,3) = 1e-15;
temp(4,3) = 1e-15;
c = [0, 128, 0]/255;
ensemble_M_min = temp(3:9,3)';  % must be 1xN
ensemble_M_max = temp(3:9,4)';
x = 3:9;
x2 = [x, fliplr(x)];
inBetween = [ensemble_M_min, fliplr(ensemble_M_max)];

h3 = fill(x2, inBetween, c); alpha(h3, .2); hold on;
h3.EdgeColor = 'none';

set(gca, 'YScale', 'log')
ylabel('Daily Runoff (mm/day)', 'FontSize', label_size);
title('C3-AZ/NM', 'FontSize', title_size);
xticks([1 2 3 4 5 6 7 8 9])
xticklabels({'0.01','0.05','0.10','0.25','0.50','0.75','0.90','0.95','0.99'})
xlabel('FDC Non-exceedance Probability', 'FontSize', label_size);
grid on;
xlim([3, 7]);
ylim([10^-4, 10^1]);
set(gca,'FontSize',tick_size);
% l = legend([h1, h2, h3], {'Obs.', 'Default Sim.', 'Uncertainty Range'});
% set(l,'FontSize',legend_size, 'Location','northwest','Orientation','vertical'); 
% legend boxoff
grid on;
box on;


subplot(3, 3, 4)
cluster=4;
clear temp; x=1:9;
temp(:,:) = mean_m_flow(cluster, :,:);
h1 = plot(x, temp(:,1), '-o','MarkerSize',marksize,'Color',[205 92 92]/255,'linewidth',linewidth,'MarkerFaceColor',[205 92 92]/255); hold on; 
h2 = plot(x, temp(:,2), '-o','MarkerSize',marksize,'Color',[100 149 237]/255,'linewidth',linewidth,'MarkerFaceColor',[100 149 237]/255); hold on;     

c = [0, 128, 0]/255;
ensemble_M_min = temp(:,3)';  % must be 1xN
ensemble_M_max = temp(:,4)';

x2 = [x, fliplr(x)];
inBetween = [ensemble_M_min, fliplr(ensemble_M_max)];

h3 = fill(x2, inBetween, c); alpha(h3, .2); hold on;
h3.EdgeColor = 'none';

set(gca, 'YScale', 'log')
ylabel('Daily Runoff (mm/day)', 'FontSize', label_size);
title('C4-Rockies', 'FontSize', title_size);
xticks([1 2 3 4 5 6 7 8 9])
xticklabels({'0.01','0.05','0.10','0.25','0.50','0.75','0.90','0.95','0.99'})
xlabel('FDC Non-exceedance Probability', 'FontSize', label_size);
grid on;
xlim([3, 7]);
ylim([10^-2, 10^1]);
set(gca,'FontSize',tick_size);
% l = legend([h1, h2, h3], {'Obs.', 'Default Sim.', 'Uncertainty Range'});
% set(l,'FontSize',legend_size, 'Location','northwest','Orientation','vertical'); 
% legend boxoff
grid on;
box on;


subplot(3, 3, 5)
cluster=5;
clear temp; x=1:9;
temp(:,:) = mean_m_flow(cluster, :,:);
h1 = plot(x, temp(:,1), '-o','MarkerSize',marksize,'Color',[205 92 92]/255,'linewidth',linewidth,'MarkerFaceColor',[205 92 92]/255); hold on; 
h2 = plot(x, temp(:,2), '-o','MarkerSize',marksize,'Color',[100 149 237]/255,'linewidth',linewidth,'MarkerFaceColor',[100 149 237]/255); hold on;     

c = [0, 128, 0]/255;
ensemble_M_min = temp(:,3)';  % must be 1xN
ensemble_M_max = temp(:,4)';

x2 = [x, fliplr(x)];
inBetween = [ensemble_M_min, fliplr(ensemble_M_max)];

h3 = fill(x2, inBetween, c); alpha(h3, .2); hold on;
h3.EdgeColor = 'none';

set(gca, 'YScale', 'log')
ylabel('Daily Runoff (mm/day)', 'FontSize', label_size);
title('C5-Great Plains', 'FontSize', title_size);
xticks([1 2 3 4 5 6 7 8 9])
xticklabels({'0.01','0.05','0.10','0.25','0.50','0.75','0.90','0.95','0.99'})
xlabel('FDC Non-exceedance Probability', 'FontSize', label_size);
grid on;
xlim([3, 7]);
ylim([10^-3, 10^1]);
set(gca,'FontSize',tick_size);
% l = legend([h1, h2, h3], {'Obs.', 'Default Sim.', 'Uncertainty Range'});
% set(l,'FontSize',legend_size, 'Location','northwest','Orientation','vertical'); 
% legend boxoff
grid on;
box on;


subplot(3, 3, 6)
cluster=6;
clear temp; x=1:9;
temp(:,:) = mean_m_flow(cluster, :,:);
h1 = plot(x, temp(:,1), '-o','MarkerSize',marksize,'Color',[205 92 92]/255,'linewidth',linewidth,'MarkerFaceColor',[205 92 92]/255); hold on; 
h2 = plot(x, temp(:,2), '-o','MarkerSize',marksize,'Color',[100 149 237]/255,'linewidth',linewidth,'MarkerFaceColor',[100 149 237]/255); hold on;     

c = [0, 128, 0]/255;
ensemble_M_min = temp(:,3)';  % must be 1xN
ensemble_M_max = temp(:,4)';

x2 = [x, fliplr(x)];
inBetween = [ensemble_M_min, fliplr(ensemble_M_max)];

h3 = fill(x2, inBetween, c); alpha(h3, .2); hold on;
h3.EdgeColor = 'none';

set(gca, 'YScale', 'log')
ylabel('Daily Runoff (mm/day)', 'FontSize', label_size);
title('C6-Midwest', 'FontSize', title_size);
xticks([1 2 3 4 5 6 7 8 9])
xticklabels({'0.01','0.05','0.10','0.25','0.50','0.75','0.90','0.95','0.99'})
xlabel('FDC Non-exceedance Probability', 'FontSize', label_size);
grid on;
xlim([3, 7]);%ylim([10^-4, 10^2]);
set(gca,'FontSize',tick_size);
% l = legend([h1, h2, h3], {'Obs.', 'Default Sim.', 'Uncertainty Range'});
% set(l,'FontSize',legend_size, 'Location','northwest','Orientation','vertical'); 
% legend boxoff
grid on;
box on;



subplot(3, 3, 7)
cluster=7;
clear temp; x=1:9;
temp(:,:) = mean_m_flow(cluster, :,:);
h1 = plot(x, temp(:,1), '-o','MarkerSize',marksize,'Color',[205 92 92]/255,'linewidth',linewidth,'MarkerFaceColor',[205 92 92]/255); hold on; 
h2 = plot(x, temp(:,2), '-o','MarkerSize',marksize,'Color',[100 149 237]/255,'linewidth',linewidth,'MarkerFaceColor',[100 149 237]/255); hold on;     

c = [0, 128, 0]/255;
ensemble_M_min = temp(:,3)';  % must be 1xN
ensemble_M_max = temp(:,4)';

x2 = [x, fliplr(x)];
inBetween = [ensemble_M_min, fliplr(ensemble_M_max)];

h3 = fill(x2, inBetween, c); alpha(h3, .2); hold on;
h3.EdgeColor = 'none';

set(gca, 'YScale', 'log')
ylabel('Daily Runoff (mm/day)', 'FontSize', label_size);
title('C7-Southeast', 'FontSize', title_size);
xticks([1 2 3 4 5 6 7 8 9])
xticklabels({'0.01','0.05','0.10','0.25','0.50','0.75','0.90','0.95','0.99'})
xlabel('FDC Non-exceedance Probability', 'FontSize', label_size);
grid on;
xlim([3, 7]);
ylim([10^-2, 10^1]);
set(gca,'FontSize',tick_size);
% l = legend([h1, h2, h3], {'Obs.', 'Default Sim.', 'Uncertainty Range'});
% set(l,'FontSize',legend_size, 'Location','northwest','Orientation','vertical'); 
% legend boxoff
grid on;
box on;


%% output the plot

fig = gcf;
fig.PaperUnits = 'inches';
% fig.PaperPosition = [0 0 10 5];

fig.PaperPositionMode = 'auto';
fig.PaperPosition = [0 0 12 12];
print('./fig', '-dpng', '-r300')


