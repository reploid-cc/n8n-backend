/**
 * Migration để tối ưu hóa các indexes sau khi kiểm thử hiệu năng
 */
exports.up = function(knex) {
  return knex.schema
    // 1. Tối ưu tìm kiếm workflow theo tên và mô tả
    .raw(`
      CREATE INDEX IF NOT EXISTS idx_workflows_name_description ON n8n.workflows 
      USING gin(to_tsvector('simple', name || ' ' || COALESCE(description, '')));
    `)
    
    // 2. Tối ưu truy vấn workflow executions
    .raw(`
      CREATE INDEX IF NOT EXISTS idx_workflow_executions_workflow_id_status ON n8n.workflow_executions(workflow_id, status);
    `)
    .raw(`
      CREATE INDEX IF NOT EXISTS idx_workflow_executions_started_at ON n8n.workflow_executions(started_at DESC);
    `)
    
    // 3. Index cho tìm kiếm theo is_public
    .raw(`
      CREATE INDEX IF NOT EXISTS idx_workflows_is_public ON n8n.workflows(is_public) WHERE is_public = true;
    `)
    
    // 4. Index cho truy vấn user workflow permissions
    .raw(`
      CREATE INDEX IF NOT EXISTS idx_user_workflow_permissions_user_workflow ON n8n.user_workflow_permissions(user_id, workflow_id);
    `)
    .raw(`
      CREATE INDEX IF NOT EXISTS idx_user_workflow_permissions_workflow_permission ON n8n.user_workflow_permissions(workflow_id, permission);
    `)
    
    // 5. Index cho JSON fields
    .raw(`
      CREATE INDEX IF NOT EXISTS idx_workflow_executions_input_jsonb ON n8n.workflow_executions USING gin(input::jsonb);
    `)
    .raw(`
      CREATE INDEX IF NOT EXISTS idx_workflow_executions_output_jsonb ON n8n.workflow_executions USING gin(output::jsonb);
    `)
    
    // 6. Index cho user tiers
    .raw(`
      CREATE INDEX IF NOT EXISTS idx_user_tier_assignments_tier_id ON n8n.user_tier_assignments(tier_id);
    `)
    
    // 7. Index cho truy vấn workflow versions
    .raw(`
      CREATE INDEX IF NOT EXISTS idx_workflow_versions_workflow_id_version ON n8n.workflow_versions(workflow_id, version);
    `)
    
    // 8. Tối ưu các truy vấn theo ngày tháng
    .raw(`
      CREATE INDEX IF NOT EXISTS idx_workflow_executions_date ON n8n.workflow_executions(DATE(started_at));
    `);
};

exports.down = function(knex) {
  return knex.schema
    .raw(`DROP INDEX IF EXISTS n8n.idx_workflows_name_description`)
    .raw(`DROP INDEX IF EXISTS n8n.idx_workflow_executions_workflow_id_status`)
    .raw(`DROP INDEX IF EXISTS n8n.idx_workflow_executions_started_at`)
    .raw(`DROP INDEX IF EXISTS n8n.idx_workflows_is_public`)
    .raw(`DROP INDEX IF EXISTS n8n.idx_user_workflow_permissions_user_workflow`)
    .raw(`DROP INDEX IF EXISTS n8n.idx_user_workflow_permissions_workflow_permission`)
    .raw(`DROP INDEX IF EXISTS n8n.idx_workflow_executions_input_jsonb`)
    .raw(`DROP INDEX IF EXISTS n8n.idx_workflow_executions_output_jsonb`)
    .raw(`DROP INDEX IF EXISTS n8n.idx_user_tier_assignments_tier_id`)
    .raw(`DROP INDEX IF EXISTS n8n.idx_workflow_versions_workflow_id_version`)
    .raw(`DROP INDEX IF EXISTS n8n.idx_workflow_executions_date`);
}; 