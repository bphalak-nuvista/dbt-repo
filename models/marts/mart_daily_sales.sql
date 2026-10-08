-- Mart: one row per day

select
    order_date,
    count(*)                                                    as total_orders,
    sum(case when is_revenue_order then 1 else 0 end)           as revenue_orders,
    sum(case when is_revenue_order then quantity else 0 end)    as units_sold,
    sum(revenue_amount)                                         as revenue,
    sum(case when order_status = 'CANCELLED' then 1 else 0 end) as cancelled_orders,
    sum(case when order_status = 'RETURNED'  then 1 else 0 end) as returned_orders
from {{ ref('fct_orders') }}
group by order_date
