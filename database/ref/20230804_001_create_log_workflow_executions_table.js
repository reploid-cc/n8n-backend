// migrations/20230804_001_create_log_workflow_executions_table.js
exports.up = function(knex) {
  return knex.schema.withSchema('n8n').createTable('log_workflow_executions', function(table) {
    table.uuid('id').primary().defaultTo(knex.raw('uuid_generate_v4()'));
    table.uuid('workflow_id').notNullable().references('id').inTable('n8n.workflows').onDelete('CASCADE');
    table.uuid('workflow_version_id').references('id').inTable('n8n.workflow_versions').onDelete('SET NULL');
    table.uuid('user_id').references('id').inTable('n8n.users').onDelete('SET NULL');
    table.string('status', 50).notNullable(); // 'pending', 'running', 'completed', 'failed'
    table.jsonb('input_data');
    table.jsonb('output_data');
    table.text('error_message');
    table.timestamp('started_at').notNullable().defaultTo(knex.fn.now());
    table.timestamp('completed_at');
    table.integer('execution_time_ms');
    
    // Indexes
    table.index('workflow_id');
    table.index('user_id');
    table.index('status');
    table.index('started_at');
  });
};

exports.down = function(knex) {
  return knex.schema.withSchema('n8n').dropTable('log_workflow_executions');
}; 