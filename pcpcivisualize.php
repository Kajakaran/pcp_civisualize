<?php
//todo: move that to core
function _civicrm_api3_basic_getsql ($params,$sql) {
  $returnSQL        = CRM_Utils_Array::value('sql', $params, CRM_Utils_Array::value('options_sql', $params));
  if ($returnSQL) {
    return array("is_error"=>1,"sql"=>$sql);
  }
  $dao = CRM_Core_DAO::executeQuery($sql);
  $values = array();
  while ($dao->fetch()) {
    $values[] = $dao->toArray();
  }
  return civicrm_api3_create_success($values, $params, NULL, NULL, $dao);
}


require_once 'pcpcivisualize.civix.php';

function civicrm_civicrm_dashboard( $contactID, &$contentPlacement ) {
   CRM_Core_Resources::singleton()
    ->addScriptFile('uk.co.vedaconsulting.pcp_civisualize', 'js/d3.v3.js', 110, 'html-header', FALSE)
    ->addScriptFile('uk.co.vedaconsulting.pcp_civisualize', 'js/dc/dc.js', 110, 'html-header', FALSE)
    ->addScriptFile('uk.co.vedaconsulting.pcp_civisualize', 'js/dc/crossfilter.js', 110, 'html-header', FALSE)
    ->addStyleFile('uk.co.vedaconsulting.pcp_civisualize', 'js/dc/dc.css')
    ->addStyleFile('uk.co.vedaconsulting.pcp_civisualize', 'css/style.css');
}


/**
 * Implementation of hook_civicrm_config
 */
function pcpcivisualize_civicrm_config(&$config) {
  _pcpcivisualize_civix_civicrm_config($config);
}

/**
 * Implementation of hook_civicrm_xmlMenu
 *
 * @param $files array(string)
 */
function pcpcivisualize_civicrm_xmlMenu(&$files) {
  _pcpcivisualize_civix_civicrm_xmlMenu($files);
}

/**
 * Implementation of hook_civicrm_install
 */
function pcpcivisualize_civicrm_install() {
  return _pcpcivisualize_civix_civicrm_install();
}

/**
 * Implementation of hook_civicrm_uninstall
 */
function pcpcivisualize_civicrm_uninstall() {
  return _pcpcivisualize_civix_civicrm_uninstall();
}

/**
 * Implementation of hook_civicrm_enable
 */
function pcpcivisualize_civicrm_enable() {
  return _pcpcivisualize_civix_civicrm_enable();
}

/**
 * Implementation of hook_civicrm_disable
 */
function pcpcivisualize_civicrm_disable() {
  return _pcpcivisualize_civix_civicrm_disable();
}

/**
 * Implementation of hook_civicrm_upgrade
 *
 * @param $op string, the type of operation being performed; 'check' or 'enqueue'
 * @param $queue CRM_Queue_Queue, (for 'enqueue') the modifiable list of pending up upgrade tasks
 *
 * @return mixed  based on op. for 'check', returns array(boolean) (TRUE if upgrades are pending)
 *                for 'enqueue', returns void
 */
function pcpcivisualize_civicrm_upgrade($op, CRM_Queue_Queue $queue = NULL) {
  return _pcpcivisualize_civix_civicrm_upgrade($op, $queue);
}

/**
 * Implementation of hook_civicrm_managed
 *
 * Generate a list of entities to create/deactivate/delete when this module
 * is installed, disabled, uninstalled.
 */
function pcpcivisualize_civicrm_managed(&$entities) {
  return _pcpcivisualize_civix_civicrm_managed($entities);
}


/**
*
*Adds a navigation menu item under report.
*
*/
function pcpcivisualize_civicrm_navigationMenu( &$params ) {
  // get the id of Administer Menu
  $reportMenuId = CRM_Core_DAO::getFieldValue('CRM_Core_BAO_Navigation', 'Reports', 'id', 'name');

  // skip adding menu if there is no administer menu
  if ($reportMenuId) {
    // get the maximum key under adminster menu
    $maxKey = max( array_keys($params[$reportMenuId]['child']));
    $params[$reportMenuId]['child'][$maxKey+1] =  array (
      'attributes' => array (
        'label'      => 'PCPCivisualize',
        'name'       => 'PCPCivisualize',
        'url'        => 'civicrm/pcpdataviz',
        'permission' => 'access CiviReport',
        'operator'   => NULL,
        'separator'  => TRUE,
        'parentID'   => $reportMenuId,
        'navID'      => $maxKey+1,
        'active'     => 1
      )
    );
  }
}
