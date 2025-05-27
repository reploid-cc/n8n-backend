// migrations/20230804_002_create_orders_table.js
exports.up = function(knex) {
  return knex.schema.withSchema('n8n').createTable('orders', function(table) {
    table.uuid('id').primary().defaultTo(knex.raw('uuid_generate_v4()'));
    table.uuid('user_id').notNullable().references('id').inTable('n8n.users').onDelete('CASCADE');
    table.uuid('workflow_id').notNullable().references('id').inTable('n8n.workflows').onDelete('CASCADE');
    table.timestamp('purchase_date').notNullable().defaultTo(knex.fn.now());
    table.timestamp('expiry_date');
    table.boolean('is_active').notNullable().defaultTo(true);
    table.string('transaction_id');
    table.text('note');
    table.boolean('is_vip').notNullable().defaultTo(false);
    table.timestamp('created_at').notNullable().defaultTo(knex.fn.now());
    table.timestamp('updated_at').notNullable().defaultTo(knex.fn.now());
    
    // Indexes
    table.index('user_id');
    table.index('workflow_id');
    table.index('is_active');
    table.index('expiry_date');
  });
};

exports.down = function(knex) {
  return knex.schema.withSchema('n8n').dropTable('orders');
}; 