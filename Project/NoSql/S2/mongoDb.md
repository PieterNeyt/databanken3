## 0. Json bestanden aanmaken
Run de ![S2_MONGODB_SETUP] om het json bestand aan te maken gevuld met de juiste gegevens
Deze zal later gerbuikt worden.

## 1. Mapstructuur aanmaken
We gaan eerste beginnen met de mappen aan te maken voor onze config en sharding servers.
Maak een nieuwe map `CatchemData` aan waarin onze database komt. Binnen deze map zullen we onze 3 shard met 2 replica sets aanmaken
Zorg dat de mappe sturctuur als volgd uitziet:
```
CatchemData
├─ ConfigDb
│  ├─ config1
│  ├─ config2
│  └─ config3
├─ Shard1
│  ├─ ReplicaSet1
│  └─ ReplicaSet2
├─ Shard2
│  ├─ ReplicaSet1
│  └─ ReplicaSet2
└─ Shard3
   ├─ ReplicaSet1
   └─ ReplicaSet2
```

---

## 2. Configuratie-servers opzetten

Het is aangeraden minstens **3 config servers** te gebruiken in mongoDb. \
Let op de paden na --dbpath moeten overeen komen met **jou** paden van de mappen. \
Je kan ook kiezen om het start up schript te gebruiken, deze zal alles zelf opstarten. (hier ook goed kijken naar de paden die worden gebruikt!) \
Als dit handmatig wilt doen doe het volgende. \
Je begint met 3 terminals te openen en voer volgende commandos uit:

```bash
cd "C:\Program Files\MongoDB\Server\8.2\bin"

mongod --configsvr --replSet configReplSet --port 27019 --dbpath "C:\Program Files\MongoDB\Server\8.2\CatchemData\ConfigDb\config1" --bind_ip localhost
mongod --configsvr --replSet configReplSet --port 27020 --dbpath "C:\Program Files\MongoDB\Server\8.2\CatchemData\ConfigDb\config2" --bind_ip localhost
mongod --configsvr --replSet configReplSet --port 27021 --dbpath "C:\Program Files\MongoDB\Server\8.2\CatchemData\ConfigDb\config3" --bind_ip localhost
```
### Meer uitleg over meegegeven variablelen
- --configsvr: zegt tegen mongoDb dat je de server die je nu gaat maken een CONFIG server is \
- --replSet configReplSet: telt mongoDb dat het deel is van een replica set \
- --port: verteld op welke port je het wilt dat de server opend \
- --dbpath: het pad je hier achter ingeeft zal mongoDb zien als de plek waar die al de server data moet opslagen \
- --bind_ip localhost: Dit zorgt ervoor dat enkel jij op dit machine aan de server kan, is goed als veiligheid maatregeb \

---
### Config replica set initialiseren

```bash
mongosh --port 27019

rs.initiate({
  _id: "configReplSet",
  members: [
    {_id: 0, host:"localhost:27019"},
    {_id: 1, host:"localhost:27020"},
    {_id: 2, host:"localhost:27021"}
  ]
})
```
### Meer uitleg
- mongosh --port 27019: hier zeg je dat je de mongosh terminal wilt openen en verbind met port 27019 \
- je gaat bij de initiate zeggen dat je een replica set wilt aanmaken met volgende naam en dat am de onderstaande servers toebehoren tot deze replicaset

Status Controleren
```bash
rs.status()
```
---

## 3. Shards en hun Replica Sets opzetten
We gaan nu voor elke shard de 2 replica servers opzetten, voor in aparte terminals volgende commandos uit:
### Shard 1

```bash
mongod --shardsvr --replSet shardReplSet1 --port 27028 --dbpath "C:\Program Files\MongoDB\Server\8.2\CatchemData\Shard1\ReplicaSet1" --bind_ip localhost
mongod --shardsvr --replSet shardReplSet1 --port 27029 --dbpath "C:\Program Files\MongoDB\Server\8.2\CatchemData\Shard1\ReplicaSet2" --bind_ip localhost
```

