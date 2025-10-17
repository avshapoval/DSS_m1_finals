## Data Vault Design (Sample Superstore)

**Легенда:**
- **Синий** — Хабы (Hubs)
- **Зеленый** — Линки (Links)
- **Оранжевый** — Спутники (Satellites)

```mermaid
graph TB
    H_CUSTOMER["<b>H_CUSTOMER</b><br/>customer_hkey<br/>bk_customer<br/>load_dts<br/>record_source"]
    H_PRODUCT["<b>H_PRODUCT</b><br/>product_hkey<br/>bk_product<br/>load_dts<br/>record_source"]
    H_LOCATION["<b>H_LOCATION</b><br/>location_hkey<br/>bk_location<br/>load_dts<br/>record_source"]
    H_ORDER["<b>H_ORDER</b><br/>order_hkey<br/>bk_order<br/>load_dts<br/>record_source"]
    
    L_ORDER_CUSTOMER["<b>L_ORDER_CUSTOMER</b><br/>l_order_customer_hkey<br/>order_hkey FK<br/>customer_hkey FK<br/>load_dts<br/>record_source"]
    L_ORDER_PRODUCT["<b>L_ORDER_PRODUCT</b><br/>l_order_product_hkey<br/>order_hkey FK<br/>product_hkey FK<br/>load_dts<br/>record_source"]
    L_ORDER_LOCATION["<b>L_ORDER_LOCATION</b><br/>l_order_location_hkey<br/>order_hkey FK<br/>location_hkey FK<br/>load_dts<br/>record_source"]
    
    S_CUSTOMER_ATTR["<b>S_CUSTOMER_ATTR</b><br/>customer_hkey PK,FK<br/>load_dts PK<br/>segment<br/>hashdiff<br/>record_source"]
    S_PRODUCT_ATTR["<b>S_PRODUCT_ATTR</b><br/>product_hkey PK,FK<br/>load_dts PK<br/>category<br/>sub_category<br/>hashdiff<br/>record_source"]
    S_LOCATION_ATTR["<b>S_LOCATION_ATTR</b><br/>location_hkey PK,FK<br/>load_dts PK<br/>country<br/>state<br/>city<br/>postal_code<br/>region<br/>hashdiff<br/>record_source"]
    S_ORDER_METRICS["<b>S_ORDER_METRICS</b><br/>order_hkey PK,FK<br/>load_dts PK<br/>ship_mode<br/>sales<br/>quantity<br/>discount<br/>profit<br/>hashdiff<br/>record_source"]
    
    H_CUSTOMER --- L_ORDER_CUSTOMER
    H_ORDER --- L_ORDER_CUSTOMER
    H_ORDER --- L_ORDER_PRODUCT
    H_PRODUCT --- L_ORDER_PRODUCT
    H_ORDER --- L_ORDER_LOCATION
    H_LOCATION --- L_ORDER_LOCATION
    
    H_CUSTOMER --- S_CUSTOMER_ATTR
    H_PRODUCT --- S_PRODUCT_ATTR
    H_LOCATION --- S_LOCATION_ATTR
    H_ORDER --- S_ORDER_METRICS
    
    classDef hubStyle fill:#bbdefb,stroke:#1976d2,stroke-width:2px,color:#000
    classDef linkStyle fill:#c8e6c9,stroke:#388e3c,stroke-width:2px,color:#000
    classDef satStyle fill:#ffe0b2,stroke:#f57c00,stroke-width:2px,color:#000
    
    class H_CUSTOMER,H_PRODUCT,H_LOCATION,H_ORDER hubStyle
    class L_ORDER_CUSTOMER,L_ORDER_PRODUCT,L_ORDER_LOCATION linkStyle
    class S_CUSTOMER_ATTR,S_PRODUCT_ATTR,S_LOCATION_ATTR,S_ORDER_METRICS satStyle
```
