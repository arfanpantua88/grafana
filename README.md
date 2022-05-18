# Installing and configuring Grafana HA (AWS Provider)

## Create Iam Policy using cli
- `aws iam create-policy --policy-name allow-to-rds-postgress-grafana --policy-document file://<path-to-monitoring-storage-policy.json>`
## Create namespace
- `kubectl create namespace grafana`
## Attach policy to cluster using eksctl and create service account
- `eksctl create iamserviceaccount --name grafana-sa --cluster <cluster-name> --namespace=grafana --attach-policy-arn arn:aws:iam::706050889978:policy/allow-to-rds-postgress-grafana --approve --override-existing-serviceaccounts`
## Create secret
- `kubectl  create secret generic -n grafana grafana-secret-config --from-file=grafana-secret-config.yaml=grafana-secret-config.yaml`

## Create database in RDS
- `kubectl apply -f .\ubuntu-pod.yaml -n grafana`
## Going to pod of Ubuntu and install postgres
- `apt update`
- `apt install postgresql postgresql-contrib`
-  `psql --host=dev-20220411-rds-pg.crzsc5gb1vu2.ap-southeast-1.rds.amazonaws.com --port=5432 -U hx --dbname=postgres`
- `CREATE DATABASE grafana`;

## Export SQLLite to Postgress
- Copy install.sh file to ubuntu
    `kubectl cp .\install.sh <namespace>/<pod>:/home/`
- login to ubuntu pod
    - `kubectl exec -it <ubuntu-pod> -n <namespace> -c <container> bash`
    - `cd /home`
    - `chmod +x ./install.sh`
    - `./install.sh`
    - `git clone https://github.com/haron/grafana-migrator.git`
    - `cd grafana-migrator`
- Copy grafana.db from pod grafana, usually in /var/lib/grafana/grafana.db, to pod ubuntu
    `kubectl cp <namespace>/<pod>:/var/lib/grafana/grafana.db <namespace>/<pod>:/home/grafana-migrator/`
- login to ubuntu pod
    - `kubectl exec -it <ubuntu-pod> -n <namespace> -c <container> bash`
    - `cd /home/grafana-migrator`
    - `PYTHON_CMD=python2 PSQL_CMD='psql postgresql://<user>:<password>@dev-20220411-rds-pg.crzsc5gb1vu2.ap-southeast-1.rds.amazonaws.com:5432/grafana?sslmode=disable' ./migrator.sh sqlite_to_postgres.py ./grafana.db . 2>&1 | tee migration.log`
- change password admin (if necessary)
    - `kubectl exec -it <grafana-pod> -n <namespace> -c <container> bash`
    - `grafana-cli admin reset-admin-password yourNewPasswordHere`


## Helming
### Grafana Helm
- `helm repo add stable https://charts.helm.sh/stable`
- `kubectl scale deploy -n <namespace> --replicas=0`
- `helm upgrade --install --version 6.29.2 grafana -n grafana grafana/grafana --values .\values.yaml`