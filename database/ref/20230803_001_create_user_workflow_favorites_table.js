// migrations/20230803_001_create_user_workflow_favorites_table.js
exports.up = function(knex) {
  return knex.schema.withSchema('n8n').createTable('user_workflow_favorites', function(table) {
    table.uuid('id').primary().defaultTo(knex.raw('uuid_generate_v4()'));
    table.uuid('user_id').notNullable().references('id').inTable('n8n.users').onDelete('CASCADE');
    table.uuid('workflow_id').notNullable().references('id').inTable('n8n.workflows').onDelete('CASCADE');
    table.timestamp('created_at').notNullable().defaultTo(knex.fn.now());
    
    // Unique constraint
    table.unique(['user_id', 'workflow_id']);
    
    // Indexes
    table.index('user_id');
    table.index('workflow_id');
  });
};

exports.down = function(knex) {
  return knex.schema.withSchema('n8n').dropTable('user_workflow_favorites');
}; 