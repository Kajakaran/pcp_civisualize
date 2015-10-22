SELECT COUNT(contribute.id) as count
, DATE(contribute.receive_date) as receive_date
, donor.display_name as donor_name
, donor.id as donor_id
, pcp.id as pcp_id
, CASE WHEN pcp_block.entity_table = 'civicrm_event' THEN event.title 
       WHEN pcp_block.entity_table = 'civicrm_contribution_page' THEN contribution_page.title 
  END as page_type
, SUM(contribute.total_amount) as total
, pcp.title as instrument
, contribute.total_amount as amount
FROM civicrm_pcp pcp 
LEFT JOIN civicrm_contribution_soft soft_contribute ON (pcp.id = soft_contribute.pcp_id) 
LEFT JOIN civicrm_contribution contribute ON (contribute.id = soft_contribute.contribution_id)
LEFT JOIN civicrm_contact donor ON (donor.id = contribute.contact_id)
LEFT JOIN civicrm_pcp_block pcp_block ON (pcp_block.id = pcp.pcp_block_id)
LEFT JOIN civicrm_event event ON (event.id = pcp_block.entity_id AND pcp_block.entity_table = 'civicrm_event')   
LEFT JOIN civicrm_contribution_page contribution_page ON (contribution_page.id = pcp_block.entity_id AND pcp_block.entity_table = 'civicrm_contribution_page')
WHERE contribute.receive_date is not null AND soft_contribute.pcp_id IS NOT NULL
AND contribute.receive_date <> '0000-00-00' 
AND contribute.contribution_status_id = 1
group by DATE(contribute.receive_date)
,page_type , instrument, contribute.id
order by contribute.total_amount DESC;
