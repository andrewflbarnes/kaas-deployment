# kaas-deployment
For deploying KAAS

## Docker images
kaas/site should be built from kaas-site-react
```bash
rm -rf build
npm run build
docker build -t kaas/site .
```

kaas/results-service should be built from kings-results-service
```bash
mvn clean package -Dmaven.test.skip
docker build -t kaas/results-service .
```

kaas/proxy should be built locally
```bash
docker build -t kaas/proxy .
```

## Database
Note that the database is currently a stock postgres10 image.

It can be preloaded from kings-results-service
```bash
mvn -Ddb.port=40030 -pl :database-scripts -Pdb-migrate
mvn -Ddb.port=40030 -pl :database-scripts -Pdb-load-test
```
