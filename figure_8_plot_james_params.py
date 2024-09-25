import numpy as np
import pandas as pd 
from plot_parallel import custom_parallel_coordinates

axis_labels = [r"$fff$", r"$N_{bf}$", r"$K_{bf}$", r"$S_{y}$", r"$B$", r"$k_{sat}$", r"$\theta_{sat}$", 
                r"$N_{melt}$", r"$k_{acc}$", r"$p_{sno}$", r"$p_{lip}$", r"$N_{bf}$", r"$f_{wet}$", r"$d_{max}$", r"$\theta_{ini}$"]

util_names = ['OWASA', 'Durham', 'Cary', 'Raleigh', 'Chatham', 'Pittsboro', 'Regional']
objs = ['REL', 'RF', 'NPC', 'PFC', 'WCC', 'UC']
dvs = ['RT', 'TT', 'InfT']

# set parallel plot function parameters
fontsize = 10
figsize = (10, 4)

data_file = 'data.csv'

data_df = pd.read_csv(data_file, index_col=None)
num_axis = data_df.shape[1]
axis_abbrevs = data_df.columns
colors = ['#DC851F', '#48A9A6','#355544']
fig_filename = f'parallel_params.pdf'
fig_title = f'Behavioral hydrological parameters (C1-Northeast Basin)'
custom_parallel_coordinates(data_df, columns_axes=axis_abbrevs, axis_labels=axis_labels, 
                                zorder_by=0, ideal_direction='upwards', zorder_direction='ascending',
                                alpha_base=0.6, lw_base=1.5, fontsize=fontsize, figsize=figsize,
                                minmaxs=['max']*num_axis, figtitle=fig_title, 
                                save_fig_filename = fig_filename, kde_plot=True)