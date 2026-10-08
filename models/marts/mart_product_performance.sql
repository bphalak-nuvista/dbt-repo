-- Mart: one row per product with sales and cancellation/return metrics

with orders as (

    select
        product_id,
        count(*)                                                    as total_orders,
        sum(case when is_revenue_order then quantity else 0 end)    as units_sold,
        sum(revenue_amount)                                         as revenue,
        sum(case when order_status = 'CANCELLED' then 1 else 0 end) as cancelled_orders,
        sum(case when order_status = 'RETURNED'  then 1 else 0 end) as returned_orders
    from {{ ref('fct_orders') }}
    group by product_id

)

select
    p.product_id,
    p.product_name,
    p.category,
    p.price_tier,
    coalesce(o.total_orders, 0)                                     as total_orders,
    coalesce(o.units_sold, 0)                                       as units_sold,
    coalesce(o.revenue, cast(0 as decimal(18,2)))                   as revenue,
    coalesce(o.cancelled_orders, 0)                                 as cancelled_orders,
    coalesce(o.returned_orders, 0)                                  as returned_orders,
    cast((o.cancelled_orders + o.returned_orders) * 100.0
         / nullif(o.total_orders, 0) as decimal(5,2))               as cancel_return_pct
from {{ ref('dim_products') }} p
left join orders o
    on p.product_id = o.product_id
