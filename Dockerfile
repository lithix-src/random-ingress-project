FROM ubuntu:latest

ENV AWS_ACCESS_KEY_ID "$AWS_ACCESS_KEY_ID"
ENV AWS_SECRET_ACCESS_KEY "$AWS_SECRET_ACCESS_KEY"
ENV INGRESS_PRJ_STATE_BKT "$INGRESS_PRJ_STATE_BKT"

ENV TF_VAR_assume_role_arn "$TF_VAR_assume_role_arn"
ENV TF_VAR_src_ip "$TF_VAR_src_ip"
ENV TF_VAR_slack_webhook "$TF_VAR_slack_webhook"
ENV TF_VAR_slack_user "$TF_VAR_slack_user"
ENV TF_VAR_slack_channel "$TF_VAR_slack_channel"

ENV DEBIAN_FRONTEND "noninteractive"

RUN apt-get -q -qq update \
    && apt-get -q -qq -o Dpkg::Options::="--force-confnew" --force-yes -fuy dist-upgrade \
    && apt-get -q -qq -y install unzip zip gzip bash python3 python3-pip awscli build-essential wget \
    && pip install -U pip \
    && pip install -U checkov\
    && wget https://github.com/gruntwork-io/terragrunt/releases/download/v0.34.1/terragrunt_linux_amd64 -O /usr/bin/terragrunt \
    && chmod +x /usr/bin/terragrunt \
    && wget https://releases.hashicorp.com/terraform/1.0.8/terraform_1.0.8_linux_amd64.zip \
    && unzip terraform_1.0.8_linux_amd64.zip -d /usr/bin/

# fixes botocore's issue with requests lib
RUN  apt remove python3-botocore \
    && pip3 uninstall botocore \
    && apt install -y python3-botocore \
    && apt install -y awscli \
    && pip install --upgrade boto3 awscli

WORKDIR /APP

COPY ./ /APP

CMD ["make", "app"]
