// migrations/20230804_003_create_vip_custom_limits_table.js
exports.up = function(knex) {
  return knex.schema.withSchema('n8n').createTable('vip_custom_limits', function(table) {
    table.uuid('id').primary().defaultTo(knex.raw('uuid_generate_v4()'));
    table.uuid('user_id').notNullable().references('id').inTable('n8n.users').onDelete('CASCADE');
    table.uuid('workflow_id').notNullable().references('id').inTable('n8n.workflows').onDelete('CASCADE');
    table.string('limit_unit', 50).notNullable(); // 'executions_per_day', 'execution_time_sec', etc.
    table.integer('limit_value').notNullable();
    table.timestamp('created_at').notNullable().defaultTo(knex.fn.now());
    table.timestamp('updated_at').notNullable().defaultTo(knex.fn.now());
    
    // Unique constraint
    table.unique(['user_id', 'workflow_id', 'limit_unit']);
    
    // Indexes
    table.index('user_id');
    table.index('workflow_id');
  });
};

exports.down = function(knex) {
  return knex.schema.withSchema('n8n').dropTable('vip_custom_limits');
}; 