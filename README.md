# kaas-deployment
For deploying KAAS

## Starting the services
For convenience a Makefile is provided. The easiest way to bring up all services is to
```bash
make all
```
and to add kaas.com as a host for 127.0.0.1 in /etc/hosts e.g.
```bash
sudo sed -i.backup '/127.0.0.1/s/$/ kaas.com/' /etc/hosts
```

The host is required as the nginx reverse proxy will only route requests to the frontend
and backend if targetting this host. To use localhost the nginx.conf can be modified and
the image rebuilt locally.

Note that the database is currently a stock postgres10 image. It can be preloaded from
kings-results-service
```bash
mvn -Ddb.port=40030 -pl :database-scripts -Pdb-migrate
mvn -Ddb.port=40030 -pl :database-scripts -Pdb-load-test
```
This is aliased by `make db-build` and performed as part of `make all`

## Building docker images locally
The tag version of the containers being used is defined in .env - ensure it is
updated or the image is tagged appropriately

andrewflbarnes/kaas-frontend should be built from kaas-site-react
```bash
rm -rf build
npm run build
docker build -t andrewflbarnes/kaas-frontend
```

andrewflbarnes/kaas-backend should be built from kings-results-service
```bash
mvn clean package -Dmaven.test.skip
docker build -t andrewflbarnes/kaas-backend .
```

andrewflbarnes/kaas-proxy should be built locally
```bash
docker build -t andrewflbarnes/kaas-proxy docker/proxy
```
