### Data Vault Design (Sample Superstore)


**Легенда:**
- 🔵 **Хабы (Hubs)** 
- 🟢 **Линки (Links)**
- 🟡 **Спутники (Satellites)**

```mermaid
---
config:
  look: neo
  layout: dagre
  theme: base
  themeVariables:
    primaryColor: "#e3f2fd"
    primaryTextColor: "#000"
    primaryBorderColor: "#1976d2"
    lineColor: "#424242"
    secondaryColor: "#fff3e0"
    tertiaryColor: "#f3e5f5"
---
erDiagram
	direction TB
	"🔵 H_CUSTOMER" {
		bytea customer_hkey PK ""  
		string bk_customer  ""  
		timestamp load_dts  ""  
		string record_source  ""  
	}
	"🔵 H_PRODUCT" {
		bytea product_hkey PK ""  
		string bk_product  ""  
		timestamp load_dts  ""  
		string record_source  ""  
	}
	"🔵 H_LOCATION" {
		bytea location_hkey PK ""  
		string bk_location  ""  
		timestamp load_dts  ""  
		string record_source  ""  
	}
	"🔵 H_ORDER" {
		bytea order_hkey PK ""  
		string bk_order  ""  
		timestamp load_dts  ""  
		string record_source  ""  
	}
	"🟢 L_ORDER_CUSTOMER" {
		bytea l_order_customer_hkey PK ""  
		bytea order_hkey FK ""  
		bytea customer_hkey FK ""  
		timestamp load_dts  ""  
		string record_source  ""  
	}
	"🟢 L_ORDER_PRODUCT" {
		bytea l_order_product_hkey PK ""  
		bytea order_hkey FK ""  
		bytea product_hkey FK ""  
		timestamp load_dts  ""  
		string record_source  ""  
	}
	"🟢 L_ORDER_LOCATION" {
		bytea l_order_location_hkey PK ""  
		bytea order_hkey FK ""  
		bytea location_hkey FK ""  
		timestamp load_dts  ""  
		string record_source  ""  
	}
	"🟡 S_CUSTOMER_ATTR" {
		bytea customer_hkey PK,FK ""  
		timestamp load_dts PK ""  
		string segment  ""  
		bytea hashdiff  ""  
		string record_source  ""  
	}
	"🟡 S_PRODUCT_ATTR" {
		bytea product_hkey PK,FK ""  
		timestamp load_dts PK ""  
		string category  ""  
		string sub_category  ""  
		bytea hashdiff  ""  
		string record_source  ""  
	}
	"🟡 S_LOCATION_ATTR" {
		bytea location_hkey PK,FK ""  
		timestamp load_dts PK ""  
		string country  ""  
		string state  ""  
		string city  ""  
		string postal_code  ""  
		string region  ""  
		bytea hashdiff  ""  
		string record_source  ""  
	}
	"🟡 S_ORDER_METRICS" {
		bytea order_hkey PK,FK ""  
		timestamp load_dts PK ""  
		string ship_mode  ""  
		numeric sales  ""  
		integer quantity  ""  
		numeric discount  ""  
		numeric profit  ""  
		bytea hashdiff  ""  
		string record_source  ""  
	}
	"🔵 H_CUSTOMER"||--o{"🟢 L_ORDER_CUSTOMER":"  "
	"🔵 H_ORDER"||--o{"🟢 L_ORDER_CUSTOMER":"  "
	"🔵 H_ORDER"||--o{"🟢 L_ORDER_PRODUCT":"  "
	"🔵 H_PRODUCT"||--o{"🟢 L_ORDER_PRODUCT":"  "
	"🔵 H_ORDER"||--o{"🟢 L_ORDER_LOCATION":"  "
	"🔵 H_LOCATION"||--o{"🟢 L_ORDER_LOCATION":"  "
	"🔵 H_CUSTOMER"||--o{"🟡 S_CUSTOMER_ATTR":"  "
	"🔵 H_PRODUCT"||--o{"🟡 S_PRODUCT_ATTR":"  "
	"🔵 H_LOCATION"||--o{"🟡 S_LOCATION_ATTR":"  "
	"🔵 H_ORDER"||--o{"🟡 S_ORDER_METRICS":"  "
```
