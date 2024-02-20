{{ config(materialized="table") }}
with fhv_data as (
    select *
    from {{ ref('stg_fhv_tripdata') }}
),

dim_zone as (
    select *
    from {{ ref('dim_zone') }}
    where borough != 'Unknown'
)

select fhv_data.*,
    pickup_zone.borough as pickup_borough, 
    pickup_zone.zone as pickup_zone, 
    dropoff_zone.borough as dropoff_borough, 
    dropoff_zone.zone as dropoff_zone

from fhv_data
inner join dim_zone as pickup_zone
on fhv_data.pickup_location_id = pickup_zone.locationid
inner join dim_zone as dropoff_zone
on fhv_data.dropoff_location_id = dropoff_zone.locationid