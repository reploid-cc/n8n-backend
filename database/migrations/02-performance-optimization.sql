-- Performance Optimization for n8n Database
-- Advanced indexes and materialized views (20230807_001, 20230807_002)

-- Advanced indexes for search optimization (20230807_001)
CREATE INDEX IF NOT EXISTS idx_workflows_name_description ON n8n.workflows 
USING gin(to_tsvector('simple', name || ' ' || COALESCE(description, '')));

CREATE INDEX IF NOT EXISTS idx_workflow_executions_workflow_id_status ON n8n.log_workflow_executions(workflow_id, status);
CREATE INDEX IF NOT EXISTS idx_workflow_executions_started_at ON n8n.log_workflow_executions(started_at DESC);
CREATE INDEX IF NOT EXISTS idx_workflows_is_public ON n8n.workflows(is_public) WHERE is_public = true;

-- JSON indexes for performance
CREATE INDEX IF NOT EXISTS idx_workflow_executions_input_jsonb ON n8n.log_workflow_executions USING gin(input_data::jsonb);
CREATE INDEX IF NOT EXISTS idx_workflow_executions_output_jsonb ON n8n.log_workflow_executions USING gin(output_data::jsonb);

-- Date-based indexes
CREATE INDEX IF NOT EXISTS idx_workflow_executions_date ON n8n.log_workflow_executions(DATE(started_at));

-- Materialized view for daily workflow statistics (20230807_002)
CREATE MATERIALIZED VIEW IF NOT EXISTS n8n.mv_daily_workflow_stats AS
SELECT
    DATE(started_at) AS execution_date,
    workflow_id,
    COUNT(*) AS total_executions,
    SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) AS successful_executions,
    SUM(CASE WHEN status = 'failed' THEN 1 ELSE 0 END) AS failed_executions,
    AVG(execution_time_ms) AS avg_duration_ms,
    MAX(execution_time_ms) AS max_duration_ms,
    MIN(execution_time_ms) AS min_duration_ms
FROM n8n.log_workflow_executions
WHERE started_at IS NOT NULL
GROUP BY DATE(started_at), workflow_id
ORDER BY DATE(started_at) DESC, workflow_id;

CREATE UNIQUE INDEX IF NOT EXISTS idx_mv_daily_workflow_stats_date_workflow
ON n8n.mv_daily_workflow_stats(execution_date, workflow_id);

-- Materialized view for top workflows
CREATE MATERIALIZED VIEW IF NOT EXISTS n8n.mv_top_workflows AS
SELECT
    w.id AS workflow_id,
    w.name AS workflow_name,
    COUNT(we.id) AS execution_count,
    SUM(CASE WHEN we.status = 'completed' THEN 1 ELSE 0 END) AS successful_count,
    SUM(CASE WHEN we.status = 'failed' THEN 1 ELSE 0 END) AS error_count,
    AVG(we.execution_time_ms) AS avg_duration_ms,
    MAX(we.execution_time_ms) AS max_duration_ms,
    COUNT(DISTINCT uwf.user_id) AS user_count
FROM n8n.workflows w
LEFT JOIN n8n.log_workflow_executions we ON w.id = we.workflow_id
LEFT JOIN n8n.user_workflow_favorites uwf ON w.id = uwf.workflow_id
GROUP BY w.id, w.name
ORDER BY execution_count DESC;

CREATE UNIQUE INDEX IF NOT EXISTS idx_mv_top_workflows_workflow_id
ON n8n.mv_top_workflows(workflow_id);

-- Materialized view for workflow tier statistics
CREATE MATERIALIZED VIEW IF NOT EXISTS n8n.mv_workflow_tier_stats AS
SELECT
    wtl.tier,
    COUNT(DISTINCT wtl.workflow_id) AS workflow_count,
    COUNT(DISTINCT we.id) AS total_executions,
    AVG(we.execution_time_ms) AS avg_execution_time,
    COUNT(DISTINCT uwf.user_id) AS user_count
FROM n8n.workflow_tier_limits wtl
LEFT JOIN n8n.log_workflow_executions we ON wtl.workflow_id = we.workflow_id
LEFT JOIN n8n.user_workflow_favorites uwf ON wtl.workflow_id = uwf.workflow_id
GROUP BY wtl.tier
ORDER BY wtl.tier;

CREATE UNIQUE INDEX IF NOT EXISTS idx_mv_workflow_tier_stats_tier
ON n8n.mv_workflow_tier_stats(tier);

-- Function to refresh all materialized views
CREATE OR REPLACE FUNCTION n8n.refresh_all_materialized_views()
RETURNS void AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY n8n.mv_daily_workflow_stats;
    REFRESH MATERIALIZED VIEW CONCURRENTLY n8n.mv_top_workflows;
    REFRESH MATERIALIZED VIEW CONCURRENTLY n8n.mv_workflow_tier_stats;
END;
$$ LANGUAGE plpgsql; 