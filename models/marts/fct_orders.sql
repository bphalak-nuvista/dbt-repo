-- Mart: order fact table. Incremental MERGE on order_id, so updated orders replace the old row.

{{
    config(
        materialized = 'incremental',
        incremental_strategy = 'merge',
        unique_key = 'order_id',
        file_format = 'iceberg'
    )
}}

select
    order_id,
    customer_id,
    product_id,
    order_date,
    ordered_at,
    quantity,
    order_amount,
    order_status,
    case when order_status in ('COMPLETED', 'SHIPPED') then true else false end as is_revenue_order,
    case when order_status in ('COMPLETED', 'SHIPPED') then order_amount
         else cast(0 as decimal(18,2)) end                                        as revenue_amount,
    updated_at
from {{ ref('stg_orders') }}

{% if is_incremental() %}
where updated_at >= (select max(updated_at) from {{ this }})
{% endif %}
