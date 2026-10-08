-- Mart: one row per customer with lifetime metrics

with orders as (

    select
        customer_id,
        count(*)                                            as total_orders,
        sum(case when is_revenue_order then 1 else 0 end)   as revenue_orders,
        sum(revenue_amount)                                 as lifetime_revenue,
        min(order_date)                                     as first_order_date,
        max(order_date)                                     as last_order_date
    from {{ ref('fct_orders') }}
    group by customer_id

)

select
    c.customer_id,
    c.customer_name,
    c.city,
    c.state,
    c.segment,
    coalesce(o.total_orders, 0)                             as total_orders,
    coalesce(o.revenue_orders, 0)                           as revenue_orders,
    coalesce(o.lifetime_revenue, cast(0 as decimal(18,2)))  as lifetime_revenue,
    cast(o.lifetime_revenue / nullif(o.revenue_orders, 0) as decimal(18,2)) as avg_order_value,
    o.first_order_date,
    o.last_order_date
from {{ ref('dim_customers') }} c
left join orders o
    on c.customer_id = o.customer_id
