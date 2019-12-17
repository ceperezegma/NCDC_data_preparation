# ncdc dataset preparation
This repo contains the files required to prepare the ncdc dataset for processing using hadoop on AWS (EMR).

# ncdc dataset period
The dataset cover the weather station readings worldwide from 1901 until 2019.

# ncdc data preparation without hadoop
The bash script **dataPreparationNCDC_without hadoop.sh** process all the dataset stored in a s3 bucket. It concatenates all the weather stations readings for each year and then compress and stores the files in a different s3 bucket. At the end of the processing, there is only one file per year containing all the readings of all the weather stations worldwide.