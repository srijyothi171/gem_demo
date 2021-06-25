#This Terraform code Deploys 3 s3 buckets, 2 users, attach policies, 1 role, lambda function and s3 bucket trigger for lambda
#Terraform main.tf file steps

#1. Provider aws
#2. backend state file to local / to S3 bucket
#3. Create a source bucket tests3exifa
#4. Create a target bucket tests3exifb
#5. Create an IAM role as lambda_role
#6. Attach a AmazonS3FullAccess policy to IAM role 'lambda_role'
#7. Attach a CloudWatchFullAccess policy to IAM role 'lambda_role' 
#8. Create a lambda function exifremoval
#9. Adding S3 bucket as trigger to lambda and giving the permissions
#10. Create a test userA 
#11. Attach a poilcy S3 bucket tests3exifa read write to the test-userA
#12. Create a test userB 
#13. Attach a poilcy S3 bucket tests3exifa read only to the test-userB

provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "${var.aws_region}"
}

# backend the state file locally
terraform {
  backend "local" {
    path = "c/Users/Home/terraform_scripts/terraform.tfstate"
  }
}

/*
# Create a bucket for terraform state file
resource "aws_s3_bucket" "b" {
  bucket = "my-tf-testjaji-bucket"
  acl    = "private"

  tags = {
    Name        = "TerraformSatebucket"
    Environment = "Dev"
  }
}
# backend the state file in S3
terraform {
  backend "s3" {
     bucket = "my-tf-testjaji-bucket"
     region = "us-east-1"
     key = "statefile/tfstates/terraform.tfstate"
  }
}
*/

# Create a source bucket tests3exifa
resource "aws_s3_bucket" "ia" {
  bucket = "tests3exifa"
  acl    = "private"

  tags = {
    Name        = "Sbucket"
    Environment = "Dev"
  }
}

# Create a target bucket tests3exifb
resource "aws_s3_bucket" "ib" {
  bucket = "tests3exifb"
  acl    = "private"

  tags = {
    Name        = "Tbucket"
    Environment = "Dev"
  }
}

# Create an IAM role as lambda_role 
resource "aws_iam_role" "lambda_role" {
    name = "lambda_role"

    assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}
# Attach a AmazonS3FullAccess policy to IAM role 'lambda_role' 
resource "aws_iam_role_policy_attachment" "s3fullaccess"{
     role  = aws_iam_role.lambda_role.id
     policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
} 

# Attach a CloudWatchFullAccess policy to IAM role 'lambda_role' 
resource "aws_iam_role_policy_attachment" "cwfullaccess"{
     role  = aws_iam_role.lambda_role.id
     policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
} 

# Create a lambda function
resource "aws_lambda_function" "exif_lambda" {
  filename      = "exifremoval.zip"
  function_name = "exifremoval"
  role          = aws_iam_role.lambda_role.arn
  handler       = "exports.test"
  source_code_hash = filebase64sha256("exifremoval.zip")

  runtime = "python3.8"

  environment {
    variables = {
      env = "Dev"
    }
  }
# Adding S3 bucket as trigger to lambda and giving the permissions
resource "aws_s3_bucket_notification" "s3trigger" {
bucket = "tests3exifa"
lambda_function {
lambda_function_arn = aws_lambda_function.exif_lambda.arn
events              = ["s3:ObjectCreated:*"]
filter_prefix       = "file-prefix"
filter_suffix       = "file-extension"
}
}
resource "aws_lambda_permission" "test" {
statement_id  = "AllowS3Invoke"
action        = "lambda:InvokeFunction"
function_name = aws_lambda_function.exif_lambda.function_name
principal = "s3.amazonaws.com"
source_arn = arn:aws:s3:::aws_s3_bucket.tests3exifa.id
}

# Create a test userA 
resource "aws_iam_user" "usera" {
  name = "test-userA"
}

# Attach a poilcy S3 bucket tests3exifa read write to the test-userA
resource "aws_iam_user_policy" "rw" {
  name = "s3_rw"
  user = aws_iam_user.usera.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*Object"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::tests3exifa/*"
    }
  ]
}
EOF
}

# Create a test userB 
resource "aws_iam_user" "userb" {
  name = "test-userA"
}

# Attach a poilcy S3 bucket tests3exifa read only to the test-userB
resource "aws_iam_user_policy" "ro" {
  name = "s3_ro"
  user = aws_iam_user.userb.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::tests3exifb/*"
    }
  ]
}
EOF
}

