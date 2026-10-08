# LinguaPop Marketing Mart

## About the Project

LinguaPop is a fictional mobile app for learning foreign languages. The company buys paid traffic: it pays ad networks for app installs. To understand which campaigns pay off and which waste budget, it needs a marketing mart: a single table that brings together ad spend and the revenue those campaigns generated.

Right now this data sits in four separate tables that are not connected to each other.

## Tasks

1. Join the four tables and build a marketing mart at the ad campaign level.
2. Use the mart to determine which campaigns pay off and which do not (Profit, ROI).
3. Build a Tableau dashboard with several visualizations.

## Data

All data is synthetic and was created for this learning project. The task logic is inspired by a real-world assignment, but no data from a real company was used. Period: August – September 2026.

| Table | Contents |
|---|---|
| `cost_table` | Ad spend |
| `ad_revenue_raw` | In-app ad revenue (free version) |
| `in_app_events_report` | Subscriptions, purchases and related events |
| `non_org_installs_report` | App installs from ad sources |

## Tools

Google BigQuery (Sandbox), SQL, Tableau Public, GitHub.

## Process

### 1. Data exploration

I started by reviewing all four tables and their structure to understand what each source contains and which fields can be used to join them. I then checked the time period: all four tables cover **1 August – 30 September 2026**, so the data can be combined consistently.

The common key is `campaign_id`, the unique identifier of an ad campaign. The `non_org_installs_report` table was reviewed but not used in the mart, since installs are not needed to calculate revenue, profit and ROI.

### 2. Mart structure

The mart is built at the level of a single ad campaign: one row = one campaign (`cost_table` contains 40 unique campaigns). It includes:

- **Campaign ID**: campaign identifier
- **Campaign**: campaign name
- **Media Source**: traffic source
- **Total Cost**: total ad spend
- **Ad Revenue**: revenue from in-app ads
- **In-App Revenue**: revenue from in-app events (purchases, subscriptions)
- **Total Revenue**: total revenue of the campaign
- **Profit**: campaign profit
- **ROI**: return on ad spend

### 3. Aggregation before joining

To get correct results, I first aggregated spend and each revenue type separately at the `campaign_id` level, and only then joined them. This prevents rows from being duplicated: a campaign has many revenue rows, and joining raw tables would multiply them.

### 4. Joining the tables

`cost_table` is the base table, because it holds ad spend and the full list of campaigns. I joined revenue with `LEFT JOIN`, which keeps every campaign even if one of the revenue types is missing.

Before calculating the metrics, I checked how complete the revenue data is for each of the 40 campaigns:

- 5 campaigns have no Ad Revenue;
- 9 campaigns have no In-App Revenue;
- 2 campaigns have no revenue of either type (these are included in both counts above).

For missing values I used `COALESCE(..., 0)`: if a campaign has no record for a given revenue type, it is counted as 0 instead of NULL, and the campaign stays in the result.
### 5. Calculating the metrics

After joining the data at the campaign level, I calculated the main financial metrics that show how effective each campaign is.

**Total Cost** is the total ad spend of a campaign: the sum of all `cost_usd` values for a given `campaign_id`. If a campaign had several records in `cost_table`, all of its spend is summed into a single value.

```sql
SUM(cost_usd) AS total_cost_usd
```

**Ad Revenue** is revenue earned from in-app ads: the sum of `event_revenue_usd` from `ad_revenue_raw` for each campaign.

```sql
SUM(event_revenue_usd) AS ad_revenue_usd
```

**In-App Revenue** is revenue from in-app events such as purchases and subscriptions: the sum of `event_revenue_usd` from `in_app_events_report` for each campaign.

```sql
SUM(event_revenue_usd) AS in_app_revenue_usd
```

**Total Revenue** is the total revenue a campaign brought in from both sources: `Total Revenue = Ad Revenue + In-App Revenue`. I used `COALESCE(..., 0)` so that a missing revenue source counts as 0 rather than NULL.

```sql
COALESCE(ad_revenue_usd, 0) + COALESCE(in_app_revenue_usd, 0) AS total_revenue_usd
```

**Profit** is the financial result of a campaign after ad spend: `Profit = Total Revenue − Total Cost`. A positive value means the campaign earned more than it cost; a negative value means it lost money.

```sql
COALESCE(ad_revenue_usd, 0) + COALESCE(in_app_revenue_usd, 0) - total_cost_usd AS profit_usd
```

**ROI** (Return on Investment) shows how profitable ad spend was relative to its size: `ROI = (Profit / Total Cost) × 100%`. I used `SAFE_DIVIDE` so that a campaign with zero spend returns NULL instead of causing a division-by-zero error.

```sql
SAFE_DIVIDE(profit_usd, total_cost_usd) * 100 AS roi_percent
```

ROI measures efficiency, not the absolute size of the profit. That is why a campaign with very low spend can have an extremely high ROI. In this data, one campaign spent only $4.39 and earned a $294.80 profit, which gives an ROI of about 6,715%, while campaigns with spend in the thousands of dollars have a much lower ROI but a far larger absolute profit. For this reason, ROI should always be read together with Profit and Total Cost.
