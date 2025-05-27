// migrations/20230803_002_create_workflow_tier_limits_table.js
exports.up = function(knex) {
  return knex.schema.withSchema('n8n').createTable('workflow_tier_limits', function(table) {
    table.uuid('id').primary().defaultTo(knex.raw('uuid_generate_v4()'));
    table.uuid('workflow_id').notNullable().references('id').inTable('n8n.workflows').onDelete('CASCADE');
    table.string('tier', 50).notNullable(); // 'free', 'pro', 'premium', 'vip'
    table.string('limit_unit', 50).notNullable(); // 'executions_per_day', 'execution_time_sec', etc.
    table.integer('limit_value').notNullable();
    table.timestamp('created_at').notNullable().defaultTo(knex.fn.now());
    table.timestamp('updated_at').notNullable().defaultTo(knex.fn.now());
    
    // Unique constraint
    table.unique(['workflow_id', 'tier', 'limit_unit']);
    
    // Indexes
    table.index('workflow_id');
    table.index('tier');
  });
};

exports.down = function(knex) {
  return knex.schema.withSchema('n8n').dropTable('workflow_tier_limits');
}; 