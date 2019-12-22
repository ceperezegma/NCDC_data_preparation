#!/bin/bash

# NLineInputFormat gives a single line: key is offset, value is the s3 URI
read offset s3file

# local directory used to copy the data files from s3
directoryBase=/hadoop/user/carlos/ncdc-dataset/

# retrieve file from s3 to local disk
echo "reporter:stats:retrieving $s3file" >&2
# formation of the AWS s3 command
command="aws s3 cp $s3file $directoryBase"
# exection of the AWS s3 command
$command

# un-bzip and un-tar the local file
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
echo "reporter:status:gzipping $target and putting in s3" >&2
gzip $directoryBase$target.all | aws s3 cp
$directoryBase$target.all.gz s3://ncdc-dataset-all-concatenated/

# delete the gzipped files in the server
rm $directoryBase$target.all.gz
echo "reporter:status:compressed & stored in s3 the concatenated file $target.all.gz"    