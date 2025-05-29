# 📋 Mock Data Scenarios - Business Logic Test Cases

## 🎯 Mục Tiêu
Tạo realistic test data cho 16 tables trong schema "n8n" để test toàn bộ business logic của hệ thống.

---

## 👥 **USER SCENARIOS**

### **Scenario 1: Free User Journey**
- **User:** `demo_free_01` (free tier, 100 credits)
- **Workflow:** Sử dụng workflow `free_autoInbox_fb` (limit: 10 calls/day)
- **Usage Pattern:** 
  - Ngày 1: 8 calls (OK)
  - Ngày 2: 12 calls (2 calls bị block)
  - Ngày 3: 5 calls (OK)
- **Credit Consumption:** 10 credits/call
- **Expected Behavior:** Rate limiting kicks in, usage logs track violations

### **Scenario 2: Pro User Upgrade**
- **User:** `demo_pro_01` (pro tier, 1000 credits)
- **Order:** Mua workflow `premium_dataSync_api` với Pro pricing
- **Workflow Access:** Tier required = premium, nhưng user chỉ có pro tier
- **Expected Behavior:** Access denied, suggest upgrade to premium

### **Scenario 3: Premium User Normal Usage**
- **User:** `demo_premium_01` (premium tier, 5000 credits)
- **Workflows:** Multiple workflows với different limits
  - `premium_dataSync_api`: 500 calls/day
  - `premium_emailMarketing_auto`: 100 calls/day
- **Usage Pattern:** Heavy usage nhưng trong limits
- **Queue Priority:** High priority trong queue system

### **Scenario 4: VIP User Unlimited**
- **User:** `demo_vip_01` (vip tier, 999999 credits)
- **Custom Limits:** Có custom limits cho specific workflows
- **Workflow Access:** Access tất cả workflows, kể cả VIP-only
- **Queue Behavior:** Bypass queue tổng, có queue riêng
- **Worker Assignment:** Dedicated worker containers

---

## 🛒 **ORDER & PAYMENT SCENARIOS**

### **Scenario 5: Monthly Subscription**
- **User:** `demo_pro_02`
- **Order:** Monthly subscription cho workflow bundle
- **Payment:** Recurring payment qua Stripe
- **Expiry:** Auto-renewal sau 30 ngày
- **Access Control:** Immediate access sau payment success

### **Scenario 6: One-time Purchase**
- **User:** `demo_premium_02`
- **Order:** One-time purchase workflow `premium_crm_integration`
- **Payment:** Single payment, lifetime access
- **Workflow Version:** Access to current version + updates trong 1 năm

### **Scenario 7: VIP Custom Development**
- **User:** `demo_vip_02`
- **Order:** Custom workflow development
- **Payment:** Project-based pricing
- **Delivery:** Custom workflow với exclusive access
- **Support:** Dedicated support channel

### **Scenario 8: Failed Payment Recovery**
- **User:** `demo_pro_03`
- **Order:** Payment failed, account suspended
- **Grace Period:** 7 ngày grace period
- **Recovery:** Payment retry, account reactivation
- **Data Retention:** Workflow data preserved during suspension

---

## ⚙️ **WORKFLOW EXECUTION SCENARIOS**

### **Scenario 9: High-Volume Execution**
- **Workflow:** `premium_dataSync_api`
- **Volume:** 1000+ executions/day
- **Performance:** Mix of success/failed executions
- **Worker Load:** Multiple workers processing
- **Monitoring:** Performance metrics tracking

### **Scenario 10: Error Handling & Retry**
- **Workflow:** `pro_emailMarketing_auto`
- **Error Types:** Network timeout, API rate limit, invalid data
- **Retry Logic:** 3 retries với exponential backoff
- **Dead Letter Queue:** Failed jobs sau max retries
- **Notification:** Error alerts to user

### **Scenario 11: Queue Priority Testing**
- **Concurrent Jobs:** 100+ jobs từ different tiers
- **Priority Order:** VIP → Premium → Pro → Free
- **Queue Overflow:** Free users get "system busy" message
- **Resource Allocation:** Dynamic worker scaling

---

## 📊 **LOGGING & ANALYTICS SCENARIOS**

### **Scenario 12: User Activity Tracking**
- **Activities:** Login, workflow execution, settings change
- **Session Management:** Multiple sessions, device tracking
- **IP Tracking:** Geographic usage patterns
- **Behavior Analysis:** Usage patterns for recommendations

