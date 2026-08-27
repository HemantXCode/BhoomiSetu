const { initDb } = require('../src/config/db');
const authService = require('../src/services/authService');
const projectService = require('../src/services/projectService');
const dashboardService = require('../src/services/dashboardService');

async function runAllTests() {
  console.log('🧪 Starting BhoomiSetu Backend Test Suite...\n');
  let passed = 0;
  let failed = 0;

  function assert(condition, testName) {
    if (condition) {
      console.log(`  ✅ PASS: ${testName}`);
      passed++;
    } else {
      console.error(`  ❌ FAIL: ${testName}`);
      failed++;
    }
  }

  try {
    // 1. Initialize DB
    await initDb();
    console.log('\n--- 1. Authentication Tests ---');

    // 1.1 Valid Central login
    const centralLogin = await authService.loginUser('central.demo@example.com', 'Demo@12345');
    assert(centralLogin && centralLogin.token && centralLogin.user.role === 'CENTRAL_MINISTRY', 'Central login succeeds with valid token & role');

    // 1.2 Valid State login
    const stateLogin = await authService.loginUser('state.demo@example.com', 'Demo@12345');
    assert(stateLogin && stateLogin.user.role === 'STATE_GOVERNMENT' && stateLogin.user.state_id === 1, 'State login succeeds with state_id = 1 (Maharashtra)');

    // 1.3 Valid District login
    const districtLogin = await authService.loginUser('district.demo@example.com', 'Demo@12345');
    assert(districtLogin && districtLogin.user.role === 'DISTRICT_AUTHORITY' && districtLogin.user.district_id === 1, 'District login succeeds with district_id = 1 (Pune)');

    // 1.4 Valid Agency login
    const agencyLogin = await authService.loginUser('agency.demo@example.com', 'Demo@12345');
    assert(agencyLogin && agencyLogin.user.role === 'PROJECT_AGENCY' && agencyLogin.user.agency_id === 1, 'Agency login succeeds with agency_id = 1 (NHAI)');

    // 1.5 Valid Field Officer login
    const fieldLogin = await authService.loginUser('field.demo@example.com', 'Demo@12345');
    assert(fieldLogin && fieldLogin.user.role === 'FIELD_OFFICER', 'Field Officer login succeeds');

    // 1.6 Invalid Password Test
    try {
      await authService.loginUser('central.demo@example.com', 'WrongPassword123');
      assert(false, 'Should reject invalid password');
    } catch (err) {
      assert(err.statusCode === 401, 'Rejects invalid password with 401 Unauthorized');
    }

    // 1.7 Non-existent user Test
    try {
      await authService.loginUser('nonexistent@example.com', 'Demo@12345');
      assert(false, 'Should reject unknown user');
    } catch (err) {
      assert(err.statusCode === 401, 'Rejects unknown user with 401 Unauthorized');
    }

    console.log('\n--- 2. Data Scope Authorization Tests ---');

    // 2.1 Central Ministry gets all projects
    const centralProjects = await projectService.getScopedProjects(centralLogin.user);
    assert(centralProjects.length >= 10, `Central Ministry retrieves all national projects (count: ${centralProjects.length})`);

    // 2.2 State Government gets only Maharashtra projects (state_id = 1)
    const stateProjects = await projectService.getScopedProjects(stateLogin.user);
    const nonStateProjects = stateProjects.filter(p => p.state_id !== 1);
    assert(stateProjects.length > 0 && nonStateProjects.length === 0, `State Government retrieves only Maharashtra projects (count: ${stateProjects.length})`);

    // 2.3 District Authority gets only Pune projects (district_id = 1)
    const districtProjects = await projectService.getScopedProjects(districtLogin.user);
    const nonDistrictProjects = districtProjects.filter(p => p.district_id !== 1);
    assert(districtProjects.length > 0 && nonDistrictProjects.length === 0, `District Authority retrieves only Pune projects (count: ${districtProjects.length})`);

    // 2.4 Project Agency gets only NHAI projects (agency_id = 1)
    const agencyProjects = await projectService.getScopedProjects(agencyLogin.user);
    const nonAgencyProjects = agencyProjects.filter(p => p.agency_id !== 1);
    assert(agencyProjects.length > 0 && nonAgencyProjects.length === 0, `Project Agency retrieves only NHAI projects (count: ${agencyProjects.length})`);

    // 2.5 Cross-scope project access prevention (State user trying to get Gujarat project #5)
    try {
      await projectService.getProjectById(5, stateLogin.user); // Project 5 is in Gujarat (state_id = 2)
      assert(false, 'State user should NOT access Gujarat project');
    } catch (err) {
      assert(err.statusCode === 403, 'Rejects cross-state project access with 403 Forbidden');
    }

    // 2.6 District user trying to access Nagpur project #3 (district_id = 2)
    try {
      await projectService.getProjectById(3, districtLogin.user);
      assert(false, 'District user should NOT access non-assigned district project');
    } catch (err) {
      assert(err.statusCode === 403, 'Rejects cross-district project access with 403 Forbidden');
    }

    console.log('\n--- 3. Dashboard Dynamic Statistics Tests ---');

    // 3.1 Central Stats
    const centralStats = await dashboardService.getDashboardStats(centralLogin.user);
    assert(centralStats.summary && parseFloat(centralStats.summary.total_land_proposed) > 0, 'Central Dashboard returns computed national land stats');
    assert(centralStats.state_wise_progress && centralStats.state_wise_progress.length > 0, 'Central Dashboard returns state-wise breakdown');

    // 3.2 State Stats
    const stateStats = await dashboardService.getDashboardStats(stateLogin.user);
    assert(stateStats.summary && stateStats.state_name === 'Maharashtra', 'State Dashboard returns Maharashtra scoped stats');
    assert(stateStats.district_wise_progress && stateStats.district_wise_progress.length > 0, 'State Dashboard returns district-wise breakdown');

    // 3.3 District Stats
    const districtStats = await dashboardService.getDashboardStats(districtLogin.user);
    assert(districtStats.summary && districtStats.field_verification_queue.length > 0, 'District Dashboard returns verification queue');

    // 3.4 Agency Stats
    const agencyStats = await dashboardService.getDashboardStats(agencyLogin.user);
    assert(agencyStats.summary && agencyStats.milestones.length > 0, 'Agency Dashboard returns milestone tracker');

    // 3.5 Field Officer Stats
    const fieldStats = await dashboardService.getDashboardStats(fieldLogin.user);
    assert(fieldStats.summary && fieldStats.field_tasks.length > 0, 'Field Officer Dashboard returns field tasks');

    console.log('\n--- 4. Project Creation API Tests ---');
    const newProject = await projectService.createProject(agencyLogin.user, {
      project_name: 'Solapur-Pune Green Feeder Corridor',
      description: 'Highway bypass acquisition corridor',
      state_id: 1,
      district_id: 1,
      proposed_area: 125.50,
      status: 'PROPOSED'
    });
    assert(newProject && newProject.id && newProject.agency_id === 1, 'Project Agency successfully creates new project proposal');

  } catch (testError) {
    console.error('Fatal test error:', testError);
    failed++;
  }

  console.log('\n========================================');
  console.log(`🏁 TEST RESULTS: ${passed} PASSED, ${failed} FAILED`);
  console.log('========================================\n');

  if (failed > 0) {
    process.exit(1);
  }
}

runAllTests();
