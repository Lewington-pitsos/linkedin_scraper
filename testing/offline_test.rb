require "minitest/autorun"

require_relative '../rubyscripts/archivist'

TEST_DB = 'linkedin_test'

SAMPLE_EMPLOYER = {
  name: 'Newgate Communications – Australia',
  url: 'https://www.linkedin.com/company/3267679/?lipi=urn%3Ali%3Apage%3Ad_flagship3_profile_view_base%3B3QBculZ%2FRlGYHpYZiif6gw%3D%3D&licu=urn%3Ali%3Acontrol%3Ad_flagship3_profile_view_base-background_details_company',
  location: 'Sydney, NSW',
  size: '1000-5000 employees',
  website: 'http://www.newgatecomms.com.au'
 }

 SAMPLE_NEW_EMPLOYER = {
   name: 'Newgate Communications – Greece',
   url: 'https://www.linkedin.com/company/3267679/?lipi=urn%3Ali%3Apage%3Ad_flagship3_profile_view_base%3B3QBculZ%2FRlGYHpYZiif6gw%3D%3D&licu=urn%3Ali%3Acontrol%3Ad_flagship3_profile_view_base-background_details_company',
   location: 'Sydney, NSW',
   size: '4000-9000 employees',
   website: 'http://www.newgatecomms.com.au'
  }

 SAMPLE_UPDATED_EMPLOYER = {
   name: 'Newgate Communications – Australia',
   url: 'https://www.linkedin.com/company/3267679/?lipi=urn%3Ali%3Apage%3Ad_flagship3_profile_view_base%3B3QBculZ%2FRlGYHpYZiif6gw%3D%3D&licu=urn%3Ali%3Acontrol%3Ad_flagship3_profile_view_base-background_details_company',
   location: 'Sydney, ACT',
   size: '5000-9000 employees',
   website: 'http://www.nnnn.com.au'
  }

 SAMPLE_PERSON =  {
   url: 'https://www.linkedin.com/in/sophie-mitchell-447471a1/',
   first_name: 'Sophie',
   last_name: 'Mitchell',
   current_job: 'Associate Partner at Newgate Communications – Australia',
   country: 'Australia',
   further_location: 'Melbourne',
   employer_id: 1
 }

 SAMPLE_NEW_PERSON = {
   url: 'https://www.linkedin.com/in/sophie-mitch/',
   first_name: 'Sophie',
   last_name: 'Mitchell',
   current_job: 'Associate Partner at Newgate Communications – Australia',
   country: 'Australia',
   further_location: 'Melbourne',
   employer_id: 1
 }

class OfflineTests < Minitest::Test

  def setup
    @archivist = Archivist.new(TEST_DB)
    @archivist.setup_tables
  end

  def test_archivist_makes_and_kills_tables
    @archivist.clear_database
    assert_raises('ERROR') { @archivist.show_table('people') }
    assert_raises('ERROR') { @archivist.show_table('employers') }
    @archivist.setup_tables
    assert @archivist.show_table('people')
    assert @archivist.show_table('employers')
  end

  def test_archivist_inserts_employer
    @archivist.record_employer(SAMPLE_EMPLOYER)
    refute_empty @archivist.get_all('employers')
    assert_equal "1", @archivist.get_all('employers')[0][0]
  end

  def test_archiveist_inserts_employee
    @archivist.record_employer(SAMPLE_EMPLOYER)
    @archivist.insert_employee(SAMPLE_PERSON)
    @archivist.get_all('people')
    assert_equal "1", @archivist.get_all('people')[0][0]
  end

  def test_archivist_gets_recent_urls
    @archivist.record_employer(SAMPLE_EMPLOYER)
    @archivist.insert_employee(SAMPLE_PERSON)
    assert @archivist.get_recent_employee_urls()
    assert_equal "https://www.linkedin.com/in/sophie-mitchell-447471a1/", @archivist.get_recent_people_urls()[0]
  end

  def test_archivist_updates_employer
    @archivist.record_employer(SAMPLE_EMPLOYER)
    assert_equal 'Newgate Communications – Australia', @archivist.get_all('employers')[0][2]
    @archivist.record_employer(SAMPLE_UPDATED_EMPLOYER)
    assert_equal 'Newgate Communications – Australia', @archivist.get_all('employers')[0][2]
    assert_equal '5000-9000 employees', @archivist.get_all('employers')[0][5]
  end

  def test_archivist_updates_only_when_needed
    @archivist.record_employer(SAMPLE_EMPLOYER)
    assert_equal 'Newgate Communications – Australia', @archivist.get_all('employers')[0][2]
    @archivist.record_employer(SAMPLE_NEW_EMPLOYER)
    assert_equal 'Newgate Communications – Australia', @archivist.get_all('employers')[0][2]
    assert_equal '1000-5000 employees', @archivist.get_all('employers')[0][5]
  end

  def test_picks_up_same_person
    @archivist.record_employer(SAMPLE_EMPLOYER)
    @archivist.insert_employee(SAMPLE_PERSON)
    assert @archivist.get_recent_people_urls()
    assert_equal "https://www.linkedin.com/in/sophie-mitchell-447471a1/", @archivist.get_recent_people_urls()[0]
    assert @archivist.person_already_recorded(SAMPLE_PERSON)
    refute @archivist.person_already_recorded(SAMPLE_NEW_PERSON)
  end

  def test_gets_employer_id
    @archivist.record_employer(SAMPLE_EMPLOYER)
    assert_equal '1', @archivist.get_employer(SAMPLE_EMPLOYER[:name])
  end

  def teardown
    @archivist.clear_database()
  end

end