### **Scenario 13: Credit System Testing**
- **Credit Purchase:** User mua thêm credits
- **Credit Consumption:** Different workflows consume different amounts
- **Credit Expiry:** Credits expire sau 1 năm
- **Low Balance Alert:** Notification khi credits < 100

### **Scenario 14: Transaction Audit Trail**
- **Payment Processing:** Stripe, PayPal, bank transfer
- **Refund Handling:** Partial/full refunds
- **Chargeback Management:** Dispute resolution
- **Tax Calculation:** VAT/GST based on user location

---

## 🔄 **WORKFLOW VERSION SCENARIOS**

### **Scenario 15: Version Management**
- **Workflow:** `premium_crm_integration`
- **Versions:** v1.0 → v1.1 → v2.0
- **Backward Compatibility:** v1.x users can upgrade
- **Breaking Changes:** v2.0 requires new purchase
- **Migration Path:** Automated migration tools

### **Scenario 16: A/B Testing**
- **Workflow:** `pro_leadGeneration_fb`
- **Versions:** v1.5 (stable) vs v1.6 (beta)
- **User Split:** 80% stable, 20% beta
- **Performance Comparison:** Success rate, execution time
- **Rollback Plan:** Auto-rollback if beta performance drops

---

## 💬 **COMMUNITY FEATURES SCENARIOS**

### **Scenario 17: Rating & Review System**
- **Workflow:** `free_socialMedia_scheduler`
- **Ratings:** 1-5 stars với detailed reviews
- **Review Moderation:** Spam detection, inappropriate content
- **Rating Impact:** Workflow ranking, recommendation algorithm

### **Scenario 18: Comment System**
- **Target:** Workflow executions, workflow definitions
- **Threading:** Nested comments, reply chains
- **Moderation:** User reporting, admin moderation
- **Notifications:** Comment notifications to workflow owners

---

## 🏥 **WORKER & PERFORMANCE SCENARIOS**

### **Scenario 19: Worker Health Monitoring**
- **Workers:** 5 worker containers
- **Health Metrics:** CPU, memory, queue length
- **Auto-scaling:** Scale up/down based on load
- **Failure Recovery:** Worker restart, job redistribution

### **Scenario 20: Performance Optimization**
- **Database:** Query optimization, index usage
- **Caching:** Redis caching for frequent queries
- **CDN:** Static asset delivery
- **Monitoring:** Real-time performance dashboards

---

## 📈 **BUSINESS INTELLIGENCE SCENARIOS**

### **Scenario 21: Revenue Analytics**
- **Metrics:** MRR, churn rate, ARPU
- **Segmentation:** By tier, by workflow, by region
- **Forecasting:** Revenue prediction, growth trends
- **Reporting:** Executive dashboards, automated reports

### **Scenario 22: Usage Analytics**
- **Metrics:** DAU, MAU, workflow popularity
- **Cohort Analysis:** User retention, engagement
- **Feature Usage:** Most/least used features
- **Optimization:** Resource allocation, feature development

---

## 🎯 **DATA VOLUME TARGETS**

### **Realistic Data Distribution:**
- **Users:** 1000 total (600 free, 250 pro, 120 premium, 30 vip)
- **Workflows:** 200 total (50 free, 80 pro, 50 premium, 20 vip)
- **Orders:** 500 total (mix of active/expired/cancelled)
- **Executions:** 10,000 total (last 30 days)
- **Comments:** 2,000 total
- **Ratings:** 1,500 total
- **Transactions:** 800 total
- **Usage Logs:** 50,000 total

### **Time Range:**
- **Historical Data:** 6 months back
- **Active Period:** Last 30 days heavy activity
- **Future Data:** Some orders với future expiry dates

---

## ✅ **VALIDATION CRITERIA**

### **Data Integrity:**
- All foreign key relationships valid
- No orphaned records
- Consistent timestamps
- Realistic value ranges

### **Business Logic:**
- Tier restrictions enforced
- Credit calculations accurate
- Queue priorities correct
- Rate limits realistic

### **Performance:**
- Query response times < 100ms
- Index usage optimized
- No table scans on large tables
- Efficient joins across tables

---

**📝 Note:** Mock data chỉ populate schema "n8n", không touch core tables trong schema "public". 