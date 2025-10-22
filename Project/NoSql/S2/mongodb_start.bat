@echo off
setlocal

set MONGO_BIN="C:\Program Files\MongoDB\Server\8.2\bin"
set BASE_PATH="C:\Program Files\MongoDB\Server\8.2\CatchemData"

cd /d %MONGO_BIN%

echo ==========================================
echo Starting MongoDB Sharded Cluster
echo ==========================================

REM === CONFIG SERVERS ===
start "Config1" cmd /c mongod --configsvr --replSet configReplSet --port 27019 --dbpath "%BASE_PATH%\ConfigDb\config1" --bind_ip localhost
start "Config2" cmd /c mongod --configsvr --replSet configReplSet --port 27020 --dbpath "%BASE_PATH%\ConfigDb\config2" --bind_ip localhost
start "Config3" cmd /c mongod --configsvr --replSet configReplSet --port 27021 --dbpath "%BASE_PATH%\ConfigDb\config3" --bind_ip localhost

timeout /t 10 /nobreak >nul

REM === SHARD 1 ===
start "Shard1-Node1" cmd /c mongod --shardsvr --replSet shardReplSet1 --port 27028 --dbpath "%BASE_PATH%\Shard1\ReplicaSet1" --bind_ip localhost
start "Shard1-Node2" cmd /c mongod --shardsvr --replSet shardReplSet1 --port 27029 --dbpath "%BASE_PATH%\Shard1\ReplicaSet2" --bind_ip localhost

timeout /t 5 /nobreak >nul

REM === SHARD 2 ===
start "Shard2-Node1" cmd /c mongod --shardsvr --replSet shardReplSet2 --port 27030 --dbpath "%BASE_PATH%\Shard2\ReplicaSet1" --bind_ip localhost
start "Shard2-Node2" cmd /c mongod --shardsvr --replSet shardReplSet2 --port 27031 --dbpath "%BASE_PATH%\Shard2\ReplicaSet2" --bind_ip localhost

timeout /t 5 /nobreak >nul

REM === SHARD 3 ===
start "Shard3-Node1" cmd /c mongod --shardsvr --replSet shardReplSet3 --port 27032 --dbpath "%BASE_PATH%\Shard3\ReplicaSet1" --bind_ip localhost
start "Shard3-Node2" cmd /c mongod --shardsvr --replSet shardReplSet3 --port 27033 --dbpath "%BASE_PATH%\Shard3\ReplicaSet2" --bind_ip localhost

timeout /t 5 /nobreak >nul

REM === MONGOS ===
start "Mongos" cmd /c mongos --configdb configReplSet/localhost:27019,localhost:27020,localhost:27021 --bind_ip localhost --port 27040

echo ==========================================
echo MongoDB Cluster successfully started!
echo ==========================================
pause
