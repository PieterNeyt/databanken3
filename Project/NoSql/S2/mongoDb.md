## 0. Json bestanden aanmaken
Run de ![S2_MONGODB_SETUP] om 4 json bestanden aan te maken gevuld met de juiste

## 1. Mapstructuur aanmaken

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

Het is aangeraden minstens **3 config servers** te gebruiken in mongoDb.
Open 3 terminals en voer volgende commandos uit:

```bash
cd "C:\Program Files\MongoDB\Server\8.2\bin"

mongod --configsvr --replSet configReplSet --port 27019 --dbpath "C:\Program Files\MongoDB\Server\8.2\CatchemData\ConfigDb\config1" --bind_ip localhost
mongod --configsvr --replSet configReplSet --port 27020 --dbpath "C:\Program Files\MongoDB\Server\8.2\CatchemData\ConfigDb\config2" --bind_ip localhost
mongod --configsvr --replSet configReplSet --port 27021 --dbpath "C:\Program Files\MongoDB\Server\8.2\CatchemData\ConfigDb\config3" --bind_ip localhost
```

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

rs.status()
```
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

### Shard replica sets initialiseren

```bash
mongosh --port 27028
rs.initiate({_id:"shardReplSet1", members:[{_id: 0, host:"localhost:27028"}, {_id: 1, host:"localhost:27029"}]})

mongosh --port 27030
rs.initiate({_id:"shardReplSet2", members:[{_id: 0, host:"localhost:27030"}, {_id: 1, host:"localhost:27031"}]})

mongosh --port 27032
rs.initiate({_id:"shardReplSet3", members:[{_id: 0, host:"localhost:27032"}, {_id: 1, host:"localhost:27033"}]})
```

---

## 4. Mongos router starten en shards toevoegen

```bash
mongos --configdb configReplSet/localhost:27019 --bind_ip localhost --port 27040
mongosh --port 27040

sh.addShard("shardReplSet1/localhost:27028")
sh.addShard("shardReplSet2/localhost:27030")
sh.addShard("shardReplSet3/localhost:27032")
sh.enableSharding("Catchem")
```

---

## 5. Data importeren
Nu gaan we onze eerder gemaakte json bestanden in laden op de databank
```bash
cd "C:\Program Files\MongoDB\Tools\100\bin"

mongoimport --port 27040 --db Catchem --collection treasure --file "C:\Kdg Projecten\PyCharm\ProjectDP\Project\NoSql\S2\treasures_export.json\part-00000-d0ecfc1f-42ea-42b3-81d2-edec72de0e32-c000.json"

```

### Index en sharding
hier gaan we kiezen op welke index we onze MongoDb gaan opdelen, wij kiezen in dit geval voor country name
```bash
use Catchem
db.treasure.createIndex({ "country": "hashed" })
sh.shardCollection("Catchem.treasure", {"country":"hashed"})
sh.startBalancer()  
```

---

## 6. Handige sharding info commands
Deze commandos kunne je helpen met meer info te hebben of de sharding is gelukt
```bash
sh.status()          
sh.isBalancerRunning()
sh.getBalancerState()  
use Catchem
db.treasure.getShardDistribution() 
```

---
