-- Mart: product dimension

select
    product_id,
    product_name,
    category,
    unit_price,
    is_active,
    case
        when unit_price >= 20000 then 'Premium'
        when unit_price >= 2000  then 'Mid'
        else 'Budget'
    end as price_tier
from {{ ref('stg_products') }}
