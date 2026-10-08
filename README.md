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

### 2. Mart granularity

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
