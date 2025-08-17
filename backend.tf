terraform {
  backend "s3" {
    bucket         = "my-storage-tf-state-bucket7"      
    key            = "prod/terraform.tfstate"          
    region         = "us-east-1"                    
    encrypt        = true
    dynamodb_table = "storage-tfstate"
  }
}