// migrations/20230802_002_create_workflow_versions_table.js
exports.up = function(knex) {
  return knex.schema.withSchema('n8n').createTable('workflow_versions', function(table) {
    table.uuid('id').primary().defaultTo(knex.raw('uuid_generate_v4()'));
    table.uuid('workflow_id').notNullable().references('id').inTable('n8n.workflows').onDelete('CASCADE');
    table.integer('version').notNullable();
    table.jsonb('configuration').notNullable();
    table.jsonb('form_schema');
    table.timestamp('created_at').notNullable().defaultTo(knex.fn.now());
    
    // Unique constraint
    table.unique(['workflow_id', 'version']);
    
    // Indexes
    table.index('workflow_id');
  }).then(function() {
    // Add foreign key to workflows.current_version_id
    return knex.schema.withSchema('n8n').alterTable('workflows', function(table) {
      table.foreign('current_version_id').references('id').inTable('n8n.workflow_versions').onDelete('SET NULL');
    });
  });
};

exports.down = function(knex) {
  return knex.schema.withSchema('n8n')
    .alterTable('workflows', function(table) {
      table.dropForeign('current_version_id');
    })
    .then(function() {
      return knex.schema.withSchema('n8n').dropTable('workflow_versions');
    });
}; 