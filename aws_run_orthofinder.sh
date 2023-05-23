#!/bin/bash
## Set AWS credentials
export AWS_ACCESS_KEY_ID=###
export AWS_SECRET_ACCESS_KEY=###
export DEFAULT_REGION_NAME=us-east-2
export DEFAULT_OUTPUT_FORMAT=json

## Install OrthoFinder
mkdir ~/orthofinder
cd ./orthofinder
wget https://github.com/davidemms/OrthoFinder/releases/latest/download/OrthoFinder.tar.gz
tar xzvf OrthoFinder.tar.gz
cd OrthoFinder/
mkdir ./Proteomes

## Download files from S3 bucket
aws s3 cp s3://palmer-baum-dedup-orthofinder/Proteomes ./Proteomes --recursive

## Confirm files were downloaded
ls ./Proteomes
current_date=$(date +%Y-%m-%d)
output_folder=${current_date}_OF_Results
./orthofinder -f ./Proteomes --output $output_folder

## install pigz to compress directory using multiple threads
sudo yum install pigz -y
output_folder_compressed=${output_folder}.tar.gz
time tar -I pigz -cf $output_folder_compressed $output_folder
echo $output_folder
aws s3 cp $output_folder_compressed s3://palmer-baum-dedup-orthofinder/
