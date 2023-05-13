FROM --platform=linux/amd64 amazonlinux:latest 
RUN yum install -y python3 python3-pip jq unzip
# Install AWS CLI v2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install
# Install Hardeneks
RUN python3 -m venv /tmp/.venv
RUN source /tmp/.venv/bin/activate
RUN pip install hardeneks
# Setup the scan script as entry point
COPY run.sh /run.sh
RUN chmod +x /run.sh
CMD ["sh","run.sh"]