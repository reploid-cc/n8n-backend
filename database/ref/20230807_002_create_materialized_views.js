/**
 * Migration để tạo materialized views cho các báo cáo thống kê
 */
exports.up = function(knex) {
  return knex.schema
    // 1. Materialized view cho thống kê workflow executions hàng ngày
    .raw(`
      CREATE MATERIALIZED VIEW IF NOT EXISTS n8n.mv_daily_workflow_stats AS
      SELECT
        DATE(started_at) AS execution_date,
        workflow_id,
        COUNT(*) AS total_executions,
        SUM(CASE WHEN status = 'success' THEN 1 ELSE 0 END) AS successful_executions,
        SUM(CASE WHEN status = 'error' THEN 1 ELSE 0 END) AS failed_executions,
        AVG(duration_ms) AS avg_duration_ms,
        MAX(duration_ms) AS max_duration_ms,
        MIN(duration_ms) AS min_duration_ms
      FROM 
        n8n.workflow_executions
      WHERE 
        started_at IS NOT NULL
      GROUP BY 
        DATE(started_at), workflow_id
      ORDER BY 
        DATE(started_at) DESC, workflow_id;
    `)
    .raw(`
      CREATE UNIQUE INDEX IF NOT EXISTS idx_mv_daily_workflow_stats_date_workflow
      ON n8n.mv_daily_workflow_stats(execution_date, workflow_id);
    `)
    
    // 2. Materialized view cho thống kê người dùng theo tiers
    .raw(`
      CREATE MATERIALIZED VIEW IF NOT EXISTS n8n.mv_user_tier_stats AS
      SELECT
        t.id AS tier_id,
        t.name AS tier_name,
        COUNT(u.id) AS user_count,
        COUNT(DISTINCT w.id) AS workflow_count,
        COUNT(DISTINCT we.id) AS execution_count,
        (t.limits->>'max_workflows')::int AS max_workflows_limit,
        (t.limits->>'max_executions_per_day')::int AS max_executions_limit
      FROM
        n8n.user_tiers t
        LEFT JOIN n8n.user_tier_assignments uta ON t.id = uta.tier_id
        LEFT JOIN n8n.users u ON uta.user_id = u.id
        LEFT JOIN n8n.user_workflow_permissions uwp ON u.id = uwp.user_id
        LEFT JOIN n8n.workflows w ON uwp.workflow_id = w.id
        LEFT JOIN n8n.workflow_executions we ON w.id = we.workflow_id
      GROUP BY
        t.id, t.name, t.limits
      ORDER BY
        t.name;
    `)
    .raw(`
      CREATE UNIQUE INDEX IF NOT EXISTS idx_mv_user_tier_stats_tier_id
      ON n8n.mv_user_tier_stats(tier_id);
    `)
    
    // 3. Materialized view cho top workflows theo số lần thực thi
    .raw(`
      CREATE MATERIALIZED VIEW IF NOT EXISTS n8n.mv_top_workflows AS
      SELECT
        w.id AS workflow_id,
        w.name AS workflow_name,
        COUNT(we.id) AS execution_count,
        SUM(CASE WHEN we.status = 'success' THEN 1 ELSE 0 END) AS successful_count,
        SUM(CASE WHEN we.status = 'error' THEN 1 ELSE 0 END) AS error_count,
        AVG(we.duration_ms) AS avg_duration_ms,
        MAX(we.duration_ms) AS max_duration_ms,
        MIN(we.finished_at - we.started_at) AS min_duration,
        COUNT(DISTINCT uwp.user_id) AS user_count
      FROM
        n8n.workflows w
        LEFT JOIN n8n.workflow_executions we ON w.id = we.workflow_id
        LEFT JOIN n8n.user_workflow_permissions uwp ON w.id = uwp.workflow_id
      GROUP BY
        w.id, w.name
      ORDER BY
        execution_count DESC;
    `)
    .raw(`
      CREATE UNIQUE INDEX IF NOT EXISTS idx_mv_top_workflows_workflow_id
      ON n8n.mv_top_workflows(workflow_id);
    `)
    
    // 4. Tạo function để refresh materialized views
    .raw(`
      CREATE OR REPLACE FUNCTION n8n.refresh_all_materialized_views()
      RETURNS void AS $$
      BEGIN
        REFRESH MATERIALIZED VIEW CONCURRENTLY n8n.mv_daily_workflow_stats;
        REFRESH MATERIALIZED VIEW CONCURRENTLY n8n.mv_user_tier_stats;
        REFRESH MATERIALIZED VIEW CONCURRENTLY n8n.mv_top_workflows;
      END;
      $$ LANGUAGE plpgsql;
    `)
    
    // 5. Tạo function định kỳ refresh materialized views hàng ngày
    .raw(`
      CREATE OR REPLACE FUNCTION n8n.create_refresh_mv_job()
      RETURNS void AS $$
      BEGIN
        -- Check if pg_cron extension is available
        IF EXISTS (
          SELECT 1 FROM pg_extension WHERE extname = 'pg_cron'
        ) THEN
          -- Create cron job to refresh materialized views daily at 1:00 AM
          PERFORM cron.schedule('0 1 * * *', 'SELECT n8n.refresh_all_materialized_views()');
        ELSE
          RAISE NOTICE 'pg_cron extension not available. Manual refresh of materialized views will be required.';
        END IF;
      END;
      $$ LANGUAGE plpgsql;
    `);
};

exports.down = function(knex) {
  return knex.schema
    .raw(`DROP FUNCTION IF EXISTS n8n.create_refresh_mv_job()`)
    .raw(`DROP FUNCTION IF EXISTS n8n.refresh_all_materialized_views()`)
    .raw(`DROP MATERIALIZED VIEW IF EXISTS n8n.mv_top_workflows`)
    .raw(`DROP MATERIALIZED VIEW IF EXISTS n8n.mv_user_tier_stats`)
    .raw(`DROP MATERIALIZED VIEW IF EXISTS n8n.mv_daily_workflow_stats`);
}; 