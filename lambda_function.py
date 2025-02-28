import boto3
import csv
import os

def lambda_handler(event, context):
    s3 = boto3.client('s3')
    bucket_name = os.environ['BUCKET_NAME']
    file_key = 'sample-csv-files-sample4.csv'  # Change this to your CSV file name

    try:
        # Fetch the file from S3
        response = s3.get_object(Bucket=bucket_name, Key=file_key)
        lines = response['Body'].read().decode('utf-8').splitlines()
        
        # Read CSV content
        reader = csv.reader(lines)
        for row in reader:
            print(row)

        return {
            'statusCode': 200,
            'body': 'CSV file processed successfully!'
        }
    except Exception as e:
        print(f"Error: {e}")
        return {
            'statusCode': 500,
            'body': f"Error processing file: {str(e)}"
        }

