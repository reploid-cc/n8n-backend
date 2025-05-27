/**
 * Migration để sửa các vấn đề trong schema:
 * 1. Thêm trường order_id (FK) vào bảng log_workflow_executions
 * 2. Đổi tên trường count thành usage_count trong bảng log_usage
 */
exports.up = function(knex) {
  return Promise.all([
    // 1. Thêm trường order_id vào bảng log_workflow_executions
    knex.schema.withSchema('n8n').table('log_workflow_executions', function(table) {
      table.uuid('order_id').references('id').inTable('n8n.orders').onDelete('SET NULL');
      // Thêm index cho order_id
      table.index('order_id');
    }),
    
    // 2. Đổi tên trường count thành usage_count trong bảng log_usage
    knex.schema.withSchema('n8n').raw('ALTER TABLE n8n.log_usage RENAME COLUMN count TO usage_count')
  ]);
};

exports.down = function(knex) {
  return Promise.all([
    // 1. Xóa trường order_id khỏi bảng log_workflow_executions
    knex.schema.withSchema('n8n').table('log_workflow_executions', function(table) {
      table.dropColumn('order_id');
    }),
    
    // 2. Đổi tên trường usage_count trở lại thành count trong bảng log_usage
    knex.schema.withSchema('n8n').raw('ALTER TABLE n8n.log_usage RENAME COLUMN usage_count TO count')
  ]);
}; 