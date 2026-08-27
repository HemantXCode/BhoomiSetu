const express = require('express');
const router = express.Router();
const geoController = require('../controllers/geoController');

router.get('/states', geoController.getStates);
router.get('/districts', geoController.getDistricts);
router.get('/agencies', geoController.getAgencies);

module.exports = router;
