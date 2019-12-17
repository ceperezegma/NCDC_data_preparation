#!/bin/bash 
# path to the file containing the list of files to download from s3
input=~/mapreducejobs/ncdc_files_sample.txt
#--------------------------------------
# local directory used to copy the data files from s3
directoryBase=~/ncdc-dataset-sample/
# this is the standard way for reading lines from a file in a loop: https://stackoverflow.com/questions/10929453/read-a-file-line-by-line-assigning-the-value-to-a-variable 
while IFS= read -r s3file; do   
    # formation of the AWS s3 command
    command="aws s3 cp $s3file $directoryBase"
    # exection of the AWS s3 command
    $command
    #-------------------
    # retrieve file from the local disk
    # echo "reporter:status:retrieving $s3file" >&2
    # --> $HADOOP_HOME/bin/hadoop fs -get $S3file $directoryBase
    # un-zip and un-tar the local file
    target=`basename $s3file .tar.bz2`
    mkdir -p $directoryBase$target
    echo "reporter:status:un-taring $s3file to $target" >&2    
    tar -jxf $directoryBase`basename $s3file` -C $directoryBase
    # un-gzip each station file and concat into one file
    echo "reporter:status:un-gzipping $target" >&2 
    for file in $directoryBase$target/*
    do
        gunzip -c $file >> $directoryBase$target.all
        echo "reporter:status:processed $file" >&2 
    done
    # remove input and intermediary files
    rm -r $directoryBase$target
    rm $directoryBase`basename $s3file`
    # put the gzipped version into a bucket s3 "ncdc-dataset-all-concatenated"
    gzip $directoryBase$target.all | aws s3 cp $directoryBase$target.all.gz s3://ncdc-dataset-all-concatenated/
    # delete the gzipped files in the server
    rm $directoryBase$target.all.gz
    echo "reporter:status:compressed & stored in s3 the concatenated file $target.all.gz"    
done < $input
