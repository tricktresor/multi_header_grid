# multi_header_grid
ALV Grid with mulitple header lines

# purpose
sometimes the column description is not sufficient and one would like to have multiple lines as column header.
With this trick it is possible to realize such a behaviour.

# screenshots
![screenshot](https://github.com/tricktresor/multi_header_grid/blob/master/img/SNAG-00711.png)

# functionality

two grids will be created:
one for the header lines (column description) and one for the data.
The field catalog of the data table will be copied to the header structure. All fields are set to "TEXT40" rollname to display longer column titles.

the data table will be adapted so that no column changes are possible. All changes like resizing and moving of columns must be done in the header grid.
Unfortunately there is no event that reacts on these changes. So the changes made to the header grid can only be copied to the data grid after pressing a key.
