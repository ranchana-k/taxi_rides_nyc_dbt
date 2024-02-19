{{ config(materialized= "view")}}

select 
-- identifiers
    {{ dbt_utils.generate_surrogate_key(['vendor_id','pickup_datetime']) }} as tripid,
    {{ dbt.safe_cast("vendor_id", api.Column.translate_type("integer")) }} as vendor_id,
    {{ dbt.safe_cast("rate_code", api.Column.translate_type("integer")) }} as rate_code,
    {{ dbt.safe_cast("pickup_location_id", api.Column.translate_type("integer")) }} as pickup_location_id,
    {{ dbt.safe_cast("dropoff_location_id", api.Column.translate_type("integer")) }} as dropoff_location_id,
    
    -- timestamps
    pickup_datetime,
    dropoff_datetime,
    
    -- trip info
    store_and_fwd_flag,
    {{ dbt.safe_cast("passenger_count", api.Column.translate_type("integer")) }} as passenger_count,
    cast(trip_distance as numeric) as trip_distance,
    -- yellow cabs are always street-hail
    1 as trip_type,

    -- payment info
    cast(fare_amount as numeric) as fare_amount,
    cast(extra as numeric) as extra,
    cast(mta_tax as numeric) as mta_tax,
    cast(tip_amount as numeric) as tip_amount,
    cast(tolls_amount as numeric) as tolls_amount,
    cast(0 as numeric) as ehail_fee,
    cast(imp_surcharge as numeric) as improvement_surcharge,
    cast(total_amount as numeric) as total_amount,
    {{ dbt.safe_cast("payment_type", api.Column.translate_type("integer")) }} as payment_type,
    {{ get_payment_type_description("payment_type") }} as payment_type_description
from {{ source('staging', 'yellow_tripdata') }}
where vendor_id is not null
{% if var('is_test_run', default=true) %} 
limit 100
{% endif %}