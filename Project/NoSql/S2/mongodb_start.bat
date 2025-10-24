@echo off
setlocal

set MONGO_BIN="C:\Program Files\MongoDB\Server\8.2\bin"
cd /d %MONGO_BIN%

echo ==========================================
echo Starting MongoDB Sharded Cluster
echo ==========================================

REM === CONFIG SERVERS ===
start /b mongod --configsvr --replSet configReplSet --port 27019 --dbpath "C:\Program Files\MongoDB\Server\8.2\CatchemData\ConfigDb\config1" --bind_ip localhost
start /b mongod --configsvr --replSet configReplSet --port 27020 --dbpath "C:\Program Files\MongoDB\Server\8.2\CatchemData\ConfigDb\config2" --bind_ip localhost
start /b mongod --configsvr --replSet configReplSet --port 27021 --dbpath "C:\Program Files\MongoDB\Server\8.2\CatchemData\ConfigDb\config3" --bind_ip localhost

timeout /t 10 /nobreak >nul

REM === SHARD 1 ===
start /b mongod --shardsvr --replSet shardReplSet1 --port 27028 --dbpath "C:\Program Files\MongoDB\Server\8.2\CatchemData\Shard1\ReplicaSet1" --bind_ip localhost
start /b mongod --shardsvr --replSet shardReplSet1 --port 27029 --dbpath "C:\Program Files\MongoDB\Server\8.2\CatchemData\Shard1\ReplicaSet2" --bind_ip localhost

timeout /t 5 /nobreak >nul

REM === SHARD 2 ===
start /b mongod --shardsvr --replSet shardReplSet2 --port 27030 --dbpath "C:\Program Files\MongoDB\Server\8.2\CatchemData\Shard2\ReplicaSet1" --bind_ip localhost
start /b mongod --shardsvr --replSet shardReplSet2 --port 27031 --dbpath "C:\Program Files\MongoDB\Server\8.2\CatchemData\Shard2\ReplicaSet2" --bind_ip localhost

timeout /t 5 /nobreak >nul

REM === SHARD 3 ===
start /b mongod --shardsvr --replSet shardReplSet3 --port 27032 --dbpath "C:\Program Files\MongoDB\Server\8.2\CatchemData\Shard3\ReplicaSet1" --bind_ip localhost
start /b mongod --shardsvr --replSet shardReplSet3 --port 27033 --dbpath "C:\Program Files\MongoDB\Server\8.2\CatchemData\Shard3\ReplicaSet2" --bind_ip localhost

timeout /t 5 /nobreak >nul

REM === MONGOS ===
start "Mongos" cmd /k mongos --configdb configReplSet/localhost:27019 --bind_ip localhost --port 27040

echo ==========================================
echo MongoDB Cluster successfully started!
echo ==========================================
pause
