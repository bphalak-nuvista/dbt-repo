-- Mart: customer dimension

select
    customer_id,
    customer_name,
    email,
    city,
    state,
    segment,
    created_at as customer_since
from {{ ref('stg_customers') }}
