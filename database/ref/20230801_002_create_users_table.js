// migrations/20230801_002_create_users_table.js
exports.up = function(knex) {
  return knex.schema.withSchema('n8n').createTable('users', function(table) {
    table.uuid('id').primary().defaultTo(knex.raw('uuid_generate_v4()'));
    table.string('email').notNullable().unique();
    table.string('username').unique().notNullable();
    table.string('password');
    table.string('avatar_url');
    table.boolean('is_vip').defaultTo(false);
    table.timestamp('created_at').notNullable().defaultTo(knex.fn.now());
    table.timestamp('updated_at').notNullable().defaultTo(knex.fn.now());
    
    // Indexes
    table.index('email');
    table.index('username');
  });
};

exports.down = function(knex) {
  return knex.schema.withSchema('n8n').dropTable('users');
}; 