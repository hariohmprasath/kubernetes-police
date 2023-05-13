export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
export BUCKET_NAME=hardeneks-report-output-$AWS_ACCOUNT_ID
aws eks list-clusters > clusters.json --region $AWS_REGION
if aws s3api head-bucket --bucket $BUCKET_NAME 2>/dev/null; then
    echo "Bucket exists"
else
    aws s3api create-bucket --bucket $BUCKET_NAME --region $AWS_REGION --create-bucket-configuration LocationConstraint=$AWS_REGION
fi
for cluster in $(jq -r '.clusters[]' clusters.json); do
    aws eks update-kubeconfig --region $AWS_REGION --name $cluster
    hardeneks --cluster $cluster --region $AWS_REGION --export-txt $cluster.txt
    aws s3 cp $cluster.txt s3://$BUCKET_NAME/$cluster.txt
    echo "Uploaded $cluster.txt to s3://$BUCKET_NAME/$cluster.txt"    
done