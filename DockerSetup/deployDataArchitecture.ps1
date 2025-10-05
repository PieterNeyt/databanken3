# Set network name
$network = "datacomponents"
$pysparkjupyter_name="sparkjupyter"
$postgres_name="postgres"
$project_root = "C:\Users\neytp\PycharmProjects\JVO_02_pieter-hugo"

# Check if the network exists
$networkExists = docker network ls --format "{{.Name}}" | Select-String -Pattern "^$network$"
if (-not $networkExists) {
    docker network create $network
}

# Build the PySpark Jupyter image
docker build -t pysparkjupyter -f pysparkjupyter/Dockerfile .

# Run Postgres container
docker run --network=$network --name=$postgres_name --hostname=$postgres_name --mac-address=c6:d8:da:94:7b:42 `
  --env=POSTGRES_PASSWORD=data `
  --env=PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/lib/postgresql/17/bin `
  --env=GOSU_VERSION=1.17 `
  --env=LANG=en_US.utf8 `
  --env=PG_MAJOR=17 `
  --env=PG_VERSION=17.6-1.pgdg13+1 `
  --env=PGDATA=/var/lib/postgresql/data `
  --volume=/var/lib/postgresql/data `
  -p 5432:5432 --restart=no --runtime=runc -d postgres:latest

# Run PySpark Jupyter container
docker run --detach --hostname=$pysparkjupyter_name --network=$network --name=$pysparkjupyter_name `
  -p 8888:8888 -p 4040:4040 -p 4041:4041 `
  -v ${project_root}:/home/jovyan/work `
  pysparkjupyter start-notebook.py `
  --PasswordIdentityProvider.hashed_password='argon2:$argon2id$v=19$m=10240,t=10,p=8$ytRWl+yXhDBZWMR0jC+O+g$RY3TdzRMbnkf9IoK7bExKYTaqD25fxFfujab7m+s1xA' `
  --notebook-dir=/home/jovyan/work