FROM python:3
RUN apt-get update
RUN apt-get install -y python3-pip curl
RUN curl -sL https://deb.nodesource.com/setup_15.x | bash -
RUN apt-get install -y nodejs
RUN npm install -g aws-cdk
RUN python3 -m pip install aws-cdk.core aws-cdk.aws-ec2
ADD scripts /app
RUN chmod a+x /app/*.sh
WORKDIR /app
ENTRYPOINT ["/app/entrypoint.sh"]
