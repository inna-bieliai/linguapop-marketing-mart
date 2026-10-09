-- LinguaPop marketing mart
-- One row per campaign: ad spend, ad revenue, in-app revenue, profit and ROI.
-- Base table: cost_table (all campaigns). Revenue is aggregated per campaign_id before joining.
-- Note: the table name `cost_table ` contains a trailing space, as created in BigQuery.

WITH costs AS (
  SELECT
    campaign_id,
    campaign,
    media_source,
    SUM(cost_usd) AS total_cost_usd
  FROM `linguapop-portfolio.linguapop.cost_table `
  GROUP BY
    campaign_id,
    campaign,
    media_source
),

ad_revenue AS (
  SELECT
    campaign_id,
    SUM(event_revenue_usd) AS ad_revenue_usd
  FROM `linguapop-portfolio.linguapop.ad_revenue_raw`
  WHERE campaign_id IS NOT NULL
  GROUP BY campaign_id
),

in_app_revenue AS (
  SELECT
    campaign_id,
    SUM(event_revenue_usd) AS in_app_revenue_usd
  FROM `linguapop-portfolio.linguapop.in_app_events_report`
  WHERE campaign_id IS NOT NULL
  GROUP BY campaign_id
)

SELECT
  c.campaign_id,
  c.campaign,
  c.media_source,

  ROUND(c.total_cost_usd, 2) AS total_cost_usd,

  ROUND(
    COALESCE(a.ad_revenue_usd, 0),
    2
  ) AS ad_revenue_usd,

  ROUND(
    COALESCE(i.in_app_revenue_usd, 0),
    2
  ) AS in_app_revenue_usd,

  ROUND(
    COALESCE(a.ad_revenue_usd, 0)
    + COALESCE(i.in_app_revenue_usd, 0),
    2
  ) AS total_revenue_usd,

  ROUND(
    COALESCE(a.ad_revenue_usd, 0)
    + COALESCE(i.in_app_revenue_usd, 0)
    - c.total_cost_usd,
    2
  ) AS profit_usd,

  ROUND(
    SAFE_DIVIDE(
      COALESCE(a.ad_revenue_usd, 0)
      + COALESCE(i.in_app_revenue_usd, 0)
      - c.total_cost_usd,
      c.total_cost_usd
    ) * 100,
    2
  ) AS roi_percent

FROM costs c

LEFT JOIN ad_revenue a
  ON c.campaign_id = a.campaign_id

LEFT JOIN in_app_revenue i
  ON c.campaign_id = i.campaign_id

ORDER BY roi_percent DESC;
