with stg_sales as (
    select * from {{ ref('stg_sales') }}
),

dim_product as (
    select * from {{ ref('dim_product') }}
),

dim_location as (
    select * from {{ ref('dim_location') }}
),

-- Create dimension tables for retailer
dim_retailer as (
    select distinct
        retailer_id,
        retailer_name
    from stg_sales
),

-- Create dimension tables for channel
dim_channel as (
    select
        channel,
        row_number() over (order by channel) as channel_id
    from stg_sales
    group by channel
),

-- Final fact sales table
final as (
    select
        s.sale_id,
        s.product_id,
        s.retailer_id,
        l.location_id,
        c.channel_id,
        s.date as date_id,
        s.quantity,
        s.price / s.quantity as unit_price,
        s.price as total_amount,
        s.transformed_at
    from stg_sales s
    inner join dim_location l on s.location = l.location
    inner join dim_channel c on s.channel = c.channel
)

select * from final