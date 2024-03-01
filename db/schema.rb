# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2024_03_01_163604) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "address_details", force: :cascade do |t|
    t.text "current_address_1"
    t.text "current_address_2"
    t.string "current_address_area"
    t.string "current_address_country"
    t.string "current_address_state"
    t.string "current_address_city"
    t.string "current_address_pincode"
    t.text "permanent_address_1"
    t.text "permanent_address_2"
    t.string "permanent_address_area"
    t.string "permanent_address_country"
    t.string "permanent_address_city"
    t.string "permanent_address_pincode"
    t.bigint "student_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["student_id"], name: "index_address_details_on_student_id"
  end

  create_table "branches", force: :cascade do |t|
    t.bigint "course_id", null: false
    t.string "name"
    t.string "code"
    t.integer "number_of_semesters", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_branches_on_course_id"
  end

  create_table "contact_details", force: :cascade do |t|
    t.string "mobile_number"
    t.string "emergency_mobile_number"
    t.string "residence_phone_number"
    t.string "personal_email_address"
    t.string "university_email_address"
    t.string "fathers_mobile_number"
    t.string "fathers_personal_email"
    t.string "mothers_mobile_number"
    t.string "mothers_personal_email"
    t.bigint "student_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["student_id"], name: "index_contact_details_on_student_id"
  end

  create_table "courses", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "divisions", force: :cascade do |t|
    t.integer "number"
    t.string "name"
    t.bigint "semester_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["semester_id"], name: "index_divisions_on_semester_id"
  end

  create_table "guardian_details", force: :cascade do |t|
    t.string "name"
    t.string "relation"
    t.string "mobile_number"
    t.string "personal_email"
    t.string "professional_email"
    t.text "address_1"
    t.text "address_2"
    t.string "area"
    t.string "country"
    t.string "state"
    t.string "city"
    t.string "pincode"
    t.bigint "student_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["student_id"], name: "index_guardian_details_on_student_id"
  end

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.bigint "resource_owner_id"
    t.bigint "application_id", null: false
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.string "scopes"
    t.datetime "created_at", null: false
    t.datetime "revoked_at"
    t.string "previous_refresh_token", default: "", null: false
    t.index ["application_id"], name: "index_oauth_access_tokens_on_application_id"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", force: :cascade do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.text "redirect_uri"
    t.string "scopes", default: "", null: false
    t.boolean "confidential", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "parent_details", force: :cascade do |t|
    t.string "qualification_of_father"
    t.string "occupation_of_father"
    t.string "father_company_name"
    t.string "father_designation"
    t.string "father_office_address"
    t.string "father_annual_income"
    t.string "father_professional_email"
    t.string "qualification_of_mother"
    t.string "mother_company_name"
    t.string "mother_designation"
    t.string "mother_office_address"
    t.string "mother_annual_income"
    t.string "mother_professional_email"
    t.string "date_of_marriage"
    t.bigint "student_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["student_id"], name: "index_parent_details_on_student_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.string "resource_type"
    t.bigint "resource_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource"
  end

  create_table "semesters", force: :cascade do |t|
    t.bigint "branch_id", null: false
    t.string "name"
    t.integer "number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "number_of_divisions", default: 0
    t.index ["branch_id"], name: "index_semesters_on_branch_id"
  end

  create_table "students", force: :cascade do |t|
    t.string "name"
    t.string "enrollment_number"
    t.bigint "course_id", null: false
    t.bigint "branch_id", null: false
    t.bigint "semester_id", null: false
    t.boolean "fees_paid", default: false
    t.string "gender"
    t.string "father_name"
    t.string "mother_name"
    t.string "date_of_birth"
    t.string "birth_place"
    t.string "religion"
    t.string "caste"
    t.string "nationality"
    t.string "mother_tongue"
    t.string "marrital_status"
    t.string "blood_group"
    t.boolean "physically_handicapped"
    t.string "otp"
    t.datetime "otp_generated_at"
    t.bigint "division_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id"], name: "index_students_on_branch_id"
    t.index ["course_id"], name: "index_students_on_course_id"
    t.index ["division_id"], name: "index_students_on_division_id"
    t.index ["semester_id"], name: "index_students_on_semester_id"
  end

  create_table "subjects", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.bigint "semester_id", null: false
    t.bigint "course_id", null: false
    t.bigint "branch_id", null: false
    t.string "category"
    t.string "lecture"
    t.string "tutorial"
    t.string "practical"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id"], name: "index_subjects_on_branch_id"
    t.index ["course_id"], name: "index_subjects_on_course_id"
    t.index ["semester_id"], name: "index_subjects_on_semester_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "first_name"
    t.string "last_name"
    t.string "mobile_number"
    t.integer "gender"
    t.text "contact_address"
    t.text "permanent_address"
    t.boolean "status", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "designation"
    t.string "department"
    t.datetime "date_of_joining"
    t.bigint "course_id"
    t.bigint "branch_id"
    t.integer "user_type"
    t.string "otp"
    t.datetime "otp_generated_at"
    t.boolean "show"
    t.text "secure_id"
    t.index ["branch_id"], name: "index_users_on_branch_id"
    t.index ["course_id"], name: "index_users_on_course_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "role_id"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

  add_foreign_key "address_details", "students"
  add_foreign_key "branches", "courses"
  add_foreign_key "contact_details", "students"
  add_foreign_key "divisions", "semesters"
  add_foreign_key "guardian_details", "students"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "users", column: "resource_owner_id"
  add_foreign_key "parent_details", "students"
  add_foreign_key "semesters", "branches"
  add_foreign_key "students", "branches"
  add_foreign_key "students", "courses"
  add_foreign_key "students", "divisions"
  add_foreign_key "students", "semesters"
  add_foreign_key "subjects", "branches"
  add_foreign_key "subjects", "courses"
  add_foreign_key "subjects", "semesters"
  add_foreign_key "users", "branches"
  add_foreign_key "users", "courses"
end
