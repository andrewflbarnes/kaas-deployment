Create the backend property files as secrets
```bash
make k-secret
```
This will create a kubernetes secret which is mounted into the kaas-backend deployment

Start all 0-dependent deployments and services
```bash
make k-deploy
```
This will
- start all services
- start the db, db admin, frontend and proxy deployments

WAIT for all 0-dependent services to start

Start dependent services
```bash
make k-deploy-2
```
This will
- run the maven database script profiles "migrate" and "load-test" targeting the db node port on the minikube IP
- start the kaas-backend deployment (spring boot API)

Port forward to the reverse proxy
```bash
make k-proxy
```
This will forward port 80 locally to port 80 on kaas-proxy

Now add kaas.com as `127.0.0.1` to `/etc/hosts` and visit `http://kaas.com` in a browser to see the website!

NOTE: visiting localhost:80 will cause the reverse proxy to present the default nginx welcome page
