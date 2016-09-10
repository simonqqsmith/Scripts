 <#
        .DESCRIPTION
            Lists AWS Buckets
        .AUTHOR
            Simon Smith
    #>
    
 $AWSDOTNETSDKPath = "C:\Program Files (x86)\AWS SDK for .NET\bin\Net45\AWSSDK.dll"
[Reflection.Assembly]::LoadFile($AWSDOTNETSDKPath) | Out-Null
# Create a client
AmazonS3Client client = new AmazonS3Client();

# Issue call
ListBucketsResponse response = client.ListBuckets();

# View response data
Console.WriteLine("Buckets owner - {0}",response.Owner.DisplayName);
foreach (S3Bucket bucket in response.Buckets)
{
    Console.WriteLine("Bucket {0}, Created on {1}",bucket.BucketName,bucket.CreationDate);
}
