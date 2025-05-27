// migrations/20230802_001_create_workflows_table.js
exports.up = function(knex) {
  return knex.schema.withSchema('n8n').createTable('workflows', function(table) {
    table.uuid('id').primary().defaultTo(knex.raw('uuid_generate_v4()'));
    table.string('name', 255).notNullable();
    table.text('description');
    table.string('slug').unique();
    table.string('n8n_workflow_id', 255);
    table.boolean('is_public').notNullable().defaultTo(false);
    table.uuid('current_version_id').nullable();
    table.jsonb('input');
    table.jsonb('output');
    table.string('doc_url');
    table.timestamp('created_at').notNullable().defaultTo(knex.fn.now());
    table.timestamp('updated_at').notNullable().defaultTo(knex.fn.now());
    
    // Indexes
    table.index('name');
    table.index('is_public');
  });
};

exports.down = function(knex) {
  return knex.schema.withSchema('n8n').dropTable('workflows');
}; 