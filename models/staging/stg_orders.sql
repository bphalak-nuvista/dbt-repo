-- Staging: cleaned and typed orders, one row per order_id

with source as (

    select * from {{ source('bronze', 'orders') }}

),

cleaned as (

    select
        trim(order_id)                          as order_id,
        trim(customer_id)                       as customer_id,
        trim(product_id)                        as product_id,
        cast(quantity as int)                   as quantity,
        cast(amount as decimal(18,2))           as order_amount,
        upper(trim(status))                     as order_status,
        cast(order_date as timestamp)           as ordered_at,
        cast(order_date as date)                as order_date,
        cast(updated_at as timestamp)           as updated_at,
        _source_file,
        _ingested_at
    from source
    where order_id is not null
      and customer_id is not null
      and product_id is not null
      and quantity > 0
      and amount >= 0

),

deduped as (

    select
        *,
        row_number() over (
            partition by order_id
            order by updated_at desc, _ingested_at desc
        ) as row_num
    from cleaned

)

select
    order_id,
    customer_id,
    product_id,
    quantity,
    order_amount,
    order_status,
    ordered_at,
    order_date,
    updated_at,
    _source_file,
    _ingested_at
from deduped
where row_num = 1
