![image](ERD_DP.drawio.png)


# Bronanalyse

## TreasureFoundFact

| Column | Source                                                                                | SCD Type |
|--------|---------------------------------------------------------------------------------------|----------|
| UserSurKey | UserDim.UserSurKey                                                                    | n.v.t. (fact table) |
| DateSurKey | DateDim.DateSurKey                                                                    | n.v.t. (fact table) |
| SeasonSurKey | SeasonDim.SeasonSurKey (via LogDate + Treasure.City.Country)                          | n.v.t. (fact table) |
| RainSurKey | RainDim.RainSurKey (via Weather API op basis van LogDate + Treasure.City coördinaten) | n.v.t. (fact table) |
| TreasureTypeSurKey | TreasureTypeDim.TreasureTypeSurKey                                                    | n.v.t. (fact table) |
| StandardValue | standaard 1                                                                           | n.v.t. (fact table) |
| Duration | Berekend: Log.LogDate - Log.SessionStart                                                      | n.v.t. (fact table) |
| CreationDate | Log.LogDate (timestamp van de log)                                                    | n.v.t. (fact table) |

## DateDim

| Column         | Source | SCD Type |
|----------------|--------|----------|
| DateSurKey     | Gegenereerd (datum in YYYYMMDD formaat) | nvt       |
| DateId         | Gegenereerd (volgnummer) | n.v.t.        |
| Day            | Afgeleid uit Log.LogDate | 1        |
| Week           | Afgeleid uit Log.LogDate | 1        |
| Month          | Afgeleid uit Log.LogDate | 1        |
| Year           | Afgeleid uit Log.LogDate | 1        |
| MonthOfTheYear | Afgeleid uit Log.LogDate | 1        |
| DayOfTheWeek   | Afgeleid uit Log.LogDate | 1        |
| IsWeekDay      | Afgeleid uit Log.LogDate | 1        |

## SeasonDim

| Column | Source                                                                   | SCD Type |
|--------|--------------------------------------------------------------------------|----------|
| SeasonSurKey | Gegenereerd (volgnummer)                                                 | nvt        |
| SeasonName | Afgeleid uit Log.LogDate + coordinaten laatste stage van treasure stages | 1        |

## RainDim

| Column | Source                                                          | SCD Type |
|--------|-----------------------------------------------------------------|----------|
| RainSurKey | Gegenereerd (volgnummer)                                        | nvt        |
| RainCode | Weather API code (http://openweathermap.org/weather-conditions) | 1        |
| RainDescription | Weather API - beschrijving van weercode                         | 1        |

**Opmerking RainDim:** Deze dimensie bevat maximaal 3 rijen:
- 1 rij voor alle weertypes MET regen (weercode 200-699)
- 1 rij voor alle weertypes ZONDER regen
- 1 rij voor "Regen situatie onbekend"

## TreasureTypeDim

| Column | Source | SCD Type |
|--------|--------|----------|
| TreasureTypeSurKey | Gegenereerd (volgnummer) | nvt        |
| Difficulty | Treasure.Difficulty (0-4) | 1        |
| DifficultyName | Afgeleid van Treasure.Difficulty | 1        |
| Terrain | Treasure.Terrain (0-4) | 1        |
| Size | COUNT(Stage) per Treasure (aantal stages binnen een treasure) | 1        |

## UserDim

| Column          | Source                                                                                                | SCD Type |
|-----------------|-------------------------------------------------------------------------------------------------------|----------|
| UserSurKey      | Gegenereerd (volgnummer - surrogate key, wijzigt per versie)                                          | nvt      |
| UserId          | User.UserId (natuurlijke sleutel, blijft constant over versies)                                       | 2        |
| firstName       | User.FirstName                                                                                        | 1        |
| lastName        | User.LastName                                                                                         | 1        |
| email           | User.Email                                                                                            | 1        |
| address         | User.Street + User.Number                                                                             | 1        |
| country         | User.city_id -> city_id, city.country_code -> country_code                                            | 1        |
| experienceLevel | Berekend obv COUNT(Log WHERE LogType=2): Starter (0), Amateur (<4), Professional (4-10), Pirate (>10) | 2        |
| dedicator       | Berekend: TRUE als User is admin van minimum 1 Treasure, anders FALSE                                 | 2        |
| startScd        | Gegenereerd: begindatum versie (datum wanneer deze versie actief werd)                                | 2        |
| endScd          | Gegenereerd: einddatum versie (NULL voor huidige versie)                                              | 2        |
| current         | Gegenereerd: TRUE voor huidige versie, FALSE voor historische versies                                 | 2        |

