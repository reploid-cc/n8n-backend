// migrations/20230801_003_create_user_oauth_table.js
exports.up = function(knex) {
  return knex.schema.withSchema('n8n').createTable('user_oauth', function(table) {
    table.uuid('id').primary().defaultTo(knex.raw('uuid_generate_v4()'));
    table.uuid('user_id').notNullable().references('id').inTable('n8n.users').onDelete('CASCADE');
    table.string('provider', 50).notNullable(); // 'google', 'github', etc.
    table.string('provider_user_id').notNullable();
    table.string('access_token');
    table.string('refresh_token');
    table.jsonb('profile_data');
    table.timestamp('created_at').notNullable().defaultTo(knex.fn.now());
    table.timestamp('updated_at').notNullable().defaultTo(knex.fn.now());
    
    // Unique constraint
    table.unique(['provider', 'provider_user_id']);
    
    // Indexes
    table.index('user_id');
    table.index('provider');
  });
};

exports.down = function(knex) {
  return knex.schema.withSchema('n8n').dropTable('user_oauth');
}; 