// migrations/20230805_001_create_log_tables.js
exports.up = function(knex) {
  // log_user_activities
  return knex.schema.withSchema('n8n').createTable('log_user_activities', function(table) {
    table.uuid('id').primary().defaultTo(knex.raw('uuid_generate_v4()'));
    table.uuid('user_id').references('id').inTable('n8n.users').onDelete('SET NULL');
    table.string('activity_type', 50).notNullable();
    table.jsonb('activity_data');
    table.timestamp('created_at').notNullable().defaultTo(knex.fn.now());
    
    // Indexes
    table.index('user_id');
    table.index('activity_type');
    table.index('created_at');
  })
  
  // log_workflow_changes
  .then(() => {
    return knex.schema.withSchema('n8n').createTable('log_workflow_changes', function(table) {
      table.uuid('id').primary().defaultTo(knex.raw('uuid_generate_v4()'));
      table.uuid('workflow_id').notNullable().references('id').inTable('n8n.workflows').onDelete('CASCADE');
      table.uuid('user_id').references('id').inTable('n8n.users').onDelete('SET NULL');
      table.string('change_type', 50).notNullable(); // 'created', 'updated', 'deleted', 'published'
      table.jsonb('change_data');
      table.timestamp('created_at').notNullable().defaultTo(knex.fn.now());
      
      // Indexes
      table.index('workflow_id');
      table.index('user_id');
      table.index('change_type');
      table.index('created_at');
    });
  })
  
  // log_transactions
  .then(() => {
    return knex.schema.withSchema('n8n').createTable('log_transactions', function(table) {
      table.uuid('id').primary().defaultTo(knex.raw('uuid_generate_v4()'));
      table.uuid('user_id').references('id').inTable('n8n.users').onDelete('SET NULL');
      table.uuid('order_id').references('id').inTable('n8n.orders').onDelete('SET NULL');
      table.string('transaction_type', 50).notNullable(); // 'purchase', 'refund', etc.
      table.decimal('amount', 10, 2);
      table.string('currency', 3).defaultTo('USD');
      table.string('status', 50).notNullable(); // 'success', 'failed', 'pending'
      table.string('payment_method', 50);
      table.jsonb('transaction_data');
      table.timestamp('created_at').notNullable().defaultTo(knex.fn.now());
      
      // Indexes
      table.index('user_id');
      table.index('order_id');
      table.index('transaction_type');
      table.index('status');
      table.index('created_at');
    });
  })
  
  // log_usage
  .then(() => {
    return knex.schema.withSchema('n8n').createTable('log_usage', function(table) {
      table.uuid('id').primary().defaultTo(knex.raw('uuid_generate_v4()'));
      table.uuid('user_id').references('id').inTable('n8n.users').onDelete('SET NULL');
      table.uuid('workflow_id').references('id').inTable('n8n.workflows').onDelete('CASCADE');
      table.string('resource_type', 50).notNullable(); // 'workflow_execution', 'api_call', etc.
      table.integer('count').notNullable().defaultTo(1);
      table.date('usage_date').notNullable();
      table.timestamp('created_at').notNullable().defaultTo(knex.fn.now());
      
      // Indexes
      table.index('user_id');
      table.index('workflow_id');
      table.index('resource_type');
      table.index('usage_date');
    });
  });
};

exports.down = function(knex) {
  return knex.schema.withSchema('n8n')
    .dropTableIfExists('log_usage')
    .dropTableIfExists('log_transactions')
    .dropTableIfExists('log_workflow_changes')
    .dropTableIfExists('log_user_activities');
}; 