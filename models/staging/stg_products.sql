-- Staging: cleaned products, one row per product_id

with source as (

    select * from {{ source('bronze', 'products') }}

),

cleaned as (

    select
        trim(product_id)                        as product_id,
        trim(product_name)                      as product_name,
        initcap(trim(category))                 as category,
        cast(unit_price as decimal(18,2))       as unit_price,
        cast(is_active as boolean)              as is_active,
        _source_file,
        _ingested_at
    from source
    where product_id is not null

),

deduped as (

    select
        *,
        row_number() over (
            partition by product_id
            order by _ingested_at desc
        ) as row_num
    from cleaned

)

select
    product_id,
    product_name,
    category,
    unit_price,
    is_active,
    _source_file,
    _ingested_at
from deduped
where row_num = 1