### Shard 2

```bash
mongod --shardsvr --replSet shardReplSet2 --port 27030 --dbpath "C:\Program Files\MongoDB\Server\8.2\CatchemData\Shard2\ReplicaSet1" --bind_ip localhost
mongod --shardsvr --replSet shardReplSet2 --port 27031 --dbpath "C:\Program Files\MongoDB\Server\8.2\CatchemData\Shard2\ReplicaSet2" --bind_ip localhost
```

### Shard 3

```bash
mongod --shardsvr --replSet shardReplSet3 --port 27032 --dbpath "C:\Program Files\MongoDB\Server\8.2\CatchemData\Shard3\ReplicaSet1" --bind_ip localhost
mongod --shardsvr --replSet shardReplSet3 --port 27033 --dbpath "C:\Program Files\MongoDB\Server\8.2\CatchemData\Shard3\ReplicaSet2" --bind_ip localhost
```

### Meer uitleg
- --shardsvr: Dit toont aan dat de server die je nu gaat openen, zal functioneren als een shard server.
- --replSet shardReplSet1: Zegt dat deze server deel zal worden van de Replica set shardReplSet1 
- --port 27028 :Vertelt op welke poort je de server zal willen openen 
- --dbpath [PATH]: Dit verteld MongoDB waar het alle data van deze server zal moeten opslagen.
- --bind_ip localhost: Dit zorgt ervoor dat enkel jij, op deze machine, aan de server kan. 
                         Het zorgt ervoor dat mensen de configuratie server niet zomaar kunnen aanraken. Altijd een handige veiligheidsmaatregel!
### Shard replica sets initialiseren

```bash
mongosh --port 27028
rs.initiate({_id:"shardReplSet1", members:[{_id: 0, host:"localhost:27028"}, {_id: 1, host:"localhost:27029"}]})

mongosh --port 27030
rs.initiate({_id:"shardReplSet2", members:[{_id: 0, host:"localhost:27030"}, {_id: 1, host:"localhost:27031"}]})

mongosh --port 27032
rs.initiate({_id:"shardReplSet3", members:[{_id: 0, host:"localhost:27032"}, {_id: 1, host:"localhost:27033"}]})
```
### meer uitleg
de _ID variable en de member poorten zullen moeten aangepast worden voor elke shard natuurlijk. 
Ook hier kan gecontroleerd worden of onze replicasets correct opgezet zijn door “rs.status()” in te voeren.
---

## 4. Mongos router starten en shards toevoegen

```bash
mongos --configdb configReplSet/localhost:27019 --bind_ip localhost --port 27040
mongosh --port 27040

sh.addShard("shardReplSet1/localhost:27028")
sh.addShard("shardReplSet2/localhost:27030")
sh.addShard("shardReplSet3/localhost:27032")
```

---


## 5. Index en sharding
hier gaan we kiezen op welke index we onze MongoDb gaan opdelen, wij kiezen in dit geval voor country name
```bash
use config
db.settings.updateOne(
   { _id: "chunksize" },
   { $set: { _id: "chunksize", value: 1 } },
   { upsert: true }
)
use Catchem
sh.shardCollection("Catchem.treasure", { "city.id": 1 });
sh.enableSharding("Catchem")
```

---
## 6. Data importeren
Nu gaan we onze eerder gemaakte json bestanden in laden op de databank
```bash
cd "C:\Program Files\MongoDB\Tools\100\bin"

mongoimport --port 27040 --db Catchem --collection treasure --file "C:\Kdg Projecten\PyCharm\ProjectDP\Project\NoSql\S2\treasures_export.json\part-00000-b1af9409-abf1-402b-bacc-4b1e902193f0-c000.json

```
---

## 7. Handige sharding info commands
Deze commandos kunne je helpen met meer info te hebben of de sharding is gelukt
```bash
sh.status()          
sh.isBalancerRunning()
sh.getBalancerState()  
use Catchem
db.treasure.getShardDistribution() 
```

---
