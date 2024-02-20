{{ config(materialized="view") }}
with trip_data as (
    select 
    dispatching_base_num,
    {{ dbt.safe_cast("pickup_datetime", api.Column.translate_type("timestamp")) }} as pickup_datetime,
    {{ dbt.safe_cast("dropoff_datetime", api.Column.translate_type("timestamp")) }} as dropoff_datetime,
    {{ dbt.safe_cast("PULocationID", api.Column.translate_type("integer")) }} as pickup_location_id,
    {{ dbt.safe_cast("DOLocationID", api.Column.translate_type("integer")) }} as dropoff_location_id,
    {{ dbt.safe_cast("SR_Flag", api.Column.translate_type("integer")) }} as sr_flag,
    affiliated_base_number
from {{ source("staging","fhv_trip_data")}}
)
select *
from trip_data
where extract(year from pickup_datetime) = 2019
{% if var('is_test_run', default=true) %} 
limit 100
{% endif %} 