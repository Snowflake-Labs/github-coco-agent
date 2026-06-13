-- Teardown — removes all CoCo agent resources from Snowflake.
-- Run in reverse order of setup.sql.
--
-- Run:
--   snow sql -f snowflake/teardown.sql \
--     -D "PREFIX=MYORG" \
--     -c <your-connection>

USE ROLE ACCOUNTADMIN;

DROP USER      IF EXISTS <% PREFIX %>_GITHUB_COCO_AGENT_USER;
DROP WAREHOUSE IF EXISTS <% PREFIX %>_GITHUB_COCO_AGENT_WH;
DROP ROLE      IF EXISTS <% PREFIX %>_GITHUB_COCO_AGENT_ROLE;
