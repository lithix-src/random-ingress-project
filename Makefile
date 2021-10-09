build:
	docker build -t ingress-prj:latest .

## provide a manual runtime environment
console:
	docker container run \
		-e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
		-e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
		-e INGRESS_PRJ_STATE_BKT=${INGRESS_PRJ_STATE_BKT} \
		-e TF_VAR_assume_role_arn=${TF_VAR_assume_role_arn} \
		-e TF_VAR_src_ip=${TF_VAR_src_ip} \
		-e TF_VAR_ingress_s3_bucket=${TF_VAR_ingress_s3_bucket} \
		-e TF_VAR_slack_webhook=${TF_VAR_slack_webhook} \
		-e TF_VAR_slack_user=${TF_VAR_slack_user} \
		-e TF_VAR_slack_channel=${TF_VAR_slack_channel} \
		-it ingress-prj:latest /bin/bash

automation-role-plan:
	cd ./infrastructure/rbac \
		&& terragrunt plan

automation-role: automation-role-plan
	cd ./infrastructure/rbac \
		&& terragrunt apply -auto-approve

s3-plan:
	cd ./infrastructure/storage/ingress-s3 \
		&& terragrunt plan	

s3: s3-plan
	cd ./infrastructure/storage/ingress-s3 \
		&& terragrunt apply -auto-approve

lambda-build:
	cd ./infrastructure/app/lambda/ingress-handler \
		&& pip install --target ./package boto3 \
		&& cd ./package \
		&& zip -r ../ingress-handler.zip . \
		&& cd .. \
		&& zip -g ingress-handler.zip ingress-handler.py 

lambda-plan:
	cd ./infrastructure/app/lambda \
		&& terragrunt plan	

lambda: lambda-build lambda-plan
	cd ./infrastructure/app/lambda \
		&& terragrunt apply -auto-approve

## this will build and deploy the latest
## lambda code before uploading test files
lambda-test: lambda
	touch bad-file.txt \
		&& aws s3 cp ./bad-file.txt s3://${TF_VAR_ingress_s3_bucket}/bad-file.txt

	echo '1,2,3' > good-file.txt \
		&& aws s3 cp ./good-file.txt s3://${TF_VAR_ingress_s3_bucket}/good-file.txt

monitoring-plan:
	cd ./infrastructure/monitoring \
		&& terragrunt plan	

monitoring: monitoring-plan
	cd ./infrastructure/monitoring \
		&& terragrunt apply -auto-approve

app-plan: automation-role-plan s3-plan lambda-plan monitring-plan
	
app: automation-role s3 lambda monitoring

clean:
	cd ./infrastructure \
		&& terragrunt run-all init \
		&& terragrunt run-all destroy