// migrations/20230801_001_create_schema.js
exports.up = function(knex) {
  return knex.raw('CREATE SCHEMA IF NOT EXISTS n8n')
    .then(() => knex.raw('CREATE EXTENSION IF NOT EXISTS "uuid-ossp"'));
};

exports.down = function(knex) {
  return knex.raw('DROP SCHEMA IF EXISTS n8n CASCADE');
}; 