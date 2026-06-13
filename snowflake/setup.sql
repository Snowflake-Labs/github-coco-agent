-- ┌─ Variables ──────────────────────────────────────────────────────────────┐
-- │  PREFIX     : resource name prefix, e.g. MYORG                           │
-- │  REPO_PATH  : GitHub org/repo, e.g. myorg/github-coco-agent              │
-- └──────────────────────────────────────────────────────────────────────────┘
--
-- Run:
--   snow sql -f snowflake/setup.sql \
--     -D "PREFIX=MYORG" \
--     -D "REPO_PATH=myorg/github-coco-agent" \
--     -c <your-connection>
--
-- Safe to re-run — all statements use IF NOT EXISTS / ALTER ... SET.

USE ROLE ACCOUNTADMIN;

-- Role
CREATE ROLE IF NOT EXISTS <% PREFIX %>_GITHUB_COCO_AGENT_ROLE;
GRANT ROLE <% PREFIX %>_GITHUB_COCO_AGENT_ROLE TO ROLE SYSADMIN;

-- Warehouse
CREATE WAREHOUSE IF NOT EXISTS <% PREFIX %>_GITHUB_COCO_AGENT_WH
  WAREHOUSE_SIZE = 'X-SMALL'
  AUTO_SUSPEND   = 60
  AUTO_RESUME    = TRUE;
GRANT USAGE ON WAREHOUSE <% PREFIX %>_GITHUB_COCO_AGENT_WH
  TO ROLE <% PREFIX %>_GITHUB_COCO_AGENT_ROLE;

-- Cortex access
-- Required for cortex exec to call Snowflake Cortex AI endpoints (REST API).
-- cortex exec authenticates via OIDC, then calls POST /api/v2/cortex/inference:complete.
-- Snowflake checks for this database role on the session before serving any LLM request.
-- Without it: auth succeeds but every model inference call returns 403 Forbidden.
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER
  TO ROLE <% PREFIX %>_GITHUB_COCO_AGENT_ROLE;

-- WORKLOAD_IDENTITY user
-- Note: WORKLOAD_IDENTITY users have no password — omit it entirely.
CREATE USER IF NOT EXISTS <% PREFIX %>_GITHUB_COCO_AGENT_USER
  TYPE              = WORKLOAD_IDENTITY
  DEFAULT_ROLE      = <% PREFIX %>_GITHUB_COCO_AGENT_ROLE
  DEFAULT_WAREHOUSE = <% PREFIX %>_GITHUB_COCO_AGENT_WH;
GRANT ROLE <% PREFIX %>_GITHUB_COCO_AGENT_ROLE
  TO USER <% PREFIX %>_GITHUB_COCO_AGENT_USER;

-- OIDC trust — binds to pushes on the main branch of your repo.
-- Note: SUBJECT reflects what *triggered* the workflow (a push to main),
--       not what the workflow does. Both scan and fix jobs share this identity.
-- Note: The GitHub Actions OIDC token audience is set automatically by
--       the Snowflake CLI action (use-oidc: true) — no manual config needed.
ALTER USER <% PREFIX %>_GITHUB_COCO_AGENT_USER SET
  EXTERNAL_OAUTH_ISSUER = 'https://token.actions.githubusercontent.com'
  SUBJECT               = 'repo:<% REPO_PATH %>:ref:refs/heads/main';
