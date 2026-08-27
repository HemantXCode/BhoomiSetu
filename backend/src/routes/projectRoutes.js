const express = require('express');
const router = express.Router();
const projectController = require('../controllers/projectController');
const { authenticateToken } = require('../middleware/authMiddleware');
const { authorizeRoles } = require('../middleware/rbacMiddleware');

// All project routes require authentication
router.use(authenticateToken);

// GET /api/projects - Scope-filtered project listing
router.get('/', projectController.listProjects);

// GET /api/projects/:id - Single project details with data scope check
router.get('/:id', projectController.getProject);

// POST /api/projects - Create proposal (Project Agency or Central Ministry)
router.post(
  '/',
  authorizeRoles('PROJECT_AGENCY', 'CENTRAL_MINISTRY'),
  projectController.createProject
);

module.exports = router;
