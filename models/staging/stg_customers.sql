-- Staging: cleaned customers, one row per customer_id

with source as (

    select * from {{ source('bronze', 'customers') }}

),

cleaned as (

    select
        trim(customer_id)                       as customer_id,
        initcap(trim(customer_name))            as customer_name,
        lower(trim(email))                      as email,
        initcap(trim(city))                     as city,
        initcap(trim(state))                    as state,
        initcap(trim(segment))                  as segment,
        cast(created_at as timestamp)           as created_at,
        _source_file,
        _ingested_at
    from source
    where customer_id is not null

),

deduped as (

    select
        *,
        row_number() over (
            partition by customer_id
            order by _ingested_at desc
        ) as row_num
    from cleaned

)

select
    customer_id,
    customer_name,
    email,
    city,
    state,
    segment,
    created_at,
    _source_file,
    _ingested_at
from deduped
where row_num = 1
