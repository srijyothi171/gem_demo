# gem_demo
Terraform code for removing image exif metadata

**#Terraform main.tf file steps**
1. Provider aws
2. backend state file to local (or) to S3 bucket
3. Create a source bucket tests3exifa
4. Create a target bucket tests3exifb
5. Create an IAM role for lambda (lambda_role)
6. Attach a AmazonS3FullAccess policy to IAM role 'lambda_role'
7. Attach a CloudWatchFullAccess policy to IAM role 'lambda_role' 
8. Create a lambda function exifremoval
9. Adding S3 bucket as a trigger to lambda and giving the permissions
10. Create a test userA 
11. Attach a poilcy with permissions S3 bucket tests3exifa read write to the test-userA
12. Create a test userB 
13. Attach a poilcy with permissions S3 bucket tests3exifb read only to the test-userB

**Lambda Function steps:**
1. Create a S3 bucket trigger notification i.e, it invokes the lamba as soon as file uploaded in S3 bucket tests3exifa
2. import boto3,json,os,PIL,Image etc
3. Get the Source bucket name(tests3exifa) and filename
4. print the Source(tests3exifa) & target(tests3exifb) bucket names and filename
5. print Metadata using s3.head_object 
6. Remove EXIF data by using PIL import Image; if PIL not working on your env, add dependencies to this code
7. Copying file into target bucket tests3exifb using s3.copy_object







