# Violin Plot

Feature (gene or transcript) expression can be viewed by violin plot based on sample metadata

Violin plots are a hybrid of density and box plots. It shows probability density of the data at different values of expression level. The horizontal line is a marker for the median of the data and the box shows the interquartile ranges.

The parameter 'Variable to group by' allows the user to select the variable that they want to use for making the plot.

There are two additional parameters, 'Variable to filter by' and 'Value to filter by', that can be chosen if the user wants to 
select a specific subset of the overall data for plotting. 
'Variable to filter by' lets the user select for the specific parameter in the metadata that they would like to subset the data based on and the 'Value to filter by' further allows to select for the group within that category. 

Example: In order to display the day vs gene expression violin plot on only the cells that form cluster_1 out of say, 4 cluster types, in a dataset with 'cluster_types' as one of the metadata category. I would select 'cluster_types' for 'Variable to filter by' and 'cluster_1' for 'Value to filter by'.

- does it use 'seurat_integration' pipeline??
