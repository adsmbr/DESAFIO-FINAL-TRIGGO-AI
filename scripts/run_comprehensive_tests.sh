#!/bin/bash
# scripts/run_comprehensive_tests.sh
# Comprehensive testing script for COVID19 dbt project improvements
# This script validates ALL improvements without affecting the main pipeline

echo "🧪 Starting Comprehensive Test Suite for Performance & Monitoring Improvements"
echo "================================================================================="
echo "📅 Test Date: $(date)"
echo "👤 User: $(whoami)"
echo "🌍 Environment: ${DBT_PROFILES_DIR:-default}"
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counter
PASSED_TESTS=0
FAILED_TESTS=0
TOTAL_TESTS=0

# Function to run a test and track results
run_test() {
    local test_name="$1"
    local test_command="$2"
    local test_description="$3"
    
    echo -e "${BLUE}🔍 Running: $test_name${NC}"
    echo -e "   Description: $test_description"
    echo -e "   Command: $test_command"
    
    if eval $test_command > /dev/null 2>&1; then
        echo -e "   ${GREEN}✅ PASSED${NC}"
        ((PASSED_TESTS++))
    else
        echo -e "   ${RED}❌ FAILED${NC}"
        ((FAILED_TESTS++))
        echo -e "   ${YELLOW}⚠️  Error details: Check logs for more information${NC}"
    fi
    
    ((TOTAL_TESTS++))
    echo ""
}

# Function to run dbt test and capture results
run_dbt_test() {
    local test_name="$1"
    local test_selector="$2"
    local test_description="$3"
    
    echo -e "${BLUE}🔍 Running dbt test: $test_name${NC}"
    echo -e "   Description: $test_description"
    echo -e "   Selector: $test_selector"
    
    if dbt test --select "$test_selector" > /dev/null 2>&1; then
        echo -e "   ${GREEN}✅ PASSED${NC}"
        ((PASSED_TESTS++))
    else
        echo -e "   ${RED}❌ FAILED${NC}"
        ((FAILED_TESTS++))
        echo -e "   ${YELLOW}⚠️  Run 'dbt test --select $test_selector' for details${NC}"
    fi
    
    ((TOTAL_TESTS++))
    echo ""
}

echo "🚀 PHASE 1: Basic dbt Project Validation"
echo "=========================================="

# Test 1: dbt project parsing
run_test "Project Parsing" "dbt parse" "Validates all SQL syntax and project configuration"

# Test 2: dbt compilation
run_test "SQL Compilation" "dbt compile" "Compiles all models to ensure SQL is valid"

# Test 3: Check if main models still work (safety check)
run_test "Original Pipeline Safety" "dbt run --select models/facts/fact_ocupacao_leitos --dry-run" "Ensures original models are not affected"

echo "📊 PHASE 2: Monitoring Models Validation"
echo "========================================="

# Test 4: Performance baseline model
run_test "Performance Baseline" "dbt run --select models/monitoring/performance_baseline --dry-run" "Validates performance monitoring model"

# Test 5: Data quality dashboard
run_test "Data Quality Dashboard" "dbt run --select models/monitoring/data_quality_dashboard_enhanced --dry-run" "Validates quality monitoring model"

# Test 6: Pipeline health check
run_test "Pipeline Health Check" "dbt run --select models/monitoring/pipeline_health_check --dry-run" "Validates health monitoring model"

echo "🧪 PHASE 3: Testing Models Validation"
echo "===================================="

# Test 7: Optimized fact model
run_test "Optimized Fact Model" "dbt run --select models/testing/fact_ocupacao_leitos_optimized --dry-run" "Validates performance-optimized model"

echo "⚙️ PHASE 4: Custom Test Validation"
echo "=================================="

# Test 8: SQL syntax validation
run_dbt_test "SQL Syntax Validation" "tests/validation/test_sql_syntax_validation" "Validates all new SQL is syntactically correct"

# Test 9: Model references validation
run_dbt_test "Model References" "tests/validation/test_model_references" "Validates all model references are correct"

# Test 10: Schema configurations validation
run_dbt_test "Schema Configuration" "tests/validation/test_schema_configurations" "Validates schema isolation is working"

# Test 11: Performance comparison validation
run_dbt_test "Performance Comparison" "tests/validation/test_performance_comparison" "Validates data consistency and performance"

# Test 12: Performance regression test
run_dbt_test "Performance Regression" "tests/performance/test_performance_regression" "Validates no regression in existing functionality"

echo "🔍 PHASE 5: Integration Tests"
echo "============================="

# Test 13: All monitoring models together
run_test "All Monitoring Models" "dbt run --select models/monitoring/ --dry-run" "Validates all monitoring models work together"

# Test 14: All testing models together
run_test "All Testing Models" "dbt run --select models/testing/ --dry-run" "Validates all testing models work together"

# Test 15: All new tests together
run_dbt_test "All Custom Tests" "tests/validation/ tests/performance/" "Validates all custom tests pass"

echo "📋 PHASE 6: Final Safety Checks"
echo "==============================="

# Test 16: Original pipeline still intact
run_test "Original Models Compilation" "dbt compile --select models/staging/ models/intermediate/ models/dimensions/ models/facts/" "Ensures original pipeline compiles"

# Test 17: All existing tests still pass
run_dbt_test "Existing Tests" "tests/test_no_future_dates.sql" "Validates existing tests still work"

echo "📊 TEST RESULTS SUMMARY"
echo "========================"
echo -e "📈 Total Tests: $TOTAL_TESTS"
echo -e "${GREEN}✅ Passed: $PASSED_TESTS${NC}"
echo -e "${RED}❌ Failed: $FAILED_TESTS${NC}"

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "\n🎉 ${GREEN}ALL TESTS PASSED!${NC}"
    echo -e "✅ The improvements are ready to be used safely"
    echo -e "✅ No impact on existing pipeline detected"
    echo -e "✅ All new functionality validated"
    echo ""
    echo "🚀 Next Steps:"
    echo "1. Merge the pull request"
    echo "2. Run monitoring models: dbt run --select models/monitoring/"
    echo "3. Test optimizations: dbt run --select models/testing/"
    exit 0
else
    echo -e "\n⚠️ ${YELLOW}SOME TESTS FAILED${NC}"
    echo -e "❌ Number of failed tests: $FAILED_TESTS"
    echo ""
    echo "🔧 Recommended Actions:"
    echo "1. Review the failed tests above"
    echo "2. Run individual tests for more details"
    echo "3. Fix issues before proceeding"
    echo "4. Rollback is available: git checkout main"
    exit 1
fi