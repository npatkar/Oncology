# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20101216135152) do

  create_table "active_status", :primary_key => "active_status_id", :force => true do |t|
    t.integer "display_order"
    t.string  "active_status", :limit => 15, :null => false
  end

  add_index "active_status", ["active_status"], :name => "active_status", :unique => true
  add_index "active_status", ["active_status_id"], :name => "active_status_id_idx"

  create_table "additional_files", :force => true do |t|
    t.string   "file_content_type"
    t.string   "file"
    t.integer  "version",               :default => 0, :null => false
    t.integer  "article_submission_id",                :null => false
    t.integer  "file_size"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "answer_choice_types", :primary_key => "answer_choice_type_id", :force => true do |t|
    t.string "answer_type_name", :limit => 20, :null => false
  end

  add_index "answer_choice_types", ["answer_type_name"], :name => "answer_type_name", :unique => true

  create_table "answer_choices", :primary_key => "answer_choices_id", :force => true do |t|
    t.string  "hw_answer_id",          :limit => 10, :null => false
    t.integer "course_id",                           :null => false
    t.integer "quiz_id",                             :null => false
    t.integer "question_id",                         :null => false
    t.string  "hw_course_id",          :limit => 35, :null => false
    t.string  "hw_quizoreval_id",      :limit => 35, :null => false
    t.boolean "answer_choice_type_id",               :null => false
    t.integer "sort_num",              :limit => 1
    t.string  "hw_question_id",        :limit => 10, :null => false
    t.text    "text",                                :null => false
    t.string  "is_correct",            :limit => 5,  :null => false
  end

  add_index "answer_choices", ["answer_choice_type_id"], :name => "answer_choices_answer_choice_type_id_idx"
  add_index "answer_choices", ["hw_question_id"], :name => "answer_choices_hw_question_id_idx"
  add_index "answer_choices", ["question_id"], :name => "answer_choices_question_id_idx"

  create_table "article_sections", :primary_key => "article_section_id", :force => true do |t|
    t.date    "create_date"
    t.integer "create_by_id"
    t.string  "create_by_ip",         :limit => 39,   :default => ""
    t.date    "mod_date"
    t.integer "mod_by_id"
    t.string  "mod_by_ip",            :limit => 39,   :default => ""
    t.integer "active_status_id",     :limit => 1,    :default => 2,  :null => false
    t.integer "parent_id",                            :default => 0,  :null => false
    t.integer "display_order"
    t.string  "article_section_name", :limit => 125,  :default => "", :null => false
    t.string  "ser_cur_comment",      :limit => 3500
    t.string  "key_change_history",   :limit => 3500, :default => ""
    t.integer "public",                               :default => 0,  :null => false
  end

  add_index "article_sections", ["active_status_id"], :name => "article_sections_active_status_id_idx"
  add_index "article_sections", ["article_section_id"], :name => "article_sections_article_section_id_idx"
  add_index "article_sections", ["public"], :name => "public"

  create_table "article_sections_odd", :primary_key => "article_section_id", :force => true do |t|
    t.date    "create_date"
    t.integer "create_by_id"
    t.string  "create_by_ip",         :limit => 39,   :default => ""
    t.date    "mod_date"
    t.integer "mod_by_id"
    t.string  "mod_by_ip",            :limit => 39,   :default => ""
    t.integer "active_status_id",     :limit => 1,    :default => 2,  :null => false
    t.integer "parent_id",                            :default => 0,  :null => false
    t.integer "display_order"
    t.string  "article_section_name", :limit => 125,  :default => "", :null => false
    t.string  "ser_cur_comment",      :limit => 3500
    t.string  "key_change_history",   :limit => 3500, :default => ""
    t.integer "public",                               :default => 0,  :null => false
  end

  add_index "article_sections_odd", ["active_status_id"], :name => "article_sections_active_status_id_idx"
  add_index "article_sections_odd", ["article_section_id"], :name => "article_sections_article_section_id_idx"

  create_table "article_status", :primary_key => "article_status_id", :force => true do |t|
    t.integer "display_order",                               :null => false
    t.integer "ser_display_order"
    t.string  "status",                        :limit => 35, :null => false
    t.string  "article_submission_status_key"
  end

  create_table "article_submission_reviewers", :force => true do |t|
    t.integer  "article_submission_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "alternate_reviewer_id"
    t.integer  "days_to_comment"
    t.text     "comments"
    t.datetime "comments_deadline"
  end

  create_table "article_submissions", :force => true do |t|
    t.datetime "create_date"
    t.integer  "create_by_id"
    t.string   "create_by_ip",                  :limit => 39
    t.datetime "mod_date"
    t.integer  "mod_by_id"
    t.string   "mod_by_ip",                     :limit => 39
    t.string   "title",                                                           :null => false
    t.integer  "article_section_id",                                              :null => false
    t.integer  "num_pages",                                     :default => 0,    :null => false
    t.integer  "num_refs",                                      :default => 0,    :null => false
    t.integer  "num_tables",                                    :default => 0,    :null => false
    t.integer  "num_figures",                                                     :null => false
    t.integer  "num_suppl_mtrls",                                                 :null => false
    t.boolean  "incl_gap"
    t.boolean  "incl_abstract"
    t.boolean  "incl_keywords"
    t.boolean  "incl_learn_obj"
    t.boolean  "incl_best_practices"
    t.boolean  "incl_two_strategies"
    t.integer  "submission_type_id"
    t.string   "invited_by"
    t.string   "fees_cc_type"
    t.string   "fees_pubfee_status",            :limit => 63
    t.string   "fees_nopubfee_reason"
    t.boolean  "indemnify"
    t.string   "cant_pay_reason",               :limit => 512
    t.datetime "committed"
    t.integer  "article_id"
    t.boolean  "approved"
    t.string   "payment_type"
    t.boolean  "invited"
    t.integer  "cover_letter_id"
    t.date     "imported_to_pf"
    t.string   "reviewer1",                     :limit => 1024
    t.string   "reviewer2",                     :limit => 1024
    t.string   "reviewer3",                     :limit => 1024
    t.integer  "review_pdf_id"
    t.date     "charged_pub_fee"
    t.date     "charged_initial_fee"
    t.date     "pub_charge_settled"
    t.date     "initial_charge_settled"
    t.integer  "permission_id"
    t.integer  "manuscript_type_id"
    t.text     "learn_obj_1"
    t.text     "learn_obj_2"
    t.text     "learn_obj_3"
    t.text     "learn_obj_4"
    t.text     "gap_1"
    t.text     "gap_2"
    t.text     "gap_3"
    t.text     "gap_4"
    t.text     "gap_5"
    t.text     "gap_6"
    t.text     "gap_7"
    t.text     "gap_8"
    t.text     "gap_9"
    t.text     "gap_10"
    t.text     "gap_11"
    t.text     "gap_12"
    t.boolean  "has_gap_and_learn_objs"
    t.boolean  "is_sole_author"
    t.boolean  "visited_coauthor_page"
    t.text     "abstract"
    t.string   "manuscript_video_link"
    t.text     "note_of_recused_editors"
    t.text     "section_editor_correspondence"
    t.text     "publisher_comments"
    t.boolean  "admin_urgent"
    t.text     "admin_notes"
    t.boolean  "is_letter"
    t.boolean  "sole_author"
    t.boolean  "resubmitted"
    t.datetime "updated_at"
    t.string   "short_title"
    t.string   "keywords"
    t.integer  "parent_id"
    t.integer  "version"
    t.boolean  "last_revision",                                 :default => true
  end

  create_table "article_to_articlesection", :id => false, :force => true do |t|
    t.integer "section_id",                          :null => false
    t.integer "article_id",                          :null => false
    t.string  "canonical",              :limit => 5
    t.integer "article_to_sections_id"
  end

  add_index "article_to_articlesection", ["article_id"], :name => "article_to_articlesection_article_id_idx"
  add_index "article_to_articlesection", ["section_id"], :name => "article_to_articlesection_section_id_idx"

  create_table "article_to_articlesection_bk", :primary_key => "article_to_sections_id", :force => true do |t|
    t.integer "section_id",              :null => false
    t.integer "article_id",              :null => false
    t.string  "canonical",  :limit => 5
  end

  add_index "article_to_articlesection_bk", ["article_id"], :name => "article_to_articlesection_article_id_idx"
  add_index "article_to_articlesection_bk", ["section_id"], :name => "article_to_articlesection_section_id_idx"

  create_table "article_to_reminder", :primary_key => "article_to_reminder_id", :force => true do |t|
    t.integer  "article_id",           :null => false
    t.datetime "sent_date",            :null => false
    t.integer  "reminder_template_id", :null => false
    t.text     "actual_desc",          :null => false
  end

  add_index "article_to_reminder", ["article_id"], :name => "article_to_reminder_article_id_idx"
  add_index "article_to_reminder", ["reminder_template_id"], :name => "article_to_reminder_reminder_template_id_idx"

  create_table "articles", :primary_key => "article_id", :force => true do |t|
    t.datetime "create_date"
    t.integer  "create_by_id"
    t.string   "create_by_ip",                :limit => 39
    t.datetime "mod_date"
    t.integer  "mod_by_id"
    t.string   "mod_by_ip",                   :limit => 39
    t.integer  "article_status_id",                                           :null => false
    t.string   "title",                       :limit => 750,                  :null => false
    t.text     "abstract"
    t.date     "date_suggested"
    t.boolean  "alternates_needed_flag"
    t.date     "date_invited"
    t.string   "submission_type",             :limit => 10
    t.date     "date_pledged"
    t.date     "date_promised_1"
    t.date     "date_received"
    t.string   "manuscript_num",              :limit => 10
    t.string   "manuscript_suffix",           :limit => 3
    t.date     "date_submission_1"
    t.boolean  "submit_fee_paid_flag"
    t.date     "reviewers_selected_1"
    t.date     "comments_sent_to_mgeditor_1"
    t.date     "date_first_decision"
    t.string   "first_decision_type",         :limit => 25
    t.date     "date_promised_2"
    t.date     "date_submission_2"
    t.date     "reviewers_selected_2"
    t.date     "comments_sent_to_mgeditor_2"
    t.date     "date_second_decision"
    t.string   "second_decision_type",        :limit => 25
    t.date     "date_promised_3"
    t.date     "date_submission_3"
    t.date     "date_third_decision"
    t.string   "third_decision_type",         :limit => 25,   :default => ""
    t.date     "date_promised_4"
    t.date     "date_submission_4"
    t.date     "date_final_decision"
    t.string   "final_decision_type",         :limit => 25,   :default => ""
    t.date     "date_published"
    t.boolean  "pub_with_cme_flag"
    t.string   "doi",                         :limit => 40
    t.string   "hw_article_id",               :limit => 40
    t.string   "hw_sort_num",                 :limit => 3
    t.integer  "volume"
    t.string   "issue",                       :limit => 35
    t.integer  "start_page"
    t.integer  "end_page"
    t.date     "date_retracted"
    t.date     "date_withdrawn"
    t.string   "withdrawal_reason",           :limit => 25,   :default => ""
    t.string   "conflict_of_interest",        :limit => 3500
    t.boolean  "pcoi_flag"
    t.string   "peer_review_note",            :limit => 3500
    t.binary   "ser_cur_comment"
    t.string   "ser_comment_history",         :limit => 3500
    t.string   "article_comments",            :limit => 3500
    t.string   "key_changes_history",         :limit => 3500
    t.date     "publish_date"
  end

  add_index "articles", ["article_status_id"], :name => "articles_article_status_id_idx"
  add_index "articles", ["doi"], :name => "articles_doi_idx"
  add_index "articles", ["final_decision_type"], :name => "articles_final_decision_type_idx"
  add_index "articles", ["first_decision_type"], :name => "articles_first_decision_type_idx"
  add_index "articles", ["hw_article_id"], :name => "articles_hw_article_id_idx"
  add_index "articles", ["pub_with_cme_flag"], :name => "articles_pub_with_cme_flag_idx"
  add_index "articles", ["second_decision_type"], :name => "articles_interim_decision_type_idx"
  add_index "articles", ["submission_type"], :name => "articles_submission_type_id_idx"
  add_index "articles", ["title"], :name => "articles_title_idx", :length => {"title"=>333}
  add_index "articles", ["withdrawal_reason"], :name => "articles_withdrawal_reason_idx"

  create_table "articles_odd", :primary_key => "article_id", :force => true do |t|
    t.datetime "create_date"
    t.integer  "create_by_id"
    t.string   "create_by_ip",                :limit => 39
    t.datetime "mod_date"
    t.integer  "mod_by_id"
    t.string   "mod_by_ip",                   :limit => 39
    t.integer  "article_status_id",                                           :null => false
    t.string   "title",                       :limit => 750,                  :null => false
    t.text     "abstract"
    t.date     "date_suggested"
    t.boolean  "alternates_needed_flag"
    t.date     "date_invited"
    t.string   "submission_type",             :limit => 10
    t.date     "date_pledged"
    t.date     "date_promised_1"
    t.date     "date_received"
    t.string   "manuscript_num",              :limit => 10
    t.string   "manuscript_suffix",           :limit => 3
    t.date     "date_submission_1"
    t.boolean  "submit_fee_paid_flag"
    t.date     "reviewers_selected_1"
    t.date     "comments_sent_to_mgeditor_1"
    t.date     "date_first_decision"
    t.string   "first_decision_type",         :limit => 25
    t.date     "date_promised_2"
    t.date     "date_submission_2"
    t.date     "reviewers_selected_2"
    t.date     "comments_sent_to_mgeditor_2"
    t.date     "date_second_decision"
    t.string   "second_decision_type",        :limit => 25
    t.date     "date_promised_3"
    t.date     "date_submission_3"
    t.date     "date_third_decision"
    t.string   "third_decision_type",         :limit => 25,   :default => ""
    t.date     "date_promised_4"
    t.date     "date_submission_4"
    t.date     "date_final_decision"
    t.string   "final_decision_type",         :limit => 25,   :default => ""
    t.date     "date_published"
    t.boolean  "pub_with_cme_flag"
    t.string   "doi",                         :limit => 40
    t.string   "hw_article_id",               :limit => 40
    t.string   "hw_sort_num",                 :limit => 3
    t.integer  "volume"
    t.string   "issue",                       :limit => 35
    t.integer  "start_page"
    t.integer  "end_page"
    t.date     "date_retracted"
    t.date     "date_withdrawn"
    t.string   "withdrawal_reason",           :limit => 25,   :default => ""
    t.string   "conflict_of_interest",        :limit => 3500
    t.boolean  "pcoi_flag"
    t.string   "peer_review_note",            :limit => 3500
    t.string   "ser_cur_comment",             :limit => 3500
    t.string   "ser_comment_history",         :limit => 3500
    t.string   "article_comments",            :limit => 3500
    t.string   "key_changes_history",         :limit => 3500
  end

  add_index "articles_odd", ["article_status_id"], :name => "articles_article_status_id_idx"
  add_index "articles_odd", ["doi"], :name => "articles_doi_idx"
  add_index "articles_odd", ["final_decision_type"], :name => "articles_final_decision_type_idx"
  add_index "articles_odd", ["first_decision_type"], :name => "articles_first_decision_type_idx"
  add_index "articles_odd", ["hw_article_id"], :name => "articles_hw_article_id_idx"
  add_index "articles_odd", ["pub_with_cme_flag"], :name => "articles_pub_with_cme_flag_idx"
  add_index "articles_odd", ["second_decision_type"], :name => "articles_interim_decision_type_idx"
  add_index "articles_odd", ["submission_type"], :name => "articles_submission_type_id_idx"
  add_index "articles_odd", ["title"], :name => "articles_title_idx", :length => {"title"=>333}
  add_index "articles_odd", ["withdrawal_reason"], :name => "articles_withdrawal_reason_idx"

  create_table "articlesection_sercommenthistory", :primary_key => "articlesection_sercommenthistory_id", :force => true do |t|
    t.integer "article_section_id",                 :null => false
    t.integer "ser_issue_id"
    t.string  "ser_comment",        :limit => 3500
  end

  create_table "audit_logs", :primary_key => "audit_item_id", :force => true do |t|
    t.datetime "create_date",                                :null => false
    t.integer  "create_by_id",                               :null => false
    t.string   "create_by_ip", :limit => 39,                 :null => false
    t.string   "function",     :limit => 35,                 :null => false
    t.string   "action",                                     :null => false
    t.integer  "primary_key"
    t.string   "pre_value",                                  :null => false
    t.string   "post_value",                 :default => ""
  end

  create_table "audit_trails", :force => true do |t|
    t.integer  "user_id",               :null => false
    t.integer  "article_submission_id"
    t.integer  "user_acted_as_id"
    t.integer  "user_acted_on_id"
    t.integer  "contribution_id"
    t.integer  "coi_form_id"
    t.string   "details",               :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "author_contributions", :primary_key => "author_contrib_id", :force => true do |t|
    t.integer "display_order"
    t.string  "contribution_title", :limit => 60, :null => false
  end

  add_index "author_contributions", ["author_contrib_id"], :name => "author_contributions_author_contrib_id_idx"
  add_index "author_contributions", ["contribution_title"], :name => "contribution_title", :unique => true

  create_table "author_credentials_disclosures", :primary_key => "author_credentials_disclosures_id", :force => true do |t|
    t.integer "course_id",   :null => false
    t.text    "credentials", :null => false
    t.text    "disclosures", :null => false
    t.integer "author_id",   :null => false
  end

  add_index "author_credentials_disclosures", ["author_id"], :name => "author_credentials_disclosures_author_id_idx"
  add_index "author_credentials_disclosures", ["course_id"], :name => "author_credentials_disclosures_course_id_idx"

  create_table "author_to_contribs", :primary_key => "author_to_contribs_id", :force => true do |t|
    t.integer "author_id",                              :null => false
    t.integer "author_contrib_id",        :limit => 1,  :null => false
    t.string  "other_contribution_title", :limit => 60
  end

  add_index "author_to_contribs", ["author_contrib_id"], :name => "author_to_contribs_author_contrib_id_idx"
  add_index "author_to_contribs", ["author_id"], :name => "author_to_contribs_author_id_idx"
  add_index "author_to_contribs", ["author_to_contribs_id"], :name => "author_to_contribs_id_idx"

  create_table "authors", :primary_key => "author_id", :force => true do |t|
    t.datetime "create_date"
    t.integer  "create_by_id"
    t.string   "create_by_ip",         :limit => 39
    t.datetime "mod_date"
    t.string   "mod_by_id",            :limit => 39
    t.string   "mod_by_ip",            :limit => 39
    t.string   "unique_email_link_id", :limit => 15,  :null => false
    t.integer  "manuscript_id",                       :null => false
    t.integer  "role_id",              :limit => 1,   :null => false
    t.string   "pre_title",            :limit => 10
    t.string   "first_name",           :limit => 35,  :null => false
    t.string   "middle_name",          :limit => 35
    t.string   "last_name",            :limit => 35,  :null => false
    t.string   "degree1",              :limit => 8
    t.string   "degree2",              :limit => 8
    t.string   "degree3",              :limit => 8
    t.string   "employer",             :limit => 80,  :null => false
    t.string   "position_title",       :limit => 50,  :null => false
    t.string   "address_1",            :limit => 64,  :null => false
    t.string   "address_2",            :limit => 64
    t.string   "city",                 :limit => 32,  :null => false
    t.integer  "state_province_id",                   :null => false
    t.string   "zip_postalcode",       :limit => 15,  :null => false
    t.integer  "country_id",                          :null => false
    t.string   "phone",                :limit => 10,  :null => false
    t.string   "phone_fax",            :limit => 10,  :null => false
    t.string   "url",                  :limit => 100
    t.string   "email",                :limit => 128, :null => false
  end

  add_index "authors", ["author_id"], :name => "authors_author_id_idx"
  add_index "authors", ["country_id"], :name => "authors_country_id_idx"
  add_index "authors", ["manuscript_id"], :name => "authors_manuscript_id_idx"
  add_index "authors", ["role_id"], :name => "authors_role_id_idx"
  add_index "authors", ["state_province_id"], :name => "authors_state_province_id_idx"
  add_index "authors", ["unique_email_link_id"], :name => "authors_unique_email_link_id_idx"
  add_index "authors", ["unique_email_link_id"], :name => "unique_email_link_id", :unique => true

  create_table "boilerplate_text", :primary_key => "boilerplate_text_id", :force => true do |t|
    t.integer "active_status_id",       :limit => 1,  :null => false
    t.string  "bp_type",                :limit => 20
    t.string  "boilerplate_merge_code", :limit => 15
    t.string  "title",                  :limit => 65
    t.text    "description",                          :null => false
  end

  create_table "cadmus_submission_logs", :force => true do |t|
    t.integer  "article_submission_id"
    t.boolean  "successful"
    t.string   "file_name"
    t.string   "failure_reason"
    t.text     "stack_trace"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cc_transactions", :force => true do |t|
    t.integer  "charge_id",                                        :null => false
    t.float    "amount",                                           :null => false
    t.string   "state"
    t.string   "authorization"
    t.string   "avs_result"
    t.string   "cvv_result"
    t.string   "message",       :limit => 1027
    t.string   "params",        :limit => 1027
    t.string   "response",      :limit => 1027
    t.boolean  "fraud_review",                  :default => false, :null => false
    t.boolean  "success",                       :default => false, :null => false
    t.boolean  "test",                          :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "charge_types", :force => true do |t|
    t.string "code",        :null => false
    t.string "description", :null => false
    t.float  "amount",      :null => false
  end

  create_table "charges", :force => true do |t|
    t.integer  "article_submission_id",                  :null => false
    t.integer  "charge_type_id",                         :null => false
    t.float    "amount",                :default => 0.0, :null => false
    t.date     "date_due",                               :null => false
    t.string   "state"
    t.datetime "processed"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "charge_pdf_id"
  end

  create_table "cme_users", :primary_key => "cme_user_id", :force => true do |t|
    t.datetime "create_date"
    t.integer  "create_by_id"
    t.string   "create_by_ip",                  :limit => 39
    t.datetime "mod_date"
    t.integer  "mod_by_id"
    t.string   "mod_by_ip",                     :limit => 39
    t.string   "member_no",                     :limit => 15,  :null => false
    t.string   "subscr_type",                   :limit => 12
    t.string   "first_name",                    :limit => 50,  :null => false
    t.string   "last_name",                     :limit => 50,  :null => false
    t.string   "inst_name",                     :limit => 100
    t.string   "email",                         :limit => 80,  :null => false
    t.string   "user_type",                     :limit => 12
    t.string   "user_name",                     :limit => 150, :null => false
    t.datetime "activation_date"
    t.string   "region",                        :limit => 20
    t.string   "address_1"
    t.string   "address2",                      :limit => 25
    t.string   "phone",                         :limit => 25
    t.string   "fax",                           :limit => 25
    t.string   "country",                       :limit => 45
    t.string   "city",                          :limit => 25
    t.string   "state_province",                :limit => 30
    t.string   "zip_postal",                    :limit => 15
    t.string   "title",                         :limit => 5
    t.string   "affiliation",                   :limit => 80
    t.string   "d101_professional_role",        :limit => 65
    t.string   "d102_professional_role_other",  :limit => 80
    t.string   "d103_primary_specialty",        :limit => 80
    t.string   "d104_primary_specialty_other",  :limit => 80
    t.string   "d105_gender",                   :limit => 10
    t.string   "d106_med_school",               :limit => 100
    t.string   "d107_med_school_other",         :limit => 80
    t.string   "d108_year_of_graduation",       :limit => 6
    t.string   "d109_degree",                   :limit => 50
    t.string   "d110_degree_other",             :limit => 80
    t.string   "d111_medical_education_number", :limit => 80
    t.string   "d112_license_number",           :limit => 80
    t.string   "d113_state_issued",             :limit => 30
  end

  add_index "cme_users", ["cme_user_id"], :name => "cme_users_cme_user_id_idx"
  add_index "cme_users", ["country"], :name => "cme_users_country_idx"
  add_index "cme_users", ["d101_professional_role"], :name => "cme_users_d101_professional_role_idx"
  add_index "cme_users", ["member_no"], :name => "cme_users_member_no_idx"
  add_index "cme_users", ["member_no"], :name => "member_no", :unique => true
  add_index "cme_users", ["user_name"], :name => "user_name", :unique => true

  create_table "cmeuser_to_course", :primary_key => "cmeuser_to_course_id", :force => true do |t|
    t.integer  "course_id",                          :null => false
    t.string   "hw_membership_no",     :limit => 15, :null => false
    t.string   "hw_course_id",         :limit => 35, :null => false
    t.string   "how_taken",            :limit => 15
    t.string   "status",               :limit => 35
    t.datetime "last_updated"
    t.integer  "credit_cat"
    t.integer  "hours_credits_earned"
  end

  add_index "cmeuser_to_course", ["course_id"], :name => "cmeuser_to_course_course_id_idx"
  add_index "cmeuser_to_course", ["hw_course_id"], :name => "cmeuser_to_course_hw_course_id_idx"
  add_index "cmeuser_to_course", ["hw_membership_no"], :name => "cmeuser_to_course_hw_membership_no_idx"

  create_table "coi", :primary_key => "coi_id", :force => true do |t|
    t.datetime "create_date"
    t.integer  "create_by_id"
    t.string   "create_by_ip",             :limit => 39
    t.datetime "mod_date"
    t.integer  "mod_by_id"
    t.string   "mod_by_ip",                :limit => 39
    t.string   "stdalone_mnscrpt_title",   :limit => 750, :null => false
    t.integer  "author_id"
    t.string   "stdalone_disclosure_name", :limit => 35
    t.integer  "coi_role_id",              :limit => 1,   :null => false
    t.string   "reason_emplymnt",          :limit => 100
    t.string   "reason_ip",                :limit => 100
    t.string   "reason_cnsltnt",           :limit => 100
    t.string   "reason_honoraria",         :limit => 100
    t.string   "reason_research",          :limit => 100
    t.string   "reason_ownership",         :limit => 100
    t.string   "reason_expert",            :limit => 100
    t.string   "reason_other",             :limit => 100
    t.boolean  "no_conflicts",                            :null => false
    t.boolean  "unbiased",                                :null => false
  end

  add_index "coi", ["author_id"], :name => "coi_author_id_idx"
  add_index "coi", ["coi_id"], :name => "coi_id_idx"
  add_index "coi", ["coi_role_id"], :name => "coi_role_id_idx"

  create_table "coi_forms", :force => true do |t|
    t.datetime "create_date"
    t.integer  "create_by_id"
    t.string   "create_by_ip",                   :limit => 39
    t.datetime "mod_date"
    t.integer  "mod_by_id"
    t.string   "mod_by_ip",                      :limit => 39
    t.integer  "version",                                      :default => 0, :null => false
    t.integer  "author_id"
    t.boolean  "employment"
    t.string   "ip_details"
    t.string   "consultant_details"
    t.string   "honoraria_details"
    t.string   "research_details"
    t.string   "ownership_details"
    t.string   "expert_details"
    t.string   "other_details"
    t.string   "alternative_use_details"
    t.boolean  "conflicts"
    t.boolean  "unbiased"
    t.string   "token"
    t.datetime "committed"
    t.integer  "contribution_id"
    t.integer  "user_id"
    t.string   "type"
    t.string   "employment_details"
    t.boolean  "alternative_use"
    t.boolean  "honoraria"
    t.boolean  "ip"
    t.boolean  "consultant"
    t.boolean  "research"
    t.boolean  "expert"
    t.boolean  "other"
    t.boolean  "ownership"
    t.string   "sig_completed_by"
    t.string   "sig_entity"
    t.string   "sig_entity_title"
    t.datetime "sig_time"
    t.boolean  "sig_assent"
    t.text     "roles_list"
    t.integer  "article_submission_reviewer_id"
    t.boolean  "employment_comp"
    t.boolean  "honoraria_comp"
    t.boolean  "consultant_comp"
    t.boolean  "research_comp"
    t.boolean  "expert_comp"
    t.boolean  "other_comp"
    t.boolean  "ownership_comp"
    t.boolean  "ip_comp"
    t.boolean  "employment_uncomp"
    t.boolean  "honoraria_uncomp"
    t.boolean  "consultant_uncomp"
    t.boolean  "research_uncomp"
    t.boolean  "expert_uncomp"
    t.boolean  "other_uncomp"
    t.boolean  "ownership_uncomp"
    t.boolean  "ip_uncomp"
  end

  add_index "coi_forms", ["author_id"], :name => "coi_author_id_idx"
  add_index "coi_forms", ["user_id"], :name => "user_id"

  create_table "configurations", :force => true do |t|
    t.string   "name"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contribution_types", :force => true do |t|
    t.integer "display_order", :default => 0,     :null => false
    t.string  "title",                            :null => false
    t.boolean "public",        :default => false, :null => false
  end

  add_index "contribution_types", ["public"], :name => "public"

  create_table "contribution_types_contributions", :id => false, :force => true do |t|
    t.integer "contribution_type_id", :null => false
    t.integer "contribution_id",      :null => false
  end

  create_table "contributions", :force => true do |t|
    t.integer  "role_id",                                          :null => false
    t.integer  "article_submission_id",                            :null => false
    t.integer  "user_id",                                          :null => false
    t.integer  "fy_served_flag"
    t.datetime "create_date"
    t.integer  "create_by_id"
    t.string   "create_by_ip",                      :limit => 39
    t.datetime "mod_date"
    t.integer  "mod_by_id"
    t.string   "mod_by_ip",                         :limit => 39
    t.boolean  "emailed_coi_link"
    t.string   "coi_token"
    t.string   "responsibilities_sig_completed_by"
    t.string   "responsibilities_sig_entity"
    t.string   "responsibilities_sig_entity_title"
    t.datetime "responsibilities_sig_time"
    t.boolean  "responsibilities_sig_assent"
    t.string   "copyright_sig_completed_by"
    t.string   "copyright_sig_entity"
    t.string   "copyright_sig_entity_title"
    t.datetime "copyright_sig_time"
    t.boolean  "copyright_sig_assent"
    t.boolean  "assisted"
    t.string   "assisted_details"
    t.boolean  "agree_contents"
    t.string   "agree_contents_details"
    t.boolean  "sole_submission"
    t.string   "sole_submission_details"
    t.boolean  "received_payment"
    t.string   "received_payment_details"
    t.boolean  "tobacco"
    t.string   "tobacco_details"
    t.boolean  "published_elsewhere"
    t.boolean  "dna_research"
    t.boolean  "human_experiment"
    t.boolean  "clintrials"
    t.boolean  "consort_guidelines"
    t.boolean  "proprietary_guidelines"
    t.string   "proprietary_guidelines_details"
    t.boolean  "agree_policies"
    t.string   "agree_policies_details"
    t.integer  "responsibilities_pdf_id"
    t.integer  "copyright_pdf_id"
    t.boolean  "arynq1"
    t.string   "arynq1_details",                    :limit => 100
    t.boolean  "ctynq1"
    t.string   "ctynq1_details",                    :limit => 100
    t.boolean  "arynq2"
    t.string   "arynq2_details",                    :limit => 100
    t.boolean  "ctynq2"
    t.string   "ctynq2_details",                    :limit => 100
    t.boolean  "arynq3"
    t.string   "arynq3_details",                    :limit => 100
    t.boolean  "ctynq3"
    t.string   "ctynq3_details",                    :limit => 100
    t.boolean  "arynq4"
    t.string   "arynq4_details",                    :limit => 100
    t.boolean  "ctynq4"
    t.string   "ctynq4_details",                    :limit => 100
    t.boolean  "arynq5"
    t.string   "arynq5_details",                    :limit => 100
    t.boolean  "ctynq5"
    t.string   "ctynq5_details",                    :limit => 100
    t.boolean  "arynq6"
    t.string   "arynq6_details",                    :limit => 100
    t.boolean  "ctynq6"
    t.string   "ctynq6_details",                    :limit => 100
    t.boolean  "arynq7"
    t.string   "arynq7_details",                    :limit => 100
    t.boolean  "ctynq7"
    t.string   "ctynq7_details",                    :limit => 100
    t.boolean  "arynq8"
    t.string   "arynq8_details",                    :limit => 100
    t.boolean  "ctynq8"
    t.string   "ctynq8_details",                    :limit => 100
    t.boolean  "arynq9"
    t.string   "arynq9_details",                    :limit => 100
    t.boolean  "ctynq9"
    t.string   "ctynq9_details",                    :limit => 100
    t.boolean  "arynq10"
    t.string   "arynq10_details",                   :limit => 100
    t.boolean  "ctynq10"
    t.string   "ctynq10_details",                   :limit => 100
    t.boolean  "first_author"
  end

  add_index "contributions", ["article_submission_id"], :name => "article_submission_id"
  add_index "contributions", ["role_id", "article_submission_id"], :name => "role_id"
  add_index "contributions", ["role_id"], :name => "role_id_2"
  add_index "contributions", ["user_id"], :name => "user_id"

  create_table "countries", :primary_key => "country_id", :force => true do |t|
    t.string  "country_name",   :limit => 64, :null => false
    t.string  "country_3_code", :limit => 3
    t.string  "country_2_code", :limit => 2
    t.integer "display_order"
  end

  add_index "countries", ["country_id"], :name => "countries_country_id_idx"

  create_table "course_sections", :primary_key => "course_section_id", :force => true do |t|
    t.string  "hw_section_id",       :limit => 35
    t.integer "active_status_id",    :limit => 1,   :default => 2,  :null => false
    t.integer "parent_id",                          :default => 0,  :null => false
    t.integer "display_order"
    t.string  "course_section_name", :limit => 125, :default => "", :null => false
  end

  add_index "course_sections", ["active_status_id"], :name => "course_sections_active_status_id_idx"
  add_index "course_sections", ["hw_section_id"], :name => "course_sections_hw_section_id_idx"

  create_table "course_to_article", :primary_key => "course_to_article_id", :force => true do |t|
    t.integer "course_id",                   :null => false
    t.integer "article_id",                  :null => false
    t.string  "hw_course_id",  :limit => 35
    t.string  "hw_article_id", :limit => 40
  end

  add_index "course_to_article", ["article_id"], :name => "course_to_article_article_id_idx"
  add_index "course_to_article", ["course_id"], :name => "course_to_article_course_id_idx"
  add_index "course_to_article", ["hw_article_id"], :name => "course_to_article_hw_article_id_idx"
  add_index "course_to_article", ["hw_course_id"], :name => "course_to_article_hw_course_id_idx"

  create_table "course_to_coursesection", :primary_key => "course_to_coursesections_id", :force => true do |t|
    t.integer "course_section_id",               :null => false
    t.string  "hw_section_id",     :limit => 35
    t.integer "course_id",                       :null => false
    t.string  "hw_course_id",      :limit => 35
    t.string  "canonical",         :limit => 5
  end

  add_index "course_to_coursesection", ["course_id"], :name => "course_to_coursesection_course_id_idx"
  add_index "course_to_coursesection", ["course_section_id"], :name => "course_to_coursesection_course_section_id_idx"
  add_index "course_to_coursesection", ["hw_course_id"], :name => "course_to_coursesection_hw_course_id_idx"
  add_index "course_to_coursesection", ["hw_section_id"], :name => "course_to_coursesection_hw_section_id_idx"

  create_table "courses", :primary_key => "course_id", :force => true do |t|
    t.string   "hw_course_id",     :limit => 35
    t.integer  "active_status_id", :limit => 1,   :default => 2, :null => false
    t.datetime "create_date"
    t.integer  "create_by_id"
    t.string   "create_by_ip",     :limit => 39
    t.datetime "mod_date"
    t.integer  "mod_by_id"
    t.string   "mod_by_ip",        :limit => 39
    t.string   "title",            :limit => 750,                :null => false
    t.text     "abstract"
    t.date     "publication_date"
    t.date     "expiration_date"
    t.date     "reviewed_date"
    t.integer  "in_production",    :limit => 1,                  :null => false
    t.integer  "is_linkable",      :limit => 1,                  :null => false
    t.integer  "is_expired",       :limit => 1,                  :null => false
  end

  add_index "courses", ["active_status_id"], :name => "courses_active_status_id_idx"
  add_index "courses", ["hw_course_id"], :name => "courses_hw_course_id_idx"
  add_index "courses", ["publication_date"], :name => "courses_publication_date_idx"

  create_table "cover_letters", :force => true do |t|
    t.string   "file_content_type"
    t.string   "file"
    t.integer  "version",               :default => 0, :null => false
    t.integer  "article_submission_id",                :null => false
    t.integer  "file_size"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "credit_cards", :force => true do |t|
    t.integer  "user_id",              :null => false
    t.string   "customer_profile_id"
    t.string   "payment_profile_id"
    t.string   "merchant_customer_id"
    t.binary   "encrypted_name"
    t.binary   "encrypted_num"
    t.binary   "encrypted_exp_mo"
    t.binary   "encrypted_exp_yr"
    t.binary   "encrypted_zip"
    t.binary   "encrypted_cvv"
    t.string   "email"
    t.string   "num_last_four"
    t.string   "cc_type"
    t.binary   "encrypted_key"
    t.binary   "encrypted_iv"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "degrees", :force => true do |t|
    t.string   "name",                                      :null => false
    t.integer  "public",                     :default => 0, :null => false
    t.datetime "create_date"
    t.integer  "create_by_id"
    t.string   "create_by_ip", :limit => 39
    t.datetime "mod_date"
    t.integer  "mod_by_id"
    t.string   "mod_by_ip",    :limit => 39
    t.integer  "position"
  end

  create_table "dropdowns", :primary_key => "dropdown_id", :force => true do |t|
    t.string  "dropdown_kind", :limit => 12, :null => false
    t.integer "dropdown_key",                :null => false
    t.string  "dropdown_lbl",  :limit => 80, :null => false
  end

  create_table "editor_to_article_section", :primary_key => "editor_to_article_section_id", :force => true do |t|
    t.integer "display_order"
    t.integer "user_id",                            :null => false
    t.integer "article_section_id",                 :null => false
    t.date    "date_joined",                        :null => false
    t.string  "editor_active_status", :limit => 20, :null => false
  end

  create_table "email_logs", :force => true do |t|
    t.text     "content"
    t.string   "sender"
    t.string   "recipient"
    t.text     "subject"
    t.integer  "recipient_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "email_loggable_id"
    t.string   "email_loggable_type"
    t.string   "category"
  end

  create_table "entities", :force => true do |t|
    t.string "entity_type"
  end

  create_table "entity_statuses", :force => true do |t|
    t.integer  "status_id"
    t.integer  "trackable_id"
    t.string   "trackable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "evals", :primary_key => "eval_id", :force => true do |t|
    t.integer  "course_id",                                     :null => false
    t.datetime "create_date"
    t.integer  "create_by_id"
    t.string   "create_by_ip",     :limit => 39
    t.datetime "mod_date"
    t.integer  "mod_by_id"
    t.string   "mod_by_ip",        :limit => 39
    t.string   "hw_course_id",     :limit => 35
    t.string   "hw_eval_id",       :limit => 35
    t.integer  "active_status_id", :limit => 1,  :default => 2, :null => false
    t.string   "title",                                         :null => false
    t.integer  "version_num",      :limit => 1,  :default => 1, :null => false
    t.boolean  "eval_pubstatus"
    t.datetime "eval_pub_date"
    t.string   "scoring_style",    :limit => 35
    t.integer  "sort_num",         :limit => 1
    t.integer  "num_questions",    :limit => 1
  end

  add_index "evals", ["active_status_id"], :name => "evals_active_status_id_idx"
  add_index "evals", ["course_id"], :name => "evals_course_id_idx"
  add_index "evals", ["hw_course_id"], :name => "evals_hw_course_id_idx"
  add_index "evals", ["hw_eval_id"], :name => "evals_hw_eval_id_idx"

  create_table "fiscal_years", :primary_key => "fiscal_year_id", :force => true do |t|
    t.string "fiscal_year_name", :limit => 10, :null => false
  end

  create_table "forms_cois", :primary_key => "forms_coi_id", :force => true do |t|
    t.integer  "forms_manuscript_id",                :null => false
    t.datetime "create_date"
    t.integer  "create_by_id"
    t.string   "create_by_ip",        :limit => 39
    t.datetime "mod_date"
    t.integer  "mod_by_id"
    t.string   "mod_by_ip",           :limit => 39
    t.string   "name",                :limit => 200, :null => false
    t.string   "token",               :limit => 63,  :null => false
    t.string   "email",               :limit => 128, :null => false
    t.integer  "role_id",                            :null => false
    t.datetime "coi_completed_date"
  end

  add_index "forms_cois", ["forms_coi_id"], :name => "coi_id_idx"

  create_table "forms_manuscripts", :primary_key => "forms_manuscript_id", :force => true do |t|
    t.datetime "create_date"
    t.integer  "create_by_id"
    t.string   "create_by_ip",          :limit => 39
    t.datetime "mod_date"
    t.integer  "mod_by_id"
    t.string   "mod_by_ip",             :limit => 39
    t.string   "corr_auth_pre_title",   :limit => 10,  :default => ""
    t.string   "corr_auth_first_name",  :limit => 35,  :default => "", :null => false
    t.string   "corr_auth_middle_name", :limit => 35,  :default => ""
    t.string   "corr_auth_last_name",   :limit => 35,  :default => "", :null => false
    t.string   "title",                 :limit => 750,                 :null => false
    t.string   "email",                 :limit => 128,                 :null => false
    t.integer  "num_authors",                                          :null => false
  end

  add_index "forms_manuscripts", ["forms_manuscript_id"], :name => "manuscript_id_idx"

  create_table "learning_objectives", :primary_key => "learning_objective_id", :force => true do |t|
    t.integer "course_id",     :null => false
    t.integer "display_order"
    t.text    "description"
  end

  add_index "learning_objectives", ["course_id"], :name => "course_id"

  create_table "manuscript_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "order_num"
    t.boolean  "enabled"
  end

  create_table "manuscripts", :force => true do |t|
    t.string   "file_content_type"
    t.string   "file"
    t.integer  "version",               :default => 0, :null => false
    t.integer  "article_submission_id",                :null => false
    t.integer  "file_size"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "pfile_file_name"
    t.string   "pfile_content_type"
    t.integer  "pfile_file_size"
  end

  create_table "pages", :force => true do |t|
    t.string "url", :null => false
  end

  create_table "pdfs", :force => true do |t|
    t.integer  "user_id",     :null => false
    t.string   "file",        :null => false
    t.string   "form_type",   :null => false
    t.string   "output"
    t.integer  "size"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "coi_form_id"
  end

  create_table "permissions", :force => true do |t|
    t.string   "file_content_type"
    t.string   "file"
    t.integer  "version",               :default => 0, :null => false
    t.integer  "article_submission_id",                :null => false
    t.integer  "file_size"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "question_types", :primary_key => "question_type_id", :force => true do |t|
    t.string "question_type", :limit => 20, :null => false
  end

  add_index "question_types", ["question_type"], :name => "question_type", :unique => true

  create_table "questions", :primary_key => "question_id", :force => true do |t|
    t.string  "quiz_or_eval",     :limit => 4
    t.integer "course_id",                                       :null => false
    t.integer "quizoreval_id",                                   :null => false
    t.string  "hw_course_id",     :limit => 35
    t.string  "hw_quizoreval_id", :limit => 35
    t.integer "version_num",      :limit => 1,    :default => 1
    t.integer "question_type_id", :limit => 1,                   :null => false
    t.integer "sort_num",         :limit => 1
    t.string  "hw_question_id",   :limit => 10
    t.string  "question_text",    :limit => 1024,                :null => false
    t.text    "hint"
  end

  add_index "questions", ["hw_course_id"], :name => "questions_hw_course_id_idx"
  add_index "questions", ["hw_question_id"], :name => "questions_hw_question_id_idx"
  add_index "questions", ["question_type_id"], :name => "questions_question_type_id_idx"
  add_index "questions", ["quiz_or_eval"], :name => "questions_quiz_or_eval_idx"
  add_index "questions", ["quizoreval_id"], :name => "questions_quizoreval_id_idx"

  create_table "quizzes", :primary_key => "quiz_id", :force => true do |t|
    t.datetime "create_date"
    t.integer  "create_by_id"
    t.string   "create_by_ip",     :limit => 39
    t.datetime "mod_date"
    t.integer  "mod_by_id"
    t.string   "mod_by_ip",        :limit => 39
    t.integer  "course_id",                                     :null => false
    t.string   "hw_course_id",     :limit => 35
    t.string   "hw_quiz_id",       :limit => 35
    t.integer  "active_status_id", :limit => 1,  :default => 2, :null => false
    t.text     "title",                                         :null => false
    t.integer  "version_num",      :limit => 1,  :default => 1, :null => false
    t.boolean  "quiz_pubstatus"
    t.datetime "quiz_pub_date"
    t.string   "scoring_style",    :limit => 35
    t.integer  "threshold",        :limit => 1
    t.integer  "sort_num",         :limit => 1
    t.integer  "num_questions",    :limit => 1
  end

  add_index "quizzes", ["active_status_id"], :name => "quizzes_active_status_id_idx"
  add_index "quizzes", ["course_id"], :name => "quizzes_course_id_idx"
  add_index "quizzes", ["hw_course_id"], :name => "quizzes_hw_course_id_idx"
  add_index "quizzes", ["hw_quiz_id"], :name => "quizzes_hw_quiz_id_idx"

  create_table "reminder_templates", :primary_key => "reminder_template_id", :force => true do |t|
    t.string "template_name", :limit => 25, :null => false
    t.text   "template_desc",               :null => false
  end

  create_table "reviewer_comment_revisions", :force => true do |t|
    t.text     "remarks_to_editor"
    t.text     "comments_to_author"
    t.integer  "reviewer_comment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reviewer_comments", :force => true do |t|
    t.string   "apropriateness"
    t.string   "bridges_gap"
    t.string   "clinical_relevance"
    t.string   "scientific_quality"
    t.string   "positive_impact"
    t.string   "usefullness_to_practioner"
    t.string   "clarity_of_writing"
    t.boolean  "study_conforms"
    t.boolean  "evidence_based"
    t.boolean  "fair_topic"
    t.boolean  "stats_need_validation"
    t.boolean  "appropriate_for_cme"
    t.text     "question_comments"
    t.boolean  "accept_with_revision"
    t.boolean  "accept_with_revisions_text"
    t.boolean  "accept_with_revisions_figures"
    t.boolean  "accept_with_revisions_grammer"
    t.boolean  "get_further_info"
    t.boolean  "reject"
    t.boolean  "will_review_revised"
    t.text     "remarks_to_editor"
    t.text     "comments_to_author"
    t.integer  "article_submission_reviewer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "sanitized_remarks_to_editor"
    t.text     "sanitized_comments_to_author"
  end

  create_table "reviewer_subjects", :force => true do |t|
    t.integer "user_id"
    t.integer "article_section_id"
  end

  create_table "reviewer_suggestions", :primary_key => "reviewer_suggestion_id", :force => true do |t|
    t.datetime "create_date"
    t.integer  "create_by_id"
    t.string   "create_by_ip",  :limit => 39
    t.datetime "mod_date"
    t.string   "mod_by_id",     :limit => 39
    t.string   "mod_by_ip",     :limit => 39
    t.integer  "manuscript_id",                :null => false
    t.string   "pre_title",     :limit => 10
    t.string   "first_name",    :limit => 35,  :null => false
    t.string   "middle_name",   :limit => 35
    t.string   "last_name",     :limit => 35,  :null => false
    t.string   "affiliation",   :limit => 80,  :null => false
    t.string   "email",         :limit => 128, :null => false
  end

  add_index "reviewer_suggestions", ["last_name"], :name => "reviewer_suggestions_last_name_idx"
  add_index "reviewer_suggestions", ["manuscript_id"], :name => "reviewer_suggestions_manuscript_id_idx"
  add_index "reviewer_suggestions", ["reviewer_suggestion_id"], :name => "reviewer_suggestions_reviewer_suggestion_id_idx"

  create_table "reviewing_instances", :id => false, :force => true do |t|
    t.integer "article_submission_id", :null => false
    t.integer "user_id",               :null => false
    t.boolean "approved"
  end

  create_table "roles", :primary_key => "role_id", :force => true do |t|
    t.integer "display_order"
    t.string  "role_title",    :limit => 40,  :null => false
    t.string  "key",           :limit => 128, :null => false
  end

  create_table "section_editor_sections", :force => true do |t|
    t.integer "user_id"
    t.integer "article_section_id"
  end

  create_table "ser_issues", :primary_key => "ser_issue_id", :force => true do |t|
    t.datetime "create_date"
    t.integer  "create_by_id"
    t.string   "create_by_ip",        :limit => 39
    t.datetime "mod_date"
    t.integer  "mod_by_id"
    t.string   "mod_by_ip",           :limit => 39
    t.integer  "active_status_id",    :limit => 1,    :default => 2, :null => false
    t.string   "ser_title",           :limit => 100,                 :null => false
    t.date     "ser_close_date",                                     :null => false
    t.string   "ser_overall_comment", :limit => 3500
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "states_provinces", :primary_key => "state_province_id", :force => true do |t|
    t.integer "country_id",                 :default => 1, :null => false
    t.string  "state_name",   :limit => 64,                :null => false
    t.string  "state_3_code", :limit => 3
    t.string  "state_2_code", :limit => 2,                 :null => false
  end

  add_index "states_provinces", ["country_id"], :name => "country_id"

  create_table "states_provinces_odd", :primary_key => "state_province_id", :force => true do |t|
    t.integer "country_id",                 :default => 1, :null => false
    t.string  "state_name",   :limit => 64,                :null => false
    t.string  "state_3_code", :limit => 3
    t.string  "state_2_code", :limit => 2,                 :null => false
  end

  add_index "states_provinces_odd", ["country_id"], :name => "country_id"

  create_table "statuses", :force => true do |t|
    t.string   "name"
    t.string   "key"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "entity_id"
    t.text     "human_friendly_name"
  end

  create_table "submission_type", :primary_key => "submission_type_id", :force => true do |t|
    t.integer "display_order",                 :null => false
    t.string  "submission_type", :limit => 35, :null => false
  end

  create_table "sys_params", :primary_key => "sys_params_id", :force => true do |t|
    t.integer "lang_id",                              :default => 0,     :null => false
    t.string  "app_name",              :limit => 50,                     :null => false
    t.string  "version",               :limit => 15,  :default => "",    :null => false
    t.date    "sys_last_updated",                                        :null => false
    t.string  "date_format",           :limit => 10,                     :null => false
    t.string  "time_format",           :limit => 10,                     :null => false
    t.string  "home_url",              :limit => 100,                    :null => false
    t.boolean "down_for_maint_flag",                  :default => false, :null => false
    t.boolean "debug_mode",                           :default => false, :null => false
    t.string  "debug_ips",                                               :null => false
    t.integer "default_list_max_rows",                :default => 50,    :null => false
    t.string  "email_server",          :limit => 25,                     :null => false
    t.integer "email_port",                                              :null => false
    t.string  "robot_email_from_addr", :limit => 80,                     :null => false
    t.string  "robot_email_pw",        :limit => 15,                     :null => false
    t.string  "hostname",              :limit => 75,  :default => "",    :null => false
    t.string  "download_dir",                         :default => "",    :null => false
    t.string  "upload_dir",                           :default => "",    :null => false
    t.string  "dir_root",              :limit => 25,  :default => "",    :null => false
    t.string  "dir_fs",                               :default => "",    :null => false
  end

  create_table "updated_manuscripts", :force => true do |t|
    t.integer  "manuscript_id"
    t.integer  "article_submission_id"
    t.string   "file_content_type"
    t.string   "file"
    t.integer  "file_size"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_eval_answers", :primary_key => "user_eval_answers_id", :force => true do |t|
    t.integer "user_eval_result_id",               :null => false
    t.integer "course_id",                         :null => false
    t.integer "quiz_id",                           :null => false
    t.integer "question_id",                       :null => false
    t.integer "answer_choices_id",                 :null => false
    t.string  "hw_membership_no",    :limit => 15, :null => false
    t.string  "hw_course_id",        :limit => 35, :null => false
    t.string  "hw_eval_id",          :limit => 35, :null => false
    t.string  "hw_question_id",      :limit => 10, :null => false
    t.string  "hw_answer_id",        :limit => 10, :null => false
    t.text    "user_answer_text"
  end

  add_index "user_eval_answers", ["answer_choices_id"], :name => "user_eval_answers_answer_choices_id_idx"
  add_index "user_eval_answers", ["hw_membership_no"], :name => "user_eval_answers_hw_membership_no_idx"
  add_index "user_eval_answers", ["question_id"], :name => "user_eval_answers_question_id_idx"
  add_index "user_eval_answers", ["user_eval_result_id"], :name => "user_eval_answers_user_eval_result_id_idx"

  create_table "user_eval_results", :primary_key => "user_eval_result_id", :force => true do |t|
    t.integer  "course_id",                        :null => false
    t.integer  "eval_id",                          :null => false
    t.string   "hw_membership_no",   :limit => 15, :null => false
    t.string   "hw_course_id",       :limit => 35, :null => false
    t.string   "hw_eval_id",         :limit => 35, :null => false
    t.integer  "session_id",                       :null => false
    t.string   "is_current_session", :limit => 5,  :null => false
    t.string   "status",             :limit => 20, :null => false
    t.datetime "submit_date",                      :null => false
  end

  add_index "user_eval_results", ["eval_id"], :name => "user_eval_results_eval_id_idx"
  add_index "user_eval_results", ["hw_eval_id"], :name => "user_eval_results_hw_eval_id_idx"
  add_index "user_eval_results", ["hw_membership_no"], :name => "user_eval_results_hw_membership_no_idx"
  add_index "user_eval_results", ["is_current_session"], :name => "user_eval_results_is_current_session_idx"

  create_table "user_quiz_answers", :primary_key => "user_quiz_answers_id", :force => true do |t|
    t.integer "user_quiz_result_id",               :null => false
    t.integer "course_id",                         :null => false
    t.integer "quiz_id",                           :null => false
    t.integer "question_id",                       :null => false
    t.integer "answer_choices_id",                 :null => false
    t.string  "hw_membership_no",    :limit => 15, :null => false
    t.string  "hw_course_id",        :limit => 35, :null => false
    t.string  "hw_quiz_id",          :limit => 35, :null => false
    t.string  "hw_question_id",      :limit => 10, :null => false
    t.string  "hw_answer_id",        :limit => 10, :null => false
    t.text    "user_answer_text"
  end

  add_index "user_quiz_answers", ["answer_choices_id"], :name => "user_quiz_answers_answer_choices_id_idx"
  add_index "user_quiz_answers", ["hw_membership_no"], :name => "user_quiz_answers_hw_membership_no_idx"
  add_index "user_quiz_answers", ["question_id"], :name => "user_quiz_answers_question_id_idx"
  add_index "user_quiz_answers", ["user_quiz_result_id"], :name => "user_quiz_answers_user_quiz_result_id_idx"

  create_table "user_quiz_results", :primary_key => "user_quiz_result_id", :force => true do |t|
    t.integer  "course_id",                        :null => false
    t.integer  "quiz_id",                          :null => false
    t.string   "hw_membership_no",   :limit => 15, :null => false
    t.string   "hw_course_id",       :limit => 35, :null => false
    t.string   "hw_quiz_id",         :limit => 35, :null => false
    t.integer  "session_id",                       :null => false
    t.string   "is_current_session", :limit => 5,  :null => false
    t.boolean  "passed_quiz",                      :null => false
    t.float    "score",                            :null => false
    t.float    "points",                           :null => false
    t.string   "status",             :limit => 20, :null => false
    t.datetime "submit_date",                      :null => false
  end

  add_index "user_quiz_results", ["hw_membership_no"], :name => "user_quiz_results_hw_membership_no_idx"
  add_index "user_quiz_results", ["hw_quiz_id"], :name => "user_quiz_results_hw_quiz_id_idx"
  add_index "user_quiz_results", ["is_current_session"], :name => "user_quiz_results_is_current_session_idx"
  add_index "user_quiz_results", ["passed_quiz"], :name => "user_quiz_results_passed_quiz_idx"
  add_index "user_quiz_results", ["quiz_id"], :name => "user_quiz_results_quiz_id_idx"

  create_table "user_security_levels", :primary_key => "user_security_level", :force => true do |t|
    t.integer "security_level",     :limit => 1,  :null => false
    t.string  "security_level_lbl", :limit => 20, :null => false
  end

  add_index "user_security_levels", ["security_level_lbl"], :name => "security_level_lbl", :unique => true

  create_table "user_templates", :force => true do |t|
    t.string  "title",                             :null => false
    t.string  "alias"
    t.text    "body",        :limit => 2147483647
    t.text    "description", :limit => 2147483647
    t.boolean "to_html"
    t.text    "body_html",   :limit => 2147483647
  end

  add_index "user_templates", ["alias"], :name => "alias"

  create_table "user_to_role", :primary_key => "user_to_role_id", :force => true do |t|
    t.integer "display_order"
    t.integer "user_id",                                     :null => false
    t.integer "role_id",        :limit => 1,                 :null => false
    t.integer "article_id"
    t.string  "credentials",                 :default => ""
    t.integer "fiscal_year_id"
  end

  add_index "user_to_role", ["article_id"], :name => "article_id"
  add_index "user_to_role", ["role_id"], :name => "role_id"
  add_index "user_to_role", ["user_id"], :name => "user_id"

  create_table "users", :primary_key => "user_id", :force => true do |t|
    t.datetime "create_date"
    t.integer  "create_by_id"
    t.string   "create_by_ip",              :limit => 39,                     :null => false
    t.datetime "mod_date"
    t.string   "mod_by_id",                 :limit => 39
    t.string   "mod_by_ip",                 :limit => 39
    t.integer  "active_status_id",          :limit => 1,                      :null => false
    t.integer  "display_order"
    t.string   "username",                  :limit => 128,                    :null => false
    t.string   "password",                  :limit => 128,                    :null => false
    t.boolean  "temp_password_flag",                       :default => false
    t.integer  "security_level",            :limit => 1,                      :null => false
    t.string   "pre_title",                 :limit => 10
    t.string   "first_name",                :limit => 35
    t.string   "middle_name",               :limit => 35
    t.string   "last_name",                 :limit => 35
    t.string   "email",                     :limit => 128
    t.boolean  "ok_to_email",                              :default => true,  :null => false
    t.datetime "last_login"
    t.string   "last_login_ip",             :limit => 16
    t.integer  "login_count",                              :default => 0
    t.datetime "last_login_attempt"
    t.string   "last_login_ip_attempt",     :limit => 16
    t.integer  "failed_login_count"
    t.integer  "lost_password_count"
    t.string   "employer",                  :limit => 80
    t.string   "department",                :limit => 80
    t.string   "position_title",            :limit => 50
    t.string   "address_1",                 :limit => 64
    t.string   "address_2",                 :limit => 64
    t.string   "city",                      :limit => 32
    t.integer  "state_province_id"
    t.string   "zip_postalcode",            :limit => 15
    t.integer  "country_id"
    t.string   "phone_preferred",           :limit => 20
    t.string   "phone_work",                :limit => 15
    t.string   "phone_work_ext",            :limit => 6
    t.string   "phone_cell",                :limit => 15
    t.string   "phone_fax",                 :limit => 15
    t.string   "assistant_name",            :limit => 60
    t.string   "assistant_email",           :limit => 80
    t.string   "assistant_phone",           :limit => 15
    t.boolean  "cc_emails_to_asst"
    t.string   "notes"
    t.string   "degree1"
    t.string   "degree2"
    t.string   "degree3"
    t.integer  "page_id"
    t.string   "degree1_other"
    t.string   "degree2_other"
    t.string   "degree3_other"
    t.string   "url"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "secret_token"
    t.boolean  "auto_created"
    t.integer  "user_can_edit"
    t.boolean  "supress_email"
    t.boolean  "disabled"
  end

  add_index "users", ["active_status_id"], :name => "users_active_status_id_idx"
  add_index "users", ["country_id"], :name => "users_country_id_idx"
  add_index "users", ["email"], :name => "email"
  add_index "users", ["last_name"], :name => "users_last_name_idx"
  add_index "users", ["notes"], :name => "users_notes_idx"
  add_index "users", ["password"], :name => "users_password_idx"
  add_index "users", ["security_level"], :name => "users_security_level_idx"
  add_index "users", ["state_province_id"], :name => "users_state_province_id_idx"
  add_index "users", ["username"], :name => "username", :unique => true
  add_index "users", ["username"], :name => "users_username_idx"

  create_table "users_odd", :primary_key => "user_id", :force => true do |t|
    t.datetime "create_date"
    t.integer  "create_by_id"
    t.string   "create_by_ip",              :limit => 39,                     :null => false
    t.datetime "mod_date"
    t.string   "mod_by_id",                 :limit => 39
    t.string   "mod_by_ip",                 :limit => 39
    t.integer  "active_status_id",          :limit => 1,                      :null => false
    t.integer  "display_order"
    t.string   "username",                  :limit => 32,                     :null => false
    t.string   "password",                  :limit => 128,                    :null => false
    t.boolean  "temp_password_flag",                       :default => false
    t.integer  "security_level",            :limit => 1,                      :null => false
    t.string   "pre_title",                 :limit => 10
    t.string   "first_name",                :limit => 35
    t.string   "middle_name",               :limit => 35
    t.string   "last_name",                 :limit => 35
    t.string   "email",                     :limit => 128
    t.boolean  "ok_to_email",                              :default => true,  :null => false
    t.datetime "last_login"
    t.string   "last_login_ip",             :limit => 16
    t.integer  "login_count",                              :default => 0
    t.datetime "last_login_attempt"
    t.string   "last_login_ip_attempt",     :limit => 16
    t.integer  "failed_login_count"
    t.integer  "lost_password_count"
    t.string   "employer",                  :limit => 80
    t.string   "department",                :limit => 80
    t.string   "position_title",            :limit => 50
    t.string   "address_1",                 :limit => 64
    t.string   "address_2",                 :limit => 64
    t.string   "city",                      :limit => 32
    t.integer  "state_province_id"
    t.string   "zip_postalcode",            :limit => 15
    t.integer  "country_id"
    t.string   "phone_preferred",           :limit => 20
    t.string   "phone_work",                :limit => 15
    t.string   "phone_work_ext",            :limit => 6
    t.string   "phone_cell",                :limit => 15
    t.string   "phone_fax",                 :limit => 15
    t.string   "assistant_name",            :limit => 60
    t.string   "assistant_email",           :limit => 80
    t.string   "assistant_phone",           :limit => 15
    t.boolean  "cc_emails_to_asst"
    t.string   "notes"
    t.string   "degree1"
    t.string   "degree2"
    t.string   "degree3"
    t.integer  "page_id"
    t.string   "degree1_other"
    t.string   "degree2_other"
    t.string   "degree3_other"
    t.string   "url"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "secret_token"
    t.boolean  "auto_created"
    t.integer  "user_can_edit"
  end

  add_index "users_odd", ["active_status_id"], :name => "users_active_status_id_idx"
  add_index "users_odd", ["country_id"], :name => "users_country_id_idx"
  add_index "users_odd", ["email"], :name => "email"
  add_index "users_odd", ["last_name"], :name => "users_last_name_idx"
  add_index "users_odd", ["notes"], :name => "users_notes_idx"
  add_index "users_odd", ["password"], :name => "users_password_idx"
  add_index "users_odd", ["security_level"], :name => "users_security_level_idx"
  add_index "users_odd", ["state_province_id"], :name => "users_state_province_id_idx"
  add_index "users_odd", ["username"], :name => "username", :unique => true
  add_index "users_odd", ["username"], :name => "users_username_idx"

end
