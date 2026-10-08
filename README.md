# linguapop-marketing-mart
Marketing mart for a fictional language-learning app: joins ad spend, ad revenue and in-app revenue to show which campaigns pay off. BigQuery SQL + Tableau.
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
