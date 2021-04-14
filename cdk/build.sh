TAG=infuseai/cdk:v0.1
docker build . -t $TAG
docker push $TAG
