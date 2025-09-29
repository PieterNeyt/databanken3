![image](ERD_DP.drawio.png)


# Bronanalyse
## TreasureFoundFact

| Column | Source | SCD Type |
|--------|--------|----------|
| UserSurKey | UserDim.UserSurKey | n.v.t. (fact table) |
| DateSurKey | DateDim.DateSurKey | n.v.t. (fact table) |
| SeasonSurKey | SeasonDim.SeasonSurKey (via LogDate + Treasure.City.Country) | n.v.t. (fact table) |
| RainSurKey | RainDim.RainSurKey (via Weather API op basis van LogDate + Treasure.City coördinaten) | n.v.t. (fact table) |
| TreasureTypeSurKey | TreasureTypeDim.TreasureTypeSurKey | n.v.t. (fact table) |
| StandardValue | Berekend veld (gebaseerd op Difficulty + Terrain) | n.v.t. (fact table) |
| Duration | Berekend: LogDate - SessionStart | n.v.t. (fact table) |
| CreationDate | Log.LogDate (timestamp van de log) | n.v.t. (fact table) |
| LogType | Log.LogType (0=General Message, 1=Not Found, 2=Found) | n.v.t. (fact table) |

## DateDim

| Column | Source | SCD Type |
|--------|--------|----------|
| DateSurKey | Gegenereerd (datum in YYYYMMDD formaat) | Type 0 |
| DateId | Gegenereerd (volgnummer) | Type 0 |
| Day | Afgeleid uit Log.LogDate | Type 0 |
| Week | Afgeleid uit Log.LogDate | Type 0 |
| Month | Afgeleid uit Log.LogDate | Type 0 |
| Year | Afgeleid uit Log.LogDate | Type 0 |

## SeasonDim

| Column | Source | SCD Type |
|--------|--------|----------|
| SeasonSurKey | Gegenereerd (volgnummer) | Type 0 |
| SeasonName | Afgeleid uit Log.LogDate + Treasure.City.Country (meteorologisch seizoen) | Type 0 |

## RainDim

| Column | Source | SCD Type |
|--------|--------|----------|
| RainSurKey | Gegenereerd (volgnummer) | Type 0 |
| RainCode | Weather API (http://openweathermap.org/weather-conditions) op basis van LogDate + Treasure.City coördinaten | Type 0 |
| RainDescription | Weather API - beschrijving van weercode | Type 0 |
| RainIcon | Weather API - icon code | Type 0 |

**Opmerking RainDim:** Deze dimensie bevat maximaal 3 rijen:
- 1 rij voor alle weertypes MET regen (weercode 200-699)
- 1 rij voor alle weertypes ZONDER regen
- 1 rij voor "Regen situatie onbekend"

## TreasureTypeDim

| Column | Source | SCD Type |
|--------|--------|----------|
| TreasureTypeSurKey | Gegenereerd (volgnummer) | Type 1 |
| TreasureTypeId | Treasure.TreasureId (natuurlijke sleutel) | Type 1 |
| Difficulty | Treasure.Difficulty (0-4) | Type 1 |
| Terrain | Treasure.Terrain (0-4) | Type 1 |
| Size | COUNT(Stage) per Treasure (aantal stages binnen een treasure) | Type 1 |

## UserDim

| Column | Source | SCD Type |
|--------|--------|----------|
| UserSurKey | Gegenereerd (volgnummer - surrogate key) | Type 2 |
| UserId | User.UserId (natuurlijke sleutel) | Type 2 |
| firstName | User.FirstName | Type 2 |
| lastName | User.LastName | Type 2 |
| email | User.Email | Type 2 |
| address | User.Street + User.Number | Type 2 |
| country | User.City.Country | Type 2 |
| experienceLevel | Berekend obv COUNT(Log WHERE LogType=2): Starter (0), Amateur (<4), Professional (4-10), Pirate (>10) | Type 2 |
| isDedicator | Berekend: TRUE als User is admin van minimum 1 Treasure, anders FALSE | Type 2 |
| startLogDate | Gegenereerd: begindatum versie (datum wanneer deze versie actief werd) | Type 2 |
| endLogDate | Gegenereerd: einddatum versie (NULL voor huidige versie) | Type 2 |
| isCurrentVersion | Gegenereerd: TRUE voor huidige versie, FALSE voor historische versies | Type 2 |

## Toelichting SCD Types

**Type 0 (Geen wijzigingen):**
- **DateDim**: Datums zijn statische referentiedata die niet wijzigen
- **SeasonDim**: Seizoenen zijn vaste definities gebaseerd op datum en locatie
- **RainDim**: Bevat vaste classificaties van regentypes (met regen, zonder regen, onbekend)

**Type 1 (Overschrijven):**
- **TreasureTypeDim**: Eigenschappen van een treasure (moeilijkheidsgraad, terrein, aantal stages) kunnen wijzigen. Historiek van deze wijzigingen is niet relevant voor de analyses - we willen altijd de meest actuele informatie.

**Type 2 (Historiek bijhouden):**
- **UserDim**: Voor woonplaats, land, experienceLevel en isDedicator moet de situatie op het moment van de logdatum geraadpleegd kunnen worden. Als een gebruiker verandert van Amateur naar Professional, moeten logs vóór die wijziging gekoppeld zijn aan de Amateur-versie en logs erna aan de Professional-versie. Dit vereist:
  - `startLogDate`: wanneer deze versie actief werd
  - `endLogDate`: wanneer deze versie eindigde (NULL voor huidige versie)
  - `isCurrentVersion`: boolean om snel de huidige versie te identificeren

