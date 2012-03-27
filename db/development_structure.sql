CREATE TABLE IF NOT EXISTS `active_status` (
  `active_status_id` tinyint(3) NOT NULL auto_increment,
  `display_order` int(5) default NULL,
  `active_status` varchar(15) collate utf8_bin NOT NULL,
  PRIMARY KEY  (`active_status_id`),
  UNIQUE KEY `active_status` (`active_status`),
  KEY `active_status_id_idx` (`active_status_id`)
) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `additional_files` (
  `id` int(11) NOT NULL auto_increment,
  `file_content_type` varchar(255) character set utf8 default NULL,
  `file` varchar(255) character set utf8 default NULL,
  `version` int(11) NOT NULL default '0',
  `article_submission_id` int(11) NOT NULL,
  `file_size` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=108 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `answer_choice_types` (
  `answer_choice_type_id` tinyint(1) NOT NULL auto_increment,
  `answer_type_name` varchar(20) character set latin1 NOT NULL,
  PRIMARY KEY  (`answer_choice_type_id`),
  UNIQUE KEY `answer_type_name` (`answer_type_name`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `answer_choices` (
  `answer_choices_id` int(11) NOT NULL auto_increment,
  `hw_answer_id` char(10) character set latin1 NOT NULL,
  `course_id` int(11) NOT NULL,
  `quiz_id` int(11) NOT NULL,
  `question_id` int(11) NOT NULL,
  `hw_course_id` varchar(35) character set latin1 NOT NULL,
  `hw_quizoreval_id` varchar(35) character set latin1 NOT NULL,
  `answer_choice_type_id` tinyint(1) NOT NULL,
  `sort_num` tinyint(3) default NULL,
  `hw_question_id` char(10) character set latin1 NOT NULL,
  `text` text character set latin1 NOT NULL,
  `is_correct` varchar(5) character set latin1 NOT NULL,
  PRIMARY KEY  (`answer_choices_id`),
  KEY `answer_choices_question_id_idx` (`question_id`),
  KEY `answer_choices_answer_choice_type_id_idx` (`answer_choice_type_id`),
  KEY `answer_choices_hw_question_id_idx` (`hw_question_id`)
) ENGINE=MyISAM AUTO_INCREMENT=20514 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `article_sections` (
  `article_section_id` int(11) NOT NULL auto_increment,
  `create_date` date default NULL,
  `create_by_id` int(11) default NULL,
  `create_by_ip` varchar(39) default '',
  `mod_date` date default NULL,
  `mod_by_id` int(11) default NULL,
  `mod_by_ip` varchar(39) default '',
  `active_status_id` tinyint(3) NOT NULL default '2',
  `parent_id` int(11) NOT NULL default '0',
  `display_order` int(5) default NULL,
  `article_section_name` varchar(125) NOT NULL default '',
  `ser_cur_comment` varchar(3500) default NULL,
  `key_change_history` varchar(3500) default '',
  `public` int(1) NOT NULL default '0',
  PRIMARY KEY  (`article_section_id`),
  KEY `article_sections_active_status_id_idx` (`active_status_id`),
  KEY `article_sections_article_section_id_idx` (`article_section_id`)
) ENGINE=MyISAM AUTO_INCREMENT=82 DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `article_sections_odd` (
  `article_section_id` int(11) NOT NULL auto_increment,
  `create_date` date default NULL,
  `create_by_id` int(11) default NULL,
  `create_by_ip` varchar(39) default '',
  `mod_date` date default NULL,
  `mod_by_id` int(11) default NULL,
  `mod_by_ip` varchar(39) default '',
  `active_status_id` tinyint(3) NOT NULL default '2',
  `parent_id` int(11) NOT NULL default '0',
  `display_order` int(5) default NULL,
  `article_section_name` varchar(125) NOT NULL default '',
  `ser_cur_comment` varchar(3500) default NULL,
  `key_change_history` varchar(3500) default '',
  `public` int(1) NOT NULL default '0',
  PRIMARY KEY  (`article_section_id`),
  KEY `article_sections_active_status_id_idx` (`active_status_id`),
  KEY `article_sections_article_section_id_idx` (`article_section_id`)
) ENGINE=MyISAM AUTO_INCREMENT=82 DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `article_status` (
  `article_status_id` int(11) NOT NULL auto_increment,
  `display_order` int(5) NOT NULL,
  `ser_display_order` int(5) default NULL,
  `status` varchar(35) character set latin1 NOT NULL,
  PRIMARY KEY  (`article_status_id`)
) ENGINE=MyISAM AUTO_INCREMENT=16 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `article_submissions` (
  `id` int(11) NOT NULL auto_increment,
  `create_date` datetime default NULL,
  `create_by_id` int(11) default NULL,
  `create_by_ip` varchar(39) character set latin1 default NULL,
  `mod_date` datetime default NULL,
  `mod_by_id` int(11) default NULL,
  `mod_by_ip` varchar(39) character set latin1 default NULL,
  `title` varchar(255) character set latin1 NOT NULL,
  `article_section_id` int(11) NOT NULL,
  `num_pages` int(3) NOT NULL default '0',
  `num_refs` int(3) NOT NULL default '0',
  `num_tables` int(3) NOT NULL default '0',
  `num_figures` int(3) NOT NULL,
  `num_suppl_mtrls` int(3) NOT NULL,
  `incl_gap` tinyint(1) default NULL,
  `incl_abstract` tinyint(1) default NULL,
  `incl_keywords` tinyint(1) default NULL,
  `incl_learn_obj` tinyint(1) default NULL,
  `incl_best_practices` tinyint(1) default NULL,
  `incl_two_strategies` tinyint(1) default NULL,
  `submission_type_id` int(11) default NULL,
  `invited_by` varchar(255) character set latin1 default NULL,
  `fees_cc_type` varchar(255) character set latin1 default NULL,
  `fees_pubfee_status` varchar(63) character set latin1 default NULL,
  `fees_nopubfee_reason` varchar(255) character set latin1 default NULL,
  `indemnify` tinyint(1) default NULL,
  `cant_pay_reason` varchar(512) character set latin1 default NULL,
  `committed` datetime default NULL,
  `article_id` int(11) default NULL,
  `approved` tinyint(1) default NULL,
  `payment_type` varchar(255) character set latin1 default NULL,
  `invited` tinyint(1) default NULL,
  `cover_letter_id` int(11) default NULL,
  `imported_to_pf` date default NULL,
  `reviewer1` varchar(255) collate utf8_bin default NULL,
  `reviewer2` varchar(255) collate utf8_bin default NULL,
  `reviewer3` varchar(255) collate utf8_bin default NULL,
  `review_pdf_id` int(11) default NULL,
  `charged_pub_fee` date default NULL,
  `charged_initial_fee` date default NULL,
  `pub_charge_settled` date default NULL,
  `initial_charge_settled` date default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=121 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `article_to_articlesection` (
  `article_to_sections_id` int(11) NOT NULL auto_increment,
  `section_id` int(11) NOT NULL,
  `article_id` int(11) NOT NULL,
  `canonical` varchar(5) character set latin1 default NULL,
  PRIMARY KEY  (`article_to_sections_id`),
  KEY `article_to_articlesection_section_id_idx` (`section_id`),
  KEY `article_to_articlesection_article_id_idx` (`article_id`)
) ENGINE=MyISAM AUTO_INCREMENT=2387 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `article_to_reminder` (
  `article_to_reminder_id` int(11) NOT NULL auto_increment,
  `article_id` int(11) NOT NULL,
  `sent_date` datetime NOT NULL,
  `reminder_template_id` int(11) NOT NULL,
  `actual_desc` text character set latin1 NOT NULL,
  PRIMARY KEY  (`article_to_reminder_id`),
  KEY `article_to_reminder_article_id_idx` (`article_id`),
  KEY `article_to_reminder_reminder_template_id_idx` (`reminder_template_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `articles` (
  `article_id` int(11) NOT NULL auto_increment,
  `create_date` datetime default NULL,
  `create_by_id` int(11) default NULL,
  `create_by_ip` varchar(39) character set latin1 default NULL,
  `mod_date` datetime default NULL,
  `mod_by_id` int(11) default NULL,
  `mod_by_ip` varchar(39) character set latin1 default NULL,
  `article_status_id` int(11) NOT NULL,
  `title` varchar(750) collate utf8_bin NOT NULL,
  `abstract` text character set latin1,
  `date_suggested` date default NULL,
  `alternates_needed_flag` tinyint(1) default NULL,
  `date_invited` date default NULL,
  `submission_type` varchar(10) character set latin1 default NULL,
  `date_pledged` date default NULL,
  `date_promised_1` date default NULL,
  `date_received` date default NULL,
  `manuscript_num` varchar(10) character set latin1 default NULL,
  `manuscript_suffix` varchar(3) character set latin1 default NULL,
  `date_submission_1` date default NULL,
  `submit_fee_paid_flag` tinyint(1) default NULL,
  `reviewers_selected_1` date default NULL,
  `comments_sent_to_mgeditor_1` date default NULL,
  `date_first_decision` date default NULL,
  `first_decision_type` varchar(25) character set latin1 default NULL,
  `date_promised_2` date default NULL,
  `date_submission_2` date default NULL,
  `reviewers_selected_2` date default NULL,
  `comments_sent_to_mgeditor_2` date default NULL,
  `date_second_decision` date default NULL,
  `second_decision_type` varchar(25) character set latin1 default NULL,
  `date_promised_3` date default NULL,
  `date_submission_3` date default NULL,
  `date_third_decision` date default NULL,
  `third_decision_type` varchar(25) character set latin1 default '',
  `date_promised_4` date default NULL,
  `date_submission_4` date default NULL,
  `date_final_decision` date default NULL,
  `final_decision_type` varchar(25) character set latin1 default '',
  `date_published` date default NULL,
  `pub_with_cme_flag` tinyint(1) default NULL,
  `doi` varchar(40) character set latin1 default NULL,
  `hw_article_id` varchar(40) character set latin1 default NULL,
  `hw_sort_num` varchar(3) character set latin1 default NULL,
  `volume` int(3) default NULL,
  `issue` varchar(35) character set latin1 default NULL,
  `start_page` int(4) default NULL,
  `end_page` int(4) default NULL,
  `date_retracted` date default NULL,
  `date_withdrawn` date default NULL,
  `withdrawal_reason` varchar(25) character set latin1 default '',
  `conflict_of_interest` text character set latin1,
  `pcoi_flag` tinyint(1) default NULL,
  `peer_review_note` text character set latin1,
  `ser_cur_comment` text collate utf8_bin,
  `ser_comment_history` text character set utf8 collate utf8_unicode_ci,
  `article_comments` text character set latin1,
  `key_changes_history` text character set latin1,
  PRIMARY KEY  (`article_id`),
  KEY `articles_article_status_id_idx` (`article_status_id`),
  KEY `articles_title_idx` (`title`(333)),
  KEY `articles_submission_type_id_idx` (`submission_type`),
  KEY `articles_first_decision_type_idx` (`first_decision_type`),
  KEY `articles_interim_decision_type_idx` (`second_decision_type`),
  KEY `articles_final_decision_type_idx` (`final_decision_type`),
  KEY `articles_pub_with_cme_flag_idx` (`pub_with_cme_flag`),
  KEY `articles_withdrawal_reason_idx` (`withdrawal_reason`),
  KEY `articles_doi_idx` (`doi`),
  KEY `articles_hw_article_id_idx` (`hw_article_id`)
) ENGINE=MyISAM AUTO_INCREMENT=2389 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `articles_odd` (
  `article_id` int(11) NOT NULL auto_increment,
  `create_date` datetime default NULL,
  `create_by_id` int(11) default NULL,
  `create_by_ip` varchar(39) character set latin1 default NULL,
  `mod_date` datetime default NULL,
  `mod_by_id` int(11) default NULL,
  `mod_by_ip` varchar(39) character set latin1 default NULL,
  `article_status_id` int(11) NOT NULL,
  `title` varchar(750) collate utf8_bin NOT NULL,
  `abstract` text character set latin1,
  `date_suggested` date default NULL,
  `alternates_needed_flag` tinyint(1) default NULL,
  `date_invited` date default NULL,
  `submission_type` varchar(10) character set latin1 default NULL,
  `date_pledged` date default NULL,
  `date_promised_1` date default NULL,
  `date_received` date default NULL,
  `manuscript_num` varchar(10) character set latin1 default NULL,
  `manuscript_suffix` varchar(3) character set latin1 default NULL,
  `date_submission_1` date default NULL,
  `submit_fee_paid_flag` tinyint(1) default NULL,
  `reviewers_selected_1` date default NULL,
  `comments_sent_to_mgeditor_1` date default NULL,
  `date_first_decision` date default NULL,
  `first_decision_type` varchar(25) character set latin1 default NULL,
  `date_promised_2` date default NULL,
  `date_submission_2` date default NULL,
  `reviewers_selected_2` date default NULL,
  `comments_sent_to_mgeditor_2` date default NULL,
  `date_second_decision` date default NULL,
  `second_decision_type` varchar(25) character set latin1 default NULL,
  `date_promised_3` date default NULL,
  `date_submission_3` date default NULL,
  `date_third_decision` date default NULL,
  `third_decision_type` varchar(25) character set latin1 default '',
  `date_promised_4` date default NULL,
  `date_submission_4` date default NULL,
  `date_final_decision` date default NULL,
  `final_decision_type` varchar(25) character set latin1 default '',
  `date_published` date default NULL,
  `pub_with_cme_flag` tinyint(1) default NULL,
  `doi` varchar(40) character set latin1 default NULL,
  `hw_article_id` varchar(40) character set latin1 default NULL,
  `hw_sort_num` varchar(3) character set latin1 default NULL,
  `volume` int(3) default NULL,
  `issue` varchar(35) character set latin1 default NULL,
  `start_page` int(4) default NULL,
  `end_page` int(4) default NULL,
  `date_retracted` date default NULL,
  `date_withdrawn` date default NULL,
  `withdrawal_reason` varchar(25) character set latin1 default '',
  `conflict_of_interest` varchar(3500) character set latin1 default NULL,
  `pcoi_flag` tinyint(1) default NULL,
  `peer_review_note` varchar(3500) character set latin1 default NULL,
  `ser_cur_comment` varchar(3500) character set latin1 default NULL,
  `ser_comment_history` varchar(3500) character set latin1 default NULL,
  `article_comments` varchar(3500) character set latin1 default NULL,
  `key_changes_history` varchar(3500) character set latin1 default NULL,
  PRIMARY KEY  (`article_id`),
  KEY `articles_article_status_id_idx` (`article_status_id`),
  KEY `articles_title_idx` (`title`(333)),
  KEY `articles_submission_type_id_idx` (`submission_type`),
  KEY `articles_first_decision_type_idx` (`first_decision_type`),
  KEY `articles_interim_decision_type_idx` (`second_decision_type`),
  KEY `articles_final_decision_type_idx` (`final_decision_type`),
  KEY `articles_pub_with_cme_flag_idx` (`pub_with_cme_flag`),
  KEY `articles_withdrawal_reason_idx` (`withdrawal_reason`),
  KEY `articles_doi_idx` (`doi`),
  KEY `articles_hw_article_id_idx` (`hw_article_id`)
) ENGINE=MyISAM AUTO_INCREMENT=2284 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `articlesection_sercommenthistory` (
  `articlesection_sercommenthistory_id` int(11) NOT NULL auto_increment,
  `article_section_id` int(11) NOT NULL,
  `ser_issue_id` int(11) default NULL,
  `ser_comment` varchar(3500) character set latin1 default NULL,
  PRIMARY KEY  (`articlesection_sercommenthistory_id`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `audit_logs` (
  `audit_item_id` int(11) NOT NULL auto_increment,
  `create_date` datetime NOT NULL,
  `create_by_id` int(11) NOT NULL,
  `create_by_ip` varchar(39) character set latin1 NOT NULL,
  `function` varchar(35) character set latin1 NOT NULL,
  `action` varchar(255) character set latin1 NOT NULL,
  `primary_key` int(11) default NULL,
  `pre_value` varchar(255) character set latin1 NOT NULL,
  `post_value` varchar(255) character set latin1 default '',
  PRIMARY KEY  (`audit_item_id`)
) ENGINE=MyISAM AUTO_INCREMENT=152 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `author_contributions` (
  `author_contrib_id` tinyint(3) NOT NULL auto_increment,
  `display_order` int(5) default NULL,
  `contribution_title` varchar(60) character set latin1 NOT NULL,
  PRIMARY KEY  (`author_contrib_id`),
  UNIQUE KEY `contribution_title` (`contribution_title`),
  KEY `author_contributions_author_contrib_id_idx` (`author_contrib_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `author_credentials_disclosures` (
  `author_credentials_disclosures_id` int(11) NOT NULL auto_increment,
  `course_id` int(11) NOT NULL,
  `credentials` text character set latin1 NOT NULL,
  `disclosures` text character set latin1 NOT NULL,
  `author_id` int(11) NOT NULL,
  PRIMARY KEY  (`author_credentials_disclosures_id`),
  KEY `author_credentials_disclosures_course_id_idx` (`course_id`),
  KEY `author_credentials_disclosures_author_id_idx` (`author_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `author_to_contribs` (
  `author_to_contribs_id` tinyint(3) NOT NULL auto_increment,
  `author_id` int(11) NOT NULL,
  `author_contrib_id` tinyint(3) NOT NULL,
  `other_contribution_title` varchar(60) character set latin1 default NULL,
  PRIMARY KEY  (`author_to_contribs_id`),
  KEY `author_to_contribs_id_idx` (`author_to_contribs_id`),
  KEY `author_to_contribs_author_id_idx` (`author_id`),
  KEY `author_to_contribs_author_contrib_id_idx` (`author_contrib_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `authors` (
  `author_id` int(11) NOT NULL auto_increment,
  `create_date` datetime default NULL,
  `create_by_id` int(11) default NULL,
  `create_by_ip` varchar(39) character set latin1 default NULL,
  `mod_date` datetime default NULL,
  `mod_by_id` varchar(39) character set latin1 default NULL,
  `mod_by_ip` varchar(39) character set latin1 default NULL,
  `unique_email_link_id` varchar(15) character set latin1 NOT NULL,
  `manuscript_id` int(11) NOT NULL,
  `role_id` tinyint(3) NOT NULL,
  `pre_title` varchar(10) character set latin1 default NULL,
  `first_name` varchar(35) character set latin1 NOT NULL,
  `middle_name` varchar(35) character set latin1 default NULL,
  `last_name` varchar(35) character set latin1 NOT NULL,
  `degree1` varchar(8) character set latin1 default NULL,
  `degree2` varchar(8) character set latin1 default NULL,
  `degree3` varchar(8) character set latin1 default NULL,
  `employer` varchar(80) character set latin1 NOT NULL,
  `position_title` varchar(50) character set latin1 NOT NULL,
  `address_1` varchar(64) character set latin1 NOT NULL,
  `address_2` varchar(64) character set latin1 default NULL,
  `city` varchar(32) character set latin1 NOT NULL,
  `state_province_id` int(3) NOT NULL,
  `zip_postalcode` varchar(15) character set latin1 NOT NULL,
  `country_id` int(3) NOT NULL,
  `phone` varchar(10) character set latin1 NOT NULL,
  `phone_fax` varchar(10) character set latin1 NOT NULL,
  `url` varchar(100) character set latin1 default NULL,
  `email` varchar(128) character set latin1 NOT NULL,
  PRIMARY KEY  (`author_id`),
  UNIQUE KEY `unique_email_link_id` (`unique_email_link_id`),
  KEY `authors_author_id_idx` (`author_id`),
  KEY `authors_unique_email_link_id_idx` (`unique_email_link_id`),
  KEY `authors_manuscript_id_idx` (`manuscript_id`),
  KEY `authors_role_id_idx` (`role_id`),
  KEY `authors_state_province_id_idx` (`state_province_id`),
  KEY `authors_country_id_idx` (`country_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `boilerplate_text` (
  `boilerplate_text_id` int(11) NOT NULL auto_increment,
  `active_status_id` tinyint(3) NOT NULL,
  `bp_type` varchar(20) character set latin1 default NULL,
  `boilerplate_merge_code` varchar(15) character set latin1 default NULL,
  `title` varchar(65) character set latin1 default NULL,
  `description` text character set latin1 NOT NULL,
  PRIMARY KEY  (`boilerplate_text_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `cc_transactions` (
  `id` int(11) NOT NULL auto_increment,
  `charge_id` int(11) NOT NULL,
  `amount` float NOT NULL,
  `state` varchar(255) collate utf8_bin default NULL,
  `authorization` varchar(255) collate utf8_bin default NULL,
  `avs_result` varchar(255) collate utf8_bin default NULL,
  `cvv_result` varchar(255) collate utf8_bin default NULL,
  `message` varchar(1027) collate utf8_bin default NULL,
  `params` varchar(1027) collate utf8_bin default NULL,
  `response` varchar(1027) collate utf8_bin default NULL,
  `fraud_review` tinyint(1) NOT NULL default '0',
  `success` tinyint(1) NOT NULL default '0',
  `test` tinyint(1) NOT NULL default '0',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `charge_types` (
  `id` int(11) NOT NULL auto_increment,
  `code` varchar(255) collate utf8_bin NOT NULL,
  `description` varchar(255) collate utf8_bin NOT NULL,
  `amount` float NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `charges` (
  `id` int(11) NOT NULL auto_increment,
  `article_submission_id` int(11) NOT NULL,
  `charge_type_id` int(11) NOT NULL,
  `amount` float NOT NULL default '0',
  `date_due` date NOT NULL,
  `state` varchar(255) collate utf8_bin default NULL,
  `processed` datetime default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `cme_users` (
  `cme_user_id` int(11) NOT NULL auto_increment,
  `create_date` datetime default NULL,
  `create_by_id` int(11) default NULL,
  `create_by_ip` varchar(39) character set latin1 default NULL,
  `mod_date` datetime default NULL,
  `mod_by_id` int(11) default NULL,
  `mod_by_ip` varchar(39) character set latin1 default NULL,
  `member_no` varchar(15) character set latin1 NOT NULL,
  `subscr_type` varchar(12) character set latin1 default NULL,
  `first_name` varchar(50) character set latin1 NOT NULL,
  `last_name` varchar(50) character set latin1 NOT NULL,
  `inst_name` varchar(100) character set latin1 default NULL,
  `email` varchar(80) character set latin1 NOT NULL,
  `user_type` varchar(12) character set latin1 default NULL,
  `user_name` varchar(150) character set latin1 NOT NULL,
  `activation_date` datetime default NULL,
  `region` varchar(20) character set latin1 default NULL,
  `address_1` varchar(255) character set latin1 default NULL,
  `address2` varchar(25) character set latin1 default NULL,
  `phone` varchar(25) character set latin1 default NULL,
  `fax` varchar(25) character set latin1 default NULL,
  `country` varchar(45) character set latin1 default NULL,
  `city` varchar(25) character set latin1 default NULL,
  `state_province` varchar(30) character set latin1 default NULL,
  `zip_postal` varchar(15) character set latin1 default NULL,
  `title` varchar(5) character set latin1 default NULL,
  `affiliation` varchar(80) character set latin1 default NULL,
  `d101_professional_role` varchar(65) character set latin1 default NULL,
  `d102_professional_role_other` varchar(80) character set latin1 default NULL,
  `d103_primary_specialty` varchar(80) character set latin1 default NULL,
  `d104_primary_specialty_other` varchar(80) character set latin1 default NULL,
  `d105_gender` varchar(10) character set latin1 default NULL,
  `d106_med_school` varchar(100) character set latin1 default NULL,
  `d107_med_school_other` varchar(80) character set latin1 default NULL,
  `d108_year_of_graduation` varchar(6) character set latin1 default NULL,
  `d109_degree` varchar(50) character set latin1 default NULL,
  `d110_degree_other` varchar(80) character set latin1 default NULL,
  `d111_medical_education_number` varchar(80) character set latin1 default NULL,
  `d112_license_number` varchar(80) character set latin1 default NULL,
  `d113_state_issued` varchar(30) character set latin1 default NULL,
  PRIMARY KEY  (`cme_user_id`),
  UNIQUE KEY `member_no` (`member_no`),
  UNIQUE KEY `user_name` (`user_name`),
  KEY `cme_users_cme_user_id_idx` (`cme_user_id`),
  KEY `cme_users_member_no_idx` (`member_no`),
  KEY `cme_users_country_idx` (`country`),
  KEY `cme_users_d101_professional_role_idx` (`d101_professional_role`)
) ENGINE=MyISAM AUTO_INCREMENT=10812 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `cmeuser_to_course` (
  `cmeuser_to_course_id` int(11) NOT NULL auto_increment,
  `course_id` int(11) NOT NULL,
  `hw_membership_no` varchar(15) character set latin1 NOT NULL,
  `hw_course_id` varchar(35) character set latin1 NOT NULL,
  `how_taken` varchar(15) character set latin1 default NULL,
  `status` varchar(35) character set latin1 default NULL,
  `last_updated` datetime default NULL,
  `credit_cat` int(1) default NULL,
  `hours_credits_earned` int(2) default NULL,
  PRIMARY KEY  (`cmeuser_to_course_id`),
  KEY `cmeuser_to_course_course_id_idx` (`course_id`),
  KEY `cmeuser_to_course_hw_membership_no_idx` (`hw_membership_no`),
  KEY `cmeuser_to_course_hw_course_id_idx` (`hw_course_id`)
) ENGINE=MyISAM AUTO_INCREMENT=62236 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `coi` (
  `coi_id` int(11) NOT NULL auto_increment,
  `create_date` datetime default NULL,
  `create_by_id` int(11) default NULL,
  `create_by_ip` varchar(39) character set latin1 default NULL,
  `mod_date` datetime default NULL,
  `mod_by_id` int(11) default NULL,
  `mod_by_ip` varchar(39) character set latin1 default NULL,
  `stdalone_mnscrpt_title` varchar(750) character set latin1 NOT NULL,
  `author_id` int(11) default NULL,
  `stdalone_disclosure_name` varchar(35) character set latin1 default NULL,
  `coi_role_id` tinyint(3) NOT NULL,
  `reason_emplymnt` varchar(100) character set latin1 default NULL,
  `reason_ip` varchar(100) character set latin1 default NULL,
  `reason_cnsltnt` varchar(100) character set latin1 default NULL,
  `reason_honoraria` varchar(100) character set latin1 default NULL,
  `reason_research` varchar(100) character set latin1 default NULL,
  `reason_ownership` varchar(100) character set latin1 default NULL,
  `reason_expert` varchar(100) character set latin1 default NULL,
  `reason_other` varchar(100) character set latin1 default NULL,
  `no_conflicts` tinyint(1) NOT NULL,
  `unbiased` tinyint(1) NOT NULL,
  PRIMARY KEY  (`coi_id`),
  KEY `coi_id_idx` (`coi_id`),
  KEY `coi_author_id_idx` (`author_id`),
  KEY `coi_role_id_idx` (`coi_role_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `coi_forms` (
  `id` int(11) NOT NULL auto_increment,
  `create_date` datetime default NULL,
  `create_by_id` int(11) default NULL,
  `create_by_ip` varchar(39) character set latin1 default NULL,
  `mod_date` datetime default NULL,
  `mod_by_id` int(11) default NULL,
  `mod_by_ip` varchar(39) character set latin1 default NULL,
  `version` int(11) NOT NULL default '0',
  `author_id` int(11) default NULL,
  `employment` tinyint(1) default NULL,
  `ip_details` varchar(100) character set latin1 default NULL,
  `consultant_details` varchar(100) character set latin1 default NULL,
  `honoraria_details` varchar(100) character set latin1 default NULL,
  `research_details` varchar(100) character set latin1 default NULL,
  `ownership_details` varchar(100) character set latin1 default NULL,
  `expert_details` varchar(100) character set latin1 default NULL,
  `other_details` varchar(100) character set latin1 default NULL,
  `alternative_use_details` varchar(100) character set latin1 default NULL,
  `conflicts` tinyint(1) default NULL,
  `unbiased` tinyint(1) default NULL,
  `token` varchar(255) character set latin1 default NULL,
  `committed` datetime default NULL,
  `contribution_id` int(11) default NULL,
  `user_id` int(11) default NULL,
  `type` varchar(255) collate utf8_bin default NULL COMMENT 'Polymorphic model',
  `employment_details` varchar(100) character set latin1 default NULL,
  `alternative_use` tinyint(1) default NULL,
  `honoraria` tinyint(1) default NULL,
  `ip` tinyint(1) default NULL,
  `consultant` tinyint(1) default NULL,
  `research` tinyint(1) default NULL,
  `expert` tinyint(1) default NULL,
  `other` tinyint(1) default NULL,
  `ownership` tinyint(1) default NULL,
  `sig_completed_by` varchar(255) character set latin1 default NULL,
  `sig_entity` varchar(255) character set latin1 default NULL,
  `sig_entity_title` varchar(255) character set latin1 default NULL,
  `sig_time` datetime default NULL,
  `sig_assent` tinyint(1) default NULL,
  `roles_list` text collate utf8_bin,
  PRIMARY KEY  (`id`),
  KEY `coi_author_id_idx` (`author_id`),
  KEY `user_id` (`user_id`)
) ENGINE=MyISAM AUTO_INCREMENT=348 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `contribution_types` (
  `id` int(11) NOT NULL auto_increment,
  `display_order` int(11) NOT NULL default '0',
  `title` varchar(255) character set latin1 NOT NULL,
  `public` tinyint(1) NOT NULL default '0',
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=93 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `contribution_types_contributions` (
  `contribution_type_id` int(11) NOT NULL,
  `contribution_id` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `contributions` (
  `id` int(11) NOT NULL auto_increment,
  `role_id` int(11) NOT NULL,
  `article_submission_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `fy_served_flag` int(11) default NULL,
  `create_date` datetime default NULL,
  `create_by_id` int(11) default NULL,
  `create_by_ip` varchar(39) character set latin1 default NULL,
  `mod_date` datetime default NULL,
  `mod_by_id` int(11) default NULL,
  `mod_by_ip` varchar(39) character set latin1 default NULL,
  `emailed_coi_link` tinyint(1) default NULL,
  `coi_token` varchar(255) character set latin1 default NULL,
  `responsibilities_sig_completed_by` varchar(255) character set latin1 default NULL,
  `responsibilities_sig_entity` varchar(255) character set latin1 default NULL,
  `responsibilities_sig_entity_title` varchar(255) character set latin1 default NULL,
  `responsibilities_sig_time` datetime default NULL,
  `responsibilities_sig_assent` tinyint(1) default NULL,
  `copyright_sig_completed_by` varchar(255) character set latin1 default NULL,
  `copyright_sig_entity` varchar(255) character set latin1 default NULL,
  `copyright_sig_entity_title` varchar(255) character set latin1 default NULL,
  `copyright_sig_time` datetime default NULL,
  `copyright_sig_assent` tinyint(1) default NULL,
  `assisted` tinyint(1) default NULL,
  `assisted_details` varchar(255) character set latin1 default NULL,
  `agree_contents` tinyint(1) default NULL,
  `agree_contents_details` varchar(255) character set latin1 default NULL,
  `sole_submission` tinyint(1) default NULL,
  `sole_submission_details` varchar(255) character set latin1 default NULL,
  `received_payment` tinyint(1) default NULL,
  `received_payment_details` varchar(255) character set latin1 default NULL,
  `tobacco` tinyint(1) default NULL,
  `tobacco_details` varchar(255) character set latin1 default NULL,
  `published_elsewhere` tinyint(1) default NULL,
  `dna_research` tinyint(1) default NULL,
  `human_experiment` tinyint(1) default NULL,
  `clintrials` tinyint(1) default NULL,
  `consort_guidelines` tinyint(1) default NULL,
  `proprietary_guidelines` tinyint(1) default NULL,
  `proprietary_guidelines_details` varchar(255) character set latin1 default NULL,
  `agree_policies` tinyint(1) default NULL,
  `agree_policies_details` varchar(255) character set latin1 default NULL,
  `responsibilities_pdf_id` int(11) default NULL,
  `copyright_pdf_id` int(11) default NULL,
  `arynq1` tinyint(1) default NULL,
  `arynq1_details` varchar(100) collate utf8_bin default NULL,
  `ctynq1` tinyint(1) default NULL,
  `ctynq1_details` varchar(100) collate utf8_bin default NULL,
  `arynq2` tinyint(1) default NULL,
  `arynq2_details` varchar(100) collate utf8_bin default NULL,
  `ctynq2` tinyint(1) default NULL,
  `ctynq2_details` varchar(100) collate utf8_bin default NULL,
  `arynq3` tinyint(1) default NULL,
  `arynq3_details` varchar(100) collate utf8_bin default NULL,
  `ctynq3` tinyint(1) default NULL,
  `ctynq3_details` varchar(100) collate utf8_bin default NULL,
  `arynq4` tinyint(1) default NULL,
  `arynq4_details` varchar(100) collate utf8_bin default NULL,
  `ctynq4` tinyint(1) default NULL,
  `ctynq4_details` varchar(100) collate utf8_bin default NULL,
  `arynq5` tinyint(1) default NULL,
  `arynq5_details` varchar(100) collate utf8_bin default NULL,
  `ctynq5` tinyint(1) default NULL,
  `ctynq5_details` varchar(100) collate utf8_bin default NULL,
  `arynq6` tinyint(1) default NULL,
  `arynq6_details` varchar(100) collate utf8_bin default NULL,
  `ctynq6` tinyint(1) default NULL,
  `ctynq6_details` varchar(100) collate utf8_bin default NULL,
  `arynq7` tinyint(1) default NULL,
  `arynq7_details` varchar(100) collate utf8_bin default NULL,
  `ctynq7` tinyint(1) default NULL,
  `ctynq7_details` varchar(100) collate utf8_bin default NULL,
  `arynq8` tinyint(1) default NULL,
  `arynq8_details` varchar(100) collate utf8_bin default NULL,
  `ctynq8` tinyint(1) default NULL,
  `ctynq8_details` varchar(100) collate utf8_bin default NULL,
  `arynq9` tinyint(1) default NULL,
  `arynq9_details` varchar(100) collate utf8_bin default NULL,
  `ctynq9` tinyint(1) default NULL,
  `ctynq9_details` varchar(100) collate utf8_bin default NULL,
  `arynq10` tinyint(1) default NULL,
  `arynq10_details` varchar(100) collate utf8_bin default NULL,
  `ctynq10` tinyint(1) default NULL,
  `ctynq10_details` varchar(100) collate utf8_bin default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=369 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `countries` (
  `country_id` int(3) NOT NULL auto_increment,
  `country_name` varchar(64) character set latin1 NOT NULL,
  `country_3_code` char(3) character set latin1 default NULL,
  `country_2_code` char(2) character set latin1 default NULL,
  `display_order` int(11) default NULL,
  PRIMARY KEY  (`country_id`),
  KEY `countries_country_id_idx` (`country_id`)
) ENGINE=MyISAM AUTO_INCREMENT=240 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `course_sections` (
  `course_section_id` int(11) NOT NULL auto_increment,
  `hw_section_id` varchar(35) character set latin1 default NULL,
  `active_status_id` tinyint(3) NOT NULL default '2',
  `parent_id` int(11) NOT NULL default '0',
  `display_order` int(5) default NULL,
  `course_section_name` varchar(125) character set latin1 NOT NULL default '',
  PRIMARY KEY  (`course_section_id`),
  KEY `course_sections_hw_section_id_idx` (`hw_section_id`),
  KEY `course_sections_active_status_id_idx` (`active_status_id`)
) ENGINE=MyISAM AUTO_INCREMENT=47 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `course_to_article` (
  `course_to_article_id` int(11) NOT NULL auto_increment,
  `course_id` int(11) NOT NULL,
  `article_id` int(11) NOT NULL,
  `hw_course_id` varchar(35) character set latin1 default NULL,
  `hw_article_id` varchar(40) character set latin1 default NULL,
  PRIMARY KEY  (`course_to_article_id`),
  KEY `course_to_article_course_id_idx` (`course_id`),
  KEY `course_to_article_article_id_idx` (`article_id`),
  KEY `course_to_article_hw_course_id_idx` (`hw_course_id`),
  KEY `course_to_article_hw_article_id_idx` (`hw_article_id`)
) ENGINE=MyISAM AUTO_INCREMENT=836 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `course_to_coursesection` (
  `course_to_coursesections_id` int(11) NOT NULL auto_increment,
  `course_section_id` int(11) NOT NULL,
  `hw_section_id` varchar(35) character set latin1 default NULL,
  `course_id` int(11) NOT NULL,
  `hw_course_id` varchar(35) character set latin1 default NULL,
  `canonical` varchar(5) character set latin1 default NULL,
  PRIMARY KEY  (`course_to_coursesections_id`),
  KEY `course_to_coursesection_course_section_id_idx` (`course_section_id`),
  KEY `course_to_coursesection_hw_section_id_idx` (`hw_section_id`),
  KEY `course_to_coursesection_course_id_idx` (`course_id`),
  KEY `course_to_coursesection_hw_course_id_idx` (`hw_course_id`)
) ENGINE=MyISAM AUTO_INCREMENT=579 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `courses` (
  `course_id` int(11) NOT NULL auto_increment,
  `hw_course_id` varchar(35) character set latin1 default NULL,
  `active_status_id` tinyint(3) NOT NULL default '2',
  `create_date` datetime default NULL,
  `create_by_id` int(11) default NULL,
  `create_by_ip` varchar(39) character set latin1 default NULL,
  `mod_date` datetime default NULL,
  `mod_by_id` int(11) default NULL,
  `mod_by_ip` varchar(39) character set latin1 default NULL,
  `title` varchar(750) character set latin1 NOT NULL,
  `abstract` text character set latin1,
  `publication_date` date default NULL,
  `expiration_date` date default NULL,
  `reviewed_date` date default NULL,
  `in_production` tinyint(3) NOT NULL,
  `is_linkable` tinyint(3) NOT NULL,
  `is_expired` tinyint(3) NOT NULL,
  PRIMARY KEY  (`course_id`),
  KEY `courses_hw_course_id_idx` (`hw_course_id`),
  KEY `courses_active_status_id_idx` (`active_status_id`),
  KEY `courses_publication_date_idx` (`publication_date`)
) ENGINE=MyISAM AUTO_INCREMENT=566 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `cover_letters` (
  `id` int(11) NOT NULL auto_increment,
  `file_content_type` varchar(255) collate utf8_bin default NULL,
  `file` varchar(255) collate utf8_bin default NULL,
  `version` int(11) NOT NULL default '0',
  `article_submission_id` int(11) NOT NULL,
  `file_size` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `credit_cards` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) NOT NULL,
  `customer_profile_id` varchar(255) collate utf8_bin default NULL,
  `payment_profile_id` varchar(255) collate utf8_bin default NULL,
  `merchant_customer_id` varchar(255) collate utf8_bin default NULL,
  `encrypted_name` blob,
  `encrypted_num` blob,
  `encrypted_exp_mo` blob,
  `encrypted_exp_yr` blob,
  `encrypted_zip` blob,
  `encrypted_cvv` blob,
  `email` varchar(255) collate utf8_bin default NULL,
  `num_last_four` varchar(255) collate utf8_bin default NULL,
  `cc_type` varchar(255) collate utf8_bin default NULL,
  `encrypted_key` blob,
  `encrypted_iv` blob,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `degrees` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) character set latin1 NOT NULL,
  `public` int(11) NOT NULL default '0' COMMENT 'Used as a boolean, to indicate whether this is a degree given to everyone to choose',
  `create_date` datetime default NULL,
  `create_by_id` int(11) default NULL,
  `create_by_ip` varchar(39) character set latin1 default NULL,
  `mod_date` datetime default NULL,
  `mod_by_id` int(11) default NULL,
  `mod_by_ip` varchar(39) character set latin1 default NULL,
  `position` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=97 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `dropdowns` (
  `dropdown_id` int(11) NOT NULL auto_increment,
  `dropdown_kind` varchar(12) character set latin1 NOT NULL,
  `dropdown_key` int(5) NOT NULL,
  `dropdown_lbl` varchar(80) character set latin1 NOT NULL,
  PRIMARY KEY  (`dropdown_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `editor_to_article_section` (
  `editor_to_article_section_id` int(11) NOT NULL auto_increment,
  `display_order` int(5) default NULL,
  `user_id` int(11) NOT NULL,
  `article_section_id` int(11) NOT NULL,
  `date_joined` date NOT NULL,
  `editor_active_status` varchar(20) character set latin1 NOT NULL,
  PRIMARY KEY  (`editor_to_article_section_id`)
) ENGINE=MyISAM AUTO_INCREMENT=69 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `evals` (
  `eval_id` int(11) NOT NULL auto_increment,
  `course_id` int(11) NOT NULL,
  `create_date` datetime default NULL,
  `create_by_id` int(11) default NULL,
  `create_by_ip` varchar(39) character set latin1 default NULL,
  `mod_date` datetime default NULL,
  `mod_by_id` int(11) default NULL,
  `mod_by_ip` varchar(39) character set latin1 default NULL,
  `hw_course_id` varchar(35) character set latin1 default NULL,
  `hw_eval_id` varchar(35) character set latin1 default NULL,
  `active_status_id` tinyint(3) NOT NULL default '2',
  `title` varchar(255) character set latin1 NOT NULL,
  `version_num` tinyint(2) NOT NULL default '1',
  `eval_pubstatus` tinyint(1) default NULL,
  `eval_pub_date` datetime default NULL,
  `scoring_style` varchar(35) character set latin1 default NULL,
  `sort_num` tinyint(3) default NULL,
  `num_questions` tinyint(2) default NULL,
  PRIMARY KEY  (`eval_id`),
  KEY `evals_course_id_idx` (`course_id`),
  KEY `evals_hw_course_id_idx` (`hw_course_id`),
  KEY `evals_hw_eval_id_idx` (`hw_eval_id`),
  KEY `evals_active_status_id_idx` (`active_status_id`)
) ENGINE=MyISAM AUTO_INCREMENT=192 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `fiscal_years` (
  `fiscal_year_id` int(11) NOT NULL auto_increment,
  `fiscal_year_name` varchar(10) character set latin1 NOT NULL,
  PRIMARY KEY  (`fiscal_year_id`)
) ENGINE=MyISAM AUTO_INCREMENT=10 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `forms_cois` (
  `forms_coi_id` int(11) NOT NULL auto_increment,
  `forms_manuscript_id` int(11) NOT NULL,
  `create_date` datetime default NULL,
  `create_by_id` int(11) default NULL,
  `create_by_ip` varchar(39) character set latin1 default NULL,
  `mod_date` datetime default NULL,
  `mod_by_id` int(11) default NULL,
  `mod_by_ip` varchar(39) character set latin1 default NULL,
  `name` varchar(200) character set latin1 NOT NULL,
  `token` varchar(63) character set latin1 NOT NULL,
  `email` varchar(128) character set latin1 NOT NULL,
  `role_id` int(3) NOT NULL,
  `coi_completed_date` datetime default NULL,
  PRIMARY KEY  (`forms_coi_id`),
  KEY `coi_id_idx` (`forms_coi_id`)
) ENGINE=MyISAM AUTO_INCREMENT=38 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `forms_manuscripts` (
  `forms_manuscript_id` int(11) NOT NULL auto_increment,
  `create_date` datetime default NULL,
  `create_by_id` int(11) default NULL,
  `create_by_ip` varchar(39) character set latin1 default NULL,
  `mod_date` datetime default NULL,
  `mod_by_id` int(11) default NULL,
  `mod_by_ip` varchar(39) character set latin1 default NULL,
  `corr_auth_pre_title` varchar(10) character set latin1 default '',
  `corr_auth_first_name` varchar(35) character set latin1 NOT NULL default '',
  `corr_auth_middle_name` varchar(35) character set latin1 default '',
  `corr_auth_last_name` varchar(35) character set latin1 NOT NULL default '',
  `title` varchar(750) character set latin1 NOT NULL,
  `email` varchar(128) character set latin1 NOT NULL,
  `num_authors` int(3) NOT NULL,
  PRIMARY KEY  (`forms_manuscript_id`),
  KEY `manuscript_id_idx` (`forms_manuscript_id`)
) ENGINE=MyISAM AUTO_INCREMENT=20 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `learning_objectives` (
  `learning_objective_id` int(11) NOT NULL auto_increment,
  `course_id` int(11) NOT NULL,
  `display_order` int(5) default NULL,
  `description` text character set latin1,
  PRIMARY KEY  (`learning_objective_id`),
  KEY `course_id` (`course_id`)
) ENGINE=MyISAM AUTO_INCREMENT=11867 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `manuscripts` (
  `id` int(11) NOT NULL auto_increment,
  `file_content_type` varchar(255) character set utf8 default NULL,
  `file` varchar(255) character set utf8 default NULL,
  `version` int(11) NOT NULL default '0',
  `article_submission_id` int(11) NOT NULL,
  `file_size` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=110 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `pages` (
  `id` int(11) NOT NULL auto_increment,
  `url` varchar(255) character set latin1 NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=7 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `pdfs` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) NOT NULL,
  `file` varchar(255) collate utf8_bin NOT NULL,
  `form_type` varchar(255) collate utf8_bin NOT NULL,
  `output` varchar(255) collate utf8_bin default NULL,
  `size` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `coi_form_id` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `question_types` (
  `question_type_id` tinyint(4) NOT NULL auto_increment,
  `question_type` varchar(20) character set latin1 NOT NULL,
  PRIMARY KEY  (`question_type_id`),
  UNIQUE KEY `question_type` (`question_type`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `questions` (
  `question_id` int(11) NOT NULL auto_increment,
  `quiz_or_eval` varchar(4) character set latin1 default NULL,
  `course_id` int(11) NOT NULL,
  `quizoreval_id` int(11) NOT NULL,
  `hw_course_id` varchar(35) character set latin1 default NULL,
  `hw_quizoreval_id` varchar(35) character set latin1 default NULL,
  `version_num` tinyint(2) default '1',
  `question_type_id` tinyint(4) NOT NULL,
  `sort_num` tinyint(3) default NULL,
  `hw_question_id` char(10) character set latin1 default NULL,
  `question_text` varchar(1024) character set latin1 NOT NULL,
  `hint` text character set latin1,
  PRIMARY KEY  (`question_id`),
  KEY `questions_quiz_or_eval_idx` (`quiz_or_eval`),
  KEY `questions_quizoreval_id_idx` (`quizoreval_id`),
  KEY `questions_hw_course_id_idx` (`hw_course_id`),
  KEY `questions_question_type_id_idx` (`question_type_id`),
  KEY `questions_hw_question_id_idx` (`hw_question_id`)
) ENGINE=MyISAM AUTO_INCREMENT=5683 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `quizzes` (
  `quiz_id` int(11) NOT NULL auto_increment,
  `create_date` datetime default NULL,
  `create_by_id` int(11) default NULL,
  `create_by_ip` varchar(39) character set latin1 default NULL,
  `mod_date` datetime default NULL,
  `mod_by_id` int(11) default NULL,
  `mod_by_ip` varchar(39) character set latin1 default NULL,
  `course_id` int(11) NOT NULL,
  `hw_course_id` varchar(35) character set latin1 default NULL,
  `hw_quiz_id` varchar(35) character set latin1 default NULL,
  `active_status_id` tinyint(3) NOT NULL default '2',
  `title` text character set latin1 NOT NULL,
  `version_num` tinyint(2) NOT NULL default '1',
  `quiz_pubstatus` tinyint(1) default NULL,
  `quiz_pub_date` datetime default NULL,
  `scoring_style` varchar(35) character set latin1 default NULL,
  `threshold` tinyint(2) default NULL,
  `sort_num` tinyint(3) default NULL,
  `num_questions` tinyint(2) default NULL,
  PRIMARY KEY  (`quiz_id`),
  KEY `quizzes_course_id_idx` (`course_id`),
  KEY `quizzes_hw_course_id_idx` (`hw_course_id`),
  KEY `quizzes_hw_quiz_id_idx` (`hw_quiz_id`),
  KEY `quizzes_active_status_id_idx` (`active_status_id`)
) ENGINE=MyISAM AUTO_INCREMENT=566 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `reminder_templates` (
  `reminder_template_id` int(11) NOT NULL auto_increment,
  `template_name` varchar(25) character set latin1 NOT NULL,
  `template_desc` text character set latin1 NOT NULL,
  PRIMARY KEY  (`reminder_template_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `reviewer_suggestions` (
  `reviewer_suggestion_id` int(11) NOT NULL auto_increment,
  `create_date` datetime default NULL,
  `create_by_id` int(11) default NULL,
  `create_by_ip` varchar(39) character set latin1 default NULL,
  `mod_date` datetime default NULL,
  `mod_by_id` varchar(39) character set latin1 default NULL,
  `mod_by_ip` varchar(39) character set latin1 default NULL,
  `manuscript_id` int(11) NOT NULL,
  `pre_title` varchar(10) character set latin1 default NULL,
  `first_name` varchar(35) character set latin1 NOT NULL,
  `middle_name` varchar(35) character set latin1 default NULL,
  `last_name` varchar(35) character set latin1 NOT NULL,
  `affiliation` varchar(80) character set latin1 NOT NULL,
  `email` varchar(128) character set latin1 NOT NULL,
  PRIMARY KEY  (`reviewer_suggestion_id`),
  KEY `reviewer_suggestions_reviewer_suggestion_id_idx` (`reviewer_suggestion_id`),
  KEY `reviewer_suggestions_manuscript_id_idx` (`manuscript_id`),
  KEY `reviewer_suggestions_last_name_idx` (`last_name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `reviewing_instances` (
  `article_submission_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `approved` tinyint(1) default NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `role_instances` (
  `id` int(11) NOT NULL auto_increment,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `roles` (
  `role_id` tinyint(3) NOT NULL auto_increment,
  `display_order` int(5) default NULL,
  `role_title` varchar(40) character set latin1 NOT NULL,
  PRIMARY KEY  (`role_id`),
  UNIQUE KEY `role_title` (`role_title`),
  KEY `roles_role_id_idx` (`role_id`)
) ENGINE=MyISAM AUTO_INCREMENT=10 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `schema_migrations` (
  `version` varchar(255) collate utf8_bin NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `ser_issues` (
  `ser_issue_id` int(11) NOT NULL auto_increment,
  `create_date` datetime default NULL,
  `create_by_id` int(11) default NULL,
  `create_by_ip` varchar(39) character set latin1 default NULL,
  `mod_date` datetime default NULL,
  `mod_by_id` int(11) default NULL,
  `mod_by_ip` varchar(39) character set latin1 default NULL,
  `active_status_id` tinyint(3) NOT NULL default '2',
  `ser_title` varchar(100) character set latin1 NOT NULL,
  `ser_close_date` date NOT NULL,
  `ser_overall_comment` varchar(3500) character set latin1 default NULL,
  PRIMARY KEY  (`ser_issue_id`)
) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `sessions` (
  `id` int(11) NOT NULL auto_increment,
  `session_id` varchar(255) character set latin1 NOT NULL,
  `data` text character set latin1,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_sessions_on_session_id` (`session_id`),
  KEY `index_sessions_on_updated_at` (`updated_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `states_provinces` (
  `state_province_id` int(3) NOT NULL auto_increment,
  `country_id` int(3) NOT NULL default '1',
  `state_name` varchar(64) collate utf8_bin NOT NULL,
  `state_3_code` char(3) collate utf8_bin default NULL,
  `state_2_code` char(2) collate utf8_bin NOT NULL,
  PRIMARY KEY  (`state_province_id`),
  KEY `country_id` (`country_id`)
) ENGINE=MyISAM AUTO_INCREMENT=166 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `states_provinces_odd` (
  `state_province_id` int(3) NOT NULL auto_increment,
  `country_id` int(3) NOT NULL default '1',
  `state_name` varchar(64) character set utf8 collate utf8_bin NOT NULL,
  `state_3_code` char(3) character set utf8 collate utf8_bin default NULL,
  `state_2_code` char(2) character set utf8 collate utf8_bin NOT NULL,
  PRIMARY KEY  (`state_province_id`),
  KEY `country_id` (`country_id`)
) ENGINE=MyISAM AUTO_INCREMENT=166 DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `submission_type` (
  `submission_type_id` int(11) NOT NULL auto_increment,
  `display_order` int(5) NOT NULL,
  `submission_type` varchar(35) character set latin1 NOT NULL,
  PRIMARY KEY  (`submission_type_id`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `sys_params` (
  `sys_params_id` int(11) NOT NULL auto_increment,
  `lang_id` int(11) NOT NULL default '0',
  `app_name` varchar(50) character set latin1 NOT NULL,
  `version` varchar(15) character set latin1 NOT NULL default '',
  `sys_last_updated` date NOT NULL,
  `date_format` varchar(10) character set latin1 NOT NULL,
  `time_format` varchar(10) character set latin1 NOT NULL,
  `home_url` varchar(100) character set latin1 NOT NULL,
  `down_for_maint_flag` tinyint(1) NOT NULL default '0',
  `debug_mode` tinyint(1) NOT NULL default '0',
  `debug_ips` varchar(255) character set latin1 NOT NULL,
  `default_list_max_rows` int(4) NOT NULL default '50',
  `email_server` varchar(25) character set latin1 NOT NULL,
  `email_port` int(4) NOT NULL,
  `robot_email_from_addr` varchar(80) character set latin1 NOT NULL,
  `robot_email_pw` varchar(15) character set latin1 NOT NULL,
  `hostname` varchar(75) character set latin1 NOT NULL default '',
  `download_dir` varchar(255) character set latin1 NOT NULL default '',
  `upload_dir` varchar(255) character set latin1 NOT NULL default '',
  `dir_root` varchar(25) character set latin1 NOT NULL default '',
  `dir_fs` varchar(255) character set latin1 NOT NULL default '',
  PRIMARY KEY  (`sys_params_id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `user_eval_answers` (
  `user_eval_answers_id` int(11) NOT NULL auto_increment,
  `user_eval_result_id` int(11) NOT NULL,
  `course_id` int(11) NOT NULL,
  `quiz_id` int(11) NOT NULL,
  `question_id` int(11) NOT NULL,
  `answer_choices_id` int(11) NOT NULL,
  `hw_membership_no` varchar(15) character set latin1 NOT NULL,
  `hw_course_id` varchar(35) character set latin1 NOT NULL,
  `hw_eval_id` varchar(35) character set latin1 NOT NULL,
  `hw_question_id` char(10) character set latin1 NOT NULL,
  `hw_answer_id` char(10) character set latin1 NOT NULL,
  `user_answer_text` text character set latin1,
  PRIMARY KEY  (`user_eval_answers_id`),
  KEY `user_eval_answers_user_eval_result_id_idx` (`user_eval_result_id`),
  KEY `user_eval_answers_question_id_idx` (`question_id`),
  KEY `user_eval_answers_answer_choices_id_idx` (`answer_choices_id`),
  KEY `user_eval_answers_hw_membership_no_idx` (`hw_membership_no`)
) ENGINE=MyISAM AUTO_INCREMENT=214366 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `user_eval_results` (
  `user_eval_result_id` int(11) NOT NULL auto_increment,
  `course_id` int(11) NOT NULL,
  `eval_id` int(11) NOT NULL,
  `hw_membership_no` varchar(15) character set latin1 NOT NULL,
  `hw_course_id` varchar(35) character set latin1 NOT NULL,
  `hw_eval_id` varchar(35) character set latin1 NOT NULL,
  `session_id` int(6) NOT NULL,
  `is_current_session` varchar(5) character set latin1 NOT NULL,
  `status` varchar(20) character set latin1 NOT NULL,
  `submit_date` datetime NOT NULL,
  PRIMARY KEY  (`user_eval_result_id`),
  KEY `user_eval_results_eval_id_idx` (`eval_id`),
  KEY `user_eval_results_hw_membership_no_idx` (`hw_membership_no`),
  KEY `user_eval_results_hw_eval_id_idx` (`hw_eval_id`),
  KEY `user_eval_results_is_current_session_idx` (`is_current_session`)
) ENGINE=MyISAM AUTO_INCREMENT=21143 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `user_quiz_answers` (
  `user_quiz_answers_id` int(11) NOT NULL auto_increment,
  `user_quiz_result_id` int(11) NOT NULL,
  `course_id` int(11) NOT NULL,
  `quiz_id` int(11) NOT NULL,
  `question_id` int(11) NOT NULL,
  `answer_choices_id` int(11) NOT NULL,
  `hw_membership_no` varchar(15) character set latin1 NOT NULL,
  `hw_course_id` varchar(35) character set latin1 NOT NULL,
  `hw_quiz_id` varchar(35) character set latin1 NOT NULL,
  `hw_question_id` char(10) character set latin1 NOT NULL,
  `hw_answer_id` char(10) character set latin1 NOT NULL,
  `user_answer_text` text character set latin1,
  PRIMARY KEY  (`user_quiz_answers_id`),
  KEY `user_quiz_answers_user_quiz_result_id_idx` (`user_quiz_result_id`),
  KEY `user_quiz_answers_question_id_idx` (`question_id`),
  KEY `user_quiz_answers_answer_choices_id_idx` (`answer_choices_id`),
  KEY `user_quiz_answers_hw_membership_no_idx` (`hw_membership_no`)
) ENGINE=MyISAM AUTO_INCREMENT=1861743 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `user_quiz_results` (
  `user_quiz_result_id` int(11) NOT NULL auto_increment,
  `course_id` int(11) NOT NULL,
  `quiz_id` int(11) NOT NULL,
  `hw_membership_no` varchar(15) character set latin1 NOT NULL,
  `hw_course_id` varchar(35) character set latin1 NOT NULL,
  `hw_quiz_id` varchar(35) character set latin1 NOT NULL,
  `session_id` int(6) NOT NULL,
  `is_current_session` varchar(5) character set latin1 NOT NULL,
  `passed_quiz` tinyint(1) NOT NULL,
  `score` float NOT NULL,
  `points` float NOT NULL,
  `status` varchar(20) character set latin1 NOT NULL,
  `submit_date` datetime NOT NULL,
  PRIMARY KEY  (`user_quiz_result_id`),
  KEY `user_quiz_results_quiz_id_idx` (`quiz_id`),
  KEY `user_quiz_results_hw_membership_no_idx` (`hw_membership_no`),
  KEY `user_quiz_results_hw_quiz_id_idx` (`hw_quiz_id`),
  KEY `user_quiz_results_is_current_session_idx` (`is_current_session`),
  KEY `user_quiz_results_passed_quiz_idx` (`passed_quiz`)
) ENGINE=MyISAM AUTO_INCREMENT=338884 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `user_security_levels` (
  `user_security_level` tinyint(3) NOT NULL auto_increment,
  `security_level` tinyint(3) NOT NULL,
  `security_level_lbl` varchar(20) character set latin1 NOT NULL,
  PRIMARY KEY  (`user_security_level`),
  UNIQUE KEY `security_level_lbl` (`security_level_lbl`)
) ENGINE=MyISAM AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `user_templates` (
  `id` int(11) NOT NULL auto_increment,
  `title` varchar(255) character set latin1 NOT NULL,
  `alias` varchar(255) collate utf8_bin default NULL,
  `body` longtext character set latin1,
  `description` longtext character set latin1,
  `to_html` tinyint(1) default NULL COMMENT 'bool',
  `body_html` longtext collate utf8_bin COMMENT 'markdown equiv of body',
  PRIMARY KEY  (`id`),
  KEY `alias` (`alias`)
) ENGINE=MyISAM AUTO_INCREMENT=149 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `user_to_role` (
  `user_to_role_id` int(11) NOT NULL auto_increment,
  `display_order` int(5) default NULL,
  `user_id` int(11) NOT NULL,
  `role_id` tinyint(3) NOT NULL,
  `article_id` int(11) default NULL,
  `credentials` varchar(255) character set latin1 default '',
  `fiscal_year_id` int(11) default NULL,
  PRIMARY KEY  (`user_to_role_id`),
  KEY `article_id` (`article_id`),
  KEY `user_id` (`user_id`),
  KEY `role_id` (`role_id`)
) ENGINE=MyISAM AUTO_INCREMENT=5964 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `users` (
  `user_id` int(11) NOT NULL auto_increment,
  `create_date` datetime default NULL,
  `create_by_id` int(11) default NULL,
  `create_by_ip` varchar(39) collate utf8_bin NOT NULL,
  `mod_date` datetime default NULL,
  `mod_by_id` varchar(39) collate utf8_bin default NULL,
  `mod_by_ip` varchar(39) collate utf8_bin default NULL,
  `active_status_id` tinyint(3) NOT NULL,
  `display_order` int(5) default NULL,
  `username` varchar(128) collate utf8_bin NOT NULL,
  `password` varchar(128) collate utf8_bin NOT NULL,
  `temp_password_flag` tinyint(1) default '0',
  `security_level` tinyint(3) NOT NULL,
  `pre_title` varchar(10) collate utf8_bin default NULL,
  `first_name` varchar(35) collate utf8_bin default NULL,
  `middle_name` varchar(35) collate utf8_bin default NULL,
  `last_name` varchar(35) collate utf8_bin default NULL,
  `email` varchar(128) character set utf8 collate utf8_unicode_ci default NULL,
  `ok_to_email` tinyint(1) NOT NULL default '1',
  `last_login` datetime default NULL,
  `last_login_ip` varchar(16) collate utf8_bin default NULL,
  `login_count` int(6) default '0',
  `last_login_attempt` datetime default NULL,
  `last_login_ip_attempt` varchar(16) collate utf8_bin default NULL,
  `failed_login_count` int(6) default NULL,
  `lost_password_count` int(6) default NULL,
  `employer` varchar(80) collate utf8_bin default NULL,
  `department` varchar(80) collate utf8_bin default NULL,
  `position_title` varchar(50) collate utf8_bin default NULL,
  `address_1` varchar(64) collate utf8_bin default NULL,
  `address_2` varchar(64) collate utf8_bin default NULL,
  `city` varchar(32) collate utf8_bin default NULL,
  `state_province_id` int(3) default NULL,
  `zip_postalcode` varchar(15) collate utf8_bin default NULL,
  `country_id` int(3) default NULL,
  `phone_preferred` varchar(20) collate utf8_bin default NULL,
  `phone_work` varchar(15) collate utf8_bin default NULL,
  `phone_work_ext` varchar(6) collate utf8_bin default NULL,
  `phone_cell` varchar(15) collate utf8_bin default NULL,
  `phone_fax` varchar(15) collate utf8_bin default NULL,
  `assistant_name` varchar(60) collate utf8_bin default NULL,
  `assistant_email` varchar(80) collate utf8_bin default NULL,
  `assistant_phone` varchar(15) collate utf8_bin default NULL,
  `cc_emails_to_asst` tinyint(1) default NULL,
  `notes` varchar(255) collate utf8_bin default NULL,
  `degree1` varchar(255) collate utf8_bin default NULL,
  `degree2` varchar(255) collate utf8_bin default NULL,
  `degree3` varchar(255) collate utf8_bin default NULL,
  `page_id` int(11) default NULL,
  `degree1_other` varchar(255) collate utf8_bin default NULL,
  `degree2_other` varchar(255) collate utf8_bin default NULL,
  `degree3_other` varchar(255) collate utf8_bin default NULL,
  `url` varchar(255) collate utf8_bin default NULL,
  `remember_token` varchar(255) collate utf8_bin default NULL,
  `remember_token_expires_at` datetime default NULL,
  `secret_token` varchar(255) collate utf8_bin default NULL,
  `auto_created` tinyint(1) default NULL,
  `user_can_edit` int(11) default NULL,
  PRIMARY KEY  (`user_id`),
  UNIQUE KEY `username` (`username`),
  KEY `users_active_status_id_idx` (`active_status_id`),
  KEY `users_username_idx` (`username`),
  KEY `users_password_idx` (`password`),
  KEY `users_security_level_idx` (`security_level`),
  KEY `users_last_name_idx` (`last_name`),
  KEY `users_state_province_id_idx` (`state_province_id`),
  KEY `users_country_id_idx` (`country_id`),
  KEY `users_notes_idx` (`notes`),
  KEY `email` (`email`)
) ENGINE=MyISAM AUTO_INCREMENT=4602 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE IF NOT EXISTS `users_odd` (
  `user_id` int(11) NOT NULL auto_increment,
  `create_date` datetime default NULL,
  `create_by_id` int(11) default NULL,
  `create_by_ip` varchar(39) character set latin1 NOT NULL,
  `mod_date` datetime default NULL,
  `mod_by_id` varchar(39) character set latin1 default NULL,
  `mod_by_ip` varchar(39) character set latin1 default NULL,
  `active_status_id` tinyint(3) NOT NULL,
  `display_order` int(5) default NULL,
  `username` varchar(32) character set latin1 NOT NULL,
  `password` varchar(128) character set latin1 NOT NULL,
  `temp_password_flag` tinyint(1) default '0',
  `security_level` tinyint(3) NOT NULL,
  `pre_title` varchar(10) character set latin1 default NULL,
  `first_name` varchar(35) character set latin1 default NULL,
  `middle_name` varchar(35) character set latin1 default NULL,
  `last_name` varchar(35) character set latin1 default NULL,
  `email` varchar(128) character set latin1 default NULL,
  `ok_to_email` tinyint(1) NOT NULL default '1',
  `last_login` datetime default NULL,
  `last_login_ip` varchar(16) character set latin1 default NULL,
  `login_count` int(6) default '0',
  `last_login_attempt` datetime default NULL,
  `last_login_ip_attempt` varchar(16) character set latin1 default NULL,
  `failed_login_count` int(6) default NULL,
  `lost_password_count` int(6) default NULL,
  `employer` varchar(80) character set latin1 default NULL,
  `department` varchar(80) character set latin1 default NULL,
  `position_title` varchar(50) character set latin1 default NULL,
  `address_1` varchar(64) character set latin1 default NULL,
  `address_2` varchar(64) character set latin1 default NULL,
  `city` varchar(32) character set latin1 default NULL,
  `state_province_id` int(3) default NULL,
  `zip_postalcode` varchar(15) character set latin1 default NULL,
  `country_id` int(3) default NULL,
  `phone_preferred` varchar(20) collate utf8_bin default NULL,
  `phone_work` varchar(15) character set latin1 default NULL,
  `phone_work_ext` varchar(6) character set latin1 default NULL,
  `phone_cell` varchar(15) character set latin1 default NULL,
  `phone_fax` varchar(15) character set latin1 default NULL,
  `assistant_name` varchar(60) character set latin1 default NULL,
  `assistant_email` varchar(80) character set latin1 default NULL,
  `assistant_phone` varchar(15) character set latin1 default NULL,
  `cc_emails_to_asst` tinyint(1) default NULL,
  `notes` varchar(255) character set latin1 default NULL,
  `degree1` varchar(255) character set latin1 default NULL,
  `degree2` varchar(255) character set latin1 default NULL,
  `degree3` varchar(255) character set latin1 default NULL,
  `page_id` int(11) default NULL,
  `degree1_other` varchar(255) character set latin1 default NULL,
  `degree2_other` varchar(255) character set latin1 default NULL,
  `degree3_other` varchar(255) character set latin1 default NULL,
  `url` varchar(255) character set latin1 default NULL,
  `remember_token` varchar(255) character set latin1 default NULL,
  `remember_token_expires_at` datetime default NULL,
  `secret_token` varchar(255) character set latin1 default NULL,
  `auto_created` tinyint(1) default NULL,
  `user_can_edit` int(11) default NULL,
  PRIMARY KEY  (`user_id`),
  UNIQUE KEY `username` (`username`),
  KEY `users_active_status_id_idx` (`active_status_id`),
  KEY `users_username_idx` (`username`),
  KEY `users_password_idx` (`password`),
  KEY `users_security_level_idx` (`security_level`),
  KEY `users_last_name_idx` (`last_name`),
  KEY `users_state_province_id_idx` (`state_province_id`),
  KEY `users_country_id_idx` (`country_id`),
  KEY `users_notes_idx` (`notes`),
  KEY `email` (`email`)
) ENGINE=MyISAM AUTO_INCREMENT=4163 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

INSERT INTO schema_migrations (version) VALUES ('20090228004056');

INSERT INTO schema_migrations (version) VALUES ('20090228204641');

INSERT INTO schema_migrations (version) VALUES ('20090301205744');

INSERT INTO schema_migrations (version) VALUES ('20090311075550');

INSERT INTO schema_migrations (version) VALUES ('20090316131913');

INSERT INTO schema_migrations (version) VALUES ('20090317152137');

INSERT INTO schema_migrations (version) VALUES ('20090317154724');

INSERT INTO schema_migrations (version) VALUES ('20090317210350');

INSERT INTO schema_migrations (version) VALUES ('20090323054129');

INSERT INTO schema_migrations (version) VALUES ('20090404223259');

INSERT INTO schema_migrations (version) VALUES ('20090509193414');
